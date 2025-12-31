// import { LightningElement, api, track } from 'lwc';
// export default class Nc_companyInformation extends LightningElement {
//     @api payload;
//     companyInfo = {
//         Company_Name__c: '',
//         Company_Phone__c: '',
//         Tax_ID__c: '',
//         Company_Country__c: '',
//         Company_Address__c: '',
//         Company_Zip__c: '',
//         Company_State__c: '',
//         Company_City__c: ''
//     };

//     connectedCallback() {
//         //If payload exists update with existing data
//         if (this.payload) {
//             const companydetailsdata = this.payload.find(item => item?.driverDetails?.companyInformation)?.driverDetails?.companyInformation;
//             // console.log('Loop Lienholder data', companydetailsdata);
//             if (companydetailsdata) {
//                 this.companyInfo = {
//                     ...this.companyInfo,
//                     ...companydetailsdata
//                 };
//                 // Fire custom event after updating companyInfo
//                 this.dispatchCompanyInfoUpdate();
//             }
//             // console.log('Lienholder Data', this.companyInfo);
//         }

//     }

//     isDebug = true;

//     countryOptions = [
//         { label: 'United States', value: 'United States' },
//         { label: 'Canada', value: 'Canada' },
//         { label: 'United Kingdom', value: 'United Kingdom' },
//         { label: 'Australia', value: 'Australia' },
//         { label: 'India', value: 'India' }
//     ];

//     // Handle input changes
//     // handleInputChange(event) {
//     //     const field = event.target.dataset.field;
//     //     this.companyInfo = { ...this.companyInfo, [field]: event.target.value };

//     //     if (name === 'Company Phone') {
//     //         // Solo guardamos el número limpio
//     //         const cleaned = value.replace(/\D+/g, '');
//     //         this.inputValues.rawPhone = cleaned;
//     //     } else {
//     //         this.inputValues[name] = value;
//     //     }
//     //     // Fire custom event after updating companyInfo
//     //     this.dispatchCompanyInfoUpdate();
//     // }
//     handleInputChange(event) {
//         const field = event.target.dataset.field;
//         const value = event.target.value;

//         if (field === 'Company_Phone__c') {
//             // Solo guardamos el número limpio
//             const cleaned = value.replace(/\D+/g, '');
//             this.inputValues = { ...this.inputValues, rawPhone: cleaned };
//         } else {
//             this.inputValues = { ...this.inputValues, [field]: value };
//         }
//         if (field === 'Tax_ID__c') {
//             value = value.toUpperCase();
//             if (value.length > 17) {
//                 value = value.substring(0, 17);
//             }
//             event.target.value = value;
//         }

//         // Actualizamos companyInfo
//         this.companyInfo = { ...this.companyInfo, [field]: value };

//         // Fire custom event after updating companyInfo
//         this.dispatchCompanyInfoUpdate();
//     }

//     get formattedPhone() {
//         const raw = this.inputValues?.rawPhone || '';
//         const match = raw.match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
//         return !match?.[2]
//             ? match?.[1] || ''
//             : `(${match[1]}) ${match[2]}` + (match[3] ? `-${match[3]}` : ``);
//     }

//     // Dispatch custom event with current company info
//     dispatchCompanyInfoUpdate() {
//         const companyInfoEvent = new CustomEvent('add', {
//             detail: {
//                 companyInformation: this.companyInfo
//             },

//         });
//         this.dispatchEvent(companyInfoEvent);
//     }

//     @api validate() {
//         return true;
//     }

//     @api validateInputs() {
//         const inputs = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group, lightning-checkbox-group');
//         let isValid = true;

//         inputs.forEach(input => {
//             if (!input.checkValidity()) {
//                 input.reportValidity();
//                 isValid = false;
//             }
//         });

//         return isValid;
//     }
// }

import { LightningElement, api, track } from 'lwc';

export default class Nc_companyInformation extends LightningElement {
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
        const field = event.target.dataset.field;
        let value = event.target.value;

        if (field === 'Company_Phone__c') {
            // 
            const cleaned = value.replace(/\D+/g, '');
            this.inputValues = { ...this.inputValues, rawPhone: cleaned };
        } else {
            this.inputValues = { ...this.inputValues, [field]: value };
        }
        
        // Convert Tax ID to uppercase
        if (field === 'Tax_ID__c') {
            value = value.toUpperCase();
            event.target.value = value;
        }

        // Actualizamos companyInfo
        this.companyInfo = { ...this.companyInfo, [field]: value };
        this.dispatchCompanyInfoUpdate();
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
        console.log('in the validateInputs');
        let isValid = true;

        try {
            const inputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
            
            inputs.forEach(input => {
                try {
                    if (input && input.reportValidity && typeof input.reportValidity === 'function') {
                        if (!input.reportValidity()) {
                            isValid = false;
                        }
                    }
                } catch (error) {
                    console.warn('Error validating input:', error);
                }
            });

            // Handle custom components safely
            const customComponents = this.template.querySelectorAll('c-address-recommendations');
            customComponents.forEach(component => {
                try {
                    if (component && component.validate && typeof component.validate === 'function') {
                        if (!component.validate()) {
                            isValid = false;
                        }
                    }
                } catch (error) {
                    console.warn('Error validating custom component:', error);
                }
            });

        } catch (error) {
            console.error('Error in validateInputs:', error);
            // Don't block form submission on validation errors
            return true;
        }

        return isValid;
    }
}