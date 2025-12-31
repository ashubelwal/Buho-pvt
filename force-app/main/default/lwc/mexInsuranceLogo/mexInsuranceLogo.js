import { LightningElement } from 'lwc';

export default class MexInsuranceLogo extends LightningElement {
    redirectToSite() {
        window.location.href = "https://www.mexinsurance.com";
    }
}