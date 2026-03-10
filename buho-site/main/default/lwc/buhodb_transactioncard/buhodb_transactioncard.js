import { LightningElement, api } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buhodb_transactioncard extends LightningElement {
    @api transactionId;
    @api transactionName = '';
    @api transactionType = '';
    @api amount = '';
    @api premiumAmount = '';
    @api taxIva = '';
    @api paymentType = '';
    @api mode = '';
    @api policyRef = '';
    @api ccMask = '';
    @api gatewaySource = '';
    @api termDays = '';
    @api createdAt = '';
    @api description = '';

    get transactionIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }
}
