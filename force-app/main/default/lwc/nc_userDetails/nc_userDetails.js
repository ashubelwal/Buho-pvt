import { LightningElement, track, api } from 'lwc';
import saveLeadUserDetails from '@salesforce/apex/CustomerQuoteFlow.saveLeadUserDetails';
import checkalreadyExistUserAction from '@salesforce/apex/CustomerQuoteFlow.checkalreadyExistUserAction';
import createNewUser from '@salesforce/apex/CustomerQuoteFlow.createNewUser';
import userdetails from '@salesforce/label/c.TR_User_Detail';
import enteryourname from '@salesforce/label/c.TR_Kindly_enter_your_name_and_email_below_so_we_can_securely_store_the_quote_for';
import knowyouremail from '@salesforce/label/c.TR_We_know_your_email_is_sacred_and_we_ll_never_share_or_sell_any_of_your_detail';
import next from '@salesforce/label/c.TR_Next';
import firstname from '@salesforce/label/c.TR_First_Name';
import lastname from '@salesforce/label/c.TR_Last_Name';
import email from '@salesforce/label/c.TR_Email';
import phone from '@salesforce/label/c.TR_Phone';
import notavaild from '@salesforce/label/c.TR_Not_a_valid_phone_number';
import youraccountisalready from '@salesforce/label/c.TR_Your_account_already_exist_s_0_to_login';
import youraccountisalreadybut from '@salesforce/label/c.TR_Your_account_already_exist_s_but_is_inactive_0_to_activate_your_account';
import Clickhere from '@salesforce/label/c.TR_Click_here';


export default class Nc_userDetails extends LightningElement {
    label = {
        userdetails, enteryourname, knowyouremail, next, firstname, lastname, email, Clickhere, phone, notavaild, youraccountisalready, youraccountisalreadybut
    };
    @api payload;
    userDetails = {};  // Form data
    @track inputValues = {
        'countryCode': '+1',
    };
    @track returnLeadValue;
    @track leaddata;
    @track paramData = {};
    @track flag = { isCustomer: false, isInActiveCustomer: false,customerWithPortelAccess: false }
    isDebug = true;

    @track countryCodes = [
        { label: '+1 (USA)', value: '+1' },
        // { label: '+44 (UK)', value: '+44' },
        // { label: '+91 (India)', value: '+91' },
        // { label: '+81 (Japan)', value: '+81' },
        // { label: '+61 (Australia)', value: '+61' },
        // { label: '+49 (Germany)', value: '+49' },
        // { label: '+33 (France)', value: '+33' },
        // { label: '+39 (Italy)', value: '+39' },
        // { label: '+86 (China)', value: '+86' },
        // { label: '+7 (Russia)', value: '+7' },
        { label: '+52 (Mexico)', value: '+52' },
    ];

    handleInputChange(event) {
    const { name, value } = event.target;
    
    if (name === "Email") {
        if (this.inputValues?.Id) {
            this.inputValues.Id = '';
        }
    }
    
    // LOGIC TO PHONE MASKING
    if (name === 'Phone' && value && value.length > 0) {
        const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
        let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        this.inputValues[name] = phonevalues;
        } else {
        this.inputValues[name] = value;
        }
    }

    get shouldShowSection() {
        console.log('OUTPUT flag : ',this.flag);
        return !(!this.flag.isCustomer || !this.flag.isInActiveCustomer);
    }

    async handleEmailInput() {
        this.flag.customerWithPortelAccess = false;
        this.flag.isCustomer = false;
        this.flag.isInActiveCustomer = false;
        try {
            let data = this.paramData?.Email ? this.paramData : this.inputValues;
            console.log('OUTPUT : data',JSON.stringify(data));

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false })); 
            // Initial validation
            console.log('this.inputValues :: ',this.inputValues);     
            if ((!this.inputValues && !data) || (this.inputValues.Email == '' && data.Email =='')) {
                return;
            }  
            console.log('this.inputValuesown :: ',this.inputValues.Email);      
            console.log(data.Email );    
            if((!this.inputValues.hasOwnProperty("Email") && !data.hasOwnProperty("Email")) || (this.inputValues.Email == '' && data.Email =='')){
                console.log('inside the return metohd');
                return;
            }

            const result = await checkalreadyExistUserAction({
                'leadDataItem': JSON.stringify(data)
            }).catch(err => {
                console.error('API Error:', err);
                throw new Error('API call failed');
            });

            this.returnLeadValue = result;
            console.log('UD API Result:', JSON.parse(JSON.stringify(result)));
            let transformedData = [];

            if (this.returnLeadValue?.LeadInfo) {
                transformedData = this.createTransformedData?.() || [];
                this.payload = JSON.parse(JSON.stringify(transformedData));

                const cleanData = JSON.parse(JSON.stringify(transformedData));
                this.dispatchEvent(new CustomEvent('fullpayloadupdate', {
                    detail: cleanData,
                    bubbles: true,
                    composed: true
                }));                

                const userDetails = transformedData.find(x => x?.userDetails)?.userDetails;
                if (userDetails) {
                    this.inputValues = { ...this.inputValues, ...userDetails };
                }

                if (this.returnLeadValue?.status === "Success" && !this.returnLeadValue?.isExistUser) {
                    this.leaddata = {
                        ...JSON.parse(JSON.stringify(this.leaddata || {})),
                        Id: this.returnLeadValue?.LeadInfo?.Id,
                        quoteId: this.returnLeadValue?.QuoteInfo?.Id
                    };
                }

                if(this.flag.isCustomer || this.flag.isInActiveCustomer) {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: true }));
                } else {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
                }

            } else if (this.returnLeadValue?.userData) {
                this.payload ={};
                console.log('UD OUTPUT Customer Data: ',JSON.stringify(this.returnLeadValue?.userData));
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: {
                        variant: 'info',
                        title: 'Account Found',
                        message: 'Your account already exists. Please proceed with login or activation.'
                    },
                    bubbles: true,
                    composed: true
                }));

                if(this.returnLeadValue?.userData.IsActive) {
                    console.log('user is active');
                    // this.flag.isCustomer = true;
                    this.flag = { ...this.flag, isCustomer: true };
                    window.open(window.location.origin+'/login?c=true', "_self");
                } else {
                    console.log('user is inactive');
                    // this.flag.isInActiveCustomer = true;
                    this.flag = { ...this.flag, isInActiveCustomer: true };
                }
                
                if(this.flag.isCustomer || this.flag.isInActiveCustomer) {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: true }));
                } else {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
                }
            } else if (this.returnLeadValue?.contactData){
                this.payload ={};
                this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
                console.log('UD OUTPUT Customer Data: ',JSON.stringify(this.returnLeadValue?.userData));
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: {
                        variant: 'info',
                        title: 'Already a Member',
                        message: 'Please create a account to login'
                    },
                    bubbles: true,
                    composed: true
                }));
                this.flag = { ...this.flag, customerWithPortelAccess: true };
                this.flag = { ...this.flag, isCustomer: true };
            } else {
                this.payload = [];
                this.inputValues.FirstName = '';
                this.inputValues.LastName = '';
                this.inputValues.Company = '';
                this.inputValues.Phone = '';

                this.dispatchEvent(new CustomEvent('fullpayloadupdate', {
                    detail: [],
                    bubbles: true,
                    composed: true
                }));

                if(this.flag.isCustomer || this.flag.isInActiveCustomer) {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: true }));
                } else {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
                }

                return;
            }            
        } catch (err) {            
            console.error('Full Error:', {
                message: err.message,
                stack: err.stack,
                fullError: JSON.stringify(err, Object.getOwnPropertyNames(err))
            });
            
        } finally {
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));            
            console.log('UD Final state:', {
                inputValues: this.inputValues,
                payload: this.payload,
                leaddata: this.leaddata
            });

            if(this.flag.isCustomer || this.flag.isInActiveCustomer) {
                this.dispatchEvent(new CustomEvent('flagupdate', { detail: true }));
            } else {
                this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
            }
        }
    }

    async handleConfirmPortelAccess(){
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let contactInfo = JSON.stringify(this.returnLeadValue?.contactData);

        await createNewUser({
            'contactInfo': contactInfo
        })
        .then((result) => {
            
            console.log('result for contact :: ', result);
            if (result.Success === true){
                this.dispatchEvent(new CustomEvent('toastevent', {
                        detail: {
                            variant: 'info',
                            title: 'Welcome Email Send',
                            message: 'Check you inbox for welcome email'
                        },
                        bubbles: true,
                        composed: true
                    }));

                setTimeout(() => {
                    this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                    window.open(window.location.origin+'/customer/login', "_self");
                }, 3000);                    
            }          

            
        });
    }

    // if (this.returnLeadValue?.LeadInfo) {
    //     transformedData = this.createTransformedData?.() || [];                
    // } else { 
    //     const updateEvent = new CustomEvent('fullpayloadupdate', {
    //         detail: this.payload,
    //         bubbles: true,
    //         composed: true
    //     });
    //     this.dispatchEvent(updateEvent);
    //     return;
    // }

    //         this.payload = JSON.parse(JSON.stringify(transformedData));            
    //         const cleanData = JSON.parse(JSON.stringify(transformedData));

    //         const updateEvent = new CustomEvent('fullpayloadupdate', {
    //             detail: cleanData,
    //             bubbles: true,
    //             composed: true
    //         });
    //         this.dispatchEvent(updateEvent);

    //         const userDetails = transformedData.find(x => x?.userDetails)?.userDetails;
    //         if (userDetails) { this.inputValues = { ...this.inputValues, ...userDetails }; }

    //         if (this.returnLeadValue?.status === "Success" && !this.returnLeadValue?.isExistUser) {
    //             this.leaddata = {
    //                 ...JSON.parse(JSON.stringify(this.leaddata || {})),
    //                 Id: this.returnLeadValue?.LeadInfo?.Id,
    //                 quoteId: this.returnLeadValue?.QuoteInfo?.Id
    //             }; 
    //         }
    //         this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    //     } catch (err) {
    //         this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    //         console.error('Full Error:', {
    //             message: err.message,
    //             stack: err.stack,
    //             fullError: JSON.stringify(err, Object.getOwnPropertyNames(err))
    //         });
    //     } finally {
    //         this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    //         console.log('UD Final state:', {
    //             inputValues: this.inputValues,
    //             payload: this.payload,
    //             leaddata: this.leaddata
    //         });
    //     }
    // }

    // Validation method (returns true if valid, false if invalid)
    @api validate() {
        const inputs = this.template.querySelectorAll('lightning-input, lightning-checkbox-group, lightning-radio-group, lightning-combobox');
        let allValid = true;

        // Create a copy of current inputValues to modify
        const updatedValues = { ...this.inputValues };

        inputs.forEach(input => {
            const { required, value, name, type } = input;

            // Handle validation for required fields
            if (required && !input.checkValidity()) {
                input.classList.add('slds-has-error');
                input.reportValidity();
                allValid = false;
            } else {
                input.classList.remove('slds-has-error');

                // Get the appropriate value based on input type
                let inputValue;
                if (type === 'checkbox') {
                    inputValue = input.checked;
                } else if (type === 'radio') {
                    inputValue = input.value;
                } else if (type === 'combobox') {
                    inputValue = input.value;
                } else {
                    inputValue = value;
                }

                // Only update if the field has a value (preserve existing if not)
                if (inputValue !== null && inputValue !== undefined && inputValue !== '') {
                    updatedValues[name] = inputValue;
                } else if (updatedValues[name] === undefined) {
                    // If the field is empty and doesn't exist in inputValues, set it to empty
                    updatedValues[name] = '';
                }
                // Else: keep the existing value in inputValues
            }
        });

        if (allValid) {
            // Update inputValues while preserving any existing data not in the form
            this.inputValues = {
                ...this.inputValues,  // Keep all existing values
                ...updatedValues      // Override with updated values
            };

            if (this.isDebug) console.log('UD Updated inputValues:', this.inputValues);
            return true;
        } else {
            if (this.isDebug) console.error('Validation failed');
            return false;
        }
    }

    async connectedCallback() {
        if (this.isDebug) console.log('UD OUTPUT : ', JSON.stringify(this.payload));
        const params = new URLSearchParams(window.location.search);        
        if (params.get('email')) {            
            this.paramData = {
                Email: params.get('email') 
            }
            this.handleEmailInput();
        }
        this.CampaignFields(params);
    }

    // Method to capture the data from the form fields
    @api async getData() {        
        await this.insertLeadData()
            .then(() => {
                if (this.isDebug) console.log('UD Lead data inserted successfully');
            })
            .catch((error) => {
                if (this.isDebug) console.error('Error in inserting lead data', error);
                this.dispatchEvent(new CustomEvent('toastevent', { detail: {variant:'error', title: 'Error', message: 'Getting error, please contact with support team!'} }));
            });

        this.inputValues = {
            ...this.inputValues,
            ['Company']: 'Vehicle Insurance',
        }
        if (this.isDebug) console.log('UD user details: OUTPUT : ', JSON.stringify(this.inputValues));
        return this.inputValues;
    }

    // Insert the new lead data into database
    async insertLeadData() {
        // Insert neccesary data into the object
        this.inputValues = {
            ...this.inputValues,
            ['Company']: 'Vehicle Insurance',
        }

        // Add if there is some data validation 
        await this.checkData();

        //Save data in the backend
        await saveLeadUserDetails({ strLeadDetails: JSON.stringify(this.inputValues) })
            .then((result) => {
                if (result.Status === 'Success') {
                    this.inputValues = result.Data;
                    if (this.isDebug) console.log('UD Input values after insertion', this.inputValues);
                } else if (result.Status === 'Error') {
                    if (this.isDebug) console.log('UD Error in inserting lead data', result.Message);
                }
            })
            .catch((error) => {
                if (this.isDebug) console.error('Error in inserting lead data', error);
                this.dispatchEvent(new CustomEvent('toastevent', { detail: {variant:'error', title: 'Error', message: 'Getting error, please contact with support team!'} }));
            });
    }

    // Method to add extra validation on data
    checkData() {
        return true;
    }

    // Method to add the campaign data to the lead object
    CampaignFields = async (params) => {
        if (params !== undefined) {
            this.inputValues = {
                ...this.inputValues,
                ['pi_utm_id__c']: params.get('utm_id'),
                ['pi__utm_source__c']: params.get('utm_source'),
                ['pi__utm_medium__c']: params.get('utm_medium'),
                ['pi__utm_campaign__c']: params.get('utm_campaign'),
                ['pi__utm_term__c']: params.get('utm_term'),
                ['pi__utm_content__c']: params.get('utm_content'),
                ['GCLID__c']: params.get('gclid'),
            };
        }
    }

    renderedCallback() {
        // Populate input fields when the component loads or updates
        if (this.payload && this.payload.length > 0) {
            const userDetailsData = this.payload.find((item) => item.userDetails);
            // if (this.isDebug) console.log('UD userDetailsData: ', userDetailsData);
            if (userDetailsData) {
                this.userDetails = userDetailsData.userDetails;
                this.populateInputFields();
            }
        }
    }

    populateInputFields() {
        // Get all input elements and set their values
        const inputs = this.template.querySelectorAll('lightning-input');
        inputs.forEach((input) => {
            const fieldName = input.name;
            if (this.userDetails[fieldName]) {
                input.value = this.userDetails[fieldName];
            }
        });
    }

    //Transforming the data for the future use
    createTransformedData() {
        const getVehicleDetails = () => {
            try {
                return this.returnLeadValue?.LeadInfo?.Vehicle_details__c
                    ? JSON.parse(this.returnLeadValue.LeadInfo.Vehicle_details__c)
                    : null;
            } catch (e) {
                console.error('Error parsing Vehicle_details__c:', e);
                return null;
            }
        };
        const getCompanyDetails = () => {
            try {
                return this.returnLeadValue?.LeadInfo?.Company_details__c
                    ? JSON.parse(this.returnLeadValue.LeadInfo.Company_details__c)
                    : null;
            } catch (e) {
                console.error('Error parsing Company Details:', e);
                return null;
            }
        };
        const getDriverDetails = () => {
            try {
                return this.returnLeadValue?.LeadInfo?.Driver_details__c
                    ? JSON.parse(this.returnLeadValue.LeadInfo.Driver_details__c)
                    : null;
            } catch (e) {
                console.error('Error parsing Driver Details:', e);
                return null;
            }
        };
        const getTowDetails = () => {
            try {
                return this.returnLeadValue?.LeadInfo?.Towing__c
                    ? JSON.parse(this.returnLeadValue.LeadInfo.Towing__c)
                    : null;
            } catch (e) {
                console.error('Error parsing Driver Details:', e);
                return null;
            }
        };
        const getLienholderDetails = () => {
            try {
                return this.returnLeadValue?.LeadInfo?.Lienholder_info__c
                    ? JSON.parse(this.returnLeadValue.LeadInfo.Lienholder_info__c)
                    : null;
            } catch (e) {
                console.error('Error parsing Driver Details:', e);
                return null;
            }
        };
        const getTermsAndAlerts = () => {
            try {
                return this.returnLeadValue?.LeadInfo?.Terms_Alert__c
                    ? JSON.parse(this.returnLeadValue.LeadInfo.Terms_Alert__c)
                    : null;
            } catch (e) {
                console.error('Error parsing Driver Details:', e);
                return null;
            }
        };
        // Updated transformTowedUnits method that takes an array parameter
        const transformTowedUnits = (unitsArray) => {
            if (!Array.isArray(unitsArray)) return [];

            return unitsArray.map(towDetail => ({
                Towed_Unit_Type__c: towDetail.Towed_Unit_Type__c || null,
                Towed_Unit_Value__c: towDetail.Towed_Unit_Value__c || null,
                Days_in_Tow__c: towDetail.Days_in_Tow__c || null,
                count: towDetail.towedCount || null,
                isDeleteButton: towDetail.isDeleteTowedButton !== false,
                style: towDetail.selectedStyle || '',
                Year__c: towDetail.Year__c || null,
                Make__c: towDetail.Make__c || null,
                Model__c: towDetail.Model__c || null,
                VIN_Number__c: towDetail.VIN_Number__c || null,
                Plate__c: towDetail.Plate__c || null
            }));
        };
        const vehicleData = getVehicleDetails();
        const quoteInfo = this.returnLeadValue?.QuoteInfo || {};
        const driverDetails = getDriverDetails();
        const companyDetails = getCompanyDetails();
        const lienholderDetails = getLienholderDetails();
        const rawTowDetails = getTowDetails();
        const termsAndAlerts = getTermsAndAlerts();
        // console.log('UD vehicle Data', vehicleData);
        // console.log('UD Quote DATa', quoteInfo);
        // console.log('UD Driver details', driverDetails);
        // Transform the towed units data
        const towData = rawTowDetails ? transformTowedUnits(rawTowDetails) : [];
        return [
            {
                userDetails: {
                    Company: this.returnLeadValue?.LeadInfo?.Company ?? null,
                    Email: this.returnLeadValue?.LeadInfo?.Email ?? null,
                    FirstName: this.returnLeadValue?.LeadInfo?.FirstName ?? null,
                    Phone: this.returnLeadValue?.LeadInfo?.Phone ?? null,
                    LastName: this.returnLeadValue?.LeadInfo?.LastName ?? null,
                    Id: this.returnLeadValue?.LeadInfo?.Id ?? null
                }
            },
            {
                vehicleDetails: {
                    is_the_vehicle_used_for_business_purpose__c: vehicleData?.Is_the_vehicle_used_for_business_purpose__c ?? false,
                    is_there_a_driver_under_21__c: vehicleData?.Is_there_a_driver_under_21__c ?? false,
                    Is_this_a_Rental_Vehicle__c: vehicleData?.Is_this_a_Rental_Vehicle__c ?? false,
                    salvage_vehicle__c: vehicleData?.Salvage_Vehicle__c ?? false,
                    Coverage__c: quoteInfo?.Coverage__c ?? 'Complete',
                    isTowing: vehicleData?.isTowing ?? false, // Will be populated later
                    Electric_Hybrid__c: vehicleData?.Electric_Hybrid__c ?? false, // Will be populated later
                    towunits: towData?.length ? towData : (vehicleData?.towunits?.length ? vehicleData.towunits : []),
                    Liability__c: quoteInfo.Liability__c != null ? quoteInfo.Liability__c : (vehicleData?.Liability != null ? parseInt(vehicleData.Liability) : '100,000'),
                    Medical__c: quoteInfo.Medical__c != null ? quoteInfo.Medical__c : (vehicleData?.Medical ?? "10,000/50,000"),
                    Year__c: vehicleData?.Year__c ? vehicleData.Year__c : '2025',
                    Vehicle_sub_type__c: vehicleData?.Vehicle_sub_type__c ?? 'Automobile-Van-Minivan',
                    Make: vehicleData?.Make__c ?? null,
                    Model: vehicleData?.Model__c ?? null,
                    Value__c: vehicleData?.Value__c ? vehicleData.Value__c : null,
                }
            },
            {
                territory: {
                    region: this.returnLeadValue?.LeadInfo?.Territory_Options__c ?? null
                }
            },
            {
                finalizeVehicleDetails: {
                    Is_Lienholder__c: vehicleData?.Is_Lienholder__c ?? false,
                    is_the_vehicle_used_for_business_purpose__c: vehicleData?.Is_the_vehicle_used_for_business_purpose__c ?? false,
                    is_there_a_driver_under_21__c: vehicleData?.Is_there_a_driver_under_21__c ?? false,
                    Is_this_a_Rental_Vehicle__c: quoteInfo.Is_this_a_Rental_Vehicle__c ?? false,
                    salvage_vehicle__c: vehicleData?.Salvage_Vehicle__c ?? false,
                    Coverage__c: quoteInfo?.Coverage__c ?? 'Complete',
                    isTowing: this.returnLeadValue?.LeadInfo?.Is_towing__c ?? false,
                    Electric_Hybrid__c: vehicleData?.Electric_Hybrid__c ?? false, // Will be populated later
                    towunits: towData != null ? towData : [], // Will be populated later
                    Liability__c: quoteInfo.Liability__c ? parseInt(quoteInfo.Liability__c) : '100,000',
                    Medical__c: quoteInfo.Medical__c ?? "10,000/50,000",
                    Year__c: vehicleData?.Year__c ? vehicleData.Year__c :'2025',
                    Vehicle_sub_type__c: vehicleData?.Vehicle_Type__c ?? null,
                    Make: vehicleData?.Make__c ?? null,
                    Model: vehicleData?.Model__c ?? null,
                    Value__c: vehicleData?.Value__c ? vehicleData.Value__c : null,
                    Vin__c: vehicleData?.Vin__c ?? null,
                    Registered_Country__c: vehicleData?.Registered_Country__c ?? null,
                    Registered_State__c: vehicleData?.Registered_State__c ?? null,
                    licensePlate: vehicleData?.Registered_Plate__c ?? null,
                    Is_the_vehicle_registered_to_a_business__c: vehicleData?.Is_the_vehicle_registered_to_a_business__c ?? null
                }
            },
            {
                lienholderInformation: {
                    ...lienholderDetails
                }
            },
            {
                driverDetails: {
                    drivers: driverDetails ?? [], // Will be populated later
                    companyInformation: { ...companyDetails } // Will be populated later
                }
            }, {
                finalDetails: {
                    ...termsAndAlerts
                }
            }
        ];
    }
}