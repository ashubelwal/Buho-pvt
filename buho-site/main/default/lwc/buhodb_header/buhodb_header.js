import { LightningElement, api, wire, track } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/BuhoAssets';
import getUserName from '@salesforce/apex/BuhoDashboardController.getUserName';
export default class Buhodb_header extends LightningElement {
    searchQuery = '';
    userName = '';
    @wire(getUserName)
    wiredUserName({ error, data }) {
        if (data) {
            this.userName = data;
        } else if (error) {
            console.error('Error fetching user name:', error);
            this.userName = '';
        }
    }
    // Asset URLs
    get logoUrl() {
        return `${buhoAssets}/images/Logo.png`;
    }

    get searchIconUrl() {
        return `${buhoAssets}/images/magnifyingglassicon.svg`;
    }

    get commandIconUrl() {
        return `${buhoAssets}/images/commandicon.svg`;
    }

    get hamburgerIconUrl() {
        return `${buhoAssets}/images/hamburger-menu.svg`;
    }

    get userAvatar() {
        return `${buhoAssets}/images/lady image.png`;
    }

    handleMenuToggle() {
        // Dispatch event to parent container
        this.dispatchEvent(new CustomEvent('menutoggle'));
    }

    handleSearchInput(event) {
        this.searchQuery = event.target.value;
    }

    handleSearch(event) {
        if (event.key === 'Enter') {
            // Implement search functionality later
            console.log('Search for:', this.searchQuery);
        }
    }

    handleUserProfileClick() {
        // Implement user profile dropdown later
        console.log('User profile clicked');
    }
}