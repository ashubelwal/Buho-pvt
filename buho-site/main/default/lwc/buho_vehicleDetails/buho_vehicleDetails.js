import { LightningElement, track, api } from 'lwc';
import getVehicleTypesMetadata from '@salesforce/apex/VehicleDetailsFlow.getVehicleTypesMetadata';
import getMakes from '@salesforce/apex/VehicleDetailsFlow.getMakes';
import getModels from '@salesforce/apex/VehicleDetailsFlow.getModels';
import saveLeadVehicleDetails from '@salesforce/apex/VehicleDetailsFlow.saveLeadVehicleDetails';
import selectavehicle from '@salesforce/label/c.TR_Select_a_Vehicle_from_your_account';

export default class Buho_vehicleDetails extends LightningElement {
    @api payload;
    isDebug = true; // True/False To control the logs
    vehicleDetails = {}
    
    // Field values
    @track vehicleType = 'Automobile-Van-Minivan';
    @track year = 2025;
    @track make = '';
    @track model = '';
    @track vehicleValue = '';
    @track populateFlag = true;
    @track userType;
    @track liabilityOnly = false;
    
    label = { selectavehicle };
    
    @track booleanVar = { towNotAdded: false, isModelLoaded: false }
    
    @track inputValues = {
        "is_the_vehicle_used_for_business_purpose__c": false,
        "is_there_a_driver_under_21__c": false,
        "Is_this_a_Rental_Vehicle__c": false,
        "salvage_vehicle__c": false,
        "Coverage__c": 'Complete',
        "isTowing": false,
        "Electric_Hybrid__c": false,
        "towunits": [],
        "Liability__c": '300,000',
        "Medical__c": "10,000/50,000",
        "Year__c": 2025
    };
    
    @track vehicleTypeOptions = [
        { label: 'Sedan', value: 'sedan' },
        { label: 'SUV', value: 'suv' },
    ];
    
    @track yearOptions = Array.from({ length: 30 }, (_, i) => ({
        label: `${new Date().getFullYear() - i}`,
        value: `${new Date().getFullYear() - i}`,
    }));
    
    @track makeOptions = [{ label: 'Select a year', value: 'Select a year' }];
    @track modelOptions = [{ label: 'Select a make', value: 'Select a make' }];

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

    // Handle checkbox change for towing
    handleisTowing(event) {
        this.inputValues.isTowing = event.target.checked;
    }

    // Fetch vehicle types metadata and update dropdown options
    getVehicleTypeOptions() {
        getVehicleTypesMetadata()
            .then((result) => {
                if (result.Status === 'Success') {
                    this.vehicleTypeOptions = result.Data.map(option => ({
                        ...option,
                        selected: option.value === this.vehicleType
                    }));
                    console.log('BVD vehicle TypeOptions: ', this.vehicleTypeOptions);
                } else if (result.Status === 'Error') {
                    if (this.isDebug) console.error('BVD Error fetching vehicle types:', result.Message);
                    this.dispatchEvent(new CustomEvent('toastevent', { 
                        detail: { variant: 'error', title: 'Error', message: 'Getting error, please contact with support team!' },
                        bubbles: true,
                        composed: true
                    }));
                }
            })
    }

    // Handle checkbox change for liability-only selection
    handleLiabilityOnly = (event) => {
        if (this.isDebug) console.log('BVD handleLiabilityOnly: ', event.target.checked);
        if (event.target.checked) {
            this.inputValues.Coverage__c = 'Liability';
        } else {
            this.inputValues.Coverage__c = 'Complete';
        }
    }

    vehicleMakesCache = new Map();  // Store retrieved makes    
    async getVehicleMake(Year) {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { 
            detail: false,
            bubbles: true,
            composed: true
        }));
        try {
            const result = await getMakes({ year: Year });
            if (result.Status === 'Success') {
                this.makeOptions = result.Data.map(option => ({
                    ...option,
                    selected: option.value === this.make
                }));
            }
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { 
                detail: true,
                bubbles: true,
                composed: true
            }));
        } catch (error) {
            this.debugLog('BVD Error fetching vehicle makes:', error);
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { 
                detail: true,
                bubbles: true,
                composed: true
            }));
            this.dispatchEvent(new CustomEvent('toastevent', { 
                detail: { variant: 'error', title: 'Error', message: 'We are not able to make call to get Make' },
                bubbles: true,
                composed: true
            }));
        }
    }

    // Fetch vehicle models based on selected year and make
    async getVehicleModel(Year, Make) {
        this.booleanVar.isModelLoaded = true;
        if (Year != null && Year != '' && Year != undefined && Make != null && Make != '' && Make != undefined) {
            await getModels({ year: Year, make: Make })
                .then((result) => {
                    if (result.Status === 'Success') {
                        this.modelOptions = result.Data.map(option => ({
                            ...option,
                            selected: option.value === this.model
                        }));
                    } else if (result.Status === 'Error') {
                        if (this.isDebug) console.error('BVD Error fetching vehicle models:', result.Message);
                    }
                    this.booleanVar.isModelLoaded = false;
                })
                .catch((error) => {
                    if (this.isDebug) console.error('BVD Error fetching vehicle models:', error);
                    this.dispatchEvent(new CustomEvent('toastevent', { 
                        detail: { variant: 'error', title: 'Error', message: 'We are not able to make call to get Model.' },
                        bubbles: true,
                        composed: true
                    }));
                });
        }
    }

    // Handle input changes
    async handleInputChange(event) {
        try {
            const fieldName = event.target.name.replace(/ /g, '').toLowerCase();
            const { name, value, type, checked } = event.target;

            this.inputValues[name] = type === 'checkbox' ? checked : value;
            console.log('BVD Input values on vehicle Change', this.inputValues);
            this.vehicleType = name === 'Vehicle_sub_type__c' ? value : this.vehicleType;
            this.vehicleValue = name === 'Value__c' ? value : this.vehicleValue;

            console.log('BVD Vehicle Type: ', this.vehicleType);

            if (name === 'Vehicle_sub_type__c') {
                this.year = '';
                this.handleComboboxReset('Year');
                // Update vehicleTypeOptions with new selected value
                this.vehicleTypeOptions = this.vehicleTypeOptions.map(option => ({
                    ...option,
                    selected: option.value === value
                }));
            }

            if (fieldName.toLowerCase() === 'year__c' && (this.vehicleType != 'Motorcycle' && this.vehicleType != 'Motorhome')) {
                this.handleComboboxReset('Year');
                this.year = value;
                // Update yearOptions with new selected value
                this.yearOptions = this.yearOptions.map(option => ({
                    ...option,
                    selected: option.value === value
                }));
                this.getVehicleMake(this.year);
            } else if (fieldName.toLowerCase() === 'year__c' && (this.vehicleType === 'Motorcycle' || this.vehicleType === 'Motorhome')) {
                this.handleComboboxReset('Year');
                this.year = value;
                // Update yearOptions with new selected value
                this.yearOptions = this.yearOptions.map(option => ({
                    ...option,
                    selected: option.value === value
                }));
                this.makeOptions = [];
                this.modelOptions = [];
                this.booleanVar.isModelLoaded = false;
            }
        } catch (err) {
            if (this.isDebug) console.log('BVD handleInputChange Error : ', err.message);
            this.dispatchEvent(new CustomEvent('toastevent', { 
                detail: { variant: 'error', title: 'Error', message: `Getting error ${err.message}` },
                bubbles: true,
                composed: true
            }));
        }
    }

    // It will clear the make and model comboboxes
    handleComboboxReset(value) {
        if (value === 'Year') {
            this.make = '';
            this.model = '';
            this.makeOptions = [{ label: 'Select a year', value: 'Select a year' }];
            this.modelOptions = [{ label: 'Select a make', value: 'Select a make' }];
        } else if (value === 'Make') {
            this.model = '';
            this.modelOptions = [{ label: 'Select a make', value: 'Select a make' }];
        }
    }

    handleMakeChange(event) {
        const selectedMake = event.target.value;
        this.make = selectedMake;
        this.inputValues['Make'] = selectedMake;
        this.handleComboboxReset('Make');
        // Update makeOptions with new selected value
        this.makeOptions = this.makeOptions.map(option => ({
            ...option,
            selected: option.value === selectedMake
        }));
        if (this.year && selectedMake) {
            this.getVehicleModel(this.year, selectedMake);
        }
    }

    handleModelChange(event) {
        const selectedModel = event.target.value;
        this.model = selectedModel;
        this.inputValues['Model'] = selectedModel;
        // Update modelOptions with new selected value
        this.modelOptions = this.modelOptions.map(option => ({
            ...option,
            selected: option.value === selectedModel
        }));
    }

    // Validation method (returns true if valid, false if invalid)
    @api validate() {
        const inputs = this.template.querySelectorAll('input[required], select[required], lightning-input[required], lightning-combobox[required]');
        let allValid = true;

        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                allValid = false;
            }
        });

        if (!allValid) {
            console.log('BVD Validation failed');
            return false;
        }

        // Additional validation for Make and Model
        if (!this.make || this.make === '' || this.make === 'Select a year') {
            this.dispatchEvent(new CustomEvent('toastevent', { 
                detail: { variant: 'error', title: 'Error', message: 'Please select a Make' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        if (!this.model || this.model === '' || this.model === 'Select a make') {
            this.dispatchEvent(new CustomEvent('toastevent', { 
                detail: { variant: 'error', title: 'Error', message: 'Please select a Model' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Check for towing validation
        if (this.inputValues.isTowing && this.inputValues.towunits.length === 0) {
            this.booleanVar.towNotAdded = true;
            this.dispatchEvent(new CustomEvent('toastevent', { 
                detail: { variant: 'error', title: 'Error', message: 'Please add at least one towed unit' },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        return true;
    }

    getTowData(event) {
        this.inputValues.towunits = event.detail;
        this.booleanVar.towNotAdded = this.inputValues.towunits.length == 0 ? true : false;
        if (this.isDebug) console.log('BVD getTowData: ', JSON.stringify(this.inputValues));
    }

    handleToastEvent(event) {
        // Re-dispatch the toast event so it bubbles up to the wizard
        this.dispatchEvent(new CustomEvent('toastevent', {
            detail: event.detail,
            bubbles: true,
            composed: true
        }));
    }

    // Method to capture the data from the form fields
    @api async getData() {
        if (this.inputValues.isTowing) {
            if (this.inputValues.towunits.length != 0) {
                if (this.isDebug) console.log('BVD towunits length: ', this.inputValues.towunits.length);
                await this.insertVehiclRecord();
                await this.addData();
                if (this.isDebug) console.log('BVD getData: ', JSON.stringify(this.inputValues));
                return this.inputValues;
            } else {
                if (this.isDebug) console.log('BVD getting error - no tow units');
            }
        } else {
            await this.insertVehiclRecord();
            await this.addData();
            if (this.isDebug) console.log('BVD getData: ', JSON.stringify(this.inputValues));
            return this.inputValues;
        }
    }

    // Insert vehicle, Update the vehicle record Check the validation for the salesforce record
    async insertVehiclRecord() {
        if (this.isDebug) console.log('BVD Inside insert vehicle Record');
        await this.addData();

        let temp = { ['vehicleDetails']: this.inputValues }
        const existingIndex = this.payload.findIndex(item =>
            Object.keys(item)[0] === "vehicleDetails"
        );
        if (existingIndex !== -1) {
            this.payload[existingIndex] = { ...temp };
        } else {
            this.payload = [...this.payload, { ...temp }];
        }
        if (this.isDebug) console.log('BVD Payload after insert: ', JSON.stringify(this.payload, null, 4));

        
        try {
            const result = await saveLeadVehicleDetails({ strLeadDetails: JSON.stringify(this.payload) });
            if (this.isDebug) console.log('BVD Vehicle details saved: ', result);
        } catch (error) {
            console.error('BVD Error saving vehicle details:', error);
            this.dispatchEvent(new CustomEvent('toastevent', { 
                detail: { variant: 'error', title: 'Error', message: 'Error saving vehicle details' },
                bubbles: true,
                composed: true
            }));
        }
    }

    addData() {
        this.inputValues.Make = this.make;
        this.inputValues.Model = this.model;
        this.inputValues.Value__c = this.vehicleValue;
        this.inputValues.Vehicle_sub_type__c = this.vehicleType;
        this.inputValues.Make__c = this.make;
        this.inputValues.Model__c = this.model;
    }

    connectedCallback() {
        if (this.year === '') {
            this.year = '2025';
        }
        // Initialize yearOptions with selected property
        this.yearOptions = Array.from({ length: 30 }, (_, i) => {
            const yearValue = `${new Date().getFullYear() - i}`;
            return {
                label: yearValue,
                value: yearValue,
                selected: yearValue === this.year.toString()
            };
        });
        this.getVehicleTypeOptions();
    }

    async renderedCallback() {
        const vehicleSubTypesToClear = [
            'Homeowners',
            'Motorcycle/Street Legal ATV',
            'Northbound',
            'Motorcycle/Street',
            'Auto',
            'Powersports',
            'Trucking',
            'Automobile/Sedan',
            'SUV',
            'Pickup Truck w or w/o Camper Shell',
            'Vehicle',
            'Automobile',
            'Watercraft',
            'RV',
            'Pick Up'
        ];
        
        // Populate input fields when the component loads or updates        
        if (this.payload && this.payload.length > 0 && this.populateFlag) {
            this.payload = JSON.parse(JSON.stringify(this.payload));
            console.log('BVD Payload data in renderedCallback', this.payload);
            this.populateFlag = false;
            const vehicleDetailsData = this.payload.find((item) => item.vehicleDetails);
            if (vehicleDetailsData) {
                let updatedVehicleDetails = { ...vehicleDetailsData.vehicleDetails };

                if (updatedVehicleDetails?.Vehicle_sub_type__c && vehicleSubTypesToClear.includes(updatedVehicleDetails.Vehicle_sub_type__c)) {
                    updatedVehicleDetails.Vehicle_sub_type__c = null;
                    this.vehicleType = null;
                }

                this.vehicleDetails = updatedVehicleDetails;
                console.log('BVD Updated vehicleDetails ', JSON.stringify(this.vehicleDetails));

                this.updateInputValues();
                await this.populateInputFields();
                console.log('BVD After populate inputs', this.inputValues);
                console.log('BVD Vehicle details', this.vehicleDetails);
            }
        } else if (this.populateFlag) {
            // For new users (no payload), fetch makes for the default year
            this.populateFlag = false;
            await this.getVehicleMake(this.year);
        }
    }

    // Method to update inputValues with vehicleDetails
    updateInputValues() {
        if (this.vehicleDetails) {
            const updatedValues = { ...this.inputValues };

            for (const [key, value] of Object.entries(this.vehicleDetails)) {
                if (key in updatedValues) {
                    if (typeof updatedValues[key] === 'boolean' && typeof value === 'string') {
                        console.log('BVD In if', value);
                        updatedValues[key] = value.toLowerCase() === 'true';
                    } else {
                        console.log('BVD In else', value);
                        updatedValues[key] = value;
                    }
                } else {
                    updatedValues[key] = value;
                }
            }
            console.log('BVD Updated values', updatedValues);

            this.inputValues = updatedValues;
        }
    }

    async populateInputFields() {
        console.log('BVD yearOptions: ', this.yearOptions);
        const inputs = this.template.querySelectorAll('input, select, lightning-input, lightning-combobox');

        inputs.forEach((input) => {
            const fieldName = input.name;
            const fieldValue = this.vehicleDetails[fieldName];

            if (fieldValue !== undefined) {
                if (input.type === 'checkbox') {
                    input.checked = typeof fieldValue === 'string' ? fieldValue.toLowerCase() === 'true' : fieldValue;
                } else {
                    //if (fieldName !== 'Year__c') {
                        input.value = fieldValue;
                    //}
                }
            }
        });

        this.make = this.vehicleDetails['Make'];
        this.model = this.vehicleDetails['Model'];
        this.vehicleValue = this.vehicleDetails['Value__c'];
        this.vehicleType = this.vehicleDetails['Vehicle_sub_type__c'];
        this.year = this.vehicleDetails['Year__c'];
        this.liabilityOnly = this.vehicleDetails['Coverage__c'] == 'Liability' ? true : false;

        // Fetch make and model options when navigating back
        if (this.year && this.make && this.model) {
            // First, fetch makes for the selected year
            await this.getVehicleMake(this.year);
            
            // Then, fetch models for the selected make
            if (this.make) {
                await this.getVehicleModel(this.year, this.make);
            }
        }
    }

    async changevehicleOption(event) {
        const selectedId = event.target.value;
        const vehicleList = this.vehicleDetails.vehicleList || [];

        const selectedVehicle = vehicleList.find(vehicle => vehicle.Id === selectedId);

        if (selectedVehicle) {
            const updatedVehicleDetails = {
                ...this.vehicleDetails,
                Coverage__c: selectedVehicle.Coverage__c,
                Electric_Hybrid__c: selectedVehicle.Electric_Hybrid__c,
                Liability__c: selectedVehicle.Liability__c,
                Medical__c: selectedVehicle.Medical__c,
                Year__c: selectedVehicle.Year__c,
                Vehicle_sub_type__c: selectedVehicle.Vehicle_sub_type__c,
                Make: selectedVehicle.Make,
                Model: selectedVehicle.Model,
                Value__c: selectedVehicle.Value__c,
                Vin__c: selectedVehicle.Vin__c,
                Registered_Country__c: selectedVehicle.Registered_Country__c,
                Registered_State__c: selectedVehicle.Registered_State__c,
                licensePlate: selectedVehicle.licensePlate,
                Id: selectedVehicle.Id
            };

            this.vehicleDetails = updatedVehicleDetails;
            await this.populateInputFields();
            this.updateInputValues();
            console.log('BVD Vehicle Details Updated', this.vehicleDetails);
        } else {
            console.warn('BVD Vehicle not found with Id:', selectedId);
        }
    }

    handleContinue() {
        if (!this.validate()) {
            return;
        }
        // Dispatch event to parent to move to next step
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    debugLog(message, data) {
        if (this.isDebug) {
            console.log(message, data);
        }
    }
}
