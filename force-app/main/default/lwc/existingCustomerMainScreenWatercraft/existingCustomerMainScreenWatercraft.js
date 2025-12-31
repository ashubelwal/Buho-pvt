import {api, LightningElement } from 'lwc';
import getQuoteDataToContinueQuote from '@salesforce/apex/Mex_NewLeadProcess.getQuoteDataToContinueQuote';
import letstacklepayment from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';

export default class ExistingCustomerMainScreenWatercraft extends LightningElement {
     label = {
        letstacklepayment,
    };
    @api isCommunityUser;
    @api watercraftData;
    @api driverData;
    @api towedUnitData;
    @api policyType;
    screenname;
    @api customerRecord = {};
    policyName;
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    async connectedCallback() {
        this.isOpenLogCaseModal = false;
        console.log('---watercraftData--existing-', this.watercraftData);
        let recordId = sessionStorage.getItem('continueQuoteID');
        let isDataFetchedForContinueQuote = sessionStorage.getItem('isContinueQuote');
        if ((recordId != '' && recordId != null) && (isDataFetchedForContinueQuote == true || isDataFetchedForContinueQuote == 'true')) {
            await this.fetchQuoteData(recordId);
        } else {
            this.customerRecord = { ...this.customerRecord, ['policyType']: this.policyType };
        }
        this.screenname = 'watercraftDetails';


    }

    async fetchQuoteData(recordId) {
        let data = await getQuoteDataToContinueQuote({ 'quoteId': recordId });
        console.log('---getQuoteDataToContinueQuote---'+JSON.stringify(data, null, 4));
      

        if (data.status == 'success') {
            // sessionStorage.removeItem('continueQuoteID');
            const { term__c, ...rest } = data.quoteRecord;
            this.customerRecord = { ...this.customerRecord, ...data.userRecord };
            this.customerRecord = { ...this.customerRecord, ['policyType']: data.quoteRecord?.Policy_Type_picklist__c };
            this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord.quoteRecord, ...rest, ['Term__c']: term__c != undefined ? term__c : 'Daily' } };
            if (data.watercraftRecord != undefined) {
                this.customerRecord = { ...this.customerRecord, ['watercraftData']: { ...this.customerRecord.watercraftData, ...data.watercraftRecord[0]}};
            }
            this.customerRecord = { ...this.customerRecord, ['DriverData']: data.driverRecord?.length > 0 ? [...data.driverRecord] : [] };
            this.policyType = data.quoteRecord?.Policy_Type_picklist__c;
            
        }
        sessionStorage.setItem('isContinueQuote', false);
    }

    handleCustomerRecordChange(e) {
        this.customerRecord = { ...this.customerRecord, ...e.detail };
        console.log('event :::: ', JSON.stringify(this.customerRecord, null, 4));
    }
    @api openModalLogCase(event){
        console.log('event.detail--', event.detail)
        if(event.detail == 'delayClose'){
            this.isOpenLogCaseModal = true;
        }else if(event.detail == 'quickClose'){
            this.isShowCaseLog = false;
        }
        
    }
    get isWatercraftDetails() {
        return this.screenname == 'watercraftDetails';
    }
    get isTermOptions() {
        return this.screenname == 'termOptions';
    }
    get communityUser() {
        return this.isCommunityUser != null ? this.isCommunityUser : false;
    }
    get isQuickQuote() {
        return this.screenname == 'quickQuote';
    }

    get isReviewVehicle() {
        return this.screenname == 'reviewWatercraft';
    }
    get isDriverDetail() {
        return this.screenname == 'driverRegistration';
    }

    get isVerifyEditQuickQuote() {
        return this.screenname == 'verifyWatercraft';
    }

    get isInsurenceLegalTerm() {
        return this.screenname == 'insuranceLegalTerm';
    }

    get isPaymentDetail() {
        return this.screenname == 'paymentDetail';
    }

    get isPolicyDetail() {
        return this.screenname == 'policyDetail';
    }





    changeNextScreen = (val) => {
        if (this.screenname == 'watercraftDetails') {
            this.screenname = 'termOptions';
        } else if (this.screenname == 'termOptions') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'quickQuote') {
            this.screenname = 'reviewWatercraft';
        } else if (this.screenname == 'reviewWatercraft') {
            this.screenname = 'driverRegistration';
        } else if (this.screenname == 'driverRegistration') {
            this.screenname = 'verifyWatercraft';
        } else if (this.screenname == 'verifyWatercraft') {
            this.screenname = 'insuranceLegalTerm';
        } else if (this.screenname == 'insuranceLegalTerm') {
            this.screenname = 'paymentDetail';
        } else if (this.screenname == 'paymentDetail') {
            this.policyName = val;
            this.screenname = 'policyDetail';
        }
    }
    @api
    showLogaCase(event){
        this.isShowCaseLog = true;
        setTimeout(() => {
            if(!this.isOpenLogCaseModal){
                this.isShowCaseLog = false;
            }
          }, 7800);
    }
    changePrevScreen = () => {
        console.log('---prevScreen--', this.screenname);
        if (this.screenname == 'watercraftDetails') {
        } else if (this.screenname == 'termOptions') {
            this.screenname = 'watercraftDetails';
        } else if (this.screenname == 'quickQuote') {
            this.screenname = 'termOptions';
        } else if (this.screenname == 'reviewWatercraft') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'driverRegistration') {
            this.screenname = 'reviewWatercraft';
        } else if (this.screenname == 'verifyWatercraft') {
            this.screenname = 'driverRegistration';
        } else if (this.screenname == 'insuranceLegalTerm') {
            this.screenname = 'verifyWatercraft';
        } else if (this.screenname == 'paymentDetail') {
            this.screenname = 'insuranceLegalTerm';
        } else if (this.screenname == 'policyDetail') {
            this.screenname = 'paymentDetail';
        }
    }



}