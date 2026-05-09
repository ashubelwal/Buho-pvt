import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const FIELDS = ['User.Name'];

export default class AgentHeader extends LightningElement {
    @api pageTitle = 'Dashboard';
    userName = 'Agent';
    userInitials = 'AG';

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.userInitials = this.getInitials(this.userName);
        } else if (error) {
            console.error('Error fetching user details:', error);
        }
    }

    getInitials(name) {
        if (!name) return 'AG';
        const parts = name.trim().split(' ');
        let initials = parts[0].substring(0, 1).toUpperCase();
        if (parts.length > 1) {
            initials += parts[parts.length - 1].substring(0, 1).toUpperCase();
        }
        return initials;
    }

    handleMenuToggle() {
        this.dispatchEvent(new CustomEvent('togglemenu'));
    }
}
