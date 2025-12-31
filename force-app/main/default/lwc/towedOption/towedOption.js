import { api, LightningElement } from 'lwc';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import areyoutowing from '@salesforce/label/c.TR_Are_you_towing_anything';
import yes from '@salesforce/label/c.TR_Yes';
import no from '@salesforce/label/c.TR_No';
import prev from '@salesforce/label/c.TR_Prev';
import next from '@salesforce/label/c.TR_Next';
import PleaseSelectAnyOneOption from '@salesforce/label/c.TR_Please_Select_Any_One_Option';

export default class TowedOption extends LightningElement {
     label = {
        areyoutowing,yes,no,prev,next,PleaseSelectAnyOneOption,
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api handleInsertData;
    @api towedoption = false;
    @api customerRecord;
    @api communityUser;
    spinner = false;
    @api oldpolicydata;
    @api editpolicydata;
    policyType;
    _title = 'Error';
    message = this.label.PleaseSelectAnyOneOption ;
    variant = 'error';

    connectedCallback() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        this.spinner = true;
        if (this.editpolicydata != null) {
            this.towedoption = this.editpolicydata.towedUnitData.length > 0 ? true : false;
            this.spinner = false;
        } else {
            let resp = this.fetchData();
            if (!this.communityUser && this.editpolicydata == null) {
                this.towedoption = this.leaddata?.isTowing;

                const params = new URLSearchParams(window.location.search);
                let leadId = params.get('id');
                let leadEmail = params.get('email');

                if ((leadId != null || leadEmail != null) && (!this.communityUser && window.localStorage.getItem('continueNext') == 'true')) {
                    this.handleNextClick(leadId, leadEmail);
                }
            }
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));

    }

    get isTowingYes() {
        return this.towedoption;
    }
    get isTowingNo() {
        return this.towedoption == true ? false : true;
    }
    handleChange(event) {
        this.towedoption = event.target.text == 'Yes' ? true : false;
    }

    fetchData = async () => {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.leaddata?.Id != undefined && !this.communityUser) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Is_Towing__c" });
                console.log("---data fetch--", data);
                if (data.status == 'success') {
                    console.log("---data fetch undefined--", data.data[0].Is_towing__c);
                    if (data.data[0].Is_towing__c != undefined) {
                        let IsTowedData = data.data[0].Is_towing__c;
                        let prevPolicyType = data.data[0].Insurance_Type__c;

                        this.towedoption = this.leaddata?.Policy_Type__c == prevPolicyType ? IsTowedData : '';

                        console.log('OUTPUT towedoption: ', this.towedoption);
                    }
                    this.spinner = false;
                    return data.status;
                } else {
                    this.generateLogs();
                    this.spinner = false;
                    return 'error';
                }

            } catch (ex) {
                this.generateLogs();
                console.log('error : ', ex);
                this.spinner = false;
            }
        } else {
            if (this.communityUser != null && this.communityUser) {
                this.towedoption = this.customerRecord && this.customerRecord?.Is_Towing__c ? this.customerRecord?.Is_Towing__c : false;
            }
            this.spinner = false;
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    handleNextClick = async (leadId, leadEmail) => {
        console.log('this.editpolicydata',this.editpolicydata);
        console.log('this.leaddata',this.leaddata);
        console.log('this.customerRecord',this.customerRecord);
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        try {
            if (this.editpolicydata != null) {
                this.editpolicydata = { ...this.editpolicydata, ['Is_Towing__c']: this.towedoption };
                const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                    detail: this.editpolicydata,
                });
                // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_5');
                //     if (eventExist == undefined){
                //         window.dataLayer.push({
                //             'event': 'funnel_step',
                //             'step_number': 'step_5',
                //             'step_name': 'towing_option', 
                //             'towing_option': this.editpolicydata.Is_Towing__c,
                //             'insurance_category': this.policyType
                //             });
                //     }
                this.dispatchEvent(editPolicyChange);
                this.changesnextscreen(this.towedoption);
            } else {
                this.template.querySelector('.buttonNext').classList.add('loading');
                this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                console.log(JSON.stringify(this.towedoption, null, 4));
                if (this.towedoption != null) {
                    if (!this.communityUser && this.editpolicydata == null) {
                        const data = await InsertLeadData({ 'leadData': JSON.stringify({ ['Is_Towing__c']: this.towedoption, ['Id']: this.leaddata?.Id }) });
                        if (data.status == 'Success') {
                            this.leaddata = { ...this.leaddata, ['Is_Towing__c']: this.towedoption };
                            const leadChange = new CustomEvent('leadvaluechange', {
                                detail: this.leaddata,
                            });
                            let eventExist = window.dataLayer.find((data) => data.step_number === 'step_5');
                            if (eventExist == undefined){
                                window.dataLayer.push({
                                    'event': 'funnel_step',
                                    'step_number': 'step_5',
                                    'step_name': 'towing_option', 
                                    'towing_option': this.leaddata?.Is_Towing__c,
                                    'insurance_category': this.leaddata?.Policy_Type__c
                                    });
                            }
                            this.dispatchEvent(leadChange);
                            console.log("The renderData ", this.leaddata);
                            this.changesnextscreen(this.towedoption);
                        } else {
                            this.generateLogs();
                            this.template.querySelector('.buttonNext').classList.remove('loading');
                            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                            // handle errors if any...
                        }
                    } else {
                        if (this.communityUser != null && this.communityUser) {
                            this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ['Towed_Unit__c']: this.towedoption == true ? 'Yes' : 'No' } };
                            this.customerRecord = { ...this.customerRecord, ['Is_Towing__c']: this.towedoption };
                            const customerRecordChange = new CustomEvent('customerecordchange', {
                                detail: this.customerRecord,
                            });
                            // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_5');
                            // if (eventExist == undefined){
                            //     window.dataLayer.push({
                            //         'event': 'funnel_step',
                            //         'step_number': 'step_5',
                            //         'step_name': 'towing_option', 
                            //         'towing_option': this.customerRecord.Is_Towing__c,
                            //         'insurance_category': this.customerRecord.Policy_Type__c
                            //         });
                            // }
                            this.dispatchEvent(customerRecordChange);
                            this.changesnextscreen();
                        }
                    }
                } else {
                    if (!this.communityUser && (leadId || leadEmail)) {
                        window.localStorage.setItem('continueNext', 'false');
                    }
                    const evt = new ShowToastEvent({
                        title: this._title,
                        message: this.message,
                        variant: this.variant,
                    });
                    this.dispatchEvent(evt);
                }
            }

        } catch (error) {
            console.log(error);
            this.generateLogs();
            this.template.querySelector('.buttonNext').classList.remove('loading');
            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            // handle errors if any...
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    handlePrevClick() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
            const customerRecordChange = new CustomEvent('customerecordchange', {
                detail: this.customerRecord,
            });

            this.dispatchEvent(customerRecordChange);
        } else if (this.editpolicydata != null) {
            this.editpolicydata = { ...this.editpolicydata, ['Is_Towing__c']: this.towedoption }

            const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                detail: this.editpolicydata,
            });
            this.dispatchEvent(editPolicyChange);
        }
        this.changeprevscreen();
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
	
}