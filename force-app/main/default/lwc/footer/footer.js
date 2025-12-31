import { LightningElement, api, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getCustomData from '@salesforce/apex/AgencyController.getUserData';

export default class Footer extends LightningElement {
    @api recordId;

    @track primaryColor = '#eee';

    @wire(getCustomData, { 'recordId': USER_ID})
    customMetaData({data,error}){
        if(data){        
            if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
                this.primaryColor = `background-color: ${data.Primary_Color__c};`;
            }

            // if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
            //     this.partnerName = data.Partner_Name__c;
            // }

            // if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
            //     this.partnerId = data.Partner_Id__c;
            // }

            // if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
            //     this.partnerEmail = data.Partner_email__c;
            // }

            // if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
            //     this.getUrl = data.Logo_URL__c;
            // }
            
            // console.log('primaryColor--->',this.primaryColor);
            // console.log('getUrl--->',this.getUrl);
           
        }else{
            console.log('error',error);
        }
    }
}