import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import preViewPdfAction from '@salesforce/apex/Mex_PolicyEditController.preViewPdfAction';
import getEditPolicyDetail from '@salesforce/apex/Mex_PolicyEditController.getEditPolicyDetail';
import Displaypolicy from '@salesforce/label/c.TR_Display_Policy';
import RenewPolicy from '@salesforce/label/c.TR_Renew_Policy';
import Edit from '@salesforce/label/c.TR_Edit';
import Terminate from '@salesforce/label/c.TR_Terminate';
import Oursystemfoundsome from '@salesforce/label/c.TR_Our_system_found_some_problem_Kindly_try_again_later_Sorry_for_the_inconv';
import generateGreenCardfromPolicyId from '@salesforce/apex/PolicyDocumentGenerator.generateGreenCardfromPolicyId';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';

export default class Buhodb_policyCustomButtonComponent extends NavigationMixin(LightningElement) {
    label = {
        Displaypolicy, RenewPolicy, Edit, Terminate, Oursystemfoundsome,
    };

    @api PageName;
    @api recordId;

    // ── Summary data passed from parent ──
    @api policyNumber;
    @api vehicleLabel;
    @api policyType;
    @api dateRange;
    @api totalPremium;
    @api packageName;
    @api termName;

    policyExpiredOrTerminated;
    homeownersPolicy = false;
    renewPolicyDisabled = false;
    spinner = false;
    @track isDisableYellowCard = false;
    isHiddenRenewButton = false;

    // ── Icon URL ──
    get carIconUrl() {
        return `${buhoAssets}/images/caricon.svg`;
    }

    // ── Summary display helpers ──
    get hasSummary() {
        return !!this.policyNumber;
    }

    get summaryMetaLine() {
        const parts = [this.vehicleLabel, this.policyType].filter(Boolean);
        return parts.join(' • ');
    }

    get isDisabled() {
        return this.policyExpiredOrTerminated == 'Expired' || this.policyExpiredOrTerminated == 'Terminated' || this.policyExpiredOrTerminated == 'Updated' || this.policyExpiredOrTerminated == 'Fully Earned';
    }

    get isRenewBtnDisabled() {
        return this.renewPolicyDisabled;
    }

    get isHomeownersPolicy() {
        return this.homeownersPolicy;
    }

    async connectedCallback() {
        if (this.recordId != null) {
            await this.fetchPolicyData();
        }
    }

    fetchPolicyData = async () => {
        try {
            this.spinner = true;
            const systemTime = await getTimeZone();
            
            const { status, ...rest } = await getEditPolicyDetail({ 'policyId': this.recordId });

            if (rest && rest?.policyData && rest.policyData?.Policy_Type_picklist__c && rest.policyData.Policy_Type_picklist__c == 'Northbound') {
                this.isDisableYellowCard = true;
                this.isHiddenRenewButton = true;
            }

            if (rest.policyData.Policy_Type_picklist__c == 'Homeowners') {
                this.homeownersPolicy = true;
                this.spinner = false;
                return;
            }

            if (status == 'success') {
                this.policyExpiredOrTerminated = rest.policyData.Status_picklist__c;
                this.spinner = false;
                const timeNow = new Date();
                if ((parseInt(new Date(rest.policyData?.Issued_At__c).getFullYear()) <= 2019) || (rest?.policyData?.Status_picklist__c == 'Updated' || rest?.policyData?.Status_picklist__c == 'Terminated' || new Date(rest?.policyData.Start_Date__c) > timeNow)) {
                    this.renewPolicyDisabled = true;
                }
                const hhours = Math.floor(rest.quoteData.Start_Time__c / 3600000);
                const mminutes = Math.floor((rest.quoteData.Start_Time__c % 3600000) / 60000);
                const sseconds = Math.floor(((rest.quoteData.Start_Time__c % 3600000) % 60000) / 1000);
                const Firstdate = new Date(rest.quoteData.Start_Date_for_Coverage__c);
                
                const Customdate = new Date(Firstdate.getFullYear(), Firstdate.getMonth(), Firstdate.getDate(), hhours, mminutes, sseconds);

                if (rest.quoteData.Term__c == 'Daily') {    
                    let startDatetime = this.calculateDateTime(rest.quoteData.Start_Date_for_Coverage__c, rest.quoteData.Start_Time__c);
                    let endDatetime = this.calculateDateTime(rest.quoteData.End_Date_for_Coverage__c, rest.quoteData.End_Time__c);

                    if (timeNow > endDatetime) {
                        this.policyExpiredOrTerminated = 'Fully Earned';
                    }
                }
            } else {
                this.spinner = false;
                if (status == 'error') {
                    let evt = new ShowToastEvent({
                        message: this.label.Oursystemfoundsome,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    return;
                }
            }
        } catch (error) {
            console.log(error);
            this.spinner = false;
            if (error.status === 500 && error.statusText === 'Server Error') {
                let errEvt = new ShowToastEvent({
                    message: this.label.Oursystemfoundsome,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                return;
            }
        }
    }

    calculateDateTime(customdate, customtime) {
        const hhours = Math.floor(customtime / 3600000);
        const mminutes = Math.floor((customtime % 3600000) / 60000);
        const sseconds = Math.floor(((customtime % 3600000) % 60000) / 1000);
        const Firstdate = new Date(customdate);
        const Finaldate = new Date(Firstdate.getFullYear(), Firstdate.getMonth(), Firstdate.getDate(), hhours, mminutes, sseconds);
        return Finaldate;
    }

    navigateToLightningComponent() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: this.PageName,
                recordId: this.recordId
            }
        });
    }

    handleEditClick = () => {
        sessionStorage.setItem('recordId', this.recordId);
        // Navigate inline within the dashboard instead of a full page redirect
        this.dispatchEvent(
            new CustomEvent('hashupdate', {
                detail: { hash: 'editpolicy' },
                bubbles: true,
                composed: true
            })
        );
    }

    handleRenewClick = () => {
        sessionStorage.setItem('recordId', this.recordId);
        window.location.href = '/renew/';
    }

    handleTerminateClick = () => {
        sessionStorage.setItem('recordId', this.recordId);
        window.location.href = '/terminate';
    }

    async handleDisplayClick() {
        let actionData = await preViewPdfAction({ 'policyId': this.recordId });
        if (actionData != null) {
            window.open('/customer' + actionData, "_blank");
        }
    }

    generatePolicyPDF(event) {
        validateandGenerateQuotePDF({ 'policyId': this.recordId })
            .then((result) => {
                if (result) {
                    window.open(('/apex/' + result + '?id=' + this.recordId), '_blank');
                } else {
                    let errEvt = new ShowToastEvent({
                        message: 'Cannot generate PDF for the current policy.',
                        title: 'Something wrong happened while generating PDF!',
                        variant: 'error',
                    });
                    this.dispatchEvent(errEvt);
                }
            })
            .catch((error) => {
                console.log('Some error occured');
                console.log(error);
            });
    }

    generatePolicyGreenCard(event) {
        generateGreenCardfromPolicyId({ 'policyId': this.recordId })
            .then((result) => {
                if (result) {
                    window.open(('/apex/renderAsPdf?id=' + this.recordId), '_blank');
                } else {
                    let errEvt = new ShowToastEvent({
                        message: 'Cannot generate Yellow Card for the current policy',
                        title: 'This policy doesn\'t support Yellow Card',
                        variant: 'error',
                    });
                    this.dispatchEvent(errEvt);
                }
            })
            .catch((error) => {
                console.log('Some error occured');
                console.log(error);
            });
    }
}
