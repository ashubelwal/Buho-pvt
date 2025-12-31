import { LightningElement, api, track } from 'lwc';
import addNewCardToCustomerProfile from '@salesforce/apex/SavedCardController.addNewCardTOCustomerProfile';
import updateCardToCustomerProfile from '@salesforce/apex/SavedCardController.updateCardToCustomerProfile';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddNewCardModal extends LightningElement {
    @api carddata = '';
    @api actiontype = ''
    @track formattedCreditCardNumber;
    pageTitle = 'Card Informations';    
    
    address;
    secondAddress = '';
    country;
    state;
    city;
    postalCode;
    holderName;
    fullName;
    cardNumber;
    experationMonth;
    experationYear;
    securityCode;    

    showStateInput = false;
    newCardLoader = false;

    months = [];
    years = [];
    currentDate = new Date();
    startMonthNumber = 1;        

    get formattedCreditCardNumberOrg() {       
        return this.formattedCreditCardNumber?.replace(/ /g, '');
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleCardOprations = (event) => {
        event.preventDefault();            

        let cardDetails = {
            'name': (this.holderName ? this.holderName : this.carddata?.billTo?.firstName + ' ' + this.carddata?.billTo?.lastName),
            'cardNumber': this.formattedCreditCardNumberOrg ? this.formattedCreditCardNumberOrg : this.carddata?.payment?.creditCard?.cardNumber,
            'month': this.experationMonth ? this.experationMonth : 'XX',
            'year': this.experationYear ? this.experationYear : 'XXXX',
            'code': this.securityCode ? this.securityCode : '' ,
            'address1': this.address ? this.address + ' ' + this.secondAddress : this.carddata?.billTo?.address,
            'city': this.city ? this.city : this.carddata?.billTo?.city,
            'state': this.state ? this.state : this.carddata?.billTo?.state,
            'country': this.country ? this.country : this.carddata?.billTo?.country,
            'zip': this.postalCode ? this.postalCode : this.carddata?.billTo?.zip
        }

        let isValid = this.isInputValid();

        if(this.securityCode == 0) {
            isValid = false;            
        }

        if (isValid == true) {
            this.newCardLoader = true;
            if (this.actiontype == 'addCard') {
                addNewCardToCustomerProfile({ newCreditCard: JSON.stringify(cardDetails) }).
                    then((result) => {
                        let res = JSON.parse(result);
                        console.log(res);
                        if (res.Status == "Error") {
                            const evt = new ShowToastEvent({ message: res.Message, variant: 'error', });
                            this.dispatchEvent(evt);
                        } else if (res.Status == "Ok") {
                            const evt = new ShowToastEvent({ message: "A new card is added!!! 😊", variant: 'success', });
                            this.dispatchEvent(evt);
                            this.dispatchEvent(new CustomEvent('newcard', { detail: result }));
                            this.dispatchEvent(new CustomEvent('closenewcardscreen', { detail: 'close' }));
                        } else {
                            const evt = new ShowToastEvent({ message: "We are facing some issue 😌", variant: 'error', });
                            this.dispatchEvent(evt);
                        }
                        this.newCardLoader = false;
                    }).
                    catch(error => {
                        console.log(error)
                        const evt = new ShowToastEvent({ message: "We are facing some issue 😌", variant: 'error', });
                        this.dispatchEvent(evt);
                        this.dispatchEvent(new CustomEvent('newcard', { detail: error }));
                        this.dispatchEvent(new CustomEvent('closenewcardscreen', { detail: 'close' }))
                        this.newCardLoader = false;
                    })
            } else if (this.actiontype == 'editCard') {
                console.log('111 | In the edit card type ')
                updateCardToCustomerProfile({ paymentProfileId: this.carddata.customerPaymentProfileId, cardDetails: JSON.stringify(cardDetails) }).
                    then((result) => {
                        let res = JSON.parse(result);
                        console.log(res)
                        if (res.messages.resultCode == 'Ok') {
                            const evt = new ShowToastEvent({ message: "Card is updated!!! 😊", variant: 'success', });
                            this.dispatchEvent(evt);
                            this.dispatchEvent(new CustomEvent('newcard', { detail: res }));
                            this.dispatchEvent(new CustomEvent('closenewcardscreen', { detail: 'close' }));
                            this.newCardLoader = false;
                        } else {
                            const evt = new ShowToastEvent({ message: "We are facing some issue😌", variant: 'error', });
                            this.dispatchEvent(evt);
                            this.newCardLoader = false;
                        }
                    }).
                    catch(error => {
                        console.log(error);
                        const evt = new ShowToastEvent({ message: "We are facing some issue😌", variant: 'error', });
                        this.dispatchEvent(evt);
                        this.newCardLoader = false;
                    })
            } else {
                this.newCardLoader = true;
                const evt = new ShowToastEvent({ message: "We are facing some issue😌", variant: 'error', });
                this.dispatchEvent(evt);
            }
        }

    }
    
    get MM() {        
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


    get countryoptions() {        
        return [
            { label: 'United States', value: 'United States' },
            { label: 'Canada', value: 'Canada' },
            { label: 'Mexico', value: 'Mexico' },
            { label: 'Other', value: 'Other' },
        ];
    }

    get stateOption() {

        if (this.country == 'Mexico') {
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
        else if (this.country == 'United States') {
            return [
                { value: "Alabama", label: "Alabama" },
                { value: "Alaska", label: "Alaska" },
                { value: "Arizona", label: "Arizona" },
                { value: "Arkansas", label: "Arkansas" },
                { value: "California", label: "California" },
                { value: "Colorado", label: "Colorado" },
                { value: "Connecticut", label: "Connecticut" },
                { value: "Delaware", label: "Delaware" },
                { value: "District of Columbia", label: "District of Columbia" },
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
        else if (this.country == 'Canada') {
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

    handleInput = (event) => {
        this[event.target.name] = event.target.value;
        console.log(this.carddata?.billTo?.country);
        if (this.country == 'Other' || this.carddata?.billTo?.country == 'Other') {
            this.showStateInput = true;
        } else {
            this.showStateInput = false;
        }

        if (event.target?.name == 'experationYear') {            
            if (event.target?.value == this.currentDate.getFullYear()) {
                this.startMonthNumber = this.currentDate.getMonth() + 1;
                this.months = [];
                this.template.querySelectorAll('lightning-combobox').forEach(each => {                    
                    if(each.name == 'experationMonth') {
                        each.value = undefined;
                    }
                });              
                this.MM;
            } else {
                this.months = [];
                this.startMonthNumber = 1;
                this.MM;
            }
        }        

        if (event.target.name == 'experationMonth' || event.target.name == 'experationYear') {
            if (event.target.value != '') {
                console.log(this.template.querySelector('[data-id="experationMonth"]'))
                this.template.querySelector('[data-id="experationMonth"]').required = true;
                this.template.querySelector('[data-id="experationMonth"]').className = 'validate';
                this.template.querySelector('[data-id="experationYear"]').required = true;
                this.template.querySelector('[data-id="experationYear"]').className = 'validate';
            } else {
                this.template.querySelector('[data-id="experationMonth"]').required = false;
                this.template.querySelector('[data-id="experationMonth"]').className = '';
                this.template.querySelector('[data-id="experationYear"]').required = false;
                this.template.querySelector('[data-id="experationYear"]').className = '';
            }
        }        
    }

    handleChange(event) {
        const rawNumber = event.target.value.replace(/ /g, '');
        const formattedNumber = this.formatCreditCardNumber(rawNumber);
        this.formattedCreditCardNumber = formattedNumber;  
        
        let cardNum = this.template.querySelector('[data-id="cardNumber"]')
        let expMonth = this.template.querySelector('[data-id="experationMonth"]')
        let expYear = this.template.querySelector('[data-id="experationYear"]')

        if(event.target.name == 'formattedCreditCardNumberOrg') {
            if(event.target.value != '' ) {                                
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

    handleCloseNewCardScreen = () => {
        this.dispatchEvent(new CustomEvent('closenewcardscreen', { detail: 'close' }))
    }

    connectedCallback() { 
        this.MM;  
        console.log(this.months);

        if (this.actiontype == 'addCard') {
            this.addActionType = true;
            this.pageTitle = 'Add a new card';
        } else {                    
            if(this.carddata?.billTo?.country == 'Other'){
                this.showStateInput = true;
            }else{
                this.showStateInput = false;
            }
            this.pageTitle = 'Update card informations';
            this.fullName = this.carddata?.billTo?.firstName + ' ' + this.carddata?.billTo?.lastName;            
            this.addActionType = false;

        }
    }
}