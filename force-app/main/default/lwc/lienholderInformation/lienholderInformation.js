import { LightningElement, api } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import updateQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateQuoteRecordData';
import lienholderinfo from '@salesforce/label/c.TR_Lienholder_Information';
import name from '@salesforce/label/c.TR_Name';
import phone from '@salesforce/label/c.TR_Phone';
import fax from '@salesforce/label/c.TR_Fax';
import streetaddress from '@salesforce/label/c.TR_Street_Address';
import streetaddresss from '@salesforce/label/c.TR_Street_Address_2';
import country from '@salesforce/label/c.TR_Country';
import postalcode from '@salesforce/label/c.TR_Postal_Code';
import city from '@salesforce/label/c.TR_City';
import state from '@salesforce/label/c.TR_State';
import prev from '@salesforce/label/c.TR_Prev';
import next from '@salesforce/label/c.TR_Next';
import getLienholderData from '@salesforce/apex/Mex_existingCustomerFlowController.getLienholderData';	
import LienholderName from '@salesforce/label/c.TR_Lienholder_Name';
import SelectLienholder from '@salesforce/label/c.TR_Select_Lienholder';
import LienholderPostalCode from '@salesforce/label/c.TR_Lienholder_Postal_Code';
import LienholderState from '@salesforce/label/c.TR_Lienholder_State';
import LienholderCity from '@salesforce/label/c.TR_Lienholder_City';
import LienholderStreetAddress from '@salesforce/label/c.TR_Lienholder_Street_Address';
import LienholderStreetAddress2 from '@salesforce/label/c.TR_Lienholder_Street_Address_2';
import LienholderPhone from '@salesforce/label/c.TR_Lienholder_Phone';
import LienholderFax from '@salesforce/label/c.TR_Lienholder_Fax';


export default class LienholderInformation extends LightningElement {
    label = {
        lienholderinfo,name,phone,fax,streetaddress,city,state,streetaddresss,country,postalcode,next,prev,LienholderName,SelectLienholder,LienholderPostalCode,
        LienholderState,LienholderCity,LienholderStreetAddress,LienholderStreetAddress2,LienholderPhone,LienholderFax
    };
    lienholderDetails = {}; 
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api policyType;
    @api oldpolicydata;
    @api editpolicydata;

    @api customerRecord;
    @api communityUser;

    get addNewLienHolder(){
        return this.leinHolderValue.length > 0 ? true : false;
    }
        leinHolderValue = [];

    get leinHolderOPtion() {
        return [
            { label: 'Please check this mark if you are unable to find you Leinholder.', value: 'option1' },
            
        ];
    }
        leinHolderhandleChange(e) {
        this.leinHolderValue = e.detail.value;
        console.log(this.leinHolderValue);
    }

    lienholderName = '';
    lienholderPhone = '';
    lienholderFax = '';
    lienholderStreet = '';
    lienholderStreet2 = '';
    lienholderState = '';
    lienholderCity = '';
    lienholderPostalCode = '';
    otherCountry = false;
    comboBoxLineholderCountryValue;
    lienholderDetails = {};
    spinner = false;
    isGettingError = false;

    async connectedCallback() {
       try {
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
            if (this.editpolicydata != null) {
                this.lienholderDetails = { ...this.editpolicydata.vehicleData };
            } else {
                this.spinner = true;
                await this.fetchData();
            }

            this.getOldData();
        } catch (error) {
            console.error('Error in connectedCallback:', error.message);
            this.spinner = false;
        } finally {
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
        }
    }

    get countryoptions() {
        if (this.policyType == 'Northbound') {
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

    getOldData(){
        this.lienholderName = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_name__c : '';
        this.lienholderPhone = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Phone__c : '';
        this.lienholderFax = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Fax__c : '';
        this.lienholderStreet = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Street__c : '';
        this.lienholderStreet2 = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Street_2__c : '';
        this.lienholderState = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_State__c : '';
        this.lienholderCity = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_City__c : '';
        this.lienholderPostalCode = this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Postal_Code__c : '';
        
        if (this.lienholderPhone) {
            const x = this.lienholderPhone.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,7})/);
            let phoneValue = !x[2] ? x[1] : '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '');
            console.log('phoneValue', phoneValue);
            this.lienholderPhone = phoneValue;
        }
    }
    /*
    get lienholderName() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_name__c : '';
    }
    get lienholderPhone() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Phone__c : '';
    }
    get lienholderFax() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Fax__c : '';
    }
    get lienholderStreet() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Street__c : '';
    }
    get lienholderStreet2() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Street_2__c : '';
    }
    get lienholderState() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_State__c : '';
    }
    get lienholderCity() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_City__c : '';
    }

    get lienholderPostalCode() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Postal_Code__c : '';
    }
    */
    get lienholderCountry() {
        return this.lienholderDetails != undefined ? this.lienholderDetails.Lienholder_Country__c : '';
    }
    get lienholderCountryCombox() {
        return this.comboBoxLineholderCountryValue != 'Other' ? this.lienholderDetails.Lienholder_Country__c : 'Other';
    }
    

    get stateOption() {
        //log('call stateoptions companyInfomartion   '.this.companyInfo);
        if (this.lienholderDetails.Lienholder_Country__c == 'Mexico') {
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
        else if (this.lienholderDetails.Lienholder_Country__c == 'United States') {
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
        else if (this.lienholderDetails.Lienholder_Country__c == 'Canada') {
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

    isInputValid = () => {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.Validation');
        
         let inputFields1 = this.template.querySelectorAll('c-lookup');
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
        if (this.leaddata?.Id != undefined && !this.communityUser) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Lienholder_info__c" });
                console.log("---data fetch--", data);
                if (data.status == 'success') {
                    if (data.data[0].Lienholder_info__c != undefined) {
                        let parseLienholderData = JSON.parse(data.data[0].Lienholder_info__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;
                        console.log('OUTPUT parse data : ', parseLienholderData);
                        this.lienholderDetails = this.leaddata?.Policy_Type__c == prevPolicyType ? parseLienholderData : {};
                    }

                    if ((!this.lienholderDetails.Lienholder_Country__c || this.lienholderDetails.Lienholder_Country__c === '') && 
                        this.policyType !== 'Northbound') {
                        this.lienholderDetails = {
                            ...this.lienholderDetails,
                            ['Lienholder_Country__c']: 'United States'
                        };
                        this.comboBoxLineholderCountryValue = 'United States';
                    }

                    if (this.lienholderDetails.Lienholder_Country__c == 'Canada' ||
                        this.lienholderDetails.Lienholder_Country__c == 'Mexico' ||
                        this.lienholderDetails.Lienholder_Country__c == 'United States') {
                        this.comboBoxLineholderCountryValue = this.lienholderDetails.Lienholder_Country__c;
                        this.otherCountry = false;
                    }else if(this.lienholderDetails.Lienholder_Country__c == '' || this.lienholderDetails.Lienholder_Country__c == null || this.lienholderDetails.Lienholder_Country__c == undefined){
                        if(this.policyType != 'Northbound'){
                            this.lienholderDetails = {...this.lienholderDetails, ['Lienholder_Country__c'] : 'United States'};
                          }else{
                              this.lienholderDetails = {...this.lienholderDetails, ['Lienholder_Country__c'] : 'Mexico'};
                          }
                    } else {
                        this.comboBoxLineholderCountryValue = 'Other';
                        this.otherCountry = true
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
                return 'error';
            }
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                this.lienholderDetails = { ...this.lienholderDetails, ...this.customerRecord?.vehicleData };
                this.policyType = this.customerRecord?.policyType;

                 // Set default country if not set and not Northbound
                if (!this.lienholderDetails.Lienholder_Country__c ||  this.lienholderDetails.Lienholder_Country__c === '') {
                    this.lienholderDetails = {
                        ...this.lienholderDetails,
                        ['Lienholder_Country__c']: 'United States'
                    };
                    this.comboBoxLineholderCountryValue = 'United States';
                    this.otherCountry = false;
                }

                this.spinner = false;
                return 'success';
            }
        }
    }


    handleNextClick = async () => {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let allValid = this.isInputValid();
        if (allValid) {
            try {
                if (this.editpolicydata != null) {
                    // this.editpolicydata = { ...this.lienholderDetails };
                    console.log('In editpolicy data', this.editpolicydata);
                    this.editpolicydata = { ...this.editpolicydata, ['vehicleData']: { ...this.editpolicydata.vehicleData, ...this.lienholderDetails } }
                    const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                        detail: this.editpolicydata,
                    });

                    this.dispatchEvent(editPolicyChange);
                    this.changesnextscreen();
                } else {
                    this.template.querySelector('.buttonNext').classList.add('loading');
                    this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                    console.log(JSON.stringify(this.lienholderDetails, null, 4));
                    const data = await validateFormData({ "objData": JSON.stringify({ ['Lienholder_info__c']: this.lienholderDetails }), "objName": 'lienholderDetails' });
                    console.log('In first Else', data);
                    if (data.status == 'success') {
                        if (this.communityUser != null & this.communityUser) {
                            let lienHolderUpdate = await updateQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord }), "vehicleRecord": JSON.stringify({ ...this.customerRecord?.vehicleData, ...this.lienholderDetails }), "towedUnitRecord": '', "driversRecord": '' });
                            console.log('lienholderUpdate==', lienHolderUpdate);
                            if (lienHolderUpdate.status == 'success') {
                                this.customerRecord = {...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...lienHolderUpdate.quoteData }, ['vehicleData']: { ...this.customerRecord?.vehicleData, ...lienHolderUpdate.vehicleData } };
                                console.log('customerRecord==', this.customerRecord);
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
                            const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Lienholder_info__c']: JSON.stringify(this.lienholderDetails), ['Id']: this.leaddata?.Id }) });
                            if (res.status == 'Success') {
                                this.leaddata = { ...this.leaddata, ['lienholderDetails']: { ...this.lienholderDetails } };
                                const leadDataChange = new CustomEvent('leadvaluechange', {
                                    detail: this.leaddata,
                                });
                                this.dispatchEvent(leadDataChange);
                            } else {
                                this.generateLogs();
                                this.template.querySelector('.buttonNext').classList.remove('loading');
                                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                                //error...
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
            this.editpolicydata = { ...this.editpolicydata, ['vehicleData']: { ...this.editpolicydata.vehicleData, ...this.lienholderDetails } }
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

    handleSearch(event){
        console.log(event);
        console.log('event detail',event.detail.recordId);
        console.log('event Name',event.detail.recordName);
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        let Id = event.detail.recordId;
        if(Id != null){
            getLienholderData({recordId : Id})
            .then(result =>{
                console.log('Lienholder Selected==', result);
                if(result[0] != null){
                    if(result[0].Country__c != null){
                        this.comboBoxLineholderCountryValue = result[0].Country__c;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Country__c']: result[0].Country__c };
                    }
                    if(result[0].Name__c != null){
                        this.lienholderName =result[0].Name__c;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_name__c']: result[0].Name__c };
                    }
                    if(result[0].Phone__c != null){
                        const x = result[0].Phone__c.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
                        let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
                        this.lienholderPhone = phonevalues;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Phone__c']: this.lienholderPhone };
                    }
                    if(result[0].Fax__c != null){
                        const x = result[0].Fax__c.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
                        let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
                        this.lienholderFax=phonevalues;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Fax__c']: this.lienholderFax };
                    }
                    if(result[0].Street__c != null){
                        this.lienholderStreet=result[0].Street__c;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Street__c']: result[0].Street__c };
                    }
                    if(result[0].Street2__c != null){
                        this.lienholderStreet2=result[0].Street2__c;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Street_2__c']: result[0].Street2__c };
                    }
                    if(result[0].State__c != null){
                        this.lienholderState=result[0].State__c;
                        console.log('state==',this.lienholderState);
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_State__c']: result[0].State__c };
                    }
                    if(result[0].City__c != null){
                        this.lienholderCity=result[0].City__c;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_City__c']: result[0].City__c };
                    }
                    if(result[0].Zip__c != null){
                        this.lienholderPostalCode =result[0].Zip__c;
                        this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Postal_Code__c']: result[0].Zip__c };
                    }
                    console.log("lienholderDetails values - " + JSON.stringify(this.lienholderDetails));
                }
                
            })
            .catch(error=>{
                console.log('Error in hadnle search==', error);
                this.generateLogs();
            })
        }else{
            this.lienholderName='';
            this.lienholderPhone='';
            this.lienholderFax='';
            this.lienholderStreet='';
            this.lienholderStreet2='';
            this.lienholderState='';
            this.lienholderCity='';
            this.lienholderPostalCode='';
            console.log("lienholderDetails values - " + JSON.stringify(this.lienholderDetails));
        }
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }

    handleChange(event) {

        let name = event.target.name;
        let value = event.target.value;

        if (/^\s/.test(value)) {
            value = '';
        }

        if (name == 'Lienholder_Country__cmbx') {
            this.lienholderName='';
            this.lienholderPhone='';
            this.lienholderFax='';
            this.lienholderStreet='';
            this.lienholderStreet2='';
            this.lienholderState='';
            this.lienholderCity='';
            this.lienholderPostalCode='';
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Country__c']: ''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_name__c']: ''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Phone__c']: ''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Fax__c']: ''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Street__c']: ''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Street_2__c']:''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_State__c']: ''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_City__c']: ''};
            this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Postal_Code__c']: '' };
                    
            if (value != 'Other') {
                this.otherCountry = false;
                this.comboBoxLineholderCountryValue = value;
                this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Country__c']: value };
            } else {
                this.otherCountry = true;
                this.comboBoxLineholderCountryValue = 'other';
                this.lienholderDetails = { ...this.lienholderDetails, ['Lienholder_Country__c']: '' };
            }
        }

        if (name == 'Lienholder_Phone__c' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            console.log('--phone value--', x);
            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            console.log('--phone value--', phonevalues);
            value = phonevalues;
            this.lienholderPhone = value;
        }
        if (name == 'Lienholder_Fax__c' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            console.log('--phone value--', x);
            let faxvalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            console.log('--fax value--', faxvalues);
            value = faxvalues;
            this.lienholderFax = value;
        }
        if (name == 'Lienholder_Postal_Code__c') {
            value = value.toUpperCase();
            this.lienholderPostalCode = value;
        }
        if (value != '' && name != 'Lienholder_Country__cmbx') {
            this.lienholderDetails = { ...this.lienholderDetails, [name]: value };
            if (this.communityUser != null && !this.communityUser) {
                this.leaddata = { ...this.leaddata, ['lienholderDetails']: this.lienholderDetails };
            }
        }
        console.log("lienholderDetails values - " + JSON.stringify(this.lienholderDetails));
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}