import { api, LightningElement } from 'lwc';
import getQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getQuote';
import getNorthboundQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundQuote';
import getWatercraftQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getWatercraftQuote';
import updatePolicyDetails from '@salesforce/apex/Mex_PolicyEditController.updatePolicyDetails';
import calculateTotalCoverage from '@salesforce/apex/CalculateCoverage.calculateTotalCoverage';
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

export default class EditUnderwriterScreen extends NavigationMixin(LightningElement) {
    label = {
        OriginalPolicy, Summary, AmountDueMessage, Premium, Surcharge, Medical, Liability, BrokerCharge, MexicanIVATax, TOTAL, ModifiedPolicy, Refundamount, Amountowed, Prev, Confirm,
    };
    @api oldpolicydata;
    @api editpolicydata;
    @api policyType;
    @api changeprevscreen;
    @api changesnextscreen;
    @api refundAmount;
    @api selectedQuote;
    @api agentFee;
    medicalValue;
    policyRecord;
    quickQuoteDetail;
    quoteId;
    isRefund;
    isGettingError = false;
    isSpinLoad = false;

    async connectedCallback() {
        console.log('--oldpolicydata--', this.oldpolicydata);
        console.log('--oldpolicydata--', JSON.stringify(this.oldpolicydata));
        console.log('--newpolicydata--', JSON.stringify(this.editpolicydata));

        this.policyRecord = this.oldpolicydata.policyData;
        if(this.policyRecord){
            this.agentFee = this.policyRecord.Agent_Brokerage_Fee__c == '0' ? this.policyRecord.Agent_Fee__c : this.policyRecord.Agent_Brokerage_Fee__c;
            console.log('Agent Fee in connected Callback',this.agentFee);

        }
        if (this.editpolicydata != '' && this.editpolicydata != null) {
            // if (this.policyType == 'Automobile' || this.policyType == 'RV' || this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'Northbound') {
                this.fetchPolicyDetail(this.editpolicydata);
            // } else if (this.policyType == 'Watercraft') {
            //     this.fetchWatercraftpolicyDetail(this.editpolicydata);
            // }
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

 // async fetchPolicyDetail(quoteDetails) {
    //     // let policyData = await getEditPolicyDetail({'policyid':this.policyId});
    //     //  console.log('---policyId---', policyData);
    //     // if(policyData.status == 'success'){
    //     //     this.policyRecord = policyData.data;
    //     // }
    //     // console.log('--policyreacord--', this.policyRecord);
    //     // for new quote rate calcluate
    //     let liabilityChange;
    //     let startDateChange;
    //     let endDateChange;
    //     let medicalChange;
    //     let territoryChange;
    //     let towUnitChange;
    //     let amountChange;
    //     console.log('fetching quote details ');
    //     console.log(JSON.stringify(quoteDetails));
    //     let isTowing = quoteDetails?.Is_Towing__c == true ? 'Yes' : quoteDetails.quoteData.Towed_Unit__c == 'Yes' ? 'Yes' : 'No';
    //     console.log(quoteDetails.quoteData.Medical__c);
    //     if (quoteDetails.quoteData.Medical__c != undefined && quoteDetails.quoteData.Medical__c != '') {
    //         let splitMedicalValue = quoteDetails.quoteData.Medical__c.split('/');
    //         this.medicalValue = '$' + splitMedicalValue[0] + '/$' + splitMedicalValue[1];
    //     } else {
    //         this.medicalValue = "$5,000/$25,000";
    //     }

    //     if (this.oldpolicydata != undefined && this.editpolicydata != undefined) {
    //         liabilityChange = this.oldpolicydata.quoteData?.Liability__c != this.editpolicydata.quoteData?.Liability__c ? true : false;
    //         startDateChange = this.oldpolicydata.quoteData?.Start_Date_for_Coverage__c != this.editpolicydata.quoteData?.Start_Date_for_Coverage__c ? true : false;
    //         endDateChange = this.oldpolicydata.quoteData?.End_Date_for_Coverage__c != this.editpolicydata.quoteData?.End_Date_for_Coverage__c ? true : false;
    //         medicalChange = this.oldpolicydata.quoteData?.Medical__c != this.editpolicydata.quoteData?.Medical__c ? true : false;
    //         territoryChange = this.oldpolicydata.quoteData?.Territory__c != this.editpolicydata.quoteData?.Territory__c ? true : false;
    //         towUnitChange = (this.oldpolicydata.quoteData?.Towed_Unit__c != isTowing || (
    //             (this.oldpolicydata.towedUnitData && this.oldpolicydata.towedUnitData.length)
    //             != (this.editpolicydata.towedUnitData && this.editpolicydata.towedUnitData.length)
    //             ) 
    //             )? true : false;
    //         amountChange = this.oldpolicydata.quoteData?.Vehicle_Value__c != this.editpolicydata.quoteData?.Vehicle_Value__c ? true : false;
    //     }

    //     console.log('quoteDetails check->', quoteDetails);

    //     let Underwriter = quoteDetails.quoteData.Underwriter__c == 'Qualitas' ? 'qualitasQuote' : quoteDetails.quoteData.Underwriter__c == 'Chubb' ? 'chubbQuote' : 'mapfreQuote'

    //     console.log('Underwriter check->', Underwriter);

    //     let qt = {
    //         Policy_Type_picklist: quoteDetails.quoteData.Vehicle_Type__c == 'Car/Truck/Auto' ? 'Automobile' : quoteDetails.quoteData.Vehicle_Type__c,
    //         Vehicle_Type: quoteDetails.quoteData.Vehicle_Type__c,
    //         Territory: quoteDetails.quoteData.Territory__c,
    //         Is_there_a_driver_under_21: quoteDetails.quoteData.Is_there_a_driver_under_21__c,
    //         Salvage_Vehicle: quoteDetails.quoteData.Salvage_Vehicle__c,
    //         Vehicle_used_for_Business_Purposes: quoteDetails.quoteData.Vehicle_used_for_Business_Purposes__c ? 'Yes' : 'No',
    //         Is_Rental_Vehicle: quoteDetails.quoteData.Is_this_a_Rental_Vehicle__c ? 'Yes' : 'No',
    //         Vehicle_Sub_Type: this.editpolicydata?.quoteData?.Vehicle_Sub_type__c ? this.editpolicydata.quoteData.Vehicle_Sub_type__c : this.editpolicydata.vehicleData.Vehicle_Type__c ,
    //         Vehicle_Sub_Type: quoteDetails?.quoteData?.Vehicle_Sub_type__c ? quoteDetails.quoteData.Vehicle_Sub_type__c : quoteDetails.vehicleData.Vehicle_Type__c,
    //         Vehicle_Value: quoteDetails.quoteData.Vehicle_Value__c,
    //         Start_Date_for_Coverage: quoteDetails.quoteData.Start_Date_for_Coverage__c,
    //         End_Date_for_Coverage: quoteDetails.quoteData.End_Date_for_Coverage__c,
    //         Liability: this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '') || "300000",
    //         Liability_Type: quoteDetails.quoteData.Coverage__c || "Complete",
    //         Medical: this.medicalValue,
    //         Is_Towing: isTowing,
    //         towedUnits: quoteDetails?.towedUnitData.length > 0 ? quoteDetails?.towedUnitData : [],
    //     };

    //     console.log('qt check->', JSON.stringify(qt));

    //     const res = this.policyType == 'Northbound'? await getNorthboundQuote({
    //         'requestBody': JSON.stringify(qt),
    //         'liability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '')

    //     }):
    //      await getQuote({
    //         'requestBody': JSON.stringify(qt),
    //         'qualitasLiability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, ''),
    //         'chubbLiability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, ''),
    //         'mapfreLiability': this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, ''),
    //         'qualitasMedical': this.medicalValue,
    //         'chubbMedical': this.medicalValue,
    //         'mapfreMedical': this.medicalValue

    //     });
    //     console.log(res);
    //     let parseRes = JSON.parse(res);
    //     this.quickQuoteDetail = this.policyType == 'Northbound'?parseRes: parseRes[Underwriter];
        
    //     // 7 Aug update on the agent fee
    //     if(this.oldpolicydata.policyData.Agent_Fee__c != null){
    //         this.agentFee = this.oldpolicydata.policyData.Agent_Fee__c;
    //         this.quickQuoteDetail = {...this.quickQuoteDetail,['Policy_Fee']:this.quickQuoteDetail.Policy_Fee + this.agentFee };
    //         this.quickQuoteDetail = {...this.quickQuoteDetail,['rateValue']:this.quickQuoteDetail.rateValue + this.agentFee };
    //     }

    //     console.log('parseRes Data->', parseRes);
    //     console.log('quickQuoteDetail Data->', this.quickQuoteDetail);
    //     console.log('rateValue Data->', this.quickQuoteDetail.rateValue);
    //     console.log('policyRecord Data->', this.policyRecord.Total_Transaction_Amount__c);

    //     if (liabilityChange || startDateChange || endDateChange || medicalChange || territoryChange || towUnitChange || amountChange) {
    //         this.refundAmount =  JSON.parse(JSON.stringify(this.quickQuoteDetail?.rateValue?.toFixed(2) - this.policyRecord?.Total_Transaction_Amount__c?.toFixed(2)));
    //         this.refundAmount = this.refundAmount.toFixed(2);
    //         console.log('refundAmount Data With Amount->', this.refundAmount);

    //         this.quickQuoteDetail = { ...this.quickQuoteDetail, ['surcharge']: this.quickQuoteDetail?.surcharge || 0 }
    //         this.editpolicydata = {
    //             ...this.editpolicydata,
    //             ['quoteData']: {
    //                 ...this.editpolicydata?.quoteData,
    //                 ['I_V_A_Mex_Tax__c']: this.quickQuoteDetail?.iva,
    //                 ['Broker_Policy_Fee__c']: this.quickQuoteDetail?.Policy_Fee,
    //                 ['Term__c']: this.quickQuoteDetail?.Term__c == 'Annual' ? 'Annual(One Year)' : this.quickQuoteDetail?.Term__c == 'Semi-Annual' ? 'Semi-Annual(Half a Year)' : 'Daily',
    //                 ['Net_Premium__c']: this.quickQuoteDetail?.net_premium,
    //                 ['Vehicle_Deductible_Collision__c']: this.quickQuoteDetail?.collision_deductible,
    //                 ['Vehicle_Deductible_Comprehensive__c']: this.quickQuoteDetail?.theft_Total,
    //                 ['Quote_Value__c']: this.quickQuoteDetail?.rateValue,
    //                 ['Term_Days__c']: parseInt(this.quickQuoteDetail?.days),
    //                 ['Agent_Fee__c']: this.agentFee,
    //                 ['Surcharge__c']: this.quickQuoteDetail?.surcharge || 0
    //             }
    //         }
    //     } else {
    //         this.refundAmount = 0;
    //         this.editpolicydata = { ...this.editpolicydata };
    //         this.quickQuoteDetail = {
    //             ...this.quickQuoteDetail,
    //             ['net_premium']: this.policyRecord?.Net_Premium__c,
    //             ['rateValue']: this.policyRecord?.Total_Premium_Amount__c,
    //             ['surcharge']: this.policyRecord?.Surcharge__c,
    //             ['Policy_Fee']: this.policyRecord?.Broker_Policy_Fee__c,
    //             ['iva']: this.policyRecord?.I_V_A_Mex_Tax__c,
    //         }
    //     }

    //     console.log('Test Refund value ', this.refundAmount);


    //     console.log('--after update value--', this.editpolicydata);
// }

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

        let Underwriter = quoteDetails.quoteData.Underwriter__c;

        console.log('Underwriter check->', Underwriter);

        let qt = {
            Policy_Type_picklist: quoteDetails.quoteData.Vehicle_Type__c == '' ? 'Automobile-Van-Minivan' : quoteDetails.quoteData.Vehicle_Type__c,
            Vehicle_Type: quoteDetails.quoteData.Vehicle_Type__c,
            Vehicle_Sub_Type: quoteDetails.quoteData.Vehicle_Sub_type__c || quoteDetails.quoteData.Vehicle_Type__c
        };

        // console.log('qt check->', JSON.stringify(qt));

        const transformedPayload = this.transformPolicyData(this.editpolicydata, this.oldpolicydata);
        console.log(JSON.stringify(transformedPayload, null, 2));

        const res = await calculateTotalCoverage({ jsonString: JSON.stringify(transformedPayload) });

        let parseRes = res;

        this.selectedQuote = parseRes[Underwriter];
        this.selectedQuote = { ...this.selectedQuote, ['Vendor']: Underwriter };

        let quoteDataMapped = await this.createDataForQuoteSave(transformedPayload);
        this.quickQuoteDetail = { ...this.quickQuoteDetail, ...quoteDataMapped, ...this.selectedQuote };

        console.log('parseRes Data->', parseRes);
        console.log('quickQuoteDetail Data->', this.quickQuoteDetail);
        console.log('Transformed Data->', quoteDataMapped);
        console.log('policyRecord Data->', this.policyRecord.Total_Transaction_Amount__c);

        if (liabilityChange || startDateChange || endDateChange || medicalChange || territoryChange || towUnitChange) {
            const total = parseFloat(this.quickQuoteDetail?.Quote_Value__c);
            const transactionTotal = parseFloat(this.policyRecord?.Total_Transaction_Amount__c);

            if (!isNaN(total) && !isNaN(transactionTotal)) {
                this.refundAmount = (total - transactionTotal).toFixed(2);
            } else {
                this.refundAmount = 0; // or 0, or handle error appropriately
            }
            console.log('refundAmount Data With Amount->', this.refundAmount);

            this.quickQuoteDetail = { ...this.quickQuoteDetail, ['surcharge']: this.quickQuoteDetail?.TotalSurcharges || 0 }
            this.editpolicydata = {
                ...this.editpolicydata,
                ['quoteData']: {
                    ...this.editpolicydata?.quoteData,
                    ...quoteDataMapped,
                    ...qt
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

        const paymentscreenEvent = new CustomEvent('navigatepaymentscreen',{
            detail:{
                'editPolicyData':this.editpolicydata?.quoteData,
                'amountDifference':this.refundAmount
            }
        });
        this.dispatchEvent(paymentscreenEvent);
        this.isSpinLoad = false;
        return;

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
        let cstEvent = new CustomEvent('navigatequotescreen',{
            detail:'pre-quote'
        });
        this.dispatchEvent(cstEvent);

    }
    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
    transformPolicyData(editPolicyData, oldPolicyData) {
        console.log('Data in transformPolicyData editPolicyData', editPolicyData);
        console.log('Data in transformPolicyData oldPolicyData', oldPolicyData);
        const getSafe = (primary, secondary, path, defaultValue = null) => {
            const traverse = (obj, p) =>
                p.split('.').reduce((acc, part) => (acc && acc[part] !== undefined) ? acc[part] : undefined, obj);

            const primaryValue = traverse(primary, path);
            if (primaryValue !== undefined && primaryValue !== null) return primaryValue;

            const secondaryValue = traverse(secondary, path);
            return (secondaryValue !== undefined && secondaryValue !== null) ? secondaryValue : defaultValue;
        };

        const formatTime = (timeValue) => {
            console.log('Time value',timeValue);
            if (!timeValue) return '00:00:00';

            // Already in HH:MM:SS format
            if (typeof timeValue === 'string' && /^\d{2}:\d{2}:\d{2}$/.test(timeValue)) {
                console.log('First If',timeValue);
                return timeValue;
            }

            // If time is in ISO format like "11:00:00.000Z"
            if (typeof timeValue === 'string' && /^\d{2}:\d{2}:\d{2}\.\d{3}Z?$/.test(timeValue)) {
                console.log('Second If', timeValue);
                return timeValue.split('.')[0]; // Extract "HH:MM:SS"
            }

            // If it's a number (milliseconds)
            if (typeof timeValue === 'number') {
                console.log('Third If',timeValue);
                const totalSeconds = Math.floor(timeValue / 1000);
                const hours = Math.floor(totalSeconds / 3600);
                const minutes = Math.floor((totalSeconds % 3600) / 60);
                const seconds = totalSeconds % 60;
                return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            }

            return '00:00:00'; // fallback
        };


        const inputPrimary = editPolicyData || {};
        const inputFallback = oldPolicyData || {};

        const userDetails = {
            Email: getSafe(inputPrimary, inputFallback, 'policyData.Contact_Email__c', ''),
            FirstName: getSafe(inputPrimary, inputFallback, 'DriverData.0.First_Name__c', ''),
            LastName: getSafe(inputPrimary, inputFallback, 'DriverData.0.Last_Name__c', ''),
            Phone: '',
            Id: getSafe(inputPrimary, inputFallback, 'DriverData.0.Contact__c', '')
        };

        console.log('user DEtails', userDetails);

        const isBusinessUse = getSafe(inputPrimary, inputFallback, 'vehicleData.Is_the_vehicle_used_for_business_purpose__c', false);
        const isRental = getSafe(inputPrimary, inputFallback, 'vehicleData.Rental__c', 'No') === 'Yes';
        const isSalvage = getSafe(inputPrimary, inputFallback, 'vehicleData.Salvage_Vehicle__c', false);
        const isElectric = getSafe(inputPrimary, inputFallback, 'vehicleData.Electric_Hybrid__c', false);
        const isTowing = getSafe(inputPrimary, inputFallback, 'Is_Towing__c', false)
            || ((inputPrimary.towedUnitData || inputFallback.towedUnitData || []).length > 0);

        const towunitsRaw = inputPrimary.towedUnitData || inputFallback.towedUnitData || [];

        const towunitsList = towunitsRaw.map(towUnit => ({
            Towed_Unit_Type__c: towUnit.Towed_Unit_Type__c || '',
            Towed_Unit_Value__c: towUnit.Towed_Unit_Value__c || '0',
            Days_in_Tow__c: towUnit.Days_in_Tow__c || '1',
            count: 1,
            isDeleteButton: true,
            style: "",
            Year__c: towUnit.Year__c || '',
            Make__c: towUnit.Make__c || '',
            Model__c: towUnit.Model__c || '',
            VIN_Number__c: towUnit.VIN_Number__c || '',
            Plate__c: towUnit.Plate__c || '',
            label: `${towUnit.Make__c || ''} ${towUnit.Model__c || ''} ${towUnit.Year__c || ''} - ${towUnit.VIN_Number__c || ''}`,
            value: towUnit.Id || '',
            Id: towUnit.Id || ''
        }));
        console.log('Towed Unit List', towunitsList);

        const vehicleDetails = {
            is_the_vehicle_used_for_business_purpose__c: isBusinessUse,
            is_there_a_driver_under_21__c: getSafe(inputPrimary, inputFallback, 'quoteData.Is_there_a_driver_under_21__c', 'false') === 'true',
            Is_this_a_Rental_Vehicle__c: isRental,
            salvage_vehicle__c: isSalvage,
            Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.Coverage__c', 'Complete'),
            isTowing: isTowing,
            Electric_Hybrid__c: isElectric,
            towunits: towunitsList,
            Liability__c: getSafe(inputPrimary, inputFallback, 'quoteData.Liability__c', '100,000'),
            Medical__c: getSafe(inputPrimary, inputFallback, 'quoteData.Medical__c', '10,000/50,000'),
            Year__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Year__c', ''),
            Vehicle_sub_type__c: getSafe(inputPrimary, inputFallback, 'policyData.Policy_Type_picklist__c', 'Automobile-Van-Minivan'),
            Make: getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', ''),
            Model: getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', ''),
            Value__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Value__c', '0'),
            towunitsList: towunitsList,
            vehicleList: [
                {
                    Id: getSafe(inputPrimary, inputFallback, 'vehicleData.Id', ''),
                    label: `${getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', '')} ${getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', '')} ${getSafe(inputPrimary, inputFallback, 'vehicleData.Year__c', '')} - ${getSafe(inputPrimary, inputFallback, 'vehicleData.Vin__c', '')}`,
                    value: getSafe(inputPrimary, inputFallback, 'vehicleData.Id', ''),
                    Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.Coverage__c', 'Complete'),
                    Electric_Hybrid__c: isElectric,
                    Liability__c: getSafe(inputPrimary, inputFallback, 'quoteData.Liability__c', '100,000'),
                    Medical__c: getSafe(inputPrimary, inputFallback, 'quoteData.Medical__c', '10,000/50,000'),
                    Year__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Year__c', ''),
                    Vehicle_sub_type__c: getSafe(inputPrimary, inputFallback, 'policyData.Policy_Type_picklist__c', 'Automobile-Van-Minivan'),
                    Make: getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', ''),
                    Model: getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', ''),
                    Value__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Value__c', '0'),
                    Vin__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Vin__c', ''),
                    Registered_Country__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Country__c', ''),
                    Registered_State__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_State__c', ''),
                    licensePlate: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Plate__c', '')
                }
            ],
            Vin__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Vin__c', ''),
            Registered_Country__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Country__c', ''),
            Registered_State__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_State__c', ''),
            licensePlate: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Plate__c', ''),
            Id: getSafe(inputPrimary, inputFallback, 'vehicleData.Id', ''),
            Make__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', ''),
            Model__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', ''),
            Account_Vehicle__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Account_Vehicle__c', ''),
            Contact__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Contact__c', '')
        };
        console.log('Vehicle Details', vehicleDetails);

        const driverRaw = getSafe(inputPrimary, inputFallback, 'DriverData', []);
        const driverDetails = {
            drivers: driverRaw.map(driver => ({
                Id: driver.Id || '',
                label: `${driver.First_Name__c || ''} ${driver.Last_Name__c || ''} - ${driver.Dob__c || ''} - ${driver.license_number__c || ''}`,
                value: driver.Id || '',
                First_Name__c: driver.First_Name__c || '',
                Last_Name__c: driver.Last_Name__c || '',
                License_Country__c: driver.License_Country__c || '',
                License_state__c: driver.License_state__c || '',
                license_number__c: driver.license_number__c || '',
                Dob__c: driver.Dob__c || '',
                Driver_Type__c: driver.Driver_Type__c === 'Owner',
                Country__c: driver.Country__c || '',
                Country_Text__c: driver.Country__c || '',
                State_Province__c: driver.State_Province__c || '',
                Postal_Code__c: driver.Postal_Code__c || '',
                City__c: driver.City__c || '',
                Address__c: driver.Address__c || '',
                diff: Date.now()
            })),
            companyInformation: {},
        };

        const termOption = {
            Term__c: getSafe(inputPrimary, inputFallback, 'quoteData.Term__c', 'Daily'),
            Start_Date_for_Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.Start_Date_for_Coverage__c', ''),
            Start_Time__c: formatTime(getSafe(inputPrimary, inputFallback, 'quoteData.Start_Time__c', '19800000')),
            End_Date_for_Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.End_Date_for_Coverage__c', ''),
            End_Time__c: formatTime(getSafe(inputPrimary, inputFallback, 'quoteData.End_Time__c', '19800000')),
            Gold__c :  getSafe(inputPrimary, inputFallback, 'quoteData.Gold__c', 'false'),
            Max__c :  getSafe(inputPrimary, inputFallback, 'quoteData.Max__c', 'false'),
            Platinum__c :  getSafe(inputPrimary, inputFallback, 'quoteData.Platinum__c', 'false')
        };
        console.log('Term option-->',termOption);
        return [
            { userDetails },
            { vehicleDetails },
            { UserType: { UserType: "Customer" } },
            { termOption },
            { territory: { region: getSafe(inputPrimary, inputFallback, 'quoteData.Territory__c', '') } },
            { driverDetails }
        ];
    }

    async createDataForQuoteSave(transformedData) {
        const dataMap = {};
        const finalJson = transformedData;

        finalJson.forEach((entry) => {
            const [key, value] = Object.entries(entry)[0];
            dataMap[key] = value;
        });

        const calculateDaysWithNewDate = (startDateStr, endDateStr) => {
            const startDate = new Date(startDateStr);
            const endDate = new Date(endDateStr);
            const diffMs = endDate - startDate;
            return diffMs / (1000 * 60 * 60 * 24);
        };

        const termDays = calculateDaysWithNewDate(
            dataMap?.termOption?.Start_Date_for_Coverage__c,
            dataMap?.termOption?.End_Date_for_Coverage__c
        );

        const selectedQuote = this.selectedQuote || {}; // Use selectedQuote from component context
        const agentFee = this.agentFee || 0;
        const underwriter = this.selectedQuote?.Vendor != null ? this.selectedQuote?.Vendor : 'Error Vendor';
        const company = dataMap?.territory?.region;
        const dataId = dataMap?.userDetails?.Id;


        let vehicleCollision;
        let vehicleTheft;
        let vehicleValue = dataMap?.vehicleDetails?.Value__c;
        if (underwriter.toLowerCase() === 'mapfre') {
            if ((dataMap?.vehicleDetails?.Coverage__c || '').toLowerCase() === 'liability') {
                vehicleCollision = null; // This will become "" in JSON, not null
                vehicleTheft = null;
            } else {
                let updatedVehicleValueCollision = Number(vehicleValue) * 0.02;
                let updatedVehicleValueTheft = Number(vehicleValue) * 0.05;
                if (this.checkedData?.Max__c === true) {
                    vehicleCollision = '500';
                    vehicleTheft = '1000';
                } else {
                    vehicleCollision = updatedVehicleValueCollision > 500 ? String(updatedVehicleValueCollision) : '500';
                    vehicleTheft = updatedVehicleValueTheft > 1000 ? String(updatedVehicleValueTheft) : '1000';                     
                }
            }
        }
        if (underwriter.toLowerCase() === 'chubb') {
            if ((dataMap?.vehicleDetails?.Coverage__c || '').toLowerCase() === 'liability') {
                vehicleCollision = null; // This will become "" in JSON, not null
                vehicleTheft = null;
            } else {
                    vehicleCollision = '500';
                    vehicleTheft = '1000';
            }
        }
        if (underwriter.toLowerCase() === 'qualitas') {
            if ((dataMap?.vehicleDetails?.Coverage__c || '').toLowerCase() === 'liability') {
                vehicleCollision = null; // This will become "" in JSON, not null
                vehicleTheft = null;
            } else {
                if (this.checkedData?.Gold__c === true) {
                    vehicleCollision = '500';
                    vehicleTheft = '1000';
                } else {
                    vehicleCollision = '1000';
                    vehicleTheft = '1000';                     
                }
            }
        }

        const dataMapped = {
            Start_Date_for_Coverage__c: dataMap?.termOption?.Start_Date_for_Coverage__c,
            End_Date_for_Coverage__c: dataMap?.termOption?.End_Date_for_Coverage__c,
            Start_Time__c: dataMap?.termOption?.Start_Time__c,
            End_Time__c: dataMap?.termOption?.End_Time__c,

            Vehicle_used_for_Business_Purposes__c: dataMap?.vehicleDetails?.is_the_vehicle_used_for_business_purpose__c || false,
            Is_there_a_driver_under_21__c: dataMap?.vehicleDetails?.is_there_a_driver_under_21__c || false,
            Is_this_a_Rental_Vehicle__c: dataMap?.vehicleDetails?.Is_this_a_Rental_Vehicle__c === 'Yes',

            Vehicle_Make__c: dataMap?.vehicleDetails?.Make__c,
            Vehicle_Model__c: dataMap?.vehicleDetails?.Model__c,
            Salvage_Vehicle__c: dataMap?.vehicleDetails?.salvage_vehicle__c,
            Vehicle_Value__c: dataMap?.vehicleDetails?.Value__c,
            Vehicle_Year__c: dataMap?.vehicleDetails?.Year__c,

            // Vehicle_Type__c: dataMap?.vehicleDetails?.Vehicle_sub_type__c,
            // Policy_Type_picklist__c: dataMap?.vehicleDetails?.Vehicle_sub_type__c,

            Term__c: dataMap?.termOption?.Term__c,
            Territory__c: company,

            Net_Premium__c: (parseFloat(selectedQuote?.Total) - parseFloat(selectedQuote?.IVA) - parseFloat(selectedQuote?.BrokerFee) - parseFloat(selectedQuote?.TotalSurcharges) - parseFloat(selectedQuote?.AgentFee) + parseFloat(Number(agentFee))).toFixed(2),
            Broker_Policy_Fee__c: selectedQuote?.BrokerFee,
            Term_Days__c: termDays != null ? termDays : '0', // Add Days
            I_V_A_Mex_Tax__c: selectedQuote?.IVA,
            Quote_Value__c: (parseFloat(selectedQuote?.Total) - parseFloat(selectedQuote?.AgentFee) + parseFloat(Number(agentFee))).toFixed(2),
            Surcharge__c: selectedQuote?.TotalSurcharges,

            Underwriter__c: underwriter,

            Coverage__c: dataMap?.vehicleDetails?.Coverage__c,
            Towed_Unit__c: dataMap?.vehicleDetails?.isTowing,

            Vehicle_deductible_comprehensive__c: vehicleTheft ?? null,
            Vehicle_deductible_collision__c: vehicleCollision ?? null,
            Physical_Damage__c: selectedQuote?.PropertyDamage || '',
            Total_Theft_Payment__c: selectedQuote?.TotalTheft || '',
            Liability_Payment__c: selectedQuote?.Liability || '',
            Medical_Payment__c: selectedQuote?.Medical || '',
            Platinum_Endorsment__c: selectedQuote?.platinumEndorsementPayment || '',

            Liability__c: dataMap?.vehicleDetails?.Liability__c,
            Medical__c: dataMap?.vehicleDetails?.Medical__c,

            Agent_Fee__c: agentFee,
            Old_Net_Premium__c: (parseFloat(selectedQuote?.Total) - parseFloat(selectedQuote?.AgentFee) + parseFloat(Number(agentFee))).toFixed(2),

            Gold__c: underwriter.toLowerCase() === 'qualitas' ? this.policyRecord?.Gold__c || false : false,
            Max__c: underwriter.toLowerCase() === 'mapfre' ? this.policyRecord?.Max__c || false : false,
            Platinum__c: underwriter.toLowerCase() === 'chubb' ? this.policyRecord?.Platinum__c || false : false
        };

        console.log('Final Payload Object and Data Mapped:', dataMapped);
        return dataMapped;
    }

}