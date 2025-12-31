import { LightningElement, api } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import updateQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateQuoteRecordData';
import addressdata from '@salesforce/apex/Mex_existingCustomerFlowController.getAddressData';
import Companyinformation from '@salesforce/label/c.TR_Company_Information';
import CompanyName from '@salesforce/label/c.TR_Company_Name';
import Phone from '@salesforce/label/c.TR_Phone';
import TaxID from '@salesforce/label/c.TR_TAX_ID';
import Country from '@salesforce/label/c.TR_Country';
import States from '@salesforce/label/c.TR_States';
import City from '@salesforce/label/c.TR_City';
import Address from '@salesforce/label/c.TR_Address';
import PostalCode from '@salesforce/label/c.TR_Postal_Code';
import ZIP from '@salesforce/label/c.TR_ZIP';
import Prev from '@salesforce/label/c.TR_Prev';
import Next from '@salesforce/label/c.TR_Next';
import EnterPostalCode from '@salesforce/label/c.TR_Enter_Postal_Code';
import EnterState from '@salesforce/label/c.TR_Enter_State';
import EnterCity from '@salesforce/label/c.TR_Enter_City';
import State from '@salesforce/label/c.TR_State';

export default class CompanyInformation extends LightningElement {
 label = {
       Companyinformation,CompanyName,Phone,Country,States,City,Address,PostalCode,ZIP,Prev,Next,TaxID,EnterPostalCode,EnterState,EnterCity,State,
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api policyType;

    @api oldpolicydata;
    @api editpolicydata;
    @api customerRecord;
    @api communityUser;
    loader = false;
    companyInfo = {};

    otherCountry = false;
    comboBoxcompanyCountryValue;
    spinner = false;

    async connectedCallback() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.editpolicydata != null) {
            this.companyInfo = { ...this.editpolicydata.vehicleData };
        } else {
            this.spinner = true;
            await this.fetchData();
        }
        if(this.compnayZip != null && this.compnayZip != '' && this.companyState != null && this.companyState != '' && this.companyCity != '' && this.companyCity != null){
            
            this.city = this.companyInfo != undefined ? this.companyInfo.Company_City__c : '';
            this.cityId = this.city;
            this.postalCode = this.companyInfo != undefined ? this.companyInfo.Company_Zip__c : '';
            this.postalCodeId = this.postalCode;
            this.state = this.companyInfo != undefined ? this.companyInfo.Company_State__c : '';
            this.stateId = this.state;
            console.log('old data==', this.city + this.postalCode+' '+this.state);
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
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

    get stateOption() {
        //log('call stateoptions companyInfomartion   '.this.companyInfo);
        if (this.companyInfo.Company_Country__c == 'Mexico') {
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
        else if (this.companyInfo.Company_Country__c == 'United States') {
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
        else if (this.companyInfo.Company_Country__c == 'Canada') {
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

    get yesNoOptions() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' },
        ];
    }
    get companyName() {
        return this.companyInfo != undefined ? this.companyInfo.Company_Name__c : '';
    }
    get companyPhone() {
        return this.companyInfo != undefined ? this.companyInfo.Company_Phone__c : '';
    }
    get companyTaxId() {
        return this.companyInfo != undefined ? this.companyInfo.Tax_ID__c : '';
    }
    get companyCountry() {
        return this.companyInfo != undefined ? this.companyInfo.Company_Country__c : '';
    }
    get companyCountryCombox() {
        return this.comboBoxcompanyCountryValue != 'Other' ? this.companyInfo.Company_Country__c : 'Other';
    }
    get companyState() {
        return this.companyInfo != undefined ? this.companyInfo.Company_State__c : '';
    }
    get companyCity() {
        return this.companyInfo != undefined ? this.companyInfo.Company_City__c : '';
    }
    get companyAddress() {
        return this.companyInfo != undefined ? this.companyInfo.Company_Address__c : '';
    }

    get compnayZip() {
        return this.companyInfo != undefined ? this.companyInfo.Company_Zip__c : '';
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
        let name = event.target.name;
        let value = event.target.value;
        console.log('---name--', name);

        if (/^\s/.test(value)) {
            value = '';
        }
        if (name == 'Is_the_vehicle_registered_to_a_business__c' || name == 'Is_Lienholder__c') {
            value = value == 'Yes' ? true : false;
        }

        if (name == 'Company_Country__cmbx') {
            if (value != 'Other') {
                this.otherCountry = false;
                this.comboBoxcompanyCountryValue = value;
                this.state = '';
                this.city = '';
                this.companyInfo = { ...this.companyInfo, ['Company_Country__c']: value };
            } else {
                this.otherCountry = true;
                this.comboBoxcompanyCountryValue = 'Other';
                this.companyInfo = { ...this.companyInfo, ['Company_Country__c']: '' };
            }
            this.companyInfo = { ...this.companyInfo, ['Company_Zip__c']: '' };
            this.companyInfo = { ...this.companyInfo, ['Company_City__c']: '' };
            this.companyInfo = { ...this.companyInfo, ['Company_State__c']: '' };
            this.state = null;
            this.stateId = null;
            this.city = null;
            this.cityId = null;
            this.postalCode = null;
            this.postalCodeId = null;
        }

        if ((value != null || value != '') && (name == 'Address__c' || name == 'Address_Line_2__c' || name == 'Country__c' || name == 'State_Province__c' || name == 'Postal_Code__c' || name == 'City__c')) {
            if(name == 'City__c'){
                this.city = value;
            }
            this.reviewVehicle = { ...this.reviewVehicle, ['BusinessAddress__c']: { ...this.reviewVehicle?.BusinessAddress__c, [name]: value } };
        } else if ((value != null || value != '') && name != 'Registered_Country__cmbx' && name != 'Country__combox') {
            this.reviewVehicle = { ...this.reviewVehicle, [name]: value };
            console.log("this is reviewVehicle", this.reviewVehicle);

        }
        console.log('---reviewVehicle---', this.reviewVehicle);
        //this.nextRenderComponent();

    if (name == 'Company_Phone__c' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            console.log('--phone value--', x);
            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            console.log('--phone value--', phonevalues);
            value = phonevalues;
        }
        if (name == 'Company_Zip__c') {
            value = value.toUpperCase();
        }

        if(name == 'Company_City__c'){
            this.city = value;
            this.cityId = value;
        }
        if(name == 'Company_State__c'){
            this.state = value;
            this.stateId = value;
        }
        if(name == 'Company_Zip__c'){
            this.postalCode = value;
            this.postalCodeId = value;
        }
        if (name != 'Company_Country__cmbx') {
            this.companyInfo = { ...this.companyInfo, [name]: value };
            if (this.communityUser != null && !this.communityUser) {
                this.leaddata = { ...this.leaddata, ['companyInfo']: this.companyInfo };
            }
            console.log("companyInfo values inside condition - " + JSON.stringify(this.companyInfo));
        }
        console.log("companyInfo values - " + JSON.stringify(this.companyInfo));
    }

    postalCode;
    postalCodeId;
    city;
    state;
    cityOptions;
    stateId;
    cityId;

    handleSearch(event){
        if(event.detail.searchedagainst == 'Postal_Code__c'){
            console.log('Call-1-postalCodeId');
            this.postalCodeId = event.detail.recordName;  
            if(this.postalCodeId != null && this.postalCodeId != '' && this.postalCodeId != undefined){
                this.autoPopulateFieldsValueRun('postalCodeId');
            }else{
                this.postalCode = null;
                this.postalCodeId = null;
                this.city = null;
                this.cityId = null;
                
            }
        }
            
        if(event.detail.searchedagainst == 'State__c'){
            this.stateId = event.detail.recordName;
            console.log('State==',this.stateId);
            if(this.stateId != null && this.stateId != '' && this.stateId != undefined){
                this.autoPopulateFieldsValueRun('stateId');
            }else{
                this.postalCode = null;
                this.postalCodeId = null;
                this.state = null;
                this.stateId = null;
                this.city = null;
                this.cityId = null;
            }
        }
            
        if(event.detail.searchedagainst == 'City__c'){
            console.log('Call-3-cityId');
            this.cityId = event.detail.recordName;
            if(this.cityId != null && this.cityId != '' && this.cityId != undefined){
                this.autoPopulateFieldsValueRun('cityId');
            }else{
                this.city = null;
                this.cityId = null;
            }
        }
    }

    autoPopulateFieldsValueRun(fieldValue){
        addressdata({ 
           country:this.companyCountry,
           postalCode:this.postalCodeId,
           stateCode:this.stateId,
           cityCode:this.cityId
           }).then(result => {

               console.log('*******result*******');
               console.log(result);
               console.log('*******result*******');

                if(fieldValue != 'postalCodeId' && fieldValue != 'stateId'){
                       this.state = result[0].State__c;
                       this.stateId = result[0].State__c;
                       this.postalCode = result[0].Postal_Code__c;
                       this.postalCodeId = result[0].Postal_Code__c;
                }
                   
                   if(fieldValue != 'cityId' && fieldValue != 'stateId'){
                       this.state = result[0].State__c;
                       this.stateId = result[0].State__c; 
                       this.city = result[0].City__c;
                       this.cityId =  result[0].City__c;
                       
                    }
 
                   if(fieldValue != 'cityId' && fieldValue != 'postalCodeId'){
                       this.city = result[0].City__c;
                       this.cityId =  result[0].City__c;
                       this.postalCode = result[0].Postal_Code__c;
                       this.postalCodeId = result[0].Postal_Code__c;
                    }


                var s = 'this.postalCode = > '+this.postalCode+'\n';
                s += 'this.postalCodeId = > '+this.postalCodeId+'\n';

                s += 'this.city = > '+this.city+'\n';
                s += 'this.cityId = > '+this.cityId+'\n';

                s += 'this.state = > '+this.state+'\n';
                s += 'this.stateId = > '+this.stateId+'\n';

                s += 'fieldValue= > '+fieldValue+'\n';

                console.log(s);

                this.companyInfo = { ...this.companyInfo, ['Company_City__c']: this.cityId };
                this.companyInfo = { ...this.companyInfo, ['Company_State__c']: this.stateId };
                this.companyInfo = { ...this.companyInfo, ['Company_Zip__c']: this.postalCodeId};

                console.log(this.companyInfo);


                }).catch(error => {
                    this.generateLogs();
            });
        }

    fetchData = async () => {
        if (this.leaddata?.Id != undefined && !this.communityUser) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Company_details__c" });
                console.log("---data fetch--", data);
                if (data.status == 'success') {
                    if (data.data[0].Company_details__c != undefined) {
                        let parseCompanyData = JSON.parse(data.data[0].Company_details__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;
                        console.log('OUTPUT parse data : ', parseCompanyData);
                        this.companyInfo = this.leaddata?.Policy_Type__c == prevPolicyType ? parseCompanyData : {};
                    }
                    if (this.companyInfo.Company_Country__c == 'Canada' ||
                        this.companyInfo.Company_Country__c == 'Mexico' ||
                        this.companyInfo.Company_Country__c == 'United States') {
                        this.comboBoxcompanyCountryValue = this.companyInfo.Company_Country__c;
                        this.otherCountry = false;
                    }else if(this.companyInfo.Company_Country__c == '' || this.companyInfo.Company_Country__c == null || this.companyInfo.Company_Country__c == undefined){
                        if(this.policyType != 'Northbound'){
                            this.companyInfo = {...this.companyInfo, ['Company_Country__c'] : 'United States'};
                          }else{
                              this.companyInfo = {...this.companyInfo, ['Company_Country__c'] : 'Mexico'};
                          }
                    } else {
                        this.comboBoxcompanyCountryValue = 'Other';
                        this.otherCountry = true;
                    }
                    this.spinner = false;
                    return data.status;
                } else {
                    this.spinner = false;
                    return 'error';
                }
            } catch (ex) {
                this.spinner = false;
                console.log('error : ', ex);
                this.generateLogs();
            }
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                this.companyInfo = { ...this.companyInfo, ...this.customerRecord?.vehicleData };
                this.policyType = this.customerRecord?.policyType;
                this.spinner = false;
                return 'success';
            }
        }
    }

    handleNextClick = async () => {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let allValid = this.isInputValid();
        console.log('-allValid--', allValid);
        if (allValid) {
            try {
                if (this.editpolicydata != null) {
                    // this.editPolicyData = { ...this.companyInfo };
                    this.editpolicydata = { ...this.editpolicydata, ['vehicleData']: { ...this.editpolicydata.vehicleData, ...this.companyInfo } }
                    const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                        detail: this.editpolicydata,
                    });

                    this.dispatchEvent(editPolicyChange);
                    this.changesnextscreen();
                } else {
                    console.log(JSON.stringify(this.companyInfo, null, 4));
                    this.template.querySelector('.buttonNext').classList.add('loading');
                    this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                    const data = await validateFormData({ "objData": JSON.stringify({ ['Company_details__c']: this.companyInfo }), "objName": 'companyInfo' });
                    console.log('--data validate--', data);
                    if (data.status == 'success') {
                        if (this.communityUser != null && this.communityUser) {
                            let {BusinessAddress__c, ...cobmineVecileCompanyData} = {...this.customerRecord?.vehicleData, ...this.companyInfo};
                            console.log('--cobmineVecileCompanyData--', cobmineVecileCompanyData);
                           
                            let companyInfoUpdate = await updateQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord }), "vehicleRecord": JSON.stringify(cobmineVecileCompanyData), "towedUnitRecord": '', "driversRecord": '' });
                                console.log('--companyInfoUpdate---', companyInfoUpdate);
                            if (companyInfoUpdate.status == 'success') {
                                this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...companyInfoUpdate.quoteData }, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...companyInfoUpdate.vehicleData } };

                                const customerRecordChange = new CustomEvent('customerecordchange', {
                                    detail: this.customerRecord,
                                });

                                this.dispatchEvent(customerRecordChange);
                            } else {
                                this.generateLogs();
                                this.template.querySelector('.buttonNext').classList.remove('loading');
                                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                            }
                        } else {
                            const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Company_details__c']: JSON.stringify(this.companyInfo), ['Id']: this.leaddata?.Id }) });
                            console.log(res);
                            if (res.status == 'Success') {
                                this.leaddata = { ...this.leaddata, ['companyInfo']: { ...this.companyInfo } }
                                const leadDataChange = new CustomEvent('leadvaluechange', {
                                    detail: this.leaddata,
                                });
                                this.dispatchEvent(leadDataChange);
                            } else {
                                // error handle...
                                this.generateLogs();
                                this.template.querySelector('.buttonNext').classList.remove('loading');
                                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                            }
                        }
                        this.changesnextscreen();
                    } else {
                        // error handle...
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
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
            console.log('---all field are not valid---');
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    handlePrevClick() {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        if (this.editpolicydata != null) {
            this.editpolicydata = { ...this.editpolicydata, ['vehicleData']: { ...this.editpolicydata.vehicleData, ...this.companyInfo } }
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
                console.log("Lead Data in prev button", this.leaddata);
    
                this.dispatchEvent(leadChange);
            }
        }
        this.changeprevscreen();
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}