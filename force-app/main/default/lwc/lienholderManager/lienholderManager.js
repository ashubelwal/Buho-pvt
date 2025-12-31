import { LightningElement, track, api, wire } from 'lwc';
import getLienholderData from '@salesforce/apex/Mex_existingCustomerFlowController.getLienholderData';
export default class LienholderManager extends LightningElement {

    lienholderData = {};
    @api lienholderdetails;

    connectedCallback() {
        // set Existing lead data for lienholder.....

        this.lienholderData = {...this.lienholderData,
        ['Lienholder_name__c']: this.lienholderdetails.Lienholder_name__c,
        ['Lienholder_Street__c']: this.lienholderdetails.Lienholder_Street__c,
        ['Lienholder_State__c']: this.lienholderdetails.Lienholder_State__c,
        ['Lienholder_Postal_Code__c']: this.lienholderdetails.Lienholder_Postal_Code__c,
        ['Lienholder_Phone__c']: this.lienholderdetails.Lienholder_Phone__c,
        ['Lienholder_Country__c']: this.lienholderdetails.Lienholder_Country__c,
        ['Lienholder_Country__cmbx']: this.lienholderdetails.Lienholder_Country__c,
        ['Lienholder_City__c']: this.lienholderdetails.Lienholder_City__c};       
    }
    get addNewLienHolder() {
        return this.leinHolderValue.length > 0 ? true : false;
    }
    leinHolderValue = [];

    leinHolderhandleChange(e) {
        this.leinHolderValue = e.detail.value;
        console.log(this.leinHolderValue);
    }

    otherCountry = false;

    get countryoptions() {
        return [
            { label: 'United States', value: 'United States' },
            { label: 'Canada', value: 'Canada' },
            { label: 'Other', value: 'Other' },
        ];
    }

    get stateOption() {
        //log('call stateoptions companyInfomartion   '.this.companyInfo);
        if (this.lienholderData.Lienholder_Country__c == 'Mexico') {
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
        else if (this.lienholderData.Lienholder_Country__c == 'United States') {
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
        else if (this.lienholderData.Lienholder_Country__c == 'Canada') {
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


    handleSearch(event) {
        console.log(event);
        console.log('event detail', event.detail.recordId);
        console.log('event Name', event.detail.recordName);

        let Id = event.detail.recordId;
        if (Id != null) {
            getLienholderData({ recordId: Id })
                .then(result => {
                    console.log('Lienholder Selected==', result);
                    if (result[0] != null) {
                        if (result[0].Country__c != null) {
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_Country__c']: result[0].Country__c };
                        }
                        if (result[0].Name__c != null) {
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_name__c']: result[0].Name__c };
                        }
                        if (result[0].Phone__c != null) {
                            const x = result[0].Phone__c.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
                            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_Phone__c']: phonevalues };
                        }
                        if (result[0].Fax__c != null) {
                            const x = result[0].Fax__c.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
                            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_Fax__c']: phonevalues };
                        }
                        if (result[0].Street__c != null) {
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_Street__c']: result[0].Street__c };
                        }
                        if (result[0].Street2__c != null) {
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_Street_2__c']: result[0].Street2__c };
                        }
                        if (result[0].State__c != null) {
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_State__c']: result[0].State__c };
                        }
                        if (result[0].City__c != null) {
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_City__c']: result[0].City__c };
                        }
                        if (result[0].Zip__c != null) {
                            this.lienholderData = { ...this.lienholderData, ['Lienholder_Postal_Code__c']: result[0].Zip__c };
                        }
                        console.log("lienholderData values - ::::11" + JSON.stringify(this.lienholderData));

                        const lienholderDetailsEvent = new CustomEvent('lienholderdetails',{
                            detail : this.lienholderData
                        });
                        this.dispatchEvent(lienholderDetailsEvent);
                    }

                })
                .catch(error => {
                    console.log('Error in hadnle search==', error);
                    this.generateLogs();
                })
        } else {
            let countryValue = this.lienholderData.Lienholder_Country__c; 
           this.lienholderData = {};
            this.lienholderData = { ...this.lienholderData, ['Lienholder_Country__c']: countryValue };
            const lienholderDetailsEvent = new CustomEvent('lienholderdetails',{
                detail : this.lienholderData
            });
            this.dispatchEvent(lienholderDetailsEvent);
            console.log("lienholderData values - ::::22" + JSON.stringify(this.lienholderData));
        }
    }

    handleChange(event) {
        
        let name = event.target.name;
        let value = event.target.value;

        if (/^\s/.test(value)) {
            value = '';
        }
        this.lienholderData = { ...this.lienholderData, [name]: value };
        console.log('this.lienholderData11::::',this.lienholderData);
        if (name == 'Lienholder_Country__cmbx') {
            this.lienholderData = {};

            if (value != 'Other') {
                this.otherCountry = false;
                this.lienholderData = { ...this.lienholderData, ['Lienholder_Country__c']: value };
                this.lienholderData = { ...this.lienholderData, ['Lienholder_Country__cmbx']: value };
            } else {
                this.otherCountry = true;
                this.lienholderData = { ...this.lienholderData, ['Lienholder_Country__c']: '' };
            }
        }

        if (name == 'Lienholder_Phone__c' && value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            console.log('--phone value--', x);
            let phonevalues = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
            console.log('--phone value--', phonevalues);
            value = phonevalues;
            this.lienholderData = { ...this.lienholderData, ['Lienholder_Phone__c']: value };
        }
        
        if (name == 'Lienholder_Postal_Code__c') {
            value = value.toUpperCase();
            this.lienholderData = { ...this.lienholderData, ['Lienholder_Country__c']: value };
        }

        if (value != '' && name != 'Lienholder_Country__cmbx') {
            this.lienholderData = { ...this.lienholderData, [name]: value };
        }
        console.log("lienholderData values - :::" + JSON.stringify(this.lienholderData));

         if (name != 'Lienholder_Country__cmbx') {
            const lienholderDetailsEvent = new CustomEvent('lienholderdetails',{
                detail : this.lienholderData
            });
            this.dispatchEvent(lienholderDetailsEvent);
         }
         console.log('this.lienholderData ENDDD::::',this.lienholderData);
    }

    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }

}