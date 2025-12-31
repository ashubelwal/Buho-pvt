import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import updateQuoteData from '@salesforce/apex/Mex_PolicyEditController.updateQuoteData';
import getLiabilityMedicalLimitForVendors from '@salesforce/apex/Mex_PolicyEditController.getLiabilityMedicalLimitForVendors';
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


export default class Nc_policyEditTermOption extends NavigationMixin(LightningElement) {
    label = {
        DoyouwanttochangetheTermorCoverageLimits, StartDateforCoverage, STARTTIME, Thetermdayscantbe, Annual, SemiAnnual, EndDateforCoverage, EndTime, TerritoryCoverage, Medical,
        Liability, IstheMaximumSpeedmorethan50mph, Willanyoneoperatetheboatundertheageof22, IstheownerlivinginMexico, Next,
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
    @track medicalOptions = [];
    @track liabilityOptions = [];

    async connectedCallback() {
        await this.getSystemTime();
        this.loadVendorLimits();

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
        if (this.editpolicydata?.quoteData?.Medical__c) {
            this.oldMedicalValuesPersist = this.editpolicydata?.quoteData?.Medical__c;
        }
        if (this.editpolicydata?.quoteData?.Liability__c) {
            this.oldLiabilityValuesPersist = this.editpolicydata?.quoteData?.Liability__c;
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
        if ((this.isRenewalPolicy == 'Yes' || this.isRenewalPolicy == true) && this.connectedcallback == false) {
            console.log('---startDayForCoverage--', this.todayDateValue);
            let startDayForCoverage = this.todayDateValue;
            let startdate = startDayForCoverage.getDate();
            let startmonth = startDayForCoverage.getMonth() + 1;
            let startYear = startDayForCoverage.getFullYear();
            console.log('---this.editpolicydata?.quoteData?.Term__c--', this.editpolicydata?.quoteData?.Term__c);
            let endDayForCoverage = startDayForCoverage;

            if (this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual(Half a Year)' || this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual') {
                console.log('Test SEMI annual');
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            } else if (this.editpolicydata?.quoteData?.Term__c === 'Annual(One Year)' || this.editpolicydata?.quoteData?.Term__c === 'Annual') {
                console.log('Test Annual');
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);

            } else {
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

    loadVendorLimits() {
        getLiabilityMedicalLimitForVendors()
            .then(result => {
                const data = JSON.parse(result);
                console.log('Data fetched from apex:- Liability and Medical', data);
                if (data.error) {
                    console.error(data.error);
                    return;
                }

                const vendorData = data.filter(
                    item => item.Vendor === this.editpolicydata?.quoteData?.Underwriter__c
                );

                if (vendorData?.length > 0) {
                    const liabilityJson = vendorData[0].Liability.replace(/'/g, '"');
                    const medicalJson = vendorData[0].Medical.replace(/'/g, '"');

                    const uniqueLiability = JSON.parse(liabilityJson);
                    const uniqueMedical = JSON.parse(medicalJson);

                    this.liabilityOptions = uniqueLiability.map(item => ({
                        label: item.label,
                        value: item.value
                    }));

                    this.medicalOptions = uniqueMedical.map(item => ({
                        label: item.label,
                        value: item.value
                    }));
                }
            })
            .catch(error => {
                console.error('Error fetching liability and medical options: ', error);
            });
    }

    renderedCallback() {
        console.log('In rendered CAll back', this.isComponentRendered);
        // if (!this.isComponentRendered) {
        //     Promise.all([
        //         loadStyle(this, StyleCSS + '/style.css')
        //     ]).then(() => {
        //         console.log("Files loaded");
        //         this.isComponentRendered = true;
        //     }).catch(error => {
        //         console.log('css error', error.body.message);
        //         this.isComponentRendered = false;
        //     });
        // }
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

   async handleNextClick(){
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let a = new Date(this.editpolicydata.quoteData.Start_Date_for_Coverage__c);
        let b = new Date(this.editpolicydata.quoteData.End_Date_for_Coverage__c);
        console.log(a);
        console.log(b);
        let difference = this.dateDiffInDays(a, b);
        console.log(difference);

        if (difference > 365) {
            let errEvt = new ShowToastEvent({
                message: this.label.Thetermdayscantbe,
                variant: 'error',
            });
            this.dispatchEvent(errEvt);
            return;
        } else if (difference < 1) {
            let errEvt = new ShowToastEvent({
                message: 'Policy End Date must be greater than Policy Start Date!',
                variant: 'error',
            });
            this.dispatchEvent(errEvt);
            return;
        }
        this.template.querySelector('.buttonNext').classList.add('loading');
        this.template.querySelector('.buttonNext').setAttribute('disabled', true);
        this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Term__c']: difference > 0 && difference <= 30 ? 'Daily' : difference > 30 && difference <= 180 ? 'Semi-Annual' : 'Annual', ['Term_Days__c']: difference.toString() } };
        console.log('--handle next click editpolicydata--', JSON.stringify(this.editpolicydata, null, 4));

        let allValid = this.isInputValid();
        console.log(allValid);
        if (allValid) {
            if (this.isRenewalPolicy == 'Yes') {
                if (!this.policyExist) {
                    // update the renewed quote data...
                    let updateCloneQuote = await updateQuoteData({ 'quote': JSON.stringify(this.editpolicydata.quoteData) });
                    console.log('--updateCloneQuote111--' + this.policyExist, updateCloneQuote);
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
                    console.log('--createCloneQuoteReacord222--' + this.policyExist, createCloneQuoteReacord);
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

        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));

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
        return this.medicalOptions.length > 0 ? this.medicalOptions : [
            { label: '$2,000/$10,000', value: '2,000/10,000' },
            { label: '$3,000/$15,000', value: '3,000/15,000' },
            { label: '$4,000/$16,000', value: '4,000/16,000' },
            { label: '$5,000/$25,000', value: '5,000/25,000' },
            { label: '$10,000/$50,000', value: '10,000/50,000' },
            { label: '$15,000/$75,000', value: '15,000/75,000' },
            { label: '$20,000/$100,000', value: '20,000/100,000' }
        ];
    }

    get liabilityOption() {
        return this.liabilityOptions.length > 0 ? this.liabilityOptions : [
            { label: '$100,000', value: '100,000' },
            { label: '$200,000', value: '200,000' },
            { label: '$300,000', value: '300,000' },
            { label: '$500,000', value: '500,000' },
            { label: '$1,000,000', value: '1,000,000' }
        ];
    }
    get startDatePolicy() {
        //this.termOptions = {...this.termOptions, ['Start_Date_for_Coverage__c']: this.editpolicydata.quoteData.Start_Date_for_Coverage__c};
        return this.editpolicydata?.quoteData?.Start_Date_for_Coverage__c;

    }
    // get startTimePolicy() {
    //     console.log('Time Data in getStartTime',this.editpolicydata?.quoteData?.Start_Time__c.toString());
    //     return this.msToTime(this.editpolicydata?.quoteData?.Start_Time__c.toString());
    //     // return this.editpolicydata?.quoteData?.Start_Time__c;
    // }
    get endDatePolicy() {
        //this.termOptions = {...this.termOptions, ['End_Date_for_Coverage__c']: this.editpolicydata.quoteData.End_Date_for_Coverage__c};
        return this.editpolicydata?.quoteData?.End_Date_for_Coverage__c;

    }
    // get endTimePolicy() {
    //     console.log('Time Data in getEndTime',this.editpolicydata?.quoteData?.End_Time__c.toString());
    //     return this.msToTime(this.editpolicydata?.quoteData?.End_Time__c.toString());
    //     // return this.editpolicydata?.quoteData?.End_Time__c;
    // }

    get startTimePolicy() {
        const rawValue = this.editpolicydata?.quoteData?.Start_Time__c;
        console.log('Time Data in getStartTime', rawValue);

        if (!rawValue) return '';

        // If it's already a string like "13:30:00", return as is
        if (typeof rawValue === 'string' && rawValue.includes(':')) {
            return rawValue;
        }

        // If it's a number or string number like "48600000", convert to time
        return this.msToTime(this.editpolicydata?.quoteData?.Start_Time__c.toString())
    }

    get endTimePolicy() {
        const rawValue = this.editpolicydata?.quoteData?.End_Time__c;
        console.log('Time Data in getEndTime', rawValue);

        if (!rawValue) return '';

        if (typeof rawValue === 'string' && rawValue.includes(':')) {
            return rawValue;
        }

        return this.msToTime(this.editpolicydata?.quoteData?.End_Time__c.toString())
    }

    get medicalData() {
        // return this.editpolicydata?.quoteData?.Medical__c;
        const storedValue = this.editpolicydata?.quoteData?.Medical__c;
        console.log('Formatted Data', this.getFormattedValue(storedValue, this.medicalOption));
        return this.getFormattedValue(storedValue, this.medicalOption);
    }
    get liabilityData() {
        const storedValue = this.editpolicydata?.quoteData?.Liability__c;
        console.log('Formatted Data Liability', this.getFormattedValue(storedValue, this.liabilityOption));
        return this.getFormattedValue(storedValue, this.liabilityOption);
        // return this.editpolicydata?.quoteData?.Liability__c;
    }

    // Helper method to format a number with commas (e.g., 10000 → "10,000")
    formatNumberWithCommas(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    // Method to ensure the value matches the dropdown format
    getFormattedValue(value, options) {
        if (!value) return value;

        // Check if the value already exists in the options
        const foundOption = options.find(opt => opt.value === value);
        if (foundOption) {
            return value; // Return as-is if it matches
        }

        // Handle Liability format (e.g., "10000/50000" → "10,000/50,000")
        if (value.includes('/')) {
            const [first, second] = value.split('/');
            const formattedFirst = this.formatNumberWithCommas(parseInt(first.replace(/,/g, ''), 10));
            const formattedSecond = this.formatNumberWithCommas(parseInt(second.replace(/,/g, ''), 10));
            return `${formattedFirst}/${formattedSecond}`;
        }
        // Handle Medical format (e.g., "100000" → "100,000")
        else {
            return this.formatNumberWithCommas(parseInt(value.replace(/,/g, ''), 10));
        }
    }
    get territoryCoverageData() {
        return this.editpolicydata?.quoteData?.Territory__c;
    }
    get isSemiAnnual() {
        this.semiAnnual = (this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual(Half a Year)' || this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual') && true;
        //this.termOptions = {...this.termOptions, ['SemiAnnual']: this.editpolicydata.quoteData.Term__c === 'Semi-Annual(Half a Year)' && true};
        return (this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual(Half a Year)' || this.editpolicydata?.quoteData?.Term__c === 'Semi-Annual');
    }

    get isDaily() {
        //this.termOptions = {...this.termOptions, ['SemiAnnual']: this.editpolicydata.quoteData.Term__c === 'Semi-Annual(Half a Year)' && true};
        return this.editpolicydata?.quoteData?.Term__c === 'Daily';
    }

    get isAnnual() {
        this.annual = (this.editpolicydata?.quoteData?.Term__c === 'Annual(One Year)' || this.editpolicydata?.quoteData?.Term__c === 'Annual') && true;
        //this.termOptions = {...this.termOptions, ['Annual']: this.editpolicydata.quoteData.Term__c === 'Annual(One Year)' && true};
        return this.editpolicydata?.quoteData?.Term__c === 'Annual(One Year)' || this.editpolicydata?.quoteData?.Term__c === 'Annual';
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
            let oldIndex, newIndex = 0;
            let indexCounter = 0;
            for (let mdval of this.medicalOption) {
                if (mdval.value == this.oldMedicalValuesPersist) {
                    oldIndex = indexCounter;
                }
                if (mdval.value == val) {
                    newIndex = indexCounter;
                }
                indexCounter++;
            }
            if ((parseInt(newIndex) - parseInt(oldIndex)) < 0) {
                let errEvt = new ShowToastEvent({
                    message: 'You cannot select Medical lower than $' + this.oldMedicalValuesPersist,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                let combobox = this.template.querySelector('.Medicalpicklist');
                combobox.value = this.oldMedicalValuesPersist;
                return;
            } else {
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: val } };
            }
        } else if(name === 'Medical__c' && this.isRenewalPolicy){
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: val } };
            console.log('Edit Policy/Renewal Polciy Data while updating medical',this.editpolicydata);
        }

        if (name === 'Liability__c' && !this.isRenewalPolicy) {
            //checking values not shorter
            let oldIndex, newIndex = 0;
            let indexCounter = 0;
            for (let mdval of this.liabilityOption) {
                if (mdval.value == this.oldLiabilityValuesPersist) {
                    oldIndex = indexCounter;
                }
                if (mdval.value == val) {
                    newIndex = indexCounter;
                }
                indexCounter++;
            }
            if ((parseInt(newIndex) - parseInt(oldIndex)) < 0) {
                let errEvt = new ShowToastEvent({
                    message: 'You cannot select Liability lower than $' + this.oldLiabilityValuesPersist,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                let combobox = this.template.querySelector('.LiabilityPicklist');
                combobox.value = this.oldLiabilityValuesPersist;
                return;
            } else {
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: val } };
            }
        }else if(name === 'Liability__c' && this.isRenewalPolicy){
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, [name]: val } };
            console.log('Edit Policy/Renewal Polciy Data while updating Liability',this.editpolicydata);
        }


        if (this.isRenewalPolicy || (name != 'Medical__c' && name != 'Liability__c')) {
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
                if (milliseconds == 0) {
                    milliseconds = 100;
                }
                console.log('fetch milliseconds-----', milliseconds);
                this.termOptions = { ...this.termOptions, ['Start_Time__c']: '00:00:00.000Z', ['End_Time__c']: '00:00:00.000Z' };
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Start_Time__c']: milliseconds } };
                this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Time__c']: milliseconds } };
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
            if (milliseconds == 0) {
                milliseconds = 100;
            }
            console.log('milliseconds-----', milliseconds);
            // this.termOptions = { ...this.termOptions, ['Start_Time__c']: milliseconds };
            // this.termOptions = { ...this.termOptions, ['End_Time__c']: this.termOptions.Start_Time__c };
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['Start_Time__c']: milliseconds, ['End_Time__c']: milliseconds } };
            console.log('---quoteData--', this.editpolicydata.quoteData);


        }

        console.log('Handle change end:::Policy Data',this.editpolicydata);
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
        if (name == 'Daily' && checked == false) {
            this.editpolicydata = { ...this.editpolicydata, ['Term__c']: 'Daily' };
            const checktex = this.template.querySelector('.dailyChecked');
            if (checktex != null) {
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
            this.editpolicydata = { ...this.editpolicydata, ['quoteData']: { ...this.editpolicydata.quoteData, ['End_Date_for_Coverage__c']: endDateFormated, ['Term__c']: this.annual ? 'Annual' : this.semiAnnual ? 'Semi-Annual' : 'Daily' } };
        }
    }
    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}