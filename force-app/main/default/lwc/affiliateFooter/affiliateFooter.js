import { LightningElement,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class AffiliateFooter extends LightningElement {
    isFrame = false;
    frame;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.frame = currentPageReference.state.frame;
            if(this.frame) {
                this.isFrame = true;
            } else {
                this.isFrame = false;
            }
        }
    }

}