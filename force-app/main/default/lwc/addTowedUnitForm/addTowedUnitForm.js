import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import typeoftowed from '@salesforce/label/c.TR_Type_of_Towed_Unit';
import towedunitvalue from '@salesforce/label/c.TR_Towed_Unit_Value';
import daysintow from '@salesforce/label/c.TR_Days_in_tow';
import year from '@salesforce/label/c.TR_Year';
import make from '@salesforce/label/c.TR_Make';
import model from '@salesforce/label/c.TR_Model';
import vinnumber from '@salesforce/label/c.TR_VIN_Number';
import licenseplate from '@salesforce/label/c.TR_License_Plate';
import cancel from '@salesforce/label/c.TR_Cancel';
import updatedetail from '@salesforce/label/c.TR_Update_Detail';
import add from '@salesforce/label/c.TR_Add';
import enteravalidyear from '@salesforce/label/c.TR_Enter_a_valid_year';
import Yes from '@salesforce/label/c.TR_Yes';
import No from '@salesforce/label/c.TR_No';
import Motorcycle from '@salesforce/label/c.TR_Motorcycle';
import ATV_UTV from '@salesforce/label/c.TR_ATV_UTV';
import Boat from '@salesforce/label/c.TR_Boat';
import Camper from '@salesforce/label/c.TR_Camper';
import Utility_Misc_Trailer from '@salesforce/label/c.TR_Utility_Misc_Trailer';
import Towed_Automobile from '@salesforce/label/c.TR_Towed_Automobile';
import yearcantbegreater from '@salesforce/label/c.TR_Year_can_t_be_greater_than';
import thisvinnumberorlicenseplatenumber from '@salesforce/label/c.TR_This_VIN_number_or_license_plate_number_already_used';
import thisvinnumberorlicenseplatenumberalready from '@salesforce/label/c.TR_This_VIN_number_or_license_plate_number_already_used_fields_are_not_valid';
import fieldsarenotvalid from '@salesforce/label/c.TR_fields_are_not_valid';


export default class AddTowedUnitForm extends LightningElement {
      label = {
      typeoftowed,towedunitvalue,daysintow,year,make,model,vinnumber,licenseplate,cancel,updatedetail,add,enteravalidyear,Yes,No,
      Motorcycle,ATV_UTV,Boat,Camper,Utility_Misc_Trailer,Towed_Automobile,yearcantbegreater,thisvinnumberorlicenseplatenumber,fieldsarenotvalid,thisvinnumberorlicenseplatenumberalready,
    };
    @api daysInTowValue;
    @api towedUnitList;
    @api editTowedData;
    @api isEdit;
    @api step;

    currentDate = new Date();
    currentYear = this.currentDate.getFullYear();
    towedUnitObj = {};
    connectedCallback() {

        console.log('--currentYear--', this.currentYear);
        console.log('towedUnitList connected call back ', this.towedUnitList);
        if (this.editTowedData != undefined && this.editTowedData != '') {
            this.towedUnitObj = this.editTowedData
        }
       // this.TowedVehicleOptions = this.fetchPicklist();
    }

    get towedYear() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.Year__c : '';
    }
    get towedMake() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.Make__c : '';
    }
    get isDisabled() {
        return !this.step;
    }
    get towedModel() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.Model__c : '';
    }
    get towedVinNumber() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.VIN_Number__c : '';
    }

    get towedLicensePlate() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.Plate__c : '';
    }
    get TowedUnitValue() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.Towed_Unit_Value__c : '';
    }

    get DaysTowed() {
        return this.daysInTowValue;
    }
    get TowedUnitType() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.Towed_Unit_Type__c : '';
    }
    get StreetLegal() {
        return this.towedUnitObj != undefined ? this.towedUnitObj.Street_Legal__c : '';
    }


    YesNoOptions = [
        { label: this.label.Yes, value: 'Yes' },
        { label: this.label.No, value: 'No' },
    ];


    TowedVehicleOptions = [
        { label: this.label.Motorcycle, value: 'Motorcycle' },
        { label: this.label.ATV_UTV, value: 'ATV-UTV' },
        { label: this.label.Boat, value: 'Boat' },
        { label: this.label.Camper, value: 'Camper' },
        { label: this.label.Utility_Misc_Trailer, value: 'Utility/Misc Trailer' },
        { label: this.label.Towed_Automobile, value: 'Towed Automobile' },
    ];

    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value.trim();
        if (/^\s/.test(value)) {
            value = '';
        }
        if (name == 'Towed_Unit_Value__c' || name == 'Days_in_Tow__c') {
            // value = value == 'Yes' ? true : false;
            if (/^[0-9]*$/.test(value) && value != '') {
                console.log('insodedfkdsfkds');
                value = parseFloat(value);
                this.towedUnitObj = { ...this.towedUnitObj, [name]: value };
            }

        } else {
            this.towedUnitObj = { ...this.towedUnitObj, [name]: value };
        }
        console.log("onhandle change towed unit name : " + name + ' value : ' + value);

        console.log("towedUnitObj : ", this.towedUnitObj);

    }


    fetchPicklist(objectName, fieldApi) {
        getPicklistValues({ "objectApiName": objectName, "fieldApiName": fieldApi }).then((result) => {

            let getResultValue = [];
            result.map((data)=>{
                getResultValue.push({
                    'label' : data.label,
                    'value': data.label
                })
            })
        });
    }


    isInputValid = () => {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validateField');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    addTowedUnit() {

        let allValid = this.isInputValid();
        let dublicateTowed = false;
        if(!this.step) {
            if (this.towedUnitObj.Year__c > this.currentYear) {
                allValid = false;
                const evt = new ShowToastEvent({
                    message: this.label.yearcantbegreater + this.currentYear,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
            console.log('--towedUnitList---', this.towedUnitList);
            let tempTowedUnitList = this.towedUnitList.filter((data)=>{
                console.log('---data--', data);
                console.log('---this.towedUnitObj.Id--', this.towedUnitObj.Id);
                return data.Id != this.towedUnitObj.Id;
            })
console.log('--tempTowedUnitList---', tempTowedUnitList);
            tempTowedUnitList != undefined ? tempTowedUnitList.map((data) => {
                
                if (data.VIN_Number__c == this.towedUnitObj.VIN_Number__c || data.Plate__c == this.towedUnitObj.Plate__c) {
                    console.log("this VIN number or license plate number used");
                    dublicateTowed = true;
                }
            }) : '';
        }
        if (!dublicateTowed && allValid) {
            const towedUnit = new CustomEvent('towedaddvalue', {
                detail: this.towedUnitObj,
            });
            console.log('addTowedunit---', this.towedUnitList);
            this.dispatchEvent(towedUnit);
        } else {
            if (dublicateTowed && !allValid) {
                const evt = new ShowToastEvent({
                    message: this.label.thisvinnumberorlicenseplatenumberalready,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            } else if (dublicateTowed) {
                const evt = new ShowToastEvent({
                    message: this.label.thisvinnumberorlicenseplatenumber,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    message: this.label.fieldsarenotvalid,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }

        }
    }

    updateTowed() {
        let allvalid = this.isInputValid();
        let dublicateTowed = false;
        if (!this.step && allvalid) {
            if (this.towedUnitObj.Year__c > this.currentYear) {
                allvalid = false;
                const evt = new ShowToastEvent({
                    message: this.label.yearcantbegreater + this.currentYear,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
            console.log('--towedUnitList---', this.towedUnitList);
            let tempTowedUnitList = this.towedUnitList.filter((data)=>{
                console.log('---data--', data);
                console.log('---this.towedUnitObj.Id--', this.towedUnitObj.Id);
                return data.Id != this.towedUnitObj.Id;
            })
console.log('--tempTowedUnitList---', tempTowedUnitList);
            tempTowedUnitList != undefined ? tempTowedUnitList.map((data) => {
                
                if (data.VIN_Number__c == this.towedUnitObj.VIN_Number__c || data.Plate__c == this.towedUnitObj.Plate__c) {
                    console.log("this VIN number or license plate number used");
                    dublicateTowed = true;
                }
            }) : '';
        }
        if (!dublicateTowed && allvalid) {

            const towedUnit = new CustomEvent('towedaddvalue', {
                detail: this.towedUnitObj,
            });
            console.log('addTowedunit---', this.towedUnitList);
            this.dispatchEvent(towedUnit);
        } else {
            if (dublicateTowed && !allvalid) {
                const evt = new ShowToastEvent({
                    message: this.label.thisvinnumberorlicenseplatenumberalready,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            } else if (dublicateTowed) {
                const evt = new ShowToastEvent({
                    message: this.label.thisvinnumberorlicenseplatenumber,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    message: this.label.fieldsarenotvalid,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }

        }
    }

    cancelEditSection() {
        const towedUnit = new CustomEvent('towedaddvalue', {
            detail: 'cancelSection'
        });
        console.log('addTowedunit---', this.towedUnitList);
        this.dispatchEvent(towedUnit);
    }
}