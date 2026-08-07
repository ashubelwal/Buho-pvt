import { LightningElement, api, track } from 'lwc';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';


export default class AgentPolicyQuickActions extends LightningElement {
    @api cmpSource;
    @api renewdPolicyId;
    @api actionmode;
    @track isLoading;

    get acknowledgementMessage() {
        return this.actionmode == 'renew' ? 'Your policy has been renewed successfully' : 'Your policy has been updated successfully';
    }

    showToastmethod(variant, title, message) {
        this.template.querySelector('c-custom-toast').showToast(variant, title, message);
    }

    generatePolicyPDF(event) {
        this.isLoading = true;
        validateandGenerateQuotePDF({ 'policyId': this.renewdPolicyId })
            .then((result) => {
                this.isLoading = false;
                if (result) {
                    if (this.cmpSource === 'comm') {
                        window.open(('/customervforcesite/apex/' + result + '?id=' + this.renewdPolicyId), '_blank');
                    } else if (this.isAgentPortal) {
                        window.open(('/agencyvforcesite/apex/' + result + '?id=' + this.renewdPolicyId), '_blank');
                    } else {
                        window.open(('/apex/' + result + '?id=' + this.renewdPolicyId), '_blank');
                    }
                } else {
                    if (this.cmpSource === 'comm') {
                        this.showToastmethod('error', 'Something wrong happened while generating PDF!', 'Cannot generate PDF for the current policy.');

                    } else {
                        let errEvt = new ShowToastEvent({
                            message: 'Cannot generate PDF for the current policy.',
                            title: 'Something wrong happened while generating PDF!',
                            variant: 'error',
                        });
                        this.dispatchEvent(errEvt);
                    }

                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log(error);
            });
    }

    navigateToPolicy(event) {
        console.log('this.cmpSource');
        console.log(this.cmpSource);
        if (this.cmpSource == 'comm') {
            let currentUrl = window.location.origin;
            location.replace(`${currentUrl}/agency/policy/` + this.renewdPolicyId);
            console.log('INSIDE community');
        } else {
            console.log('OUTSIDE community');
            window.open(('/' + this.renewdPolicyId), '_blank');
        }

    }

}