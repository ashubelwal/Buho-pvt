import { LightningElement, api } from 'lwc';

/**
 * BÚHO Theme Layout Component
 * This is a simple layout without header/footer
 * All CSS is loaded globally in the community head markup
 */
export default class Buho_theme extends LightningElement {
    @api recordId;
    @api objectApiName;
}
