import { LightningElement, api } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import updateWatercraftQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateWatercraftQuoteRecordData';
import Reviewwatercraftinformation from '@salesforce/label/c.TR_Review_watercraft_information';
import Year from '@salesforce/label/c.TR_Year';
import Make from '@salesforce/label/c.TR_Make';
import Model from '@salesforce/label/c.TR_Model';
import Value from '@salesforce/label/c.TR_Value';
import VesselType from '@salesforce/label/c.TR_Vessel_Type';
import VesselLength from '@salesforce/label/c.TR_Vessel_Length';
import VINNumber from '@salesforce/label/c.TR_VIN_Number';
import Beamwidth from '@salesforce/label/c.TR_Beam_width';
import Prev from '@salesforce/label/c.TR_Prev';
import Next from '@salesforce/label/c.TR_Next';
import Internationallawrequiresthatevery from '@salesforce/label/c.TR_International_law_requires_that_every_watercraft_be_registered_in_a_country';
import Flag from '@salesforce/label/c.TR_Flag';
import EngineType from '@salesforce/label/c.TR_Engine_Type';
import EngineTypeInboardOutboard from '@salesforce/label/c.TR_Engine_Type_Inboard_Outboard';

export default class WatercraftReview extends LightningElement {
    label = {
        Reviewwatercraftinformation,Year,Make,Model,Value,VesselType,VesselLength,VINNumber,Beamwidth,Prev,Next,Internationallawrequiresthatevery,Flag,EngineType,EngineTypeInboardOutboard,
        };
    
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;

    @api oldpolicydata;
    @api editpolicydata;
    @api isEditPolicy;
    @api isRenewalPolicy;
    spinner = false;

    watercraftReview = {};


    @api communityUser;
    @api customerRecord;

    async connectedCallback() {
        this.spinner = true;
        console.log('--communityUser--', this.communityUser);
        console.log('--customerRecord--',JSON.stringify( this.customerRecord, null, 4));
        console.log('--isEditPolicy--', this.isEditPolicy);
        if (this.isEditPolicy == 'Yes' || this.isRenewalPolicy == 'Yes') {

            console.log('--editPolicyData--', this.editpolicydata);
            console.log('--oldpolicydata--', this.oldpolicydata);
            this.watercraftReview = this.editpolicydata.watercraftData;
            this.spinner = false;
        } else {
            await this.fetchData();
        }

    }

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    get setYearValue() {
        return this.watercraftReview.Year__c != undefined ? this.watercraftReview.Year__c : '';
    }
    get setMakeValue() {
        return this.watercraftReview.Make__c != undefined ? this.watercraftReview.Make__c : '';
    }
    get setModelValue() {
        return this.watercraftReview.Model__c != undefined ? this.watercraftReview.Model__c : '';
    }
    get setVesselType() {
        return this.watercraftReview.Type_of_Vessel__c != undefined ? this.watercraftReview.Type_of_Vessel__c : '';
    }
    get setVesselLength() {
        return this.watercraftReview.Vessel_Length__c != undefined ? this.watercraftReview.Vessel_Length__c : '';
    }
    get showVesselLength() {

        return this.watercraftReview.Type_of_Vessel__c != undefined ?
            (this.watercraftReview.Type_of_Vessel__c == 'Personal Watercraft (Jet Ski)' ? true : false) : false;
    }
    get setVehicleValue() {
        return this.watercraftReview.Value__c != undefined ? this.watercraftReview.Value__c : '';
    }
    get setVinNumberValue() {
        return this.watercraftReview.VIN_Number__c != undefined ? this.watercraftReview.VIN_Number__c : '';
    }
    get setBeamValue() {
        return this.watercraftReview.Beam__c != undefined ? this.watercraftReview.Beam__c : '';
    }
    get setFlagValue() {
        return this.watercraftReview.Flag__c != undefined ? this.watercraftReview.Flag__c : '';
    }
    get setEngineTypeValue() {
        return this.watercraftReview.Engine_Type__c != undefined ? this.watercraftReview.Engine_Type__c : '';
    }

    handleChange(event) {

        let name = event.target.name;
        let value = event.target.value;

        if (/^\s/.test(value)) {
            value = '';
        }
        this.watercraftReview = { ...this.watercraftReview, [name]: value };
        this.leaddata = { ...this.leaddata, ['watercraftReview']: this.watercraftReview };

        console.log("watercraftReview values - " + JSON.stringify(this.watercraftReview));
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



    fetchData = async () => {
        try {
            if (this.leaddata != undefined && !this.communityUser){
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Watercraft_Detail__c" });
                console.log('--data---', data);
                if (data.status == 'success') {
                    if (data.data[0].Watercraft_Detail__c != undefined) {
                        let parseReviewVehicleData = JSON.parse(data.data[0].Watercraft_Detail__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;
    
                        this.watercraftReview = this.leaddata?.Policy_Type__c == prevPolicyType ? parseReviewVehicleData : {};
    
                        console.log('--watercraftReview--', this.watercraftReview);
    
                        this.spinner = false;
                    }
    
                }else{
                    this.generateLogs();
                }
            }else{
                if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                    this.watercraftReview = { ...this.customerRecord?.watercraftData, ...this.watercraftReview };
    
                    
                    this.policyType = this.customerRecord?.policyType;
                    this.spinner = false;
                }else{
                    this.spinner = false;
                    this.generateLogs();
                    console.log('error occurs');
                }
            }
           
        } catch (ex) {
            this.spinner = false;
            this.generateLogs();
            console.log('error : ', ex);this.generateLogs();
        }

    }


    handleNextClick = async () => {
        let allValid = this.isInputValid();
        if (allValid) {
            try {
                this.template.querySelector('.buttonNext').classList.add('loading');
                this.template.querySelector('.buttonNext').setAttribute('disabled', true);
                console.log(JSON.stringify(this.watercraftReview, null, 4));

                const data = await validateFormData({ "objData": JSON.stringify(this.watercraftReview), "objName": 'watercraftReview' });

                console.log('-data---', data);
                if(this.communityUser != null && this.communityUser && data.status == 'success' && !this.isEditPolicy){
                    const updateVehicleResp = await updateWatercraftQuoteRecordData({ 'quoteRecord': JSON.stringify(this.customerRecord?.quoteRecord), 'watercraftRecord': JSON.stringify({ ...this.customerRecord?.watercraftData, ...this.watercraftReview }), 'driversRecord': '' })

                            if (updateVehicleResp.status == 'success') {
                                this.customerRecord = { ...this.customerRecord, ['quoteRecord']: { ...this.customerRecord?.quoteRecord, ...updateVehicleResp.quoteData }, ['watercraftData']: { ...this.customerRecord?.watercraftData, ...this.watercraftReview } };

                                const customerRecordChange = new CustomEvent('customerecordchange', {
                                    detail: this.customerRecord,
                                });

                                this.dispatchEvent(customerRecordChange);
                                this.changesnextscreen();
                            }else {
                                this.generateLogs();
                                this.template.querySelector('.buttonNext').classList.remove('loading');
                                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                            } 
                }
                else if (data.status == 'success' && !this.isEditPolicy && !this.isRenewalPolicy) {
                    const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Watercraft_Detail__c']: JSON.stringify(this.watercraftReview), ['Id']: this.leaddata?.Id }) });
                    console.log('--res--', res);
                    if (res.status == 'Success') {
                        this.leaddata = { ...this.leaddata, ['reviewVehicle']: this.watercraftReview };
                        const leadChange = new CustomEvent('leadvaluechange', {
                            detail: this.leaddata,
                        });

                        let eventExist = window.dataLayer.find((data) => data.step_number === 'step_8');
                        if (eventExist == undefined){
                            window.dataLayer.push({
                                'event': 'funnel_step',
                                'step_number': 'step_8',
                                'step_name': 'vehicle_details_2', 
                                'insurance_category': this.leaddata?.Policy_Type__c
                                });
                        }

                        this.dispatchEvent(leadChange);
                        this.changesnextscreen();
                    } else {
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    }
                    // call insert method here...
                } else if (data.status == 'success' && (this.isEditPolicy == 'Yes' || this.isRenewalPolicy == 'Yes')) {
                

                  this.editpolicydata = { ...this.editpolicydata, ['watercraftData']: { ...this.editpolicydata.watercraftData, ...this.watercraftReview } };
                this.editpolicydata.quoteData = {...this.editpolicydata.quoteData, ['Vehicle_Value__c']: this.watercraftReview.Value__c };
                                        
                    console.log('--review edit policy data--', this.editpolicydata);
                    const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                        detail: this.editpolicydata,
                    });
                    console.log('--editpolicyvaluechange--' );
                    this.dispatchEvent(editPolicyChange);
                    console.log('--dispatchEvent--' );
                    this.changesnextscreen();
                    console.log('--changesnextscreen--' );
                } else {
                    this.generateLogs();
                    this.template.querySelector('.buttonNext').classList.remove('loading');
                    this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                    // handle error...
                }
                
            } catch (error) {
                console.log(error);
                this.generateLogs();
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                // handle errors if any...
            }
        }
    }

    handlePrevClick() {
        // const leadChange = new CustomEvent('leadvaluechange', {
        //     detail: this.leaddata,
        // });

        // this.dispatchEvent(leadChange);
        this.changeprevscreen();
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}