import { LightningElement , api} from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import convertAgencyToUser from '@salesforce/apex/AgencyController.convertAgencyToUser';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class MyApp extends LightningElement {
    
    @api recordId;

    // connectedCallback(){
    //     this.handleConfirmClick();
    // }
      
    handleClick(){
        this.handleConfirmClick();
    }
    
    handleConfirmClick(){
        if(this.recordId){
            convertAgencyToUser({recordId:this.recordId})
            .then(result =>{
                if(result === 'Success'){
                    
                    if(this.cmpSource == 'comm'){
                        this.showToastmethod('Success','Agent contact is scuccesfully created.','Contact created');
                        this.dispatchEvent(new CloseActionScreenEvent());
                        
        
                    }else{
                        this.showToastEvent('Contact created', 'Agent contact is scuccesfully created.', 'Success');
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                }
                else{
                    if(this.cmpSource == 'comm'){
                        this.showToastmethod('error','Error occur while creating contact.','Contact creation failed');
                        this.dispatchEvent(new CloseActionScreenEvent());
        
                    }else{
                        this.showToastEvent('Contact creation failed', 'Error occur while creating contact.', 'error');
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                }
            })
            .catch((error)=>{
                if(this.cmpSource == 'comm'){
                    this.showToastmethod('error','Duplicate username','Contact creation failed');
                    this.dispatchEvent(new CloseActionScreenEvent());
    
                }else{
                    this.showToastEvent('Contact creation failed', 'Duplicate username', 'error');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
           }else{
               this.handleError('No record Id found.');
           }
    }


    handleRejectClick(){
        this.dispatchEvent(new CloseActionScreenEvent());
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