import { LightningElement, track, api, wire } from 'lwc';
import getCountries from '@salesforce/apex/FinalizeVehicleDetailsFlow.getCountries';
import getStatesByCountry from '@salesforce/apex/FinalizeVehicleDetailsFlow.getStatesByCountry';
import saveFinalizeVehicleDetails from '@salesforce/apex/FinalizeVehicleDetailsFlow.saveFinalizeVehicleDetails';
import updateQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.updateQuoteRecordData';


export default class Buho_finalizeVehicleDetails extends LightningElement {
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

            this.countryOptions = [
                { label: 'Select Country', value: '' },
                ...countries.map(country => ({
                    label: country,
                    value: country
                }))
            ];
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

    // Handle input changes from buho_input component
    handleInputChange(event) {
        const { name, value } = event.detail;
        this.vehicleDetails = { ...this.vehicleDetails, [name]: value };
        console.log('Vehicle Details', this.vehicleDetails);
    }

    // Handle VIN input with uppercase and length limit
    handleVINInput(event) {
        const { value } = event.detail;
        if (value) {
            let upperValue = value.toUpperCase();
            if (upperValue.length > 17) {
                upperValue = upperValue.substring(0, 17);
            }
            this.vehicleDetails = { ...this.vehicleDetails, Vin__c: upperValue };
        }
    }

    // Handle license plate input with uppercase
    handleLicensePlateInput(event) {
        const { value } = event.detail;
        if (value) {
            const upperValue = value.toUpperCase();
            this.vehicleDetails = { ...this.vehicleDetails, licensePlate: upperValue };
        }
    }

    // Handle country combobox change
    handleCountryChange(event) {
        const { value } = event.detail;
        this.vehicleDetails = { ...this.vehicleDetails, Registered_Country__c: value };
        this.registeredCountry = value;

        // Reset state when country changes
        //this.vehicleDetails.Registered_State__c = '';
        //this.registeredState = '';
        this.stateOptions = [];

        // Load states for selected country
        if (value) {
            getStatesByCountry({ country: value })
                .then(result => {
                    this.stateOptions = [
                        { label: 'Select State/Province', value: '' },
                        ...result.map(state => ({
                            label: state,
                            value: state
                        }))
                    ];
                    this.flag.isStateDisabled = false;
                    console.log('State Options: ', JSON.stringify(this.stateOptions));
                })
                .catch(error => {
                    console.error('Error loading states', error);
                    this.flag.isStateDisabled = false;
                });
        }
    }

    // Handle state combobox change
    handleStateChange(event) {
        const { value } = event.detail;
        this.vehicleDetails = { ...this.vehicleDetails, Registered_State__c: value };
        this.registeredState = value;
    }

    // Handle checkbox changes
    handleCheckboxChange(event) {
        const { name, checked } = event.detail;
        this.vehicleDetails = { ...this.vehicleDetails, [name]: checked };
        console.log('Vehicle Details', this.vehicleDetails);
    }


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
                this.vehicleDetails.Vin__c = this.vehicleDetails.Vin__c || '';
                this.vehicleDetails.licensePlate = this.vehicleDetails.licensePlate || (this.vehicleDetails.Registered_Plate__c || '');
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
            if(this.registeredCountry) {
                this.handleCountryChange({detail:{value:this.registeredCountry}});
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
                    this.stateOptions = [
                        { label: 'Select State/Province', value: '' },
                        ...result.map(state => ({
                            label: state,
                            value: state
                        }))
                    ];
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
        // Validate required fields
        const requiredFields = {
            'Vin__c': 'VIN Number',
            'licensePlate': 'License Plate',
            'Registered_Country__c': 'Registered Country',
            'Registered_State__c': 'Registered State/Province'
        };

        // Check VIN
        if (!this.vehicleDetails.Vin__c || this.vehicleDetails.Vin__c.trim() === '') {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Validation Error',
                    message: 'Please enter a VIN Number.'
                },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Check License Plate
        if (!this.vehicleDetails.licensePlate || this.vehicleDetails.licensePlate.trim() === '') {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Validation Error',
                    message: 'Please enter a License Plate.'
                },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Check Registered Country
        if (!this.vehicleDetails.Registered_Country__c || this.vehicleDetails.Registered_Country__c.trim() === '') {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Validation Error',
                    message: 'Please select a Registered Country.'
                },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Check Registered State
        if (!this.vehicleDetails.Registered_State__c || this.vehicleDetails.Registered_State__c.trim() === '') {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Validation Error',
                    message: 'Please select a Registered State/Province.'
                },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        if (this.ISDEBUG) console.log('FVD - validate - All fields valid:', this.vehicleDetails);
        return true;
    }

    // Handle continue button
    handleContinue() {
        if (!this.validate()) {
            return;
        }

        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

}