import { LightningElement,api,track } from 'lwc';
import getDependentMap from '@salesforce/apex/Mex_ValidateFormData.getDependentMapWithTranslations';
import getPicklistValues from '@salesforce/apex/Mex_ValidateFormData.getPicklistValues';
import WhatisyourTripDestination from '@salesforce/label/c.TR_What_is_your_trip_destination';
import Whatisthetrippurposetrip from '@salesforce/label/c.TR_What_is_the_purpose_of_trip';
import Newsletter from '@salesforce/label/c.TR_Newsletter';

export default class AgentTermAgreement extends LightningElement {
    label = {
        WhatisyourTripDestination,Whatisthetrippurposetrip,Newsletter
    };
    
    @api termPolicyType;
    usDestinations;
    tripPurposes;
    termsAndAgreement = {};
    @api isAgentPortal = false;
    
    get tripDestination() {
        return this.termsAndAgreement?.What_is_your_trip_destination_in_US__c != undefined ? this.termsAndAgreement.What_is_your_trip_destination_in_US__c : '';
    }

    get tripPurpose() {
        return this.termsAndAgreement?.What_is_the_purpose_of_trip__c != undefined ? this.termsAndAgreement.What_is_the_purpose_of_trip__c : '';
    }

    get Newsletter() {
        
    }

    async connectedCallback() {
        console.log('---call concetedcallback---');
        this.getDependentPicklistValues('Policy__c', 'Policy_Type_picklist__c', 'What_is_your_trip_destination_in_US__c');
        if(this.termPolicyType == "RV"){
            this.tripPurposes = [{label : 'Vacation', value: 'Vacation'},{label: 'Pleasure', value: 'Pleasure'}];
        }else{
            this.tripPurposes = [{label : 'Business', value: 'Business'},{label: 'Pleasure', value: 'Pleasure'}];
        }
        
    }

    getDependentPicklistValues(objectName, controllingField, dependentField) {
        getDependentMap({ "objectApiName": objectName, "contrfieldApiName": controllingField, "depfieldApiName": dependentField }).then((result) => {
            console.log("this is getdepentedntfetchPicklistcall from apex result" + JSON.stringify(result));
            let storeResponse = result;
            console.log('policyType--', this.termPolicyType);
            console.log('option--', storeResponse);
            if (this.termPolicyType != null && this.termPolicyType != undefined && storeResponse && storeResponse[this.termPolicyType] != null) {

                var options = [];
                let relevantControllingField = storeResponse[this.termPolicyType];
                 for (const property in relevantControllingField) {
                    /**logic here !*/
                    options.push({
                        'label': relevantControllingField[property],
                        'value': property
                    })
                 }
                this.usDestinations = options;
                console.log('---this is after filter--', this.usDestinations);
            }

        });
    }

    handleChange(event) {
        if (event.target?.name == 'Newsletter__c') {
            this.termsAndAgreement = { ...this.termsAndAgreement, [event.target?.name]: event.target?.checked };
        }
        else {
            this.termsAndAgreement = { ...this.termsAndAgreement, [event.target?.name]: event.target?.value };
        }
        console.log('Data in input change of term and agreement', this.termsAndAgreement);
        
    }

    handleDataUpdate() {
        console.log('Information update');
        const senddata = new CustomEvent('destinationinformation', {
            detail: this.termsAndAgreement,
        });
        this.dispatchEvent(senddata);
    }

}