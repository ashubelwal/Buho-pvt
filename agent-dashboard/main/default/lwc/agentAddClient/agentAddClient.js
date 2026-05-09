import { LightningElement, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

export default class AgentAddClient extends LightningElement {

    @api contactId; // agency contact id, passed from parent

    @track isCreating = false;
    @track newClient = {
        firstName: '', lastName: '', phone: '',
        email: '', street: '', city: '',
        state: '', postalCode: '', country: ''
    };

    get isCreateDisabled() {
        return this.isCreating || !this.newClient.firstName || !this.newClient.lastName;
    }

    handleNewClientInput(event) {
        const field = event.target.dataset.field;
        this.newClient = { ...this.newClient, [field]: event.target.value };
    }

    handleCreateClient() {
        const { firstName, lastName, phone, email, street, city, state, postalCode, country } = this.newClient;
        if (!firstName || !lastName) return;

        this.isCreating = true;

        const fields = {
            FirstName: firstName,
            LastName: lastName,
            ...(phone      && { Phone: phone }),
            ...(email      && { Email: email }),
            ...(street     && { MailingStreet: street }),
            ...(city       && { MailingCity: city }),
            ...(state      && { MailingState: state }),
            ...(postalCode && { MailingPostalCode: postalCode }),
            ...(country    && { MailingCountry: country }),
            ...(this.contactId && { Agency__c: this.contactId })
        };

        createRecord({ apiName: 'Contact', fields })
            .then(result => {
                console.log('Contact created', result.id);
                this.isCreating = false;
                // notify parent: record created
                this.dispatchEvent(new CustomEvent('clientcreated', {
                    detail: { id: result.id },
                    bubbles: true
                }));
            })
            .catch(err => {
                console.error('Create contact error', err);
                this.isCreating = false;
            });
    }

    closeCreateModal() {
        this.dispatchEvent(new CustomEvent('closemodal', { bubbles: true }));
    }

    stopPropagation(event) { event.stopPropagation(); }
}