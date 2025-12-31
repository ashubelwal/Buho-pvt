import { api, LightningElement } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import selectatowed from '@salesforce/label/c.TR_Select_a_Towed_from_your_account';
import type from '@salesforce/label/c.TR_Type';
import value from '@salesforce/label/c.TR_Value';
import daysintow from '@salesforce/label/c.TR_Days_in_tow';
import ADDADIFF from '@salesforce/label/c.TR_ADD_A_DIFFERENT_TOWED';
import prev from '@salesforce/label/c.TR_Prev';
import next from '@salesforce/label/c.TR_Next';
import FinalizeTowDetails from '@salesforce/label/c.TR_Finalize_Tow_Details';
import Tellusaboutwhatyouretowing from '@salesforce/label/c.TR_Tell_us_about_what_you_are_towing';
import EditUnit from '@salesforce/label/c.TR_Edit_Unit';
import DeleteUnit from '@salesforce/label/c.TR_Delete_Unit';
import Kindlyprovidetherequireddetails from '@salesforce/label/c.TR_Kindly_provide_the_required_details_for_the_tow_unit_s';
import TowedErrorLabel from '@salesforce/label/c.TowedErrorLabel';
import Kindlyverifyifallthe from '@salesforce/label/c.TR_Kindly_verify_if_all_the_details_are_filled';
import AddatleastoneTowed from '@salesforce/label/c.TR_Add_at_least_one_Towed';

export default class TowedDeatils extends LightningElement {
    label = {
        selectatowed,type,TowedErrorLabel,value,daysintow,ADDADIFF,prev,next,AddatleastoneTowed,Kindlyverifyifallthe,Kindlyprovidetherequireddetails,FinalizeTowDetails,Tellusaboutwhatyouretowing,EditUnit,DeleteUnit,
    };
    @api changesnextscreen
    @api changeprevscreen;
    @api handleInsertData;
    @api leaddata;
    @api policyType;
    @api towedUnitList = [];
    @api editTowedData = {};
    @api isEdit = false;
    @api step;
    @api towedUnitData;
    @api daysInTowValue;

    @api oldpolicydata;
    @api editpolicydata;
    @api customerRecord;
    @api communityUser;
    activeSectionMessage = '';
    newSectionOpen = false;
    editIndex;
    disableEditTowed
    towedForAdditionQuote;

    loginUserTowedOption;
    activeAccordinSection;
    connectedCallback() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.communityUser) {
            this.getAllTowedDetails();
        }
        if (this.editpolicydata != null) {
            this.towedUnitList = [...this.editpolicydata.towedUnitData];
        } else {
            let fetchResp = this.fetchData();
            if (fetchResp == 'success') {
                const params = new URLSearchParams(window.location.search);
                let leadId = params.get('id');
                let leadEmail = params.get('email');

                if ((leadId != null || leadEmail != null) && (!this.communityUser && window.localStorage.getItem('continueNext') == 'true')) {
                    this.handleNextClick(leadId, leadEmail);
                }
            }
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        // this.towedUnitList = this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails : this.towedUnitList;
    }

    get pageHeading() {
        return this.step == '1' ? this.label.Tellusaboutwhatyouretowing: this.label.FinalizeTowDetails;
    }

    get isStep1() {
        return this.step == '1';
    }
    get selectedTowedId() {
        return this.editTowedData?.Id;
    }

    /*
    get Make() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.Make__c : '';
    }
    get Model() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.Model__c : '';
    }
    get VinNumber() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.Vin_Number__c : '';
    }
    get LicensePlate() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.License_Plate__c : '';
    }
    get TowedUnitValue() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.Towed_Unit_Value__c : '';
    }
    get DaysTowed() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.DaysTowed : '';
    }
    get TowedUnitType() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.Towed_Unit_Type__c : '';
    }
    get StreetLegal() {
        return this.leaddata.towedDetails != undefined ? this.leaddata.towedDetails.Street_Legal__c : '';
    }
    */

    fetchData = async () => {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.leaddata?.Id != undefined && !this.communityUser) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Towing__c" });
              
                if (data.status == 'success') {
                    if (data.data[0].Towing__c != undefined) {
                        let parseTowedData = JSON.parse(data.data[0].Towing__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;
                        this.towedUnitList = this.leaddata?.Policy_Type__c == prevPolicyType ? parseTowedData : [];
                        this.daysInTowValue = this.leaddata?.Policy_Type__c == prevPolicyType && parseTowedData.length > 0 && parseTowedData[0].Days_in_Tow__c;

                    }
                    return data.status;
                } else {
                    this.generateLogs();
                    return 'error';
                }
            } catch (ex) {
                this.generateLogs();
                console.log('error : ', ex);
            }
        } else {
            if (this.communityUser !== null && this.communityUser) {
               
                this.towedUnitList = this.customerRecord?.towedUnitData?.length ? [...this.customerRecord?.towedUnitData] : [];
                this.daysInTowValue = this.customerRecord?.towedUnitData?.length && this.customerRecord?.towedUnitData[0].Days_in_Tow__c;
                return 'success';
            }
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }
    getAllTowedDetails = async () => {
        try {

            let loginUserTowed = [{ 'value': '', 'label': '--None--' }];
            if (this.towedUnitData != null) {
                this.towedUnitData.forEach(function (item) {
                   
                    let label = item.Make__c + ' ' + item.Model__c + ' ' + item.Year__c + ' - ' + item.VIN_Number__c + '';
                    loginUserTowed.push({ 'value': item.Id, 'label': label });
                });
                this.loginUserTowedOption = loginUserTowed;
            }
        } catch (ex) {
            this.generateLogs();
            console.log('errod ::: ', ex);
        }
    }
    changeTowedOption = async (event) => {
        let TowedId = event.target.value;
      
        let filterTowedDetail = this.towedUnitData.filter(item => {
       
            return item.Id == TowedId;
        })
        
        this.editTowedData = filterTowedDetail[0];

        // this.handleSectionToggle();
        this.newSectionOpen = true;
        this.activeAccordinSection = 'A';
        this.disableEditTowed = true;
    
    }

    handleNextClick = async (leadId, leadEmail) => {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.towedUnitList.length > 0) {
            let errorField = false;
            if (this.step == '1') {
                this.towedUnitList.map((tow) => {
                    if (!tow.Towed_Unit_Type__c || !tow.Towed_Unit_Value__c || !tow.Days_in_Tow__c) {
                        errorField = true;
                    }
                });
            }

            if (this.step == '2') {
                this.towedUnitList = this.towedUnitList.map((tow) => {
                    if (!tow.Year__c || !tow.Make__c || !tow.Model__c || !tow.VIN_Number__c || !tow.Plate__c) {
                        errorField = true;
                        return { ...tow, updateFields: true };
                    }else {
                        return { ...tow, updateFields: false };
                      }
                });

            }

            if (errorField) {
                const errMsg = new ShowToastEvent({
                    title: this.label.Kindlyprovidetherequireddetails ,
                    message:this.label.TowedErrorLabel,
                    variant: 'error',
                });
                this.dispatchEvent(errMsg);
                return;
            }

            try {

                if (this.editpolicydata != null) {
                    this.editpolicydata = { ...this.editpolicydata, ['towedUnitData']: [...this.towedUnitList] };
                    const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                        detail: this.editpolicydata,
                    });
                    this.dispatchEvent(editPolicyChange);
                    this.changesnextscreen();
                } else {
                    this.template.querySelector('.buttonNext').classList.add('loading');
                    this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                
                    const data = await validateFormData({ "objData": JSON.stringify({ ['Towing__c']: this.towedUnitList }), "objName": 'towDetails' });
                    //  const data = await validateFormData({ "objData": JSON.stringify({['Vehicle_details__c'] : this.vehicleDetail}), "objName": 'vehicleDetails' });

                    if (this.communityUser !== null && this.communityUser) {
                        this.customerRecord = { ...this.customerRecord, ['towedUnitData']: [...this.towedUnitList] }
                      
                        const customerRecordChange = new CustomEvent('customerecordchange', {
                            detail: this.customerRecord,
                        });

                        this.dispatchEvent(customerRecordChange);
                        // this.changesnextscreen();
                    } else {
                     
                        if (data.status == 'success' && this.towedUnitList.length > 0) {
                            const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Towing__c']: JSON.stringify(this.towedUnitList), ['Id']: this.leaddata?.Id }) });
                         
                            if (res.status == 'Success') {
                                
                            } else {
                                this.generateLogs();
                                this.template.querySelector('.buttonNext').classList.remove('loading');
                                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                                return;
                                // error...
                            }

                            // call insert method here...
                        } else {
                            this.generateLogs();
                            this.template.querySelector('.buttonNext').classList.remove('loading');
                            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                           
                            const evt = new ShowToastEvent({
                                message: this.label.Kindlyverifyifallthe ,
                                variant: 'error',
                            });
                            this.dispatchEvent(evt);
                            return;
                            // handle error...
                        }
                    }
                    this.changesnextscreen();
                }
            } catch (error) {
                console.log(error);
                this.generateLogs();
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                if (!this.communityUser && (leadId || leadEmail)) {
                    window.localStorage.setItem('continueNext', 'false');
                }
                // handle errors if any...
            }
        } else {
            if (!this.communityUser && (leadId || leadEmail)) {
                window.localStorage.setItem('continueNext', 'false');
            }
            const evt = new ShowToastEvent({
                message: this.label.AddatleastoneTowed,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));

    }

    handlePrevClick() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.editpolicydata != null) {
            this.editpolicydata = { ...this.editpolicydata, ['towedUnitData']: [...this.towedUnitList] };
            const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                detail: this.editpolicydata,
            });
            this.dispatchEvent(editPolicyChange);
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                const customerRecordChange = new CustomEvent('customerecordchange', {
                    detail: this.customerRecord,
                });

                this.dispatchEvent(customerRecordChange);
            }
        }
        this.changeprevscreen();
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }


    handleAddTowed(e) {
       
        if (e.detail != 'cancelSection') {
            if (this.isEdit != true) {
                this.towedUnitList.push(e.detail);
            } else {
                this.towedUnitList[this.editIndex] = e.detail;
            }

            this.daysInTowValue = e.detail.Days_in_Tow__c;
            if (this.towedUnitList.length > 1) {
                this.towedUnitList.map((tow) => tow.Days_in_Tow__c = e.detail.Days_in_Tow__c)
            }
        }


        
        this.newSectionOpen = false;
        this.isEdit = false;
        this.disableEditTowed = false;

    }


    handleSectionToggle(event) {
        this.newSectionOpen = !this.newSectionOpen;
        this.editTowedData = {};
        this.isEdit = false;
        this.disableEditTowed = !this.disableEditTowed;

    }
    editTowedUnit(event) {

       
        let index = event.target.dataset.index ? event.target.dataset.index : event.currentTarget.dataset.index;
     
        this.editTowedData = this.towedUnitList[index];
        this.editIndex = index;
        
        this.isEdit = true;
        this.disableEditTowed = true;
        this.newSectionOpen = true;
    }
    deleteTowedUnit(event) {
       
        let index = event.target.dataset.index;
        
        this.towedUnitList.splice(index, 1);
        this.towedUnitList = this.towedUnitList;
    }

    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}