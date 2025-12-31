import { LightningElement, api, track } from 'lwc';
import images from '@salesforce/resourceUrl/mexJs';
import { loadStyle } from 'lightning/platformResourceLoader';
import getDateForQuoteScreen from '@salesforce/apex/Mex_NewLeadProcess.getDateForQuoteScreen';
import insertNewQuotes from '@salesforce/apex/Mex_NewLeadProcess.insertNewQuotes';
import sendEmailQuoteDetails from '@salesforce/apex/Mex_NewLeadProcess.sendEmailQuoteDetails';
import updateQuoteData from '@salesforce/apex/Mex_PolicyEditController.updateQuoteData';
import updateQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateQuoteRecordData';
import saveQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.saveQuoteRecordData';
import getNorthboundCoverage from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundCoverage';
import getNorthboundQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import StyleCSS from '@salesforce/resourceUrl/mexinsurance_assets';

import { NavigationMixin } from 'lightning/navigation';
import getyourquick from '@salesforce/label/c.TR_Get_your_quick_quote';
import quotedetail from '@salesforce/label/c.TR_Quote_Detail';
import compare from '@salesforce/label/c.TR_Compare';
import Days from '@salesforce/label/c.TR_Days';
import VehicleValue from '@salesforce/label/c.TR_Vehicle_Value';
import CombinedLiability from '@salesforce/label/c.TR_Combined_Liability';
import Medical from '@salesforce/label/c.TR_Medical';
import LiabilityOnly from '@salesforce/label/c.TR_Liability_Only';
import Deductibles from '@salesforce/label/c.TR_Deductibles';
import thirdPartyLiability from '@salesforce/label/c.TR_Third_Party_Liability';
import zero from '@salesforce/label/c.TR_0';
import CollisionDeductible from '@salesforce/label/c.TR_Collision_Deductible';
import NA from '@salesforce/label/c.TR_N_A';
import TotalTheftDeductible from '@salesforce/label/c.TR_Total_Theft_Deductible';
import UninsuredUnderinsuredMotoristDeductibleWaiver from '@salesforce/label/c.TR_Uninsured_Underinsured_Motorist_Deductible_Waiver';
import LaborRates from '@salesforce/label/c.TR_Labor_Rates';
import GlassBreakage from '@salesforce/label/c.TR_Glass_Breakage';
import RentalCar from '@salesforce/label/c.TR_Rental_Car';
import Roadsideassistance from '@salesforce/label/c.TR_Roadside_assistance';
import LegalDefenseandBail from '@salesforce/label/c.TR_Legal_Defense_and_Bail';
import PartialTheft from '@salesforce/label/c.TR_Partial_Theft';
import PlaneTicketsHome from '@salesforce/label/c.TR_Plane_Tickets_Home';
import BonusCoverage from '@salesforce/label/c.TR_Bonus_Coverage';
import Purchase from '@salesforce/label/c.TR_Purchase';
import Prev from '@salesforce/label/c.TR_Prev';
import Save from '@salesforce/label/c.TR_Save';
import SelectQuoteAndDownload from '@salesforce/label/c.TR_Select_Quote_And_Download';
import Cancel from '@salesforce/label/c.TR_Cancel';
import DownloadPDF from '@salesforce/label/c.TR_Download_PDF';
import EmailPDF from '@salesforce/label/c.TR_Email_PDF';
import PDF from '@salesforce/label/c.TR_PDF';
import Towing from '@salesforce/label/c.TR_Towing';
import Fullterms from '@salesforce/label/c.TR_Full_Terms';
import Vandalism from '@salesforce/label/c.TR_Vandalism';
import EmailhasbeenSent from '@salesforce/label/c.TR_Email_has_been_Sent';
import Yourestimateofvehiclevalue from '@salesforce/label/c.TR_Your_estimate_of_vehicle_value_in_case_of_a_total_loss_This_amount_will_be_y';
import Thisamountgoestowardsdamages from '@salesforce/label/c.TR_This_amount_goes_toward_damages_to_the_other_party_3rd_party_that_you';
import Thisistheamountof from '@salesforce/label/c.TR_This_is_the_amount_of_coverage_for_medical_expenses_as_result_of_accident';


export default class NorthboundQuickQuote extends NavigationMixin(LightningElement) {
     label = {
        getyourquick,quotedetail,compare,Yourestimateofvehiclevalue,Thisamountgoestowardsdamages,Thisistheamountof,Days,VehicleValue,CombinedLiability,Medical,LiabilityOnly,Deductibles,thirdPartyLiability,zero,EmailhasbeenSent,
        CollisionDeductible,NA,TotalTheftDeductible,Vandalism,UninsuredUnderinsuredMotoristDeductibleWaiver,LaborRates,GlassBreakage,Roadsideassistance,RentalCar,LegalDefenseandBail,PartialTheft,PlaneTicketsHome,BonusCoverage,Purchase,Prev,Save,SelectQuoteAndDownload,Cancel,EmailPDF,PDF,DownloadPDF,Towing,Fullterms,
    };
    chubb = images + '/mexJs/images/chubb.png';
    isStyleSheetRendered = false;
    @api changesnextscreen;
    @api changeprevscreen;
    @api quoteDetails = {};
    @api leaddata;
    @api communityUser;
    @api customerRecord;
    @api editpolicydata;
    @api isRenewalPolicy;
    @track AgreedChubbDisclaimer = false;
    disclaimerModal = false;
    quickQuoteDetail = {};
    coverageDetails = {};
    coverageMap = {};
    liabilityOptions = ['100000', '200000', '300000'];
    showLiability;
    isHighlight = false;
    saveQuoteData;
    isSaveQuote = false;
    pdfQuote;
    manageDesclaimer = '';
    showingAgreeBtn = false;

    async connectedCallback() {
        let today = new Date();
        let day = today.getDate();
        let month = today.getMonth();
        let year = today.getFullYear();
        let term = 0;
        let currentDate = new Date(year, month, day);
        console.log("todaye date : ", currentDate);
        this.minDate = currentDate.toISOString();

        const params = new URLSearchParams(window.location.search);
        let leadId = params.get('id');
        let leadEmail = params.get('email');

        if ((leadId != null || leadEmail != null) && (!this.communityUser && window.localStorage.getItem('continueNext') == 'true')) {
            window.localStorage.setItem('continueNext', 'false');
        }

        if (this.isRenewalPolicy == 'Yes') {
            this.quoteDetails = {
                ...this.editpolicydata.quoteData,
                ...this.editpolicydata.vehicleData,
                territory: 'Northbound',
                Is_Towing: this.editpolicydata?.Is_Towing__c != undefined ? this.editpolicydata?.Is_Towing__c : this.editpolicydata.quoteData.Towed_Unit__c == 'Yes' ? true : false,
                towedUnits: this.editpolicydata?.Is_Towing__c != undefined && this.editpolicydata?.Is_Towing__c ? this.editpolicydata.towedUnitData : this.editpolicydata.quoteData.Towed_Unit__c == 'Yes' ? this.editpolicydata.towedUnitData : [],
            }
        } else {
            if (this.communityUser != null && !this.communityUser) {
                let someId = this.leaddata?.Id ? this.leaddata?.Id : '';
                let userType = this.leaddata?.Id ? 'newLead' : 'existingUser';
                const resp = await getDateForQuoteScreen({ someId, userType });
                let parsedData = JSON.parse(resp).data;
                console.log('====', parsedData);
                let vehicleData = JSON.parse(parsedData?.Vehicle_details__c);
                let termData = JSON.parse(parsedData?.Term_options__c);
                let quoteData = parsedData?.Quote_Details__c != undefined ? JSON.parse(parsedData?.Quote_Details__c) : '';
                this.quoteDetails = {
                    ...vehicleData,
                    ...quoteData,
                    ...termData,
                    territory: parsedData?.Territory_Options__c,
                    Is_Towing: parsedData?.Is_towing__c == true ? 'Yes' : 'No',
                    towedUnits: parsedData?.Towing__c ? JSON.parse(parsedData?.Towing__c) : [],
                }
            } else {
                if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                    this.policyType = this.customerRecord?.policyType;
                    console.log('-----this.customerRecord- towedUnitData--', this.customerRecord?.towedUnitData);
                    this.quoteDetails = {
                        ...this.customerRecord?.vehicleData,
                        ...this.customerRecord?.quoteRecord,
                        Is_Towing: this.customerRecord?.quoteRecord?.Towed_Unit__c == true ? 'Yes' : this.customerRecord?.quoteRecord?.Towed_Unit__c == 'Yes' ? 'Yes' : 'No',
                        towedUnits: this.customerRecord?.towedUnitData,
                    }
                }
            }
        }


        console.log('----this.quoteDetails 00--', this.quoteDetails);
        this.showLiability = this.quoteDetails != undefined && this.quoteDetails?.Liability__c != null ? this.quoteDetails.Liability__c == '100,000' ? '100000' : this.quoteDetails.Liability__c == '200,000' ? '200000' : '300000' : '300000';
        console.log('----this.showLiability 00--', this.showLiability);
        await this.fetchQuoteData(this.quoteDetails);
        await this.fetchCoverageQuote();
    }

    renderedCallback() {
        if (!this.isStyleSheetRendered) {
            Promise.all([
                loadStyle(this, StyleCSS + '/style.css')
            ]).then(() => {
                console.log("Files loaded");
            })
                .catch(error => {
                    console.log('css error', error.body.message);
                });
            this.isStyleSheetRendered = true;
        }
    }



    get chubbDeductibles() {
        return this.coverageMap.Deductibles__c == 'Yes' ? true : false;
    }

    get chubbUninsuredMotoristDeductibleWavier() {
        return this.coverageMap.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }
    get chubbGlassBreakage() {
        return this.coverageMap.Glass_Breakage__c == 'Yes' ? true : false;
    }
    get chubbRoadsideAssistance() {
        return this.coverageMap.Roadside_Assistance__c == "Yes" ? true : false;
    }
    get chubbRentalCar() {
        return this.coverageMap.Rental_Car__c == "Yes" ? true : false;
    }
    get chubbLegalDefenseandBail() {
        return this.coverageMap.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }
    get chubbVandalism() {
        return this.coverageMap.Vandalism__c == 'Yes' ? true : false;
    }
    get chubbPartialTheft() {
        return this.coverageMap.Partial_Theft__c == 'Yes' ? true : false;
    }
    get chubbPlaneTicketsHome() {
        return this.coverageMap.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }
    get showTimeField() {
        return this.quoteDetails.Term__c == 'Annual(One Year)' || this.quoteDetails.Term__c == 'Semi-Annual(Half a Year)';
    }


    get setEndTime() {
        return this.quoteDetails != undefined ? (this.quoteDetails.Start_Time__c != undefined ? this.msToTime(this.quoteDetails.Start_Time__c) : '') : '';
    }
    get setStartTime() {
        return this.quoteDetails != undefined ? (this.quoteDetails.Start_Time__c != undefined ? this.msToTime(this.quoteDetails.Start_Time__c) : '') : '';
    }


    CompareHandle() {
        this.isHighlight = !this.isHighlight;
        console.log('--isHighlight--', this.isHighlight);
    }

    fetchQuoteData = async (quoteDetails) => {
        console.log('Inside Fetch ----> ', JSON.stringify(quoteDetails, null, 4));
        let isValid = this.isInputValid();
        console.log('--isValid--', isValid);
        if (isValid) {
            let vehicleAge = new Date().getFullYear() - parseInt(quoteDetails.Year__c);
            this.AgreedChubbDisclaimer = quoteDetails.Agreed_Chubb_Disclaimer__c
            console.log(vehicleAge);
            if (vehicleAge < 1) {
                vehicleAge = 1;
            }
            let driverAge;
            if (this.isRenewalPolicy == 'Yes') {
                let dob = parseInt(new Date(quoteDetails.Date_of_Birth__c).getFullYear());

                driverAge = new Date().getFullYear() - dob;
            } else {
                driverAge = new Date().getFullYear() - parseInt(quoteDetails.DOBYear);
            }
            console.log(driverAge);

            if (driverAge < 16 || driverAge > 85) {
                // show error message;
                const evt = new ShowToastEvent({
                    message: 'Driver age should be between 16 & 85',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                return;
            }

            let qt;

            qt = {
                Policy_Type_picklist: 'Northbound',
                Vehicle_Type: quoteDetails.Vehicle_Type__c,
                Is_Towing: quoteDetails.Is_Towing == true ? 'Yes' : quoteDetails.Is_Towing == 'Yes' ? 'Yes' : 'No',
                Is_there_a_driver_under_21: quoteDetails.Is_there_a_driver_under_21__c == true ? 'Yes' : quoteDetails.Is_there_a_driver_under_21__c == 'Yes' ? 'Yes' : 'No',
                Salvage_Vehicle: quoteDetails.Salvage_Vehicle__c == true ? 'Yes' : quoteDetails.Salvage_Vehicle__c == 'Yes' ? 'Yes' : 'No',
                Vehicle_used_for_Business_Purposes: quoteDetails.Is_the_vehicle_used_for_business_purpose__c == true ? 'Yes' : quoteDetails.Is_the_vehicle_used_for_business_purpose__c == 'Yes' ? 'Yes' : 'No',
                Is_Rental_Vehicle: quoteDetails.Is_this_a_Rental_Vehicle__c == true ? 'Yes' : quoteDetails.Is_this_a_Rental_Vehicle__c == 'Yes' ? 'Yes' : 'No',
                Vehicle_Sub_Type: !this.isRenewalPolicy ? quoteDetails.Vehicle_sub_type__c : quoteDetails.Vehicle_Type__c,
                Vehicle_Value: quoteDetails.Value__c,
                vehicle_Age: JSON.stringify(vehicleAge),
                driver_Age: JSON.stringify(driverAge),
                Start_Date_for_Coverage: quoteDetails.Start_Date_for_Coverage__c,
                End_Date_for_Coverage: quoteDetails.End_Date_for_Coverage__c,
                Liability_Type: 'Liability',
                Medical: "$5,000/$25,000",
                towedUnits: quoteDetails.towedUnits != undefined && quoteDetails.towedUnits.length > 0 ? quoteDetails.towedUnits : [],
            }

            console.log('qt ::::: ', JSON.stringify(qt, null, 4));

            try {
                const resp = await getNorthboundQuote({ 'requestBody': JSON.stringify(qt), 'liability': this.showLiability });
                const parsedData = JSON.parse(resp);

                if (parsedData.status == 'success') {
                    console.log(JSON.stringify(parsedData, null, 4));
                    this.quickQuoteDetail = { ...parsedData, ['showChubb']: true };
                }else{
                    this.generateLogs();
                }
            } catch (error) {
                this.generateLogs();
                console.log('Error :::: ', error);
            }
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

    fetchCoverageQuote = async () => {
        try {
            const resp = await getNorthboundCoverage();
            console.log(JSON.stringify(resp, null, 4));

            if (resp.length) {
                this.coverageMap = { ...resp[0] };
            }
        } catch (error) {
            this.generateLogs();
            console.log('Error :::: ', error);
        }
    }
    saveQuoteDetailData = async () => {
        this.saveQuoteData = {
            Start_Date_for_Coverage__c: this.quoteDetails.Start_Date_for_Coverage__c,
            End_Time__c: this.quoteDetails.End_Time__c,
            End_Date_for_Coverage__c: this.quoteDetails.End_Date_for_Coverage__c,
            Vehicle_used_for_Business_Purposes__c: this.quoteDetails.Is_the_vehicle_used_for_business_purpose__c == true ? true : this.quoteDetails.Is_the_vehicle_used_for_business_purpose__c == 'Yes' ? true : false,
            Is_there_a_driver_under_21__c: this.quoteDetails.Is_there_a_driver_under_21__c == true ? 'Yes' : this.quoteDetails.Is_there_a_driver_under_21__c == 'Yes' ? 'Yes' : 'No',
            Is_this_a_Rental_Vehicle__c: this.quoteDetails.Is_this_a_Rental_Vehicle__c == true ? true : this.quoteDetails.Is_this_a_Rental_Vehicle__c == 'Yes' ? true : false,
            Liability__c: this.showLiability == '100000' ? '100,000' : this.showLiability == '200000' ? '200,000' : '300,000',
            Driver_Age__c: new Date().getFullYear() - parseInt(this.quoteDetails.DOBYear),
            Vehicle_Age__c: new Date().getFullYear() - parseInt(this.quoteDetails.Year__c),
            Vehicle_Make__c: this.quoteDetails.Make__c,
            Vehicle_Model__c: this.quoteDetails.Model__c,
            Salvage_Vehicle__c: this.quoteDetails.Salvage_Vehicle__c == true ? 'Yes' : this.quoteDetails.Salvage_Vehicle__c == 'Yes' ? 'Yes' : 'No',
            Start_Time__c: this.quoteDetails.Start_Time__c,
            Vehicle_Value__c: this.quoteDetails.Value__c,
            Vehicle_Type__c: this.quoteDetails.Vehicle_sub_type__c,
            Vehicle_Year__c: this.quoteDetails.Year__c,
            Term__c: parseInt(this.quickQuoteDetail.days) <= 30 ? 'Daily' : parseInt(this.quickQuoteDetail.days) > 30 && parseInt(this.quickQuoteDetail.days) <= 90 ? '90 Day' : parseInt(this.quickQuoteDetail.days) > 90 && parseInt(this.quickQuoteDetail.days) <= 180 ? 'Semi-Annual(Half a Year)' : 'Annual(One Year)',
            Policy_Type_picklist__c: 'Northbound',
            Territory__c: 'Northbound',
            Territory_Coverage__c: 'PARTIAL(US ADJACENT)',
            Net_Premium__c: this.quickQuoteDetail.net_premium,
            Broker_Policy_Fee__c: this.quickQuoteDetail.Policy_Fee != undefined ? this.quickQuoteDetail.Policy_Fee : 0,
            Term_Days__c: this.quickQuoteDetail.days != undefined ? this.quickQuoteDetail.days : 0,
            I_V_A_Mex_Tax__c: this.quickQuoteDetail.iva != undefined ? this.quickQuoteDetail.iva : 0,
            Quote_Value__c: this.quickQuoteDetail.rateValue != undefined ? this.quickQuoteDetail.rateValue : 0,
            Surcharge__c: this.quickQuoteDetail.surcharge != undefined ? this.quickQuoteDetail.surcharge : 0,
            Underwriter__c: 'Chubb',
            Medical__c: "5,000/25,000",
            Coverage__c: 'Liability',
            Towed_Unit__c: this.quoteDetails.Is_Towing == true ? 'Yes' : this.quoteDetails.Is_Towing == 'Yes' ? 'Yes' : 'No',
            Agreed_Chubb_Disclaimer__c : this.AgreedChubbDisclaimer
        };

        if (this.communityUser != null && this.communityUser && !this.isRenewalPolicy) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Id']: this.customerRecord?.quoteRecord?.Id }
            this.saveQuoteData = { ...this.saveQuoteData, ['Date_of_Birth__c']: `${this.quoteDetails.DOBYear}-${this.quoteDetails.DOBMonth}-${this.quoteDetails.DOBDay}` }
        } else if (this.communityUser != null && !this.communityUser) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Id']: this.leaddata?.quoteId }
            this.saveQuoteData = { ...this.saveQuoteData, ['Date_of_Birth__c']: `${this.quoteDetails.DOBYear}-${this.quoteDetails.DOBMonth}-${this.quoteDetails.DOBDay}` }
        } else if (this.editpolicydata?.quoteData?.Id != undefined) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Id']: this.editpolicydata?.quoteData?.Id };
            this.saveQuoteData = { ...this.saveQuoteData, ['Date_of_Birth__c']: this.editpolicydata?.quoteRecord?.Date_of_Birth__c }
        }

    }

    handleNextClick = async () => {
        this.manageDesclaimer = 'Purchase';
        if(this.AgreedChubbDisclaimer){
            this.saveQuoteDetailData();
            //if (this.quoteDetails.Id != null || this.quoteDetails.Id != undefined) this.saveQuoteData.Id = this.quoteDetails.Id;
    
            let isValid = this.isInputValid();
            console.log('isValid--', isValid);
            console.log('saveQuoteData--', JSON.stringify(this.saveQuoteData, null, 4));
            if (isValid) {
                if (this.isRenewalPolicy == 'Yes') {
                    let updateCloneQuote = await updateQuoteData({ 'quote': JSON.stringify(this.saveQuoteData) });
                    console.log("Update Clone Quote ::::: ::::", JSON.stringify(updateCloneQuote, null, 4));
                    if (updateCloneQuote.status == 'success') {
                        this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ...this.saveQuoteData } }
                        const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                            detail: this.editpolicydata,
                        });
    
                        this.dispatchEvent(editPolicyChange);
                    } else {
                        // show error;
                        this.generateLogs();
                        return;
                    }
                } else {
                    if (this.communityUser != null && this.communityUser) {
                        let quoteResponse;
                        if (this.customerRecord != null && this.customerRecord?.quoteRecord?.Id != null && this.customerRecord?.vehicleData?.Id) {
                            quoteResponse = await updateQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord, ...this.saveQuoteData }), "vehicleRecord": JSON.stringify(this.customerRecord?.vehicleData), "towedUnitRecord": this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify(this.customerRecord?.towedUnitData) : '', "driversRecord": '' });
                        } else {
                            quoteResponse = await saveQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord, ...this.saveQuoteData }), "vehicleRecord": JSON.stringify(this.customerRecord?.vehicleData), "towedUnitRecord": this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify(this.customerRecord?.towedUnitData) : '' });
                        }
    
                        if (quoteResponse && quoteResponse.status == 'success') {
                            this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...quoteResponse.quoteData }, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...quoteResponse.vehicleData } };
    
                            if (quoteResponse?.towedUnitData?.length) {
                                this.customerRecord = { ...this.customerRecord, ['towedUnitData']: [...quoteResponse.towedUnitData] };
                            }
    
                            const customerRecordChange = new CustomEvent('customerecordchange', {
                                detail: this.customerRecord,
                            });
    
                            this.dispatchEvent(customerRecordChange);
                        } else {
                            // show error;
                            console.log('testing data');
                            this.generateLogs();
                            console.log(JSON.stringify(quoteResponse, null, 4));
                            return;
                        }
                    } else {
                        let quote = await insertNewQuotes({ "quotes": JSON.stringify(this.saveQuoteData), "leadId": this.leaddata?.Id });
    
                        console.log('quote--', quote);
                        if (quote.status == 'success') {
                            this.leaddata = { ...this.leaddata, ['quoteId']: quote.data.Id };
    
                            console.log('quote--', quote);
                            console.log('quote--', this.leaddata);
                            const leadChange = new CustomEvent('leadvaluechange', {
                                detail: this.leaddata,
                            });
                            this.dispatchEvent(leadChange);
                        } else {
                            // show error;
                            this.generateLogs();
                            console.log(JSON.stringify(quote, null, 4));
                            return;
                        }
                    }
                }
                this.changesnextscreen();
            }
        }else{
            this.disclaimerModal = true;
        }
       
    }

    handlePrevClick() {
        if (this.communityUser != null && !this.communityUser) {
            const leadChange = new CustomEvent('leadvaluechange', {
                detail: this.leaddata,
            });
            this.dispatchEvent(leadChange);
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                const customerRecordChange = new CustomEvent('customerecordchange', {
                    detail: this.customerRecord,
                });

                this.dispatchEvent(customerRecordChange);
            }
        }
        this.changeprevscreen();
    }

    handleDownloadPdf = async (event) => {


        // this.isSaveQuote = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin + '/apex/selectedQuoteRate?Id=' + quote.data.Id
            },
        })
    }
    savedQuoteDetail = async () => {
        this.saveQuoteDetailData();
        // this.quickQuoteDetail = { ...this.quickQuoteDetail,  };

        let northboundQuickQuoteDetail = { ['chubbQuote']: this.quickQuoteDetail, ['Chubb']: true };
        console.log('--northboundQuickQuoteDetail---', northboundQuickQuoteDetail);
        this.saveQuoteData = { ...this.saveQuoteData, ['QuotePdfJson__c']: JSON.stringify(northboundQuickQuoteDetail) }
        if (this.communityUser != null && this.communityUser) {

            // if (this.customerRecord != null && this.customerRecord?.quoteRecord?.Id != null && this.customerRecord?.vehicleData?.Id) {
            //     this.pdfQuote = await updateQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.saveQuoteData, ...this.customerRecord?.quoteRecord }), "vehicleRecord": JSON.stringify(this.customerRecord?.vehicleData), "towedUnitRecord": this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify(this.customerRecord?.towedUnitData) : '', "driversRecord": '' });
            // } else {
            this.pdfQuote = await saveQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.saveQuoteData, ...this.customerRecord?.quoteRecord }), "vehicleRecord": JSON.stringify(this.customerRecord?.vehicleData), "towedUnitRecord": this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify(this.customerRecord?.towedUnitData) : '' });

            console.log('--pdfQuote 222--', this.pdfQuote);
            if (this.pdfQuote.status == 'success') {
                this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...this.pdfQuote.quoteData } };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...this.pdfQuote.vehicleData } };



                if (this.pdfQuote?.towedUnitData?.length) {
                    this.customerRecord = { ...this.customerRecord, ['towedUnitData']: [...this.pdfQuote.towedUnitData] };
                }
                console.log('---this.customerRecord---', this.customerRecord);
                const customerRecordChange = new CustomEvent('customerecordchange', {
                    detail: this.customerRecord,
                });

                this.dispatchEvent(customerRecordChange);
            }else{
                this.generateLogs();
            }
        } else {
            console.log('---saveQuoteData----->', this.saveQuoteData);
            this.pdfQuote = await insertNewQuotes({ "quotes": JSON.stringify(this.saveQuoteData), "leadId": this.leaddata?.Id });
            console.log('--pdfQuote 222--', this.pdfQuote);
            if (this.pdfQuote.status == 'success') {
                this.leaddata = { ...this.leaddata, ['quoteId']: this.pdfQuote.data.Id };

                console.log('pdfQuote--', this.pdfQuote);
                console.log('pdfQuote--', this.leaddata);
                const leadChange = new CustomEvent('leadvaluechange', {
                    detail: this.leaddata,
                });
                this.dispatchEvent(leadChange);
            }else{
                this.generateLogs();
            }
        }


    }
    SaveQuoteHandle = async (event) => {
        
        this.manageDesclaimer = 'saveQuote';                                                
        if(this.AgreedChubbDisclaimer){
            this.isSaveQuote = true;
        }else{
            this.disclaimerModal = true;
        }
        
    }
    cancleEdit() {
        this.isSaveQuote = !this.isSaveQuote;
    }
    downloadQuote = async () => {
        this.AgreedChubbDisclaimer = true;
        await this.savedQuoteDetail();
        this.isSaveQuote = false;
        let quoteIdforPdf = '';
        if (this.communityUser != null && this.communityUser) {
            quoteIdforPdf = this.customerRecord.quoteRecord.Id;
        } else {
            quoteIdforPdf = this.pdfQuotes.data.Id;
        }
        console.log('--quoteIdforPdf--', quoteIdforPdf);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin + '/apex/selectedQuoteRate?Id=' + quoteIdforPdf
            },
        })
    }

    sendEmailQuoteDetail = async () => {
        this.AgreedChubbDisclaimer = true;
        await this.savedQuoteDetail();
        this.isSaveQuote = false;
        let quoteIdforPdf = '';
        if (this.communityUser != null && this.communityUser) {
            quoteIdforPdf = this.customerRecord.quoteRecord.Id;
        } else {
            quoteIdforPdf = this.pdfQuotes.data.Id;
        }
        console.log('--quoteIdforPdf--', quoteIdforPdf);
        let sendEmailOfQuoteDetail = await sendEmailQuoteDetails({ 'quoteId': quoteIdforPdf });
        console.log('--sendEmailOfQuoteDetail--', sendEmailOfQuoteDetail);
        if (sendEmailOfQuoteDetail.status == 'success') {
            const evt = new ShowToastEvent({
                message: this.label.EmailhasbeenSent,
                variant: 'success',
            });
            this.dispatchEvent(evt);
        }else{
            this.generateLogs();
        }
    }
    msToTime(s) {
        if (typeof s == 'string') {
            return s;
        } else {
            // Pad to 2 or 3 digits, default is 2
            function pad(n, z) {
                z = z || 2;
                return ('00' + n).slice(-z);
            }

            var ms = s % 1000;
            s = (s - ms) / 1000;
            var secs = s % 60;
            s = (s - secs) / 60;
            var mins = s % 60;
            var hrs = (s - mins) / 60;

            return pad(hrs) + ':' + pad(mins) + ':' + pad(secs) + '.' + pad(ms, 3);
        }
    }
    ShowDiscaimerModals(){
        this.showingAgreeBtn = true;
        this.disclaimerModal = true;
    }
    AgreeDiscailmer(event){
        let selectQuoteName = event.target.dataset.id;
        
        this.disclaimerModal = false;
        
        if(this.manageDesclaimer == 'Purchase'){
            this.AgreedChubbDisclaimer = true;
            this.handleNextClick();
        }else if(this.manageDesclaimer == 'saveQuote'){
            this.isSaveQuote = true;
        }
        
    }
    CancelDescailmer(){
       // this.AgreedChubbDisclaimer = false; 
        this.disclaimerModal = false;
    }
    async updateLiability(event) {
        let type = event.target.dataset.type;
        let liabilityListLength = (this.liabilityOptions.length - 1);
        let liablity = this.showLiability;
        let updatelibality;
        if (type && type == 'high') {
            var index = this.liabilityOptions.indexOf(liablity);
            console.log('--index--', index);
            console.log('data index  ', this.liabilityOptions[index + 1]);
            if (liabilityListLength != index) {
                updatelibality = this.liabilityOptions[index + 1];
            }
        } else if (type && type == 'low') {
            var index = this.liabilityOptions.indexOf(liablity);
            if (index != 0) {
                updatelibality = this.liabilityOptions[index - 1];
            }
        }

        console.log('--updatelibality--', updatelibality);


        if (updatelibality && updatelibality != null) {
            this.showLiability = updatelibality;
            await this.fetchQuoteData(this.quoteDetails);
        }

    }
    generateLogs(){
        console.log('generated logs');
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}