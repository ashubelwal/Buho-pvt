import { LightningElement, api } from 'lwc';

export default class Buho_modal extends LightningElement {
    @api modalTitle = '';
    @api modalContent = '';
    @api btnName = 'See more';
    @api classNames = '';

    showModal = false;

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleOverlayClick(event) {
        // Close modal if clicking on the overlay (not the content)
        if (event.target === event.currentTarget) {
            this.closeModal();
        }
    }
}

