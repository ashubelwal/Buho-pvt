import { LightningElement, api, track } from 'lwc';

export default class AgentTowedUnit extends LightningElement {
    @api actionType;
    @api enableNewTowed;
    @api addedTowed;
    @api getYearsOptions;
    @api validateFields(towed){
        towed = JSON.parse(JSON.stringify(towed));
        console.log('towed----',towed);
        let count = 0;
        if(towed){
            if (towed.length > 0) {
                towed = towed.map((tow) => {
                        if (!tow.Year__c && !tow.Make__c && !tow.Model__c && !tow.VIN_Number__c && !tow.Plate__c) {
                            count++;
                            return;
                        }else {
                            return ;
                          }
                    });
                    console.log('Towed Unit Validate---',towed);
            }
        }
        console.log('count ---',count);
        if(count > 0){
            return false;
        }else{
            return true;
        }

        // let status = this.isInputValid('.quoteValidate');
        // if (!status) {
        //     return true;
        // }else{
        //     return false;
        // }
    }

    newTowed = {};
    towedCount = 0;
    isDaysInTowInvalid = false;
    isRequiredTowed = false;
    openEditTowed = false;
    currentDate = new Date();
    currentYear = this.currentDate.getFullYear();
    years = [];

    TowedVehicleOptions = [
        { label: 'Motorcycle', value: 'Motorcycle' },
        { label: 'ATV_UTV', value: 'ATV-UTV' },
        { label: 'Boat', value: 'Boat' },
        { label: 'Camper', value: 'Camper' },
        { label: 'Utility_Misc_Trailer', value: 'Utility/Misc Trailer' },
        { label: 'Towed_Automobile', value: 'Towed Automobile' },
    ];

    isInputValid(className) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(className);
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleTowedInputChange = (event) => {
        this.newTowed[event.target?.name] = event.target.value;
    }

    handleEditTowed = (event) => {
        if(this.actionType == 'editRenew'){
            this.enableNewTowed =false;
        }
        
        console.log('--handleEditTowed--',this.addedTowed);
        this.addedTowed = JSON.parse(JSON.stringify(this.addedTowed));
        console.log('--handleEditTowed--AFTER Parse',this.addedTowed);
        this.isRequiredTowed = true;
        this.newTowed = {};
        this.addedTowed.map(towedUnit => {
            if (event.target.dataset?.id == towedUnit?.towedCount) {
                this.newTowed = { ...towedUnit };
                towedUnit.isDeleteTowedButton = false;
                towedUnit.selectedStyle = 'background:#feded8';
            } else {
                towedUnit.isDeleteTowedButton = true;
                towedUnit.selectedStyle = '';
            }
        });

        this.openEditTowed = true;
        console.log('--openEditTowed--',this.openEditTowed);
        console.log('--addedTowed--222',this.addedTowed);
    }

    handleDeleteTowned = (event) => {
        
        this.addedTowed = JSON.parse(JSON.stringify(this.addedTowed));
        this.addedTowed = this.addedTowed.filter(towedUnit => {
            return towedUnit.towedCount != event.target.dataset.id
        });

        console.log('Added towed empty--',this.addedTowed);
        if(this.addedTowed.length < 1){
            console.log('Added towed empty------- 0000');
            this.addedTowed = [];
            this.openEditTowed = false;
            if(this.actionType == 'editRenew'){
                this.enableNewTowed =true;
            }
        }

        const updateTowedEvent = new CustomEvent('updatetowed',{
            detail : this.addedTowed
        });
        this.dispatchEvent(updateTowedEvent);

    }

    handleAddNewTowed = () => {
        console.log('INSIDE ADD NEW TOWED');
        let status = this.isInputValid('.cTowed');
        console.log('---------->',status);
        if(status ){
            console.log('STATSUS ADD NEW Towed');
            if (this.addedTowed && this.addedTowed.length > 0) {
                const firstTowed = this.addedTowed[0];
                console.log('firstTowed.Days_in_Tow__c-->',firstTowed.Days_in_Tow__c);
                console.log('this.newTowed.Days_in_Tow__c-->',this.newTowed.Days_in_Tow__c);
                if (firstTowed.Days_in_Tow__c != this.newTowed.Days_in_Tow__c) {
                    console.log('INSIDE NOT SAME DAYS TOWED-->');
                    this.isDaysInTowInvalid = true;
                    return;
                }
            }
    
            this.isDaysInTowInvalid = false;
            if (this.addedTowed != null) {
                this.addedTowed.map((towed) => {
                    if (towed.towedCount > this.towedCount) {
                        this.towedCount = towed.towedCount;
                    }
                });
            }
    
            this.newTowed.towedCount = this.towedCount + 1;
            this.newTowed.isDeleteTowedButton = true;
            this.addedTowed = [...this.addedTowed, this.newTowed];
            this.towedCount++;
            this.newTowed = {};
    
            // Create a separate method and pass the class to reset
            this.template.querySelectorAll(".cTowed").forEach((inputField) => {
                inputField.value = null;
            });
            this.isRequiredTowed = false;
            const updateTowedEvent = new CustomEvent('updatetowed',{
                detail : this.addedTowed
            });
            this.dispatchEvent(updateTowedEvent);
        }else {
            console.log('ELSE ADD NEW Towed');
            if(this.cmpSource == 'comm'){
                this.showToastmethod('error', 'Please add the towed unit; otherwise, make the towing unchecked.','Add Towed unit');

            }else{
                this.showToastEvent('Add Towed unit', 'Please add the towed unit; otherwise, make the towing unchecked.', 'error');
            }
            console.log('END ADD NEW Towed');
        }
    }

    handleUpdateTowed = () => {
        let status = this.isInputValid('.quoteValidate');
        if (!status) {
            return true;
        }

        if(this.actionType == 'editRenew'){
            this.enableNewTowed =true;
        }

        this.isRequiredTowed = false;
        this.addedTowed = JSON.parse(JSON.stringify(this.addedTowed));
        console.log('this.addedTowed-->'+JSON.parse(JSON.stringify(this.addedTowed)));
        if (this.addedTowed && this.addedTowed.length > 0) {
            const firstTowed = this.addedTowed[0];
            if (firstTowed.Days_in_Tow__c != this.newTowed.Days_in_Tow__c) {
                this.isDaysInTowInvalid = true;
                return;
            }
        }
        
        this.isDaysInTowInvalid = false;

        for (let each of this.addedTowed) {
            if (each.towedCount == this.newTowed.towedCount) {
                each.Days_in_Tow__c = this.newTowed.Days_in_Tow__c;
                each.Towed_Unit_Type__c = this.newTowed.Towed_Unit_Type__c;
                each.Towed_Unit_Value__c = this.newTowed.Towed_Unit_Value__c;
                each.Year__c = this.newTowed.Year__c;
                each.Make__c = this.newTowed.Make__c;
                each.Model__c = this.newTowed.Model__c;
                each.VIN_Number__c = this.newTowed.VIN_Number__c;
                each.Plate__c = this.newTowed.Plate__c;
                each.towedCount = this.newTowed.towedCount;
                each.selectedStyle = '';
                each.isDeleteTowedButton = true
            }
        }
        this.newTowed = {};
        this.openEditTowed = false;

        // Create a seprate method and pass the class to reset
        this.template.querySelectorAll('.cTowed').forEach(inputField => {
            inputField.value = null;
        });

        const updateTowedEvent = new CustomEvent('updatetowed',{
            detail : this.addedTowed
        });
        this.dispatchEvent(updateTowedEvent);
    }

}