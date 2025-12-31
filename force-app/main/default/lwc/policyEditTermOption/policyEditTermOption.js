import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import updateQuoteData from '@salesforce/apex/Mex_PolicyEditController.updateQuoteData';
import createNewRenewQuote from '@salesforce/apex/Mex_PolicyEditController.createNewRenewQuote';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import { loadStyle } from 'lightning/platformResourceLoader';
import StyleCSS from '@salesforce/resourceUrl/mexinsurance_assets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DoyouwanttochangetheTermorCoverageLimits from '@salesforce/label/c.TR_Do_you_want_to_change_the_Termor_Coverage_Limits';
import StartDateforCoverage from '@salesforce/label/c.TR_Start_Date_for_Coverage';
import STARTTIME from '@salesforce/label/c.TR_Start_Time';
import Annual from '@salesforce/label/c.TR_Annual';
import SemiAnnual from '@salesforce/label/c.TR_Semi_Annual';
import EndDateforCoverage from '@salesforce/label/c.TR_End_Date_for_Coverage';
import EndTime from '@salesforce/label/c.TR_End_Time';
import TerritoryCoverage from '@salesforce/label/c.TR_Territory_Coverage';
import Medical from '@salesforce/label/c.TR_Medical';
import Liability from '@salesforce/label/c.TR_Liability';
import IstheMaximumSpeedmorethan50mph from '@salesforce/label/c.TR_Is_the_Maximum_Speed_more_than_50_mph';
import Willanyoneoperatetheboatundertheageof22 from '@salesforce/label/c.TR_Will_anyone_operate_the_boat_under_the_age_of_22';
import IstheownerlivinginMexico from '@salesforce/label/c.TR_Is_the_owner_living_in_Mexico';
import Next from '@salesforce/label/c.TR_Next';
import Thetermdayscantbe from '@salesforce/label/c.TR_The_term_days_can_t_be_greater_than_365';


export default class PolicyEditTermOption extends NavigationMixin(LightningElement) {
     label = {
          DoyouwanttochangetheTermorCoverageLimits,StartDateforCoverage,STARTTIME,Thetermdayscantbe,Annual,SemiAnnual,EndDateforCoverage,EndTime,TerritoryCoverage,Medical,
          Liability,IstheMaximumSpeedmorethan50mph,Willanyoneoperatetheboatundertheageof22,IstheownerlivinginMexico,Next,
    };

    @api changeprevscreen;
    @api changesnextscreen;
    @api oldpolicydata;
    @api editpolicydata;
    @api policyType;
    @api disableDate = false;
    @api isRenewalPolicy;
    @api policyExist;
    @api connectedcallback;
    isComponentRendered = false;
    termOptions = {};
    endMinDate;
    mindate;
    annual = false;
    semiAnnual = false;
    systemTime;
    displayPstTime;
    oldMedicalValuesPersist;
    oldLiabilityValuesPersist;
    todayDateValue;

    async connectedCallback() {
        await this.getSystemTime();

        let today = new Date(this.systemTime.dtPST);
        let day = today.getDate();
        let month = today.getMonth();
        let year = today.getFullYear();
        let currentDate = new Date(year, month, day);
        console.log("todaye date : ", currentDate);
        this.todayDateValue = currentDate;
        this.mindate = currentDate.toISOString();
        console.log('connected call back ', JSON.stringify(this.editpolicydata, null, 4));
        console.log('renewwable policy--', this.isRenewalPolicy);
        if(this.editpolicydata?.quoteData?.Medical__c){
            this.oldMedicalValuesPersist = this.editpolicydata?.quoteData?.Medical__c;
            if(this.isRenewalPolicy && this.editpolicydata.policyData.Underwriter_picklist__c && this.editpolicydata.policyData.Underwriter_picklist__c == 'Chubb' &&
                     (this.editpolicydata?.quoteData?.Medical__c != '10,000/50,000' && this.editpolicydata?.quoteData?.Medical__c != '15,000/75,000' && this.editpolicydata?.quoteData?.Medical__c != '20,000/100,000') ){
                        
                        this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Medical__c']: '10,000/50,000' } };
              
                     //   this.editpolicydata.quoteData.Medical__c = '10,000/50,000';
            }
        }
        if(this.editpolicydata?.quoteData?.Liability__c){
            this.oldLiabilityValuesPersist = this.editpolicydata?.quoteData?.Liability__c;
            if(this.isRenewalPolicy && this.editpolicydata.policyData.Underwriter_picklist__c && this.editpolicydata.policyData.Underwriter_picklist__c == 'Chubb' &&
                     (this.editpolicydata?.quoteData?.Liability__c  != '500,000' && this.editpolicydata?.quoteData?.Liability__c  != '1,000,000') ){
                        this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Liability__c']: '500,000' } };
                       // this.editpolicydata.quoteData.Liability__c  = '500,000';
            }
        }

        let currentDatesystem = new Date(this.systemTime.dtPST);
        const startCoverageDate = new Date(this.editpolicydata.quoteData.Start_Date_for_Coverage__c);
        const startTime = this.msToTime(this.editpolicydata?.quoteData?.Start_Time__c.toString());

        if (!this.isRenewalPolicy) {
            if (currentDatesystem >= startCoverageDate && this.editpolicydata?.quoteData?.Term__c != undefined) {
                this.disableDate = true;
            } else {
                this.disableDate = false;
            }
        }
        let dateOfSystem = this.systemTime.dtPST.split(' ');
        if (this.editpolicydata.quoteData.Start_Date_for_Coverage__c != '' && this.editpolicydata.quoteData.Start_Date_for_Coverage__c != undefined) {
            if (dateOfSystem[0] == this.editpolicydata.quoteData.Start_Date_for_Coverage__c) {
                this.displayPstTime = this.systemTime.timePst;
            } else {
                this.displayPstTime = '00:00:000'
            }
        }

        // set the today date for renewal policy ....
        if((this.isRenewalPolicy == 'Yes' || this.isRenewalPolicy == true) && this.connectedcallback == false){
            console.log('---startDayForCoverage--', this.todayDateValue);
            let startDayForCoverage = this.todayDateValue;
            let startdate = startDayForCoverage.getDate();
            let startmonth = startDayForCoverage.getMonth() + 1;
            let startYear = startDayForCoverage.getFullYear();
            console.log('---this.editpolicydata?.quoteData?.Term__c--', this.editpolicydata?.quoteData?.Term__c);
            let endDayForCoverage = startDayForCoverage;

            if (this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual(Half a Year)') {
                console.log('Test SEMI annual');
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            }else if(this.editpolicydata?.quoteData?.Term__c ==='Annual(One Year)'){
                console.log('Test Annual');
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
                
            }else{
                endDayForCoverage.setDate(endDayForCoverage.getDate() + parseInt(this.editpolicydata?.quoteData?.Term_Days__c));                
            }

            let date = new Date(endDayForCoverage);
            let tempDay = date.getDate();
            let month = date.getMonth() + 1;

            let endDateFormated = date.getFullYear() + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(tempDay);
            let startDateFormated = startYear + '-' + this.toDigitFormate(startmonth) + '-' + this.toDigitFormate(startdate);
            console.log('---endDateFormated--', endDateFormated);
            console.log('---startDateFormated--', startDateFormated);
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Start_Date_for_Coverage__c']: startDateFormated } };
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Date_for_Coverage__c']: endDateFormated } };
            console.log('---quoteData--', this.editpolicydata.quoteData);
            
            const renewconnectedcallback = new CustomEvent('renewconnectedcallback', {
                detail: true,
            });
            this.dispatchEvent(renewconnectedcallback);
        }


    }

    renderedCallback() {

        if (!this.isComponentRendered) {
            Promise.all([
                loadStyle(this, StyleCSS + '/style.css')
            ]).then(() => {
                console.log("Files loaded");
                this.isComponentRendered = true;
            }).catch(error => {
                console.log('css error', error.body.message);
                this.isComponentRendered = false;
            });
        }
    }

    get isDisabledDate() {
        return this.disableDate == true || this.annual == true || this.semiAnnual == true;
    }

    get isWatercraft() {
        return this.policyType == 'Watercraft';
    }

    get isNorthbound() {
        return this.policyType == 'Northbound';
    }

    get isMotorcyclePolicy() {
        return this.policyType == 'Motorcycle' || this.policyType == 'Motorcycle/Street Legal ATV';
    }
    get yesNoOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    handleNextClick = async () => {
        console.log(' handle click next ');
        
        let a = new Date(this.editpolicydata.quoteData.Start_Date_for_Coverage__c);
        let b = new Date(this.editpolicydata.quoteData.End_Date_for_Coverage__c);
        console.log(a);
        console.log(b);
        let difference = this.dateDiffInDays(a, b);
        console.log(difference);
        
        if (difference > 365) {
            let errEvt = new ShowToastEvent({
                message: this.label.Thetermdayscantbe ,
                variant: 'error',
            });
            this.dispatchEvent(errEvt);
            return;
        }else if(difference < 1){
            let errEvt = new ShowToastEvent({
                message: 'Policy End Date must be greater than Policy Start Date!',
                variant: 'error',
            });
            this.dispatchEvent(errEvt);
            return;
        }
        this.template.querySelector('.buttonNext').classList.add('loading');
        this.template.querySelector('.buttonNext').setAttribute('disabled', true);
        this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Term__c']: difference > 0 && difference <= 30 ? 'Daily' : difference > 30 && difference <= 180 ? 'Semi-Annual(Half a Year)' : 'Annual(One Year)', ['Term_Days__c']: difference.toString() } };
        console.log('--handle next click editpolicydata--', JSON.stringify(this.editpolicydata, null, 4));

        let allValid = this.isInputValid();
        console.log(allValid);
        if (allValid) {
            if (this.isRenewalPolicy == 'Yes') {
                if (!this.policyExist) {
                    // update the renewed quote data...
                    let updateCloneQuote = await updateQuoteData({ 'quote': JSON.stringify(this.editpolicydata.quoteData) });
                    console.log('--updateCloneQuote--' + this.policyExist, updateCloneQuote);
                    if (updateCloneQuote.status == 'success') {
                        this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...updateCloneQuote.data } }
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    } else {
                        console.log('there are some error occur');
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    }

                } else {
                    // create new quote...
                    let { Id, ...quote } = { ...this.editpolicydata.quoteData };
                    console.log('--quote---', quote);
                    console.log('--oldQuoteId---', Id);

                    let createCloneQuoteReacord = await createNewRenewQuote({ 'quote': JSON.stringify(quote), 'oldQuoteId': Id });
                    console.log('--createCloneQuoteReacord--' + this.policyExist, createCloneQuoteReacord);
                    if (createCloneQuoteReacord.status == 'success') {
                        this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...createCloneQuoteReacord.data } }
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    } else {
                        console.log('there are some error occur');
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    }


                }
            }
            console.log('--after edit updatequotedata--', this.editpolicydata);
            const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                detail: this.editpolicydata,
            });
            this.dispatchEvent(editPolicyChange);
            this.changesnextscreen();
        } else {
            this.template.querySelector('.buttonNext').classList.remove('loading');
            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
        }



    }

    dateDiffInDays(a, b) {
        const _MS_PER_DAY = 1000 * 60 * 60 * 24;
        // Discard the time and time-zone information.
        const utc1 = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate());
        const utc2 = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate());

        return Math.floor((utc2 - utc1) / _MS_PER_DAY);
    }

    handlePrevClick = () => {
        const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
            detail: this.editpolicydata,
        });
        this.dispatchEvent(editPolicyChange);
        this.changeprevscreen();

    }
    getSystemTime = async () => {
        try {
            const timeData = await getTimeZone();
            console.log('--timeData---', timeData);
            if (timeData.status == 'success') {
                this.systemTime = timeData;
                this.displayPstTime = this.systemTime.timePst;
            } else {
                console.log('error occur in method to get system time');
            }
        } catch (ex) {
            console.log('erron occur in get system time : ' + ex);
        }
    }

    get TerritoryOption() {
        return [
            { label: 'Baja Sonora', value: 'Baja/Sonora' },
            { label: 'Partial (US Adjacent)', value: 'Limited' },
            { label: 'Entire Mexico', value: 'Full' },
        ];
    }

    get medicalOption() {
        if (this.policyType != undefined && this.policyType != 'Northbound' && this.policyType != 'Watercraft' && this.policyType != 'Driver License' && this.policyType != 'Automobile') {
            if (this.isRenewalPolicy && this.editpolicydata && this.editpolicydata.policyData && this.editpolicydata.policyData.Underwriter_picklist__c && this.editpolicydata.policyData.Underwriter_picklist__c == 'Chubb' && this.policyType == 'Motorcycle/Street Legal ATV') {
                return [{ 'label': '$10,000/$50,000', 'value': '10,000/50,000' },
                { 'label': '$15,000/$75,000', 'value': '15,000/75,000' },
                { 'label': '$20,000/$100,000', 'value': '20,000/100,000' }];
            }else{
                return [{ 'label': '$2,000/$10,000', 'value': '2,000/10,000' },
                { 'label': '$3,000/$15,000', 'value': '3,000/15,000' },
                { 'label': '$4,000/$20,000', 'value': '4,000/20,000' },
                { 'label': '$5,000/$25,000', 'value': '5,000/25,000' },
                { 'label': '$10,000/$50,000', 'value': '10,000/50,000' }];
            }

        } else if (this.policyType != undefined && this.policyType == 'Automobile' ) {

            if (this.isRenewalPolicy && this.editpolicydata && this.editpolicydata.policyData && this.editpolicydata.policyData.Underwriter_picklist__c && this.editpolicydata.policyData.Underwriter_picklist__c == 'Chubb') {
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

        } else if (this.policyType != undefined && this.policyType == 'Watercraft') {
            return [
                { 'label': '$50,000/$100,000', 'value': '50,000/100,000' },
                { 'label': '$100,000/$300,000', 'value': '100,000/300,000' },
                { 'label': '$250,000/$500,000', 'value': '250,000/500,000' }];
        }
    }

    get liabilityOption() {
        if (this.policyType != undefined && this.policyType != 'Northbound' && this.policyType != 'Watercraft' && this.policyType != 'Driver License' && this.policyType != 'Automobile') {
            
            if (this.isRenewalPolicy && this.editpolicydata && this.editpolicydata.policyData && this.editpolicydata.policyData.Underwriter_picklist__c && this.editpolicydata.policyData.Underwriter_picklist__c == 'Chubb' && this.policyType == 'Motorcycle/Street Legal ATV') {
                return [
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$400,000', 'value': '400,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else {
                return [{ 'label': '$100,000', 'value': '100,000' },
                { 'label': '$200,000', 'value': '200,000' },
                { 'label': '$300,000', 'value': '300,000' },
                { 'label': '$500,000', 'value': '500,000' }];
            }

        } else if (this.policyType != undefined && this.policyType == 'Automobile') {

            if (this.isRenewalPolicy && this.editpolicydata && this.editpolicydata.policyData && this.editpolicydata.policyData.Underwriter_picklist__c && this.editpolicydata.policyData.Underwriter_picklist__c == 'Chubb') {
                return [
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$400,000', 'value': '400,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
            } else {
                if(this.editpolicydata && this.editpolicydata.policyData && this.editpolicydata.policyData.Underwriter_picklist__c && this.editpolicydata.policyData.Underwriter_picklist__c == 'Chubb'){
                    return [
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$400,000', 'value': '400,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
                }else{
                    return [{ 'label': '$100,000', 'value': '100,000' },
                    { 'label': '$200,000', 'value': '200,000' },
                    { 'label': '$300,000', 'value': '300,000' },
                    { 'label': '$500,000', 'value': '500,000' },
                    { 'label': '$1,000,000', 'value': '1,000,000' }];
                }
                
            }


        } else if (this.policyType != undefined && this.policyType == 'Watercraft') {
            return [{ 'label': '$200,000', 'value': '200,000' },
            { 'label': '$400,000', 'value': '400,000' },
            { 'label': '$750,000', 'value': '750,000' }];
        } else if (this.policyType != undefined && this.policyType == 'Northbound') {
            return [{ 'label': '$100,000', 'value': '100,000' },
            { 'label': '$200,000', 'value': '200,000' },
            { 'label': '$300,000', 'value': '300,000' }];
        } else if (this.policyType != undefined && this.policyType == 'Driver License') {
            return [{ 'label': '$300,000', 'value': '300,000' },
            { 'label': '$500,000', 'value': '500,000' }];
        }
    }
    get startDatePolicy() {
        //this.termOptions = {...this.termOptions, ['Start_Date_for_Coverage__c']: this.editpolicydata.quoteData.Start_Date_for_Coverage__c};
        return this.editpolicydata?.quoteData?.Start_Date_for_Coverage__c;
        
    }
    get startTimePolicy() {
        return this.msToTime(this.editpolicydata?.quoteData?.Start_Time__c.toString());
        // return this.editpolicydata?.quoteData?.Start_Time__c;
    }
    get endDatePolicy() {
        //this.termOptions = {...this.termOptions, ['End_Date_for_Coverage__c']: this.editpolicydata.quoteData.End_Date_for_Coverage__c};
        return this.editpolicydata?.quoteData?.End_Date_for_Coverage__c;
        
    }
    get endTimePolicy() {
        return this.msToTime(this.editpolicydata?.quoteData?.End_Time__c.toString());
        // return this.editpolicydata?.quoteData?.End_Time__c;
    }
    get medicalData() {
        return this.editpolicydata?.quoteData?.Medical__c;
    }
    get liabilityData() {
        return this.editpolicydata?.quoteData?.Liability__c;
    }
    get territoryCoverageData() {
        return this.editpolicydata?.quoteData?.Territory__c;
    }
    get isSemiAnnual() {
        this.semiAnnual = this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual(Half a Year)' && true;
        //this.termOptions = {...this.termOptions, ['SemiAnnual']: this.editpolicydata.quoteData.Term__c === 'Semi-Annual(Half a Year)' && true};
        return this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual(Half a Year)';
    }

    get isDaily(){
        //this.termOptions = {...this.termOptions, ['SemiAnnual']: this.editpolicydata.quoteData.Term__c === 'Semi-Annual(Half a Year)' && true};
        return this.editpolicydata?.quoteData?.Term__c === 'Daily';
    }

    get isAnnual() {
        this.annual = this.editpolicydata?.quoteData?.Term__c === 'Annual(One Year)' && true;
        //this.termOptions = {...this.termOptions, ['Annual']: this.editpolicydata.quoteData.Term__c === 'Annual(One Year)' && true};
        return this.editpolicydata?.quoteData?.Term__c === 'Annual(One Year)';
    }
    get setMaximumSpeedValue() {
        return this.editpolicydata != undefined ? (this.editpolicydata?.quoteData?.Is_the_Maximum_Speed_more_than_50_mph__c != undefined ? this.editpolicydata?.quoteData?.Is_the_Maximum_Speed_more_than_50_mph__c : '') : '';
    }
    get setUnderAgeDriver() {
        return this.editpolicydata != undefined ? (this.editpolicydata?.quoteData?.Any_Boat_Operator_Under_22__c != undefined ? this.editpolicydata?.quoteData?.Any_Boat_Operator_Under_22__c : '') : '';
    }
    get setMaxcioLivilig() {
        return this.editpolicydata != undefined ? (this.editpolicydata?.quoteData?.Is_the_owner_living_in_Mexico__c != undefined ? this.editpolicydata?.quoteData?.Is_the_owner_living_in_Mexico__c : '') : '';
    }
    msToTime(s) {
        console.log('---maToTime---', s);
        // Pad to 2 or 3 digits, default is 2
        function pad(n, z) {
            z = z || 2;
            return ('00' + n).slice(-z);
        }

        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;

        return pad(hrs) + ':' + pad(mins) + ':' + pad(secs) + '.' + pad(ms, 3);
    }

    handleChange(e) {
        let name = e.target.name;
        let val = e.target.value;


        if (name === 'Medical__c' && !this.isRenewalPolicy) {
            //checking values not shorter
            let oldIndex , newIndex = 0;
            let indexCounter = 0;
            for(let mdval of this.medicalOption){
                if(mdval.value == this.oldMedicalValuesPersist){
                    oldIndex = indexCounter;
                }
                if(mdval.value == val){
                    newIndex = indexCounter;
                }
                indexCounter++;
            }
            if((parseInt(newIndex) - parseInt(oldIndex)) < 0 ){
                let errEvt = new ShowToastEvent({
                    message: 'You cannot select Medical lower than $'+this.oldMedicalValuesPersist,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                let combobox = this.template.querySelector('.Medicalpicklist');
                combobox.value = this.oldMedicalValuesPersist;
                return;
            }else{
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: val } };
            }
        }

        if (name === 'Liability__c' && !this.isRenewalPolicy) {
            //checking values not shorter
            let oldIndex , newIndex = 0;
            let indexCounter = 0;
            for(let mdval of this.liabilityOption){
                if(mdval.value == this.oldLiabilityValuesPersist){
                    oldIndex = indexCounter;
                }
                if(mdval.value == val){
                    newIndex = indexCounter;
                }
                indexCounter++;
            }
            if((parseInt(newIndex) - parseInt(oldIndex)) < 0 ){
                let errEvt = new ShowToastEvent({
                    message: 'You cannot select Liability lower than $'+this.oldLiabilityValuesPersist,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                let combobox = this.template.querySelector('.LiabilityPicklist');
                combobox.value = this.oldLiabilityValuesPersist;
                return;
            }else{
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: val } };
            }
        }


        if(this.isRenewalPolicy || ( name != 'Medical__c' && name != 'Liability__c')){
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: val } };
        }

        
        let startDayForCoverage = new Date(this.editpolicydata.quoteData.Start_Date_for_Coverage__c);
        if (startDayForCoverage != null && startDayForCoverage != undefined) {
            startDayForCoverage = new Date(startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            let dateMinforend = new Date(this.editpolicydata.quoteData.Start_Date_for_Coverage__c);
            this.endMinDate = dateMinforend.toISOString();
        }
        

        if (name === 'Start_Date_for_Coverage__c' && startDayForCoverage != null && startDayForCoverage != undefined) {
            // if (val !== this.oldpolicydata.quoteData.Start_Date_for_Coverage__c) {
            let dateOfSystem = this.systemTime.dtPST.split(' ');
            console.log('---systemdate--', dateOfSystem[0]);
            console.log('---val--', val);

            if (dateOfSystem[0] == val) {
                this.displayPstTime = this.systemTime.timePst;
                this.termOptions = { ...this.termOptions, ['Start_Time__c']: this.systemTime?.nextMin, ['End_Time__c']: this.systemTime?.nextMin };
            } else {
                this.displayPstTime = '00:00:000';
                 let timestamp = this.displayPstTime.split(":")
                let seconds = parseFloat(timestamp[2].replace(',', "."))
                let minutes = parseInt(timestamp[1])
                let hours = parseInt(timestamp[0])

                let milliseconds = seconds * 1000 + minutes * 60 * 1000 + hours * 3600 * 1000;
                if(milliseconds == 0){
                    milliseconds = 100;
                }
                console.log('fetch milliseconds-----',milliseconds);
                this.termOptions = { ...this.termOptions, ['Start_Time__c']: '00:00:00.000Z', ['End_Time__c']: '00:00:00.000Z' };
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Start_Time__c']: milliseconds} };
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Time__c']: milliseconds} };
            }
            let endDayForCoverage = startDayForCoverage;
            if (this.annual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (this.semiAnnual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            }
            let date = new Date(endDayForCoverage);
            let tempDay = date.getDate();
            let month = date.getMonth() + 1;

            let endDateFormated = date.getFullYear() + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(tempDay);
            this.enddateValue = endDateFormated;
            console.log('---endDateFormated--', endDateFormated);
            // if (this.editpolicydata.quoteData.End_Date_for_Coverage__c != undefined || this.editpolicydata.quoteData.End_Date_for_Coverage__c != null) {
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Date_for_Coverage__c']: endDateFormated } };
            console.log('---quoteData--', this.editpolicydata.quoteData);
            // }
            // }
        }
        if (name == 'Start_Time__c') {
            let timestamp = val.split(":")
            let seconds = parseFloat(timestamp[2].replace(',', "."))
            let minutes = parseInt(timestamp[1])
            let hours = parseInt(timestamp[0])

             let milliseconds = seconds * 1000 + minutes * 60 * 1000 + hours * 3600 * 1000;
            if(milliseconds == 0){
                milliseconds = 100;
            }
            console.log('milliseconds-----',milliseconds);
            // this.termOptions = { ...this.termOptions, ['Start_Time__c']: milliseconds };
            // this.termOptions = { ...this.termOptions, ['End_Time__c']: this.termOptions.Start_Time__c };
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Start_Time__c']: milliseconds, ['End_Time__c']: milliseconds } };
            console.log('---quoteData--', this.editpolicydata.quoteData);


        }
        // if (name == 'Start_Time__c') {
        //     this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Start_Time__c']: val, ['End_Time__c']: val } };
        // }

        console.log(this.editpolicydata);
    }
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

    onGroup(event) {
        let name = event.target.name;
        let checked = event.target.checked;
        if(name == 'Daily' && checked == false){
            this.editpolicydata = { ...this.editpolicydata, ['Term__c']: 'Daily'  };
            const checktex = this.template.querySelector('.dailyChecked');
            if(checktex!=null){
                checktex.checked = true;
            }
        }
        if (name == 'Annual' && checked == true) {
            this.annual = true;
            this.semiAnnual = false;
        } else if (name == 'SemiAnnual' && checked == true) {
            this.annual = false;
            this.semiAnnual = true;
        } else {
            this.annual = false;
            this.semiAnnual = false;
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Date_for_Coverage__c']: '' } }
        }
        let startDayForCoverage = new Date(this.editpolicydata.quoteData.Start_Date_for_Coverage__c);
        if (startDayForCoverage != null && startDayForCoverage != undefined) {
            let endDayForCoverage = startDayForCoverage;
            if (this.annual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (this.semiAnnual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            }
            const date = new Date(endDayForCoverage);
            let month = parseInt(date.getMonth()) + 1;
            month = month.toString().padStart(2, "0");
            let day = !this.annual && !this.semiAnnual ? date.getDate() + 1 : date.getDate();

            let endDateFormated = date.getFullYear() + '-' + month + '-' + day;
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Date_for_Coverage__c']: endDateFormated, ['Term__c']: this.annual ? 'Annual(One Year)' : this.semiAnnual ? 'Semi-Annual(Half a Year)' : 'Daily' } };
        }
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}