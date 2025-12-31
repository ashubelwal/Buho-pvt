import { api, wire, LightningElement } from 'lwc';
import getPicklistValuesFromApex from '@salesforce/apex/Mex_ValidateFormData.getPicklistValues';
import getDependentMap from '@salesforce/apex/Mex_ValidateFormData.getDependentMap';
import getDependentMapWithTranslations from '@salesforce/apex/Mex_ValidateFormData.getDependentMapWithTranslations';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import getYears from '@salesforce/apex/Mex_NewLeadProcess.getYears';
import getMakes from '@salesforce/apex/Mex_NewLeadProcess.getMakes';
import getModels from '@salesforce/apex/Mex_NewLeadProcess.getModels';
import getCurrentUserVehicles from '@salesforce/apex/Mex_NewLeadProcess.getCurrentUserVehicles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fillthevehicledetails from '@salesforce/label/c.TR_Please_fill_in_vehicle_details_below';
import selectavehicle from '@salesforce/label/c.TR_Select_a_Vehicle_from_your_account';
import ADDAVEHICLE from '@salesforce/label/c.TR_ADD_A_DIFFERENT_VEHICLE';
import enteravalidyear from '@salesforce/label/c.TR_Enter_a_valid_year';
import dateofbirth from '@salesforce/label/c.TR_Date_of_Birth';
import willanyoneunder from '@salesforce/label/c.TR_Will_anyone_under_age_21_drive_the_vehicle';
import vehicleusedforbusiness from '@salesforce/label/c.TR_Is_the_vehicle_used_for_business_purposes';
import isthisrented from '@salesforce/label/c.TR_Is_this_a_rental_vehicle';
import next from '@salesforce/label/c.TR_Next';
import prev from '@salesforce/label/c.TR_Prev';
import isthissalvage from '@salesforce/label/c.TR_Is_this_a_salvage_vehicle';
import liabilityonly from '@salesforce/label/c.TR_Liability_Only';
import vehiclevalue from '@salesforce/label/c.TR_Vehicle_Value';
import model from '@salesforce/label/c.TR_Model';
import make from '@salesforce/label/c.TR_Make';
import year from '@salesforce/label/c.TR_Year';
import vehicletype from '@salesforce/label/c.TR_Vehicle_Type';
import Vehicledetails from '@salesforce/label/c.TR_Vehicle_Details';
import yes from '@salesforce/label/c.TR_Yes';
import no from '@salesforce/label/c.TR_No';
import none from '@salesforce/label/c.TR_None';
import Yearcantbegreaterthan from '@salesforce/label/c.TR_Year_can_t_be_greater_than';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';


export default class VehicleDetails extends LightningElement {
     label = {
        fillthevehicledetails,selectavehicle,ADDAVEHICLE,enteravalidyear,Yearcantbegreaterthan,dateofbirth,willanyoneunder,vehicleusedforbusiness,isthisrented,next,prev,isthissalvage,liabilityonly,vehiclevalue,model,make,year,vehicletype,Vehicledetails,yes,no,none
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api isTowingOption;
    @api communityUser;
    @api vehicleData = [];
    @api customerRecord;
    @api policyType;
    @api
    issecondtimeload = false;
    vehiclesList = [];
    loginUserVehicleOption = [];
    getLoginAllVehicles = [];
    isLoadSpin = false;
    yearOption;
    DOBDay = '';
    DOBMonth = '';
    DOBYear = '';
    months = [];
    days = [];
    years = [];
    DOBY = '';

    currentDate = new Date();
    currentYear = this.currentDate.getFullYear();
    startFrom = this.currentDate.getFullYear() - 85;
    currentMonth = this.currentDate.getMonth();
    currentDay = this.currentDate.getDate();

    comboboxMakevalue;
    comboBoxmodelValue;
    showManualMake = false;
    showManualModel = false;
    showYearPickList = true;
    picklistOfYear = false;
    disableMake = true;
    disableModel = true;
    vehicleDetail = {};
    makeOptions;
    modelOptions;
    vehicleTypeQuoteOptions;
    spinner = false;
    newSectionOpen = false;
    activeAccordinSection = '';

    async connectedCallback() {
        try {
            this.spinner = true;
            const fetchDatareturn = await this.fetchData();
            this.policyType = this.communityUser != null && this.communityUser ? this.customerRecord?.policyType : this.leaddata?.policyType;

            if (this.communityUser) {
                const AllVehicleData = await this.getAllVehiclesData();
            } else {
                this.newSectionOpen = true;
                this.activeAccordinSection = 'A';
            }
            if (fetchDatareturn == "success") {
                if (this.policyType == 'Automobile') {

                    this.getVehicleYears();
                    if (this.vehicleDetail != undefined && this.vehicleDetail.Year__c != undefined) {
                        this.getVehicleMakes();
                    }

                    if (this.vehicleDetail != undefined && this.vehicleDetail.Year__c != undefined && this.vehicleDetail.Model__c != undefined) {
                        this.getVehicleModels();
                    }

                    let vehicleMake = this.vehicleDetail != undefined ? this.vehicleDetail.Make__c : '';
                    let vehicleModel = this.vehicleDetail != undefined ? this.vehicleDetail.Model__c : '';


                } else {
                    this.showYearPickList = false;
                }

                if (this.policyType == 'Motorcycle/Street Legal ATV') {
                    this.picklistOfYear = true;
                    this.getVehicleYears();
                }

                if (this.policyType == 'Northbound') {
                    this.fetchPicklist('Quote__c', 'Vehicle_Type__c');
                } else {
                    this.getDependentPicklistValues('Quote__c', 'Vehicle_Type__c', 'Vehicle_Sub_type__c');
                }

                const params = new URLSearchParams(window.location.search);
                let leadId = params.get('id');
                let leadEmail = params.get('email');

                console.log('running '+this.isloadStop);
                if ((leadId != null || leadEmail != null) && (!this.communityUser && window.localStorage.getItem('continueNext') == 'true')) {                  
                        if(this.issecondtimeload == false){
                            this.handleNextClick(leadId, leadEmail);
                        }
                        this.issecondtimeload = true;
                        
                }
            }
        } catch (error) {
            console.log('Error ::: ', error);
            this.generateLogs();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: 'Quote__c.Vehicle_Sub_type__c' })
    amitisTesting({ error, data }) {
        if (data) {
            console.log('Picklist Value ',data);
        } else if (error) {
            console.log('Picklist error ',error);
        }
    }

    get isDayValue() {
        return this.vehicleDetail != undefined && this.policyType.toLowerCase() === 'northbound' ? this.vehicleDetail.DOBDay : '';
    }

    get isMonthValue() {
        return this.vehicleDetail != undefined && this.policyType.toLowerCase() === 'northbound' ? this.vehicleDetail.DOBMonth : '';
    }

    get isYearValue() {
        return this.vehicleDetail != undefined && this.policyType.toLowerCase() === 'northbound' ? this.vehicleDetail.DOBYear : '';
    }

    get isSouthboudVehicle() {
        return this.policyType == 'RV' || this.policyType == 'Automobile' || this.policyType == 'Motorcycle/Street Legal ATV';
    }
    get isNorthboundVehicle() {
        return this.policyType == 'Northbound';
    }
    get vehicleType() {
        return this.vehicleDetail != undefined ? this.vehicleDetail.Vehicle_Type__c : '';
    }
    get vehicleSubType() {
        return this.vehicleDetail != undefined ? this.vehicleDetail.Vehicle_sub_type__c != undefined ? this.vehicleDetail.Vehicle_sub_type__c : this.vehicleDetail.Vehicle_Type__c : '';
    }
    get year() {
        return this.vehicleDetail != undefined ? this.vehicleDetail.Year__c : '';
    }
    get make() {
        return this.vehicleDetail != undefined ? this.vehicleDetail.Make__c : '';
    }
    get model() {
        return this.vehicleDetail != undefined ? this.vehicleDetail.Model__c : '';
    }
    get liabilityValue() {
        return this.vehicleDetail != undefined && this.vehicleDetail.Coverage__c == 'Liability';
    }
    get comboboxMake() {
        return this.comboboxMakevalue != '<Manually Enter>' ? this.vehicleDetail?.Make__c : this.comboboxMakevalue;
    }
    get comboBoxmodel() {
        return this.comboBoxmodelValue != '<Manually Enter>' ? this.vehicleDetail?.Model__c : this.comboBoxmodelValue;
    }
    get vehicleValue() {
        return this.vehicleDetail != undefined ? this.vehicleDetail.Value__c : '';
    }
    get agedrive() {
        return this.vehicleDetail?.Is_there_a_driver_under_21__c != undefined ? (this.vehicleDetail.Is_there_a_driver_under_21__c == true ? 'Yes' : 'No') : '';
    }
    get salvage() {
        return this.vehicleDetail?.Salvage_Vehicle__c != undefined ? (this.vehicleDetail.Salvage_Vehicle__c == true ? 'Yes' : 'No') : '';
    }
    get business() {
        return this.vehicleDetail?.Is_the_vehicle_used_for_business_purpose__c != undefined ? (this.vehicleDetail.Is_the_vehicle_used_for_business_purpose__c == true ? 'Yes' : 'No') : '';
    }
    get rental() {
        return this.vehicleDetail?.Is_this_a_Rental_Vehicle__c != undefined ? (this.vehicleDetail.Is_this_a_Rental_Vehicle__c == true ? 'Yes' : 'No') : '';
    }
    get selectedVehicleId() {
        return this.vehicleDetail?.Id;
    }

    get DD() {
        for (let i = 1; i <= 31; i++) {
            let dy = i;
            if (i <= 9) {
                dy = '0' + i.toString();
            }
            dy = dy.toString()
            this.days.push({
                'label': dy,
                'value': dy
            });
        }
        return this.days;
    }

    get MM() {
        for (let i = 1; i <= 12; i++) {
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
        for (this.startFrom; this.startFrom <= this.currentYear - 15; this.startFrom++) {
            this.years.push({
                'label': this.startFrom.toString(),
                'value': this.startFrom.toString()
            });
        }
        return this.years;
    }
    get yesNoOptions() {
        return [
            { label: this.label.yes, value: 'Yes' },
            { label: this.label.no, value: 'No' },
        ];
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

    handleChange(event) {
        try{
        let name = event.target.name;
        let value = event.target.value.trim();
        // if (!/^(?![\s-])[\w\s-]+$/.test(value)) {
        //     console.log('inside mathch value ');
        //     value = '';
        // }
        if (name == 'Coverage__c') {
            value = event.target.checked ? 'Liability' : 'Complete';
        }
        if (name == 'Is_there_a_driver_under_21__c' || name == 'Salvage_Vehicle__c' || name == 'Is_the_vehicle_used_for_business_purpose__c' || name == 'Is_this_a_Rental_Vehicle__c') {
            value = value == 'Yes' ? true : false;
        }
        if (name == 'DOBYear') {
            this.DOBYear = value;
        }
        if (name == 'DOBMonth') {
            this.DOBMonth = value;
        }
        if (name == 'DOBDay') {
            this.DOBDay = value;
        }
        // this.vehicleDetail = { ...this.vehicleDetail, [name]: value };


        if (name == 'Year__c') {
            console.log('changing year');
            this.vehicleDetail = { ...this.vehicleDetail, ['Year__c']: value };
            this.disableMake = true;
            this.getVehicleMakes();
        } else if (name == 'combobox_Make__c') {

            if (value != '<Manually Enter>') {
                this.vehicleDetail = { ...this.vehicleDetail, ['Make__c']: value };
                this.getVehicleModels();
                this.showManualMake = false;
                this.showManualModel = false;
            } else {
                this.comboboxMakevalue = value;
                this.comboBoxmodelValue = '<Manually Enter>';
                this.vehicleDetail = { ...this.vehicleDetail, ['Make__c']: '', ['Model__c']: '' };
                this.showManualMake = true;
                this.showManualModel = true;
            }
            this.disableModel = true;
        } else if (name == 'combobox_Model__c') {

            if (value != '<Manually Enter>') {
                this.vehicleDetail = { ...this.vehicleDetail, ['Model__c']: value };
                this.showManualModel = false;
            } else {
                this.comboBoxmodelValue = value;
                this.vehicleDetail = { ...this.vehicleDetail, ['Model__c']: '' };
                this.showManualModel = true;
            }
        }
        if (name != 'combobox_Model__c' && name != 'combobox_Make__c') {
            this.vehicleDetail = { ...this.vehicleDetail, [name]: value };
        }
        // if(name == 'Vehicle_type__c'){
        //     this.vehicleDetail = { ...this.vehicleDetail, ['Vehicle_sub_type__c']: value };
        // }
        }catch(e){
            console.error(e);
        }
    }

    getAllVehiclesData = async () => {
        try {
            const getAllVehicles = await getCurrentUserVehicles({ "policyType": this.policyType });
            let loginUserVechicles = [{ 'value': '', 'label': '--'+this.label.none+'--' }];
            if (getAllVehicles != null) {
                this.getLoginAllVehicles = getAllVehicles;
                getAllVehicles.forEach(function (item) {
                    let label = item.Make__c + ' ' + item.Model__c + ' ' + item.Year__c + ' - ' + (item.Vin__c != undefined ? item.Vin__c : '') + '';
                    loginUserVechicles.push({ 'value': item.Id, 'label': label });
                });
                this.loginUserVehicleOption = loginUserVechicles;
            }else{
                this.generateLogs();
            }
        } catch (ex) {
            console.log('errod ::: ', ex);
            this.generateLogs();
        }
    }
    changevehicleOption = async (event) => {
        let vehicleId = event.target.value;
        let filterVehicleDetail = this.getLoginAllVehicles.filter(item => {
            return item.Id == vehicleId;
        })

        filterVehicleDetail.map((data) => {
            data.Vehicle_sub_type__c = data.Vehicle_Type__c;
            data.Is_this_a_Rental_Vehicle__c = data.Rental__c == 'No' ? false : true;
            data.Is_there_a_driver_under_21__c = false;
        })
        this.vehicleDetail = filterVehicleDetail[0];
        if (filterVehicleDetail.length > 0) {
            if (this.vehicleDetail != undefined && this.vehicleDetail.Year__c != undefined) {
                this.getVehicleMakes();
            }

            if (this.vehicleDetail != undefined && this.vehicleDetail.Year__c != undefined && this.vehicleDetail.Model__c != undefined) {
                this.getVehicleModels();
            }
        }
        // this.handleSectionToggle();

        this.activeAccordinSection = 'A';
    }
    handleSectionToggle() {
        if (this.communityUser != undefined && this.communityUser == true) {
            this.newSectionOpen = !this.newSectionOpen;
        }
    }

    fetchData = async () => {
        if (this.leaddata?.Id != undefined && !this.communityUser) {

            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Vehicle_details__c" });

                if (data.status == 'success') {
                    if (data.data[0].Vehicle_details__c != undefined) {
                        //this.newSectionOpen = true;
                        let parseVehicleData = JSON.parse(data.data[0].Vehicle_details__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;
                        this.vehicleDetail = this.leaddata?.Policy_Type__c == prevPolicyType ? parseVehicleData : {};
                        this.vehicleDetail = { ...this.vehicleDetail, ['Is_there_a_driver_under_21__c']: parseVehicleData?.Is_there_a_driver_under_21__c != undefined ? parseVehicleData?.Is_there_a_driver_under_21__c : false };
                        this.vehicleDetail = { ...this.vehicleDetail, ['Salvage_Vehicle__c']: parseVehicleData?.Salvage_Vehicle__c != undefined ? parseVehicleData?.Salvage_Vehicle__c : false };
                        this.vehicleDetail = { ...this.vehicleDetail, ['Is_the_vehicle_used_for_business_purpose__c']: parseVehicleData?.Is_the_vehicle_used_for_business_purpose__c != undefined ? parseVehicleData?.Is_the_vehicle_used_for_business_purpose__c : false };
                        this.vehicleDetail = { ...this.vehicleDetail, ['Is_this_a_Rental_Vehicle__c']: parseVehicleData?.Is_this_a_Rental_Vehicle__c != undefined ? parseVehicleData?.Is_this_a_Rental_Vehicle__c : false };
                    }

                    this.spinner = false;
                    return data.status;
                } else {
                    this.spinner = false;
                    this.generateLogs();
                    return 'error';
                }

            } catch (ex) {
                this.spinner = false;
                this.generateLogs();
                console.log('error : ', ex);
            }
        } else {
            if (this.vehiclesList.length === 0) {
                this.vehiclesList = [...this.vehicleData];
            }
            this.spinner = false;

            this.vehicleDetail = this.communityUser && this.customerRecord && this.customerRecord?.vehicleData ? this.customerRecord?.vehicleData : { ['Coverage__c']: 'Complete' };
            this.vehicleDetail = { ...this.vehicleDetail, ['Is_there_a_driver_under_21__c']: this.customerRecord?.vehicleData?.Is_there_a_driver_under_21__c != undefined ? this.customerRecord?.vehicleData?.Is_there_a_driver_under_21__c : false };
            this.vehicleDetail = { ...this.vehicleDetail, ['Salvage_Vehicle__c']: this.customerRecord?.vehicleData?.Salvage_Vehicle__c != undefined ? this.customerRecord?.vehicleData?.Salvage_Vehicle__c : false };
            this.vehicleDetail = { ...this.vehicleDetail, ['Is_the_vehicle_used_for_business_purpose__c']: this.customerRecord?.vehicleData?.Is_the_vehicle_used_for_business_purpose__c != undefined ? this.customerRecord?.vehicleData?.Is_the_vehicle_used_for_business_purpose__c : false };
            this.vehicleDetail = { ...this.vehicleDetail, ['Is_this_a_Rental_Vehicle__c']: this.customerRecord?.vehicleData?.Is_this_a_Rental_Vehicle__c != undefined ? this.customerRecord?.vehicleData?.Is_this_a_Rental_Vehicle__c : false };
            // this.newSectionOpen = true;
            return 'success';
        }
    }

    handleNextClick = async (leadId, leadEmail) => {
        this.template.querySelector('.buttonNext').classList.add('loading');
        this.template.querySelector('.buttonNext').setAttribute('disabled', true);
        let vehicleType;
        let allValid = false;
        if (this.communityUser) {
            vehicleType = this.customerRecord?.policyType == 'Automobile' ? 'Car/Truck/Auto' : this.customerRecord?.policyType;
        } else {
            vehicleType = this.leaddata?.Policy_Type__c == 'Automobile' ? 'Car/Truck/Auto' : this.leaddata?.Policy_Type__c;
        }

        
        this.vehicleDetail = { ...this.vehicleDetail, ['Vehicle_Type__c']: this.policyType === 'Automobile' ? 'Car/Truck/Auto' : this.policyType, ['Coverage__c']: this.liabilityValue ? 'Liability' : 'Complete' };

        if( this.policyType == 'Northbound' && (this.vehicleDetail?.Is_this_a_Rental_Vehicle__c || this.vehicleDetail?.Is_the_vehicle_used_for_business_purpose__c)){
            const errorevt = new ShowToastEvent({
                message: 'Rental or Business vehicles are not eligible for the coverage!',
                variant: 'error',
            });
            this.dispatchEvent(errorevt);
            this.template.querySelector('.buttonNext').classList.remove('loading');
            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            return;
        }

        allValid = this.isInputValid();
        //Commented for enabling 2024 vehicles
        // if (this.vehicleDetail.Year__c > this.currentYear) {

        //     const evt = new ShowToastEvent({
        //         message: this.label.Yearcantbegreaterthan  + this.currentYear,
        //         variant: 'error',
        //     });
        //     this.dispatchEvent(evt);
        //     allValid = false;
        // }
        if (allValid) {
            try {
                this.vehicleDetail = { ...this.vehicleDetail }
                if (this.policyType == 'Northbound') {
                    this.DOBY = this.DOBYear + '-' + this.DOBMonth + '-' + this.DOBDay;
                    this.vehicleDetail = { ...this.vehicleDetail, ['Dob__c']: this.DOBY }
                }
                const data = await validateFormData({ "objData": JSON.stringify({ ['Vehicle_details__c']: this.vehicleDetail, ['Policy_Type__c']: this.policyType }), "objName": 'vehicleDetails' });

                if (this.communityUser && data.status == 'success') {
                    this.customerRecord = { ...this.customerRecord, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...this.vehicleDetail } };
                    const customerRecordChange = new CustomEvent('customerecordchange', {
                        detail: this.customerRecord,
                    });
                    // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_3');
                    // if (eventExist == undefined){
                    //     window.dataLayer.push({
                    //         'event': 'funnel_step',
                    //         'step_number': 'step_3',
                    //         'step_name': 'vehicle_details_1', 
                    //         'insurance_category': this.leaddata.Policy_Type__c
                    //         });
                    // }
                    this.dispatchEvent(customerRecordChange);
                    this.changesnextscreen();
                } else {
                    if (data.status == 'success') {
                        const res = await InsertLeadData({
                            'leadData': JSON.stringify({
                                ['Vehicle_details__c']: JSON.stringify(this.vehicleDetail),
                                ['Is_Towing__c']: this.isTowingOption,
                                ['Id']: this.leaddata?.Id,
                                ['Policy_Type__c']: this.leaddata?.Policy_Type__c,

                            })
                        });
                        if (res.status == 'Success') {
                            const leadRecordChange = new CustomEvent('leadvaluechange', {
                                detail: { ...this.leaddata, ['Vehicle_sub_type__c']: this.vehicleDetail?.Vehicle_sub_type__c != null ? this.vehicleDetail?.Vehicle_sub_type__c : '' },
                            });
                            let eventExist = window.dataLayer.find((data) => data.step_number === 'step_3');
                            if (eventExist == undefined){
                                window.dataLayer.push({
                                    'event': 'funnel_step',
                                    'step_number': 'step_3',
                                    'step_name': 'vehicle_details_1', 
                                    'insurance_category': this.leaddata?.Policy_Type__c
                                    });
                            }
                            this.dispatchEvent(leadRecordChange);
                            this.changesnextscreen();
                        } else {
                            this.template.querySelector('.buttonNext').classList.remove('loading');
                            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                            // error...
                        }
                    } else {
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                        // error...
                    }
                }
            } catch (error) {
                console.log(error);
                this.generateLogs();
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                // handle errors if any...
            }
        } else {
            this.template.querySelector('.buttonNext').classList.remove('loading');
            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            if (!this.communityUser && (leadId || leadEmail)) {
                window.localStorage.setItem('continueNext', 'false');
            }
        }
    }

    handlePrevClick() {
        if (!this.communityUser) {
            const { Id, ...rest } = this.leaddata;
            const leadRecordChange = new CustomEvent('leadvaluechange', {
                detail: { ...rest },
            });

            this.dispatchEvent(leadRecordChange);
            this.changeprevscreen();
        }
    }

    fetchPicklist(objectName, fieldApi) {
        getPicklistValuesFromApex({ "objectApiName": objectName, "fieldApiName": fieldApi }).then((result) => {

            let getResultValue = result
            let filterOption = [];
            getResultValue.map((item) => {
                if (this.policyType && this.policyType.toLowerCase() == 'northbound' && item.value != 'Watercraft' && item.value != 'RV' && item.value != 'Driver License') {
                    filterOption.push(item);
                } else if (this.policyType && (this.policyType.toLowerCase() == 'automobile'
                    || this.policyType.toLowerCase() == 'rv'
                    || this.policyType.toLowerCase() == 'motorcycle/street legal atv')
                    && item.value != 'Watercraft') {
                    filterOption.push(item);
                }
            });
            // if(filterOption.length)
            this.vehicleTypeQuoteOptions = filterOption;

        }).catch((error)=>{
            this.generateLogs();    
        });
    }
    
    getDependentPicklistValues(objectName, controllingField, dependentField) {
        getDependentMapWithTranslations({ "objectApiName": objectName, "contrfieldApiName": controllingField, "depfieldApiName": dependentField }).then((result) => {

            let vehicleType = this.policyType;
            if (vehicleType == 'Automobile') {
                vehicleType = 'Car/Truck/Auto';
            } else if (vehicleType == 'Motorcycle') {
                vehicleType = 'Motorcycle/Street Legal ATV';
            }
            let storeResponse = result;
            let option = [];
            
            if (vehicleType != null && storeResponse && storeResponse[vehicleType.trim()] != null) {
                let relevantControllingField = storeResponse[vehicleType];
                for (const property in relevantControllingField) {
                    option.push({
                        'label': relevantControllingField[property],
                        'value': property
                    })
                }
            }

            this.vehicleTypeQuoteOptions = option;
        }).catch((error)=>{
            this.generateLogs();    
        });
    }

    getVehicleYears() {
        getYears().then((result) => {
            this.yearOption = result;
        }).catch(error => {
            console.log('error')
        });
        //    return this.yearOption; 
    }
    getVehicleMakes() {
        this.isLoadSpin = true;
        console.log('running get makes');
        console.log('running get makes '+this.vehicleDetail.Year__c);
        getMakes({ 'year': this.vehicleDetail.Year__c }).then((result) => {
            console.log(result);
            this.makeOptions = result;
            this.isLoadSpin = false;
            let makeOptionValue = Object.values(this.makeOptions);
            let existOption = false;
            let valueToset = this.vehicleDetail.Make__c;
            if(valueToset){
                for (var i = 0; i < this.makeOptions.length; i++) {
                    if (this.makeOptions[i]['value'].toUpperCase() === this.vehicleDetail.Make__c?.toUpperCase()) {
                        existOption = true;
                        valueToset = this.makeOptions[i]['value'];
                    }
                }
            }
            
            if (!existOption) {
                this.comboboxMakevalue = '<Manually Enter>';
                this.showManualMake = true;
                this.showManualModel = true;
                const startSelect = this.template.querySelector('.comboboxMake');
                    if (startSelect) {
                        startSelect.value = '<Manually Enter>';
                    }
            }else{
                console.log('inside existing option');
                const startSelect = this.template.querySelector('.comboboxMake');
                if (startSelect) {
                    startSelect.value = valueToset;
                    this.showManualMake = false;
                    this.showManualModel = false;
                }
            }
            this.disableMake = false;
        }).catch(error => {
            this.isLoadSpin = false;
            console.log('error : '+JSON.stringify(error));
        })
    }

    getVehicleModels() {
        console.log('running vehcile models');
        this.isLoadSpin = true;
        getModels({ 'year': this.vehicleDetail.Year__c, 'make': this.vehicleDetail.Make__c }).then((result) => {
            console.log(result);
            this.modelOptions = result;
            this.isLoadSpin = false;
            let existOption = false;
            let valueToset = this.vehicleDetail.Model__c; 
            if(valueToset){
                for (var i = 0; i < this.modelOptions.length; i++) {
                    if (this.modelOptions[i]['value'].toUpperCase() === this.vehicleDetail.Model__c.toUpperCase()) {
                        existOption = true;
                        valueToset = this.modelOptions[i]['value'];
                    }
                }
            }
                if (!existOption) {
                    this.comboBoxmodelValue = '<Manually Enter>';
                    this.showManualModel = true;
                    const startSelect = this.template.querySelector('.comboboxModel');
                    if (startSelect) {
                        startSelect.value = '<Manually Enter>';
                    }
                }else{
                    console.log('inside existing option');
                    const startSelect = this.template.querySelector('.comboboxModel');
                    if (startSelect) {
                        startSelect.value = valueToset;
                        this.showManualMake = false;
                        this.showManualModel = false;
                    }
                }


            this.disableModel = false;
            this.newSectionOpen = true;
        }).catch(error => {
            this.isLoadSpin = false;
            console.log('error : ', error);
        })
    }

    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}