import { LightningElement, track, api } from 'lwc';
import getVehicleTypesMetadata from '@salesforce/apex/VehicleDetailsFlow.getVehicleTypesMetadata';
import getMakes from '@salesforce/apex/VehicleDetailsFlow.getMakes';
import getModels from '@salesforce/apex/VehicleDetailsFlow.getModels';
import saveLeadVehicleDetails from '@salesforce/apex/VehicleDetailsFlow.saveLeadVehicleDetails';
import selectavehicle from '@salesforce/label/c.TR_Select_a_Vehicle_from_your_account';


export default class Nc_vehicleDetails extends LightningElement {
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
    vehicleTypeOptions = [
        { label: 'Sedan', value: 'sedan' },
        { label: 'SUV', value: 'suv' },
    ];
    yearOptions = Array.from({ length: 30 }, (_, i) => ({
        label: `${new Date().getFullYear() - i}`,
        value: `${new Date().getFullYear() - i}`,
    }));
    makeOptions = [{ label: 'Select a year', value: 'Select a year' }];
    modelOptions = [{ label: 'Select a make', value: 'Select a make' }];

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
                    this.vehicleTypeOptions = result.Data;
                    this.getVehicleMake('2025');
                    console.log('VD OUTPUT vehicleTypeOptions: ', this.vehicleTypeOptions);
                } else if (result.Status === 'Error') {
                    if (this.isDebug) console.error('vehicleDetails - getVehicleTypeOptions - Error fetching vehicle types:', result.Message);
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Getting error, please contact with support team!' } }));
                }
            })
    }

    // Handle checkbox change for liability-only selection
    handleLiabilityOnly = (event) => {
        if (this.isDebug) console.log('handleLiabilityOnly OUTPUT : ', event.target.checked);
        if (event.target.checked) {
            this.inputValues.Coverage__c = 'Liability';
        } else {
            this.inputValues.Coverage__c = 'Complete';
        }
    }

    vehicleMakesCache = new Map();  // Store retrieved makes    
    async getVehicleMake(Year) {
        //if (!Year || this.vehicleMakesCache.has(Year)) return;
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        try {
            const result = await getMakes({ year: Year });
            if (result.Status === 'Success') {
                //this.vehicleMakesCache.set(Year, result.Data);
                this.makeOptions = result.Data;
            }
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        } catch (error) {
            this.debugLog('Error fetching vehicle makes:', error);
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'We are not able to make call to get Make' } }));
        }


    }

    // Fetch vehicle models based on selected year and make
    async getVehicleModel(Year, Make) {
        this.booleanVar.isModelLoaded = true;
        if (Year != null && Year != '' && Year != undefined && Make != null && Make != '' && Make != undefined) {
            await getModels({ year: Year, make: Make })
                .then((result) => {
                    if (result.Status === 'Success') {
                        this.modelOptions = result.Data;
                    } else if (result.Status === 'Error') {
                        if (this.isDebug) console.error('Error fetching vehicle models:', result.Message);
                    }
                    this.booleanVar.isModelLoaded = false;
                })
                .catch((error) => {
                    if (this.isDebug) console.error('Error fetching vehicle models:', error);
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'We are not able to make call to get Model.' } }));
                });
        }
    }

    // async handleInputChange(event) {
    //     try {
    //         const fieldName = event.target.name.replace(/ /g, '').toLowerCase();
    //         const { name, value, type, checked } = event.target;

    //         this.inputValues[name] = type === 'checkbox' ? checked : value;

    //         if (name === 'Vehicle_sub_type__c') {
    //             this.vehicleType = value;

    //             if (this.vehicleType === 'Motorcycle') {
    //                 // Reset make and model fields
    //                 this.make = '';
    //                 this.model = '';
    //                 this.handleComboboxReset('Year');

    //                 this.makeOptions = [
    //                     { label: 'TVS', value: 'TVS' },
    //                     { label: 'Hero', value: 'Hero' }
    //                 ];
    //                 this.modelOptions = [
    //                     { label: 'Apache 200', value: 'Apache 200' },
    //                     { label: 'Splendor', value: 'Splendor' }
    //                 ];
    //                 this.booleanVar.isModelLoaded = false;
    //             } else {
    //                 // Restore normal behavior (based on selected year)
    //                 if (this.year) {
    //                     await this.getVehicleMake(this.year);
    //                     if (this.make) {
    //                         await this.getVehicleModel(this.year, this.make);
    //                     }
    //                 }
    //             }
    //         }

    //         // Year selection logic
    //         if (fieldName === 'year__c') {
    //             this.year = value;

    //             if (this.vehicleType !== 'Motorcycle') {
    //                 this.handleComboboxReset('Year');
    //                 await this.getVehicleMake(this.year);
    //             }
    //         }

    //     } catch (err) {
    //         if (this.isDebug) console.log('vehicleDetails - handleInputChange Error : ', err.message);
    //     }
    // }


    // Handle input changes
    async handleInputChange(event) {
        try {
            const fieldName = event.target.name.replace(/ /g, '').toLowerCase();
            const { name, value, type, checked } = event.target;

            this.inputValues[name] = type === 'checkbox' ? checked : value;
            console.log('Input values on vehicle Change', this.inputValues);
            this.vehicleType = name === 'Vehicle_sub_type__c' ? value : this.vehicleType;
            this.vehicleValue = name === 'Value__c' ? value : this.vehicleValue;

            console.log('Vehicle Type: ', this.vehicleType);

            if (name === 'Vehicle_sub_type__c') {
                this.year = '';
                this.handleComboboxReset('Year');
            }

            if (fieldName.toLowerCase() === 'year__c' && (this.vehicleType != 'Motorcycle' && this.vehicleType != 'Motorhome')) {
                this.handleComboboxReset('Year');
                this.year = value;
                this.getVehicleMake(this.year);
            } else if (fieldName.toLowerCase() === 'year__c' && (this.vehicleType === 'Motorcycle' || this.vehicleType === 'Motorhome')) {
                this.handleComboboxReset('Year');
                this.year = value;
                this.makeOptions = [];
                this.modelOptions = [];

                this.booleanVar.isModelLoaded = false;
            }
        } catch (err) {
            if (this.isDebug) console.log('vehicleDetails - handleInputChange Error : ', err.message);
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: `Getting error ${err.message}` } }));
        }
    }

    // It will clear the make and model comboboxes
    handleComboboxReset(value) {
        if (value === 'Year') {
            const comboboxes = this.template.querySelectorAll('c-nc_combobox');
            if (comboboxes) {
                comboboxes.forEach((combobox) => {
                    combobox.handleReset();
                });

                this.makeOptions = [{ label: 'Select a year', value: 'Select a year' }];
                this.modelOptions = [{ label: 'Select a make', value: 'Select a make' }];
            }
        } else if (value === 'Make') {
            const comboboxes = this.template.querySelectorAll('c-nc_combobox');
            if (comboboxes) {
                comboboxes.forEach((combobox) => {
                    if (combobox.inputLabel === 'Model') {
                        combobox.handleReset();
                    }
                });
                this.modelOptions = [{ label: 'Select a make', value: 'Select a make' }];
            }
        }
    }

    // It will clear the model combobox
    handleChildComboboxReset(event) {
        if (event.detail === 'Make') {
            this.handleComboboxReset(event.detail);
        }
    }

    handleAddValue(event) {
        // const { value, label, name } = event.detail;
        // console.log('OUTPUT event.detail: ', event.detail);
        // if (name === 'Make__c') {
        //     this.inputValues[name] = value;
        //     this.make = value;
        // }
        // else if (name === 'Model__c') {
        //     this.inputValues[name] = value;
        //     this.model = value;
        // }
        const { name, value, label } = event.detail;
        this.inputValues[name] = value;

        // Retrieve the selected value from the event's detail
        const fieldLabel = event.detail.name;
        const selectedValue = event.detail.value;

        if (label === 'Make') {
            if (this.isDebug) console.log('Make : ', fieldLabel + " selectedValue " + selectedValue);
            this.make = selectedValue;
            this.handleComboboxReset('Make');
        }

        if (label === 'Model') {
            if (this.isDebug) console.log('In the Model : ', fieldLabel + " selectedValue " + selectedValue);
            this.model = selectedValue;
        }

        console.log('OUTPUT this.inputValues: ', JSON.stringify(this.inputValues));

    }

    handleOptionClick(event) {
        const { name, value } = event.detail;
        this.inputValues[name] = value;

        // Retrieve the selected value from the event's detail
        const fieldLabel = event.detail.name;
        const selectedValue = event.detail.value;
        if (fieldLabel === 'Make') {
            if (this.isDebug) console.log('Make : ', fieldLabel + " selectedValue " + selectedValue);
            this.make = selectedValue;
            this.handleComboboxReset('Make');
            this.getVehicleModel(this.year, this.make);
        }

        if (fieldLabel === 'Model') {
            if (this.isDebug) console.log('In the Model : ', fieldLabel + " selectedValue " + selectedValue);
            this.model = selectedValue;
        }
    }

    handleTypedValue(event) {
        const { name, value } = event.detail;
        // Use `name` to decide where to store `value`
        console.log('OUTPUT : name', name + ' value: ' + value);
        this.inputValues[name] = value;

        if (name === 'Make') {
            this.make = value;
        }

        if (name === 'Model') {
            this.model = value;
        }


    }

    // Validation method (returns true if valid, false if invalid)
    @api validate() {
        const inputs = this.template.querySelectorAll('input, lightning-input, c-nc_combobox, lightning-checkbox-group, lightning-radio-group, lightning-combobox, input[type="radio"]');
        // const values = {};
        let allValid = true;

        inputs.forEach(input => {
            const { required, value, name, type } = input;
            // Handle validation for required fields
            if (required && !input.checkValidity() || input && !input.reportValidity()) {
                console.log('OUTPUT if error---: ', name);
                input.classList.add('slds-has-error'); // Add error styling
                input.reportValidity(); // Show validation message
                console.log('OUTPUT : return false0');
                allValid = false;
            } else {
                console.log('OUTPUT : Else block', name + ' value ' + value);
                console.log('OUTPUT : return true11');
                input.classList.remove('slds-has-error'); // Remove error styling if valid             
                // let inputValue; // Capture values based on type
                // if (type === 'checkbox') {
                //     inputValue = input.checked; // Checkbox value
                // } else if (type === 'radio') {
                //     inputValue = input.value; // Selected radio value
                // } else if (type === 'combobox') {
                //     inputValue = input.value; // Selected combobox value
                // } else {
                //     inputValue = value; // For text, email, etc.
                // }

                // // Add to value
                // values[name] = inputValue;
            }
        });

        if (allValid) {
            console.log('OUTPUT: vehicleDetails: ', JSON.stringify(this.inputValues?.vehicleDetails));

            if (!this.inputValues?.vehicleDetails?.Model__c || !this.inputValues?.vehicleDetails?.Make__c) {
                console.log('OUTPUT : please make sure to add ');
            }
            // this.inputValues = values; // Update with valid values             
            if (this.inputValues.isTowing && this.inputValues.towunits.length == 0) {
                if (this.isDebug) console.log('OUTPUT 123: ', this.inputValues.towunits.length);
                this.booleanVar.towNotAdded = true;
                console.log('OUTPUT : return false1');
                return false;
            }
            this.booleanVar.towNotAdded = false;
        } else {
            if (this.isDebug) console.error('vehicleDetilas - validate - Some required fields are invalid. Please fix the errors and try again.');
            console.log('OUTPUT : return false2');
            return false;
        }
        console.log('OUTPUT : return true');
        return true;  // Valid if fields are filled
    }

    // get the added towed units
    getTowData(event) {
        this.inputValues['towunits'] = [...event.detail];
        this.booleanVar.towNotAdded = this.inputValues.towunits.length == 0 ? true : false;
        if (this.isDebug) console.log('vehicleDetilas- getTowData: ', JSON.stringify(this.inputValues));
    }

    // Method to capture the data from the form fields
    @api async getData() {

        if (this.inputValues.isTowing) {
            if (this.inputValues.towunits.length != 0) {
                if (this.isDebug) console.log('OUTPUT 123: ', this.inputValues.towunits.length);

                await this.insertVehiclRecord();
                //Send the inserted data back to the grandparent component
                await this.addData();
                if (this.isDebug) console.log('vehicleDetilas- getData: ', JSON.stringify(this.inputValues));
                return this.inputValues;
            } else {
                if (this.isDebug) console.log('getting error');
            }
        } else {
            await this.insertVehiclRecord();
            //Send the inserted data back to the grandparent component
            await this.addData();
            if (this.isDebug) console.log('vehicleDetilas- getData: ', JSON.stringify(this.inputValues));
            return this.inputValues;
        }
    }

    // Insert vehicle, Update the vehicle record Check the validation for the salesforce record

    async insertVehiclRecord() {
        if (this.isDebug) console.log('Inside insert vehicle REcord');
        // Add the neccesary data in the object
        await this.addData();

        let temp = { ['vehicleDetails']: this.inputValues }
        let updatedPayload = [...this.payload];

        const existingIndex = this.payload.findIndex(item =>
            Object.keys(item)[0] === "vehicleDetails"
        );
        if (existingIndex !== -1) {
            // Update the existing item at the found index
            updatedPayload[existingIndex] = temp;
        } else {
            // Add the new vehicleDetails object
            updatedPayload.push(temp);
        }

        // Reassign the updated array back to payload
        this.payload = updatedPayload;

        if (this.isDebug) console.log('Payload data in the vehicle record', this.payload);
        //Insert the vehicle record in the lead through backend
        if (!this.currentUserType) {
            await saveLeadVehicleDetails({ strLeadDetails: JSON.stringify(this.payload) })
                .then((result) => {
                    if (result.Status === 'Success') {
                        if (this.isDebug) console.log('Vehicle data inserted successfully', result.Data);
                    } else if (result.Status === 'Error') {
                        if (this.isDebug) console.error('Error in inserting vehicle data', result.Message);
                    }
                })
                .catch((error) => {
                    if (this.isDebug) console.error('Error in inserting vehicle data', error);
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Getting error while saving the records' } }));
                });
        }
    }

    addData() {
        this.inputValues = {
            ...this.inputValues,

            Make__c: this.make,
            Model__c: this.model,
            Value__c: this.vehicleValue,
            Vehicle_sub_type__c: this.vehicleType
        }
    }

    connectedCallback() {
        // if (this.isDebug) console.log('Vehicle - OUTPUT : ', JSON.stringify(this.payload));
        if (this.year === '') {
            this.year = '2025';
        }
        this.getVehicleTypeOptions();
    }

    renderedCallback() {
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
            console.log('Payload data in the render CAllback', this.payload);
            this.populateFlag = false;
            const vehicleDetailsData = this.payload.find((item) => item.vehicleDetails);
            if (vehicleDetailsData) {
                let updatedVehicleDetails = { ...vehicleDetailsData.vehicleDetails };

                if (updatedVehicleDetails?.Vehicle_sub_type__c && vehicleSubTypesToClear.includes(updatedVehicleDetails.Vehicle_sub_type__c)) {
                    updatedVehicleDetails.Vehicle_sub_type__c = null;
                    this.vehicleType = null;
                }

                // ✅ Now safely assign to tracked property
                this.vehicleDetails = updatedVehicleDetails;

                console.log('OUTPUT :Updated vehicleDetails ', JSON.stringify(this.vehicleDetails));

                // console.log('Vehicle DEtails', this.vehicleDetails);
                this.updateInputValues();
                // console.log('After update input values', this.inputValues);
                this.populateInputFields();
                console.log('After populate inputs', this.inputValues);
                console.log('Vehicle details', this.vehicleDetails);
            }
        }
    }

    // Method to update inputValues with vehicleDetails
    updateInputValues() {
        if (this.vehicleDetails) {
            // Create a copy to avoid direct mutation (if needed)
            const updatedValues = { ...this.inputValues };

            // Loop through vehicleDetails and update matching fields
            for (const [key, value] of Object.entries(this.vehicleDetails)) {
                if (key in updatedValues) {
                    // Special handling for boolean fields if needed
                    if (typeof updatedValues[key] === 'boolean' && typeof value === 'string') {
                        console.log('In if', value);
                        updatedValues[key] = value.toLowerCase() === 'true';
                    } else {
                        console.log('In else', value);
                        updatedValues[key] = value;
                    }


                } else {
                    updatedValues[key] = value;
                }
            }
            console.log('Updated values', updatedValues);

            // Update the tracked property
            this.inputValues = updatedValues;
        }
    }

    populateInputFields() {
        console.log('OUTPUT yearOptions: ', this.yearOptions);
        // Get all input elements and set their values
        const inputs = this.template.querySelectorAll(
            'lightning-input, c-nc_combobox, lightning-checkbox-group, lightning-radio-group, lightning-combobox, input[type="radio"]'
        );

        inputs.forEach((input) => {
            const fieldName = input.name;
            const fieldValue = this.vehicleDetails[fieldName];
            // console.log('VD OUTPUT fieldName: ', fieldName);
            // console.log('VD OUTPUT fieldValue: ', fieldValue);

            if (fieldValue !== undefined) {

                if (input.type === 'checkbox') {
                    input.checked = typeof fieldValue === 'string' ? fieldValue.toLowerCase() === 'true' : fieldValue;

                } else if (input.type === 'radio') {
                    // console.log('in the radio type input loop');
                    this.template
                        .querySelector(`input[name="${fieldName}"][value="${fieldValue}"]`)
                        ?.setAttribute('checked', true);
                } else if (
                    input.localName === 'lightning-checkbox-group' ||
                    input.localName === 'lightning-radio-group'
                ) {
                    input.value = Array.isArray(fieldValue) ? fieldValue : [fieldValue];
                } else {
                    if (fieldName !== 'Year__c') {
                        input.value = fieldValue;
                    }
                    // console.log('OUTPUT : '+input.name, fieldValue);
                }
            }
        });

        this.make = this.vehicleDetails['Make'];
        this.model = this.vehicleDetails['Model'];
        this.vehicleValue = this.vehicleDetails['Value__c'];
        this.vehicleType = this.vehicleDetails['Vehicle_sub_type__c'];
        this.year = this.vehicleDetails['Year__c'];
        this.liabilityOnly = this.vehicleDetails['Coverage__c'] == 'Liability' ? true : false;
        // console.log('Make updated in popuateInput',this.make);
        // console.log('VEhicle details make',this.vehicleDetails['Make']);
        // console.log('Vehicle Sub type', this.vehicleType);
        // console.log('Coverage value',this.liabilityOnly);
        // console.log('Coverage Data in payload',this.vehicleDetails['Coverage__c']);
    }

    changevehicleOption(event) {
        const selectedId = event.target.value;
        const vehicleList = this.vehicleDetails.vehicleList || [];

        const selectedVehicle = vehicleList.find(vehicle => vehicle.Id === selectedId);

        if (selectedVehicle) {
            // Create a new object instead of mutating the reactive proxy
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

            // Reassign the object to preserve reactivity
            this.vehicleDetails = updatedVehicleDetails;
            this.populateInputFields();
            this.updateInputValues();
            console.log('VEhicle DEtails Updated', this.vehicleDetails);
        } else {
            console.warn('Vehicle not found with Id:', selectedId);
        }
    }
}