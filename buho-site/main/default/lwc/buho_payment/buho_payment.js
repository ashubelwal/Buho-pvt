import { api, wire, track, LightningElement } from 'lwc';
import createCloneQuote from '@salesforce/apex/Mex_PolicyEditController.createCloneQuote';
import createNewEditPolicy from '@salesforce/apex/Mex_PolicyEditController.createNewEditPolicy';
import createNewWatercraftEditPolicy from '@salesforce/apex/Mex_PolicyEditController.createNewWatercraftEditPolicy';
import getPaymentInfo from '@salesforce/apex/PaymentFormController.getPaymentInfo';
import createTransaction from '@salesforce/apex/PaymentFormController.createTransaction';
import createPaymentProfile from '@salesforce/apex/PaymentFormController.createPaymentProfile';
import createPaymentProfileTransaction from '@salesforce/apex/PaymentFormController.createPaymentProfileTransaction';
import createAdditionalPaymentProfileTransactionForCards from '@salesforce/apex/PaymentFormController.createAdditionalPaymentProfileTransactionForCards';
import refundTransaction from '@salesforce/apex/PaymentFormController.refundTransaction';
import refundTransactionUsingSaveddCard from '@salesforce/apex/PaymentFormController.refundTransactionUsingSavedCard';
import createTransactionWithPredefinedAmount from '@salesforce/apex/PaymentFormController.createTransactionWithPredefinedAmount';
import createPolicy from '@salesforce/apex/Mex_NewLeadProcess.createPolicy';
import createWaterCraftPolicy from '@salesforce/apex/Mex_NewLeadProcess.createWaterCraftPolicy';
import createPolicyForExistingCustomer from '@salesforce/apex/Mex_existingCustomerFlowController.createPolicyForExistingCustomer';
import createWatercraftPolicyForExistingCustomer from '@salesforce/apex/Mex_existingCustomerFlowController.createWatercraftPolicyForExistingCustomer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import AddressInformation from '@salesforce/label/c.TR_Address_Information';
import address from '@salesforce/label/c.TR_Address';
import Country from '@salesforce/label/c.TR_Country';
import State from '@salesforce/label/c.TR_State';
import City from '@salesforce/label/c.TR_City';
import PostalCode from '@salesforce/label/c.TR_Postal_Code';
import CardDetails from '@salesforce/label/c.TR_Card_Details';
import CardholderName from '@salesforce/label/c.TR_Card_Holder_Name';
import CardNumber from '@salesforce/label/c.TR_Card_Number';
import ExpirationMonth from '@salesforce/label/c.TR_Expiration_Month';
import Expirationyear from '@salesforce/label/c.TR_Expiration_Year';
import SecurityCode from '@salesforce/label/c.TR_Security_Code';
import SaveCard from '@salesforce/label/c.TR_Save_Card';
import Prev from '@salesforce/label/c.TR_Prev';
import PayNow from '@salesforce/label/c.TR_Pay_Now';
import Addanewcreditcard from '@salesforce/label/c.TR_Add_a_new_credit_card';
import Addressline2 from '@salesforce/label/c.TR_Address_Line_2';
import Copyaddressfromcompanyinfo from '@salesforce/label/c.TR_Copy_address_from_company_info';
import Stateprovince from '@salesforce/label/c.TR_State_province';
import Nameoncard from '@salesforce/label/c.TR_Name_on_card';
import Amount from '@salesforce/label/c.TR_Amount';
import Paymentunsuccessfullsomethingwentwrong from '@salesforce/label/c.TR_Payment_Unsuccessfull_Something_went_wrong';
import Paymentsuccessfull from '@salesforce/label/c.TR_Payment_Successfull';
import Pleaseenteravalidexpirationdate from '@salesforce/label/c.TR_Please_enter_a_valid_expiration_date';
import PolicyCreated from '@salesforce/label/c.TR_Policy_Created';
import Somethingwentwrongpleasetryagainlater from '@salesforce/label/c.TR_Something_went_wrong_please_try_again_later';
import Success from '@salesforce/label/c.TR_Success';
import buhoAssets from '@salesforce/resourceUrl/BuhoAssets';


import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
export default class Payment extends NavigationMixin(LightningElement) {
    label = {
        AddressInformation, address, Amount, Country, Success, Nameoncard, Pleaseenteravalidexpirationdate, Somethingwentwrongpleasetryagainlater, State, PolicyCreated, Paymentsuccessfull, Paymentunsuccessfullsomethingwentwrong, Addressline2, City, Stateprovince, Copyaddressfromcompanyinfo, Addanewcreditcard, PostalCode, CardholderName, CardDetails, CardNumber, ExpirationMonth, SaveCard, SecurityCode, Expirationyear, Prev, PayNow,
    };
    @api payload;
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api refundAmount;
    @api policyType;
    @api oldPolicyData;
    @api editpolicydata;
    @api isRenewalPolicy;
    @api isEditPolicy;
    @api isRefund;
    @api customerRecord;
    @api communityUser;
    @api
    istestcase;
    @api
    refundObj;
    @api
    amounttestcase;
    @api
    quoteidtest;
    @track otheCountry = false;
    dataMap = {};    // accessible across the component where payload is converted
    spinner = false;
    @track isCardLoaded = false;
    newQuoteId;
    paymentDetails = {};
    paymentInfo;
    EXPMonth = '';
    EXPYear = '';
    months = [];
    years = [];
    currentDate = new Date();
    currentYear;
    startFrom;
    createdPolicyName;
    renewQuoteId;
    driverList;
    compnayAddress;
    bussinessAddress;
    addressOfbussines

    saveCreditCard = [];
    @track activeAccordinSectionForNewCard = 'B';
    @track
    showCardDetailForm = false;
    selectedCardId = '';
    @track
    refreshAccordian = true;
    AmountToCharge;
    @track
    showSaveCards = true;
    @track showExistingSaveCards = false;
    @track addNewCard = false; // New variable for add card flow
    startMonthNumber = 1;
    @track policyDetails; //Add policy details for future use in all the JS

    @api companyaddress = false;
    @api cmpSource;
    @track userType;

    // Checkbox states
    @track copyAddressChecked = false;
    @track saveCardChecked = false;
    @track termsOfPurchaseChecked = false;
    @track termsOfCancellationChecked = false;

    // Visa logo URL (you can update this with actual logo path)
    get visaLogoUrl() {
        return `${buhoAssets}/images/visa.png`;
    }

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




    async connectedCallback() {

        console.log('Payment connected callback', this.payload);
        // Intialize the datamap to user all over the class without looping in the payload
        this.initializeDataMap();

        this.MM;
        console.log('is refund functionality called? ', this.isRefund);
        this.currentYear = this.currentDate.getFullYear();
        this.startFrom = this.currentYear;
        await this.getPaymentInfo();
        console.log('running payment screen logs:   ');
        console.log('running payment screen logs: this.refundAmount ' + this.refundAmount);
        console.log(' refund amount first ', this.refundAmount);
        if (this.refundAmount) {
            this.AmountToCharge = this.refundAmount;
            //this.showSaveCards = true;
        } else {
            // this.showSaveCards = true;
        }
        if (this.istestcase) {
            this.AmountToCharge = this.amounttestcase;
        }

        console.log('this edit policy data-> ' + JSON.stringify(this.editpolicydata));
        if (this.editpolicydata != null && this.editpolicydata != undefined) {
            this.driverList = this.editpolicydata.DriverData;
            this.AmountToCharge = this.refundAmount != undefined ? this.refundAmount : this.editpolicydata?.quoteData?.Quote_Value__c;
        } else if (this.payload != null) {
            this.driverList = this.dataMap.driverDetails?.drivers || [];
            this.AmountToCharge = this.dataMap.quotePage?.QuoteData?.Quote_Value__c || 0;
            console.log('Driver list in connected callback', this.driverList);
            console.log('Amount to be charged', this.AmountToCharge);
        } else if (this.currentUserType) {
            this.driverList = this.dataMap.driverDetails?.drivers || [];
            this.policyType = this.dataMap.finalizeVehicleDetails?.Vehicle_sub_type__c || '';
            this.compnayAddress = this.dataMap?.finalizeVehicleDetails?.Is_the_vehicle_registered_to_a_business__c == true ? this.dataMap?.driverDetails?.companyInformation : '';
            this.bussinessAddress = this.dataMap?.finalizeVehicleDetails?.Is_the_vehicle_registered_to_a_business__c == true ? this.dataMap?.finalizeVehicleDetails?.BusinessAddress__c : '';;
            this.AmountToCharge = this.dataMap.quotePage?.QuoteData?.Quote_Value__c || 0;
        }
        this.getPopulateDetailsCard();
        if (this.dataMap != null && this.dataMap?.finalizeVehicleDetails != null && this.dataMap?.finalizeVehicleDetails?.Is_the_vehicle_registered_to_a_business__c) {
            this.addressOfbussines = this.dataMap?.finalizeVehicleDetails?.Is_the_vehicle_registered_to_a_business__c == true ? true : false;
        } else if (this.currentUserType) {
            this.addressOfbussines = this.dataMap?.finalizeVehicleDetails?.Is_the_vehicle_registered_to_a_business__c == true ? true : false;
        }
        if (this.istestcase == 'True' || this.istestcase == true) {
            this.AmountToCharge = this.amounttestcase;
        }

        // Set initial state for add/view cards
        if (this.saveCreditCard && this.saveCreditCard.length > 0) {
            this.showExistingSaveCards = true;
            this.addNewCard = false;
        } else {
            this.showExistingSaveCards = false;
            this.addNewCard = true;
        }
        this.AmountToCharge = this.AmountToCharge.toFixed(2)
    }

    initializeDataMap() {
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

    handleToggleSection(event) {
        console.log('Selected tab: ' + event.detail.openSections);
        this.activeAccordinSectionForNewCard = event.detail.openSections;

        if (this.tempCardDetails) {
            this.paymentDetails = this.tempCardDetails;
        }

        if (event.detail.openSections == 'B') {
            this.showCardDetailForm = true;
            if (this.paymentDetails?.cardNumber) {
                this.paymentDetails.cardNumber = '';
            }
            if (this.paymentDetails?.month) {
                this.paymentDetails.month = '';
            }
            if (this.paymentDetails?.year) {
                this.paymentDetails.year = '';
            }
            if (this.paymentDetails?.code) {
                this.paymentDetails.code = '';
            }
            console.log('cleared previous card details');
        } else {
            this.showCardDetailForm = false;
            for (let i = 0; i < this.saveCreditCard.length; i++) {
                console.log(this.saveCreditCard[i]);
                this.saveCreditCard[i] = { ...this.saveCreditCard[i], ['selected']: false };
            }
        }

        this.selectedCardId = '';


    }
    getPopulateDetailsCard() {
        try {


            let ownerDriver = {};
            console.log('Inside getPopulateDetailsCard', this.driverList);
            this.driverList?.map((data) => {
                console.log('------data-------', data);
                if (data.Driver_Type__c == 'Owner' || data.Driver_Type__c == "Owner & Driver" || data.Driver_Type__c == true || data.Driver_Type__c === 'true') {
                    ownerDriver = { ...data };
                }
            });
            console.log('--getPopulateDetailsCard paymentDetails---', ownerDriver);
            console.log('--lead Data ::::: ', this.leaddata);
            if (ownerDriver.Driver_Type__c != undefined && ownerDriver.Driver_Type__c != null && (ownerDriver.Driver_Type__c == 'Owner' || ownerDriver.Driver_Type__c == "Owner & Driver" || ownerDriver.Driver_Type__c == true || ownerDriver.Driver_Type__c === 'true')) {
                console.log('Start', ownerDriver);
                console.log('Payment details strat', this.paymentDetails);
                console.log('Owner driver country', ownerDriver?.Country__c);
                this.paymentDetails = {
                    ...this.paymentDetails, ['address1']: ownerDriver?.Address__c,
                    ['address2']: ownerDriver?.Address_Line_2__c,
                    ['country']: ownerDriver?.Country__c,
                    ['state']: ownerDriver?.State_Province__c,
                    ['city']: ownerDriver?.City__c,
                    ['zip']: ownerDriver?.Postal_Code__c,
                    ['name']: ownerDriver?.First_Name__c + ' ' + ownerDriver?.Last_Name__c
                }
                console.log('---End---', this.paymentDetails);
            } else {
                this.paymentDetails = {
                    ...this.paymentDetails,
                    ['name']: this.leaddata != null ? this.leaddata.FirstName + ' ' + this.leaddata?.LastName : '',
                }
            }
            console.log('--after update paymentDetails---', this.paymentDetails);
        } catch (err) {
            console.log('ERROR msg : ', err.message);
        }
    }

    get address() {
        return this.paymentDetails?.address1;
    }

    get address2() {
        return this.paymentDetails?.address2 ? this.paymentDetails.address2 : '';
    }
    get countryValue() {
        console.log('Payment details', this.paymentDetails);
        if (this.paymentDetails?.country != 'United States' && this.paymentDetails?.country != 'Canada' && this.paymentDetails?.country != 'Mexico' && this.paymentDetails?.country != '') {
            console.log('Test Input OTHER');
            this.otheCountry = true;
            return 'Other';
        } else {
            console.log('Test Input Country ELSE');
            this.otheCountry = false;
            return this.paymentDetails?.country;
        }
    }

    get otherCountryValue() {
        return this.paymentDetails?.country;
    }

    get otherStateValue() {
        return this.paymentDetails?.state;
    }

    get stateValue() {
        return this.paymentDetails?.state;
    }

    get CityValue() {
        return this.paymentDetails?.city;
    }
    get postalCode() {
        return this.paymentDetails?.zip;
    }
    get CardName() {
        return this.paymentDetails?.name ? this.paymentDetails?.name : '';
    }
    get cardNumber() {
        return this.paymentDetails?.cardNumber ? this.paymentDetails?.cardNumber : '';
    }

    get cvvNumber() {
        return this.paymentDetails?.code ? this.paymentDetails?.code : '';
    }
    get countryoptions() {
        if (this.policyType == 'Northbound') {
            return [
                { label: 'United States', value: 'United States' },
                { label: 'Canada', value: 'Canada' },
                { label: 'Mexico', value: 'Mexico' },
                { label: 'Other', value: 'Other' },
            ];
        }
        else {
            return [
                { label: 'United States', value: 'United States' },
                { label: 'Canada', value: 'Canada' },
                { label: 'Other', value: 'Other' },
            ];
        }

    }
    get stateOption() {
        //log('call stateoptions companyInfomartion   '.this.companyInfo);
        if (this.paymentDetails.country == 'Mexico') {
            return [
                { value: "Aguascalientes", label: "Aguascalientes" },
                { value: "Baja California", label: "Baja California" },
                { value: "Baja California Sur", label: "Baja California Sur" },
                { value: "Campeche", label: "Campeche" },
                { value: "Chihuahua", label: "Chihuahua" },
                { value: "Chiapas", label: "Chiapas" },
                { value: "Coahuila", label: "Coahuila" },
                { value: "Colima", label: "Colima" },
                { value: "Distrito Federal", label: "Distrito Federal" },
                { value: "Durango", label: "Durango" },
                { value: "Guerrero", label: "Guerrero" },
                { value: "Guanajuato", label: "Guanajuato" },
                { value: "Hidalgo", label: "Hidalgo" },
                { value: "Jalisco", label: "Jalisco" },
                { value: "México", label: "México" },
                { value: "Michoacán", label: "Michoacán" },
                { value: "Morelos", label: "Morelos" },
                { value: "Nayarit", label: "Nayarit" },
                { value: "Nuevo León", label: "Nuevo León" },
                { value: "Oaxaca", label: "Oaxaca" },
                { value: "Puebla", label: "Puebla" },
                { value: "Querétaro", label: "Querétaro" },
                { value: "Quintana Roo", label: "Quintana Roo" },
                { value: "Sinaloa", label: "Sinaloa" },
                { value: "San Luís Potosí", label: "San Luís Potosí" },
                { value: "Sonora", label: "Sonora" },
                { value: "Tabasco", label: "Tabasco" },
                { value: "Tamaulipas", label: "Tamaulipas" },
                { value: "Tlaxcala", label: "Tlaxcala" },
                { value: "Veracruz", label: "Veracruz" },
                { value: "Yucatán", label: "Yucatán" },
                { value: "Zacatecas", label: "Zacatecas" }
            ];
        }
        else if (this.paymentDetails.country == 'United States') {
            return [
                { value: "Alabama", label: "Alabama" },
                { value: "Alaska", label: "Alaska" },
                { value: "Arizona", label: "Arizona" },
                { value: "Arkansas", label: "Arkansas" },
                { value: "California", label: "California" },
                { value: "Colorado", label: "Colorado" },
                { value: "Connecticut", label: "Connecticut" },
                { value: "Delaware", label: "Delaware" },
                { value: "District of Columbia", label: "District of Columbia" },
                { value: "Florida", label: "Florida" },
                { value: "Georgia", label: "Georgia" },
                { value: "Hawaii", label: "Hawaii" },
                { value: "Idaho", label: "Idaho" },
                { value: "Illinois", label: "Illinois" },
                { value: "Indiana", label: "Indiana" },
                { value: "Iowa", label: "Iowa" },
                { value: "Kansas", label: "Kansas" },
                { value: "Kentucky", label: "Kentucky" },
                { value: "Louisiana", label: "Louisiana" },
                { value: "Maine", label: "Maine" },
                { value: "Maryland", label: "Maryland" },
                { value: "Massachusetts", label: "Massachusetts" },
                { value: "Michigan", label: "Michigan" },
                { value: "Minnesota", label: "Minnesota" },
                { value: "Mississippi", label: "Mississippi" },
                { value: "Missouri", label: "Missouri" },
                { value: "Montana", label: "Montana" },
                { value: "Nebraska", label: "Nebraska" },
                { value: "Nevada", label: "Nevada" },
                { value: "New Hampshire", label: "New Hampshire" },
                { value: "New Jersey", label: "New Jersey" },
                { value: "New Mexico", label: "New Mexico" },
                { value: "New York", label: "New York" },
                { value: "North Carolina", label: "North Carolina" },
                { value: "North Dakota", label: "North Dakota" },
                { value: "Ohio", label: "Ohio" },
                { value: "Oklahoma", label: "Oklahoma" },
                { value: "Oregon", label: "Oregon" },
                { value: "Pennsylvania", label: "Pennsylvania" },
                { value: "Rhode Island", label: "Rhode Island" },
                { value: "South Carolina", label: "South Carolina" },
                { value: "South Dakota", label: "South Dakota" },
                { value: "Tennessee", label: "Tennessee" },
                { value: "Texas", label: "Texas" },
                { value: "Utah", label: "Utah" },
                { value: "Vermont", label: "Vermont" },
                { value: "Virginia", label: "Virginia" },
                { value: "Washington", label: "Washington" },
                { value: "West Virginia", label: "West Virginia" },
                { value: "Wisconsin", label: "Wisconsin" },
                { value: "Wyoming", label: "Wyoming" }
            ];
        }
        else if (this.paymentDetails.country == 'Canada') {
            return [
                { value: "Alberta", label: "Alberta" },
                { value: "British Columbia", label: "British Columbia" },
                { value: "Manitoba", label: "Manitoba" },
                { value: "New Brunswick", label: "New Brunswick" },
                { value: "Newfoundland", label: "Newfoundland" },
                { value: "Northwest Territories", label: "Northwest Territories" },
                { value: "Nova Scotia", label: "Nova Scotia" },
                { value: "Nunavut", label: "Nunavut" },
                { value: "Ontario", label: "Ontario" },
                { value: "Prince Edward Island", label: "Prince Edward Island" },
                { value: "Quebec", label: "Quebec" },
                { value: "Saskatchewan", label: "Saskatchewan" },
                { value: "Yukon", label: "Yukon" },
            ];
        }
    }

    get MM() {
        this.months.push({'label': 'Select Month', 'value': ''});
        for (let i = this.startMonthNumber; i <= 12; i++) {
            let mon = i;
            if (i <= 9) {
                mon = '0' + i.toString();
            }
            mon = mon.toString()
            this.months.push({
                'label': mon,
                'value': mon
            });
        }
        return this.months;
    }
    get YYYY() {
        this.years.push({'label': 'Select Year', 'value': ''});
        for (this.startFrom; this.startFrom < (this.currentYear + 10); this.startFrom++) {
            this.years.push({
                'label': this.startFrom.toString(),
                'value': this.startFrom.toString()
            });
        }
        return this.years;
    }


    handleChange(event) {
        // Handle both buho_input events (event.detail) and native input events (event.target)
        let name = event.detail?.name || event.target?.name;
        let value = event.detail?.value || event.target?.value;
        let checkedValue = event.detail?.checked || event.target?.checked;
        console.log('checkedValue-> ', checkedValue);

        // Handle checkbox states
        if (name == 'copyAdd') {
            this.copyAddressChecked = checkedValue;
        }
        if (name == 'saveCard') {
            this.saveCardChecked = checkedValue;
        }
        if (name == 'termsOfPurchase') {
            this.termsOfPurchaseChecked = checkedValue;
        }
        if (name == 'termsOfCancellation') {
            this.termsOfCancellationChecked = checkedValue;
        }

        if (name == 'country') {
            if (value == 'Other') {
                console.log('Test Input');
                this.otheCountry = true;
            } else {
                console.log('Test Input LESE');
                this.otheCountry = false;
            }
        }

        if (name == 'otherCountry') {
            this.paymentDetails = { ...this.paymentDetails, ['otherCountry']: value };
        }

        if (name == 'otherState') {
            this.paymentDetails = { ...this.paymentDetails, ['otherState']: value };
        }

        if (/^\s/.test(value)) {
            value = '';
            console.log('enter space ');
        }
        if (name == 'year') {
            if (value == this.currentDate.getFullYear()) {
                this.startMonthNumber = this.currentDate.getMonth() + 1;
                this.months = [];
                this.template.querySelectorAll('c-buho_input').forEach(each => {
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
            this.EXPYear = value;
            console.log("year CHECK " + this.EXPYear);
        }
        if (name == 'month') {
            this.EXPMonth = value;
            console.log("month CHECK " + this.EXPMonth);
        }
        if (name == 'saveCard') {
            this.paymentDetails = { ...this.paymentDetails, ['saveCard']: checkedValue };
        } else {
            this.paymentDetails = { ...this.paymentDetails, [name]: value };
        }
        // this.leaddata = { ...this.leaddata, ['paymentDetails']: this.paymentDetails };
    }

    // Handler for Add New Method button
    handleAddNewCard() {
        console.log('Add New Card clicked');
        this.addNewCard = true;
        this.showExistingSaveCards = true;
    }

    // Handler for Save Card Details button
    handleSaveCardDetails() {
        console.log('Save Card Details clicked');

        // Validate inputs
        const inputs = this.template.querySelectorAll('c-buho_input');
        let allValid = true;

        inputs.forEach(input => {
            if (!input.reportValidity()) {
                allValid = false;
            }
        });

        if (!allValid) {
            return;
        }

        // Save the card and reset view
        this.addNewCard = false;

        // If there are saved cards, show them; otherwise keep showing add form
        if (this.saveCreditCard && this.saveCreditCard.length > 0) {
            this.showExistingSaveCards = true;
        }

        // Dispatch event to notify parent
        this.handleProceedToPayment();
    }

    handleProceedToPayment() {
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    // Handler for Cancel button
    handleCancelAddCard() {
        console.log('Cancel Add Card clicked');
        this.addNewCard = false;
        this.showExistingSaveCards = true;
    }

    handleCardChange(event) {

        let selectedIndex = parseInt(event.target.dataset.index);

        for (let i = 0; i < this.saveCreditCard.length; i++) {
            console.log(i);
            console.log(selectedIndex);
            if (i !== selectedIndex) {
                // this.saveCreditCard[i].selected = false;
                this.saveCreditCard[i] = { ...this.saveCreditCard[i], ['selected']: false };

            } else {
                this.tempCardDetails = this.paymentDetails;
                this.paymentDetails = this.saveCreditCard[i];
                // this.saveCreditCard[i].selected = true;
                this.saveCreditCard[i] = { ...this.saveCreditCard[i], ['selected']: true };
                this.selectedCardId = this.saveCreditCard[i].cardId;
            }
        }
        console.log('--saveCreditCard--', this.saveCreditCard);
        console.log('--paymentDetails--', this.paymentDetails);
        console.log('--selectedCardId--', this.selectedCardId);
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

    copyAddress = (event) => {

        let checked = event.target.checked;
        // let addressOfbussines
        // let addressOfCard;
        this.bussinessAddress = this.dataMap?.finalizeVehicleDetails?.Is_the_vehicle_registered_to_a_business__c == true ? this.dataMap?.finalizeVehicleDetails?.BusinessAddress__c : '';
        //this.compnayAddress = this.leaddata.companyInfo ? this.leaddata.companyInfo : '';

        console.log('--addressOfUserAccount--', this.bussinessAddress);
        console.log('--addressOfCompany--', this.compnayAddress);
        console.log('--addressOfbussines--', this.addressOfbussines);
        if (checked) {
            if (this.addressOfbussines) {
                this.paymentDetails = {
                    ...this.paymentDetails,
                    address1: this.bussinessAddress.Address__c,
                    address2: this.bussinessAddress.Address_Line_2__c,
                    country: this.bussinessAddress.Country__c,
                    state: this.bussinessAddress.State_Province__c,
                    city: this.bussinessAddress.City__c,
                    zip: this.bussinessAddress.Postal_Code__c,
                    name: this.dataMap?.driverDetails?.companyInformation?.Company_Name__c
                };
            } else if (!this.addressOfbussines) {
                this.paymentDetails = {
                    ...this.paymentDetails, ['address1']: this.compnayAddress.Company_Address__c,
                    ['country']: this.compnayAddress.Company_Country__c,
                    ['state']: this.compnayAddress.Company_State__c,
                    ['city']: this.compnayAddress.Company_City__c,
                    ['zip']: this.compnayAddress.Company_Zip__c,
                    // ['name']: addressOfUserAccount.First_Name__c + ' ' + addressOfUserAccount?.Last_Name__c
                }
            }
        } else {
            this.paymentDetails = {
                ...this.paymentDetails, ['address1']: '',
                ['address2']: '',
                ['country']: '',
                ['state']: '',
                ['city']: '',
                ['zip']: '',
                // ['name']: addressOfUserAccount.First_Name__c + ' ' + addressOfUserAccount?.Last_Name__c
            }
        }



    }
    handlePrevClick() {
        if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
            const customerRecordChange = new CustomEvent('customerecordchange', {
                detail: this.customerRecord,
            });

            this.dispatchEvent(customerRecordChange);
        }

        this.changeprevscreen();
    }

    @api async validate() {
        await this.handlePayment();

        // Wait until policyDetails is populated (max 3 seconds)
        const maxAttempts = 300;
        let attempts = 0;
        console.log('Before the loop', this.policyDetails);

        while (!this.policyDetails && attempts < maxAttempts) {
            console.log('In the loop', this.policyDetails);
            await new Promise(resolve => setTimeout(resolve, 100)); // wait 100ms
            attempts++;
        }

        if (this.policyDetails && this.policyDetails.PolicyId && this.policyDetails.status === 'success') {
            console.log('In policy details validate', this.policyDetails);
            return true;
        } else {
            console.log('In policy details validate', this.policyDetails);
            return false;
        }
    }


    @api async getData() {
        return this.policyDetails;
    }


    handlePayment = async () => {

        let allValid = this.isInputValid();

        var currentDate = new Date();
        let currentYear = currentDate.getFullYear();
        let currentMonth = (currentDate.getMonth() + 1);

        if (this.paymentDetails != undefined && currentYear == parseInt(this.paymentDetails.year) && currentMonth > parseInt(this.paymentDetails.month)) {
            console.log("Log 1: ");
            // const evt = new ShowToastEvent({
            //     message: this.label.Pleaseenteravalidexpirationdate,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);

            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: this.label.Pleaseenteravalidexpirationdate } }));
            return;
        }

        console.log('refund obj');
        console.log(JSON.stringify(this.refundObj));
        //  return;

        console.log('Processing Payment');
        console.log('this.isEditPolicy ' + this.isEditPolicy);
        console.log('this.isRenewalPolicy ' + this.isRenewalPolicy);
        console.log('Policy Objects');
        console.log('Old Policy Data-> ' + JSON.stringify(this.oldPolicyData));
        console.log('Edit Policy Data-> ' + JSON.stringify(this.editpolicydata));

        if (allValid || this.selectedCardId != '') {
            this.spinner = true;

            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
            if (this.isEditPolicy == 'Yes') {
                this.newQuoteId = await this.createCloneQuotes();

            }
            if (this.isEditPolicy == 'Yes') {
                // new flow for edit policy
                if (this.selectedCardId != '') {
                    this.createPaymentProfForEditCardPaymentAction(this.selectedCardId);
                } else {
                    //old flow
                    if (this.refundAmount > 0) {
                        await this.createAdditionalTransaction();
                        return;
                    } else if (this.refundAmount < 0) {
                        await this.refundTransactions();
                        return;
                    } else if (this.selectedCardId != '') {
                        this.createPaymentProfileTransactionAction(this.selectedCardId);
                    } else if (this.paymentDetails.saveCard == true) {
                        await this.createPaymentProfileAction();
                    } else {
                        await this.createTransaction();
                    }
                }

            } else if (this.isRefund && this.refundAmount != null && this.selectedCardId != '') {
                await this.refundTransactionsUsingSavedCard();
            } else if (this.isRefund && this.refundAmount != null && this.selectedCardId == '') {
                await this.refundTransactions();
            }
            else {
                //old flow
                if (this.refundAmount > 0) {
                    await this.createAdditionalTransaction();
                    return;
                } else if (this.refundAmount < 0) {
                    await this.refundTransactions();
                    return;
                } else if (this.selectedCardId != '') {
                    this.createPaymentProfileTransactionAction(this.selectedCardId);
                } else if (this.paymentDetails.saveCard == true) {
                    await this.createPaymentProfileAction();
                } else {
                    await this.createTransaction();
                }
            }
        } else {
            if (this.activeAccordinSectionForNewCard == 'A' && !this.selectedCardId) {
                // const evt = new ShowToastEvent({
                //     title: 'Please select a card.',
                //     message: 'Please select a card to proceed with payment!',
                //     variant: 'error',
                // });
                // this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Please select a card', message: 'Please select a card to proceed with payment!' } }));
            }
        }
    }

    getPaymentInfo = async () => {
        this.isCardLoaded = false;
        try {

            let data;
            if (this.isEditPolicy == 'Yes') {
                data = await getPaymentInfo({ "quoteIds": [this.editpolicydata?.quoteData?.Id] });
            } else if (this.isRenewalPolicy == 'Yes') {
                data = await getPaymentInfo({ "quoteIds": [this.editpolicydata?.quoteData?.Id] });
            } else if (this.isRefund) {
                data = await getPaymentInfo({ "quoteIds": [this.editpolicydata?.quoteData?.Id] });
            } else if (this.currentUserType) {
                let quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
                data = await getPaymentInfo({ "quoteIds": [quoteId] });
            } else {
                // In else section of the payment Get info. 
                let quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
                // console.log('Quote Id', quoteId);
                data = await getPaymentInfo({ "quoteIds": [quoteId] });
                // console.log('Data after calig the apex from the JS', data);
            }
            let parseData = JSON.parse(data);
            // console.log('calling js getPaymentInfo ');
            if (data != null && data != undefined) {
                this.paymentInfo = JSON.parse(data);
                this.saveCreditCard = parseData.creditCards;
                this.getIpAddress();
            }
            // console.log('calling js getPaymentInfo ', this.saveCreditCard);
            if ((this.saveCreditCard.length > 0 && !this.isRefund)) {

                this.showCardDetailForm = true;

                this.showExistingSaveCards = true;
                if (this.refundAmount < 0) {
                    this.showExistingSaveCards = false;
                }
                this.activeAccordinSectionForNewCard = 'A';
                // const accordion = this.template.querySelector('.mycustomaccordian');
                // console.log('Accordion:::',accordion);
                // console.log('values for accordion:::',accordion?.activeSectionName);
                // accordion.activeSectionName = 'A';

            }
            console.log('---saveCreditCard---', this.saveCreditCard);
        } catch (err) {
            this.isCardLoaded = true;
            console.log('OUTPUT : ', err.message);
        }
        this.isCardLoaded = true;
    }

    getIpAddress = async () => {
        const urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf('/s/'));
        let xmlHttp = new XMLHttpRequest();
        xmlHttp.open("GET", baseURL + '/apex/IPAddress', false);
        xmlHttp.send(null);
        const ip = JSON.parse(xmlHttp.responseText).ip;

        // Handle IPv6 addresses by truncating or using only the first 15 characters
        const formattedIp = ip.length > 15 ? ip.substring(0, 15) : ip;

        this.paymentInfo = { ...this.paymentInfo, ['ip']: formattedIp };
    }

    createPaymentProfileAction = async () => {
        const that = this;
        const ip = this.paymentInfo.ip;
        let transactionDetails = {};
        let quoteId;
        if (this.isEditPolicy == 'Yes') {
            quoteId = this.editpolicydata?.quoteData.Id;
        } else if (this.isRenewalPolicy == 'Yes') {
            quoteId = this.editpolicydata?.quoteData.Id;
        } else if (this.currentUserType) {
            quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
        } else {
            quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
        }
        transactionDetails = { ...transactionDetails, ['ip']: ip, ['quoteIds']: [quoteId] };
        // transactionDetails.ip = ip;
        try {
            let createProfile = await createPaymentProfile({ 'newCreditCard': JSON.stringify(this.paymentDetails), 'quoteIds': [quoteId] });

            console.log('--createProfile--', createProfile);
            if (createProfile) {
                this.createPaymentProfileTransactionAction(createProfile);
            } else {
                this.spinner = false;
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            }
        } catch (error) {
            this.generateLogs();
            console.log('test');
            console.log('--error--', error);
            // const evt = new ShowToastEvent({
            //     title: 'Error',
            //     message: error.body.message ? error.body.message : this.label.Paymentunsuccessfullsomethingwentwrong,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: error.body.message ? error.body.message : this.label.Paymentunsuccessfullsomethingwentwrong } }));
            this.spinner = false;
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        }

    }

    createPaymentProfForEditCardPaymentAction = async (paymentProfileId) => {
        console.log("Paying Edit policy through saved cards : " + paymentProfileId);
        // const that = this;
        const ip = this.paymentInfo.ip;
        let transactionDetails = {};
        let quoteId;
        if (this.isEditPolicy == 'Yes') {
            quoteId = this.editpolicydata?.quoteData.Id;
        }

        transactionDetails = { ...transactionDetails, ['ip']: ip, ['quoteIds']: [this.newQuoteId], ['paymentProfileId']: paymentProfileId };


        try {
            let createProfileTrans = await createAdditionalPaymentProfileTransactionForCards({ 'transactionDetails': JSON.stringify(transactionDetails), 'amount': this.refundAmount.toFixed(2), 'policyId': this.editpolicydata.policyData.Id });

            console.log('--createProfileTrans--' + JSON.stringify(createProfileTrans));
            console.log("CA log transaction in 298 lie  :" + JSON.stringify(transactionDetails, null, 4));

            if (createProfileTrans.status == 'success') {
                // const evt = new ShowToastEvent({
                //     title: this.label.Success,
                //     message: this.label.Paymentsuccessfull,
                //     variant: 'success',
                // });
                // this.dispatchEvent(evt);

                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: this.label.Success, message: this.label.Paymentsuccessfull } }));
                // condition here for edit and lead

                console.log('vehicle data before create policy',JSON.stringify(this.editpolicydata.vehicleData));
                let createCloneNewPolicy;
                if (this.policyType == 'Watercraft') {
                    createCloneNewPolicy = await createNewWatercraftEditPolicy({ 'watercraftData': JSON.stringify(this.editpolicydata.watercraftData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'quoteId': this.newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
                } else {

                    createCloneNewPolicy = await createNewEditPolicy({ 'vehicleData': JSON.stringify(this.editpolicydata.vehicleData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'towedUnitData': JSON.stringify(this.editpolicydata.towedUnitData), 'quoteId': this.newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
                }

                console.log('--createCloneNewPolicy-', JSON.stringify(createCloneNewPolicy));
                let cloneNewPlocy = createCloneNewPolicy;
                console.log('--cloneNewPlocy--', JSON.stringify(cloneNewPlocy));

                if (cloneNewPlocy.status == 'success') {
                    this.spinner = false;
                    this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            actionName: 'view',
                            recordId: cloneNewPlocy.data
                        },
                    })
                } else {
                    this.generateLogs();
                    this.spinner = false;
                    this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                }


            } else {
                this.spinner = false;
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                this.generateLogs();
                if (createProfileTrans?.responseCode != 1) {
                    // const errEvt = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: createProfileTrans?.errors[0]?.errorText ? createProfileTrans?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
                    //     variant: 'error',
                    // });
                    // this.dispatchEvent(errEvt);

                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: createProfileTrans?.errors[0]?.errorText ? createProfileTrans?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
                }
            }
        } catch (err) {
            this.generateLogs();
            console.log('--error--new implemented', err);
            this.spinner = false;
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            // const evt = new ShowToastEvent({
            //     title: 'Error',
            //     message: err.body.message ? err.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: err.body.message ? err.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
        }


    }

    createPaymentProfileTransactionAction = async (paymentProfileId) => {
        console.log("CA log paymentProfileId : " + paymentProfileId);
        // const that = this;
        const ip = this.paymentInfo.ip;
        let transactionDetails = {};
        let quoteId;
        if (this.isEditPolicy == 'Yes') {
            quoteId = this.editpolicydata?.quoteData.Id;
        } else if (this.isRenewalPolicy == 'Yes') {
            console.log('Saved Card-->', this.isRenewalPolicy);
            quoteId = this.editpolicydata?.quoteData.Id;
        } else if (this.currentUserType) {
            quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
        } else {
            quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
        }
        transactionDetails = { ...transactionDetails, ['ip']: ip, ['quoteIds']: [quoteId], ['paymentProfileId']: paymentProfileId };


        try {
            let createProfileTrans = await createPaymentProfileTransaction({ 'transactionDetails': JSON.stringify(transactionDetails) });
            console.log('--createProfileTrans--' + JSON.stringify(createProfileTrans));
            console.log("CA log transaction in 298 lie  :" + JSON.stringify(transactionDetails, null, 4));
            if (createProfileTrans.status == 'success') {
                // const evt = new ShowToastEvent({
                //     title: this.label.Success,
                //     message: this.label.Paymentsuccessfull,
                //     variant: 'success',
                // });
                // this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: this.label.Success, message: this.label.Paymentsuccessfull } }));
                // condition here for edit and lead
                if (this.isRenewalPolicy == 'Yes') {
                    let createRenewPolicy;
                    if (this.policyType == 'Watercraft') {
                        createRenewPolicy = await createNewWatercraftEditPolicy({ 'watercraftData': JSON.stringify(this.editpolicydata.watercraftData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'quoteId': quoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': this.isRenewalPolicy == 'Yes' ? true : false });
                    } else {
                        console.log('vehicleData', JSON.stringify(this.editpolicydata.vehicleData));
                        console.log('isRenewal', this.isRenewalPolicy == 'Yes' ? true : false);
                        console.log('DriverData', JSON.stringify(this.editpolicydata.DriverData));
                        console.log('towedUnitData', JSON.stringify(this.editpolicydata.towedUnitData));
                        console.log('quoteId', quoteId, 'oldPolicyId', this.oldPolicyData.policyData.Id);
                        createRenewPolicy = await createNewEditPolicy({ 'vehicleData': JSON.stringify(this.editpolicydata.vehicleData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'towedUnitData': JSON.stringify(this.editpolicydata.towedUnitData), 'quoteId': quoteId, 'oldPolicyId': this.oldPolicyData.policyData.Id, 'isRenewal': this.isRenewalPolicy == 'Yes' ? true : false });
                    }
                    console.log('---------createRenewPolicy-------', createRenewPolicy);
                    let renewPlocy = createRenewPolicy;
                    if (renewPlocy.status == 'success') {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                actionName: 'view',
                                recordId: renewPlocy.data
                            },
                        })
                    }
                } else {
                    console.log('capturing details');
                    await this.createPolicy();
                }
            } else {
                this.spinner = false;
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                this.generateLogs();
                if (createProfileTrans?.responseCode != 1) {
                    // const errEvt = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: createProfileTrans?.errors[0]?.errorText ? createProfileTrans?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
                    //     variant: 'error',
                    // });
                    // this.dispatchEvent(errEvt);

                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: createProfileTrans?.errors[0]?.errorText ? createProfileTrans?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
                }
            }
        } catch (err) {
            this.generateLogs();
            console.log('--error--new implemented', err);
            this.spinner = false;
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            // const evt = new ShowToastEvent({
            //     title: 'Error',
            //     message: err.body.message ? err.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);

            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: err.body.message ? err.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
        }


    }
    createTransaction = async () => {
        let ip = this.paymentInfo.ip;
        let transactionDetails = {};
        let quoteId;
        if (this.isEditPolicy == 'Yes') {
            quoteId = this.editpolicydata?.quoteData.Id;
        } else if (this.isRenewalPolicy == 'Yes') {
            quoteId = this.editpolicydata?.quoteData.Id;
        } else if (this.currentUserType) {
            quoteId = this.dataMap?.quotePage?.QuoteData?.Id;
        } else {
            quoteId = this.dataMap?.quotePage?.QuoteData?.Id;

        }

        if (this.istestcase == 'True' || this.istestcase == true) {
            quoteId = this.quoteidtest;
            ip = '192.168.24.24';
        }
        console.log("- createTransaction --this.paymentDetails------", this.paymentDetails);
        transactionDetails = { ...transactionDetails, ['ip']: ip, ['quoteIds']: [quoteId] };
        console.log("CA log transactionDetails : " + JSON.stringify(transactionDetails, null, 4));
        console.log("CA log transactionDetails : " + JSON.stringify(transactionDetails));
        console.log("CA log transactionDetails : " + JSON.stringify(this.paymentDetails));
        try {
            const createTransactionData = await createTransaction({ "newCreditCard": JSON.stringify(this.paymentDetails), "transactionDetails": JSON.stringify(transactionDetails), "email": '' });
            console.log('OUTPUT createTransactionData : ', createTransactionData);

            if (createTransactionData.status == 'success') {
                // const evt = new ShowToastEvent({
                //     title: this.label.Success,
                //     message: this.label.Paymentsuccessfull,
                //     variant: 'success',
                // });
                // this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: this.label.Success, message: this.label.Paymentsuccessfull } }));
                if (this.istestcase == 'True' || this.istestcase == true) {
                    const evtCustom = new CustomEvent('paymentcompleted', {
                        detail: true,
                    });
                    this.dispatchEvent(evtCustom);
                    return;
                }

                // condition here for edit and lead
                if (this.isRenewalPolicy == 'Yes') {
                    let createRenewPolicy;
                    if (this.policyType == 'Watercraft') {
                        createRenewPolicy = await createNewWatercraftEditPolicy({ 'watercraftData': JSON.stringify(this.editpolicydata.watercraftData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'quoteId': quoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': this.isRenewalPolicy == 'Yes' ? true : false });
                    } else {
                        console.log('vehicleData', JSON.stringify(this.editpolicydata.vehicleData));
                        console.log('isRenewal', this.isRenewalPolicy == 'Yes' ? true : false);
                        console.log('DriverData', JSON.stringify(this.editpolicydata.DriverData));
                        console.log('towedUnitData', JSON.stringify(this.editpolicydata.towedUnitData));
                        console.log('quoteId', quoteId, 'oldPolicyId', this.oldPolicyData.policyData.Id);
                        createRenewPolicy = await createNewEditPolicy({ 'vehicleData': JSON.stringify(this.editpolicydata.vehicleData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'towedUnitData': JSON.stringify(this.editpolicydata.towedUnitData), 'quoteId': quoteId, 'oldPolicyId': this.oldPolicyData.policyData.Id, 'isRenewal': this.isRenewalPolicy == 'Yes' ? true : false });
                    }
                    console.log('---------createRenewPolicy-------', createRenewPolicy);
                    let renewPlocy = createRenewPolicy;
                    if (renewPlocy.status == 'success') {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                actionName: 'view',
                                recordId: renewPlocy.data
                            },
                        })
                    } else {
                        this.generateLogs();
                    }
                } else {
                    console.log('capturing details 12');
                    await this.createPolicy();
                }
            } else {
                this.generateLogs();
                if (createTransactionData?.responseCode != 1) {
                    // const errEvt = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: createTransactionData?.errors[0]?.errorText ? createTransactionData?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
                    //     variant: 'error',
                    // });
                    // this.dispatchEvent(errEvt);
                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: createTransactionData?.errors[0]?.errorText ? createTransactionData?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
                }
                this.spinner = false;
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            }
        } catch (error) {
            this.generateLogs();
            console.log('--error--', error);
            // const evt = new ShowToastEvent({
            //     title: 'Error',
            //     message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
        }

        this.spinner = false;
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    async createAdditionalTransaction() {


        let transactionDetails = { ['ip']: this.paymentInfo.ip, ['quoteIds']: [this.newQuoteId] }



        console.log("CA log transactionDetail : " + JSON.stringify(transactionDetails, null, 4));
        console.log("CA log refundamount : " + this.refundAmount.toFixed(2));
        try {
            const data = await createTransactionWithPredefinedAmount({ 'newCreditCard': JSON.stringify(this.paymentDetails), 'transactionDetails': JSON.stringify(transactionDetails), 'amount': this.refundAmount.toFixed(2), 'policyId': this.editpolicydata.policyData.Id, "email": '' });

            console.log('--data--', data);
            if (data.status == 'success') {
                // const evt = new ShowToastEvent({
                //     title: this.label.Success,
                //     message: this.label.Paymentsuccessfull,
                //     variant: 'success',
                // });
                // this.dispatchEvent(evt);

                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: this.label.Success, message: this.label.Paymentsuccessfull } }));

                let createCloneNewPolicy;
                console.log('creating a new watercraft policy');
                if (this.policyType == 'Watercraft') {
                    createCloneNewPolicy = await createNewWatercraftEditPolicy({ 'watercraftData': JSON.stringify(this.editpolicydata.watercraftData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'quoteId': this.newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
                } else {
                    createCloneNewPolicy = await createNewEditPolicy({ 'vehicleData': JSON.stringify(this.editpolicydata.vehicleData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'towedUnitData': JSON.stringify(this.editpolicydata.towedUnitData), 'quoteId': this.newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
                }

                console.log('--createCloneNewPolicy-', createCloneNewPolicy);
                let cloneNewPlocy = createCloneNewPolicy;
                console.log('--cloneNewPlocy--', cloneNewPlocy);

                if (cloneNewPlocy.status == 'success') {
                    this.spinner = false;
                    this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            actionName: 'view',
                            recordId: cloneNewPlocy.data
                        },
                    })
                } else {
                    this.generateLogs();
                    this.spinner = false;
                    this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
                }
            } else {
                this.generateLogs();
                if (data?.responseCode != 1) {
                    // const evt = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: data?.errors[0]?.errorText ? data?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
                    //     variant: 'error',
                    // });
                    // this.dispatchEvent(evt);

                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: data?.errors[0]?.errorText ? data?.errors[0]?.errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
                }
                this.spinner = false;
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            }
        } catch (error) {
            this.generateLogs();
            console.log('--error--', error);
            // const evt = new ShowToastEvent({
            //     title: 'Error',
            //     message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);

            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
            this.spinner = false;
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        }




    }

    refundTransactions = async () => {
        // let transactionDetails = component.get('v.transactionDetails');
        let amountToRefund = Number(this.refundAmount).toFixed(2);
        console.log('--amountToRefund--', amountToRefund);
        let transactionDetails = {}
        if (this.isRefund) {
            transactionDetails = { ...this.editpolicydata.transactionData, ['quoteIds']: [this.editpolicydata.quoteData.Id] };
        } else {
            transactionDetails = { ...this.editpolicydata.transactionData, ['quoteIds']: [this.newQuoteId] };
        }


        console.log('--transactionDetails--', transactionDetails);
        try {
            console.log('Reached for refund calculation');
            const actionData = await refundTransaction({
                'newCreditCard': JSON.stringify(this.paymentDetails), 'transactionDetails': JSON.stringify(transactionDetails), 'refundAmount': amountToRefund,
                'policyId': this.editpolicydata.policyData.Id, 'refundObjtext': (this.refundObj ? JSON.stringify(this.refundObj) : '')
            })
            console.log('--actionData--', actionData);
            if (actionData.status == 'success') {
                // const evt = new ShowToastEvent({
                //     title: this.label.Success,
                //     message: this.label.Paymentsuccessfull,
                //     variant: 'success',
                // });
                // this.dispatchEvent(evt);

                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: this.label.Success, message: this.label.Paymentsuccessfull } }));
                if (this.cmpSource == 'comm' || this.cmpSource == 'customSource') {
                    this.showToastmethod('success', this.label.Paymentsuccessfull, 'Policy termination Success!');
                }

                if (this.isRefund) {
                    // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_12');
                    // if (eventExist == undefined){
                    //     window.dataLayer.push({
                    //         'event': 'funnel_step',
                    //         'step_number': 'step_12',
                    //         'step_name': 'payment_details', 
                    //         'insurance_category': this.policyType
                    //         });
                    // }
                    this.changesnextscreen();
                } else {
                    let createCloneNewPolicy;
                    if (this.policyType == 'Watercraft') {
                        createCloneNewPolicy = await createNewWatercraftEditPolicy({ 'watercraftData': JSON.stringify(this.editpolicydata.watercraftData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'quoteId': this.newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
                    } else {
                        createCloneNewPolicy = await createNewEditPolicy({ 'vehicleData': JSON.stringify(this.editpolicydata.vehicleData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'towedUnitData': JSON.stringify(this.editpolicydata.towedUnitData), 'quoteId': this.newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
                    }


                    let cloneNewPlocy = createCloneNewPolicy;
                    console.log('--cloneNewPlocy--', cloneNewPlocy);
                    if (cloneNewPlocy.status == 'success') {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                actionName: 'view',
                                recordId: cloneNewPlocy.data
                            },
                        })
                    }
                }

            } else {
                console.log('Error catched 111');
                this.generateLogs();
                if (actionData?.responseCode != 1) {
                    if (this.cmpSource == 'comm' || this.cmpSource == 'customSource') {
                        this.showToastmethod('error', actionData?.errors[0].errorText + ' Kindly try again with different card.', 'Policy termination failed!');
                    }
                    // const evt = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: actionData?.errors[0].errorText ? actionData?.errors[0].errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
                    //     variant: 'error',
                    // });
                    // this.dispatchEvent(evt);

                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: actionData?.errors[0].errorText ? actionData?.errors[0].errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
                }

                this.spinner = false;
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            }
        } catch (error) {
            console.log('Error catched 22222', error);
            console.log('Cmp source', this.cmpSource);
            if (this.cmpSource == 'comm' || this.cmpSource == 'customSource') {
                this.showToastmethod('error', error.body.message, 'Policy termination failed!');
            }
            this.generateLogs();
            // const evt = new ShowToastEvent({
            //     title: 'Error',
            //     message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
            this.spinner = false;
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        }


    }

    refundTransactionsUsingSavedCard = async () => {
        // let transactionDetails = component.get('v.transactionDetails');
        let amountToRefund = Number(this.refundAmount).toFixed(2);
        console.log('--amountToRefund--', amountToRefund);
        let transactionDetails = {};
        transactionDetails = { ...this.editpolicydata.transactionData, ['quoteIds']: [this.editpolicydata.quoteData.Id], ['paymentProfileId']: this.selectedCardId };
        console.log('--transactionDetails--', transactionDetails);
        console.log('--transactionDetails--', JSON.stringify(transactionDetails));
        try {
            console.log({ 'transactionDetails': JSON.stringify(transactionDetails), 'refundAmount': amountToRefund, 'policyId': this.editpolicydata.policyData.Id });
            const actionData = await refundTransactionUsingSaveddCard({ 'transactionDetails': JSON.stringify(transactionDetails), 'refundAmount': amountToRefund, 'policyId': this.editpolicydata.policyData.Id })

            console.log('--actionData--', actionData);
            if (actionData.status == 'success') {
                // const evt = new ShowToastEvent({
                //     title: this.label.Success,
                //     message: this.label.Paymentsuccessfull,
                //     variant: 'success',
                // });

                this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: this.label.Success, message: this.label.Paymentsuccessfull } }));

                // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_12');
                // if (eventExist == undefined){
                //     window.dataLayer.push({
                //         'event': 'funnel_step',
                //         'step_number': 'step_12',
                //         'step_name': 'payment_details', 
                //         'insurance_category': this.policyType
                //         });
                // }

                // this.dispatchEvent(evt);

                this.changesnextscreen();
            } else {
                this.generateLogs();
                if (actionData?.responseCode != 1) {
                    // const evt = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: actionData?.errors[0].errorText ? actionData?.errors[0].errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
                    //     variant: 'error',
                    // });
                    // this.dispatchEvent(evt);

                    this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: actionData?.errors[0].errorText ? actionData?.errors[0].errorText + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
                }

                this.spinner = false;
                this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            }
        } catch (error) {
            this.generateLogs();
            // const evt = new ShowToastEvent({
            //     title: 'Error',
            //     message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong,
            //     variant: 'error',
            // });
            // this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: error.body.message ? error.body.message + ' Kindly try again with different card.' : this.label.Paymentunsuccessfullsomethingwentwrong } }));
            this.spinner = false;
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        }


    }

    async createCloneQuotes() {
        try {
            let { Id, ...rest } = this.editpolicydata.quoteData;

            console.log('--newquote--', rest);
            let data = await createCloneQuote({ 'quote': JSON.stringify(rest), 'oldQuoteId': '' });

            console.log('--data--', data);
            if (data.status == 'success') {
                return data.data;
            } else {
                console.log('--else part--', data);
            }

        } catch (error) {
            console.log(error);
        }
    }


    createPolicy = async () => {
        let policy;
        if (this.currentUserType) {
            if (this.policyType == 'Watercraft') {
                console.log('creating watercraft real');
                policy = await createWatercraftPolicyForExistingCustomer({ 'quoteId': this.customerRecord?.quoteRecord?.Id, 'watercraftId': this.customerRecord?.watercraftData?.Id, 'termAgreement': JSON.stringify(this.customerRecord?.termAgreement) });
            } else {
                console.log('creating watercraft rsasaeal');

                policy = await createPolicyForExistingCustomer({ 'quoteId': this.dataMap?.quotePage?.QuoteData?.Id, 'vehicleId': this.dataMap?.finalizeVehicleDetails?.Id, 'termAgreement': JSON.stringify(this.dataMap?.finalDetails) });
            }
        } else {
            console.log('Inside else section for createPolicy');
            
            if (this.policyType == 'Watercraft') {
                console.log('creating watercraft real newuser ');
                policy = await createWaterCraftPolicy({ 'leadId': this.leaddata?.Id });
            } else {
                console.log('After else section for creating the policy');
                policy = await createPolicy({ 'leadId': this.dataMap?.userDetails?.Id });
                console.log('Policy-----', policy);
            }
        }
        let resParse = JSON.parse(policy);
        this.policyDetails = resParse;
        if (resParse.status == 'success') {
           

            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'success', title: this.label.Success, message: this.label.PolicyCreated } }));

            //this.changesnextscreen(resParse);
        } else {
            this.generateLogs();
            
            this.dispatchEvent(new CustomEvent('toastevent', { detail: { variant: 'error', title: 'Error', message: this.label.Somethingwentwrongpleasetryagainlater } }));
        }
        console.log("--createPolicy---", resParse);
    }

    setDataLayer() {
        console.log("Called Datalayer");
        window.dataLayer.push({
            event: "payment_details_submit",
        });
    }

    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
    showToastmethod(variant, title, message) {
        this.template.querySelector('c-custom-toast').showToast(variant, title, message);
    }
}