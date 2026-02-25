import { LightningElement, api } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buhodb_vehiclecard extends LightningElement {
    @api vehicleId;
    @api vehicleName = '';
    @api vin = '';
    @api plate = '';
    @api value = '';
    @api surcharge = '';
    @api surchargeType = '';
    @api primaryDriver = '';
    @api added = '';
    @api usageStats = '';
    @api premium = '';

    get carIconUrl() {
        return `${buhoAssets}/images/caricon.svg`;
    }

    handleEdit() {
        this.dispatchEvent(new CustomEvent('editvehicle', {
            detail: { vehicleId: this.vehicleId },
            bubbles: true,
            composed: true
        }));
    }

    handleUpdateValue() {
        this.dispatchEvent(new CustomEvent('updatevalue', {
            detail: { vehicleId: this.vehicleId },
            bubbles: true,
            composed: true
        }));
    }
}
