import { LightningElement, api } from 'lwc';
import images from '@salesforce/resourceUrl/mexJs';
import getCoverageDetailForSouthbound from '@salesforce/apex/Mex_QuickQuoteCommonController.getCoverageDetailForSouthbound';
import getDateForQuoteScreen from '@salesforce/apex/Mex_NewLeadProcess.getDateForQuoteScreen';
import getWatercraftQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getWatercraftQuote';
import updateWatercraftQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateWatercraftQuoteRecordData';
import saveWatercraftQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.saveWatercraftQuoteRecordData';
import insertNewQuotes from '@salesforce/apex/Mex_NewLeadProcess.insertNewQuotes';
import sendEmailQuoteDetails from '@salesforce/apex/Mex_NewLeadProcess.sendEmailQuoteDetails';
import updateQuoteData from '@salesforce/apex/Mex_PolicyEditController.updateQuoteData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { NavigationMixin } from 'lightning/navigation';
import Prev from '@salesforce/label/c.TR_Prev';
import Save from '@salesforce/label/c.TR_Save';
import SelectQuoteAndDownload from '@salesforce/label/c.TR_Select_Quote_And_Download';
import DownloadPDF from '@salesforce/label/c.TR_Download_PDF';
import EmailPDF from '@salesforce/label/c.TR_Email_PDF';
import Cancel from '@salesforce/label/c.TR_Cancel';
import Fullterms from '@salesforce/label/c.TR_Full_Terms';
import LaborRates from '@salesforce/label/c.TR_Labor_Rates';
import PlaneTicketsHome from '@salesforce/label/c.TR_Plane_Tickets_Home';
import PartialTheft from '@salesforce/label/c.TR_Partial_Theft';
import Vandalism from '@salesforce/label/c.TR_Vandalism';
import LegalDefenseandBail from '@salesforce/label/c.TR_Legal_Defense_and_Bail';
import RentalCar from '@salesforce/label/c.TR_Rental_Car';
import Roadsideassistance from '@salesforce/label/c.TR_Roadside_assistance';
import GlassBreakage from '@salesforce/label/c.TR_Glass_Breakage';
import CollisionDeductible from '@salesforce/label/c.TR_Collision_Deductible';
import Deductibles from '@salesforce/label/c.TR_Deductibles';
import LiabilityOnly from '@salesforce/label/c.TR_Liability_Only';
import ThirdPartyPropertyDamage from '@salesforce/label/c.TR_Third_Party_Property_Damage';
import NA from '@salesforce/label/c.TR_N_A';
import ThirdPartyBodilyInjury from '@salesforce/label/c.TR_Third_Party_Bodily_Injury';
import TotalThirdPartyLiability from '@salesforce/label/c.TR_Total_Third_Party_Liability';
import Days from '@salesforce/label/c.TR_Days';
import Watercraft from '@salesforce/label/c.TR_Watercraft';
import Compare from '@salesforce/label/c.TR_Compare';
import QuoteDetail from '@salesforce/label/c.TR_Quote_Detail';
import Getyourquickquote from '@salesforce/label/c.TR_Get_your_quick_quote';
import Purchase from '@salesforce/label/c.TR_Purchase';
import Chubb from '@salesforce/label/c.TR_Chubb';
import Thecombinationofmax from '@salesforce/label/c.TR_The_combination_of_max_limits_below_Liability_is_required_by_the_dockmasters';
import Theamountofliabilitycoverage from '@salesforce/label/c.TR_The_amount_of_liability_coverage_to_third_party_person_Think_medical_damages';
import Theamountofdamageto from '@salesforce/label/c.TR_The_amount_of_damage_to_third_party_property_ie_a_dock_another_boat_etc';
import SaveQuote from '@salesforce/label/c.TR_Save_quote';
import EmailhasbeenSent from '@salesforce/label/c.TR_Email_has_been_Sent';



export default class WatercraftQuickQuoteDetails extends NavigationMixin(LightningElement) {
     label = {
           Prev,Save,SelectQuoteAndDownload,DownloadPDF,Purchase,Chubb,EmailPDF,EmailhasbeenSent,Cancel,Fullterms,LaborRates,PlaneTicketsHome,PartialTheft,Vandalism,LegalDefenseandBail,
           RentalCar,Roadsideassistance,GlassBreakage,CollisionDeductible,Deductibles,LiabilityOnly,ThirdPartyPropertyDamage,NA,ThirdPartyBodilyInjury,SaveQuote,
           TotalThirdPartyLiability,Days,Watercraft,Compare,QuoteDetail,Getyourquickquote,Thecombinationofmax,Theamountofliabilitycoverage,Theamountofdamageto,
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api handleInsertData;
    @api policyType;
    @api isRenewalPolicy;
    @api editpolicydata;
    @api isEditPolicy;



    @api customerRecord;
    @api communityUser;


    chubb = images + '/mexJs/images/chubb.png';
    isHighlight = false;
    coverageMap = {};
    quoteDetails;
    quickQuoteDetail;
    saveQuoteData;
    pdfQuote;
    isSaveQuote = false;

    totalThirdPartyLiability = '200,000';
    thirdPartyBodilyInjuriy = '$50,000 / $100,000';
    valuePropertyDamageLiability = '$100,000';



    async connectedCallback() {
        console.log('--communityUser--', this.communityUser);
        console.log('--quick quote customerRecord--', this.customerRecord);
        console.log('--isEditPolicy--', this.isEditPolicy);
        if (!this.communityUser && !this.isRenewalPolicy) {
            await this.initializeData();
        } else if (!this.communityUser && this.isRenewalPolicy == 'Yes') {
            console.log('------concectedcallBAck------', this.editpolicydata);
            this.renewalinitializeData();
        } else if (this.communityUser) {
            this.existingUserInitializeData();
        }
        await this.fetchCoverageQuote();

        // this.isRenewalPolicy = false;
    }



    get setEndTime() {
        return this.quoteDetails != undefined ? (this.quoteDetails.Start_Time__c != undefined ? this.msToTime(this.quoteDetails.Start_Time__c) : '') : '';

    }
    get setStartTime() {
        return this.quoteDetails != undefined ? (this.quoteDetails.Start_Time__c != undefined ? this.msToTime(this.quoteDetails.Start_Time__c) : '') : '';

    }
    get coverageDecuctible() {
        return this.coverageMap?.Chubb?.Deductibles__c == 'Yes'
    }
    get uninsuredMotoristDeductibleWaiver() {
        return this.coverageMap?.Chubb?.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }
    get GlassBreakage() {
        return this.coverageMap?.Chubb?.Glass_Breakage__c == 'Yes' ? true : false;
    }
    get roadsideAssistance() {
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

    get showTimeField(){
        return (this.quickQuoteDetail.rateRecord.Term__c != 'Daily');
    }


    initializeData = async () => {

        let someId = this.leaddata?.Id ? this.leaddata?.Id : '';
        let userType = this.leaddata?.Id ? 'newLead' : 'existingUser';


        const resp = await getDateForQuoteScreen({ someId, userType });
        let parsedData = JSON.parse(resp).data;
        console.log('====', parsedData);
        let vehicleData = JSON.parse(parsedData?.Watercraft_Detail__c);
        let termData = JSON.parse(parsedData?.Term_options__c);
        this.quoteDetails = {
            ...vehicleData,
            ...termData,
        }
        console.log('----this.quoteDetails 00--', this.quoteDetails);

        await this.fetchQuoteData(this.quoteDetails);
    }

    renewalinitializeData = async () => {
        this.quoteDetails = {
            ...this.editpolicydata.quoteData,
            ...this.editpolicydata.watercraftData
        }
        console.log('---- renewalinitializeData quoteDetails--', this.quoteDetails);
        await this.fetchQuoteData(this.quoteDetails);
    }

    existingUserInitializeData = async () => {
        this.quoteDetails = {
            ...this.customerRecord.quoteRecord,
            ...this.customerRecord.watercraftData
        }
        console.log('---- existingUserInitializeData quoteDetails--', this.quoteDetails);

        await this.fetchQuoteData(this.quoteDetails);
    }


    async fetchQuoteData(quoteDetails) {
        let isValid = this.isInputValid();
        console.log('--isValid--', isValid);
        console.log('quoteId---', this.leaddata?.quoteId);
        if (isValid) {
            let qt;
            if (!this.isRenewalPolicy) {
                qt = {
                    Policy_Type_picklist: "Watercraft",
                    Vehicle_Type__c: "Watercraft",
                    Type_of_Vessel__c: quoteDetails.Type_of_Vessel__c,
                    Vessel_Length__c: quoteDetails.Vessel_Length__c,
                    Start_Date_for_Coverage: quoteDetails.Start_Date_for_Coverage__c,
                    End_Date_for_Coverage: quoteDetails.End_Date_for_Coverage__c,
                    Is_the_Maximum_Speed_more_than_50_mph__c: quoteDetails.Is_the_Maximum_Speed_more_than_50_mph__c,
                    Any_Boat_Operator_Under_22__c: quoteDetails.Any_Boat_Operator_Under_22__c,
                    Is_the_owner_living_in_Mexico__c: quoteDetails.Is_the_owner_living_in_Mexico__c,
                    Liability__c: this.totalThirdPartyLiability,
                    Third_Party_Bodily_Injury__c: this.thirdPartyBodilyInjuriy,
                    Property_Damage_Liability__c: this.valuePropertyDamageLiability,
                    Towed_Unit__c: 'No',

                    // Liability__c:quoteDetails.Liability__c
                };
            } else {

                let medicalSplit = this.editpolicydata.quoteData.Medical__c?.split('/');
                qt = {
                    Policy_Type_picklist: "Watercraft",
                    Vehicle_Type__c: "Watercraft",
                    Type_of_Vessel__c: quoteDetails.Type_of_Vessel__c,
                    Vessel_Length__c: quoteDetails.Vessel_Length__c,
                    Start_Date_for_Coverage: quoteDetails.Start_Date_for_Coverage__c,
                    End_Date_for_Coverage: quoteDetails.End_Date_for_Coverage__c,
                    Is_the_Maximum_Speed_more_than_50_mph__c: quoteDetails.Is_the_Maximum_Speed_more_than_50_mph__c,
                    Any_Boat_Operator_Under_22__c: quoteDetails.Any_Boat_Operator_Under_22__c,
                    Is_the_owner_living_in_Mexico__c: quoteDetails.Is_the_owner_living_in_Mexico__c,
                    Liability__c: this.totalThirdPartyLiability,
                    Third_Party_Bodily_Injury__c: this.thirdPartyBodilyInjuriy,
                    Property_Damage_Liability__c: this.valuePropertyDamageLiability,
                    Towed_Unit__c: 'No',
                };
            }

            const res = await getWatercraftQuote({
                'requestBody': JSON.stringify(qt),
                'annualTerm': quoteDetails.Term__c != "Annual(One Year)" ? false : true,
            });

            console.log('Res ::::::  ', res);
            console.log('Res Parsed :::: ', JSON.parse(res));
            this.quickQuoteDetail = JSON.parse(res);
            // if (!this.quickQuoteDetail.qualitasQuote.showQualitas && !this.quickQuoteDetail.mapfreQuote.showMapfre && !this.quickQuoteDetail.chubbQuote.showChubb) {
            //     const evt = new ShowToastEvent({
            //         message: 'No Quote exist for the provided vehicle value!!',
            //         variant: 'error'
            //     });
            //     this.dispatchEvent(evt);
            // } 
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


    CompareHandle() {
        this.isHighlight = !this.isHighlight;
    }
    fetchCoverageQuote = async () => {
        let mainCoverageMap = await getCoverageDetailForSouthbound({ 'pickList': 'watercraft' });
        console.log('---data- covergae--', mainCoverageMap);
        mainCoverageMap.Chubb.map((data) => {
            this.coverageMap = { ...this.coverageMap, ['Chubb']: data };
        });
        console.log('---coverageMap-', this.coverageMap);
    }

    saveQuoteDetailData = async () => {
        console.log('saving wuote data');
        this.saveQuoteData = {
            Start_Date_for_Coverage__c: this.quoteDetails.Start_Date_for_Coverage__c,
            End_Time__c: this.quoteDetails.End_Time__c,
            End_Date_for_Coverage__c: this.quoteDetails.End_Date_for_Coverage__c,
            Any_Boat_Operator_Under_22__c: this.quoteDetails.Any_Boat_Operator_Under_22__c,
            Is_the_Maximum_Speed_more_than_50_mph__c: this.quoteDetails.Is_the_Maximum_Speed_more_than_50_mph__c,
            Is_the_owner_living_in_Mexico__c: this.quoteDetails.Is_the_owner_living_in_Mexico__c,

            // Engine_Type__c:this.quoteDetails.Engine_Type__c,

            Liability__c: this.totalThirdPartyLiability || "200,000",
            Vehicle_Make__c: this.quoteDetails.Make__c,
            Vehicle_Model__c: this.quoteDetails.Model__c,
            // Salvage_Vehicle__c: this.quoteDetails.Salvage_Vehicle__c == true ? 'Yes' : 'No',
            Start_Time__c: this.quoteDetails.Start_Time__c,
            Vehicle_Value__c: this.quoteDetails.Value__c,
            Vehicle_Type__c: 'Watercraft',
            Vehicle_sub_type__c: 'Watercraft',
            Vehicle_Year__c: this.quoteDetails.Year__c,
            Term__c: this.quickQuoteDetail.rateRecord.Term__c,
            Type_of_Vessel__c: this.quoteDetails.Type_of_Vessel__c,
            Vessel_Length__c: this.quoteDetails.Vessel_Length__c,
            Third_Party_Bodily_Injury__c: this.thirdPartyBodilyInjuriy,
            Property_Damage_Liability__c: this.valuePropertyDamageLiability,


            Policy_Type_picklist__c: 'Watercraft',
            Net_Premium__c: this.quickQuoteDetail.rateRecord.Net_Premium__c,
            Broker_Policy_Fee__c: this.quickQuoteDetail.rateRecord.Broker_Policy_Fee__c != undefined ? this.quickQuoteDetail.rateRecord.Broker_Policy_Fee__c : 0,
            Term_Days__c: this.quickQuoteDetail.rateRecord.Day__c != undefined ? this.quickQuoteDetail.rateRecord.Day__c : 0,
            I_V_A_Mex_Tax__c: this.quickQuoteDetail.rateRecord.I_V_A_Mex_Tax__c != undefined ? this.quickQuoteDetail.rateRecord.I_V_A_Mex_Tax__c : 0,
            Quote_Value__c: this.quickQuoteDetail.rateRecord.Quote_Value__c != undefined ? this.quickQuoteDetail.rateRecord.Quote_Value__c : 0,
            Surcharge__c: this.quickQuoteDetail.rateRecord.Surcharge__c != undefined ? this.quickQuoteDetail.rateRecord.Surcharge__c : 0,
            Underwriter__c: 'Chubb',
            // Medical__c: this.quoteDetails.Medical || "10,000/50,000",
            Coverage__c: 'Liability',
            Towed_Unit__c: 'No',
        };

        console.log('Saved quote data--->',this.saveQuoteData);


        if (this.leaddata?.quoteId) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Id']: this.leaddata.quoteId };
        } else if (this.customerRecord?.quoteRecord?.Id) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Id']: this.customerRecord?.quoteRecord?.Id }
        }
    }

    handleNextClick = async () => {

        let isValid = this.isInputValid();
        console.log('--isValid--', isValid);
        this.saveQuoteDetailData();

        if (typeof this.saveQuoteData.Start_Time__c === 'string' && this.saveQuoteData.Start_Time__c.includes(':')) {
            this.saveQuoteData = { ...this.saveQuoteData, ['Start_Time__c']:  this.saveQuoteData.Start_Time__c + 'Z'};
        }

        if (typeof this.saveQuoteData.End_Time__c === 'string' && this.saveQuoteData.End_Time__c.includes(':')) {
            this.saveQuoteData = { ...this.saveQuoteData, ['End_Time__c']: this.saveQuoteData.End_Time__c + 'Z'};
        }
        
        console.log('OUTPUT saveQuoteData : ', this.saveQuoteData);


        if (isValid) {
            if (this.isRenewalPolicy == 'Yes') {

                this.editpolicydata = {
                    ...this.editpolicydata, ['quoteData']: {
                        ...this.editpolicydata.quoteData,
                        ['Net_Premium__c']: this.saveQuoteData.Net_Premium__c,
                        ['Broker_Policy_Fee__c']: this.saveQuoteData.Broker_Policy_Fee__c,
                        ['I_V_A_Mex_Tax__c']: this.saveQuoteData.I_V_A_Mex_Tax__c,
                        ['Quote_Value__c']: this.saveQuoteData.Quote_Value__c,
                        ['Surcharge__c']: this.saveQuoteData.Surcharge__c,
                        ['Liability__c']: this.saveQuoteData.Liability__c,
                        ['Third_Party_Bodily_Injury__c']: this.saveQuoteData.Third_Party_Bodily_Injury__c,
                        ['Property_Damage_Liability__c']: this.saveQuoteData.Property_Damage_Liability__c,
                        ['Underwriter__c']: 'Chubb',
                    }
                }
                let updateCloneQuote = await updateQuoteData({ 'quote': JSON.stringify(this.editpolicydata.quoteData) });
                console.log('--updateCloneQuote--', updateCloneQuote);
                console.log('Policy details in screen change-->',JSON.stringify(this.editpolicydata));
                if (updateCloneQuote.status == 'success') {
                    console.log('in if section of event dispatch');
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
                    //         'insurance_category': this.editpolicydata.Policy_Type__c
                    //         });
                    // }
                    
                    this.dispatchEvent(editPolicyChange);
                    this.changesnextscreen();
                }
            } else {
                if (this.communityUser != null && this.communityUser) {
                    if (typeof this.customerRecord.quoteRecord.Start_Time__c === 'string' && this.customerRecord.quoteRecord.Start_Time__c.includes(':')) {
                        this.customerRecord = {
                            ...this.customerRecord, ['quoteRecord']: {
                                ...this.customerRecord.quoteRecord,
                                ['Start_Time__c']: this.customerRecord.quoteRecord.Start_Time__c + 'Z',
                                ['End_Time__c']: this.customerRecord.quoteRecord.End_Time__c + 'Z',
                            }
                        }
                    }
                    console.log('Customer record--->',this.customerRecord);
                    console.log('Saved quote data--->',this.saveQuoteData);
                    let quoteResponse;
                    if (this.customerRecord != null && this.customerRecord?.quoteRecord?.Id != null && this.customerRecord?.watercraftData?.Id) {
                        quoteResponse = await updateWatercraftQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.saveQuoteData }), "watercraftRecord": JSON.stringify(this.customerRecord?.watercraftData), "driversRecord": '' });
                    } else {
                        quoteResponse = await saveWatercraftQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.saveQuoteData }), "watercraftRecord": JSON.stringify(this.customerRecord?.watercraftData), });
                    }

                    console.log('---quoteResponse--', JSON.stringify(quoteResponse, null, 4));
                    if (quoteResponse.status == 'success') {
                        this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...quoteResponse.quoteData }, ['watercraftData']: { ...this.customerRecord?.watercraftData, ...quoteResponse.watercraftData } };

                        if (quoteResponse?.towedUnitData?.length) {
                            this.customerRecord = { ...this.customerRecord, ['towedUnitData']: [...quoteResponse.towedUnitData] };
                        }

                        const customerRecordChange = new CustomEvent('customerecordchange', {
                            detail: this.customerRecord,
                        });

                        let eventExist = window.dataLayer.find((data) => data.step_number === 'step_7');
                        if (eventExist == undefined){
                            window.dataLayer.push({
                                'event': 'funnel_step',
                                'step_number': 'step_7',
                                'step_name': 'plan_selection', 
                                'underwriter_selected': quoteResponse?.quoteData?.Underwriter__c,
                                'insurance_category': quoteResponse?.Policy_Type__c
                                });
                        }
                        
                        this.dispatchEvent(customerRecordChange);
                        this.changesnextscreen();
                    }else{
                        this.generateLogs();
                    }
                } else {
                    console.log('data-> ');
                    console.log(this.saveQuoteData);
                    console.log(this.leaddata);
                    console.log(this.customerRecord);
                    let quote = await insertNewQuotes({ "quotes": JSON.stringify(this.saveQuoteData), "leadId": this.leaddata?.Id });

                    console.log('quote--', quote);
                    if (quote.status == 'success') {
                        this.leaddata = { ...this.leaddata, ['quoteId']: quote.data.Id };

                        console.log('quote---', quote);
                        console.log('quote--', this.leaddata);
                        const leadChange = new CustomEvent('leadvaluechange', {
                            detail: this.leaddata,
                        });

                        let eventExist = window.dataLayer.find((data) => data.step_number === 'step_7');
                        if (eventExist == undefined){
                            window.dataLayer.push({
                                'event': 'funnel_step',
                                'step_number': 'step_7',
                                'step_name': 'plan_selection', 
                                'underwriter_selected': this.leaddata?.Underwriter__c,
                                'insurance_category': this.leaddata?.Policy_Type__c
                                });
                        }
                        this.dispatchEvent(leadChange);
                        this.changesnextscreen();
                    }else{
                        this.generateLogs();
                    }
                    console.log('before change screen');
                }

            }

        }


        const leadChange = new CustomEvent('leadvaluechange', {
            detail: this.leaddata,
        });
        // this.handleInsertData();
        this.dispatchEvent(leadChange);
        // this.changesnextscreen();
        console.log('Quick Quote Details Lead data ---> ', this.leaddata);
    }
    SaveQuoteHandle = async () => {
        this.isSaveQuote = true;
    }
    cancleEdit() {
        this.isSaveQuote = !this.isSaveQuote;
    }

    savedQuoteDetail = async () => {
        this.saveQuoteDetailData();
        let chubbQuote = {
            ['Policy_Fee']: this.quickQuoteDetail.rateRecord.Broker_Policy_Fee__c != undefined ? this.quickQuoteDetail.rateRecord.Broker_Policy_Fee__c : 0,
            ['days']: this.quickQuoteDetail.rateRecord.Day__c,
            ['iva']: this.quickQuoteDetail.rateRecord.I_V_A_Mex_Tax__c,
            ['rateValue']: this.quickQuoteDetail.rateRecord.Quote_Value__c,
            ['showChubb']:true
        }


        let watercraftQuickQuoteDetail = { ['chubbQuote']: chubbQuote, ['Chubb']: true, ['Third_Party_Bodily_Injury'] : this.thirdPartyBodilyInjuriy, ['Property_Damage_Liability']: this.valuePropertyDamageLiability, ['ThirdPartyLiabiliy']:this.thirdPartyBodilyInjuriy};
        this.saveQuoteData = { ...this.saveQuoteData, ['QuotePdfJson__c']: JSON.stringify(watercraftQuickQuoteDetail) };
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

    downloadQuote = async () => {
        await this.savedQuoteDetail();
        this.isSaveQuote = false;
        console.log('/apex/selectedQuoteRate?Id=');
        console.log(JSON.stringify(this.pdfQuote));
        window.open(window.location.origin+`/s/quoterate?Id=${this.pdfQuote.data.Id}`, "_blank");
    }

    sendEmailQuoteDetail = async () => {
        await this.savedQuoteDetail();
        this.isSaveQuote = false;
        let sendEmailOfQuoteDetail = await sendEmailQuoteDetails({ 'quoteId': this.pdfQuote.data.Id });
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

    handlePrevClick() {
        this.changeprevscreen();
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
    async highLiability() {
        if (this.totalThirdPartyLiability == '200,000') {
            this.thirdPartyBodilyInjuriy = '$100,000 / $300,000';
            this.valuePropertyDamageLiability = '$100,000';
            this.totalThirdPartyLiability = '400,000'

        } else if (this.totalThirdPartyLiability == '400,000') {
            this.thirdPartyBodilyInjuriy = '$250,000 / $500,000';
            this.valuePropertyDamageLiability = '$250,000';
            this.totalThirdPartyLiability = '750,000'
        }

        await this.fetchQuoteData(this.quoteDetails);
    }
    async lowLiability() {
        console.log('this.totalThirdPartyLiability --', this.totalThirdPartyLiability );
        if (this.totalThirdPartyLiability == '750,000') {
            this.thirdPartyBodilyInjuriy = '$100,000 / $300,000';
            this.valuePropertyDamageLiability = '$100,000';
            this.totalThirdPartyLiability = '400,000'

        } else if (this.totalThirdPartyLiability == '400,000') {
            this.thirdPartyBodilyInjuriy = '$50,000 / $100,000';
            this.valuePropertyDamageLiability = '$100,000';
            this.totalThirdPartyLiability = '200,000'
        }
        await this.fetchQuoteData(this.quoteDetails);
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}