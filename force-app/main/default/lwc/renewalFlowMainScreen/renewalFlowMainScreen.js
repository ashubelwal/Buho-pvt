import { api, LightningElement } from 'lwc';
import getEditPolicyDetail from '@salesforce/apex/Mex_PolicyEditController.getEditPolicyDetail';
import fetchRenewQuoteData from '@salesforce/apex/Mex_PolicyEditController.fetchRenewQuoteData';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/Mex_existingCustomerFlowController.checkCommunityUserAndFetchDetails';
import LetstacklethePaymentnow from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';
import RenewPolicy from '@salesforce/label/c.TR_Renew_Policy';


export default class RenewalFlowMainScreen extends LightningElement {
     label = {
          LetstacklethePaymentnow,RenewPolicy,
    };
    @api isRenewalPolicy = 'Yes';
    @api renewalPolicyName;
    @api recordId;
    @api changeprevscreen;
    @api changesnextscreen;
    @api policyType;
    @api disableDate;
    @api screenname;
    @api renewalPolicy = {};
    @api renewQuoteId;
    @api annualTerm = false;
    @api semiAnnualTerm = false;
    @api oldPolicy = {};
    @api policyExist = false;
    @api isCommunityUser = false;
    @api DriverData;
    @api towedUnitData;
    @api connectedcallback = false;
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    async connectedCallback() {
        // this.isRenewalPolicy = true;
        this.isOpenLogCaseModal = false;
        console.log("Is Renewal Policy", this.isRenewalPolicy);
        const recordId = sessionStorage.getItem('recordId');
        this.recordId = recordId;
        console.log('Record Id',JSON.stringify(this.recordId));
        const data = await checkCommunityUserAndFetchDetails();
        const parsedData = JSON.parse(data);
        console.log(JSON.stringify(parsedData, null, 4));
        if (parsedData.status == 'success' && parsedData.userType == true) {
            this.isCommunityUser = parsedData.userType;
            this.DriverData = parsedData.drivers && parsedData.drivers.length > 0 ? parsedData.drivers : [];
            this.towedUnitData = parsedData.towedUnits && parsedData.towedUnits.length > 0 ? parsedData.towedUnits : [];
            await this.fetchPolicyData();
        }
    }

    renewconnectedcallback(event){
        console.log('recieved data '+JSON.stringify(event.detail));
        if(event.detail == true){
            this.connectedcallback = true;
        }else{
            this.connectedcallback = false;
        }
    }

    handleEditPolicyChange(event) {
        this.renewalPolicy = { ...this.renewalPolicy, ...event.detail };
        console.log('Renwal Event :::: ',JSON.stringify(this.renewalPolicy, null, 4));
    }

    handleRefundAmountChange(event) {
        this.refundAmount = event.detail;
    }

    get isTermOptions() {
        return this.screenname == 'termOptions';
    }
    get isReviewVehicle() {
        return this.screenname == 'ReviewVehicle';
    }
    get isReviewWatercraft() {
        return this.screenname == 'ReviewWatercraft';
    }
    get isCompanyInfo() {
        return this.screenname == 'companyInfo';
    }
    get isLienholderDetails() {
        return this.screenname == 'lienholderDetails';
    }
    get isDriverDetail() {
        return this.screenname == 'DriverDetail';
    }
    get isTowingAnything() {
        return this.screenname == 'isTowing';
    }
    get isTowedDetails() {
        return this.screenname == 'towedDetails';
    }
    get isTowedDetailsFinal() {
        return this.screenname == 'towedDetailsFinal';
    }
    get isConfirmScreen() {
        return this.screenname == 'confirmScreen';
    }
    get isPaymentDetail() {
        return this.screenname == 'paymentDetail';
    }
    get isSouthboundpolicy() {
        return (this.policyType == 'Automobile' || this.policyType == 'RV' || this.policyType == 'Motorcycle/Street Legal ATV');
    }
    get isNorthbound() {
        return this.policyType == 'Northbound';
    }
    get isWatercraft() {
        return this.policyType == 'Watercraft';
    }
    changeNextScreen = (val) => {
        if (this.screenname == 'termOptions') {
            if (this.policyType == 'Watercraft') {
                this.screenname = 'ReviewWatercraft';
            } else {
                this.screenname = 'ReviewVehicle';
            }

        } else if (this.screenname == 'ReviewVehicle' && this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'ReviewVehicle' && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && !this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'ReviewVehicle' && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'companyInfo' && this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'companyInfo' && !this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'lienholderDetails') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'ReviewWatercraft') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'DriverDetail' && this.policyType != 'Watercraft' && this.policyType != 'Motorcycle/Street Legal ATV') {
            this.screenname = 'isTowing';
        } else if (this.screenname == 'DriverDetail' && this.policyType == 'Watercraft') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'DriverDetail' && this.policyType == 'Motorcycle/Street Legal ATV') {
            this.screenname = 'confirmScreen';
        }else if (this.screenname == 'isTowing') {
            if (this.renewalPolicy.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'confirmScreen';
            }
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'confirmScreen') {
            if (this.renewalPolicy.Is_Towing__c) {
                this.renewQuoteId = val;
                this.screenname = 'towedDetailsFinal';
            } else {
                this.renewQuoteId = val;
                this.screenname = 'paymentDetail';
            }
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'paymentDetail';
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
    changePrevScreen = () => {
        if (this.screenname == 'termOptions') {
        } else if (this.screenname == 'ReviewVehicle' || this.screenname == 'ReviewWatercraft') {
            this.screenname = 'termOptions';
        } else if (this.screenname == 'companyInfo') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'lienholderDetails' && this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'lienholderDetails' && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'ReviewVehicle';
        } else if (this.policyType!= 'Watercraft' && this.screenname == 'DriverDetail' && this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.policyType!= 'Watercraft' &&  this.screenname == 'DriverDetail' && !this.renewalPolicy.vehicleData.Is_Lienholder__c && this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.policyType != 'Watercraft' && this.screenname == 'DriverDetail' && !this.renewalPolicy.vehicleData.Is_Lienholder__c && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'ReviewVehicle';
        } else if (this.policyType == 'Watercraft' && this.screenname == 'DriverDetail') {
            this.screenname = 'ReviewWatercraft';
        } else if (this.screenname == 'isTowing') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'isTowing';
        } else if (this.policyType!= 'Watercraft' && this.screenname == 'confirmScreen') {
            if (this.renewalPolicy.Is_Towing__c && this.policyType != 'Watercraft' && this.policyType != 'Motorcycle/Street Legal ATV') {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'isTowing';
            }
        } else if (this.policyType== 'Watercraft' && this.screenname == 'confirmScreen') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetailsFinal' ) {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'paymentDetail') {
            if (this.renewalPolicy.Is_Towing__c) {
                this.screenname = 'towedDetailsFinal'
            } else {
                this.screenname = 'confirmScreen';
            }
        }
    }










    fetchPolicyData = async () => {
        try {
            const { status, ...rest } = await getEditPolicyDetail({ 'policyId': this.recordId });
            if (status == 'success') {
                this.renewalPolicy = { ...rest };
                console.log('--this.renewalPolicy----', this.renewalPolicy);
                console.log('--this.renewalPolicy----', JSON.stringify( this.oldPolicy));
                this.oldPolicy = { ...rest };
                this.policyType = rest.policyData.Policy_Type_picklist__c;
                this.renewalPolicyName = rest.policyData.Name;
                if (true) {
                    console.log('creating renewed Quote from Policy');
                    let newQuoteReacord = {
                        Quote_Value__c: 0,
                        Net_Premium__c: 0,
                        Surcharge__c: 0,
                        I_V_A_Mex_Tax__c: 0,
                        Broker_Policy_Fee__c: 0

                    };
                    let todaysDate = new Date();
                    let endDayForCoverage = new Date(rest.quoteData.End_Date_for_Coverage__c);
                    if (endDayForCoverage < todaysDate) {
                        endDayForCoverage = todaysDate;
                    }
                    let startDayForCoverage = endDayForCoverage;
                    startDayForCoverage.setDate(startDayForCoverage.getDate() + 1);
                    const date = new Date(startDayForCoverage);
                    let month = date.getMonth() + 1;
                    let day = date.getDate();

                    let startDateFormated = date.getFullYear() + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(day);

                    newQuoteReacord['Start_Date_for_Coverage__c'] = startDateFormated;

                    console.log('-before set end date--', newQuoteReacord);
                    let termsdays = rest.quoteData.Term_Days__c;
                    console.log('-termsdays-', termsdays);
                    startDayForCoverage = new Date(newQuoteReacord.Start_Date_for_Coverage__c);
                    endDayForCoverage = new Date(startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                    if (termsdays != null) {
                        endDayForCoverage.setDate(endDayForCoverage.getDate() + parseInt(termsdays));

                        const dateFormate = new Date(endDayForCoverage);
                        let endMonthFormate = dateFormate.getMonth() + 1;
                        let endDayFormate = dateFormate.getDate();
                        let endDateFormated = dateFormate.getFullYear() + '-' + this.toDigitFormate(endMonthFormate) + '-' + this.toDigitFormate(endDayFormate);
                        newQuoteReacord['End_Date_for_Coverage__c'] = endDateFormated;

                    }
                    if (rest.quoteData.Term__c == 'Annual(One Year)') {
                        this.annualTerm = true;
                    } else if (rest.quoteData.Term__c == 'Semi-Annual(Half a Year)') {
                        this.semiAnnualTerm = true
                    }
                    this.policyExist = true;
                    this.renewalPolicy = { ...this.renewalPolicy, ['quoteData']: { ...this.renewalPolicy.quoteData, ...newQuoteReacord } };

                } else {
                    console.log('calling renewed Quote from Policy');
                    // call renewed quote data...
                    const fetchdata = await fetchRenewQuoteData({ 'renewedQuoteId': rest.quoteData.Renew_Quote__c });
                    console.log('--fetchdata--', fetchdata);
                    if (fetchdata.status == 'success') {
                        this.policyExist = fetchdata.policyExist == 'true' ? true : false;
                        let resParsequoteData = JSON.parse(fetchdata.quoteData);
                        // let resParsevehicleData = fetchdata.vehicleData ? JSON.parse(fetchdata.vehicleData) : {};
                        // let resParseDriverData = fetchdata.DriverData ? JSON.parse(fetchdata.DriverData) : {};
                        // let resParseTowedUnitData = fetchdata.towedUnitData ? JSON.parse(fetchdata.towedUnitData) : {};
                        // let resParsePolicyData = fetchdata.policyData ? JSON.parse(fetchdata.policyData) : {};


                        this.renewalPolicy = {
                            ...this.renewalPolicy, ['quoteData']: { ...resParsequoteData },
                            // ['vehicleData']: { ...this.renewalPolicy?.vehicleData, ...resParsevehicleData },
                            // ['DriverData']: { ...this.renewalPolicy?.DriverData, ...resParseDriverData },
                            // ['towedUnitData']: { ...this.renewalPolicy?.towedUnitData, ...resParseTowedUnitData },
                            // ['policyData']: { ...this.renewalPolicy?.policyData, ...resParsePolicyData },
                        };
                        this.renewalPolicy.quoteData = { ...this.renewalPolicy.quoteData, ['Start_Time__c']: this.renewalPolicy.policyData.Start_Time__c }
                        this.renewalPolicy.quoteData = { ...this.renewalPolicy.quoteData, ['End_Time__c']: this.renewalPolicy.policyData.End_Time__c }
                    }

                    console.log('-- fetch renewalPolicy--', this.renewalPolicy);

                }
                console.log('--> renewal policy ---> ', JSON.stringify(this.renewalPolicy));
            } else {
                // error -> something went wrong...
                console.log(status);
            }
            this.screenname = 'termOptions';
        } catch (error) {
            console.log(error);
            if (error.status === 500 && error.statusText === 'Server Error') {
                // something went wrong. Please try again...
            }
        }
    }

    toDigitFormate(n) {
        return n > 9 ? "" + n : "0" + n;
    }

}