import { api, LightningElement } from 'lwc';
import mexImage from '@salesforce/resourceUrl/mexinsurance_assets';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Territory from '@salesforce/label/c.TR_Territory';
import Whatterritorycoverageareyoulookingfor from '@salesforce/label/c.TR_What_territory_coverage_are_you_looking_for';
import BajaSonora from '@salesforce/label/c.TR_Baja_Sonora';
import BajaSonoras from '@salesforce/label/c.TR_Baja_Sonora_Chihuahua_Coahuila_Nuevo_Leon_Tamaulipas';
import EntireMexico from '@salesforce/label/c.TR_Entire_Mexico';
import Letstacklethepaymentnow from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';
import Prev from '@salesforce/label/c.TR_Prev';
import Next from '@salesforce/label/c.TR_Next';
import PleaseSelectAnyOneOption from '@salesforce/label/c.TR_Please_Select_Any_One_Option';


export default class SouthboundMainScreen extends LightningElement {
     label = {
         Territory,Whatterritorycoverageareyoulookingfor,BajaSonora,BajaSonoras,EntireMexico,Letstacklethepaymentnow,Prev,Next,PleaseSelectAnyOneOption,
    };
    @api screenname = 'userDetail';
    @api leadData = {};
    @api policytype;
    @api policyName;
    @api isCommunityUser;
    @api isTowingOption;
    @api
    isSecondTimeLoad = false;
    territoryCoverageValue;
    towedUnitForAdditionalQuote;
    additonQuote = false;
    @api
    isShowCaseLog = false;
    isOpenLogCaseModal = false;

    message = this.label.PleaseSelectAnyOneOption;
    variant = 'error';

    imagebaja = mexImage + '/images/baja-sonora-blue.png';
    imageparital = mexImage + '/images/max-naxico-partial-blue.png';
    imagemexico = mexImage + '/images/Entire-mexico-blue.png';

    connectedCallback() {
        this.isOpenLogCaseModal = false;
        console.log(this.isTowingOption);
    }

    get communityUser() {
        return this.isCommunityUser != null ? this.isCommunityUser : false;
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
    get isTowedDetails() {
        return this.screenname == 'towedDetails'
    }
    get territoryCoverage() {
        return this.screenname == 'territoryCoverage';
    }
    get quickQuote() {
        return this.screenname == 'quickQuote';
    }
    get ReviewVehicle() {
        return this.screenname == 'ReviewVehicle';
    }
    get ReviewTowDetail() {
        return this.screenname == 'ReviewTowDetail';
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

    get insurenceLegalTerm() {
        return this.screenname == 'insuranceLegalTerm';
    }
    get paymentDetail() {
        return this.screenname == 'paymentDetail';
    }
    get policyDetail() {
        return this.screenname == 'policyDetail';
    }
    get additionalQuickQuote() {
        return this.screenname == 'additionalQuickQuote';
    }

    get bajaSonaraValue() {
        return this.territoryCoverageValue == 'Baja/Sonora';
    }
    get partialValue() {
        return this.territoryCoverageValue == 'Limited';
    }
    get entireMexico() {
        return this.territoryCoverageValue == 'Full';
    }

    handleLeadChange(e) {
        this.leadData = { ...this.leadData, ...e.detail };
        console.log("Event ::: ", JSON.stringify(this.leadData, null, 4));
    }

    handleTerritoryChange(e) {
        if (e.target.value !== null || e.target.value !== '') {
            this.territoryCoverageValue = e.target.value
        }
    }
    isInputValid = () => {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.Validation');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    fetchData = async () => {
        if (this.leadData.Id != undefined) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leadData.Id, "screenName": "Territory_options__c" });
                if (data.status == 'success') {
                    let parseData = data.data[0].Territory_Options__c;
                    this.territoryCoverageValue = parseData;

                    const params = new URLSearchParams(window.location.search);
                    let leadId = params.get('id');
                    let leadEmail = params.get('email');

                    if ((leadId != null || leadEmail != null) && (!this.isCommunityUser && window.localStorage.getItem('continueNext') == 'true')) {
                        if(this.isSecondTimeLoad == false){
                            console.log('running first Time load');
                            this.handleNextClick(leadId, leadEmail);
                        }   
                        this.isSecondTimeLoad = true;
                    }
                }
            } catch (ex) {
                console.log('error : ', ex);
                return 'error';
            }
        }
    }

    handlePrevClick(leadId, leadEmail) {
        this.changePrevScreen();

    }

    handleNextClick = async (leadId,leadEmail) => {
        console.log('running handleNextClick');
        this.isSecondTimeLoad = true;
        let isValid = this.isInputValid();
        if (isValid && this.territoryCoverageValue != null) {
            try {
                this.template.querySelector('.buttonNext').classList.add('loading');
                this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                const data = await validateFormData({ "objData": JSON.stringify({ ['Territory_options__c']: this.territoryCoverageValue }), "objName": 'territoryCoverage' });

                if (data.status == 'success') {
                    const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Territory_options__c']: this.territoryCoverageValue, ['Id']: this.leadData.Id }) });

                    if (res.status == 'Success') {
                        this.changeNextScreen();
                    } else {

                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                        // error....
                    }
                } else {
                    this.template.querySelector('.buttonNext').classList.remove('loading');
                    this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    // error...
                }
            } catch (error) {
                console.log(error);
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                // handle errors if any...
            }
        } else {
            if (!this.communityUser && (leadId || leadEmail)) {
                window.localStorage.setItem('continueNext', 'false');
            }
            const evt = new ShowToastEvent({
                message: this.message,
                variant: this.variant,
            });
            this.dispatchEvent(evt);
        }
    }

    changeNextScreen = (val) => {
        console.log('running change next screen');
        console.log('this.policytype',this.policytype);
        this.isSecondTimeLoad = true;
        this.leadData = { ...this.leadData, ['policyType']: this.policytype, ['Is_Towing__c']: this.leadData.Is_Towing__c != undefined ? this.leadData.Is_Towing__c : this.isTowingOption };
        this.policytype = this.policytype;

        if (this.screenname == 'userDetail') {
            this.screenname = 'vehicleDetail';
        } else if (this.screenname == 'vehicleDetail') {
            this.screenname = 'termOption';
        } else if (this.screenname == 'termOption' && this.policytype.toLowerCase() != 'motorcycle/street legal atv') {
            if (this.leadData.Is_Towing__c) {
                //this.screenname = 'towedDetails';
                this.screenname = 'isTowing';
            } else {
                this.fetchData();
               // this.screenname = 'territoryCoverage';
               this.screenname = 'isTowing';
            }
        } else if (this.screenname == 'termOption' && this.policytype.toLowerCase() == 'motorcycle/street legal atv') {
            this.fetchData();
            this.screenname = 'territoryCoverage';
        }
        else if (this.screenname == 'isTowing') {
            if (this.leadData?.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
                if (this.policytype !== 'Northbound') {
                    this.screenname = 'territoryCoverage';
                } else {
                    this.screenname = 'quickQuote';
                }
            }
        }
        else if (this.screenname == 'towedDetails') {
            this.fetchData();
            if (val != null && val != '') {
                this.towedUnitForAdditionalQuote = val;
                this.additonQuote = true;
            }
            this.screenname = 'territoryCoverage';
        } else if (this.screenname == 'territoryCoverage') {
            let eventExist = window.dataLayer.find((data) => data.step_number === 'step_6');
            if (eventExist == undefined){
                window.dataLayer.push({
                    'event': 'funnel_step',
                    'step_number': 'step_6',
                    'step_name': 'territory_selection', 
                    'territory_selected': this.territoryCoverageValue,
                    'insurance_category': this.policytype
                    });
            }
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'quickQuote' && this.policytype.toLowerCase() == 'motorcycle/street legal atv') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'quickQuote' && this.policytype.toLowerCase() != 'motorcycle/street legal atv') {
            if (this.leadData.Is_Towing__c) {
                this.screenname = 'ReviewTowDetail';
            } else {
                this.screenname = 'ReviewVehicle';
            }
        } else if (this.screenname == 'ReviewTowDetail') {
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
            this.policyName = val;
            this.screenname = 'policyDetail';
        }
    }

    @api
    showLogaCase(event){
        this.isShowCaseLog = true;
        console.log('---isOpenLogCaseModal--', this.isOpenLogCaseModal);
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
        console.log('fetching screen name-> '+this.screenname);
        if (this.screenname == 'userDetail') {
        } else if (this.screenname == 'vehicleDetail') {
            this.leadData = { ...this.leadData, ['Id']: null };
            this.screenname = 'userDetail';
        } else if (this.screenname == 'termOption') {
            this.screenname = 'vehicleDetail';
        }
        else if (this.screenname == 'isTowing') {
            this.screenname = 'termOption';
        }
        // else if (this.screenname == 'isTowing') {
        //     this.screenname = 'termOption';
        // } 
        else if (this.screenname == 'towedDetails') {
            //this.screenname = 'termOption';
            this.screenname = 'isTowing';
        } else if (this.screenname == 'territoryCoverage' && this.leadData.policyType.toLowerCase() !== 'motorcycle/street legal atv') {
            if (this.leadData.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
               // this.screenname = 'termOption';
               this.screenname = 'isTowing';
            }
        } else if (this.screenname == 'territoryCoverage' && this.leadData.policyType.toLowerCase() === 'motorcycle/street legal atv') {
            this.screenname = 'termOption';
        }
        else if (this.screenname == 'quickQuote') {
            this.fetchData();
            this.screenname = 'territoryCoverage';
        } else if (this.screenname == 'additionalQuickQuote') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'ReviewTowDetail') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'ReviewVehicle' && this.leadData.policyType.toLowerCase() == 'motorcycle/street legal atv') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'ReviewVehicle' && this.leadData.policyType.toLowerCase() != 'motorcycle/street legal atv') {
            if (this.leadData.Is_Towing__c) {
                this.screenname = 'ReviewTowDetail';
            } else {
                this.screenname = 'quickQuote';
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

}