import { LightningElement, api } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buhodb_policycard extends LightningElement {
    @api policyId;
    @api vehicleName = '';
    @api policyNumber = '';
    @api activeUntil = '';
    @api coverage = '';
    @api premium = '';
    @api paymentType = '';

    get carIconUrl() {
        return `${buhoAssets}/images/caricon.svg`;
    }

    handleViewDetails() {
        this.dispatchEvent(new CustomEvent('viewdetails', {
            detail: { policyId: this.policyId },
            bubbles: true,
            composed: true
        }));
    }

    handleDownloadDocuments() {
        this.dispatchEvent(new CustomEvent('downloaddocuments', {
            detail: { policyId: this.policyId },
            bubbles: true,
            composed: true
        }));
    }

    handleRenew() {
        this.dispatchEvent(new CustomEvent('renew', {
            detail: { policyId: this.policyId },
            bubbles: true,
            composed: true
        }));
    }
}
