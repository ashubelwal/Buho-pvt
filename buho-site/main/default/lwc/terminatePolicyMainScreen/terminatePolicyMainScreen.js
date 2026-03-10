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

export default class TerminatePolicyMainScreen extends NavigationMixin(LightningElement) {
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
    debug = false
    get refundDisplayAmount() {
        return this.refundAmount != null && this.refundAmount != undefined ? Math.abs(this.refundAmount) : '';
    }

    @api isshowaddress;


    async connectedCallback() {
        this.spinner = true;
        this.isRefund = true;
        const params = new URLSearchParams(window.location.search);

        if (params.get('c__id') === null) {
            const recordId = sessionStorage.getItem('recordId');
            if(this.debug) console.log('Session Storage', sessionStorage.getItem('recordId'));
            this.recordId = recordId;
        }
        else {
            const commrecordId = params.get('c__id');
            this.recordId = commrecordId;
        }
        if(this.debug) console.log('Test Record Id in connected callback after session storage', this.recordId);
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

    renderedCallback() {
        let actionType = sessionStorage.getItem('actionType');
        if (!this.isComponentRendered && actionType == null) {
            Promise.all([
                loadStyle(this, StyleCSS + '/style.css')
            ]).then(() => {
                if(this.debug) console.log("Files loaded");
                this.isComponentRendered = true;
            }).catch(error => {
                if(this.debug) console.log('css error', error.body.message);
                this.isComponentRendered = false;
            });
        }
    }

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
            if (this.refundAmount > 0 || this.refundWatercraft > 0) {
                this.screenname = 'PaymentDetail';                
            } else {
                this.terminatePolicy();
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
            if(this.debug) console.log('rest : ', rest);
            if (status == 'success') {
                this.policyDetail = { ...rest };
                this.policyType = rest.policyData.Policy_Type_picklist__c;
                this.terminatePolicyName = rest.policyData.Name;
            }
            if(this.debug) console.log('policyDetail : ', this.policyDetail);
        } catch (error) {
            if(this.debug) console.log('error msg : ', error);
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
            if(this.debug) console.log('Policy Id', this.recordId);
            const refundData = await refundCalculation({ 'policyId': this.recordId });
            if(this.debug) console.log('--refundData--- : ', refundData);

                this.refundObj = refundData.Data;
            this.refundObj.totalBrokerageFee = Number(refundData.Data.AgentBrokerageFee) + Number(refundData.Data.BrokerPolicyFee);
                if(this.debug) console.log('Refund return object', this.refundObj);
            if(this.debug) console.log('---this.policyType --', this.policyType);

            if (this.policyDetail.policyData.Term__c == 'Daily') {
                if (refundData.success) {
                    if (this.refundObj.PolicyNotStartedYet == "false" || this.refundObj.PolicyNotStartedYet == false) {
                        this.refundAmount = ((this.policyDetail.policyData.Total_Premium_Amount__c - Number(this.refundObj.Total)) - this.refundObj.totalBrokerageFee).toFixed(2);
                        this.usedPolicyPrimium = Number(this.refundObj.Total).toFixed(2);
                    } else {
                        this.refundAmount = (this.policyDetail.policyData.Total_Premium_Amount__c - this.refundObj.totalBrokerageFee).toFixed(2);
                        this.usedPolicyPrimium = 0;
                    }
                } else {
                    // The daily policy has started No refund...
                    this.refundAmount = 0.00;
                    this.usedPolicyPrimium = this.policyDetail?.policyData.Total_Premium_Amount__c.toFixed(2);
                }
            } else {
                let fullyEarned = 0;
                if (this.policyDetail.policyData.Underwriter_picklist__c === "Chubb") {
                    fullyEarned = 23;
                } else if (this.policyDetail.policyData.Underwriter_picklist__c === 'Mapfre') {
                    fullyEarned = 25;
                } else if (this.policyDetail.policyData.Underwriter_picklist__c === 'Qualitas') {
                    fullyEarned = 34;
                }

                if (parseInt(this.refundObj.DaysUsed) <= fullyEarned) {
                    if (this.refundObj.PolicyNotStartedYet == "false" || this.refundObj.PolicyNotStartedYet == false) {
                        //this.refundAmount = this.refundObj.brokerFee.toFixed(2) - this.refundObj.oldPremium.toFixed(2);
                        this.refundAmount = ((this.policyDetail.policyData.Total_Premium_Amount__c - Number(this.refundObj.Total)) - this.refundObj.totalBrokerageFee).toFixed(2);
                        this.usedPolicyPrimium = Number(this.refundObj.Total).toFixed(2);
                    } else {
                        this.refundAmount = (this.policyDetail.policyData.Total_Premium_Amount__c - this.refundObj.totalBrokerageFee).toFixed(2);
                        this.usedPolicyPrimium = 0;
                        // let totalDeductAmount = (this.refundObj?.Total ? parseFloat(this.refundObj?.Total.toFixed(2)) : 0) +
                        // (this.refundObj.brokerFee ? parseFloat(this.refundObj.brokerFee.toFixed(2)) : 0);
                        // if(this.debug) console.log('calculating sum ' + totalDeductAmount);
                        // let totalPremiumAmount = this.policyDetail.policyData ? this.policyDetail.policyData.Total_Premium_Amount__c : 0;
                        // this.refundAmount = (totalDeductAmount - totalPremiumAmount).toFixed(2);
                    }

                    // this.usedPolicyPrimium = (this.refundObj.premium ? this.refundObj.premium.toFixed(2) : 0);
                    // this.refundAmount = parseFloat(this.refundAmount);
                    if(this.debug) console.log('---refundAmount---', this.refundAmount);
                } else if (parseInt(this.refundObj.DaysUsed) > fullyEarned) {
                    this.refundAmount = 0.00;
                    this.usedPolicyPrimium = this.policyDetail?.policyData.Total_Premium_Amount__c.toFixed(2);
                    if(this.debug) console.log('---refundAmount--- Else If ', this.refundAmount);
                }
            }

            // if (refundData.success) {
            //     this.refundObj = refundData.Data;
            //     if(this.debug) console.log('Refund return object', this.refundObj);
            //     if (this.policyType == 'Watercraft' && this.refundObj.daysUsed <= 20) {
            //         let calculateToRefund = this.refundObj.premium * this.refundObj.daysUsed;
            //         this.refundWatercraft = (calculateToRefund - this.policyDetail.policyData.Net_Premium__c).toFixed(2);
            //         this.usedPolicyPrimium = calculateToRefund.toFixed(2);

            //         // this.usedPolicyPrimium = parseInt(this.usedPolicyPrimium);
            //         if(this.debug) console.log('--usedPolicyPrimium--', this.usedPolicyPrimium);
            //         this.refundWatercraft = parseFloat(this.refundWatercraft);
            //         if(this.debug) console.log('--refundWatercraft--', this.refundWatercraft);
            //     } else if (this.policyType == 'Watercraft' && this.refundObj.daysUsed > 20) {
            //         this.refundWatercraft = 0.00;
            //         this.usedPolicyPrimium = this.refundObj.oldPremium;
            //     }
            //     if(this.debug) console.log('---this.policyType --', this.policyType);
            //     if (this.policyType != 'Watercraft' && this.refundObj.daysUsed <= 34) {
            //         if (this.refundObj.policyNotStartedYet == false) {
            //             if(this.debug) console.log('This refund amount', this.refundObj);
            //             this.refundAmount = - this.refundObj.oldPremium.toFixed(2);
            //         } else {
            //             if(this.debug) console.log('calculating this.refundObj',this.refundObj);
            //             let totalDeductAmount = (this.refundObj.total ? parseFloat(this.refundObj.total.toFixed(2)) : 0) +
            //                 (this.refundObj.brokerFee ? parseFloat(this.refundObj.brokerFee.toFixed(2)) : 0);
            //             if(this.debug) console.log('calculating sum ' + totalDeductAmount);
            //             let totalPremiumAmount = this.policyDetail.policyData ? this.policyDetail.policyData.Total_Premium_Amount__c : 0;
            //             this.refundAmount = (totalDeductAmount - totalPremiumAmount).toFixed(2);
            //         }

            //         this.usedPolicyPrimium = (this.refundObj.premium ? this.refundObj.premium.toFixed(2) : 0);
            //         this.refundAmount = parseFloat(this.refundAmount);
            //         if(this.debug) console.log('---refundAmount---', this.refundAmount);
            //     } else if (this.policyType != 'Watercraft' && this.refundObj.daysUsed > 34) {
            //         if(this.debug) console.log('In else section');
            //         this.refundAmount = 0.00;
            //         this.usedPolicyPrimium = this.refundObj.oldPremium;
            //         if(this.debug) console.log('---refundAmount--- Else If ', this.refundAmount);
            //     }

                this.refundObj = { ...this.refundObj, 'usedPolicyPrimium': this.usedPolicyPrimium, 'PolicyTotalPremium': this.policyDetail.policyData.Total_Premium_Amount__c.toFixed(2) };
                if(this.debug) console.log('---refundAmount-- LAST Amount-', this.refundAmount);
                this.spinner = false;
            // }
        } catch (error) {
            if(this.debug) console.log('error msg : ', error);
        }

    }
    async terminate() {
        this.isTerminate = true;
    }
    async cancleTerminate() {
        if(this.debug) console.log('terminate cancel clicked', this.cmpSource);
        if (this.cmpSource == 'comm') {
            location.replace('${window.location.origin}/partnercomm');
        }
        else {
            this.isTerminate = false;
        }
    }
    async terminateConfirm() {

        this.changeNextScreen();
        if(this.debug) console.log('--resons--', this.whyterminatePolicy);

        // if (this.isCommunity) {
        //     this.template.querySelector('.buttonNext').classList.add('loading');
        //     this.template.querySelector('.buttonNext').setAttribute('disabled', true);
        // }

        // let isValid = this.isInputValid();
        // if (isValid) {
        //     this.isTerminate = false;
        //     if (this.isCommunity) {
        //         this.template.querySelector('.buttonNext').classList.remove('loading');
        //         this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
        //     }
        // } else {
        //     if (this.isCommunity) {
        //         this.template.querySelector('.buttonNext').classList.remove('loading');
        //         this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
        //     }
        // }
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

    async terminatePolicy() {

        const terminatePolicy = await terminatedPolicy({ 'policyId': this.recordId, 'whyTerminate': this.whyterminatePolicy });
        // 2 Sep Update
        if (this.cmpSource == 'comm' || this.cmpSource == 'customSource') {
            if(this.debug) console.log('--terminatePolicy--', terminatePolicy);
            if (terminatePolicy.status == 'success') {
                let viewurl = `policy/${this.recordId}`;
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',                    
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Policy__c',
                        actionName: 'view'
                    },
                    state: {
                        recordId: this.recordId
                    }
                });
                this.showToastmethod('success', 'Refund Initiated', 'Policy termination completed!');
            }
            else {
                this.showToastmethod('error', terminatePolicy.message, 'Policy termination failed!');
            }
            this.spinner = false;
        }
        else {
            if(this.debug) console.log('--terminatePolicy--', terminatePolicy);
            if (terminatePolicy.status == 'success') {


                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        actionName: 'view',
                        recordId: this.recordId
                    },
                });
                this.spinner = false;
            }
            else {
                // const errEvt = new ShowToastEvent({
                //     message: terminatePolicy.message,
                //     variant: 'error',
                // });
                // this.dispatchEvent(errEvt);
                this.showToastmethod('error', terminatePolicy.message, 'Policy termination failed!');
                this.spinner = false;

            }
        }

    }

    showToastmethod(variant, title, message) {
        this.template.querySelector('c-custom-toast').showToast(variant, title, message);
    }

}