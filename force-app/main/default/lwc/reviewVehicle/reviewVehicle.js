import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import updateQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateQuoteRecordData';
import addressdata from '@salesforce/apex/Mex_existingCustomerFlowController.getAddressData';
import Year from '@salesforce/label/c.TR_Year';
import Make from '@salesforce/label/c.TR_Make';
import Model from '@salesforce/label/c.TR_Model';
import Vehiclevalue from '@salesforce/label/c.TR_Vehicle_Value';
import VINNumber from '@salesforce/label/c.TR_VIN_Number';
import RegisteredCountry from '@salesforce/label/c.TR_Registered_Country';
import RegisteredStateProvince from '@salesforce/label/c.TR_Registered_State_Province';
import Isthevehicleregisteredtoabusiness from '@salesforce/label/c.TR_Is_the_vehicle_registered_to_a_business';
import Isvehicleleasedorfinanced from '@salesforce/label/c.TR_Is_vehicle_leased_or_financed';
import Isthisaccountcompanynamed from '@salesforce/label/c.TR_Is_this_account_company_named';
import BusinessAddressInformation from '@salesforce/label/c.TR_Business_Address_Information';
import Country from '@salesforce/label/c.TR_Country';
import PostalCode from '@salesforce/label/c.TR_Postal_Code';
import States from '@salesforce/label/c.TR_States';
import State from '@salesforce/label/c.TR_State';
import Cities from '@salesforce/label/c.TR_Cities';
import City from '@salesforce/label/c.TR_City';
import Address from '@salesforce/label/c.TR_Address';
import Prev from '@salesforce/label/c.TR_Prev';
import Next from '@salesforce/label/c.TR_Next';
import AddressLine2 from '@salesforce/label/c.TR_Address_Line_2';
import PlacasLicensePlate from '@salesforce/label/c.TR_Placas_License_Plate';
import Finalizevehicledetails from '@salesforce/label/c.TR_Finalize_Vehicle_Details';
import EnterPostalCode from '@salesforce/label/c.TR_Enter_Postal_Code';
import EnterState from '@salesforce/label/c.TR_Enter_State';
import EnterCity from '@salesforce/label/c.TR_Enter_City';
import yes from '@salesforce/label/c.TR_Yes';
import no from '@salesforce/label/c.TR_No';


export default class ReviewVehicle extends LightningElement {
    label = {
        Year, Make, Model, Vehiclevalue, VINNumber, RegisteredCountry, RegisteredStateProvince, Isthevehicleregisteredtoabusiness, Isvehicleleasedorfinanced,
        Isthisaccountcompanynamed, BusinessAddressInformation, PlacasLicensePlate, Country, EnterCity, EnterState, EnterPostalCode, PostalCode, States, State, Cities, City, Address, Prev, Next, AddressLine2, Finalizevehicledetails,
        yes, no
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api policyId;
    @api handleInsertData;
    @api leaddata;
    @api policyType;
    @api companyInfoRender = false;
    @api lienholderRender = false;
    @api reviewVehicle = {};

    @api oldpolicydata;
    @api editpolicydata;
    @api isRenewalPolicy;
    @api customerRecord;
    @api communityUser;

    comboBoxReisterCountryValue
    userCountryComboxValue;
    otherstate = false;
    otherCoutryAdd = false;
    spinner = false;

    async connectedCallback() {
        console.log('Insine connected CAllback', this.editpolicydata);
        console.log('Review vehicle Data', this.reviewVehicle);
        if (this.editpolicydata != null) {
            this.reviewVehicle = { ...this.editpolicydata.vehicleData };
            console.log('Inside if block', this.editpolicydata);
        } else {
            this.spinner = true;
            await this.fetchData();
        }

        if (this.reviewVehicle != undefined && this.reviewVehicle.BusinessAddress__c != undefined) {
            if (this.reviewVehicle.BusinessAddress__c.Country__c != undefined && (this.reviewVehicle.BusinessAddress__c.Country__c != 'Mexico' && this.reviewVehicle.BusinessAddress__c.Country__c != 'United States' &&
                this.reviewVehicle.BusinessAddress__c.Country__c != 'Canada')) {
                this.userCountryComboxValue = 'Other'
                this.otherCoutryAdd = true;
            } else if (this.reviewVehicle.BusinessAddress__c.Country__c == undefined || this.reviewVehicle.BusinessAddress__c.Country__c == '' || this.reviewVehicle.BusinessAddress__c.Country__c == null) {
                if (this.policyType != 'Northbound') {
                    this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle.BusinessAddress__c, ['Country__c']: 'United States' } };
                } else {
                    this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle.BusinessAddress__c, ['Country__c']: 'Mexico' } };
                }
            } else {
                this.userCountryComboxValue = this.reviewVehicle.BusinessAddress__c.Country__c;
            }
        }
        if (this.userPostalCode != null && this.userPostalCode != '' && this.userStateProvince != null && this.userStateProvince != '' && this.userCity != '' && this.userCity != null) {
            this.city = this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.City__c != undefined ? this.reviewVehicle.BusinessAddress__c.City__c : '') : '';
            this.cityId = this.city;
            this.postalCode = this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.Postal_Code__c != undefined ? this.reviewVehicle.BusinessAddress__c.Postal_Code__c : '') : '';
            this.postalCodeId = this.postalCode;
            this.state = this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.State_Province__c != undefined ? this.reviewVehicle.BusinessAddress__c.State_Province__c : '') : '';
            this.stateId = this.state;
        }

        this.nextRenderComponent();
        //code
    }
    get countryoptions() {
        if (this.policyType == 'Northbound') {
            return [
                { label: 'Mexico', value: 'Mexico' },
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
    get valueDisable() {
        return this.isRenewalPolicy == 'Yes' ? false : true;
    }
    get userStateOption() {
        if (this.reviewVehicle.BusinessAddress__c != undefined) {
            if (this.reviewVehicle.BusinessAddress__c.Country__c == 'Mexico') {
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
            else if (this.reviewVehicle.BusinessAddress__c.Country__c == 'United States') {
                return [
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
            }
            else if (this.reviewVehicle.BusinessAddress__c.Country__c == 'Canada') {
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
    }
    get stateOption() {
        if (this.reviewVehicle != undefined) {
            if (this.reviewVehicle.Registered_Country__c == 'Mexico') {
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
            else if (this.reviewVehicle.Registered_Country__c == 'United States') {
                return [
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
            }
            else if (this.reviewVehicle.Registered_Country__c == 'Canada') {
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
    }
    get YesNooptions() {
        return [
            { label: this.label.yes, value: 'Yes' },
            { label: this.label.no, value: 'No' },
        ];
    }
    get Year() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Year__c : '';
    }
    get Make() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Make__c : '';
    }
    get Model() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Model__c : '';
    }
    get VehicleValue() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Value__c : '';
    }
    get VINNumber() {
        return this.reviewVehicle != undefined && this.reviewVehicle.Vin__c != '' ? this.reviewVehicle.Vin__c : '';
    }
    get RegisteredCountry() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Registered_Country__c : '';
    }
    get comboBoxReisterCountry() {
        return this.comboBoxReisterCountryValue != 'Other' ? this.reviewVehicle.Registered_Country__c : 'Other';
    }
    get comboBoxUserCountry() {
        return this.userCountryComboxValue != 'Other' ? (this.reviewVehicle.BusinessAddress__c != undefined ? this.reviewVehicle.BusinessAddress__c.Country__c : '') : 'Other';
    }
    get RegisteredState() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Registered_State__c : '';
    }
    get LicensePlate() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Registered_Plate__c : '';
    }
    get vehicleRegistered() {
        return this.reviewVehicle.Is_the_vehicle_registered_to_a_business__c != undefined ? (this.reviewVehicle.Is_the_vehicle_registered_to_a_business__c == true ? 'Yes' : 'No') : '';
    }
    get vehicleInfo() {
        return this.reviewVehicle.Is_Lienholder__c != undefined ? (this.reviewVehicle.Is_Lienholder__c == true ? 'Yes' : 'No') : '';
    }
    get IsUserAddress() {
        return this.reviewVehicle.Is_Account_Company_Named__c != undefined ? (this.reviewVehicle.Is_Account_Company_Named__c == true ? 'Yes' : 'No') : 'No';
    }
    get showAdditionalAddressForm() {
        return !this.reviewVehicle.Is_Account_Company_Named__c && this.reviewVehicle.Is_the_vehicle_registered_to_a_business__c;
    }
    get userAddress() {
        return this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.Address__c != undefined ? this.reviewVehicle.BusinessAddress__c.Address__c : '') : '';
    }
    get userAddressLine2() {
        return this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.Address_Line_2__c != undefined ? this.reviewVehicle.BusinessAddress__c.Address_Line_2__c : '') : '';
    }
    get userCity() {
        return this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.City__c != undefined ? this.reviewVehicle.BusinessAddress__c.City__c : '') : '';
    }
    get userCountry() {
        return this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.Country__c != undefined ? this.reviewVehicle.BusinessAddress__c.Country__c : '') : '';
    }
    get userPostalCode() {
        return this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.Postal_Code__c != undefined ? this.reviewVehicle.BusinessAddress__c.Postal_Code__c : '') : '';
    }
    get userStateProvince() {
        return this.reviewVehicle.BusinessAddress__c != undefined ? (this.reviewVehicle.BusinessAddress__c.State_Province__c != undefined ? this.reviewVehicle.BusinessAddress__c.State_Province__c : '') : '';
    }

    nextRenderComponent() {
        if (this.reviewVehicle.Is_the_vehicle_registered_to_a_business__c == true) {
            this.companyInfoRender = true;
        }
        if (this.reviewVehicle.Is_Lienholder__c == true) {
            this.lienholderRender = true;
        }
    }
    /* commented for address change
        handleChange(event) {
            let name = event.target.name;
            let value = event.target.value;
            if (/^\s/.test(value)) {
                value = '';
            }
            if (name == 'Is_the_vehicle_registered_to_a_business__c' || name == 'Is_Lienholder__c' || name == 'Is_Account_Company_Named__c') {
                value = value == 'Yes' ? true : false;
            }
    
            if (name == 'Registered_Country__cmbx') {
                if (value != 'Other') {
                    this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: value };
                    this.otherstate = false;
                } else {
                    this.otherstate = true;
                    this.comboBoxReisterCountryValue = 'Other';
                    this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: '' };
                }
            }
    
            if (name == 'Country__combox') {
                if (value != 'Other') {
                    this.otherCoutryAdd = false;
                    this.userCountryComboxValue = value;
                    this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['Country__c']: value } };
    
                } else {
                    this.otherCoutryAdd = true;
                    this.userCountryComboxValue = value;
                    this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['Country__c']: '' } };
                }
    
            }
    
            if ((value != null || value != '') && (name == 'Address__c' || name == 'Address_Line_2__c' || name == 'Country__c' || name == 'State_Province__c' || name == 'Postal_Code__c' || name == 'City__c')) {
                this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, [name]: value } };
            } else if ((value != null || value != '') && name != 'Registered_Country__cmbx' && name != 'Country__combox') {
                this.reviewVehicle = { ...this.reviewVehicle, [name]: value };
    
            }
            this.nextRenderComponent();
        }
    */
    isInputValid = () => {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.Validation');

        let inputFields1 = this.template.querySelectorAll('c-custom-lookup');
        inputFields1.forEach(inputField => {
            inputField.reportValidity();
            isValid = inputField.isValid();
        });

        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    fetchData = async () => {
        if (this.leaddata != undefined && !this.communityUser) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Vehicle_details__c" });

                if (data.status == 'success') {
                    if (data.data[0].Vehicle_details__c != undefined) {
                        let parseReviewVehicleData = JSON.parse(data.data[0].Vehicle_details__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;

                        this.reviewVehicle = this.leaddata?.Policy_Type__c == prevPolicyType ? parseReviewVehicleData : {};

                        if (this.reviewVehicle.Registered_Country__c == 'United States' ||
                            this.reviewVehicle.Registered_Country__c == 'Mexico' || this.reviewVehicle.Registered_Country__c == 'Canada') {
                            this.comboBoxReisterCountryValue = this.reviewVehicle.Registered_Country__c;
                            this.otherstate = false;
                        } else if (this.reviewVehicle.Registered_Country__c == '' || this.reviewVehicle.Registered_Country__c == null || this.reviewVehicle.Registered_Country__c == undefined) {
                            if (this.policyType != 'Northbound') {
                                this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: 'United States' };
                            } else {
                                this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: 'Mexico' };
                            }
                        } else {
                            this.comboBoxReisterCountryValue = 'Other';
                            this.otherstate = true;
                        }

                        this.spinner = false;
                    }

                }
            } catch (ex) {
                this.generateLogs();
                this.spinner = false;
                console.log('error : ', ex);
            }
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                this.reviewVehicle = { ...this.customerRecord?.vehicleData, ...this.reviewVehicle };
                if (this.reviewVehicle.Registered_Country__c == 'United States' ||
                    this.reviewVehicle.Registered_Country__c == 'Mexico' || this.reviewVehicle.Registered_Country__c == 'Canada') {
                    this.comboBoxReisterCountryValue = this.reviewVehicle.Registered_Country__c;
                    this.otherstate = false;
                } else if (this.reviewVehicle.Registered_Country__c == '' || this.reviewVehicle.Registered_Country__c == null || this.reviewVehicle.Registered_Country__c == undefined) {
                    if (this.policyType != 'Northbound') {
                        this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: 'United States' };
                    } else {
                        this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: 'Mexico' };
                    }
                } else {
                    this.comboBoxReisterCountryValue = 'Other';
                    this.otherstate = true;
                }
                this.policyType = this.customerRecord?.policyType;
                this.spinner = false;
            }
        }
    }

    handleNextClick = async () => {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        // 23 Aug Update
        console.log('Review vehicle data in the review vehicle component', JSON.stringify(this.reviewVehicle));
        if (this.reviewVehicle.Registered_Country__c.toLowerCase() === 'mexico') {
            const errEvt = new ShowToastEvent({
                title: 'Mexican vehicles (Mexican License Plates) are not eligible for tourist automobile insurance.',
                variant: 'error',
                message: 'Contact a domestic Mexican agent or go directly to a Mexican insurance company to secure insurance on a Mexican-registered vehicle.'
            });
            this.dispatchEvent(errEvt);
            return;
        }

        let allValid = this.isInputValid();
        if (allValid) {
            if (!this.reviewVehicle.Is_the_vehicle_registered_to_a_business__c) this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: {}, ['Is_Account_Company_Named__c']: false };
            try {
                if (this.editpolicydata != null) {
                    console.log('AFter all valid', this.editpolicydata);
                    this.editpolicydata = { ...this.editpolicydata, ['vehicleData']: { ...this.editpolicydata.vehicleData, ...this.reviewVehicle }, ['quoteData']: { ...this.editpolicydata.quoteData, ['Vehicle_Value__c']: this.reviewVehicle.Value__c } };
                    console.log('After pdate new values', this.editpolicydata);
                    const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                        detail: this.editpolicydata,
                    });

                    // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_8');
                    // if (eventExist == undefined){
                    //     window.dataLayer.push({
                    //         'event': 'funnel_step',
                    //         'step_number': 'step_8',
                    //         'step_name': 'vehicle_details_2', 
                    //         'insurance_category': this.policyType
                    //         });
                    // }
                    this.dispatchEvent(editPolicyChange);

                    this.changesnextscreen();
                } else {
                    this.template.querySelector('.buttonNext').classList.add('loading');
                    this.template.querySelector('.buttonNext').setAttribute('disabled', true);

                    const data = await validateFormData({ "objData": JSON.stringify({ ['Review_vehicle__c']: this.reviewVehicle }), "objName": 'reviewVehicle' });
                    if (data.status == 'success') {
                        if (this.communityUser != null && this.communityUser) {
                            const updateVehicleResp = await updateQuoteRecordData({ 'quoteRecord': JSON.stringify(this.customerRecord?.quoteRecord), 'vehicleRecord': JSON.stringify({ ...this.customerRecord?.vehicleData, ...this.reviewVehicle }), 'towedUnitRecord': this.customerRecord?.towedUnitData != undefined && this.customerRecord?.towedUnitData?.length > 0 ? JSON.stringify([...this.customerRecord?.towedUnitData]) : '', 'driversRecord': '' })
                            if (updateVehicleResp.status == 'success') {
                                this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...updateVehicleResp.quoteData }, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...this.reviewVehicle }, ['towedUnitData']: updateVehicleResp?.towedUnitData != undefined && updateVehicleResp?.towedUnitData.length > 0 ? [...updateVehicleResp.towedUnitData] : [] };

                                const customerRecordChange = new CustomEvent('customerecordchange', {
                                    detail: this.customerRecord,
                                });

                                this.dispatchEvent(customerRecordChange);
                            } else {
                                this.generateLogs();
                            }
                        } else {
                            const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Vehicle_details__c']: JSON.stringify(this.reviewVehicle), ['Id']: this.leaddata?.Id }) });

                            if (res.status == 'Success') {
                                this.leaddata = { ...this.leaddata, ['companyInfoRender']: this.reviewVehicle?.Is_the_vehicle_registered_to_a_business__c, ['lienholderRender']: this.reviewVehicle?.Is_Lienholder__c, ['reviewVehicle']: this.reviewVehicle };
                                const leadChange = new CustomEvent('leadvaluechange', {
                                    detail: this.leaddata,
                                });
                                this.dispatchEvent(leadChange);

                                let eventExist = window.dataLayer.find((data) => data.step_number === 'step_8');
                                if (eventExist == undefined) {
                                    window.dataLayer.push({
                                        'event': 'funnel_step',
                                        'step_number': 'step_8',
                                        'step_name': 'vehicle_details_2',
                                        'insurance_category': this.policyType
                                    });
                                }
                            } else {
                                this.generateLogs();
                                this.template.querySelector('.buttonNext').classList.remove('loading');
                                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                                // error...
                            }
                        }

                        this.changesnextscreen();
                    } else {
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                        // error...
                    }
                }
            } catch (error) {
                this.generateLogs();
                console.log(error);
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                // handle errors if any...
            }
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    handlePrevClick() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.editpolicydata != null) {
            this.editpolicydata = { ...this.editpolicydata, ['vehicleData']: { ...this.editpolicydata.vehicleData, ...this.reviewVehicle } }

            const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                detail: this.editpolicydata,
            });
            this.dispatchEvent(editPolicyChange);
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                const customerRecordChange = new CustomEvent('customerecordchange', {
                    detail: this.customerRecord,
                });

                this.dispatchEvent(customerRecordChange);
            } else {
                const leadChange = new CustomEvent('leadvaluechange', {
                    detail: this.leaddata,
                });
                this.dispatchEvent(leadChange);
            }
        }
        this.changeprevscreen();
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    //Address changes

    state;
    city;
    postalCode;
    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value;

        if (/^\s/.test(value)) {
            value = '';
        }
        if (name === 'Vin__c') { 
            value = value.toUpperCase(); 
            if (value.length > 17) { 
                value = value.substring(0, 17);
            }
            event.target.value = value; 
        }
        if (name === 'Registered_Plate__c') {
            value = value.toUpperCase();
            event.target.value = value;
        }
        if (name == 'Is_the_vehicle_registered_to_a_business__c' || name == 'Is_Lienholder__c' || name == 'Is_Account_Company_Named__c') {
            value = value == 'Yes' ? true : false;
        }

        if (name == 'Registered_Country__cmbx') {
            if (value != 'Other') {
                this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: value };
                this.otherstate = false;
            } else {
                this.otherstate = true;
                this.comboBoxReisterCountryValue = 'Other';
                this.reviewVehicle = { ...this.reviewVehicle, ['Registered_Country__c']: '' };
            }
        }

        if (name == 'Country__combox') {
            if (value != 'Other') {
                this.otherCoutryAdd = false;
                this.userCountryComboxValue = value;
                this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['Country__c']: value } };

            } else {
                this.otherCoutryAdd = true;
                this.userCountryComboxValue = value;
                this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['Country__c']: '' } };
            }
            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['State_Province__c']: '' } };
            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['Postal_Code__c']: '' } };
            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['City__c']: '' } };

            this.state = null;
            this.stateId = null;
            this.city = null;
            this.cityId = null;
            this.postalCode = null;
            this.postalCodeId = null;
        }

        if ((value != null || value != '') && (name == 'Address__c' || name == 'Address_Line_2__c' || name == 'Country__c' || name == 'State_Province__c' || name == 'Postal_Code__c' || name == 'City__c')) {
            if (name == 'City__c') {
                this.city = value;
            }
            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, [name]: value } };
        } else if ((value != null || value != '') && name != 'Registered_Country__cmbx' && name != 'Country__combox') {
            this.reviewVehicle = { ...this.reviewVehicle, [name]: value };

        }
        this.nextRenderComponent();
    }
    postalCodeId;
    stateId;
    cityId;

    handleSearch(event) {
        if (event.detail.searchedagainst == 'Postal_Code__c') {
            this.postalCodeId = event.detail.recordName;
            if (this.postalCodeId != null && this.postalCodeId != '' && this.postalCodeId != undefined) {
                this.autoPopulateFieldsValue('postalCodeId');
            } else {
                this.postalCode = null;
                this.postalCodeId = null;
                this.city = null;
                this.cityId = null;
            }

        }


        if (event.detail.searchedagainst == 'State__c') {
            this.stateId = event.detail.recordName;
            if (this.stateId != null && this.stateId != '' && this.stateId != undefined) {
                this.autoPopulateFieldsValue('stateId');
            } else {
                this.postalCode = null;
                this.postalCodeId = null;
                this.state = null;
                this.stateId = null;
                this.city = null;
                this.cityId = null;
            }
        }

        if (event.detail.searchedagainst == 'City__c') {

            this.cityId = event.detail.recordName;
            if (this.cityId != null) {
                this.autoPopulateFieldsValue('cityId');
            } else {
                this.city = null;
                this.cityId = null;
            }

        }

    }

    autoPopulateFieldsValue(fieldValue) {
        addressdata({
            country: this.comboBoxUserCountry,
            postalCode: this.postalCodeId,
            stateCode: this.stateId,
            cityCode: this.cityId
        }).then(result => {
            if (fieldValue != 'postalCodeId' && fieldValue != 'stateId') {
                this.stateId = result[0].State__c;
                this.state = result[0].State__c;
                this.postalCode = result[0].Postal_Code__c;
                this.postalCodeId = result[0].Postal_Code__c;
            }

            if (fieldValue != 'cityId' && fieldValue != 'stateId') {
                this.city = result[0].City__c;
                this.cityId = result[0].City__c;
                this.stateId = result[0].State__c;
                this.state = result[0].State__c;
            }

            if (fieldValue != 'cityId' && fieldValue != 'postalCodeId') {
                this.city = result[0].City__c;
                this.cityId = result[0].City__c;
                this.postalCode = result[0].Postal_Code__c;
                this.postalCodeId = result[0].Postal_Code__c;
            }

            var s = 'this.postalCode = > ' + this.postalCode + '\n';
            s += 'this.postalCodeId = > ' + this.postalCodeId + '\n';

            s += 'this.city = > ' + this.city + '\n';
            s += 'this.cityId = > ' + this.cityId + '\n';

            s += 'this.state = > ' + this.state + '\n';
            s += 'this.stateId = > ' + this.stateId + '\n';

            s += 'fieldValue= > ' + fieldValue + '\n';


            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['Postal_Code__c']: this.postalCodeId } };
            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['State_Province__c']: this.stateId } };
            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, ['City__c']: this.cityId } };
            // alert(s);
        }).catch(error => {

        });
    }

    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}