import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import buhoAssets from '@salesforce/resourceUrl/BuhoAssets';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import getCurrentSiteDetails from '@salesforce/apex/BuhoLoginController.getCurrentSiteDetails';
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
    @api baseUrl

    currentSiteData;
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

    get finalBaseUrl() {
        console.log(this.baseUrl, 'base url');
        console.log('current site', this.currentSiteData)
        let base = this.baseUrl || '';
        if (!base) {
            const { baseUrl: siteBase, pathPrefix } = this.currentSiteData || {};
            base = siteBase ? (pathPrefix ? siteBase : `${siteBase}/`) : '';
        }

        1 / 0;
        return base;
    }

    @wire(getCurrentSiteDetails)
    wiredSiteDetails({ data, error }) {
        if (data) {
            this.currentSiteData = data;
            this.error = undefined;
            console.log('Site Details:', JSON.stringify(data));
        } else if (error) {
            this.error = error;
            this.currentSiteData = undefined;
            console.error('Error:', error);
        }
    }

    fetchPolicyData = async () => {
        try {
            this.showSpinner(true);
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
                this.showSpinner(false);
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
                this.showSpinner(false);
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
            this.showSpinner(false);
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

    /**
     * Show or hide the global loading overlay.
     */
    showLoading(isLoading) {
        this.dispatchEvent(
            new CustomEvent('loadingstatus', {
                detail: { isLoading },
                bubbles: true,
                composed: true
            })
        );
    }

    /**
     * Navigate inline within the dashboard by updating the URL hash.
     */
    navigateToHash(hash) {
        sessionStorage.setItem('recordId', this.recordId);
        this.showLoading(true);
        this.dispatchEvent(
            new CustomEvent('hashupdate', {
                detail: { hash },
                bubbles: true,
                composed: true
            })
        );
    }

    handleEditClick = () => {
        this.navigateToHash('editpolicy');
    }

    handleRenewClick = () => {
        this.navigateToHash('renewpolicy');
    }

    handleTerminateClick = () => {
        this.navigateToHash('terminatepolicy');
    }

    buildVfUrl(path) {
        let base = this.finalBaseUrl || '';
        if (base && !base.endsWith('/')) {
            base += '/';
        }
        return `${base}vforcesite${path}`;
    }

    async handleDisplayClick() {
        this.showSpinner(true);
        let actionData = await preViewPdfAction({ 'policyId': this.recordId });
        if (actionData != null) {

            const link = this.buildVfUrl(actionData);
            if (window.parent && window.parent !== window) {
                window.parent.postMessage({ type: 'downloadPdf', url: link, name: 'policy.pdf' }, '*');
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: link
                    }
                });
            }
            this.showSpinner(false);
        }
    }

    generatePolicyPDF(event) {
        this.showSpinner(true);
        validateandGenerateQuotePDF({ 'policyId': this.recordId })
            .then((result) => {
                if (result) {

                    const link = this.buildVfUrl('/apex/' + result + '?id=' + this.recordId);
                    if (window.parent && window.parent !== window) {
                        window.parent.postMessage({ type: 'downloadPdf', url: link, name: 'policy.pdf' }, '*');
                    } else {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__webPage',
                            attributes: {
                                url: link
                            }
                        });
                    }
                } else {
                    let errEvt = new ShowToastEvent({
                        message: 'Cannot generate PDF for the current policy.',
                        title: 'Something wrong happened while generating PDF!',
                        variant: 'error',
                    });
                    this.dispatchEvent(errEvt);
                }
                this.showSpinner(false);
            })
            .catch((error) => {
                console.log('Some error occured');
                console.log(error);
            });
    }

    generatePolicyGreenCard(event) {
        this.showSpinner(true);
        generateGreenCardfromPolicyId({ 'policyId': this.recordId })
            .then((result) => {
                if (result) {
                    const link = this.buildVfUrl('/apex/renderAsPdf?id=' + this.recordId);
                    if (window.parent && window.parent !== window) {
                        window.parent.postMessage({ type: 'downloadPdf', url: link, name: 'policy_greencard.pdf' }, '*');
                    } else {

                        this[NavigationMixin.Navigate]({
                            type: 'standard__webPage',
                            attributes: {
                                url: link
                            }
                        });
                    }
                } else {
                    let errEvt = new ShowToastEvent({
                        message: 'Cannot generate Yellow Card for the current policy',
                        title: 'This policy doesn\'t support Yellow Card',
                        variant: 'error',
                    });
                    this.dispatchEvent(errEvt);
                }
                this.showSpinner(false);
            })
            .catch((error) => {
                console.log('Some error occured');
                console.log(error);
            });
    }

    showSpinner(value) {
        console.log('dispatching loader', value);
        this.dispatchEvent(
            new CustomEvent('loadingstatuschange', {
                detail: value,
                bubbles: true,
                composed: true
            })
        );
    }
}