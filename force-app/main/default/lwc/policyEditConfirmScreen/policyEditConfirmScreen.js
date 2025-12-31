import { api, LightningElement } from 'lwc';
import getQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getQuote';
import getNorthboundQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundQuote';
import getWatercraftQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getWatercraftQuote';
import updatePolicyDetails from '@salesforce/apex/Mex_PolicyEditController.updatePolicyDetails';
import { NavigationMixin } from 'lightning/navigation';
import OriginalPolicy from '@salesforce/label/c.TR_Original_Policy';
import Summary from '@salesforce/label/c.TR_Summary';
import Premium from '@salesforce/label/c.TR_Premium';
import Surcharge from '@salesforce/label/c.TR_Surcharge';
import Medical from '@salesforce/label/c.TR_Medical';
import Liability from '@salesforce/label/c.TR_Liability';
import BrokerCharge from '@salesforce/label/c.TR_Broker_Charge';
import MexicanIVATax from '@salesforce/label/c.TR_Mexican_IVA_TAX';
import TOTAL from '@salesforce/label/c.TR_TOTAL';
import ModifiedPolicy from '@salesforce/label/c.TR_Modified_Policy';
import Refundamount from '@salesforce/label/c.TR_Refund_Amount';
import Amountowed from '@salesforce/label/c.TR_Amount_towed';
import Prev from '@salesforce/label/c.TR_Prev';
import Confirm from '@salesforce/label/c.TR_Confirm';
import AmountDueMessage from '@salesforce/label/c.AmountDueMessage';

export default class PolicyEditConfirmScreen extends NavigationMixin(LightningElement) {
    label = {
        OriginalPolicy, Summary, AmountDueMessage, Premium, Surcharge, Medical, Liability, BrokerCharge, MexicanIVATax, TOTAL, ModifiedPolicy, Refundamount, Amountowed, Prev, Confirm,
    };
    @api oldpolicydata;
    @api editpolicydata;
    @api policyType;
    @api changeprevscreen;
    @api changesnextscreen;
    @api refundAmount;
    medicalValue;
    policyRecord;
    quickQuoteDetail;
    quoteId;
    isRefund;
    isGettingError = false;
    isSpinLoad = false;

    async connectedCallback() {
        console.log('--oldpolicydata--', this.oldpolicydata);
        this.policyRecord = this.oldpolicydata.policyData;
        if (this.editpolicydata != '' && this.editpolicydata != null) {
            if (this.policyType == 'Automobile' || this.policyType == 'RV' || this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'Northbound') {
                this.fetchPolicyDetail(this.editpolicydata);
            } else if (this.policyType == 'Watercraft') {
                this.fetchWatercraftpolicyDetail(this.editpolicydata);
            }
        }
    }

    get showMedical() {

        return this.policyType != 'Motorcycle/Street Legal ATV' && this.policyType != 'Watercraft';
    }

    get showWatercraft() {
        return this.policyType == 'Watercraft';
    }
    async fetchWatercraftpolicyDetail(quoteDetails) {
        console.log('---quoteDetails---' + JSON.stringify(quoteDetails));





        let qt = {
            Policy_Type_picklist: "Watercraft",
            Vehicle_Type__c: "Watercraft",
            Type_of_Vessel__c: quoteDetails.quoteData.Type_of_Vessel__c,
            Vessel_Length__c: quoteDetails.quoteData.Vessel_Length__c,
            Start_Date_for_Coverage: quoteDetails.quoteData.Start_Date_for_Coverage__c,
            End_Date_for_Coverage: quoteDetails.quoteData.End_Date_for_Coverage__c,
            Is_the_Maximum_Speed_more_than_50_mph__c: quoteDetails.quoteData.Is_the_Maximum_Speed_more_than_50_mph__c,
            Any_Boat_Operator_Under_22__c: quoteDetails.quoteData.Any_Boat_Operator_Under_22__c,
            Is_the_owner_living_in_Mexico__c: quoteDetails.quoteData.Is_the_owner_living_in_Mexico__c,
            Liability__c: quoteDetails.quoteData.Liability__c,
            Third_Party_Bodily_Injury__c: quoteDetails.quoteData.Third_Party_Bodily_Injury__c,
            Property_Damage_Liability__c: quoteDetails.quoteData.Property_Damage_Liability__c,
            Towed_Unit__c: 'No',
            // Liability__c:quoteDetails.Liability__c
        };

        console.log('Quote Data ::::: ', qt);
        const res = await getWatercraftQuote({
            'requestBody': JSON.stringify(qt),
            'annualTerm': quoteDetails.Term__c != "Annual(One Year)" ? false : true,
        });


        console.log('Res ::::::  ', res);
        console.log('Res Parsed :::: ', JSON.parse(res));
        let parseRes = JSON.parse(res)

        this.quickQuoteDetail = {
            ...this.quickQuoteDetail,
            ['Third_Party_Bodily_Injury__c']:this.policyRecord?.Third_Party_Bodily_Injury__c,
            ['iva']: parseRes.rateRecord.I_V_A_Mex_Tax__c,
            ['Policy_Fee']: parseRes.rateRecord.Broker_Policy_Fee__c,
            ['rateValue']: parseRes.rateRecord.Quote_Value__c,
            ['surcharge']: parseRes.rateRecord.Surcharge__c,
            ['net_premium']: parseRes.rateRecord.Net_Premium__c,
        };
        console.log('--quickQuoteDetail--', this.quickQuoteDetail);

        this.refundAmount = this.quickQuoteDetail.rateValue.toFixed(2) - this.policyRecord.Total_Transaction_Amount__c.toFixed(2);
        this.editpolicydata = {
            ...this.editpolicydata,
            ['quoteData']: {
                ...this.editpolicydata.quoteData,
                ['I_V_A_Mex_Tax__c']: this.quickQuoteDetail.iva,
                ['Broker_Policy_Fee__c']: this.quickQuoteDetail.Policy_Fee,
                ['Term__c']: this.quickQuoteDetail.Term__c == 'Annual' ? 'Annual(One Year)' : this.quickQuoteDetail.Term__c == 'Semi-Annual' ? 'Semi-Annual(Half a Year)' : 'Daily',
                ['Net_Premium__c']: this.quickQuoteDetail.net_premium,
                ['Vehicle_Deductible_Collision__c']: this.quickQuoteDetail.collision_deductible,
                ['Vehicle_Deductible_Comprehensive__c']: this.quickQuoteDetail.theft_Total,
                ['Quote_Value__c']: this.quickQuoteDetail.rateValue,
                ['Term_Days__c']: parseInt(this.quickQuoteDetail.days), ['Surcharge__c']: this.quickQuoteDetail.surcharge || 0
            }
        }


        console.log('--after update value-- 1 ', this.editpolicydata);
    }

    async fetchPolicyDetail(quoteDetails) {
        // let policyData = await getEditPolicyDetail({'policyid':this.policyId});
        //  console.log('---policyId---', policyData);
        // if(policyData.status == 'success'){
        //     this.policyRecord = policyData.data;
        // }
        // console.log('--policyreacord--', this.policyRecord);
        // for new quote rate calcluate
        let liabilityChange;
        let startDateChange;
        let endDateChange;
        let medicalChange;
        let territoryChange;
        let towUnitChange;
        console.log('fetching quote details ');
        console.log(JSON.stringify(quoteDetails));
        let isTowing = quoteDetails?.Is_Towing__c == true ? 'Yes' : quoteDetails.quoteData.Towed_Unit__c == 'Yes' ? 'Yes' : 'No';

        if (quoteDetails.quoteData.Medical__c != undefined && quoteDetails.quoteData.Medical__c != '') {
            let splitMedicalValue = quoteDetails.quoteData.Medical__c.split('/');
            this.medicalValue = '$' + splitMedicalValue[0] + '/$' + splitMedicalValue[1];
        } else {
            this.medicalValue = "$5,000/$25,000";
        }

        if (this.oldpolicydata != undefined && this.editpolicydata != undefined) {
            liabilityChange = this.oldpolicydata.quoteData?.Liability__c != this.editpolicydata.quoteData?.Liability__c ? true : false;
            startDateChange = this.oldpolicydata.quoteData?.Start_Date_for_Coverage__c != this.editpolicydata.quoteData?.Start_Date_for_Coverage__c ? true : false;
            endDateChange = this.oldpolicydata.quoteData?.End_Date_for_Coverage__c != this.editpolicydata.quoteData?.End_Date_for_Coverage__c ? true : false;
            medicalChange = this.oldpolicydata.quoteData?.Medical__c != this.editpolicydata.quoteData?.Medical__c ? true : false;
            territoryChange = this.oldpolicydata.quoteData?.Territory__c != this.editpolicydata.quoteData?.Territory__c ? true : false;
            towUnitChange = this.oldpolicydata.quoteData?.Towed_Unit__c != isTowing ? true : false;
        }

        console.log('quoteDetails check->', quoteDetails);

        let Underwriter = quoteDetails.quoteData.Underwriter__c == 'Qualitas' ? 'qualitasQuote' : quoteDetails.quoteData.Underwriter__c == 'Chubb' ? 'chubbQuote' : 'mapfreQuote'

        console.log('Underwriter check->', Underwriter);

        let qt = {
            Policy_Type_picklist: quoteDetails.quoteData.Vehicle_Type__c == 'Car/Truck/Auto' ? 'Automobile' : quoteDetails.quoteData.Vehicle_Type__c,
            Vehicle_Type: quoteDetails.quoteData.Vehicle_Type__c,
            Territory: quoteDetails.quoteData.Territory__c,
            Is_there_a_driver_under_21: quoteDetails.quoteData.Is_there_a_driver_under_21__c,
            Salvage_Vehicle: quoteDetails.quoteData.Salvage_Vehicle__c,
            Vehicle_used_for_Business_Purposes: quoteDetails.quoteData.Vehicle_used_for_Business_Purposes__c ? 'Yes' : 'No',
            Is_Rental_Vehicle: quoteDetails.quoteData.Is_this_a_Rental_Vehicle__c ? 'Yes' : 'No',
            Vehicle_Sub_Type: quoteDetails.quoteData.Vehicle_Sub_type__c,
            Vehicle_Value: quoteDetails.quoteData.Vehicle_Value__c,
            Start_Date_for_Coverage: quoteDetails.quoteData.Start_Date_for_Coverage__c,
            End_Date_for_Coverage: quoteDetails.quoteData.End_Date_for_Coverage__c,
            Liability: this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '') || "300000",
            Liability_Type: quoteDetails.quoteData.Coverage__c || "Complete",
            Medical: this.medicalValue,
            Is_Towing: isTowing,
            towedUnits: quoteDetails?.towedUnitData.length > 0 ? quoteDetails?.towedUnitData : [],
        };

        console.log('qt check->', JSON.stringify(qt));

        const res = this.policyType == 'Northbound'? await getNorthboundQuote({
            'requestBody': JSON.stringify(qt),
            'liability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '')

        }):
         await getQuote({
            'requestBody': JSON.stringify(qt),
            'qualitasLiability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, ''),
            'chubbLiability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, ''),
            'mapfreLiability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, ''),
            'qualitasMedical': this.medicalValue,
            'chubbMedical': this.medicalValue,
            'mapfreMedical': this.medicalValue

        });
        console.log(res);
        let parseRes = JSON.parse(res);
        this.quickQuoteDetail = this.policyType == 'Northbound'?parseRes: parseRes[Underwriter];

        console.log('parseRes Data->', parseRes);
        console.log('quickQuoteDetail Data->', this.quickQuoteDetail);
        console.log('rateValue Data->', this.quickQuoteDetail.rateValue);
        console.log('policyRecord Data->', this.policyRecord.Total_Transaction_Amount__c);

        if (liabilityChange || startDateChange || endDateChange || medicalChange || territoryChange || towUnitChange) {
            this.refundAmount = parseInt(this.quickQuoteDetail?.rateValue)?.toFixed(2) - this.policyRecord?.Total_Transaction_Amount__c?.toFixed(2);

            console.log('refundAmount Data With Amount->', this.refundAmount);

            this.quickQuoteDetail = { ...this.quickQuoteDetail, ['surcharge']: this.quickQuoteDetail?.surcharge || 0 }
            this.editpolicydata = {
                ...this.editpolicydata,
                ['quoteData']: {
                    ...this.editpolicydata?.quoteData,
                    ['I_V_A_Mex_Tax__c']: this.quickQuoteDetail?.iva,
                    ['Broker_Policy_Fee__c']: this.quickQuoteDetail?.Policy_Fee,
                    ['Term__c']: this.quickQuoteDetail?.Term__c == 'Annual' ? 'Annual(One Year)' : this.quickQuoteDetail?.Term__c == 'Semi-Annual' ? 'Semi-Annual(Half a Year)' : 'Daily',
                    ['Net_Premium__c']: this.quickQuoteDetail?.net_premium,
                    ['Vehicle_Deductible_Collision__c']: this.quickQuoteDetail?.collision_deductible,
                    ['Vehicle_Deductible_Comprehensive__c']: this.quickQuoteDetail?.theft_Total,
                    ['Quote_Value__c']: this.quickQuoteDetail?.rateValue,
                    ['Term_Days__c']: parseInt(this.quickQuoteDetail?.days),
                    ['Surcharge__c']: this.quickQuoteDetail?.surcharge || 0
                }
            }
        } else {
            this.refundAmount = 0;
            this.editpolicydata = { ...this.editpolicydata };
            this.quickQuoteDetail = {
                ...this.quickQuoteDetail,
                ['net_premium']: this.policyRecord?.Net_Premium__c,
                ['rateValue']: this.policyRecord?.Total_Premium_Amount__c,
                ['surcharge']: this.policyRecord?.Surcharge__c,
                ['Policy_Fee']: this.policyRecord?.Broker_Policy_Fee__c,
                ['iva']: this.policyRecord?.I_V_A_Mex_Tax__c,
            }
        }

        console.log('Test Refund value ', this.refundAmount);


        console.log('--after update value--', this.editpolicydata);
    }
    handleNext = async () => {
        console.log('--call the payment method--');
        console.log('this.editpolicydata--', this.editpolicydata);
        console.log('this.editpolicydata--', JSON.stringify(this.oldpolicydata.quoteData, null, 4));
        this.isSpinLoad = true;
        let quoteCompare = this.compareData(this.oldpolicydata?.quoteData, this.editpolicydata?.quoteData);
        let vehicleCompare;
        if (this.policyType != 'Watercraft') {
            vehicleCompare = this.compareData(this.oldpolicydata?.vehicleData, this.editpolicydata?.vehicleData);
        } else {
            vehicleCompare = this.compareData(this.oldpolicydata?.watercraftData, this.editpolicydata?.watercraftData);
        }
        console.log('--changesValue quoteCompare--', quoteCompare);
        console.log('--changesValue vehicleCompare--', vehicleCompare);
        const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
            detail: this.editpolicydata,
        });

        this.dispatchEvent(editPolicyChange);
        const refundAmountChange = new CustomEvent('refundamountchange', {
            detail: this.refundAmount,
        });
        this.dispatchEvent(refundAmountChange);

        if (this.refundAmount == 0) {
            console.log('comes inside only for update data');
            const data = await updatePolicyDetails({ 'quoteData': JSON.stringify(this.editpolicydata.quoteData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'vehicleData': JSON.stringify(this.editpolicydata.vehicleData), 'towedUnitData': this.editpolicydata.towedUnitData.length > 0 ? JSON.stringify(this.editpolicydata.towedUnitData) : '' });

            if (data.status == 'success') {
                this.goToDetailPage();
            } else {
                this.generateLogs();
                console.log('occur error', JSON.stringify(data, null, 4));
            }
        } else if (this.refundAmount > 0) {
            this.changesnextscreen();
            console.log('comes inside create transaction for charge');
            // const data = await updatePolicyDetails({'quoteData':quoteCompare ? JSON.stringify(this.editpolicydata.quoteData) : null, 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'vehicleData': vehicleCompare ? JSON.stringify(this.editpolicydata.vehicleData) : null , 'towedUnitData':  this.editpolicydata.towedUnitData.length() > 0 ? JSON.stringify(this.editpolicydata.towedUnitData) : null})

        } else if (this.refundAmount < 0) {
            this.changesnextscreen();
            console.log('comes inside create transaction for refund');
        }
        this.isSpinLoad = false;

    }

    compareData(oldData, newData) {
        let abc = oldData != undefined && Object.keys(oldData);
        let policyCompare = [];

        abc.map((key) => {
            if (oldData[key] != newData[key]) {
                policyCompare.push(false);
            }
        })

        let changesValue = policyCompare.includes(false);
        return changesValue;
    }

    goToDetailPage() {
        console.log('goToDetailPage start');
        let recordId = this.oldpolicydata.policyData.Id;

        //added by dev to redirect to new policy record
        //var newPolicyId = component.get("v.newPolicyId");
        // if( newPolicyId !=  undefined && newPolicyId != null ){
        // 	recordId = newPolicyId;
        // }

        // let pageName = '/policy/';
        // let currentPagePrefix = '/editpolicy';


        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            },
            state: {
                nooverride: '1'
            }
        });

    }

    handlePrevClick = () => {
        console.log('clicked on previous page: ');
        const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
            detail: this.editpolicydata,
        });
        this.dispatchEvent(editPolicyChange);
        console.log('clicked on previous page: ');
        this.changeprevscreen();

    }
    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }

}