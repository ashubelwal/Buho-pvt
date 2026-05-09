import { LightningElement, api } from 'lwc';
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
const BASE_CLASS = 'sidebar-nav-item';
const ACTIVE_CLASS = `${BASE_CLASS} active`;

const ALL_PAGES = [
    'dashboard', 'clients', 'quotes', 'renewals',
    'newQuote', 'endorsement', 'cancelPolicy',
    'reports', 'underwriting', 'users', 'profile'
];

export default class AgentSideNavigation extends LightningElement {

    @api activePage = 'dashboard';
    @api logoUrl;
    @api isMobileOpen = false;
    @api isAgencyUser = false;

    // Dynamically compute CSS class for sidebar container
    get sidebarClass() {
        return this.isMobileOpen ? 'sidebar sidebar-mobile-open' : 'sidebar';
    }

    // Dynamically compute CSS class for each nav item
    get navClass() {
        return ALL_PAGES.reduce((acc, page) => {
            acc[page] = this.activePage === page ? ACTIVE_CLASS : BASE_CLASS;
            return acc;
        }, {});
    }

    handleNavClick(event) {
        const page = event.currentTarget.dataset.page;
        if (!page) return;

        // Bubble up to agentContainer
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { page }
        }));
    }

    handleLogout() {
        window.location.replace('/agency/secur/logout.jsp');
    }
}
