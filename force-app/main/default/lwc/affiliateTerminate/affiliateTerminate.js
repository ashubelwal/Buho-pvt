import { api, LightningElement, wire, track } from 'lwc';
import getEditPolicyDetail from '@salesforce/apex/Mex_PolicyEditController.getEditPolicyDetail';
import refundCalculation from '@salesforce/apex/PoilcyEditController.refundCalculation';
import terminatedPolicy from '@salesforce/apex/PoilcyEditController.terminatedPolicy';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import StyleCSS from '@salesforce/resourceUrl/mexinsurance_assets';
import PolicyType from '@salesforce/label/c.TR_Policy_Type';
import LetstacklethePaymentnow from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';
import ConfirmTerminate from '@salesforce/label/c.TR_Confirm_Terminate';
import Cancel from '@salesforce/label/c.TR_Cancel';
import TOTALREFUND from '@salesforce/label/c.TR_TOTAL_REFUND';
import Whyareyouterminating from '@salesforce/label/c.TR_Why_are_you_terminating';
import Terminate from '@salesforce/label/c.TR_Terminate';
import Note from '@salesforce/label/c.TR_Note';
import Reasonforterminating from '@salesforce/label/c.TR_Reason_for_terminating';
import Brokerfee from '@salesforce/label/c.TR_Broker_Fee';
import Surcharge from '@salesforce/label/c.TR_Surcharge';
import IVATax from '@salesforce/label/c.TR_IVA_Tax';
import PolicyUsedPremium from '@salesforce/label/c.TR_Policy_Used_Premium';
import PolicyPremiumAmount from '@salesforce/label/c.TR_Policy_Premium_Amount';
import RefundCalculation from '@salesforce/label/c.TR_Refund_Calculation';
import PolicyUsedDays from '@salesforce/label/c.TR_Policy_Used_Days';
import PolicyDays from '@salesforce/label/c.TR_Policy_Days';
import TermType from '@salesforce/label/c.TR_Term_Type';
import EndDate from '@salesforce/label/c.TR_End_Date';
import StartDate from '@salesforce/label/c.TR_Start_Date';
import PolicyInformation from '@salesforce/label/c.TR_Policy_Information';
import LiabilityType from '@salesforce/label/c.TR_Liability_Type';
import Pacakge from '@salesforce/label/c.TR_Pacakge';
import MedicalType from '@salesforce/label/c.TR_Medical_Type';
import Onceconfirmed from '@salesforce/label/c.TR_Once_confirmed_your_policy_will_be_terminated_and_your_refund_will_be_applie';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import fetchPolicyDetails from '@salesforce/apex/AffiliatePolicyEditRenewUtils.fetchPolicyDetails';
import validateSession from '@salesforce/apex/AffiliatePortalController.validateSession'




export default class AffiliateTerminate extends NavigationMixin(LightningElement) {
    label = {
        PolicyType, LetstacklethePaymentnow, MedicalType, ConfirmTerminate, Cancel, TOTALREFUND, Whyareyouterminating, Terminate, Note, Reasonforterminating, Brokerfee,
        Surcharge, IVATax, PolicyUsedPremium, Onceconfirmed, PolicyPremiumAmount, RefundCalculation, PolicyUsedDays, PolicyDays, TermType, EndDate, StartDate, PolicyInformation,
        LiabilityType, Pacakge
    };
    @api cmpSource;
    @api spinner = false;
    @api recordId;
    @api policyDetail;
    @api policyType;
    @api isRefund = false;
    @api refundObj;
    screenname = 'refundDetail'
    @api refundAmount;
    @api refundWatercraft;
    terminatePolicyName;
    isTerminate = false;
    whyterminatePolicy = '';
    isComponentRendered = false;
    usedPolicyPrimium;
    resonForTerminateOptions
    showOtherOption = false;
    policyId;
    actionmode;
    @track affiliateCode;
    @track frame;
    contactId;

    get refundDisplayAmount() {
        return this.refundAmount != null && this.refundAmount != undefined ? Math.abs(this.refundAmount) : '';
    }

    @api isshowaddress;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('Wire')
        if (currentPageReference) {
            let params = currentPageReference.state;
            if (params) {
                this.policyId = params?.policyId;
            }
            console.log('This policy Id in terminate', this.policyId);

            this.affiliateCode = currentPageReference.state.code;
            this.frame = currentPageReference.state.frame;
            console.log('Frame console in terminate', this.frame);
            console.log('Affiliate cide in terminate', this.affiliateCode);
        } else {
            console.log('Params are not there')
        }
    }


    async connectedCallback() {
        this.spinner = true;
        this.isRefund = true;

        console.log('PolicYId in connected callback', this.policyId);
        await fetchPolicyDetails({ policyId: this.policyId })
            .then(async (result) => {
                console.log('getting contact');
                const data = JSON.parse(JSON.stringify(result));
                this.contactId = data?.Contact__c;
                this.recordId = data?.Id;
                console.log('getting contact', data);

            })
            .catch((error) => {
                console.log('Error in getting contact Id', error);
            })

        console.log('Contact Id', this.contactId);
        console.log('Cookie in the agent dashboard', document.cookie);
        const cookies = document.cookie.split('; ').reduce((acc, cookie) => {
            const [key, ...valueParts] = cookie.split('=');
            acc[key] = valueParts.join('=');
            return acc;
        }, {});

        const sessionId = cookies.sessionId;
        console.log('Session Id', sessionId);
        console.log('Contact Id in callback', this.contactId);
        if (sessionId !== undefined) {
            await validateSession({ sessionId: sessionId, contactId: this.contactId })
                .then((result) => {
                    if (result) {
                        console.log('Result in validation 1', result);
                    } else {
                        console.log('Result in validation 2', result);
                        console.log('Invalid session');
                        let currentUrl = window.location.origin;
                        if (this.affiliateCode != undefined && this.frame != undefined) {
                            location.replace(`${currentUrl}/affiliate/user-login?code=${this.affiliateCode}&frame=true`);
                        } else if (this.affiliateCode != undefined & this.frame == undefined) {
                            location.replace(`${currentUrl}/affiliate/user-login?code=${this.affiliateCode}`);
                        } else if (this.affiliateCode == undefined & this.frame != undefined) {
                            location.replace(`${currentUrl}/affiliate/user-login?frame=true`);
                        }
                        else {
                            location.replace(`${currentUrl}/affiliate/user-login`);
                        }

                    }
                })
                .catch((error) => {
                    console.log('Error', error);
                    this.error = 'Failed to load policies. Please try again.';
                })
        } else {
            console.log('Session Id failed');
            this.error = 'Failed to load policies. Please try again.';
            let currentUrl = window.location.origin;
            if (this.affiliateCode != undefined && this.frame != undefined) {
                location.replace(`${currentUrl}/affiliate/user-login?code=${this.affiliateCode}&frame=true`);
            } else if (this.affiliateCode != undefined & this.frame == undefined) {
                location.replace(`${currentUrl}/affiliate/user-login?code=${this.affiliateCode}`);
            } else if (this.affiliateCode == undefined & this.frame != undefined) {
                location.replace(`${currentUrl}/affiliate/user-login?frame=true`);
            }
            else {
                location.replace(`${currentUrl}/affiliate/user-login`);
            }
        }
        console.log('Test Record Id in connected callback after session storage', this.recordId);
        this.resonForTerminateOptions = [
            { 'value': 'Trip Cancelled Illness', 'label': 'Trip Cancelled Illness' },
            { 'value': 'Trip Cancelled Other', 'label': 'Trip Cancelled Other' },
            { 'value': 'Trip Changed', 'label': 'Trip Changed' },
            { 'value': 'Vehicle Breakdown', 'label': 'Vehicle Breakdown' },
            { 'value': 'Technical Error', 'label': 'Technical Error' },
            { 'value': 'Other', 'label': '-Other-' },
        ]
        await this.fetchPolicyData();
        await this.fetchRefundAmount();



    }

    // renderedCallback() {
    //     let actionType = sessionStorage.getItem('actionType');
    //     if (!this.isComponentRendered && actionType == null) {
    //         Promise.all([
    //             loadStyle(this, StyleCSS + '/style.css')
    //         ]).then(() => {
    //             console.log("Files loaded");
    //             this.isComponentRendered = true;
    //         }).catch(error => {
    //             console.log('css error', error.body.message);
    //             this.isComponentRendered = false;
    //         });
    //     }
    // }

    get isRefundDetail() {
        return this.screenname == 'refundDetail';
    }
    get isPaymentDetail() {
        return this.screenname == 'PaymentDetail';
    }

    get isWatercraft() {
        return this.policyType == 'Watercraft';
    }


    get nonWatercraftPolicy() {
        return this.policyType != 'Watercraft'
    }

    get isCommunity() {
        if (this.cmpSource == 'comm') {
            return false;
        }
        else {
            return true;
        }
    }
    changeNextScreen = (val) => {
        if (this.screenname == 'refundDetail') {
            if (this.refundAmount >= 0 || this.refundWatercraft >= 0) {
                console.log('Inside if section on change next screen');
                this.terminatePolicy();
            } else {
                console.log('Inside else section on change next screen');
                this.screenname = 'PaymentDetail';
            }

        } else if (this.screenname == 'PaymentDetail') {
            this.terminatePolicy();
        }
    }

    changePrevScreen = (val) => {
        if (this.screenname == 'PaymentDetail') {
            this.screenname = 'refundDetail';
        }
    }
    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                recordId: this.recordId
            },
        })
    }
    fetchPolicyData = async () => {
        try {
            const { status, ...rest } = await getEditPolicyDetail({ 'policyId': this.recordId });
            console.log('rest : ', rest);
            if (status == 'success') {
                this.policyDetail = { ...rest };
                this.policyType = rest.policyData.Policy_Type_picklist__c;
                this.terminatePolicyName = rest.policyData.Name;
            }
            console.log('policyDetail : ', this.policyDetail);
        } catch (error) {
            console.log('error msg : ', error);
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
        return isValid;
    }

    fetchRefundAmount = async () => {
        try {
            console.log('Policy Id', this.recordId);
            const refundData = await refundCalculation({ 'policyId': this.recordId });
            console.log('--refundData--- : ', refundData);
            if (refundData.success) {
                this.refundObj = refundData.Data;

                if (this.policyType == 'Watercraft' && this.refundObj.daysUsed <= 20) {
                    let calculateToRefund = this.refundObj.premium * this.refundObj.daysUsed;
                    this.refundWatercraft = (calculateToRefund - this.policyDetail.policyData.Net_Premium__c).toFixed(2);
                    this.usedPolicyPrimium = calculateToRefund.toFixed(2);

                    // this.usedPolicyPrimium = parseInt(this.usedPolicyPrimium);
                    console.log('--usedPolicyPrimium--', this.usedPolicyPrimium);
                    this.refundWatercraft = parseFloat(this.refundWatercraft);
                    console.log('--refundWatercraft--', this.refundWatercraft);
                } else if (this.policyType == 'Watercraft' && this.refundObj.daysUsed > 20) {
                    this.refundWatercraft = 0.00;
                    this.usedPolicyPrimium = this.refundObj.oldPremium;
                }
                console.log('---this.policyType --', this.policyType);
                if (this.policyType != 'Watercraft' && this.refundObj.daysUsed <= 34) {
                    if (this.refundObj.policyNotStartedYet == false) {
                        this.refundAmount = - this.refundObj.oldPremium.toFixed(2);
                    } else {
                        console.log('calculating sum');
                        let totalDeductAmount = (this.refundObj.total ? parseFloat(this.refundObj.total.toFixed(2)) : 0) +
                            (this.refundObj.brokerFee ? parseFloat(this.refundObj.brokerFee.toFixed(2)) : 0);
                        console.log('calculating sum ' + totalDeductAmount);
                        let totalPremiumAmount = this.policyDetail.policyData ? this.policyDetail.policyData.Total_Premium_Amount__c : 0;
                        this.refundAmount = (totalDeductAmount - totalPremiumAmount).toFixed(2);
                    }

                    this.usedPolicyPrimium = (this.refundObj.premium ? this.refundObj.premium.toFixed(2) : 0);
                    this.refundAmount = parseFloat(this.refundAmount);
                    console.log('---refundAmount---', this.refundAmount);
                } else if (this.policyType != 'Watercraft' && this.refundObj.daysUsed > 34) {
                    this.refundAmount = 0.00;
                    this.usedPolicyPrimium = this.refundObj.oldPremium;
                    console.log('---refundAmount--- Else If ', this.refundAmount);
                }

                this.refundObj = { ...this.refundObj, 'usedPolicyPrimium': this.usedPolicyPrimium, 'PolicyTotalPremium': this.policyDetail.policyData.Total_Premium_Amount__c.toFixed(2) };
                console.log('---refundAmount-- LAST Amount-', this.refundAmount);
                this.spinner = false;
            }
        } catch (error) {
            console.log('error msg : ', error);
        }

    }
    async terminate() {
        this.isTerminate = true;
    }
    async cancleTerminate() {
        console.log('terminate cancel clicked', this.cmpSource);
        if (this.cmpSource == 'comm') {
            location.replace('https://mexinsurance--partialcpy.sandbox.my.site.com/partnercomm');
        }
        else {
            this.isTerminate = false;
        }
    }
    async terminateConfirm() {

        console.log('--resons--', this.whyterminatePolicy);

        if (this.isCommunity) {
            this.template.querySelector('.buttonNext').classList.add('loading');
            this.template.querySelector('.buttonNext').setAttribute('disabled', true);
        }

        let isValid = this.isInputValid();
        if (isValid) {
            this.isTerminate = false;
            this.changeNextScreen();
            if (this.isCommunity) {
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            }
        } else {
            if (this.isCommunity) {
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            }
        }
    }
    async handlechangeTerminate(event) {

        let value = event.target.value;
        let name = event.target.name;
        if (name == 'combobox_Reason__c') {
            if (value == 'Other') {
                this.whyterminatePolicy = '';
                this.showOtherOption = true;
            } else {
                this.whyterminatePolicy = value;
                this.showOtherOption = false;
            }
        } else {
            this.whyterminatePolicy = value;
        }

    }
    
    // Updates for affiliate code
    async terminatePolicy() {

        const terminatePolicy = await terminatedPolicy({ 'policyId': this.recordId, 'whyTerminate': this.whyterminatePolicy });
        // 2 Sep Update
        if (this.cmpSource == 'comm') {
            console.log('--terminatePolicy--', terminatePolicy);
            if (terminatePolicy.status == 'success') {

                this.showToastmethod('success', 'Refund Initiated', 'Policy termination completed!');
                let currentUrl = window.location.origin;
                if (this.affiliateCode != undefined && this.frame != undefined) {
                    location.replace(`${currentUrl}/affiliate/user-login?code=${this.affiliateCode}&frame=true`);
                } else if (this.affiliateCode != undefined & this.frame == undefined) {
                    location.replace(`${currentUrl}/affiliate/user-login?code=${this.affiliateCode}`);
                } else if (this.affiliateCode == undefined & this.frame != undefined) {
                    location.replace(`${currentUrl}/affiliate/user-login?frame=true`);
                }
                else {
                    location.replace(`${currentUrl}/affiliate/user-login`);
                }
            }
            else {
                this.showToastmethod('error', terminatePolicy.message, 'Policy termination failed!');
            }
        }
        else {
            console.log('--terminatePolicy--', terminatePolicy);
            if (terminatePolicy.status == 'success') {


                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        actionName: 'view',
                        recordId: this.recordId
                    },
                });
            }
            else {
                const errEvt = new ShowToastEvent({
                    message: terminatePolicy.message,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                this.spinner = false;

            }
        }

    }

    showToastmethod(variant, title, message) {
        this.template.querySelector('c-custom-toast').showToast(variant, title, message);
    }

}