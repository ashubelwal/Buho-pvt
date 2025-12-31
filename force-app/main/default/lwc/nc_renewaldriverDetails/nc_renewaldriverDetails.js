// LWC Imports and Apex method references
import { LightningElement, track, api, wire } from 'lwc';
import getCountries from '@salesforce/apex/FinalizeVehicleDetailsFlow.getCountries';
import getStatesByCountry from '@salesforce/apex/FinalizeVehicleDetailsFlow.getStatesByCountry';
import saveDriverDetails from '@salesforce/apex/DriverDetailsFlow.saveDriverDetails';
import saveCompanyInformationDetails from '@salesforce/apex/CompanyInformationDetailFlow.saveCompanyInformationDetails';
import saveFinalizeVehicleDetails from '@salesforce/apex/FinalizeVehicleDetailsFlow.saveFinalizeVehicleDetails';
import updateQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.updateQuoteRecordData';
import Selectadriverfromyouraccount from '@salesforce/label/c.TR_Select_a_driver_from_your_account';

export default class Nc_renewaldriverDetails extends LightningElement {
    @api payload;
    ISDEBUG = true;
    @api editpolicydata;
    @api changesnextscreen;
    @api changeprevscreen;

    label = {
        Selectadriverfromyouraccount
    };


    // Track user-entered input values for drivers and company information
    @track inputValues = {
        drivers: [],
        companyInformation: {}
    };

    // Template for driver details
    @track driver = {
        First_Name__c: '',
        Last_Name__c: '',
        License_Country__c: '', // Default value
        License_state__c: '',
        license_number__c: '',
        Dob__c: '',
        Driver_Type__c: false,
        Country__c: '',
        Country_Text__c: '',
        State_Province__c: '',
        Postal_Code__c: '',
        City__c: '',
        Address__c: ''
    };

    // Track multiple booleans to manage UI state and logic
    @track flag = {
        isOwner: false,
        isCompanyDisabled: false,
        isCompanyStatus: false,
        isStateDisabled: true,
        Is_the_vehicle_registered_to_a_business__c: false
    }

    @track drivers = [];
    @track existingDriversList = []
    @track loginUserDriverOption = [];
    @track flagForRender = true;
    @track userType;

    get currentUserType() {
        const existingIndex = this.payload.findIndex(item =>
            Object.keys(item)[0] === "UserType"
        );
        if (existingIndex != -1) {
            this.userType = "Customer";
            return true;
        }
        return false;
    }

    // Fetch and map country options on component load
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            this.countryOptions = data.map(country => {
                return { label: country, value: country };
            });
        } else if (error) {
            console.error('Error loading countries', error);
        }
    }

    countryOptions = [
        { label: 'USA', value: 'USA' },
        { label: 'Canada', value: 'Canada' },
        { label: 'Mexico', value: 'Mexico' },
        { label: 'India', value: 'India' }
    ];

    stateOptions = [
        { label: 'Select a state', value: 'Select a state' }
    ];

    // Dynamically calculate min allowed date of birth (16 years old)
    get minDateAllowed() {
        let today = new Date();
        today.setFullYear(today.getFullYear() - 16);
        return today.toISOString().split('T')[0];


        // let today = new Date();
        // today.setFullYear(today.getFullYear() - 16);
        // if (this.driver){ this.driver.Dob__c = today.toISOString().split('T')[0];}
        // return today.toISOString().split('T')[0];
    }

    // Handle input field changes and conditionally update state and country
    handleChange(event) {
        try {
            // console.log('DD Driver Data in driver input change', this.driver);
            // console.log('DD Driver data Array in input change', this.drivers);
            const { name, checked, value, type } = event.target;
            this.driver = { ...this.driver, [name]: type === 'checkbox' ? checked : value };

            if (name === 'license_number__c') {
                let upperValue = value.toUpperCase();
                if (upperValue.length > 17) {
                    upperValue = upperValue.substring(0, 17);
                }
                this.driver = { ...this.driver, [name]: upperValue };
                this.isCompanyOrDriverOwner();
                return; // Exit early to avoid duplicate updates
            }

            if (name === 'Is_the_vehicle_registered_to_a_business__c') {
                this.flag.isCompanyStatus = checked;
                this.flag.Is_the_vehicle_registered_to_a_business__c = checked;

                if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
                    this.loginUserDriverOption = this.loginUserDriverOption.filter(driver => !driver.Driver_Type__c);
                } else {
                    const existingAllDrivers = this.payload.find(item => item?.driverDetails?.drivers)?.driverDetails?.driverList;
                    if (existingAllDrivers) {
                        if (Array.isArray(existingAllDrivers) && existingAllDrivers.length > 0) {
                            this.loginUserDriverOption = [...existingAllDrivers];
                            // console.log('DD Login User Driver Option : ', this.loginUserDriverOption);
                        }
                    }
                }


                // Update finalizeVehicleDetails section
                let newPayload = JSON.parse(JSON.stringify(this.payload));
                const finalizeIndex = newPayload.findIndex(item => item.finalizeVehicleDetails);
                if (finalizeIndex >= 0) {
                    newPayload[finalizeIndex].finalizeVehicleDetails = {
                        ...newPayload[finalizeIndex].finalizeVehicleDetails,
                        Is_the_vehicle_registered_to_a_business__c: this.flag?.Is_the_vehicle_registered_to_a_business__c
                    };
                } else {
                    newPayload.push({
                        finalizeVehicleDetails: {
                            Is_the_vehicle_registered_to_a_business__c: this.flag?.Is_the_vehicle_registered_to_a_business__c
                        }
                    });
                }

                // Update local reference
                this.payload = newPayload;
                this.dispatchPayloadUpdate({
                    Is_the_vehicle_registered_to_a_business__c: this.flag?.Is_the_vehicle_registered_to_a_business__c
                });
            }

            // if (name === 'License_Country__c') {
            //     this.driver = { ...this.driver, [name]: value };
            //     this.driver.License_state__c = '';
            //     this.stateOptions = [];

            //     if (this.driver.License_Country__c) {
            //         getStatesByCountry({ country: this.driver.License_Country__c })
            //             .then(result => {
            //                 this.stateOptions = result.map(state => {
            //                     return { label: state, value: state };
            //                 });
            //                 this.flag.isStateDisabled = false;
            //             })
            //             .catch(error => {
            //                 console.error('DD ERROR: loading states', error);
            //                 this.flag.isStateDisabled = false;
            //             });
            if (name === 'License_Country__c') {
                // Set the selected value or default to 'United States'
                const selectedCountry = value || 'United States';

                this.driver = { ...this.driver, [name]: selectedCountry };
                this.driver.License_state__c = '';
                this.stateOptions = [];

                if (this.driver.License_Country__c) {
                    getStatesByCountry({ country: this.driver.License_Country__c })
                        .then(result => {
                            this.stateOptions = result.map(state => {
                                return { label: state, value: state };
                            });
                            this.flag.isStateDisabled = false;
                        })
                        .catch(error => {
                            console.error('DD ERROR: loading states', error);
                            this.flag.isStateDisabled = false;
                        });
                }
            }

            this.isCompanyOrDriverOwner();
        } catch (err) {
            console.log('DD ERROR: ', err.message);
        }
    }

    updateLoginUserDriverOption() {
        const hasOwner = this.drivers?.some(driver => driver.Driver_Type__c === true);
        const isBusinessVehicle = this.flag?.Is_the_vehicle_registered_to_a_business__c === true;

        if (hasOwner || isBusinessVehicle) {
            // If owner is present OR vehicle is registered to business,
            // remove owner-type drivers from dropdown
            this.loginUserDriverOption = this.existingDriversList.filter(driver => !driver.Driver_Type__c);
        } else {
            // Otherwise, show all drivers
            this.loginUserDriverOption = [...this.existingDriversList];
        }
    }

    // Handle dropdown selection from custom child component
    handleOptionClick(event) {
        const { name, value } = event.detail;
        const fieldLabel = event.detail.inputName;
        const selectedValue = event.detail.value;

        if (fieldLabel === 'License_Country__c') {
            this.driver = { ...this.driver, [fieldLabel]: value };
            this.driver.License_state__c = '';
            this.stateOptions = [];

            if (this.driver.License_Country__c) {
                this.handleComboboxReset(name);
                getStatesByCountry({ country: this.driver.License_Country__c })
                    .then(result => {
                        this.stateOptions = result.map(state => {
                            return { label: state, value: state };
                        });
                        this.flag.isStateDisabled = false;
                    })
                    .catch(error => {
                        console.error('Error loading states', error);
                        this.flag.isStateDisabled = false;
                    });
            }
        }

        if (fieldLabel === 'License_state__c') {
            this.driver = { ...this.driver, [fieldLabel]: value };
        }
    }

    // Handle event from child combobox for resetting related fields
    handleChildComboboxReset(event) {
        if (event.detail === 'License Country') {
            this.handleComboboxReset(event.detail);
        }
    }

    // Resets dependent comboboxes when a higher-level option is changed
    handleComboboxReset(value) {
        if (value === 'License Country') {
            const comboboxes = this.template.querySelectorAll('c-nc_combobox');
            if (comboboxes) {
                comboboxes.forEach((combobox) => {
                    if (combobox.name === 'License_state__c') {
                        combobox.handleReset();
                    }
                });

                this.stateOptions = [{ label: 'Select a state', value: 'Select a state' }];
            }
        }
    }

    // Handles additional input values selected from dropdowns
    handleAddValue(event) {
        const { value, name } = event.detail;
        if (name === 'License_Country__c') {
            this.driver = { ...this.driver, [name]: value };
            this.flag.isStateDisabled = false;
        } else if (name === 'License_state__c') {
            this.driver = { ...this.driver, [name]: value };
        }
    }

    // Add the selected driver in the list
    changeDriverOption(event) {
        // Get the selected driver ID from the combobox
        const selectedDriverId = event.detail.value;

        // Find the selected driver in the loginUserDriverOption array
        const selectedDriver = this.loginUserDriverOption.find(
            driver => driver.value === selectedDriverId
        );

        // If a driver is found, update the driver object with its values
        if (selectedDriver) {
            this.driver = {
                First_Name__c: selectedDriver.First_Name__c || '',
                Last_Name__c: selectedDriver.Last_Name__c || '',
                License_Country__c: selectedDriver.License_Country__c || '',
                License_state__c: selectedDriver.License_state__c || '',
                license_number__c: selectedDriver.license_number__c || '',
                Dob__c: selectedDriver.Dob__c || '',
                Driver_Type__c: selectedDriver.Driver_Type__c || false,
                Country__c: selectedDriver.Country__c || '',
                Country_Text__c: selectedDriver.Country_Text__c || '',
                State_Province__c: selectedDriver.State_Province__c || '',
                Postal_Code__c: selectedDriver.Postal_Code__c || '',
                City__c: selectedDriver.City__c || '',
                Address__c: selectedDriver.Address__c || ''
            };
        } else {
            // If no driver is selected, reset the driver object
            this.driver = {
                First_Name__c: '',
                Last_Name__c: '',
                License_Country__c: '',
                License_state__c: '',
                license_number__c: '',
                Dob__c: '',
                Driver_Type__c: false,
                Country__c: '',
                Country_Text__c: '',
                State_Province__c: '',
                Postal_Code__c: '',
                City__c: '',
                Address__c: ''
            };
        }
    }

    // Adds driver to the list and resets the form
    addDriver() {
        if (!this.validateDriver()) {
            console.log('DD Add Driver - Fields are missing');
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Fields are missing' } }));
            return;
        }

        if (this.driver.First_Name__c && this.driver.Last_Name__c) {
            this.drivers = [...this.drivers, { ...this.driver, diff: Date.now() }];
            this.isCompanyOrDriverOwner();
            this.driver = {
                First_Name__c: '',
                Last_Name__c: '',
                License_Country__c: '',
                License_state__c: '',
                license_number__c: '',
                Dob__c: '',
                Driver_Type__c: false,
                Country__c: '',
                Country_Text__c: '',
                State_Province__c: '',
                Postal_Code__c: '',
                City__c: '',
                Address__c: ''
            };

            console.log('DD OUTPUT Driver Data', this.drivers);
        }
    }

    // Always keep your driver data up-to-date
    updateLoginUserDriverOption() {
        const hasOwner = this.drivers?.some(driver => driver.Driver_Type__c === true);

        if (hasOwner) {
            this.loginUserDriverOption = this.existingDriversList.filter(driver => !driver.Driver_Type__c);
        } else {
            this.loginUserDriverOption = [...this.existingDriversList];
        }
    }


    // Checks if at least one driver is marked as owner and updates related flags
    isCompanyOrDriverOwner() {
        this.flag.isOwner = this.drivers.some(driver => driver.Driver_Type__c === true);
        this.flag.isCompanyDisabled = this.flag.isOwner;

        if (this.flag.isCompanyStatus) {
            this.flag.isOwner = true
        }

        this.updateLoginUserDriverOption();
    }

    // Allows editing an existing driver entry by removing it and pre-filling the form
    editDriver(event) {
        const index = event.target.dataset.index;
        this.driver = { ...this.drivers[index] };
        this.drivers.splice(index, 1);
        this.isCompanyOrDriverOwner();
    }

    // Deletes a driver entry based on index
    deleteDriver(event) {
        const index = event.target.dataset.index;
        this.drivers = this.drivers.filter((_, i) => i !== parseInt(index, 10));
        this.isCompanyOrDriverOwner();
    }

    // Populates the driver object with address received from the company section
    handleCompanyAddress(event) {
        let fetchaddress = JSON.parse(event.detail);

        this.driver = {
            ...this.driver,
            Driver_Type__c: true,
            Country__c: fetchaddress.Country || null,
            Country_Text__c: fetchaddress.Country || null,
            State_Province__c: fetchaddress.State || null,
            Postal_Code__c: fetchaddress.PostalCode || null,
            City__c: fetchaddress.City || null,
            Address__c: fetchaddress.Address || null,
        };
    }

    // Sends driver details to Apex for saving
    async handleDriverDataSave() {
        // console.log('DD Update payload in handleDriverDataSave', this.payload);
        if (!this.currentUserType) {
            saveDriverDetails({ strLeadDetails: JSON.stringify(this.payload) })
                .then(result => {
                    // console.log('DD Res from saving Driver Data: ', result);
                })
                .catch(err => {
                    console.log('DD ERROR: Getting error while saving the Driver Data: ', JSON.stringify(err));
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: JSON.stringify(err) } }));
                })
        } else {
            // Prepare the data
            // console.log('DD Payload data while updating payload in the Driver-Company Save', this.payload);
            const quotePageObj = this.payload.find(item => item.quotePage);
            const quoteRecord = quotePageObj ? quotePageObj.quotePage.QuoteData : null;

            const vehicleDetailsObj = this.payload.find(item => item.finalizeVehicleDetails);
            const vehicleRecord = vehicleDetailsObj ? vehicleDetailsObj.finalizeVehicleDetails : null;
            // console.log('DD Vehicle Record while saving the company information', vehicleRecord);
            // Process vehicle data and merge with lienholder info
            const updatedVehicleData = {
                ...this.processVehicleData(vehicleRecord)
            };
            // console.log('DD Updated vehicle data', updatedVehicleData);

            // Get driver details from payload
            const driverDetailsObj = this.payload.find(item => item.driverDetails);
            const driversRecord = driverDetailsObj?.driverDetails?.drivers?.length > 0
                ? driverDetailsObj.driverDetails.drivers
                : '';
            // console.log('DD Driver Data while saving', driversRecord);
            // Call Apex method with properly formatted data
            const updateVehicleResp = await updateQuoteRecordData({
                quoteRecord: quoteRecord ? JSON.stringify(quoteRecord) : '',
                vehicleRecord: vehicleRecord ? JSON.stringify(updatedVehicleData) : '',
                towedUnitRecord: '',
                driversRecord: driversRecord ? JSON.stringify(driversRecord) : ''
            }); //console.log('DD Data update in contact', updateVehicleResp);
            if (updateVehicleResp.status == 'success') {
                //console.log('DD Data update in contact', updateVehicleResp);
                // Update inputValues with the new DriversData

                if (updateVehicleResp && Array.isArray(updateVehicleResp.DriversData)) {
                    updateVehicleResp.DriversData = await updateVehicleResp.DriversData.map(driver => {
                        let type = String(driver.Driver_Type__c || '').toLowerCase();
                        return {
                            ...driver,
                            Driver_Type__c: type === 'true' || type === 'owner'
                        };
                    });
                }

                this.inputValues = {
                    ...this.inputValues,  // Keep existing values
                    drivers: updateVehicleResp.DriversData ?
                        [...updateVehicleResp.DriversData] :  // Copy new drivers data if exists
                        [...this.drivers],                   // Fallback to existing drivers
                    companyInformation: this.inputValues.companyInformation || {}  // Preserve company info
                };
            }

            console.log('DD OUTPUT updateVehicleResp: ', JSON.stringify(updateVehicleResp));
            console.log('DD OUTPUT inputValues: ', JSON.stringify(this.inputValues));
        }
    }

    // Receives updated company information from child and stores it
    handleCompanyInfoUpdate(event) {
        this.inputValues = {
            ...this.inputValues,
            companyInformation: event.detail.companyInformation
        };
    }

    // Saves company information by calling Apex
    async handleCompanyDataSave() {
        await saveCompanyInformationDetails({ strLeadDetails: JSON.stringify(this.payload) })
            .then((result) => {
                if (result.Status === 'Success') {
                    console.log('Company data inserted successfully', result);
                } else if (result.Status === 'Error') {
                    console.error('Error in inserting Compny data', result);
                }
            })
            .catch((error) => {
                if (this.ISDEBUG) console.error('Error in inserting vehicle data', error);
            });
    }

    // Fields validation whiel adding a new driver
    validateDriver() {
        const inputs = this.template.querySelectorAll('input, c-nc_combobox, lightning-input, lightning-checkbox-group, lightning-radio-group, lightning-combobox, input[type="radio"]');
        let allValid = true;

        inputs.forEach(input => {
            const { required } = input;

            if (required && !input.checkValidity()) {
                input.classList.add('slds-has-error'); // Add error styling
                input.reportValidity(); // Show validation message
                allValid = false;
            } else {
                input.classList.remove('slds-has-error'); // Remove error styling if valid                
            }
        });

        if (!allValid) {
            console.error('vehicleDetails - validate - Some required fields are invalid. Please fix the errors and try again.');
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Some required fields are invalid.' } }));
            // this.inputValues = values; // Update with valid values                     
            return false;
        }
        return true;  // Valid if fields are filled
    }

    // Validate all the condition when user click on continue button
    @api validate() {
        try {
            let allValid = true;
            console.log('Flag Data',this.flag);
            if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
                // Validate child component(s)
                const childCmp = this.template.querySelector('c-nc_company-information');

                const isInvalidDriver = this.drivers.length > 0 && this.drivers.some(driver => !driver.Driver_Type__c);
                if (!isInvalidDriver) {
                    allValid = false; // Driver is not valid (i.e. condition failed), so show error and block
                    console.log('DD ⚠️ Driver is not added correctly.');
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: '⚠️ Driver is not added correctly.' } }));
                } else if (childCmp && !childCmp.validateInputs()) {
                    allValid = false; // Company fields are invalid
                    console.log('DD ⚠️ Company Information is invalid.');
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: '⚠️ Driver is not added correctly.' } }));
                } else {
                    console.log('DD ✅ All validations passed: drivers + company info.');
                }
            } else if (!(this.drivers.length >= 1 && this.drivers.some(driver => driver.Driver_Type__c === true))) {
                allValid = false;
                console.log('DD -- Error: there should be one owner ');
                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: '⚠️ Driver is not added correctly.' } }));
            } else {
                if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
                    // Business vehicle: All drivers should have Driver_Type__c !== true
                    const hasInvalidTypes = this.drivers.length > 0 && this.drivers.every(driver => driver.Driver_Type__c !== true);
                    if (!hasInvalidTypes) {
                        console.error('❌ Validation failed: All drivers must have Driver_Type__c set to false/null when registered to a business.');
                    }
                } else {
                    // Personal vehicle: At least one driver must have Driver_Type__c === true
                    const hasValidType = this.drivers.length > 0 && this.drivers.some(driver => driver.Driver_Type__c === true);
                    if (!hasValidType) {
                        console.error('❌ Validation failed: At least one driver with Driver_Type__c === true is required for personal vehicle registration.');
                    }
                }
            }

            if (!allValid) {
                console.error('vehicleDetails - validate - Some required fields are invalid. Please fix the errors and try again.');
                return false;
            }
            return true;  // Valid if fields are filled
        } catch (err) {
            console.log('RDD OUTPUT : ', err.message);
        }
    }

    @api afterValidateCheck() {
        console.log('in the afterValidateCheck method ');
        if (!this.flag.isOwner && !this.flag.isCompanyStatus) {
            console.log('Please add owner first');
            return false;
        }
        return true;
    }

    // Public method to retrieve final data and prepare the payload
    @api async getData() {

        this.inputValues = {
            drivers: [...this.drivers],
            companyInformation: this.inputValues.companyInformation || {},
            driverList: [...this.existingDriversList] || []
        };


        const driverPageData = {
            driverDetails: {
                drivers: [...this.drivers],
                companyInformation: this.inputValues.companyInformation || {},
                driverList: [...this.existingDriversList] || []
            }
        };

        // console.log('DD Start 1',this.inputValues);
        // console.log('DD Start 2',driverPageData);

        const driverPageIndex = this.payload.findIndex(item => item.driverDetails);
        // console.log('DD Driver page Index',driverPageIndex);
        if (driverPageIndex >= 0) {
            this.payload = [
                ...this.payload.slice(0, driverPageIndex),
                driverPageData,
                ...this.payload.slice(driverPageIndex + 1)
            ];
        } else {
            this.payload = [...this.payload, driverPageData];
        }

        if (this.flag.isCompanyStatus) {
            const data = this.updateBusinessAddress();
            // Update finalizeVehicleDetails section
            let newPayload = JSON.parse(JSON.stringify(this.payload));
            const finalizeIndex = newPayload.findIndex(item => item.finalizeVehicleDetails);
            if (finalizeIndex >= 0) {
                newPayload[finalizeIndex].finalizeVehicleDetails = {
                    ...newPayload[finalizeIndex].finalizeVehicleDetails,
                    BusinessAddress__c: data
                };
            } else {
                newPayload.push({
                    finalizeVehicleDetails: {
                        BusinessAddress__c: data
                    }
                });
            }

            this.payload = newPayload;
            console.log('DD Updated payload', this.payload);

            if (!this.currentUserType) {
                saveFinalizeVehicleDetails({ strLeadDetails: JSON.stringify(this.payload) })
                    .then(result => {
                        console.log('DD Res from updating Vehicle Data in driver: ');
                    })
                    .catch(err => {
                        console.log('DD -- ERROR:Getting error while saving the Vehicle Data: ', JSON.stringify(err));
                    })
                await this.handleCompanyDataSave();
            }
        }
        // console.log('DD Payload 2 update', this.payload);

        // Update the payload with the current data present
        const driverPageIndexUpdated = this.payload.findIndex(item => item.driverDetails);


        if (driverPageIndexUpdated >= 0) {
            // Safest overwrite approach:
            this.payload = [
                ...this.payload.slice(0, driverPageIndexUpdated), // Keep items before
                driverPageData,                                  // New data
                ...this.payload.slice(driverPageIndexUpdated + 1) // Keep items after
            ];
        } else {
            this.payload = [...this.payload, driverPageData];
        }

        console.log('DD Again data after update', this.payload);
        console.log('DD Input values', this.inputValues);

        await this.handleDriverDataSave();

        return this.inputValues;
    }

    processVehicleData(vehicleDetails) {
        if (!vehicleDetails || typeof vehicleDetails !== 'object') {
            return null;
        }

        // List of fields we want to KEEP in the final object
        const fieldsToKeep = [
            'Is_Lienholder__c',
            'is_the_vehicle_used_for_business_purpose__c',
            'is_there_a_driver_under_21__c',
            'Is_this_a_Rental_Vehicle__c',
            'salvage_vehicle__c',
            'isTowing',
            'Electric_Hybrid__c',
            'Year__c',
            'Vehicle_sub_type__c',
            'Make',
            'Model',
            'Value__c',
            'Vin__c',
            'Registered_Country__c',
            'Registered_State__c',
            'Id',
            'Make__c',
            'Model__c',
            'Account_Vehicle__c',
            'Contact__c',
            'BusinessAddress__c',
            'Is_the_vehicle_registered_to_a_business__c'
        ];

        // Create a new object with only the fields we want to keep
        const processedData = {};

        fieldsToKeep.forEach(field => {
            if (vehicleDetails.hasOwnProperty(field)) {
                processedData[field] = vehicleDetails[field];
            }
        });

        // Add Registered_Plate__c with licensePlate's value
        if (vehicleDetails.hasOwnProperty('licensePlate')) {
            processedData['Registered_Plate__c'] = vehicleDetails.licensePlate;
        }

        return processedData;
    }

    // Lifecycle hook: used to log incoming payload when component is inserted
    connectedCallback() {

        console.log('DD OUTPUT -- Payload Data: ', JSON.stringify(this.payload));

        if (this.payload) {

            //const driverDetails = this.payload.find(item => item?.driverDetails?.drivers)?.driverDetails?.drivers;
            // console.log('DD Driver Details from Payload:', driverDetails);

            // console.log('DD OUTPUT added/selected drivers: ', driverDetails);
            // if (driverDetails) {
            //     if (Array.isArray(driverDetails) && driverDetails.length > 0) {
            //         this.drivers = [...driverDetails];
            //     }
            // }

            const driverPayload = this.payload.find(item => item?.driverDetails)?.driverDetails;
            console.log('OUTPUT : driverPayload', driverPayload);
            const existingDrivers = driverPayload?.driverList || [];

            this.existingDriversList = [...existingDrivers]; // Backup all drivers


            // Check if companyInformation has data
            const hasCompanyInfo = this.payload.some(
                obj => obj.driverDetails?.companyInformation && Object.keys(obj.driverDetails.companyInformation).length > 0
            );

            if (existingDrivers.length > 0) {
                console.log('OUTPUT in the lenght: ');
                if (hasCompanyInfo) {
                    // Company info present → pick only non-owner drivers
                    console.log('OUTPUT hascmpinfo: ');
                    this.loginUserDriverOption = existingDrivers.filter(driver => !driver.Driver_Type__c);
                } else {
                    console.log('OUTPUT All driver: ');
                    // No company info → allow all drivers
                    this.loginUserDriverOption = [...this.existingDriversList];
                }
            } else {
                console.warn('No drivers available in payload.');
                this.loginUserDriverOption = [];
            }

            // Setting driver owner list
            const allDriverData = this.payload.find(item => item?.driverDetails)?.driverDetails;
            const existingDriverList = allDriverData?.driverList || [];
            const addedDrivers = allDriverData?.drivers || [];

            console.log('OUTPUT allDriverData: ', JSON.stringify(allDriverData));

            this.drivers = [...addedDrivers]; // Store selected/added drivers

            const hasOwnerInAddedDrivers = addedDrivers.some(driver => driver.Driver_Type__c === true);

            if (existingDriverList.length > 0) {
                console.log('OUTPUT :in the lenght ');
                if (hasOwnerInAddedDrivers) {
                    // Show only non-owner drivers
                    console.log('OUTPUT :log only drievr ');
                    this.loginUserDriverOption = existingDriverList.filter(driver => !driver.Driver_Type__c);
                } else {
                    // Show all drivers
                    console.log('OUTPUT : log all type drivers');
                    this.loginUserDriverOption = [...existingDriverList];
                }
            } else {
                this.loginUserDriverOption = [];
                console.log('OUTPUT :no driver ');
            }
            //this.payload.find(item => item?.driverDetails?.drivers)?.driverDetails?.driverList;
            // const existingDrivers = this.payload.find(item => item?.driverDetails)?.driverDetails?.driverList;
            // console.log('DD OUTPUT all existingDrivers: ',existingDrivers);
            // if (existingDrivers) {
            //     if (Array.isArray(existingDrivers) && existingDrivers.length > 0) {
            //         if (this.payload.some(obj => obj.driverDetails?.companyInformation && Object.keys(obj.driverDetails.companyInformation).length > 0)) {
            //             this.loginUserDriverOption = [...existingDrivers].filter(driver => !driver.Driver_Type__c);
            //             this.existingDriversList = existingDrivers;
            //         } else {
            //             this.loginUserDriverOption = this.existingDriversList;
            //         }
            //     }
            // }

            // console.log('DD OUTPUT exesting all Driver: ',JSON.stringify(this.loginUserDriverOption));

            // const finalVehicleDetails = this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails;
            const finalVehicleDetails =
                this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails ??
                this.payload.find(item => item.vehicleDetails)?.vehicleDetails;
            console.log('Final Vehicle Details',finalVehicleDetails);
            if (finalVehicleDetails) {
                this.flag.Is_the_vehicle_registered_to_a_business__c =
                    finalVehicleDetails?.is_the_vehicle_used_for_business_purpose__c ??
                    finalVehicleDetails?.Is_the_vehicle_registered_to_a_business__c ??
                    false;
                this.flag.isCompanyStatus =
                    finalVehicleDetails?.is_the_vehicle_used_for_business_purpose__c ??
                    finalVehicleDetails?.Is_the_vehicle_registered_to_a_business__c ??
                    false;
            }
            this.isCompanyOrDriverOwner();
        }

        // Set min DOB value initially
        if (!this.driver.Dob__c) {
            let today = new Date();
            today.setFullYear(today.getFullYear() - 16);
            this.driver.Dob__c = today.toISOString().split('T')[0];
        }
    }

    // Lifecycle hook: checks if driver data exists in payload and assigns it
    renderedCallback() {
        if (this.payload && this.payload.length > 0 && this.flagForRender) {
            this.flagForRender = false;
            // const driverDetailsData = this.payload.find((item) => item.driverDetails);
            // if (driverDetailsData) {
            //     this.driver = driverDetailsData.driverDetails;
            // }
        }
    }

    // (Currently unused) method to populate input fields using driver data
    populateInputFields() {
        const inputs = this.template.querySelectorAll(
            'lightning-input, lightning-checkbox-group, lightning-radio-group, lightning-combobox, input[type="radio"]'
        );

        try {
            inputs.forEach((input) => {
                const fieldName = input.name;
                const fieldValue = this.driver[fieldName];

                if (fieldValue !== undefined) {
                    if (input.type === 'checkbox') {
                        input.checked = fieldValue;
                    } else if (input.type === 'radio') {
                        this.template
                            .querySelector(`input[name="${fieldName}"][value="${fieldValue}"]`)
                            ?.setAttribute('checked', true);
                    } else if (
                        input.localName === 'lightning-checkbox-group' ||
                        input.localName === 'lightning-radio-group'
                    ) {
                        input.value = Array.isArray(fieldValue) ? fieldValue : [fieldValue];
                    } else {
                        input.value = fieldValue;
                    }
                }
            });
        } catch (err) {
            console.log('Error while populating the values in the fields: ', JSON.stringify(err));
        }
    }


    updateBusinessAddress() {
        const businessAddress = {
            Country__c: this.inputValues?.companyInformation?.Company_Country__c,
            State_Province__c: this.inputValues?.companyInformation?.Company_State__c,
            Postal_Code__c: this.inputValues?.companyInformation?.Company_Zip__c,
            City__c: this.inputValues?.companyInformation?.Company_City__c,
            Address__c: this.inputValues?.companyInformation?.Company_Address__c
        };

        this.dispatchPayloadUpdate({
            BusinessAddress__c: businessAddress
        });

        return businessAddress;
    }


    // Dispatch event to parent
    // Enhanced dispatch method with dynamic data
    dispatchPayloadUpdate(data) {
        const updateEvent = new CustomEvent('payloadupdate', {
            detail: {
                updates: {
                    finalizeVehicleDetails: {
                        ...data // Spread the provided data
                    }
                }
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(updateEvent);
    }

    // ownerValidation() {
    //     if (this.drivers && this.drivers.length > 0) {
    //         let isValid = this.drivers.some(driver => driver.Driver_Type__c === true || driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == "Owner");
    //         console.log('Before owner validation check',isValid);
    //         if (isValid) {
    //             return isValid;
    //         }
    //         console.log('Inside owner validation check');
    //         // If no owner found in drivers, check for business registration
    //         const vehicleData = this.payload.find(item => item.vehicleDetails)?.vehicleDetails || {};
    //         const companyInfo = this.payload.find(item => item.driverDetails)?.driverDetails?.companyInformation || {};

    //         const isBusinessRegistered = vehicleData.Is_the_vehicle_registered_to_a_business__c || false;
    //         console.log('Isbussiness',isBusinessRegistered);
    //         // Check if company information has required values
    //         const hasCompanyInfo = companyInfo &&
    //             companyInfo.Company_Name__c &&
    //             companyInfo.Company_Address__c &&
    //             companyInfo.Company_Phone__c;

    //         console.log('Has company info',hasCompanyInfo);

    //         return isBusinessRegistered && hasCompanyInfo;

    //     }
    //     return false;
    // }

    // ownerValidationWhileAddingDriver() {
    //     if (this.driver) {
    //         // Check if Driver is owner
    //         let isValid = this.driver?.Driver_Type__c === true || this.driver?.Driver_Type__c === 'Owner' || this.driver?.Driver_Type__c === "Owner";
    //         console.log('Before owner validation check', isValid);

    //         const vehicleData = this.payload.find(item => item.vehicleDetails)?.vehicleDetails || {};
    //         const companyInfo = this.payload.find(item => item.driverDetails)?.driverDetails?.companyInformation || {};

    //         const isBusinessRegistered = !!vehicleData.Is_the_vehicle_registered_to_a_business__c;
    //         console.log('Is business registered:', isBusinessRegistered);

    //         const hasCompanyInfo = companyInfo.Company_Name__c && companyInfo.Company_Address__c && companyInfo.Company_Phone__c;
    //         console.log('Has company info:', hasCompanyInfo);

    //         // Logic to return true based on your described conditions
    //         if (isBusinessRegistered && isValid){
    //             return false;
    //         }

    //         return true;
    //     }

    //     return false;
    // }

    async handleNextClick() {
        const isValid = await this.validate();
        console.log('Inside handleNext Click', isValid);
        if (!isValid) {
            console.log('Validation failed at: Driver');
            return;
        }
        await this.getData();
        this.editpolicydata = { ...this.editpolicydata, ['DriverData']: [...this.drivers] };
        console.log('--edit policy driver list--', this.editpolicydata);
        const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
            detail: this.editpolicydata,
        }); this.dispatchEvent(editPolicyChange);
        this.changesnextscreen();
    }


    handlePrevClick() {
        console.log('--call handlePrevClick---');
        if (this.editpolicydata != null) {
            this.editpolicydata = { ...this.editpolicydata, ['DriverData']: [...this.drivers] };
            console.log('Edit policy data on back', this.editpolicydata);
            const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                detail: this.editpolicydata,
            });
            this.dispatchEvent(editPolicyChange);
        }
        this.changeprevscreen();
    }
}