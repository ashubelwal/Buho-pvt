import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteDataToContinueQuote from '@salesforce/apex/Mex_NewLeadProcess.getQuoteDataToContinueQuote';
import Continuequoting from '@salesforce/label/c.TR_Continue_Quoting';

export default class Mex_ContinueQuote extends NavigationMixin(LightningElement) {
     label = {
        Continuequoting,
    };
    @api recordId;
    @api PageName;
    policyType;
    btnDisabled = false;
    showNorthbound = false;

    async connectedCallback() {
        await this.fetchQuoteData();
    }

    navigateToLightningComponent() {
        sessionStorage.setItem('continueQuoteID', this.recordId)
        sessionStorage.setItem('isContinueQuote', true);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: this.PageName,
                recordId: this.recordId
            }
        });
    }

    async fetchQuoteData() {
        let data = await getQuoteDataToContinueQuote({ 'quoteId': this.recordId });

        if (data.status == 'success') {
            this.btnDisabled = data.quoteRecord?.Quote_Status__c == 'Draft' ? false : true;
            this.policyType = data.quoteRecord?.Policy_Type_picklist__c;
        }
        console.log('policy Type-> '+this.policyType);
        if(this.policyType == 'Northbound'){
            this.showNorthbound = true;
        }
    }

    redirectToQuickQuote() {
        this.PageName = this.policyType == 'Northbound' ? 'Northbound__c' : this.policyType == 'Watercraft' ? 'Watercraft__c' : this.policyType == 'RV' ? 'rv__c' : this.policyType == 'Motorcycle/Street Legal ATV' ? 'motorcycle__c' : 'automobile__c';
        this.navigateToLightningComponent();
    }
}