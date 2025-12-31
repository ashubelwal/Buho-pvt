import { LightningElement } from 'lwc';

export default class Nc_showToastMessage extends LightningElement {

    connectedCallback() {
        // Check if URL contains ?c=true
        const url = new URL(window.location.href);
        const cValue = url.searchParams.get('c');
        console.log('URL param c:', cValue);

        if (cValue === 'true') {
            console.log('Inside connectedCallback: showing toast');
       

        console.log('connectedCallback finished');
            const toastDetail = {
                variant: 'info',
                title: 'Login Page',
                message: 'Please enter your username and password to Login.'
            }
            setTimeout(() => {
                this.handleToastEvent(toastDetail);
                console.log('Inside connectedCallback: toast shown');
            }, 1000);
        }
    }  
    
    handleToastEvent(toastData) {        
        console.log('CQ OUTPUT-- toastData', toastData);
        this.template.querySelector('c-custom-toast').showToast(toastData);
    }
}