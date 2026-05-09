import { LightningElement, track, api, wire } from 'lwc';
import getCountries from '@salesforce/apex/FinalizeVehicleDetailsFlow.getCountries';
import getStatesByCountry from '@salesforce/apex/FinalizeVehicleDetailsFlow.getStatesByCountry';
import saveDriverDetails from '@salesforce/apex/DriverDetailsFlow.saveDriverDetails';
import saveCompanyInformationDetails from '@salesforce/apex/CompanyInformationDetailFlow.saveCompanyInformationDetails';
import saveFinalizeVehicleDetails from '@salesforce/apex/FinalizeVehicleDetailsFlow.saveFinalizeVehicleDetails';
import updateQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.updateQuoteRecordData';

export default class Buho_ownerDetails extends LightningElement {
    @api payload;
    ISDEBUG = true;
    @track isSelected = false;

    @track inputValues = { companyInformation: {} };

    @track owner = {
        First_Name__c: '',
        Last_Name__c: '',
        License_Country__c: 'United States',
        License_state__c: '',
        license_number__c: '',
        Dob__c: '',
        Driver_Type__c: 'Owner & Driver', // Will be Owner & Driver for selected owner
        Country__c: '',
        Country_Text__c: '',
        State_Province__c: '',
        Postal_Code__c: '',
        City__c: '',
        Address__c: '',
        isLeasedOrFinanced: false
    };

    @track flag = {
        Is_the_vehicle_registered_to_a_business__c: false
    };

    @track currentVehicleType;
    @track currentStep = 'ownership';
    @track countryOptions = [];
    @track selectedOwnerId = '';
    @track driversFromPreviousStep = [];

    // Getters
    get isStepCompanyDetails() {
        return this.currentStep === 'companyDetails';
    }

    get isStepOwnerSelection() {
        return this.currentStep === 'ownerSelection';
    }

    get businessCardClass() {
        return this.isSelected ? 'ownership-card selected' : 'ownership-card';
    }

    get personalCardClass() {
        return !this.isSelected && this.currentVehicleType === 'personal' ? 'ownership-card selected' : 'ownership-card';
    }

    get ownerTitle() {
        return this.flag.Is_the_vehicle_registered_to_a_business__c
            ? 'Select primary operator/owner and provide address'
            : 'Select vehicle owner and provide address';
    }

    get driverOptions() {
        const options = [];

        this.driversFromPreviousStep.forEach(driver => {
            options.push({
                label: `${driver.First_Name__c} ${driver.Last_Name__c} - ${driver.license_number__c}`,
                value: driver.diff || driver.Id || `driver-${driver.license_number__c}`
            });
        });

        return options;
    }

    get formattedDob() {
        if (!this.owner.Dob__c) return '';
        const date = this.parseDateAsLocal(this.owner.Dob__c);
        if (!date) return this.owner.Dob__c;
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
    }

    // Ownership Type Selection (Business vs Personal)
    handleOwnershipSelection(event) {
        const selection = event.currentTarget.dataset.value;
        console.log('OD ownership selection:', selection);
        this.currentVehicleType = selection;

        if (selection === 'business') {
            this.isSelected = true;
            this.flag.Is_the_vehicle_registered_to_a_business__c = true;
            this.currentStep = 'companyDetails';
        } else {
            this.isSelected = false;
            this.flag.Is_the_vehicle_registered_to_a_business__c = false;
            this.currentStep = 'ownerSelection';
            // Clear company information when switching to personal vehicle
            this.inputValues.companyInformation = {};
        }

        this.dispatchPayloadUpdate({
            finalizeVehicleDetails: {
                Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c
            }
        });
    }

    // Driver Selection as Owner (from drivers added in previous step)
    handleDriverSelection(event) {
        const selectedId = event.detail?.value || event.target?.value;
        console.log('OD Selected owner ID:', selectedId);
        this.selectedOwnerId = selectedId;

        if (selectedId) {
            // Update all drivers: set selected as 'Owner & Driver', others as false
            this.driversFromPreviousStep = this.driversFromPreviousStep.map(d => {
                const isSelected = (d.diff === selectedId) || (d.Id === selectedId) || (`driver-${d.license_number__c}` === selectedId);

                return {
                    ...d,
                    Driver_Type__c: isSelected ? 'Owner & Driver' : false
                };
            });

            // Find the selected driver
            const selectedDriver = this.driversFromPreviousStep.find(d =>
                (d.diff === selectedId) || (d.Id === selectedId) || (`driver-${d.license_number__c}` === selectedId)
            );

            if (selectedDriver) {
                console.log('OD Selected driver:', selectedDriver);
                // Populate owner with selected driver's data
                this.owner = {
                    ...selectedDriver,
                    label: selectedDriver.label || '',
                    value: selectedDriver.value || '',
                    First_Name__c: selectedDriver.First_Name__c || '',
                    Last_Name__c: selectedDriver.Last_Name__c || '',
                    License_Country__c: selectedDriver.License_Country__c || 'United States',
                    License_state__c: selectedDriver.License_state__c || '',
                    license_number__c: selectedDriver.license_number__c || '',
                    Dob__c: selectedDriver.Dob__c || '',
                    Driver_Type__c: 'Owner & Driver',
                    Country__c: selectedDriver.Country__c || '',
                    Country_Text__c: selectedDriver.Country_Text__c || '',
                    State_Province__c: selectedDriver.State_Province__c || '',
                    Postal_Code__c: selectedDriver.Postal_Code__c || '',
                    City__c: selectedDriver.City__c || '',
                    Address__c: selectedDriver.Address__c || '',
                    diff: selectedDriver.diff || null,
                    isLeasedOrFinanced: selectedDriver.isLeasedOrFinanced || false
                };

                console.log('OD Updated drivers list:', this.driversFromPreviousStep);
            }
        }
    }

    // Navigation
    goToCompanyDetails() {
        this.currentStep = 'companyDetails';
    }

    goToOwnerSelection() {
        // Validate company information
        const childCmp = this.template.querySelector('c-buho_company-information');

        if (childCmp && typeof childCmp.validateInputs === 'function') {
            const isValid = childCmp.validateInputs();

            if (!isValid) {
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: '⚠️ Company Information is invalid.' },
                    bubbles: true,
                    composed: true
                }));
                return;
            }
        }

        this.currentStep = 'ownerSelection';
    }

    // Input Handlers (for address fields)
    handleInputChange(event) {
        try {
            const name = event.detail?.name || event.target?.name;
            const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
            const checked = event.detail?.checked !== undefined ? event.detail.checked : event.target?.checked;
            const type = event.detail?.type || event.target?.type;

            if (this.ISDEBUG) console.log('OD handleInputChange:', { name, value, checked, type });

            // Handle Country__c separately to update Country_Text__c
            if (name === 'Country__c') {
                this.owner = {
                    ...this.owner,
                    Country__c: value,
                    Country_Text__c: value
                };
                return;
            }

            // Handle checkbox fields
            if (type === 'checkbox') {
                this.owner = { ...this.owner, [name]: checked };
                return;
            }

            // Default - update owner fields
            this.owner = { ...this.owner, [name]: value };
        } catch (err) {
            console.log('OD ERROR in handleInputChange: ', err.message);
        }
    }

    handleCompanyInfoUpdate(event) {
        try {
            const companyInfo = event.detail?.companyInformation || event.detail;
            console.log('OD Received company info:', companyInfo);

            this.inputValues = {
                ...this.inputValues,
                companyInformation: companyInfo
            };
        } catch (error) {
            console.error('OD Error handling company info update:', error);
        }
    }

    handleOwnerAddress(event) {
        try {
            const fetchaddress = JSON.parse(event.detail);
            if (this.ISDEBUG) console.log('OD Received address data:', fetchaddress);

            this.owner = {
                ...this.owner,
                Country__c: fetchaddress.Country || fetchaddress.country || '',
                Country_Text__c: fetchaddress.Country || fetchaddress.country || '',
                State_Province__c: fetchaddress.State || fetchaddress.state || fetchaddress.administrative_area_level_1 || '',
                Postal_Code__c: fetchaddress.PostalCode || fetchaddress.postalCode || fetchaddress.postal_code || '',
                City__c: fetchaddress.City || fetchaddress.city || fetchaddress.locality || '',
                Address__c: fetchaddress.Address || fetchaddress.address || ''
            };
        } catch (error) {
            console.error('OD Error handling owner address:', error);
        }
    }

    // Country / State wiring
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            this.countryOptions = data.map(country => ({ label: country, value: country }));
        } else if (error) {
            console.error('Error loading countries', error);
        }
    }

    // Date handling
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

    // Lifecycle
    connectedCallback() {
        if (this.ISDEBUG) console.log('OD connectedCallback - Payload:', JSON.stringify(this.payload));

        // Load drivers from previous step
        if (this.payload) {
            const driverPayload = this.payload.find(item => item?.driverDetails)?.driverDetails;
            const companyPayload = driverPayload?.companyInformation;
            const drivers = driverPayload?.drivers || [];

            console.log('OD Drivers from previous step:', drivers);
            this.driversFromPreviousStep = [...drivers];

            // Check if there's already a selected owner (look for 'Owner & Driver' or true or 'Owner')
            const existingOwner = drivers.find(d =>
                d.Driver_Type__c === true ||
                d.Driver_Type__c === 'Owner' ||
                d.Driver_Type__c === 'Owner & Driver'
            );

            if (existingOwner) {
                console.log('OD Found existing owner:', existingOwner);
                // Pre-populate owner data including address
                this.owner = {
                    ...existingOwner,
                    label: existingOwner.label || '',
                    value: existingOwner.value || '',
                    First_Name__c: existingOwner.First_Name__c || '',
                    Last_Name__c: existingOwner.Last_Name__c || '',
                    License_Country__c: existingOwner.License_Country__c || 'United States',
                    License_state__c: existingOwner.License_state__c || '',
                    license_number__c: existingOwner.license_number__c || '',
                    Dob__c: existingOwner.Dob__c || '',
                    Driver_Type__c: 'Owner & Driver',
                    Country__c: existingOwner.Country__c || '',
                    Country_Text__c: existingOwner.Country_Text__c || '',
                    State_Province__c: existingOwner.State_Province__c || '',
                    Postal_Code__c: existingOwner.Postal_Code__c || '',
                    City__c: existingOwner.City__c || '',
                    Address__c: existingOwner.Address__c || '',
                    isLeasedOrFinanced: existingOwner.isLeasedOrFinanced || false
                };

                // Pre-select in dropdown
                this.selectedOwnerId = existingOwner.diff || existingOwner.Id || `driver-${existingOwner.license_number__c}`;
                this.currentVehicleType === 'personal';
                this.isSelected = false;
                this.currentStep === 'ownerSelection';
                console.log('OD Pre-populated owner:', this.owner);
                console.log('OD Pre-selected owner ID:', this.selectedOwnerId);
                this.handleOwnershipSelection({ currentTarget: { dataset: { value: 'personal' } } });

            }

            if (companyPayload && Object.keys(companyPayload).length > 0 && companyPayload?.Company_Name__c?.trim()) {
                console.log('OD Found company information, pre-selecting business vehicle');
                this.isSelected = true;
                this.currentVehicleType = 'business';
                this.flag.Is_the_vehicle_registered_to_a_business__c = true;
                this.currentStep = 'companyDetails';
                this.inputValues.companyInformation = companyPayload;
                this.handleOwnershipSelection({ currentTarget: { dataset: { value: 'business' } } });
            }

            const finalVehicleDetails = this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails;
            if (finalVehicleDetails?.Is_the_vehicle_registered_to_a_business__c) {
                this.flag.Is_the_vehicle_registered_to_a_business__c = true;
            }
        }
    }

    // Validation
    validateOwner() {
        if (!this.selectedOwnerId) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: 'Please select an owner from the list.' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        const inputs = this.template.querySelectorAll('c-buho_input[required]');
        let allValid = true;

        inputs.forEach(input => {
            if (input && typeof input.reportValidity === 'function') {
                if (!input.reportValidity()) {
                    allValid = false;
                }
            }
        });

        if (!allValid) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Validation Error', message: 'Please fill in all required address fields.' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Check if address fields are filled
        if (!this.owner.Country__c || !this.owner.State_Province__c || !this.owner.City__c || !this.owner.Address__c || !this.owner.Postal_Code__c) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: 'All address fields are required for the owner' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        return true;
    }

    // Continue
    handleContinue() {
        // For business vehicles, validate company info
        if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
            const childCmp = this.template.querySelector('c-buho_company-information');

            if (childCmp && typeof childCmp.validateInputs === 'function') {
                const isValid = childCmp.validateInputs();

                if (!isValid) {
                    this.dispatchEvent(new CustomEvent('toastevent', {
                        detail: { variant: 'error', title: 'Error', message: '⚠️ Company Information is invalid.' },
                        bubbles: true,
                        composed: true
                    }));
                    return;
                }
            }
        } else {
            // For personal vehicles, validate owner selection
            if (!this.validateOwner()) {
                return;
            }
        }

        // Dispatch event to parent (wizard) to move to next step
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    // Dispatch payload update
    dispatchPayloadUpdate(detailObj) {
        console.log('OD dispatchPayloadUpdate:', detailObj);
        try {
            this.dispatchEvent(new CustomEvent('payloadupdate', {
                detail: { updates: detailObj },
                bubbles: true,
                composed: true
            }));
        } catch (error) {
            console.error('OD Error dispatching payload update:', error);
        }
    }

    // Save Owner and Driver Data
    async handleDriverDataSave() {
        console.log('OD handleDriverDataSave called');

        if (!this.currentUserType) {
            // New user - save via saveDriverDetails
            try {
                console.log('OD Saving owner/driver details for new user');
                await saveDriverDetails({ strLeadDetails: JSON.stringify(this.payload) });
                console.log('OD Owner/driver details saved successfully');
            } catch (err) {
                console.log('OD ERROR: Getting error while saving the Owner/Driver Data: ', JSON.stringify(err));
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: 'Failed to save owner details: ' + err.message },
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

            console.log('OD Updating quote record with owner data', driversRecord);

            try {
                const updateVehicleResp = await updateQuoteRecordData({
                    quoteRecord: quoteRecord ? JSON.stringify(quoteRecord) : '',
                    vehicleRecord: vehicleRecord ? JSON.stringify(updatedVehicleData) : '',
                    towedUnitRecord: '',
                    driversRecord: driversRecord ? JSON.stringify(driversRecord) : ''
                });

                if (updateVehicleResp.status == 'success') {
                    console.log('OD Quote record updated successfully with owner data');
                }
            } catch (err) {
                console.error('OD Error updating quote record data', err);
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: 'Failed to update owner details: ' + err.message },
                    bubbles: true,
                    composed: true
                }));
            }
        }
    }

    async handleCompanyDataSave() {
        try {
            console.log('OD Saving company data', this.payload);
            const result = await saveCompanyInformationDetails({ strLeadDetails: JSON.stringify(this.payload) });
            if (result.Status === 'Success') {
                if (this.ISDEBUG) console.log('OD Company data saved successfully', result);
            } else {
                console.error('OD ERROR: Error in saving Company data', result);
            }
        } catch (error) {
            if (this.ISDEBUG) console.error('OD Error in saving company data', error);
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: 'Failed to save company details: ' + error.message },
                bubbles: true,
                composed: true
            }));
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

    get currentUserType() {
        if (!this.payload || !Array.isArray(this.payload)) return false;
        const existingIndex = this.payload.findIndex(item => Object.keys(item)[0] === "UserType");
        if (existingIndex !== -1) {
            return true;
        }
        return false;
    }

    // Public API Methods (called from wizard)
    @api
    validate() {
        console.log('OD validate() called');

        // For business vehicles, skip owner validation
        if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
            // Just validate company info was provided
            if (!this.inputValues.companyInformation || !this.inputValues.companyInformation.Company_Name__c) {
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: 'Please provide company information.' },
                    bubbles: true,
                    composed: true
                }));
                return false;
            }
            return true;
        }

        // For personal vehicles, validate owner selection
        return this.validateOwner();
    }

    @api
    async getData() {
        console.log('OD getData() called');
        console.log('OD Is business vehicle:', this.flag.Is_the_vehicle_registered_to_a_business__c);

        let allDrivers;

        // Handle business vs personal vehicles differently
        if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
            // Business vehicle: All drivers should have Driver_Type__c = false
            console.log('OD Business vehicle - setting all drivers to Driver_Type__c = false');
            allDrivers = this.driversFromPreviousStep.map(d => ({
                ...d,
                Driver_Type__c: false
            }));
        } else {
            // Personal vehicle: Validate owner and set Driver_Type__c accordingly
            if (!this.validateOwner()) {
                return null;
            }

            allDrivers = this.driversFromPreviousStep.map(d => {
                // Check if this is the selected owner
                const isSelectedOwner = (d.diff === this.selectedOwnerId) ||
                    (d.Id === this.selectedOwnerId) ||
                    (`driver-${d.license_number__c}` === this.selectedOwnerId);

                if (isSelectedOwner) {
                    // This is the owner - mark as Driver_Type__c = 'Owner & Driver' and include address
                    return {
                        ...d,
                        ...this.owner, // Include updated address fields
                        Driver_Type__c: 'Owner & Driver'
                    };
                } else {
                    // Not the owner - keep as Driver_Type__c = false
                    return {
                        ...d,
                        Driver_Type__c: false
                    };
                }
            });
        }

        // UPDATE PAYLOAD BEFORE SAVING (critical for Apex to receive correct data)
        // Update driverDetails section
        // If not a business vehicle, clear companyInformation
        const driverDetailsData = {
            drivers: allDrivers,
            driverList: this.driversFromPreviousStep,
            companyInformation: this.flag.Is_the_vehicle_registered_to_a_business__c
                ? (this.inputValues.companyInformation || {})
                : {}
        };

        const driverDetailsIndex = this.payload.findIndex(item => item.driverDetails);
        if (driverDetailsIndex >= 0) {
            this.payload = [
                ...this.payload.slice(0, driverDetailsIndex),
                { driverDetails: driverDetailsData },
                ...this.payload.slice(driverDetailsIndex + 1)
            ];
        } else {
            this.payload = [...this.payload, { driverDetails: driverDetailsData }];
        }

        // Update finalizeVehicleDetails section
        const companyInformation = this.inputValues?.companyInformation || {};
        const businessAddressObj = {
            Country__c: companyInformation.Company_Country__c || '',
            State_Province__c: companyInformation.Company_State__c || '',
            Postal_Code__c: companyInformation.Company_Zip__c || '',
            City__c: companyInformation.Company_City__c || '',
            Address__c: companyInformation.Company_Address__c || ''
        };
        const shouldAttachBusinessAddress = this.currentVehicleType === 'business';

        const finalizeIndex = this.payload.findIndex(item => item.finalizeVehicleDetails);
        if (finalizeIndex >= 0) {
            this.payload[finalizeIndex] = {
                ...this.payload[finalizeIndex],
                finalizeVehicleDetails: {
                    ...this.payload[finalizeIndex].finalizeVehicleDetails,
                    Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c,
                    ...(shouldAttachBusinessAddress ? { BusinessAddress__c: businessAddressObj } : {})
                }
            };
        } else {
            this.payload = [...this.payload, {
                finalizeVehicleDetails: {
                    Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c,
                    ...(shouldAttachBusinessAddress ? { BusinessAddress__c: businessAddressObj } : {})
                }
            }];
        }

        if (this.ISDEBUG) {
            console.log('OD payload after update', this.payload);
        }

        // Save finalizeVehicleDetails (for new customers)
        if (!this.currentUserType) {
            console.log('OD Saving finalize vehicle details');
            try {
                await saveFinalizeVehicleDetails({ strLeadDetails: JSON.stringify(this.payload) });
                console.log('OD Finalize vehicle details saved successfully');
            } catch (e) {
                console.log('OD Error in saveFinalizeVehicleDetails:', e.message);
            }
            // Save company data if business vehicle
            if (this.flag.Is_the_vehicle_registered_to_a_business__c && this.inputValues.companyInformation) {
                await this.handleCompanyDataSave();
            }
        }



        // Save driver/owner data
        await this.handleDriverDataSave();

        // Return array format - updates multiple sections of payload
        // This allows wizard to handle it generically using mergeArrayPayloads
        // Ensure companyInformation is empty object if not a business vehicle
        const returnData = [
            {
                driverDetails: {
                    drivers: allDrivers,
                    driverList: this.driversFromPreviousStep,
                    companyInformation: this.flag.Is_the_vehicle_registered_to_a_business__c
                        ? (this.inputValues.companyInformation || {})
                        : {}
                }
            },
            {
                finalizeVehicleDetails: {
                    Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c,
                    ...(shouldAttachBusinessAddress ? { BusinessAddress__c: businessAddressObj } : {})
                }
            }
        ];

        console.log('OD getData returning:', returnData);
        return returnData;
    }
}
