import { api, LightningElement } from 'lwc';
import image from '@salesforce/resourceUrl/mexJs';
import automobileQualitasTermConditionCustmLbel from '@salesforce/label/c.Terms_and_Conditions_Automobile_Qualitas';
import automobileChubbTermCondCustmLbl from '@salesforce/label/c.Terms_and_Conditions_Automobile_Chubb'
import automobileMapfreTermCondCustmLbl from '@salesforce/label/c.Terms_and_Conditions_Automobile_Chubb';
import getQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getQuote';
import getDateForQuoteScreen from '@salesforce/apex/Mex_NewLeadProcess.getDateForQuoteScreen';
import insertNewQuotes from '@salesforce/apex/Mex_NewLeadProcess.insertNewQuotes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import preViewslectedQuote from '@salesforce/apex/Mex_NewLeadProcess.preViewslectedQuote';
import createCloneQuote from '@salesforce/apex/Mex_PolicyEditController.createCloneQuote';
import updateQuoteData from '@salesforce/apex/Mex_PolicyEditController.updateQuoteData';
import updateQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateQuoteRecordData';
import saveQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.saveQuoteRecordData';
import sendEmailQuoteDetails from '@salesforce/apex/Mex_NewLeadProcess.sendEmailQuoteDetails';
import getCoverageDetailForSouthbound from '@salesforce/apex/Mex_QuickQuoteCommonController.getCoverageDetailForSouthbound';
import getExactCoverageDetailForSouthbound from '@salesforce/apex/Mex_QuickQuoteCommonController.getExactCoverageDetailForSouthbound';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import getyourquick from '@salesforce/label/c.TR_Get_your_quick_quote';
import quotedetail from '@salesforce/label/c.TR_Quote_Detail';
import compare from '@salesforce/label/c.TR_Compare';
import aboutyourquotes from '@salesforce/label/c.TR_About_your_Quotes';
import starttime from '@salesforce/label/c.TR_Start_Time';
import endtime from '@salesforce/label/c.TR_End_Time';
import days from '@salesforce/label/c.TR_Days';
import vehiclevalue from '@salesforce/label/c.TR_Vehicle_Value';
import combinedliability from '@salesforce/label/c.TR_Combined_Liability';
import medical from '@salesforce/label/c.TR_Medical';
import liabilityonly from '@salesforce/label/c.TR_Liability_Only';
import purchase from '@salesforce/label/c.TR_Purchase';
import fullterms from '@salesforce/label/c.TR_Full_Terms';
import recommended from '@salesforce/label/c.TR_Recommended';
import daysintow from '@salesforce/label/c.TR_Days_in_tow';
import fullcoverage from '@salesforce/label/c.TR_Full_Coverage';
import maxcoverage from '@salesforce/label/c.TR_Max_Coverage';
import liabilitytheft from '@salesforce/label/c.TR_Liability_Theft';
import completecoverage from '@salesforce/label/c.TR_Complete_Coverage';
import deductibles from '@salesforce/label/c.TR_Deductibles';
import thirdpartyliability from '@salesforce/label/c.TR_Third_Party_Liability_Damage';
import zero from '@salesforce/label/c.TR_0';
import collisiondeductible from '@salesforce/label/c.TR_Collision_Deductible';
import NA from '@salesforce/label/c.TR_N_A';
import totaltheft from '@salesforce/label/c.TR_Total_Theft_Deductible';
import uninsuredunderinsured from '@salesforce/label/c.TR_Uninsured_Underinsured_Motorist_Deductible_Waiver';
import laborrates from '@salesforce/label/c.TR_Labor_Rates';
import glassbreakage from '@salesforce/label/c.TR_Glass_Breakage';
import roadside from '@salesforce/label/c.TR_Roadside_assistance';
import towing from '@salesforce/label/c.TR_Towing';
import rentalcar from '@salesforce/label/c.TR_Rental_Car';
import legaldefence from '@salesforce/label/c.TR_Legal_Defense_and_Bail';
import vandalism from '@salesforce/label/c.TR_Vandalism';
import partialtheft from '@salesforce/label/c.TR_Partial_Theft';
import planetickets from '@salesforce/label/c.TR_Plane_Tickets_Home';
import bonuscoverage from '@salesforce/label/c.TR_Bonus_Coverage';
import yes from '@salesforce/label/c.TR_Yes';
import selectquote from '@salesforce/label/c.TR_Select_Quote_And_Download';
import download from '@salesforce/label/c.TR_Download';
import PDF from '@salesforce/label/c.TR_PDF';
import Email from '@salesforce/label/c.TR_Email';
import cancel from '@salesforce/label/c.TR_Cancel';
import prev from '@salesforce/label/c.TR_Prev';
import save from '@salesforce/label/c.TR_Save';
import sometimesitscheaper from '@salesforce/label/c.TR_Sometimes_it_s_cheaper_to_purchase_a_six_month_policy_than_it_is_a_30_day_pol';
import yourestimateofvehicle from '@salesforce/label/c.TR_Your_estimate_of_vehicle_value_in_case_of_a_total_loss_This_amount_will_be';
import daystooltips from '@salesforce/label/c.TR_daystooltips';
import Thisamountgoestowarddamages from '@salesforce/label/c.TR_This_amount_goes_toward_damages_to_the_other_party_3rd_party_that_you_are_r';
import Thisistheamountofcoverageformedicalexpensesasresultofaccidentfor from '@salesforce/label/c.TR_This_is_the_amount_of_coverage_for_medical_expenses_as_result_of_accident_for';
import YourestimateofvehiclevalueincaseofatotallossThisamountwillbe from '@salesforce/label/c.TR_Your_estimate_of_vehicle_value_in_case_of_a_total_loss_This_amount_will_be';
import Thisamountgoestowarddamagestotheotherparty3rdpartythatyouare from '@salesforce/label/c.TR_This_amount_goes_toward_damages_to_the_other_party_3rd_party_that_you_are_r';
import Thisistheamountofcoverageformedicalexpensesaresultofaccidentfor from '@salesforce/label/c.TR_This_is_the_amount_of_coverage_for_medical_expenses_as_result_of_accident_for';
import NoQuoteexistforthe from '@salesforce/label/c.TR_No_Quote_exist_for_the_provided_vehicle_value';
import Wedonothaveaprogram from '@salesforce/label/c.TR_We_do_not_have_a_program_or_product_to_cover_your_request_Please_GO_BACK_to';
import Kindlyselectanyoptionfirst from '@salesforce/label/c.TR_Kindly_select_any_option_first';
import EmailhasbeenSent from '@salesforce/label/c.TR_Email_has_been_Sent';
import DaysinTowvaluecantbe from '@salesforce/label/c.TR_Days_in_Tow_value_can_t_be_greater_than_Term_Kindly_fix_that_and_try_again';

import { NavigationMixin } from 'lightning/navigation';


export default class SouthboundQuickQuote extends NavigationMixin(LightningElement) {
    label = {
        getyourquick, quotedetail, compare, aboutyourquotes, starttime, DaysinTowvaluecantbe, NoQuoteexistforthe, EmailhasbeenSent, Kindlyselectanyoptionfirst, Wedonothaveaprogram, Thisistheamountofcoverageformedicalexpensesaresultofaccidentfor, endtime, days, Thisamountgoestowarddamagestotheotherparty3rdpartythatyouare, YourestimateofvehiclevalueincaseofatotallossThisamountwillbe, daystooltips, vehiclevalue, combinedliability, medical, liabilityonly, purchase, fullterms,
        recommended, daysintow, fullcoverage, maxcoverage, liabilitytheft, completecoverage, Thisamountgoestowarddamages, deductibles, thirdpartyliability, zero, collisiondeductible, sometimesitscheaper,
        NA, totaltheft, uninsuredunderinsured, laborrates, glassbreakage, roadside, towing, rentalcar, Thisistheamountofcoverageformedicalexpensesasresultofaccidentfor, legaldefence, vandalism, partialtheft, planetickets, bonuscoverage, yes, selectquote, download, PDF, Email, cancel, prev, save, yourestimateofvehicle,
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api quickQuoteDetail;
    @api quoteDetails = {};
    @api isRenewalPolicy;
    @api editpolicydata;
    @api customerRecord;
    @api communityUser;
    @api policyType;
    coverageMap = {};
    systemTime;
    displayPstTime;
    refreshPage;


    newQuoteId;
    minDate = '';
    endMinDate = '';

    medicallist = ['$2,000/$10,000', '$3,000/$15,000', '$4,000/$20,000', '$5,000/$25,000', '$10,000/$50,000', '$15,000/$75,000', '$20,000/$100,000'];

    chubbmedicallist = [ '$10,000/$50,000', '$15,000/$75,000', '$20,000/$100,000'];
    liabilitylist = [
        100000, 200000, 300000, 500000, 1000000
    ]
    Chubbliabilitylist = [
     300000,400000,500000, 1000000
    ]
    qualitasLiability = 500000;
    chubbLiability = 500000;
    mapfreLiability = 300000;
    qualitasMedical = '$10,000/$50,000';
    mapfreMedical = '$5,000/$25,000';
    chubbMedical = '$10,000/$50,000';
    isSaveQuote = false;
    pdfQuotes;
    saveQuoteData;
    // !$Resource.mexJs  + '/mexJs/images/qualitas.png' {!$Label.c.Terms_and_Conditions_Automobile_Qualitas}

    qualitasImg = image + '/mexJs/images/qualitas.png';
    chubbImg = image + '/mexJs/images/chubb.png';
    mapfreImg = image + '/mexJs/images/mapfre-logo.png';
    IsHighlightView = false;

    // coverage detail variables
    get qualitasDeductibles() {
        return (this.coverageMap && this.coverageMap?.Qualitas?.Deductibles__c == 'Yes' )? true : false;
    }
    get qualitasUninsuredMotoristDeductibleWavier() {
        return this.coverageMap?.Qualitas?.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }
    get qualitasGlassBreakage() {
        return this.coverageMap?.Qualitas?.Glass_Breakage__c == 'Yes' ? true : false;
    }
    get qualitasRoadsideAssistance() {
        return this.coverageMap?.Qualitas?.Roadside_Assistance__c == "Yes" ? true : false;
    }
    get qualitasRentalCar() {
        return this.coverageMap?.Qualitas?.Rental_Car__c == "Yes" ? true : false;
    }
    get qualitasLegalDefenseandBail() {
        return this.coverageMap?.Qualitas?.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }
    get qualitasVandalism() {
        return this.coverageMap?.Qualitas?.Vandalism__c == 'Yes' ? true : false;
    }
    get qualitasPartialTheft() {
        return this.coverageMap?.Qualitas?.Partial_Theft__c == 'Yes' ? true : false;
    }
    get qualitasPlaneTicketsHome() {
        return this.coverageMap?.Qualitas?.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }
    get vehicleType() {
        return this.policyType != 'Motorcycle/Street Legal ATV' || this.policyType != 'Motorcycle' ? 'Vehicle : ' : '';
    }
    get isShowQualitas() {
        return this.quickQuoteDetail?.qualitasQuote?.showQualitas != undefined ? this.quickQuoteDetail?.qualitasQuote?.showQualitas : false;
    }
    get isShowChubb() {
        return this.quickQuoteDetail?.chubbQuote?.showChubb != undefined ? this.quickQuoteDetail?.chubbQuote?.showChubb : false;
    }
    get isShowMapfre() {
        return this.quickQuoteDetail?.mapfreQuote?.showMapfre != undefined ? this.quickQuoteDetail.mapfreQuote.showMapfre : false;
    }
    get chubbDeductibles() {
        return (this.coverageMap && this.coverageMap?.Chubb?.Deductibles__c == 'Yes' )? true : false;
    }
    get chubbUninsuredMotoristDeductibleWavier() {
        return this.coverageMap?.Chubb?.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }
    get chubbGlassBreakage() {
        return this.coverageMap?.Chubb?.Glass_Breakage__c == 'Yes' ? true : false;
    }
    get chubbRoadsideAssistance() {
        return this.coverageMap?.Chubb?.Roadside_Assistance__c == "Yes" ? true : false;
    }
    get chubbRentalCar() {
        return this.coverageMap?.Chubb?.Rental_Car__c == "Yes" ? true : false;
    }
    get chubbLegalDefenseandBail() {
        return this.coverageMap?.Chubb?.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }
    get chubbVandalism() {
        return this.coverageMap?.Chubb?.Vandalism__c == 'Yes' ? true : false;
    }
    get chubbPartialTheft() {
        return this.coverageMap?.Chubb?.Partial_Theft__c == 'Yes' ? true : false;
    }
    get chubbPlaneTicketsHome() {
        return this.coverageMap?.Chubb?.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }
    get mapfreDeductibles() {
        return (this.coverageMap && this.coverageMap?.Mapfre?.Deductibles__c == 'Yes') ? true : false;
    }
    get uninsuredMotoristDeductibleWavier() {
        return this.coverageMap?.Mapfre?.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }
    get mapFreGlassBreakage() {
        return this.coverageMap?.Mapfre?.Glass_Breakage__c == 'Yes' ? true : false;
    }
    get mapfreRoadsideAssistance() {
        return this.coverageMap?.Mapfre?.Roadside_Assistance__c == "Yes" ? true : false;
    }
    get isTowing() {
        return this.coverageMap?.Mapfre?.Towing__c == "Yes" ? true : false;
    }
    get isTowingChubb() {
        return this.coverageMap?.Chubb?.Towing__c == "Yes" ? true : false;
    }
    get isTowingQualitas() {
        return this.coverageMap?.Qualitas?.Towing__c == "Yes" ? true : false;
    }
    get mapfreRentalCar() {
        return this.coverageMap?.Mapfre?.Rental_Car__c == "Yes" ? true : false;
    }
    get mapfreLegalDefenseandBail() {
        return this.coverageMap?.Mapfre?.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }
    get mapfreVandalism() {
        return this.coverageMap?.Mapfre?.Vandalism__c == 'Yes' ? true : false;
    }
    get mapfrePartialTheft() {
        return this.coverageMap?.Mapfre?.Partial_Theft__c == 'Yes' ? true : false;
    }
    get mapfrePlaneTicketsHome() {
        return this.coverageMap?.Mapfre?.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }
    get isAutomobile() {
        return this.policyType == 'Automobile';
    }
    get rvPolicy() {
        return this.policyType == 'RV';
    }
    get motorcyclePolicy() {
        return this.policyType == 'Motorcycle/Street Legal ATV';
    }
    get northBoundPolicy() {
        return this.policyType == 'Northbound';
    }
    get liablityType() {
        if (!this.isRenewalPolicy) {
            return this.quoteDetails?.Coverage__c != undefined && this.quoteDetails?.Coverage__c == 'Liability' ? true : false;
        } else {
            return this.editpolicydata?.quoteData != undefined && this.editpolicydata?.quoteData?.Coverage__c != undefined && this.editpolicydata?.quoteData?.Coverage__c == 'Liability' ? true : false;
        }
    }
    get liabilityTheftCoverage() {
        if (!this.isRenewalPolicy) {
            return this.quoteDetails?.Coverage__c != undefined && this.quoteDetails?.Coverage__c == 'LiabilityTheft' ? true : false;
        } else {
            return this.editpolicydata?.quoteData != undefined && this.editpolicydata?.quoteData?.Coverage__c != undefined && this.editpolicydata?.quoteData?.Coverage__c == 'LiabilityTheft' ? true : false;
        }
    }
    get maxCoverage() {
        if (!this.isRenewalPolicy) {
            return this.quoteDetails?.Coverage__c != undefined && this.quoteDetails?.Coverage__c == 'Max' ? true : false;
        } else {
            return this.editpolicydata?.quoteData != undefined && this.editpolicydata?.quoteData?.Coverage__c != undefined && this.editpolicydata?.quoteData?.Coverage__c == 'Max' ? true : false;
        }
    }
    get fullAndCompleteCoverage() {
        if (!this.isRenewalPolicy) {
            return this.quoteDetails?.Coverage__c != undefined && this.quoteDetails?.Coverage__c == 'Complete' ? true : false;
        } else {
            return this.editpolicydata?.quoteData != undefined && this.editpolicydata?.quoteData?.Coverage__c != undefined && this.editpolicydata?.quoteData?.Coverage__c == 'Complete' ? true : false;
        }
    }
    get showQualitasPdf() {
        return this.quickQuoteDetail != undefined ? (this.quickQuoteDetail.Qualitas != undefined ? this.quickQuoteDetail.Qualitas : false) : false;
    }
    get showChubbPdf() {
        return this.quickQuoteDetail != undefined ? (this.quickQuoteDetail.Chubb != undefined ? this.quickQuoteDetail.Chubb : false) : false;
    }
    get showMapfrePdf() {
        return this.quickQuoteDetail != undefined ? (this.quickQuoteDetail.Mapfre != undefined ? this.quickQuoteDetail.Mapfre : false) : false;
    }
    get showTimeField() {
        return this.quoteDetails.Term__c == 'Annual(One Year)' || this.quoteDetails.Term__c == 'Semi-Annual(Half a Year)';
    }


    async connectedCallback() {
        try {
            await this.getSystemTime();
            let today = new Date(this.systemTime.dtPST);
            let day = today.getDate();
            let month = today.getMonth();
            let year = today.getFullYear();
            let term = 0;
            let currentDate = new Date(year, month, day);
            this.minDate = currentDate.toISOString();
            this.refreshPage = true;

            const params = new URLSearchParams(window.location.search);
            let leadId = params.get('id');
            let leadEmail = params.get('email');

            if ((leadId != null || leadEmail != null) && (!this.communityUser && window.localStorage.getItem('continueNext') == 'true')) {
                window.localStorage.setItem('continueNext', 'false');
            }

            if (this.isRenewalPolicy == 'Yes') {
                
                if(this.editpolicydata?.policyData.Vehicle_type__c == 'Automobile/Sedan'){
                    this.editpolicydata = { ...this.editpolicydata, ['policyData']: { ...this.editpolicydata.policyData, ['Vehicle_type__c']: 'Car/Truck/Auto' } };
                }

                this.quoteDetails = {
                    ...this.editpolicydata.quoteData,
                    ...this.editpolicydata.vehicleData,
                }
                if (this.editpolicydata?.quoteData?.Liability__c != undefined) {
                    this.updateLiabilityDataState(this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, ''));
                    this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Liability__c']: this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '') } }
                }
                if (this.editpolicydata?.quoteData?.Medical__c != undefined) {
                    let medicalSplitVal = this.editpolicydata.quoteData.Medical__c?.split('/');
                    this.updateMedicalDataState('$' + medicalSplitVal[0] + '/$' + medicalSplitVal[1]);
                    this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Medical__c']: '$' + medicalSplitVal[0] + '/$' + medicalSplitVal[1] } }
                }
            } else {
                if (this.communityUser != null && !this.communityUser) {
                    let someId = this.leaddata?.Id ? this.leaddata?.Id : '';
                    let userType = this.leaddata?.Id ? 'newLead' : 'existingUser';

                    const resp = await getDateForQuoteScreen({ someId, userType });
                    let parsedData = JSON.parse(resp).data;
                    let vehicleData = JSON.parse(parsedData?.Vehicle_details__c);
                    let termData = JSON.parse(parsedData?.Term_options__c);
                    let quoteData = parsedData?.Quote_Details__c != undefined ? JSON.parse(parsedData?.Quote_Details__c) : '';
                    this.quoteDetails = {
                        ...quoteData,
                        ...vehicleData,
                        ...termData,
                        territory: parsedData?.Territory_Options__c,
                        // Is_Towing: this.leaddata?.Is_Towing__c == true ? 'Yes' : 'No',
                        Is_Towing: this.leaddata?.Is_Towing__c == true ? 'Yes' : 'No',
                        towedUnits: parsedData?.Towing__c && this.leaddata?.Is_Towing__c ? JSON.parse(parsedData?.Towing__c) : [],
                        Coverage__c: quoteData != '' ? quoteData.Coverage__c : vehicleData.Coverage__c,
                    }
                    if (quoteData != '' && quoteData?.Liability__c != undefined) {
                        this.updateLiabilityDataState(quoteData?.Liability__c?.replace(/,/g, ''));
                        this.quoteDetails = { ...this.quoteDetails, ['Liability__c']: quoteData?.Liability__c?.replace(/,/g, '') }
                    }
                    if (quoteData != '' && quoteData?.Medical__c != undefined) {
                        let medicalSplitVal = quoteData?.Medical__c?.split('/');
                        this.updateMedicalDataState('$' + medicalSplitVal[0] + '/$' + medicalSplitVal[1]);
                        this.quoteDetails = { ...this.quoteDetails, ['Medical__c']: '$' + medicalSplitVal[0] + '/$' + medicalSplitVal[1] }
                    }
                } else {
                    if (this.communityUser != null && this.communityUser) {
                        this.policyType = this.customerRecord?.policyType;
                        this.quoteDetails = {
                            ...this.customerRecord?.vehicleData,
                            ...this.customerRecord?.quoteRecord,
                            Coverage__c: this.customerRecord?.vehicleData?.Coverage__c,
                            territory: this.customerRecord?.quoteRecord?.Territory__c,
                            Is_Towing: this.customerRecord?.Is_Towing__c ? 'Yes' : 'No',
                            towedUnits: this.customerRecord?.towedUnitData?.length > 0 ? this.customerRecord?.towedUnitData : [],
                        }
                        if (this.customerRecord?.quoteRecord != undefined && this.customerRecord?.quoteRecord?.Liability__c != undefined) {
                            this.updateLiabilityDataState(this.customerRecord?.quoteRecord?.Liability__c.replace(/,/g, ''));
                            this.quoteDetails = { ...this.quoteDetails, ['Liability__c']: this.customerRecord?.quoteRecord?.Liability__c?.replace(/,/g, '') }
                        }
                        if (this.customerRecord?.quoteRecord != undefined && this.customerRecord?.quoteRecord?.Medical__c != undefined) {
                            let medicalSplitVal = this.customerRecord?.quoteRecord?.Medical__c?.split('/');
                            this.updateMedicalDataState('$' + medicalSplitVal[0] + '/$' + medicalSplitVal[1]);
                            this.quoteDetails = { ...this.quoteDetails, ['Medical__c']: '$' + medicalSplitVal[0] + '/$' + medicalSplitVal[1] }
                        }
                    }
                }
            }
            await this.fetchQuoteData(this.quoteDetails);
            await this.fetchCoverageQuote();
        } catch (error) {
            console.log(error);
        }
    }

    updateLiabilityDataState(liability) {
        let liabilitylist = this.liabilitylist;
        let index = liabilitylist.indexOf(parseInt(liability));
        this.qualitasLiability = liabilitylist[index];
        this.chubbLiability = liabilitylist[index];
        this.mapfreLiability = liabilitylist[index];
    }

    updateMedicalDataState(medical) {
        let medicallist = this.medicallist;
        let index = medicallist.indexOf(medical);
        this.qualitasMedical = medicallist[index];
        this.chubbMedical = medicallist[index];
        this.mapfreMedical = medicallist[index];
    }

    getSystemTime = async () => {
        try {
            const timeData = await getTimeZone();
            if (timeData.status == 'success') {
                this.systemTime = timeData;
                this.displayPstTime = this.systemTime.timePst;
            } else {
                console.log('error occur in method to get system time');
            }
        } catch (ex) {
            console.log('erron occur in get system time : ' + ex);
        }
    }






    get startTime() {
        return this.msToTime(this.quoteDetails.Start_Time__c);
    }
    get endTime() {
        return this.msToTime(this.quoteDetails.End_Time__c);
    }
    get startDate() {
        return this.quoteDetails.Start_Date_for_Coverage__c;
    }
    get endData() {
        return this.quoteDetails.End_Date_for_Coverage__c;
    }



    automobileQualitasTermCondition = automobileQualitasTermConditionCustmLbel;
    automobileChubbTermCondition = automobileChubbTermCondCustmLbl;
    automobileMapfreTermCondition = 'https://mexinsurance.my.salesforce.com/sfc/p/15000000NeKA/a/6R000000ha3W/RUjt8B7rmI5UzzNXlLtf44JJLzqK3c_VcN5zqGh4zqA';

    highlightView() {
        this.IsHighlightView = !this.IsHighlightView;
    }


    openCHubbDocuments(event){

        console.log('policyType-> ',this.policyType);
        if (this.policyType == 'Automobile') {
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-chubb-english','_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-chubb-spanish','_blank');
            }, 100); // Add a slight delay to open the second URL
        }else if(this.policyType == 'RV'){
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-chubb-english','_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-chubb-spanish','_blank');
            }, 100); // Add a slight delay to open the second URL
        }else if(this.policyType == 'Motorcycle/Street Legal ATV'){
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-chubb-english','_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-chubb-spanish','_blank');
            }, 100); // Add a slight delay to open the second URL
        }else{
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-chubb-english','_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-chubb-spanish','_blank');
            }, 100); // Add a slight delay to open the second URL
        }
        
    }

    openMapFreDocuments(event){

        console.log('policyType-> ',this.policyType);
            if (this.policyType == 'Automobile') {
                setTimeout(() => {
                    console.log('English');
                    window.open('https://go.mexinsurance.com/current-terms-mapfre-english','_blank');
                }, 0); // Open the first URL
            
                setTimeout(() => {
                    console.log('Spanish')
                    window.open('https://go.mexinsurance.com/current-terms-mapfre-spanish','_blank');
                }, 100); // Add a slight delay to open the second URL
        }else if(this.policyType == 'RV'){
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-mapfre-english','_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-mapfre-spanish','_blank');
            }, 100); // Add a slight delay to open the second URL
        }else if(this.policyType == 'Motorcycle/Street Legal ATV'){
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-mapfre-english','_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-mapfre-spanish','_blank');
            }, 100); // Add a slight delay to open the second URL
        }else{
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-mapfre-english','_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-mapfre-spanish','_blank');
            }, 100); // Add a slight delay to open the second URL
        }
        
    }

    openQualitasDocuments(event){

        console.log('policyType-> ',this.policyType);
        if(this.policyType == 'Automobile'){
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-qualitas-english', '_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-qualitas-spanish', '_blank');
            }, 100); // Add a slight delay to open the second URL
        }else if(this.policyType == 'RV'){
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-qualitas-english', '_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-qualitas-spanish', '_blank');
            }, 100); // Add a slight delay to open the second URL
        }else if(this.policyType == 'Motorcycle/Street Legal ATV'){
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-qualitas-english', '_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-qualitas-spanish', '_blank');
            }, 100); // Add a slight delay to open the second URL          
        }else{
            setTimeout(() => {
                console.log('English');
                window.open('https://go.mexinsurance.com/current-terms-qualitas-english', '_blank');
            }, 0); // Open the first URL
        
            setTimeout(() => {
                console.log('Spanish')
                window.open('https://go.mexinsurance.com/current-terms-qualitas-spanish', '_blank');
            }, 100); // Add a slight delay to open the second URL
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
    async fetchQuoteData(quoteDetails) {
        console.log("Quote Details Fetch Quote ::::: ", JSON.stringify(quoteDetails, null, 4));
        let isValid = this.isInputValid();
        if (isValid) {
            let qt;
            if (!this.isRenewalPolicy) {
                qt = {
                    Policy_Type_picklist: quoteDetails.Vehicle_Type__c == 'Car/Truck/Auto' ? 'Automobile' : quoteDetails.Vehicle_Type__c,
                    Vehicle_Type: quoteDetails.Vehicle_Type__c,
                    Territory: quoteDetails.territory,
                    Is_Towing: quoteDetails.Is_Towing,
                    Is_there_a_driver_under_21: quoteDetails.Is_there_a_driver_under_21__c == 'Yes' ? 'Yes' : quoteDetails.Is_there_a_driver_under_21__c == true ? 'Yes' : 'No',
                    Salvage_Vehicle: quoteDetails.Salvage_Vehicle__c == 'Yes' ? 'Yes' : quoteDetails.Salvage_Vehicle__c == true ? 'Yes' : 'No',
                    Vehicle_used_for_Business_Purposes: quoteDetails.Is_the_vehicle_used_for_business_purpose__c == 'Yes' ? 'Yes' : quoteDetails.Is_the_vehicle_used_for_business_purpose__c == true ? 'Yes' : 'No',
                    Is_Rental_Vehicle: quoteDetails.Is_this_a_Rental_Vehicle__c == 'Yes' ? 'Yes' : quoteDetails.Is_this_a_Rental_Vehicle__c == true ? 'Yes' : 'No',
                    Vehicle_Sub_Type: quoteDetails.Vehicle_sub_type__c,
                    Vehicle_Value: quoteDetails.Value__c,
                    Start_Date_for_Coverage: quoteDetails.Start_Date_for_Coverage__c,
                    End_Date_for_Coverage: quoteDetails.End_Date_for_Coverage__c,
                    Liability: quoteDetails?.Liability__c ? quoteDetails?.Liability__c : "500000",
                    Liability_Type: quoteDetails?.Coverage__c ? quoteDetails?.Coverage__c : "Complete",
                    Medical: quoteDetails?.Medical__c ? quoteDetails?.Medical__c : "$10,000/$50,000",
                    towedUnits: quoteDetails.towedUnits,
                    // Liability__c:quoteDetails.Liability__c
                };

                    // Add the changes on 8 Aug for issue regarding chubb liability.
                    if(this.refreshPage != undefined && this.quoteDetails.QuotePdfJson__c != undefined){
                        const quotePdfJson = JSON.parse(this.quoteDetails.QuotePdfJson__c);
                        if(this.refreshPage === true){
                            this.refreshPage = false;
                            if(quotePdfJson.chubbLiability != null){
                                this.chubbLiability = quotePdfJson.chubbLiability;
                            }
                            if(quotePdfJson.qualitasLiability != null){
                                this.qualitasLiability = quotePdfJson.qualitasLiability;
                            }
                            if(quotePdfJson.mapfreLiability != null){
                                this.mapfreLiability = quotePdfJson.mapfreLiability;
                            }
                    }
                   }
            } else {

                // let medicalSplit = this.editpolicydata.quoteData.Medical__c?.split('/');
                qt = {
                    Policy_Type_picklist: this.editpolicydata.policyData.Policy_Type_picklist__c,
                    Vehicle_Type: this.editpolicydata.policyData.Vehicle_type__c,
                    Territory: this.editpolicydata.quoteData.Territory__c,
                    Is_Towing: this.editpolicydata.Is_Towing__c ? 'Yes' : 'No',
                    Is_there_a_driver_under_21: this.editpolicydata.quoteData.Is_there_a_driver_under_21__c,
                    Salvage_Vehicle: this.editpolicydata.quoteData.Salvage_Vehicle__c,
                    Vehicle_used_for_Business_Purposes: this.editpolicydata.quoteData.Vehicle_used_for_Business_Purposes__c,
                    Is_Rental_Vehicle: this.editpolicydata.quoteData.Is_this_a_Rental_Vehicle__c,
                    Vehicle_Sub_Type: this.editpolicydata?.quoteData?.Vehicle_Sub_type__c ? this.editpolicydata.quoteData.Vehicle_Sub_type__c : this.editpolicydata.vehicleData.Vehicle_Type__c ,
                    Vehicle_Value: this.editpolicydata.quoteData.Vehicle_Value__c,
                    Start_Date_for_Coverage: this.editpolicydata.quoteData.Start_Date_for_Coverage__c,
                    End_Date_for_Coverage: this.editpolicydata.quoteData.End_Date_for_Coverage__c,
                    Liability: this.editpolicydata?.quoteData?.Liability__c ? this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '') : "500000",
                    Liability_Type: this.editpolicydata.quoteData.Coverage__c ? this.editpolicydata.quoteData.Coverage__c : "Complete",
                    Medical: this.editpolicydata?.quoteData?.Medical__c ? this.editpolicydata?.quoteData?.Medical__c : "$10,000/$50,000",
                    towedUnits: this.editpolicydata !== null && this.editpolicydata.Is_Towing__c ? this.editpolicydata?.towedUnitData : [],
                };
                if(this.editpolicydata?.quoteData?.Liability__c){
                    let tempLiability = this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '');
                    if(tempLiability == '1000000'){
                        this.mapfreLiability = '500000';this.chubbLiability = tempLiability;this.qualitasLiability = tempLiability;
                    }else if(tempLiability == '100000'){
                        this.mapfreLiability = tempLiability;this.chubbLiability = '300000';this.qualitasLiability = tempLiability;
                    }else if(tempLiability == '200000'){
                        this.mapfreLiability = tempLiability;this.chubbLiability = '300000';this.qualitasLiability = tempLiability;
                    }else if(tempLiability == '400000'){
                        this.mapfreLiability = '500000';this.chubbLiability = tempLiability;this.qualitasLiability = '500000';
                    }else{
                        this.mapfreLiability = tempLiability;this.chubbLiability = tempLiability;this.qualitasLiability = tempLiability;
                    }   
                }
                
                // this.chubbLiability = this.editpolicydata?.quoteData?.Liability__c ? this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '') : "500000";
                // this.qualitasLiability = this.editpolicydata?.quoteData?.Liability__c ? this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '') : "500000";
                // this.mapfreLiability = this.editpolicydata?.quoteData?.Liability__c ? this.editpolicydata?.quoteData?.Liability__c?.replace(/,/g, '') : "500000";
            }

            console.log('Quote Data ::::: ', qt);
            console.log('JSON qt ::::: ', JSON.stringify(qt));
            console.log('qualitasLiability : ', this.qualitasLiability);

            console.log('chubbLiability::: ', this.chubbLiability);
            console.log('mapfreLiability:::: ', this.mapfreLiability);
            console.log('qualitasMedical::: ', this.qualitasMedical);
            console.log('chubbMedical:::: ', this.chubbMedical);
            console.log('mapfreMedical:::: ', this.mapfreMedical);
            
            if(this.chubbLiability === 100000){
                this.chubbLiability = 500000;
            }
            
            console.log('chubbLiability::: ', this.chubbLiability);
            if(this.qualitasMedical == undefined && this.chubbMedical == undefined  && this.mapfreMedical == undefined ){
                this.qualitasMedical = '$10,000/$50,000';
                this.chubbMedical = '$10,000/$50,000';
                this.mapfreMedical = '$5,000/$25,000';
                if(qt.Medical === "$/$undefined"){
                    qt.Medical="$10,000/$50,000";
                }
            }

            const res = await getQuote({
                'requestBody': JSON.stringify(qt),
                'qualitasLiability': this.qualitasLiability,
                'chubbLiability': this.chubbLiability,
                'mapfreLiability': this.mapfreLiability,
                'qualitasMedical': this.qualitasMedical,
                'chubbMedical': this.chubbMedical,
                'mapfreMedical': this.mapfreMedical
            });

            if (JSON.parse(res).error) {
                this.generateLogs();
                const e = new ShowToastEvent({
                    message: this.label.NoQuoteexistforthe,
                    variant: 'error'
                });
                this.dispatchEvent(e);
                return;
            }
            this.quickQuoteDetail = JSON.parse(res);
            console.log(res);
            console.log(this.quickQuoteDetail);

            if(this.quickQuoteDetail.qualitasQuote){
                console.log('xxxxxxxxxxxxxx Qualitas xxxxxxxxxxxxxxxxx');
                console.log('Theft Total: '+this.quickQuoteDetail.qualitasQuote.theft_Total);
                console.log('collision_deductible: '+this.quickQuoteDetail.qualitasQuote.collision_deductible);
                console.log('net_premium: '+this.quickQuoteDetail.qualitasQuote.net_premium);
                console.log('Term__c: '+this.quickQuoteDetail.qualitasQuote.Term__c);
                console.log('surcharge: '+this.quickQuoteDetail.qualitasQuote.surcharge);
                console.log('Policy_Fee: '+this.quickQuoteDetail.qualitasQuote.Policy_Fee);
                console.log('iva: '+this.quickQuoteDetail.qualitasQuote.iva);
                console.log('rateValue: '+this.quickQuoteDetail.qualitasQuote.rateValue);
                console.log('showQualitas: '+this.quickQuoteDetail.qualitasQuote.showQualitas);
                console.log('days: '+this.quickQuoteDetail.qualitasQuote.days);
                console.log('xxxxxxxxxxxxxx Qualitas xxxxxxxxxxxxxxxxx');
            }

            if (!this.quickQuoteDetail.qualitasQuote.showQualitas && !this.quickQuoteDetail.mapfreQuote.showMapfre && !this.quickQuoteDetail.chubbQuote.showChubb) {
                const evt = new ShowToastEvent({
                    message: this.label.Wedonothaveaprogram,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            } else if (this.quickQuoteDetail?.qualitasQuote == undefined && this.quickQuoteDetail?.qualitasQuote?.showQualitas == undefined && this.quickQuoteDetail.mapfreQuote.showMapfre && this.quickQuoteDetail.chubbQuote.showChubb) {
                this.quickQuoteDetail = { ...this.quickQuoteDetail, ['qualitasQuote']: { ...this.quickQuoteDetail?.qualitasQuote, ['showQualitas']: false } };
            } else if (this.quickQuoteDetail.qualitasQuote.showQualitas && this.quickQuoteDetail.mapfreQuote == undefined && this.quickQuoteDetail?.mapfreQuote?.showMapfre == undefined && this.quickQuoteDetail.chubbQuote.showChubb) {
                this.quickQuoteDetail = { ...this.quickQuoteDetail, ['mapfreQuote']: { ...this.quickQuoteDetail?.mapfreQuote, ['showMapfre']: false } };
            } else if (this.quickQuoteDetail.qualitasQuote.showQualitas && this.quickQuoteDetail.mapfreQuote.showMapfre && this.quickQuoteDetail?.chubbQuote == undefined && this.quickQuoteDetail?.chubbQuote?.showChubb == undefined) {
                this.quickQuoteDetail = { ...this.quickQuoteDetail, ['chubbQuote']: { ...this.quickQuoteDetail?.chubbQuote, ['showChubb']: false } };
            } else if (this.quickQuoteDetail?.qualitasQuote == undefined && this.quickQuoteDetail?.qualitasQuote?.showQualitas == undefined && this.quickQuoteDetail.mapfreQuote == undefined && this.quickQuoteDetail?.mapfreQuote?.showMapfre == undefined && this.quickQuoteDetail?.chubbQuote?.showChubb) {
                this.quickQuoteDetail = { ...this.quickQuoteDetail, ['qualitasQuote']: { ...this.quickQuoteDetail?.qualitasQuote, ['showQualitas']: false }, ['mapfreQuote']: { ...this.quickQuoteDetail?.mapfreQuote, ['showMapfre']: false } };
            } else if (this.quickQuoteDetail?.qualitasQuote?.showQualitas && this.quickQuoteDetail.mapfreQuote == undefined && this.quickQuoteDetail?.mapfreQuote?.showMapfre == undefined && this.quickQuoteDetail?.chubbQuote == undefined && this.quickQuoteDetail?.chubbQuote?.showChubb == undefined) {
                this.quickQuoteDetail = { ...this.quickQuoteDetail, ['chubbQuote']: { ...this.quickQuoteDetail?.chubbQuote, ['showChubb']: false }, ['mapfreQuote']: { ...this.quickQuoteDetail?.mapfreQuote, ['showMapfre']: false } };
            } else if (this.quickQuoteDetail?.qualitasQuote == undefined && this.quickQuoteDetail?.qualitasQuote?.showQualitas == undefined && this.quickQuoteDetail.mapfreQuote.showMapfre && this.quickQuoteDetail?.chubbQuote == undefined && this.quickQuoteDetail?.chubbQuote?.showChubb == undefined) {
                this.quickQuoteDetail = { ...this.quickQuoteDetail, ['chubbQuote']: { ...this.quickQuoteDetail?.chubbQuote, ['showChubb']: false }, ['qualitasQuote']: { ...this.quickQuoteDetail?.qualitasQuote, ['showQualitas']: false } };
            }
        } else {
            console.log('field filled are not valid');
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

    async updateLibilityValue(event) {
        let value = event.target.checked;
        let name = event.target.name;
        if (!value && name == 'Liability') {
            name = 'Complete';
        }
        let updateValue = value ? 'Liability' : 'Complete';
        if (!this.isRenewalPolicy) {
            this.quoteDetails = { ...this.quoteDetails, ['Coverage__c']: name };
        } else {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Coverage__c']: name } }
        }

        await this.fetchQuoteData(this.quoteDetails);
        await this.fetchCoverageQuote();
    }

    async handleChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        let endDateFormated;
        if (name == 'Start_Date_for_Coverage__c') {

            let startDate = new Date(value);
            let month = startDate.getMonth() + 1;
            let day = startDate.getDate() + 1;
            let year = startDate.getFullYear();

            let endmindate = new Date(year, month, day);
            this.endMinDate = startDate;
        }

        if (name == 'Start_Date_for_Coverage__c') {
            let startDayForCoverage = new Date(value);
            let endDayForCoverage = startDayForCoverage;
            if (this.quoteDetails.Term__c === 'Annual(One Year)') {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (this.quoteDetails.Term__c == 'Semi-Annual(Half a Year)') {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            } else {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + parseInt(this.quickQuoteDetail?.qualitasQuote?.days != undefined ? this.quickQuoteDetail.qualitasQuote.days : '1'));
            }

            const date = new Date(endDayForCoverage);
            let month = date.getMonth() + 1;
            let day = date.getDate();

            endDateFormated = date.getFullYear() + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(day);

            this.quoteDetails['End_Date_for_Coverage__c'] = endDateFormated;
        }

        if (this.isRenewalPolicy == 'Yes') {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: value } };
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Date_for_Coverage__c']: endDateFormated } };
            this.quoteDetails[name] = value;
        } else {
            this.quoteDetails[name] = value;
        }
        await this.fetchQuoteData(this.quoteDetails);
    }

    toDigitFormate(n) {
        return n > 9 ? "" + n : "0" + n;
    }

    async updateMedical(event) {
        var name = event.target.name;
        var type = event.target.dataset.type;
        var medicallist = this.medicallist;
        if(name && name == 'chubbMedical'){
            medicallist = this.chubbmedicallist;
        }
        var length = (medicallist.length - 1);

        var medical = '';
        if (name && name == 'qualitasMedical') {
            medical = this.qualitasMedical
        } else if (name && name == 'chubbMedical') {
            medical = this.chubbMedical
        } else if (name && name == 'mapfreMedical') {
            medical = this.mapfreMedical
        }

        var index = medicallist.indexOf(medical);
        var updateMedical;
        if (type && type == 'high') {
            if (length != index) {
                updateMedical = medicallist[index + 1];
            }
        } else if (type && type == 'low') {
            if (index != 0) {
                updateMedical = medicallist[index - 1];
            }
        }

        if (name && name == 'mapfreMedical' && (updateMedical == '$20,000/$100,000' || updateMedical == '$15,000/$75,000')) {
            updateMedical = '$10,000/$50,000';
        }

        if (name && name == 'qualitasMedical' && updateMedical && updateMedical != null) {
            this.qualitasMedical = updateMedical;

        } else if (name && name == 'mapfreMedical' && updateMedical && updateMedical != null) {
            this.mapfreMedical = updateMedical;

        } else if (name && name == 'chubbMedical' && updateMedical && updateMedical != null) {
            this.chubbMedical = updateMedical;
        }

        if (!this.isRenewalPolicy) {
            this.quoteDetails = { ...this.quoteDetails, ['Medical__c']: updateMedical != null ? updateMedical : this.quoteDetails.Medical__c };
        } else {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Medical__c']: updateMedical != null ? updateMedical : this.editpolicydata.quoteData.Medical__c } }
        }

        if (updateMedical && updateMedical != null) {
            await this.fetchQuoteData(this.quoteDetails);
        }
    }
    async updateLiability(event) {
        var name = event.target.name;
        var type = event.target.dataset.type;
        console.log('changed-> name->  '+name);
        console.log('changed-> type->  '+type);

        var liabilitylist = this.liabilitylist;
        if(name  && name == 'chubbLiability'){
            console.log('mapping chubb liability ');
            liabilitylist = this.Chubbliabilitylist;
        }
        var length = (liabilitylist.length - 1);
        var liablity = '';
        if (name && name == 'qualitasLiability') {
            liablity = this.qualitasLiability;
        } else if (name && name == 'chubbLiability') {
            liablity = this.chubbLiability;
        } else if (name && name == 'mapfreLiability') {
            liablity = this.mapfreLiability;
        }

        var updatelibality;
        if (type && type == 'high') {
            var index = liabilitylist.indexOf(parseInt(liablity));
            if (length != index) {
                updatelibality = liabilitylist[index + 1];
            }
        } else if (type && type == 'low') {
            var index = liabilitylist.indexOf(parseInt(liablity));
            if (index != 0) {
                updatelibality = liabilitylist[index - 1];
            }
        }
        if (name && name == 'mapfreLiability' && (updatelibality == '1000000')) {
            updatelibality = 300000;
        }

        if (name && name == 'qualitasLiability' && updatelibality && updatelibality != null) {
            this.qualitasLiability = updatelibality;
            console.log('changed QUalitas');
        } else if (name && name == 'chubbLiability' && updatelibality && updatelibality != null) {
            this.chubbLiability = updatelibality;
            console.log('changed Chubb');
        } else if (name && name == 'mapfreLiability' && updatelibality && updatelibality != null) {
            this.mapfreLiability = updatelibality;
            console.log('changed Mapfre');
        }

        if (!this.isRenewalPolicy) {
            this.quoteDetails = { ...this.quoteDetails, ['Liability__c']: updatelibality != null ? updatelibality.toString() : this.quoteDetails.Liability__c };
        } else {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Liability__c']: updatelibality != null ? updatelibality.toString() : this.editpolicydata.quoteData.Liability__c } }
        }

        if (updatelibality && updatelibality != null) {
            await this.fetchQuoteData(this.quoteDetails);
        }
    }

    updateSelectQuote(event) {
        let value = event.target.checked;
        let name = event.target.name;
        if (name != '') {
            this.quickQuoteDetail = { ...this.quickQuoteDetail, [name]: value }
        }
    }

    SaveQuoteHandle = async () => {
        this.isSaveQuote = true;
    }
    saveQuoteDetailData = async () => {
        this.saveQuoteData = {
            Start_Date_for_Coverage__c: this.quoteDetails.Start_Date_for_Coverage__c,
            End_Time__c: this.quoteDetails.End_Time__c,
            End_Date_for_Coverage__c: this.quoteDetails.End_Date_for_Coverage__c,
            Vehicle_used_for_Business_Purposes__c: this.quoteDetails.Is_the_vehicle_used_for_business_purpose__c,
            Is_there_a_driver_under_21__c: this.quoteDetails.Is_there_a_driver_under_21__c == true ? 'Yes' : 'No',
            Is_this_a_Rental_Vehicle__c: this.quoteDetails.Is_this_a_Rental_Vehicle__c,
            Liability__c: this.quoteDetails.Liability__c == '100000' ? '100,000' : this.quoteDetails.Liability__c == '200000' ? '200,000' : this.quoteDetails.Liability__c == '300000' ? '300,000' : this.quoteDetails.Liability__c == '500000' ? '500,000' : this.quoteDetails.Liability__c == '1000000' ? '1,000,000' : '300,000',
            Vehicle_Make__c: this.quoteDetails.Make__c,
            Vehicle_Model__c: this.quoteDetails.Model__c,
            Salvage_Vehicle__c: this.quoteDetails.Salvage_Vehicle__c == true ? 'Yes' : 'No',
            Start_Time__c: this.quoteDetails.Start_Time__c,
            Vehicle_Value__c: this.quoteDetails.Value__c,
            Vehicle_Type__c: this.quoteDetails.Vehicle_Type__c,
            Vehicle_sub_type__c: this.quoteDetails.Vehicle_sub_type__c,
            Vehicle_Year__c: this.quoteDetails.Year__c,
            Term__c: this.quoteDetails.Term__c,
            Territory__c: this.quoteDetails.territory == 'Baja Sonora' ? 'Baja/Sonora' : this.quoteDetails.territory,
            Policy_Type_picklist__c: this.quoteDetails.Vehicle_Type__c == 'Car/Truck/Auto' ? 'Automobile' : this.quoteDetails.Vehicle_Type__c,
            Medical__c: this.quoteDetails.Medical__c == '$2,000/$10,000' ? '2,000/10,000' : this.quoteDetails.Medical__c == '$3,000/$15,000' ? '3,000/15,000' : this.quoteDetails.Medical__c == '$4,000/$20,000' ? '4,000/20,000' : this.quoteDetails.Medical__c == '$5,000/$25,000' ? '5,000/25,000' : this.quoteDetails.Medical__c == '$10,000/$50,000' ? '10,000/50,000' : this.quoteDetails.Medical__c == '$15,000/$75,000' ? '15,000/75,000' : this.quoteDetails.Medical__c == '$20,000/$100,000' ? '20,000/100,000' : '5,000/25,000',
            Coverage__c: this.quoteDetails.Coverage__c || 'Complete',
            Towed_Unit__c: this.quoteDetails.Is_Towing,
            // Id: this.leaddata.quoteId 

        };

        if (this.leaddata?.quoteId) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Id']: this.leaddata.quoteId };
        } else if (this.customerRecord?.quoteRecord?.Id) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Id']: this.customerRecord?.quoteRecord?.Id }
        }

    }
    savedQuoteDetail = async () => {
        this.saveQuoteDetailData();

        this.quickQuoteDetail = {
            ...this.quickQuoteDetail, ['qualitasLiability']: this.qualitasLiability, ['qualitasMedical']: this.qualitasMedical,
            ['chubbLiability']: this.chubbLiability, ['chubbMedical']: this.chubbMedical,
            ['mapfreLiability']: this.mapfreLiability, ['mapfreMedical']: this.mapfreMedical
        };

        this.saveQuoteData = { ...this.saveQuoteData, ['QuotePdfJson__c']: JSON.stringify(this.quickQuoteDetail) }
        await this.insertAndUpdateQuote(this.saveQuoteData);

    }
    insertAndUpdateQuote = async (saveQuote) => {
        if (this.communityUser != null && this.communityUser) {
          
            this.pdfQuotes = await saveQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord, ...saveQuote }), "vehicleRecord": JSON.stringify(this.customerRecord?.vehicleData), "towedUnitRecord": this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify([...this.customerRecord?.towedUnitData]) : '' });
            if (this.pdfQuotes.status == 'success') {
                this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...this.pdfQuotes.quoteData } };
                this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...this.pdfQuotes.vehicleData } };



                if (this.pdfQuotes?.towedUnitData?.length) {
                    this.customerRecord = { ...this.customerRecord, ['towedUnitData']: [...this.pdfQuotes.towedUnitData] };
                }
                const customerRecordChange = new CustomEvent('customerecordchange', {
                    detail: this.customerRecord,
                });

                this.dispatchEvent(customerRecordChange);
            }else{
                this.generateLogs();
            }
        } else {
            console.log('saving quote-> '+JSON.stringify(saveQuote));
            this.pdfQuotes = await insertNewQuotes({ "quotes": JSON.stringify(saveQuote), "leadId": this.leaddata?.Id });
            if (this.pdfQuotes.status == 'success') {
                this.leaddata = { ...this.leaddata, ['quoteId']: this.pdfQuotes.data.Id };
                const leadChange = new CustomEvent('leadvaluechange', {
                    detail: this.leaddata,
                });
                this.dispatchEvent(leadChange);
            }else{
                this.generateLogs();
            }
        }

    }
    downloadQuote = async () => {
        if (!this.quickQuoteDetail.Qualitas && !this.quickQuoteDetail.Chubb && !this.quickQuoteDetail.Mapfre) {
            const e = new ShowToastEvent({
                message: this.label.Kindlyselectanyoptionfirst,
                variant: 'error'
            });
            this.dispatchEvent(e);
            return;
        }
        await this.savedQuoteDetail();
        this.isSaveQuote = false;
        let quoteIdforPdf = '';
        
        if (this.communityUser != null && this.communityUser) {
            quoteIdforPdf = this.customerRecord.quoteRecord.Id;
        } else {
            quoteIdforPdf = this.pdfQuotes.data.Id;
        }

        window.open(window.location.origin+`/s/quoterate?Id=${quoteIdforPdf}`, "_blank")
        

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: window.location.origin + '/apex/selectedQuoteRate?Id=' + quoteIdforPdf,
        //         actionName: 'view'
        //     },
        // })
    }

    sendEmailQuoteDetail = async () => {
        if (!this.quickQuoteDetail.Qualitas && !this.quickQuoteDetail.Chubb && !this.quickQuoteDetail.Mapfre) {
            this.generateLogs();
            const e = new ShowToastEvent({
                message: this.label.Kindlyselectanyoptionfirst,
                variant: 'error'
            });
            this.dispatchEvent(e);
            return;
        }
        await this.savedQuoteDetail();
        this.isSaveQuote = false;
        let quoteIdforPdf = '';
        if (this.communityUser != null && this.communityUser) {
            quoteIdforPdf = this.customerRecord.quoteRecord.Id;
        } else {
            quoteIdforPdf = this.pdfQuotes.data.Id;
        }
        let sendEmailOfQuoteDetail = await sendEmailQuoteDetails({ 'quoteId': quoteIdforPdf });
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
    cancleEdit() {
        this.isSaveQuote = false;
    }



    fetchCoverageQuote = async () => {
        if (this.isRenewalPolicy == 'Yes') {
            this.quoteDetails = { ...this.quoteDetails, ['Coverage__c']: this.editpolicydata.quoteData.Coverage__c }
        }
        console.log('refreshing coverages ');
        console.log('refreshing coverages '+this.quoteDetails.Coverage__c);

        let mainCoverageMap = await getExactCoverageDetailForSouthbound({ 'pickList': this.policyType, 'packageType': this.quoteDetails.Coverage__c });
        if (mainCoverageMap != undefined && mainCoverageMap != null) {
            //this.quickQuoteDetail = { ...this.quickQuoteDetail, ['Coverage']: mainCoverageMap }
            mainCoverageMap.Qualitas.map((data) => {
                if (data.Package__c == "Liability" && this.quoteDetails.Coverage__c == 'Liability') {
                    if ((this.quoteDetails.territory == 'Baja Sonora' || this.quoteDetails.territory == 'Baja/Sonora' || this.quoteDetails.territory == 'Limited' || this.quoteDetails.territory == 'Partial (US Adjacent)')
                        && data.Territory_Discount__c == 'Yes') {
                        this.coverageMap = { ...this.coverageMap, ['Qualitas']: data };
                    } else {
                        this.coverageMap = { ...this.coverageMap, ['Qualitas']: data };
                    }
                } else if (this.quoteDetails.Coverage__c != 'Liability') {
                    this.coverageMap = { ...this.coverageMap, ['Qualitas']: data };
                }
                console.log('coveragemAp--->>>>>>>>',this.coverageMap);
            })

            mainCoverageMap.Chubb.map((data) => {
                if (data.Package__c == "Liability" && this.quoteDetails.Coverage__c == 'Liability') {
                    this.coverageMap = { ...this.coverageMap, ['Chubb']: data };
                } else if (this.quoteDetails.Coverage__c != 'Liability') {
                    this.coverageMap = { ...this.coverageMap, ['Chubb']: data };
                }
            })


            mainCoverageMap.Mapfre.forEach(currentItem => {
                if (this.quoteDetails.Coverage__c == 'Liability' && currentItem.Package__c == 'Liability') {
                    this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                } else if (this.quoteDetails.Coverage__c == 'Max' && currentItem.Package__c == 'Max') {
                    this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                } else if (this.quoteDetails.Coverage__c == 'Complete' && currentItem.Package__c == 'Complete') {
                    this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                } else if (this.quoteDetails.Coverage__c == 'Full' && currentItem.Package__c == 'Full') {
                    this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                } else if (this.quoteDetails.Coverage__c == 'LiabilityTheft' && currentItem.Package__c == 'LiabilityTheft') {
                    this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                }
            });
        }
        console.log('retrieved final json-> '+ JSON.stringify(this.coverageMap));
    }

    handleNextClick = async (event) => {
        let selectQuoteName = event.target.dataset.id;

        let selectQuote = this.quickQuoteDetail[selectQuoteName];

        if (selectQuoteName == 'chubbQuote' && this.isRenewalPolicy == 'Yes') {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata?.quoteData, ['Liability__c']: this.chubbLiability, ['Medical']: this.chubbMedical } };
        } else if (selectQuoteName == 'chubbQuote' && !this.isRenewalPolicy) {
            this.quoteDetails = { ...this.quoteDetails, ['Liability__c']: this.chubbLiability, ['Medical__c']: this.chubbMedical };
        } else if (selectQuoteName == 'mapfreQuote' && this.isRenewalPolicy == 'Yes') {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata?.quoteData, ['Liability__c']: this.mapfreLiability, ['Medical__c']: this.mapfreMedical } };
        } else if (selectQuoteName == 'mapfreQuote' && !this.isRenewalPolicy) {
            this.quoteDetails = { ...this.quoteDetails, ['Liability__c']: this.mapfreLiability, ['Medical__c']: this.mapfreMedical };
        } else if (selectQuoteName == 'qualitasQuote' && this.isRenewalPolicy == 'Yes') {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata?.quoteData, ['Liability__c']: this.qualitasLiability, ['Medical__c']: this.qualitasMedical } };
        } else if (selectQuoteName == 'qualitasQuote' && !this.isRenewalPolicy) {
            this.quoteDetails = { ...this.quoteDetails, ['Liability__c']: this.qualitasLiability, ['Medical__c']: this.qualitasMedical };
        }

        if (this.isRenewalPolicy == 'Yes') {

            if (this.editpolicydata.Is_Towing__c == 'Yes' || this.editpolicydata.Is_Towing__c == true) {
                if (parseInt(this.editpolicydata.quoteData.Term_Days__c) < parseInt(this.editpolicydata.towedUnitData[0].Days_in_Tow__c)) {
                    const errorMsg = new ShowToastEvent({
                        title: 'Error',
                        message: this.label.DaysinTowvaluecantbe,
                        variant: 'error',
                    });
                    this.dispatchEvent(errorMsg);

                    return;
                }
            }

            this.editpolicydata = {
                ...this.editpolicydata, ['quoteData']: {
                    ...this.editpolicydata.quoteData,
                    ['Net_Premium__c']: selectQuote.net_premium,
                    ['Broker_Policy_Fee__c']: selectQuote.Policy_Fee,
                    ['I_V_A_Mex_Tax__c']: selectQuote.iva,
                    ['Quote_Value__c']: selectQuote.rateValue,
                    ['Surcharge__c']: selectQuote.surcharge,
                    ['Vehicle_deductible_collision__c']: selectQuote.collision_deductible,
                    ['Vehicle_deductible_comprehensive__c']: selectQuote.theft_Total,
                    ['Underwriter__c']: selectQuoteName == 'qualitasQuote' ? 'Qualitas' : selectQuoteName == 'chubbQuote' ? 'Chubb' : 'Mapfre',
                    ['Physical_Damage__c']: selectQuote?.physicalDamagePayment ? selectQuote.physicalDamagePayment : 0,
                    ['Total_Theft_Payment__c']: selectQuote?.totalTheftPayment ? selectQuote.totalTheftPayment : 0,
                    ['Liability_Payment__c']: selectQuote?.LiabilityPayment ? selectQuote.LiabilityPayment : 0,
                    ['Medical_Payment__c']: selectQuote?.medicalPayment ? selectQuote.medicalPayment : 0,
                    ['Platinum_Endorsment__c']: selectQuote?.platinumEndorsementPayment ? selectQuote.platinumEndorsementPayment : 0,
                }
            }

            this.editpolicydata = {
                ...this.editpolicydata,
                ['quoteData']: {
                    ...this.editpolicydata.quoteData,
                    ['Coverage']: (selectQuoteName == 'qualitasQuote' || selectQuoteName == 'chubbQuote') && this.editpolicydata?.quoteData?.Coverage__c == 'Max' ? 'Complete' : this.editpolicydata?.quoteData?.Coverage__c,
                }
            }
            this.editpolicydata = {
                ...this.editpolicydata, ['quoteData']: {
                    ...this.editpolicydata.quoteData,
                    ['Liability__c']: this.editpolicydata.quoteData.Liability__c == '100000' ? '100,000' : this.editpolicydata.quoteData.Liability__c == '200000' ? '200,000' : this.editpolicydata.quoteData.Liability__c == '300000' ? '300,000' : this.editpolicydata.quoteData.Liability__c == '500000' ? '500,000' : this.editpolicydata.quoteData.Liability__c == '1000000' ? '1,000,000' : '300,000',
                }
            }

            if (this.editpolicydata?.quoteData?.Policy_Type_picklist__c != 'Motorcycle/Street Legal ATV') {
                this.editpolicydata = {
                    ...this.editpolicydata, ['quoteData']: {
                        ...this.editpolicydata.quoteData,
                        ['Medical__c']: this.editpolicydata.quoteData.Medical__c == '$2,000/$10,000' ? '2,000/10,000' : this.editpolicydata.quoteData.Medical__c == '$3,000/$15,000' ? '3,000/15,000' : this.editpolicydata.quoteData.Medical__c == '$4,000/$20,000' ? '4,000/20,000' : this.editpolicydata.quoteData.Medical__c == '$5,000/$25,000' ? '5,000/25,000' : this.editpolicydata.quoteData.Medical__c == '$10,000/$50,000' ? '10,000/50,000' : this.editpolicydata.quoteData.Medical__c == '$15,000/$75,000' ? '15,000/75,000' : this.editpolicydata.quoteData.Medical__c == '$20,000/$100,000' ? '20,000/100,000' : '5,000/25,000',
                    }
                }
            }

            if (this.editpolicydata?.quoteData?.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV') {
                this.editpolicydata.quoteData.Medical__c = '';
            }

            let updateCloneQuote = await updateQuoteData({ 'quote': JSON.stringify(this.editpolicydata.quoteData) });
            if (updateCloneQuote.status == 'success') {
                const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                    detail: this.editpolicydata,
                });
                // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_7');
                // if (eventExist == undefined){
                //     window.dataLayer.push({
                //         'event': 'funnel_step',
                //         'step_number': 'step_7',
                //         'step_name': 'plan_selection', 
                //         'underwriter_selected': this.editpolicydata.quoteData.Underwriter__c,
                //         'insurance_category': this.editpolicydata.quoteData.Policy_Type_picklist__c
                //         });
                // }
                this.dispatchEvent(editPolicyChange);
                this.changesnextscreen();
            }


        } else if (!this.isRenewalPolicy) {
            if (!this.communityUser && (this.quoteDetails?.Is_Towing == 'Yes' || this.quoteDetails?.Is_Towing == true)) {
                if (parseInt(this.quoteDetails.Term_Days__c) < parseInt(this.quoteDetails.towedUnits[0].Days_in_Tow__c)) {
                    const errorMsg = new ShowToastEvent({
                        title: 'Error',
                        message: this.label.DaysinTowvaluecantbe,
                        variant: 'error',
                    });
                    this.dispatchEvent(errorMsg);

                    return;
                }
            }

            if (this.communityUser && (this.customerRecord?.Is_Towing__c == 'Yes' || this.customerRecord?.Is_Towing__c == true)) {
                if (parseInt(this.customerRecord.quoteRecord.Term_Days__c) < parseInt(this.customerRecord.towedUnitData[0].Days_in_Tow__c)) {
                    const errorMsg = new ShowToastEvent({
                        title: 'Error',
                        message: this.label.DaysinTowvaluecantbe,
                        variant: 'error',
                    });
                    this.dispatchEvent(errorMsg);

                    return;
                }
            }


            let saveQuoteData = {
                Start_Date_for_Coverage__c: this.quoteDetails.Start_Date_for_Coverage__c,
                End_Time__c:  this.quoteDetails.End_Time__c ,
                End_Date_for_Coverage__c: this.quoteDetails.End_Date_for_Coverage__c,
                Vehicle_used_for_Business_Purposes__c: this.quoteDetails.Is_the_vehicle_used_for_business_purpose__c,
                Is_there_a_driver_under_21__c: this.quoteDetails.Is_there_a_driver_under_21__c == true ? 'Yes' : 'No',
                Is_this_a_Rental_Vehicle__c: this.quoteDetails.Is_this_a_Rental_Vehicle__c,
                Vehicle_Make__c: this.quoteDetails.Make__c,
                Vehicle_Model__c: this.quoteDetails.Model__c,
                Salvage_Vehicle__c: this.quoteDetails.Salvage_Vehicle__c == true ? 'Yes' : 'No',
                Start_Time__c: this.quoteDetails.Start_Time__c ,
                Vehicle_Value__c: this.quoteDetails.Value__c,
                Vehicle_Type__c: this.quoteDetails.Vehicle_Type__c,
                Vehicle_sub_type__c: this.quoteDetails.Vehicle_sub_type__c,
                Vehicle_Year__c: this.quoteDetails.Year__c,
                Term__c: this.quoteDetails.Term__c,
                Territory__c: this.quoteDetails.territory == 'Baja Sonora' ? 'Baja/Sonora' : this.quoteDetails.territory,
                Policy_Type_picklist__c: this.quoteDetails.Vehicle_Type__c == 'Car/Truck/Auto' ? 'Automobile' : this.quoteDetails.Vehicle_Type__c,
                Net_Premium__c: selectQuote.net_premium,
                Broker_Policy_Fee__c: selectQuote.Policy_Fee != undefined ? selectQuote.Policy_Fee : 0,
                Term_Days__c: selectQuote.days != undefined ? selectQuote.days : 0,
                I_V_A_Mex_Tax__c: selectQuote.iva != undefined ? selectQuote.iva : 0,
                Quote_Value__c: selectQuote.rateValue != undefined ? selectQuote.rateValue : 0,
                Surcharge__c: selectQuote.surcharge != undefined ? selectQuote.surcharge : 0,
                Underwriter__c: selectQuoteName == 'qualitasQuote' ? 'Qualitas' : selectQuoteName == 'chubbQuote' ? 'Chubb' : 'Mapfre',
                Coverage__c: (selectQuoteName == 'qualitasQuote' || selectQuoteName == 'chubbQuote') && this.quoteDetails?.Coverage__c == 'Max' ? 'Complete' : this.quoteDetails?.Coverage__c != undefined ? this.quoteDetails?.Coverage__c : 'Complete',
                Towed_Unit__c: this.quoteDetails.Is_Towing,
                Vehicle_deductible_collision__c: selectQuote.collision_deductible != undefined ? selectQuote.collision_deductible : '0',
                Vehicle_deductible_comprehensive__c: selectQuote.theft_Total != undefined ? selectQuote.theft_Total : '0',
                Physical_Damage__c: selectQuote?.physicalDamagePayment ? selectQuote.physicalDamagePayment : 0,
                Total_Theft_Payment__c: selectQuote?.totalTheftPayment ? selectQuote.totalTheftPayment : 0,
                Liability_Payment__c: selectQuote?.LiabilityPayment ? selectQuote.LiabilityPayment : 0,
                Medical_Payment__c: selectQuote?.medicalPayment ? selectQuote.medicalPayment : 0,
                Platinum_Endorsment__c: selectQuote?.platinumEndorsementPayment ? selectQuote.platinumEndorsementPayment : 0,
            };

            if (typeof this.quoteDetails.End_Time__c === 'string' && this.quoteDetails.End_Time__c.includes(':')) {
                saveQuoteData = {...saveQuoteData,['End_Time__c']: this.quoteDetails.End_Time__c + 'Z'};
            }

            if (typeof this.quoteDetails.End_Time__c === 'string' && this.quoteDetails.Start_Time__c.includes(':')) {
                saveQuoteData = {...saveQuoteData,['Start_Time__c']: this.quoteDetails.Start_Time__c + 'Z'};
            }

            saveQuoteData = {
                ...saveQuoteData,
                ['Liability__c']: this.quoteDetails.Liability__c == '100000' ? '100,000' : this.quoteDetails.Liability__c == '200000' ? '200,000' : this.quoteDetails.Liability__c == '300000' ? '300,000' : this.quoteDetails.Liability__c == '500000' ? '500,000' : this.quoteDetails.Liability__c == '1000000' ? '1,000,000' : '300,000',
            }

            if (this.policyType != 'Motorcycle/Street Legal ATV') {
                saveQuoteData = {
                    ...saveQuoteData,
                    ['Medical__c']: this.quoteDetails.Medical__c == '$2,000/$10,000' ? '2,000/10,000' : this.quoteDetails.Medical__c == '$3,000/$15,000' ? '3,000/15,000' : this.quoteDetails.Medical__c == '$4,000/$20,000' ? '4,000/20,000' : this.quoteDetails.Medical__c == '$5,000/$25,000' ? '5,000/25,000' : this.quoteDetails.Medical__c == '$10,000/$50,000' ? '10,000/50,000' : this.quoteDetails.Medical__c == '$15,000/$75,000' ? '15,000/75,000' : this.quoteDetails.Medical__c == '$20,000/$100,000' ? '20,000/100,000' : '5,000/25,000',
                }
            }
            else if(this.policyType === 'Motorcycle/Street Legal ATV'){
                console.log('Medical liablity data');
                saveQuoteData = {
                    ...saveQuoteData,
                    ['Medical__c']: this.quoteDetails.Medical__c == '$5,000/$25,000' ? '5,000/25,000' : '$10,000/$50,000',
                }
            }

            if (this.customerRecord?.quoteRecord.Id != null || this.customerRecord?.quoteRecord.Id != undefined) {
                saveQuoteData.Id = this.quoteDetails.Id;
            }

            let isValid = this.isInputValid();
            if (isValid) {
                if (this.communityUser != null && this.communityUser) {
                    console.log('this.communityUser != null line: 1135');
                    let quoteResponse;
                    if (this.customerRecord != null && this.customerRecord?.quoteRecord?.Id != null && this.customerRecord?.vehicleData?.Id) {
                        console.log('this.customerRecord != null line: 1138');
                        console.log('JSON:::');
                        console.log('quoteRecord-> '+JSON.stringify({ ...this.customerRecord?.quoteRecord, ...saveQuoteData }));
                        console.log('vehicleRecord-> '+JSON.stringify(this.customerRecord?.vehicleData));
                        console.log('towedUnitRecord-> '+JSON.stringify(this.customerRecord?.towedUnitData));
                        
                        quoteResponse = await updateQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord, ...saveQuoteData }), "vehicleRecord": JSON.stringify(this.customerRecord?.vehicleData), "towedUnitRecord": this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify(this.customerRecord?.towedUnitData) : '', "driversRecord": '' });
                    } else {
                        quoteResponse = await saveQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord, ...saveQuoteData }), "vehicleRecord": JSON.stringify(this.customerRecord?.vehicleData), "towedUnitRecord": this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify(this.customerRecord?.towedUnitData) : '' });
                    }

                    if (quoteResponse.status == 'success') {
                        this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...quoteResponse.quoteData }, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...quoteResponse.vehicleData } };

                        if (quoteResponse?.towedUnitData?.length) {
                            this.customerRecord = { ...this.customerRecord, ['towedUnitData']: [...quoteResponse.towedUnitData] };
                        }

                        const customerRecordChange = new CustomEvent('customerecordchange', {
                            detail: this.customerRecord,
                        });

                        this.dispatchEvent(customerRecordChange);
                    }else{
                        this.generateLogs();
                    }
                } else {
                    console.log('this.communityUser != null else line: 1159');
                    console.log('Save Quote Data :::: ', JSON.stringify(saveQuoteData, null, 4));
                    if (this.quoteDetails?.Id) {
                        saveQuoteData.Id = this.quoteDetails?.Id;
                    }
                    console.log('saveQuoteData -> '+JSON.stringify(saveQuoteData));
                    let quote = await insertNewQuotes({ "quotes": JSON.stringify(saveQuoteData), "leadId": this.leaddata?.Id });
                    if (quote.status == 'success') {
                        this.leaddata = { ...this.leaddata, ['quoteId']: quote.data.Id };

                        let eventExist = window.dataLayer.find((data) => data.step_number === 'step_7');
                        if (eventExist == undefined){
                            window.dataLayer.push({
                                'event': 'funnel_step',
                                'step_number': 'step_7',
                                'step_name': 'plan_selection', 
                                'underwriter_selected': saveQuoteData?.Underwriter__c,
                                'insurance_category': this.policyType
                                });
                        }
                        
                        const leadChange = new CustomEvent('leadvaluechange', {
                            detail: this.leaddata,
                        });
                        this.dispatchEvent(leadChange);
                    }else{
                        this.generateLogs();
                    }
                }

                this.changesnextscreen();
            }
        }




    }
    async createCloneQuotes() {
        try {
            let { Id, ...rest } = this.editpolicydata.quoteData;

            let data = await createCloneQuote({ 'quote': JSON.stringify(rest), 'oldQuoteId': Id });
            if (data.status == 'success') {
                return data.data;
            } else {
                console.log('--else part--', data);
            }

        } catch (error) {
            this.generateLogs();
            console.log(error);
        }
    }
    handlePrevClick() {
        this.changeprevscreen();
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}