import { LightningElement, api } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buhodb_drivercard extends LightningElement {
    @api driverId;
    @api driverName = '';
    @api licenseNumber = '';
    @api licenseState = '';
    @api dob = '';
    @api driverType = '';
    @api email = '';
    @api phone = '';
    @api city = '';
    @api licenseExpire = '';
    @api isPrimary = false;

    get driverIconUrl() {
        return `${buhoAssets}/images/drivericon.svg`;
    }

    handleViewDetails() {
        this.dispatchEvent(new CustomEvent('viewdriver', {
            detail: { driverId: this.driverId },
            bubbles: true,
            composed: true
        }));
    }
}
