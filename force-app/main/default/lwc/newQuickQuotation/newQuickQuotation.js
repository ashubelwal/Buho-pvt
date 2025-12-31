import { LightningElement, api } from 'lwc';
// import image from '@salesforce/resourceUrl/mexinsurance_assets';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/Mex_existingCustomerFlowController.checkCommunityUserAndFetchDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import StyleCSS from '@salesforce/resourceUrl/mexinsurance_assets';
import { NavigationMixin } from 'lightning/navigation';
import whatkindof from '@salesforce/label/c.TR_What_kind_of_insurance_do_you_want_us_to_quote';
import touristauto from '@salesforce/label/c.TR_Tourist_Auto_Insurance_for_Mexico';
import automobile from '@salesforce/label/c.TR_Automobile';
import RV from '@salesforce/label/c.TR_RV';
import motorcycle from '@salesforce/label/c.TR_Motorcycle_ATV';
import othermexinsurance from '@salesforce/label/c.TR_Other_Mexican_Insurance';
import northboundinsurance from '@salesforce/label/c.TR_Northbound_Insurance_for_Mexican_Vehicles';
import privateresidence from '@salesforce/label/c.TR_Private_Residence_Home_or_Condo_in_Mexico';
import watercraftinmex from '@salesforce/label/c.TR_Watercraft_in_Mexico';
import next from '@salesforce/label/c.TR_Next';
import withTowedUnit from '@salesforce/label/c.TR_with_Towed_Unit';
import PleaseSelectAnyOneOption from '@salesforce/label/c.TR_Please_Select_Any_One_Option';


export default class QuickQuotation extends NavigationMixin(LightningElement) {
     label = {
        whatkindof,touristauto,automobile,RV,motorcycle,PleaseSelectAnyOneOption,othermexinsurance,northboundinsurance,privateresidence,watercraftinmex,next,withTowedUnit,
    };

    idName = '';
    @api insured = '';
    isInsuranceScreen = true;
    isComponentRendered = false;
    insuretype = true;
    insurancelocation = false;
    screenName = 'insuretype';
    @api policyType = '';
    southboundFlow = false;
    northboundFlow = false;
    watercraftFlow = false;
    @api isCommunityUser = false;
    @api vehicleData;
    @api watercraftData;
    @api DriverData;
    @api towedUnitData;
    @api Is_Towing__c;
    showNorthbound = false;
    quote = {};

    _title = 'Error';
    message = this.label.PleaseSelectAnyOneOption;
    variant = 'error';

    // imagetyre = image + '/images/tyre@2x.png';
    // imagehouse = image + '/images/house@2x.png';
    // imageboat = image + '/images/boat@2x.png';

    // canadaimage = image + '/images/map-us-canada@2x.png';
    // mexicoimage = image + '/images/map-mexico@2x.png';

    async connectedCallback() {
        let queryParam = window.location.pathname.split('/')[2];

        const data = await checkCommunityUserAndFetchDetails();
        const parsedData = JSON.parse(data);
        
        let getlabel = document.querySelector("label[id='isNorthbound']");
        
        if (parsedData.status == 'success' && parsedData.userType == true) {
            this.isCommunityUser = parsedData.userType;
            this.vehicleData = parsedData.vehicles && parsedData.vehicles.length > 0 ? parsedData.vehicles : [];
            this.watercraftData = parsedData.watercrafts && parsedData.watercrafts.length > 0 ? parsedData.watercrafts : [];
            this.DriverData = parsedData.drivers && parsedData.drivers.length > 0 ? parsedData.drivers : [];
            this.towedUnitData = parsedData.towedUnits && parsedData.towedUnits.length > 0 ? parsedData.towedUnits : [];
        } else if (parsedData.status == 'success' && parsedData.userType == false) {
            this.isCommunityUser = parsedData.userType;
            this.vehicleData = [];
            this.DriverData = [];
            this.towedUnitData = [];
        }

        if (queryParam == 'rv' || queryParam == 'automobile' || queryParam == 'motorcycle'  || queryParam == 'watercraft' || queryParam == 'automobiletowed') {
            if (queryParam == 'rv') {
                this.idName = 'RV';
                this.quote['insured'] = 'RV';
            } else if (queryParam == 'automobile') {
                this.idName = 'Automobile';
                this.quote['insured'] = 'Automobile';
            } else if (queryParam == 'motorcycle') {
                this.idName = 'Motorcycle/Street Legal ATV'
                this.quote['insured'] = 'Motorcycle/Street Legal ATV';
            } else if (queryParam == 'watercraft') {
                this.idName = 'Watercraft';
                this.quote['insured'] = 'Watercraft';
            } else if ('northbound') {
                this.idName = 'Northbound';
                this.quote['insured'] = 'Northbound';
            } else if (queryParam == 'automobiletowed') {
                this.idName = 'AutomobileTowed';
                this.quote['insured'] = 'AutomobileTowed';
            } else if (queryParam == 'rvtowed') {
                this.idName = 'RVTowed';
                this.quote['insured'] = 'RVTowed';
            }
            this.handleNextClick();
        }
    }

    get isAutomobile() {
        
        //let clickOption = this.template.querySelector(`[data-id="${clicksection}"]`);
        return this.idName == 'Automobile';
    }
    get isAutomobileTowed() {
        return this.idName == 'AutomobileTowed';
    }
    get isMotorcycle() {
        return this.idName == 'Motorcycle/Street Legal ATV';
    }
    get isRV() {
        return this.idName == 'RV';
    }
    get isRVTowed() {
        return this.idName == 'RVTowed';
    }
    get isNorthbound() {
        // let clickOption = this.template.querySelector(`[data-id="isNorthbound"]`);
        // if(this.idName == 'Northbound'){
            
        //     clickOption.className += " insuranceTypeSelected";
        // }else{
        //     clickOption.classList.remove("insuranceTypeSelected");
        // }
        return this.idName == 'Northbound';
    }
    get isHomeowner() {
        return this.idName == 'Homeowner';
    }
    get isWatercraft() {
        return this.idName == 'Watercraft';
    }

    handleNextClick() {
        console.log('handleNextClick ');
        // this.policyType = 'Automobile';
        if (this.idName != null && this.idName != '' && this.idName != undefined) {
            if(!this.isCommunityUser){
                let eventExist = window.dataLayer.find((data) => data.step_number === 'step_1');
                if (eventExist == undefined){
                    window.dataLayer.push({
                        'event': 'funnel_step',
                        'step_number': 'step_1',
                        'step_name': 'category_selection', 
                        'insurance_category': this.quote.insured
                    });
                }
            }
            
            if (this.quote.insured == 'RV' || this.quote.insured == 'Automobile' || this.quote.insured == 'Motorcycle/Street Legal ATV') {
                this.southboundFlow = true;
                this.northboundFlow = false;
                this.watercraftFlow = false;
                // this.Is_Towing__c = false;
                this.policyType = this.quote.insured;
            } else if (this.quote.insured == 'Northbound') {
                this.northboundFlow = true;
                this.watercraftFlow = false;
                this.southboundFlow = false;
                this.policyType = this.quote.insured;
            } else if (this.quote.insured == 'Watercraft') {
                this.watercraftFlow = true;
                this.southboundFlow = false;
                this.northboundFlow = false;
                this.Is_Towing__c = false;
                this.policyType = this.quote.insured;
            } else if (this.quote.insured == 'AutomobileTowed') {
                this.southboundFlow = true;
                this.watercraftFlow = false;
                this.northboundFlow = false;
                this.policyType = 'Automobile';
                this.Is_Towing__c = true;
            } else if (this.quote.insured == 'RVTowed') {
                this.southboundFlow = true;
                this.watercraftFlow = false;
                this.northboundFlow = false;
                this.policyType = 'RV';
                this.Is_Towing__c = true;
            } else if (this.quote.insured == 'Homeowner') {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: window.location.origin + '/s/quick-home',
                    },
                })
            }
            this.isInsuranceScreen = false;
        } else {
            const evt = new ShowToastEvent({
                message: this.label.PleaseSelectAnyOneOption,
                variant: this.variant,
            });
            this.dispatchEvent(evt);
        }
    }

    renderedCallback() {
        
        if (!this.isComponentRendered) {
            Promise.all([
                loadStyle(this, StyleCSS + '/style.css')
            ]).then(() => {
                this.isComponentRendered = true;
            }).catch(error => {
                this.isComponentRendered = false;
            });
        }
    }

      handleChange(event) {
        const allRadioButtons = this.template.querySelectorAll('input[name="insured"]');
        let parentELementclass;
        let grandParent;
        for(let i = 0; i< allRadioButtons.length; i++){
            
            if(allRadioButtons[i].checked == true){
                parentELementclass = allRadioButtons[i].parentElement;
                grandParent = parentELementclass.parentElement;
                grandParent = grandParent.parentElement;
                grandParent = grandParent.parentElement;
                grandParent.className += " insuranceTypeSelected";
            }else{
                // grandParent = allRadioButtons[i].parentElement;
                parentELementclass = allRadioButtons[i].parentElement;
                grandParent = parentELementclass.parentElement;
                grandParent = grandParent.parentElement;
                grandParent = grandParent.parentElement;
                grandParent.classList.remove("insuranceTypeSelected");
            }
        }
        
        
       

        if(event.target.name == 'isTowing'){
            this.Is_Towing__c = event.target.checked;
        }else{
            let fieldName = event.target.name;
            let fieldValue = event.target.value;
            this.quote[fieldName] = fieldValue;
            this.idName = event.target.value;
            event.target.className += " insuranceTypeSelected";
        }
    }

    redirectOldFlow() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin + '/s/old-quick-quote',
            },
        })
    }
    // testMethodHandler(){
    //     console.log('testMethodHandler');

    //     testMethod().then((data) => {
    //         console.log('data-----',data);
    //     })

    // }
}

// import { LightningElement, api } from 'lwc';
// // import image from '@salesforce/resourceUrl/mexinsurance_assets';
// import checkCommunityUserAndFetchDetails from '@salesforce/apex/Mex_existingCustomerFlowController.checkCommunityUserAndFetchDetails';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { loadStyle } from 'lightning/platformResourceLoader';
// import StyleCSS from '@salesforce/resourceUrl/mexinsurance_assets';
// import { NavigationMixin } from 'lightning/navigation';

// export default class QuickQuotation extends NavigationMixin(LightningElement) {

//     idName = '';
//     @api insured = '';
//     isInsuranceScreen = true;
//     isComponentRendered = false;
//     insuretype = true;
//     insurancelocation = false;
//     screenName = 'insuretype';
//     @api policyType = '';
//     southboundFlow = false;
//     northboundFlow = false;
//     watercraftFlow = false;
//     @api isCommunityUser = false;
//     @api vehicleData;
//     @api watercraftData;
//     @api DriverData;
//     @api towedUnitData;
//     @api Is_Towing__c;

//     quote = {};

//     _title = 'Error';
//     message = 'Please Select Any One Option';
//     variant = 'error';

//     // imagetyre = image + '/images/tyre@2x.png';
//     // imagehouse = image + '/images/house@2x.png';
//     // imageboat = image + '/images/boat@2x.png';

//     // canadaimage = image + '/images/map-us-canada@2x.png';
//     // mexicoimage = image + '/images/map-mexico@2x.png';

//     async connectedCallback() {
//         let queryParam = window.location.pathname.split('/')[2];

//         const data = await checkCommunityUserAndFetchDetails();
//         const parsedData = JSON.parse(data);
//         console.log(JSON.stringify(parsedData, null, 4));
//         let getlabel = document.querySelector("label[id='isNorthbound']");
//         console.log('--getlabel--', getlabel);
//         if (parsedData.status == 'success' && parsedData.userType == true) {
//             this.isCommunityUser = parsedData.userType;
//             this.vehicleData = parsedData.vehicles && parsedData.vehicles.length > 0 ? parsedData.vehicles : [];
//             this.watercraftData = parsedData.watercrafts && parsedData.watercrafts.length > 0 ? parsedData.watercrafts : [];
//             this.DriverData = parsedData.drivers && parsedData.drivers.length > 0 ? parsedData.drivers : [];
//             this.towedUnitData = parsedData.towedUnits && parsedData.towedUnits.length > 0 ? parsedData.towedUnits : [];
//         } else if (parsedData.status == 'success' && parsedData.userType == false) {
//             this.isCommunityUser = parsedData.userType;
//             this.vehicleData = [];
//             this.DriverData = [];
//             this.towedUnitData = [];
//         }

//         if (queryParam == 'rv' || queryParam == 'automobile' || queryParam == 'motorcycle' || queryParam == 'northbound' || queryParam == 'watercraft' || queryParam == 'automobiletowed') {
//             if (queryParam == 'rv') {
//                 this.idName = 'RV';
//                 this.quote['insured'] = 'RV';
//             } else if (queryParam == 'automobile') {
//                 this.idName = 'Automobile';
//                 this.quote['insured'] = 'Automobile';
//             } else if (queryParam == 'motorcycle') {
//                 this.idName = 'Motorcycle/Street Legal ATV'
//                 this.quote['insured'] = 'Motorcycle/Street Legal ATV';
//             } else if (queryParam == 'watercraft') {
//                 this.idName = 'Watercraft';
//                 this.quote['insured'] = 'Watercraft';
//             } else if ('northbound') {
//                 this.idName = 'Northbound';
//                 this.quote['insured'] = 'Northbound';
//             } else if (queryParam == 'automobiletowed') {
//                 this.idName = 'AutomobileTowed';
//                 this.quote['insured'] = 'AutomobileTowed';
//             } else if (queryParam == 'rvtowed') {
//                 this.idName = 'RVTowed';
//                 this.quote['insured'] = 'RVTowed';
//             }
//             this.handleNextClick();
//         }
//     }

//     get isAutomobile() {
        
//         //let clickOption = this.template.querySelector(`[data-id="${clicksection}"]`);
//         return this.idName == 'Automobile';
//     }
//     get isAutomobileTowed() {
//         return this.idName == 'AutomobileTowed';
//     }
//     get isMotorcycle() {
//         return this.idName == 'Motorcycle/Street Legal ATV';
//     }
//     get isRV() {
//         return this.idName == 'RV';
//     }
//     get isRVTowed() {
//         return this.idName == 'RVTowed';
//     }
//     get isNorthbound() {
//         // let clickOption = this.template.querySelector(`[data-id="isNorthbound"]`);
//         // if(this.idName == 'Northbound'){
            
//         //     clickOption.className += " insuranceTypeSelected";
//         // }else{
//         //     clickOption.classList.remove("insuranceTypeSelected");
//         // }
//         return this.idName == 'Northbound';
//     }
//     get isHomeowner() {
//         return this.idName == 'Homeowner';
//     }
//     get isWatercraft() {
//         return this.idName == 'Watercraft';
//     }

//     handleNextClick() {

//         console.log("---quote---" + JSON.stringify(this.quote));
//         console.log("---idName---" + this.idName);
//         // this.policyType = 'Automobile';
//         if (this.idName != null && this.idName != '' && this.idName != undefined) {
//             if (this.quote.insured == 'RV' || this.quote.insured == 'Automobile' || this.quote.insured == 'Motorcycle/Street Legal ATV') {
//                 this.southboundFlow = true;
//                 this.northboundFlow = false;
//                 this.watercraftFlow = false;
//                 this.Is_Towing__c = false;
//                 this.policyType = this.quote.insured;
//             } else if (this.quote.insured == 'Northbound') {
//                 this.northboundFlow = true;
//                 this.watercraftFlow = false;
//                 this.southboundFlow = false;
//                 this.policyType = this.quote.insured;
//             } else if (this.quote.insured == 'Watercraft') {
//                 this.watercraftFlow = true;
//                 this.southboundFlow = false;
//                 this.northboundFlow = false;
//                 this.Is_Towing__c = false;
//                 this.policyType = this.quote.insured;
//             } else if (this.quote.insured == 'AutomobileTowed') {
//                 this.southboundFlow = true;
//                 this.watercraftFlow = false;
//                 this.northboundFlow = false;
//                 this.policyType = 'Automobile';
//                 this.Is_Towing__c = true;
//             } else if (this.quote.insured == 'RVTowed') {
//                 this.southboundFlow = true;
//                 this.watercraftFlow = false;
//                 this.northboundFlow = false;
//                 this.policyType = 'RV';
//                 this.Is_Towing__c = true;
//             } else if (this.quote.insured == 'Homeowner') {
//                 this[NavigationMixin.Navigate]({
//                     type: 'standard__webPage',
//                     attributes: {
//                         url: window.location.origin + '/s/quick-home',
//                     },
//                 })
//             }
//             this.isInsuranceScreen = false;
//         } else {
//             const evt = new ShowToastEvent({
//                 message: 'Please select any one option',
//                 variant: this.variant,
//             });
//             this.dispatchEvent(evt);
//         }
//     }

//     renderedCallback() {
        
//         if (!this.isComponentRendered) {
//             Promise.all([
//                 loadStyle(this, StyleCSS + '/style.css')
//             ]).then(() => {
//                 console.log("Files loaded");
//                 this.isComponentRendered = true;
//             }).catch(error => {
//                 console.log('css error', error.body.message);
//                 this.isComponentRendered = false;
//             });
//         }
//     }

//     handleChange(event) {
//         const allRadioButtons = this.template.querySelectorAll('input[name="insured"]');
//         let parentELementclass;
//         for(let i = 0; i< allRadioButtons.length; i++){
//             console.log('--llRadioButtons[i].checked--', allRadioButtons[i].checked);
//             if(allRadioButtons[i].checked == true){
//                 parentELementclass = allRadioButtons[i].parentElement;
//                 parentELementclass.className += " insuranceTypeSelected";
//             }else{
//                 parentELementclass = allRadioButtons[i].parentElement;
//                 parentELementclass.classList.remove("insuranceTypeSelected");
//             }
//         }
//         // console.log(allRadioButtons[0].checked)
//         // console.log(allRadioButtons[1].checked)        
//         // console.log(allRadioButtons[1].parentElement) 
//         console.log("tis is name " + event.target.name);
        
       
        
//         let fieldName = event.target.name;
//         let fieldValue = event.target.value;
//         this.quote[fieldName] = fieldValue;
//         this.idName = event.target.value;
//         event.target.className += " insuranceTypeSelected";
       
        
       
        


//         console.log("idName value is :" + this.idName);
//     }

//     redirectOldFlow() {
//         this[NavigationMixin.Navigate]({
//             type: 'standard__webPage',
//             attributes: {
//                 url: window.location.origin + '/s/old-quick-quote',
//             },
//         })
//     }
// }