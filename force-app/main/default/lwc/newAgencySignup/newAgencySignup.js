import { LightningElement, track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addAgency from '@salesforce/apex/AgencyController.addAgency';
export default class NewAgencySignup extends LightningElement {
    
    @api cmpSource;
    @track formData = {
        checkboxValues: []
    }
    @track saveBtnDisabled = true;
    @track checkbox1;
    @track checkbox2;
    @track checkbox3;
    @track datasaved=false;

    handleCheckboxChange(event) {
        const { checked, dataset } = event.target;
        this.formData.checkboxValues = checked == true ? [...this.formData.checkboxValues, dataset.ptype] : this.formData.checkboxValues.filter(value => value != dataset.ptype)
        this.saveBtnDisabled = this.formData.checkboxValues.length == 0 ? true : false; 
        console.log(JSON.stringify(this.formData));      
    }

    handlePhoneNumberChange(event) {
        console.log(event);
        let phoneNumber = event.target.value.replace(/\D/g, ''); // Remove non-numeric characters
        if (phoneNumber.length > 0) {
            phoneNumber = phoneNumber.match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = !phoneNumber[2] ? phoneNumber[1] : phoneNumber[1] + '-' + phoneNumber[2] + (phoneNumber[3] ? '-' + phoneNumber[3] : '');
        }
    }

    handleAddAgency(event) {
        console.log('Add Agency clicked')
        const inputs = this.template.querySelectorAll('lightning-input, lightning-textarea');
        let allValid = true;
        
        

        inputs.forEach(input => {
            if (!input.checkValidity())
                allValid = false;
            input.reportValidity();                       
            this.formData[input.dataset.id] = input.value; // // Add input value to formData object 
        });

        

        if (allValid) {
            console.log('Data', JSON.stringify(this.formData));        
            console.log('Data size', this.formData.checkboxValues.length);
            addAgency({leadJSON:JSON.stringify(this.formData)})
            .then(result => {
                this.handleReset();
                console.log('Add agency', result);
                if(this.cmpSource == 'comm'){
                    this.showToastmethod('Success','Details submitted successfully.','Submitted');
                    this.dispatchEvent(new CloseActionScreenEvent());
    
                }else{
                    this.showToastEvent('Submitted', 'Details submitted successfully.', 'Success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch(err => {
                console.log(err);
                if(this.cmpSource == 'comm'){
                    this.showToastmethod('error',err.body.message,'Submission failed');
                    this.dispatchEvent(new CloseActionScreenEvent());
    
                }else{
                    this.showToastEvent('Contact creation failed',err.body.message, 'error');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }

            })          
            console.log('Data after clearing:', JSON.stringify(this.formData));        
            console.log('Data size:', this.formData.checkboxValues.length);
            
        } else {
            console.log('Please fill out all required fields correctly.');
        }
    }

    handleReset() {
        const checkboxinputs = this.template.querySelectorAll('lightning-input[type="checkbox"]');
    
        checkboxinputs.forEach(input => {
            console.log('Reached in for loop');
            input.checked = false; // Reset checkbox state
        });
        console.log('this.checkbox1',this.checkbox1);
        this.checkbox1=false;
        this.checkbox2=false;
        this.checkbox3=false;

        const inputs = this.template.querySelectorAll('lightning-input, lightning-textarea');
        this.formData = {
        checkboxValues: []
        };

        inputs.forEach(input => {
            input.value = ''; // Clear input value
            //input.reportValidity(); // Reset validity state
            this.formData[input.dataset.id] = ''; // Clear formData
        });
        this.saveBtnDisabled = true;
        this.datasaved=true;
        // Optionally, reset any other state or perform additional actions
        console.log('Form reset');
    }

    showToastmethod(variant,title,message) {
        this.template.querySelector('c-custom-toast').showToast(variant,title,message);
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