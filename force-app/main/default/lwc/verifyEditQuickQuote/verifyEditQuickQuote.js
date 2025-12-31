import { api, LightningElement } from 'lwc';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
import updateQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateQuoteRecordData';
import verifyandedit from '@salesforce/label/c.TR_Quote_Detail';
import policysummary from '@salesforce/label/c.TR_Policy_Summary';
import insurancecompany from '@salesforce/label/c.TR_Insurance_Company';
import premium from '@salesforce/label/c.TR_Premium';
import surcharge from '@salesforce/label/c.TR_Surcharge';
import brokercharge from '@salesforce/label/c.TR_Broker_Charge';
import MexicanIVATAX from '@salesforce/label/c.TR_Mexican_IVA_TAX';
import coveragedetails from '@salesforce/label/c.TR_Coverage_Details';
import coverage from '@salesforce/label/c.TR_Coverage';
import policytype from '@salesforce/label/c.TR_Policy_Type';
import term from '@salesforce/label/c.TR_Term';
import TOTAL from '@salesforce/label/c.TR_TOTAL';
import liability from '@salesforce/label/c.TR_Liability';
import Medical from '@salesforce/label/c.TR_Medical';
import vehicledetails from '@salesforce/label/c.TR_Vehicle_Details';
import name from '@salesforce/label/c.TR_Name';
import value from '@salesforce/label/c.TR_Value';
import vehicletype from '@salesforce/label/c.TR_Vehicle_Type';
import registeredplate from '@salesforce/label/c.TR_Registered_Plate';
import Vin from '@salesforce/label/c.TR_VIN';
import DriverDetails from '@salesforce/label/c.TR_Driver_details';
import DateOfBirth from '@salesforce/label/c.TR_Date_of_Birth';
import State from '@salesforce/label/c.TR_State';
import Country from '@salesforce/label/c.TR_Country';
import LicenseNumber from '@salesforce/label/c.TR_License_Number';
import Edit from '@salesforce/label/c.TR_Edit';
import Prev from '@salesforce/label/c.TR_Prev';
import Next from '@salesforce/label/c.TR_Next';
import EditDriver from '@salesforce/label/c.TR_Edit_Driver';
import EditUnit from '@salesforce/label/c.TR_Edit_Unit';

export default class VerifyEditQuickQuote extends LightningElement {
    label = {
        verifyandedit,policysummary,insurancecompany,premium,surcharge,brokercharge,MexicanIVATAX,coveragedetails,coverage,policytype,term,
        name,value,vehicletype,registeredplate,vehicledetails,Vin,DriverDetails,DateOfBirth,State,Country,LicenseNumber,Edit,EditUnit,Prev,Next,EditDriver,TOTAL,liability,Medical
    };

    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api isEdit;
    @api driverList;
    @api editDriverData;
    @api reviewVehicleData;
    @api communityUser;
    @api customerRecord;
    vehicleList;
    policyType;

    QuoteDetails;
    isDriverEdit = false;

    get isMotorcyclePolicy() {
        return this.QuoteDetails.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV';
    }

    connectedCallback() {
        if (!this.communityUser) {
            this.reviewVehicleData = this.leaddata.reviewVehicle;
            this.policyType = this.leaddata.Policy_Type__c;
        } else {
            if (this.customerRecord != null && this.communityUser) {
                this.reviewVehicleData = this.customerRecord?.vehicleData;
                this.policyType = this.customerRecord?.policyType;
            }

        }

        this.fetchData();
    }


    fetchData = async () => {
        if (this.leaddata?.Id != undefined && !this.communityUser) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Vehicle_details__c, Driver_details__c, Quote_Details__c" });
                console.log("---data fetch--", data);
                if (data.status == 'success') {
                    if (data.data[0].Vehicle_details__c != undefined) {
                        let parseVehicleDetailData = JSON.parse(data.data[0].Vehicle_details__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;

                        this.vehicleList = this.leaddata?.Policy_Type__c == prevPolicyType ? parseVehicleDetailData : {};

                    }
                    if (data.data[0].Driver_details__c != undefined) {
                        let parseDriverDetailData = JSON.parse(data.data[0].Driver_details__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;

                        this.driverList = this.leaddata?.Policy_Type__c == prevPolicyType ? parseDriverDetailData : [];
                    }
                    if (data.data[0].Quote_Details__c != undefined) {
                        let parseQuoteDetailData = JSON.parse(data.data[0].Quote_Details__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;

                        this.QuoteDetails = this.leaddata?.Policy_Type__c == prevPolicyType ? parseQuoteDetailData : {};
                    }
                    this.leaddata = { ...this.leaddata, ['Quote_Value__c']: this.QuoteDetails?.Quote_Value__c };
                    console.log('--QuoteDetails--', this.QuoteDetails);
                    console.log('--vehicleList--', this.vehicleList);
                    return data.status;
                } else {
                    this.generateLogs();
                    return 'error';
                }
            } catch (ex) {
                console.log('error : ', ex);
            }
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                this.vehicleList = { ...this.customerRecord?.vehicleData };
                this.driverList = [...this.customerRecord?.DriverData];
                this.QuoteDetails = { ...this.customerRecord?.quoteRecord };
                return 'success';
            }
        }
    }

    editDriverDetail(event) {
        let index = event.target.dataset.index;
        this.isDriverEdit = true;
        this.isEdit = true;
        this.editIndex = index;
        this.editDriverData = this.driverList[index];
    }

    hideEditDriverDetail() {
        this.isDriverEdit = false
    }
    handleAddNewDriver(e) {

        console.log("call this function form driverregistartion--", e.detail);
        console.log("call this function form edit drover--", this.isEdit);
        console.log("call this function form edit drover--", this.editIndex);

        if (e.detail != 'cancelSection') {
            if (this.isEdit != true) {
                this.driverList.push(e.detail);
            } else {
                let driverDetail = e.detail;
                this.driverList[this.editIndex] = driverDetail;
                console.log('thhis fter--', this.driverList);
            }
        }
        this.ifIsOwner();

        this.isDriverEdit = false;
        this.isEdit = false;
    }
    ifIsOwner() {
        const owners = this.driverList.map((driver) => {
            if (driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == "Owner & Driver") {
                return false;
            } else {
                return true;
            }

        });


        console.log('ifIsOwner---', owners);

        this.isOwner = owners.includes(false) == true ? false : true;
    }
    handleNextClick = async () => {
        this.template.querySelector('.buttonNext').classList.add('loading');
        this.template.querySelector('.buttonNext').setAttribute('disabled', true);
        if (this.communityUser != null && this.communityUser) {
            let updateData = await updateQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord }), "vehicleRecord": JSON.stringify({ ...this.customerRecord?.vehicleData }), "towedUnitRecord": '', "driversRecord": this.driverList.length > 0 ? JSON.stringify(this.driverList) : '' });

            if (updateData.status == 'success') {
                this.customerRecord = { ...this.customerRecord, ['DriverData']: [...updateData.DriversData] };
                const customerRecordChange = new CustomEvent('customerecordchange', {
                    detail: this.customerRecord,
                });

                this.dispatchEvent(customerRecordChange);
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            } else {
                this.generateLogs();
                this.template.querySelector('.buttonNext').classList.remove('loading');
                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            }
        } else {
            const leadChange = new CustomEvent('leadvaluechange', {
                detail: this.leaddata,
            });
            console.log('this is vehicle detail list : ', this.vehicleList);
            console.log('this is driver detail list : ', this.driverList);
            this.dispatchEvent(leadChange);
            let eventExist = window.dataLayer.find((data) => data.step_number === 'step_10');
            if (eventExist == undefined){
                window.dataLayer.push({
                    'event': 'funnel_step',
                    'step_number': 'step_10',
                    'step_name': 'details_confirmation', 
                    'insurance_category': this.policyType
                    });
            }
            this.template.querySelector('.buttonNext').classList.remove('loading');
            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
        }
        
        this.changesnextscreen();
    }

    handlePrevClick() {
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
        this.changeprevscreen();
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}