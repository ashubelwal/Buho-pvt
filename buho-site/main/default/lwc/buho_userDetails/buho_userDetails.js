import { LightningElement, track, api } from 'lwc';
import saveLeadUserDetails from '@salesforce/apex/CustomerQuoteFlow.saveLeadUserDetails';
import checkalreadyExistUserAction from '@salesforce/apex/CustomerQuoteFlow.checkalreadyExistUserAction';
import { createTransformedData } from 'c/buho_utils';
import createNewUser from '@salesforce/apex/CustomerQuoteFlow.createNewUser';
import login from '@salesforce/apex/BuhoLoginController.login';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
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

export default class Buho_userDetails extends LightningElement {
    label = {
        userdetails, enteryourname, knowyouremail, next, firstname, lastname, email, Clickhere, phone, notavaild, youraccountisalready, youraccountisalreadybut
    };

    @api payload;
    @api totalSteps;
    @api baseUrl;
    @api startUrl;
    @api isUserLoggedIn;
    userDetails = {};


    @track inputValues = {
        countryCode: '+1',
        Email: '',
        FirstName: '',
        LastName: '',
        Phone: '',
        Company: 'Vehicle Insurance'
    };

    @track returnLeadValue;
    @track leaddata;
    @track paramData = {};

    @track flag = {
        isCustomer: false,
        isInActiveCustomer: false,
        customerWithPortalAccess: false
    };

    // UI State Management
    @track showDetailedForm = false;
    @track showActiveCustomerMessage = false;
    @track showPreviousInquiryModal = false;
    @track showInactiveUserModal = false;
    @track showActiveUserModal = false;
    @track showWelcomeModal = false;
    @track inquiryDate = '';

    // Login credentials for active user modal
    @track loginUsername = '';
    @track loginPassword = '';
    @track loginError = '';
    @track isLoggingIn = false;

    isDebug = false;

    __formPopulated = false;

    countryCodesOptions = [
        { label: '+1 (USA)', value: '+1' },
        { label: '+52 (Mexico)', value: '+52' }
    ];

    get countryCodes() {
        return this.countryCodesOptions.map(code => ({
            ...code,
            selected: code.value === this.inputValues.countryCode
        }));
    }

    // Image URLs from static resource
    get logoUrl() {
        return `${buhoAssets}/images/Logo.svg`;
    }

    get owlIconUrl() {
        return `${buhoAssets}/images/logo_with_blackbackgrounf.png`;
    }

    get ladyImage() {
        return `${buhoAssets}/images/lady-image.png`;
    }

    get manWithTabImage() {
        return `${buhoAssets}/images/man_with_Tab.png`;
    }

    // Boolean getters for template attributes
    get hideForgotPassword() {
        return false;
    }

    // Carousel slides data for email check screen (lady image)
    get emailScreenSlides() {
        return [
            {
                image: this.ladyImage,
                text: 'Smart protection for your Mexican adventures',
                alt: 'Smart protection for your Mexican adventures'
            },
            {
                image: this.ladyImage,
                text: 'Comprehensive coverage for every journey',
                alt: 'Comprehensive coverage'
            },
            {
                image: this.ladyImage,
                text: 'Fast and easy claims process',
                alt: 'Easy claims'
            },
            {
                image: this.ladyImage,
                text: '24/7 customer support',
                alt: '24/7 Support'
            },
            {
                image: this.ladyImage,
                text: 'Best rates for your peace of mind',
                alt: 'Best rates'
            }
        ];
    }

    // Carousel slides data for detailed form screen (man with tab image)
    get detailedFormSlides() {
        return [
            {
                image: this.manWithTabImage,
                text: 'Wise Moves Start Here — Go Buho!',
                alt: 'Wise Moves Start Here'
            },
            {
                image: this.manWithTabImage,
                text: 'Comprehensive coverage for every journey',
                alt: 'Comprehensive coverage'
            },
            {
                image: this.manWithTabImage,
                text: 'Fast and easy claims process',
                alt: 'Easy claims'
            },
            {
                image: this.manWithTabImage,
                text: '24/7 customer support',
                alt: '24/7 Support'
            },
            {
                image: this.manWithTabImage,
                text: 'Best rates for your peace of mind',
                alt: 'Best rates'
            }
        ];
    }

    get shouldShowSection() {
        console.log('OUTPUT flag : ', this.flag);
        return !(!this.flag.isCustomer || !this.flag.isInActiveCustomer);
    }

    // Handle input changes
    handleInputChange(event) {

        const { name, value } = event.target;
        let formattedValue = '';
        // Reset customer flags if email changes
        if (name === 'Email') {
            if (this.inputValues?.Id) {
                this.inputValues.Id = '';
            }
            this.flag.isCustomer = false;
            this.flag.isInActiveCustomer = false;
            this.showActiveCustomerMessage = false;
        }

        // Phone masking logic
        if (name === 'Phone' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            formattedValue = phonevalues;
            this.inputValues[name] = phonevalues;

        } else {
            formattedValue = value;
            this.inputValues[name] = value;
        }

    }

    // Handle email blur - check if user exists (replicated from nc_userDetails)
    async handleEmailInput() {
        this.flag.customerWithPortalAccess = false;
        this.flag.isCustomer = false;
        this.flag.isInActiveCustomer = false;
        this.showActiveCustomerMessage = false;
        this.showPreviousInquiryModal = false;

        try {
            let data = this.paramData?.Email ? this.paramData : this.inputValues;
            console.log('BUD OUTPUT : data', JSON.stringify(data));

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));

            // Initial validation
            console.log('this.inputValues :: ', this.inputValues);
            if ((!this.inputValues && !data) || (this.inputValues.Email == '' && data.Email == '')) {
                return;
            }
            console.log('this.inputValuesown :: ', this.inputValues.Email);
            console.log(data.Email);
            if ((!this.inputValues.hasOwnProperty("Email") && !data.hasOwnProperty("Email")) || (this.inputValues.Email == '' && data.Email == '')) {
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
            console.log('BUD API Result:', JSON.parse(JSON.stringify(result)));
            let transformedData = [];

            // Case 1: Lead exists (previous inquiry)
            if (this.returnLeadValue?.LeadInfo) {
                transformedData = createTransformedData?.(this.returnLeadValue) || [];
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

                // Show previous inquiry modal instead of dispatching event
                const leadCreatedDate = this.returnLeadValue?.LeadInfo?.CreatedDate;
                if (leadCreatedDate) {
                    this.inquiryDate = this.formatDate(leadCreatedDate);
                    this.showPreviousInquiryModal = true;
                }

                if (this.flag.isCustomer || this.flag.isInActiveCustomer) {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: true }));
                } else {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
                }

            }
            // Case 2: User exists (active or inactive)
            else if (this.returnLeadValue?.userData) {
                this.payload = {};
                console.log('BUD OUTPUT Customer Data: ', JSON.stringify(this.returnLeadValue?.userData));
                /*this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: {
                        variant: 'info',
                        title: 'Account Found',
                        message: 'Your account already exists. Please proceed with login or activation.'
                    },
                    bubbles: true,
                    composed: true
                }));*/
                
                if (this.returnLeadValue?.userData.IsActive) {
                    console.log('user is active');
                    this.flag = { ...this.flag, isCustomer: true };
                    // Pre-populate username with the email
                    this.loginUsername = this.inputValues.Email || '';
                    // Show active user modal instead of dispatching event
                    this.showActiveUserModal = true;
                } else {
                    console.log('user is inactive');
                    this.flag = { ...this.flag, isInActiveCustomer: true };
                    // Show inactive user modal instead of dispatching event
                    this.showInactiveUserModal = true;
                }

                if (this.flag.isCustomer || this.flag.isInActiveCustomer) {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: true }));
                } else {
                    this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
                }
            }
            // Case 3: Contact exists without portal access
            // Keep dispatching event as is (per requirements)
            else if (this.returnLeadValue?.contactData) {
                this.payload = {};
                this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
                console.log('BUD OUTPUT Customer Data: ', JSON.stringify(this.returnLeadValue?.userData));
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: {
                        variant: 'info',
                        title: 'Already a Member',
                        message: 'Please create a account to login'
                    },
                    bubbles: true,
                    composed: true
                }));
                this.flag = { ...this.flag, customerWithPortalAccess: true };
                this.flag = { ...this.flag, isCustomer: true };
            }
            // Case 4: New user
            else {
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

                // Show welcome modal instead of dispatching event
                this.showWelcomeModal = true;

                if (this.flag.isCustomer || this.flag.isInActiveCustomer) {
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
            console.log('BUD Final state:', {
                inputValues: this.inputValues,
                payload: this.payload,
                leaddata: this.leaddata
            });

            if (this.flag.isCustomer || this.flag.isInActiveCustomer) {
                this.dispatchEvent(new CustomEvent('flagupdate', { detail: true }));
            } else {
                this.dispatchEvent(new CustomEvent('flagupdate', { detail: false }));
            }
        }
    }

    // Alias for handleEmailInput to match the blur event
    handleEmailBlur() {
        this.handleEmailInput();
    }

    // Handle confirm portal access for contact
    async handleConfirmPortalAccess() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let contactInfo = JSON.stringify(this.returnLeadValue?.contactData);

        await createNewUser({
            'contactInfo': contactInfo
        })
            .then((result) => {

                console.log('result for contact :: ', result);
                if (result.Success === true) {
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
                        window.open(this.baseUrl + '/login', "_self");
                    }, 3000);
                }


            });
    }

    // Format date for display
    formatDate(dateString) {
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', {
                month: '2-digit',
                day: '2-digit',
                year: 'numeric'
            });
        } catch (e) {
            return dateString;
        }
    }

    // Handle email continue button (first screen)
    async handleEmailContinue() {
        if (!this.inputValues.Email || this.inputValues.Email.trim() === '') {
            this.showToast('error', 'Email Required', 'Please enter your email address.');
            return;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(this.inputValues.Email)) {
            this.showToast('error', 'Invalid Email', 'Please enter a valid email address.');
            return;
        }

        // Call handleEmailInput to check user status
        // The modals will automatically show based on the cases in handleEmailInput
        await this.handleEmailInput();
    }

    // Handle back to email screen
    handleBackToEmail() {
        this.showDetailedForm = false;
    }

    // Handle back to home
    handleBackToHome() {
        window.history.back();
    }

    // Handle sign up
    handleSignUp(event) {
        event.preventDefault();
        this.showToast('info', 'Sign Up', 'Redirecting to sign up page...');
    }

    // Handle activate account
    handleActivateAccount() {
        window.open(this.baseUrl + '/activateaccount', "_self");
    }

    // Handle start new quote from inactive user modal
    handleStartNewQuote() {
        this.flag.isInActiveCustomer = false;
        this.showDetailedForm = true;
    }

    // Handle resume previous quote
    handleResumePreviousQuote() {
        this.showPreviousInquiryModal = false;
        this.showDetailedForm = true;
    }

    // Handle start new quote from previous inquiry modal
    handleStartNewQuoteFromInquiry() {
        this.showPreviousInquiryModal = false;
        this.payload = [];
        this.inputValues.FirstName = '';
        this.inputValues.LastName = '';
        this.inputValues.Phone = '';
        this.showDetailedForm = true;
    }

    // Handle close inactive user modal
    handleCloseInactiveUserModal() {
        this.showInactiveUserModal = false;
    }

    // Handle login from inactive user modal
    handleLoginFromInactiveModal() {
        window.open(this.baseUrl + '/Buho/activateaccount', "_self");
    }

    // Handle start new quote from inactive user modal
    handleStartNewQuoteFromInactiveModal() {
        this.showInactiveUserModal = false;
        this.showDetailedForm = true;
    }

    // Handle close active user modal
    handleCloseActiveUserModal() {
        this.showActiveUserModal = false;
        this.loginUsername = '';
        this.loginPassword = '';
        this.loginError = '';
    }

    // Handle login username change from child component
    handleLoginUsernameChange(event) {
        this.loginUsername = event.detail.value;
        // Clear error on input change
        this.loginError = '';
    }

    // Handle login password change from child component
    handleLoginPasswordChange(event) {
        this.loginPassword = event.detail.value;
        // Clear error on input change
        this.loginError = '';
    }

    // Handle login from active user modal
    async handleLoginFromActiveModal() {
        // Validate inputs
        if (!this.loginUsername || this.loginUsername.trim() === '') {
            this.loginError = 'Please enter your email address.';
            return;
        }

        if (!this.loginPassword || this.loginPassword.trim() === '') {
            this.loginError = 'Please enter your password.';
            return;
        }

        this.isLoggingIn = true;
        this.loginError = '';

        try {
            
            const result = await login({
                username: this.loginUsername,
                password: this.loginPassword,
                startUrl: this.startUrl
            });

            // Check if result is a URL (successful login) or error message
            if (result && result.startsWith('https://')) {
                // Success - redirect to the URL
                window.location.href = result;
            } else {
                // Error message returned
                this.loginError = result || 'Login failed. Please try again.';
                this.isLoggingIn = false;
            }
        } catch (error) {
            console.error('Login error:', error);
            this.loginError = 'An error occurred during login. Please try again.';
            this.isLoggingIn = false;
        }
    }

    // Handle close welcome modal
    handleCloseWelcomeModal() {
        this.showWelcomeModal = false;
    }

    // Handle continue from welcome modal
    handleContinueFromWelcome() {
        this.showWelcomeModal = false;
        this.showDetailedForm = true;
    }

    // Handle back button
    handleBack() {
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'previous' },
            bubbles: true,
            composed: true
        }));
    }

    // Handle continue button
    handleContinue() {
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    // Show toast message
    showToast(variant, title, message) {
        this.dispatchEvent(new CustomEvent('toastevent', {
            detail: { variant, title, message },
            bubbles: true,
            composed: true
        }));
    }

    // Validation method - called by parent (replicated from nc_userDetails)
    @api validate() {
        const inputs = this.template.querySelectorAll('input[required], select[required]');
        let allValid = true;

        // Create a copy of current inputValues to modify
        const updatedValues = { ...this.inputValues };

        inputs.forEach(input => {
            const { required, value, name, type } = input;

            // Handle validation for required fields
            if (required && !input.checkValidity()) {
                input.classList.add('slds-has-error');
                allValid = false;
            } else {
                input.classList.remove('slds-has-error');

                // Get the appropriate value based on input type
                let inputValue;
                if (type === 'checkbox') {
                    inputValue = input.checked;
                } else if (type === 'radio') {
                    inputValue = input.value;
                } else {
                    inputValue = value;
                }

                // Only update if the field has a value (preserve existing if not)
                if (inputValue !== null && inputValue !== undefined && inputValue !== '') {
                    updatedValues[name] = inputValue;
                } else if (updatedValues[name] === undefined) {
                    updatedValues[name] = '';
                }
            }
        });

        if (allValid) {
            // Update inputValues while preserving any existing data not in the form
            this.inputValues = {
                ...this.inputValues,
                ...updatedValues
            };

            if (this.isDebug) console.log('BUD Updated inputValues:', this.inputValues);
            return true;
        } else {
            if (this.isDebug) console.error('BUD Validation failed');
            return false;
        }
    }

    // Get data method - called by parent
    @api async getData() {
        await this.insertLeadData()
            .then(() => {
                if (this.isDebug) console.log('BUD Lead data inserted successfully');
            })
            .catch((error) => {
                if (this.isDebug) console.error('BUD Error in inserting lead data', error);
                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Getting error, please contact with support team!' } }));
            });

        this.inputValues = {
            ...this.inputValues,
            Company: 'Vehicle Insurance',
        }
        if (this.isDebug) console.log('BUD user details: OUTPUT : ', JSON.stringify(this.inputValues));
        return this.inputValues;
    }

    // Insert the new lead data into database
    async insertLeadData() {
        // Insert neccesary data into the object
        this.inputValues = {
            ...this.inputValues,
            Company: 'Vehicle Insurance',
        }

        // Add if there is some data validation 
        await this.checkData();

        //Save data in the backend
        await saveLeadUserDetails({ strLeadDetails: JSON.stringify(this.inputValues) })
            .then((result) => {
                if (result.Status === 'Success') {
                    this.inputValues = result.Data;
                    if (this.isDebug) console.log('BUD Input values after insertion', this.inputValues);
                } else if (result.Status === 'Error') {
                    if (this.isDebug) console.log('BUD Error in inserting lead data', result.Message);
                }
            })
            .catch((error) => {
                if (this.isDebug) console.error('BUD Error in inserting lead data', error);
                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: 'Getting error, please contact with support team!' } }));
            });
    }

    // Method to add extra validation on data
    checkData() {
        return true;
    }

    // Lifecycle: component connected
    connectedCallback() {
        if (this.isDebug) console.log('BUD OUTPUT : ', JSON.stringify(this.payload));
        const params = new URLSearchParams(window.location.search);
        if (params.get('email')) {
            this.paramData = {
                Email: params.get('email')
            }
            this.inputValues.Email = params.get('email')
            this.handleEmailInput();
        }
        this.CampaignFields(params);
    }

    // Method to add the campaign data to the lead object
    CampaignFields = async (params) => {
        if (params !== undefined) {
            this.inputValues = {
                ...this.inputValues,
                pi_utm_id__c: params.get('utm_id'),
                pi__utm_source__c: params.get('utm_source'),
                pi__utm_medium__c: params.get('utm_medium'),
                pi__utm_campaign__c: params.get('utm_campaign'),
                pi__utm_term__c: params.get('utm_term'),
                pi__utm_content__c: params.get('utm_content'),
                GCLID__c: params.get('gclid'),
            };
        }
    }

    // Lifecycle: component rendered
    renderedCallback() {
        // Populate input fields when the component loads or updates
        if (this.payload && this.payload.length > 0 && !this.__formPopulated) {
            this.payload = JSON.parse(JSON.stringify(this.payload));
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('step')) {
                this.dispatchEvent(new CustomEvent('stepchange', { detail: urlParams.get('step') }));
            }
            this.__formPopulated = true;
            const userDetailsData = this.payload.find((item) => item.userDetails);
            if (userDetailsData) {
                this.userDetails = userDetailsData.userDetails;
                this.showDetailedForm = true;
                // Wait for DOM to update after showDetailedForm change
                requestAnimationFrame(() => {
                    this.populateInputFields();
                });
            }
        }
    }

    async populateInputFields() {
        // Get all input elements and set their values
        const inputs = this.template.querySelectorAll('input');
        inputs.forEach((input) => {
            const fieldName = input.name;
            if (this.userDetails[fieldName]) {
                input.value = this.userDetails[fieldName];
                this.inputValues[fieldName] = input.value;
            }
        });
    }
    /*
    //This method is moved to buho_utils
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
        const getTermsDetails = () => {
            try {
                return this.returnLeadValue?.LeadInfo?.Term_options__c
                    ? JSON.parse(this.returnLeadValue.LeadInfo.Term_options__c)[0]
                    : null;
            } catch (e) {
                console.error('Error parsing Term Details:', e);
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
        const termDetails = getTermsDetails();
        
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
                    isTowing: vehicleData?.isTowing ?? false,
                    Electric_Hybrid__c: vehicleData?.Electric_Hybrid__c ?? false,
                    towunits: towData?.length ? towData : (vehicleData?.towunits?.length ? vehicleData.towunits : []),
                    Liability__c: quoteInfo.Liability__c != null ? quoteInfo.Liability__c : (vehicleData?.Liability != null ? parseInt(vehicleData.Liability) : '100,000'),
                    Medical__c: quoteInfo.Medical__c != null ? quoteInfo.Medical__c : (vehicleData?.Medical ?? "10,000/50,000"),
                    Year__c: vehicleData?.Year__c ? vehicleData.Year__c : '2025',
                    Vehicle_sub_type__c: vehicleData?.Vehicle_sub_type__c ?? 'Automobile-Van-Minivan',
                    Make: vehicleData?.Make__c ?? (vehicleData?.Make ?? null),
                    Model: vehicleData?.Model__c ?? (vehicleData?.Model ?? null),
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
                    Electric_Hybrid__c: vehicleData?.Electric_Hybrid__c ?? false,
                    towunits: towData != null ? towData : [],
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
                    drivers: driverDetails ?? [],
                    companyInformation: { ...companyDetails }
                }
            }, {
                finalDetails: {
                    ...termsAndAlerts
                }
            },{
                termOption: {
                    ...termDetails
                }
            }
        ];
    }
        */
}