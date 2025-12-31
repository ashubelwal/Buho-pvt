import { LightningElement, api, track } from 'lwc';
import saveTowDetails from '@salesforce/apex/TowDetailsFlow.saveTowDetails';
export default class Nc_towDetails extends LightningElement {
    @api payload;
    @api towedUnits = [
        {
            "type": "Type 2",
            "value": "Value 1",
            "days": "1"
        },
        {
            "type": "Type 1",
            "value": "Value 1",
            "days": "1"

        }]; // Data from the first component
    @track editUnit = {}; // Holds the current unit being edited
    @track showEditForm = false;
    editIndex = null; // Tracks the index of the unit being edited

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

    handleEdit(event) {
        this.editIndex = event.target.dataset.index;
        this.editUnit = { ...this.towedUnits[this.editIndex] };
        this.showEditForm = true;
    }

    handleChange(event) {
        const { name, value } = event.target;
        this.editUnit[name] = value;
    }

    handleSave() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;

        inputs.forEach(input => {
            if (!input.reportValidity()) {
                isValid = false;
            }
        });

        if (!isValid) {
            return;
        }

        this.towedUnits[this.editIndex] = { ...this.editUnit };
        this.showEditForm = false;
        this.editUnit = {};

        this.dispatchEvent(new CustomEvent('updatedtows', { detail: this.towedUnits }));
    }


    handleCancel() {
        this.showEditForm = false;
        this.editUnit = {};
    }

    connectedCallback() {
        console.log('Tow details: Payload data : ', this.payload);
        const towunits = this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.towunits;

        if (towunits) {
            this.towedUnits = Object.values(towunits).map(item => ({
                Towed_Unit_Type__c: item.Towed_Unit_Type__c,
                Towed_Unit_Value__c: item.Towed_Unit_Value__c,
                Days_in_Tow__c: item.Days_in_Tow__c,
                Year__c: item?.Year__c,
                Make__c: item?.Make__c,
                Model__c: item?.Model__c,
                VIN_Number__c: item?.VIN_Number__c,
                Plate__c: item?.Plate__c,
                Id: item?.Id
            }));
            console.log("formattedArray", JSON.stringify(this.towedUnits));
        }
    }

    @api async getData() {
        console.log('Tow Details - getData: ', this.towedUnits);
        //Method to save the tow values into the lead
        //Call apex method to save Tow data in lead obj
        let temp = { ['towDetails']: this.towedUnits };
        this.payload = [...this.payload, temp];
        if (!this.currentUserType) {
            saveTowDetails({ strLeadDetails: JSON.stringify(this.payload) })
                .then(result => {
                    console.log('Res from saving Vehicle Data: ', result);
                })
                .catch(err => {
                    this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: {
                        variant: 'error',
                        title: 'Error!',
                        message: JSON.stringify(err)
                    },
                    bubbles: true,
                    composed: true
                }));
                    console.log('Getting error while saving the Vehicle Data: ', JSON.stringify(err));
                })
        }
        return this.towedUnits;
    }

    @api validate() {        

        // If user is editing a unit, validate visible form inputs
        if (this.showEditForm) {
            const inputs = this.template.querySelectorAll('lightning-input');
            inputs.forEach(input => {
                if (!input.reportValidity()) {
                    return false;
                }
            });            
            // return isValid;
        }

        // Otherwise, validate all fields in each tow unit object
        const requiredFields = [
            'Towed_Unit_Type__c',
            'Towed_Unit_Value__c',
            'Days_in_Tow__c',
            'Year__c',
            'Make__c',
            'Model__c',
            'VIN_Number__c',
            'Plate__c'
        ];

        for (let i = 0; i < this.towedUnits.length; i++) {
            const unit = this.towedUnits[i];
            for (let field of requiredFields) {
                if (!unit[field] || unit[field].toString().trim() === '') {
                    console.warn(`Validation failed for field "${field}" in tow unit index ${i}`, unit);
                    this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: {
                        variant: 'error',
                        title: 'Error!',
                        message: `Please fill all the tow details for ${unit.Towed_Unit_Type__c}.`
                    },
                    bubbles: true,
                    composed: true
                }));
                    return false;
                }
            }
        }            
        return true;
    }
}