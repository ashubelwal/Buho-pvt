import { LightningElement, api } from 'lwc';

export default class Buho_progressBar extends LightningElement {
    @api currentStep = 1;
    @api totalSteps = 4;
    @api hideBackButton = false;

    get progressSegments() {
        const segments = [];
        for (let i = 1; i <= this.totalSteps; i++) {
            let className = 'progress-segment';
            if (i < this.currentStep) {
                className += ' completed';
            } else if (i === this.currentStep) {
                className += ' active';
            }
            segments.push({ step: i, className });
        }
        return segments;
    }

    handleBack() {
        // Dispatch event to parent to handle back navigation
        this.dispatchEvent(new CustomEvent('back', {
            detail: { direction: 'previous' },
            bubbles: true,
            composed: true
        }));
    }
}

