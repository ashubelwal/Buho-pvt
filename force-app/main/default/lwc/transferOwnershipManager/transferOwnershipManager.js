import { LightningElement, track, wire, api } from 'lwc';
import getClientContact from '@salesforce/apex/TransferOwnershipManagerController.getClientContact';
import trasferOnwership from '@salesforce/apex/TransferOwnershipManagerController.trasferOnwership';
import getUserData from '@salesforce/apex/TransferOwnershipManagerController.getUserData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TransferOwnershipManager extends LightningElement {

    @api userId;
    @api contactId;
    @track isLoading = true;
    @track clientEmail;
    @api loggedInUserEmail;
    loggedInUserName;
    @track clientData;
    @api closeModalMethod;
    @api cmpSource;
    connectedCallback() {
        console.log('contactId::::', this.contactId);
        console.log('Logged in User ID:', this.userId);

        if (this.contactId) {
            getClientContact({ 'contactId': this.contactId }).then((result) => {
                this.isLoading = false;
                console.log('result:::', result);
                const data = JSON.parse(JSON.stringify(result));
                this.clientData = JSON.parse(data);
                console.log('clientData:::', this.clientData);
            })
        }

        if(this.userId) {
            getUserData({ 'userId': this.userId }).then((result) => {
                const data = JSON.parse(JSON.stringify(result));
                this.loggedInUserName = JSON.parse(data).Name;
                this.loggedInUserEmail = JSON.parse(data).Email;
            })
        }
    }

    handleEmailChange(event) {
        this.clientEmail = event.target.value;
        console.log('clientData:::::::', this.clientData);
    }
    
    @api
    transferOwnershipHandler() {
        console.log('contactId::',this.contactId);
        console.log('clientEmail::',this.clientEmail);
        console.log('userId::', this.userId);
        
        this.isLoading = true;

        let oldAgencyEmail = this.clientData.Agency__c != null ? this.clientData.Agency__r.Email : this.clientData.Agent__r.Email;
        let oldAgencyName = this.clientData.Agency__c != null ? this.clientData.Agency__r.Name : this.clientData.Agent__r.Name;

        trasferOnwership({ 'clientId': this.contactId, 'clientEmail': this.clientEmail, 'contactOwnerId': this.userId, 'oldAgencyEmail':oldAgencyEmail, 'oldAgencyName': oldAgencyName })
            .then((data) => {
                console.log('Data:: Trasnfer:',data);
                const message = {
                    type: 'success',
                    title: 'Ownership Transfer Successful',
                    message: 'Ownership successfully transferred to new owner.'
                };
                this.dispatchEvent(new CustomEvent('toast', {
                    detail: message
                }));
                this.isLoading = false;
                this.callParentCloseModalMethod();
            })
            .catch((error) => {
                console.log('Error Message', error);
                const message = {
                    type: 'error',
                    title: error.body.message,
                    message: 'Ownership not transferred.'
                };
                this.dispatchEvent(new CustomEvent('toast', {
                    detail: message
                }));
                this.isLoading = false;
            });
        
        
    }

    callParentCloseModalMethod() {
        const event = new CustomEvent('closemodal', {
            detail: { message: 'Modal closed by child component' },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);
    }

    showToastmethod(variant, title, message) {
        this.template.querySelector('c-custom-toast').showToast(variant, title, message);
    }
}