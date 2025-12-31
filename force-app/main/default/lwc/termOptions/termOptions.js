import { api, LightningElement } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import selectyourterm from '@salesforce/label/c.TR_Please_select_your_term';
import annual from '@salesforce/label/c.TR_Annual';
import semiannual from '@salesforce/label/c.TR_Semi_Annual';
import daily from '@salesforce/label/c.TR_Daily';
import startdate from '@salesforce/label/c.TR_Start_Date_for_Coverage';
import enddate from '@salesforce/label/c.TR_End_Date_for_Coverage';
import starttime from '@salesforce/label/c.TR_Start_Time';
import endtime from '@salesforce/label/c.TR_End_Time';
import prev from '@salesforce/label/c.TR_Prev';
import next from '@salesforce/label/c.TR_Next';
import termOptions from '@salesforce/label/c.TR_Term_Option';
import allpoliciesare from '@salesforce/label/c.TR_All_policies_are_issued_in_Pacific_Time_so_please_be_sure_to_make_the_adjust';
import SystemTimeNow from '@salesforce/label/c.TR_System_Time_Now';
import Totaldayscannotequalmorethan365 from '@salesforce/label/c.TR_Total_days_cannot_equal_more_than_365';

export default class TermOptions extends LightningElement {
    label = {
       selectyourterm,annual,semiannual,daily,startdate,enddate,starttime,Totaldayscannotequalmorethan365,endtime,prev,next,allpoliciesare,SystemTimeNow,termOptions,
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api customerRecord;
    @api communityUser;
    @api 
    issecondtimeload = false;
	isRendered = false;
    annual = false;
    semiAnnual = false;
    termOptions = {};
    mindate = '';
    endMaxDate = '';
    endMinDate = '';
    policyType;
    spinner = false;
    systemTime;
    displayPstTime;
	initialFetchResponse;
    leadId;
    leadEmail;


    get isSouthboudOrNorthboundVehicle() {
        return this.policyType == 'RV' || this.policyType == 'Automobile' || this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'Northbound';
    }
    get isGridSize() {
        return this.policyType == 'RV' || this.policyType == 'Automobile' || this.policyType == 'Motorcycle/Street Legal ATV' || this.policyType == 'Northbound' ? '2' : '2';
    }
    get isAnnual() {
        return this.termOptions.Term__c == 'Annual(One Year)';
    }
    get isSemiAnnual() {
        return this.termOptions.Term__c == 'Semi-Annual(Half a Year)';
    }
    get isDaily() {
        return this.termOptions.Term__c == 'Daily';
    }
    get isShowingEndTerm() {
        return this.termOptions.Term__c == 'Daily';
    }

    async connectedCallback() {
        this.spinner = true;
        
        this.policyType = this.communityUser != null && this.communityUser ? this.customerRecord?.policyType : this.leaddata?.policyType;
        
        await this.getSystemTime();
        let fetchResp = await this.fetchData();
		this.initialFetchResponse = fetchResp;

        const params = new URLSearchParams(window.location.search);
        this.leadId = params.get('id');
        this.leadEmail = params.get('email');

        let today = new Date(this.systemTime.dtPST);
        let day = today.getDate();
        let month = today.getMonth();
        let year = today.getFullYear();
        let term = 0;
        let currentDate = new Date(year, month, day);

        this.mindate = currentDate.toISOString();
		
        if (this.termOptions.Start_Date_for_Coverage__c != '' && this.termOptions.Start_Date_for_Coverage__c != undefined) {
            let dateOfSystem = this.systemTime.dtPST.split(' ');

            if (dateOfSystem[0] == this.termOptions.Start_Date_for_Coverage__c) {
                this.displayPstTime = this.systemTime.timePst;
            } else {
                this.displayPstTime = '00:00:00';
            }
        } else {

            let endDate = today;
            endDate.setDate(endDate.getDate() + 1);

            month = month + 1;
            let endMonth = endDate.getMonth() + 1;
            let endday = endDate.getDate();
            let endYear = endDate.getFullYear();
            let nextMinTime = this.systemTime?.nextMin.split('.')[0];
            let startDateCoverage = year + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(day);
            let endDateCoverage = endYear + '-' + this.toDigitFormate(endMonth) + '-' + this.toDigitFormate(endday);
            this.termOptions = { ...this.termOptions, ['Term__c']: 'Daily' };
            this.termOptions = { ...this.termOptions, ['Start_Date_for_Coverage__c']: startDateCoverage, ['End_Date_for_Coverage__c']: endDateCoverage, ['Start_Time__c']: nextMinTime, ['End_Time__c']: nextMinTime };
        }

    }
	
	renderedCallback() {
        if (this.initialFetchResponse != null && this.initialFetchResponse == 'success' && !this.isRendered) {
            if ((this.leadId != null || this.leadEmail != null) && (!this.communityUser && window.localStorage.getItem('continueNext') == 'true')) {
                this.isRendered = true;
                if(this.issecondtimeload == false){
                    this.handleNextClick(this.leadId, this.leadEmail);
                }
                this.issecondtimeload = true;
                
            }
        }
	}

    get isEndDateDisabled() {
        return this.annual || this.semiAnnual;
    }

    get getdisplayPstTime() {
        return this.systemTime.timePst != undefined ? this.systemTime.timePst : '00:00:00';
    }

    get StartDate() {
       
        return this.termOptions != undefined ? this.termOptions.Start_Date_for_Coverage__c : '';
    }
    get StartTime() {
        
        return this.termOptions != undefined ? (this.termOptions.Start_Time__c != undefined ? this.msToTime(this.termOptions.Start_Time__c) : '') : '';
    }
    get EndDate() {
        return this.termOptions != undefined ? this.termOptions.End_Date_for_Coverage__c : '';
    }
    get EndTime() {
        // return this.termOptions != undefined ? this.msToTime(this.termOptions.End_Time__c) : '';
        return this.termOptions != undefined ? (this.termOptions.End_Time__c != undefined ? this.msToTime(this.termOptions.End_Time__c) : '') : '';
    }



    onGroup(event) {
        let name = event.target.name;
        let value = event.target.value;
         
        let checked = event.target.checked
        if (value == 'Annual(One Year)' && checked == true) {
            this.annual = true;
            this.semiAnnual = false;
        } else if (value == 'Semi-Annual(Half a Year)' && checked == true) {
            this.annual = false;
            this.semiAnnual = true;
        } else {
            this.annual = false;
            this.semiAnnual = false;
            this.termOptions = { ...this.termOptions, ['End_Date_for_Coverage__c']: '' }
        }
        let startDayForCoverage = new Date(this.termOptions.Start_Date_for_Coverage__c);
        if (startDayForCoverage != null && startDayForCoverage != undefined) {
            let endDayForCoverage = startDayForCoverage;
             
            if (this.annual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (this.semiAnnual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            } else {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 1);
            }
            
            const date = new Date(endDayForCoverage);
            let month = parseInt(date.getMonth()) + 1;
            let day = parseInt(date.getDate());
            // month = month.toString().padStart(2, "0");

            let endDateFormated = date.getFullYear() + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(day);
            
            this.termOptions = { ...this.termOptions, ['End_Date_for_Coverage__c']: endDateFormated };
            this.termOptions = { ...this.termOptions, ['Term__c']: value };
            
            if (!this.communityUser) {
                this.leaddata = { ...this.leaddata, ['termOptions']: this.termOptions };
            }
        }

    }

    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value;
         
        this.termOptions = { ...this.termOptions, [name]: value }
        let startDayForCoverage = new Date(this.termOptions.Start_Date_for_Coverage__c);
        if (startDayForCoverage != null && startDayForCoverage != undefined) {
            startDayForCoverage = new Date(startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            let dateMinforend = new Date(this.termOptions.Start_Date_for_Coverage__c);
            this.endMinDate = dateMinforend.toISOString();
        }
        if (name == 'Start_Date_for_Coverage__c' && startDayForCoverage != null && startDayForCoverage != undefined) {

            let dateOfSystem = this.systemTime.dtPST.split(' ');
             
            if (dateOfSystem[0] == value) {
                this.displayPstTime = this.systemTime.timePst;
                this.termOptions = { ...this.termOptions, ['Start_Time__c']: this.systemTime?.nextMin.split(".")[0], ['End_Time__c']: this.systemTime?.nextMin.split(".")[0] };
            } else {
                this.displayPstTime = '00:00:00';
                 let timestamp = this.displayPstTime.split(":")
                let seconds = parseFloat(timestamp[2].replace(',', "."))
                let minutes = parseInt(timestamp[1])
                let hours = parseInt(timestamp[0])

                let milliseconds = seconds * 1000 + minutes * 60 * 1000 + hours * 3600 * 1000;
                if(milliseconds == 0){
                    milliseconds = 100;
                }
                console.log('Auto select time milliseconds ---',milliseconds);
                this.termOptions = { ...this.termOptions, ['Start_Time__c']: milliseconds, ['End_Time__c']: milliseconds };
            }

            let endDayForCoverage = startDayForCoverage;
            
            if (this.annual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            } else if (this.semiAnnual) {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            } else {
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 1);
            }
            
            const date = new Date(endDayForCoverage);
            let month = date.getMonth() + 1;
            let day = date.getDate();

            let endDateFormated = date.getFullYear() + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(day);
             
            if (this.termOptions.End_Date_for_Coverage__c != undefined || this.termOptions.End_Date_for_Coverage__c != null) {
                this.termOptions = { ...this.termOptions, ['End_Date_for_Coverage__c']: endDateFormated };
            }
        }


        if (name == 'Start_Time__c') {
            let timestamp = value.split(":")
            let seconds = parseFloat(timestamp[2].replace(',', "."))
            let minutes = parseInt(timestamp[1])
            let hours = parseInt(timestamp[0])

           let milliseconds = seconds * 1000 + minutes * 60 * 1000 + hours * 3600 * 1000;
            if(milliseconds == 0){
                milliseconds = 100;
            }
            console.log('--Handle select time milliseconds ---',milliseconds);
             
            this.termOptions = { ...this.termOptions, ['Start_Time__c']: milliseconds };
            this.termOptions = { ...this.termOptions, ['End_Time__c']: this.termOptions.Start_Time__c };



        }

        if (!this.communityUser) {
            this.leaddata = { ...this.leaddata, ['termOptions']: this.termOptions };
        }
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

    getSystemTime = async () => {
        try {
            const timeData = await getTimeZone();
           
            if (timeData.status == 'success') {
                this.systemTime = timeData;
                this.displayPstTime = this.systemTime.timePst;
            } else {
               
            }
        } catch (ex) {
            console.log('erron occur in get system time : ' + ex);
        }
    }

    fetchData = async () => {
        try {
            if (this.leaddata?.Id != undefined && !this.communityUser) {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Term_options__c" });
                 
                if (data.status == 'success') {
                    if (data.data[0].Term_options__c != undefined) {
                        let parseTermsData = JSON.parse(data.data[0].Term_options__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;
                        
                        this.termOptions = this.leaddata?.Policy_Type__c == prevPolicyType ? parseTermsData : {};
                        this.annual = parseTermsData.Term__c == 'Annual(One Year)' && true;
                        this.semiAnnual = parseTermsData.Term__c == 'Semi-Annual(Half a Year)' && true;
                    }
                    this.spinner = false;
                    return data.status;
                } else {
                    this.spinner = false;
                    this.generateLogs();
                    return 'error';
                }
            } else {
                if (this.communityUser != null && this.communityUser) {
                    this.termOptions = this.customerRecord && this.customerRecord?.quoteRecord ? this.customerRecord?.quoteRecord : {};
                    this.termOptions = { ...this.termOptions, ['Term__c']: this.customerRecord?.quoteRecord?.Term_Days__c <= 30 ? 'Daily' : this.customerRecord?.quoteRecord?.Term_Days__c > 30 && this.customerRecord?.quoteRecord?.Term_Days__c <= 180 ? 'Semi-Annual(Half a Year)' : this.customerRecord?.quoteRecord?.Term_Days__c > 180 && this.customerRecord?.quoteRecord?.Term_Days__c <= 365 ? 'Annual(One Year)' : 'Daily' }
                    this.annual = this.customerRecord?.quoteRecord != undefined && this.customerRecord?.quoteRecord?.Term__c == 'Annual(One Year)' ? true : false;
                    this.semiAnnual = this.customerRecord?.quoteRecord != undefined && this.customerRecord?.quoteRecord?.Term__c == 'Semi-Annual(Half a Year)' ? true : false;
                    this.spinner = false;
                    return 'success';
                }
            }
        } catch (ex) {
            this.generateLogs();
            this.spinner = false;
            
        }
    }

    handleNextClick = async (leadId, leadEmail) => {
        let date1 = new Date(this.termOptions.Start_Date_for_Coverage__c);
        let date2 = new Date(this.termOptions.End_Date_for_Coverage__c);
        const diffTime = Math.abs(date2 - date1);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        if(diffDays == 0){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please make sure policy term should have minimum of 1 day duration.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.template.querySelector('.buttonNext').classList.remove('loading');
            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            return;
        }

        if (diffDays <= 30) {
            this.term = 'Daily'
        } else if (diffDays > 30 && diffDays <= 180) {
            this.term = 'Semi-Annual(Half a Year)'
        } else {
            this.term = 'Annual(One Year)'
        }
        this.termOptions = { ...this.termOptions, ['Term__c']: this.term };
        const { term__c, ...rest } = this.termOptions;
        this.termOptions = { ...rest };
        
        let allValid = this.isInputValid();
        if (new Date(this.termOptions.Start_Date_for_Coverage__c) < new Date(this.systemTime.dtPST.split(" ")[0])) {
            if (!this.communityUser && (leadId || leadEmail)) {
                window.localStorage.setItem('continueNext', 'false');
                return;
            }
        }

        if (allValid) {
            try {
                this.template.querySelector('.buttonNext').classList.add('loading');
                this.template.querySelector('.buttonNext').setAttribute('disabled', true);
               
                if (diffDays != null && diffDays > 365) {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: this.label.Totaldayscannotequalmorethan365,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.template.querySelector('.buttonNext').classList.remove('loading');
                    this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    return;
                }
                const data = await validateFormData({ "objData": JSON.stringify({ ['Term_options__c']: this.termOptions }), "objName": 'termOptions' });

                
                if (this.communityUser && data.status == 'success') {
                    this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...this.termOptions, ['Term_Days__c']: diffDays } };
                    const customerRecordChange = new CustomEvent('customerecordchange', {
                        detail: this.customerRecord,
                    });
                    // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_4');
                    // if (eventExist == undefined){
                    //     window.dataLayer.push({
                    //         'event': 'funnel_step',
                    //         'step_number': 'step_4',
                    //         'step_name': 'term_option', 
                    //         'term_option_selected': this.termOptions.Term__c,
                    //         'insurance_category': this.leaddata.Policy_Type__c
                    //         });
                    // }
                    this.dispatchEvent(customerRecordChange);
                    this.changesnextscreen();
                } else {
                    if (data.status == 'success') {
                        const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Term_options__c']: JSON.stringify(this.termOptions), ['Id']: this.leaddata?.Id }) });
                        
                        if (res.status == 'Success') {
                            let eventExist = window.dataLayer.find((data) => data.step_number === 'step_4');
                            if (eventExist == undefined){
                                window.dataLayer.push({
                                    'event': 'funnel_step',
                                    'step_number': 'step_4',
                                    'step_name': 'term_option', 
                                    'term_option_selected': this.termOptions?.Term__c,
                                    'insurance_category': this.leaddata?.Policy_Type__c
                                    });
                            }
                            this.changesnextscreen();
                        } else {
                            this.generateLogs();
                            this.template.querySelector('.buttonNext').classList.remove('loading');
                            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                            // handle error...
                        }
                    } else {
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                        // handle error...
                    }
                }

            } catch (error) {
                
                this.generateLogs();
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                // handle errors if any...
            }
        } else {
            
            if (!this.communityUser && (leadId || leadEmail)) {
                window.localStorage.setItem('continueNext', 'false');
            }
        }
    }

    handlePrevClick() {
        if (!this.communityUser) {
            const leadChange = new CustomEvent('leadvaluechange', {
                detail: this.leaddata,
            });

            this.dispatchEvent(leadChange);
        } else {
            const customerRecordChange = new CustomEvent('customerecordchange', {
                detail: this.customerRecord,
            });

            this.dispatchEvent(customerRecordChange);
        }
        //console.log("Check Data on prev button", this.leaddata);
        this.changeprevscreen();
    }

    msToTime(s) {
        if (typeof s == 'string') {
            return s;
        } else {
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

            return pad(hrs) + ':' + pad(mins) + ':' + pad(secs);
        }

    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}