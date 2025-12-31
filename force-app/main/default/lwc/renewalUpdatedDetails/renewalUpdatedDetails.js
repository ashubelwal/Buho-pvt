import { LightningElement,track, api} from 'lwc';
import fetchQuoteDetails from '@salesforce/apex/PolicyRenewAlertController.fetchQuoteDetails';
import updatedQuoteToPolicy from '@salesforce/apex/PolicyRenewAlertController.updatedQuoteToPolicy';


export default class RenewalUpdatedDetails extends LightningElement {
    @track fetchPolicyDetails;
    updatedQuoteDetails = {};
    @track policyType;
    @track underwriter;
    policyId;
    @track submittedDetails = false;
    @track liabilityvalue;
    @track medicalValue;
    @track vehicleValue;
    @track isWaterCraft = true;

    get medicalOption() {
        console.log('this.policyType medical',this.policyType);
        console.log('this.underwriter medical',this.underwriter);
        if (this.policyType != undefined && this.policyType != 'Northbound' && this.policyType != 'Watercraft' && this.policyType != 'Automobile') {
            if (this.underwriter != undefined && this.underwriter == 'Chubb' && this.policyType == 'Motorcycle/Street Legal ATV') {
                return [{ 'label': '$10,000/$50,000', 'value': '10,000/50,000' },
                { 'label': '$15,000/$75,000', 'value': '15,000/75,000' },
                { 'label': '$20,000/$100,000', 'value': '20,000/100,000' }];
            }else{
                return [{ 'label': '$2,000/$10,000', 'value': '2,000/10,000' },
                { 'label': '$3,000/$15,000', 'value': '3,000/15,000' },
                { 'label': '$4,000/$20,000', 'value': '4,000/20,000' },
                { 'label': '$5,000/$25,000', 'value': '5,000/25,000' },
                { 'label': '$10,000/$50,000', 'value': '10,000/50,000' }];
            }

        }else if (this.policyType == 'Northbound') {
            return [{ 'label': '$5,000/$25,000', 'value': '5,000/25,000' }];

        }
        
        else if (this.policyType == 'Automobile' ) {

            if (this.underwriter == 'Chubb') {
                return [{ 'label': '$10,000/$50,000', 'value': '10,000/50,000' },
                { 'label': '$15,000/$75,000', 'value': '15,000/75,000' },
                { 'label': '$20,000/$100,000', 'value': '20,000/100,000' }];
            }
            else if (this.underwriter == 'Mapfre') {
                 return [{ 'label': '$2,000/$10,000', 'value': '2,000/10,000' },
                { 'label': '$3,000/$15,000', 'value': '3,000/15,000' },
                { 'label': '$4,000/$20,000', 'value': '4,000/20,000' },
                { 'label': '$5,000/$25,000', 'value': '5,000/25,000' },
                { 'label': '$10,000/$50,000', 'value': '10,000/50,000' }];
            } else {
                return [{ 'label': '$2,000/$10,000', 'value': '2,000/10,000' },
                { 'label': '$3,000/$15,000', 'value': '3,000/15,000' },
                { 'label': '$4,000/$20,000', 'value': '4,000/20,000' },
                { 'label': '$5,000/$25,000', 'value': '5,000/25,000' },
                { 'label': '$10,000/$50,000', 'value': '10,000/50,000' },
                { 'label': '$15,000/$75,000', 'value': '15,000/75,000' },
                { 'label': '$20,000/$100,000', 'value': '20,000/100,000' }];
            }

        } else if (this.policyType == 'Watercraft') {
            return [
                { 'label': '$50,000/$100,000', 'value': '50,000/100,000' },
                { 'label': '$100,000/$300,000', 'value': '100,000/300,000' },
                { 'label': '$250,000/$500,000', 'value': '250,000/500,000' }];
        }else{
            return [];
        }
    }

    get liabilityOption() {
        console.log('liabilityOption 1111');
        console.log('this.policyType liability',this.policyType);
        console.log('this.underwriter liability',this.underwriter);
        if (this.policyType != undefined && this.policyType != 'Northbound' && this.policyType != 'Watercraft' && this.policyType != 'Automobile') {
            console.log('liabilityOption 2222');
            if (this.underwriter == 'Chubb' && (this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'RV')) {
                return [
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$400,000', 'value': '400,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
            }else if(this.underwriter == 'Qualitas' && (this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'RV')){
                return [{ 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' },
                { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else if(this.underwriter == 'Mapfre' && (this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'RV')){
                
                return [
                    { 'label': '$100,000', 'value': '100,000' },
                    { 'label': '$200,000', 'value': '200,000' },
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    ];
            }

        } else if (this.policyType == 'Automobile') {
            console.log('liabilityOption 3333');
            if (this.underwriter && this.underwriter == 'Chubb') {
                return [
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$400,000', 'value': '400,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
            } if (this.underwriter && this.underwriter == 'Mapfre') {
                return [{ 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' }];
            } else {
                return [{ 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' },
                { 'label': '$1,000,000', 'value': '1,000,000' }];
            }


        } else if (this.policyType == 'Watercraft') {
            console.log('liabilityOption 4444');
            return [{ 'label': '$200,000', 'value': '200,000' },
            { 'label': '$400,000', 'value': '400,000' },
            { 'label': '$750,000', 'value': '750,000' }];
        } else if (this.policyType == 'Northbound') {
            console.log('liabilityOption 5555');
            return [{ 'label': '$100,000', 'value': '100,000' },
            { 'label': '$200,000', 'value': '200,000' },
            { 'label': '$300,000', 'value': '300,000' }];
        } else{
            console.log('liabilityOption else 666');
            return [];
        }
    }

    connectedCallback(){

        const currentUrl = window.location.href;
        const urlParams = new URLSearchParams(new URL(currentUrl).search);
        this.policyId = urlParams.get('policyId');
        console.log('Policy ID:', this.policyId);

        let quoteDetails = [];
        fetchQuoteDetails({'policyId': this.policyId}).then((data) => {
            console.log('Data-->',data);
            if(data != null){
                console.log('Inside If',data);
                data.map((item) => {
                    this.policyType = item?.Policy_Type_picklist__c != null ? item.Policy_Type_picklist__c : '';
                    this.underwriter = item?.Underwriter_picklist__c != null ? item.Underwriter_picklist__c : '';
                    quoteDetails.push({'label': 'End Date', 'value':item.Quote_c__r.End_Date_for_Coverage__c});
                    quoteDetails.push({'label': 'Start Date', 'value':item.Quote_c__r.Start_Date_for_Coverage__c});
                    quoteDetails.push({'label': 'Liability', 'value':item.Quote_c__r.Liability__c});
                    quoteDetails.push({'label': 'Term Days', 'value':item.Quote_c__r.Term_Days__c});
                    quoteDetails.push({'label': 'Net Premium', 'value':item.Quote_c__r.Net_Premium__c});
                    console.log('this.policyType : ',this.policyType);
                    if(this.policyType != 'Watercraft'){
                        console.log('Test------- ');
                        this.isWaterCraft = true;
                        quoteDetails.push({'label': 'Medical', 'value':item.Quote_c__r.Medical__c});
                        quoteDetails.push({'label': 'Vehicle Value', 'value':item.Quote_c__r.Vehicle_Value__c});
                    }else if(this.policyType == 'Watercraft'){
                        console.log('Test------- Watercraft');
                        this.isWaterCraft = false;
                    }

                    if(item.Auto_Renew_Confirmed__c == true && item?.Updated_Quote_Json__c != null){
                        console.log('Updated_Quote_Json__c',item?.Updated_Quote_Json__c);
                        let getUpdatedDetails = JSON.parse(item.Updated_Quote_Json__c);
                        this.vehicleValue = getUpdatedDetails.Vehicle_Value__c;
                        this.medicalValue = getUpdatedDetails.Medical__c;
                        this.liabilityvalue = getUpdatedDetails.Liability__c;
                    }

                });

                this.fetchPolicyDetails = quoteDetails;
                 console.log('this.fetchPolicyDetails',this.fetchPolicyDetails);
            }
        });
        console.log('this.policyType connectedCallback',this.policyType);
        console.log('this.underwriter connectedCallback',this.underwriter);
    }

    handleFieldChange(event){
        console.log('handleFieldChange--');
        console.log('name',event.target.name);
        console.log('Value',event.target.value);
        this.updatedQuoteDetails = {...this.updatedQuoteDetails, [event.target?.name] : event.target?.value};
        console.log('this.updatedQuoteDetails-->',this.updatedQuoteDetails);
    }

    handleSubmit(){
        console.log('handleSubmit--',this.updatedQuoteDetails);

        updatedQuoteToPolicy({'quoteJson': JSON.stringify(this.updatedQuoteDetails),'policyId': this.policyId });
        this.submittedDetails = true;
    }

}