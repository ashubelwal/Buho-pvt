import { LightningElement, track } from 'lwc';
import activateUser from '@salesforce/apex/SiteUserController.activateUser';
export default class Nc_activateUser extends LightningElement {
    @track email = '';
    @track spinner = false;

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    connectedCallback() {
        this.spinner = true;
    }

    handleClick() {
        if (this.email) {
            this.spinner = false;
            activateUser({ email: this.email })
                .then(result => {                    
                    // this.showToast('Success', 'Account activated successfully!', 'success'); 
                    console.log('OUTPUT result: ',JSON.stringify(result));
                    this.email = '';
                    this.spinner = true;
                    this.template.querySelector('c-custom-toast').showToast({variant:'success', title: 'Success', message: 'Account activated successfully! Check your mail.'});                    
                    // this.dispatchEvent(new CustomEvent('toastevent', { detail: {variant:'success', title: 'Success', message: 'Account activated successfully! Check your mail.'} }));
                })
                .catch(error => { 
                    console.error('Activation error:', error);
                    console.error('Activation error:', error?.body?.message);
                    this.spinner = true;
                    this.template.querySelector('c-custom-toast').showToast({variant:'error', title: 'Error', message: error?.body?.message}); 
                    // this.dispatchEvent(new CustomEvent('toastevent', { detail: {variant:'error', title: 'Error', message: error?.body?.message} }));
                });
        } else { 
            this.spinner = true;
            this.template.querySelector('c-custom-toast').showToast({variant:'error', title: 'Error', message: 'Enter a coorect email.'}); 
            //this.dispatchEvent(new CustomEvent('toastevent', { detail: {variant:'error', title: 'Error', message: 'Please enter an email.'} }));
        }

    }
}