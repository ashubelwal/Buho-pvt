import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAffiliateUser from '@salesforce/apex/AffiliateController.getAffiliateUser';
import saveLeadDetails from '@salesforce/apex/AffiliateController.saveLeadDetails';
import { getCustomerRecord } from 'c/buho_utils';
import { loadStyle } from 'lightning/platformResourceLoader';
import buhoAssets from '@salesforce/resourceUrl/BuhoAssets';

export default class Affiliate_quoteWizard extends LightningElement {
    @track displayHeader = true;
    @track componentConstructor;
    @track currentStep = 1;
    @track payload = [];
    @track childLoaded = true;
    @track affiliateBranding = {};
    affiliateCode;
    stylesLoaded = false;

    steps = [
        { component: "c/buho_userDetails", name: "userDetails" },
        { component: "c/buho_vehicleDetails", name: "vehicleDetails" },
        { component: "c/buho_termOption", name: "termOption" },
        { component: "c/buho_territory", name: "territory" },
        { component: "c/buho_quotePage", name: "quotePage" },
        { component: "c/buho_towDetails", name: "towDetails" },
        { component: "c/buho_finalizeVehicleDetails", name: "finalizeVehicleDetails" },
        { component: "c/buho_lienholderInformation", name: "lienholderInformation" },
        { component: "c/buho_driverDetails", name: "driverDetails" },
        { component: "c/buho_ownerDetails", name: "driverDetails" },
        { component: "c/buho_finalDetails", name: "finalDetails" },
        { component: "c/buho_payment", name: "payment" },
        { component: "c/buho_confirmation", name: "confirmation" },
        { component: "c/buho_feedback", name: "feedback" },
    ];

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state.code) {
            this.affiliateCode = currentPageReference.state.code;
            this.fetchAffiliateDetails();
        }
    }

    async fetchAffiliateDetails() {
        try {
            const data = await getAffiliateUser({ affiliateId: this.affiliateCode });
            this.affiliateBranding = JSON.parse(data);
            this.injectAffiliateMetadata();
        } catch (error) {
            console.error('Error fetching affiliate details:', error);
        }
    }

    get totalSteps() {
        return this.steps.length;
    }

    get isFirstStep() {
        return this.currentStep === 1;
    }

    get isLastStep() {
        return this.currentStep === this.steps.length;
    }

    get showProgressBar() {
        return !this.isFirstStep && this.currentStep < 13;
    }

    get agencyLogo() {
        return this.affiliateBranding?.Agency_Logo__c;
    }

    get ownerName() {
        return this.affiliateBranding?.Owner_Name__c || 'Partner';
    }

    get dynamicStyle() {
        const primary = this.affiliateBranding?.Theme_Primary_Color__c || '#1E293B';
        const accent = this.affiliateBranding?.Theme_Accent_Color__c || '#475569';
        const light = this.affiliateBranding?.Theme_Light_Color__c || '#E2E8F0';

        return `
            --primary-blue: ${primary};
            --buho-primary-blue: ${primary};
            --accent-pink: ${accent};
            --buho-accent-pink: ${accent};
            --light-blue: ${light};
            --buho-light-blue: ${light};
        `;
    }

    injectAffiliateMetadata() {
        let newPayload = [...this.payload];
        const agentFee = parseFloat(this.affiliateBranding?.Agent_Fee__c || 0);

        const quoteIndex = newPayload.findIndex(item => item.quotePage);
        const affiliateData = {
            affiliateCode: this.affiliateCode,
            agentFee: agentFee,
            agencyId: this.affiliateBranding?.Agency_Id__c,
            agentId: this.affiliateBranding?.Agent_Id__c
        };

        if (quoteIndex >= 0) {
            newPayload[quoteIndex].quotePage.affiliate = affiliateData;
        } else {
            newPayload.push({ quotePage: { affiliate: affiliateData } });
        }
        this.payload = newPayload;
    }

    async connectedCallback() {
        this.childLoaded = false;
        await this.loadComponent();
    }

    renderedCallback() {
        if (this.stylesLoaded) {
            return;
        }
        this.stylesLoaded = true;
        loadStyle(this, buhoAssets + '/css/buhoStyles.css')
            .then(() => console.log('buhoStyles.css loaded'))
            .catch(error => console.error('Error loading buhoStyles.css', error));
    }

    handleContactClick() {
        window.dispatchEvent(new CustomEvent('openChat'));
    }

    handleLoadingStatus(event) {
        this.childLoaded = event.detail;
    }

    handleToastEvent(event) {
        const toastData = event.detail;
        if (toastData) {
            const toastComponent = this.template.querySelector('c-buho_toast');
            if (toastComponent) {
                toastComponent.showToast(toastData);
            }
        }
    }

    async loadComponent() {
        try {
            const stepIndex = this.currentStep - 1;
            const { component } = this.steps[stepIndex];
            
            // Re-inject metadata in case it was overwritten or needs to be present
            this.injectAffiliateMetadata();

            switch (component) {
                case 'c/buho_userDetails': { const { default: ctor } = await import('c/buho_userDetails'); this.componentConstructor = ctor; break; }
                case 'c/buho_vehicleDetails': { const { default: ctor } = await import("c/buho_vehicleDetails"); this.componentConstructor = ctor; break; }
                case 'c/buho_termOption': { const { default: ctor } = await import("c/buho_termOption"); this.componentConstructor = ctor; break; }
                case 'c/buho_territory': { const { default: ctor } = await import("c/buho_territory"); this.componentConstructor = ctor; break; }
                case 'c/buho_quotePage': { const { default: ctor } = await import("c/buho_quotePage"); this.componentConstructor = ctor; break; }
                case 'c/buho_towDetails': { const { default: ctor } = await import("c/buho_towDetails"); this.componentConstructor = ctor; break; }
                case 'c/buho_finalizeVehicleDetails': { const { default: ctor } = await import("c/buho_finalizeVehicleDetails"); this.componentConstructor = ctor; break; }
                case 'c/buho_lienholderInformation': { const { default: ctor } = await import("c/buho_lienholderInformation"); this.componentConstructor = ctor; break; }
                case 'c/buho_driverDetails': { const { default: ctor } = await import("c/buho_driverDetails"); this.componentConstructor = ctor; break; }
                case 'c/buho_ownerDetails': { const { default: ctor } = await import("c/buho_ownerDetails"); this.componentConstructor = ctor; break; }
                case 'c/buho_finalDetails': { const { default: ctor } = await import("c/buho_finalDetails"); this.componentConstructor = ctor; break; }
                case 'c/buho_payment': { const { default: ctor } = await import("c/buho_payment"); this.componentConstructor = ctor; break; }
                case 'c/buho_confirmation': { const { default: ctor } = await import("c/buho_confirmation"); this.componentConstructor = ctor; break; }
                case 'c/buho_feedback': { const { default: ctor } = await import("c/buho_feedback"); this.componentConstructor = ctor; break; }
                default: console.error('Component not found:', component); break;
            }

            this.childLoaded = true;
        } catch (err) {
            this.childLoaded = true;
            console.error('Error loading component:', err.message);
        }
    }

    async handleNavigation(event) {
        try {
            let direction = event.target?.dataset?.direction || event.detail?.direction;

            if (direction === 'next') {
                const isValid = await this.validateStep();
                if (!isValid) return;

                this.childLoaded = false;
                await this.capturePayloadData();

                if (!this.isLastStep) {
                    this.currentStep++;
                    this.isSkipComponent(true);
                    await this.loadComponent();
                } else {
                    this.handleQuoteSubmission();
                }
            } else if (direction === 'previous' && !this.isFirstStep) {
                this.currentStep--;
                this.isSkipComponent(false);
                await this.loadComponent();
            }
        } catch (err) {
            this.childLoaded = true;
            console.error('Navigation error:', err.message);
        }
    }

    isSkipComponent(moveNext) {
        const { component } = this.steps[this.currentStep - 1];
        if ((component === 'c/buho_towDetails' && this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.isTowing == false)
            || (component === 'c/buho_lienholderInformation' && !this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails?.Is_Lienholder__c)) {
            if (moveNext) {
                this.currentStep++;
            } else {
                this.currentStep--;
            }
        }
    }

    async handleStepChange(event) {
        try {
            const step = event.detail;
            await this.capturePayloadData();
            this.currentStep = step;
            await this.loadComponent();
        } catch (err) {
            this.childLoaded = true;
            console.error('Navigation error:', err.message);
        }
    }

    async validateStep() {
        const currentComponent = this.getDynamicComponentInstance();
        if (currentComponent && typeof currentComponent.validate === 'function') {
            try {
                return await currentComponent.validate();
            } catch (err) {
                this.childLoaded = true;
                console.error('Validation error:', err.message);
                return false;
            }
        }
        return true;
    }

    async capturePayloadData() {
        try {
            const currentComponent = this.getDynamicComponentInstance();
            if (currentComponent && typeof currentComponent.getData === 'function') {
                const data = await currentComponent.getData();
                
                if (Array.isArray(data)) {
                    const isPayloadArray = data.length > 0 && typeof data[0] === 'object' && Object.keys(data[0]).some(key => this.steps.some(step => step.name === key));
                    
                    if (isPayloadArray) {
                        this.payload = this.mergeArrayPayloads(this.payload, data);
                    } else {
                        const stepName = this.steps[this.currentStep - 1].name;
                        const temp = { [stepName]: data };
                        const key = Object.keys(temp)[0];
                        const existingIndex = this.payload.findIndex(item => Object.keys(item)[0] === key);
                        
                        if (existingIndex !== -1) {
                            this.payload[existingIndex] = { ...temp };
                        } else {
                            this.payload = [...this.payload, { ...temp }];
                        }
                    }
                } else {
                    const stepName = this.steps[this.currentStep - 1].name;
                    const temp = { [stepName]: data };
                    const key = Object.keys(temp)[0];
                    const existingIndex = this.payload.findIndex(item => Object.keys(item)[0] === key);

                    if (existingIndex !== -1) {
                        this.payload[existingIndex] = { ...temp };
                    } else {
                        this.payload = [...this.payload, { ...temp }];
                    }
                }
            }
        } catch (err) {
            this.childLoaded = true;
            console.error('Error capturing payload:', err.message);
        }
    }

    getDynamicComponentInstance() {
        const stepIndex = this.currentStep - 1;
        const componentName = this.steps[stepIndex].component.split('/').pop();
        const selector = 'c-' + componentName.replace(/([A-Z])/g, '-$1').toLowerCase().replace(/^-/, '');
        return this.template.querySelector(selector);
    }

    handlePayloadUpdate(event) {
        const { updates } = event.detail;
        let newPayload = [...this.payload];

        Object.entries(updates).forEach(([sectionName, sectionUpdates]) => {
            const sectionIndex = newPayload.findIndex(item => item[sectionName]);
            if (sectionIndex >= 0) {
                newPayload[sectionIndex] = {
                    ...newPayload[sectionIndex],
                    [sectionName]: {
                        ...newPayload[sectionIndex][sectionName],
                        ...sectionUpdates
                    }
                };
            } else {
                newPayload.push({ [sectionName]: sectionUpdates });
            }
        });

        this.payload = newPayload;
    }

    handlePayloadUpdateComplete(event) {
        if (!Array.isArray(event?.detail)) return;
        this.payload = this.mergeArrayPayloads(this.payload, event.detail);
    }

    mergeArrayPayloads(currentPayload, newData) {
        const mergedPayload = JSON.parse(JSON.stringify(currentPayload));
        const payloadMap = new Map();

        mergedPayload.forEach((item, index) => {
            const key = Object.keys(item)[0];
            if (key) payloadMap.set(key, index);
        });

        newData.forEach(newItem => {
            const key = Object.keys(newItem)[0];
            if (!key) return;

            const existingIndex = payloadMap.get(key);
            if (existingIndex !== undefined) {
                mergedPayload[existingIndex] = this.deepMergeObjects(mergedPayload[existingIndex], newItem);
            } else {
                mergedPayload.push({ ...newItem });
                payloadMap.set(key, mergedPayload.length - 1);
            }
        });

        return mergedPayload;
    }

    deepMergeObjects(target, source) {
        const result = { ...target };
        for (const key in source) {
            if (source.hasOwnProperty(key)) {
                if (source[key] instanceof Object && !Array.isArray(source[key]) &&
                    target[key] instanceof Object && !Array.isArray(target[key])) {
                    result[key] = this.deepMergeObjects(target[key], source[key]);
                } else {
                    result[key] = source[key];
                }
            }
        }
        return result;
    }

    getCustomerRecordFromPayload() {
        return getCustomerRecord(this.payload);
    }

    async handleQuoteSubmission() {
        try {
            const customerRecord = this.getCustomerRecordFromPayload();
            const leadData = {
                FirstName: customerRecord.FirstName,
                LastName: customerRecord.LastName,
                Email: customerRecord.Email,
                Phone: customerRecord.Phone,
                Policy_Type__c: customerRecord.policyType
            };

            await saveLeadDetails({
                leadJson: JSON.stringify(leadData),
                quoteJSON: JSON.stringify(customerRecord.quoteRecord || {}),
                vehicleJSON: JSON.stringify(customerRecord.vehicleData || {}),
                towedlistJSON: JSON.stringify(customerRecord.vehicleData?.towunits || []),
                affiliateCode: this.affiliateCode
            });
            console.log('Lead and Quote Submitted Successfully');
            this.childLoaded = true;
        } catch (error) {
            console.error('Error submitting lead', error);
            this.childLoaded = true;
        }
    }
}
