import { LightningElement, api } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buhodb_quotecard extends LightningElement {
    @api quoteId;
    @api quoteNumber = '';
    @api quoteStatus = '';
    @api quoteValue = '';
    @api policyType = '';
    @api coverage = '';
    @api termDays = '';
    @api netPremium = '';
    @api vehicleInfo = '';
    @api territory = '';

    get quoteIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }

    handleViewDetails() {
        this.dispatchEvent(new CustomEvent('viewquote', {
            detail: { quoteId: this.quoteId },
            bubbles: true,
            composed: true
        }));
    }
}
