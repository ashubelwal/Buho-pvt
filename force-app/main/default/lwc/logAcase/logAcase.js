import { LightningElement , wire, api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import StyleCSS from '@salesforce/resourceUrl/mexinsurance_assets';
import getCaseTypeCustomSettings from '@salesforce/apex/Mex_LogACaseHandler.getCaseTypeCustomSettings';
import createLogACaseMethod from '@salesforce/apex/Mex_LogACaseHandler.createLogACaseMethod';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/Mex_LogACaseHandler.checkCommunityUserAndFetchDetails';
import fetchAllCaseRealtedContact from '@salesforce/apex/Mex_LogACaseHandler.fetchAllCaseRealtedContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LogAcase extends LightningElement {
    isComponentRendered = false;
    caseScreenName = 'New Case';
    handleRequireDescribleField = false;
    caseData = {};
    messageData = {};
    caseTypeOptions =[];
    isCommunityUser = false;
    allRealtedCase;
    IsError = false;
    @api leadData
   
    get isNewCaseScreen(){
         return this.caseScreenName == 'New Case';
    }
   
    @wire(checkCommunityUserAndFetchDetails)
    getCommunityUser({error, data}){
        if(data){
            this.isCommunityUser = data;
        }else if(error){
            console.log('erro', error);
        }
    }

    @wire(getCaseTypeCustomSettings)
    myCustomSettings({ error, data }){
        if(data){
            data.map(currentItem => {
                this.caseTypeOptions.push({'label':currentItem.label__c, 'value':currentItem.value__c});
            });
            let index = this.caseTypeOptions.findIndex(x => x.label == 'Other');
            if(index != this.caseTypeOptions.length - 1){
                let optionsLabel = this.caseTypeOptions.splice(index, 1);
                this.caseTypeOptions = this.caseTypeOptions.concat(optionsLabel);
            }
        }else if (error) {
            console.log('erro', error);
        }
    };

    @wire(fetchAllCaseRealtedContact)
    fetchAllRealtedCase({error, data}){
        if(data){
            this.allRealtedCase = data;
            console.log('this.allRealtedCase----',this.allRealtedCase);
        }else if(error){
            console.log('erro', error);
        }
    }

    renderedCallback() {
        if (!this.isComponentRendered) {
            Promise.all([
                loadStyle(this, StyleCSS + '/style.css')
            ]).then(() => {
                this.isComponentRendered = true;
            }).catch(error => {
                this.isComponentRendered = false;
            });
        }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validateField');
        console.log('----', inputFields);
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    connectedCallback() {
        this.dispatchEvent(new CustomEvent('openlogcasemodalsection',{detail: 'OnloadedComponent'}));
    }
    handleChange(event){
        let value = event.target.value;
        let name = event.target.name;
        this.caseData = {...this.caseData, [name]: value};
        if(name ==  'Case_Type__c' && value == 'Other'){
            this.handleRequireDescribleField = true;
        }else if(name ==  'Case_Type__c'){
           this.handleRequireDescribleField = false; 
        }
    }
    handleSubmit = async()=>{
        try{
            console.log('OUTPUT : ',this.caseData);
            console.log('OUTPUT leadData : ',this.leadData);
            let allvalid = this.isInputValid();
            let returnData;
            if(allvalid){
                let userEmail = !this.isCommunityUser ? this.leadData?.Email : '';
                console.log('OUTPUT :userEmail  ',userEmail);
                await createLogACaseMethod({'caseType': this.caseData.Case_Type__c, 'caseDiscription': this.caseData.Discription, 'userEmail' : userEmail?userEmail:''}).then(result => {
                    returnData = result;
                    console.log('---returnData--', returnData);
                    if(returnData.status == 'success'){
                        this.messageData = {'message': 'Case is created. One of the support team member will connect with you soon.', 'messageType': 'success'};
                        this.IsError = false;
                        this.showToastMessage(this.messageData.message,this.messageData.messageType);
                        this.dispatchEvent(new CustomEvent('openlogcasemodalsection',{detail: 'quickClose'}));
                    }else if(returnData.status == 'error'){
                        this.messageData = {'message': error, 'messageType': 'error'};
                        this.showToastMessage(this.messageData.message,this.messageData.messageType);
                    }
                }).catch(error => {
                    this.messageData = {'message': error, 'messageType': 'error'};
                    this.showToastMessage(this.messageData.message,this.messageData.messageType);
                });
            
            
            
            }else{
                this.showToastMessage('Please fill required fields while logging a case.','error');
            }
        }catch(err){
            console.log(err);
        }
        
    }
   
    handleCreateCase(){
        console.log('OUTPUT : ',this.IsError );
        this.IsError = true;
        this.dispatchEvent(new CustomEvent('openlogcasemodalsection',{detail: 'delayClose'}));
    }
    cancle(){
        this.IsError = false;
        this.dispatchEvent(new CustomEvent('openlogcasemodalsection',{detail: 'quickClose'}));
    }
    showToastMessage(msg,variant){
        const evt = new ShowToastEvent({
            message: msg,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}