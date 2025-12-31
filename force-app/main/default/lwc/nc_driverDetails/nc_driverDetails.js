// nc_driverDetails.js (versión corregida)
import { LightningElement, track, api, wire } from 'lwc';
import getCountries from '@salesforce/apex/FinalizeVehicleDetailsFlow.getCountries';
import getStatesByCountry from '@salesforce/apex/FinalizeVehicleDetailsFlow.getStatesByCountry';
import saveDriverDetails from '@salesforce/apex/DriverDetailsFlow.saveDriverDetails';
import saveCompanyInformationDetails from '@salesforce/apex/CompanyInformationDetailFlow.saveCompanyInformationDetails';
import saveFinalizeVehicleDetails from '@salesforce/apex/FinalizeVehicleDetailsFlow.saveFinalizeVehicleDetails';
import updateQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.updateQuoteRecordData';
import Selectadriverfromyouraccount from '@salesforce/label/c.TR_Select_a_driver_from_your_account';

export default class Nc_driverDetails extends LightningElement {
    @api payload;
    ISDEBUG = true;
    @track tempDrivers = [];
    @track isSelected = false; 
    label = { Selectadriverfromyouraccount };

    @track inputValues = { drivers: [], companyInformation: {} };

    @track driver = {
        First_Name__c: '',
        Last_Name__c: '',
        License_Country__c: 'United States',
        License_state__c: '',
        license_number__c: '',
        Dob__c: '',
        Driver_Type__c: false,
        Country__c: '',
        Country_Text__c: '',
        State_Province__c: '',
        Postal_Code__c: '',
        City__c: '',
        Address__c: ''
    };
    @track selectedDriverId = '';
    
    @track flag = {
        isOwner: true,
        isCompanyDisabled: false,
        isCompanyStatus: false,
        isStateDisabled: false,
        Is_the_vehicle_registered_to_a_business__c: false
    };

    @track drivers = [];
    @track existingDriversList = [];
    @track loginUserDriverOption = [];
    @track flagForRender = true;
    @track userType;
    @track currentVehicleType ;
    @track currentStep = 'ownership';
    @track countryOptions = [];
    @track stateOptions = [];

    @track ownershipValue = 'owner';
    ownershipOptions = [
        { label: 'Human Owner', value: 'owner' },
        { label: 'Company', value: 'company' }
    ];

    // ------------------------
    // Getters
    // ------------------------
    get currentUserType() {
        if (!this.payload || !Array.isArray(this.payload)) return false;
        const existingIndex = this.payload.findIndex(item => Object.keys(item)[0] === "UserType");
        if (existingIndex !== -1) {
            this.userType = "Customer";
            return true;
        }
        return false;
    }

    get humanTitle() {
        return this.flag.isOwner || this.flag?.Is_the_vehicle_registered_to_a_business__c ? 'Add all individuals who will be operating this vehicle' : 'Add information for the registered owner of this vehicle';
    }

    get addDriverLabel() {
        if (this.flag.isOwner || this.flag?.Is_the_vehicle_registered_to_a_business__c) {
            return 'Add Driver';
        } else {
            return 'Add Owner';
        }
    }
    // get addDriverLabel() {
    //     if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
    //         return 'Add Driver';
    //     } else if (this.flag.isOwner || this.driver.Driver_Type__c) {
    //         return 'Add Driver';
    //     } else {
    //         return 'Add Owner';
    //     }
    // }

    handleEditCompany() {
        try {
            this.currentStep = 'companyDetails';
            this.isEditingCompany = true;

            try {
                sessionStorage.setItem(
                    'nc_driverDetails_snapshot',
                    JSON.stringify({
                        timestamp: Date.now(),
                        drivers: this.drivers,
                        driver: this.driver,
                        flag: this.flag,
                        currentStep: this.currentStep
                    })
                );
            } catch (e) {
                console.log('Error guardando snapshot:', e.message);
            }

        } catch (err) {
            console.error('Error al editar company:', err.message);
        }
    }

    handleOwnershipChange(event) {
        this.ownershipValue = event.detail.value;

        if (this.ownershipValue === 'company') {
            this.flag.isCompanyStatus = true;
            this.flag.isOwner = false;
            this.currentStep = 'companyDetails';
        } else {
            this.flag.isCompanyStatus = false;
            this.flag.isOwner = true;
            this.currentStep = 'humanOwner';
        }

        this.dispatchPayloadUpdate({
            finalizeVehicleDetails: {
                Is_the_vehicle_registered_to_a_business__c: this.flag.isCompanyStatus
            }
        });
    }

    editCompany() {
        this.currentStep = 'companyDetails';
    }


    // ------------------------
    dispatchPayloadUpdate(detailObj) {
        console.log('OUTPUT detailObj: ',detailObj);
        try {
            // Always send { updates: { ... } } because parent expects event.detail.updates
            this.payload = [...detailObj];
            const evt = new CustomEvent('payloadupdate', {
                detail: { updates: detailObj },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(evt);
                if (this.ISDEBUG) console.log('DD dispatched payloadupdate:', JSON.stringify({ updates: detailObj }));
            } catch (e) {
           // console.warn('dispatchPayloadUpdate error', e.message);
        }
    }

    // ------------------------
    // Combobox / driver selection helpers
    // ------------------------
    handleOptionClick(event) {
        const { inputName, value } = event.detail;
        console.log('evetdetail2@@##', event.detail);
        this.handleComboboxChange(inputName, value);
    }

    changeDriverOption(event) {
        try {
            const selectedDriverId = event.detail.value;
            this.selectedDriverId = selectedDriverId;

            const selectedDriver = this.loginUserDriverOption.find(driver => driver.value === selectedDriverId);
            if (selectedDriver) {
                this.driver = {
                    ...this.driver, 
                    Id : selectedDriver.Id || null,
                   First_Name__c: selectedDriver.First_Name__c || '',
                    Last_Name__c: selectedDriver.Last_Name__c || '',
                    License_Country__c: selectedDriver.License_Country__c || 'United States',
                    License_state__c: selectedDriver.License_state__c || '',
                    license_number__c: selectedDriver.license_number__c || '',
                    Dob__c: selectedDriver.Dob__c || '',
                    Driver_Type__c: selectedDriver.Driver_Type__c || false,
                    Country__c: selectedDriver.Country__c || '',
                    Country_Text__c: selectedDriver.Country__c || '',
                    State_Province__c: selectedDriver.State_Province__c || '',
                    Postal_Code__c: selectedDriver.Postal_Code__c || '',
                    City__c: selectedDriver.City__c || '',
                    Address__c: selectedDriver.Address__c || ''
                };

                if (this.driver.License_Country__c) {
                    this.loadStatesForCountry(this.driver.License_Country__c);
                }
                this.isCompanyOrDriverOwner();
            }
            if (selectedDriver && selectedDriver.Driver_Type__c === false || selectedDriver.Driver_Type__c === 'Driver') {
                this.flag.isOwner = true;
            } else {
                this.flag.isOwner = false;
                this.flag.Is_the_vehicle_registered_to_a_business__c = false;
            }
        } catch (error) {
            console.error('Error changing driver option:', error);
        }
    }

    handleComboboxChange(fieldName, value) {
        this.driver = { ...this.driver, [fieldName]: value };
        if (fieldName === 'License_Country__c') {
            this.driver.License_state__c = '';
            this.loadStatesForCountry(value);
        }

        this.isCompanyOrDriverOwner();
    }
    handleChildComboboxReset() {
        this.handleComboboxReset('License_Country__c');
    }

    handleComboboxReset(value) {
        if (value === 'License_Country__c') {
            const comboboxes = this.template.querySelectorAll('c-nc_combobox');
            if (comboboxes) {
                comboboxes.forEach((combobox) => {
                    if (combobox.inputLabel === 'License State') {
                        combobox.handleReset();
                    }
                });
                this.driver.License_state__c = '';
                this.loadStatesForCountry(value);
            }
        }
    }
    // ------------------------
    // Country / State wiring
    // ------------------------
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            this.countryOptions = data.map(country => ({ label: country, value: country }));
            this.loadStatesForCountry(this.driver.License_Country__c || 'United States');
        } else if (error) {
            console.error('Error loading countries', error);
        }
    }

    loadStatesForCountry(country) {
        if (country) {
            this.flag.isStateDisabled = true;
            getStatesByCountry({ country: country })
                .then(result => {
                    this.stateOptions = result.map(state => ({ label: state, value: state }));
                    this.flag.isStateDisabled = false;

                    if (this.driver.License_Country__c === country && this.driver.License_state__c) {
                        const stateExists = this.stateOptions.some(opt => opt.value === this.driver.License_state__c);
                        if (!stateExists) {
                            this.driver.License_state__c = '';
                        }
                    } else {
                        this.driver.License_state__c = '';
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.stateOptions = [];
                    this.flag.isStateDisabled = false;
                    this.driver.License_state__c = '';
                });
        } else {
            this.stateOptions = [];
            this.flag.isStateDisabled = true;
            this.driver.License_state__c = '';
        }
    }

    // ------------------------
    // Validators / helpers
    // ------------------------
    get minDateAllowed() {
        let today = new Date();
        today.setFullYear(today.getFullYear() - 16);
        return today.toISOString().split('T')[0];
    }

    validateDriver() {
        const inputs = this.template.querySelectorAll('input, c-nc_combobox, lightning-input, lightning-combobox');
        let allValid = true;

        inputs.forEach(input => {
            if (input && input.required && typeof input.checkValidity === 'function' && !input.checkValidity()) {
                try { input.reportValidity(); } catch (e) { }
                allValid = false;
            }
        });
        console.log('this.driverlicesn@@#',this.driver)
        if (!allValid) {
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Some required fields are invalid.' } }));
            return false;
        }

        if (!this.driver.First_Name__c || !this.driver.Last_Name__c) {
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'First and Last name are required' } }));
            return false;
        }
        if (!this.driver.license_number__c) {
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'License number is required' } }));
            return false;
        }
        if (!this.driver.License_state__c) {
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'License state is required' } }));
            return false;
        }
        return true;
    }

    // ------------------------
    // Main change handler (single place to touch flags)
    // ------------------------
    handleChange(event) {
        try {
            console.log('inside handle change');
            const { name, checked, value, type } = event.target;
            
            // Avoid handling combobox custom events here
            if (name === 'License_Country__c' || name === 'License_state__c') {
                return;
            }

            // Company checkbox handling - DO NOT change isOwner here
            if (name === 'Is_the_vehicle_registered_to_a_business__c') {
                this.flag.isCompanyStatus = checked;
                this.flag.Is_the_vehicle_registered_to_a_business__c = checked;

                // Change step based on checkbox
                this.currentStep = checked ? 'companyDetails' : 'humanOwner';

                // Only adjust options (do not alter driver/owner fields here)
                if (checked) {
                    this.loginUserDriverOption = [
                        { label: '-- Select a Driver --', value: '' },
                        ...this.existingDriversList.filter(d => !d.Driver_Type__c)
                    ];
                } else {
                    this.loginUserDriverOption = [
                        { label: '-- Select a Driver --', value: '' },
                        ...this.existingDriversList
                    ];
                }

                // Persist change into payload & notify parent (wrap in updates)
                try {
                    const newPayload = JSON.parse(JSON.stringify(this.payload || []));
                    
                    const finalizeIndex = newPayload.findIndex(item => item.finalizeVehicleDetails);
                    if (finalizeIndex >= 0) {
                        newPayload[finalizeIndex].finalizeVehicleDetails = {
                            ...newPayload[finalizeIndex].finalizeVehicleDetails,
                            Is_the_vehicle_registered_to_a_business__c: checked
                        };
                    } else {
                        newPayload.push({
                            finalizeVehicleDetails: {
                                Is_the_vehicle_registered_to_a_business__c: checked
                            }
                        });
                    }
                    this.payload = newPayload;
                } catch (e) {
                    console.warn('error', e.message);
                    // if cloning fails, we'll still dispatch the update below
                }
                this.dispatchPayloadUpdate({
                    finalizeVehicleDetails: {
                        Is_the_vehicle_registered_to_a_business__c: checked
                    }
                });

                // Snapshot
                this.saveSnapshot();

                return;
            }

            // license number uppercase / maxlength
            if (name === 'license_number__c') {
                let upperValue = (value || '').toUpperCase();
                if (upperValue.length > 17) upperValue = upperValue.substring(0, 17);
                this.driver = { ...this.driver, [name]: upperValue };
                this.isCompanyOrDriverOwner();
                return;
            }

            // Registered Owner checkbox change (only updates driver object)
            if (name === 'Driver_Type__c') {
                this.driver = { ...this.driver, [name]: checked };
                this.isCompanyOrDriverOwner();
                return;
            }

            // Default - update driver fields
            this.driver = { ...this.driver, [name]: type === 'checkbox' ? checked : value };

            if (name === 'License_Country__c') {
                this.driver.License_state__c = '';
                this.loadStatesForCountry(value);
            }
            if(name === 'Country__c'){
                this.driver = {
                    ...this.driver, 
                    Country_Text__c: event.target.value || ''
                };
            }
            console.log('this.driverr@###', this.driver);
           this.isCompanyOrDriverOwner();
        } catch (err) {
            console.log('DD ERROR: ', err.message);
        }
    }

    // ------------------------
    // Snapshot helper
    // ------------------------
    saveSnapshot() {
        try {
            sessionStorage.setItem('nc_driverDetails_snapshot', JSON.stringify({
                timestamp: Date.now(),
                drivers: this.drivers,
                driver: this.driver,
                flag: this.flag,
                currentStep: this.currentStep
            }));
        } catch (e) {
            if (this.ISDEBUG) console.warn('saveSnapshot error', e);
        }
    }

    // ------------------------
    // Navigation helpers
    // ------------------------
    validateOwnerOrCompany() {
        if (!this.flag.Is_the_vehicle_registered_to_a_business__c && !this.driver.Driver_Type__c) {
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: {
                    variant: 'error',
                    title: 'Selection Required',
                    message: 'Please select either a Human Owner or Company before proceeding.'
                }
            }));
            return false;
        }
        return true;
    }

    // goToDriverForm() {        
    //     const childCmp = this.template.querySelector('c-nc_company-information');
    //     console.log('childCmp.validateInputs: ', childCmp.validateInputs);

    //     if (childCmp && typeof childCmp.validateInputs === 'function' && !childCmp.validateInputs()) {
    //         console.log('Enter company information');
    //         this.dispatchEvent(new CustomEvent('toastevent', {
    //             detail: { variant: 'error', title: 'Error', message: '⚠️ Company Information is invalid.' }
    //         }));            
    //         return;
    //     }  else {
    //         console.log('OUTPUT : in else ondition');
    //     }
    //     this.currentStep = 'humanOwner';     
          
    // }

    goToDriverForm() {
      
        if(this.currentStep === 'companyDetails'){
           
            for (let i = 0; i < this.drivers.length; i++) {
                let driv = this.drivers[i]; 

                console.log(i, ':: ', driv?.Driver_Type__c, ' ');

                if (driv?.Driver_Type__c === true || driv?.Driver_Type__c ==='Owner' || driv?.Driver_Type__c ==='Co-Owner'|| driv?.Driver_Type__c ==='Owner & Driver') {
                    this.tempDrivers.push(driv);
                    
                    this.drivers.splice(i, 1);
                    i--; // Adjust index since the array has shrunk
                }
            }
            

        }
            
        // Since we're already in the company information step, we know the component exists
        const childCmp = this.template.querySelector('c-nc_company-information');

        // Add debug logging to see what's happening
        console.log('childCmp:', childCmp);
        console.log('validateInputs exists:', childCmp && typeof childCmp.validateInputs);
        try {


            if (childCmp && typeof childCmp.validateInputs === 'function') {
                console.log('OUTPUT : check passed ');
                const isValid = childCmp.validateInputs();
                console.log('Validation result:', isValid);

                if (!isValid) {
                    console.log('Company information is invalid');
                    this.dispatchEvent(new CustomEvent('toastevent', {
                        detail: { variant: 'error', title: 'Error', message: '⚠️ Company Information is invalid.' }
                    }));
                    return;
                }

                // If validation passes, proceed to next step
                console.log('Validation passed, proceeding to driver form');
                this.currentStep = 'humanOwner';
                this.driver.Driver_Type__c = false;
                if(this.currentVehicleType !=='personal'){
                    this.flag.Is_the_vehicle_registered_to_a_business__c = true;
                }
            } else {
                // Fallback: if component or method not available, still proceed
                console.log('Component or validateInputs not available, proceeding anyway');
                this.currentStep = 'humanOwner';
            }
        } catch (err) {
            console.log('OUTPUT : ', err.message);
        }
    }

    // goToDriverForm() {
    //     if (!this.validateOwnerOrCompany()) return;
    //     this.currentStep = 'humanOwner';
    // }
    //     goBack() {
    //     // Volver al step inicial
    //     this.currentStep = 'ownership';

    //     // Reset flags
    //     this.flag.isCompanyStatus = false;
    //     this.flag.Is_the_vehicle_registered_to_a_business__c = false;

    //     // Reset driver a valores por defecto
    //     this.driver = {
    //         First_Name__c: '',
    //         Last_Name__c: '',
    //         License_Country__c: 'United States',
    //         License_state__c: '',
    //         license_number__c: '',
    //         Dob__c: (() => {
    //             let today = new Date();
    //             today.setFullYear(today.getFullYear() - 16);
    //             return today.toISOString().split('T')[0];
    //         })(),
    //         Driver_Type__c: false,
    //         Country__c: '',
    //         Country_Text__c: '',
    //         State_Province__c: '',
    //         Postal_Code__c: '',
    //         City__c: '',
    //         Address__c: ''
    //     };

    //     // Reset combobox
    //     this.loginUserDriverOption = [
    //         { label: '-- Select a Driver --', value: '' },
    //         ...this.existingDriversList
    //     ];

    //     // Notificar al padre para actualizar payload
    //     this.dispatchPayloadUpdate({
    //         finalizeVehicleDetails: {
    //             Is_the_vehicle_registered_to_a_business__c: false
    //         }
    //     });

    //     // Guardar snapshot
    //     this.saveSnapshot();
    // }


    get isStepCompanyDetails() { return this.currentStep === 'companyDetails'; }
    get isStepHumanOwner() { return this.currentStep === 'humanOwner'; }

    // ------------------------
    // Drivers List / Add / Edit / Delete
    // ------------------------
    addDriver() {
        if (!this.validateDriver()) return;
        if(this.drivers.length >0){
                const isDuplicate = this.drivers.some(driver => 
                driver.license_number__c === this.driver.license_number__c 
            );
            if(isDuplicate){
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: {
                        variant: 'error',
                        title: 'Duplicate License',
                        message: 'You cannot add a driver with the same license number.'
                    }
                    }));
                    return ;
            }
        }
        
       if (this.driver.First_Name__c && this.driver.Last_Name__c) {
            this.drivers = [...this.drivers, { ...this.driver, diff: Date.now() }];

            this.reCheckDriverOwnerOnChange();

            // reset form
            this.driver = {
                First_Name__c: '',
                Last_Name__c: '',
                License_Country__c: 'United States',
                License_state__c: '',
                license_number__c: '',
                Dob__c: '',
                Driver_Type__c: false,
                Country__c: '',
                Country_Text__c: '',
                State_Province__c: '',
                Postal_Code__c: '',
                City__c: '',
                Address__c: ''
            };

            // notify parent with consistent shape
            this.dispatchPayloadUpdate({
                driverDetails: {
                    drivers: this.drivers,
                    driverList: this.existingDriversList,
                    companyInformation: this.inputValues.companyInformation || {}
                }
            });

            this.saveSnapshot();
        }
    }

    editDriver(event) {
        const index = parseInt(event.target.dataset.index, 10);
        if (isNaN(index)) return;
        const driverToEdit = this.drivers[index];
        if (driverToEdit) {
            this.driver = { ...driverToEdit };
            if (this.driver && (this.driver.Driver_Type__c === false || this.driver.Driver_Type__c === 'Driver')) {
                this.flag.isOwner = true;
            } else {
                this.flag.isOwner = false;
                this.flag.Is_the_vehicle_registered_to_a_business__c = false;
            }
            this.drivers = this.drivers.filter((_, i) => i !== index);
            this.isCompanyOrDriverOwner();
            this.dispatchPayloadUpdate({
                driverDetails: {
                    drivers: this.drivers,
                    driverList: this.existingDriversList,
                    companyInformation: this.inputValues.companyInformation || {}
                }
            });
        }
    }

    deleteDriver(event) {
        const index = parseInt(event.target.dataset.index, 10);
        if (isNaN(index)) return;
        this.drivers = this.drivers.filter((_, i) => i !== index);
        this.reCheckDriverOwnerOnChange();
        this.dispatchPayloadUpdate({
            driverDetails: {
                drivers: this.drivers,
                driverList: this.existingDriversList,
                companyInformation: this.inputValues.companyInformation || {}
            }
        });
        this.saveSnapshot();
    }

    updateLoginUserDriverOption() {
        const hasOwner = this.drivers?.some(driver => driver.Driver_Type__c === true || driver.Driver_Type__c ==='Owner' || driver.Driver_Type__c ==='Co-Owner'|| driver.Driver_Type__c ==='Owner & Driver');
        const isBusinessVehicle = this.flag?.Is_the_vehicle_registered_to_a_business__c === true;

        if (hasOwner || isBusinessVehicle) {
            this.loginUserDriverOption = this.existingDriversList.filter(driver => !driver.Driver_Type__c);
        } else {
            this.loginUserDriverOption = [
                { label: '-- Select a Driver --', value: '' },
                ...this.existingDriversList
            ];
        }
        this.isShowOwnerAndDriverInfo();
    }

    isCompanyOrDriverOwner() {
        const hasDriverOwner = this.drivers.some(d => d.Driver_Type__c === true || d.Driver_Type__c ==='Owner' || d.Driver_Type__c ==='Co-Owner'|| d.Driver_Type__c ==='Owner & Driver');
        // base isOwner only on added drivers
        const hasUserStartingWith = this.payload.some(item => item?.userDetails?.Id?.startsWith("003"));
        if(!hasUserStartingWith){
            this.flag.isOwner = hasDriverOwner;
        }
       this.flag.isCompanyDisabled = hasDriverOwner;

        this.updateLoginUserDriverOption();
    }
    isShowOwnerAndDriverInfo(){
       
        if (this.ISDEBUG) console.log('Payload Data:>>>', JSON.stringify(this.payload));
        if(this.payload){
            const driverPayload = this.payload.find(item => item?.driverDetails)?.driverDetails;
            const hasUserStartingWith = this.payload.some(item => item?.userDetails?.Id?.startsWith("003"));
            const companyPayload = driverPayload?.companyInformation;
            const OwnerDrivers = driverPayload?.driverList || [];
            const existingDrivers = driverPayload?.drivers || [];
    
           
            if (Array.isArray(OwnerDrivers) && OwnerDrivers.length > 0 &&  typeof companyPayload === 'object' && companyPayload && !companyPayload.Company_Name__c ) {
                // Filter owners
                const hasDriverOwner = this.drivers.some(d => d.Driver_Type__c === true || d.Driver_Type__c ==='Owner' || d.Driver_Type__c ==='Co-Owner'|| d.Driver_Type__c ==='Owner & Driver');
                
                if(!hasDriverOwner){
                this.existingOwnerList = OwnerDrivers
                    .filter(d => d.Driver_Type__c === true || d.Driver_Type__c ==='Owner' || d.Driver_Type__c ==='Co-Owner'|| d.Driver_Type__c ==='Owner & Driver')
                    .map(d => ({
                        ...d,
                        label: `${d.First_Name__c} ${d.Last_Name__c}`,
                        value: d.Id || `temp-${Math.random().toString(36).substr(2, 9)}`
                    }));
                    this.loginUserDriverOption = [
                        { label: '-- Select an Owner --', value: '' },
                        ...this.existingOwnerList
                    ];
                }
                    else if(hasDriverOwner && companyPayload && typeof companyPayload === 'object' &&  companyPayload.Company_Name__c && companyPayload.Company_Name__c.trim() !== ''){
                        this.existingDriverList = OwnerDrivers
                            .filter(d => d.Driver_Type__c === false || d.Driver_Type__c ==='Driver')
                            .map(d => ({
                                ...d,
                                label: `${d.First_Name__c} ${d.Last_Name__c}`,
                                value: d.Id || `temp-${Math.random().toString(36).substr(2, 9)}`
                            }));
                            this.loginUserDriverOption = [
                            { label: '-- Select a Driver --', value: '' },
                            ...this.existingDriverList
                        ];
                    }
                
            }
            else if(companyPayload && typeof companyPayload === 'object' &&  companyPayload.Company_Name__c && companyPayload.Company_Name__c.trim() !== '' && this.currentVehicleType !=='personal' && this.currentVehicleType !==undefined){
                // Filter drivers (store for later)
                this.existingDriverList = OwnerDrivers
                    .filter(d => d.Driver_Type__c === false || d.Driver_Type__c ==='Driver')
                    .map(d => ({
                        ...d,
                        label: `${d.First_Name__c} ${d.Last_Name__c}`,
                        value: d.Id || `temp-${Math.random().toString(36).substr(2, 9)}`
                    }));

                // Set only owner options initially
                this.loginUserDriverOption = [
                    { label: '-- Select a Driver --', value: '' },
                    ...this.existingDriverList
                ];
                this.flag.Is_the_vehicle_registered_to_a_business__c = true;
                if(this.currentVehicleType ==='personal'){
                    this.driver.Driver_Type__c = true;
                }
            } 
            else if(Array.isArray(OwnerDrivers) && OwnerDrivers.length ===0 && Array.isArray(existingDrivers) && existingDrivers.length ===0 && this.currentVehicleType !== undefined && this.currentVehicleType !=='personal' && this.currentVehicleType !== 'business'){
                this.driver.Driver_Type__c = true;
            } 
            else if(Array.isArray(OwnerDrivers) && OwnerDrivers.length ===0 && Array.isArray(existingDrivers) && existingDrivers.length ===0 && this.currentVehicleType ==='personal' &&  typeof companyPayload === 'object' && companyPayload && !companyPayload.Company_Name__c && !this.flag.isOwner){
                this.driver.Driver_Type__c = true;
            }
            
            else if(!this.flag.isOwner && !hasUserStartingWith && this.currentVehicleType !== 'business' && !this.flag?.Is_the_vehicle_registered_to_a_business__c){
                this.driver.Driver_Type__c = true;
            } else if(this.flag?.Is_the_vehicle_registered_to_a_business__c && Array.isArray(OwnerDrivers) && OwnerDrivers.length ===0){
                this.isSelected = true;
            } else if(hasUserStartingWith && this.flag?.Is_the_vehicle_registered_to_a_business__c && !this.flag.isCompanyStatus){
                this.isSelected = true;
            } else if(hasUserStartingWith && this.flag?.Is_the_vehicle_registered_to_a_business__c && companyPayload && typeof companyPayload === 'object' &&  companyPayload.Company_Name__c && companyPayload.Company_Name__c.trim() !== ''){
                this.isSelected = true;
            }
        }
    }
    // ------------------------
    // Company address handler
    // ------------------------
    handleCompanyAddress(event) {
        try {
            const fetchaddress = JSON.parse(event.detail);
            if (this.ISDEBUG) console.log('Received address data:', fetchaddress);

            this.driver = {
                ...this.driver,
                Driver_Type__c: true,
                Country__c: fetchaddress.Country || fetchaddress.country || '',
                Country_Text__c: fetchaddress.Country || fetchaddress.country || '',
                State_Province__c: fetchaddress.State || fetchaddress.state || fetchaddress.administrative_area_level_1 || '',
                Postal_Code__c: fetchaddress.PostalCode || fetchaddress.postalCode || fetchaddress.postal_code || '',
                City__c: fetchaddress.City || fetchaddress.city || fetchaddress.locality || '',
                Address__c: fetchaddress.Address || fetchaddress.address || (fetchaddress.streetNumber && fetchaddress.route ? `${fetchaddress.streetNumber} ${fetchaddress.route}` : fetchaddress.formatted_address) || ''
            };

            const companyInformation = {
                Company_Name__c: fetchaddress.companyName || this.inputValues?.companyInformation?.Company_Name__c || '',
                Company_Phone__c: fetchaddress.companyPhone || this.inputValues?.companyInformation?.Company_Phone__c || '',
                Company_Address__c: fetchaddress.Address || fetchaddress.address || fetchaddress.formatted_address || '',
                Company_Country__c: fetchaddress.Country || '',
                Company_State__c: fetchaddress.State || '',
                Company_City__c: fetchaddress.City || '',
                Company_Zip__c: fetchaddress.PostalCode || fetchaddress.postalCode || ''
            };

            const businessAddressObj = {
                Country__c: companyInformation.Company_Country__c || '',
                State_Province__c: companyInformation.Company_State__c || '',
                Postal_Code__c: companyInformation.Company_Zip__c || '',
                City__c: companyInformation.Company_City__c || '',
                Address__c: companyInformation.Company_Address__c || ''
            };

            this.inputValues = {
                ...this.inputValues,
                companyInformation
            };
            console.log('inputValues22@###',this.inputValues);
            // Merge locally best-effort
            try {
                const newPayload = JSON.parse(JSON.stringify(this.payload || []));
                console.log('payload685@@', this.payload);
                const di = newPayload.findIndex(it => it.driverDetails);
                if (di >= 0) {
                    newPayload[di].driverDetails = {
                        ...newPayload[di].driverDetails,
                        companyInformation,
                        drivers: this.drivers,
                        driverList: this.existingDriversList
                    };
                } else {
                    newPayload.push({ driverDetails: { companyInformation, drivers: this.drivers, driverList: this.existingDriversList } });
                }
                const fi = newPayload.findIndex(it => it.finalizeVehicleDetails);
                if (fi >= 0) {
                    newPayload[fi].finalizeVehicleDetails = {
                        ...newPayload[fi].finalizeVehicleDetails,
                        BusinessAddress__c: businessAddressObj,
                        Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c || false
                    };
                } else {
                    newPayload.push({ finalizeVehicleDetails: { BusinessAddress__c: businessAddressObj, Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c || false } });
                }
                this.payload = newPayload;
            } catch (e) {
                console.warn('Could not merge payload locally in handleCompanyAddress', e.message);
            }

            this.dispatchPayloadUpdate({
                driverDetails: {
                    drivers: this.drivers,
                    driverList: this.existingDriversList,
                    companyInformation
                },
                finalizeVehicleDetails: {
                    BusinessAddress__c: businessAddressObj,
                    Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c || false
                }
            });

            this.isCompanyOrDriverOwner();
        } catch (error) {
            console.error('Error handling company address:', error);
        }
    }

    // ------------------------
    // Lifecycle: connected / persist / restore
    // ------------------------
    connectedCallback() {
        if (this.ISDEBUG) console.log('DD OUTPUT -- Payload Data: ', JSON.stringify(this.payload));

        // Restore snapshot
        try {
            const raw = sessionStorage.getItem('nc_driverDetails_snapshot');
            if (raw) {
                const snap = JSON.parse(raw);
                if (snap && Date.now() - snap.timestamp < 1000 * 60 * 30) {
                    if (this.ISDEBUG) console.info('Restoring state from sessionStorage snapshot');
                    this.drivers = snap.drivers || this.drivers;
                    this.driver = { ...this.driver, ...(snap.driver || {}) };
                    this.flag = { ...this.flag, ...(snap.flag || {}) };
                    this.currentStep = snap.currentStep || this.currentStep;
                }
            }
        } catch (e) {
            console.warn('Error restoring snapshot', e.message);
        }

        if (!this.driver.License_Country__c) {
            this.driver.License_Country__c = 'United States';
        }
        this.loadStatesForCountry(this.driver.License_Country__c || 'United States');

        if (this.payload) {
            const driverPayload = this.payload.find(item => item?.driverDetails)?.driverDetails;
            const companyPayload = driverPayload?.companyInformation;
            console.log('companyPayload@@##', companyPayload);
            const existingDrivers = driverPayload?.driverList || [];
            const hasdriversInfo = driverPayload?.drivers || [];
            this.existingDriversList = existingDrivers.map(d => ({
                ...d,
                label: `${d.First_Name__c} ${d.Last_Name__c}`,
                value: d.Id || `temp-${Math.random().toString(36).substr(2, 9)}`
            }));

            this.loginUserDriverOption = [
                { label: '-- Select a Driver --', value: '' },
                ...this.existingDriversList
            ];

            const allDriverData = this.payload.find(item => item?.driverDetails)?.driverDetails;
            const addedDrivers = allDriverData?.drivers || [];
            if ((!this.drivers || this.drivers.length === 0) && addedDrivers.length > 0) {
                this.drivers = [...addedDrivers];
            }

            const finalVehicleDetails = this.payload.find(item => item.finalizeVehicleDetails)?.finalizeVehicleDetails;
            if (finalVehicleDetails) {
                if (this.flag.Is_the_vehicle_registered_to_a_business__c === undefined || this.flag.Is_the_vehicle_registered_to_a_business__c === false) {
                    this.flag.Is_the_vehicle_registered_to_a_business__c = finalVehicleDetails.Is_the_vehicle_registered_to_a_business__c || false;
                    this.flag.isCompanyStatus = finalVehicleDetails.Is_the_vehicle_registered_to_a_business__c || false;
                    this.currentStep = this.flag.isCompanyStatus ? 'companyDetails' : 'humanOwner';
                }
            }
           
            if(companyPayload && Object.keys(companyPayload).length > 0 && companyPayload?.Company_Name__c?.trim() && Array.isArray(hasdriversInfo) && hasdriversInfo.length ===0){
               this.isSelected = true;
                this.currentStep = 'companyDetails';
            }else if(companyPayload && Object.keys(companyPayload).length > 0 && companyPayload?.Company_Name__c?.trim() && Array.isArray(this.existingDriversList) && this.existingDriversList.length >0){
                const hasAccountDriver = this.existingDriversList.some(
                    driver => !!driver.Account_Driver__c
                );
                if(hasAccountDriver){
                    this.isSelected = true;
                    this.currentStep = 'companyDetails'
                } else if(!hasAccountDriver && this.currentVehicleType !==undefined){
                    this.isSelected = false;
                    this.currentStep = 'humanOwner';
                }
               
           }
           if ((!this.driver.First_Name__c || !this.driver.Last_Name__c) && driverPayload?.drivers?.length > 0) {
                const lastDriver = driverPayload.drivers[driverPayload.drivers.length - 1];
                this.driver.First_Name__c = lastDriver.First_Name__c || this.driver.First_Name__c;
                this.driver.Last_Name__c = lastDriver.Last_Name__c || this.driver.Last_Name__c;
                this.driver.license_number__c = lastDriver.license_number__c || this.driver.license_number__c;
                if (lastDriver.License_Country__c) {
                    this.driver.License_Country__c = lastDriver.License_Country__c;
                    this.loadStatesForCountry(lastDriver.License_Country__c);
                    setTimeout(() => {
                        this.driver.License_state__c = lastDriver.License_state__c || this.driver.License_state__c;
                    }, 300);
                }
            }

            const user = this.payload.find(i => i.userDetails)?.userDetails;
            if (user) {
                this.driver.First_Name__c = this.driver.First_Name__c || user.FirstName || '';
                this.driver.Last_Name__c = this.driver.Last_Name__c || user.LastName || '';
            }
        }

        if (!this.driver.Dob__c) {
            let today = new Date();
            today.setFullYear(today.getFullYear() - 16);
            this.driver.Dob__c = today.toISOString().split('T')[0];
        }

        if (typeof this.isCompanyOrDriverOwner === 'function') {
            this.isCompanyOrDriverOwner();
        }
    }

    disconnectedCallback() {
        try {
            const snapshot = {
                timestamp: Date.now(),
                drivers: this.drivers || [],
                driver: this.driver || {},
                flag: this.flag || {},
                currentStep: this.currentStep || 'ownership'
            };
            sessionStorage.setItem('nc_driverDetails_snapshot', JSON.stringify(snapshot));
        } catch (e) {
            console.warn('disconnectedCallback: sessionStorage error', e);
        }
    }

    renderedCallback() {
        if (this.payload && this.payload.length > 0 && this.flagForRender) {
            this.flagForRender = false;
        }
    }

    // ------------------------
    // Save driver data (Apex)
    // ------------------------
    async handleDriverDataSave() {
        console.log('I am in the handleDriverDataSave');
        if (!this.currentUserType) {
            try {
                console.log(' I am in the current user type')
                await saveDriverDetails({ strLeadDetails: JSON.stringify(this.payload) });
            } catch (err) {
                console.log('DD ERROR: Getting error while saving the Driver Data: ', JSON.stringify(err));
                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: JSON.stringify(err) } }));
            }
        } else {
            // customer path (updateQuoteRecordData)
            const quotePageObj = this.payload.find(item => item.quotePage);
            const quoteRecord = quotePageObj ? quotePageObj.quotePage.QuoteData : null;

            const vehicleDetailsObj = this.payload.find(item => item.finalizeVehicleDetails);
            const vehicleRecord = vehicleDetailsObj ? vehicleDetailsObj.finalizeVehicleDetails : null;

            const updatedVehicleData = { ...this.processVehicleData(vehicleRecord) };

            const driverDetailsObj = this.payload.find(item => item.driverDetails);
            const driversRecord = driverDetailsObj?.driverDetails?.drivers?.length > 0
                ? driverDetailsObj.driverDetails.drivers
                : '';
            
            console.log('String Data',driversRecord);

            try {
                const updateVehicleResp = await updateQuoteRecordData({
                    quoteRecord: quoteRecord ? JSON.stringify(quoteRecord) : '',
                    vehicleRecord: vehicleRecord ? JSON.stringify(updatedVehicleData) : '',
                    towedUnitRecord: '',
                    driversRecord: driversRecord ? JSON.stringify(driversRecord) : ''
                });

                if (updateVehicleResp.status == 'success') {
                    if (updateVehicleResp && Array.isArray(updateVehicleResp.DriversData)) {
                        updateVehicleResp.DriversData = updateVehicleResp.DriversData.map(driver => {
                            let type = String(driver.Driver_Type__c || '').toLowerCase();
                            return {
                                ...driver,
                                Driver_Type__c: type === 'true' || type === 'owner'
                            };
                        });
                    }

                    this.inputValues = {
                        ...this.inputValues,
                        drivers: updateVehicleResp.DriversData ? [...updateVehicleResp.DriversData] : [...this.drivers],
                        companyInformation: this.inputValues.companyInformation || {}
                    };
                }
            } catch (err) {
                console.error('Error updating quote record data', err);
            }
        }
    }

    handleCompanyInfoUpdate(event) {
        console.log('Company Information1 : ',event.detail);
        this.inputValues = {
            ...this.inputValues,
            companyInformation: event.detail.companyInformation
        };
        console.log('All data with cmpy info : ',this.inputValues.companyInformation);
        
        try{
        this.payload = (this.payload || []).map(item => {
            if (item.driverDetails) {
                return {
                    ...item,
                    driverDetails: {
                        ...item.driverDetails,
                        companyInformation: this.inputValues.companyInformation
                    }
                };
            }
            return item;
        });
        console.log('this.payload@@#######',this.payload);
    }catch(error){
        console.log('error :: ',error.message);
    }
        console.log('OUTPUT 111: ',this.payload);
    }

    async handleCompanyDataSave() {
        try {
            console.log('I am in the company data save',this.payload);
            const result = await saveCompanyInformationDetails({ strLeadDetails: JSON.stringify(this.payload) });
            if (result.Status === 'Success') {
                if (this.ISDEBUG) console.log('DD Company data inserted successfully', result);
            } else {
                console.error('DD ERROR: Error in inserting Company data', result);
            }
        } catch (error) {
            if (this.ISDEBUG) console.error('Error in inserting vehicle data', error);
        }
    }

    validateDriverFields() { return this.validateDriver(); }

    goToCompanyDetails() {
        this.flag.isCompanyStatus = true;
        this.flag.Is_the_vehicle_registered_to_a_business__c = true;
        this.currentStep = 'companyDetails';

        this.loginUserDriverOption = [
            { label: '-- Select a Driver --', value: '' },
            ...this.existingDriversList.filter(d => !d.Driver_Type__c)
        ];
        console.log('loginUserDriverOption@@## ',this.loginUserDriverOption);
        console.log('OUTPUT edit cmpy data: ',this.payload);

        try {
            const newPayload = JSON.parse(JSON.stringify(this.payload || []));
            const finalizeIndex = newPayload.findIndex(it => it.finalizeVehicleDetails);
            const finalizeUpdate = { Is_the_vehicle_registered_to_a_business__c: true };
            if (finalizeIndex >= 0) {
                newPayload[finalizeIndex].finalizeVehicleDetails = {
                    ...newPayload[finalizeIndex].finalizeVehicleDetails,
                    ...finalizeUpdate
                };
            } else {
                newPayload.push({ finalizeVehicleDetails: finalizeUpdate });
            }
            console.log('OUTPUT newPayload: ',newPayload);
            console.log('OUTPUT this.inputValues: ',this.inputValues);
            // New code added  *****************************************************************
            this.payload = [
                ...newPayload,                
                {
                    driverDetails: {
                        drivers: this.drivers,
                        driverList: this.existingDriversList,
                        companyInformation: this.inputValues.companyInformation || {}
                    }
                }
            ];
        } catch (e) {
            console.log('ERROR: ', e.message);
        }

        // this.dispatchPayloadUpdate({
        //     finalizeVehicleDetails: {                
        //         Is_the_vehicle_registered_to_a_business__c: true
        //     }
        // });

        this.dispatchPayloadUpdate({
            driverDetails: {
                drivers: this.drivers,
                driverList: this.existingDriversList,
                companyInformation: this.inputValues.companyInformation || {}
            },
            finalizeVehicleDetails: {
                Is_the_vehicle_registered_to_a_business__c: true
            }
        });
    }


    // Validate all the condition when user click on continue button
    @api validate() {
        let allValid = true;
        console.log('OUTPUT Flag : ',this.flag.Is_the_vehicle_registered_to_a_business__c);

        // If vehicle is registered to a business:
        // - company child component must be valid
        // - there must be at least one driver (human operator) AND
        //   none of the drivers should be marked as Owner (Driver_Type__c === true)
        if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
            console.log('OUTPUT in the condition: ');
            const childCmp = this.template.querySelector('c-nc_company-information');

            const hasAtLeastOneDriver = this.drivers.length > 0;
            const hasAnyOwnerMarked = this.drivers.some(driver => driver.Driver_Type__c === true || driver.Driver_Type__c ==='Owner' || driver.Driver_Type__c ==='Co-Owner'|| driver.Driver_Type__c ==='Owner & Driver');

            if (!hasAtLeastOneDriver) {
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: '⚠️ Please add at least one driver for company-registered vehicle.' }
                }));
                allValid = false;
            } else if (hasAnyOwnerMarked) {
                // If any driver is marked as owner while vehicle is company-registered, that's invalid
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: '⚠️ For company-registered vehicles, human drivers must NOT be marked as Owner.' }
                }));
                allValid = false;
            } else if (childCmp && typeof childCmp.validateInputs === 'function' && !childCmp.validateInputs()) {
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: '⚠️ Company Information is invalid.' }
                }));
                allValid = false;
            }

        } else {
            // Personal vehicle: require at least one driver marked as owner
            const hasOwner = this.drivers.length >= 1 && this.drivers.some(driver => driver.Driver_Type__c === true || driver.Driver_Type__c ==='Owner' || driver.Driver_Type__c ==='Co-Owner'|| driver.Driver_Type__c ==='Owner & Driver' );
            if (!hasOwner) {
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: '⚠️ There should be at least one owner driver.' }
                }));
                allValid = false;
            }
        }

        return allValid;
    }

    @api afterValidateCheck() {
        // If company registered it's valid if company flag is true (company may be owner)
        if (this.flag.Is_the_vehicle_registered_to_a_business__c) {
            // require that company flag is set (should be) — already true here
            return true;
        }
        // Otherwise require at least one owner driver added
        if (!this.drivers || !this.drivers.some(d => d.Driver_Type__c === true || d.Driver_Type__c ==='Owner' || d.Driver_Type__c ==='Co-Owner'|| d.Driver_Type__c ==='Owner & Driver')) {
            if (this.ISDEBUG) console.log('DD Please add owner first');
            return false;
        }
        return true;
    }


    @api async getData() {
        let filteredDrivers = [...this.drivers];
        let companyInformation = {};
        if (this.currentVehicleType === 'business') {
            filteredDrivers = filteredDrivers.filter(d => d.Driver_Type__c === false || d.Driver_Type__c ==='Driver');
            companyInformation = this.inputValues.companyInformation || {};
            this.flag.Is_the_vehicle_registered_to_a_business__c = true;
        } else if (this.currentVehicleType === 'personal') {
            filteredDrivers = filteredDrivers.filter(d => d.Driver_Type__c === true || d.Driver_Type__c === false || d.Driver_Type__c ==='Owner' || d.Driver_Type__c ==='Co-Owner'|| d.Driver_Type__c ==='Owner & Driver');
            companyInformation = {};
            this.flag.Is_the_vehicle_registered_to_a_business__c = false;
       }
        if (this.ISDEBUG) console.log('DD getDatafilteredDrivers1060 ', filteredDrivers);
        this.inputValues = {
            drivers: filteredDrivers,
            companyInformation: companyInformation,
            driverList: [...this.existingDriversList] || []
        };
        if (this.ISDEBUG) console.log('DD getDatainputvalues: ', this.inputValues);
        const driverPageData = {
            driverDetails: {
                drivers: filteredDrivers,
                companyInformation: companyInformation || {},
                driverList: [...this.existingDriversList] || []
            }
        };
        
        if (this.ISDEBUG) console.log('DD getDatadrivers: ', driverPageData);
        const driverPageIndex = this.payload.findIndex(item => item.driverDetails);

        if (driverPageIndex >= 0) {
            this.payload = [
                ...this.payload.slice(0, driverPageIndex),
                driverPageData,
                ...this.payload.slice(driverPageIndex + 1)
            ];
        } else {
            this.payload = [...this.payload, driverPageData];
        }
       
        if (this.flag.isCompanyStatus) {
            const data = this.updateBusinessAddress();
            let newPayload = JSON.parse(JSON.stringify(this.payload));
            const finalizeIndex = newPayload.findIndex(item => item.finalizeVehicleDetails);
            if (finalizeIndex >= 0) {
                newPayload[finalizeIndex].finalizeVehicleDetails = {
                    ...newPayload[finalizeIndex].finalizeVehicleDetails,
                    BusinessAddress__c: data
                };
            } else {
                newPayload.push({
                    finalizeVehicleDetails: {
                        BusinessAddress__c: data
                    }
                });
            }
            this.payload = newPayload;
            if (!this.currentUserType) {
                console.log('DD saveFinalizeVehicleDetails');
                try { 
                    await saveFinalizeVehicleDetails({ strLeadDetails: JSON.stringify(this.payload) }); 
                } 
                catch (e) { 
                    console.log('DD error in saveFinalizeVehicleDetails', e.message);
                }
                await this.handleCompanyDataSave();
            }
        } 
        else if(!this.flag.Is_the_vehicle_registered_to_a_business__c){
            const data = this.updateBusinessAddress();
            let newPayload = JSON.parse(JSON.stringify(this.payload));
           
            const finalizeIndex = newPayload.findIndex(item => item.finalizeVehicleDetails);
            if (finalizeIndex >= 0) {
                newPayload[finalizeIndex].finalizeVehicleDetails = {
                    ...newPayload[finalizeIndex].finalizeVehicleDetails,
                    BusinessAddress__c: data
                };
            } else {
                newPayload.push({
                    finalizeVehicleDetails: {
                        BusinessAddress__c: data
                    }
                });
            }
            this.payload = newPayload;
            if (!this.currentUserType) {
                console.log('DD saveFinalizeVehicleDetails1330',this.payload);
                try { 
                    await saveFinalizeVehicleDetails({ strLeadDetails: JSON.stringify(this.payload) }); 
                } 
                catch (e) { 
                    console.log('DD error in saveFinalizeVehicleDetails', e.message);
                }
            }
        }

        const driverPageIndexUpdated = this.payload.findIndex(item => item.driverDetails);
        if (driverPageIndexUpdated >= 0) {
            this.payload = [
                ...this.payload.slice(0, driverPageIndexUpdated),
                driverPageData,
                ...this.payload.slice(driverPageIndexUpdated + 1)
            ];
        } else {
            this.payload = [...this.payload, driverPageData];
        }

        if (this.ISDEBUG) {
            console.log('DD Again data after update', this.payload);
            console.log('DD Input values', this.inputValues);
        }

        if (this.ISDEBUG) console.log('DD payload after update', this.payload);
        await this.handleDriverDataSave();
        return this.inputValues;
    }

    processVehicleData(vehicleDetails) {
        if (!vehicleDetails || typeof vehicleDetails !== 'object') return null;

        const fieldsToKeep = [
            'Is_Lienholder__c', 'is_the_vehicle_used_for_business_purpose__c', 'is_there_a_driver_under_21__c',
            'Is_this_a_Rental_Vehicle__c', 'salvage_vehicle__c', 'isTowing', 'Electric_Hybrid__c', 'Year__c',
            'Vehicle_sub_type__c', 'Make', 'Model', 'Value__c', 'Vin__c', 'Registered_Country__c', 'Registered_State__c',
            'Id', 'Make__c', 'Model__c', 'Account_Vehicle__c', 'Contact__c', 'BusinessAddress__c', 'Is_the_vehicle_registered_to_a_business__c'
        ];

        const processedData = {};
        fieldsToKeep.forEach(field => {
            if (vehicleDetails.hasOwnProperty(field)) processedData[field] = vehicleDetails[field];
        });

        if (vehicleDetails.hasOwnProperty('licensePlate')) processedData['Registered_Plate__c'] = vehicleDetails.licensePlate;
        return processedData;
    }

    updateBusinessAddress() {
        const company = this.inputValues?.companyInformation || {};
        
        const businessAddress = {
            Country__c: company.Company_Country__c || '',
            State_Province__c: company.Company_State__c || '',
            Postal_Code__c: company.Company_Zip__c || '',
            City__c: company.Company_City__c || '',
            Address__c: company.Company_Address__c || ''
        };

        // Use the unified dispatch shape
        this.dispatchPayloadUpdate({
            finalizeVehicleDetails: {
                BusinessAddress__c: businessAddress,
                Is_the_vehicle_registered_to_a_business__c: this.flag.Is_the_vehicle_registered_to_a_business__c || false
            }
        });

        return businessAddress;
    }

    // Add this method to handle the new ownership selection UI
    handleOwnershipSelection(event) {
        const selection = event.currentTarget.dataset.value;
        console.log('selection@@###', selection);
        this.currentVehicleType = selection; 
        if (selection === 'business') {
            this.isSelected = true;
            this.handleChange({
                target: {
                    name: 'Is_the_vehicle_registered_to_a_business__c',
                    checked: true,
                    type: 'checkbox'
                }
            });
            this.driver = { ...this.driver, ['Driver_Type__c']: false };
            this.isCompanyOrDriverOwner();
        } else {
            this.isSelected = false;
            if(this.tempDrivers.length != 0){
                console.log('temPfriveress',this.tempDrivers);
                this.drivers = [...this.drivers, ...this.tempDrivers]
                this.tempDrivers =[];
            }
            const hasUserStartingWith = this.payload.some(item => item?.userDetails?.Id?.startsWith("003"));
            if(hasUserStartingWith){
                this.flag.isOwner = false;
           }
            this.handleChange({
                target: {
                    name: 'Is_the_vehicle_registered_to_a_business__c',
                    checked: false,
                    type: 'checkbox'
                }
                
            });
            this.reCheckDriverOwnerOnChange();
        }
    }

    reCheckDriverOwnerOnChange() {
        const hasAnyOwnerMarked = this.drivers.some(driver => driver.Driver_Type__c === true || driver.Driver_Type__c ==='Owner' || driver.Driver_Type__c ==='Co-Owner'|| driver.Driver_Type__c ==='Owner & Driver');        
        this.driver = { ...this.driver, ['Driver_Type__c']: !hasAnyOwnerMarked };
        this.isCompanyOrDriverOwner();
    }
}