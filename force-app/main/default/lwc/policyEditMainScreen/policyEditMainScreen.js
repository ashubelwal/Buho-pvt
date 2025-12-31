import { LightningElement, api } from 'lwc';
import getEditPolicyDetail from '@salesforce/apex/Mex_PolicyEditController.getEditPolicyDetail';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/Mex_existingCustomerFlowController.checkCommunityUserAndFetchDetails';
import LetstacklethePaymentnow from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';


export default class PolicyEditMainScreen extends LightningElement {
     label = {
       LetstacklethePaymentnow,
    };
    @api screenname;
    @api recordId;
    @api oldPolicy = {};
    @api editPolicy = {};
    @api disableDate = false;
    @api connectedcallback = false;
    @api refundAmount;
    @api isEditPolicy = 'Yes';
    @api isCommunityUser = false;
    @api DriverData;
    @api towedUnitData;
    policyType;
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    async connectedCallback() {
        this.isOpenLogCaseModal  = false;
        const recordId = sessionStorage.getItem('recordId');
        this.recordId = recordId;
        console.log(this.recordId);
        // this.disableDate = true;
        // this.isEditPolicy = true;
        //if (Object.keys(this.oldPolicy).length > 0 && Object.keys(this.editPolicy).length > 0) return;
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

    handleEditPolicyChange(event){
        console.log('recieved data ');
        console.log('recieved data '+JSON.stringify(event.detail));
        this.editPolicy = { ...this.editPolicy, ...event.detail };
    }

    handleRefundAmountChange(event){
        this.refundAmount = event.detail;
    }

    renewconnectedcallback(event){
        console.log('recieved data '+JSON.stringify(event.detail));
        if(event.detail == true){
            this.connectedcallback = true;
        }else{
            this.connectedcallback = false;
        }
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
    changeNextScreen = (val) => {
        console.log('new logs ');
        console.log('--next screen --', this.screenname);
        if (this.screenname == 'termOptions') {
            if(this.policyType == 'Watercraft'){
                this.screenname = 'ReviewWatercraft';
            }else{
                this.screenname = 'ReviewVehicle';
            }
        } else if (this.screenname == 'ReviewVehicle' && this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'ReviewVehicle' && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && !this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'ReviewVehicle' && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        }else if(this.screenname == 'ReviewWatercraft'){
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'companyInfo' && this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'companyInfo' && !this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'lienholderDetails') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'DriverDetail' && this.policyType != 'Watercraft' && this.policyType != 'Motorcycle/Street Legal ATV') {
            this.screenname = 'isTowing';
        }else if (this.screenname == 'DriverDetail' && (this.policyType == 'Watercraft' || this.policyType == 'Motorcycle/Street Legal ATV')) {
            this.screenname = 'confirmScreen';
        }  else if (this.screenname == 'isTowing') {
            if (this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'confirmScreen';
            }
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'confirmScreen') {
            if (this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetailsFinal';
            } else {
                this.screenname = 'paymentDetail';
            }
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'paymentDetail';
        }
    }

    changePrevScreen = () => {
        if (this.screenname == 'termOptions') {
        }else if(this.screenname == 'ReviewWatercraft'){
            this.screenname = 'termOptions';
        }  else if (this.screenname == 'ReviewVehicle') {
            this.screenname = 'termOptions';
        } else if (this.screenname == 'companyInfo') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'lienholderDetails' &&this.editPolicy.vehicleData &&  this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'lienholderDetails' && this.editPolicy.vehicleData && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'ReviewVehicle';
        }else if (this.screenname == 'DriverDetail' &&this.editPolicy.vehicleData &&  this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        }else if (this.screenname == 'DriverDetail' && this.editPolicy.vehicleData && !this.editPolicy.vehicleData.Is_Lienholder__c && this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        }else if (this.screenname == 'DriverDetail' && this.editPolicy.vehicleData && !this.editPolicy.vehicleData.Is_Lienholder__c && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c ) {
            // this.screenname = 'ReviewVehicle';
            if(this.policyType == 'Watercraft'){
                this.screenname = 'ReviewWatercraft';
            }else{
                this.screenname = 'ReviewVehicle';
            }
        }else if (this.screenname == 'DriverDetail' && this.policyType == 'Watercraft' ) {
            this.screenname = 'ReviewWatercraft';
        }  else if (this.screenname == 'isTowing') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'isTowing';
        } else if (this.screenname == 'confirmScreen'  && this.policyType != 'Watercraft' ) {
            if (this.policyType == 'Motorcycle/Street Legal ATV') {
                this.screenname = 'ReviewVehicle';
            }else if (this.policyType != 'Motorcycle/Street Legal ATV' && this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'isTowing';
            }
        }else if (this.screenname == 'confirmScreen'  && this.policyType == 'Watercraft' ) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'paymentDetail') {
            if (this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetailsFinal';
            } else {
                this.screenname = 'confirmScreen';
            }
        }
    }

    fetchPolicyData = async () => {
        try {
            const { status, ...rest } = await getEditPolicyDetail({ 'policyId': this.recordId });
            if (status == 'success') {
                this.oldPolicy = { ...rest };
                this.editPolicy = { ...rest };
                this.policyType = rest.policyData.Policy_Type_picklist__c;
            } else {
                // error -> something went wrong...
                console.log('Inside Else ::: ',status);
            }
            this.screenname = 'termOptions';
        } catch (error) {
            console.log(error);
            if (error.status === 500 && error.statusText === 'Server Error') {
                // something went wrong. Please try again...
            }
        }
    }
}