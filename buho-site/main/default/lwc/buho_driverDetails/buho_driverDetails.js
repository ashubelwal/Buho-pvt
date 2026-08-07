import { LightningElement, track, api, wire } from 'lwc';
import getCountries from '@salesforce/apex/FinalizeVehicleDetailsFlow.getCountries';
import getStatesByCountry from '@salesforce/apex/FinalizeVehicleDetailsFlow.getStatesByCountry';
import saveDriverDetails from '@salesforce/apex/DriverDetailsFlow.saveDriverDetails';
import updateQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.updateQuoteRecordData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import BUHO_ASSETS from '@salesforce/resourceUrl/buhoAssets';
import { log } from 'c/buho_utils';
export default class Buho_driverDetails extends LightningElement {
    @api payload;
    ISDEBUG = true;
    @track driver = {
        First_Name__c:  '',
        Last_Name__c:  '',
        License_Country__c: 'United States',
        License_state__c: '',
        license_number__c: '',
        Dob__c: '',
        Driver_Type__c: false // Drivers are not owners
    }
    @track selectedDriverId = '';

    @track flag = {
        isStateDisabled: false,
        flatpickrInitialized: false
    };

    @track drivers = [];
    @track existingDriversList = [];
    @track loginUserDriverOption = [];
    @track userType;
    @track countryOptions = [];
    @track stateOptions = [];
    flatpickrInstance;
    __currentUserDetails;

    // Getters
    get currentUserType() {
        if (!this.payload || !Array.isArray(this.payload)) return false;
        const existingIndex = this.payload.findIndex(item => Object.keys(item)[0] === "UserType");
        if (existingIndex !== -1) {
            this.userType = "Customer";
            return true;
        }
        return false;
    }

    get formattedDob() {
        if (!this.driver.Dob__c) return '';
        const date = this.parseDateAsLocal(this.driver.Dob__c);
        if (!date) return '';
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
    }

    get minDateAllowed() {
        let today = new Date();
        today.setFullYear(today.getFullYear() - 16);
        return today.toISOString().split('T')[0];
    }

    // Input Handlers
    handleInputChange(event) {
        try {
            const name = event.detail?.name || event.target?.name;
            const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
            const type = event.detail?.type || event.target?.type;

            if (this.ISDEBUG) console.log('DD handleInputChange:', { name, value, type });

            // Handle license number uppercase
            if (name === 'license_number__c') {
                let upperValue = (value || '').toUpperCase();
                if (upperValue.length > 40) upperValue = upperValue.substring(0, 40);
                this.driver = { ...this.driver, [name]: upperValue };
                return;
            }

            // Default - update driver fields
            this.driver = { ...this.driver, [name]: value };
        } catch (err) {
            console.log('DD ERROR in handleInputChange: ', err.message);
        }
    }

    handleCountryChange(event) {
        const value = event.detail?.value || event.target?.value;
        this.driver = { ...this.driver, License_Country__c: value, License_state__c: '' };
        this.loadStatesForCountry(value);
    }

    handleStateChange(event) {
        const value = event.detail?.value || event.target?.value;
        this.driver = { ...this.driver, License_state__c: value };
    }

    // Driver Selection (for returning customers)
    changeDriverOption(event) {
        try {
            const selectedDriverId = event.detail?.value || event.target?.value;
            this.selectedDriverId = selectedDriverId;

            const selectedDriver = this.loginUserDriverOption.find(driver => driver.value === selectedDriverId);
            if (selectedDriver) {
                this.driver = {
                    ...this.driver,
                    Id: selectedDriver.Id || null,
                    First_Name__c: selectedDriver.First_Name__c || '',
                    Last_Name__c: selectedDriver.Last_Name__c || '',
                    License_Country__c: selectedDriver.License_Country__c || 'United States',
                    License_state__c: selectedDriver.License_state__c || '',
                    license_number__c: selectedDriver.license_number__c || '',
                    Dob__c: selectedDriver.Dob__c || '',
                    Driver_Type__c: false // All additional drivers are not owners
                };

                if (this.driver.License_Country__c) {
                    this.loadStatesForCountry(this.driver.License_Country__c);
                }
            }
        } catch (error) {
            console.error('Error changing driver option:', error);
        }
    }

    // Country / State wiring
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            this.countryOptions = data.map(country => ({ label: country, value: country }));
            this.loadStatesForCountry(this.driver.License_Country__c || 'United States');
        } else if (error) {
            console.error('Error loading countries', error);
        }
    }

    loadStatesForCountry(country) {
        if (country) {
            this.flag.isStateDisabled = true;
            getStatesByCountry({ country: country })
                .then(result => {
                    // Add blank option at the beginning
                    this.stateOptions = [
                        { label: '-- None --', value: '' },
                        ...result.map(state => ({ label: state, value: state }))
                    ];
                    this.flag.isStateDisabled = false;

                    if (this.driver.License_Country__c === country && this.driver.License_state__c) {
                        const stateExists = this.stateOptions.some(opt => opt.value === this.driver.License_state__c);
                        if (!stateExists) {
                            this.driver.License_state__c = '';
                        }
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.stateOptions = [{ label: '-- None --', value: '' }];
                    this.flag.isStateDisabled = false;
                    this.driver.License_state__c = '';
                });
        } else {
            this.stateOptions = [{ label: '-- None --', value: '' }];
            this.flag.isStateDisabled = true;
            this.driver.License_state__c = '';
        }
    }

    // Validate Driver
    validateDriver() {
        const inputs = this.template.querySelectorAll('c-buho_input, input[required]');
        let allValid = true;

        inputs.forEach(input => {
            if (input && input.required) {
                if (typeof input.checkValidity === 'function' && !input.checkValidity()) {
                    try { input.reportValidity(); } catch (e) { }
                    allValid = false;
                } else if (typeof input.reportValidity === 'function' && !input.reportValidity()) {
                    allValid = false;
                }
            }
        });

        if (this.ISDEBUG) console.log('DD Validating driver:', this.driver);

        if (!allValid) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Validation Error', message: 'Please fill in all required fields.' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        if (!this.driver.First_Name__c || !this.driver.Last_Name__c) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: 'First and Last name are required' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        if (!this.driver.license_number__c) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: 'License number is required' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        if (!this.driver.License_state__c) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: 'License state is required' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        return true;
    }

    // Add Driver
    addDriver() {
        if (!this.validateDriver()) return;

        // Check for duplicate license number
        if (this.drivers.length > 0) {
            const isDuplicate = this.drivers.some(driver =>
                driver.license_number__c === this.driver.license_number__c
            );
            if (isDuplicate) {
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: 'Driver with this license number already exists.' },
                    bubbles: true,
                    composed: true
                }));
                return;
            }
        }

        const newDriver = {
            ...this.driver,
            diff: this.driver.Id || `driver-${Date.now()}`,
            Driver_Type__c: false // All drivers added here are not owners
        };

        this.drivers = [...this.drivers, newDriver];

        // Reset form
        this.driver = {
            First_Name__c: '',
            Last_Name__c: '',
            License_Country__c: 'United States',
            License_state__c: '', // Reset to empty so "None" is shown
            license_number__c: '',
            Dob__c: (() => {
                let today = new Date();
                today.setFullYear(today.getFullYear() - 16);
                return today.toISOString().split('T')[0];
            })(),
            Driver_Type__c: false
        };

        this.selectedDriverId = '';

        // Reload states for United States to show "None" option
        this.loadStatesForCountry('United States');

        this.dispatchEvent(new CustomEvent('toastevent', {
            detail: { variant: 'success', title: 'Success', message: 'Driver added successfully!' },
            bubbles: true,
            composed: true
        }));

        // Reinitialize flatpickr
        this.flag.flatpickrInitialized = false;
    }

    // Edit Driver
    editDriver(event) {
        const index = parseInt(event.currentTarget.dataset.index, 10);
        if (isNaN(index) || index < 0 || index >= this.drivers.length) return;

        this.driver = { ...this.drivers[index] };
        this.drivers = this.drivers.filter((_, i) => i !== index);

        if (this.driver.License_Country__c) {
            this.loadStatesForCountry(this.driver.License_Country__c);
        }

        // Reinitialize flatpickr
        this.flag.flatpickrInitialized = false;
    }

    // Delete Driver
    deleteDriver(event) {
        const index = parseInt(event.currentTarget.dataset.index, 10);
        if (isNaN(index)) return;
        this.drivers = this.drivers.filter((_, i) => i !== index);

        this.dispatchEvent(new CustomEvent('toastevent', {
            detail: { variant: 'success', title: 'Success', message: 'Driver deleted successfully!' },
            bubbles: true,
            composed: true
        }));
    }

    // Date Handling
    parseDateAsLocal(dateStr) {
        if (!dateStr) return null;
        const parts = dateStr.includes('/') ? dateStr.split('/') : dateStr.split('-');
        if (parts.length !== 3) return null;

        let year, month, day;
        if (dateStr.includes('/')) {
            [month, day, year] = parts;
        } else {
            [year, month, day] = parts;
        }

        return new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
    }

    formatDateForApi(date) {
        if (!date) return '';
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    // Lifecycle
    connectedCallback() {
        if (this.ISDEBUG) console.log('DD connectedCallback - Payload:', JSON.stringify(this.payload));

        if (!this.driver.License_Country__c) {
            this.driver.License_Country__c = 'United States';
        }
        this.loadStatesForCountry(this.driver.License_Country__c);

        // Load existing drivers from payload
        if (this.payload) {
            const driverPayload = this.payload.find(item => item?.driverDetails)?.driverDetails;
            const existingDrivers = driverPayload?.driverList || [];
            const addedDrivers = driverPayload?.drivers || [];
            this.__currentUserDetails = this.payload.find(item => item?.userDetails)?.userDetails;
            
            // Load all drivers (owner will be selected in next step)
            if ((!this.drivers || this.drivers.length === 0) && addedDrivers.length > 0) {
                this.drivers = addedDrivers.map(d => {
                    if (d.Driver_Type__c !== 'Owner & Driver') {
                        return { ...d, Driver_Type__c: false };
                    }
                    return d;
                })
            }

            this.existingDriversList = existingDrivers.map(d => ({
                ...d,
                label: `${d.First_Name__c} ${d.Last_Name__c}`,
                value: d.Id || `temp-${Math.random().toString(36).substr(2, 9)}`
            }));

            this.loginUserDriverOption = [
                //{ label: '-- Select a Driver --', value: '' },
                ...this.existingDriversList
            ];
            if(this.drivers.length == 0 && this.__currentUserDetails) {
                log('populating values');
                this.driver.First_Name__c = this.__currentUserDetails.FirstName;
                this.driver.Last_Name__c = this.__currentUserDetails.LastName;
            }
        }

        if (!this.driver.Dob__c) {
            let today = new Date();
            today.setFullYear(today.getFullYear() - 16);
            this.driver.Dob__c = today.toISOString().split('T')[0];
        }
    }

    renderedCallback() {

        // Initialize Flatpickr for Date of Birth
        if (!this.flag.flatpickrInitialized) {
            Promise.all([
                loadScript(this, BUHO_ASSETS + '/js/flatpickr.js')
            ]).then(() => {
                console.log('script loaded initializing js');
                this.initializeFlatpickr();
            }).catch(error => {
                console.error('Flatpickr failed to load', error);
            });

        }
    }

    initializeFlatpickr() {
        const dobInput = this.template.querySelector('.dobDate');

        if (!dobInput || typeof flatpickr === 'undefined') {
            return;
        }

        try {
            const maxDate = new Date();
            maxDate.setFullYear(maxDate.getFullYear() - 46);

            // Fixed: Proper date parsing that handles Salesforce date format
            let dobObj = maxDate; // Default to maxDate

            if (this.driver.Dob__c) {
                // Parse the date string correctly (assuming format: YYYY-MM-DD from Salesforce)
                const parts = this.driver.Dob__c.split('-');
                if (parts.length === 3) {
                    // Create date in local timezone: new Date(year, monthIndex, day)
                    dobObj = new Date(
                        parseInt(parts[0], 10),  // year
                        parseInt(parts[1], 10) - 1,  // month (0-indexed)
                        parseInt(parts[2], 10)   // day
                    );
                }
            }

            console.log('dobObj', dobObj);
            console.log('Original Dob__c', this.driver.Dob__c);

            this.flatpickrInstance = flatpickr(dobInput, {
                dateFormat: 'm/d/Y',
                maxDate: new Date(),
                minDate: new Date(1900, 0, 1), // Jan 1, 1900 (month is 0-based)
                allowInput: true,
                clickOpens: true,
                defaultDate: dobObj || null,
                onChange: (selectedDates) => {
                    if (selectedDates.length) {
                        const dob = selectedDates[0];
                        this.driver.Dob__c = this.formatDateForApi(dob);
                    }
                }
            });

            this.flag.flatpickrInitialized = true;
        } catch (error) {
            console.error('DD Error initializing Flatpickr:', error);
        }
    }
    // Continue
    handleContinue() {
        // Dispatch event to parent (wizard) to move to next step
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    // Save Driver Data
    async handleDriverDataSave() {
        console.log('DD handleDriverDataSave called');

        if (!this.currentUserType) {
            // New user - save via saveDriverDetails
            try {
                console.log('DD Saving driver details for new user', this.payload);
                let saveResponse = await saveDriverDetails({ strLeadDetails: JSON.stringify(this.payload) });
                console.log('DD Driver details saved response', saveResponse);
            } catch (err) {
                console.log('DD ERROR: Getting error while saving the Driver Data: ', JSON.stringify(err));
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: 'Failed to save driver details: ' + err.message },
                    bubbles: true,
                    composed: true
                }));
            }
        } else {
            // Existing customer - update via updateQuoteRecordData
            const quotePageObj = this.payload.find(item => item.quotePage);
            const quoteRecord = quotePageObj ? quotePageObj.quotePage.QuoteData : null;

            const vehicleDetailsObj = this.payload.find(item => item.finalizeVehicleDetails);
            const vehicleRecord = vehicleDetailsObj ? vehicleDetailsObj.finalizeVehicleDetails : null;

            const updatedVehicleData = vehicleRecord ? { ...this.processVehicleData(vehicleRecord) } : null;

            const driverDetailsObj = this.payload.find(item => item.driverDetails);
            const driversRecord = driverDetailsObj?.driverDetails?.drivers?.length > 0
                ? driverDetailsObj.driverDetails.drivers
                : '';

            console.log('DD Updating quote record with driver data', driversRecord);

            try {
                const updateVehicleResp = await updateQuoteRecordData({
                    quoteRecord: quoteRecord ? JSON.stringify(quoteRecord) : '',
                    vehicleRecord: vehicleRecord ? JSON.stringify(updatedVehicleData) : '',
                    towedUnitRecord: '',
                    driversRecord: driversRecord ? JSON.stringify(driversRecord) : ''
                });

                if (updateVehicleResp.status == 'success') {
                    console.log('DD Quote record updated successfully');

                    // Update drivers with the response
                    if (updateVehicleResp && Array.isArray(updateVehicleResp.DriversData)) {
                        const normalizedDrivers = updateVehicleResp.DriversData.map(driver => {
                            let type = String(driver.Driver_Type__c || '').toLowerCase();
                            return {
                                ...driver,
                                Driver_Type__c: type === 'true' || type === 'owner'
                            };
                        });

                        // Update our local drivers array with saved IDs
                        this.drivers = normalizedDrivers.filter(d => !d.Driver_Type__c);
                    }
                }
            } catch (err) {
                console.error('DD Error updating quote record data', err);
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: 'Failed to update driver details: ' + err.message },
                    bubbles: true,
                    composed: true
                }));
            }
        }
    }

    processVehicleData(vehicleDetails) {
        if (!vehicleDetails || typeof vehicleDetails !== 'object') return null;

        const fieldsToKeep = [
            'Is_Lienholder__c', 'is_the_vehicle_used_for_business_purpose__c', 'is_there_a_driver_under_21__c',
            'Is_this_a_Rental_Vehicle__c', 'salvage_vehicle__c', 'isTowing', 'Electric_Hybrid__c', 'Year__c',
            'Vehicle_sub_type__c', 'Make', 'Model', 'Value__c', 'Vin__c', 'Registered_Country__c', 'Registered_State__c',
            'Id', 'Make__c', 'Model__c', 'Account_Vehicle__c', 'Contact__c', 'BusinessAddress__c', 'Is_the_vehicle_registered_to_a_business__c'
        ];

        const processedData = {};
        fieldsToKeep.forEach(field => {
            if (vehicleDetails.hasOwnProperty(field)) processedData[field] = vehicleDetails[field];
        });

        if (vehicleDetails.hasOwnProperty('licensePlate')) {
            processedData['Registered_Plate__c'] = vehicleDetails.licensePlate;
        }

        return processedData;
    }

    // Public API Methods (called from wizard)
    @api
    validate() {
        let allValid = true;
        const hasAtLeastOneDriver = this.drivers.length > 0;
        // Validation is optional - drivers can be empty
        if (!hasAtLeastOneDriver) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: '⚠️ Please add at least one driver for company-registered vehicle.' }
            }));
            allValid = false;
        }
        return allValid;
    }

    @api
    async getData() {
        console.log('DD getData() called');

        // Get existing driver details from payload
        const existingDriverDetails = this.payload?.find(item => item?.driverDetails)?.driverDetails;

        // Prepare driver data
        const driverPageData = {
            driverDetails: {
                drivers: this.drivers.map(d => ({
                    ...d,
                    Driver_Type__c:
                        d.Driver_Type__c === 'Owner & Driver'
                            ? d.Driver_Type__c   // keep original value
                            : false              // set false otherwise
                })),
                driverList: existingDriverDetails?.driverList || [],
                companyInformation: existingDriverDetails?.companyInformation || {}
            }
        };
        console.log('DD getData driverPageData:', driverPageData);

        // Update payload BEFORE calling save (critical for Apex to receive correct data)
        const driverPageIndex = this.payload.findIndex(item => item.driverDetails);
        if (driverPageIndex >= 0) {
            this.payload = [
                ...this.payload.slice(0, driverPageIndex),
                driverPageData,
                ...this.payload.slice(driverPageIndex + 1)
            ];
        } else {
            this.payload = [...this.payload, driverPageData];
        }

        if (this.ISDEBUG) {
            console.log('DD payload after update', this.payload);
        }

        // Now save driver data with updated payload
        await this.handleDriverDataSave();

        // Return data WITHOUT outer key - wizard will wrap it with step name
        const data = {
            drivers: this.drivers,
            driverList: existingDriverDetails?.driverList || [],
            companyInformation: existingDriverDetails?.companyInformation || {}
        };

        console.log('DD getData returning:', data);
        return data;
    }
}
