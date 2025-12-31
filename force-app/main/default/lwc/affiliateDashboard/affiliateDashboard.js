import { LightningElement, api, track, wire } from 'lwc';
import getPolicies from '@salesforce/apex/AffiliatePortalController.getPolicies';
import validateSession from '@salesforce/apex/AffiliatePortalController.validateSession';
import { CurrentPageReference } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AffiliateDashboard extends LightningElement {
    @api recordId; // This will hold the Contact ID passed from the parent component or page
    @track policies;
    @track error;
    @track affiliateCode;
    @track frame;
    @track isLoading = true;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.affiliateCode = currentPageReference.state.code;
            this.frame = currentPageReference.state.frame;
            console.log('Frame console in Dashboard', this.frame);
            console.log('Affiliate cide in Dashboard', this.affiliateCode);

        }
    }

    connectedCallback() {
        this.isLoading = true;
        console.log('Cookie in the agent dashboard', document.cookie);
        const cookies = document.cookie.split('; ').reduce((acc, cookie) => {
            const [key, ...valueParts] = cookie.split('=');
            acc[key] = valueParts.join('=');
            return acc;
        }, {});

        const sessionId = cookies.sessionId;
        console.log('Session Id', sessionId);

        if (sessionId !== undefined) {
            console.log('inside validating session');
            validateSession({ sessionId: sessionId, contactId: this.recordId })
                .then((result) => {
                    if (result) {
                        console.log('Result in validation', result);
                        getPolicies({ contactId: this.recordId })
                            .then((data) => {
                                console.log('Data in apex', data);
                                this.policies = data;
                                this.error = undefined;
                                this.isLoading = false;
                            })
                            .catch((error) => {
                                console.log('Invalid session', error);
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
                                this.isLoading = false;
                            })
                    } else {
                        console.log('Result in validation', result);
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
                        this.isLoading = false;
                    }
                })
                .catch((error) => {
                    console.log('Error', error);
                    this.error = 'Failed to load policies. Please try again.';
                    this.isLoading = false;
                })
        } else {
            console.log('No session Id 22');
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
            this.isLoading = false;
        }
    }

    // Action handlers
    handleEdit(event) {
        const policyId = event.target.dataset.id;
        this.showToast('Edit', `Edit policy with ID: ${policyId}`);
        let currentUrl = window.location.origin;
        if (this.affiliateCode != undefined && this.frame != undefined) {
            location.assign(`${currentUrl}/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=edit&code=${this.affiliateCode}&frame=true`);
        } else if (this.affiliateCode != undefined & this.frame == undefined) {
            location.assign(`${currentUrl}/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=edit&code=${this.affiliateCode}`);
        } else if (this.affiliateCode == undefined & this.frame != undefined) {
            location.assign(`/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=edit&frame=true`);
        }
        else {
            location.assign(`${currentUrl}/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=edit`);
        }
    }

    handleRenew(event) {
        const policyId = event.target.dataset.id;
        this.showToast('Renew', `Renew policy with ID: ${policyId}`);
        let currentUrl = window.location.origin;
        if (this.affiliateCode != undefined & this.frame != undefined) {
            location.assign(`${currentUrl}/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=renew&code=${this.affiliateCode}&frame=true`);
        } else if (this.affiliateCode != undefined & this.frame == undefined) {
            location.assign(`${currentUrl}/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=renew&code=${this.affiliateCode}`);
        } else if (this.affiliateCode == undefined & this.frame != undefined) {
            location.assign(`${currentUrl}/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=renew&frame=true`);
        }
        else {
            location.assign(`${currentUrl}/affiliate/policy-edit-renew?policyId=${policyId}&actionmode=renew`);
        }
    }

    handleTerminate(event) {
         const policyId = event.target.dataset.id;
        this.showToast('Terminate', `Terminate policy with ID: ${policyId}`);
        let currentUrl = window.location.origin;
        if (this.affiliateCode != undefined & this.frame != undefined) {
            location.assign(`${currentUrl}/affiliate/terminate?policyId=${policyId}&code=${this.affiliateCode}&frame=true`);
        } else if (this.affiliateCode != undefined & this.frame == undefined) {
            location.assign(`${currentUrl}/affiliate/terminate?policyId=${policyId}&code=${this.affiliateCode}`);
        } else if (this.affiliateCode == undefined & this.frame != undefined) {
            location.assign(`${currentUrl}/affiliate/terminate?policyId=${policyId}&frame=true`);
        }
        else {
            location.assign(`${currentUrl}/affiliate/terminate?policyId=${policyId}`);
        }
    }

    // Utility function to show toast messages
    showToast(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'info'
        });
        this.dispatchEvent(evt);
    }

}