import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import forgotPassword from '@salesforce/apex/BuhoLoginController.forgotPassword';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import basePath from '@salesforce/community/basePath';

export default class Buho_forgotPassword extends NavigationMixin(LightningElement) {
    @track email = '';
    @track errorMessage = '';
    @track successMessage = '';
    @track isLoading = false;
    @track emailSent = false;

    // Logo URL
    get logoUrl() {
        return `${buhoAssets}/images/Logo.svg`;
    }

    // Dynamic email input class
    get emailInputClass() {
        return this.errorMessage ? 'error' : '';
    }

    // Handle email input change
    handleEmailChange(event) {
        this.email = event.target.value;
        this.errorMessage = '';
        this.successMessage = '';
    }

    // Handle form submission
    handleSubmit(event) {
        event.preventDefault();
        
        // Clear previous messages
        this.errorMessage = '';
        this.successMessage = '';

        // Validate email
        if (!this.validateEmail()) {
            return;
        }

        // Call Apex to send reset email
        this.sendResetEmail();
    }

    // Validate email format
    validateEmail() {
        if (!this.email || this.email.trim() === '') {
            this.errorMessage = 'Please enter your email address.';
            return false;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(this.email)) {
            this.errorMessage = 'Please enter a valid email address.';
            return false;
        }

        return true;
    }

    // Send password reset email via Apex
    async sendResetEmail() {
        this.isLoading = true;

        try {
            const result = await forgotPassword({ email: this.email });
            
            // Show success message and update UI
            this.successMessage = result;
            this.emailSent = true;
            this.errorMessage = '';

        } catch (error) {
            console.error('Error sending reset email:', error);
            this.errorMessage = error.body?.message || 'An error occurred. Please try again.';
            this.successMessage = '';
        } finally {
            this.isLoading = false;
        }
    }

    // Handle "Try Another Email" button
    handleTryAgain() {
        this.emailSent = false;
        this.email = '';
        this.successMessage = '';
        this.errorMessage = '';
    }

    // Navigate back to login page
    handleBackToLogin(event) {
        event.preventDefault();
        
        // Navigate to login page
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login'
            }
        });
    }
}

