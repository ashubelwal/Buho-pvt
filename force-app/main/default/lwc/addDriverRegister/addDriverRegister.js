import { api, LightningElement } from 'lwc';
import getPicklistValues from '@salesforce/apex/Mex_ValidateFormData.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addressdata from '@salesforce/apex/Mex_existingCustomerFlowController.getAddressData';
import driver from '@salesforce/label/c.TR_Driver';
import firstname from '@salesforce/label/c.TR_First_Name';
import lastname from '@salesforce/label/c.TR_Last_Name';
import email from '@salesforce/label/c.TR_Email';
import phone from '@salesforce/label/c.TR_Phone';
import dateofbirth from '@salesforce/label/c.TR_Date_of_Birth';
import drivertype from '@salesforce/label/c.TR_Driver_Type';
import primaryinsured from '@salesforce/label/c.TR_Primary_insured';
import addressinfo from '@salesforce/label/c.TR_Address_Information';
import country from '@salesforce/label/c.TR_Country';
import postalcode from '@salesforce/label/c.TR_Postal_Code';
import states from '@salesforce/label/c.TR_States';
import state from '@salesforce/label/c.TR_State';
import city from '@salesforce/label/c.TR_City';
import address from '@salesforce/label/c.TR_Address';
import addressline from '@salesforce/label/c.TR_Address_Line_2';
import driverslicenseinfo from '@salesforce/label/c.TR_Driver_s_License_Information';
import licensecountry from '@salesforce/label/c.TR_License_Country';
import licensestate from '@salesforce/label/c.TR_License_State';
import mexicandriverslicenses from '@salesforce/label/c.TR_Mexican_drivers_licenses_are_not_covered_under_this_tourist_auto_insurance_po';
import licensenumber from '@salesforce/label/c.TR_License_Number';
import cancel from '@salesforce/label/c.TR_Cancel';
import updatedetail from '@salesforce/label/c.TR_Update_Detail';
import adddriver from '@salesforce/label/c.TR_Add_driver';
import addannew from '@salesforce/label/c.TR_Add_a_New_driver';
import AddressInformation from '@salesforce/label/c.TR_Address_Information';
import DriversLicenseInformation from '@salesforce/label/c.TR_Driver_s_License_Information';
import Mexicandriverslicenses from '@salesforce/label/c.TR_Mexican_drivers_licenses_are_not_covered_under_this_tourist_auto_insurance_po';
import EnterPostalCode from '@salesforce/label/c.TR_Enter_Postal_Code';
import EnterState from '@salesforce/label/c.TR_Enter_State';
import Stateprovince from '@salesforce/label/c.TR_State_province';
import EnterCity from '@salesforce/label/c.TR_Enter_City';
import Fieldsarenotfilledasrequired from '@salesforce/label/c.TR_Fields_are_not_filled_as_required';
import Thislicensenumberalreadyused from '@salesforce/label/c.TR_This_license_number_already_used';
import driverhassome from '@salesforce/label/c.TR_Driver_s_0_has_some_missing_info_kindly_add_them_to_proceed';

// import Owner from '@salesforce/schema/Account.Owner';
export default class AddDriverRegister extends LightningElement {
    label = {
        driver,firstname,lastname,email,phone,dateofbirth,Thislicensenumberalreadyused,EnterPostalCode,Fieldsarenotfilledasrequired,drivertype,primaryinsured,addressinfo,country,postalcode,states,state,city,address,addressline,driverslicenseinfo,licensecountry,licensestate,mexicandriverslicenses,licensenumber,cancel,updatedetail,adddriver,addannew,AddressInformation,DriversLicenseInformation,Mexicandriverslicenses,EnterState,Stateprovince,driverhassome,
        EnterCity,
    };
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
    @api driverList;
    @api editDriverData;
    @api leaddata;
    @api isEdit;
    @api isOwner;
    @api reviewVehicleData;
    @api policyType;
    driverNewObj = {};
    driveroptions;
    //isEdit = false;
    DOBDay = '';
    DOBMonth = '';
    DOBYear = '';
    months = [];
    days = [];
    years = [];
    DOBY = '';
    currentDate = new Date();
    currentYear = this.currentDate.getFullYear();
    startFrom = this.currentDate.getFullYear() - 90;
    currentMonth = this.currentDate.getMonth();
    currentDay = this.currentDate.getDate();
    otherCoutryAdd = false;
    otherCoutryLic = false;
    licenseCountryComboxValue;
    driverCountryComboxValue;

    connectedCallback() {
        console.log("---editDriverData---", this.editDriverData);
        console.log("---leaddata---", this.leaddata);
        console.log("---reviewVehicleData---", this.reviewVehicleData);
        if (this.editDriverData != null && this.editDriverData != undefined && this.editDriverData != {}) {
            console.log('comes in side the condition ', this.isOwner);
            if (this.isEdit == true) {
                this.isOwner = (this.editDriverData.Driver_Type__c == 'Owner' || this.editDriverData.Driver_Type__c == 'Owner & driver') ? false : true;

            }
            this.driverNewObj = this.editDriverData;


        } else {


        }
        console.log('---this is leaddata new object---', this.leaddata);
        if (this.leaddata != null && this.leaddata != undefined && this.driverList.length == 0) {
            console.log('---this is driver new object---', this.driverNewObj);
            this.driverNewObj = {
                ...this.driverNewObj, ['First_Name__c']: this.leaddata.FirstName,
                ['Last_Name__c']: this.leaddata.LastName,
                ['Email__c']: this.leaddata.Email,
                ['Phone__c']: this.leaddata.Phone
            }
        }
        this.fetchPicklist('Driver__c', 'Driver_Type__c');


        if (this.driverNewObj != undefined) {
            if (this.driverNewObj.Country__c != undefined && (this.driverNewObj.Country__c != 'Mexico' && this.driverNewObj.Country__c != 'United States' &&
                this.driverNewObj.Country__c != 'Canada')) {
                this.driverCountryComboxValue = 'Other'
                this.otherCoutryAdd = true;
            } else if (this.driverNewObj.Country__c == undefined || this.driverNewObj.Country__c == null || this.driverNewObj.Country__c == '') {
                if (this.policyType != 'Northbound') {
                    this.driverNewObj = { ...this.driverNewObj, ['Country__c']: 'United States' };
                } else {
                    this.driverNewObj = { ...this.driverNewObj, ['Country__c']: 'Mexico' };
                }
            }
            if (this.driverNewObj.License_Country__c != undefined && (this.driverNewObj.License_Country__c != 'Mexico' && this.driverNewObj.License_Country__c != 'United States' &&
                this.driverNewObj.License_Country__c != 'Canada')) {
                this.licenseCountryComboxValue = 'Other'
                this.otherCoutryLic = true;
            } else if (this.driverNewObj.License_Country__c == undefined || this.driverNewObj.License_Country__c == null || this.driverNewObj.License_Country__c == '') {
                if (this.policyType != 'Northbound') {
                    this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: 'United States' };
                } else {
                    this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: 'Mexico' };
                }
            }
        }
        
        if(this.postalCode != null && this.postalCode != '' && this.stateProvince != null && this.stateProvince != '' && this.driverCity != '' && this.driverCity != null){
            this.city = this.driverNewObj != undefined ? this.driverNewObj.City__c : '';
            this.cityId = this.city;
            this.postalCodeLookup = this.driverNewObj != undefined ? this.driverNewObj.Postal_Code__c : '';
            this.postalCodeId = this.postalCode;
            this.state = this.driverNewObj != undefined ? this.driverNewObj.State_Province__c : '';
            this.stateId = this.state;
        }
        //  this.fetchData();
    }

    get isNorthboundPolicy() {
        return this.policyType == 'Northbound';
    }

    get countryoptions() {
        if (this.policyType == 'Northbound') {
            return [
                { label: 'Mexico', value: 'Mexico' },
                { label: 'United States', value: 'United States' },
                { label: 'Canada', value: 'Canada' },
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
    get countryoptionsDriver() {
        return [
            { label: 'United States', value: 'United States' },
            { label: 'Canada', value: 'Canada' },
            { label: 'Mexico', value: 'Mexico' },
            { label: 'Other', value: 'Other' },
        ];
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

    get firstName() {
        return this.driverNewObj != undefined ? this.driverNewObj.First_Name__c : '';
    }
    get lastName() {
        return this.driverNewObj != undefined ? this.driverNewObj.Last_Name__c : '';
    }
    get driverEmail() {
        return this.driverNewObj != undefined ? this.driverNewObj.Email__c : '';
    }
    get driverPhone() {
        return this.driverNewObj != undefined ? this.formatNumber(this.driverNewObj.Phone__c) : '';
    }
    get ownerDriver() {
        return (this.driverNewObj.Driver_Type__c == 'Owner' || this.driverNewObj.Driver_Type__c == 'Owner & Driver');
    }
    get driverType() {
        console.log('---drivertype---', this.driverNewObj.Driver_Type__c);
        if (this.driverNewObj.Driver_Type__c == 'Owner' || this.driverNewObj.Driver_Type__c == 'Owner & Driver') {
            this.isOwner = true;
        } else {
            this.isOwner = false;
        }
        console.log('---isOwner---', this.isOwner);
        return this.driverNewObj != undefined ? this.driverNewObj.Driver_Type__c : '';
    }
    get primaryInsured() {

        return this.driverNewObj != undefined ? this.driverNewObj.Primary_insured__c : false;
    }
    get driverAddress() {
        return this.driverNewObj != undefined ? this.driverNewObj.Address__c : '';
    }
    get addressLine2() {
        return this.driverNewObj != undefined ? this.driverNewObj.Address_Line_2__c : '';
    }
    get driverCity() {
        return this.driverNewObj != undefined ? this.driverNewObj.City__c : '';
    }
    get driverCountry() {
        return this.driverNewObj != undefined ? this.driverNewObj.Country__c : '';
    }
    get driverCountryCombox() {
        return this.driverCountryComboxValue == 'Other' ? this.driverCountryComboxValue : (this.driverNewObj != undefined ? this.driverNewObj.Country__c : '');

    }
    get postalCode() {
        return this.driverNewObj != undefined ? this.driverNewObj.Postal_Code__c : '';
    }
    get stateProvince() {
        return this.driverNewObj != undefined ? this.driverNewObj.State_Province__c : '';
    }
    get licenseCountry() {
        return this.driverNewObj != undefined ? this.driverNewObj.License_Country__c : '';
    }
    get licenseCountryCombox() {
        console.log('---', this.licenseCountryComboxValue);
        return this.licenseCountryComboxValue == 'Other' ? this.licenseCountryComboxValue : (this.driverNewObj != undefined ? this.driverNewObj.License_Country__c : '');
    }
    get licenseState() {
        return this.driverNewObj != undefined ? this.driverNewObj.License_state__c : '';
    }
    get licenseNumber() {
        return this.driverNewObj != undefined ? this.driverNewObj.license_number__c : '';
    }

    get dayValue() {
        let dateDob = this.driverNewObj.Dob__c != undefined ? this.driverNewObj.Dob__c : '';
        let day;
        if (dateDob != '' & dateDob != undefined) {
            day = dateDob.split("-")[2];
            day = day.toString().padStart(2, "0");
            this.DOBDay = day;
        }
        console.log('this is day--', day);
        return day;
    }
    get monthValue() {
        let dateDob = this.driverNewObj.Dob__c != undefined ? this.driverNewObj.Dob__c : '';
        let month;
        if (dateDob != '' & dateDob != undefined) {
            month = dateDob.split("-")[1];
            month = month.toString().padStart(2, "0");
            this.DOBMonth = month;
        }
        console.log('this is month--', month);
        return month;
    }

    get yearValue() {
        let dateDob = this.driverNewObj.Dob__c != undefined ? this.driverNewObj.Dob__c : '';
        let Year;
        if (dateDob != '' & dateDob != undefined) {
            Year = dateDob.split("-")[0];
            Year = Year.toString();
            this.DOBYear = Year;
        }
        console.log('this is Year--', Year);
        return Year;
    }

    get stateOption() {
        if (this.driverNewObj.Country__c == 'Mexico') {
            return this.mexicoStateList;
        } else if (this.driverNewObj.Country__c == 'United States') {
            return this.unitedStatesList;
        } else if (this.driverNewObj.Country__c == 'Canada') {
            return this.canadaStateList;
        }
    }

    get stateOptionForLicense() {
        if (this.driverNewObj.License_Country__c == 'Mexico') {
            return this.mexicoStateList;
        } else if (this.driverNewObj.License_Country__c == 'United States') {
            return this.unitedStatesList;
        } else if (this.driverNewObj.License_Country__c == 'Canada') {
            return this.canadaStateList;
        }
    }

    formatNumber(phone) {
        let cleaned = ('' + phone).replace(/\D/g, '');
        let match = cleaned.match(/^(\d{3})(\d{3})(\d{4,7})$/);
        if (match) {
            return '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
    }

    fetchPicklist(objectName, fieldApi) {
        getPicklistValues({ "objectApiName": objectName, "fieldApiName": fieldApi }).then((result) => {
            console.log("this is fetchPicklistcall from apex result" + JSON.stringify(result));
            if (this.reviewVehicleData && this.reviewVehicleData.Is_the_vehicle_registered_to_a_business__c != undefined && this.reviewVehicleData.Is_the_vehicle_registered_to_a_business__c == true) {
                this.driveroptions = [{ 'label': this.label.driver, 'value': 'Driver' }];
                this.isOwner = false;
            } else {
                console.log('driveroptions == ',this.driveroptions);
                this.driveroptions = result;
            }
        });
    }
/*
    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value;

        if (/^\s/.test(value)) {
            value = '';
        }
        if (name == 'Primary_insured__c') {
            value = event.target.checked;
        }
        if (name == 'DOBYear') {
            this.DOBYear = value;
            console.log("DOB CHECK " + this.DOBYear);
        }
        if (name == 'DOBMonth') {
            this.DOBMonth = value;
            console.log("DOB CHECK " + this.DOBMonth);
        }
        if (name == 'DOBDay') {
            this.DOBDay = value;
            console.log("DOB CHECK " + this.DOBDay);
        }
        if (name == 'Phone__c' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            console.log('--phone value--', x);
            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            console.log('--phone value--', phonevalues);
            value = phonevalues;
        }

        if (name == 'Country__combox') {
            if (value != 'Other') {
                this.otherCoutryAdd = false;
                this.otherCoutryLic = false;
                this.driverCountryComboxValue = value
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: value };
                this.driverNewObj = { ...this.driverNewObj, ['Country__c']: value };

            } else {
                this.otherCoutryAdd = true;
                this.otherCoutryLic = true;
                this.driverCountryComboxValue = value;
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: '' };
                this.driverNewObj = { ...this.driverNewObj, ['Country__c']: '' };


            }

        }

        if (name == 'License_Country__combox') {
            if (value != 'Other') {
                this.otherCoutryLic = false;
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: value };
            } else {
                this.otherCoutryLic = true;
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: '' };
            }
        }
        if (name == 'State_Province__c') {
            this.driverNewObj = { ...this.driverNewObj, ['License_state__c']: value };
        } else if (name == 'Country__c') {
            this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: value };
        }

        console.log("onhandle change Driver name : " + name + ' value : ' + value);
        if (name != 'DOBDay' && name != 'DOBMonth' && name != 'DOBYear' && name != 'License_Country__combox' && name != 'Country__combox') {
            this.driverNewObj = { ...this.driverNewObj, [name]: value };
            console.log("driverNewObj : ", this.driverNewObj);

        }

    }
*/
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validateField');
        console.log('----', inputFields);
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    addNewDriver() {
        if (this.driverNewObj.Driver_Type__c == 'Owner' || this.driverNewObj.Driver_Type__c == 'Owner & Driver') {
            if (!this.driverNewObj?.Postal_Code__c || !this.driverNewObj?.State_Province__c || !this.driverNewObj?.City__c || !this.driverNewObj?.Country__c) {
                const errEvt = new ShowToastEvent({
                    message: this.label.driverhassome,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                return;
            }
        }
        let allvalid = this.isInputValid();
        console.log('---allvalid--', allvalid);
        if (allvalid) {
            const dublicateDriver = (this.driverList != undefined && this.driverList.length > 0) ? this.driverList.map((data) => {
                console.log('--data--', data);
                console.log('--this.driverNewObj--', this.driverNewObj);
                if (data.license_number__c == this.driverNewObj.license_number__c) {
                    return true;
                } else {
                    return false;
                }
            }) : [false];
            console.log('--dublicateDriver--', dublicateDriver);
            console.log('--dublicateDriver--', dublicateDriver.includes(true));
            if (!dublicateDriver.includes(true)) {
                this.DOBY = this.DOBYear + '-' + this.DOBMonth + '-' + this.DOBDay;
                this.driverNewObj = { ...this.driverNewObj, ['Dob__c']: this.DOBY }
                const newDrivers = new CustomEvent('newdriveradd', {
                    detail: this.driverNewObj,
                });
                console.log('addTowedunit---', this.driverNewObj);
                this.dispatchEvent(newDrivers);
            } else {
                const evt = new ShowToastEvent({
                    message: this.label.Thislicensenumberalreadyused,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        } else {
            const evt = new ShowToastEvent({
                message: this.label.Fieldsarenotfilledasrequired,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }
    updateDriver() {
        let allvalid = this.isInputValid();
        console.log("driver--", this.driverNewObj);
        if (allvalid) {

            this.DOBY = this.DOBYear + '-' + this.DOBMonth + '-' + this.DOBDay;
            this.driverNewObj = { ...this.driverNewObj, ['Dob__c']: this.DOBY }
            const newDrivers = new CustomEvent('newdriveradd', {
                detail: this.driverNewObj,
            });
            console.log('update addTowedunit---', this.driverNewObj);

            this.dispatchEvent(newDrivers);
        }
    }
    cancelEditSection() {
        const newDrivers = new CustomEvent('newdriveradd', {
            detail: 'cancelSection',
        });
        console.log('update addTowedunit---', this.driverNewObj);

        this.dispatchEvent(newDrivers);
    }

    handleChange(event) {
        console.log('updating latest');
        let name = event.target.name;
        let value = event.target.value;

        if (/^\s/.test(value)) {
            value = '';
        }
        if(name == 'City__c'){
            this.city = value;
        }
        if (name == 'Primary_insured__c') {
            value = event.target.checked;
        }
        if (name == 'DOBYear') {
            this.DOBYear = value;
            console.log("DOB CHECK " + this.DOBYear);
        }
        if (name == 'DOBMonth') {
            this.DOBMonth = value;
            console.log("DOB CHECK " + this.DOBMonth);
        }
        if (name == 'DOBDay') {
            this.DOBDay = value;
            console.log("DOB CHECK " + this.DOBDay);
        }
        if (name == 'Phone__c' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            console.log('--phone value--', x);
            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            console.log('--phone value--', phonevalues);
            value = phonevalues;
        }

        if (name == 'Country__combox') {
            if (value != 'Other') {
                this.otherCoutryAdd = false;
                this.otherCoutryLic = false;
                this.state = '';
                this.stateId = '';
                this.city = '';
                this.cityId = '';
                this.postalCodeLookup = '';
                this.postalCodeId = '';
                this.cityOptions = [];
                const callChild = this.template.querySelector('c-custom-lookup');
                /*if(callChild != null){
                    callChild.clearSelection();
                }*/
                
                this.driverCountryComboxValue = value
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: value };
                this.driverNewObj = { ...this.driverNewObj, ['Country__c']: value };

            } else {
                this.otherCoutryAdd = true;
                this.otherCoutryLic = true;
                this.driverCountryComboxValue = value;
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: '' };
                this.driverNewObj = { ...this.driverNewObj, ['Country__c']: '' };
            }
        this.driverNewObj = { ...this.driverNewObj, ['State_Province__c']: '' };
        this.driverNewObj = { ...this.driverNewObj, ['Postal_Code__c']: '' };
        this.driverNewObj = { ...this.driverNewObj, ['City__c']: '' };

        } 

        if (name == 'License_Country__combox') {
            if (value != 'Other') {
                this.otherCoutryLic = false;
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: value };
            } else {
                this.otherCoutryLic = true;
                this.licenseCountryComboxValue = value;
                this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: '' };
            }
        }
        if (name == 'State_Province__c') {
            this.driverNewObj = { ...this.driverNewObj, ['License_state__c']: value };
        } else if (name == 'Country__c') {
            this.driverNewObj = { ...this.driverNewObj, ['License_Country__c']: value };
        }

        console.log("onhandle change Driver name : " + name + ' value : ' + value);
        if (name != 'DOBDay' && name != 'DOBMonth' && name != 'DOBYear' && name != 'License_Country__combox' && name != 'Country__combox') {
            console.log('Is thgis before console displayed?');
            this.driverNewObj = { ...this.driverNewObj, [name]: value };
            console.log('Is this after console displayed?');
            console.log("driverNewObj : ", this.driverNewObj);

        }

    }

    postalCodeLookup;
    postalCodeId;
    city;
    state;
    //cityOptions;
    stateId;
    cityId;
    handleSearch(event){
              
        if(event.detail.searchedagainst == 'Postal_Code__c'){
            this.postalCodeId = event.detail.recordName;  
            if(this.postalCodeId != null && this.postalCodeId != '' && this.postalCodeId != undefined){
              this.autoPopulateFieldsValue('postalCodeId');
          }else{
              this.postalCodeLookup = null;
              this.postalCodeId = null;
              this.city = null;
              this.cityId = null;
          }
            
          }
          
          if(event.detail.searchedagainst == 'State__c'){
              this.stateId = event.detail.recordName;
              if(this.stateId != null && this.stateId != '' && this.stateId != undefined){
                  this.autoPopulateFieldsValue('stateId');
              }else{
                  this.postalCodeLookup = null;
                  this.postalCodeId = null;
                  this.state = null;
                  this.stateId = null;
                  this.city = null;
                  this.cityId = null;
              }
          }
          
          if(event.detail.searchedagainst == 'City__c'){
              this.cityId = event.detail.recordName;
              if(this.cityId != null && this.cityId != '' && this.cityId != undefined){
                  this.autoPopulateFieldsValue('cityId');
              }else{
                  this.city = null;
                  this.cityId = null;
              }
              
          }
     }
 
    autoPopulateFieldsValue(fieldValue){
        addressdata({ 
           country:this.driverCountry,
           postalCode:this.postalCodeId,
           stateCode:this.stateId,
           cityCode:this.cityId
           }).then(result => {

               console.log('*******result*******');
               console.log(result);
               console.log('*******result*******');

               if(fieldValue != 'postalCodeId' && fieldValue != 'stateId'){
                   this.postalCodeLookup = result[0].Postal_Code__c;
                   this.postalCodeId = result[0].Postal_Code__c;
                   this.state = result[0].State__c;
                   this.stateId = result[0].State__c; 
               }
               
               if(fieldValue != 'cityId' && fieldValue != 'stateId'){
                   this.city = result[0].City__c;
                   this.cityId =  result[0].City__c;
                   this.state = result[0].State__c;
                   this.stateId = result[0].State__c; 
               }
               if(fieldValue != 'cityId' && fieldValue != 'postalCodeId'){
                       //this.state = result[0].State__c;
                       //this.stateId = result[0].State__c; 
                       this.city = result[0].City__c;
                       this.cityId =  result[0].City__c;
                       this.postalCodeLookup = result[0].Postal_Code__c;
                       this.postalCodeId = result[0].Postal_Code__c;
                }

               var s = 'this.postalCode = > '+this.postalCodeLookup+'\n';
               s += 'this.postalCodeId = > '+this.postalCodeId+'\n';

               s += 'this.City = > '+this.city+'\n';
               s += 'this.cityId = > '+this.cityId+'\n';

               s += 'this.state = > '+this.state+'\n';
               s += 'this.stateId = > '+this.stateId+'\n';

               s += 'fieldValue= > '+fieldValue+'\n';

                    console.log(s);

                this.driverNewObj = { ...this.driverNewObj, ['State_Province__c']: this.stateId };
                this.driverNewObj = { ...this.driverNewObj, ['Postal_Code__c']: this.postalCodeId };
                this.driverNewObj = { ...this.driverNewObj, ['City__c']: this.cityId };
              console.log(s);
           }).catch(error => {
          
           });
    }

}