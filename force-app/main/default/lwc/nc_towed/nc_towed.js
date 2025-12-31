import { LightningElement, track, api } from 'lwc';
import getTowMetadataRecords from '@salesforce/apex/NcController.getTowMetadataRecords';

export default class Nc_towed extends LightningElement {
    @api towedUnits = [];
    @api currentUserType;
    @api existingtowedUnits = [];

    @track newUnit = this.createEmptyUnit();
    @track editUnit = this.createEmptyUnit();
    @track isEditing = false;
    @track isFormCompleteStatus = false;
    @track editingIndex = null;
    @track isTowAdded = false;

    towedUnitTypes = [];

    connectedCallback() {

        console.log('OUTPUT : existingtowedUnits',this.existingtowedUnits);

        this.isTowAdded = this.towedUnits.length > 0;
        getTowMetadataRecords()
            .then(result => {
                this.towedUnitTypes = result;
            })
            .catch(err => {
                console.error('Tow Metadata Error:', err);
            });
    }

    createEmptyUnit() {
        return {
            Towed_Unit_Type__c: '',
            Towed_Unit_Value__c: '',
            Days_in_Tow__c: '',
            uid: Date.now() + Math.random(), // unique fallback ID'
            Year__c: '',
            Make__c: '',
            Model__c: '',
            VIN_Number__c: '',
            Plate__c: '',
        };
    }

    get getAvailableTypes() {
        const usedTypes = new Set(this.towedUnits.map((unit) => unit.Towed_Unit_Type__c));
        return this.towedUnitTypes.filter((option) => !usedTypes.has(option.value));
    }

    get showAddOrEditForm() {
        return this.isEditing || this.getAvailableTypes.length > 0;
    }

    get formType() {
        return this.isEditing ? this.editUnit.Towed_Unit_Type__c : this.newUnit.Towed_Unit_Type__c;
    }

    get formValue() {
        return this.isEditing ? this.editUnit.Towed_Unit_Value__c : this.newUnit.Towed_Unit_Value__c;
    }

    get formDays() {
        return this.isEditing ? this.editUnit.Days_in_Tow__c : this.newUnit.Days_in_Tow__c;
    }

    get saveOrAddButtonLabel() {
        return this.isEditing ? 'Save' : 'Add new tow';
    }

    handleChange(event) {
        const { name, value } = event.target;
        if (this.isEditing) {
            this.editUnit[name] = value;
        } else {
            this.newUnit[name] = value;
        }
        this.validateForm();
    }

    handleEdit(event) {
        const index = parseInt(event.currentTarget.dataset.index, 10);
        if (isNaN(index) || index < 0 || index >= this.towedUnits.length) return;

        this.isEditing = true;
        this.editingIndex = index;
        this.editUnit = { ...this.towedUnits[index] };
    }

    cancelEdit() {
        this.isEditing = false;
        this.editUnit = this.createEmptyUnit();
        this.editingIndex = null;
    }

    handleDelete(event) {
        const index = parseInt(event.currentTarget.dataset.index, 10);
        if (isNaN(index) || index < 0 || index >= this.towedUnits.length) return;

        const updatedList = [...this.towedUnits];
        updatedList.splice(index, 1);
        this.towedUnits = updatedList;
        this.isTowAdded = this.towedUnits.length > 0;
        this.isEditing = false;
        this.getTowData();
    }

    handleSaveOrAdd() {
        if (!this.validate()) return;

        const unit = this.isEditing ? this.editUnit : this.newUnit;

        if (!this.validateDays(unit.Days_in_Tow__c)) {
            this.dispatchEvent(new CustomEvent('toastevent', { 
                detail: {
                    variant:'error', 
                    title: 'Invalid Days', 
                    message: 'Days in Tow must be consistent across all units.'
                    },
                    bubbles: true,
                    composed: true
                })
            );
            return;
        }

        if (this.isEditing) {
            const updatedList = [...this.towedUnits];
            updatedList[this.editingIndex] = { ...unit };
            this.towedUnits = updatedList;
            this.cancelEdit();
        } else {
            this.towedUnits = [...this.towedUnits, { ...unit }];
            this.newUnit = this.createEmptyUnit();
        }

        this.isTowAdded = this.towedUnits.length > 0;
        this.getTowData();
    }

    validateDays(newDays) {
        return this.towedUnits.every(unit => unit.Days_in_Tow__c === newDays) || !this.towedUnits.length;
    }

    validateForm() {
        const { Towed_Unit_Type__c, Towed_Unit_Value__c, Days_in_Tow__c } = this.isEditing ? this.editUnit : this.newUnit;
        this.isFormCompleteStatus = !(Towed_Unit_Type__c && Towed_Unit_Value__c && Days_in_Tow__c);
    }

    @api validate() {
        const inputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
        let allValid = true;

        inputs.forEach(input => {
            if (input.required && !input.checkValidity()) {
                input.classList.add('slds-has-error');
                input.reportValidity();
                allValid = false;
            } else {
                input.classList.remove('slds-has-error');
            }
        });

        return allValid;
    }

    getTowData() {
        this.dispatchEvent(new CustomEvent('towedadd', {
            detail: this.towedUnits
        }));
    }

    changetowedOption(event) {
        const selectedId = event.target.value;
        const vehicleList = this.existingtowedUnits || [];
        const selectedVehicle = vehicleList.find(vehicle => vehicle.value === selectedId);

        if (selectedVehicle) {
            const alreadyExists = this.towedUnits.some(unit => unit.value === selectedId);
            if (alreadyExists) { 
                this.dispatchEvent(
                    new CustomEvent('toastevent', {
                        detail: {
                            variant:'error', 
                            title: 'Duplicate Tow', 
                            message: 'This towed unit is already added.'
                        },
                        bubbles: true,
                        composed: true
                    })
                );
                return;
            }

            this.newUnit = {
                Towed_Unit_Type__c: selectedVehicle.Towed_Unit_Type__c || '',
                Towed_Unit_Value__c: selectedVehicle.Towed_Unit_Value__c || '',
                Days_in_Tow__c: selectedVehicle.Days_in_Tow__c || '',
                value: selectedVehicle.value,
                Id: selectedVehicle.Id,
                Year__c: selectedVehicle.Year__c || '',
                Make__c: selectedVehicle.Make__c || '',
                Model__c: selectedVehicle.Model__c || '',
                VIN_Number__c: selectedVehicle.VIN_Number__c || '',
                Plate__c: selectedVehicle.Plate__c || '',
                uid: Date.now() + Math.random()
            };

            this.validateForm();
        }
    }
}