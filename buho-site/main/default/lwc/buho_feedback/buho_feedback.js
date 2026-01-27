import { LightningElement, track, api } from 'lwc';
import submitFeedback from '@salesforce/apex/NcController.submitFeedback';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nc_feedback extends LightningElement {
    @track rating = 0;
    @track feedbackText = '';
    @api baseUrl;

    // Array of stars
    get stars() {
        return Array.from({ length: 10 }, (_, i) => ({
            value: i + 1,
            filled: i < this.rating ? 'var(--accent-pink)' : 'none',
            class: 'star-icon'
        }));
    }

    // Calculate remaining characters
    get remainingChars() {
        return 500 - (this.feedbackText?.length || 0);
    }

    // Handle star selection
    handleStarClick(event) {
        // Use currentTarget to get the button element (not the SVG child)
        const button = event.currentTarget;
        this.rating = parseInt(button.dataset.value, 10);
        console.log('Star clicked, rating:', this.rating);
    }

    // Handle text area input
    handleFeedbackChange(event) {
        this.feedbackText = event.detail.value;
    }

    // Handle feedback submission
    async handleSubmit() {
        if (this.rating === 0) {
            this.showToast('Error', 'Please select a rating before submitting.', 'error');
            return;
        }

        try {
            await submitFeedback({ rating: this.rating, feedback: this.feedbackText })
            .then(result => {
                console.log('result : ', result);
                this.showToast('Success', 'Thank you for your feedback!', 'success');
                this.rating = 0;
                this.feedbackText = '';
                window.location.href = this.baseUrl;
            })            
            .catch(err => {
                console.log('OUTPUT : ', JSON.stringify(err.message));
                this.showToast('Error', 'An error occurred while saving the data. Please try again later.', 'error');
            }) 
        } catch (error) {
            this.showToast('Error', 'Error submitting feedback', 'error');
            console.error(error);
        }
    }

    // Toast Message
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    @api async getData() {        
        console.log('Feedback - getData: ', "");
        return "Feedback";
    }

    @api validate() {
        return true;
    }
}