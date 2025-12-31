import { LightningElement, api } from 'lwc';
import image from '@salesforce/resourceUrl/mexJs';
import mexImage from '@salesforce/resourceUrl/mexinsurance_assets';
export default class NorthboundMainScreen extends LightningElement {
    @api screenname = 'userDetail';
    @api leadData = {};
    @api policytype;
    @api policyName = '';
    @api isCommunityUser;
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    imagebaja = image + '/mexJs/images/MexicoBajaSonora.png';
    imageparital = mexImage + '/images/max-mexico-partial@2x.png';
    imagemexico = mexImage + '/images/map-mexico-full@2x.png';

    get isTowingOption() {
        return this.leadData.Is_Towing__c != undefined ? this.leadData.Is_Towing__c : false;
    }

    get userDetail() {
        return this.screenname == "userDetail"
    }
    get vehicleDetails() {
        return this.screenname == 'vehicleDetail'
    }
    get termOption() {
        return this.screenname == 'termOption'
    }
    get isTowing() {
        return this.screenname == 'isTowing'
    }
    get towedDetails() {
        return this.screenname == 'towedDetails'
    }
    get isTowedDetailsFinal() {
        return this.screenname == 'towedDetailsFinal';
    }
    get quickQuote() {
        return this.screenname == 'quickQuote';
    }
    get ReviewVehicle() {
        return this.screenname == 'ReviewVehicle';
    }
    get companyInfo() {
        return this.screenname == 'companyInfo';
    }
    get lienholderDetails() {
        return this.screenname == 'lienholderDetails';
    }
    get DriverDetail() {
        return this.screenname == 'DriverDetail';
    }
    get verifyEditQuickQuote() {
        return this.screenname == 'verifyEditQuickQuote';
    }
    get insuranceLegalTerm() {
        return this.screenname == 'insuranceLegalTerm';
    }
    get paymentDetails() {
        return this.screenname == 'paymentDetail';
    }
    get isPolicydetail() {
        return this.screenname == 'policyDetail';
    }
    get communityUser() {
        return this.isCommunityUser != null ? this.isCommunityUser : false;
    }
    handleLeadChange(e) {
        console.log("inside event", e.detail);
        this.leadData = { ...this.leadData, ...e.detail };
    }

    connectedCallback() {
        this.isOpenLogCaseModal = false;
    }
    changeNextScreen = (val) => {
        console.log("this is leaddata new --" + JSON.stringify(this.leadData));
        this.leadData = { ...this.leadData, ['policyType']: this.policytype };
        console.log("this is leaddata new -2-" + JSON.stringify(this.leadData));
        if (this.screenname == 'userDetail') {
            this.screenname = 'vehicleDetail';
        } else if (this.screenname == 'vehicleDetail') {
            this.screenname = 'termOption';
        } else if (this.screenname == 'termOption') {
            if (this.leadData?.Vehicle_sub_type__c != null && this.leadData?.Vehicle_sub_type__c !== 'Motorcycle/Street Legal ATV') {
                this.screenname = 'isTowing';
            } else {
                this.screenname = 'quickQuote';
            }
        } else if (this.screenname == 'isTowing') {
                if (val == true) {
                    this.screenname = 'towedDetails';
                } else {
                    this.screenname = 'quickQuote';
                }
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'quickQuote') {
            if (!this.leadData?.Is_Towing__c) {
                this.screenname = 'ReviewVehicle';
            } else {
                this.screenname = 'towedDetailsFinal';
            }
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'ReviewVehicle' && this.leadData.companyInfoRender == true && this.leadData.lienholderRender == false) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'ReviewVehicle' && this.leadData.companyInfoRender == false && this.leadData.lienholderRender == false) {
            this.screenname = 'DriverDetail';
        }
        else if (this.screenname == 'ReviewVehicle' && this.leadData.companyInfoRender == false && this.leadData.lienholderRender == true) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'ReviewVehicle' && this.leadData.companyInfoRender == true && this.leadData.lienholderRender == true) {
            this.screenname = 'companyInfo';
        }
        else if (this.screenname == 'companyInfo' && this.leadData.lienholderRender == true) {
            this.screenname = 'lienholderDetails';
        }
        else if (this.screenname == 'companyInfo' && this.leadData.lienholderRender == false) {
            this.screenname = 'DriverDetail';
        }
        else if (this.screenname == 'lienholderDetails') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'DriverDetail') {
            this.screenname = 'verifyEditQuickQuote';
        } else if (this.screenname == 'verifyEditQuickQuote') {
            this.screenname = 'insuranceLegalTerm';
        } else if (this.screenname == 'insuranceLegalTerm') {
            this.screenname = 'paymentDetail';
        } else if (this.screenname == 'paymentDetail') {
            console.log('--val--', val);
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
        if (this.screenname == 'userDetail') {
        } else if (this.screenname == 'vehicleDetail') {
            this.screenname = 'userDetail';
        } else if (this.screenname == 'termOption') {
            this.screenname = 'vehicleDetail';
        } else if (this.screenname == 'isTowing') {
            this.screenname = 'termOption';
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'isTowing';
        } else if (this.screenname == 'quickQuote') {
            if (this.leadData?.Vehicle_sub_type__c != null && this.leadData?.Vehicle_sub_type__c !== 'Motorcycle/Street Legal ATV') {
                if (this.leadData.Is_Towing__c == true) {
                    this.screenname = 'towedDetails';
                } else if (this.leadData.Is_Towing__c == false) {
                    this.screenname = 'isTowing';
                }
            } else {
                this.screenname = 'termOption';
            }
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'ReviewVehicle') {
            if (!this.leadData?.Is_Towing__c) {
                this.screenname = 'quickQuote';
            } else {
                this.screenname = 'towedDetailsFinal';
            }
        } else if (this.screenname == 'companyInfo') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'lienholderDetails' && this.leadData.companyInfoRender == true) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'lienholderDetails' && this.leadData.companyInfoRender == false) {
            this.screenname = 'ReviewVehicle';
        }
        else if (this.screenname == 'DriverDetail' && this.leadData.companyInfoRender == true && this.leadData.lienholderRender == false) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'DriverDetail' && this.leadData.companyInfoRender == true && this.leadData.lienholderRender == true) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'DriverDetail' && this.leadData.companyInfoRender == false && this.leadData.lienholderRender == true) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'DriverDetail' && this.leadData.companyInfoRender == false && this.leadData.lienholderRender == false) {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'verifyEditQuickQuote') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'insuranceLegalTerm') {
            this.screenname = 'verifyEditQuickQuote';
        } else if (this.screenname == 'paymentDetail') {
            this.screenname = 'insuranceLegalTerm';
        }
    }

    fetchData = async () => {
        if (this.leadData?.Id != null) {
            const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Vehicle_details__c" });
            if (data.status == 'success') {
                if (data.data[0].Vehicle_details__c != undefined) {
                    //
                }

                this.spinner = false;
                return data.status
            } else {
                this.spinner = false;
                return 'error';
            }
        }
    }

    handleInsert = (objData, type) => {
        console.log('Obj Data ---> ', JSON.stringify(objData, null, 4));
        InsertLeadData({ 'leadData': JSON.stringify(objData) }).then(result => {
            console.log(result);

            this.leadData = { ...this.leadData, [type]: objData }
            console.log(this.leadData);
        }).catch(err => {
            console.log(err);
        })
    }

}