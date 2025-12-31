import { LightningElement, track, wire, api } from 'lwc';
import convertLeadToAgent from '@salesforce/apex/AgencyController.convertLeadToAgent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class AgentManager extends LightningElement {


    @api recordId;
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track phone = '';
    @track isLoading = false;
    @track UserTypeValue = '';

    get UserTypeoptions() {
        return [
            { label: 'Internal', value: 'Internal' },
            { label: 'External', value: 'External' }
        ];
    }

    handleInputChange(event) {
        console.log('recordId::::', this.recordId);
        const field = event.target.dataset.id;
        if(field == 'User_Type__c'){
            this.UserTypeValue = event.target.value;
        }else{
            this[field] = event.target.value;
        }
        
        console.log('field::::', this.field);
    }


    handleSubmit() {
        let phonePattern = /^[0-9]*$/;
        let phoneInput = this.template.querySelector('lightning-input[data-id="phone"]');
        if (this.validateFields()) {
            if (!this.phone.match(phonePattern)) {
                this.showToast('Error', 'Please enter a valid phone number with only digits.', 'error');
                return;
            }
            this.isLoading = true;
            convertLeadToAgent({
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                phone: this.phone,
                agencyId: this.recordId,
                usertype : this.UserTypeValue
            })
                .then(result => {
                    console.log('result:::',result);
                    if (result == 'Exist') {
                        this.showToast('Error', 'Portal User already exist for this Email/Contact', 'error');
                    } else {
                        if (result == 'Success') {
                            this.isLoading = false;
                            this.showToast('Success', 'successfully created', 'success');
                            this.dispatchEvent(new CloseActionScreenEvent());
                        } else {
                            this.showToast('Error', 'Something wrong with the data!', 'error');
                        }
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    this.isLoading = false;
                    this.showToast('Error', 'Something wrong with the data!', 'error');
                    console.error('Error:', error);
                });
        } else {
            this.isLoading = false;
        }
    }


    validateFields() {
        const allValid = [...this.template.querySelectorAll('.validateFields')]
            .filter(input => input.required)
            .reduce((validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }, true);


        if (!allValid) {
            this.showToast('Error', 'Please fill all required fields.', 'error');
        }
        return allValid;
    }


    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvent);
    }


}