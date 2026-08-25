import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import defaultTemplate from './affiliateQuickPolicy.html';
import enhancedTemplate from './enhanced.html';
import { loadStyle } from 'lightning/platformResourceLoader';
import image from '@salesforce/resourceUrl/mexJs';
import AGENT_STYLE from '@salesforce/resourceUrl/AgentStyle';
import getQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getQuote';
import getPicklistValuesFromApex from '@salesforce/apex/Mex_ValidateFormData.getPicklistValues';
import getDependentMapWithTranslations from '@salesforce/apex/Mex_ValidateFormData.getDependentMapWithTranslations';
import getYears from '@salesforce/apex/Mex_NewLeadProcess.getYears';
import getMakes from '@salesforce/apex/Mex_NewLeadProcess.getMakes';
import getModels from '@salesforce/apex/Mex_NewLeadProcess.getModels';
import purchaseSaveDetails from '@salesforce/apex/AgentAppController.purchaseSaveDetails';
import saveInfoBeforePayment from '@salesforce/apex/AgentAppController.saveInfoBeforePayment';
import fetchContactDetails from '@salesforce/apex/AgentAppController.fetchContactDetails';
import updateContactDetails from '@salesforce/apex/AgentAppController.updateContactDetails';
import mapAffiliateOnContact from '@salesforce/apex/AgentAppController.mapAffiliateOnContact';
import paymentThroughCard from '@salesforce/apex/AgentAppController.paymentThroughCard';
import createPolicy from '@salesforce/apex/AgentAppController.createPolicy';
import createPolicyFromContact from '@salesforce/apex/AgentAppController.createPolicyFromContact';
import fetchExistingLead from '@salesforce/apex/AgentAppController.fetchExistingLead';
import getExternalIp from '@salesforce/apex/AgentAppController.getExternalIp';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNorthboundQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundQuote';
import getNorthboundCoverage from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundCoverage';
import portalAccessForUser from '@salesforce/apex/AgentAppController.portalAccessForUser';
import getPolicyData from '@salesforce/apex/AfterPolicyCreated.getPolicyData';
import emailServices from '@salesforce/apex/AfterPolicyCreated.emailServices';
import saveLeadDestinationInfoBeforePayment from '@salesforce/apex/AgentAppController.saveLeadDestinationInfoBeforePayment';
import updateContactDestinationDetails from '@salesforce/apex/AgentAppController.updateContactDestinationDetails';
import ToastContainer from 'lightning/toastContainer';
import { CurrentPageReference } from 'lightning/navigation';
import getAffiliateUser from '@salesforce/apex/AffiliateController.getAffiliateUser';
import buhoAssets from '@salesforce/resourceUrl/BuhoAssets';
import popupModal from 'c/popupModal';
import AffiliatePolicyUtils from 'c/affiliatePolicyUtils';
import type__c from '@salesforce/schema/Transaction__ChangeEvent.type__c';
export default class AffiliateQuickPolicy extends AffiliatePolicyUtils {
    buhoAssets = buhoAssets;
    policyType = 'Automobile-Van-Minivan';
    falseValue = false;
    lastActiveSection;
    @api cmpSource;
    @api paramdata;
    @api isEnhanced = false;

    render() {
        return this.isEnhanced ? enhancedTemplate : defaultTemplate;
    }

    stepMap = {
        'getAQuote': 1,
        'vehicleDetails': 2,
        'termTerritory': 3,
        'quote': 4,
        'purchase': 5,
        'payment': 6,
        'policyQuickActions': 7
    };

    get currentStepIndex() {
        return this.stepMap[this.activeSectionName] || 1;
    }

    get step1Class() { return this.getStepClass(1); }
    get step2Class() { return this.getStepClass(2); }
    get step3Class() { return this.getStepClass(3); }
    get step4Class() { return this.getStepClass(4); }
    get step5Class() { return this.getStepClass(5); }
    get step6Class() { return this.getStepClass(6); }
    get step7Class() { return this.getStepClass(7); }

    get step1Style() { return this.getStepStyle(1); }
    get step2Style() { return this.getStepStyle(2); }
    get step3Style() { return this.getStepStyle(3); }
    get step4Style() { return this.getStepStyle(4); }
    get step5Style() { return this.getStepStyle(5); }
    get step6Style() { return this.getStepStyle(6); }
    get step7Style() { return this.getStepStyle(7); }

    get hideHeader() {
        const params = new URLSearchParams(window.location.search);
        return params.get('hideHeader') === 'true';
    }

    get hideSidebar() {
        const params = new URLSearchParams(window.location.search);
        return params.get('hideSidebar') === 'true';
    }

    get isStep1Completed() { return this.currentStepIndex > 1; }
    get isStep2Completed() { return this.currentStepIndex > 2; }
    get isStep3Completed() { return this.currentStepIndex > 3; }
    get isStep4Completed() { return this.currentStepIndex > 4; }
    get isStep5Completed() { return this.currentStepIndex > 5; }
    get isStep6Completed() { return this.currentStepIndex > 6; }

    getStepStyle(stepIndex) {
        if (stepIndex === this.currentStepIndex) {
            return 'display: block; transform: translateX(0); opacity: 1; visibility: visible; position: relative; top: 0; left: 0; right: auto; transition: all 0.5s ease;';
        }
        if (stepIndex < this.currentStepIndex) {
            return 'display: block; transform: translateX(-150%); opacity: 0; visibility: hidden; position: absolute; top: 40px; left: 40px; right: 40px; transition: all 0.5s ease;';
        }
        return 'display: block; transform: translateX(150%); opacity: 0; visibility: hidden; position: absolute; top: 40px; left: 40px; right: 40px; transition: all 0.5s ease;';
    }

    getStepClass(stepIndex) {
        if (stepIndex === this.currentStepIndex) return 'wizard-step active-step';
        if (stepIndex < this.currentStepIndex) return 'wizard-step slide-left';
        return 'wizard-step slide-right';
    }

    get dynamicStyle() {
        const primary = this.affiliateUserInfo?.Theme_Primary_Color__c || '#1E293B';
        const accent = this.affiliateUserInfo?.Theme_Accent_Color__c || '#475569';
        const light = this.affiliateUserInfo?.Theme_Light_Color__c || '#E2E8F0';
        return `--primary-blue: ${primary}; --buho-primary-blue: ${primary}; --accent-pink: ${accent}; --buho-accent-pink: ${accent}; --light-blue: ${light}; --buho-light-blue: ${light};`;
    }

    // Enhanced wizard step navigation helpers
    handleGoToVehicleDetails() { this.activeSectionName = 'vehicleDetails'; }
    handleGoToTermTerritory() { this.activeSectionName = 'termTerritory'; }
    handleGoToQuote() { this.handleGenerateQuote(); }
    handleGoToPurchase() { this.activeSectionName = 'purchase'; }
    handleGoToPayment() { this.activeSectionName = 'payment'; }
    handleGoToUserDetails() { this.activeSectionName = 'getAQuote'; }

    handleEnhancedInputChange(event) {
        const name = event.detail?.name || event.target?.name;
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const checked = event.detail?.checked !== undefined ? event.detail.checked : event.target?.checked;

        // Sync cmbx fields to the actual fields so LWC templates/getters update correctly
        if (name === 'Registered_Country__cmbx') {
            this.trackVar.Registered_Country__c = value;
            this.customerData.Registered_Country__c = value;
        }
        if (name === 'Company_Country__cmbx') {
            this.trackVar.Company_Country__c = value;
            this.trackVar.companyCountrycmbx = value;
            this.customerData.Company_Country__c = value;
        }
        if (name === 'Lienholder_Country__cmbx') {
            this.trackVar.Lienholder_Country__c = value;
            this.trackVar.lienHolderCountrycmbx = value;
            this.customerData.Lienholder_Country__c = value;
        }

        const mockedEvent = {
            target: {
                name: name,
                value: value,
                checked: checked
            }
        };
        // Call the inherited handleInputChange from AffiliatePolicyUtils
        this.handleInputChange(mockedEvent);
        this.booleanVar = { ...this.booleanVar };
    }

    handleEnhancedDriverFieldsChange(event) {
        const name = event.detail?.name || event.target?.name;
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const checked = event.detail?.checked !== undefined ? event.detail.checked : event.target?.checked;

        // Custom field updates for Driver using spread to ensure reactivity
        if (name === 'License_Country__cmbx') {
            this.newDriver = {
                ...this.newDriver,
                License_Country__cmbx: value,
                License_Country__c: value
            };
        }
        if (name === 'Country__cmbx') {
            this.newDriver = {
                ...this.newDriver,
                Country__cmbx: value,
                Country__c: value
            };
        }

        const mockedEvent = {
            target: {
                name: name,
                value: value,
                checked: checked
            }
        };
        this.handleDriverFieldsChange(mockedEvent);
        this.booleanVar = { ...this.booleanVar };
    }

    handleChangeDriverOption(event) {
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const mockedEvent = {
            target: {
                value: value
            }
        };
        this.changeDriverOption(mockedEvent);
    }

    handleChangeVehiclesOption(event) {
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const mockedEvent = {
            target: {
                value: value
            }
        };
        this.changeVehiclesOption(mockedEvent);
    }

    handleEnhancedTowedInputChange(event) {
        const name = event.detail?.name || event.target?.name;
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const mockedEvent = {
            target: {
                name: name,
                value: value
            }
        };
        this.handleTowedInputChange(mockedEvent);
    }

    handleEnhancedUpdateLibilityValue(event) {
        const name = event.detail?.name || event.target?.name;
        const checked = event.detail?.checked !== undefined ? event.detail.checked : event.target?.checked;
        const mockedEvent = {
            target: {
                name: name,
                checked: checked
            }
        };
        this.updateLibilityValue(mockedEvent);
    }

    handleEnhancedDateChange(event) {
        const name = event.detail?.name || event.target?.name;
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const mockedEvent = {
            target: {
                name: name,
                value: value
            }
        };
        this.handleDateChange(mockedEvent);
    }

    handleEnhancedFetchExistingLeadOnBlur(event) {
        const mockedEvent = {
            target: {
                value: this.trackVar.Email
            }
        };
        this.fetchExistingLeadOnBlur(mockedEvent);
    }

    handleEnhancedStartTimeValidation(event) {
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const mockedEvent = {
            target: {
                value: value
            }
        };
        return this.handleStartTimeValidation(mockedEvent);
    }

    handleEnhancedPaymentInputChange(event) {
        const name = event.detail?.name || event.target?.name;
        const value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;
        const checked = event.detail?.checked !== undefined ? event.detail.checked : event.target?.checked;

        if (name === 'paymentCountrycmbx') {
            this.trackVar.paymentCountrycmbx = value;
            this.trackVar.paymentCountry = value;
            this.paymentDetails['Country__c'] = value;
        }

        const mockedEvent = {
            target: {
                name: name,
                value: value,
                checked: checked
            }
        };
        this.handlePaymentInputChange(mockedEvent);
    }

    get territoryOptions() {
        return [
            {
                label: 'Baja / Sonora',
                value: 'Baja/Sonora',
                selected: this.booleanVar.isBaja === true,
                className: this.booleanVar.isBaja === true ? 'territory-card selected' : 'territory-card',
                imageUrl: `${buhoAssets}/images/baja_sonora.png`
            },
            {
                label: 'Baja, Sonora, Chihuahua, Coahuila, Nuevo León, Tamaulipas',
                value: 'Limited',
                selected: this.booleanVar.isLimited === true,
                className: this.booleanVar.isLimited === true ? 'territory-card selected' : 'territory-card',
                imageUrl: `${buhoAssets}/images/extended_territory.png`
            },
            {
                label: 'Entire Mexico',
                value: 'Full',
                selected: this.booleanVar.isTerritory === true,
                className: this.booleanVar.isTerritory === true ? 'territory-card selected' : 'territory-card',
                imageUrl: `${buhoAssets}/images/entire_mexico.png`
            }
        ];
    }

    handleTerritorySelect(event) {
        const value = event.currentTarget.dataset.territory;
        
        // Update booleanVar properties
        this.booleanVar.isBaja = (value === 'Baja/Sonora');
        this.booleanVar.isLimited = (value === 'Limited');
        this.booleanVar.isTerritory = (value === 'Full');

        // Mock event to call the inherited handler
        const mockedEvent = {
            target: {
                name: 'territory',
                value: value
            }
        };
        this.handleInputChange(mockedEvent);
    }

    @track formattedCreditCardNumber;
    @track OldAgentFee;
    @track OldQuote;
    existingLeadId;
    // Car Api
    vehicleTypeQuoteOptions;
    yearOption;
    makeOptions;
    modelOptions;

    // driver
    @track newDriver = {};
    @track addedDriver = [];

    quoteDetails;
    allQuoteDeatils;
    allQuote;
    leadId;
    quoteId;
    systemTime;
    displayPstTime;
    mindate;
    existVehicleDetails;
    existQuoteDetails;
    existLeadDetails;
    countDriver = 0;
    countOwner = 0;
    existDriverDetails = [];
    existTowedDetails = [];
    @track customerData = {};
    @track paymentDetails = {};
    activeSectionName = 'getAQuote';
    totalAmount;
    months = [];
    years = [];
    currentDate = new Date();
    startMonthNumber = 1;
    actionType;
    contactId;
    isCommunity = false;
    currDateTime;
    apextimedata;
    isAffiliate = true;

    affiliateCode;
    affiliateUserInfo;
    ownerName;
    ownerPhoto;
    agencyLogo;

    //Custom event
    title = '';
    message = '';

    // Northbound....
    liabilityOptions = ['100000', '200000', '300000'];
    showLiability = '300000';

    isShowModal = false;
    modalHeader = 'Default Header';
    modalBody = 'This is a test body';

    qualitasImg = image + '/mexJs/images/qualitas.png';
    chubbImg = image + '/mexJs/images/chubb.png';
    mapfreImg = image + '/mexJs/images/mapfre-logo.png';
    checkmark = image + '/mexJs/images/icon-checkmark.svg';
    cross = image + '/mexJs/images/icon-cross.svg';
    isDaysInTowInvalid = false;
    IsHighlightView = false;
    @track otherCountrylienholder = false;
    @track otherCountryCompany = false;
    @track otherCountryRegister = false;
    @track otherCountrypayment = false;
    @track otherCountryDriver = false;
    @track contactype;
    isContactCreated = false;
    hasRenderedCallbackCalled = false;

    @wire(getExternalIp) ip;

    @wire(getTimeZone)
    timezonedata({ data, error }) {
        if (data) {
            const newdata = JSON.parse(JSON.stringify(data));
            this.apextimedata = newdata;
            console.log('Time data is retrived in the wire', newdata);
        } else if (error) {
            console.log('Error in retrieving time data', error);
        }
    }

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.affiliateCode = currentPageReference.state.code;
            console.log('Affiliate code', this.affiliateCode);
            if (this.affiliateCode) {
                this.isAffiliate = true;
                this.fetchAffiliateUser();
            } else {
                this.isAffiliate = true; // *********** Changed defaul true
            }
        }
    }

    fetchAffiliateUser() {
        console.log(JSON.stringify(this.affiliateCode));
        getAffiliateUser({
            affiliateId: this.affiliateCode
        })
            .then((result) => {
                const data = JSON.parse(JSON.stringify(result));
                console.log('Getting data from apex');
                console.log(data);
                this.affiliateUserInfo = JSON.parse(data);
                this.ownerName = this.affiliateUserInfo?.Owner_Name__c;
                this.ownerPhoto = this.affiliateUserInfo?.Owner_Photo__c;
                this.agencyLogo = this.affiliateUserInfo?.Agency_Logo__c;
                this.agentFee = parseFloat(this.affiliateUserInfo?.Agent_Fee__c);
                console.log(this.ownerName);
                console.log(this.ownerPhoto);
                console.log(this.agentFee);
                console.log('Type of', typeof this.agentFee);
                console.log(this.agentFee);
                console.log(this.agencyLogo);
            })
            .catch((error) => {
                this.isAffiliate = false;
                console.log(error);
                this.showToastmethod(
                    'error',
                    'Unable to load affiliate information. Please refresh and try again.',
                    'Affiliate Load Error'
                );
            });
    }

    async handleAffiliateMapping() {
        if (this.actionType === 'newPolicyFromContact' && this.affiliateUserInfo?.Id) {
            try {
                await mapAffiliateOnContact({ contactId: this.contactId, affiliateId: this.affiliateUserInfo.Id });
            } catch (err) {
                console.log('Error mapping affiliate on contact', err);
            }
        }
    }

    // Getter Setter......

    @track
    vehicleStateOption = [];

    @track
    driverStateOption = [];

    get payeeName() {
        let payeename = `${this.trackVar.FirstName} ${this.trackVar.LastName}`.trim();

        this.paymentDetails['name'] = payeename;

        // Trigger change event when payeeName is computed

        this.triggerChangeEvent();

        return payeename;
    }

    triggerChangeEvent() {
        const inputElement = this.template.querySelector('[data-id="card-holder-name"]');

        if (inputElement) {
            inputElement.dispatchEvent(new Event('change'));
        }
    }

    get liablityType() {
        return this.quoteDetails?.Coverage__c != undefined &&
            this.quoteDetails?.Coverage__c == 'Liability'
            ? true
            : false;
    }
    get liabilityTheftCoverage() {
        return this.quoteDetails?.Coverage__c != undefined &&
            this.quoteDetails?.Coverage__c == 'LiabilityTheft'
            ? true
            : false;
    }
    get maxCoverage() {
        return this.quoteDetails?.Coverage__c != undefined &&
            this.quoteDetails?.Coverage__c == 'Max'
            ? true
            : false;
    }
    get fullAndCompleteCoverage() {
        return this.quoteDetails?.Coverage__c != undefined &&
            this.quoteDetails?.Coverage__c == 'Complete'
            ? true
            : false;
    }

    get options() {
        return [
            { label: 'Card Payment', value: 'Card' },
            { label: 'Cash Payment', value: 'Cash' }
        ];
    }

    get yesNoOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    get MM() {
        for (let i = this.startMonthNumber; i <= 12; i++) {
            let mon = i;
            if (i <= 9) {
                mon = '0' + i.toString();
            }
            mon = mon.toString();
            this.months.push({
                label: mon,
                value: mon
            });
        }
        return this.months;
    }

    get YYYY() {
        let currentYear = this.currentDate.getFullYear();
        let startFrom = currentYear;
        for (startFrom; startFrom < currentYear + 40; startFrom++) {
            this.years.push({
                label: startFrom.toString(),
                value: startFrom.toString()
            });
        }
        return this.years;
    }

    get maxDate() {
        const today = new Date();
        today.setFullYear(today.getFullYear());
        const year = today.getFullYear();
        const month = (today.getMonth() + 1).toString().padStart(2, '0');
        const day = today.getDate().toString().padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    get formattedCreditCardNumberOrg() {
        return this.formattedCreditCardNumber?.replace(/ /g, '');
    }

    renderedCallback() {
        if(!this.hasRenderedCallbackCalled) {
            console.log('Style loading', AGENT_STYLE);
            loadStyle(this, AGENT_STYLE).then(() => {
                console.log('File loaded');
            });
            console.log('calling rendered callback@@@');
            this.handleInputChange({target:{name:'Policy_Type__c'}});
            if(this.isEnhanced){
                loadStyle(this, buhoAssets + '/css/buhoStyles.css')
                    .then(() => console.log('buhoStyles.css loaded'))
                    .catch(error => console.error('Error loading buhoStyles.css', error));
            }
            this.hasRenderedCallbackCalled = true;
        }
        if (this.activeSectionName !== this.lastActiveSection) {
            this.lastActiveSection = this.activeSectionName;
            this.scrollToTop();
        }
    }

    scrollToTop() {
        try {
            const container = this.template.querySelector('.wizard-content-container');
            if (container) {
                container.scrollTop = 0;
            }
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } catch (e) {
            console.error('Error scrolling to top', e);
        }
    }

    async connectedCallback() {
        if (this.cmpSource === 'comm') {
            this.booleanVar.isportalAccessHide = false;
            this.isCommunity = true;
        } else {
            this.booleanVar.isportalAccessHide = true;
            this.isCommunity = false;
        }

        this.currDateTime = new Date().toLocaleTimeString();

        console.log('URL', window.location.origin);
        this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: false };
        this.newDriver = { ...this.newDriver, ['otherCountryDriver']: false };

        // Asigning month value for payment...
        this.MM;

        // Assign Bydefault value of Term and Territory...
        this.customerData = { ...this.customerData, ['Term__c']: 'Daily' };
        this.customerData = { ...this.customerData, ['territory']: 'Baja/Sonora' };

        if (this.paramdata !== undefined && this.paramdata !== null) {
            await fetchExistingLead({ email: '', leadId: this.paramdata.id })
                .then(async (result) => {
                    if (result && result.length > 0) {
                        await this.getSystemTime();
                        console.log('Result', result);
                        this.existLeadDetails = JSON.parse(result);
                        console.log('passed 1');

                        if (this.existLeadDetails.ConvertedContactId) {
                            let policyId;
                            if (this.existLeadDetails.Quotes__r && this.existLeadDetails.Quotes__r.length > 0) {
                                const quoteWithPolicy = this.existLeadDetails.Quotes__r.find(q => q.Policy__c);
                                if (quoteWithPolicy) {
                                    policyId = quoteWithPolicy.Policy__c;
                                }
                            }
                            if (policyId) {
                                this.renewdPolicyId = policyId;
                                this.activeSectionName = 'policyQuickActions';
                            }
                        }

                        if (this.existLeadDetails.Quote_Details__c) {
                            this.existQuoteDetails = JSON.parse(
                                this.existLeadDetails.Quote_Details__c
                            );
                            console.log('passed 2');
                        }

                        if (this.existLeadDetails.Vehicle_details__c) {
                            this.existVehicleDetails = JSON.parse(
                                this.existLeadDetails.Vehicle_details__c
                            );
                            console.log('passed 3');
                        }

                        if (this.existLeadDetails && this.existLeadDetails.Driver_details__c) {
                            this.existDriverDetails = JSON.parse(
                                this.existLeadDetails.Driver_details__c
                            );
                            console.log('passed 4');
                        }

                        if (
                            this.existLeadDetails &&
                            this.existLeadDetails.Towing__c &&
                            this.existLeadDetails.Is_towing__c == true
                        ) {
                            this.booleanVar.isTowing = true;
                            this.booleanVar.isTowingChecked = true;
                            this.existTowedDetails = JSON.parse(this.existLeadDetails.Towing__c);
                            console.log('passed 4');
                        }

                        this.setExistingLeadData();
                        this.booleanVar.isPolicyDisabled = true;
                        this.booleanVar.isLoading = false;
                    } else {
                        this.booleanVar.isLoading = false;
                    }
                })
                .catch((error) => {
                    console.log('Error1 ->', error);
                    this.showToastmethod(
                        'warning',
                        'Could not load picklist values. Please try again.',
                        'Load Error'
                    );
                });
        }

        // Get year options
        this.getVehicleYears();

        // Rendering by default value....
        this.customerData = { ...this.customerData, ['Coverage__c']: 'Complete' };
        this.customerData = { ...this.customerData, ['Is_this_a_Rental_Vehicle__c']: 'No' };
        this.customerData = {
            ...this.customerData,
            ['Is_the_vehicle_used_for_business_purpose__c']: 'No'
        };
        this.customerData = { ...this.customerData, ['Salvage_Vehicle__c']: 'No' };
        this.customerData = { ...this.customerData, ['Is_there_a_driver_under_21__c']: 'No' };

        this.trackVar.Is_this_a_Rental_Vehicle__c = this.customerData.Is_this_a_Rental_Vehicle__c;
        this.trackVar.Is_the_vehicle_used_for_business_purpose__c =
            this.customerData.Is_the_vehicle_used_for_business_purpose__c;
        this.trackVar.Salvage_Vehicle__c = this.customerData.Salvage_Vehicle__c;
        this.trackVar.Is_there_a_driver_under_21__c =
            this.customerData.Is_there_a_driver_under_21__c;

        this.setCurrentTime();
    }

    //<------ Date and Time in Term Option ------->
    async setCurrentTime() {
        await this.getSystemTime();

        let today = new Date(this.systemTime.dtPST);
        let day = today.getDate();
        let month = today.getMonth();
        let year = today.getFullYear();
        let term = 0;
        let currentDate = new Date(year, month, day);
        this.mindate = currentDate.toISOString();
        this.customerData = { ...this.customerData, ['Start_Date_for_Coverage__c']: '' };
        let endDate = today;
        endDate.setDate(endDate.getDate() + 1);
        month = month + 1;
        let endMonth = endDate.getMonth() + 1;
        let endday = endDate.getDate();
        let endYear = endDate.getFullYear();
        let nextMinTime = this.systemTime?.nextMin.split('.')[0];
        let startDateCoverage =
            year + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(day);
        let endDateCoverage =
            endYear + '-' + this.toDigitFormate(endMonth) + '-' + this.toDigitFormate(endday);

        this.customerData = { ...this.customerData, ['Term__c']: 'Daily' };
        this.customerData = {
            ...this.customerData,
            ['Start_Date_for_Coverage__c']: startDateCoverage,
            ['End_Date_for_Coverage__c']: endDateCoverage,
            ['Start_Time__c']: nextMinTime,
            ['End_Time__c']: nextMinTime
        };
        this.trackVar.startDate = this.customerData.Start_Date_for_Coverage__c;
        this.trackVar.endDate = this.customerData.End_Date_for_Coverage__c;
        this.trackVar.startTime = this.customerData.Start_Time__c;
        this.trackVar.endTime = this.customerData.End_Time__c;
    }

    termDateTime(name, value) {
        // Date and time in Term Options.....

        let startDayForCoverage = new Date(this.customerData.Start_Date_for_Coverage__c);
        if (startDayForCoverage != null && startDayForCoverage != undefined) {
            startDayForCoverage = new Date(
                startDayForCoverage.getUTCFullYear(),
                startDayForCoverage.getUTCMonth(),
                startDayForCoverage.getUTCDate()
            );
            let dateMinforend = new Date(this.customerData.Start_Date_for_Coverage__c);
        }
        if (
            name == 'Start_Date_for_Coverage__c' &&
            startDayForCoverage != null &&
            startDayForCoverage != undefined
        ) {
            let dateOfSystem = this.systemTime.dtPST.split(' ');

            if (dateOfSystem[0] == value) {
                this.displayPstTime = this.systemTime.timePst;
                this.customerData = {
                    ...this.customerData,
                    ['Start_Time__c']: this.systemTime?.nextMin.split('.')[0],
                    ['End_Time__c']: this.systemTime?.nextMin.split('.')[0]
                };
                this.trackVar.startTime = this.customerData.Start_Time__c;
                this.trackVar.endTime = this.customerData.End_Time__c;
            } else {
                this.displayPstTime = '00:00:00';
                this.customerData = {
                    ...this.customerData,
                    ['Start_Time__c']: '00:00:00',
                    ['End_Time__c']: '00:00:00'
                };
                this.trackVar.startTime = this.customerData.Start_Time__c;
                this.trackVar.endTime = this.customerData.End_Time__c;
            }

            let endDayForCoverage = startDayForCoverage;

            if (this.booleanVar.annual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (this.booleanVar.semiAnnual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            } else {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 1);
            }

            const date = new Date(endDayForCoverage);
            let month = date.getMonth() + 1;
            let day = date.getDate();

            let endDateFormated =
                date.getFullYear() +
                '-' +
                this.toDigitFormate(month) +
                '-' +
                this.toDigitFormate(day);

            if (
                this.customerData.End_Date_for_Coverage__c != undefined ||
                this.customerData.End_Date_for_Coverage__c != null
            ) {
                this.customerData = {
                    ...this.customerData,
                    ['End_Date_for_Coverage__c']: endDateFormated
                };
            }
        }
    }

    handleEmailService(event) {
        console.log('EmailService');
        console.log(event.target.checked);
        this.booleanVar.emailService = event.target.checked;
    }

    async onGroup(name, value) {
        if (name == 'Term__c') {
            this.customerData = { ...this.customerData, ['Term__c']: value };
        }

        if (value == 'Daily') {
            this.booleanVar.isShowingEndTerm = true;
        } else {
            this.booleanVar.isShowingEndTerm = false;
        }

        if (value == 'Annual(One Year)' || value == 'Annual') {
            this.booleanVar.annual = true;
            this.booleanVar.semiAnnual = false;
            this.booleanVar.isEndDateDisabled = true;
        } else if (value == 'Semi-Annual(Half a Year)' || value == 'Semi-Annual') {
            this.booleanVar.annual = false;
            this.booleanVar.semiAnnual = true;
            this.booleanVar.isEndDateDisabled = true;
        } else {
            this.booleanVar.annual = false;
            this.booleanVar.semiAnnual = false;
            this.booleanVar.isEndDateDisabled = false;
            this.customerData = { ...this.customerData, ['End_Date_for_Coverage__c']: '' };
        }
        await this.getSystemTime();

        let today = new Date(this.systemTime.dtPST);
        let day = today.getDate();
        let month = today.getMonth();
        let year = today.getFullYear();

        let startDayForCoverage = new Date(this.customerData.Start_Date_for_Coverage__c);

        if (startDayForCoverage != null && startDayForCoverage != undefined) {
            let endDayForCoverage = startDayForCoverage;
            if (this.booleanVar.annual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (this.booleanVar.semiAnnual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            } else {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 1);
            }
            const date = new Date(endDayForCoverage);
            let endmonth = parseInt(date.getMonth()) + 1;
            month = month + 1;
            let endday = parseInt(date.getDate());

            let endDateFormated =
                date.getFullYear() +
                '-' +
                this.toDigitFormate(endmonth) +
                '-' +
                this.toDigitFormate(endday);
            this.customerData = {
                ...this.customerData,
                ['End_Date_for_Coverage__c']: endDateFormated
            };
            this.trackVar.endDate = endDateFormated;
        }
    }

    toDigitFormate(n) {
        return n > 9 ? '' + n : '0' + n;
    }

    getSystemTime = async () => {
        try {
            const timeData = await getTimeZone();

            if (timeData.status == 'success') {
                this.systemTime = timeData;
                // 21  Aug update on time

                let startDayForCoverage = new Date(this.customerData.Start_Date_for_Coverage__c);

                let currentDate = new Date();

                console.log('Todays date', JSON.stringify(currentDate));

                console.log('Coverage date', startDayForCoverage);

                if (startDayForCoverage === currentDate || startDayForCoverage == 'Invalid Date') {
                    this.displayPstTime = this.systemTime.timePst;
                }
            } else {
            }
        } catch (ex) {
            console.log('erron occur in get system time : ' + ex);
        }
    };

    proceedTofinalStep(newPolicyId) {
        this.activeSectionName = 'policyQuickActions';
        const accordion = this.template.querySelector('.agentDashboard');
        accordion.activeSectionName = this.activeSectionName;
        this.renewdPolicyId = newPolicyId;
    }

    paymentFieldsValue() {
        if (this.booleanVar.isVehicleRentedChecked === true) {
            this.trackVar.paymentZip = this.customerData.Company_Zip__c;
            this.trackVar.paymentCity = this.customerData.Company_City__c;
            this.trackVar.paymentState = this.customerData.Company_State__c;
            if (
                this.customerData.Company_Country__c == 'United States' ||
                this.customerData.Company_Country__c == 'Canada' ||
                this.customerData.Company_Country__c == 'Mexico'
            ) {
                this.otherCountrypayment = false;
                this.trackVar.paymentCountry = this.customerData.Company_Country__c;
                this.trackVar.paymentCountrycmbx = this.customerData.Company_Country__c;
                this.paymentDetails = {
                    ...this.paymentDetails,
                    ['Country__c']: this.customerData.Company_Country__c
                };
            } else {
                this.otherCountrypayment = true;
                this.trackVar.paymentCountrycmbx = 'Other';
                this.trackVar.paymentCountry = this.customerData.Company_Country__c;
                this.paymentDetails = {
                    ...this.paymentDetails,
                    ['Country__c']: this.customerData.Company_Country__c
                };
            }

            this.trackVar.paymentStreet = this.customerData.Company_Address__c;
        } else {
            for (let each of this.addedDriver) {
                if (each.Driver_Type__c === 'Owner & Driver' || each.Driver_Type__c === 'Owner') {
                    this.trackVar.paymentZip = each.Postal_Code__c;
                    this.trackVar.paymentCity = each.City__c;
                    this.trackVar.paymentState = each.State_Province__c;
                    if (
                        each.Country__c == 'United States' ||
                        each.Country__c == 'Canada' ||
                        each.Country__c == 'Mexico'
                    ) {
                        this.otherCountrypayment = false;
                        this.trackVar.paymentCountry = each.Country__c;
                        this.trackVar.paymentCountrycmbx = each.Country__c;
                        this.paymentDetails = {
                            ...this.paymentDetails,
                            ['Country__c']: each.Country__c
                        };
                    } else {
                        this.otherCountrypayment = true;
                        this.trackVar.paymentCountrycmbx = 'Other';
                        this.trackVar.paymentCountry = each.Country__c;
                        this.paymentDetails = {
                            ...this.paymentDetails,
                            ['Country__c']: each.Country__c
                        };
                    }
                    this.trackVar.paymentStreet = each.Address__c;
                }
            }
        }
    }

    async fetchExistingLeadOnBlur(event) {
        let email = event.target.value;
        if (email.length > 3) {
            this.booleanVar.isLoading = true;

            await portalAccessForUser({ username: email }).then((result) => {
                console.log('result : ', result);
                if (result != null) {
                    this.booleanVar.isportalAccessHide = false;
                    this.booleanVar.portalAccessYes = false;
                    this.booleanVar.portalAccessNo = true;
                    if (result.IsActive == false) {
                        this.booleanVar.isUserDeactivated = true;
                    }
                } else {
                    if (this.cmpSource == 'comm') {
                        this.booleanVar.isportalAccessHide = false;
                        this.booleanVar.portalAccessYes = false;
                    } else {
                        this.booleanVar.isportalAccessHide = true;
                    }
                    //this.booleanVar.isportalAccessHide = true;
                }
            });

            await fetchExistingLead({ email: email, leadId: '' })
                .then((result) => {
                    console.log('Test contact ID -----', result);
                    if (result && result.length > 0) {
                        this.existLeadDetails = JSON.parse(result);

                        if (
                            this.existLeadDetails &&
                            this.existLeadDetails.Towing__c &&
                            this.existLeadDetails.Is_towing__c == true
                        ) {
                            this.booleanVar.isTowing = true;
                            this.booleanVar.isTowingChecked = true;
                            this.existTowedDetails = JSON.parse(this.existLeadDetails.Towing__c);
                        }

                        if (this.existLeadDetails.Vehicle_details__c) {
                            this.existVehicleDetails = JSON.parse(
                                this.existLeadDetails.Vehicle_details__c
                            );
                        }

                        if (this.existLeadDetails?.ConvertedContactId != undefined) {
                            // Create am error message
                            if (this.cmpSource == 'comm') {
                                this.showToastmethod(
                                    'error',
                                    'This is already a contact to an agency.',
                                    'Already Contact'
                                );
                            } else {
                                this.showToastEvent(
                                    'Already Contact',
                                    'This is already a contact to an agency.',
                                    'error'
                                );
                            }
                        } else {
                            this.setExistingLeadData();
                        }

                        // this.handlePopupModal();
                        this.booleanVar.isLoading = false;
                    } else {
                        this.booleanVar.isLoading = false;
                    }
                })
                .catch((error) => {
                    this.booleanVar.isLoading = false;
                    console.log('Email Error -> ', error);
                    this.showToastmethod(
                        'error',
                        error?.body?.message || 'Failed to send quote email. Please try again.',
                        'Email Error'
                    );
                });
        }
    }

    // <------- Populate the Lead data--------->
    async setExistingLeadData() {
        console.log('existVehicleDetails-->', this.existVehicleDetails);
        console.log('existQuoteDetails-->', this.existQuoteDetails);

        // Get Agent fee and Old Quote....
        this.OldQuote = this.existQuoteDetails?.Old_Net_Premium__c
            ? this.existQuoteDetails.Old_Net_Premium__c
            : 0;
        this.OldAgentFee = this.existQuoteDetails?.Agent_Fee__c
            ? this.existQuoteDetails.Agent_Fee__c
            : 0;
        console.log('OldAgentFee-->', this.OldAgentFee);
        console.log('OldQuote-->', this.OldQuote);
        if (this.existLeadDetails?.Policy_Type__c == 'Northbound') {
            this.fetchPicklist('Quote__c', 'Vehicle_Type__c');
        } else {
            this.getDependentPicklistValues('Quote__c', 'Vehicle_Type__c', 'Vehicle_Sub_type__c');
        }

        if (this.existDriverDetails != null) {
            this.addedDriver = this.existDriverDetails;

            this.existDriverDetails.map((driver) => {
                if (driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == 'Owner') {
                    this.booleanVar.registeredOwner = true;
                    this.booleanVar.companyAddressOption = false;
                    this.booleanVar.companyRegisteredOption = true;
                }
            });
        } else {
            this.addedDriver = [];
            this.booleanVar.registeredOwner = false;
        }

        if (this.existTowedDetails != null) {
            this.addedTowed = this.existTowedDetails;
        } else {
            this.addedTowed = [];
        }

        this.policyType = this.existLeadDetails?.Policy_Type__c;
        if (
            this.existLeadDetails?.Policy_Type__c == 'Automobile-Van-Minivan' ||
            this.existLeadDetails?.Policy_Type__c == 'RV'
        ) {
            this.booleanVar.isTowingCheckbox = true;
        } else {
            this.booleanVar.isTowingCheckbox = false;
            this.booleanVar.isTowing = false;
        }
        if (this.existLeadDetails?.Policy_Type__c != '') {
            console.log(
                'this.booleanVar.isUserDeactivated---1111---',
                this.booleanVar.isUserDeactivated
            );
            if (this.booleanVar.isUserDeactivated == true) {
                this.booleanVar.showPolicyform = false;
            } else {
                this.booleanVar.showPolicyform = true;
            }
        }

        if (this.existLeadDetails?.Policy_Type__c == 'Automobile-Van-Minivan') {
            this.booleanVar.isNorthbound = false;
            this.booleanVar.isPolicyAutomobile = true;
            this.booleanVar.isPolicyMotorcycle = false;
            this.booleanVar.isPolicyRV = false;
            this.booleanVar.isPolicyNorthbound = false;
            this.booleanVar.isPolicyWatercraft = false;
            //this.booleanVar.showPolicyform = true;
        } else if (this.existLeadDetails?.Policy_Type__c == 'Motorcycle/Street Legal ATV') {
            this.booleanVar.isNorthbound = false;
            this.booleanVar.isPolicyAutomobile = false;
            this.booleanVar.isPolicyMotorcycle = true;
            this.booleanVar.isPolicyRV = false;
            this.booleanVar.isPolicyNorthbound = false;
            this.booleanVar.isPolicyWatercraft = false;
            //this.booleanVar.showPolicyform = true;
        } else if (this.existLeadDetails?.Policy_Type__c == 'RV') {
            this.booleanVar.isNorthbound = false;
            this.booleanVar.isPolicyAutomobile = false;
            this.booleanVar.isPolicyMotorcycle = false;
            this.booleanVar.isPolicyRV = true;
            this.booleanVar.isPolicyNorthbound = false;
            this.booleanVar.isPolicyWatercraft = false;
            //this.booleanVar.showPolicyform = true;
        } else if (this.existLeadDetails?.Policy_Type__c == 'Northbound') {
            this.booleanVar.isNorthbound = true;
            this.booleanVar.isPolicyAutomobile = false;
            this.booleanVar.isPolicyMotorcycle = false;
            this.booleanVar.isPolicyRV = false;
            this.booleanVar.isPolicyNorthbound = true;
            this.booleanVar.isPolicyWatercraft = false;
            //this.booleanVar.showPolicyform = true;
        } else {
            this.booleanVar.isNorthbound = false;
            this.booleanVar.isPolicyAutomobile = false;
            this.booleanVar.isPolicyMotorcycle = false;
            this.booleanVar.isPolicyRV = false;
            this.booleanVar.isPolicyNorthbound = false;
            this.booleanVar.isPolicyWatercraft = true;
            //this.booleanVar.showPolicyform = true;
        }

        if (
            this.existQuoteDetails?.Term__c == 'Annual(One Year)' ||
            this.existQuoteDetails?.Term__c == 'Annual'
        ) {
            this.booleanVar.isEndDateDisabled = true;
            this.booleanVar.isAnnual = true;
            this.booleanVar.isDaily = false;
            this.booleanVar.isSemiAnnual = false;
            this.booleanVar.isShowingEndTerm = false;
        } else if (
            this.existQuoteDetails?.Term__c == 'Semi-Annual(Half a Year)' ||
            this.existQuoteDetails?.Term__c == 'Semi-Annual'
        ) {
            this.booleanVar.isEndDateDisabled = true;
            this.booleanVar.isSemiAnnual = true;
            this.booleanVar.isAnnual = false;
            this.booleanVar.isDaily = false;
            this.booleanVar.isShowingEndTerm = false;
        } else {
            this.booleanVar.isEndDateDisabled = false;
            this.booleanVar.isSemiAnnual = false;
            this.booleanVar.isAnnual = false;
            this.booleanVar.isShowingEndTerm = true;
            this.booleanVar.isDaily = true;
        }

        if (this.existQuoteDetails?.Territory__c == 'Baja/Sonora') {
            this.booleanVar.isBaja = true;
        } else if (this.existQuoteDetails?.Territory__c == 'Limited') {
            this.booleanVar.isLimited = true;
        } else {
            this.booleanVar.isTerritory = true;
        }

        if (
            this.existVehicleDetails?.Company_Name__c !== '' &&
            this.existVehicleDetails?.Company_Name__c !== undefined
        ) {
            this.booleanVar.isVehicleRentedChecked = true;
            this.booleanVar.companyAddressOption = true;
            this.booleanVar.registeredOwner = true;

            this.trackVar.Company_Name__c =
                this.existVehicleDetails?.Company_Name__c !== ''
                    ? this.existVehicleDetails.Company_Name__c
                    : '';
            this.trackVar.Company_Address__c =
                this.existVehicleDetails?.Company_Address__c !== ''
                    ? this.existVehicleDetails.Company_Address__c
                    : '';
            this.trackVar.Company_City__c =
                this.existVehicleDetails?.Company_City__c !== ''
                    ? this.existVehicleDetails.Company_City__c
                    : '';
            this.trackVar.Company_Country__c =
                this.existVehicleDetails?.Company_Country__c !== ''
                    ? this.existVehicleDetails.Company_Country__c
                    : '';
            this.trackVar.Company_Phone__c =
                this.existVehicleDetails?.Company_Phone__c !== ''
                    ? this.existVehicleDetails.Company_Phone__c
                    : '';
            this.trackVar.Company_State__c =
                this.existVehicleDetails?.Company_State__c !== ''
                    ? this.existVehicleDetails.Company_State__c
                    : '';
            this.trackVar.Company_Zip__c =
                this.existVehicleDetails?.Company_Zip__c !== ''
                    ? this.existVehicleDetails.Company_Zip__c
                    : '';

            this.customerData = {
                ...this.customerData,
                ['Is_vehicle_owned_by_a_company_or_rented__c']: true
            };
            this.customerData = {
                ...this.customerData,
                ['Company_Name__c']: this.trackVar.Company_Name__c
            };
            this.customerData = {
                ...this.customerData,
                ['Company_Address__c']: this.trackVar.Company_Address__c
            };
            this.customerData = {
                ...this.customerData,
                ['Company_City__c']: this.trackVar.Company_City__c
            };
            this.customerData = {
                ...this.customerData,
                ['Company_Country__c']: this.trackVar.Company_Country__c
            };
            this.customerData = {
                ...this.customerData,
                ['Company_Phone__c']: this.trackVar.Company_Phone__c
            };
            this.customerData = {
                ...this.customerData,
                ['Company_State__c']: this.trackVar.Company_State__c
            };
            this.customerData = {
                ...this.customerData,
                ['Company_Zip__c']: this.trackVar.Company_Zip__c
            };

            if (
                this.existVehicleDetails?.Company_Country__c != '' &&
                this.existVehicleDetails?.Company_Country__c != undefined &&
                (this.existVehicleDetails?.Company_Country__c == 'United States' ||
                    this.existVehicleDetails?.Company_Country__c == 'Mexico' ||
                    this.existVehicleDetails?.Company_Country__c == 'Canada' ||
                    this.existVehicleDetails?.Company_Country__c == 'Other')
            ) {
                this.otherCountryCompany = false;
                this.trackVar.companyCountrycmbx = this.existVehicleDetails.Company_Country__c;
            } else {
                this.otherCountryCompany = true;
                this.trackVar.companyCountrycmbx = 'Other';
            }
        } else {
            this.trackVar.Company_Name__c = '';
            this.trackVar.Company_Address__c = '';
            this.trackVar.Company_City__c = '';
            this.trackVar.Company_Country__c = '';
            this.trackVar.Company_Phone__c = '';
            this.trackVar.Company_State__c = '';
            this.trackVar.Company_Zip__c = '';

            this.booleanVar.companyAddressOption = false;

            this.booleanVar.registeredOwner = false;
            this.booleanVar.isVehicleRentedChecked = false;
            this.customerData = {
                ...this.customerData,
                ['Is_vehicle_owned_by_a_company_or_rented__c']: false,
                ['Company_Name__c']: '',
                ['Company_Country__c']: '',
                ['Company_Zip__c']: '',
                ['Company_State__c']: '',
                ['Company_City__c']: '',
                ['Company_Address__c']: '',
                ['Company_Phone__c']: ''
            };
        }

        if (
            this.existVehicleDetails?.Lienholder_name__c !== '' &&
            this.existVehicleDetails?.Lienholder_name__c !== undefined
        ) {
            this.booleanVar.isLienholderChecked = true;
            this.booleanVar.lienholderOption = true;

            this.customerData = {
                ...this.customerData,
                ['Is_Lienholder__c']: true,
                ['Lienholder_name__c']:
                    this.existVehicleDetails?.Lienholder_name__c !== ''
                        ? this.existVehicleDetails.Lienholder_name__c
                        : '',
                ['Lienholder_Street__c']:
                    this.existVehicleDetails?.Lienholder_Street__c !== ''
                        ? this.existVehicleDetails.Lienholder_Street__c
                        : '',
                ['Lienholder_State__c']:
                    this.existVehicleDetails?.Lienholder_State__c !== ''
                        ? this.existVehicleDetails.Lienholder_State__c
                        : '',
                ['Lienholder_Postal_Code__c']:
                    this.existVehicleDetails?.Lienholder_Postal_Code__c !== ''
                        ? this.existVehicleDetails.Lienholder_Postal_Code__c
                        : '',
                ['Lienholder_Phone__c']:
                    this.existVehicleDetails?.Lienholder_Phone__c !== ''
                        ? this.existVehicleDetails.Lienholder_Phone__c
                        : '',
                ['Lienholder_Country__c']:
                    this.existVehicleDetails?.Lienholder_Country__c !== ''
                        ? this.existVehicleDetails.Lienholder_Country__c
                        : '',
                ['Lienholder_City__c']:
                    this.existVehicleDetails?.Lienholder_City__c !== ''
                        ? this.existVehicleDetails.Lienholder_City__c
                        : ''
            };

            if (
                this.existVehicleDetails?.Lienholder_Country__c != '' &&
                this.existVehicleDetails?.Lienholder_Country__c != undefined &&
                (this.existVehicleDetails?.Lienholder_Country__c == 'United States' ||
                    this.existVehicleDetails?.Lienholder_Country__c == 'Mexico' ||
                    this.existVehicleDetails?.Lienholder_Country__c == 'Canada' ||
                    this.existVehicleDetails?.Lienholder_Country__c == 'Other')
            ) {
                this.otherCountrylienholder = false;
                this.trackVar.lienHolderCountrycmbx =
                    this.existVehicleDetails.Lienholder_Country__c;
            } else {
                this.otherCountrylienholder = true;
                this.trackVar.lienHolderCountrycmbx = 'Other';
            }
        } else {
            this.booleanVar.lienholderOption = false;
            this.booleanVar.isLienholderChecked = false;
            this.customerData = {
                ...this.customerData,
                ['Is_Lienholder__c']: false,
                ['Lienholder_name__c']: '',
                ['Lienholder_Country__c']: '',
                ['Lienholder_Postal_Code__c']: '',
                ['Lienholder_State__c']: '',
                ['Lienholder_City__c']: '',
                ['Lienholder_Street__c']: '',
                ['Lienholder_Phone__c']: ''
            };
        }

        if (
            this.existVehicleDetails?.Registered_Country__c != '' &&
            this.existVehicleDetails?.Registered_Country__c != undefined &&
            (this.existVehicleDetails?.Registered_Country__c == 'United States' ||
                this.existVehicleDetails?.Registered_Country__c == 'Mexico' ||
                this.existVehicleDetails?.Registered_Country__c == 'Canada' ||
                this.existVehicleDetails?.Registered_Country__c == 'Other')
        ) {
            this.otherCountryRegister = false;
            let combobox = this.refs.Registered_Country__cmbx;
            if (combobox) {
                combobox.value = this.existVehicleDetails.Registered_Country__c;
            }
        } else {
            this.otherCountryRegister = true;
            let combobox = this.refs.Registered_Country__cmbx;
            if (combobox) {
                combobox.value = 'Other';
            }
        }

        this.trackVar.FirstName = this.existLeadDetails?.FirstName;
        this.trackVar.LastName = this.existLeadDetails?.LastName;
        this.trackVar.Is_towing__c = this.existLeadDetails?.Is_towing__c;
        this.trackVar.Year__c = this.existVehicleDetails?.Year__c
            ? this.existVehicleDetails.Year__c
            : '';
        this.trackVar.vehicleType = this.existVehicleDetails?.Vehicle_Type__c
            ? this.existVehicleDetails.Vehicle_Type__c
            : '';
        this.trackVar.Vehicle_sub_type__c = this.existVehicleDetails?.Vehicle_sub_type__c
            ? this.existVehicleDetails.Vehicle_sub_type__c
            : '';
        this.trackVar.Value__c = this.existVehicleDetails?.Value__c
            ? this.existVehicleDetails.Value__c
            : '';
        this.trackVar.Salvage_Vehicle__c =
            this.existVehicleDetails?.Salvage_Vehicle__c == true ? 'Yes' : 'No';
        this.trackVar.Model__c = this.existVehicleDetails?.Model__c
            ? this.existVehicleDetails.Model__c
            : '';
        this.trackVar.Make__c = this.existVehicleDetails?.Make__c
            ? this.existVehicleDetails.Make__c
            : '';
        this.trackVar.Coverage__c = this.existLeadDetails?.Liability__c == true ? true : false;
        this.trackVar.Is_this_a_Rental_Vehicle__c =
            this.existVehicleDetails?.Is_this_a_Rental_Vehicle__c == true ? 'Yes' : 'No';
        this.trackVar.Is_there_a_driver_under_21__c =
            this.existVehicleDetails?.Is_there_a_driver_under_21__c == true ? 'Yes' : 'No';
        this.trackVar.Is_the_vehicle_used_for_business_purpose__c =
            this.existVehicleDetails?.Is_the_vehicle_used_for_business_purpose__c == true
                ? 'Yes'
                : 'No';
        this.trackVar.startDate = this.existQuoteDetails?.Start_Date_for_Coverage__c
            ? this.existQuoteDetails.Start_Date_for_Coverage__c
            : this.customerData.Start_Date_for_Coverage__c;
        this.trackVar.endDate = this.existQuoteDetails?.End_Date_for_Coverage__c
            ? this.existQuoteDetails.End_Date_for_Coverage__c
            : this.customerData.End_Date_for_Coverage__c;
        this.trackVar.startTime = this.existQuoteDetails?.Start_Time__c
            ? this.existQuoteDetails.Start_Time__c
            : this.customerData.Start_Time__c;
        this.trackVar.endTime = this.existQuoteDetails?.End_Time__c
            ? this.existQuoteDetails.End_Time__c
            : this.customerData.End_Time__c;
        this.trackVar.Phone = this.existLeadDetails?.Phone ? this.existLeadDetails.Phone : '';
        this.trackVar.Email = this.existLeadDetails?.Email ? this.existLeadDetails.Email : '';
        this.trackVar.Vin__c = this.existVehicleDetails?.Vin__c
            ? this.existVehicleDetails.Vin__c
            : '';
        this.trackVar.Registered_Country__c = this.existVehicleDetails?.Registered_Country__c
            ? this.existVehicleDetails.Registered_Country__c
            : '';
        this.trackVar.Registered_Plate__c = this.existVehicleDetails?.Registered_Plate__c
            ? this.existVehicleDetails.Registered_Plate__c
            : '';
        this.trackVar.Registered_State__c = this.existVehicleDetails?.Registered_State__c
            ? this.existVehicleDetails.Registered_State__c
            : '';
        this.trackVar.vehicleDob = this.existVehicleDetails?.Dob__c
            ? this.existVehicleDetails.Dob__c
            : '';

        this.customerData = { ...this.customerData, ['FirstName']: this.trackVar.FirstName };
        this.customerData = { ...this.customerData, ['LastName']: this.trackVar.LastName };
        this.customerData = {
            ...this.customerData,
            ['Is_towing__c']: this.trackVar.Is_towing__c == true ? 'Yes' : 'No'
        };
        this.customerData = { ...this.customerData, ['Year__c']: this.trackVar.Year__c };
        this.customerData = {
            ...this.customerData,
            ['Vehicle_sub_type__c']: this.trackVar.Vehicle_sub_type__c
        };
        this.customerData = {
            ...this.customerData,
            ['Vehicle_Type__c']: this.trackVar.vehicleType
        };
        this.customerData = { ...this.customerData, ['Value__c']: this.trackVar.Value__c };
        this.customerData = {
            ...this.customerData,
            ['Salvage_Vehicle__c']: this.trackVar.Salvage_Vehicle__c
        };
        this.customerData = { ...this.customerData, ['Model__c']: this.trackVar.Model__c };
        this.customerData = { ...this.customerData, ['Make__c']: this.trackVar.Make__c };
        this.customerData = {
            ...this.customerData,
            ['Start_Date_for_Coverage__c']: this.trackVar.startDate
        };
        this.customerData = {
            ...this.customerData,
            ['End_Date_for_Coverage__c']: this.trackVar.endDate
        };
        this.customerData = {
            ...this.customerData,
            ['Is_there_a_driver_under_21__c']: this.trackVar.Is_there_a_driver_under_21__c
        };
        this.customerData = {
            ...this.customerData,
            ['Coverage__c']:
                this.existQuoteDetails?.Coverage__c != undefined
                    ? this.existQuoteDetails.Coverage__c
                    : 'Complete'
        };
        this.customerData = {
            ...this.customerData,
            ['Is_this_a_Rental_Vehicle__c']: this.trackVar.Is_this_a_Rental_Vehicle__c
        };
        this.customerData = {
            ...this.customerData,
            ['Is_the_vehicle_used_for_business_purpose__c']:
                this.trackVar.Is_the_vehicle_used_for_business_purpose__c
        };
        this.customerData = { ...this.customerData, ['Start_Time__c']: this.trackVar.startTime };
        this.customerData = { ...this.customerData, ['End_Time__c']: this.trackVar.endTime };
        this.customerData = { ...this.customerData, ['Phone']: this.trackVar.Phone };
        this.customerData = { ...this.customerData, ['Email']: this.trackVar.Email };
        this.customerData = { ...this.customerData, ['Vin__c']: this.trackVar.Vin__c };
        this.customerData = {
            ...this.customerData,
            ['Registered_Country__c']: this.trackVar.Registered_Country__c
        };
        this.customerData = {
            ...this.customerData,
            ['Registered_Plate__c']: this.trackVar.Registered_Plate__c
        };
        this.customerData = {
            ...this.customerData,
            ['Registered_State__c']: this.trackVar.Registered_State__c
        };
        this.customerData = { ...this.customerData, ['Id']: this.existLeadDetails?.Id };
        this.customerData = { ...this.customerData, ['QuoteId']: this.existQuoteDetails?.Id };
        this.customerData = { ...this.customerData, ['Term__c']: this.existQuoteDetails?.Term__c };
        this.customerData = {
            ...this.customerData,
            ['Policy_Type__c']: this.existLeadDetails?.Policy_Type__c
        };
        this.customerData = {
            ...this.customerData,
            ['territory']: this.existQuoteDetails?.Territory__c
                ? this.existQuoteDetails.Territory__c
                : this.customerData.territory
        };
        this.customerData = { ...this.customerData, ['Dob__c']: this.existVehicleDetails?.Dob__c };
        if (this.booleanVar.isNorthbound === false) {
            this.getVehicleMakes().then((result) => {
                console.log('resultt------', result);
                if (result) {
                    if (this.existVehicleDetails.Make__c) {
                        const valueExists = this.makeOptions.some(
                            (option) => option.value === this.existVehicleDetails.Make__c
                        );

                        if (!valueExists) {
                            this.booleanVar.showManualMake = true;
                            this.booleanVar.isModelDisabled = true;
                            this.booleanVar.showManualModel = true;
                            this.trackVar.Make__c = '<Manually Enter>';
                            this.trackVar.Model__c = '<Manually Enter>';
                            this.trackVar.MannualMake = this.existVehicleDetails?.Make__c;
                            this.customerData = {
                                ...this.customerData,
                                ['Make__c']: this.trackVar.MannualMake
                            };
                            this.trackVar.MannualModel = this.existVehicleDetails?.Model__c;
                            this.customerData = {
                                ...this.customerData,
                                ['Model__c']: this.trackVar.MannualModel
                            };
                        } else {
                            this.booleanVar.showManualModel = false;
                            this.booleanVar.showManualMake = false;
                            this.booleanVar.isModelDisabled = false;
                            this.trackVar.Make__c = this.existVehicleDetails.Make__c;
                            this.trackVar.Model__c = this.existVehicleDetails.Model__c;
                            this.customerData = {
                                ...this.customerData,
                                ['Make__c']: this.trackVar.Make__c
                            };
                            this.customerData = {
                                ...this.customerData,
                                ['Model__c']: this.trackVar.Model__c
                            };
                        }
                    }
                }
            });

            this.getVehicleModels().then((result) => {
                if (result) {
                    if (this.existVehicleDetails.Model__c) {
                        const valueExists = this.modelOptions.some(
                            (option) => option.value === this.existVehicleDetails.Model__c
                        );

                        if (!valueExists) {
                            this.booleanVar.showManualModel = true;
                            this.trackVar.Model__c = '<Manually Enter>';
                            this.trackVar.MannualModel = this.existVehicleDetails?.Model__c;
                            this.customerData = {
                                ...this.customerData,
                                ['Model__c']: this.trackVar.MannualModel
                            };
                        } else {
                            this.booleanVar.showManualModel = false;
                            this.trackVar.Model__c = this.existVehicleDetails.Model__c;
                            this.customerData = {
                                ...this.customerData,
                                ['Model__c']: this.trackVar.Model__c
                            };
                        }
                    }
                }
            });
        }
    }

    async handlePopupModal() {
        let result = await popupModal.open();
        console.log('this.existLeadDetails', this.existLeadDetails);
        let currentUrl = window.location.origin;
        if (result === false) {
            if (this.cmpSource === 'comm') {
                location.replace(`${currentUrl}/partnercomm/quick-quote`);
            } else {
                location.replace(`${currentUrl}/lightning/page/home`);
            }
        } else {
            let recordsId =
                this.existLeadDetails?.ConvertedContactId != undefined
                    ? this.existLeadDetails.ConvertedContactId
                    : this.existLeadDetails?.Id;
            console.log('recordsId', recordsId);
            if (this.cmpSource == 'comm') {
                //30 Aug
                if (this.existLeadDetails?.ConvertedContactId != undefined) {
                    // location.replace(`${currentUrl}/partnercomm/quick-quote?c__contactId=${recordsId}&c__actionmode=newPolicyFromContact`);
                    return;
                } else {
                    location.replace(
                        `${currentUrl}/partnercomm/quick-quote?c__contactId=${recordsId}&c__actionmode=resumeLead`
                    );
                }
            } else {
                if (this.existLeadDetails?.ConvertedContactId != undefined) {
                    // location.replace(`${currentUrl}/lightning/n/Quick_Quote?c__contactId=${recordsId}&c__actionmode=newPolicyFromContact`);
                    return;
                } else {
                    location.replace(
                        `${currentUrl}/lightning/n/Quick_Quote?c__contactId=${recordsId}&c__actionmode=resumeLead`
                    );
                }
            }
        }
        this.setExistingLeadData();

        this.booleanVar.isLoading = false;
    }

    handleLienHolderAddress(event) {
        let fetchaddress = JSON.parse(event.detail);
        this.searchandUpdateStateOptions(fetchaddress.State, fetchaddress.Country);
        if (
            this.customerData.Policy_Type__c === 'Northbound' &&
            (fetchaddress.Country == 'United States' || fetchaddress.Country == 'Canada')
        ) {
            if (this.cmpSource === 'comm') {
                this.showToastmethod(
                    'error',
                    'This country cannot be added to Mexican vehicles.',
                    'Country error'
                );
            } else {
                this.showToastEvent(
                    'Country error',
                    'This country cannot be added to Mexican vehicles.',
                    'error'
                );
            }
            return true;
        } else if (
            this.customerData.Policy_Type__c != 'Northbound' &&
            fetchaddress.Country == 'Mexico'
        ) {
            if (this.cmpSource === 'comm') {
                this.showToastmethod(
                    'error',
                    'This country cannot be added in Automobile, RV and motorcycle/ATV.',
                    'Country error'
                );
            } else {
                this.showToastEvent(
                    'Country error',
                    'This country cannot be added in Automobile, RV and motorcycle/ATV.',
                    'error'
                );
            }
            return true;
        } else {
            if (
                fetchaddress.Country == 'United States' ||
                fetchaddress.Country == 'Canada' ||
                fetchaddress.Country == 'Mexico'
            ) {
                this.otherCountrylienholder = false;
                this.trackVar.lienHolderCountrycmbx = fetchaddress.Country;
                this.customerData = {
                    ...this.customerData,
                    ['Lienholder_Country__c']: this.trackVar.lienHolderCountrycmbx
                };
            } else {
                this.otherCountrylienholder = true;
                this.trackVar.Lienholder_Country__c = fetchaddress.Country;
                this.trackVar.lienHolderCountrycmbx = 'Other';
                this.customerData = {
                    ...this.customerData,
                    ['Lienholder_Country__c']: this.trackVar.Lienholder_Country__c
                };
            }
        }

        this.trackVar.Lienholder_State__c = fetchaddress.State;
        this.trackVar.Lienholder_City__c = fetchaddress.City;
        this.trackVar.Lienholder_Postal_Code__c = fetchaddress.PostalCode;
        this.trackVar.Lienholder_Street__c = fetchaddress.Address;

        this.customerData = {
            ...this.customerData,
            ['Lienholder_State__c']: this.trackVar.Lienholder_State__c
        };
        this.customerData = {
            ...this.customerData,
            ['Lienholder_City__c']: this.trackVar.Lienholder_City__c
        };
        this.customerData = {
            ...this.customerData,
            ['Lienholder_Postal_Code__c']: this.trackVar.Lienholder_Postal_Code__c
        };
        this.customerData = {
            ...this.customerData,
            ['Lienholder_Street__c']: this.trackVar.Lienholder_Street__c
        };
    }

    handleRegisteredAddress(event) {
        let fetchaddress = JSON.parse(event.detail);

        this.trackVar.Registered_Country__c = fetchaddress.Country;
        this.trackVar.Registered_State__c = fetchaddress.State;

        this.customerData = {
            ...this.customerData,
            ['Registered_Country__c']: this.trackVar.Registered_Country__c
        };
        this.customerData = {
            ...this.customerData,
            ['Registered_State__c']: this.trackVar.Registered_State__c
        };
    }

    handleCompanyAddress(event) {
        let fetchaddress = JSON.parse(event.detail);
        this.searchandUpdateStateOptions(fetchaddress.State, fetchaddress.Country);
        if (
            this.customerData.Policy_Type__c == 'Northbound' &&
            (fetchaddress.Country == 'United States' || fetchaddress.Country == 'Canada')
        ) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'This country cannot be added to Mexican vehicles.',
                    'Country error'
                );
            } else {
                this.showToastEvent(
                    'Country error',
                    'This country cannot be added to Mexican vehicles.',
                    'error'
                );
            }
            return true;
        } else if (
            this.customerData.Policy_Type__c != 'Northbound' &&
            fetchaddress.Country == 'Mexico'
        ) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'This country cannot be added in Automobile, RV and motorcycle/ATV.',
                    'Country error'
                );
            } else {
                this.showToastEvent(
                    'Country error',
                    'This country cannot be added in Automobile, RV and motorcycle/ATV.',
                    'error'
                );
            }
            return true;
        } else {
            if (
                fetchaddress.Country == 'United States' ||
                fetchaddress.Country == 'Canada' ||
                fetchaddress.Country == 'Mexico'
            ) {
                this.otherCountryCompany = false;
                this.trackVar.companyCountrycmbx = fetchaddress.Country;
                this.customerData = {
                    ...this.customerData,
                    ['Company_Country__c']: this.trackVar.companyCountrycmbx
                };
            } else {
                this.otherCountryCompany = true;
                this.trackVar.Company_Country__c = fetchaddress.Country;
                this.trackVar.companyCountrycmbx = 'Other';
                this.customerData = {
                    ...this.customerData,
                    ['Company_Country__c']: this.trackVar.Company_Country__c
                };
            }
        }

        this.trackVar.Company_State__c = fetchaddress.State;
        this.trackVar.Company_City__c = fetchaddress.City;
        this.trackVar.Company_Zip__c = fetchaddress.PostalCode;
        this.trackVar.Company_Address__c = fetchaddress.Address;

        this.customerData = {
            ...this.customerData,
            ['Company_State__c']: this.trackVar.Company_State__c
        };
        this.customerData = {
            ...this.customerData,
            ['Company_City__c']: this.trackVar.Company_City__c
        };
        this.customerData = {
            ...this.customerData,
            ['Company_Zip__c']: this.trackVar.Company_Zip__c
        };
        this.customerData = {
            ...this.customerData,
            ['Company_Address__c']: this.trackVar.Company_Address__c
        };
    }

    handleDriverAddress(event) {
        let fetchaddress = JSON.parse(event.detail);
        this.searchandUpdateStateOptions(fetchaddress.State, fetchaddress.Country);
        console.log('Reached in handle driver address');
        if (
            this.customerData.Policy_Type__c == 'Northbound' &&
            (fetchaddress.Country == 'United States' || fetchaddress.Country == 'Canada')
        ) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'This country cannot be added to Mexican vehicles.',
                    'Country error'
                );
            } else {
                this.showToastEvent(
                    'Country error',
                    'This country cannot be added to Mexican vehicles.',
                    'error'
                );
            }
            return true;
        } else if (
            this.customerData.Policy_Type__c != 'Northbound' &&
            fetchaddress.Country == 'Mexico'
        ) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'This country cannot be added in Automobile, RV and motorcycle/ATV.',
                    'Country error'
                );
            } else {
                this.showToastEvent(
                    'Country error',
                    'This country cannot be added in Automobile, RV and motorcycle/ATV.',
                    'error'
                );
            }
            return true;
        } else {
            if (
                fetchaddress.Country == 'United States' ||
                fetchaddress.Country == 'Canada' ||
                fetchaddress.Country == 'Mexico'
            ) {
                if (fetchaddress.Country == 'Mexico') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                } else if (fetchaddress.Country == 'United States') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                } else if (fetchaddress.Country == 'Canada') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: false };
                this.newDriver = { ...this.newDriver, ['Country__cmbx']: fetchaddress.Country };
                this.newDriver = { ...this.newDriver, ['Country__c']: fetchaddress.Country };
                console.log('After address update :', JSON.stringify(this.newDriver));
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: true };
                this.newDriver = { ...this.newDriver, ['Country__cmbx']: 'Other' };
                this.newDriver = { ...this.newDriver, ['Country__c']: fetchaddress.Country };
            }
        }

        this.newDriver = { ...this.newDriver, ['Postal_Code__c']: fetchaddress.PostalCode };
        this.newDriver = { ...this.newDriver, ['State_Province__c']: fetchaddress.State };
        this.newDriver = { ...this.newDriver, ['City__c']: fetchaddress.City };
        this.newDriver = { ...this.newDriver, ['Address__c']: fetchaddress.Address };
    }

    handleUpdateDriver(event) {
        let status = this.isInputValid('.driverValidation');
        if (!status) {
            return true;
        }

        let driverAge;
        driverAge = new Date().getFullYear() - parseInt(this.newDriver.Dob__c);
        if (driverAge < 16) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Driver age should be between 16.', 'Driver Age');
            } else {
                this.showToastEvent('Driver Age', 'Driver age should be between 16', 'error');
            }
            return true;
        }

        this.booleanVar.editDriverBtn = false;
        this.booleanVar.isOwner = false;

        for (let each of this.addedDriver) {
            if (each.license_number__c === this.selectedDriverLicense) {
                console.log('Before Updated Driver : ', JSON.stringify(each));
                console.log('NEW DRIVER DATA ', JSON.stringify(this.newDriver));
                each.showDeleteButton = true;
                each.selectedStyle = '';
                each.First_Name__c = this.newDriver.First_Name__c
                    ? this.newDriver.First_Name__c
                    : each.First_Name__c;
                each.Last_Name__c = this.newDriver.Last_Name__c
                    ? this.newDriver.Last_Name__c
                    : each.Last_Name__c;
                each.License_Country__c = this.newDriver.License_Country__c
                    ? this.newDriver.License_Country__c
                    : each.License_Country__c;
                each.License_state__c = this.newDriver.License_state__c
                    ? this.newDriver.License_state__c
                    : each.License_state__c;
                each.license_number__c = this.newDriver.license_number__c
                    ? this.newDriver.license_number__c
                    : each.license_number__c;
                each.Dob__c = this.newDriver.Dob__c ? this.newDriver.Dob__c : each.Dob__c;
                each.owner = this.newDriver.owner ? this.newDriver.owner : each.owner;
                each.Driver_Type__c = this.newDriver.owner ? 'Owner & Driver' : 'Driver';
                each.Country__cmbx = this.newDriver.Country__cmbx
                    ? this.newDriver.Country__cmbx
                    : each.Country__cmbx;
                each.Country__c = this.newDriver.Country__c
                    ? this.newDriver.Country__c
                    : each.Country__c;
                each.Postal_Code__c = this.newDriver.Postal_Code__c
                    ? this.newDriver.Postal_Code__c
                    : each.Postal_Code__c;
                each.State_Province__c = this.newDriver.State_Province__c
                    ? this.newDriver.State_Province__c
                    : each.State_Province__c;
                each.City__c = this.newDriver.City__c ? this.newDriver.City__c : each.City__c;
                each.Address__c = this.newDriver.Address__c
                    ? this.newDriver.Address__c
                    : each.Address__c;
                each.Phone__c = this.newDriver.Phone__c ? this.newDriver.Phone__c : each.Phone__c;

                if (each.Driver_Type__c == 'Owner & Driver') {
                    this.booleanVar.registeredOwner = true;
                } else {
                    this.booleanVar.registeredOwner = false;
                    each.owner = false;
                    each.Country__c = '';
                    each.Postal_Code__c = '';
                    each.State_Province__c = '';
                    each.City__c = '';
                    each.Address__c = '';
                    each.Phone__c = '';
                }

                if (
                    each.License_Country__c == 'United States' ||
                    each.License_Country__c == 'Canada' ||
                    each.License_Country__c == 'Mexico' ||
                    each.License_Country__c == 'Other'
                ) {
                    each.otherCountryVehicle = false;
                    each = { ...each, ['License_Country__cmbx']: each.License_Country__c };
                } else {
                    each = { ...each, ['License_Country__cmbx']: 'Other' };
                    each.otherCountryVehicle = true;
                }

                if (
                    this.newDriver.Country__c == 'United States' ||
                    this.newDriver.Country__c == 'Canada' ||
                    this.newDriver.Country__c == 'Mexico' /*|| each.Country__c== 'Other' */
                ) {
                    each.otherCountryDriver = false;
                    each.Country__c = this.newDriver.Country__c;
                    each.Country__cmbx = this.newDriver.Country__cmbx;
                } else {
                    each.otherCountryDriver = true;
                }
            }

            console.log('After driver updated : ', JSON.stringify(each));
        }

        this.addedDriver = [...this.addedDriver];

        for (let each of this.addedDriver) {
            if (each.Driver_Type__c == 'Owner & Driver') {
                this.booleanVar.registeredOwner = true;
            }
        }
        this.newDriver = {};

        this.newDriver = {
            ...this.newDriver,
            ['First_Name__c']: '',
            ['Last_Name__c']: '',
            ['License_Country__c']: '',
            ['License_state__c']: '',
            ['license_number__c']: '',
            ['Dob__c']: '',
            ['owner']: false,
            ['otherCountryVehicle']: false,
            ['otherCountryDriver']: false,
            ['Country__c']: '',
            ['Postal_Code__c']: '',
            ['State_Province__c']: '',
            ['City__c']: '',
            ['Address__c']: '',
            ['Phone__c']: ''
        };
        this.booleanVar = { ...this.booleanVar };
        console.log('Added driver data', JSON.stringify(this.addedDriver));
    }

    handleDriverFieldsChange = (event) => {
        console.log('Running update on driver field');

        console.log('name--', event.target?.name, '---value---', event.target?.value);
        if (event.target.name == 'Driver_Type__c') {
            if (event.target.checked == true) {
                this.booleanVar.isOwner = true;
                this.newDriver = { ...this.newDriver, ['Driver_Type__c']: 'Owner & Driver' };
                this.newDriver = { ...this.newDriver, ['owner']: true };
                this.booleanVar.companyRegisteredOption = true;
            } else {
                this.booleanVar.isOwner = false;
                this.booleanVar.companyRegisteredOption = false;
                this.newDriver = { ...this.newDriver, ['Driver_Type__c']: 'Driver' };
                this.newDriver = { ...this.newDriver, ['owner']: false };
            }
        } else {
            this.newDriver = { ...this.newDriver, [event.target?.name]: event.target?.value };
        }

        if (event.target.name == 'Phone__c') {
            this.formatNumber(event.target.value, 'Phone__c');
            this.newDriver = { ...this.newDriver };
        }

        if (event.target.name == 'License_Country__cmbx') {
            if (event.target.value == 'Other') {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: true };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: false };
                if (event.target.value == 'Mexico') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                } else if (event.target.value == 'United States') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                } else if (event.target.value == 'Canada') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }
            }
        }

        if (event.target.name == 'Country__cmbx') {
            console.log('Owner Country ', event.target.value);
            if (event.target.value == 'Other') {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: true };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: false };
                if (event.target.value == 'Mexico') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                } else if (event.target.value == 'United States') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                } else if (event.target.value == 'Canada') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }
            }
        }

        console.log('this.newDriver', JSON.stringify(this.newDriver));
    };

    handleAddNewDriver = () => {
        let status = this.isInputValid('.driverValidation');
        if (!status) {
            return true;
        }

        let driverAge;
        driverAge = new Date().getFullYear() - parseInt(this.newDriver.Dob__c);
        if (driverAge < 16) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Driver age should be between 16.', 'Driver Age');
            } else {
                this.showToastEvent('Driver Age', 'Driver age should be between 16.', 'error');
            }
            return true;
        }

        if (
            !this.addedDriver.find(
                ({ license_number__c }) => license_number__c == this.newDriver.license_number__c
            )
        ) {
            if (
                this.newDriver.License_Country__cmbx == 'United States' ||
                this.newDriver.License_Country__cmbx == 'Canada' ||
                this.newDriver.License_Country__cmbx == 'Mexico' ||
                this.newDriver.License_Country__cmbx == 'Other'
            ) {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: false };
                this.newDriver = {
                    ...this.newDriver,
                    ['License_Country__c']: this.newDriver.License_Country__cmbx
                };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: true };
            }

            if (
                this.newDriver.Country__cmbx == 'United States' ||
                this.newDriver.Country__cmbx == 'Canada' ||
                this.newDriver.Country__cmbx ==
                    'Mexico' /* || this.newDriver.Country__cmbx== 'Other' */
            ) {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: false };
                if (this.newDriver.Country__c === undefined) {
                    console.log('Reached in update new driver empty country');
                    this.newDriver = {
                        ...this.newDriver,
                        ['Country__c']: this.newDriver.Country__cmbx
                    };
                }
                // this.newDriver = { ...this.newDriver,['Country__cmbx'] : this.newDriver.Country__cmbx};
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: true };
            }

            if (this.newDriver.Driver_Type__c == 'Owner & Driver') {
                this.newDriver.owner = true;
                this.booleanVar.isOwner = false; // Hide Owner fields

                this.booleanVar.registeredOwner = true; //
                this.booleanVar.companyRegisteredOption = true; // Disable company address option
            } else {
                this.newDriver.owner = false;
            }

            this.addedDriver = [...this.addedDriver, this.newDriver];

            this.template.querySelectorAll('.cDriver').forEach((inputField) => {
                if (inputField.type === 'checkbox' || inputField.type === 'checkbox-button') {
                    inputField.checked = false;
                } else {
                    inputField.value = null;
                }
            });
            this.newDriver = {};
            this.booleanVar = { ...this.booleanVar };

            console.log('added driver', JSON.stringify(this.addedDriver));
        } else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'The licence is already there; please add another licence.',
                    'License already exist!'
                );
            } else {
                this.showToastEvent(
                    'License already exist!',
                    'The licence is already there; please add another licence.',
                    'error'
                );
            }
            console.log('License is already there', this.newDriver);
        }
    };

    handleEditDriver = (event) => {
        this.newDriver = {};
        this.countOwner = 0;
        this.countDriver = 0;
        this.addedDriver.map((driver, index) => {
            if (driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == 'Owner') {
                this.countOwner++;
            } else {
                this.countDriver++;
            }

            if (event.target.dataset.id === driver?.license_number__c) {
                this.booleanVar.registeredOwner = false;

                if (driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == 'Owner') {
                    this.booleanVar.registeredOwner = false;
                    this.booleanVar.isOwner = true;
                    driver.owner = true;
                } else {
                    this.booleanVar.isOwner = false;
                    this.booleanVar.registeredOwner = true;
                }

                if (
                    driver.Country__c == 'United States' ||
                    driver.Country__c == 'Canada' ||
                    driver.Country__c == 'Mexico' ||
                    driver.Country__c == 'Other'
                ) {
                    driver.otherCountryDriver = false;
                    driver = { ...driver, ['Country__cmbx']: driver.Country__c };
                    driver = { ...driver, ['Country__c']: driver.Country__c };
                } else {
                    driver = { ...driver, ['Country__cmbx']: 'Other' };
                    driver = { ...driver, ['Country__c']: driver.Country__c };
                    driver.otherCountryDriver = true;
                }

                if (
                    driver.License_Country__c == 'United States' ||
                    driver.License_Country__c == 'Canada' ||
                    driver.License_Country__c == 'Mexico' ||
                    driver.License_Country__c == 'Other'
                ) {
                    driver.otherCountryVehicle = false;
                    driver = { ...driver, ['License_Country__cmbx']: driver.License_Country__c };
                } else {
                    driver = { ...driver, ['License_Country__cmbx']: 'Other' };
                    driver.otherCountryVehicle = true;
                }

                if (driver.License_Country__cmbx == 'Mexico') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                } else if (driver.License_Country__cmbx == 'United States') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                } else if (driver.License_Country__cmbx == 'Canada') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }

                if (driver.Country__c == 'Mexico') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                } else if (driver.Country__c == 'United States') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                } else if (driver.Country__c == 'Canada') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }

                driver.showDeleteButton = false;
                driver.selectedStyle = 'background:#feded8';
                this.newDriver = { ...driver };
                this.selectedDriverLicense = event.target.dataset.id;
            } else {
                driver.showDeleteButton = true;
                driver.selectedStyle = '';
            }
        });

        if (this.countOwner == 0 && this.countDriver > 0) {
            this.booleanVar.registeredOwner = false;
        }
        this.booleanVar.editDriverBtn = true;
        this.booleanVar = { ...this.booleanVar };

        console.log('added driver', this.newDriver);
    };

    handleDeleteDriver = (event) => {
        this.addedDriver = this.addedDriver.filter((driver) => {
            if (driver.license_number__c == event.target.dataset.id) {
                if (
                    driver.Driver_Type__c === 'Owner & Driver' ||
                    driver.Driver_Type__c === 'Owner'
                ) {
                    this.booleanVar.registeredOwner = false;
                    this.booleanVar.companyRegisteredOption = false;
                }
            }
            return driver.license_number__c != event.target.dataset.id;
        });
        this.booleanVar = { ...this.booleanVar };

        this.template.querySelectorAll('.cDriver').forEach((inputField) => {
            if (inputField.type === 'checkbox' || inputField.type === 'checkbox-button') {
                inputField.checked = false;
            } else {
                inputField.value = null;
            }
        });

        this.booleanVar.editDriverBtn = false;
        this.booleanVar.isOwner = false;
    };

    fetchPicklist(objectName, fieldApi) {
        getPicklistValuesFromApex({ objectApiName: objectName, fieldApiName: fieldApi })
            .then((result) => {
                let getResultValue = result;
                let filterOption = [];
                console.log('OUTPUT getResultValue: ', JSON.stringify(getResultValue));
                getResultValue.map((item) => {
                    if (
                        this.policyType &&
                        this.policyType.toLowerCase() == 'northbound' &&
                        item.value != 'Watercraft' &&
                        item.value != 'RV' &&
                        item.value != 'Driver License'
                    ) {
                        filterOption.push(item);
                    } else if (
                        this.policyType &&
                        (this.policyType.toLowerCase() == 'automobile' ||
                            this.policyType.toLowerCase() == 'automobile-van-minivan' ||
                            this.policyType.toLowerCase() == 'rv' ||
                            this.policyType.toLowerCase() == 'motorcycle/street legal atv') &&
                        item.value != 'Watercraft'
                    ) {
                        filterOption.push(item);
                    }
                });
                // if(filterOption.length)
                this.vehicleTypeQuoteOptions = filterOption;
                console.log('vehicletype');
                console.log(this.vehicleTypeQuoteOptions);
            })
            .catch((error) => {
                console.log('error', error);
                this.showToastmethod(
                    'warning',
                    'Could not load picklist values. Please try again.',
                    'Load Error'
                );
            });
    }

    getDependentPicklistValues(objectName, controllingField, dependentField) {
        getDependentMapWithTranslations({
            objectApiName: objectName,
            contrfieldApiName: controllingField,
            depfieldApiName: dependentField
        })
            .then((result) => {
                let vehicleType = this.policyType;
                if (vehicleType == 'Automobile') {
                    vehicleType = 'Car/Truck/Auto';
                } else if (vehicleType == 'Motorcycle') {
                    vehicleType = 'Motorcycle/Street Legal ATV';
                } else {
                    vehicleType = 'Automobile-Van-Minivan';
                }
                let storeResponse = result;
                let option = [];

                if (
                    vehicleType != null &&
                    storeResponse &&
                    storeResponse[vehicleType.trim()] != null
                ) {
                    let relevantControllingField = storeResponse[vehicleType];
                    for (const property in relevantControllingField) {
                        console.log('OUTPUT property: ', property);
                        option.push({
                            label: relevantControllingField[property],
                            value: property
                        });
                    }
                }

                this.vehicleTypeQuoteOptions = option;
            })
            .catch((error) => {
                console.log('error', error);
                this.showToastmethod(
                    'warning',
                    'Could not load vehicle type options. Please try again.',
                    'Load Error'
                );
            });
    }

    getVehicleYears() {
        getYears()
            .then((result) => {
                this.yearOption = result;
            })
            .catch((error) => {
                console.log('error', error);
                this.showToastmethod(
                    'warning',
                    'Could not load vehicle year options. Please try again.',
                    'Load Error'
                );
            });
    }

    async getVehicleMakes() {
        this.isLoadSpin = true;
        this.booleanVar.isLoading = true;
        return getMakes({ year: this.customerData.Year__c })
            .then((result) => {
                console.log(result);
                this.makeOptions = result;
                this.isLoadSpin = false;
                this.booleanVar.isLoading = false;
                this.trackVar.Make__c = '';
                this.trackVar.Model__c = '';
                this.customerData = { ...this.customerData, ['Make__c']: '' };
                this.customerData = { ...this.customerData, ['Model__c']: '' };
                const startSelect = this.template.querySelector('.comboboxMake');
                if (startSelect) {
                    startSelect.value = '';
                }
                const startmodelSelect = this.template.querySelector('.comboboxModel');
                if (startmodelSelect) {
                    startmodelSelect.value = '';
                }

                this.disableMake = false;
                return true;
            })
            .catch((error) => {
                this.isLoadSpin = false;
                this.booleanVar.isLoading = false;
                console.log('error : ' + JSON.stringify(error));
                this.showToastmethod(
                    'warning',
                    error?.body?.message || 'Could not load vehicle makes. Please try again.',
                    'Load Error'
                );
                return false;
            });
    }

    async getVehicleModels() {
        this.isLoadSpin = true;
        this.booleanVar.isLoading = true;
        return getModels({ year: this.customerData.Year__c, make: this.customerData.Make__c })
            .then((result) => {
                console.log(result);
                this.modelOptions = result;
                this.isLoadSpin = false;
                this.booleanVar.isLoading = false;
                return true;
            })
            .catch((error) => {
                this.isLoadSpin = false;
                this.booleanVar.isLoading = false;
                console.log('error : ', error);
                this.showToastmethod(
                    'warning',
                    error?.body?.message || 'Could not load vehicle models. Please try again.',
                    'Load Error'
                );
            });
    }

    highlightView() {
        this.IsHighlightView = !this.IsHighlightView;
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

    async updateMedical(event) {
        var name = event.target.name;
        var type = event.target.dataset.type;
        var medicallist = this.medicallist;
        if (name && name == 'chubbMedical') {
            medicallist = this.chubbmedicallist;
        }
        var length = medicallist.length - 1;

        var medical = '';
        if (name && name == 'qualitasMedical') {
            medical = this.qualitasMedical;
        } else if (name && name == 'chubbMedical') {
            medical = this.chubbMedical;
        } else if (name && name == 'mapfreMedical') {
            medical = this.mapfreMedical;
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

        if (
            name &&
            name === 'mapfreMedical' &&
            (updateMedical == '$20,000/$100,000' || updateMedical == '$15,000/$75,000')
        ) {
            updateMedical = '$10,000/$50,000';
        }

        if (name && name == 'qualitasMedical' && updateMedical && updateMedical != null) {
            this.qualitasMedical = updateMedical;
        } else if (name && name == 'mapfreMedical' && updateMedical && updateMedical != null) {
            this.mapfreMedical = updateMedical;
        } else if (name && name == 'chubbMedical' && updateMedical && updateMedical != null) {
            this.chubbMedical = updateMedical;
        }

        this.quoteDetails = {
            ...this.quoteDetails,
            ['Medical__c']: updateMedical != null ? updateMedical : this.quoteDetails.Medical__c
        };

        if (updateMedical && updateMedical != null) {
            await this.generateQuickQuote(this.quoteDetails);
        }
        this.handleUpdateRateValue();
    }

    async updateLiability(event) {
        if (this.booleanVar.isNorthbound === false) {
            var name = event.target.name;
            var type = event.target.dataset.type;

            var liabilitylist = this.liabilitylist;
            if (name && name == 'chubbLiability') {
                liabilitylist = this.Chubbliabilitylist;
            }
            var length = liabilitylist.length - 1;
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
            if (name && name == 'mapfreLiability' && updatelibality == '1000000') {
                updatelibality = 300000;
            }

            if (name && name === 'qualitasLiability' && updatelibality && updatelibality != null) {
                this.qualitasLiability = updatelibality;
            } else if (
                name &&
                name === 'chubbLiability' &&
                updatelibality &&
                updatelibality != null
            ) {
                this.chubbLiability = updatelibality;
            } else if (
                name &&
                name == 'mapfreLiability' &&
                updatelibality &&
                updatelibality != null
            ) {
                this.mapfreLiability = updatelibality;
            }

            this.quoteDetails = {
                ...this.quoteDetails,
                ['Liability__c']:
                    updatelibality != null
                        ? updatelibality.toString()
                        : this.quoteDetails.Liability__c
            };

            if (updatelibality && updatelibality != null) {
                await this.generateQuickQuote(this.quoteDetails);
            }
        }

        if (this.booleanVar.isNorthbound === true) {
            let type = event.target.dataset.type;
            let liabilityListLength = this.liabilityOptions.length - 1;
            let liablity = this.showLiability;
            let updatelibality;
            if (type && type == 'high') {
                var index = this.liabilityOptions.indexOf(liablity);
                if (liabilityListLength != index) {
                    updatelibality = this.liabilityOptions[index + 1];
                }
            } else if (type && type == 'low') {
                var index = this.liabilityOptions.indexOf(liablity);
                if (index != 0) {
                    updatelibality = this.liabilityOptions[index - 1];
                }
            }

            if (updatelibality && updatelibality != null) {
                this.showLiability = updatelibality;
                this.chubbLiability = updatelibality;
                await this.generateQuickQuote(this.quoteDetails);
            }
        }
        this.handleUpdateRateValue();
    }

    async handleDateChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        let endDateFormated;
        if (name == 'Start_Date_for_Coverage__c') {
            let startDate = new Date(value);
            let month = startDate.getMonth() + 1;
            let day = startDate.getDate() + 1;
            let year = startDate.getFullYear();
            let endmindate = new Date(year, month, day);
            this.trackVar.endDate = startDate;
        }

        if (name == 'Start_Date_for_Coverage__c') {
            let startDayForCoverage = new Date(value);
            let endDayForCoverage = startDayForCoverage;
            if (
                this.quoteDetails.Term__c === 'Annual(One Year)' ||
                this.quoteDetails.Term__c === 'Annual'
            ) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (
                this.quoteDetails.Term__c == 'Semi-Annual(Half a Year)' ||
                this.quoteDetails.Term__c === 'Semi-Annual'
            ) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            } else {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 1);
            }

            const date = new Date(endDayForCoverage);
            let month = date.getMonth() + 1;
            let day = date.getDate();

            endDateFormated =
                date.getFullYear() +
                '-' +
                this.toDigitFormate(month) +
                '-' +
                this.toDigitFormate(day);

            this.quoteDetails['End_Date_for_Coverage__c'] = endDateFormated;
            // 26 Aug Update

            this.handleInputChange(event);
        }

        this.quoteDetails[name] = value;
        await this.generateQuickQuote(this.quoteDetails);
    }

    async updateLibilityValue(event) {
        let value = event.target.checked;
        let name = event.target.name;
        console.log('Name Coverage--', name);
        if (!value && name == 'Liability') {
            name = 'Complete';
            this.trackVar.Coverage__c = false;
            this.customerData = { ...this.customerData, ['Coverage__c']: 'Complete' };
        }
        if (value && name == 'Liability') {
            this.customerData = { ...this.customerData, ['Coverage__c']: 'Liability' };
            this.trackVar.Coverage__c = true;
        }
        if (value && name == 'Complete') {
            this.customerData = { ...this.customerData, ['Coverage__c']: 'Complete' };
        }
        if (value && name == 'Max') {
            this.customerData = { ...this.customerData, ['Coverage__c']: 'Max' };
        }
        let updateValue = value ? 'Liability' : 'Complete';

        this.quoteDetails = { ...this.quoteDetails, ['Coverage__c']: name };
        await this.generateQuickQuote(this.quoteDetails);
        this.handleUpdateRateValue();
    }

    handleToggleSection(event) {
        const accordion = this.template.querySelector('.agentDashboard');
        accordion.activeSectionName = this.activeSectionName;
    }

    handlePrevAccordionSection(event) {
        let openAccordion = this.template.querySelector('.agentDashboard');
        if (this.activeSectionName == 'payment') {
            this.activeSectionName = 'purchase';
            openAccordion.activeSectionName = 'purchase';
        } else if (this.activeSectionName == 'purchase') {
            this.activeSectionName = 'quote';
            openAccordion.activeSectionName = 'quote';
        } else if (this.activeSectionName == 'quote') {
            if (this.booleanVar.checkPortalAcccess == true) {
                this.booleanVar.isportalAccessHide = false;
            } else {
                this.booleanVar.isportalAccessHide = true;
            }

            this.booleanVar.isTowingCheckbox = true;
            this.activeSectionName = 'getAQuote';
            openAccordion.activeSectionName = 'getAQuote';
        }
    }

    async handlePurchaseClick(event) {
        this.booleanVar.isLoading = true;

        let selectedQuote;

        if (this.booleanVar.isNorthbound === false) {
            selectedQuote = JSON.parse(JSON.stringify(this.quoteSelected));
        }

        console.log('selectedQuote--->', JSON.stringify(selectedQuote));

        console.log('In line number 1984');

        let generateQuote = {
            ...this.fetchQuoteData(),
            ...selectedQuote
        };
        if (this.QuotePdfJson != undefined && this.QuotePdfJson != null) {
            let jsonField = JSON.parse(JSON.stringify(this.QuotePdfJson));
            generateQuote['QuotePdfJson__c'] = JSON.stringify(this.QuotePdfJson);
        }
        console.log('generateQuote--->', JSON.stringify(generateQuote));
        if (this.actionType === 'newPolicyFromContact') {
            await purchaseSaveDetails({
                quotes: JSON.stringify(generateQuote),
                leadId: this.contactId,
                PolicyFromLead: false
            })
                .then((result) => {
                    if (result) {
                        console.log(JSON.parse(result));
                        let data = JSON.parse(result);
                        if (data?.Quote_Details__c) {
                            console.log(JSON.parse(data?.Quote_Details__c));
                            this.quoteId = JSON.parse(data?.Quote_Details__c).Id;
                            this.customerData = { ...this.customerData, ['QuoteId']: this.quoteId };
                            this.totalAmount = JSON.parse(data?.Quote_Details__c).Quote_Value__c;
                        }
                    }
                    this.booleanVar.isLoading = false;
                })
                .catch((error) => {
                    this.booleanVar.isLoading = false;
                    console.log(error);
                    this.showToastmethod(
                        'error',
                        error?.body?.message || 'Failed to save quote details. Please try again.',
                        'Save Error'
                    );
                    return true;
                });
        } else {
            console.log('purchaseSaveDetails', JSON.stringify(generateQuote));
            await purchaseSaveDetails({
                quotes: JSON.stringify(generateQuote),
                leadId: this.leadId,
                PolicyFromLead: true
            })
                .then((result) => {
                    if (result) {
                        console.log(JSON.parse(result));
                        let data = JSON.parse(result);
                        if (data?.Quote_Details__c) {
                            console.log(JSON.parse(data?.Quote_Details__c));
                            this.quoteId = JSON.parse(data?.Quote_Details__c).Id;
                            this.customerData = { ...this.customerData, ['QuoteId']: this.quoteId };
                            this.totalAmount = JSON.parse(data?.Quote_Details__c).Quote_Value__c;
                        }
                    }
                    this.booleanVar.isLoading = false;
                })
                .catch((error) => {
                    this.booleanVar.isLoading = false;
                    console.log(error);
                    this.showToastmethod(
                        'error',
                        error?.body?.message || 'Failed to save quote details. Please try again.',
                        'Save Error'
                    );
                    return true;
                });
        }

        if (this.isDownloadQuote || this.isEmailSend) {
            if (this.isEmailSend) {
                let sendEmailOfQuoteDetail = await sendEmailQuoteDetails({ quoteId: this.quoteId });

                console.log('isEmail Send Already :: ' + sendEmailOfQuoteDetail.status);
                if (sendEmailOfQuoteDetail.status == 'success') {
                    console.log('Email Sccessfully Send to User');
                    this.showToastEvent('Success!', 'Email Is Sccessfully Sent', 'success');
                } else {
                    this.showToastmethod('error', 'Make sure to fill the email first', 'Error!');
                    this.generateLogs();
                }
            } else if (this.isDownloadQuote) {
                //console.log(window.location.origin+`/s/quoterate?Id=${this.quoteId}`)
                window.open(`/affiliatevforcesite/apex/selectedQuoteNewRate?Id=${this.quoteId}&affiliateCode=${this.affiliateCode}`, '_blank');
            }

            return;
        }

        this.activeSectionName = 'purchase';
        let openAccordion = this.template.querySelector('.agentDashboard');
        openAccordion.activeSectionName = this.activeSectionName;
    }

    async handleSelectedQuote(event) {
        this.isDownloadQuote = false;
        this.isEmailSend = false;
        let selectedQuoteData = event.detail;
        this.quoteSelected = JSON.parse(JSON.stringify(selectedQuoteData));
        console.log('OUTPUT : selectedQuoteData', selectedQuoteData);
        let res = await this.handlePurchaseClick();

        this.activeSectionName = 'purchase';
        let openAccordion = this.template.querySelector('.agentDashboard');
        openAccordion.activeSectionName = this.activeSectionName;
    }

    async handleProceedButton() {
        if (this.trackVar?.Registered_Country__cmbx === 'Other') {
            if (this.trackVar?.Registered_Country__c.toLowerCase().includes('mexico')) {
                if (this.cmpSource === 'comm') {
                    this.showToastmethod(
                        'error',
                        'Mexican vehicles (Mexican License Plates) are not eligible for tourist automobile insurance.',
                        'Contact a domestic Mexican agent or go directly to a Mexican insurance company to secure insurance on a Mexican-registered vehicle.'
                    );
                } else {
                    this.showToastEvent(
                        'Mexican vehicles (Mexican License Plates) are not eligible for tourist automobile insurance.',
                        'Contact a domestic Mexican agent or go directly to a Mexican insurance company to secure insurance on a Mexican-registered vehicle.',
                        'error'
                    );
                }
                return;
            }
        }
        console.log('portalAccessYes--->', this.booleanVar.portalAccessYes);
        let status = this.isInputValid('.purchaseValidate');

        let towedstatus = false;
        if (status === true) {
            let callagentTowedUnit = this.template.querySelector('c-agent-towed-unit');
            if (callagentTowedUnit) {
                let response = callagentTowedUnit.validateFields(this.addedTowed);
                console.log('response--->', response);
                if (response == true) {
                    status = true;
                    towedstatus = false;
                } else {
                    status = false;
                    towedstatus = true;
                }
            }

            console.log('this.customerData FROM HANDLEPROCEEDBUTTON::: ', this.customerData);
            console.log('this.customerData FROM HANDLEPROCEEDBUTTON::: ', this.trackVar);

            if (
                this.booleanVar.isLienholderChecked == true &&
                (!('Lienholder_City__c' in this.customerData) ||
                    !this.customerData.Lienholder_City__c ||
                    this.customerData.Lienholder_City__c == undefined ||
                    !('Lienholder_Country__c' in this.customerData) ||
                    !this.customerData.Lienholder_Country__c ||
                    this.customerData.Lienholder_Country__c == undefined ||
                    !('Lienholder_Phone__c' in this.customerData) ||
                    !this.customerData.Lienholder_Phone__c ||
                    this.customerData.Lienholder_Phone__c == undefined ||
                    !('Lienholder_Postal_Code__c' in this.customerData) ||
                    !this.customerData.Lienholder_Postal_Code__c ||
                    this.customerData.Lienholder_Postal_Code__c == undefined ||
                    !('Lienholder_State__c' in this.customerData) ||
                    !this.customerData.Lienholder_State__c ||
                    this.customerData.Lienholder_State__c == undefined ||
                    !('Lienholder_Street__c' in this.customerData) ||
                    !this.customerData.Lienholder_Street__c ||
                    this.customerData.Lienholder_Street__c == undefined ||
                    !('Lienholder_name__c' in this.customerData) ||
                    !this.customerData.Lienholder_name__c ||
                    this.customerData.Lienholder_name__c == undefined)
            ) {
                if (this.cmpSource === 'comm') {
                    this.showToastmethod(
                        'error',
                        'For procceding further,Please fill Lienholder Details.',
                        'Lienholder are not correct!'
                    );
                    return false;
                } else {
                    this.showToastEvent(
                        'Lienholder are not correct!',
                        'For procceding further,Please fill Lienholder Details.',
                        'error'
                    );
                    return false;
                }
            }
        }

        if (this.addedDriver != '' && status == true) {
            if (this.validateBeforeQuoteGenerationDrivers()) {
                this.booleanVar.isLoading = true;

                if (this.actionType === 'newPolicyFromContact') {
                    await this.handleAffiliateMapping();
                    await updateContactDetails({
                        Istowing: this.customerData?.Is_towing__c == 'Yes' ? true : false,
                        contactId: this.contactId,
                        termOptions: JSON.stringify(this.fetchTermOptions()),
                        driverDetails: JSON.stringify(this.fetchDriverData()),
                        termsAlert: JSON.stringify(this.fetchTermAndAlert()),
                        towedlistJSON: JSON.stringify(this.addedTowed),
                        WatercraftDetails:
                            this.allQuote.Policy_Type_picklist == 'Watercraft' ? '' : '', // update watercraftDeatils JSON ...................................................
                        vehicledetails:
                            this.allQuote.Policy_Type_picklist != 'Watercraft'
                                ? JSON.stringify(this.fetchVehicleData())
                                : '',
                        quoteDetails: JSON.stringify(this.fetchQuoteData())
                    })
                        .then((result) => {
                            console.log('result', result);
                            this.activeSectionName = 'payment';
                            let openAccordion = this.template.querySelector('.agentDashboard');
                            openAccordion.activeSectionName = this.activeSectionName;
                        })
                        .catch((error) => {
                            console.log('updateContactDetails error', error);
                            this.booleanVar.isLoading = false;
                            this.showToastmethod(
                                'error',
                                error?.body?.message ||
                                    'Failed to save contact details before payment. Please try again.',
                                'Save Error'
                            );
                        });
                } else {
                    await saveInfoBeforePayment({
                        leadId: this.leadId,
                        quotedata: JSON.stringify(this.fetchQuoteData()),
                        vehicleData: JSON.stringify(this.fetchVehicleData()),
                        termsAndAlerts: JSON.stringify(this.fetchTermAndAlert()),
                        driverDetails: JSON.stringify(this.fetchDriverData()),
                        termOptions: JSON.stringify(this.fetchTermOptions()),
                        towedDetails: JSON.stringify(this.addedTowed)
                    })
                        .then((result) => {
                            if (result) {
                                console.log(result);
                                this.activeSectionName = 'payment';
                                let openAccordion = this.template.querySelector('.agentDashboard');
                                openAccordion.activeSectionName = this.activeSectionName;
                            } else {
                                console.log('Return False-->', result);
                            }
                        })
                        .catch((error) => {
                            console.log('error in saveInfoBeforePayment method');
                            console.log(error);
                            this.showToastmethod(
                                'error',
                                error?.body?.message ||
                                    'Failed to save payment information. Please try again.',
                                'Save Error'
                            );
                        });
                    console.log('Completed Lead ........... ');
                }

                this.booleanVar.isLoading = false;
                this.paymentFieldsValue();
            } else {
                console.log('In the Else block');
                this.booleanVar.isLoading = false;
                if (this.cmpSource == 'comm') {
                    this.showToastmethod(
                        'error',
                        'For procceding further,No owner found.',
                        'Driver details are not correct!'
                    );
                } else {
                    this.showToastEvent(
                        'Driver details are not correct!',
                        'For procceding further,No owner found',
                        'error'
                    );
                }
            }
        } else {
            this.booleanVar.isLoading = false;
            console.log('towedstatus-->', towedstatus);
            console.log('addedDriver-->', this.addedDriver);
            if (towedstatus == true && this.addedDriver != '') {
                if (this.cmpSource == 'comm') {
                    this.showToastmethod(
                        'error',
                        'Click on the pencil icon to fill in additional information related to towed unit.',
                        'Kindly provide the required details (Click the Edit button) for the tow unit(s).'
                    );
                } else {
                    this.showToastEvent(
                        'Kindly provide the required details (Click the Edit button) for the tow unit(s).',
                        'Click on the pencil icon to fill in additional information related to towed unit.',
                        'error'
                    );
                }
            } else {
                if (this.cmpSource == 'comm') {
                    this.showToastmethod(
                        'error',
                        'Please fill out all the required fields.',
                        'Details are not correct!'
                    );
                } else {
                    this.showToastEvent(
                        'Details are not correct!',
                        'Please fill out all the required fields.',
                        'error'
                    );
                }
            }
        }
    }

    async downloadOrSendEmail(event) {
        console.log('Is send email' + typeof event.detail.sendemail);
        //console.log('This is the check for send Email :: '+ JSON.stringify(event.detail.data));
        let selectedQuoteData = event.detail.data;
        this.quoteSelected = JSON.parse(JSON.stringify(selectedQuoteData));
        this.QuotePdfJson = event.detail.coverage;
        //console.log('OUTPUT : selectedQuoteData', selectedQuoteData);
        if (event.detail.sendemail == 'true') {
            this.isEmailSend = true;
            this.isDownloadQuote = false;
        } else {
            this.isDownloadQuote = true;
            this.isEmailSend = false;
        }
        console.log('this.isEmailSend  :: ' + this.isEmailSend);
        console.log('this.isDownloadQuote :: ' + this.isDownloadQuote);
        let res = await this.handlePurchaseClick();
    }

    showToastmethod(variant, title, message) {
        if (this.isEnhanced) {
            const toast = this.template.querySelector('c-buho_toast');
            if (toast) {
                toast.showToast({ variant, title, message });
            }
        } else {
            const toast = this.template.querySelector('c-custom-toast');
            if (toast) {
                toast.showToast({ variant, title, message });
            }
        }
    }

    showToastEvent(label, message, variant) {
        if (this.isEnhanced) {
            this.showToastmethod(variant, label, message);
        } else {
            super.showToastEvent(label, message, variant);
        }
    }

    async handlMakePayment() {
        if (this.actionType === 'newPolicyFromContact') {
            await updateContactDestinationDetails({
                contactId: this.contactId,
                termsAlert: JSON.stringify(this.termAgreement)
            })
                .then((result) => {
                    if (result) {
                        console.log('Destination data updated in updateContactDestination');
                    } else {
                        console.log('Data not updated');
                    }
                })
                .catch((error) => {
                    console.log(
                        'Error while saving destination address through updateContactDestination',
                        error
                    );
                    this.showToastmethod(
                        'error',
                        error?.body?.message ||
                            'Failed to save destination details. Please try again.',
                        'Save Error'
                    );
                });
        } else {
            await saveLeadDestinationInfoBeforePayment({
                leadId: this.leadId,
                termsAndAlerts: JSON.stringify(this.termAgreement)
            })
                .then((result) => {
                    if (result) {
                        console.log('Destination data updated');
                    } else {
                        console.log('Data not updated');
                    }
                })
                .catch((error) => {
                    console.log(
                        'Error while saving destination address through saveLeadDestination',
                        error
                    );
                    this.showToastmethod(
                        'error',
                        error?.body?.message ||
                            'Failed to save destination details. Please try again.',
                        'Save Error'
                    );
                });
        }
        let transactionDetails = {};

        console.log('Payment type', this.paymentDetails);
        if (this.paymentDetails?.Payment_Type__c != undefined) {
            console.log('All data for new Policy', this.customerData);
            console.log('portalAccessYes--->', this.booleanVar.portalAccessYes);
            let status = this.isInputValid('.validate');
            if (status) {
                if (this.booleanVar.showCardPayment == true) {
                    this.booleanVar.isLoading = true;
                    transactionDetails = {
                        ...transactionDetails,
                        ['ip']: this.ip.data,
                        ['quoteIds']: [this.quoteId]
                    };

                    paymentThroughCard({
                        transactionDetails: JSON.stringify(transactionDetails),
                        paymentDetails: JSON.stringify(this.paymentDetails),
                        email: ''
                    })
                        .then((result) => {
                            console.log('result', result);
                            if (result) {
                                if (this.cmpSource == 'comm') {
                                    this.showToastmethod(
                                        'success',
                                        'Congratulations! Your transaction has been completed successfully',
                                        'Transaction Successful'
                                    );
                                } else {
                                    this.showToastEvent(
                                        'Transaction Successful',
                                        'Congratulations! Your transaction has been completed successfully',
                                        'success'
                                    );
                                }
                                if (this.actionType === 'newPolicyFromContact') {
                                    this.createPolicyFromContact(true);
                                } else {
                                    this.createPolicyFromLead(true);
                                }
                            } else {
                                this.booleanVar.isLoading = false;
                                if (this.cmpSource == 'comm') {
                                    this.showToastmethod(
                                        'error',
                                        'We regret to inform you that your transaction has been failed.',
                                        'Transaction Failed'
                                    );
                                } else {
                                    this.showToastEvent(
                                        'Transaction Failed',
                                        'We regret to inform you that your transaction has been failed.',
                                        'error'
                                    );
                                }
                            }
                        })
                        .catch((error) => {
                            this.booleanVar.isLoading = false;
                            console.log('error on payment:::::', error.body.message);
                            if (this.cmpSource == 'comm') {
                                console.log('Inside the lwr toast event');
                                this.showToastmethod(
                                    'error',
                                    error.body.message,
                                    'Transaction Failed'
                                );
                            } else {
                                console.log('Inside lwc component');
                                this.showToastEvent(
                                    'Transaction Failed',
                                    error.body.message,
                                    'error'
                                );
                            }
                        });
                } else {
                    this.booleanVar.isLoading = true;
                    if (this.actionType === 'newPolicyFromContact') {
                        this.createPolicyFromContact(false);
                    } else {
                        this.createPolicyFromLead(false);
                    }
                }
            }
        } else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'Please select any one payment method to proceed.',
                    'Select Payment Method'
                );
            } else {
                this.showToastEvent(
                    'Select Payment Method',
                    'Please select any one payment method to proceed.',
                    'error'
                );
            }
        }
    }

    createPolicyFromContact(isCardPayment) {
        createPolicyFromContact({
            contactId: this.contactId,
            needPortalAccess: this.booleanVar.portalAccessYes,
            isCardPayment: isCardPayment
        })
            .then((result) => {
                console.log('result 1', result);
                if (this.booleanVar.emailService === false) {
                } else {
                    getPolicyData({ policyId: result })
                        .then((res) => {
                            if (res === 'Success') {
                                console.log('Pdf gen');
                            } else {
                                console.log('Pdf gen', res);
                            }
                        })
                        .catch((err) => {
                            console.log('getPolicyData error', err);
                            this.showToastmethod(
                                'warning',
                                err?.body?.message ||
                                    'Could not generate policy PDF. Please try again.',
                                'PDF Generation Warning'
                            );
                        });
                    emailServices({ policyId: result, emailService: this.booleanVar.emailService })
                        .then((nresult) => {
                            console.log(nresult);
                        })
                        .catch((nerr) => {
                            console.log(nerr);
                            this.showToastmethod(
                                'warning',
                                nerr?.body?.message || 'Email notification could not be sent.',
                                'Email Warning'
                            );
                        });
                }
                this.booleanVar.isLoading = false;
                if (result != 'Error 1' && result != 'Error 2') {
                    if (this.cmpSource == 'comm') {
                        this.showToastmethod(
                            'success',
                            'Policy has been successfully created.',
                            'Policy Creation Notification'
                        );
                    } else {
                        this.showToastEvent(
                            'Policy Creation Notification',
                            'Policy has been successfully created.',
                            'success'
                        );
                    }
                    this.proceedTofinalStep(result);
                } else {
                    if (result == 'Error 1') {
                        if (this.cmpSource == 'comm') {
                            this.showToastmethod(
                                'error',
                                'Unable to create a policy as this email has an existing contact or policy.',
                                'Error Notification'
                            );
                        } else {
                            this.showToastEvent(
                                'Error Notification',
                                'Unable to create a policy as this email has an existing contact or policy.',
                                'error'
                            );
                        }
                    } else {
                        if (this.cmpSource == 'comm') {
                            this.showToastmethod(
                                'error',
                                'Incorrect data has been provided as an error during the creation of the policy.',
                                'Error Notification'
                            );
                        } else {
                            this.showToastEvent(
                                'Error Notification',
                                'Incorrect data has been provided as an error during the creation of the policy.',
                                'error'
                            );
                        }
                    }
                }
            })
            .catch((error) => {
                console.log('error on policy', error);
                this.booleanVar.isLoading = false;
                this.showToastmethod(
                    'error',
                    error?.body?.message ||
                        'An unexpected error occurred while creating the policy. Please try again.',
                    'Policy Error'
                );
            });
    }

    createPolicyFromLead(isCardPayment) {
        createPolicy({
            leadId: this.leadId,
            needPortalAccess: this.booleanVar.portalAccessYes,
            isCardPayment: isCardPayment
        })
            .then((result) => {
                console.log('result 2', result);
                if (this.booleanVar.emailService === false) {
                } else {
                    getPolicyData({ policyId: result })
                        .then((res) => {
                            if (res === 'Success') {
                                console.log('Pdf gen');
                            } else {
                                console.log('Pdf gen', res);
                            }
                        })
                        .catch((err) => {
                            console.log('getPolicyData error', err);
                            this.showToastmethod(
                                'warning',
                                err?.body?.message ||
                                    'Could not generate policy PDF. Please try again.',
                                'PDF Generation Warning'
                            );
                        });
                    emailServices({ policyId: result, emailService: this.booleanVar.emailService })
                        .then((nresult) => {
                            console.log(nresult);
                        })
                        .catch((nerr) => {
                            console.log(nerr);
                            this.showToastmethod(
                                'warning',
                                nerr?.body?.message || 'Email notification could not be sent.',
                                'Email Warning'
                            );
                        });
                }
                this.booleanVar.isLoading = false;
                if (result != 'Error 1' && result != 'Error 2') {
                    if (this.cmpSource == 'comm') {
                        this.showToastmethod(
                            'success',
                            'Policy has been successfully created.',
                            'Policy Creation Notification'
                        );
                    } else {
                        this.showToastEvent(
                            'Policy Creation Notification',
                            'Policy has been successfully created.',
                            'success'
                        );
                    }
                    this.proceedTofinalStep(result);
                } else {
                    if (result == 'Error 1') {
                        if (this.cmpSource == 'comm') {
                            this.showToastmethod(
                                'error',
                                'Unable to create a policy as this email has an existing contact or policy.',
                                'Error Notification'
                            );
                        } else {
                            this.showToastEvent(
                                'Error Notification',
                                'Unable to create a policy as this email has an existing contact or policy.',
                                'error'
                            );
                        }
                    } else {
                        if (this.cmpSource == 'comm') {
                            this.showToastmethod(
                                'error',
                                'Incorrect data has been provided as an error during the creation of the policy.',
                                'Error Notification'
                            );
                        } else {
                            this.showToastEvent(
                                'Error Notification',
                                'Incorrect data has been provided as an error during the creation of the policy.',
                                'error'
                            );
                        }
                    }
                }
            })
            .catch((error) => {
                console.log('error', error);
                this.booleanVar.isLoading = false;
                this.showToastmethod(
                    'error',
                    error?.body?.message ||
                        'An unexpected error occurred while creating the policy. Please try again.',
                    'Policy Error'
                );
            });
    }

    handlePaymentInputChange = (event) => {
        this.paymentDetails[event.target.name] = event.target.value;
        this.paymentDetails['Payment_Type__c'] = 'Card';

        if (event.target?.name == 'paymentCountrycmbx') {
            this.paymentDetails = { ...this.paymentDetails, ['Country__c']: event.target.value };
            if (event.target.value == 'Other') {
                this.otherCountrypayment = true;
            } else {
                this.otherCountrypayment = false;
            }
        }

        if (event.target.name == 'Payment_Type__c') {
            if (event.target.value == 'Cash') {
                this.booleanVar.showCardPayment = false;
            } else if (event.target.value == 'Card') {
                this.booleanVar.showCardPayment = true;
            }
        }

        if (event.target?.name == 'year') {
            if (event.target?.value == this.currentDate.getFullYear()) {
                this.startMonthNumber = this.currentDate.getMonth() + 1;
                this.months = [];
                this.template.querySelectorAll('c-buho_input').forEach((each) => {
                    if (each.name == 'month') {
                        each.value = '';
                    }
                });
                this.MM;
            } else {
                this.months = [];
                this.startMonthNumber = 1;
                this.MM;
            }
        }

        if (event.target.name == 'month' || event.target.name == 'year') {
            if (event.target.value != '') {
                this.template.querySelector('[data-id="month"]').required = true;
                this.template.querySelector('[data-id="month"]').className = 'validate';
                this.template.querySelector('[data-id="year"]').required = true;
                this.template.querySelector('[data-id="year"]').className = 'validate';
            } else {
                this.template.querySelector('[data-id="month"]').required = false;
                this.template.querySelector('[data-id="month"]').className = '';
                this.template.querySelector('[data-id="year"]').required = false;
                this.template.querySelector('[data-id="year"]').className = '';
            }
        }

        if (event.target.name == 'cardNumber') {
            const rawNumber = event.target.value.replace(/ /g, '');
            const formattedNumber = this.formatCreditCardNumber(rawNumber);
            this.formattedCreditCardNumber = formattedNumber;
            let cardNum = this.template.querySelector('[data-id="cardNumber"]');
            let expMonth = this.template.querySelector('[data-id="month"]');
            let expYear = this.template.querySelector('[data-id="year"]');
            this.paymentDetails = { ...this.paymentDetails, ['cardNumber']: rawNumber };
            if (event.target.value != '') {
                cardNum.required = true;
                expMonth.required = true;
                expYear.required = true;

                cardNum.className = 'validate';
                expMonth.className = 'validate';
                expYear.className = 'validate';
            } else {
                cardNum.required = false;
                expMonth.required = false;
                expYear.required = false;

                cardNum.className = '';
                expMonth.className = '';
                expYear.className = '';
            }
        }
    };

    timeToMilliseconds(timeStr) {
        // Split the time string into [hours, minutes, seconds.milliseconds]
        let timeParts = timeStr.split(':'); // ["04", "45", "00.000"]

        let hours = parseInt(timeParts[0]); // Convert hours to integer
        let minutes = parseInt(timeParts[1]); // Convert minutes to integer

        // Split the seconds and milliseconds part if milliseconds exist
        let secondsParts = timeParts[2].split('.'); // ["00", "000"]
        console.log('Secong part', JSON.stringify(secondsParts));
        let seconds = parseInt(secondsParts[0]); // Convert seconds to integer

        // Calculate total milliseconds
        let totalMilliseconds =
            hours * 60 * 60 * 1000 + // hours to milliseconds
            minutes * 60 * 1000 + // minutes to milliseconds
            seconds * 1000; // add remaining milliseconds

        return totalMilliseconds;
    }

    handleStartTimeValidation(event) {
        // 17 Sep

        let apexdata = JSON.parse(JSON.stringify(this.apextimedata));
        console.log('Apex data', apexdata);
        let data = event.target.value;
        console.log(JSON.stringify(data));
        let converted = this.timeToMilliseconds(data);
        console.log('converted', converted);
        let timeinapex = JSON.parse(JSON.stringify(apexdata.nextMin));
        console.log('Time in apex', timeinapex);
        let timedataconverted = this.timeToMilliseconds(timeinapex);
        console.log('converted', timedataconverted);

        let customerDate = this.customerData.Start_Date_for_Coverage__c;
        let dateParts = customerDate.split('-');
        let localDate = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);

        let datefromapex = apexdata.dtPST.split(' ')[0];
        let apexdateparts = datefromapex.split('-');
        let todaycheck = new Date(apexdateparts[0], apexdateparts[1] - 1, apexdateparts[2]);

        let currentterm = this.customerData.Term__c;
        console.log('Term in time validation', currentterm);

        console.log('Selected date', localDate);
        console.log('Date from apex', todaycheck);

        if (
            localDate.getFullYear() === todaycheck.getFullYear() &&
            localDate.getMonth() === todaycheck.getMonth() &&
            localDate.getDate() === todaycheck.getDate() &&
            this.cmpSource == 'comm' &&
            currentterm == 'Daily'
        ) {
            if (converted < timedataconverted && this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'Start time is already passed. Please select the next time slot.',
                    'Wrong time selected'
                );
                return false;
            }
            return true;
        }
        return true;
    }

    handleGenerateQuote = async () => {
        console.log('All data', this.customerData);

        this.booleanVar.isLoading = true;
        this.booleanVar.isQuoteLoaded = false;

        if (this.addedTowed && this.addedTowed.length > 0) {
            this.booleanVar.isRequiredTowed = false;
        } else {
            this.booleanVar.isRequiredTowed = true;
        }

        //26 Aug Update

        const selectedStartDate = new Date(this.customerData.Start_Date_for_Coverage__c);
        const selectedEndDate = new Date(this.customerData.End_Date_for_Coverage__c);
        if (selectedEndDate <= selectedStartDate) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'The selected date is earlier than the Start Date for Coverage.',
                    'Wrong date selected'
                );
            } else {
                this.showToastEvent(
                    'Wrong date selected',
                    'The selected date is earlier than the Start Date for Coverage.',
                    'error'
                );
            }
            return;
        }

        const mockEvent = {
            target: {
                value: this.trackVar.startTime
            }
        };

        // 17 Sep
        if (this.cmpSource == 'comm' && !this.handleStartTimeValidation(mockEvent)) {
            return;
        }

        let status = this.isInputValid('.quoteValidate');
        if (
            (this.booleanVar.isTowing == true && this.addedTowed && this.addedTowed.length > 0) ||
            this.booleanVar.isTowing == false
        ) {
            if (status) {
                this.booleanVar.isTowingCheckbox = false;
                this.booleanVar.isportalAccessHide = false;
                this.quoteDetails = this.customerData;

                let date1 = new Date(this.quoteDetails.Start_Date_for_Coverage__c);
                let date2 = new Date(this.quoteDetails.End_Date_for_Coverage__c);
                const diffTime = Math.abs(date2 - date1);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                if (diffDays == 0) {
                    if (this.cmpSource == 'comm') {
                        this.showToastmethod(
                            'error',
                            'Please make sure policy term should have minimum of 1 day duration.',
                            'Error'
                        );
                    } else {
                        this.showToastEvent(
                            'Error',
                            'Please make sure policy term should have minimum of 1 day duration.',
                            'error'
                        );
                    }
                    return;
                }

                await this.generateQuickQuote(this.quoteDetails);
                // if(this.agentFee != null){
                //     this.trackVar.qualitasRatevalue = parseFloat(this.allQuoteDeatils.qualitasQuote.rateValue) + parseFloat(this.agentFee);
                //     this.trackVar.chubbRateValue = parseFloat(this.allQuoteDeatils.chubbQuote.rateValue) + parseFloat(this.agentFee);
                //     this.trackVar.mapfreRatevalue = parseFloat(this.allQuoteDeatils.mapfreQuote.rateValue) + parseFloat(this.agentFee);
                // }
            } else {
                console.log('Erorrrrrr->>>>>');
                if (this.cmpSource == 'comm') {
                    this.showToastmethod(
                        'error',
                        'Fill in all the required fields.',
                        'Fill out the fields'
                    );
                } else {
                    this.showToastEvent(
                        'Fill out the fields',
                        'Fill in all the required fields.',
                        'error'
                    );
                }
            }
        } else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'Please add the towed unit; otherwise, make the towing unchecked.',
                    'Add Towed unit'
                );
            } else {
                this.showToastEvent(
                    'Add Towed unit',
                    'Please add the towed unit; otherwise, make the towing unchecked.',
                    'error'
                );
            }
        }

        this.booleanVar.isLoading = false;
        this.booleanVar.isQuoteLoaded = true;
    };

    convertFinalQuoteToArray(finalQuote) {
        console.log('OUTPUT : convertFinalQuoteToArray finalQuote', finalQuote);
        const getBoolean = (value) => value === 'Yes';

        const result = [
            {
                userDetails: {
                    Company: '',
                    Email: '',
                    FirstName: finalQuote.FirstName || '',
                    Phone: '',
                    LastName: finalQuote.LastName || '',
                    Id: finalQuote.Id || this.leadId
                }
            },
            {
                vehicleDetails: {
                    is_the_vehicle_used_for_business_purpose__c: getBoolean(
                        finalQuote.Is_the_vehicle_used_for_business_purpose__c ||
                            finalQuote.Vehicle_used_for_Business_Purposes
                    ),
                    is_there_a_driver_under_21__c: getBoolean(
                        finalQuote.Is_there_a_driver_under_21__c ||
                            finalQuote.Is_there_a_driver_under_21
                    ),
                    Is_this_a_Rental_Vehicle__c: getBoolean(
                        finalQuote.Is_this_a_Rental_Vehicle__c || finalQuote.Is_Rental_Vehicle
                    ),
                    salvage_vehicle__c: getBoolean(
                        finalQuote.Salvage_Vehicle__c || finalQuote.Salvage_Vehicle
                    ),
                    Coverage__c: finalQuote?.Coverage__c !== 'Liability' ? 'Complete' : 'Liability',
                    isTowing: getBoolean(finalQuote.Is_towing__c || finalQuote.Is_Towing),
                    Electric_Hybrid__c: finalQuote?.Electric_Hybrid__c,
                    towunits: finalQuote.towedUnits || [],
                    Liability__c: finalQuote.Liability || '500,000',
                    Medical__c: finalQuote.Medical || '10,000/50,000',
                    Year__c: finalQuote.Year__c || '',
                    Make: finalQuote.Make || '',
                    Model: finalQuote.Model || '',
                    Value__c: finalQuote.Value__c || '',
                    Make__c: finalQuote.Make__c || finalQuote.Make || '',
                    Model__c: finalQuote.Model__c || finalQuote.Model || '',
                    Vehicle_sub_type__c:
                        finalQuote.Vehicle_sub_type__c ||
                        finalQuote.Vehicle_Sub_Type ||
                        'Automobile-Van-Minivan'
                }
            },
            {
                termOption: {
                    Term__c: finalQuote.Term__c || '',
                    Start_Date_for_Coverage__c:
                        finalQuote.Start_Date_for_Coverage__c ||
                        finalQuote.Start_Date_for_Coverage ||
                        '',
                    Start_Time__c: finalQuote.Start_Time__c || '',
                    End_Date_for_Coverage__c:
                        finalQuote.End_Date_for_Coverage__c ||
                        finalQuote.End_Date_for_Coverage ||
                        '',
                    End_Time__c: finalQuote.End_Time__c || '',
                    Gold__c: true,
                    Max__c: true,
                    Platinum__c: true
                }
            },
            {
                territory: {
                    region: finalQuote.territory || finalQuote.Territory || ''
                }
            }
        ];
        return result;
    }z

    async generateQuickQuote(quoteDetails) {
        this.booleanVar.isQuoteLoaded = false;
        // JSON Data for New Lead apex class....
        let newLeadData = { ...this.quoteDetails, ['towedUnits']: this.addedTowed };
        // Data for quote apex class....
        let data;
        // Data for quote apex class....
        if (this.booleanVar.isNorthbound === false) {
            this.allQuote = {
                Policy_Type_picklist: quoteDetails?.Policy_Type__c,
                // Vehicle_Type: quoteDetails?.Policy_Type__c == 'Automobile' ? 'Car/Truck/Auto' : quoteDetails?.Policy_Type__c,
                Vehicle_Type: 'Automobile-Van-Minivan',
                Territory: quoteDetails?.territory,
                Is_Towing: quoteDetails?.Is_towing__c,
                Is_there_a_driver_under_21: quoteDetails?.Is_there_a_driver_under_21__c,
                Salvage_Vehicle: quoteDetails?.Salvage_Vehicle__c,
                Vehicle_used_for_Business_Purposes:
                    quoteDetails?.Is_the_vehicle_used_for_business_purpose__c,
                Is_Rental_Vehicle: quoteDetails?.Is_this_a_Rental_Vehicle__c,
                Vehicle_Sub_Type: quoteDetails?.Vehicle_sub_type__c,
                Vehicle_Value: quoteDetails?.Value__c,
                Start_Date_for_Coverage: quoteDetails?.Start_Date_for_Coverage__c,
                End_Date_for_Coverage: quoteDetails?.End_Date_for_Coverage__c,
                Liability: quoteDetails?.Liability__c ? quoteDetails?.Liability__c : '500,000',
                Liability_Type: quoteDetails?.Coverage__c ? quoteDetails?.Coverage__c : 'Complete',
                Medical: quoteDetails?.Medical__c ? quoteDetails?.Medical__c : '10,000/50,000',
                towedUnits: this.addedTowed
            };
        }

        const additionalFields = {};
        for (const key in quoteDetails) {
            if (!this.allQuote.hasOwnProperty(key)) {
                additionalFields[key] = quoteDetails[key];
            }
        }

        // update Contact details.....
        if (this.actionType === 'newPolicyFromContact') {
            await this.handleAffiliateMapping();
            await updateContactDetails({
                Istowing: this.customerData?.Is_towing__c == 'Yes' ? true : false,
                contactId: this.contactId,
                termOptions: '',
                driverDetails: '',
                termsAlert: '',
                towedlistJSON: JSON.stringify(this.addedTowed),
                WatercraftDetails: this.allQuote.Policy_Type_picklist == 'Watercraft' ? '' : '', // update watercraftDeatils JSON ...................................................
                vehicledetails:
                    this.allQuote.Policy_Type_picklist != 'Watercraft'
                        ? JSON.stringify(this.fetchVehicleData())
                        : '',
                quoteDetails: JSON.stringify(this.fetchQuoteData())
            })
                .then((result) => {
                    console.log('result', result);
                    data = result;
                    this.booleanVar.isLoading = false;
                })
                .catch((error) => {
                    console.log('updateContactDetails error', error);
                    this.booleanVar.isLoading = false;
                    this.showToastmethod(
                        'error',
                        error?.body?.message ||
                            'Failed to save quote details for contact. Please try again.',
                        'Save Error'
                    );
                });
        } else {
            console.log('Calling saveLeadDetailsintodApex method');
            // Saving Data in Lead......
            data = await this.saveLeadDetailsintoApex(
                JSON.stringify(this.fetchLeadData()),
                JSON.stringify(this.fetchQuoteData()),
                JSON.stringify(this.fetchVehicleData()),
                JSON.stringify(this.addedTowed)
            );
            console.log('OUTPUT : 123fldskj', data);
        }

        console.log('OUTPUT : data', data);
        if (data === 'success') {
            const finalQuote = {
                ...this.allQuote,
                ...additionalFields,
                ...{ id: this.leadId },
                ...{ Agent_Fee__c: this.agentFee }
            };
            console.log('OUTPUT : finalQuote', finalQuote);
            const formattedData = this.convertFinalQuoteToArray(finalQuote);

            this.payload = formattedData;
            console.log('OUTPUT : formatted quote data: ', this.payload);
            this.booleanVar.isLoading = false;
            this.activeSectionName = 'quote';
            let openAccordion = this.template.querySelector('.agentDashboard');
            openAccordion.activeSectionName = this.activeSectionName;
            this.booleanVar = { ...this.booleanVar, isQuoteLoaded: true };

            this.booleanVar.isLoading = false;
        }
        console.log('OUTPUT : 11111111123fldskj');
        return true;

        if (this.booleanVar.isNorthbound === true) {
            let vehicleAge = new Date().getFullYear() - parseInt(quoteDetails.Year__c);

            if (vehicleAge < 1) {
                vehicleAge = 1;
            }

            let driverAge;
            driverAge = new Date().getFullYear() - parseInt(quoteDetails.Dob__c);

            if (driverAge < 16 || driverAge > 85) {
                // show error message;
                if (this.cmpSource == 'comm') {
                    this.showToastmethod(
                        'error',
                        'Driver age should be between 16 & 85. Change date of birth',
                        'Driver Age'
                    );
                } else {
                    this.showToastEvent(
                        'Driver Age',
                        'Driver age should be between 16 & 85. Change date of birth',
                        'error'
                    );
                }
                return true;
            }

            this.allQuote = {
                Policy_Type_picklist: 'Northbound',
                Vehicle_Type: quoteDetails?.Vehicle_sub_type__c,
                Is_Towing: quoteDetails?.Is_towing__c,
                Is_there_a_driver_under_21: quoteDetails?.Is_there_a_driver_under_21__c,
                Salvage_Vehicle: quoteDetails?.Salvage_Vehicle__c,
                Vehicle_used_for_Business_Purposes:
                    quoteDetails?.Is_the_vehicle_used_for_business_purpose__c,
                Is_Rental_Vehicle: quoteDetails?.Is_this_a_Rental_Vehicle__c,
                Vehicle_Sub_Type: quoteDetails?.Vehicle_sub_type__c,
                Vehicle_Value: quoteDetails?.Value__c,
                vehicle_Age: JSON.stringify(vehicleAge),
                driver_Age: JSON.stringify(driverAge),
                Start_Date_for_Coverage: quoteDetails?.Start_Date_for_Coverage__c,
                End_Date_for_Coverage: quoteDetails?.End_Date_for_Coverage__c,
                Liability_Type: 'Liability',
                Medical: '$5,000/$25,000',
                towedUnits: this.addedTowed
            };
        }

        console.log('allQuote', this.allQuote);

        const vehicleValue = parseInt(this.allQuote.Vehicle_Value, 10);

        if (this.allQuote.Vehicle_Type == 'Car/Truck/Auto' && vehicleValue > 119000) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'Please check your Vehicle value must be less than 119000.',
                    'Vehicle Value are not correct!'
                );
            } else {
                this.showToastEvent(
                    'Vehicle Value are not correct!',
                    'Please check your Vehicle value must be less than 119000.',
                    'error'
                );
            }
            return true;
        } else if (this.allQuote.Vehicle_Type == 'RV' && vehicleValue > 200000) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'Please check your Vehicle value must be less than 200000.',
                    'Vehicle Value are not correct!'
                );
            } else {
                this.showToastEvent(
                    'Vehicle Value are not correct!',
                    'Please check your Vehicle value must be less than 200000.',
                    'error'
                );
            }
            return true;
        } else if (
            this.allQuote.Vehicle_Type == 'Motorcycle/Street Legal ATV' &&
            vehicleValue > 100000
        ) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod(
                    'error',
                    'Please check your Vehicle value must be less than 100000.',
                    'Vehicle Value are not correct!'
                );
            } else {
                this.showToastEvent(
                    'Vehicle Value are not correct!',
                    'Please check your Vehicle value must be less than 100000.',
                    'error'
                );
            }
            return true;
        }

        this.booleanVar.isLoading = true;

        // Southbound flow........
        if (this.booleanVar.isNorthbound === false) {
            console.log('Request Body', this.allQuote);
            console.log('Qualitas Liability', this.qualitasLiability);
            console.log('Chubb Liability', this.chubbLiability);
            console.log('Mapre Liability', this.mapfreLiability);
            console.log('Qualitas medical ', this.qualitasMedical);
            console.log('Chubbs medical ', this.chubbMedical);
            console.log('Mapre medical ', this.mapfreMedical);
            await getQuote({
                requestBody: JSON.stringify(this.allQuote),
                qualitasLiability: this.qualitasLiability,
                chubbLiability: this.chubbLiability,
                mapfreLiability: this.mapfreLiability,
                qualitasMedical: this.qualitasMedical,
                chubbMedical: this.chubbMedical,
                mapfreMedical: this.mapfreMedical
            })
                .then((result) => {
                    if (result) {
                        this.allQuoteDeatils = JSON.parse(result);
                        console.log('res-->', JSON.parse(result));
                    } else {
                        if (this.cmpSource == 'comm') {
                            this.showToastmethod(
                                'error',
                                'Please fill out all the required fields.',
                                'Incorrect Data'
                            );
                        } else {
                            this.showToastEvent(
                                'Incorrect Data',
                                'Please check the data and try again!',
                                'error'
                            );
                        }
                        this.booleanVar.isLoading = false;
                    }
                })
                .catch((error) => {
                    console.log('getQuote error', error);
                    this.booleanVar.isLoading = false;
                    this.showToastmethod(
                        'error',
                        error?.body?.message ||
                            'Failed to retrieve quote. Please check your inputs and try again.',
                        'Quote Error'
                    );
                });

            await this.fetchCoverageQuote();

            // Updating track variables....
            this.booleanVar.showQualitas = this.allQuoteDeatils.qualitasQuote.showQualitas;
            this.booleanVar.showChubb = this.allQuoteDeatils.chubbQuote.showChubb;
            this.booleanVar.showMapfre = this.allQuoteDeatils.mapfreQuote.showMapfre;

            if (quoteDetails.Policy_Type_picklist == 'Automobile-Van-Minivan') {
                this.booleanVar.isAutomobile = true;
            } else {
                this.booleanVar.isAutomobile = false;
            }
            if (quoteDetails.Policy_Type_picklist == 'Motorcycle/Street Legal ATV') {
                this.booleanVar.motorcyclePolicy = true;
            } else {
                this.booleanVar.motorcyclePolicy = false;
            }

            this.trackVar.qualitasRatevalue =
                Number(this.allQuoteDeatils.qualitasQuote.rateValue) + Number(this.agentFee);
            this.trackVar.startDate = quoteDetails?.Start_Date_for_Coverage__c;
            this.trackVar.endDate = quoteDetails?.End_Date_for_Coverage__c;
            //26 Aug Update

            if (quoteDetails.Term__c != 'Daily') {
                this.trackVar.startTime = '00:00:00';
                this.trackVar.endTime = '00:00:00';
            }

            this.trackVar.vehicleValue = quoteDetails?.Value__c;
            this.trackVar.qualitasDays = this.allQuoteDeatils.qualitasQuote.days;
            this.trackVar.chubbDays = this.allQuoteDeatils.chubbQuote.days;
            this.trackVar.chubbRateValue =
                Number(this.allQuoteDeatils.chubbQuote.rateValue) + Number(this.agentFee);
            this.trackVar.mapfreRatevalue =
                Number(this.allQuoteDeatils.mapfreQuote.rateValue) + Number(this.agentFee);
            this.trackVar.mapfreDays = this.allQuoteDeatils.mapfreQuote.days;
            this.trackVar.vehicleType = this.allQuote.Vehicle_Type;
        }

        // Northbound flow......
        if (this.booleanVar.isNorthbound === true) {
            let quote = await getNorthboundQuote({
                requestBody: JSON.stringify(this.allQuote),
                liability: this.showLiability
            });
            this.allQuoteDeatils = JSON.parse(quote);

            await this.fetchNorthBoundCoverageQuote();

            // const resp = await getNorthboundCoverage();
            // console.log(JSON.stringify(resp, null, 4));

            // if (resp.length) {
            //     this.allQuoteDeatils = { ...this.allQuoteDeatils, ...resp[0] };
            // }

            this.booleanVar.showChubb = true;

            this.chubbLiability = this.showLiability;
            this.trackVar.startDate = quoteDetails?.Start_Date_for_Coverage__c;
            this.trackVar.endDate = quoteDetails?.End_Date_for_Coverage__c;
            this.trackVar.startTime = quoteDetails?.Start_Time__c;
            this.trackVar.endTime = quoteDetails?.End_Time__c;
            this.trackVar.vehicleValue = quoteDetails?.Value__c;
            this.trackVar.chubbDays = this.allQuoteDeatils.days;
            this.trackVar.chubbRateValue = this.allQuoteDeatils.rateValue;
            this.trackVar.vehicleType = this.allQuote.Vehicle_Type;
        }

        // update Contact details.....
        if (this.actionType === 'newPolicyFromContact') {
            await this.handleAffiliateMapping();
            await updateContactDetails({
                Istowing: this.customerData?.Is_towing__c == 'Yes' ? true : false,
                contactId: this.contactId,
                termOptions: '',
                driverDetails: '',
                termsAlert: '',
                towedlistJSON: JSON.stringify(this.addedTowed),
                WatercraftDetails: this.allQuote.Policy_Type_picklist == 'Watercraft' ? '' : '', // update watercraftDeatils JSON ...................................................
                vehicledetails:
                    this.allQuote.Policy_Type_picklist != 'Watercraft'
                        ? JSON.stringify(this.fetchVehicleData())
                        : '',
                quoteDetails: JSON.stringify(this.fetchQuoteData())
            })
                .then((result) => {
                    console.log('result', result);
                    this.booleanVar.isLoading = false;
                })
                .catch((error) => {
                    console.log('updateContactDetails error', error);
                    this.booleanVar.isLoading = false;
                    this.showToastmethod(
                        'error',
                        error?.body?.message || 'Failed to save contact details. Please try again.',
                        'Save Error'
                    );
                });
        } else {
            // Saving Data in Lead......
            this.saveLeadDetailsintoApex(
                JSON.stringify(this.fetchLeadData()),
                JSON.stringify(this.fetchQuoteData()),
                JSON.stringify(this.fetchVehicleData()),
                JSON.stringify(this.addedTowed)
            );
        }

        //this.booleanVar.isLoading = false;
        this.activeSectionName = 'quote';
        let openAccordion = this.template.querySelector('.agentDashboard');
        openAccordion.activeSectionName = this.activeSectionName;
    }

    // update Lienholder component details in Customer data...
    updateLienHolderDetails(event) {
        let lienholderDetails = event.detail;
        console.log('IN updateLienHolderDetails lienholderDetails::::', lienholderDetails);
        this.customerData = {
            ...this.customerData,
            ['Is_Lienholder__c']: true,
            ['Lienholder_name__c']: lienholderDetails.Lienholder_name__c,
            ['Lienholder_Street__c']: lienholderDetails.Lienholder_Street__c,
            ['Lienholder_State__c']: lienholderDetails.Lienholder_State__c,
            ['Lienholder_Postal_Code__c']: lienholderDetails.Lienholder_Postal_Code__c,
            ['Lienholder_Phone__c']: lienholderDetails.Lienholder_Phone__c,
            ['Lienholder_Country__c']: lienholderDetails.Lienholder_Country__c,
            ['Lienholder_City__c']: lienholderDetails.Lienholder_City__c
        };

        console.log('this.customerData FROM LINEHOLDER EVENT::: ', this.customerData);
    }
}
