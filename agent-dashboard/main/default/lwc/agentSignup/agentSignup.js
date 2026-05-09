import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import AGENT_DASHBOARD_RESOURCE from '@salesforce/resourceUrl/agentdashboardResource';

export default class AgentSignup extends LightningElement {

    logoUrl;
    backgroundStyle;
    cssLoaded = false;

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

    handleGoToLogin(event) {
        event.preventDefault();
        // Navigation to login will be wired up later
    }

    handleSignup(event) {
        event.preventDefault();
        // Sign-up logic will be wired up later
    }
}
