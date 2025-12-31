import { api, LightningElement,track } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import getPicklistValues from '@salesforce/apex/Mex_ValidateFormData.getPicklistValues';
import getDependentMap from '@salesforce/apex/Mex_ValidateFormData.getDependentMapWithTranslations';
import retrieveLegalTermDetails from '@salesforce/apex/Mex_QuickQuoteCommonController.retrieveLegalTermDetails';
import getQuoteRecord from '@salesforce/apex/Mex_QuickQuoteCommonController.getQuoteRecord';
import Onlineinsurancefinaldetails from '@salesforce/label/c.TR_Online_Insurance_Final_Details';
import WhatisyourTripDestination from '@salesforce/label/c.TR_What_is_your_trip_destination';
import Whatisthetrippurposetrip from '@salesforce/label/c.TR_What_is_the_purpose_of_trip';
import Howdidyouhearaboutus from '@salesforce/label/c.TR_How_did_you_hear_about_us';
import YesIwanttoreceivethefollowing from '@salesforce/label/c.TR_Yes_I_want_to_receive_the_following';
import Newsletter from '@salesforce/label/c.TR_Newsletter';
import Announcements from '@salesforce/label/c.TR_Announcements';
import TravelAlerts from '@salesforce/label/c.TR_Travel_Alerts';
import YellowCard from '@salesforce/label/c.TR_Yellow_Card';
import Ireadandagreewiththefollowing from '@salesforce/label/c.TR_I_read_and_agree_with_the_following';
import Termsofpurchase from '@salesforce/label/c.TR_Terms_of_purchase';
import Termsofcancellation from '@salesforce/label/c.TR_Terms_of_cancellation';
import Prev from '@salesforce/label/c.TR_Prev';
import Next from '@salesforce/label/c.TR_Next';
import clickinghere from '@salesforce/label/c.TR_clicking_here';
import Iagreetothefollowingwhen from '@salesforce/label/c.TR_I_agree_to_the_following_when_I_click_the_next_button_to_purchase_northboun';
import IhavereadunderstandandagreetotheTermsofAccessandUse from '@salesforce/label/c.TR_have_read_understand_and_agree_to_the_Terms_of_Access_and_Use_The_Mexico';
import Iunderstandandagreetotheinsurancepolicycontractofthe from '@salesforce/label/c.TR_I_understand_and_agree_to_the_insurance_policy_contract_of_the_Northbound';
import Iunderstandandagreethatcoverageappliesonlytothe from '@salesforce/label/c.TR_I_understand_and_agree_that_coverage_applies_only_to_the_vehicles_and_towed_u';
import IunderstandandagreethatIwillonlybeinsuredbetweenthe from '@salesforce/label/c.TR_I_understand_and_agree_that_I_will_only_be_insured_between_the_beginning_and';
import IunderstandandagreethatthelawsofMexicodonot from '@salesforce/label/c.TR_I_understand_and_agree_that_the_laws_of_Mexico_do_not_authorize_certain_types';
import IunderstandandagreethatthistouristNorthboundInsurance from '@salesforce/label/c.TR_I_understand_and_agree_that_this_tourist_Northbound_Insurance_only_provides';
import IunderstandandagreethatImustprintthe from '@salesforce/label/c.TR_I_understand_and_agree_that_I_must_print_the_insurance_policy_declaration_pag';
import Iunderstandandagreethatthepolicydeclarationspage from '@salesforce/label/c.TR_I_understand_and_agree_that_the_policy_declarations_page_will_be_available_to';
import IunderstandandagreethatthepolicyNorthboundTermsandConditions from '@salesforce/label/c.TR_I_understand_and_agree_that_the_policy_Northbound_Terms_and_Conditions_can';
import IunderstandandagreethatImustreport from '@salesforce/label/c.TR_I_understand_and_agree_that_I_must_report_all_claims_to_the_insurance_company';
import Iunderstandandagreethatfailuretoreport from '@salesforce/label/c.TR_I_understand_and_agree_that_failure_to_report_the_claim_while_in_Mexico_could';
import Iunderstandandagreethatthistourist from '@salesforce/label/c.TR_I_understand_and_agree_that_this_tourist_Northbound_auto_insurance_policy_d';
import ThefollowingareTermsofCancellation from '@salesforce/label/c.TR_The_following_are_Terms_of_Cancellation_a_legal_agreement_Agreement';
import WhentheContractingPartyrequests from '@salesforce/label/c.TR_When_the_Contracting_Party_requests_the_early_termination_of_this';
import DailyPolicyCancellation from '@salesforce/label/c.TR_Daily_Policy_Cancellation';
import Dailytermpoliciesarefully from '@salesforce/label/c.TR_Daily_term_policies_are_fully_earned_as_soon_as_coverage_begins';
import SemiAnnualandAnnualPolicyCancellation from '@salesforce/label/c.TR_Semi_Annual_and_Annual_Policy_Cancellation';
import SemiannualandAnnualpoliciesar from '@salesforce/label/c.TR_Semi_annual_and_Annual_policies_are_fully_earned_after_22_days';
import Allcancellationswillbeassesseda from '@salesforce/label/c.TR_All_cancellations_will_be_assessed_a_nominal_cancellation_fee';
import Iunderstand from '@salesforce/label/c.TR_I_understand_and_agree_that_this_northbound_auto_insurance_policy_is_issued_b';


export default class Nc_finalDetails extends LightningElement {
    label = {
        Onlineinsurancefinaldetails, WhatisyourTripDestination, Iunderstand, Allcancellationswillbeassesseda, SemiannualandAnnualpoliciesar, SemiAnnualandAnnualPolicyCancellation, Dailytermpoliciesarefully, DailyPolicyCancellation, WhentheContractingPartyrequests, ThefollowingareTermsofCancellation, Iunderstandandagreethatthistourist, Iunderstandandagreethatfailuretoreport, IunderstandandagreethatImustreport, IunderstandandagreethatthepolicyNorthboundTermsandConditions, Iunderstandandagreethatthepolicydeclarationspage, IunderstandandagreethatImustprintthe, IunderstandandagreethatthistouristNorthboundInsurance, IunderstandandagreethatthelawsofMexicodonot, IunderstandandagreethatIwillonlybeinsuredbetweenthe, Iunderstandandagreethatcoverageappliesonlytothe, Iunderstandandagreetotheinsurancepolicycontractofthe, clickinghere, IhavereadunderstandandagreetotheTermsofAccessandUse, Iagreetothefollowingwhen, Prev, Next, Whatisthetrippurposetrip, Termsofpurchase, Termsofcancellation, Ireadandagreewiththefollowing, Howdidyouhearaboutus, YellowCard, YesIwanttoreceivethefollowing, Newsletter, Announcements, TravelAlerts,
    };
    @api payload;
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api handleInsertData;
    @api policyType;
    @api communityUser;
    @api customerRecord;
    yellowCard = false;
    termsAndAgreement = {};
    usDestinations;
    aboutusOption;
    tripPurposes;
    showOtherOptioForHearus = false;
    legalTermRecord;
    dataMap = {};    // accessible across the component where payload is converted


    async connectedCallback() {
        console.log('---call concetedcallback---');
        // Intialize the datamap to user all over the class without looping in the payload
        this.initializeDataMap();

        this.fetchData();
        this.getDependentPicklistValues('Policy__c', 'Policy_Type_picklist__c', 'What_is_your_trip_destination_in_US__c');
        if (this.policyType == "RV") {
            this.tripPurposes = [{ label: 'Vacation', value: 'Vacation' }, { label: 'Pleasure', value: 'Pleasure' }];
        } else {
            this.tripPurposes = [{ label: 'Business', value: 'Business' }, { label: 'Pleasure', value: 'Pleasure' }];
        }

        this.fetchPicklist('contact', 'How_did_you_hear_about_us__c', 'aboutusOption');
        if (this.payload != undefined && !this.communityUser) {
            this.policyType = this.dataMap?.vehicleDetails?.Vehicle_sub_type__c;
        } else {
            if (this.customerRecord != null) {
                console.log('---this.customerRecord?.policyType--', this.customerRecord);
                this.policyType = this.customerRecord?.policyType;
            }
        }
    }

    initializeDataMap() {
        console.log('FD OUTPUT payload: ',this.payload);
        this.dataMap = this.convertPayloadToDataMap(this.payload);
        console.log('🚀 Converted Data Map:', this.dataMap);
    }

    convertPayloadToDataMap(payload) {
        const map = {};
        if (Array.isArray(payload)) {
            payload.forEach(entry => {
                const [key, value] = Object.entries(entry)[0];
                map[key] = value;
            });
        }
        return map;
    }


    get isWatercraft() {
        return this.policyType == 'Watercraft';
    }

    get isSouthboudVehicle() {

        return this.policyType == 'RV' || this.policyType == 'Automobile' || this.policyType == 'Motorcycle/Street Legal ATV';
    }

    get isNorthboundVehicle() {
        return this.policyType == 'Northbound';
    }

    get tripDestination() {
        return this.termsAndAgreement.What_is_your_trip_destination_in_US__c != undefined ? this.termsAndAgreement.What_is_your_trip_destination_in_US__c : '';
    }
    get tripPurpose() {
        return this.termsAndAgreement.What_is_the_purpose_of_trip__c != undefined ? this.termsAndAgreement.What_is_the_purpose_of_trip__c : '';
    }
    get hearAboutUs() {
        return this.termsAndAgreement.How_did_you_hear_about_us__c != undefined ? this.termsAndAgreement.How_did_you_hear_about_us__c : '';
    }
    get hearAboutUsOther() {
        return this.termsAndAgreement.How_did_you_hear_about_us_Other__c != undefined ? this.termsAndAgreement.How_did_you_hear_about_us_Other__c : '';
    }

    // get Newsletter() {

    //     return this.termsAndAgreement.Newsletter__c != undefined ? (this.termsAndAgreement.Newsletter__c == 'Yes' ? true : false) : false;
    // }

    get Newsletter() {
        console.log('GET SETTTER');
        console.log(this.termsAndAgreement);
        console.log(this.customerRecord);

        if (this.communityUser != null && this.communityUser) {
            if (this.customerRecord.termAgreement?.Newsletter__c == 'Yes') {
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Newsletter__c']: 'Yes' };
                return true;
            } else if (this.customerRecord.termAgreement?.Newsletter__c == 'No') {
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Newsletter__c']: 'No' };
                return false;
            } else {
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Newsletter__c']: 'Yes' };
                return true;
            }
        } else {
            if (this.termsAndAgreement.Newsletter__c == undefined) {
                console.log('INSIDE UNDEFINED');
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Newsletter__c']: 'Yes' };
                return true;
            } else {
                return this.termsAndAgreement.Newsletter__c == 'Yes' ? true : false
            }
        }

    }

    get Announcements() {
        return this.termsAndAgreement.Announcements__c != undefined ? (this.termsAndAgreement.Announcements__c == 'Yes' ? true : false) : false;
    }
    // get TravelAlerts() {
    //     return this.termsAndAgreement.Travel_Alerts__c != undefined ? (this.termsAndAgreement.Travel_Alerts__c == 'Yes' ? true : false) : false;
    // }

    get TravelAlerts() {
        console.log('GET SETTTER');
        console.log(this.termsAndAgreement);
        console.log(this.customerRecord);

        if (this.communityUser != null && this.communityUser) {
            if (this.customerRecord.termAgreement?.Travel_Alerts__c == 'Yes') {
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Travel_Alerts__c']: 'Yes' };
                return true;
            } else if (this.customerRecord.termAgreement?.Travel_Alerts__c == 'No') {
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Travel_Alerts__c']: 'No' };
                return false;
            } else {
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Travel_Alerts__c']: 'Yes' };
                return true;
            }
        } else {
            if (this.termsAndAgreement.Travel_Alerts__c == undefined) {
                console.log('INSIDE UNDEFINED');
                this.termsAndAgreement = { ...this.termsAndAgreement, ['Travel_Alerts__c']: 'Yes' };
                return true;
            } else {
                return this.termsAndAgreement.Travel_Alerts__c == 'Yes' ? true : false
            }
        }
    }

    get TermsOfPurchaseConfirmed() {
        return this.termsAndAgreement.Terms_of_Purchase_Confirmed__c != undefined ? (this.termsAndAgreement.Terms_of_Purchase_Confirmed__c) : false;
    }
    get TermsOfPurchaseCancellation() {
        return this.termsAndAgreement.Terms_of_Cancellation_Confirmed__c != undefined ? (this.termsAndAgreement.Terms_of_Cancellation_Confirmed__c) : false;
    }
    get isShowingOrgDataPurchaseAndUse() {
        return (this.policyType == 'Automobile-Van-Minivan' || this.policyType == 'Pickup' || this.policyType == 'SUV-Crossover' || this.policyType == 'ATV-UTV-Quads-Buggie' || this.policyType == 'Motorhome' || this.policyType == 'Motorcycle' || this.policyType == 'RV' || this.policyType == 'Automobile' || this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'Watercraft') && this.legalTermRecord;
    }
    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    @track userType;

    get currentUserType() {
        const existingIndex = this.payload.findIndex(item =>
            Object.keys(item)[0] === "UserType"
        );
        if (existingIndex != -1) {
            this.userType = "Customer";
            return true;
        }
        return false;
    }

    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        if (name == 'Terms_of_Purchase_Confirmed__c' || name == 'Terms_of_Cancellation_Confirmed__c') {
            value = event.target.checked;
            console.log("value checked in if condition test", value);
        }
        if (name == 'Travel_Alerts__c' || name == 'Announcements__c' || name == 'Newsletter__c' || name == 'Yellow_Card__c') {
            value = event.target.checked;
            value = value ? 'Yes' : 'No';
        }
        if (name == 'How_did_you_hear_about_us__c') {
            if (value == 'Other') {
                this.showOtherOptioForHearus = true;
            } else {
                this.showOtherOptioForHearus = false
            }
        }
        this.termsAndAgreement = { ...this.termsAndAgreement, [name]: value };
        if (this.communityUser != null && this.communityUser) {
            this.customerRecord = { ...this.customerRecord, ['termAgreement']: { ...this.termsAndAgreement } };
        } else {
            this.leaddata = { ...this.leaddata, ['termsAndAgreement']: this.termsAndAgreement };
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
        if (this.dataMap?.userDetails?.Id != undefined && !this.communityUser) {
            let quoteId;
            if (this.customerRecord !== null && this.communityUser) {
                quoteId = this.customerRecord?.quoteRecord.Id;
            } else {
                quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
            }
            try {
                const quoteRecord = await getQuoteRecord({ 'quoteId': quoteId });
                console.log('--fetch quoteRecord---', quoteRecord);

                const legalTerm = await retrieveLegalTermDetails({ 'policyType': this.dataMap?.vehicleDetails?.Vehicle_sub_type__c, 'underwriter': quoteRecord.Underwriter__c });
                console.log('---legalTerm----', legalTerm);
                this.legalTermRecord = legalTerm;
                const data = await fetchDataFromLead({ "LeadId": this.dataMap?.quotePage?.QuoteData?.Id, "screenName": "Terms_Alert__c" });
                console.log('--data--', data);
                if (data.status == 'success') {
                    if (data.data[0].Terms_Alert__c) {
                        let parseData = JSON.parse(data.data[0].Terms_Alert__c);
                        console.log(JSON.stringify(parseData, null, 4));
                        this.termsAndAgreement = parseData;
                    }

                } else {
                    this.generateLogs();
                }
            } catch (ex) {
                this.generateLogs();
                console.log('error : ', ex);
            }
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                console.log('--policyType--', this.customerRecord?.policyType);
                console.log('--quoteRecord--', this.customerRecord?.quoteRecord);
                const legalTerm = await retrieveLegalTermDetails({ 'policyType': this.customerRecord?.policyType, 'underwriter': this.customerRecord?.quoteRecord.Underwriter__c });
                console.log('---legalTerm----', legalTerm);
                this.legalTermRecord = legalTerm;
                this.termsAndAgreement = this.customerRecord?.termAgreement ? { ...this.customerRecord?.termAgreement } : {};
            }
        }
    }

    @api validate() {
        console.log('Valid method in jS of Final Details called');
        return this.isInputValid();
    }

    @api async getData() {
        console.log('Terms and agreement', this.termsAndAgreement);
        console.log('Reached in validateForm data');
        console.log('Term ans consition', this.termsAndAgreement);
        console.log('Strigify value', JSON.stringify({ ['Terms_Alert__c']: this.termsAndAgreement }));

        try {
            const data = await validateFormData({
                "objData": JSON.stringify({ ['Terms_Alert__c']: this.termsAndAgreement }),
                "objName": 'termsAndAgreement'
            });

            console.log('Data--', data);
            if (data.status == 'success') {
                if (this.currentUserType) {
                    console.log('Return data form contact');
                } else {
                    const res = await InsertLeadData({
                        'leadData': JSON.stringify({
                            ['Terms_Alert__c']: JSON.stringify(this.termsAndAgreement),
                            ['Id']: this.dataMap?.userDetails?.Id
                        })
                    });

                    if (res.status == 'Success') {
                        console.log('res----', res);
                    } else {
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    }
                }
            }
        } catch (error) {
            console.log('Error on calling the method validate form data', error);
        }

        return this.termsAndAgreement;
    }

    // handleNextClick = async () => {
    //     let allValid = this.isInputValid();
    //     if (allValid) {
    //         try {
    //             this.template.querySelector('.buttonNext').classList.add('loading');
    //             this.template.querySelector('.buttonNext').setAttribute('disabled', true);
    //             console.log(JSON.stringify(this.termsAndAgreement, null, 4));
    //             const data = await validateFormData({ "objData": JSON.stringify({ ['Terms_Alert__c']: this.termsAndAgreement }), "objName": 'termsAndAgreement' });

    //             if (data.status == 'success') {
    //                 if (this.communityUser != null && this.communityUser) {
    //                     const customerRecordChange = new CustomEvent('customerecordchange', {
    //                         detail: this.customerRecord,
    //                     });

    //                     this.dispatchEvent(customerRecordChange);
    //                 } else {
    //                     const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Terms_Alert__c']: JSON.stringify(this.termsAndAgreement), ['Id']: this.leaddata?.Id }) });
    //                     if (res.status == 'Success') {
    //                         let eventExist = window.dataLayer.find((data) => data.step_number === 'step_11');
    //                         if (eventExist == undefined) {
    //                             window.dataLayer.push({
    //                                 'event': 'funnel_step',
    //                                 'step_number': 'step_11',
    //                                 'step_name': 'poilicy_terms',
    //                                 'insurance_category': this.policyType
    //                             });
    //                         }
    //                         // let eventExist = window.dataLayer.find((data) => data.event === 'term_and_conditions_accept');
    //                         // if (eventExist == undefined) this.setDataLayer();
    //                         console.log('res----', res);
    //                     } else {
    //                         this.generateLogs();
    //                         this.template.querySelector('.buttonNext').classList.remove('loading');
    //                         this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
    //                         // error...
    //                     }
    //                 }

    //                 this.changesnextscreen();
    //             } else {
    //                 this.generateLogs();
    //                 this.template.querySelector('.buttonNext').classList.remove('loading');
    //                 this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
    //                 // error...
    //             }
    //         } catch (error) {
    //             console.log(error);
    //             this.generateLogs();
    //             this.template.querySelector('.buttonNext').classList.remove('loading');
    //             this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
    //             // handle errors if any...
    //         }
    //     }
    // }

    handlePrevClick() {
        if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
            const customerRecordChange = new CustomEvent('customerecordchange', {
                detail: this.customerRecord,
            });

            this.dispatchEvent(customerRecordChange);
        } else {
            const leadChange = new CustomEvent('leadvaluechange', {
                detail: this.leaddata,
            });

            this.dispatchEvent(leadChange);
        }
        this.changeprevscreen();
    }

    setDataLayer() {
        dataLayer.push({
            event: "term_and_conditions_accept",
        });

    }

    fetchPicklist(objectName, fieldApi, filledAtrr) {
        getPicklistValues({ "objectApiName": objectName, "fieldApiName": fieldApi }).then((result) => {
            console.log("this is fetchPicklistcall from apex result" + JSON.stringify(result));
            let storeResponse = result;
            if (filledAtrr == 'tripPurposes') {
                this.tripPurposes = storeResponse;
            } else if (filledAtrr == 'aboutusOption') {
                this.aboutusOption = storeResponse;
            }

        });
    }
    getDependentPicklistValues(objectName, controllingField, dependentField) {
        getDependentMap({ "objectApiName": objectName, "contrfieldApiName": controllingField, "depfieldApiName": dependentField }).then((result) => {
            console.log("this is getdepentedntfetchPicklistcall from apex result" + JSON.stringify(result));
            let storeResponse = result;
            console.log('policyType--', this.policyType);
            console.log('option--', storeResponse);
            if (this.policyType != null && this.policyType != undefined && storeResponse && storeResponse[this.policyType] != null) {

                var options = [];
                let relevantControllingField = storeResponse[this.policyType];
                for (const property in relevantControllingField) {
                    /**logic here !*/
                    options.push({
                        'label': relevantControllingField[property],
                        'value': property
                    })
                }
                this.usDestinations = options;
                console.log('---this is after filter--', this.usDestinations);
            }

        });
    }
    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}