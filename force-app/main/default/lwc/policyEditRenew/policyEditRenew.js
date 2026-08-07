import { LightningElement, api, wire, track } from 'lwc';
import fetchPolicyDetails from '@salesforce/apex/PolicyEditRenewUtils.fetchPolicyDetails';
import fetchPolicyQuoteDetails from '@salesforce/apex/PolicyEditRenewUtils.fetchPolicyQuoteDetails';
import fetchPolicyVehicleDetails from '@salesforce/apex/PolicyEditRenewUtils.fetchPolicyVehicleDetails';
import fetchPolicyDriverDetails from '@salesforce/apex/PolicyEditRenewUtils.fetchPolicyDriverDetails';
import fetchPolicyTowedDetails from '@salesforce/apex/PolicyEditRenewUtils.fetchPolicyTowedDetails';
import fetchDateRelatedInfo from '@salesforce/apex/PolicyEditRenewUtils.fetchDateRelatedInfo';
import createNewEditPolicyFromCash from '@salesforce/apex/PolicyEditRenewUtils.createNewEditPolicyFromCash';
import createNewEditPolicyFromCashWithAmount from '@salesforce/apex/PolicyEditRenewUtils.createNewEditPolicyFromCashWithAmount';
import createNewEditPolicy from '@salesforce/apex/AgentAppController.createNewEditPolicy';
import paymentThroughCard from '@salesforce/apex/AgentAppController.paymentThroughCard';
import updatePolicyDetails from '@salesforce/apex/AgentAppController.updatePolicyDetails';
import createCloneQuote from '@salesforce/apex/AgentAppController.createCloneQuote';
import updateQuoteTime from '@salesforce/apex/AgentAppController.updateQuoteTime';
import fetchUpdatedDate from '@salesforce/apex/PolicyEditRenewUtils.fetchUpdatedDate';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';
import createTransactionWithPredefinedAmount from '@salesforce/apex/PaymentFormController.createTransactionWithPredefinedAmount';
import getUpdatedPolicyData from '@salesforce/apex/AfterPolicyCreated.getUpdatedPolicyData';
import getPolicyData from '@salesforce/apex/AfterPolicyCreated.getPolicyData';
import getContactEmail from '@salesforce/apex/AfterPolicyCreated.getContactEmail';
import USER_ID from '@salesforce/user/Id';
import getAgentFeeFRomUser from '@salesforce/apex/AgencyController.getAgentFeeFromUser';
import updateAgentFeeFromQuote from '@salesforce/apex/AgencyController.updateAgentFeeFromQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import refundTransaction from '@salesforce/apex/PaymentFormController.refundTransaction';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';



export default class PolicyEditRenew extends NavigationMixin(LightningElement) {
    @track OldAgentFee;
    @track OldQuote;
    @api
    policyId;
    //actionmode = 'renew';
    @api
    actionmode;
    @api cmpSource;
    trackVar = {
        'startDate': '',
        'endDate': '',
        'startTime': '',
        'endTime': ''
    }
    @track paymentsFields = { paymentZip: '', paymentCity: '', paymentState: '', paymentCountry: '', paymentCountrycmbx: '', paymentStreet: '' };
    @track formattedCreditCardNumber;
    @track
    booleanVar = {
        'isShowingEndTerm': true,
        'registeredOwner': false,
        'companyRegisteredOption': false,
        'Electric_Hybrid__c': false,
        'isOwner': false,
        'isTowing': false,
        'editDriverBtn': false,
        'isLienholderChecked': false,
        'isVehicleRentedChecked': false,
        'companyAddressOption': false,
        'showCardPayment': false,
        'showCashPayment': false,
        'isLoading': false
    }
    TowedVehicleOptions = [
        { label: 'Motorcycle', value: 'Motorcycle' },
        { label: 'ATV_UTV', value: 'ATV-UTV' },
        { label: 'Boat', value: 'Boat' },
        { label: 'Camper', value: 'Camper' },
        { label: 'Utility_Misc_Trailer', value: 'Utility/Misc Trailer' },
        { label: 'Towed_Automobile', value: 'Towed Automobile' },
    ];
    quoteData;
    policyData;
    @track vehicleData;
    quoteDataBackup;
    policyDataBackup;
    vehicleDataBackup;
    addedTowedBackup = [];
    addedDriverBackup = [];
    isLoadQuoteScreen = false;
    isLoadEditQuoteScreen = false;
    isLoadNorthboundEditQuoteScreen = false;
    isRenewalPolicy = 'Yes';
    addedDriver = [];
    addedTowed = [];
    @track newDriver = {};
    trackVar = {};
    newTowed = {};
    paymentDetails = {};
    selectedDriverLicense = '';
    activeSectionName = 'A';
    paymentPrice;
    renewdPolicyId;
    isPolicyTransactionCompleted = false;
    mindate;
    months = [];
    years = [];
    currentDate = new Date();
    startMonthNumber = 1;
    otherCountryCompany = false;
    otherCountryRegister = false;
    otherCountrypayment = false;
    quoteDataUpdate;
    trueValue = true;
    invalidCheck = false;
    pname;
    apextimedata;

    @track agentfeeinquote;
    @track agentFee;
    @track isDisabled = true;
    @track
    mexicoStateList = [
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
    @track
    unitedStatesList = [
        { value: "Alabama", label: "Alabama" },
        { value: "Alaska", label: "Alaska" },
        { value: "Arizona", label: "Arizona" },
        { value: "Arkansas", label: "Arkansas" },
        { value: "California", label: "California" },
        { value: "Colorado", label: "Colorado" },
        { value: "Connecticut", label: "Connecticut" },
        { value: "Delaware", label: "Delaware" },
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
    @track
    canadaStateList = [
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

    @track
    vehicleStateOption = [];




    @wire(getTimeZone)
    timezonedata({ data, error }) {
        if (data) {
            const newdata = JSON.parse(JSON.stringify(data));
            this.apextimedata = newdata;
            console.log('Time data is retrived in the wire', newdata);
        }
        else if (error) {
            console.log('Error in retrieving time data', error);
        }
    }

    timeToMilliseconds(timeStr) {
        // Split the time string into [hours, minutes, seconds.milliseconds]
        let timeParts = timeStr.split(':'); // ["04", "45", "00.000"]

        let hours = parseInt(timeParts[0]);          // Convert hours to integer
        let minutes = parseInt(timeParts[1]);        // Convert minutes to integer

        // Split the seconds and milliseconds part if milliseconds exist
        let secondsParts = timeParts[2].split('.');  // ["00", "000"]
        console.log('Secong part', JSON.stringify(secondsParts));
        let seconds = parseInt(secondsParts[0]);     // Convert seconds to integer

        // Calculate total milliseconds
        let totalMilliseconds = (hours * 60 * 60 * 1000) + // hours to milliseconds
            (minutes * 60 * 1000) +   // minutes to milliseconds
            (seconds * 1000);             // add remaining milliseconds

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


        let customerDate = this.quoteData?.Start_Date_for_Coverage__c;
        let dateParts = customerDate.split('-');
        let localDate = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);

        let datefromapex = apexdata.dtPST.split(' ')[0];
        let apexdateparts = datefromapex.split('-');
        let todaycheck = new Date(apexdateparts[0], apexdateparts[1] - 1, apexdateparts[2]);

        console.log('Selected date', localDate);
        console.log('Date from apex', todaycheck);


        if (
            localDate.getFullYear() === todaycheck.getFullYear() &&
            localDate.getMonth() === todaycheck.getMonth() &&
            localDate.getDate() === todaycheck.getDate()) {
            if (converted < timedataconverted && this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Start time is already passed. Please select the next time slot.', 'Wrong time selected');
                return false;
            }
            else if (converted < timedataconverted) {
                this.showToastEvent('Wrong time selected!', 'Start time is already passed. Please select the next time slot.', 'error');
                return false;
            }
            return true;

        }
        return true;
    }


    handleAgentFee(event) {

        this.agentFee = event.target.value;
        console.log('this.agentfee', this.agentFee);
        if (parseFloat(this.agentFee) >= 0) {
            this.isDisabled = false;
        } else {
            this.isDisabled = true;
        }

    }

    async handleUpdateRateValue() {
        this.isDisabled = true;
        if (this.agentFee != null) {

            // this.trackVar.qualitasRatevalue = parseFloat(this.allQuoteDeatils.qualitasQuote.rateValue) + parseFloat(this.agentFee);
            // this.trackVar.chubbRateValue = parseFloat(this.allQuoteDeatils.chubbQuote.rateValue) + parseFloat(this.agentFee);
            // this.trackVar.mapfreRatevalue = parseFloat(this.allQuoteDeatils.mapfreQuote.rateValue) + parseFloat(this.agentFee);

            this.agentfeeinquote = this.agentFee;
            this.template.querySelector('c-under-writer-screen-clone').handleAgentFeeUpdate(this.agentfeeinquote);

            await updateAgentFeeFromQuote({ 'agentFee': this.agentFee, 'userId': USER_ID }).then((item) => {
                if (item) {
                    console.log('item--->', item);
                }
            })
        }
        console.log('this.agentFee', this.agentFee);
        console.log('this.trackVar.qualitasRatevalue', this.trackVar.qualitasRatevalue);

    }


    get payeeName() {

        let payeename;

        for (let eachDriver of this.addedDriver) {

            if (eachDriver.Driver_Type__c == 'Owner & Driver' || eachDriver.Driver_Type__c == 'Owner' || eachDriver.Driver_Type__c == true || eachDriver.Driver_Type__c == 'true' && this.invalidCheck === false) {

                payeename = `${eachDriver.First_Name__c} ${eachDriver.Last_Name__c}`.trim();

                this.pname = payeename;

                this.invalidCheck = false;

            }

            else if (this.invalidCheck === true) {

                payeename = this.pname;

            }

        }


        if (this.invalidCheck === false) {

            this.paymentDetails['name'] = payeename;

            this.invalidCheck = false;

        }

        else if (this.invalidCheck === true) {

            this.paymentDetails['name'] = this.pname;

        }

        console.log('Payment details in payee', JSON.stringify(this.paymentDetails));

        console.log('Payment Namre ---->', payeename);
        this.triggerChangeEvent();

        return payeename;

    }

    triggerChangeEvent() {

        const inputElement = this.template.querySelector('[data-id="card-holder-name"]');

        if (inputElement) {

            inputElement.dispatchEvent(new Event('change'));

        }

    }


    get acknowledgementMessage() {
        return this.actionmode == 'renew' ? 'Your policy has been renewed successfully' : 'Your policy has been updated successfully';
    }
    get medicalOption() {
        if (this.policyData && this.policyData.Policy_Type_picklist__c != 'Northbound' && this.policyData.Policy_Type_picklist__c != 'Watercraft' && this.policyData.Policy_Type_picklist__c != 'Driver License' && this.policyData.Policy_Type_picklist__c != 'Automobile') {
            if (this.actionmode == 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Chubb' && this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV') {
                return [{ 'label': '$10,000/$50,000', 'value': '10,000/50,000' },
                { 'label': '$15,000/$75,000', 'value': '15,000/75,000' },
                { 'label': '$20,000/$100,000', 'value': '20,000/100,000' }];
            } else {
                return [{ 'label': '$2,000/$10,000', 'value': '2,000/10,000' },
                { 'label': '$3,000/$15,000', 'value': '3,000/15,000' },
                { 'label': '$4,000/$20,000', 'value': '4,000/20,000' },
                { 'label': '$5,000/$25,000', 'value': '5,000/25,000' },
                { 'label': '$10,000/$50,000', 'value': '10,000/50,000' }];
            }

        } else if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound') {
            return [{ 'label': '$5,000/$25,000', 'value': '5,000/25,000' }];

        }

        else if (this.policyData && this.policyData.Policy_Type_picklist__c != undefined && this.policyData.Policy_Type_picklist__c == 'Automobile') {

            if (this.actionmode == 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Chubb') {
                return [{ 'label': '$10,000/$50,000', 'value': '10,000/50,000' },
                { 'label': '$15,000/$75,000', 'value': '15,000/75,000' },
                { 'label': '$20,000/$100,000', 'value': '20,000/100,000' }];
            } else {
                return [{ 'label': '$2,000/$10,000', 'value': '2,000/10,000' },
                { 'label': '$3,000/$15,000', 'value': '3,000/15,000' },
                { 'label': '$4,000/$20,000', 'value': '4,000/20,000' },
                { 'label': '$5,000/$25,000', 'value': '5,000/25,000' },
                { 'label': '$10,000/$50,000', 'value': '10,000/50,000' },
                { 'label': '$15,000/$75,000', 'value': '15,000/75,000' },
                { 'label': '$20,000/$100,000', 'value': '20,000/100,000' }];
            }

        } else if (this.policyData && this.policyData.Policy_Type_picklist__c && this.policyData.Policy_Type_picklist__c == 'Watercraft') {
            return [
                { 'label': '$50,000/$100,000', 'value': '50,000/100,000' },
                { 'label': '$100,000/$300,000', 'value': '100,000/300,000' },
                { 'label': '$250,000/$500,000', 'value': '250,000/500,000' }];
        } else {
            return [];
        }
    }
    get liabilityOption() {
        if (this.policyData?.Underwriter_picklist__c == 'Mapfre') {
            return [
                { 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' }];
        }
        return [
            { 'label': '$100,000', 'value': '100,000' },
            { 'label': '$200,000', 'value': '200,000' },
            { 'label': '$300,000', 'value': '300,000' },
            { 'label': '$500,000', 'value': '500,000' },
            { 'label': '$1,000,000', 'value': '1,000,000' }];
        if (this.policyData != undefined && this.policyData.Policy_Type_picklist__c != 'Northbound' && this.policyData.Policy_Type_picklist__c != 'Watercraft' && this.policyData.Policy_Type_picklist__c != 'Driver License' && this.policyData.Policy_Type_picklist__c != 'Automobile') {

            if (this.actionmode == 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Chubb' && (this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' || this.policyData.Policy_Type_picklist__c == 'RV')) {
                return [
                    { 'label': '$100,000', 'value': '100,000' },
                    { 'label': '$200,000', 'value': '200,000' },
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else if (this.actionmode == 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Qualitas' && (this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' || this.policyData.Policy_Type_picklist__c == 'RV')) {
                return [{ 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' },
                { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else if (this.actionmode == 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Mapfre' && (this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' || this.policyData.Policy_Type_picklist__c == 'RV')) {

                return [
                    { 'label': '$100,000', 'value': '100,000' },
                    { 'label': '$150,000', 'value': '150,000' },
                    { 'label': '$200,000', 'value': '200,000' },
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                ];
            } else if (this.actionmode != 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Chubb' && (this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' || this.policyData.Policy_Type_picklist__c == 'RV')) {
                return [
                    { 'label': '$100,000', 'value': '100,000' },
                    { 'label': '$200,000', 'value': '200,000' },
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else if (this.actionmode != 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Qualitas' && (this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' || this.policyData.Policy_Type_picklist__c == 'RV')) {
                return [{ 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' },
                { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else if (this.actionmode != 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Mapfre' && (this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' || this.policyData.Policy_Type_picklist__c == 'RV')) {

                return [
                    { 'label': '$100,000', 'value': '100,000' },
                    { 'label': '$150,000', 'value': '150,000' },
                    { 'label': '$200,000', 'value': '200,000' },
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                ];
            }

        } else if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Automobile') {

            if (this.actionmode == 'renew' && this.policyData && this.policyData.Underwriter_picklist__c && this.policyData.Underwriter_picklist__c == 'Chubb') {
                return [
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else {
                return [{ 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' },
                { 'label': '$1,000,000', 'value': '1,000,000' }];
            }


        } else if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Watercraft') {
            return [{ 'label': '$200,000', 'value': '200,000' },
            { 'label': '$400,000', 'value': '400,000' },
            { 'label': '$750,000', 'value': '750,000' }];
        } else if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound') {
            return [{ 'label': '$100,000', 'value': '100,000' },
            { 'label': '$200,000', 'value': '200,000' },
            { 'label': '$300,000', 'value': '300,000' }];
        } else if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Driver License') {
            return [{ 'label': '$300,000', 'value': '300,000' },
            { 'label': '$500,000', 'value': '500,000' }];
        } else {
            return [];
        }
    }
    get policyTermOption() {
        return [
            { label: 'Annual', value: 'Annual' },
            { label: 'Semi-Annual', value: 'Semi-Annual' },
            { label: 'Daily', value: 'Daily' },
        ];
    }
    get territoryOption() {
        return [
            { label: 'Baja/Sonora', value: 'Baja/Sonora' },
            { label: 'Limited', value: 'Limited' },
            { label: 'Full', value: 'Full' },
        ];
    }
    get quoteId() {
        console.log('Quote Id--->', this.policyData?.Quote_c__c)
        return (this.policyData && this.policyData.Quote_c__c) ? this.policyData.Quote_c__c : '';
    }
    get vehicleId() {
        return (this.policyData && this.policyData.Vehicle_Policy__c) ? this.policyData.Vehicle_Policy__c : '';
    }

    get isMedicalVisible() {
        return this.policyData && this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' ? false : true;
    }
    get isTowedVisible() {
        return this.policyData && this.policyData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' ? false : true;
    }
    get isPaymentNeeded() {
        if (this.actionmode == 'renew') {
            return true;
        } else if (this.actionmode == 'edit' && this.paymentPrice == 0) {
            return false;
        } else {
            return true;
        }
    }

    get editpolicydata() {
        return {
            'policyData': this.policyData,
            'quoteData': this.quoteData,
            'Is_Towing__c': this.booleanVar.isTowing,
            'towedUnitData': this.addedTowed
        }
    }

    get isDiscountVisible() {
        return this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound' ? false : true;
    }

    get isRenewalPolicyFlag() {
        let convertedStartDate = new Date(this.policyData?.Start_Date__c);
        let todaysDate = new Date();
        if (this.actionmode == 'edit') {
            if (convertedStartDate <= todaysDate) {
                console.log('Returned if false');
                this.isDisabled = true;
                return false;
            } else {
                console.log('Returned if true');
                this.isDisabled = false;
                return true;
            }

        } else {
            console.log('Returned else true');
            this.isDisabled = false;
            return true;
        }
        // return this.actionmode == 'renew';
    }

    get isdisabledstartdate() {
        let convertedStartDate = new Date(this.policyData?.Start_Date__c);
        let todaysDate = new Date();
        if (this.actionmode == 'edit') {
            if (convertedStartDate <= todaysDate) {
                return true;
            } else {
                console.log('Returned if true');
                return false;
            }

        } else {
            return false;
        }
    }

    get isEditEndDateFlag() {
        let convertedStartDate = new Date(this.policyData?.Start_Date__c);
        let todaysDate = new Date();


        if (this.actionmode == 'edit') {
            if (convertedStartDate >= todaysDate) {
                if (this.policyData?.Term__c === 'Daily' && this.quoteData?.Term__c == 'Daily') {
                    let templateElement = this.template.querySelectorAll('.End_Date_for_Coverage__c');
                    templateElement.forEach(element => {
                        //Added this if block on 6 Aug
                        if (this.quoteData.End_Date_for_Coverage__c != this.policyData.End_Date__c) {
                            element.value = this.quoteData?.End_Date_for_Coverage__c;
                        }
                        else {
                            element.value = this.policyData?.End_Date__c;
                        }
                    });
                    return true;
                } else {
                    if (this.quoteData?.Term__c != 'Daily') {
                        return false;
                    } else {
                        return true;
                    }
                }

            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    // get isEditEndDateFlag() {
    //     const convertedStartDate = new Date(this.policyData?.Start_Date__c);
    //     const formattedStartDate = convertedStartDate.toDateString();
    //     const todaysDate = new Date();
    //     let templateElement = this.template.querySelectorAll('.End_Date_for_Coverage__c');
    //     templateElement.forEach(element => {
    //         element.value = this.policyData?.End_Date__c;
    //     });

    //     if (this.actionmode !== 'edit') {
    //         return false;
    //     }

    //     if (convertedStartDate < todaysDate) {
    //         return false;
    //     }

    //     if (this.policyData?.Term__c === 'Daily' && this.quoteData?.Term__c !== 'Daily') {
    //         return false;
    //     }

    //     return true;
    // }


    get editOldProcessData() {
        return {
            'policyData': this.policyDataBackup,
            'vehicleData': this.vehicleDataBackup,
            'DriverData': this.addedDriverBackup,
            'towedUnitData': this.addedTowedBackup,
            'quoteData': this.quoteDataBackup,
            'transactionData': [],
            'Is_Towing__c': this.booleanVar.isTowing,
            'towedUnitData': this.addedTowed
        }
    }
    get editNewProcessData() {
        return {
            'policyData': this.policyData,
            'vehicleData': this.vehicleData,
            'DriverData': this.addedDriver,
            'towedUnitData': this.addedTowed,
            'quoteData': this.quoteData,
            'transactionData': [],
            'Is_Towing__c': this.booleanVar.isTowing,
            'towedUnitData': this.addedTowed
        }
    }

    get MM() {
        this.months = [];
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
        let currentYear = this.currentDate.getFullYear();
        let startFrom = currentYear;
        for (startFrom; startFrom < (currentYear + 40); startFrom++) {
            this.years.push({
                'label': startFrom.toString(),
                'value': startFrom.toString()
            });
        }
        return this.years;
    }

    get maxDOBDate() {
        const today = new Date();
        today.setFullYear(today.getFullYear() - 15);
        const year = today.getFullYear();
        const month = (today.getMonth() + 1).toString().padStart(2, '0');
        const day = today.getDate().toString().padStart(2, '0');

        return `${year}-${month}-${day}`;
    }

    get formattedCreditCardNumberOrg() {
        return this.formattedCreditCardNumber?.replace(/ /g, '');
    }

    get countryoptions() {
        if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound') {
            return [
                { label: 'Mexico', value: 'Mexico' },
                { label: 'Other', value: 'Other' }
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
        if (this.quoteData && this.quoteData?.Registered_Country__c != undefined) {
            if (this.quoteData && this.quoteData.Registered_Country__c == 'Mexico') {
                return this.mexicoStateList;
            }
            else if (this.quoteData && this.quoteData.Registered_Country__c == 'United States') {
                return this.unitedStatesList;
            }
            else if (this.quoteData && this.quoteData.Registered_Country__c == 'Canada') {
                return this.canadaStateList;
            }
        } else {
            if (this.vehicleData && this.vehicleData.Registered_Country__c == 'Mexico') {
                return this.mexicoStateList;
            }
            else if (this.vehicleData && this.vehicleData.Registered_Country__c == 'United States') {
                return this.unitedStatesList;
            }
            else if (this.vehicleData && this.vehicleData.Registered_Country__c == 'Canada') {
                return this.canadaStateList;
            }
        }
    }

    get CompanyStateOption() {
        if (this.quoteData && this.quoteData?.Company_Country__c != undefined) {
            if (this.quoteData && this.quoteData.Company_Country__c == 'Mexico') {
                return this.mexicoStateList;
            }
            else if (this.quoteData && this.quoteData.Company_Country__c == 'United States') {
                return this.unitedStatesList;
            }
            else if (this.quoteData && this.quoteData.Company_Country__c == 'Canada') {
                return this.canadaStateList;
            }
        } else {
            if (this.vehicleData && this.vehicleData.Company_Country__c == 'Mexico') {
                return this.mexicoStateList;
            }
            else if (this.vehicleData && this.vehicleData.Company_Country__c == 'United States') {
                return this.unitedStatesList;
            }
            else if (this.vehicleData && this.vehicleData.Company_Country__c == 'Canada') {
                return this.canadaStateList;
            }
        }
    }

    get paymentStateOption() {
        if (this.paymentDetails.Country__c == 'Mexico') {
            return this.mexicoStateList;
        }
        else if (this.paymentDetails.Country__c == 'United States') {
            return this.unitedStatesList;
        }
        else if (this.paymentDetails.Country__c == 'Canada') {
            return this.canadaStateList;
        }
    }


    @wire(getAgentFeeFRomUser, { 'userId': USER_ID })
    getAgentFee({ data, error }) {
        if (data) {

            console.log('data--->', error);
            this.agentFee = data;
            this.agentfeeinquote = data;
        } else {
            this.agentFee = 0;
            this.agentfeeinquote = 0;
        }

        if (error) {
            console.log('Error in getAgentFeeFromUser', error);
        }
    }

    @wire(fetchDateRelatedInfo)
    wiringdates({ data, error }) {
        if (data) {
            console.log('date');
            console.log(data);
            // let minimumDate = new Date(data.minDate);
            // console.log('minimumDate',minimumDate);
            this.mindate = data.minDate;
        } else {
            console.log('Error in fetchDateRelatedInfo', error);
        }
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('Wire')
        if (currentPageReference) {
            let params = currentPageReference.state;
            if (params) {
                this.policyId = params?.c__policyId;
                this.actionmode = params?.c__actionmode;
            }
        } else {
            console.log('Params are not there')
        }
    }

    @wire(fetchPolicyDetails, { policyId: '$policyId' })
    wiringpolicyData({ data, error }) {
        if (data) {
            console.log('fetched ploicy');
            this.policyData = JSON.parse(JSON.stringify(data));
            console.log(this.policyData);
            if (this.actionmode == 'edit') {
                this.policyDataBackup = JSON.parse(JSON.stringify(data));
            }
            this.OldQuote = this.policyData?.Total_Transaction_Amount__c != undefined ? this.policyData.Total_Transaction_Amount__c : 0;
            this.OldAgentFee = this.policyData?.Agent_Fee__c != undefined ? this.policyData.Agent_Fee__c : 0;

        } else {
            console.log('Error in fetched policy', error);
        }
    };

    @wire(fetchPolicyQuoteDetails, { quoteId: '$quoteId' })
    wiringQuoteData({ data, error }) {
        if (data) {
            console.log('fetched Quote');
            console.log(data);
            this.quoteData = JSON.parse(data);

            if (this.quoteData.Start_Time__c.endsWith('Z')) {
                this.quoteData.Start_Time__c = this.quoteData.Start_Time__c.substring(0, this.quoteData.Start_Time__c.length - 1);
            }

            if (this.quoteData.End_Time__c.endsWith('Z')) {
                this.quoteData.End_Time__c = this.quoteData.End_Time__c.substring(0, this.quoteData.End_Time__c.length - 1);
            }


            if (this.actionmode == 'edit') {
                this.quoteDataBackup = JSON.parse(data);
            }
            this.autoFillValues(this.quoteData, true);
            this.autoFillValues(this.quoteData, false);

        } else {
            console.log('Quote Id in wire--->', this.quoteId);
            console.log('Error in fetch policyQuoteDetails', error);
        }
    };

    @wire(fetchPolicyVehicleDetails, { vehicleId: '$vehicleId' })
    wiringVehicleData({ data, error }) {
        if (data) {
            console.log('fetched vehicle');
            console.log(data);
            this.vehicleData = JSON.parse(data);
            if (this.actionmode == 'edit') {
                this.vehicleDataBackup = JSON.parse(data);
            }
            if (this.vehicleData.Is_vehicle_owned_by_a_company_or_rented__c == true) {
                this.booleanVar.registeredOwner = true;
                if (this.vehicleData.Company_Country__c == 'United States' || this.vehicleData.Company_Country__c == 'Canada' || this.vehicleData.Company_Country__c == 'Mexico') {
                    this.otherCountryCompany = false;
                    this.vehicleData = { ...this.vehicleData, ['companyCountrycmbx']: this.vehicleData.Company_Country__c };
                    this.vehicleData = { ...this.vehicleData, ['Company_Country__c']: this.vehicleData.Company_Country__c };
                } else {
                    this.otherCountryCompany = true;
                    this.vehicleData = { ...this.vehicleData, ['companyCountrycmbx']: 'Other' };
                    this.vehicleData = { ...this.vehicleData, ['Company_Country__c']: this.vehicleData.Company_Country__c };
                }
            }

            if (this.vehicleData.Is_Lienholder__c == true) {
                if (this.vehicleData.Lienholder_Country__c == 'United States' || this.vehicleData.Lienholder_Country__c == 'Canada' || this.vehicleData.Lienholder_Country__c == 'Mexico') {
                    this.otherCountryCompany = false;
                    this.vehicleData = { ...this.vehicleData, ['lienHolderCountrycmbx']: this.vehicleData.Lienholder_Country__c };
                    this.vehicleData = { ...this.vehicleData, ['Lienholder_Country__c']: this.vehicleData.Lienholder_Country__c };
                } else {
                    this.otherCountryCompany = true;
                    this.vehicleData = { ...this.vehicleData, ['lienHolderCountrycmbx']: 'Other' };
                    this.vehicleData = { ...this.vehicleData, ['Lienholder_Country__c']: this.vehicleData.Lienholder_Country__c };
                }
            }

            if (this.vehicleData.Electric_Hybrid__c) {
                this.booleanVar.Electric_Hybrid__c = true;
            } else {
                this.booleanVar.Electric_Hybrid__c = false;
            }

            this.autoFillValues(this.vehicleData, true);
        } else {
            console.log('Error in fetched policy vehicle data-->', error);
        }
    };

    @wire(fetchPolicyDriverDetails, { quoteId: '$quoteId' })
    wiringDriverData({ data, error }) {
        if (data) {
            console.log('fetched driver');
            console.log(data);
            this.addedDriver = JSON.parse(data);
            if (this.actionmode == 'edit') {
                this.addedDriverBackup = JSON.parse(data);
            }
            for (let driver of this.addedDriver) {
                driver.showDeleteButton = true;
                driver.isOwner = (driver.Driver_Type__c && (driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == true || driver.Driver_Type__c == 'true')) ? true : false;
                if (driver.Country__c == 'Mexico') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                }
                else if (driver.Country__c == 'United States') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                }
                else if (driver.Country__c == 'Canada') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }

                if (driver.License_Country__c == 'Mexico') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                }
                else if (driver.License_Country__c == 'United States') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                }
                else if (driver.License_Country__c == 'Canada') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }
            }
            //this.autoFillValues(this.vehicleData,true);
        } else {
            console.log('Error in fetch policy driver details ', error);
        }
    };

    @wire(fetchPolicyTowedDetails, { quoteId: '$quoteId' })
    wiringTowedData({ data, error }) {
        if (data) {
            console.log('fetched Towed');
            console.log(data);
            this.addedTowed = JSON.parse(data);
            if (this.actionmode == 'edit') {
                this.addedTowedBackup = JSON.parse(data);
            }

            for (let i = 0; i < this.addedTowed.length; i++) {
                this.addedTowed[i].towedCount = i;
                this.addedTowed[i].isDeleteTowedButton = true;
            }
            console.log('Towed Unit');
            console.log(this.addedTowed);
        } else {
            console.log('Error in fetch policy towed details', error);
        }
    };
    //lifecyly hooks
    toDigitFormate(n) {
        return n > 9 ? "" + n : "0" + n;
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

    autoFillValues(data, autoFill) {
        //Filling Term Options
        if (autoFill) {
            for (let eachParam in data) {
                if (eachParam) {
                    console.log(eachParam);
                    let templateElement = this.template.querySelector('.' + eachParam);
                    if (templateElement != null) {
                        templateElement.value = data[eachParam];
                        //3 Sep update
                        if (eachParam === "Start_Date_for_Coverage__c") {
                            console.log('Inside date set');
                            this.trackVar.startDate = data[eachParam];
                        }
                    }
                    console.log('Check set value for fields-----', data[eachParam]);
                    // console.log(templateElement.value);
                }
            }
        } else {
            //filing for term
            //filling for towed Unit
            if (data && data.Towed_Unit__c == 'Yes') {
                const termOptionel = this.template.querySelector('.TowedUnit');
                termOptionel.checked = true;
                this.booleanVar.isTowing = true;
            } else {
                this.booleanVar.isTowing = false;
            }

        }

    }

    //event handlers
    isInputValidbyClass(className) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(className);
        console.log('----', inputFields);
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
                this.invalidCheck = true;
            }
        });
        return isValid;
    }

    handleToggleSection(event) {
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = this.activeSectionName;
    }

    handlePaymentInputChange = (event) => {
        this.paymentDetails[event.target.name] = event.target.value;

        if (event.target?.name == 'paymentCountrycmbx') {
            this.paymentDetails = { ...this.paymentDetails, ['Country__c']: event.target.value };
            if (event.target.value == 'Other') {
                this.otherCountrypayment = true;
            } else {
                this.otherCountrypayment = false;
            }
        }

        if (event.target?.name == 'year') {
            if (event.target?.value == this.currentDate.getFullYear()) {
                this.startMonthNumber = this.currentDate.getMonth() + 1;
                this.months = [];
                this.template.querySelectorAll('lightning-combobox').forEach(each => {
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
                console.log(this.template.querySelector('[data-id="month"]'))
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
            console.log('Card formatter');
            const rawNumber = event.target.value.replace(/ /g, '');
            const formattedNumber = this.formatCreditCardNumber(rawNumber);
            this.formattedCreditCardNumber = formattedNumber;
            let cardNum = this.template.querySelector('[data-id="cardNumber"]');
            let expMonth = this.template.querySelector('[data-id="month"]');
            let expYear = this.template.querySelector('[data-id="year"]');
            this.paymentDetails = { ...this.paymentDetails, ['cardNumber']: rawNumber };
            if (event.target.value != '') {
                console.log('Value is ' + event.target.value)
                cardNum.required = true;
                expMonth.required = true;
                expYear.required = true;

                cardNum.className = 'validate'
                expMonth.className = 'validate'
                expYear.className = 'validate'
            } else {
                cardNum.required = false;
                expMonth.required = false;
                expYear.required = false;

                cardNum.className = ''
                expMonth.className = ''
                expYear.className = ''
            }

        }


    }

    formatNumber(phone, name) {
        let cleaned = ('' + phone).replace(/\D/g, '');
        let match = cleaned.match(/^(\d{3})(\d{3})(\d{4,7})$/);
        if (match) {

            if (name == 'Phone__c') {
                this.newDriver.Phone__c = '(' + match[1] + ') ' + match[2] + '-' + match[3];
            }

            if (name == 'Company_Phone__c') {
                this.vehicleData.Company_Phone__c = '(' + match[1] + ') ' + match[2] + '-' + match[3];
            }

            if (name == 'Lienholder_Phone__c') {
                this.vehicleData.Lienholder_Phone__c = '(' + match[1] + ') ' + match[2] + '-' + match[3];
            }

        }
    }


    formatCreditCardNumber(rawNumber) {
        let formattedNumber = '';
        for (let i = 0; i < rawNumber.length; i++) {
            if (i > 0 && i % 4 === 0) {
                formattedNumber += ' ';
            }
            formattedNumber += rawNumber.charAt(i);
        }
        return formattedNumber;
    }

    //For Going back to First screen
    navigateScreen(event) {
        if (event.detail == 'pre-quote') {
            this.isLoadEditQuoteScreen = false;
            this.isLoadNorthboundEditQuoteScreen = false;
            this.isLoadQuoteScreen = false;
            this.activeSectionName = 'A';
            const accordion = this.template.querySelector('.example-accordion');
            accordion.activeSectionName = this.activeSectionName;
        }
    }
    //For going to payment screen on renewal process
    async navigatePaymentScreen(event) {
        let retrievedObject = event.detail;
        this.paymentPrice = retrievedObject.rateValue;
        this.quoteData = { ...retrievedObject.updatedQuote };
        console.log('recheved data-> ' + JSON.stringify(this.quoteData));
        console.log('recheved data-> ' + this.quoteData.Id);
        console.log('quoteDataUpdate--->', this.quoteDataUpdate);
        await updateQuoteTime({ 'quoteDataUpdate': JSON.stringify(this.quoteData), 'quoteId': this.quoteData.Id });

        this.activeSectionName = 'C';
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = this.activeSectionName;
        this.paymentFieldsValue();
    }
    //for going back to Quote screen from Payment screen
    navigatePrevious(event) {
        this.activeSectionName = 'B';
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = this.activeSectionName;
        if (this.actionmode == 'renew') {
            if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound') {
                this.isLoadNorthboundEditQuoteScreen = true;
            } else {
                this.isLoadQuoteScreen = true;
            }

        } else {

            this.isLoadEditQuoteScreen = true;


        }

    }
    //for going to payment screen on edit process
    navigateToPayment(event) {
        let retrievedObject = event.detail;
        console.log('recieving on payment');
        console.log('recieving on payment-> ' + JSON.stringify(retrievedObject));
        this.quoteData = { ...retrievedObject.editPolicyData };
        this.paymentPrice = retrievedObject.amountDifference;
        this.activeSectionName = 'C';
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = this.activeSectionName;
        this.paymentFieldsValue();
    }
    updateTowingCheckbox(event) {
        this.booleanVar.isTowing = event.detail.checked;
        if (event.detail.checked) {
            this.quoteData.Towed_Unit__c = 'Yes';
        } else {
            this.quoteData.Towed_Unit__c = 'No';
        }

    }


    generateQuote(event) {
        if (this.booleanVar.isTowing == false) {
            this.addedTowed = [];
        }

        const mockEvent = {
            target: {
                value: this.quoteData?.Start_Time__c
            }
        };


        // 17 Sep
        if (!this.handleStartTimeValidation(mockEvent)) {
            return;
        }

        console.log('Test Insdide generateQuote');
        console.log('updateTowedController-->', this.addedTowed);
        if (this.isInputValid()) {
            console.log('Test Insdide IF AAAA');
            if (this.validateLienholderData()) {
                if (this.validateBeforeQuoteGenerationDrivers()) {
                    console.log('Test Insdide IFFF BBB');
                    if (this.validateBeforeQuoteGenerationTowed()) {
                        console.log('Test Insdide IFFF CCCCC');
                        this.activeSectionName = 'B';
                        const accordion = this.template.querySelector('.example-accordion');
                        accordion.activeSectionName = this.activeSectionName;
                        if (this.actionmode == 'renew') {
                            this.quoteDataUpdate = this.quoteData;
                            console.log('this.quoteDataUpdate--->', this.quoteDataUpdate);
                            if (this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound') {
                                this.isLoadNorthboundEditQuoteScreen = true;
                            } else {
                                this.isLoadQuoteScreen = true;
                            }

                        } else {
                            this.isLoadEditQuoteScreen = true;
                        }
                    }
                }

            }

        } else {

            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Please check if you have filled all the mandatory details.', 'Cannot generate Quote!');

            } else {
                this.showToastEvent('Cannot generate Quote!', 'Please check if you have filled all the mandatory details.', 'error');
            }

        }

    }

    validateLienholderData() {
        console.log('inside validate lienholder', this.vehicleData);
        if (this.vehicleData.Is_Lienholder__c == true && (
            !('Lienholder_City__c' in this.vehicleData) || !this.vehicleData.Lienholder_City__c ||
            !('Lienholder_Country__c' in this.vehicleData) || !this.vehicleData.Lienholder_Country__c ||
            !('Lienholder_Phone__c' in this.vehicleData) || !this.vehicleData.Lienholder_Phone__c ||
            !('Lienholder_Postal_Code__c' in this.vehicleData) || !this.vehicleData.Lienholder_Postal_Code__c ||
            !('Lienholder_State__c' in this.vehicleData) || !this.vehicleData.Lienholder_State__c ||
            !('Lienholder_Street__c' in this.vehicleData) || !this.vehicleData.Lienholder_Street__c ||
            !('Lienholder_name__c' in this.vehicleData) || !this.vehicleData.Lienholder_name__c
        )) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'For proceeding further,Please fill Lienholder Details.', 'Lienholder are not correct!');
                return false;
            } else {
                this.showToastEvent('Lienholder are not correct!', 'For proceeding further,Please fill Lienholder Details.', 'error');
                return false;
            }
        } else {
            return true;
        }
    }
    validateBeforeQuoteGenerationTowed() {
        let towedstatus = false;
        let callagentTowedUnit = this.template.querySelector('c-agent-towed-unit');
        if (callagentTowedUnit) {
            let response = callagentTowedUnit.validateFields(this.addedTowed);
            console.log('response--->', response);
            if (response == true) {
                towedstatus = false;
            } else {
                towedstatus = true;
            }
        }
        if (this.booleanVar.isTowing && this.addedTowed && this.addedTowed.length > 0 && towedstatus == false) {
            return true;
        } else if (this.booleanVar.isTowing == false) {
            return true;
        } else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Please check Towed unit Details as you have selected for towing.', 'Cannot generate Quote!');

            } else {

                this.showToastEvent('Cannot generate Quote!', 'Please check Towed unit Details as you have selected for towing.', 'error');
            }

            return false;
        }
    }

    validateBeforeQuoteGenerationDrivers() {

        let countOwner = 0;
        for (let eachDriver of this.addedDriver) {
            if (eachDriver.Driver_Type__c == 'Owner & Driver' || eachDriver.Driver_Type__c == 'Owner' || eachDriver.Driver_Type__c == true || eachDriver.Driver_Type__c == 'true') {
                countOwner++;
            }
        }

        if (countOwner == 0 && this.vehicleData.Is_vehicle_owned_by_a_company_or_rented__c == false) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Please check if your insurance has at least 1 owner.', 'Driver details are not correct!');

            } else {

                this.showToastEvent('Driver details are not correct!', 'Please check if your insurance has at least 1 owner.', 'error');
            }
            return false;
        } else if (countOwner > 1 && this.vehicleData.Is_vehicle_owned_by_a_company_or_rented__c == false) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Your insurance quote cannot have more than 1 owner.', 'Driver details are not correct!');

            } else {

                this.showToastEvent('Driver details are not correct!', 'Your insurance quote cannot have more than 1 owner.', 'error');
            }
            return false;
        } else if (countOwner == 1 && this.vehicleData.Is_vehicle_owned_by_a_company_or_rented__c == false) {
            return true;
        } else if (this.vehicleData.Is_vehicle_owned_by_a_company_or_rented__c == true && countOwner > 0) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Your vehicle is company owned, you cannot add owner to this insurance.', 'Driver details are not correct!');

            } else {

                this.showToastEvent('Driver details are not correct!', 'Your vehicle is company owned, you cannot add owner to this insurance.', 'error');
            }
            return false;
        }
        else if (this.vehicleData.Is_vehicle_owned_by_a_company_or_rented__c == true && countOwner == 0) {
            return true;
        }
        else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Something wrong with the drivers, please contact administrator.', 'Driver details are not correct!');

            } else {

                this.showToastEvent('Driver details are not correct!', 'Something wrong with the drivers, please contact administrator.', 'error');
            }

            return false;
        }
    }

    handleUpdateDriver(event) {

        let status = this.isInputValidbyClass('.driverValidation');
        console.log('Validation status in the add driver: ', status)
        if (!status) {
            return true;
        }



        this.booleanVar.editDriverBtn = false;
        this.booleanVar.isOwner = false;

        for (let each of this.addedDriver) {
            if (each.license_number__c === this.selectedDriverLicense) {
                console.log('mathced');
                console.log('this.newDriver', this.newDriver);
                console.log('OUTPUT each: ', each);

                each.showDeleteButton = true;
                each.selectedStyle = '';
                each.First_Name__c = (this.newDriver.First_Name__c) ? this.newDriver.First_Name__c : each.First_Name__c;
                each.Last_Name__c = (this.newDriver.Last_Name__c) ? this.newDriver.Last_Name__c : each.Last_Name__c;
                each.License_Country__c = (this.newDriver.License_Country__c) ? this.newDriver.License_Country__c : each.License_Country__c;
                each.License_state__c = (this.newDriver.License_state__c) ? this.newDriver.License_state__c : each.License_state__c;
                each.license_number__c = (this.newDriver.license_number__c) ? this.newDriver.license_number__c : each.license_number__c;
                each.Dob__c = (this.newDriver.Dob__c) ? this.newDriver.Dob__c : each.Dob__c;
                each.owner = (this.newDriver.owner) ? this.newDriver.owner : each.owner;
                each.Driver_Type__c = (this.newDriver.owner) ? 'Owner & Driver' : 'Driver';
                each.Country__c = (this.newDriver.Country__c) ? this.newDriver.Country__c : each.Country__c;
                each.Postal_Code__c = (this.newDriver.Postal_Code__c) ? this.newDriver.Postal_Code__c : each.Postal_Code__c;
                each.State_Province__c = (this.newDriver.State_Province__c) ? this.newDriver.State_Province__c : each.State_Province__c;
                each.City__c = (this.newDriver.City__c) ? this.newDriver.City__c : each.City__c;
                each.Address__c = (this.newDriver.Address__c) ? this.newDriver.Address__c : each.Address__c;
                //each.Phone__c = (this.newDriver.Phone__c)?this.newDriver.Phone__c:each.Phone__c;

                if (each.License_Country__c == 'United States' || each.License_Country__c == 'Canada' || each.License_Country__c == 'Mexico' || each.License_Country__c == 'Other') {
                    each.otherCountryVehicle = false;
                    each = { ...each, ['License_Country__cmbx']: each.License_Country__c };
                } else {
                    each = { ...each, ['License_Country__cmbx']: 'Other' };
                    each.otherCountryVehicle = true;
                }

                if (each.Country__c == 'United States' || each.Country__c == 'Canada' || each.Country__c == 'Mexico' || each.Country__c == 'Other') {
                    each.otherCountryDriver = false;
                    each = { ...each, ['Country__cmbx']: each.Country__c };
                } else {
                    each = { ...each, ['Country__cmbx']: 'Other' };
                    each.otherCountryDriver = true;
                }

            }
        }



        this.newDriver = {
            ...this.newDriver,
            ['First_Name__c']: "",
            ['Last_Name__c']: "",
            ['License_Country__c']: "",
            ['License_state__c']: "",
            ['license_number__c']: "",
            ['Dob__c']: "",
            ['owner']: false,
            ['otherCountryVehicle']: false,
            ['otherCountryDriver']: false,
            ['Country__c']: '',
            ['Postal_Code__c']: '',
            ['State_Province__c']: '',
            ['City__c']: '',
            ['Address__c']: '',
            //['Phone__c']: ''
        };

    }

    handleEditDriver = (event) => {
        this.newDriver = {};
        this.addedDriver.map(driver => {
            if (event.target.dataset.id === driver?.license_number__c) {

                if (driver.License_Country__c == 'United States' || driver.License_Country__c == 'Canada' || driver.License_Country__c == 'Mexico' || driver.License_Country__c == 'Other') {
                    driver.otherCountryVehicle = false;
                    driver = { ...driver, ['License_Country__cmbx']: driver.License_Country__c };
                } else {
                    driver = { ...driver, ['License_Country__cmbx']: 'Other' };
                    driver.otherCountryVehicle = true;
                }

                if (driver.Country__c == 'United States' || driver.Country__c == 'Canada' || driver.Country__c == 'Mexico' || driver.Country__c == 'Other') {
                    driver.otherCountryDriver = false;
                    driver = { ...driver, ['Country__cmbx']: driver.Country__c };
                } else {
                    driver = { ...driver, ['Country__cmbx']: 'Other' };
                    driver.otherCountryDriver = true;
                }

                this.newDriver = { ...driver };
                if (driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == true || driver.Driver_Type__c == 'true') {
                    this.booleanVar.registeredOwner = false; // 
                    this.booleanVar.isOwner = true;
                    this.newDriver = {
                        ...this.newDriver,
                        ['owner']: true,
                        ['isOwner']: true
                    };
                    let combobox = this.template.querySelector('.registeredOwnerCheckbox');
                    combobox.checked = true;
                } else {
                    this.booleanVar.isOwner = false;
                    this.booleanVar.registeredOwner = false; // 
                    this.newDriver = {
                        ...this.newDriver,
                        ['owner']: false,
                        ['isOwner']: false
                    };
                }

                driver.showDeleteButton = false;
                driver.selectedStyle = 'background:#feded8';


                this.selectedDriverLicense = event.target.dataset.id;
                // this.booleanVar.editDriverBtn = true;
            } else {
                driver.showDeleteButton = true;
                driver.selectedStyle = '';
            }
        })
        this.booleanVar.editDriverBtn = true;
        console.log('this.newDriver');
        console.log(this.newDriver);
    }
    handleDeleteDriver = (event) => {
        console.log(event.target.dataset.id);
        this.addedDriver = this.addedDriver.filter(driver => {
            if (driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == true || driver.Driver_Type__c == 'true') {
                this.booleanVar.registeredOwner = false; // 
                this.booleanVar.companyRegisteredOption = false;
            }
            return driver.license_number__c != event.target.dataset.id
        })

        this.template.querySelectorAll('.cDriver').forEach(inputField => {
            if (inputField.type === 'checkbox' || inputField.type === 'checkbox-button') {
                inputField.checked = false;
            } else {
                inputField.value = null;
            }
        });

        if (this.addedDriver) {
            this.booleanVar.registeredOwner = false;
            this.booleanVar.companyRegisteredOption = false;
        }

    }

    handleDriverFieldsChange = (event) => {

        console.log('inside driver change');
        console.log(event.target.name);
        console.log(event.detail.name);
        if (event.target.name == 'Driver_Type__c') {
            if (event.target.checked == true) {
                this.booleanVar.isOwner = true;
                this.newDriver = { ...this.newDriver, ['owner']: true };
            } else {
                this.booleanVar.isOwner = false;
                this.newDriver = { ...this.newDriver, ['Driver_Type__c']: "Driver", ['owner']: false };
            }
        }
        else {
            this.newDriver[event.target?.name] = event.target?.value;
        }

        if (event.target.name == 'Phone__c') {
            this.formatNumber(event.target.value, 'Phone__c');
        }

        if (event.target.name == 'License_Country__cmbx') {

            if (event.target.value == 'Other') {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: true };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: false };
                if (event.target.value == 'Mexico') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                }
                else if (event.target.value == 'United States') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                }
                else if (event.target.value == 'Canada') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }
            }
        }

        if (event.target.name == 'Country__cmbx') {

            if (event.target.value == 'Other') {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: true };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: false };
                if (event.target.value == 'Mexico') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                }
                else if (event.target.value == 'United States') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                }
                else if (event.target.value == 'Canada') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }
            }
        }

    }
    handleAddNewDriver = () => {

        let status = this.isInputValidbyClass('.driverValidation');
        console.log('Validation status in the add driver: ', status)
        console.log('Added drivers: ', this.addedDriver);
        if (!status) {
            return true;
        }

        if (!this.addedDriver.find(({ license_number__c }) => license_number__c == this.newDriver.license_number__c)) {

            if (this.newDriver.License_Country__cmbx == 'United States' || this.newDriver.License_Country__cmbx == 'Canada' || this.newDriver.License_Country__cmbx == 'Mexico' || this.newDriver.License_Country__cmbx == 'Other') {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: false };
                this.newDriver = { ...this.newDriver, ['License_Country__c']: this.newDriver.License_Country__cmbx };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryVehicle']: true };
            }

            if (this.newDriver.Country__cmbx == 'United States' || this.newDriver.Country__cmbx == 'Canada' || this.newDriver.Country__cmbx == 'Mexico' || this.newDriver.Country__cmbx == 'Other') {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: false };
                this.newDriver = { ...this.newDriver, ['Country__c']: this.newDriver.Country__cmbx };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: true };
            }
            console.log('OUTPUT : this.newDriver.owner', this.newDriver.owner);
            if (this.newDriver.owner == true) {
                this.newDriver = { ...this.newDriver, ['Driver_Type__c']: 'Owner & Driver' };
                this.booleanVar.isOwner = false; // Hide Owner fields
                // this.booleanVar.registeredOwner = true; // 
                this.booleanVar.companyRegisteredOption = true; // Disable company address option                
            } else {
                this.newDriver = { ...this.newDriver, ['Driver_Type__c']: 'Driver' };
                this.newDriver.owner = false;
            }
            this.newDriver = { ...this.newDriver, ['showDeleteButton']: true };
            this.addedDriver = [...this.addedDriver, this.newDriver];

            this.template.querySelectorAll('.cDriver').forEach(inputField => {
                if (inputField.type === 'checkbox' || inputField.type === 'checkbox-button') {
                    inputField.checked = false;
                } else {
                    inputField.value = null;
                }
            });
            this.newDriver = {};
        } else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'The licence is already there; please add another licence.', 'License already exist!');

            } else {

                this.showToastEvent('License already exist!', 'The licence is already there; please add another licence.', 'error');
            }
            console.log('License is already there', this.newDriver)
        }
    }

    handleCompanyAddress(event) {
        let fetchaddress = JSON.parse(event.detail);
        this.searchandUpdateStateOptions(fetchaddress.State, fetchaddress.Country);
        console.log('fetchaddress-->', fetchaddress);

        if ((this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound') && (fetchaddress.Country == 'United States' || fetchaddress.Country == 'Canada')) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'This country cannot be added to Mexican vehicles.', 'Country error');

            } else {

                this.showToastEvent('Country error', 'This country cannot be added to Mexican vehicles.', 'error');
            }
            return true;
        } else if ((this.policyData && this.policyData.Policy_Type_picklist__c != 'Northbound') && fetchaddress.Country == 'Mexico') {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'This country cannot be added in Automobile, RV and motorcycle/ATV.', 'Country error');

            } else {

                this.showToastEvent('Country error', 'This country cannot be added in Automobile, RV and motorcycle/ATV.', 'error');
            }
            return true;
        } else {
            if (fetchaddress.Country == 'United States' || fetchaddress.Country == 'Canada' || fetchaddress.Country == 'Mexico') {
                this.otherCountryCompany = false;
                this.vehicleData.companyCountrycmbx = fetchaddress.Country;
                this.vehicleData = { ...this.vehicleData, ['Company_Country__c']: fetchaddress.Country };
                this.quoteData.companyCountrycmbx = fetchaddress.Country;
                this.quoteData = { ...this.quoteData, ['Company_Country__c']: fetchaddress.Country };
            } else {
                this.otherCountryCompany = true;
                this.vehicleData.companyCountrycmbx = 'Other';
                this.vehicleData = { ...this.vehicleData, ['Company_Country__c']: fetchaddress.Country };
                this.quoteData.companyCountrycmbx = 'Other';
                this.quoteData = { ...this.quoteData, ['Company_Country__c']: fetchaddress.Country };
            }
        }

        this.vehicleData.Company_State__c = fetchaddress.State;
        this.vehicleData.Company_City__c = fetchaddress.City;
        this.vehicleData.Company_Zip__c = fetchaddress.PostalCode;
        this.vehicleData.Company_Address__c = fetchaddress.Address;

        this.quoteData = { ...this.quoteData, ['Company_State__c']: this.vehicleData.Company_State__c };
        this.quoteData = { ...this.quoteData, ['Company_City__c']: this.vehicleData.Company_City__c };
        this.quoteData = { ...this.quoteData, ['Company_Zip__c']: this.vehicleData.Company_Zip__c };
        this.quoteData = { ...this.quoteData, ['Company_Address__c']: this.vehicleData.Company_Address__c };
    }

    handleDriverAddress(event) {
        let fetchaddress = JSON.parse(event.detail);
        this.searchandUpdateStateOptions(fetchaddress.State, fetchaddress.Country);
        console.log('fetchaddress-->', fetchaddress);

        if ((this.policyData && this.policyData.Policy_Type_picklist__c == 'Northbound') && (fetchaddress.Country == 'United States' || fetchaddress.Country == 'Canada')) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'This country cannot be added to Mexican vehicles.', 'Country error');

            } else {

                this.showToastEvent('Country error', 'This country cannot be added to Mexican vehicles.', 'error');
            }
            return true;
        } else if ((this.policyData && this.policyData.Policy_Type_picklist__c != 'Northbound') && fetchaddress.Country == 'Mexico') {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'This country cannot be added in Automobile, RV and motorcycle/ATV.', 'Country error');

            } else {

                this.showToastEvent('Country error', 'This country cannot be added in Automobile, RV and motorcycle/ATV.', 'error');
            }
            return true;
        } else {
            if (fetchaddress.Country == 'United States' || fetchaddress.Country == 'Canada' || fetchaddress.Country == 'Mexico') {
                if (fetchaddress.Country == 'Mexico') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                }
                else if (fetchaddress.Country == 'United States') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                }
                else if (fetchaddress.Country == 'Canada') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: false };
                this.newDriver = { ...this.newDriver, ['Country__cmbx']: fetchaddress.Country };
            } else {
                this.newDriver = { ...this.newDriver, ['otherCountryDriver']: true };
                this.newDriver = { ...this.newDriver, ['Country__cmbx']: 'Other' };
                this.newDriver = { ...this.newDriver, ['Country__c']: fetchaddress.Country };
            }
        }

        //this.newDriver = { ...this.newDriver, ['Country__c']: fetchaddress.Country };
        this.newDriver = { ...this.newDriver, ['Postal_Code__c']: fetchaddress.PostalCode };
        this.newDriver = { ...this.newDriver, ['State_Province__c']: fetchaddress.State };
        this.newDriver = { ...this.newDriver, ['City__c']: fetchaddress.City };
        this.newDriver = { ...this.newDriver, ['Address__c']: fetchaddress.Address };

    }

    searchandUpdateStateOptions(stateValue, countryValue) {
        let isOptionFound = false;
        if (countryValue.toLowerCase() == 'mexico') {
            for (let each of this.mexicoStateList) {
                if (each.value.toLowerCase() == stateValue.toLowerCase()) {
                    isOptionFound = true;
                    break;
                }
            }
            if (isOptionFound == false) {
                this.mexicoStateList.push({
                    'value': stateValue,
                    'label': stateValue
                });
            }
        }
        else if (countryValue.toLowerCase() == 'united states') {
            for (let each of this.unitedStatesList) {
                if (each.value.toLowerCase() == stateValue.toLowerCase()) {
                    isOptionFound = true;
                    break;
                }
            }
            if (isOptionFound == false) {
                this.unitedStatesList.push({
                    'value': stateValue,
                    'label': stateValue
                });
            }
        }
        else if (countryValue.toLowerCase() == 'canada') {
            for (let each of this.canadaStateList) {
                if (each.value.toLowerCase() == stateValue.toLowerCase()) {
                    isOptionFound = true;
                    break;
                }
            }
            if (isOptionFound == false) {
                this.canadaStateList.push({
                    'value': stateValue,
                    'label': stateValue
                });
            }
        }
    }

    onGroup(event) {
        console.log(event.target.name);
        console.log(event.target.value);
        this.quoteData = { ...this.quoteData, [event.target.name]: event.target.value };
        this.booleanVar.isLoading = true;
        fetchUpdatedDate({ 'dateValue': this.quoteData.Start_Date_for_Coverage__c, 'term': this.quoteData.Term__c })
            .then((result) => {
                console.log(result);
                this.booleanVar.isLoading = false;
                if (result) {
                    this.quoteData = { ...this.quoteData, ['End_Date_for_Coverage__c']: result };
                    this.fillValueByClass('.End_Date_for_Coverage__c', 'value', result);
                }
            })
            .catch((error) => {
                this.booleanVar.isLoading = false;
                console.log(error);
            })

    }

    fillValueByClass(classname, propertyname, value) {
        try {
            console.log('classname', classname);
            console.log('value', value);
            const temTemp = this.template.querySelector(classname);
            if (temTemp) {
                temTemp.value = value;
            }
        } catch (err) {
            console.log(err);
        }

    }

    handleInputChange = (event) => {
        try {
            if (event.target?.name == 'lienholder') {
                this.vehicleData = {
                    ...this.vehicleData,
                    ['Is_Lienholder__c']: event.target.checked,
                };
                if (event.target.checked) {
                    this.booleanVar.lienholderOption = true;
                    this.booleanVar.isLienholderChecked = true;
                } else {
                    this.booleanVar.lienholderOption = false;
                    this.booleanVar.isLienholderChecked = false;
                }
            } else if (event.target?.name == 'companyAddress') {
                this.vehicleData = {
                    ...this.vehicleData,
                    ['Is_vehicle_owned_by_a_company_or_rented__c']: event.target.checked,
                };
                if (event.target.checked) {
                    this.booleanVar.companyAddressOption = true;
                    this.booleanVar.isVehicleRentedChecked = true;
                    // Disable Driver & Owner option
                    this.booleanVar.registeredOwner = true;
                } else {
                    this.booleanVar.companyAddressOption = false;
                    // Enable Driver & Owner option
                    this.booleanVar.registeredOwner = false;
                    this.booleanVar.isVehicleRentedChecked = false;
                }
            } else if (event.target.name == 'paymentGroup') {
                if (event.target.value == 'cashPayment') {
                    this.booleanVar.showCardPayment = false;
                    this.booleanVar.showCashPayment = true;
                } else if (event.target.value == 'cardPayment') {
                    this.booleanVar.showCardPayment = true;
                    this.booleanVar.showCashPayment = false;
                }
            } else if (event.target.name == 'Value__c') {
                this.vehicleData = {
                    ...this.vehicleData,
                    [event.target?.name]: event.target.value,
                };
                this.quoteData = {
                    ...this.quoteData,
                    ['Vehicle_Value__c']: event.target.value,
                };
            } else if (event.target.name == 'Start_Date_for_Coverage__c') {
                this.quoteData = { ...this.quoteData, ['Start_Date_for_Coverage__c']: event.target.value };
                this.booleanVar.isLoading = true;
                console.log('this.quoteData.Term__c', this.quoteData.Term__c);
                fetchUpdatedDate({ 'dateValue': event.target.value, 'term': this.quoteData.Term__c })
                    .then((result) => {
                        console.log('result-->', result);
                        this.booleanVar.isLoading = false;
                        if (result) {
                            this.quoteData = { ...this.quoteData, ['End_Date_for_Coverage__c']: result };
                            this.fillValueByClass('.End_Date_for_Coverage__c', 'value', result);
                            console.log('this.quoteData---->', this.quoteData);
                        }
                    })
                    .catch((error) => {
                        this.booleanVar.isLoading = false;
                        console.log(error);
                    })
            }
            else if (event.target.name == 'End_Date_for_Coverage__c') {
                //Added this on 6 Aug  & 13 sep else if
                const sdate = new Date(this.quoteData?.Start_Date_for_Coverage__c);
                const edate = new Date(event.target.value);
                if (sdate >= edate) {
                    if (this.cmpSource == 'comm') {
                        this.showToastmethod('error', 'The selected date is earlier than the Start Date for Coverage.', 'Wrong date selected');

                    } else {
                        let errEvt = new ShowToastEvent({
                            message: 'The selected date is earlier than the Start Date for Coverage.',
                            variant: 'error',
                        });
                        this.dispatchEvent(errEvt);
                    }
                    return;
                }
                this.quoteData = { ...this.quoteData, ['End_Date_for_Coverage__c']: event.target.value };
                this.booleanVar.isLoading = false;
                this.fillValueByClass('.End_Date_for_Coverage__c', 'value', event.target.value);

            }
            else if (event.target.name == 'Start_Time__c') {
                this.quoteData = { ...this.quoteData, ['Start_Time__c']: event.target.value };
                this.quoteData = { ...this.quoteData, ['End_Time__c']: event.target.value };
                this.fillValueByClass('.End_Time__c', 'value', event.target.value);
            }
            else if (event.target.name == 'Territory__c') {
                this.quoteData = { ...this.quoteData, ['Territory__c']: event.target.value };
            } else if (event.target.name == 'Company_Phone__c') {
                this.formatNumber(event.target.value, 'Company_Phone__c');
            } else if (event.target.name == 'Lienholder_Phone__c') {
                this.formatNumber(event.target.value, 'Lienholder_Phone__c');
            }
            else {
                this.vehicleData = {
                    ...this.vehicleData,
                    [event.target?.name]: event.target.value,
                };
            }

            if (event.target?.name == 'Lienholder_Country__cmbx') {
                this.quoteData = { ...this.quoteData, ['Lienholder_Country__c']: event.target.value };
            }

            if (event.target?.name == 'Company_Country__cmbx') {
                this.quoteData = { ...this.quoteData, ['Company_Country__c']: event.target.value };
                if (event.target.value == 'Other') {
                    this.otherCountryCompany = true;
                } else {
                    this.otherCountryCompany = false;
                }
            }

            if (event.target?.name == 'Registered_Country__cmbx') {
                this.quoteData = { ...this.quoteData, ['Registered_Country__c']: event.target.value };
                if (event.target.value == 'Other') {
                    this.otherCountryRegister = true;
                } else {
                    this.otherCountryRegister = false;
                }
            }






        } catch (err) {
            console.log(err.message);
        }
    }

    handleChange(event) {
        try {
            console.log(event.detail.name);
            console.log(event.target.name);
            let val = event.target.value;
            if (event.target.name === 'Medical__c' && this.actionmode == 'edit') {
                //checking values not shorter
                let oldIndex, newIndex = 0;
                let indexCounter = 0;
                for (let mdval of this.medicalOption) {
                    if (mdval.value == this.editOldProcessData.quoteData.Medical__c) {
                        oldIndex = indexCounter;
                    }
                    if (mdval.value == val) {
                        newIndex = indexCounter;
                    }
                    indexCounter++;
                }
                if ((parseInt(newIndex) - parseInt(oldIndex)) < 0) {
                    if (this.cmpSource == 'comm') {
                        this.showToastmethod('error', 'You cannot select Medical lower than $' + this.editOldProcessData.quoteData.Medical__c + '.', 'Medical amount error');

                    } else {
                        let errEvt = new ShowToastEvent({
                            message: 'You cannot select Medical lower than $' + this.editOldProcessData.quoteData.Medical__c,
                            variant: 'error',
                        });
                        this.dispatchEvent(errEvt);
                    }

                    let combobox = this.template.querySelector('.Medicalpicklist');
                    combobox.value = this.editOldProcessData.quoteData.Medical__c;
                    return;
                } else {
                    this.quoteData = { ...this.quoteData, [event.target.name]: event.target.value };
                }
            } else
                if (event.target.name === 'Liability__c' && this.actionmode == 'edit') {
                    //checking values not shorter
                    let oldIndex, newIndex = 0;
                    let indexCounter = 0;
                    for (let mdval of this.liabilityOption) {
                        if (mdval.value == this.editOldProcessData.quoteData.Liability__c) {
                            oldIndex = indexCounter;
                        }
                        if (mdval.value == val) {
                            newIndex = indexCounter;
                        }
                        indexCounter++;
                    }
                    if ((parseInt(newIndex) - parseInt(oldIndex)) < 0) {
                        if (this.cmpSource == 'comm') {
                            this.showToastmethod('error', 'You cannot select Liability lower than $' + this.editOldProcessData.quoteData.Liability__c + '.', 'Liability amount error');

                        } else {
                            let errEvt = new ShowToastEvent({
                                message: 'You cannot select Liability lower than $' + this.editOldProcessData.quoteData.Liability__c,
                                variant: 'error',
                            });
                            this.dispatchEvent(errEvt);
                        }

                        let combobox = this.template.querySelector('.LiabilityPicklist');
                        combobox.value = this.editOldProcessData.quoteData.Liability__c;
                        return;
                    } else {
                        this.quoteData = { ...this.quoteData, [event.target.name]: event.target.value };
                    }
                } else {
                    this.quoteData = { ...this.quoteData, [event.target.name]: event.target.value };
                }


        } catch (err) {
            console.log(err.message);
        }


    }

    // Get input values from towed inputs
    handleTowedInputChange = (event) => {
        this.newTowed[event.target?.name] = event.target.value;
    }

    // Add a new towed unit
    handleAddNewTowed = (event) => {
        if (this.isInputValidbyClass('.cTowed')) {
            this.addedTowed = [...this.addedTowed, this.newTowed];
            //this.towedCount++;
            for (let i = 0; i < this.addedTowed.length; i++) {
                this.addedTowed[i].towedCount = i;
            }
            this.newTowed = {};
            console.log(this.addedTowed);

            // Create a seprate method and pass the class to reset
            this.template.querySelectorAll('.cTowed').forEach(inputField => {
                inputField.value = null;
            });
        } else {
            console.log(this.addedTowed);
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Please make sure you filled in all the towed details.', 'Cannot add towed units!');

            } else {
                this.showToastEvent('Cannot add towed units!', 'Please make sure you filled in all the towed details.', 'error');
            }
        }

    }

    // Edit towed unit
    handleEditTowed = (event) => {
        console.log('Action: Edit');
        this.newTowed = {};
        this.addedTowed.map(towedUnit => {
            if (event.target.dataset?.id == towedUnit?.towedCount) {
                this.newTowed = { ...towedUnit };
                this.booleanVar.editTowedBtn = true;
            }
        })

        console.log(this.newTowed)

    }

    // Delete towed unit
    handleDeleteTowned = (event) => {
        this.addedTowed = this.addedTowed.filter(towedUnit => {
            return towedUnit.towedCount != event.target.dataset.id
        })
    }

    // Update the selected towed unit
    handleUpdateTowed = () => {
        try {
            this.booleanVar.editTowedBtn = false;
            if (this.isInputValidbyClass('.cTowed')) {

                this.addedTowed.map(towedUnit => {
                    if (this.newTowed.towedCount == towedUnit?.towedCount) {
                        console.log('mapped');
                        console.log(this.newTowed.towedCount);
                        console.log(towedUnit.towedCount);
                        towedUnit.Towed_Unit_Type__c = this.newTowed.Towed_Unit_Type__c;
                        towedUnit.Towed_Unit_Value__c = this.newTowed.Towed_Unit_Value__c;
                        towedUnit.Days_in_Tow__c = this.newTowed.Days_in_Tow__c;
                    }
                });
            }
            // Create a seprate method and pass the class to reset
            this.template.querySelectorAll('.cTowed').forEach(inputField => {
                inputField.value = null;
            });
            this.newTowed = {};
        } catch (err) {
            console.log(err);
        }

    }

    async handlMakePayment() {
        let transactionDetails = {};

        console.log('Make Payment');
        console.log('Make Payment ' + this.booleanVar.showCardPayment);

        if (this.booleanVar.showCardPayment == false && this.booleanVar.showCashPayment == false) {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Please choose either cash or card as payment option!', 'Unable to proceed next');

            } else {
                this.showToastEvent('Unable to proceed next', 'Please choose either cash or card as payment option!', 'error');
            }
            this.booleanVar.isLoading = false;
        } else {

            for (let each of this.addedDriver) {
                if (each.owner || each.Driver_Type__c && (each.Driver_Type__c == 'Owner' || each.Driver_Type__c == 'Owner & Driver' || each.Driver_Type__c == true || each.Driver_Type__c == 'true')) {
                    each.Driver_Type__c = 'Owner & Driver';
                } else {
                    each.Driver_Type__c = 'Driver';
                }
                delete each.owner;
            }
            if (this.actionmode == 'renew') {
                if (this.booleanVar.showCardPayment == true) {

                    if (!this.isInputValidbyClass('.paymentValidation')) {
                        this.booleanVar.isLoading = false;
                        this.showToastEvent('Cannot proceed to purchase!', 'Make sure you filled in all the required details.', 'error');
                        return;
                    }

                    this.booleanVar.isLoading = true;
                    console.log('Make Payment ' + this.quoteData.Id);

                    transactionDetails = { ...transactionDetails, ['ip']: '101.188.67.134', ['quoteIds']: [this.quoteData.Id] };


                    paymentThroughCard({ 'transactionDetails': JSON.stringify(transactionDetails), 'paymentDetails': JSON.stringify(this.paymentDetails), 'email': '' })
                        .then((result) => {
                            console.log('result', result);
                            if (result) {
                                this.showToastEvent('Transaction Successful', 'Congratulations! Your transaction has been completed successfully', 'success');
                                //once payment is successfull

                                createNewEditPolicy({
                                    'vehicleData': JSON.stringify(this.vehicleData),
                                    'DriverData': JSON.stringify(this.addedDriver),
                                    'towedUnitData': JSON.stringify(this.addedTowed),
                                    'quoteId': this.quoteData.Id,
                                    'oldPolicyId': this.policyId,
                                    'isRenewal': this.actionmode == 'renew' ? true : false
                                })
                                    .then(async (result) => {
                                        console.log(result);
                                        if (this.cmpSource == 'comm') {
                                            this.showToastmethod('success', 'Congratulations! Your policy has been renewed', 'Policy Created');

                                        } else {
                                            this.showToastEvent('Policy Created', 'Congratulations! Your policy has been renewed', 'success');
                                        }
                                        let email = await getContactEmail({ 'policyID': result.data });

                                        if (email === false) {
                                            getPolicyData({ 'policyId': result.data })
                                                .then((res) => {
                                                    if (res === 'Success') {
                                                        console.log('Pdf gen')
                                                    }
                                                    else {
                                                        console.log('Pdf gen', res);
                                                    }
                                                });
                                        }
                                        this.booleanVar.isLoading = false;
                                        this.proceedTofinalStep(result.data);
                                    })
                                    .then(async (result) => {
                                        console.log(result);
                                        this.showToastEvent('Policy Created', 'Congratulations! Your policy has been renewed', 'success');
                                        let email = await getContactEmail({ 'policyID': result.data });

                                        if (email === false) {
                                            getPolicyData({ 'policyId': result.data })
                                                .then((res) => {
                                                    if (res === 'Success') {
                                                        console.log('Pdf gen')
                                                    }
                                                    else {
                                                        console.log('Pdf gen', res);
                                                    }
                                                });
                                        }
                                        this.booleanVar.isLoading = false;
                                        this.proceedTofinalStep(result.data);
                                    })
                                    .catch((error) => {
                                        this.showToastEvent('Policy creation Failed', 'We regret to inform you that your policy renewal has been failed.', 'error');
                                        this.booleanVar.isLoading = false;
                                    });

                            } else {
                                this.booleanVar.isLoading = false;
                                this.showToastEvent('Transaction Failed', 'We regret to inform you that your transaction has been failed.', 'error');
                            }
                        })
                        .catch((error) => {
                            console.log('error in handleMakePayment', error);
                            console.log(error);
                            this.showToastEvent('Policy creation Failed', error.body.message, 'error');
                            this.booleanVar.isLoading = false;
                        })

                } else {
                    this.showToastEvent('Policy creation Failed', error.body.message, 'error');
                }
                this.booleanVar.isLoading = false;
            })

        } else {
            this.booleanVar.isLoading = true;
            createNewEditPolicyFromCash({
                'vehicleData': JSON.stringify(this.vehicleData),
                'DriverData': JSON.stringify(this.addedDriver),
                'towedUnitData': JSON.stringify(this.addedTowed),
                'quoteId': this.quoteData.Id,
                'oldPolicyId': this.policyId,
                'isRenewal': this.actionmode == 'renew' ? true : false
            })
                .then(async (result) => {
                    console.log(result);
                    this.showToastEvent('Policy Created', 'Congratulations! Your policy has been renewed', 'success');
                    let email = await getContactEmail({ 'policyID': result.data });

                    if (email === false) {
                        getPolicyData({ 'policyId': result.data })
                            .then((res) => {
                                if (res === 'Success') {
                                    console.log('Pdf gen')
                                }
                                else {
                                    console.log('Pdf gen', res);
                                }
                            });
                    }
                    this.booleanVar.isLoading = false;
                    this.proceedTofinalStep(result.data);
                })
                .catch((error) => {
                    this.showToastEvent('Policy creation Failed', 'We regret to inform you that your policy renewal has been failed.', 'error');
                    this.booleanVar.isLoading = false;
                });
        }
    }else{
    this.booleanVar.isLoading = true;
    let quoteIdd = await this.createCloneQuotes();
    if (quoteIdd) {
        this.handleEditPolicyPayments(quoteIdd);
    }
}
        }
        

        

    }
generatePolicyPDF(event){
    this.booleanVar.isLoading = true;
    validateandGenerateQuotePDF({ 'policyId': this.renewdPolicyId })
        .then((result) => {
            this.booleanVar.isLoading = false;
            console.log(result);
            if (result) {
                window.open(((this.isAgentPortal ? '/agencyvforcesite/' : '/') + 'apex/' + result + '?id=' + this.renewdPolicyId), '_system');
            } else {
                this.showToastEvent('Something wrong happened while generating PDF!', 'Cannot generate PDF for the current policy.', 'error');

            }
        })
        .catch((error) => {
            this.booleanVar.isLoading = false;
            console.log('Some error occured');
            console.log(error);
        });
}
navigateToPolicy(event) {
    console.log('this.cmpSource');
    console.log(this.cmpSource);
    if (this.cmpSource == 'comm') {
        console.log('INSIDE community');
        let url = `policy/${this.renewdPolicyId}`;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/agency/${url}`
            },
            state: {
                recordId: this.renewdPolicyId
            }
        });
    } else {
        console.log('OUTSIDE community');
        window.open(('/' + this.renewdPolicyId), '_system');
    }

}

showToastEvent(label, message, variant) {
    const errMsg = new ShowToastEvent({
        title: label,
        message: message,
        variant: variant,
    });
    this.dispatchEvent(errMsg);
}

proceedTofinalStep(newPolicyId){
    this.isPolicyTransactionCompleted = true;
    this.activeSectionName = 'D';
    const accordion = this.template.querySelector('.example-accordion');
    accordion.activeSectionName = this.activeSectionName;
    this.renewdPolicyId = newPolicyId;
}

    async updatePolicy(event){
    this.booleanVar.isLoading = true;
    console.log('undating drivers ' + this.editOldProcessData.DriverData.length);
    for (let each of this.editNewProcessData.DriverData) {
        if (each.owner || each.Driver_Type__c && (each.Driver_Type__c == 'Owner' || each.Driver_Type__c == 'Owner & Driver' || each.Driver_Type__c == true || each.Driver_Type__c == 'true')) {
            each.Driver_Type__c = 'Owner & Driver';
        } else {
            each.Driver_Type__c = 'Driver';
        }
        delete each.owner;
    }
    const data = await updatePolicyDetails({ 'quoteData': JSON.stringify(this.editNewProcessData.quoteData), 'DriverData': JSON.stringify(this.editNewProcessData.DriverData), 'vehicleData': JSON.stringify(this.editNewProcessData.vehicleData), 'towedUnitData': this.editNewProcessData.towedUnitData.length > 0 ? JSON.stringify(this.editNewProcessData.towedUnitData) : '' });
    if (data.status == 'success') {
        this.showToastEvent('Policy Created', 'Congratulations! Your policy has been updated', 'success');

        getUpdatedPolicyData({ 'quoteData': JSON.stringify(this.editNewProcessData.quoteData) })
            .then((res) => {
                if (res === 'Success') {
                    console.log('Pdf generated');
                }
                else {
                    console.log('Pdf response', res);
                }
            })
        this.booleanVar.isLoading = false;
        this.proceedTofinalStep(this.policyId);
    } else {
        this.showToastEvent('Policy update Failed', 'We regret to inform you that your policy update has been failed.', 'error');
        this.booleanVar.isLoading = false;
        console.log('occur error', JSON.stringify(data, null, 4));
    }
}

    async createCloneQuotes() {
    try {
        let { Id, ...rest } = this.editpolicydata.quoteData;

        console.log('--newquote--', rest);
        this.invalidCheck = true;
        let data = await createCloneQuote({ 'quote': JSON.stringify(rest), 'oldQuoteId': '' });

        console.log('--data--', data);
        if (data.status == 'success') {
            return data.data;
        } else {
            console.log('--else part--', data);
            return null;
        }

    } catch (error) {
        console.log(error);
    }
}
    async handleEditPolicyPayments(newlatestQuoteId){
    console.log('handling Edit policy Payments');
    if (this.booleanVar.showCardPayment == true) {
        if (!this.isInputValidbyClass('.paymentValidation')) {
            this.booleanVar.isLoading = false;
            this.showToastEvent('Cannot proceed to purchase!', 'Make sure you filled in all the required details.', 'error');
            return;
        }
        if (this.paymentPrice > 0) {
            await this.createAdditionalTransaction(newlatestQuoteId);
            return;
        } else if (this.paymentPrice < 0) {
            await this.refundTransactions(newlatestQuoteId);
            return;
        }
    } else {
        console.log('handle edit policy in else section.....', this.booleanVar.isTowing);
        this.booleanVar.isLoading = true;
        createNewEditPolicyFromCashWithAmount({
            'vehicleData': JSON.stringify(this.vehicleData),
            'DriverData': JSON.stringify(this.addedDriver),
            'towedUnitData': JSON.stringify(this.addedTowed),
            'quoteId': newlatestQuoteId,
            'oldPolicyId': this.policyId,
            'isRenewal': this.actionmode == 'renew' ? true : false,
            'amountForTransaction': this.paymentPrice
        })
            .then(async (result) => {
                console.log(result);
                if (this.cmpSource == 'comm') {
                    this.showToastmethod('success', 'Congratulations! Your policy has been updated', 'Policy Created');

                } else {
                    this.showToastEvent('Policy Created', 'Congratulations! Your policy has been updated', 'success');
                }

                let email = await getContactEmail({ 'policyID': result.data });

                if (email === false) {
                    getPolicyData({ 'policyId': result.data })
                        .then((res) => {
                            if (res === 'Success') {
                                console.log('Pdf gen')
                            }
                            else {
                                console.log('Pdf gen', res);
                            }
                        });
                }
                this.booleanVar.isLoading = false;
                this.proceedTofinalStep(result.data);
            })
            .catch((error) => {
                if (this.cmpSource == 'comm') {
                    this.showToastmethod('error', 'We regret to inform you that your policy update has been failed.', 'Policy creation Failed');

                } else {
                    this.showToastEvent('Policy creation Failed', 'We regret to inform you that your policy update has been failed.', 'error');
                }
                this.booleanVar.isLoading = false;
            });
    }
    this.booleanVar.isLoading = false;
    this.proceedTofinalStep(result.data);
})
                .catch ((error) => {
    this.showToastEvent('Policy creation Failed', 'We regret to inform you that your policy update has been failed.', 'error');
    this.booleanVar.isLoading = false;
});
        }
    }

    async createAdditionalTransaction(newQuoteId) {

    this.booleanVar.isLoading = true;
    this.paymentPrice = parseFloat(this.paymentPrice);
    let transactionDetails = { ['ip']: '192.168.33.43', ['quoteIds']: [newQuoteId] }
    console.log("CA log transactionDetail : " + JSON.stringify(transactionDetails, null, 4));
    console.log("CA log refundamount : " + this.paymentPrice.toFixed(2));
    try {
        const data = await createTransactionWithPredefinedAmount({ 'newCreditCard': JSON.stringify(this.paymentDetails), 'transactionDetails': JSON.stringify(transactionDetails), 'amount': this.paymentPrice.toFixed(2), 'policyId': this.policyId, "email": '' });

        console.log('--data--', data);
        if (data.status == 'success') {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('success', 'Congratulations! Your transaction has been completed successfully', 'Transaction Successful');

            } else {
                this.showToastEvent('Transaction Successful', 'Congratulations! Your transaction has been completed successfully', 'success');
            }
            let createCloneNewPolicy;
            console.log('creating a new watercraft policy');
            if (this.policyData.Policy_Type_picklist__c == 'Watercraft') {
                createCloneNewPolicy = await createNewWatercraftEditPolicy({ 'watercraftData': JSON.stringify(this.editpolicydata.watercraftData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'quoteId': newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
            } else {
                console.log('Data---->vehicleData', this.vehicleData);
                console.log('Data---->this.addedDriver', this.addedDriver);
                console.log('Data---->this.policyId', this.policyId);
                console.log('Data---->newQuoteId', newQuoteId);
                createCloneNewPolicy = await createNewEditPolicy({ 'vehicleData': JSON.stringify(this.vehicleData), 'DriverData': JSON.stringify(this.addedDriver), 'towedUnitData': JSON.stringify(this.addedTowed), 'quoteId': newQuoteId, 'oldPolicyId': this.policyId, 'isRenewal': false });
            }

            console.log('--createCloneNewPolicy-', createCloneNewPolicy);
            let cloneNewPlocy = createCloneNewPolicy;
            console.log('--cloneNewPlocy--', cloneNewPlocy);

            if (cloneNewPlocy.status == 'success') {
                if (this.cmpSource == 'comm') {
                    this.showToastmethod('success', 'Congratulations! Your policy has been updated', 'Policy Created');

                } else {
                    this.showToastEvent('Policy Created', 'Congratulations! Your policy has been updated', 'success');
                }
                let email = await getContactEmail({ 'policyID': cloneNewPlocy.data });

                if (email === false) {
                    getPolicyData({ 'policyId': cloneNewPlocy.data })
                        .then((res) => {
                            if (res === 'Success') {
                                console.log('Pdf gen')
                            }
                            else {
                                console.log('Pdf gen', res);
                            }
                        });
                }
                this.booleanVar.isLoading = false;
                this.proceedTofinalStep(cloneNewPlocy.data);
            } else {
                this.showToastEvent('Policy update Failed', 'We regret to inform you that your policy update has been failed.', 'error');
                this.booleanVar.isLoading = false;
            }
        } else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'We regret to inform you that your policy update has been failed.', 'Policy update Failed');

            } else {
                this.showToastEvent('Policy update Failed', 'We regret to inform you that your policy update has been failed.', 'error');
            }

            this.booleanVar.isLoading = false;
        }
    } catch (error) {
        console.log('outer error');
        console.log(error);
        this.showToastEvent('Policy update Failed', error.body.message, 'error');

        this.booleanVar.isLoading = false;
    }

}

refundTransactions = async (newQuoteId) => {
    this.booleanVar.isLoading = true;
    this.paymentPrice = parseFloat(this.paymentPrice);
    let amountToRefund = this.paymentPrice.toFixed(2);
    console.log('--amountToRefund--', amountToRefund);
    let transactionDetails = {}
    transactionDetails = { ...this.editpolicydata.transactionData, ['quoteIds']: [newQuoteId] };
    try {
        const actionData = await refundTransaction({ 'newCreditCard': JSON.stringify(this.paymentDetails), 'transactionDetails': JSON.stringify(transactionDetails), 'refundAmount': amountToRefund, 'policyId': this.policyId });
        if (actionData.status == 'success') {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('success', 'Congratulations! Your transaction has been completed successfully', 'Transaction Successful');

            } else {
                this.showToastEvent('Transaction Successful', 'Congratulations! Your transaction has been completed successfully', 'success');
            }

            let createCloneNewPolicy;
            if (this.policyData.Policy_Type_picklist__c == 'Watercraft') {
                createCloneNewPolicy = await createNewWatercraftEditPolicy({ 'watercraftData': JSON.stringify(this.editpolicydata.watercraftData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'quoteId': this.newQuoteId, 'oldPolicyId': this.editpolicydata.policyData.Id, 'isRenewal': false });
            } else {
                console.log('Data---->vehicleData', this.vehicleData);
                console.log('Data---->this.addedDriver', this.addedDriver);
                console.log('Data---->this.policyId', this.policyId);
                console.log('Data---->newQuoteId', newQuoteId);
                createCloneNewPolicy = await createNewEditPolicy({ 'vehicleData': JSON.stringify(this.vehicleData), 'DriverData': JSON.stringify(this.addedDriver), 'towedUnitData': JSON.stringify(this.addedTowed), 'quoteId': newQuoteId, 'oldPolicyId': this.policyId, 'isRenewal': false });
            }
            this.booleanVar.isLoading = false;
            this.proceedTofinalStep(cloneNewPlocy.data);
        } else {
            this.showToastEvent('Policy update Failed', 'We regret to inform you that your policy update has been failed.', 'error');
            this.booleanVar.isLoading = false;
        }

        let cloneNewPlocy = createCloneNewPolicy;
        console.log('--cloneNewPlocy--', cloneNewPlocy);
        if (cloneNewPlocy.status == 'success') {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('success', 'Congratulations! Your policy has been updated', 'Policy Created');

            } else {
                this.showToastEvent('Policy Created', 'Congratulations! Your policy has been updated', 'success');
            }

            let email = await getContactEmail({ 'policyID': cloneNewPlocy.data });

            if (email === false) {

                getPolicyData({ 'policyId': cloneNewPlocy.data })
                    .then((res) => {
                        if (res === 'Success') {
                            console.log('Pdf gen')
                        }
                        else {
                            console.log('Pdf gen', res);
                        }
                    });
            }
            this.booleanVar.isLoading = false;
            this.proceedTofinalStep(cloneNewPlocy.data);
        } else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'We regret to inform you that your policy update has been failed.', 'Policy update Failed');

            } else {
                this.showToastEvent('Policy update Failed', 'We regret to inform you that your policy update has been failed.', 'error');
            }
            this.booleanVar.isLoading = false;
        }


    } else {
        if (this.cmpSource == 'comm') {
            this.showToastmethod('error', 'We regret to inform you that your policy update has been failed.', 'Policy update Failed');

        } else {
            this.showToastEvent('Policy update Failed', 'We regret to inform you that your policy update has been failed.', 'error');
        }
        this.booleanVar.isLoading = false;
    }
} catch (error) {
    console.log(error);
    this.showToastEvent('Policy update Failed', error.body.message, 'error');

}else {
    this.showToastEvent('Policy update Failed', error.body.message, 'error');
}

this.booleanVar.isLoading = false;
        }


    }

// set payment fields value...
paymentFieldsValue() {

    if (this.vehicleData.Is_vehicle_owned_by_a_company_or_rented__c === true) {
        this.paymentsFields.paymentZip = this.vehicleData.Company_Zip__c;
        this.paymentsFields.paymentCity = this.vehicleData.Company_City__c;
        this.paymentsFields.paymentState = this.vehicleData.Company_State__c;
        if (this.vehicleData.Company_Country__c == 'United States' || this.vehicleData.Company_Country__c == 'Canada' || this.vehicleData.Company_Country__c == 'Mexico') {
            this.otherCountrypayment = false;
            this.paymentsFields.paymentCountry = this.vehicleData.Company_Country__c;
            this.paymentsFields.paymentCountrycmbx = this.vehicleData.Company_Country__c;
        } else {
            this.otherCountrypayment = true;
            this.paymentsFields.paymentCountrycmbx = 'Other';
            this.paymentsFields.paymentCountry = this.vehicleData.Company_Country__c;
        }

        this.paymentsFields.paymentStreet = this.vehicleData.Company_Address__c;

    } else {
        for (let each of this.addedDriver) {
            if (each.Driver_Type__c === 'Owner & Driver' || each.Driver_Type__c === 'Owner' || each.Driver_Type__c == true || each.Driver_Type__c == 'true') {

                this.paymentsFields.paymentZip = each.Postal_Code__c;
                this.paymentsFields.paymentCity = each.City__c;
                this.paymentsFields.paymentState = each.State_Province__c;
                if (each.Country__c == 'United States' || each.Country__c == 'Canada' || each.Country__c == 'Mexico') {
                    this.otherCountrypayment = false;
                    this.paymentsFields.paymentCountrycmbx = each.Country__c;
                    this.paymentsFields.paymentCountry = each.Country__c;
                } else {
                    this.otherCountrypayment = true;
                    this.paymentsFields.paymentCountrycmbx = 'Other';
                    this.paymentsFields.paymentCountry = each.Country__c;
                }
                this.paymentsFields.paymentStreet = each.Address__c;
            }

        }
    }
    console.log(' this.paymentsFields.paymentCountrycmbx = ', this.paymentsFields.paymentCountrycmbx);
}
showToastmethod(variant, title, message) {
    this.template.querySelector('c-custom-toast').showToast(variant, title, message);
}

updateTowedController(event){
    let updatedToweddetail = event.detail;
    this.addedTowed = updatedToweddetail;
    console.log('updateTowedController-->', this.addedTowed);
}

// update Lienholder component details in Customer data...
updateLienHolderDetails(event) {
    let lienholderDetails = event.detail;
    console.log('IN updateLienHolderDetails lienholderDetails::::', lienholderDetails);
    this.vehicleData = {
        ...this.vehicleData,
        ['Is_Lienholder__c']: true,
        ['Lienholder_name__c']: lienholderDetails.Lienholder_name__c,
        ['Lienholder_Street__c']: lienholderDetails.Lienholder_Street__c,
        ['Lienholder_State__c']: lienholderDetails.Lienholder_State__c,
        ['Lienholder_Postal_Code__c']: lienholderDetails.Lienholder_Postal_Code__c,
        ['Lienholder_Phone__c']: lienholderDetails.Lienholder_Phone__c,
        ['Lienholder_Country__c']: lienholderDetails.Lienholder_Country__c,
        ['Lienholder_City__c']: lienholderDetails.Lienholder_City__c
    };

}

}