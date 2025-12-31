import { LightningElement ,track, api} from 'lwc';
import insertContactsFeature from '@salesforce/apex/AgentAppController.insertContactsFeature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactsFeature extends LightningElement {
    @track phoneValue;
    @api contacttype;
    showThanksPage = false;
    @track isLoading = false;
    contactData = {};

    get servicesType(){
        return [
            {label : 'Title' ,value : 'Title'},
            {label : 'Renewal' ,value : 'Renewal'},
            {label : 'Transfer' ,value : 'Transfer'},
            {label : 'Duplicate' ,value : 'Duplicate'},
        ];
    }

    get domesticType(){
        return [
            {label : 'Auto' ,value : 'Auto'},
            {label : 'Motorcycle' ,value : 'Motorcycle'},
            {label : 'Watercraft' ,value : 'Watercraft'},
            {label : 'Off-road' ,value : 'Off-road'},
            {label : 'Home' ,value : 'Home'},
            {label : 'Truck' ,value : 'Truck'},
            {label : 'Commercial' ,value : 'Commercial'},
        ];
    }

    get contactType() {
        return this.contacttype == 'Domestic Insurance' ? true : false;
    }
    

    handleInputChange(event){
        let name =event.target.name;
        let value = event.target.value;
        console.log('Name-->', name);
        console.log('Value-->', value);

        if (event.target.name == 'Phone') {
            this.formatNumber(event.target.value);
        }

        this.contactData = {...this.contactData, [name] : value};

        console.log('Contact Data-->', this.contactData);
    }

    handleSubmit(){
        
        if(this.contacttype == 'Domestic Insurance'){
            this.contactData = {...this.contactData, ['Type_of_Services__c'] : ''};
            this.contactData = {...this.contactData, ['Contact_Type__c'] : 'Domestic Insurance'};
        }else{
            this.contactData = {...this.contactData, ['Type_of_Domestic__c'] : ''};
            this.contactData = {...this.contactData, ['Contact_Type__c'] : 'DMV Service'};
        }

        console.log('Handle Submit -- Contact Data-->', this.contactData);
        console.log('Handle Submit -- Contact Data-->', JSON.stringify(this.contactData));
        let status = this.isInputValid('.quoteValidate');
        if(status){
            this.isLoading = true;
            console.log('Called apex Class method---');
            insertContactsFeature({'contactDetails': JSON.stringify(this.contactData)})
            .then((result) => {
                this.isLoading = false;
                if(result != 'False'){
                    const customEvent = new CustomEvent('contactcreation', {
                        detail: result
                    });
                    this.dispatchEvent(customEvent);
                }else{
                    let errEvt = new ShowToastEvent({
                        message: 'Error occurred while creating a record; this email address already exists; Kindly use a different email address.',
                        title: 'Error!',
                        variant: 'error',
                    });
                    this.dispatchEvent(errEvt);
                }
            })
        }
    }

    formatNumber(phone) {
        let cleaned = ('' + phone).replace(/\D/g, '');
        let match = cleaned.match(/^(\d{3})(\d{3})(\d{4,7})$/);
        if (match) {
            this.phoneValue = '(' + match[1] + ') ' + match[2] + '-' + match[3];
           
        }
    }

    isInputValid(className) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(className);
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    showToastEvent(label, message, variant) {
        const errMsg = new ShowToastEvent({
            title: label,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(errMsg);
    }


}