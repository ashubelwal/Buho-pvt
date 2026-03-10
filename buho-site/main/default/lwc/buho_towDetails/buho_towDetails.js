import { LightningElement, api, track } from 'lwc';
import saveTowDetails from '@salesforce/apex/TowDetailsFlow.saveTowDetails';
import BUHO_ASSETS from '@salesforce/resourceUrl/BuhoAssets';

const ICON_EDIT = BUHO_ASSETS + '/images/icon-edit.svg';

export default class Buho_towDetails extends LightningElement {
    @api payload;
    @api towedUnits = [];
    @track editUnit = {}; // Holds the current unit being edited
    @track showEditForm = false;
    editIndex = null; // Tracks the index of the unit being edited

    @track userType;

    get iconEdit() {
        return ICON_EDIT;
    }

    get hasTowedUnits() {
        return this.towedUnits && this.towedUnits.length > 0;
    }

    get towedUnitsForTemplate() {
        if (!this.towedUnits || this.towedUnits.length === 0) {
            return [];
        }
        return this.towedUnits.map((unit, idx) => {
            const uniqueId = String(unit.uid || unit.Id || `tow-${idx}`);
            return {
                ...unit,
                uid: uniqueId
            };
        });
    }

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
        const index = parseInt(event.currentTarget.dataset.index, 10);
        if (isNaN(index) || index < 0 || index >= this.towedUnits.length) return;
        
        this.editIndex = index;
        this.editUnit = { ...this.towedUnits[index] };
        this.showEditForm = true;
    }

    handleInputChange(event) {
        const { name, value } = event.detail;
        this.editUnit[name] = value;
    }

    handleSave() {
        // Validate required fields
        const requiredFields = ['Year__c', 'Make__c', 'Model__c', 'VIN_Number__c', 'Plate__c'];
        const missingFields = requiredFields.filter(field => !this.editUnit[field] || this.editUnit[field].toString().trim() === '');

        if (missingFields.length > 0) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Validation Error',
                    message: 'Please fill in all required fields: ' + missingFields.join(', ')
                },
                bubbles: true,
                composed: true
            }));
            return;
        }

        // Update the towed unit
        const updatedUnits = [...this.towedUnits];
        updatedUnits[this.editIndex] = { ...this.editUnit };
        this.towedUnits = updatedUnits;
        
        this.showEditForm = false;
        this.editUnit = {};
        this.editIndex = null;

        this.dispatchEvent(new CustomEvent('updatedtows', { 
            detail: this.towedUnits,
            bubbles: true,
            composed: true
        }));
    }


    handleCancel() {
        this.showEditForm = false;
        this.editUnit = {};
        this.editIndex = null;
    }

    connectedCallback() {
        console.log('Tow details: Payload data : ', this.payload);
        const towunits = this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.towunits;

        if (towunits) {
            this.towedUnits = Object.values(towunits).map((item, index) => {
                const uid = item?.Id || `tow-${index}-${Date.now()}-${Math.random()}`;
                return {
                    Towed_Unit_Type__c: item.Towed_Unit_Type__c,
                    Towed_Unit_Value__c: item.Towed_Unit_Value__c,
                    Days_in_Tow__c: item.Days_in_Tow__c,
                    Year__c: item?.Year__c,
                    Make__c: item?.Make__c,
                    Model__c: item?.Model__c,
                    VIN_Number__c: item?.VIN_Number__c,
                    Plate__c: item?.Plate__c,
                    Id: item?.Id,
                    uid: uid
                };
            });
            console.log("formattedArray", JSON.stringify(this.towedUnits));
        }
    }

    // Ensure towedUnits always have uid when set externally
    renderedCallback() {
        if (this.towedUnits && this.towedUnits.length > 0) {
            this.towedUnits.forEach((unit, index) => {
                if (!unit.uid) {
                    unit.uid = unit.Id || `tow-${index}-${Date.now()}-${Math.random()}`;
                }
            });
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
        // If user is editing a unit, they must save first
        if (this.showEditForm) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Validation Error',
                    message: 'Please save or cancel the current edit before proceeding.'
                },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Validate all fields in each tow unit object
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

        if (!this.towedUnits || this.towedUnits.length === 0) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Validation Error',
                    message: 'No towed units found. Please add towed units in the vehicle details section.'
                },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        for (let i = 0; i < this.towedUnits.length; i++) {
            const unit = this.towedUnits[i];
            for (let field of requiredFields) {
                if (!unit[field] || unit[field].toString().trim() === '') {
                    console.warn(`Validation failed for field "${field}" in tow unit index ${i}`, unit);
                    this.dispatchEvent(new CustomEvent('toastevent', {
                        detail: {
                            variant: 'error',
                            title: 'Validation Error',
                            message: `Please fill all the tow details for ${unit.Towed_Unit_Type__c || 'towed unit ' + (i + 1)}.`
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