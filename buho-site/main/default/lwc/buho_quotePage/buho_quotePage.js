import { LightningElement, track, api } from 'lwc';
import calculateTotalCoverage from '@salesforce/apex/CalculateCoverage.calculateTotalCoverage';
import getDescriptionAndTitle from '@salesforce/apex/CalculateCoverageTitleAndDescription.getDescriptionAndTitle';
import saveQuoteDetails from '@salesforce/apex/QuoteOptionFlow.saveQuoteDetails';
import getVendors from '@salesforce/apex/QuoteOptionFlow.getVendors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveQuoteRecord from '@salesforce/apex/QuoteOptionFlow.saveQuoteRecord';
import saveQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.saveQuoteRecordData';
import sendEmailQuoteDetails from '@salesforce/apex/Mex_NewLeadProcess.sendEmailQuoteDetails';
import { NavigationMixin } from 'lightning/navigation';
import MAPFRE_LOGO from '@salesforce/resourceUrl/buhoAssets';


export default class Buho_quotePage extends NavigationMixin(LightningElement) {
    @api payload;
    @api pathPrefix;
    @api baseUrl;
    @track results = {};
    @track isDebug = true;
    @track value = 0; // Number input value
    @track activeTab = ''; // Default active tab
    @track stickyClass = 'tabs-container slds-p-top_small';
    @track parentPayloadData;
    @track selectedQuote;
    @track checkedData = {
        "Gold__c": true,
        "Max__c": true,
        "Platinum__c": true
    }
    @track vendorDataList;
    @track userType;
    @track liabilityOnly;
    @track liabilityDisabled = false;
    @track vehicleAge;

    @track coverageData;
    @track coverageList = [];
    @track isDownloadQuote = false;
    @track isEmailSent = false;

    // New properties for updated design
    @track showOtherCompanies = false;
    @track selectedTerm = 'Daily'; // 'single', 'semi-annual', 'annual'

    @track semiAnnualPrice = '322.50';
    @track annualPrice = '445.00';

    // Liability Options
    liabilityOptions = ['100,000', '200,000', '300,000', '500,000', '1,000,000'];
    @track combinedLiabilityValue = this.liabilityOptions[0]; // Default first value

    // Medical Options
    medicalValues = ['2,000/10,000', '3,000/15,000', '4,000/16,000', '5,000/25,000', '10,000/50,000', '15,000/75,000', '20,000/100,000'];
    @track medicalValue = this.medicalValues[0]; // Default first value

    coverageList = [
        {
            image: 'https://www.mexinsurance.com/wp-content/uploads/2023/10/Auto-Insurance-1.png',
            title: 'Medical Payments',
            desc: 'Medical payments for the driver and passengers of your vehicle',
            price: '$100',
        },
        {
            image: 'https://www.mexinsurance.com/wp-content/uploads/2023/10/Auto-Insurance-1.png',
            title: 'Legal Assistance & Bail Bond',
            desc: 'Available 24/7. This limit is equal to the Third Party Liability limit shown above.',
            price: '$100',
        },
    ];
    vendorVsTermVsTotals = [];

    @track companyTotals = []

    termsToCalculate = []

    tabs = [
        {
            id: 'chubb',
            label: 'Chubb',
            total: '',
            content: {
                name: 'Chubb',
                price: '500',
            },
        }
    ];


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

    // Compute the tab properties dynamically
    get computedTabs() {
        const resp = (this.tabs || [])
            .filter((tab) => tab) // Filters out null/undefined values
            .map((tab) => ({
                ...tab,
                isSelected: tab.id === this.activeTab,
                tabIndex: tab.id === this.activeTab ? '0' : '-1',
                class: tab.id === this.activeTab
                    ? 'slds-tabs_default__item slds-is-active'
                    : 'slds-tabs_default__item',
            }));
        console.log('@@@@', JSON.stringify(resp));
        return resp;
    }

    // New getters for updated design
    get mapfreLogo() {
        return MAPFRE_LOGO + '/images/mapfre.png';
    }

    get isMapfreActive() {
        return this.activeTab === 'Mapfre';
    }

    get activeCompanyLabel() {
        const activeCompany = this.tabs?.find(tab => tab?.id === this.activeTab);
        return activeCompany ? activeCompany.label : '';
    }

    get activeCompanyId() {
        return this.activeTab;
    }

    get otherCompaniesList() {
        return Object.keys(this.vendorVsTermVsTotals).filter(company => company !== this.activeTab);
    }

    get showSingleDayTrip() {
        // Show upsell options if the term is "Daily" (Single Trip)
        const termOption = this.payload?.find(item => item.termOption)?.termOption;
        return termOption?.Term__c === 'Daily' && this.dailyPreviewTotal > 0;
    }

    get showSemiAnnualTrip() {
        const termOption = this.payload?.find(item => item.termOption)?.termOption;
        return termOption?.Term__c == 'Daily' && this.semiAnnualPreviewTotal > 0;
    }

    get showAnnualTrip() {
        return this.annualPreviewTotal > 0;
    }

    get singleTripCardClass() {
        return this.selectedTerm === 'Daily' ? 'term-card selected' : 'term-card';
    }

    get semiAnnualCardClass() {
        return this.selectedTerm === 'Semi-Annual' ? 'term-card selected' : 'term-card upsell';
    }

    get annualCardClass() {
        return this.selectedTerm === 'Annual' ? 'term-card selected' : 'term-card upsell';
    }

    get medicalOptions() {
        return this.medicalValues;
    }

    // Disabled States for Liability
    get isMinLiabilityDisabled() {
        return this.combinedLiabilityValue === this.liabilityOptions[0];
    }

    get isMaxLiabilityDisabled() {
        return this.combinedLiabilityValue === this.liabilityOptions[this.liabilityOptions.length - 1];
    }

    // Disabled States for Medical
    get isMinMedicalDisabled() {
        return this.medicalValue === this.medicalValues[0];
    }

    get isMaxMedicalDisabled() {
        return this.medicalValue === this.medicalValues[this.medicalValues.length - 1];
    }

    get activeTabCoverage() {
        const activeCompany = this.tabs.find(tab => tab.id === this.activeTab);
        return activeCompany ? activeCompany.coverageList : [];
    }

    get quotePreviewData() {
        return this.vendorVsTermVsTotals[this.activeTab]?.[this.selectedTerm] || {};
    }

    get annualPreviewTotal() {
        return this.vendorVsTermVsTotals[this.activeTab]?.['Annual']?.total || 0;
    }

    get semiAnnualPreviewTotal() {
        return this.vendorVsTermVsTotals[this.activeTab]?.['Semi-Annual']?.total || 0;
    }

    get dailyPreviewTotal() {
        return this.vendorVsTermVsTotals[this.activeTab]?.['Daily']?.total || 0;
    }


    getCoverageItems(coverage) {
        return Object.values(coverage);
    }

    // New event handlers for updated design
    toggleOtherCompanies() {
        this.showOtherCompanies = !this.showOtherCompanies;
    }

    handleCompanySelect(event) {
        const companyId = event.currentTarget.dataset.companyId;
        // Set the clicked company as active
        this.activeTab = companyId;
        this.evaluateLiabilityConditions();
        this.prepareCoverageList(companyId);
        this.toggleOtherCompanies();

    }

    handleSelectSingleTrip() {
        this.selectedTerm = 'Daily';
    }

    handleSelectSemiAnnual() {
        this.selectedTerm = 'Semi-Annual';
    }

    handleSelectAnnual() {
        this.selectedTerm = 'Annual';
    }

    handleBackNavigation() {
        const navEvent = new CustomEvent('changescreen', {
            detail: {
                direction: 'previous'
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(navEvent);
    }

    // Handle tab click event
    handleTabClick(event) {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        const clickedTabId = event.currentTarget.dataset.tabId;

        // Find the clicked tab and move it to the first position in the array
        const clickedTab = this.tabs.find((tab) => tab.id === clickedTabId);
        const otherTabs = this.tabs.filter((tab) => tab.id !== clickedTabId);

        // Update the tabs order
        this.tabs = [clickedTab, ...otherTabs];

        // Set the clicked tab as active
        this.activeTab = clickedTabId;
        this.evaluateLiabilityConditions();
        this.prepareCoverageList(clickedTabId);

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    handleOpenEngDriveLink(event) {
        const engURL = this.results[this.selectedTerm][this.activeTab].TermAndConditionENG;
        if (engURL) {
            window.open(engURL, '_blank');
        } else {
            if (this.isDebug) console.log('No english URL exist');
        }
    }

    handleOpenSpnDriveLink(event) {
        const spnURL = this.results[this.selectedTerm][this.activeTab].TermAndConditionSPN;
        if (spnURL) {
            window.open(spnURL, '_blank');
        } else {
            if (this.isDebug) console.log('No english URL exist');
        }
    }

    // Handle buy button
    handleBuyBtn(event) {
        const direction = event.currentTarget.dataset.direction; // safer than event.target
        const quoteId = event.currentTarget.dataset.buyId;
        if (this.isDebug) console.log('handleBuyBtn quoteId : ', quoteId);

        this.selectedQuote = { ...this.results[this.selectedTerm][this.activeTab], Vendor: this.activeTab };
        this.isEmailSent = false;
        this.isDownloadQuote = false;
        // Create an event that will work with parent's event.target.dataset.direction
        const navEvent = new CustomEvent('changescreen', {
            detail: {
                direction: direction // Pass direction in detail
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(navEvent);
        if (this.isDebug) console.log('Selected Quote: ', JSON.stringify(this.selectedQuote));

    }


    handleEmailandDownloadQuote(event) {
        const direction = event.currentTarget.dataset.direction;
        if (event.currentTarget.dataset.sendEmail == 'true') {
            this.isEmailSent = true;
            this.isDownloadQuote = false;
        }
        else {
            this.isDownloadQuote = true;
            this.isEmailSent = false;
        }
        console.log('Is Email Sent :: ' + this.isEmailSent);
        console.log('Is Download quote :: ' + this.isDownloadQuote);
        const quoteId = event.currentTarget.dataset.buyId;
        if (this.isDebug) console.log('handleBuyBtn quoteId : ', quoteId);

        this.selectedQuote = { ...this.results[this.selectedTerm][this.activeTab], Vendor: this.activeTab }

        if (this.isDebug) console.log('Selected Quote: ', JSON.stringify(this.selectedQuote));
        this.getData();

    }

    // Handle the change in the number input field
    handleInputChange(event) {
        const newValue = event.target.value;
        if (event?.detail?.name === 'Gold__c') {
            const { name, checked, type } = event.detail;
            this.checkedData = { ...this.checkedData, [name]: checked };
            if (this.isDebug) console.log(`🔄 Input Changed: ${name} | Checked: ${checked} | Type: ${type}`);
            this.handleGoldUpdate(checked);
        }
        if (event?.detail?.name === 'Max__c') {
            const { name, checked, type } = event.detail;
            this.checkedData = { ...this.checkedData, [name]: checked };
            if (this.isDebug) console.log(`🔄 Input Changed: ${name} | Checked: ${checked} | Type: ${type}`);
            this.handleMaxUpdate(checked);
        }

        if (event?.detail?.name === 'Coverage__c') {
            const { name, checked, type } = event.detail;
            this.checkedData = { ...this.checkedData, [name]: checked };
            if (this.isDebug) console.log(`🔄 Input Changed: ${name} | Checked: ${checked} | Type: ${type}`);
            this.handleLiabilityOnly(checked);
        }

        if (!isNaN(newValue)) {
            this.value = parseInt(newValue, 10);
        }
    }


    handleLiabilityOnly(isChecked) {
        if (!this.payload || !Array.isArray(this.payload)) return;

        this.liabilityOnly = isChecked;

        const vehicleOptionIndex = this.payload.findIndex(item => item.hasOwnProperty('vehicleDetails'));
        if (vehicleOptionIndex === -1) return;

        let updatedPayload = JSON.parse(JSON.stringify(this.payload));

        updatedPayload[vehicleOptionIndex].vehicleDetails.Coverage__c = isChecked ? 'Liability' : 'Complete';

        this.dispatchPayloadUpdate('vehicleDetails', {
            Coverage__c: isChecked ? 'Liability' : 'Complete'
        });

        const termOptionIndex = this.payload.findIndex(item => item.hasOwnProperty('termOption'));
        if (termOptionIndex !== -1) {
            // 🔹 Si Liability está activo, poner Max y Gold en false
            updatedPayload[termOptionIndex].termOption.Max__c = isChecked ? false : this.checkedData.Max__c;
            updatedPayload[termOptionIndex].termOption.Gold__c = isChecked ? false : this.checkedData.Gold__c;

            this.dispatchPayloadUpdate('termOption', {
                Max__c: isChecked ? false : this.checkedData.Max__c,
                Gold__c: isChecked ? false : this.checkedData.Gold__c
            });

            // Actualizar estado visual (checkbox marcado o no)
            this.checkedData = {
                ...this.checkedData,
                Max__c: isChecked ? false : this.checkedData.Max__c,
                Gold__c: isChecked ? false : this.checkedData.Gold__c
            };
        }

        // 🔹 Clases CSS para deshabilitar visualmente
        this.goldClass = `slds-size_1-of-1 slds-medium-size_4-of-12 slds-large-size_4-of-12 slds-p-around_small ${isChecked ? 'disabled-option' : ''}`;
        this.maxClass = `slds-size_1-of-1 slds-medium-size_4-of-12 slds-large-size_4-of-12 slds-p-around_small ${isChecked ? 'disabled-option' : ''}`;

        this.payload = updatedPayload;

        this.getQuote();
    }


    //Update the payload based on after vehicle liabilty Update
    dispatchPayloadUpdate(key, data) {
        const updateEvent = new CustomEvent('payloadupdate', {
            detail: {
                updates: {
                    [key]: {
                        ...data // Spread the provided data
                    }
                }
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(updateEvent);
    }

    handleMaxUpdate(isChecked) {
        if (!this.payload || !Array.isArray(this.payload)) {
            if (this.isDebug) console.error('Payload is undefined or not an array');
            return;
        }

        const termOptionIndex = this.payload.findIndex(item => item.hasOwnProperty('termOption'));

        if (termOptionIndex === -1) {
            if (this.isDebug) console.error('vehicleDetails object not found in payload');
            return;
        }

        if (this.isDebug) console.log('Before Update:', JSON.stringify(this.payload[termOptionIndex], null, 2));

        this.dispatchPayloadUpdate('termOption', {
            Max__c: isChecked
        });

        //Clone the entire payload for reactivity
        let updatedPayload = JSON.parse(JSON.stringify(this.payload));

        //Ensure vehicleDetails exists
        if (!updatedPayload[termOptionIndex].termOption) {
            if (this.isDebug) console.error('Term Option is undefined');
            return;
        }

        // Update Liability__c safely
        updatedPayload[termOptionIndex].termOption.Max__c = isChecked;

        this.payload = updatedPayload;

        this.getQuote();
    }

    handleGoldUpdate(isChecked) {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (!this.payload || !Array.isArray(this.payload)) {
            if (this.isDebug) console.error('Payload is undefined or not an array');
            return;
        }

        const termOptionIndex = this.payload.findIndex(item => item.hasOwnProperty('termOption'));

        if (termOptionIndex === -1) {
            if (this.isDebug) console.error('vehicleDetails object not found in payload');
            return;
        }

        this.dispatchPayloadUpdate('termOption', {
            Gold__c: isChecked
        });

        if (this.isDebug) console.log('Before Update:', JSON.stringify(this.payload[termOptionIndex], null, 2));

        //Clone the entire payload for reactivity
        let updatedPayload = JSON.parse(JSON.stringify(this.payload));

        //Ensure vehicleDetails exists
        if (!updatedPayload[termOptionIndex].termOption) {
            if (this.isDebug) console.error('Term Option is undefined');
            return;
        }

        // Update Liability__c safely
        updatedPayload[termOptionIndex].termOption.Gold__c = isChecked;

        this.payload = updatedPayload;

        if (this.isDebug) console.log('After Update:', JSON.stringify(this.payload[termOptionIndex], null, 2));
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        //Update the Quote based on new data
        this.getQuote();
    }

    handlePlatinumUpdate(isChecked) {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (!this.payload || !Array.isArray(this.payload)) {
            if (this.isDebug) console.error('Payload is undefined or not an array');
            return;
        }

        const termOptionIndex = this.payload.findIndex(item => item.hasOwnProperty('termOption'));

        if (termOptionIndex === -1) {
            if (this.isDebug) console.error('vehicleDetails object not found in payload');
            return;
        }

        this.dispatchPayloadUpdate('termOption', {
            Platinum__c: isChecked
        });

        if (this.isDebug) console.log('Before Update:', JSON.stringify(this.payload[termOptionIndex], null, 2));

        //Clone the entire payload for reactivity
        let updatedPayload = JSON.parse(JSON.stringify(this.payload));

        //Ensure vehicleDetails exists
        if (!updatedPayload[termOptionIndex].termOption) {
            if (this.isDebug) console.error('Term Option is undefined');
            return;
        }

        // Update Liability__c safely
        updatedPayload[termOptionIndex].termOption.Platinum__c = isChecked;

        this.payload = updatedPayload;

        if (this.isDebug) console.log('After Update:', JSON.stringify(this.payload[termOptionIndex], null, 2));

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));

        //Update the Quote based on new data
        this.getQuote();
    }

    handleCombinedLiabilityChange = (event) => {

        const newValue = event.target.value;
        if (!isNaN(newValue)) {
            this.combinedLiabilityValue = parseInt(newValue, 10);
        }
    }

    // Handle dropdown changes
    handleLiabilityChange(event) {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));

        this.combinedLiabilityValue = event.detail.value;
        this.dispatchPayloadUpdate('vehicleDetails', {
            Liability__c: this.combinedLiabilityValue
        });

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        this.updateLiabilityInPayload();
    }

    handleMedicalChange(event) {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));

        this.medicalValue = event.detail.value;
        this.dispatchPayloadUpdate('vehicleDetails', {
            Medical__c: this.medicalValue
        });

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        this.updateMedicalInPayload();
    }

    // Increment and Decrement for Liability
    incrementLiability() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));


        let currentIndex = this.liabilityOptions.indexOf(this.combinedLiabilityValue);
        if (currentIndex < this.liabilityOptions.length - 1) {
            this.combinedLiabilityValue = this.liabilityOptions[currentIndex + 1];
            this.dispatchPayloadUpdate('vehicleDetails', {
                Liability__c: this.combinedLiabilityValue
            });

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            this.updateLiabilityInPayload();
        }
    }

    decrementLiability() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let currentIndex = this.liabilityOptions.indexOf(this.combinedLiabilityValue);
        if (currentIndex > 0) {
            this.combinedLiabilityValue = this.liabilityOptions[currentIndex - 1];
            this.dispatchPayloadUpdate('vehicleDetails', {
                Liability__c: this.combinedLiabilityValue
            });

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            this.updateLiabilityInPayload();

        }
    }

    updateLiabilityInPayload() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (!this.payload || !Array.isArray(this.payload)) {
            if (this.isDebug) console.error('Payload is undefined or not an array');
            return;
        }

        const vehicleDetailsIndex = this.payload.findIndex(item => item.hasOwnProperty('vehicleDetails'));

        if (vehicleDetailsIndex === -1) {
            if (this.isDebug) console.error('vehicleDetails object not found in payload');
            return;
        }

        if (this.isDebug) console.log('Before Update:', JSON.stringify(this.payload[vehicleDetailsIndex], null, 2));

        //Clone the entire payload for reactivity
        let updatedPayload = JSON.parse(JSON.stringify(this.payload));

        //Ensure vehicleDetails exists
        if (!updatedPayload[vehicleDetailsIndex].vehicleDetails) {
            if (this.isDebug) console.error('vehicleDetails is undefined');
            return;
        }

        // Update Liability__c safely
        updatedPayload[vehicleDetailsIndex].vehicleDetails.Liability__c = this.combinedLiabilityValue;
        this.payload = updatedPayload;

        if (this.isDebug) console.log('After Update:', JSON.stringify(this.payload[vehicleDetailsIndex], null, 2));

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        //Update the Quote based on new data
        this.getQuote();
    }

    // Increment and Decrement for Medical
    incrementMedical() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let currentIndex = this.medicalValues.indexOf(this.medicalValue);
        if (currentIndex < this.medicalValues.length - 1) {
            this.medicalValue = this.medicalValues[currentIndex + 1];
            this.dispatchPayloadUpdate('vehicleDetails', {
                Medical__c: this.medicalValue
            });

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            this.updateMedicalInPayload();

        }
    }

    decrementMedical() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let currentIndex = this.medicalValues.indexOf(this.medicalValue);
        if (currentIndex > 0) {
            this.medicalValue = this.medicalValues[currentIndex - 1];
            this.dispatchPayloadUpdate('vehicleDetails', {
                Medical__c: this.medicalValue
            });

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            this.updateMedicalInPayload();

        }
    }

    updateMedicalInPayload() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (!this.payload || !Array.isArray(this.payload)) {
            if (this.isDebug) console.error('Payload is undefined or not an array');
            return;
        }

        const vehicleDetailsIndex = this.payload.findIndex(item => item.hasOwnProperty('vehicleDetails'));

        if (vehicleDetailsIndex === -1) {
            if (this.isDebug) console.error('vehicleDetails object not found in payload');
            return;
        }

        if (this.isDebug) console.log('Before Update:', JSON.stringify(this.payload[vehicleDetailsIndex], null, 2));

        //Clone the entire payload for reactivity
        let updatedPayload = JSON.parse(JSON.stringify(this.payload));

        //Ensure vehicleDetails exists
        if (!updatedPayload[vehicleDetailsIndex].vehicleDetails) {
            if (this.isDebug) console.error('vehicleDetails is undefined');
            return;
        }

        // Update Medical safely
        updatedPayload[vehicleDetailsIndex].vehicleDetails.Medical__c = this.medicalValue;

        this.payload = updatedPayload;

        if (this.isDebug) console.log('After Update:', JSON.stringify(this.payload[vehicleDetailsIndex], null, 2));

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        //Update the Quote based on new data
        this.getQuote();
    }

    // Helper method to evaluate liability conditions
    evaluateLiabilityConditions() {
        if (!this.vehicleAge) return;

        const vehicleObj = this.payload.find(item => item.hasOwnProperty('vehicleDetails'));
        if (!vehicleObj || !vehicleObj.vehicleDetails) return;

        const isChubbCondition = (this.vehicleAge > 20 && this.activeTab === 'Chubb');
        const isMapfreCondition = (this.vehicleAge > 25 && this.activeTab === 'Mapfre');

        if (isChubbCondition || isMapfreCondition) {
            this.liabilityOnly = true;
            this.liabilityDisabled = true;
            if (vehicleObj.vehicleDetails.Coverage__c !== 'Liability') {
                this.dispatchPayloadUpdate('vehicleDetails', {
                    Coverage__c: 'Liability'
                });
            }
        } else {
            this.liabilityDisabled = false;
            // Only reset liabilityOnly if it was previously forced
            if (this.liabilityOnly && vehicleObj.vehicleDetails.Coverage__c === 'Complete') {
                this.liabilityOnly = false;
            }
        }
    }

    connectedCallback() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.isDebug) console.log('Payload OUTPUT : ', JSON.stringify(this.payload));



        // Assuming `this.payload` is already assigned with the JSON array
        if (Array.isArray(this.payload)) {
            // Find the object that has vehicleDetails
            const vehicleObj = this.payload.find(item => item.hasOwnProperty('vehicleDetails'));

            if (vehicleObj && vehicleObj.vehicleDetails && vehicleObj.vehicleDetails.Liability__c) {
                this.combinedLiabilityValue = vehicleObj.vehicleDetails.Liability__c;
            }
            if (vehicleObj && vehicleObj.vehicleDetails && vehicleObj.vehicleDetails.Medical__c) {
                this.medicalValue = vehicleObj.vehicleDetails.Medical__c;
            }
            if (vehicleObj && vehicleObj.vehicleDetails && vehicleObj.vehicleDetails.Coverage__c) {
                this.liabilityOnly = vehicleObj.vehicleDetails.Coverage__c == 'Liability' ? true : false;
            }

            // Calculate vehicle age
            if (vehicleObj?.vehicleDetails.Year__c) {
                const currentYear = new Date().getFullYear();
                this.vehicleAge = currentYear - parseInt(vehicleObj.vehicleDetails.Year__c);
            }

            // Set default tab if not set
            if (!this.activeTab) {
                this.activeTab = 'Mapfre';
            }

            // Evaluate conditions
            this.evaluateLiabilityConditions();

            // Initialize selectedTerm to 'single' by default
            this.selectedTerm = 'Daily';

            const termIndex = this.payload.findIndex(item => item.hasOwnProperty('termOption'));



            if (termIndex !== -1) {
                // Create a deep clone of the payload to work with
                const newPayload = JSON.parse(JSON.stringify(this.payload));

                // Get existing termOption from the clone
                const existingTerm = newPayload[termIndex].termOption;

                // Create updated object
                const updatedTerm = {
                    ...existingTerm,
                    Gold__c: this.checkedData?.Gold__c,
                    Max__c: this.checkedData?.Max__c,
                    Platinum__c: this.checkedData?.Platinum__c
                };

                this.dispatchPayloadUpdate('termOption', {
                    Gold__c: this.checkedData?.Gold__c
                });
                this.dispatchPayloadUpdate('termOption', {
                    Max__c: this.checkedData?.Max__c
                });
                this.dispatchPayloadUpdate('termOption', {
                    Platinum__c: this.checkedData?.Platinum__c
                });


                // Replace in the cloned payload
                newPayload[termIndex].termOption = updatedTerm;
                this.selectedTerm = updatedTerm.Term__c;
                // Assign the new payload back (this avoids modifying the proxied object directly)
                this.payload = newPayload;
            }



        }
        this.getQuote();
        window.addEventListener('scroll', this.handleScroll.bind(this));
    }


    prepareCoverageList(companyName) {
        this.coverageList = [];

        const companyData = this.coverageData[companyName];
        if (this.isDebug) console.log('companyData by company name: ', companyData);

        if (companyData && typeof companyData === 'object') {
            this.coverageList = Object.entries(companyData)
                .filter(([_, value]) => {
                    const title = value?.Title?.toLowerCase();
                    return title !== 'not covered' && title !== 'not included';
                })
                .sort(([, a], [, b]) => {
                    const orderA = parseFloat(a.Order || 0);
                    const orderB = parseFloat(b.Order || 0);
                    return orderA - orderB;
                })
                .map(([key, value]) => {
                    const fullDescription = value.Description || '';
                    const isLong = fullDescription.length > 150;

                    return {
                        key,
                        title: value.Title || '',
                        description: isLong ? fullDescription.slice(0, 150) + '...' : fullDescription,
                        fullDescription, // You can use this when See More is clicked
                        image: value.Image || '',
                        order: parseFloat(value.Order || 0),
                        showSeeMore: isLong,
                        classList: isLong
                            ? 'slds-text-body_regular slds-truncate show-see-more'
                            : 'slds-text-body_regular'
                    };
                });
        }
    }

    async getQuote() {
        let allowedVendors = ['Mapfre', 'Chubb', 'Qualitas'];
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.isDebug) console.log('Payload in getQote Method While Calculation', this.payload);

        const nresult = await getDescriptionAndTitle({ jsonString: JSON.stringify(this.payload) });
        this.coverageData = nresult || '';
        let showMedical = this.payload.find(i => i.vehicleDetails)?.vehicleDetails?.Vehicle_sub_type__c !== 'Motorcycle';
        const vehicleValue = this.payload.find(i => i.vehicleDetails)?.vehicleDetails?.Value__c || '0';
        let cleanValue = parseFloat(String(vehicleValue).replace(/[^0-9.]/g, ''));
        if (this.isDebug) console.log('vehichle value22@@', cleanValue);
        if (this.isDebug) console.log('Payload in getQote Method While Calculation', this.payload);
        if (this.isDebug) console.log('OUTPUT : Desc loading');

        if (this.isDebug) console.log('Return result for coverageDetails', nresult);

        if (!isNaN(cleanValue) && cleanValue > 200000) {
            allowedVendors = [];
        } else if (!isNaN(cleanValue) && cleanValue > 150000) {
            allowedVendors = ['Mapfre', 'Chubb'];
        }
        await this.calculateCoverageUpdate()
            .then(() => {
                this.vendorVsTermVsTotals = {}
                Object.keys(this.results).forEach(currentTerm => {
                    const companiesData = this.results[currentTerm];
                    Object.keys(companiesData).forEach(vendor => {
                        const companyData = companiesData[vendor];
                        if (allowedVendors.includes(vendor) && parseFloat(companyData.Liability) > 0 && parseFloat(companyData.Total) > 0) {
                            if (!this.vendorVsTermVsTotals[vendor]) {
                                this.vendorVsTermVsTotals[vendor] = {};
                            }

                            const total = {
                                id: vendor,
                                label: vendor,
                                Gold: companyData.Is_Gold__c === "true" ? true : false,
                                Max: companyData.Is_Max__c === "true" ? true : false,
                                Platinum: companyData.Is_Platinum__c === "true" ? true : false,
                                TermAndConditionENG: companyData.TermAndConditionENG != '' ? companyData.TermAndConditionENG : '',
                                TermAndConditionSPN: companyData.TermAndConditionSPN != '' ? companyData.TermAndConditionSPN : '',
                                total: parseFloat(companyData.Total).toFixed(2),
                                showMedical: showMedical,
                                coverageList: [
                                    {
                                        liability: companyData.Liability != '' ? {
                                            title: 'Liability (Damage You Cause)',
                                            desc: 'USD ',
                                            price: companyData.Liability,
                                            img: 'https://via.placeholder.com/150'
                                        } : false
                                    }
                                ],
                                coverageListByCompanyName: this.coverageData
                            }

                            this.vendorVsTermVsTotals[vendor][currentTerm] = total;
                        }
                    });
                });
                this.activeTab = this.activeTab.trim() === "" ? 'Mapfre' : this.activeTab; // Setting it default because of fixed order system


                const hasMapfre = Object.keys(this.vendorVsTermVsTotals).some(vendor => vendor === 'Mapfre');
                if (!hasMapfre) { this.activeTab = 'Chubb'; }

                this.prepareCoverageList(this.activeTab);
                this.evaluateLiabilityConditions();

                if (this.isDebug) console.log('Quote details: ', JSON.stringify(this.tabs));

                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));

            })
            .catch((err) => {
                console.log('Error while calculating the quote', err)
            });
    }

    async calculateCoverageUpdate() {
        try {
            console.log('Payload', this.payload);
            // Create a mutable copy of the payload to avoid modifying the original
            const parsedPayload = JSON.parse(JSON.stringify(this.payload));

            console.log('Reached here 1');
            // Extract termOption from the payload
            let termOption = parsedPayload.find(obj => obj.termOption)?.termOption;
            if (!termOption) {
                console.error('No termOption found in payload');
                return;
            }
            console.log('Reached here 2');

            // Pick user-selected term and calculate date difference
            const userSelectedTerm = (termOption.Term__c || '').trim();
            const startDate = new Date(termOption.Start_Date_for_Coverage__c);
            const endDate = new Date(termOption.End_Date_for_Coverage__c);
            const diffDays = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));

            console.log(`⚡ Coverage duration = ${diffDays} days`);

            // Decide which terms to calculate based on the coverage duration
            this.termsToCalculate = [];
            if (!['Semi-Annual', 'Annual'].includes(userSelectedTerm)) {
                /*
                if (diffDays > 180) {
                    this.termsToCalculate = ['Daily', 'Annual'];
                } else if (diffDays > 90) {
                    this.termsToCalculate = ['Daily', 'Semi-Annual', 'Annual'];
                } else if (diffDays > 30) {
                    this.termsToCalculate = ['Daily', '90-Days', 'Semi-Annual'];
                } else if (diffDays > 1) {
                    this.termsToCalculate = ['Daily', '30-Days', '90-Days'];
                } else {
                    this.termsToCalculate = ['Daily'];
                }*/
                this.termsToCalculate = ['Daily', 'Semi-Annual', 'Annual'];
            } else if (userSelectedTerm == 'Semi-Annual') {
                this.termsToCalculate = ['Semi-Annual', 'Annual'];
            } else if (userSelectedTerm == 'Annual') {
                this.termsToCalculate = ['Annual'];
            } else {
                this.termsToCalculate = [userSelectedTerm];
            }

            console.log('✅ Terms selected:', this.termsToCalculate);

            // Make sequential calls to Apex for each term
            for (let termKey of this.termsToCalculate) {
                const clonedPayload = JSON.parse(JSON.stringify(parsedPayload));
                let clonedTermOption = clonedPayload.find(obj => obj.termOption)?.termOption;
                if (clonedTermOption) {
                    clonedTermOption.Term__c = termKey;
                }

                const updatedJson = JSON.stringify(clonedPayload);

                console.log(`▶ Calling Apex for term: ${termKey}`);
                console.log('JSON String', updatedJson);
                const res = await calculateTotalCoverage({ jsonString: updatedJson });
                console.log('Response from apex', res);
                // **FIX APPLIED HERE**
                // The result from Apex is a read-only Proxy. We convert it to a
                // plain JavaScript object to prevent errors in other functions.
                this.results[termKey] = JSON.parse(JSON.stringify(res));

                console.log(`📝 Result for ${termKey}:`, this.results[termKey]);
            }

            console.log('All results after calculation', this.results);
            Object.keys(this.results).forEach(term => {
                const companies = this.results[term];
            
                Object.keys(companies).forEach(company => {
                    companies[company].Calculated_On_Term__c = term;
                });
            });
            //return this.getBestForEachVendor(this.results);

        } catch (error) {
            console.error('Error in calculateCoverage:', error);
            // Also log the error stack for more details
            if (error.stack) {
                console.error(error.stack);
            }
        }
    }

    getBestForEachVendor(results) {
        console.log('Input results for getBestForEachVendor:', results);
        const bestResults = {};

        // This object will hold the best offer found so far for each vendor
        // Structure: { vendorName: { total: 123.45, term: 'Daily', data: {...} } }
        const vendorBest = {};

        // Iterate over each term (e.g., 'Daily', 'Annual')
        for (let term in results) {
            console.log('Checking term:', term);
            const vendors = results[term];

            // Iterate over each vendor in the current term
            for (let vendor in vendors) {
                const totalStr = vendors[vendor].Total;
                console.log(`Vendor: ${vendor}, Total String: ${totalStr}`);

                const total = parseFloat(totalStr);

                // Ensure the total is a valid number
                if (!isNaN(total)) {
                    // If we haven't seen this vendor yet, or if the new total is lower,
                    // update it as the new best option for this vendor.
                    if (!vendorBest[vendor] || total < vendorBest[vendor].total) {
                        console.log(`Updating best for vendor: ${vendor} with total: ${total}`);
                        vendorBest[vendor] = {
                            total,
                            term,
                            data: vendors[vendor]
                        };
                    }
                } else {
                    console.warn(`Invalid Total for ${vendor} under term ${term}:`, totalStr);
                }
            }
        }

        // Build the final result object from the best options found
        for (let vendor in vendorBest) {
            bestResults[vendor] = {
                ...vendorBest[vendor].data,
                Calculated_On_Term__c: vendorBest[vendor].term // Add the term that gave the best price
            };
            console.log(`Best result for ${vendor}:`, bestResults[vendor]);
        }

        console.log('Final bestResults:', bestResults);
        return bestResults;
    }

    disconnectedCallback() {
        window.removeEventListener('scroll', this.handleScroll.bind(this));
    }

    handleScroll() {
        const scrollPosition = window.scrollY;
        if (scrollPosition > 60) {
            this.stickyClass = 'tabs-container slds-p-top_small sticky';
        } else {
            this.stickyClass = 'tabs-container slds-p-top_small';
        }
    }

    @api validate() {
        return true;
    }


    @api async getData() {

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let temp = { ['quotePage']: this.selectedQuote };
        try {
            let updatedData = await this.createDataForQuoteSave();

            // Merge updatedData into quotePage
            temp['quotePage'] = {
                ...this.selectedQuote,
                ...updatedData
            };
            if (this.isDebug) console.log('Quote data created successfully');
        } catch (error) {
            if (this.isDebug) console.error('Error while creating quote data:', error);
        }

        const existingIndex = this.payload.findIndex(item => item.hasOwnProperty('quotePage'));

        if (existingIndex !== -1) {
            // Replace existing quotePage data by creating a new array
            this.payload = [
                ...this.payload.slice(0, existingIndex),
                temp,
                ...this.payload.slice(existingIndex + 1)
            ];
        } else {
            // Add new quotePage data to existing payload by creating a new array
            this.payload = [...this.payload, temp];
        }
        console.log('This is the total coverage details :: ', this.coverageData);

        // Find the index of the object that contains quotePage
        const quotePageIndex = this.payload.findIndex(item => item.quotePage);
        console.log('index :: ' + quotePageIndex);
        if (quotePageIndex !== -1) {
            this.payload[quotePageIndex].quotePage.QuotePdfJson__c = JSON.stringify(this.coverageData);
        }
        console.log('Payload after adding quotePage data:', this.payload)

        try {
            if (!this.currentUserType) {
                const result = await saveQuoteDetails({ strLeadDetails: JSON.stringify(this.payload) });
                if (this.isDebug) console.log('Res from saving Quote: ', result);

                // Parse the Quote_Details__c string to JSON
                if (result?.Data?.Quote_Details__c) {
                    const parsedQuoteData = JSON.parse(result.Data.Quote_Details__c);

                    // Add the parsed quote data as 'QuoteData' to selectedQuote
                    this.selectedQuote.QuoteData = parsedQuoteData;
                }

                if (this.isDebug) console.log('Updated selectedQuote with QuoteData:', JSON.stringify(this.selectedQuote));
            } else {
                const data = await this.createDataForContactQuoteSave(); // Add await here
                if (this.isDebug) console.log('Data received:', data); // Verify the data structure
                if (data && data.stringifiedData) {
                    const result = await saveQuoteRecordData(data.stringifiedData);
                    if (result.status == 'success') {
                        if (this.isDebug) console.log('Result after saving the qoute for exisiting costumer', result);
                        const savedVehicleData = result?.vehicleData;
                        const savedQuoteData = result?.quoteData;
                        const savedTowedData = result?.towedUnitData;
                        if (savedVehicleData != null) {
                            if (this.isDebug) console.log('Vehicle data on save', savedVehicleData);
                            this.dispatchPayloadUpdate('vehicleDetails', {
                                Id: savedVehicleData?.Id != null ? savedVehicleData.Id : '',
                                Account_Vehicle__c: savedVehicleData?.Account_Vehicle__c != null ? savedVehicleData.Account_Vehicle__c : '',
                                Contact__c: savedVehicleData?.Contact__c != null ? savedVehicleData.Contact__c : ''
                            });
                        }
                        if (savedQuoteData != null) {
                            if (this.isDebug) console.log('Quote data on save', savedQuoteData);
                            this.selectedQuote.QuoteData = savedQuoteData;
                            if (this.isDebug) console.log('After adding quote data in the selected quote', this.selectedQuote);
                        }
                        if (savedTowedData != null && savedTowedData != undefined) {
                            if (this.isDebug) console.log('Towed data on save', savedTowedData);
                            this.dispatchPayloadUpdate('vehicleDetails', {
                                towunits: savedTowedData
                            });
                        }
                    }
                    if (this.isDebug) console.log('Result', result);

                    this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                } else {

                    this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                    if (this.isDebug) console.error('No data received from createDataForContactQuoteSave');
                }
            }
            console.log('this.isDownloadQuote :: ', this.isDownloadQuote);
            console.log('this.isEmailSent :: ', this.isEmailSent);


            if (this.isEmailSent == true) {
                let sendEmailOfQuoteDetail = await sendEmailQuoteDetails({ 'quoteId': this.selectedQuote.QuoteData.Id });

                console.log('isEmail Send Already :: ' + sendEmailOfQuoteDetail.status);
                if (sendEmailOfQuoteDetail.status == 'success') {
                    console.log('Email Sccessfully Send to User');
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: 'Success', message: 'Email Sccessfully Send' } }));
                } else {
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Something went wrong' } }));
                }
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                this.isEmailSent == false;
                return;
            }
            else if (this.isDownloadQuote == true) {
                //window.open(`/apex/selectedQuoteNewRate?Id=${this.selectedQuote.QuoteData.Id}`, "_blank");
                console.log('this.selectedQuote.QuoteData :: ' + this.selectedQuote.QuoteData.Id);
                this.isDownloadQuote == false;
                window.open( `${this.baseUrl}/apex/selectedQuoteNewRate?Id=${this.selectedQuote.QuoteData.Id}`, "_blank");
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                return;

            }

        } catch (err) {

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            if (this.isDebug) console.log('Getting error while saving the QuoteOption: ', JSON.stringify(err));
        }

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        if (this.isDebug) console.log('Sending Selected Quote in parent component', this.selectedQuote);
        return this.selectedQuote;
    }

    async createDataForContactQuoteSave() {
        try {
            // Extract data from payload using find()
            const quotePageData = this.payload.find(item => item.quotePage)?.quotePage;
            const vehicleDetailsData = this.payload.find(item => item.vehicleDetails)?.vehicleDetails;
            const towedUnitsData = vehicleDetailsData?.towunits || [];

            if (this.isDebug) console.log('[DEBUG] Original vehicleDetailsData:', JSON.stringify(vehicleDetailsData, null, 2));

            // Prepare vehicle record with only valid fields
            const vehicleRecord = vehicleDetailsData ? {
                is_the_vehicle_used_for_business_purpose__c: vehicleDetailsData.is_the_vehicle_used_for_business_purpose__c,
                is_there_a_driver_under_21__c: vehicleDetailsData.is_there_a_driver_under_21__c,
                Is_this_a_Rental_Vehicle__c: vehicleDetailsData.Is_this_a_Rental_Vehicle__c,
                salvage_vehicle__c: vehicleDetailsData.salvage_vehicle__c,
                isTowing: vehicleDetailsData.isTowing,
                Year__c: vehicleDetailsData.Year__c,
                Vehicle_sub_type__c: vehicleDetailsData.Vehicle_sub_type__c,
                Value__c: vehicleDetailsData.Value__c,
                Make__c: vehicleDetailsData.Make__c || vehicleDetailsData.Make,
                Model__c: vehicleDetailsData.Model__c || vehicleDetailsData.Model,
                Id: vehicleDetailsData?.Id != null ? vehicleDetailsData.Id : null,
            } : {};

            if (this.isDebug) console.log('[DEBUG] Cleaned vehicleRecord:', JSON.stringify(vehicleRecord, null, 2));

            const towedUnitRecord = towedUnitsData.length > 0 ? towedUnitsData : null;

            // Update quoteData with Towed_Unit__c based on isTowing
            const updatedQuoteData = {
                ...quotePageData,
                Towed_Unit__c: vehicleDetailsData?.isTowing || false
            };

            // Prepare the return object with both stringified and raw data
            const result = {
                // Stringified data for immediate use
                stringifiedData: {
                    quoteRecord: JSON.stringify(updatedQuoteData),
                    vehicleRecord: JSON.stringify(vehicleRecord),
                    towedUnitRecord: towedUnitRecord ? JSON.stringify(towedUnitRecord) : ''
                },
                // Raw data for further processing
                rawData: {
                    quoteRecord: updatedQuoteData,
                    vehicleRecord: vehicleRecord,
                    towedUnitRecord: towedUnitRecord
                }
            };

            if (this.isDebug) console.log('[DEBUG] Prepared data:', {
                stringifiedQuote: result.stringifiedData.quoteRecord.length,
                stringifiedVehicle: result.stringifiedData.vehicleRecord.length,
                rawQuoteKeys: Object.keys(result.rawData.quoteRecord),
                rawVehicleKeys: Object.keys(result.rawData.vehicleRecord)
            });

            return result;

        } catch (error) {
            if (this.isDebug) console.error('[ERROR] in createDataForContactQuoteSave:', error);
            throw error;
        }
    }


    async createDataForQuoteSave() {
        const dataMap = {};
        const finalJson = this.payload;
        if (this.isDebug) console.log('Final JSON in createDataForsaveMethod', finalJson);

        finalJson.forEach((entry) => {
            const [key, value] = Object.entries(entry)[0];
            dataMap[key] = value;
        });

        if (this.isDebug) console.log('Final JSON after converted to the dataMap', dataMap);

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

        console.log('Cehcked Data', this.checkedData);
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

        console.log('Vehicle collison', vehicleCollision);
        console.log('Vehicle theft', vehicleTheft);

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

            Vehicle_Type__c: dataMap?.vehicleDetails?.Vehicle_sub_type__c,
            Policy_Type_picklist__c: dataMap?.vehicleDetails?.Vehicle_sub_type__c,

            Term__c: dataMap?.termOption?.Term__c,
            Territory__c: company,

            Net_Premium__c: parseFloat(selectedQuote?.Total) - parseFloat(selectedQuote?.IVA) - parseFloat(selectedQuote?.BrokerFee) - parseFloat(selectedQuote?.TotalSurcharges),
            Broker_Policy_Fee__c: selectedQuote?.BrokerFee,
            Term_Days__c: termDays != null ? termDays : '0', // Add Days
            I_V_A_Mex_Tax__c: selectedQuote?.IVA,
            Quote_Value__c: agentFee !== null ? parseFloat(selectedQuote?.Total || 0) + parseFloat(agentFee) : selectedQuote?.Total,
            Surcharge__c: selectedQuote?.TotalSurcharges,

            Underwriter__c: underwriter,

            Coverage__c: dataMap?.vehicleDetails?.Coverage__c,
            Towed_Unit__c: dataMap?.vehicleDetails?.isTowing,

            Vehicle_deductible_comprehensive__c: vehicleTheft ?? null,
            Vehicle_deductible_collision__c: vehicleCollision ?? null,
            Physical_Damage__c: selectedQuote?.PropertyDamage || '',
            Total_Theft_Payment__c: selectedQuote?.TotalTheft || '',
            Liability_Payment__c: selectedQuote?.Liability || '',
            // Medical_Payment__c: selectedQuote?.Medical || '',
            Medical_Payment__c:
                dataMap?.vehicleDetails?.Vehicle_sub_type__c === 'Motorcycle'
                    ? null
                    : selectedQuote?.Medical || '',
            Platinum_Endorsment__c: selectedQuote?.platinumEndorsementPayment || '',

            Liability__c: dataMap?.vehicleDetails?.Liability__c,
            // Medical__c: dataMap?.vehicleDetails?.Medical__c,
            Medical__c:
                dataMap?.vehicleDetails?.Vehicle_sub_type__c === 'Motorcycle'
                    ? null
                    : dataMap?.vehicleDetails?.Medical__c,

            Agent_Fee__c: selectedQuote?.AgentFee || agentFee,
            Old_Net_Premium__c: agentFee !== null ? parseFloat(selectedQuote?.Total || 0) + parseFloat(agentFee) : selectedQuote?.Total,

            Gold__c: underwriter.toLowerCase() === 'qualitas' ? this.checkedData?.Gold__c || false : false,
            Max__c: underwriter.toLowerCase() === 'mapfre' ? this.checkedData?.Max__c || false : false,
            Platinum__c: underwriter.toLowerCase() === 'chubb' ? this.checkedData?.Platinum__c || false : false
        };

        if (this.isDebug) console.log('Final Payload Object and Data Mapped:', dataMapped);
        return dataMapped;
    }

    //Update the payload based on liability,Medical and Gold,Max update
    dispatchPayloadUpdate(key, data) {
        const updateEvent = new CustomEvent('payloadupdate', {
            detail: {
                updates: {
                    [key]: {
                        ...data // Spread the provided data
                    }
                }
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(updateEvent);
    }
}