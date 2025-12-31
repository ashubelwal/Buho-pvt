import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import LightningConfirm from "lightning/confirm";

import fetchContactDetails from '@salesforce/apex/AgentAppController.fetchContactDetails'

const columns = [
    { label: 'Label', fieldName: 'name' },
    { label: 'Website', fieldName: 'website', type: 'url' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Balance', fieldName: 'amount', type: 'currency' },
    { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
];

export default class AgentContactDetails extends NavigationMixin(LightningElement) {

    actionTypeDefault = true;
    actionTypeContactDetails = false;
    driverDrawer = false;
    vehicleDrawer = false;

    @track booleanVar = {
        policyDataStatus: false, quoteDataStatus: false, driverDataStatus: false, vehicleDataStatus: false, contactResult: false
    }

    contactDetails = {}

    stateContact = {}
    data = [{
        'name' : 'Atul Rai',
        'website' : 'www.salesforce.com',
        'amount' : '$300',
        'closeAt': '8545035946'
    }];
    columns = columns;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {        
        if (currentPageReference ) {
            let params = currentPageReference.state;            

            this.actionTypeDefault = Object.keys(params).length == 0 ? true : false;                  
            this.actionTypeContactDetails = params?.c__obj === 'contact' ? true : false;            

            this.stateContact = {
                'id': params?.c__id,                
                'obj': params?.c__obj,
                'actionType': params?.c__action
            }            
            // console.log('Wire Params: ', this.stateContact)            
            this.getContactDetails(this.stateContact.id);
            // console.log('calling from wire');
        } else {
            console.log('Params are not there')
        }
    }

    handleKeyUpSearch = (event) => {
        console.log(event.target.value);
    }

    // Get all contact details, pass contact id
    getContactDetails = (contactId) => { 
        // console.log('Id is', contactId, this.booleanVar.policyDataStatus)
        fetchContactDetails({"contactId": contactId}).
        then(result => {            
            if(result != 'Error') {
                this.contactDetails = JSON.parse(result)[0];
                
                // console.log(this.contactDetails)
                this.booleanVar.contactResult = true;               
                
                // Set Policy data into table 
                if( this.contactDetails?.Policies__r?.records != '') {
                    // console.log("1")                    
                    this.contactDetails?.Policies__r?.records.map(policy => {                        
                        // console.log('Term__c: ',policy.Term__c)
                        // console.log('Status: ',policy.Status_picklist__c)
                        if(policy.Status_picklist__c == 'Expired' || policy.Status_picklist__c == 'Updated' || policy.Status_picklist__c == 'Terminated') {                            
                            policy.EditBtn = false;
                            console.log('in the Edit if', policy.EditBtn)
                        } else {                            
                            policy.EditBtn = true;
                            console.log('in the Edit else', policy.EditBtn)
                        }

                        if(policy.Term__c == 'Daily') {
                            console.log('In the daily policy type')
                        }

                        if(policy.Status_picklist__c == 'Updated' || policy.Status_picklist__c == 'Terminated') {
                            policy.RenewBtn = true;
                            console.log('in the renew if', policy.RenewBtn)
                        } else {
                            policy.RenewBtn = false;
                            console.log('in the renew else', policy.RenewBtn)
                        }

                        if(policy.Status_picklist__c == 'Active') {
                            policy.TerminateBtn = true;
                            console.log('In the Terminate if', policy.TerminateBtn)
                        } else {
                            policy.TerminateBtn = false;
                            console.log('In the Terminate Else', policy.TerminateBtn)
                        }

                        console.log('Policy: ', policy)
                        this.booleanVar.policyDataStatus = true;
                    })
                } else {
                    this.contactDetails.Policies__r.records = [];
                    this.booleanVar.policyDataStatus = false;                    
                }

                // Set quoteData into table
                if( this.contactDetails?.Quotes__r?.records != '') {
                    console.log("2")                    
                    this.booleanVar.quoteDataStatus = true;
                } else {
                    this.contactDetails.Quotes__r.records = [];
                    this.booleanVar.quoteDataStatus = false;
                }

                // Set vehicleData into table 
                if( this.contactDetails?.Vehicle__r?.records != '') {
                    console.log("3")                    
                    this.booleanVar.vehicleDataStatus = true;
                } else {
                    this.contactDetails.Vehicle__r.records = [];
                    this.booleanVar.vehicleDataStatus = false;
                }

                // Set Drivers data into table 
                if( this.contactDetails?.Drivers__r?.records != '') {
                    console.log("4")                    
                    this.booleanVar.driverDataStatus = true;
                } else {
                    this.contactDetails.Drivers__r.records = [];
                    this.booleanVar.driverDataStatus = false;                    
                }

                if(this.contactDetails) {

                }
                                
                console.log('Contact details', this.booleanVar);
                console.log(this.contactDetails);
            } else {
                console.log('Getting some error');
            }         
        })
        .catch (error => {
            console.log('Error', error);
        })
    }

    // Create a new Driver, passing contact id and Driver Id
    handleNewDriver = (event) => {
        let state = {}
        console.log('handleNewDriver | ');
        let dataSets = event.target.dataset;         
        if( dataSets?.id != ' ' && dataSets?.actiontype != ' ' &&  dataSets?.obj != '') {            
            console.log('state')
            state = { c__obj : dataSets?.obj, c__action : dataSets?.actiontype, c__id : dataSets?.id }                        
            this.navigateTo('standard__navItemPage', 'Contact_Detail', state);             
            this.driverDrawer = !this.driverDrawer;
        } else {
            console.log('Error --> details are missing.')
        }
    }

    // New and Edit Vehicle, passing contact id and Vehicle Id
    handleNewVehicle = (event) => { 
        let state = {}
        console.log('handleNewDriver | ');
        let dataSets = event.target.dataset;         
        if( dataSets?.id != ' ' && dataSets?.actiontype != ' ' &&  dataSets?.obj != '') {            
            console.log('state')
            state = { c__obj : dataSets?.obj, c__action : dataSets?.actiontype, c__id : dataSets?.id }                        
            this.navigateTo('standard__navItemPage', 'Contact_Detail', state);             
            this.vehicleDrawer = !this.vehicleDrawer;            
        } else {
            console.log('Error --> details are missing.')
        }
    }

    navigateToPolicyEdit(event) {
        let customId = event.target.dataset.id ? event.target.dataset.id : event.currenTarget.dataset.id;
        let state = {
            c__policyId: customId,
            c__actionmode: 'edit'
        };
        this.navigateTo('standard__navItemPage', 'Policy_Edit_Renew', state);
    }

    navigateToPolicyRenew(event) {
        let customId = event.target.dataset.id ? event.target.dataset.id : event.currenTarget.dataset.id;
        let state = {
            c__policyId: customId,
            c__actionmode: 'renew'
        };
        this.navigateTo('standard__navItemPage', 'Policy_Edit_Renew', state);
    }

    handleOperations = (event) => {        
        let state = {}
        let dataSets = event.target.dataset;     

        if( dataSets?.id != ' ' && dataSets?.actiontype != ' ' &&  dataSets?.obj == 'contact') {            
            state = { c__obj : dataSets?.obj, c__action : dataSets?.actiontype, c__id : dataSets?.id }            
            this.navigateTo('standard__navItemPage', 'Contact_Detail', state);        
        } if( dataSets?.id != ' ' && dataSets?.actiontype != ' ' &&  dataSets?.obj == 'quote') {            
            state = { c__obj : dataSets?.obj, c__action : dataSets?.actiontype, c__id : dataSets?.id }            
            this.navigateTo('standard__navItemPage', 'Quote_Details', state);        
        } else {
            console.log('Error --> details are missing.')
        }    
    }

    async handleConfirmClick(event) {          
        const result = await LightningConfirm.open({
          message: "Are you sure you want to delete this?",
          variant: "default",
          label: "Delete a record"
        });      
        if (result) {          
          console.log('Got yes')
            // const evt = new ShowToastEvent({
            //   message: "We are Not able to delete the card.",
            //   variant: 'error',
            // });
            // this.dispatchEvent(evt);
        }      
    } 

    navigateTo = (type, apiName, state) => {        
        this[NavigationMixin.Navigate]({
            type: type,
            attributes: {
                apiName: apiName
            },
            state: state
        });
    }
    
    connectedCallback() {  

        // console.log('Params: ',this.stateContact.id)      
        if(this.stateContact.id) {
            // console.log('Calling')
            //this.getContactDetails(this.stateContact.id);        
        } else 
            console.log('Loading')
    }

    renderedCallback(){
        // if(this.stateContact.id && this.booleanVar.contactResult == false)
        //     console.log('Rendered') //this.getContactDetails(this.stateContact.id);            
        // else 
        //     console.log('Loading')
    }
}