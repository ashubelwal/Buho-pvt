import { LightningElement, api } from 'lwc';

export default class Nc_modal extends LightningElement {
    @api modalTitle = 'Modal Title';
    @api btnName = 'See more';
    @api modalContent = 'This is some information in the modal.';
    @api classNames = 'slds-button slds-button_outline-brand'

    isVisible = false; // Determines if modal DOM is rendered
    isClosing = false; // Controls fade out animation

    get modalClass() {
        return `slds-modal ${this.isClosing ? 'modal-close' : 'modal-open'}`;
    }

    get backdropClass() {
        return `slds-backdrop ${this.isClosing ? 'modal-close' : 'slds-backdrop_open'}`;
    }

    handleOpenModal() {
        this.isVisible = true;
        this.isClosing = false;
    }

    handleCloseModal() {
        this.isClosing = true;

        // Wait for animation to finish before removing from DOM
        setTimeout(() => {
            this.isVisible = false;
        }, 500); // Match duration in CSS
    }
}