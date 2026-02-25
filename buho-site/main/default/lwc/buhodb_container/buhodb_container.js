import { LightningElement, track } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

// Valid views that map to URL hashes
const VALID_VIEWS = [
    'dashboard',
    'policies',
    'newpolicy',
    'policydetail',
    'editpolicy',
    'vehicles',
    'drivers',
    'quotes',
    'transactions',
    'documents',
    'notifications',
    'settings'
];

export default class Buhodb_container extends LightningElement {
    @track currentView = 'dashboard';
    @track isMobileSidebarOpen = false;

    // Asset URLs
    get logoUrl() {
        return `${buhoAssets}/images/Logo.png`;
    }

    connectedCallback() {
        // Restore view from URL hash on load
        this._restoreViewFromHash();

        // Use popstate (not hashchange) so that history.pushState driven
        // navigation doesn't fight with the Experience Cloud LWR router.
        this._boundPopState = this._handlePopState.bind(this);
        window.addEventListener('popstate', this._boundPopState);

        this._boundResize = this.handleResize.bind(this);
        window.addEventListener('resize', this._boundResize);
    }

    disconnectedCallback() {
        window.removeEventListener('popstate', this._boundPopState);
        window.removeEventListener('resize', this._boundResize);
    }

    // ── Hash / URL helpers ──

    _restoreViewFromHash() {
        const hash = window.location.hash.replace('#', '').toLowerCase();
        if (hash && VALID_VIEWS.includes(hash)) {
            this.currentView = hash;
        } else {
            this.currentView = 'dashboard';
            // Use replaceState for the initial default so we don't push
            // an extra history entry on first load.
            history.replaceState(null, '', '#dashboard');
        }
    }

    _handlePopState() {
        const hash = window.location.hash.replace('#', '').toLowerCase();
        if (hash && VALID_VIEWS.includes(hash) && hash !== this.currentView) {
            this.currentView = hash;
        }
    }

    _updateHash(view) {
        if (window.location.hash !== `#${view}`) {
            // pushState updates the URL without triggering the LWR router
            // or hashchange events — avoids page reload in Experience Cloud.
            history.pushState(null, '', `#${view}`);
        }
    }

    // ── Resize ──

    handleResize() {
        if (window.innerWidth > 768 && this.isMobileSidebarOpen) {
            this.isMobileSidebarOpen = false;
        }
    }

    // ── Menu interactions ──

    handleMenuToggle() {
        this.isMobileSidebarOpen = !this.isMobileSidebarOpen;
    }

    handleOverlayClick() {
        this.isMobileSidebarOpen = false;
    }

    handleNavigate(event) {
        const { view } = event.detail;
        this.currentView = view;
        this._updateHash(view);

        if (this.isMobileSidebarOpen) {
            this.isMobileSidebarOpen = false;
        }
    }

    /**
     * Fired by child components (e.g. buhodb_mypolicy) to update the URL hash.
     */
    handleHashUpdate(event) {
        const { hash } = event.detail;
        if (hash && VALID_VIEWS.includes(hash)) {
            this.currentView = hash;
            this._updateHash(hash);
        }
    }

    // ── View state getters ──

    get showDashboard() {
        return this.currentView === 'dashboard';
    }

    get showPolicies() {
        return this.currentView === 'policies' || this.currentView === 'newpolicy' || this.currentView === 'policydetail' || this.currentView === 'editpolicy';
    }

    /** Sub-view for mypolicy: 'list', 'addPolicy', 'detail', or 'editPolicy' */
    get policySubView() {
        if (this.currentView === 'newpolicy') return 'addPolicy';
        if (this.currentView === 'policydetail') return 'detail';
        if (this.currentView === 'editpolicy') return 'editPolicy';
        return 'list';
    }

    get showVehicles() {
        return this.currentView === 'vehicles';
    }

    get showDrivers() {
        return this.currentView === 'drivers';
    }

    get showQuotes() {
        return this.currentView === 'quotes';
    }

    get showTransactions() {
        return this.currentView === 'transactions';
    }

    get showDocuments() {
        return this.currentView === 'documents';
    }

    get showNotifications() {
        return this.currentView === 'notifications';
    }

    get showSettings() {
        return this.currentView === 'settings';
    }

    // ── CSS class getters ──

    get overlayClass() {
        return this.isMobileSidebarOpen ? 'dashboard-sidebar-overlay active' : 'dashboard-sidebar-overlay';
    }

    /** Remove padding for new policy (quote wizard) and edit policy views */
    get dashboardContentClass() {
        return (this.currentView === 'newpolicy' || this.currentView === 'editpolicy')
            ? 'dashboard-content dashboard-content-no-padding'
            : 'dashboard-content';
    }
}
