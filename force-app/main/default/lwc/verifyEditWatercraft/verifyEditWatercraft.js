import { LightningElement, api } from 'lwc';
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
import watercraftdetails from '@salesforce/label/c.TR_Watercraft_Details';
import Name from '@salesforce/label/c.TR_Name';
import value from '@salesforce/label/c.TR_Value';
import vesseltype from '@salesforce/label/c.TR_Vessel_Type';
import vessellength from '@salesforce/label/c.TR_Vessel_Length';
import Vin from '@salesforce/label/c.TR_VIN';
import Beam from '@salesforce/label/c.TR_Beam';
import DriverDetails from '@salesforce/label/c.TR_Driver_details';
import DateOfBirth from '@salesforce/label/c.TR_Date_of_Birth';
import State from '@salesforce/label/c.TR_State';
import Country from '@salesforce/label/c.TR_Country';
import LicenseNumber from '@salesforce/label/c.TR_License_Number';
import Edit from '@salesforce/label/c.TR_Edit';
import Prev from '@salesforce/label/c.TR_Prev';
import Next from '@salesforce/label/c.TR_Next';
import EditDriver from '@salesforce/label/c.TR_Edit_Driver';
import EditWatercraft from '@salesforce/label/c.TR_Edit_Watercraft';
import EditUnit from '@salesforce/label/c.TR_Edit_Unit';

export default class VerifyEditWatercraft extends LightningElement {
    label = {
        verifyandedit,policysummary,insurancecompany,premium,surcharge,brokercharge,MexicanIVATAX,coveragedetails,coverage,policytype,term,TOTAL,watercraftdetails,
        Name,value,vesseltype,vessellength,Vin,Beam,DriverDetails,DateOfBirth,State,Country,LicenseNumber,Edit,Prev,Next,EditDriver,EditWatercraft,EditUnit,
    };
    @api changesnextscreen;
    @api changeprevscreen;
    @api leaddata;
    @api handleInsertData;
    @api customerRecord;
    @api communityUser;
    quoteId = '';
    watercraftList;
    driverList;
    QuoteDetails
    isDriverEdit = false;
    isWatercraftEdit = false;
    spinner = false;
    policyType;

    async connectedCallback() {
        this.spinner = true;
        this.quoteId = this.leaddata?.quoteId;
        await this.fetchData();
    }
    fetchData = async () => {
        try {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {

                this.watercraftList = this.customerRecord?.watercraftData ;
                console.log('--watercraftList--', this.watercraftList);

                this.driverList = this.customerRecord?.DriverData ;
                console.log('--driverList--', this.driverList);

                this.QuoteDetails = this.customerRecord?.quoteRecord;

                console.log('--QuoteDetails--', this.QuoteDetails);

                this.policyType = 'Watercraft';
                this.spinner = false;
                console.log('end of fetch ');

            } else {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Watercraft_Detail__c, Driver_details__c, Quote_Details__c" });
                console.log("---data fetch--", data);
                if (data.status == 'success') {
                    if (data.data[0].Watercraft_Detail__c != undefined) {
                        let parseVehicleDetailData = JSON.parse(data.data[0].Watercraft_Detail__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;

                        this.watercraftList = this.leaddata?.Policy_Type__c == prevPolicyType ? parseVehicleDetailData : {};

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
                    console.log('--QuoteDetails--', this.QuoteDetails);
                    console.log('--watercraftList--', this.watercraftList);
                    this.spinner = false;
                    return data.status;
                } else {
                    this.generateLogs();
                    return 'error';
                }
            }

        } catch (ex) {
            console.log('error : ', ex);
        }
    }
    editWatercraftDetail(event) {
        let index = event.target.dataset.index;
        this.isWatercraftEdit = true;
        this.isEdit = true;
        this.editIndex = index;

    }
    hideEditWatercraftDetail() {
        this.isWatercraftEdit = false
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

    handleNextClick() {
        // this.handleInsertData();

        let eventExist = window.dataLayer.find((data) => data.step_number === 'step_10');
        if (eventExist == undefined){
            window.dataLayer.push({
                'event': 'funnel_step',
                'step_number': 'step_10',
                'step_name': 'details_confirmation', 
                'insurance_category': this.leaddata?.Policy_Type__c
                });
        }
        this.changesnextscreen();

    }

    handlePrevClick() {
        const leadChange = new CustomEvent('leadvaluechange', {
            detail: this.leaddata,
        });

        this.dispatchEvent(leadChange);
        this.changeprevscreen();
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}