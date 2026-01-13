import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import buhoAssets from '@salesforce/resourceUrl/BuhoAssets';
import { createTransformedData } from 'c/buho_utils';
import checkalreadyExistUserAction from '@salesforce/apex/CustomerQuoteFlow.checkalreadyExistUserAction';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/NcExistingCustomerFlow.checkCommunityUserAndFetchDetails';
import getCurrentSiteDetails from '@salesforce/apex/BuhoLoginController.getCurrentSiteDetails';
import USER_ID from '@salesforce/user/Id';

export default class Buho_quoteWizard extends LightningElement {
    @track componentConstructor; // Holds the current component
    @track currentStep = 1; // Tracks the current step (1-indexed for display)
    @track payload = []; // Shared payload to store form data
    @track childLoaded = true;
    @track processedData = [];
    @track flag = {
        hideNavigation: true // Navigation is inside each step component
    };
    @track currentSiteData;

    stylesLoaded = false; // Flag to prevent multiple CSS loads



    // Steps and their corresponding component imports
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
    ];
    // Total steps in the wizard
    get totalSteps() {
        return this.steps.length;
    }

    // Asset URLs
    get logoUrl() {
        return `${buhoAssets}/images/Logo.svg`;
    }

    get pathPrefix() {
        this.currentSiteData?.pathPrefix || '';
    }

    // Computed properties for button states
    get isFirstStep() {
        return this.currentStep === 1;
    }

    get isLastStep() {
        return this.currentStep === this.steps.length;
    }

    // Generate progress segments
    get progressSegments() {
        const segments = [];
        for (let i = 1; i <= this.totalSteps; i++) {
            let className = 'progress-segment';
            if (i < this.currentStep) {
                className += ' completed';
            } else if (i === this.currentStep) {
                className += ' active';
            }
            segments.push({ step: i, className });
        }
        return segments;
    }

    get isUserLoggedIn() {
        !!USER_ID;
    }

    @wire(getCurrentSiteDetails)
    wiredSiteDetails({ data, error }) {
        if (data) {
            this.currentSiteData = data;
            this.error = undefined;
            console.log('Site Details:', JSON.stringify(data));
        } else if (error) {
            this.error = error;
            this.currentSiteData = undefined;
            console.error('Error:', error);
        }
    }


    // Lifecycle hook: triggered when component is inserted into the DOM
    async connectedCallback() {
        console.log('connected callback of wizard called');
        const urlParams = new URLSearchParams(window.location.search);
        try {
            const data = await checkCommunityUserAndFetchDetails();
            console.log('community user data',data)
            const parseData = JSON.parse(data);

            if (parseData.status == 'success' && parseData.userType) {
                const cleanedData = this.transformData(parseData);
                console.log('BQW Cleaned Data', cleanedData);

                // Pass the key as a string in an array
                this.copyDataToPayload(cleanedData,
                    ['userDetails', 'vehicleDetails',
                        'UserType', 'driverDetails', 'termOption',
                        'quotePage', 'finalizeVehicleDetails', 'territory',
                        'lienholderInformation', 'finalDetails']);

                console.log('BQW Payload after data copy', this.payload);


            } else if (urlParams.has('email')) {
                const result = await checkalreadyExistUserAction({
                    'leadDataItem': JSON.stringify({ Email: urlParams.get('email') })
                }).catch(err => {
                    console.error('API Error:', err);
                    throw new Error('API call failed');
                });
                if (result?.LeadInfo) {
                    const transformedData = createTransformedData?.(result) || [];
                    this.payload = JSON.parse(JSON.stringify(transformedData));
                    console.log('@@@payload wizard', this.payload);
                    if (urlParams.has('step')) {
                        this.currentStep = urlParams.get('step');
                    } else {
                        this.currentStep = 3; // Skip user details for existing customers
                    }
                }
            }
            console.log('quote wizard loaded with current step', this.currentStep);
            this.childLoaded = false;
            await this.loadComponent();
        } catch (err) {
            this.childLoaded = true;
            console.error('BQW Error in connectedCallback:', err.message);
        }
        console.log('is user already loggedin',USER_ID);
    }


    // Handle loading status from child components
    handleLoadingStatus(event) {
        this.childLoaded = event.detail;
    }

    // Handle toast events from child components
    handleToastEvent(event) {
        const toastData = event.detail;
        console.log('BQW Toast event received:', toastData);
        if (toastData) {
            const toastComponent = this.template.querySelector('c-buho_toast');
            if (toastComponent) {
                toastComponent.showToast(toastData);
            }
        }
    }

    // Handle flag updates from child components
    handleFlagUpdate(event) {
        this.flag.hideNavigation = event.detail;
    }

    // Dynamically imports and sets the component constructor for the current step
    async loadComponent() {
        try {
            const stepIndex = this.currentStep - 1;
            const { component } = this.steps[stepIndex];
            console.log('BQW Loading component:', component, 'Step:', this.currentStep);

            this.flag.hideNavigation = true; // Default: navigation inside component

            switch (component) {
                case 'c/buho_userDetails': {
                    const { default: ctor } = await import('c/buho_userDetails');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_vehicleDetails': {
                    const { default: ctor } = await import("c/buho_vehicleDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_termOption': {
                    const { default: ctor } = await import("c/buho_termOption");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_territory': {
                    const { default: ctor } = await import("c/buho_territory");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_quotePage': {
                    const { default: ctor } = await import("c/buho_quotePage");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_towDetails': {
                    const { default: ctor } = await import("c/buho_towDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_finalizeVehicleDetails': {
                    const { default: ctor } = await import("c/buho_finalizeVehicleDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_lienholderInformation': {
                    const { default: ctor } = await import("c/buho_lienholderInformation");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_driverDetails': {
                    const { default: ctor } = await import("c/buho_driverDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_ownerDetails': {
                    const { default: ctor } = await import("c/buho_ownerDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_finalDetails': {
                    const { default: ctor } = await import("c/buho_finalDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/buho_payment': {
                    const { default: ctor } = await import("c/buho_payment");
                    this.componentConstructor = ctor;
                    break;
                }
                default:
                    console.error('BQW Component not found:', component);
                    break;
            }

            this.childLoaded = true;
        } catch (err) {
            this.childLoaded = true;
            console.error('BQW Error loading component:', err.message);
        }
    }

    // Handles navigation between steps (next/previous)
    async handleNavigation(event) {
        try {
            let direction = event.target?.dataset?.direction;
            if (!direction) {
                direction = event.detail?.direction;
            }
            console.log('BQW Navigation direction:', direction);

            if (direction === 'next') {
                // Validate the current step
                const isValid = await this.validateStep();
                console.log('BQW Validation result:', isValid);

                if (!isValid) {
                    console.log('BQW Validation failed at:', this.steps[this.currentStep - 1].component);
                    return;
                }

                this.childLoaded = false;

                // Capture data before moving to next step
                try {
                    await this.capturePayloadData();
                } catch (err) {
                    this.childLoaded = true;
                    console.error('1BQW Error capturing payload:', err.message);
                    return;
                }

                // Move to next step or handle completion
                if (!this.isLastStep) {
                    this.currentStep++;
                    const { component } = this.steps[this.currentStep - 1];
                    if ((component === 'c/nc_towDetails' && !this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.isTowing)
                        || (component === 'c/nc_lienholderInformation' && !this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails?.Is_Lienholder__c)) {
                        this.currentStep++;
                    }
                    await this.loadComponent();
                } else {
                    // Last step - handle quote submission
                    this.handleQuoteSubmission();
                }
            } else if (direction === 'previous' && !this.isFirstStep) {
                this.currentStep--;
                await this.loadComponent();
            }
            console.log('@@@payload ', this.payload);
        } catch (err) {
            this.childLoaded = true;
            console.error('BQW Navigation error:', err.message);
        }
        this.updateUrlStep();
    }

    updateUrlStep() {
        const url = new URL(window.location.href);
        url.searchParams.set('step', this.currentStep);
        window.history.replaceState({}, '', url);
    }

    async handleStepChange(event) {
        try {
            const step = event.detail;
            try {
                await this.capturePayloadData();
            } catch (err) {
                this.childLoaded = true;
                console.error('2BQW Error capturing payload:', err.message);
                return;
            }
            this.currentStep = step;
            await this.loadComponent();
        } catch (err) {
            this.childLoaded = true;
            console.error('BQW Navigation error:', err.message);
        }
    }

    // Validates the current step using the validate() method in the child component
    async validateStep() {
        const currentComponent = this.getDynamicComponentInstance();
        console.log('BQW Validating step...');
        if (currentComponent && typeof currentComponent.validate === 'function') {
            try {
                return await currentComponent.validate();
            } catch (err) {
                this.childLoaded = true;
                console.error('BQW Validation error:', err.message);
                return false;
            }
        }
        return true; // Default to valid if no validate method
    }

    // Captures the current step's data from child component
    async capturePayloadData() {
        try {
            const currentComponent = this.getDynamicComponentInstance();
            console.log('@@@calling get data', currentComponent);
            if (currentComponent && typeof currentComponent.getData === 'function') {
                const data = await currentComponent.getData();
                console.log('data@@@', data);
                
                // Check if data is an array
                if (Array.isArray(data)) {
                    // Determine if this is a "payload array" or a "data array"
                    // Payload array: [{ driverDetails: {...} }, { finalizeVehicleDetails: {...} }]
                    // Data array: [{ Towed_Unit_Type__c: "...", ... }]
                    
                    const isPayloadArray = data.length > 0 && 
                        typeof data[0] === 'object' && 
                        Object.keys(data[0]).some(key => 
                            this.steps.some(step => step.name === key)
                        );
                    
                    if (isPayloadArray) {
                        // This is a payload array (like from buho_ownerDetails) - merge it
                        this.payload = this.mergeArrayPayloads(this.payload, data);
                    } else {
                        // This is a data array (like from buho_towDetails) - wrap it with step name
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
                    // Standard handling - wrap with step name
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

                console.log('BQW Payload updated:', JSON.stringify(this.payload));
            }
        } catch (err) {
            this.childLoaded = true;
            console.error('3BQW Error capturing payload:', err.message);
        }
    }

    getDynamicComponentInstance() {
        const stepIndex = this.currentStep - 1;
        const componentName = this.steps[stepIndex].component.split('/').pop();
        // Convert only camelCase to kebab-case, preserve underscores
        const selector = 'c-' + componentName.replace(/([A-Z])/g, '-$1').toLowerCase().replace(/^-/, '');
        console.log('BQW Looking for component with selector:', selector);
        return this.template.querySelector(selector);
    }

    // Handle payload updates from child components
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
        console.log('BQW Payload updated from child:', JSON.stringify(this.payload));
    }

    // Handle complete payload replacement from child
    handlePayloadUpdateComplete(event) {
        if (!Array.isArray(event?.detail)) return;
        this.payload = this.mergeArrayPayloads(this.payload, event.detail);
        console.log('BQW Full payload updated:', JSON.stringify(this.payload));
    }

    // Merge array payloads
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

    // Deep merge helper
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

    // Handle quote submission after last step
    handleQuoteSubmission() {
        console.log('BQW Quote submission with payload:', JSON.stringify(this.payload));
        // Navigate to quote summary or handle submission
        // This will be implemented based on requirements
        this.childLoaded = true;
    }

    // Generic method to copy data by key
    copyDataToPayload(cleanedData, keysToCopy) {
        try {
            if (!cleanedData || !Array.isArray(cleanedData)) {
                throw new Error('cleanedData must be an array');
            }

            if (!keysToCopy || !Array.isArray(keysToCopy)) {
                throw new Error('keysToCopy must be an array of strings');
            }

            // Create a new payload array to maintain reactivity
            let newPayload = [...this.payload];

            keysToCopy.forEach(key => {
                // Find the object in cleanedData that contains this key
                const sourceItem = cleanedData.find(item => item && item[key] !== undefined);

                if (sourceItem) {
                    // Find if this key already exists in payload
                    const existingIndex = newPayload.findIndex(item => item && item[key] !== undefined);

                    if (existingIndex >= 0) {
                        // Update existing entry
                        newPayload[existingIndex] = {
                            ...newPayload[existingIndex],
                            [key]: { ...sourceItem[key] } // Deep clone
                        };
                    } else {
                        // Add new entry
                        newPayload.push({ [key]: { ...sourceItem[key] } });
                    }
                }
            });

            this.payload = newPayload;
        } catch (error) {
            console.error('BQW Error in copyDataToPayload:', error.message);
        }
    }

    // Transform data for existing customers
    transformData(apiResponse) {
        const vehicles = apiResponse.vehicles || [];
        const vehicle = vehicles?.[0] || {};
        const drivers = apiResponse.drivers || [];
        const contact = apiResponse.contact?.[0] || {};
        const towedUnits = apiResponse.towedUnits || [];

        // Transform the towed units data
        const transformTowedUnits = (unitsArray) => {
            if (!Array.isArray(unitsArray)) return [];
            return unitsArray.map((unit, index) => ({
                Towed_Unit_Type__c: unit.Towed_Unit_Type__c || null,
                Towed_Unit_Value__c: unit.Towed_Unit_Value__c?.toString() || null,
                Days_in_Tow__c: unit.Days_in_Tow__c?.toString() || null,
                count: index + 1,
                isDeleteButton: true,
                style: '',
                Year__c: unit.Year__c || null,
                Make__c: unit.Make__c || null,
                Model__c: unit.Model__c || null,
                VIN_Number__c: unit.VIN_Number__c || null,
                Plate__c: unit.Plate__c || null,
                label: unit.Make__c + ' ' + unit.Model__c + ' ' + unit.Year__c + ' - ' + (unit.VIN_Number__c || ''),
                value: unit?.Id,
                Id: unit?.Id
            }));
        };

        const towData = transformTowedUnits(towedUnits);

        const vehicleList = vehicles.map(veh => ({
            Id: veh?.Id,
            label: veh.Make__c + ' ' + veh.Model__c + ' ' + veh.Year__c + ' - ' + (veh.Vin__c || ''),
            value: veh?.Id,
            Coverage__c: 'Complete',
            Electric_Hybrid__c: veh.Electric_Hybrid__c || false,
            Liability__c: '300,000',
            Medical__c: '10,000/50,000',
            Year__c: veh.Year__c || '2025',
            Vehicle_sub_type__c: veh.Vehicle_Type__c || 'Automobile-Van-Minivan',
            Make: veh.Make__c || null,
            Model: veh.Model__c || null,
            Value__c: veh.Value__c?.toString() || null,
            Vin__c: veh.Vin__c || null,
            Registered_Country__c: veh.Registered_Country__c || null,
            Registered_State__c: veh.Registered_State__c || null,
            licensePlate: veh.Registered_Plate__c || null
        }));

        const getDriverType = (driverType) => {
            if (driverType === undefined || driverType === null) return false;
            if (typeof driverType === 'boolean') return driverType;
            if (typeof driverType === 'string') {
                return driverType.toLowerCase() === 'true' ||
                    driverType.toLowerCase() === 'owner' ||
                    driverType.toLowerCase() === 'owner & driver';
            }
            return false;
        };

        const driverList = drivers.map(driver => ({
            Id: driver?.Id || null,
            label: `${driver.First_Name__c || ''} ${driver.Last_Name__c || ''} - ${driver.Dob__c || ''} - ${driver.license_number__c || ''}`,
            value: driver?.Id || null,
            First_Name__c: driver.First_Name__c || '',
            Last_Name__c: driver.Last_Name__c || '',
            License_Country__c: driver.License_Country__c || '',
            License_state__c: driver.License_state__c || '',
            license_number__c: driver.license_number__c || '',
            Dob__c: driver.Dob__c || '',
            Driver_Type__c: getDriverType(driver.Driver_Type__c),
            Country__c: driver.Country__c || '',
            Country_Text__c: driver.Country__c || '',
            State_Province__c: driver.State_Province__c || '',
            Postal_Code__c: driver.Postal_Code__c || '',
            City__c: driver.City__c || '',
            Address__c: driver.Address__c || '',
            diff: Date.now()
        }));

        return [
            {
                UserType: {
                    UserType: 'Customer'
                }
            },
            {
                userDetails: {
                    Email: contact.Email || apiResponse.email || null,
                    FirstName: contact.FirstName || null,
                    Phone: contact.Phone || contact.MobilePhone || null,
                    LastName: contact.LastName || null,
                    Id: contact.Id || null,
                    countryCode: '+1'
                }
            },
            {
                vehicleDetails: {
                    Coverage__c: 'Complete',
                    towunits: [],
                    Electric_Hybrid__c: vehicle.Electric_Hybrid__c || false,
                    Liability__c: '300,000',
                    Medical__c: '10,000/50,000',
                    Year__c: vehicle.Year__c || '2025',
                    Vehicle_sub_type__c: vehicle.Vehicle_Type__c || 'Automobile-Van-Minivan',
                    Make: vehicle.Make__c || null,
                    Model: vehicle.Model__c || null,
                    Value__c: vehicle.Value__c?.toString() || null,
                    towunitsList: towData,
                    vehicleList: vehicleList,
                    isTowing: towData && towData.length > 0,
                    is_there_a_driver_under_21__c: false,
                    is_the_vehicle_used_for_business_purpose__c: false,
                    salvage_vehicle__c: false,
                    Is_this_a_Rental_Vehicle__c: false
                }
            },
            {
                driverDetails: {
                    drivers: [],
                    driverList: driverList
                }
            }
        ];
    }
}

