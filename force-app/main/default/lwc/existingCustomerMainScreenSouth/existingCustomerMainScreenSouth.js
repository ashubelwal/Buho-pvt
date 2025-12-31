import { LightningElement, api } from 'lwc';
import image from '@salesforce/resourceUrl/mexJs';
import mexImage from '@salesforce/resourceUrl/mexinsurance_assets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteDataToContinueQuote from '@salesforce/apex/Mex_NewLeadProcess.getQuoteDataToContinueQuote';
import territorycoverage from '@salesforce/label/c.TR_What_territory_coverage_are_you_looking_for';
import bajasonora from '@salesforce/label/c.TR_Baja_Sonora';
import entiremexico from '@salesforce/label/c.TR_Entire_Mexico';
import prev from '@salesforce/label/c.TR_Prev';
import next from '@salesforce/label/c.TR_Next';
import letstacklepayment from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';
import bajasonarachihuahua from '@salesforce/label/c.TR_Baja_Sonora_Chihuahua_Coahuila_Nuevo_Leon_Tamaulipas';
import partial from '@salesforce/label/c.TR_Partial_US_Adjacent';
import PleaseSelectAnyOneOption from '@salesforce/label/c.TR_Please_Select_Any_One_Option';

export default class ExistingCustomerMainScreenSouth extends LightningElement {
     label = {
        territorycoverage,bajasonora,entiremexico,prev,next,letstacklepayment,bajasonarachihuahua,partial, PleaseSelectAnyOneOption
    };
    @api isCommunityUser;
    isDataFetchedForContinueQuote = false;
    @api vehicleData;
    @api driverData;
    @api towedUnitData;
    @api policyType;
    @api isTowingOption;
    screenname;
    @api customerRecord = {};
    @api policyName;
    imagebaja = mexImage + '/images/baja-sonora-blue.png';
    imageparital = mexImage + '/images/max-naxico-partial-blue.png';
    imagemexico = mexImage + '/images/Entire-mexico-blue.png';

    message = this.label.PleaseSelectAnyOneOption;
    variant = 'error';
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    async connectedCallback() {
        this.isOpenLogCaseModal = false;
        // this.customerRecord = { ...this.customerRecord,  };
        let recordId = sessionStorage.getItem('continueQuoteID');
        let isDataFetchedForContinueQuote = sessionStorage.getItem('isContinueQuote');


        if ((recordId != '' && recordId != null) && (isDataFetchedForContinueQuote == true || isDataFetchedForContinueQuote == 'true')) {
            await this.fetchQuoteData(recordId);
        } else {
            this.customerRecord = { ...this.customerRecord, ['Is_Towing__c']: this.isTowingOption, ['policyType']: this.policyType, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ['Towed_Unit__c']: this.isTowingOption } };
            if (this.policyType == 'Northbound') {
                this.customerRecord = { ...this.customerRecord, ['Territory__c']: 'Northbound' };
            }
        }
        this.screenname = 'vehicleDetails';
    }

    updateTowingOption(event){
        console.log('Updating universal Towing option');
        this.customerRecord.Is_Towing__c = event.detail;
        this.isTowingOption = event.detail;
    }

    async fetchQuoteData(recordId) {
        let data = await getQuoteDataToContinueQuote({ 'quoteId': recordId });
        
        if (data.status == 'success') {
            // sessionStorage.removeItem('continueQuoteID');
            const { term__c, ...rest } = data.quoteRecord;
            this.customerRecord = { ...this.customerRecord, ...data.userRecord };
            this.customerRecord = { ...this.customerRecord, ['Is_Towing__c']: data.quoteRecord?.Towed_Unit__c == 'Yes' ? true : data.quoteRecord?.Towed_Unit__c == true ? true : false };
            this.customerRecord = { ...this.customerRecord, ['policyType']: data.quoteRecord?.Policy_Type_picklist__c };
            this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord.quoteRecord, ...rest, ['Term__c']: term__c != undefined ? term__c : 'Daily' } };
            if (data.vehicleRecord != undefined) {
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord.vehicleData, ...data.vehicleRecord[0], ['Vehicle_sub_type__c']: data.quoteRecord?.Policy_Type_picklist__c != 'Northbound' ? data.quoteRecord?.Vehicle_Sub_type__c : data.quoteRecord?.Vehicle_Type__c } };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord.vehicleData, ['Is_there_a_driver_under_21__c']: data.quoteRecord.Is_there_a_driver_under_21__c == 'Yes' ? true : false } };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord.vehicleData, ['Is_this_a_Rental_Vehicle__c']: data.quoteRecord.Is_this_a_Rental_Vehicle__c } };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord.vehicleData, ['Salvage_Vehicle__c']: data.quoteRecord.Salvage_Vehicle__c == 'Yes' ? true : false } };
            }
            this.customerRecord = { ...this.customerRecord, ['DriverData']: data.driverRecord?.length > 0 ? [...data.driverRecord] : [] };
            this.customerRecord = { ...this.customerRecord, ['towedUnitData']: data.towRecord?.length > 0 ? [...data.towRecord] : [] };
            this.policyType = data.quoteRecord?.Policy_Type_picklist__c;
            this.isTowingOption = data.quoteRecord?.Towed_Unit__c == 'Yes' ? true : data.quoteRecord?.Towed_Unit__c == true ? true : false;
            if (data.quoteRecord.Policy_Type_picklist__c == 'Northbound') {
                let dob = data.quoteRecord?.Date_of_Birth__c?.split("-");
                this.customerRecord = { ...this.customerRecord, ['Territory__c']: 'Northbound' };
                this.customerRecord = { ...this.customerRecord, ['Is_Towing__c']: data.quoteRecord?.Towed_Unit__c == 'Yes' ? true : data.quoteRecord?.Towed_Unit__c == true ? true : false };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord.vehicleData, ...data.vehicleRecord[0], ['DOBYear']: dob[0] } };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord.vehicleData, ['DOBMonth']: dob[1] } };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord.vehicleData, ['DOBDay']: dob[2] } };
            }
        }
        sessionStorage.setItem('isContinueQuote', false);
    }

    handleCustomerRecordChange(e) {
        this.customerRecord = { ...this.customerRecord, ...e.detail };
        console.log('event :::: ', JSON.stringify(this.customerRecord, null, 4));
    }

    get communityUser() {
        return this.isCommunityUser != null ? this.isCommunityUser : false;
    }

    get isDriverData() {
        return this.driverData != null && this.driverData.length > 0 ? this.driverData : [];
    }

    get isTowedUnit() {
        return this.towedUnitData != null && this.towedUnitData.length > 0 ? this.towedUnitData : [];
    }

    get isBajaSonaraValue() {
        return this.customerRecord?.quoteRecord?.Territory__c !== null && this.customerRecord?.quoteRecord?.Territory__c === 'Baja/Sonora';
    }

    get isPartialValue() {
        return this.customerRecord?.quoteRecord?.Territory__c !== null && this.customerRecord?.quoteRecord?.Territory__c === 'Limited';
    }

    get isEntireMexico() {
        return this.customerRecord?.quoteRecord?.Territory__c !== null && this.customerRecord?.quoteRecord?.Territory__c === 'Full';
    }

    get isVehicleDetails() {
        return this.screenname == 'vehicleDetails';
    }

    get isTermOptions() {
        return this.screenname == 'termOption';
    }

    get ReviewTowDetail() {
        return this.screenname == 'ReviewTowDetail';
    }

    get isTowingDetails() {
        return this.screenname == 'towingDetails';
    }

    get isTowing() {
        return this.screenname == 'isTowing';
    }

    get isTerritoryCoverage() {
        return this.screenname == 'territoryCoverage' && this.policyType != 'Northbound';
    }

    get isSouthboundQuickQuote() {
        return this.screenname == 'quickQuote' && this.policyType != 'Northbound';
    }

    get isNorthboundQuickQuote() {
        return this.screenname == 'quickQuote' && this.policyType == 'Northbound';
    }

    get isReviewVehicle() {
        return this.screenname == 'ReviewVehicle';
    }

    get isCompanyInfo() {
        return this.screenname == 'companyInfo';
    }

    get isLienholderDetails() {
        return this.screenname == 'lienHolderInfo';
    }

    get isDriverDetail() {
        return this.screenname == 'driverDetails';
    }

    get isVerifyEditQuickQuote() {
        return this.screenname == 'verifyEditQuickQuote';
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
    handleTerritoryChange(e) {
        if (e.target.value !== null || e.target.value !== '') {
            this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ['Territory__c']: e.target.value } }
        }
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

    handleNextClick = async () => {
        if (this.customerRecord?.quoteRecord?.Territory__c != null) {
            try {
                this.template.querySelector('.buttonNext').classList.add('loading');
                this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                this.changeNextScreen();
            } catch (error) {
                console.log(error);
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                // handle errors if any...
            }
        } else {
            const evt = new ShowToastEvent({
                message: this.message,
                variant: this.variant,
            });
            this.dispatchEvent(evt);
        }
    }

    handlePrevClick = () => {
        this.changePrevScreen();
    }

    changeNextScreen = (val) => {
        console.log('----isTowingOption---', this.isTowingOption);
        console.log('----screenname---', this.screenname);
        console.log('----policyType---', this.policyType);
        if (this.screenname == 'vehicleDetails') {
            this.screenname = 'termOption';
        } else if (this.screenname == 'termOption' && this.customerRecord?.policyType?.toLowerCase() !== 'motorcycle/street legal atv') {
            if (this.customerRecord?.policyType == 'Northbound' && this.customerRecord?.vehicleData?.Vehicle_sub_type__c !== 'Motorcycle/Street Legal ATV') {
                this.screenname = 'isTowing';
            } else if (this.customerRecord?.policyType == 'Northbound' && this.customerRecord?.vehicleData?.Vehicle_sub_type__c == 'Motorcycle/Street Legal ATV') {
                this.screenname = 'quickQuote';
            } else if (this.customerRecord?.policyType !== 'Northbound' && !this.isTowingOption) {
               // this.screenname = 'territoryCoverage';
               this.screenname = 'isTowing';
            } else if (this.isTowingOption) {
                this.screenname = 'isTowing';
            }
        } else if (this.screenname == 'termOption' && this.customerRecord?.policyType?.toLowerCase() === 'motorcycle/street legal atv') {
            this.screenname = 'territoryCoverage';
        } else if (this.screenname == 'isTowing') {
            if (this.customerRecord?.Is_Towing__c) {
                this.screenname = 'towingDetails';
            } else {
                if (this.customerRecord?.policyType !== 'Northbound') {
                    this.screenname = 'territoryCoverage';
                } else {
                    this.screenname = 'quickQuote';
                }
            }
        } else if (this.screenname == 'towingDetails') {
            if (this.customerRecord?.policyType !== 'Northbound') {
                this.screenname = 'territoryCoverage';
            } else {
                this.screenname = 'quickQuote';
            }
        } else if (this.screenname == 'territoryCoverage') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'quickQuote' && (this.policyType.toLowerCase() == 'motorcycle/street legal atv')) {
            console.log('change screen from quickQuote to reviewvehicle');
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'quickQuote' && (this.policyType.toLowerCase() != 'motorcycle/street legal atv')) {
            if (this.customerRecord?.Is_Towing__c) {
                this.screenname = 'ReviewTowDetail';
            } else {
                this.screenname = 'ReviewVehicle';
            }
        } else if (this.screenname == 'ReviewTowDetail') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'ReviewVehicle' && this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'ReviewVehicle' && !this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c && !this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'driverDetails';
        } else if (this.screenname == 'ReviewVehicle' && !this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c && this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'lienHolderInfo';
        } else if (this.screenname == 'companyInfo' && this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'lienHolderInfo';
        } else if (this.screenname == 'companyInfo' && !this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'driverDetails';
        } else if (this.screenname == 'lienHolderInfo') {
            this.screenname = 'driverDetails';
        } else if (this.screenname == 'driverDetails') {
            this.screenname = 'verifyEditQuickQuote';
        } else if (this.screenname == 'verifyEditQuickQuote') {
            this.screenname = 'insuranceLegalTerm';
        } else if (this.screenname == 'insuranceLegalTerm') {
            this.screenname = 'paymentDetail';
        } else if (this.screenname == 'paymentDetail') {
            this.policyName = val;
            this.screenname = 'policyDetail';
        }

        console.log('----screenname end---', this.screenname);
    }

    changePrevScreen = () => {
        console.log('----screenname ---', this.screenname);
        if (this.screenname == 'vehicleDetails') {
        } else if (this.screenname == 'termOption') {
            this.screenname = 'vehicleDetails';
        } else if (this.screenname == 'isTowing') {
            this.screenname = 'termOption';
        } else if (this.screenname == 'towingDetails') {
            if (this.customerRecord?.policyType == 'Northbound') {
                this.screenname = 'isTowing';
            } else {
               // this.screenname = 'termOption';
               this.screenname = 'isTowing';
            }
        } else if (this.screenname == 'territoryCoverage' && this.policyType?.toLowerCase() !== 'motorcycle/street legal atv') {
            if (this.customerRecord?.Is_Towing__c) {
                this.screenname = 'towingDetails';
            } else if (this.isTowingOption) {
                this.screenname = 'isTowing';
            } else {
               // this.screenname = 'termOption';
               this.screenname = 'isTowing';
            }
        } else if (this.screenname == 'territoryCoverage' && this.policyType?.toLowerCase() === 'motorcycle/street legal atv') {
            this.screenname = 'termOption';
        } else if (this.screenname == 'quickQuote') {
            if (this.customerRecord?.policyType == 'Northbound' && this.customerRecord?.vehicleData?.Vehicle_sub_type__c == 'Motorcycle/Street Legal ATV') {
                this.screenname = 'termOption';
            } else if (this.customerRecord?.policyType == 'Northbound' && this.customerRecord?.vehicleData?.Vehicle_sub_type__c != 'Motorcycle/Street Legal ATV' && this.customerRecord?.Is_Towing__c) {
                this.screenname = 'towingDetails';
            } else if (this.customerRecord?.policyType == 'Northbound' && this.customerRecord?.vehicleData?.Vehicle_sub_type__c != 'Motorcycle/Street Legal ATV' && !this.customerRecord?.Is_Towing__c) {
                this.screenname = 'isTowing';
            } else {
                this.screenname = 'territoryCoverage';
            }
        } else if (this.screenname == 'ReviewTowDetail') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'ReviewVehicle' && this.customerRecord?.vehicleData?.Vehicle_sub_type__c != 'Motorcycle/Street Legal ATV') {
            if (this.customerRecord?.Is_Towing__c) {
                this.screenname = 'ReviewTowDetail';
            } else {
                this.screenname = 'quickQuote';
            }
        } else if (this.screenname == 'ReviewVehicle' && this.customerRecord?.vehicleData?.Vehicle_sub_type__c == 'Motorcycle/Street Legal ATV') {
            this.screenname = 'quickQuote';
        } else if (this.screenname == 'companyInfo') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'lienHolderInfo' && this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'lienHolderInfo' && !this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'driverDetails' && this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c && !this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'driverDetails' && this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c && this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'lienHolderInfo';
        } else if (this.screenname == 'driverDetails' && !this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c && this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'lienHolderInfo';
        } else if (this.screenname == 'driverDetails' && !this.customerRecord?.vehicleData?.Is_the_vehicle_registered_to_a_business__c && !this.customerRecord?.vehicleData?.Is_Lienholder__c) {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'verifyEditQuickQuote') {
            this.screenname = 'driverDetails';
        } else if (this.screenname == 'insuranceLegalTerm') {
            this.screenname = 'verifyEditQuickQuote';
        } else if (this.screenname == 'paymentDetail') {
            this.screenname = 'insuranceLegalTerm';
        }
    }
}