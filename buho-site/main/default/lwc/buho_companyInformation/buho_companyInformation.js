import { LightningElement, api, track } from 'lwc';

export default class Buho_companyInformation extends LightningElement {
    @api payload;
    @track flag = {
        isLoaded: false
    }
    
    @track companyInfo = {
        Company_Name__c: '',
        Company_Phone__c: '',
        Tax_ID__c: '',
        Company_Country__c: 'United States',
        Company_Address__c: '',
        Company_Zip__c: '',
        Company_State__c: '',
        Company_City__c: ''
    };

    @track inputValues = {
        rawPhone: ''
    };

    @track countryOptions = [
        { label: 'United States', value: 'United States' },
        { label: 'Canada', value: 'Canada' },
        { label: 'United Kingdom', value: 'United Kingdom' },
        { label: 'Australia', value: 'Australia' },
        { label: 'India', value: 'India' }
    ];

    connectedCallback() {
        try {
            if (this.payload) {
                console.log('OUTPUT : ', this.payload);
                const companydetailsdata = this.payload.find(item => item?.driverDetails?.companyInformation)?.driverDetails?.companyInformation;

                console.log('OUTPUT companydetailsdata: ', companydetailsdata);
                console.log('OUTPUT this.companyInfo: ', this.companyInfo);

                if (companydetailsdata) {
                    this.companyInfo = {
                        ...this.companyInfo,
                        ...companydetailsdata
                    };
                    if (companydetailsdata.Company_Phone__c) {
                        const cleaned = companydetailsdata.Company_Phone__c.replace(/\D+/g, '');
                        this.inputValues = { ...this.inputValues, rawPhone: cleaned };
                    }
                    this.dispatchCompanyInfoUpdate();
                }

                console.log('OUTPUT Company info : ', this.companyInfo);
                console.log('OUTPUT Company info2 : ', this.payload);
            }
        } catch (err) {
            console.log('OUTPUT : ', err.message);
        } finally {
            this.flag = {
                ...this.flag,
                isLoaded: true
            };
            console.log('isLoaded set to:', this.flag.isLoaded);
        }
    }

    handleInputChange(event) {
        // Handle buho_input events (event.detail) and native events (event.target)
        const field = event.detail?.name || event.target?.name || event.target?.dataset?.field;
        let value = event.detail?.value !== undefined ? event.detail.value : event.target?.value;

        console.log('CI handleInputChange:', { field, value });

        if (field === 'Company_Phone__c') {
            // Clean and format phone number
            const cleaned = value.replace(/\D+/g, '');
            this.inputValues = { ...this.inputValues, rawPhone: cleaned };
            value = this.formatPhone(cleaned);
        } else {
            this.inputValues = { ...this.inputValues, [field]: value };
        }
        
        // Convert Tax ID to uppercase
        if (field === 'Tax_ID__c') {
            value = value.toUpperCase();
        }

        // Update companyInfo
        this.companyInfo = { ...this.companyInfo, [field]: value };
        this.dispatchCompanyInfoUpdate();
    }
    
    formatPhone(raw) {
        const match = raw.match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
        return !match?.[2]
            ? match?.[1] || ''
            : `(${match[1]}) ${match[2]}` + (match[3] ? `-${match[3]}` : ``);
    }

    // Manejar dirección autocompletada
    handleCompanyAddress(event) {
        const addressData = JSON.parse(event.detail);
        this.companyInfo = {
            ...this.companyInfo,
            Company_Address__c: addressData.Address || addressData.address || 
                              (addressData.streetNumber && addressData.route ? 
                               `${addressData.streetNumber} ${addressData.route}` : ''),
            Company_City__c: addressData.City || addressData.city || addressData.locality || '',
            Company_State__c: addressData.State || addressData.state || addressData.administrative_area_level_1 || '',
            Company_Country__c: addressData.Country || addressData.country || 'United States',
            Company_Zip__c: addressData.PostalCode || addressData.postalCode || addressData.postal_code || ''
        };
        this.dispatchCompanyInfoUpdate();
    }

    get formattedPhone() {
        const raw = this.inputValues?.rawPhone || '';
        const match = raw.match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
        return !match?.[2]
            ? match?.[1] || ''
            : `(${match[1]}) ${match[2]}` + (match[3] ? `-${match[3]}` : ``);
    }

    // Dispatch custom event with current company info
    dispatchCompanyInfoUpdate() {
        const companyInfoEvent = new CustomEvent('add', {
            detail: {
                companyInformation: this.companyInfo
            },
        });
        this.dispatchEvent(companyInfoEvent);
    }

    @api validate() {
        return true;
    }

    // @api validateInputs() {
    //     console.log('in the validateInputs ');
    //     const inputs = this.template.querySelectorAll(
    //         'lightning-input, lightning-combobox, c-address-recommendations'
    //     );
    //     let isValid = true;

    //     inputs.forEach(input => {
    //         if (!input.reportValidity()) {
    //             isValid = false;
    //         }
    //     });

    //     return isValid;
    // }

    @api validateInputs() {
        console.log('CI validateInputs');
        let isValid = true;

        try {
            // Query buho_input components
            const buhoInputs = this.template.querySelectorAll('c-buho_input');
            
            buhoInputs.forEach(input => {
                try {
                    if (input && input.reportValidity && typeof input.reportValidity === 'function') {
                        if (!input.reportValidity()) {
                            isValid = false;
                        }
                    }
                } catch (error) {
                    console.warn('CI Error validating input:', error);
                }
            });

            // Validate required fields manually
            if (!this.companyInfo.Company_Name__c || !this.companyInfo.Company_Name__c.trim()) {
                console.warn('CI Company Name is required');
                isValid = false;
            }
            
            if (!this.companyInfo.Company_Phone__c || !this.companyInfo.Company_Phone__c.trim()) {
                console.warn('CI Company Phone is required');
                isValid = false;
            }
            
            if (!this.companyInfo.Company_Country__c) {
                console.warn('CI Company Country is required');
                isValid = false;
            }
            
            if (!this.companyInfo.Company_Address__c || !this.companyInfo.Company_Address__c.trim()) {
                console.warn('CI Company Address is required');
                isValid = false;
            }
            
            if (!this.companyInfo.Company_Zip__c || !this.companyInfo.Company_Zip__c.trim()) {
                console.warn('CI Company Zip is required');
                isValid = false;
            }
            
            if (!this.companyInfo.Company_State__c || !this.companyInfo.Company_State__c.trim()) {
                console.warn('CI Company State is required');
                isValid = false;
            }
            
            if (!this.companyInfo.Company_City__c || !this.companyInfo.Company_City__c.trim()) {
                console.warn('CI Company City is required');
                isValid = false;
            }

            // Handle custom components safely
            const customComponents = this.template.querySelectorAll('c-buho_address-recommendations');
            customComponents.forEach(component => {
                try {
                    if (component && component.validate && typeof component.validate === 'function') {
                        if (!component.validate()) {
                            isValid = false;
                        }
                    }
                } catch (error) {
                    console.warn('CI Error validating custom component:', error);
                }
            });

        } catch (error) {
            console.error('CI Error in validateInputs:', error);
            // Don't block form submission on validation errors
            return true;
        }

        console.log('CI validation result:', isValid);
        return isValid;
    }
}