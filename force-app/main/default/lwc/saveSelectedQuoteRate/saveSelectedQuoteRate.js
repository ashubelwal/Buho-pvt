import { LightningElement, wire, track } from 'lwc';

export default class SaveSelectedQuoteRate extends LightningElement {
    isShowSpinner = true;
    isPolicyId = false;
    connectedCallback() {
        const params = new URLSearchParams(window.location.search);
        let policyPdfId = params.get('Id');
        if(policyPdfId) {
            window.open(window.location.origin + '/apex/selectedQuoteRate?Id=' + policyPdfId, "_self");
        }
        else {
            this.isShowSpinner = false;
            this.isPolicyId = true;
        }
    }
}