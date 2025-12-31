import { LightningElement, wire, track } from 'lwc';
import getUserDetails from '@salesforce/apex/UserProfileController.getCurrentUserInfo';

export default class Nc_customerProfile extends LightningElement {
    @track userData = {};
    selectedTab = 'profile';
    isAnimating = false;

    get getName() {
        return this.userData?.Name || 'N/A';
    }

    get getEmail() {
        return this.userData?.Contact?.Email || 'N/A';
    }

    get getPhone() {
        return this.userData?.Contact?.Phone || 'N/A';
    }

    get getDOB() {
        return this.userData?.Contact?.Date_of_Birth__c || 'N/A';
    }

    get getStreet() {
        return this.userData?.Contact?.Street__c || 'N/A';
    }

    get getCity() {
        return this.userData?.Contact?.City__c || 'N/A';
    }

    get getState() {
        return this.userData?.Contact?.State__c || 'N/A';
    }

    get getPostalCode() {
        return this.userData?.Contact?.Postal_Code__c || 'N/A';
    }

    get getCountry() {
        return this.userData?.Contact?.Country__c || 'N/A';
    }

    get getLocation() {
        const city = this.getCity;
        const country = this.getCountry;
        return `${city}, ${country}`;
    }

    get getAgency() {
        return this.userData?.Contact?.Agency__r?.Name || 'N/A';
    }

    get isProfileTab() {
        return this.selectedTab === 'profile';
    }

    get isPaymentTab() {
        return this.selectedTab === 'payment';
    }

    get isTeamTab() {
        return this.selectedTab === 'team';
    }

    get tabContentClass() {
        return `tab-content ${this.isAnimating ? 'fade-out' : 'fade-in'}`;
    }


    @wire(getUserDetails)
    wiredUser({ error, data }) {
        if (data) {
            this.userData = data;
            console.log('User data: ', JSON.stringify(this.userData));
        } else if (error) {
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'We are not able to get profile details.' } }));
            console.error('Error fetching user data: ', error);
        }
    }

    handleTabClick(event) {
        const clickedTab = event.currentTarget.dataset.tab;        

        if (clickedTab === this.selectedTab) return;

        this.isAnimating = true;

        if(clickedTab === 'team') {
            window.location.href = '/secur/logout.jsp';
        }

        setTimeout(() => {
            this.selectedTab = clickedTab;

            // Wait another frame before fade-in
            requestAnimationFrame(() => {
                this.isAnimating = false;
            });
        }, 300); // Match with your CSS transition duration

        // Update active class in sidebar
        const allTabs = this.template.querySelectorAll('.slds-nav-vertical__item');
        allTabs.forEach(tab => tab.classList.remove('slds-is-active'));
        event.currentTarget.classList.add('slds-is-active');
    }
}