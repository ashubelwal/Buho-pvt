import { LightningElement, api, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import FIRSTNAME from '@salesforce/schema/User.FirstName';
import LASTNAME from '@salesforce/schema/User.LastName';
import EMAIL from '@salesforce/schema/User.Email';
import USERNAME from '@salesforce/schema/User.Username';
import MOBILE from '@salesforce/schema/User.MobilePhone';
import ALIAS from '@salesforce/schema/User.Alias';
import TIMEZONESIDKEY from '@salesforce/schema/User.TimeZoneSidKey';
import LOCALSIDKEY from '@salesforce/schema/User.LocaleSidKey';
import EMAILENCODEINGKEY from '@salesforce/schema/User.EmailEncodingKey';
import PROFILEID from '@salesforce/schema/User.ProfileId';
import LanguageLocaleKey from '@salesforce/schema/User.LanguageLocaleKey';


import CompanyName from '@salesforce/schema/User.CompanyName';
import updateMdtData from '@salesforce/apex/AgencyController.updateUserData';
import getCustomSettings from '@salesforce/apex/AgencyController.getUserData';
import getAffiliateCode from '@salesforce/apex/AgencyController.getAffiliateCode'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';




export default class PartnerProfile extends LightningElement {
   @api recordId = USER_ID;
   @api objectApiName;
   @track isLoading = false;
   @track isDisabled = true;
    editableText = 'No affiliate Code.Please contact your administrator';
    noneditableText = 'No affiliate Code.Please contact your administrator';


   fields = [FIRSTNAME, LASTNAME, EMAIL, CompanyName, ALIAS, LOCALSIDKEY, EMAILENCODEINGKEY, PROFILEID, LanguageLocaleKey, MOBILE, USERNAME];
  
   @wire(getAffiliateCode, { 'UserId': USER_ID })
   affiliateRecord({ data, error }) {
       if (data) {
           const affiliateCode = data[0]?.Affiliate_Id__c;
           if (affiliateCode !== undefined) {
               console.log('Affiliate Code',data[0]?.Affiliate_Id__c);
               let currentUrl = window.location.origin;
               let urlData = `${currentUrl}/affiliate?code=${affiliateCode}&frame=true`;
               this.editableText = urlData
               this.noneditableText = `${currentUrl}/affiliate?code=${affiliateCode}`;
               console.log('Text value', this.editableText);
               console.log('Test vslue', this.noneditableText);
           }
       }
       else if (error) {
           console.log('Error in wire method', error);
       }
       else {
           console.log('Error in wire method 2');


       }
   };
      
   @wire(getCustomSettings, { 'recordId': USER_ID})
   metadatarecord;
  
   get userTypeAgency(){
       return this.metadatarecord?.data?.User_Type__c == 'Agency' ? true : false;
   }


   get primaryColor() {
       console.log('metadatarecord',this.metadatarecord);
       return this.metadatarecord.data.Primary_Color__c;
   }


   get partnerName() {
       console.log('metadatarecord',this.metadatarecord);
       return this.metadatarecord.data.Partner_Name__c;
   }


   get email() {
       console.log('metadatarecord',this.metadatarecord);
       return this.metadatarecord.data.Partner_email__c;
   }


   get url() {
       console.log('metadatarecord',this.metadatarecord);
       return this.metadatarecord.data.Logo_URL__c;
   }


   get PartnerId() {
       console.log('metadatarecord',this.metadatarecord);
       return this.metadatarecord.data.Partner_Id__c;
   }




   handleMDTFieldHandler(event){
       console.log('event Name',event.target.name);
       console.log('event Value',event.target.value);
       this.isDisabled = false;
       this.mdtData = {...this.mdtData,[event.target.name]: event.target.value}
       console.log('this.mdtData',this.mdtData);
   }


    handleUpdateMdtClick(){
       this.isLoading = true;
       console.log('handleUpdateMdtClick mdtData',this.mdtData);
        updateMdtData({'JsonData':JSON.stringify(this.mdtData),'recordId': USER_ID }).then((item) => {
           console.log('item',item);
           this.isLoading = false;
           if(item != null && item == 'Success'){
               console.log('IN IFF-----');
               this.isDisabled = true;
               let errEvt = new ShowToastEvent({
                   message: 'Cannot generate PDF for the current policy.',
                   title: 'Something wrong happened while generating PDF!',
                   variant: 'error',
               });
               this.dispatchEvent(errEvt);
               this.showToastEvent('Record Updated', 'Record has been Updated', 'Success');
               refreshApex(this.metadatarecord);
               console.log('Called refresh apex-----');
           }else{
               console.log('IN ELSEEE-----');
               this.showToastEvent('Record Updation Error', 'There is an error while updating the record', 'Error');
           }
       })
   }


   showToastEvent(label, message, variant) {
       console.log('Called in ShowToastEvent-->>');
       const errMsg = new ShowToastEvent({
           title: label,
           message: message,
           variant: variant,
       });
       this.dispatchEvent(errMsg);
   }


   handleSubmit(event) {
       event.preventDefault(); // stop the form from submitting
       const fields = event.detail.fields;
       //fields.LastName = 'My Custom Last Name'; // modify a field
       this.template.querySelector('lightning-record-form').submit(fields);
   }


   handleFrameButtonClick(event) {
       console.log(event.target.name);
       console.log('Affiliate Record', this.affiliateRecord);
       console.log('Editable text ', this.editableText);
       console.log('non editable text', this.noneditableText);
       if (event.target.name == 'with_frame') {
           if (this.affiliateRecord) {
              
                   navigator.clipboard.writeText
                       (`${this.editableText}`);
                   this.showToastmethod('success', 'Affiliate link copied.', 'Affiliate Code');
              
           }


       } else if(event.target.name == 'without_frame'){
          
                   navigator.clipboard.writeText
                       (`${this.noneditableText}`);
                   this.showToastmethod('success', 'Affiliate link copied.', 'Affiliate Code');
       }
      
   }


   handleUrlInput(event) {
       console.log('Editable text ', this.editableText);      
       this.editableText = event.target.value;
   }


   showToastmethod(variant, title, message) {
       this.template.querySelector('c-custom-toast').showToast(variant, title, message);
   }
}