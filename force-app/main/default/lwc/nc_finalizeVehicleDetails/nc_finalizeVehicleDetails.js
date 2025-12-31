import { LightningElement, track, api, wire } from 'lwc';
import getCountries from '@salesforce/apex/FinalizeVehicleDetailsFlow.getCountries';
import getStatesByCountry from '@salesforce/apex/FinalizeVehicleDetailsFlow.getStatesByCountry';
import saveFinalizeVehicleDetails from '@salesforce/apex/FinalizeVehicleDetailsFlow.saveFinalizeVehicleDetails';
import updateQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.updateQuoteRecordData';


export default class Nc_finalizeVehicleDetails extends LightningElement {
    // Payload received as API property, expected to contain vehicle details
    @api payload;
    countryOptions = [];
    ISDEBUG = true;
    @track stateOptions = [];
    @track flag = { isStateDisabled: true };
    includeMexico = false;
    @track registeredCountry = '';
    @track registeredState = '';

    // Wire method to get countries on component load
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            let countries = data;

            // Filter Mexico based on the includeMexico boolean
            if (!this.includeMexico) {
                countries = data.filter(country => country !== 'Mexico');
            }

            this.countryOptions = countries.map(country => {
                return { label: country, value: country };
            });
        } else if (error) {
            console.error('Error loading countries', error);
        }
    }

    // Tracks vehicle details and updates when user makes changes
    @track vehicleDetails = {
        "Is_Lienholder__c": false       // Whether the vehicle is leased or financed
    };

    // Boolean variable to track component loading state
    @track boolvar = {
        isLoaded: false  // Indicates when the component has completed initialization
    };

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

    /**
     * Handles changes in input fields and updates the vehicleDetails object.
     * Supports both checkbox and text input fields.
     * @param {Event} event - The event triggered when an input field changes
     */
    // handleChange(event) {
    //     const fieldName = event.target.name;  // Get the field name from the input
    //     const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value; // Handle checkbox vs. text inputs
    //     this.vehicleDetails = { ...this.vehicleDetails, [fieldName]: value }; // Update the vehicle details dynamically
    //     console.log('Vehicle Details', this.vehicleDetails);
    // }
    // handleChange(event) {
    // const fieldName = event.target.name;  // Get the field name from the input
    // let value = event.target.type === 'checkbox' ? event.target.checked : event.target.value; // Handle checkbox vs. text inputs

    // // Convert license plate to uppercase automatically
    //     if (fieldName === 'licensePlate') {
    //         value = value.toUpperCase();
    //         // Update the input field display with uppercase value
    //         event.target.value = value;
    //     }

    //     this.vehicleDetails = { ...this.vehicleDetails, [fieldName]: value }; // Update the vehicle details dynamically
    //     console.log('Vehicle Details', this.vehicleDetails);
    // }
    handleChange(event) {
        const fieldName = event.target.name;
        let value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

        if (fieldName === 'licensePlate') {
            value = value.toUpperCase();
            event.target.value = value;
        }
        if (fieldName === 'Vin__c') {
            value = value.toUpperCase();
            if (value.length > 17) {
                value = value.substring(0, 17);
            }
            event.target.value = value;
        }

        this.vehicleDetails = { ...this.vehicleDetails, [fieldName]: value };
        console.log('Vehicle Details', this.vehicleDetails);
    }


    // handleOptionClick(event) {
    //     console.log('Event in the handleOption Click', event.detail);
    //     const { name, value, inputName } = event.detail;

    //     if (inputName === 'Registered_Country__c') {
    //         this.vehicleDetails = { ...this.vehicleDetails, [inputName]: value };
    //         this.handleComboboxReset('Registered_Country__c');
    //         this.vehicleDetails.Registered_State__c = ''; // Reset state when country changes
    //         this.stateOptions = []; // Clear previous states

    //         if (this.vehicleDetails.Registered_Country__c) {
    //             getStatesByCountry({ country: this.vehicleDetails.Registered_Country__c })
    //                 .then(result => {
    //                     this.stateOptions = result.map(state => {
    //                         return { label: state, value: state };
    //                     });
    //                     this.flag.isStateDisabled = false;
    //                     console.log('State Options: ', JSON.stringify(this.stateOptions));
    //                 })
    //                 .catch(error => {
    //                     console.error('Error loading states', error);
    //                     this.flag.isStateDisabled = false;

    //                 });
    //         }
    //     }

    //     if (inputName === 'Registered_State__c') {
    //         this.vehicleDetails = { ...this.vehicleDetails, [inputName]: value };
    //     }
    // }
    handleOptionClick(event) {
        console.log('Event in the handleOption Click', event.detail);
        const { name, value, inputName } = event.detail;

        if (inputName === 'Registered_Country__c') {
            this.vehicleDetails = { ...this.vehicleDetails, [inputName]: value };
            this.registeredCountry = value;

            this.handleComboboxReset('Registered_Country__c');
            this.vehicleDetails.Registered_State__c = '';
            this.registeredState = '';
            this.stateOptions = [];

            if (value) {
                getStatesByCountry({ country: value })
                    .then(result => {
                        this.stateOptions = result.map(state => ({
                            label: state,
                            value: state
                        }));
                        this.flag.isStateDisabled = false;
                        console.log('State Options: ', JSON.stringify(this.stateOptions));
                    })
                    .catch(error => {
                        console.error('Error loading states', error);
                        this.flag.isStateDisabled = false;
                    });
            }
        }

        if (inputName === 'Registered_State__c') {
            this.vehicleDetails = { ...this.vehicleDetails, [inputName]: value };
            this.registeredState = value;
        }
    }


    handleChildComboboxReset() {
        this.handleComboboxReset('Registered_Country__c');
    }

    handleComboboxReset(value) {
        if (value === 'Registered_Country__c') {
            const comboboxes = this.template.querySelectorAll('c-nc_combobox');
            if (comboboxes) {
                comboboxes.forEach((combobox) => {
                    if (combobox.inputLabel === 'Registered State/Province') {
                        combobox.handleReset();
                    }
                });
                this.stateOptions = [{ label: 'Select state', value: 'Select state' }];
            }
        }
    }

    handleAddValue(event) {
        const { value, label, name } = event.detail;
        this.vehicleDetails = { ...this.vehicleDetails, [name]: value };
        if (name === 'Registered_Country__c') {
            this.flag.isStateDisabled = false;

        }

    }

    /**
     * Lifecycle hook that runs when the component is inserted into the DOM.
     * It initializes the vehicleDetails from the payload if available.
     * Uses setTimeout to simulate a loading delay.
     */
    // connectedCallback() {
    //     this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
    //     // Extract vehicle details from the payload
    //     if (this.payload) {
    //         console.log('Inside payload', this.payload);
    //         const payloadVehicleDetails = this.payload.find(item => item.vehicleDetails)?.vehicleDetails;
    //         if (payloadVehicleDetails) {
    //             // Merge payload data with existing vehicleDetails (preserving Is_Lienholder__c)
    //             this.vehicleDetails = {
    //                 ...this.vehicleDetails, // Keep existing properties
    //                 ...payloadVehicleDetails // Override with payload data
    //             };
    //             this.registeredCountry = payloadVehicleDetails?.Registered_Country__c ?? '';
    //             this.registeredState = payloadVehicleDetails?.Registered_State__c ?? '';
    //         }
    //         const finalVehicleDetails = this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails;
    //         if (finalVehicleDetails) {
    //             // Merge payload data with existing vehicleDetails (preserving Is_Lienholder__c)
    //             const mergedVehicleDetails = { ...this.vehicleDetails };

    //             for (const key in finalVehicleDetails) {
    //                 if (!(key in this.vehicleDetails)) {
    //                     mergedVehicleDetails[key] = finalVehicleDetails[key];
    //                 }
    //             }

    //             this.vehicleDetails = mergedVehicleDetails;
    //             console.log('Updating con and stat values', this.vehicleDetails);
    //             this.registeredCountry = this.vehicleDetails?.Registered_Country__c ?? '';
    //             this.registeredState = this.vehicleDetails?.Registered_State__c ?? '';
    //             console.log('Updated values', this.registeredCountry);
    //             console.log('Registred', this.registeredState);
    //         }


    //     }
    //     // Simulate a loading delay before setting isLoaded to true
    //     setTimeout(() => {
    //         this.boolvar.isLoaded = true;
    //         this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true}));
    //     }, 1000);
    // }

    // WORKING ONE ////////////////////////////////////////////////////
    //     connectedCallback() {
    //     this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));

    //     if (this.payload) {
    //         const payloadVehicleDetails = this.payload.find(item => item.vehicleDetails)?.vehicleDetails;
    //         const finalVehicleDetails = this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails;

    //         let mergedVehicleDetails = { ...this.vehicleDetails };

    //         if (payloadVehicleDetails) {
    //             mergedVehicleDetails = {
    //                 ...mergedVehicleDetails,
    //                 ...payloadVehicleDetails
    //             };
    //         }

    //         if (finalVehicleDetails) {
    //             for (const key in finalVehicleDetails) {
    //                 if (!(key in mergedVehicleDetails)) {
    //                     mergedVehicleDetails[key] = finalVehicleDetails[key];
    //                 }
    //             }
    //         }

    //         this.vehicleDetails = mergedVehicleDetails;

    //         // Set defaults if not present
    //         if (!this.vehicleDetails?.Registered_Country__c) {
    //             this.vehicleDetails.Registered_Country__c = 'United States';

    //             getStatesByCountry({ country: this.vehicleDetails.Registered_Country__c })
    //                 .then(result => {
    //                     this.stateOptions = result.map(state => ({
    //                         label: state,
    //                         value: state
    //                     }));
    //                     this.flag.isStateDisabled = false;
    //                 })
    //                 .catch(error => {
    //                     console.error('Error loading states', error);
    //                     this.flag.isStateDisabled = false;
    //                 });
    //         }

    //         this.registeredCountry = this.vehicleDetails.Registered_Country__c;
    //         this.registeredState = this.vehicleDetails.Registered_State__c;

    //         // Force the logic that happens when country is selected manually
    //         this.handleOptionClick({
    //             detail: {
    //                 name: 'Registered_Country__c',
    //                 inputName: 'Registered_Country__c',
    //                 value: this.registeredCountry
    //             }
    //         });

    //         console.log('Default Registered Country:', this.registeredCountry);
    //         console.log('Default Registered State:', this.registeredState);
    //     }

    //     setTimeout(() => {
    //         this.boolvar.isLoaded = true;
    //         this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    //     }, 1000);
    // }
    // WORKING ONE ////////////////////////////////////////////////////

    // OLD ONE ////////////////////////////////////////////////////
    // connectedCallback() {
    //     // Extract vehicle details from the payload
    //     if (this.payload) {
    //         console.log('Inside payload', this.payload);
    //         const payloadVehicleDetails = this.payload.find(item => item.vehicleDetails)?.vehicleDetails;
    //         if (payloadVehicleDetails) {
    //             // Merge payload data with existing vehicleDetails (preserving Is_Lienholder__c)
    //             this.vehicleDetails = {
    //                 ...this.vehicleDetails, // Keep existing properties
    //                 ...payloadVehicleDetails // Override with payload data
    //             };
    //             this.registeredCountry = payloadVehicleDetails?.Registered_Country__c ?? '';
    //             this.registeredState = payloadVehicleDetails?.Registered_State__c ?? '';
    //         }
    //         const finalVehicleDetails = this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails;
    //         if (finalVehicleDetails) {
    //             // Merge payload data with existing vehicleDetails (preserving Is_Lienholder__c)
    //             this.vehicleDetails = {
    //                 ...this.vehicleDetails, // Keep existing properties
    //                 ...finalVehicleDetails // Override with payload data
    //             };
    //             console.log('Updating con and stat values', this.vehicleDetails);
    //             this.registeredCountry = this.vehicleDetails?.Registered_Country__c ?? '';
    //             this.registeredState = this.vehicleDetails?.Registered_State__c ?? '';
    //             console.log('Updated values', this.registeredCountry);
    //             console.log('Registred', this.registeredState);
    //         }


    //     }
    //     // Simulate a loading delay before setting isLoaded to true
    //     setTimeout(() => {
    //         this.boolvar.isLoaded = true;
    //     }, 1000);
    // }
    // OLD ONE ////////////////////////////////////////////////////

    connectedCallback() {
        // Extract vehicle details from the payload
        if (this.payload) {
            console.log('Inside payload', this.payload);
            const payloadVehicleDetails = this.payload.find(item => item.vehicleDetails)?.vehicleDetails;
            if (payloadVehicleDetails) {
                // Merge payload data with existing vehicleDetails (preserving Is_Lienholder__c)
                this.vehicleDetails = {
                    ...this.vehicleDetails, // Keep existing properties
                    ...payloadVehicleDetails // Override with payload data
                };
                this.registeredCountry = payloadVehicleDetails?.Registered_Country__c ?? '';
                this.registeredState = payloadVehicleDetails?.Registered_State__c ?? '';
            }
            const finalVehicleDetails = this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails;
            if (finalVehicleDetails) {
                // Merge payload data with existing vehicleDetails (preserving Is_Lienholder__c)
                this.vehicleDetails = {
                    ...this.vehicleDetails, // Keep existing properties
                    ...finalVehicleDetails // Override with payload data
                };
                console.log('Updating con and stat values', this.vehicleDetails);
                this.registeredCountry = this.vehicleDetails?.Registered_Country__c ?? '';
                this.registeredState = this.vehicleDetails?.Registered_State__c ?? '';
                console.log('Updated values', this.registeredCountry);
                console.log('Registred', this.registeredState);
            }
        }

        // Set default country to "United States" if no country is already set
        if (!this.registeredCountry) {
            this.registeredCountry = 'United States';
            this.vehicleDetails = {
                ...this.vehicleDetails,
                Registered_Country__c: 'United States'
            };

            // Load states for United States by default
            getStatesByCountry({ country: 'United States' })
                .then(result => {
                    this.stateOptions = result.map(state => ({
                        label: state,
                        value: state
                    }));
                    this.flag.isStateDisabled = false;
                    console.log('Default State Options for US: ', JSON.stringify(this.stateOptions));
                })
                .catch(error => {
                    console.error('Error loading default states for US', error);
                    this.flag.isStateDisabled = false;
                });
        }

        // Simulate a loading delay before setting isLoaded to true
        setTimeout(() => {
            this.boolvar.isLoaded = true;
        }, 1000);
    }
    /**
     * API method to retrieve the latest vehicle details.
     * @returns {Object} The updated vehicle details object.
     */
    @api async getData() {
        console.log('Finalize vehicle details - getData: ', JSON.stringify(this.vehicleDetails));
        // call apex method to save Vehicles data in lead obj
        let temp = { ['finalizeVehicleDetails']: this.vehicleDetails };
        this.payload = [...this.payload, temp];
        if (!this.currentUserType) {
            saveFinalizeVehicleDetails({ strLeadDetails: JSON.stringify(this.payload) })
                .then(result => {
                    console.log('Res from saving Vehicle Data: ', result);
                })
                .catch(err => {
                    console.log('Getting error while saving the Vehicle Data: ', JSON.stringify(err));
                })
        } else {
            // Prepare the data
            const quotePageObj = this.payload.find(item => item.quotePage);
            const quoteRecord = quotePageObj ? quotePageObj.quotePage.QuoteData : null;

            const vehicleDetailsObj = this.payload.find(item => item.finalizeVehicleDetails);
            const vehicleRecord = vehicleDetailsObj ? vehicleDetailsObj.finalizeVehicleDetails : null;

            const updatedVehicleData = this.processVehicleData(vehicleRecord);

            const towDetailsObj = this.payload.find(item => item.towDetails);
            const towedUnitRecord = towDetailsObj?.towDetails?.length > 0
                ? towDetailsObj.towDetails
                : null;

            // Call Apex method with properly formatted data
            const updateVehicleResp = await updateQuoteRecordData({
                quoteRecord: quoteRecord ? JSON.stringify(quoteRecord) : '',
                vehicleRecord: vehicleRecord ? JSON.stringify(updatedVehicleData) : '',
                towedUnitRecord: towedUnitRecord ? JSON.stringify(towedUnitRecord) : '',
                driversRecord: ''
            });
            console.log('Vehicle Registerd Update', updateVehicleResp);
            if (updateVehicleResp.status == 'success') {
                console.log('Vehicle Registered Updated', updateVehicleResp);
                const savedVehicleData = updateVehicleResp?.vehicleData;
                const savedQuoteData = updateVehicleResp?.quoteData;
                const savedTowedData = updateVehicleResp?.towedUnitData;
                if (savedVehicleData != null) {
                    console.log('Vehicle data on save', savedVehicleData);
                    this.dispatchPayloadUpdate('vehicleDetails', {
                        Id: savedVehicleData?.Id != null ? savedVehicleData.Id : '',
                        Account_Vehicle__c: savedVehicleData?.Account_Vehicle__c != null ? savedVehicleData.Account_Vehicle__c : '',
                        Contact__c: savedVehicleData?.Contact__c != null ? savedVehicleData.Contact__c : ''
                    });
                }
                if (savedQuoteData != null) {
                    console.log('Quote data on save', savedQuoteData);
                    this.dispatchPayloadUpdate('quotePage', {
                        QuoteData: savedQuoteData
                    });
                }
                if (savedTowedData != null && savedTowedData != undefined) {
                    console.log('Towed data on save', savedTowedData);
                    this.dispatchPayloadUpdate('vehicleDetails', {
                        towunits: savedTowedData
                    });
                }
            }
        }
        return this.vehicleDetails;
    }

    /**
 * Processes vehicle details by removing unwanted fields and keeping only specified ones
 * @param {Object} vehicleDetails - The original vehicle details object
 * @returns {Object} - Processed vehicle details with only required fields
 */
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
            'Contact__c'
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

    //Update the payload based on after vehicle and tow update
    dispatchPayloadUpdate(key, data) {
        const updateEvent = new CustomEvent('payloadupdate', {
            detail: {
                updates: {
                    [key]: {
                        ...data // Spread the provided data
                    }
                }
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(updateEvent);
    }


    /**
     * API method to validate the component data.
     * Currently, it always returns true (no validation logic implemented).
     * @returns {boolean} Always returns true.
     */
    @api validate() {
        const inputs = this.template.querySelectorAll('lightning-input, c-nc_combobox, lightning-checkbox-group, lightning-radio-group, lightning-combobox');
        const values = {};
        let allValid = true;

        inputs.forEach(input => {
            const { required, value, name, type } = input;

            // Handle validation for required fields
            if (required && !input.checkValidity() || input && !input.reportValidity()) {
                input.classList.add('slds-has-error'); // Add error styling
                input.reportValidity(); // Show validation message
                allValid = false;
            } else {
                input.classList.remove('slds-has-error'); // Remove error styling if valid
                // Capture values based on type
                let inputValue;
                if (type === 'checkbox') {
                    inputValue = input.checked; // Checkbox value
                } else if (type === 'radio') {
                    inputValue = input.value; // Selected radio value
                } else if (type === 'combobox') {
                    inputValue = input.value; // Selected combobox value
                } else {
                    inputValue = value; // For text, email, etc.
                }

                // Add to value
                values[name] = inputValue;
            }
        });

        if (allValid) {
            //  this.vehicleDetails = values; // Update with valid values             
            if (this.ISDEBUG) console.log('FVD - validate - Captured values:', this.vehicleDetails);
        } else {
            if (this.ISDEBUG) console.error('FVD - validate - Some required fields are invalid. Please fix the errors and try again.');
            return false;
        }

        return true;  // Valid if fields are filled
    }

}