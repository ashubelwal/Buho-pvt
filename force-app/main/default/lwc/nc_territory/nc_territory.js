import { LightningElement, track, api } from 'lwc';
import image from '@salesforce/resourceUrl/mexJs';
import mexImage from '@salesforce/resourceUrl/mexinsurance_assets';
import saveTerritoryDetails from '@salesforce/apex/TerritoryOptionFlow.saveTerritoryDetails';

export default class Nc_territory extends LightningElement {
    @api payload;
    @track parentPayloadData;
    isDebug = true;

    @track inputValues = {};
    options = [
        { label: 'Baja/Sonora', value: 'Baja/Sonora', selected: true, imageUrl: image + '/mexJs/images/MexicoBajaSonora.png' },
        { label: 'Baja/Sonora Baja, Sonora, Chihuahua, Coahuila, Nuevo Leon, Tamaulipas', value: 'Limited', selected: false, imageUrl: mexImage + '/images/max-mexico-partial@2x.png' },
        { label: 'Entire Mexico', value: 'Full', selected: false, imageUrl: mexImage + '/images/map-mexico-full@2x.png' }
    ];

    @track booleanvar = {
        isError: false,
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

    async handleInputChange(event) {
        try {
            const { value } = event.target;

            // Update selected option in optio n array
            this.options = this.options.map(option => ({
                ...option,
                selected: option.value === value
            }));
            if (this.isDebug) console.log('Selected region:', this.inputValues);

            this.booleanvar.isError = false;
        } catch (err) {
            if (this.isDebug) console.log('OUTPUT : ', err.message);
        }
    }

    // Validation method (returns true if valid, false if invalid)
    @api validate() {
        const inputs = this.template.querySelectorAll('input');
        let allValid = true;

        inputs.forEach(input => {
            const { required, value, type, name, checked } = input;
            // Handle validation for required fields
            if (required && !input.checkValidity()) {
                input.classList.add('slds-has-error'); // Add error styling
                input.reportValidity(); // Show validation message
                allValid = false;
                this.booleanvar.isError = true;
            } else {
                this.booleanvar.isError = false;
                input.classList.remove('slds-has-error'); // Remove error styling if valid 

                // Capture values based on type                
                if (type === 'radio' && checked == true) {
                    this.inputValues['region'] = value;
                    if (this.isDebug) console.log("name ---- " + name + "Value: " + value + "checked---: " + checked);
                }
            }
        });

        if (allValid) {
            // this.inputValues = values; // Update with valid values
            if (this.isDebug) console.log('Territory: Captured values:', this.inputValues);
        } else {
            console.error('Territory: Some required fields are invalid. Please fix the errors and try again.');
            return false;
        }
        return true;  // Valid if fields are filled
    }

    @api async getData() {

        let temp = { ['territory']: this.inputValues }
        let updatedPayload = [...this.payload];

        const existingIndex = this.payload.findIndex(item =>
            Object.keys(item)[0] === "territory"
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
        // call apex method to save TerritoryOption data in lead obj
        if (this.isDebug) console.log('saveTerritoryDetails data  : ', JSON.stringify(this.payload));
        if (!this.currentUserType) {
            saveTerritoryDetails({ strLeadDetails: JSON.stringify(this.payload) })
                .then(result => {
                    if (this.isDebug) console.log('Res from sabe territory data: ', result);
                })
                .catch(err => {
                    if (this.isDebug) console.log('Getting error while saving the TerritoryOption: ', JSON.stringify(err));
                })
        }

        if (this.isDebug) console.log('Territory - getData - Final Data', JSON.stringify(this.inputValues));
        return this.inputValues;
    }
}