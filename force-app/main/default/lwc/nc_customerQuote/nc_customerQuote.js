import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import CUSTOMER_PORTAL_STYLE from '@salesforce/resourceUrl/CustomerPortalStyle';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/NcExistingCustomerFlow.checkCommunityUserAndFetchDetails';


export default class Nc_customerQuote extends LightningElement {
    // @api payload;
    @track componentConstructor; // Holds the current component
    @track currentStep = 0; // Tracks the current step
    @track payload = []; // Shared payload to store form data
    childLoaded = true;
    processedData = [];
    @track flag = {
        isQuotePage: false
    }


    // Steps and their corresponding component imports
    steps = [
        { component: "c/nc_userDetails" },
        { component: "c/nc_vehicleDetails" },
        { component: "c/nc_termOption" },
        { component: "c/nc_territory" },
        { component: "c/nc_quotePage" },
        { component: "c/nc_towDetails" },
        { component: "c/nc_finalizeVehicleDetails" },
        { component: "c/nc_lienholderInformation" },
        { component: "c/nc_driverDetails" },
        { component: "c/nc_finalDetails" },
        { component: "c/nc_payment" },
        { component: "c/nc_confirmation" },
        { component: "c/nc_feedback" },
    ];

    comboboxOptions = [
        { label: "Option 1", value: "option1" },
        { label: "Option 2", value: "option2" },
        { label: "Option 3", value: "option3" },
    ];

    @track isModalOpen = false;

    // Computed properties for button states
    get isFirstStep() {
        return this.currentStep === 0;
    }

    get isLastStep() {
        return this.currentStep === this.steps.length - 1;
    }

    // Lifecycle hook: triggered when component is inserted into the DOM.
    // Loads the initial step's component .
    async connectedCallback() {
        try {
            const data = await checkCommunityUserAndFetchDetails();
            // console.log('CQ In Customer Quote Connected CAllback data', data);
            const parseData = JSON.parse(data);
            // console.log('CQ Parsed data', parseData);
            if (parseData.status == 'success' && parseData.userType) {
                const cleanedData = this.transformData(parseData);
                console.log('CQ Cleaed Data', cleanedData);

                // Pass the key as a string in an array
                this.copyDataToPayload(cleanedData, ['userDetails']); // console.log('CQ Payload after data copy', this.payload);
                this.copyDataToPayload(cleanedData, ['vehicleDetails']); // console.log('CQ Payload after data copy', this.payload);
                this.copyDataToPayload(cleanedData, ['UserType']); // console.log('CQ Payload after data copy', this.payload);
                this.copyDataToPayload(cleanedData, ['driverDetails']);  
                console.log('CQ Payload after data copy', this.payload);

                this.currentStep++;
            }
            this.childLoaded = false;
            await this.loadComponent();
        } catch (err) {
            this.childLoaded = true;
            console.log('CQ OUTPUT : ', err.message);
        }
    }

    // Lifecycle hook: triggered after the component is rendered.
    // Loads external CSS from static resource.
    renderedCallback() {
        // console.log('CQ Style loading', CUSTOMER_PORTAL_STYLE)
        loadStyle(this, CUSTOMER_PORTAL_STYLE).then(() => {
            // console.log('CQ CustomerQuote - renderedCallback CSS/Style File loaded');
        })
    }

    handleLoadingStatus(event) {        
        this.childLoaded = event.detail;
    }

    handleToastEvent(event) {        
        let toastData = event.detail;
        console.log('CQ OUTPUT-- toastData', toastData);
        if(toastData) {
            this.template.querySelector('c-custom-toast').showToast(toastData);
        }
    }

    // Processes and formats form data into structured sections for display (e.g. summary or review screen)
    processSections(data) {
        return data.map((item) => {
            const sectionName = Object.keys(item)[0];
            const sectionData = item[sectionName];

            // Define the fields you want to display for each section
            let fields = [];
            switch (sectionName) {
                case 'userDetails':
                    fields = [
                        { key: 'Name', label: 'First Name', value: sectionData.FirstName + " " + sectionData.LastName },
                        { key: 'Email', label: 'Email', value: sectionData.Email },
                        { key: 'Phone', label: 'Phone Number', value: sectionData.countryCode + sectionData.Phone }
                    ];
                    break;

                case 'vehicleDetails':
                    fields = [
                        { key: 'Vehicle_sub_type__c', label: 'Vehicle Type', value: sectionData.Vehicle_sub_type__c },
                        { key: 'Year__c', label: 'Year', value: sectionData.Year__c },
                        { key: 'Value__c', label: 'Value', value: `$${sectionData.Value__c}` },
                    ];
                    break;

                case 'termOption':
                    fields = [
                        { key: 'Term__c', label: 'Term', value: sectionData.Term__c },
                        { key: 'dateRange', label: 'Date Range', value: sectionData.dateRange },
                        { key: 'Start_Time__c', label: 'Start Time', value: sectionData.Start_Time__c }
                    ];
                    break;

                default:
                    fields = [];
                    break;
            }

            // Format display values
            fields = fields.map((field) => ({
                ...field,
                displayValue: this.formatDisplayValue(field.value)
            }));

            return {
                sectionName: this.formatSectionName(sectionName),
                fields: fields
            };
        });
    }

    // Formats field values for UI display, especially handling booleans
    formatDisplayValue(value) {
        if (typeof value === 'boolean') {
            return value ? 'Yes' : 'No';
        }
        return value;
    }

    // Converts section identifiers (camelCase or snake_case) to readable titles
    formatSectionName(name) {
        return name
            .replace(/([A-Z])/g, ' $1')
            .replace(/_/g, ' ')
            .replace(/^./, (str) => str.toUpperCase())
            .trim();
    }

    handleFlagUpdate(event) {
        this.flag.isQuotePage = event.detail;
    }

    // Dynamically imports and sets the component constructor for the current step
    async loadComponent() {
        try {
            const { component } = this.steps[this.currentStep];
            // console.log('CQ Component name', component + ' Current Step: ' + this.currentStep + "Is towing: " + this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.isTowing)        

            // const { default: ctor } = await import("c/nc_userDetails");
            this.flag.isQuotePage = false;
            switch (component) {
                case 'c/nc_userDetails': {
                    const { default: ctor } = await import("c/nc_userDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_vehicleDetails': {
                    const { default: ctor } = await import("c/nc_vehicleDetails");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_termOption': {
                    const { default: ctor } = await import("c/nc_termOption");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_towed': {
                    const { default: ctor } = await import("c/nc_towed");
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_territory': {
                    const { default: ctor } = await import('c/nc_territory');
                    this.componentConstructor = ctor;                    
                    break;
                }
                case 'c/nc_quotePage': {
                    const { default: ctor } = await import('c/nc_quotePage');
                    this.componentConstructor = ctor;
                    this.flag.isQuotePage = true; // hide continue btn
                    break;
                }
                case 'c/nc_towDetails': {
                    const { default: ctor } = await import('c/nc_towDetails');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_finalizeVehicleDetails': {
                    const { default: ctor } = await import('c/nc_finalizeVehicleDetails');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_companyInformation': {
                    const { default: ctor } = await import('c/nc_companyInformation');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_lienholderInformation': {
                    const { default: ctor } = await import('c/nc_lienholderInformation');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_driverDetails': {
                    const { default: ctor } = await import('c/nc_driverDetails');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_finalDetails': {
                    const { default: ctor } = await import('c/nc_finalDetails');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_payment': {
                    const { default: ctor } = await import('c/nc_payment');
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_confirmation': {
                    const { default: ctor } = await import('c/nc_confirmation');
                    this.flag.isQuotePage = true; // hide continue btn
                    this.componentConstructor = ctor;
                    break;
                }
                case 'c/nc_feedback': {
                    const { default: ctor } = await import('c/nc_feedback');
                    this.componentConstructor = ctor;
                    break;
                }
                default:
                    console.error('Component not found:', componentName);
                    break;
            }

            this.childLoaded = true;
        } catch (err) {
            this.childLoaded = true;
            console.log('CQ -- ERROR: err.message : ', err.message);
        }
    }

    // Handles navigation between steps (next/previous), includes validation and skip logic for conditional steps
    async handleNavigation(event) {
        try {
            // console.log('CQ Navigation event triggered', event);
            let direction = event.target.dataset.direction;
            // console.log('CQ Direction', direction);
            if (direction == null || direction == undefined) {
                direction = event.detail?.direction;
                // console.log('CQ Inside if', direction);
            }
            // console.log('CQ Direction after', direction);

            if (direction === 'next') {
                // Validate the current step
                const isValid = await this.validateStep();
                console.log('CQ OUTPUT isValid: ',isValid);

                if (!isValid) {
                    console.log('CQ -- ERROR: Validation failed at:', this.steps[this.currentStep].component);
                    return true;
                }

                if (isValid) {
                    console.log('CQ OUTPUT isValid if condition: ', isValid);
                    this.childLoaded = false;
                    // Capture data and move to the next step if valid
                    try {
                        let status = await this.capturePayloadData();
                        console.log('CQ handleNavigation Status: ', status);
                    } catch (err) {
                        this.childLoaded = true;
                        console.log('CQ OUTPUT11 : ', err.message);
                    }

                    if (!this.isLastStep) {
                        this.currentStep++;
                        this.processedData = this.processSections(this.payload)

                        const { component } = this.steps[this.currentStep];                        
                        if ((component === 'c/nc_towDetails' && !this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.isTowing) || (component === 'c/nc_lienholderInformation' && !this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails?.Is_Lienholder__c)) {
                            this.currentStep++;
                            this.loadComponent();
                            return;
                        }
                    }
                } else {
                    console.log('CQ OUTPUT isValid else condition : ', isValid);
                    const { component } = this.steps[this.currentStep];
                    console.log('CQ -- ERROR:Validation failed, check the required fields in ', component);
                }
            } else if (direction === 'previous' && !this.isFirstStep) {

                //console.log('CQ Payload: On back btn click: ', JSON.stringify(this.payload));

                this.currentStep--;
                const { component } = this.steps[this.currentStep];
                // console.log('CQ Component name', component + ' Current Step: ' + this.currentStep + "Is towing: " + this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.isTowing)
                if ((component === 'c/nc_towDetails' && !this.payload.find(item => item.vehicleDetails)?.vehicleDetails?.isTowing) || (component === 'c/nc_lienholderInformation' && !this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails?.Is_Lienholder__c)) {
                    this.currentStep--;
                    this.loadComponent();
                    return;
                }
            }
            await this.loadComponent(); // Load the updated step component
        } catch (err) {
            this.childLoaded = true;
            console.log('CQ Error message', err.message);
            console.log('CQ Error stack trace', JSON, stringify(err));
        }
    }
    // Allows direct navigation to a specific step when editing from a summary/review section
    async handleEditScreen(event) {
        let step = event.target.dataset.id;
        // console.log('CQ step OUTPUT : ', step);
        this.currentStep = step;
        await this.loadComponent(); // Load the updated step component
    }

    // Validates the current step using the `validate()` method in the loaded child component
    async validateStep() {
        const currentComponent = this.getDynamicComponentInstance();
        console.log('CQ In the validate step');
        if (currentComponent) {
            console.log('CQ Inside parent validate method');
            try {
                return await currentComponent.validate();
            } catch (err) {
                this.childLoaded = true;
                console.log('CQ ERRRO message: ', err.message);
                return false;
            }
        }
        console.log('CQ Not returned any value');
        // return true; // Default to valid if no validate method is present
    }

    // Captures the current step's data from child component and updates the shared payload array
    async capturePayloadData() {
        try {
            const currentComponent = this.getDynamicComponentInstance(); // Ensure this returns the correct instance
            if (currentComponent) {

                if (currentComponent.afterValidateCheck != undefined) {
                    let result = await currentComponent.afterValidateCheck();
                    console.log('CQ afterValidateCheck : ', result);
                }

                //Set data to child component if we need any data from parent component
                // if (currentComponent.setData != undefined) {
                //     await currentComponent.setData(this.payload);
                // }

                const data = await currentComponent.getData();
                // Use the component name from the current step to create the key in the payload
                const componentName = this.steps[this.currentStep].component.split('c/nc_')[1];
                const temp = { [componentName]: data }

                const key = Object.keys(temp)[0];

                // Check if an object with the same key already exists in the payload
                const existingIndex = this.payload.findIndex(item => Object.keys(item)[0] === key);
                
                if (existingIndex !== -1) {
                    // If it exists, update the existing object
                    this.payload[existingIndex] = { ...temp };
                } else {
                    // If it doesn't exist, add it as a new object
                    this.payload = [...this.payload, { ...temp }];
                }
                console.log('After payload update in CQ',this.payload);

                // console.log('CQ capturePayloadDat a: payload in customer quote component ', JSON.stringify(this.payload));
            }
        } catch (err) {
            this.childLoaded = true;
            console.log('CQ OUTPUT : ', err.message);
        }

    }


    // Retrieves the active child component instance rendered dynamically
    getDynamicComponentInstance() {
        return this.template.querySelector('c-' + this.steps[this.currentStep].component.split('/').pop().replace(/([A-Z])/g, '-$1').toLowerCase());
    }

    handlePayloadUpdateComplete(event) {
        if (!Array.isArray(event?.detail)) return;

        // Merge array payloads while maintaining order and references
        this.payload = this.mergeArrayPayloads(this.payload, event.detail);
        //console.log('CQ Updated parent payload:', JSON.parse(JSON.stringify(this.payload)));
    }

    mergeArrayPayloads(currentPayload, newData) {
        // Create a deep copy of currentPayload to avoid mutating the original
        const mergedPayload = JSON.parse(JSON.stringify(currentPayload));

        // Create a map for quick lookup of existing items by their primary key
        const payloadMap = new Map();
        mergedPayload.forEach((item, index) => {
            const key = Object.keys(item)[0];
            if (key) payloadMap.set(key, index);
        });

        // Process each new item
        newData.forEach(newItem => {
            const key = Object.keys(newItem)[0];
            if (!key) return;

            const existingIndex = payloadMap.get(key);

            if (existingIndex !== undefined) {
                // Item exists - perform deep merge
                const existingItem = mergedPayload[existingIndex];
                mergedPayload[existingIndex] = this.deepMergeObjects(existingItem, newItem);
            } else {
                // New item - add to payload
                mergedPayload.push({ ...newItem });
                payloadMap.set(key, mergedPayload.length - 1);
            }
        });

        return mergedPayload;
    }

    // Helper method for deep merging objects
    deepMergeObjects(target, source) {
        const result = { ...target };

        for (const key in source) {
            if (source.hasOwnProperty(key)) {
                if (source[key] instanceof Object && !Array.isArray(source[key]) &&
                    target[key] instanceof Object && !Array.isArray(target[key])) {
                    // Both are objects (not arrays) - recursive merge
                    result[key] = this.deepMergeObjects(target[key], source[key]);
                } else {
                    // Overwrite with source value
                    result[key] = source[key];
                }
            }
        }

        return result;
    }


    //Update the Payload if needed
    handlePayloadUpdate(event) {
        const { updates } = event.detail;
        // console.log('CQ Event recieved in parent', event);
        // Create new payload with immutable update
        let newPayload = [...this.payload];
        // console.log('CQ New payload', JSON.stringify(newPayload));
        // Process each section update
        Object.entries(updates).forEach(([sectionName, sectionUpdates]) => {
            const sectionIndex = newPayload.findIndex(item => item[sectionName]);

            if (sectionIndex >= 0) {
                // Update existing section
                newPayload[sectionIndex] = {
                    ...newPayload[sectionIndex],
                    [sectionName]: {
                        ...newPayload[sectionIndex][sectionName],
                        ...sectionUpdates
                    }
                };
            } else {
                // Add new section
                newPayload.push({ [sectionName]: sectionUpdates });
            }
        });

        // Update the payload reactively
        this.payload = newPayload;

        // console.log('CQ Payload updated in the parent', JSON.stringify(this.payload));
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
            console.error('-- ERROR:Error in copyDataToPayload:', error.message);
            // Handle error appropriately
        }
    }


    //Creating data for the Login user
    transformData(apiResponse) {
        // Extract primary data
        const vehicles = apiResponse.vehicles || [];
        const vehicle = vehicles?.[0] || {}; // <-- Add this line
        const drivers = apiResponse.drivers || [];
        const contact = apiResponse.contact?.[0] || {};
        const towedUnits = apiResponse.towedUnits || [];

        // Transform towed units
        const transformedTowedUnits = towedUnits.map((unit, index) => ({
            Towed_Unit_Type__c: unit.Towed_Unit_Type__c || null,
            Towed_Unit_Value__c: unit.Towed_Unit_Value__c?.toString() || null,
            Days_in_Tow__c: unit.Days_in_Tow__c?.toString() || null,
            count: index + 1,
            isDeleteButton: true,
            style: "",
            Year__c: unit.Year__c || null,
            Make__c: unit.Make__c || null,
            Model__c: unit.Model__c || null,
            VIN_Number__c: unit.VIN_Number__c || null,
            Plate__c: unit.Plate__c || null,
            label: unit.Make__c + ' ' + unit.Model__c + ' ' + unit.Year__c + ' - ' + (unit.VIN_Number__c != undefined ? unit.VIN_Number__c : '') + '',
            value: unit?.Id,
            Id: unit?.Id
        }));

        const vehicleList = vehicles.map(vehicle => ({
            Id: vehicle?.Id,
            label: vehicle.Make__c + ' ' + vehicle.Model__c + ' ' + vehicle.Year__c + ' - ' + (vehicle.Vin__c != undefined ? vehicle.Vin__c : '') + '',
            value: vehicle?.Id,
            Coverage__c: 'Complete',
            Electric_Hybrid__c: vehicle.Electric_Hybrid__c || false,
            Liability__c: "300,000",
            Medical__c: "10,000/50,000",
            Year__c: vehicle.Year__c || "2025",
            Vehicle_sub_type__c: vehicle.Vehicle_Type__c || "Automobile-Van-Minivan",
            Make: vehicle.Make__c || null,
            Model: vehicle.Model__c || null,
            Value__c: vehicle.Value__c?.toString() || null,
            Vin__c: vehicle.Vin__c || null,
            Registered_Country__c: vehicle.Registered_Country__c || null,
            Registered_State__c: vehicle.Registered_State__c || null,
            licensePlate: vehicle.Registered_Plate__c || null
        }));

        const companyInfo = {
            Company_Name__c: vehicles[0]?.Company_Name__c || '',
            Company_Phone__c: vehicles[0]?.Company_Phone__c || '',
            Tax_ID__c: vehicles[0]?.Tax_ID__c || '',
            Company_Country__c: vehicles[0]?.Registered_Country__c || '',
            Company_Address__c: vehicles[0]?.Company_Address__c || '',
            Company_Zip__c: vehicles[0]?.Company_Zip__c || '',
            Company_State__c: vehicles[0]?.Company_State__c || '',
            Company_City__c: vehicles[0]?.Company_City__c || ''
        };

        
        // Helper function to determine Driver_Type__c
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

        console.log('CQ OUTPUT : ',drivers);
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

        console.log('CQ OUTPUT driverList: ',driverList);

        // Build the final structure
        return [
            {
                UserType: {
                    UserType: "Customer"
                }
            },
            {
                userDetails: {
                    Email: contact.Email || apiResponse.email || null,
                    FirstName: contact.FirstName || null,
                    Phone: contact.Phone || contact.MobilePhone || null,
                    LastName: contact.LastName || null,
                    Id: contact.Id || null,
                }
            },
            {
                vehicleDetails: {
                    Coverage__c: 'Complete', // Default value
                    towunits: [],
                    Electric_Hybrid__c: false,
                    Liability__c: "300,000", // Default value
                    Medical__c: "10,000/50,000", // Default value
                    Year__c: "2025",
                    Vehicle_sub_type__c: "Automobile-Van-Minivan",
                    Make: null,
                    Model: null,
                    Value__c: null,
                    towunitsList: transformedTowedUnits,
                    vehicleList: vehicleList
                }
            },
            {
                finalizeVehicleDetails: {
                    Electric_Hybrid__c: vehicle.Electric_Hybrid__c || false,
                    towunits: transformedTowedUnits,
                    Year__c: vehicle.Year__c || null,
                    Vehicle_sub_type__c: vehicle.Vehicle_Type__c || null,
                    Make: vehicle.Make__c || null,
                    Model: vehicle.Model__c || null,
                    Value__c: vehicle.Value__c?.toString() || null,
                    Vin__c: vehicle.Vin__c || null,
                    Registered_Country__c: vehicle.Registered_Country__c || null,
                    Registered_State__c: vehicle.Registered_State__c || null,
                    licensePlate: vehicle.Registered_Plate__c || null,
                    Is_the_vehicle_registered_to_a_business__c: vehicle.Is_the_vehicle_registered_to_a_business__c || false
                }
            },
            {
                lienholderInformation: {
                    Lienholder_Postal_Code__c: vehicle.Lienholder_Postal_Code__c || null,
                    Lienholder_City__c: vehicle.Lienholder_City__c || null,
                    Lienholder_State__c: vehicle.Lienholder_State__c || null,
                    Lienholder_Street__c: vehicle.Lienholder_Street__c || null,
                    Lienholder_Phone__c: vehicle.Lienholder_Phone__c || null,
                    Lienholder_name__c: vehicle.Lienholder_name__c || null,
                    Lienholder_Country__c: vehicle.Lienholder_Country__c || null
                }
            },
            {
                driverDetails: {
                    drivers: [],
                    companyInformation: companyInfo,
                    driverList: driverList
                }
            },
            {
                finalDetails: {
                    Newsletter__c: contact.Newsletter__c ? "Yes" : "No",
                    Terms_of_Purchase_Confirmed__c: true, // Default value
                    Terms_of_Cancellation_Confirmed__c: true, // Default value
                    What_is_your_trip_destination_in_US__c: null, // Not in original data
                    What_is_the_purpose_of_trip__c: null, // Not in original data
                    How_did_you_hear_about_us__c: contact.Source__c || null
                }
            }
        ];
    }
}