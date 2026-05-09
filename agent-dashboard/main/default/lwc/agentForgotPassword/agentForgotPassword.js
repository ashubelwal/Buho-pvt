import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import AGENT_DASHBOARD_RESOURCE from '@salesforce/resourceUrl/agentdashboardResource';
import forgotPassword from '@salesforce/apex/AgentLoginController.forgotPassword';

export default class AgentForgotPassword extends LightningElement {

    logoUrl;
    backgroundStyle;
    cssLoaded = false;

    @track errorCheck = false;
    @track errorMessage = '';
    @track isLoading = false;
    @track isSubmitted = false;

    successMessage = 'If an account exists with this email, you will receive password reset instructions. Please check your inbox (and spam folder).';

    connectedCallback() {
        this.logoUrl = `${AGENT_DASHBOARD_RESOURCE}/images/logo.png`;
        this.backgroundStyle = `background-image: url(${AGENT_DASHBOARD_RESOURCE}/images/rv-mexico-1024x683.webp)`;
    }

    renderedCallback() {
        if (this.cssLoaded) return;
        this.cssLoaded = true;

        Promise.all([
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css'),
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css'),
            loadStyle(this, `${AGENT_DASHBOARD_RESOURCE}/css/style.css`)
        ]).catch(error => {
            console.error('Error loading stylesheets', error);
        });
    }

    // ─── Handlers ─────────────────────────────────────────────────────────────

    handleKeyPress(event) {
        if (event.keyCode === 13) {
            this.handleForgotPassword(event);
        }
    }

    handleForgotPassword(event) {
        if (event) event.preventDefault();

        const emailInput = this.template.querySelector('.email-input');
        const email = emailInput ? emailInput.value.trim() : '';

        // Client-side validation
        if (!email) {
            this.errorMessage = 'Please enter your email address.';
            this.errorCheck = true;
            return;
        }

        if (!this._isValidEmail(email)) {
            this.errorMessage = 'Please enter a valid email address.';
            this.errorCheck = true;
            return;
        }

        this.errorCheck = false;
        this.isLoading = true;

        forgotPassword({ email })
            .then(result => {
                this.isLoading = false;
                // Apex always returns the same neutral message for security;
                // show success state regardless.
                this.isSubmitted = true;
                this.successMessage = result || this.successMessage;
            })
            .catch(error => {
                this.isLoading = false;
                this.errorCheck = true;
                this.errorMessage = (error.body ? error.body.message : null)
                    || 'An error occurred. Please try again.';
            });
    }

    handleResend(event) {
        if (event) event.preventDefault();
        // Go back to the form so the agent can trigger another send
        this.isSubmitted = false;
        this.errorCheck = false;
        this.errorMessage = '';
    }

    handleBackToLogin(event) {
        if (event) event.preventDefault();
        // Navigate back to the login page
        window.location.href = '/agency/login';
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    /**
     * Quick client-side email format check (mirrors the Apex regex).
     * @param {string} email
     * @returns {boolean}
     */
    _isValidEmail(email) {
        const emailRegex = /^[a-zA-Z0-9._|%#~`=?&/$^*!}{+\-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
        return emailRegex.test(email);
    }
}
