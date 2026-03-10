import { LightningElement, api, track } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buhodb_documentcard extends LightningElement {
    @api documentId;
    @api title = '';
    // 'action' = pink "Action" button, 'download' = pink "Download Document" button
    @api variant = 'action';
    // Pass details as JSON arrays: [{id, text}]
    @api leftDetails = [];
    @api rightDetails = [];

    @track isActionOpen = false;

    get chevronDownIconUrl() {
        return `${buhoAssets}/images/chevron-down.svg`;
    }

    get actionLabel() {
        return this.variant === 'download' ? 'Download Document' : 'Action';
    }

    get actionBtnClass() {
        return 'btn-doc-action';
    }

    handleActionToggle() {
        this.isActionOpen = !this.isActionOpen;
    }

    handleDownload() {
        this.isActionOpen = false;
        this.dispatchEvent(new CustomEvent('downloaddoc', {
            detail: { documentId: this.documentId },
            bubbles: true,
            composed: true
        }));
    }

    handleView() {
        this.isActionOpen = false;
        this.dispatchEvent(new CustomEvent('viewdoc', {
            detail: { documentId: this.documentId },
            bubbles: true,
            composed: true
        }));
    }

    handleEmail() {
        this.isActionOpen = false;
        this.dispatchEvent(new CustomEvent('emaildoc', {
            detail: { documentId: this.documentId },
            bubbles: true,
            composed: true
        }));
    }
}
