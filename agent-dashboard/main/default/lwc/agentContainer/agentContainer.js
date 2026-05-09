import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import AGENT_DASHBOARD_RESOURCE from '@salesforce/resourceUrl/agentdashboardResource';
import isGuestUser from '@salesforce/user/isGuest';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const CONTACT_FIELDS = ['Contact.Agency__c'];

// Map each hash value → a readable page title
const PAGE_TITLES = {
    dashboard: 'Dashboard',
    clients: 'Clients',
    quotes: 'Quotes',
    renewals: 'Renewals',
    newQuote: 'New Quote',
    lookUpPolicy: 'Look Up Policy',
    contactDetails: 'Contact Details',
    policyEditRenew: 'Policy Edit / Renew',
    agentQuickQuote: 'Quick Quote',
    endorsement: 'Endorsement',
    cancelPolicy: 'Cancel Policy',
    terminatePolicy: 'Terminate Policy',
    reports: 'Charts',
    underwriting: 'Underwriting',
    users: 'Users',
    profile: 'Profile'
};

export default class AgentContainer extends NavigationMixin(LightningElement) {

    @track activePage = 'dashboard';
    @track isMobileMenuOpen = false;
    @track contactId;

    // Resolved agency id – set by the agencyId getter logic
    @track _agencyIdFromContact;

    logoUrl;
    cssLoaded = false;
    loadPage = false;

    @track isAgencyUser = false;

    @wire(getRecord, { recordId: USER_ID, fields: ['User.ContactId', 'User.Logo_URL__c', 'User.Contact.RecordType.Name'] })
    wiredUser({ error, data }) {
        if (data) {
            this.contactId = getFieldValue(data, 'User.ContactId');
            const logo = getFieldValue(data, 'User.Logo_URL__c');
            this.logoUrl = logo ? logo : `${AGENT_DASHBOARD_RESOURCE}/images/logo.png`;
            const rtName = getFieldValue(data, 'User.Contact.RecordType.Name');
            this.isAgencyUser = rtName === 'Agency RT';
        } else if (error) {
            this.logoUrl = `${AGENT_DASHBOARD_RESOURCE}/images/logo.png`;
        }
    }

    // Fetch Contact.Agency__c so non-Agency-RT agents can resolve their parent agency
    @wire(getRecord, { recordId: '$contactId', fields: CONTACT_FIELDS })
    wiredContact({ data, error }) {
        if (data) {
            this._agencyIdFromContact = getFieldValue(data, 'Contact.Agency__c');
        }
        if (error) {
            console.error('AgentContainer: error fetching Contact.Agency__c', error);
        }
    }

    /**
     * Returns the agency Id to pass down to child components.
     * - Agency RT users  → their own Contact Id (they ARE the agency record).
     * - All other users  → their Contact's Agency__c lookup value.
     */
    get agencyId() {
        return this.isAgencyUser ? this.contactId : this._agencyIdFromContact;
    }

    // ── Lifecycle ────────────────────────────────────────────────────
    connectedCallback() {
        this.loadPage = !isGuestUser;
        if (isGuestUser) {
            window.location.href = '/agency/login';
        }
        if (!this.logoUrl) {
            this.logoUrl = `${AGENT_DASHBOARD_RESOURCE}/images/logo.png`;
        }

        // Read initial hash
        this._readHash();

        // Listen for hash changes (browser back/forward or manual URL edits)
        this._hashChangeHandler = this._readHash.bind(this);
        window.addEventListener('hashchange', this._hashChangeHandler);
    }

    disconnectedCallback() {
        window.removeEventListener('hashchange', this._hashChangeHandler);
    }

    renderedCallback() {
        if (this.cssLoaded) return;
        this.cssLoaded = true;

        Promise.all([
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css'),
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css'),
            loadStyle(this, `${AGENT_DASHBOARD_RESOURCE}/css/style.css`)
        ]).catch(error => console.error('Style load error', error));
    }

    // ── Routing helpers ──────────────────────────────────────────────
    _readHash() {
        const hash = (window.location.hash || '').replace('#', '') || 'dashboard';
        this.activePage = Object.keys(PAGE_TITLES).includes(hash) ? hash : 'dashboard';
        this.isMobileMenuOpen = false; // close menu on route change
    }

    get pageTitle() {
        return PAGE_TITLES[this.activePage] || 'Dashboard';
    }

    // ── Mobile Menu Handlers ─────────────────────────────────────────
    handleMenuToggle() {
        this.isMobileMenuOpen = !this.isMobileMenuOpen;
    }

    closeMobileMenu() {
        this.isMobileMenuOpen = false;
    }

    get overlayClass() {
        return this.isMobileMenuOpen ? 'sidebar-overlay active' : 'sidebar-overlay';
    }

    // ── Event from sidebar ───────────────────────────────────────────
    handleNavigate(event) {
        console.log('@@@event received', event);
        const page = event.detail.page;
        const params = event.detail.params;

        let newUrl = new URL(window.location.href);
        newUrl.search = ''; // clear existing parameters

        if (params) {
            for (let key in params) {
                newUrl.searchParams.set(key, params[key]);
            }
        }

        window.history.pushState({}, '', newUrl.toString());
        Promise.resolve().then(() => {
            window.location.hash = page;
            this.activePage = page;
            this.isMobileMenuOpen = false; // Close menu after navigating
        });
    }

    handleToast(event) {
        const toastCmp = this.template.querySelector('c-agent-toast');
        if (toastCmp) {
            toastCmp.showToast(event.detail);
        }
    }

    // ── Page guards (drives lwc:if / lwc:elseif in template) ─────────
    get isDashboard() { return this.activePage === 'dashboard'; }
    get isClients() { return this.activePage === 'clients'; }
    get isQuotes() { return this.activePage === 'quotes'; }
    get isRenewals() { return this.activePage === 'renewals'; }
    get isNewQuote() { return this.activePage === 'newQuote'; }
    get isLookUpPolicy() { return this.activePage === 'lookUpPolicy'; }
    get isContactDetails() { return this.activePage === 'contactDetails'; }
    get isPolicyEditRenew() { return this.activePage === 'policyEditRenew'; }
    get isAgentQuickQuote() { return this.activePage === 'agentQuickQuote'; }
    get isEndorsement() { return this.activePage === 'endorsement'; }
    get isCancelPolicy() { return this.activePage === 'cancelPolicy'; }
    get isTerminatePolicy() { return this.activePage === 'terminatePolicy'; }
    
    get targetRecordId() {
        const urlParams = new URL(window.location.href).searchParams;
        return urlParams.get('c__id') || urlParams.get('c__policyId');
    }

    get isReports() { return this.activePage === 'reports'; }
    get isUnderwriting() { return this.activePage === 'underwriting'; }
    get isUsers() { return this.activePage === 'users'; }
    get isProfile() { return this.activePage === 'profile'; }
}
