import { api, LightningElement } from 'lwc';
import checkalreadyExistUserAction from '@salesforce/apex/Mex_NewLeadProcess.checkalreadyExistUserAction';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import userdetails from '@salesforce/label/c.TR_User_Detail';
import enteryourname from '@salesforce/label/c.TR_Kindly_enter_your_name_and_email_below_so_we_can_securely_store_the_quote_for';
import knowyouremail from '@salesforce/label/c.TR_We_know_your_email_is_sacred_and_we_ll_never_share_or_sell_any_of_your_detail';
import next from '@salesforce/label/c.TR_Next';
import firstname from '@salesforce/label/c.TR_First_Name';
import lastname from '@salesforce/label/c.TR_Last_Name';
import email from '@salesforce/label/c.TR_Email';
import phone from '@salesforce/label/c.TR_Phone';
import notavaild from '@salesforce/label/c.TR_Not_a_valid_phone_number';
import youraccountisalready from '@salesforce/label/c.TR_Your_account_already_exist_s_0_to_login';
import youraccountisalreadybut from '@salesforce/label/c.TR_Your_account_already_exist_s_but_is_inactive_0_to_activate_your_account';
import Clickhere from '@salesforce/label/c.TR_Click_here';

export default class UserDetails extends LightningElement {
     label = {
        userdetails,enteryourname,knowyouremail,next,firstname,lastname,email,Clickhere,phone,notavaild,youraccountisalready,youraccountisalreadybut
    };
    @api screenname;
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api policyType;
    @api isTowing;
    @api issecondtimeload = false;
    returnLeadValue = {};

    async connectedCallback() {
        const params = new URLSearchParams(window.location.search);
        let leadId = params.get('id');
        let leadEmail = params.get('email');
        let firstName = params.get('firstname');
        let lastName = params.get('lastname');
        let phone = params.get('phone');

        if(firstName != null && lastName != null && leadEmail != null){
            this.leaddata = { ...this.leaddata, ['FirstName']: firstName, ['LastName']: lastName , ['Phone']: phone, ['Email']: leadEmail};
            console.log('this.leaddata-->',this.leaddata);
            //this.handleNextClick();
        }
        // if(leadId){
        this.CampaignFields(params);
        // }

        if (leadId != null || leadEmail != null) {
            let resp = await checkalreadyExistUserAction({ 'leadDataItem': JSON.stringify({ 'Id': leadId != null ? leadId : '', 'email': leadEmail != null ? leadEmail : '' }) });
            if (resp.status == 'Success' && !resp.isExistUser) {
                let towData = await fetchDataFromLead({ 'LeadId': resp?.LeadInfo?.Id, 'screenName': 'Is_towing__c' });
                if (towData.status == 'success') {
                    this.proceedAStep(resp, towData.data[0].Is_towing__c);
                }
            }

        }

    }

    CampaignFields = async (params) => {
        // const params = new URLSearchParams(window.location.search);

        this.leaddata = {
            ...this.leaddata,
            ['pi_utm_id__c']: params.get('utm_id'),
            ['pi__utm_source__c']: params.get('utm_source'),
            ['pi__utm_medium__c']: params.get('utm_medium'),
            ['pi__utm_campaign__c']: params.get('utm_campaign'),
            ['pi__utm_term__c']: params.get('utm_term'),
            ['pi__utm_content__c']: params.get('utm_content'),
            ['GCLID__c']: params.get('gclid'),
        };


        const leadChange = new CustomEvent('leadvaluechange', {
            detail: { ...this.leaddata, ['Source__c']: 'Portal' },
        });
        this.dispatchEvent(leadChange);

    }


    proceedAStep(resp, Is_towing__c) {
        this.leaddata = { ...this.leaddata, ['Id']: resp.LeadInfo.Id, ['quoteId']: resp?.QuoteInfo?.Id };
        this.leaddata = { ...this.leaddata, ['Policy_Type__c']: resp.LeadInfo.Insurance_Type__c, ['policyType']: resp.LeadInfo.Insurance_Type__c };
        this.leaddata = { ...this.leaddata, ['Is_Towing__c']: Is_towing__c };
        this.leaddata = { ...this.leaddata, ['FirstName']: resp.LeadInfo.FirstName, ['LastName']: resp.LeadInfo.LastName, ['Email']: resp.LeadInfo.Email };
        const leadChange = new CustomEvent('leadvaluechange', {
            detail: this.leaddata,
        });
        this.dispatchEvent(leadChange);
        this.isTowing = Is_towing__c;
        console.log('running user detail '+this.issecondtimeload);
        if(this.issecondtimeload == false){
            window.localStorage.setItem('continueNext', 'true');
            console.log('setting controller value to true');
        }else{
            console.log('setting controller value to false');
        }
        this.changesnextscreen();
    }


    handleChange(event) {
        if (event.target.value == '') {
        }
        let name = event.target.name;
        let value = event.target.value.trim();
        if (/^\s/.test(value)) {
            value = '';
        }
        if (name == 'Phone' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            value = phonevalues;
        }
        this.leaddata = { ...this.leaddata, [name]: value };
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
        return isValid;
    }

    handleNextClick = async () => {

        let emailregx = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        let allValid = this.isInputValid();
        if (allValid) {
            this.template.querySelector('.buttonNext').setAttribute('disabled', true);
            this.template.querySelector('.buttonNext').classList.add('loading');
            this.leaddata = { ...this.leaddata, ['Policy_Type__c']: this.policyType == 'AutomobileTowed' ? 'Automobile' : this.policyType }
            console.log('This handle next :::: ', JSON.stringify(this.leaddata, null, 4));
            await checkalreadyExistUserAction({ 'leadDataItem': JSON.stringify(this.leaddata) }).then(result => {
                this.returnLeadValue = result;
                console.log('Lead value', this.returnLeadValue);

                if (this.returnLeadValue.status == "Success" && !this.returnLeadValue.isExistUser) {
                    let eventExist = window.dataLayer.find((data) => data.step_number === 'step_2');
                    if (eventExist == undefined){
                        window.dataLayer.push({
                            'event': 'funnel_step',
                            'step_number': 'step_2',
                            'step_name': 'user_details', 
                            'email_id': this.leaddata.Email,
                            'insurance_category': this.leaddata.Policy_Type__c
                            });
                    }

                    if (!this.returnLeadValue.isExistUser) {
                        this.leaddata = { ...this.leaddata, ['Id']: this.returnLeadValue?.LeadInfo?.Id, ['quoteId']: this.returnLeadValue?.QuoteInfo?.Id }
                        //InsertLeadData({ 'leadData': JSON.stringify({ ['Is_Towing__c']: this.towedoption ? this.towedoption : false }) });
                        InsertLeadData({ 'leadData': JSON.stringify({... this.leaddata, ['Is_Towing__c']: this.towedoption ? this.towedoption : false }) });
                        
                        console.log('Lead', this.leaddata)
                        const leadChange = new CustomEvent('leadvaluechange', {
                            detail: this.leaddata,
                        });
                        this.dispatchEvent(leadChange);
                        this.changesnextscreen();
                    } else {
                        console.log('in the else')
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                        //error...
                    }
                } else {
                    let evt;
                    if (this.returnLeadValue.status == 'Success' && this.returnLeadValue.isExistUser && this.returnLeadValue.userData.IsActive) {
                        evt = new ShowToastEvent({
                            message: this.label.youraccountisalready,
                            messageData: [
                                {
                                    url: window.location.origin + '/s/login',
                                    label: this.label.Clickhere
                                }
                            ],
                        });
                    } else if (this.returnLeadValue.status == 'Success' && this.returnLeadValue.isExistUser && !this.returnLeadValue.userData.IsActive) {
                        evt = new ShowToastEvent({
                            message: this.label.youraccountisalreadybut,
                            messageData: [
                                {
                                    url: window.location.origin + '/s/activateaccount',
                                    label: this.label.Clickhere
                                }
                            ],
                        });
                        
                    }
                    this.dispatchEvent(evt);
                    this.template.querySelector('.buttonNext').classList.remove('loading');
                    this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                }
            }).catch(err => {
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            })
        }
    }

    setDataLayer() {
        window.dataLayer.push({
            event: "user_details_submit",
        });
    }


}