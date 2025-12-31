import { LightningElement, api } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import getPicklistValues from '@salesforce/apex/Mex_ValidateFormData.getPicklistValues';
import getDependentMap from '@salesforce/apex/Mex_ValidateFormData.getDependentMap';
import getYears from '@salesforce/apex/Mex_NewLeadProcess.getYears';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import pleasefillin from '@salesforce/label/c.TR_Please_fill_in_watercraft_details_below';
import selctawatercraft from '@salesforce/label/c.TR_Please_fill_in_watercraft_details_below';
import addadifferent from '@salesforce/label/c.TR_ADD_A_DIFFERENT_WATERCRAFT';
import typeofvessel from '@salesforce/label/c.TR_Type_of_Vessel';
import vessellength from '@salesforce/label/c.TR_Vessel_Length';
import year from '@salesforce/label/c.TR_Year';
import make from '@salesforce/label/c.TR_Make';
import model from '@salesforce/label/c.TR_Model';
import vehiclevalue from '@salesforce/label/c.TR_Vehicle_Value';
import captainsdob from '@salesforce/label/c.TR_Captain_s_Date_of_Birth';
import willanyoneoperate from '@salesforce/label/c.TR_Will_anyone_operate_the_boat_under_the_age_of_22';
import istheowner from '@salesforce/label/c.TR_Is_the_owner_living_in_Mexico';
import pleaseattest from '@salesforce/label/c.TR_Please_attest_to_the_following_statements_by_checking_the_box_to_proceed';
import coverageisnot from '@salesforce/label/c.TR_Coverage_is_not_available_for_the_risks_below';
import thiscraftis from '@salesforce/label/c.TR_This_craft_is_not_a_commercial_vessel';
import thisvesselis from '@salesforce/label/c.TR_This_vessel_is_not_over_40_year_old';
import thisvesselisnot from '@salesforce/label/c.TR_This_vessel_is_not_competing_or_participating_in_race_events';
import thisvesselisnotfor from '@salesforce/label/c.TR_This_vessel_is_not_for_hire';
import prev from '@salesforce/label/c.TR_Prev';
import next from '@salesforce/label/c.TR_Next';
import Vehicledetails from '@salesforce/label/c.TR_Vehicle_Details';
import SelectaWatercraftfroyouraccount from '@salesforce/label/c.TR_Select_a_Watercraft_from_your_account';
import isthemaximum from '@salesforce/label/c.TR_Is_the_Maximum_Speed_more_than_50_mph';
import yes from '@salesforce/label/c.TR_Yes';
import no from '@salesforce/label/c.TR_No';


export default class WatercraftDetails extends LightningElement {
     label = {
        pleasefillin,selctawatercraft,addadifferent,yes,no,typeofvessel,vessellength,year,make,model,vehiclevalue,captainsdob,willanyoneoperate,istheowner,pleaseattest,coverageisnot,thiscraftis,thisvesselis,thisvesselisnot,thisvesselisnotfor,prev,next,Vehicledetails,
        SelectaWatercraftfroyouraccount,isthemaximum
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api handleInsertData;
    DOBDay = '';
    DOBMonth = '';
    DOBYear = '';
    DOBY = '';
    months = [];
    days = [];
    years = [];
    watercraftDetails = {};
    vesselTypes;
    vesselLengths;
    yearOption;
    currentDate = new Date();
    currentYear = this.currentDate.getFullYear();
    startFrom = this.currentDate.getFullYear() - 90;
    loginUserWatercraftOption = [];
    activeAccordinSection;
    newSectionOpen = false;


    @api watercraftData;
    @api communityUser;
    @api customerRecord;


   

    get DD() {
        this.days = [];
        for (let i = 1; i <= 31; i++) {
            let dy = i;
            if (i <= 9) {
                dy = '0' + i.toString();
            }
            dy = dy.toString()
            this.days.push({
                'label': dy,
                'value': dy
            });
        }
        return this.days;
    }
    get MM() {
        this.months = [];
        for (let i = 1; i <= 12; i++) {
            let mon = i;
            if (i <= 9) {
                mon = '0' + i.toString();
            }
            mon = mon.toString()
            this.months.push({
                'label': mon,
                'value': mon
            });
        }
        return this.months;
    }
    get YYYY() {
        let years = [];
 
        let startYear = this.startFrom;
        for (startYear; startYear <= this.currentYear-15; startYear++) {
            years.push({
                'label': startYear.toString(),
                'value': startYear.toString()
            });
        }
 
        return years;
    }
    get yesNoOptions() {
        return [
            { label: this.label.yes, value: 'Yes' },
            { label: this.label.no, value: 'No' },
        ];
    }

    async connectedCallback() {
        await this.getAllWatercraftData();
        await this.fetchPicklist('Quote__c', 'Type_of_Vessel__c');
        console.log('---communityUser--', this.communityUser);
        console.log('---watercraftData--', this.watercraftData);
        if (!this.communityUser) {
            await this.fetchData();
            this.newSectionOpen = true;
        }else{
           // console.log('---back customerRecord--'+JSON.stringify(this.customerRecord));
           console.log('---back cuscustomerRecordtomerRecord--'+JSON.stringify(this.customerRecord));
            this.watercraftDetails = this.communityUser && this.customerRecord && this.customerRecord?.watercraftData ;
            console.log('---back customerRecorwatercraftDetailsd--'+JSON.stringify(this.watercraftDetails));
            this.yearValue =  this.watercraftDetails?.Captain_s_Year__c;
            this.monthValue =  this.watercraftDetails?.Captain_s_Month__c;
            this.dayValue =  this.watercraftDetails?.Captain_s_Day__c;
           // console.log('---updates watercraftDetails---', this.watercraftDetails);
        }
        this.activeAccordinSection = 'A';
        if (this.watercraftDetails != undefined && this.watercraftDetails.Type_of_Vessel__c != undefined) {
            await this.getDependentPicklistValues('Quote__c', 'Type_of_Vessel__c', 'Vessel_Length__c');
        }
        await this.getVehicleYears();
        console.log('---log--leadData--', this.leaddata);
        console.log('---watercraftData---', this.watercraftData);
    }
    get vesselType() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Type_of_Vessel__c != undefined ? this.watercraftDetails.Type_of_Vessel__c : '') : '';
    }
    get vesselLength() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Vessel_Length__c != undefined ? this.watercraftDetails.Vessel_Length__c : '') : '';
    }
    get vehicleYear() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Year__c != undefined ? this.watercraftDetails.Year__c : '') : '';
    }
    get setMake() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Make__c != undefined ? this.watercraftDetails.Make__c : '') : '';
    }
    get setModel() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Model__c != undefined ? this.watercraftDetails.Model__c : '') : '';
    }
    get setVehicleValue() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Value__c != undefined ? this.watercraftDetails.Value__c : '') : '';
    }
    get setMaximumSpeedValue() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Is_the_Maximum_Speed_more_than_50_mph__c != undefined ? this.watercraftDetails.Is_the_Maximum_Speed_more_than_50_mph__c : '') : '';
    }
    get setUnderAgeDriver() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Any_Boat_Operator_Under_22__c != undefined ? this.watercraftDetails.Any_Boat_Operator_Under_22__c : '') : '';
    }
    get setMaxcioLivilig() {
        return this.watercraftDetails != undefined ? (this.watercraftDetails.Is_the_owner_living_in_Mexico__c != undefined ? this.watercraftDetails.Is_the_owner_living_in_Mexico__c : '') : '';
    }

    dayValue;
    monthValue;
    yearValue;
    get selectedWatercraftId() {
        return this.watercraftDetails?.Id;
    }
    // get setOlderVessel(){
    //     return this.watercraftDetails != 
    // }
    get isShowVesselLength() {
        return this.watercraftDetails?.Type_of_Vessel__c != 'Personal Watercraft (Jet Ski)';
    }
    getAllWatercraftData = async () => {
        try {
          
            let loginUserWatercraft = [{ 'value': '', 'label': '--None--' }];
            if (this.watercraftData != null) {
                this.watercraftData.forEach(function (item) {
                    console.log('--WatercraftOption item---', item);
                    let label = item.Make__c + ' ' + item.Model__c + ' ' + item.Year__c + ' - ' + (item.Vin__c != undefined ? item.Vin__c : '') + '';
                    loginUserWatercraft.push({ 'value': item.Id, 'label': label });
                });
                this.loginUserWatercraftOption = loginUserWatercraft;
            }
        } catch (ex) {
            console.log('errod ::: ', ex);
        }
    }
    changeWatercraftOption = async (event) => {
        let vehicleId = event.target.value;
        console.log('---vehicleId--', vehicleId);
        let filterWatercraftDetail = this.watercraftData.filter(item => {
            console.log('--item---', item);
            return item.Id == vehicleId;
        })
        console.log('---filterWatercraftDetail---', filterWatercraftDetail);
       
        this.watercraftDetails = filterWatercraftDetail[0];
        this.yearValue =  this.watercraftDetails?.Captain_s_Year__c;
                        this.monthValue =  this.watercraftDetails?.Captain_s_Month__c;
                        this.dayValue =  this.watercraftDetails?.Captain_s_Day__c;
       
        if (this.watercraftDetails != undefined && this.watercraftDetails?.Type_of_Vessel__c != undefined) {
            await this.getDependentPicklistValues('Quote__c', 'Type_of_Vessel__c', 'Vessel_Length__c');
        }
        await this.getVehicleYears();
        // this.handleSectionToggle();
       // this.newSectionOpen = true;
        this.activeAccordinSection = 'A';
        console.log('---vehicleDetail---', this.watercraftDetails);
        console.log('---newSectionOpen--', this.newSectionOpen);
    }
    handleSectionToggle() {
        console.log('enter in handleSectionToggle ', this.activeAccordinSection);
        console.log('enter communityUser ', this.communityUser);
        if (this.communityUser != undefined && this.communityUser) {
            this.newSectionOpen = !this.newSectionOpen;
        }
    }

    isInputValid = () => {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.Validation');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        console.log('checking validations on watercraftDetails --- ');
        return isValid;
    }
    fetchData = async () => {
        if (this.leaddata?.Id != undefined && !this.communityUser) {

            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Watercraft_Detail__c" });
                console.log('-fetch data are : --', data);
                if (data.status == 'success') {
                    if (data.data[0].Watercraft_Detail__c != undefined) {
                        let parseVehicleData = JSON.parse(data.data[0].Watercraft_Detail__c);
                        console.log('---parseVehicleData--', parseVehicleData);
                        let prevPolicyType = data.data[0].Insurance_Type__c;
                        this.watercraftDetails = this.leaddata?.Policy_Type__c == prevPolicyType ? parseVehicleData : {};
                        this.yearValue =  this.watercraftDetails?.Captain_s_Year__c;
                        this.monthValue =  this.watercraftDetails?.Captain_s_Month__c;
                        this.dayValue =  this.watercraftDetails?.Captain_s_Day__c;
                    }

                    this.spinner = false;
                    return data.status
                } else {
                    this.spinner = false;
                    return 'error';
                }

            } catch (ex) {
                this.spinner = false;
                console.log('error : ', ex);
            }
        } else {
            // if (this.vehiclesList.length === 0) {
            //     this.vehiclesList = [...this.vehicleData];
            // }
            

            this.watercraftDetails = this.communityUser && this.customerRecord && this.customerRecord?.watercraftData ;
            this.spinner = false;
            return 'success';

        }
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
            console.log(getResultValue);
            this.vesselTypes = getResultValue;

        });
    }

    async getDependentPicklistValues(objectName, controllingField, dependentField) {
        getDependentMap({ "objectApiName": objectName, "contrfieldApiName": controllingField, "depfieldApiName": dependentField }).then((result) => {
            let vesselType = this.watercraftDetails.Type_of_Vessel__c;
 
            let storeResponse = result;
            let option = [];
 
            if (vesselType != null && storeResponse && storeResponse[vesselType.trim()] != null) {
                console.log('in if condition');
                storeResponse[vesselType].map((data) => {
                    console.log('data in if', data);
                    option.push({
                        'label': data,
                        'value': data
                    })
                });
            }
            // this.vehicleTypeQuoteOptions = option;
            this.vesselLengths = option;
        });
    }



    async getVehicleYears() {

       await getYears().then((result) => {
            this.yearOption = result;
        }).catch(error => {
            console.log('error')
        });
      
        //    return this.yearOption; 
    }


    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value.trim();
        if (name == 'Type_of_Vessel__c') {
            this.getDependentPicklistValues('Quote__c', 'Type_of_Vessel__c', 'Vessel_Length__c');
            this.watercraftDetails = { ...this.watercraftDetails, ['Vessel_Length__c']: '' };
        }
        if (name == 'Type_of_Vessel__c' && value == 'Personal Watercraft (Jet Ski)') {
            this.watercraftDetails = { ...this.watercraftDetails, ['Vessel_Length__c']: '' };
        }

        if (name == 'DOBYear') {
            this.DOBYear = value;
            this.yearValue = value;
            this.watercraftDetails = { ...this.watercraftDetails, ['Captain_s_Year__c']: value };
        }
        if (name == 'DOBMonth') {
            this.DOBMonth = value;
            this.monthValue = value;
  
            this.watercraftDetails = { ...this.watercraftDetails, ['Captain_s_Month__c']: value };
        }
        if (name == 'DOBDay') {
            this.DOBDay = value;
            this.dayValue = value;
 
            this.watercraftDetails = { ...this.watercraftDetails, ['Captain_s_Day__c']: value };
        }
        if (name != 'DOBDay' && name != 'DOBMonth' && name != 'DOBYear') {
            this.watercraftDetails = { ...this.watercraftDetails, [name]: value };
        }


    }





    handleNextClick = async () => {
        let allValid = this.isInputValid();

        if(this.watercraftDetails.Year__c > this.currentYear){
            const evt = new ShowToastEvent({
                message: 'Year cannot be greater than '+this.currentYear,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            allValid = false;
        }
 
        this.DOBY = this.DOBYear + '-' + this.DOBMonth + '-' + this.DOBDay;
        let DOBYearText = this.yearValue;
        let DOBMonthText = this.monthValue;
        let DOBDayText = this.dayValue;
        this.watercraftDetails = { ...this.watercraftDetails, ['Dob__c']: this.DOBY };
        this.watercraftDetails = { ...this.watercraftDetails, ['Captain_s_Day__c']: DOBDayText, ['Captain_s_Month__c']: DOBMonthText, ['Captain_s_Year__c']: DOBYearText };
 
        if (allValid) {
            try {
                this.template.querySelector('.buttonNext').classList.add('loading');
                this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                
                // return;
                const data = await validateFormData({ "objData": JSON.stringify(this.watercraftDetails), "objName": 'watercraftDetails' });
 
                if (this.communityUser && data.status == 'success') {
                    this.customerRecord = { ...this.customerRecord, ['watercraftData']: { ...this.customerRecord?.watercraftData, ...this.watercraftDetails } };
                    console.log('-----customerRecord-----', this.customerRecord);
                    const customerRecordChange = new CustomEvent('customerecordchange', {
                        detail: this.customerRecord,
                    });

                    let eventExist = window.dataLayer.find((data) => data.step_number === 'step_3');
                    if (eventExist == undefined){
                        window.dataLayer.push({
                            'event': 'funnel_step',
                            'step_number': 'step_3',
                            'step_name': 'vehicle_details_1', 
                            'insurance_category': this.watercraftDetails.Policy_Type__c
                            });
                    }

                    this.dispatchEvent(customerRecordChange);
                    this.changesnextscreen();
                } else if (!this.communityUser && data.status == 'success') {
                    const res = await InsertLeadData({
                        'leadData': JSON.stringify({
                            ['Watercraft_Detail__c']: JSON.stringify(this.watercraftDetails),
                            ['Id']: this.leaddata?.Id,
                            ['Policy_Type__c']: this.leaddata?.Policy_Type__c,

                        })
                    });
                    console.log(res);
                    console.log(res.status);
                    if (res.status == 'Success') {
                        console.log('res----', res);

                        let eventExist = window.dataLayer.find((data) => data.step_number === 'step_3');
                        if (eventExist == undefined){
                            window.dataLayer.push({
                                'event': 'funnel_step',
                                'step_number': 'step_3',
                                'step_name': 'vehicle_details_1', 
                                'insurance_category': this.leaddata?.Policy_Type__c
                                });
                        }
                        
                        this.changesnextscreen();
                    } else {
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                        // error...
                    }
                } else {
                    this.generateLogs();
                    this.template.querySelector('.buttonNext').classList.remove('loading');
                    this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    // error...
                }



            } catch (error) {
                console.log(error);
                this.generateLogs();
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                // handle errors if any...
            }
        }
    }

    handlePrevClick() {
        const leadChange = new CustomEvent('leadvaluechange', {
            detail: this.leaddata,
        });

        this.dispatchEvent(leadChange);
        this.changeprevscreen();
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}