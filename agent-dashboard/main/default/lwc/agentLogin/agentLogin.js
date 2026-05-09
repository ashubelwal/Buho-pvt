import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import AGENT_DASHBOARD_RESOURCE from '@salesforce/resourceUrl/agentdashboardResource';
import login from '@salesforce/apex/AgentLoginController.login';

export default class AgentLogin extends LightningElement {

    logoUrl;
    backgroundStyle;
    cssLoaded = false;

    errorCheck = false;
    errorMessage = '';

    connectedCallback() {
        this.logoUrl = `${AGENT_DASHBOARD_RESOURCE}/images/logo.png`;
        this.backgroundStyle = `background-image: url(${AGENT_DASHBOARD_RESOURCE}/images/rv-mexico-1024x683.webp)`;
    }

    renderedCallback() {
        if (this.cssLoaded) return;
        this.cssLoaded = true;

        // Load Bootstrap 5 CSS (CDN) + our shared stylesheet
        Promise.all([
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css'),
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css'),
            loadStyle(this, `${AGENT_DASHBOARD_RESOURCE}/css/style.css`)
        ]).catch(error => {
            console.error('Error loading stylesheets', error);
        });
    }

    handleGoToSignup(event) {
        if (event) event.preventDefault();
        // Navigation to signup will be wired up later
    }

    handleForgotPassword(event) {
        if (event) event.preventDefault();
        window.location.href = '/agency/ForgotPassword';
    }

    handleKeyPress(event) {
        if (event.keyCode === 13) {
            this.handleLogin(event);
        }
    }

    handleLogin(event) {
        if (event) event.preventDefault();

        let emailInput = this.template.querySelector('.email-input').value;
        let pswInput = this.template.querySelector('.password-input').value;

        if (!emailInput || !pswInput) {
            this.errorMessage = 'Please enter both email and password.';
            this.errorCheck = true;
            return;
        }

        login({ username: emailInput, password: pswInput, startUrl: '/agency' })
            .then(result => {
                // If it looks like a URL (starts with slash or http), login was successful
                if (result && (result.startsWith('/') || result.startsWith('http'))) {
                    this.errorCheck = false;
                    window.location.href = result;
                } else {
                    // Display specific error string returned from Apex
                    this.errorCheck = true;
                    this.errorMessage = result || 'Invalid login or credentials.';
                }
            })
            .catch(error => {
                this.errorCheck = true;
                this.errorMessage = error.body ? error.body.message : 'An error occurred directly communicating with the server.';
            });
    }
}
