import { LightningElement ,api, track } from 'lwc';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';
import defaultTemplate from './affiliatePolicyQuickActions.html';
import enhancedTemplate from './enhanced.html';

export default class AffiliatePolicyQuickActions extends LightningElement {
    @api cmpSource;
    @api renewdPolicyId;
    @api actionmode;
    @api isEnhanced = false;
    @track isLoading;

    render() {
        return this.isEnhanced ? enhancedTemplate : defaultTemplate;
    }

    get acknowledgementMessage() {
        if (this.actionmode === 'renew') {
            return 'Your policy has been renewed successfully';
        }
        if (this.actionmode === 'purchase' || this.actionmode === 'new') {
            return 'Your policy has been created successfully';
        }
        return 'Your policy has been updated successfully';
    }

    handleNewQuote() {
        window.location.reload();
    }

    showToastmethod(variant, title, message) {
        if (this.isEnhanced) {
            const toast = this.template.querySelector('c-buho_toast');
            if (toast) {
                toast.showToast({ variant, title, message });
            }
        } else {
            const toast = this.template.querySelector('c-custom-toast');
            if (toast) {
                toast.showToast({ variant, title, message });
            }
        }
    }

    generatePolicyPDF(event) {
        this.isLoading = true;
        validateandGenerateQuotePDF({ 'policyId': this.renewdPolicyId })
            .then((result) => {
                this.isLoading = false;
                if (result) {
                    window.open(('/affiliatevforcesite/apex/' + result + '?id=' + this.renewdPolicyId), '_blank');
                } else {
                    this.showToastmethod('error', 'Something wrong happened while generating PDF!', 'Cannot generate PDF for the current policy.');
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log(error);
                this.showToastmethod('error', error?.body?.message || 'An error occurred while generating the PDF. Please try again.', 'PDF Generation Error');
            });
    }
}