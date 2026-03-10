import { LightningElement, api, track } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buhodb_menu extends LightningElement {
    @api currentView = 'dashboard';
    @api isMobileOpen = false;
    @track isCollapsed = false;

    // Asset URLs
    get logoUrl() {
        return `${buhoAssets}/images/Logo.png`;
    }

    get logoUrlSmall() {
        return `${buhoAssets}/images/Owl-no-bg.png`;
    }

    // Icon URLs
    get policiesIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }

    get vehiclesIconUrl() {
        return `${buhoAssets}/images/vehicleicon.svg`;
    }

    get driversIconUrl() {
        return `${buhoAssets}/images/drivericon.svg`;
    }

    get documentsIconUrl() {
        return `${buhoAssets}/images/documenticon.svg`;
    }

    get notificationsIconUrl() {
        return `${buhoAssets}/images/bellicon.svg`;
    }

    get settingsIconUrl() {
        return `${buhoAssets}/images/settingsicon.svg`;
    }

    // Computed properties for each menu item's active class
    get dashboardClass() {
        return this.currentView === 'dashboard' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get policiesClass() {
        return this.currentView === 'policies' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get vehiclesClass() {
        return this.currentView === 'vehicles' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get driversClass() {
        return this.currentView === 'drivers' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get quotesClass() {
        return this.currentView === 'quotes' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get transactionsClass() {
        return this.currentView === 'transactions' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get documentsClass() {
        return this.currentView === 'documents' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get notificationsClass() {
        return this.currentView === 'notifications' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    get settingsClass() {
        return this.currentView === 'settings' ? 'dashboard-nav-link active' : 'dashboard-nav-link';
    }

    handleNavClick(event) {
        // Prevent <a> tag default behavior that can interfere with
        // Experience Cloud routing and cause unwanted page navigation.
        event.preventDefault();

        const view = event.currentTarget.dataset.view;
        
        // Dispatch custom event to parent container
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { view },
            bubbles: true,
            composed: true
        }));
    }

    handleLogout(event) {
        event.preventDefault();
        window.location.href = '/secur/logout.jsp';
    }

    handleCollapseToggle() {
        this.isCollapsed = !this.isCollapsed;
        
        // Dispatch event to parent container
        this.dispatchEvent(new CustomEvent('collapse', {
            detail: { isCollapsed: this.isCollapsed },
            bubbles: true,
            composed: true
        }));
    }

    get sidebarClass() {
        let cls = 'dashboard-sidebar';
        if (this.isCollapsed) cls += ' collapsed';
        if (this.isMobileOpen) cls += ' mobile-open';
        return cls;
    }

    get collapseIconClass() {
        return this.isCollapsed ? 'bi bi-chevron-right' : 'bi bi-chevron-left';
    }
}
