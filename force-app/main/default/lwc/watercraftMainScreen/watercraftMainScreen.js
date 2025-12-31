import { LightningElement, api, track } from 'lwc';
import LetstacklethePaymentnow from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';


export default class WatercraftMainScreen extends LightningElement {
     label = {
        LetstacklethePaymentnow,
    };
    @api screenName = 'userDetails';
    @api leadData = {};
    @api policytype = '';
    @api policyName = '';
    @api communityUser = false;
    @track hasRendered = true;
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    

    get isUserDetails () {
        return this.screenName == 'userDetails';
    }

    get isWatercraftDetails () {
        return this.screenName == 'watercraftDetails';
    }

    get isTermOptions () {
        return this.screenName == 'termOptions';
    }

    get isQuickQuote () {
        return this.screenName == 'quickQuote';
    }

    get isReviewWatercraft () {
        return this.screenName == 'reviewWatercraft';
    }

    get isDriverRegistration () {
        return this.screenName == 'driverRegistration';
    }

    get isVerifyWatercraft () {
        return this.screenName == 'verifyWatercraft';
    }

    get isInsuranceFinalDetails () {
        return this.screenName == 'insuranceFinalDetails';
    }

    get isPaymentDetail () {
        return this.screenName == 'paymentDetail';
    }

    get isPolicyDetail () {
        return this.screenName == 'isPolicyDetail';
    }

    renderedCallback() {
        if (this.hasRendered) {
            this.leadData = {...this.leadData, policyType: this.policytype};
            console.log(this.leadData);
            this.hasRendered = false;
        }
    }

    handleLeadChange (e) {
        console.log("inside event",e.detail);
        this.leadData = {...this.leadData, ...e.detail};
    }

    changeNextScreen = (val) => {
        this.leadData = {...this.leadData, ['policyType']:this.policytype};
        
        console.log('----', this.policytype);
        console.log('next screen name '+ this.screenName);
        if (this.screenName == 'userDetails') {
            this.screenName = 'watercraftDetails';
        } else if (this.screenName == 'watercraftDetails') {
            this.screenName = 'termOptions';
        } else if (this.screenName == 'termOptions') {
            this.screenName = 'quickQuote';
        } else if (this.screenName == 'quickQuote') {
            this.screenName = 'reviewWatercraft';
        } else if (this.screenName == 'reviewWatercraft') {
            this.screenName = 'driverRegistration';
        } else if (this.screenName == 'driverRegistration') {
            this.screenName = 'verifyWatercraft';
        } else if (this.screenName == 'verifyWatercraft') {
            this.screenName = 'insuranceFinalDetails';
        } else if (this.screenName == 'insuranceFinalDetails') {
            this.screenName = 'paymentDetail';
        } else if (this.screenName == 'paymentDetail') {
            console.log('--val--',val);
            this.policyName = val;
            console.log('--southbound-mainscreen--', this.policyName);
            this.screenName = 'isPolicyDetail';
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
    @api openModalLogCase(event){
        console.log('event.detail--', event.detail)
        if(event.detail == 'delayClose'){
            this.isOpenLogCaseModal = true;
        }else if(event.detail == 'quickClose'){
            this.isShowCaseLog = false;
        }else if(event.detail == 'OnloadedComponent'){
            this.isOpenLogCaseModal = false;
        }
        
    }
    connectedCallback() {
        this.isOpenLogCaseModal = false;
    }
    changePrevScreen = () => {
        console.log('---prevScreen--', this.screenName);
        if (this.screenName == 'userDetails') {
        } else if (this.screenName == 'watercraftDetails') {
            this.screenName = 'userDetails';
        } else if (this.screenName == 'termOptions') {
            this.screenName = 'watercraftDetails';
        } else if (this.screenName == 'quickQuote') {
            this.screenName = 'termOptions';
        } else if (this.screenName == 'reviewWatercraft') {
            this.screenName = 'quickQuote';
        } else if (this.screenName == 'driverRegistration') {
            this.screenName = 'reviewWatercraft';
        } else if (this.screenName == 'verifyWatercraft') {
            this.screenName = 'driverRegistration';
        } else if (this.screenName == 'insuranceFinalDetails') {
            this.screenName = 'verifyWatercraft';
        } else if (this.screenName == 'paymentDetail') {
            this.screenName = 'insuranceFinalDetails';
        } else if (this.screenName == 'isPolicyDetail') {
            this.screenName = 'paymentDetail';
        }
    }
    // handleLeadChange(event){
    //     this.leaddata = {...this.leaddata,...event.detail}
    // }


    handleInsert = (objData, type) => {
        console.log('Obj Data ---> ', JSON.stringify(objData, null, 4));
        InsertLeadData({'leadData': JSON.stringify(objData)}).then(result => {
            console.log(result);

            this.leadData = {...this.leadData, [type]: objData}
            console.log(this.leadData);
        }).catch(err => {
            console.log(err);
        })
    }


}