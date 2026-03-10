import { LightningElement, wire, track } from 'lwc';
import getUserProfile from '@salesforce/apex/BuhoDashboardController.getUserProfile';

export default class Buhodb_settings extends LightningElement {

    @track userData = {};
    @track isLoading = true;
    @track errorMessage = '';

    @wire(getUserProfile)
    wiredProfile({ error, data }) {
        if (data) {
            this.userData = this._mapProfile(data);
            this.isLoading = false;
            this.errorMessage = '';
        } else if (error) {
            console.error('Error loading user profile:', JSON.stringify(error));
            this.errorMessage = 'Unable to load profile data. Please try again later.';
            this.isLoading = false;
        }
    }

    /** Map the raw User sObject into display-friendly key/values */
    _mapProfile(user) {
        const c = user.Contact || {};

        // Name
        const name = [user.FirstName, user.LastName].filter(Boolean).join(' ') || '—';

        // Email
        const email = user.Email || '—';

        // Phone — prefer Contact phone, fall back to User phone
        const phone = c.Phone || user.Phone || '—';

        // Address — build from Contact mailing fields
        const address = [
            c.MailingStreet,
            c.MailingCity,
            c.MailingState,
            c.MailingPostalCode,
            c.MailingCountry
        ].filter(Boolean).join(', ') || '—';

        // Date of Birth — prefer custom field, fall back to standard Birthdate
        const rawDob = c.Date_of_Birth__c || c.Birthdate;
        let dateOfBirth = '—';
        if (rawDob) {
            const d = new Date(rawDob + 'T00:00:00'); // ensure local date
            const mm = String(d.getMonth() + 1).padStart(2, '0');
            const dd = String(d.getDate()).padStart(2, '0');
            const yyyy = d.getFullYear();
            dateOfBirth = `${mm}/${dd}/${yyyy}`;
        }

        return { name, email, phone, address, dateOfBirth };
    }
}
