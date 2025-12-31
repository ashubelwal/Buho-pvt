import { api, LightningElement } from 'lwc';
import validateFormData from '@salesforce/apex/Mex_ValidateFormData.validateFormData';
import updateWatercraftQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateWatercraftQuoteRecordData';
import InsertLeadData from '@salesforce/apex/Mex_NewLeadProcess.InsertLeadData';
import fetchDataFromLead from '@salesforce/apex/Mex_NewLeadProcess.fetchDataFromLead';
//import getCurrentUserDrivers from '@salesforce/apex/Mex_NewLeadProcess.getCurrentUserDrivers';
import updateQuoteRecordData from '@salesforce/apex/Mex_existingCustomerFlowController.updateQuoteRecordData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ownerof from '@salesforce/label/c.TR_Owner_of_the_Registered_Vehicle';
import name from '@salesforce/label/c.TR_Name';
import dob from '@salesforce/label/c.TR_DOB';
import license from '@salesforce/label/c.TR_License';
import oradda from '@salesforce/label/c.TR_Or_Add_a_New_Driver';
import prev from '@salesforce/label/c.TR_Prev';
import next from '@salesforce/label/c.TR_Next';
import Driverdetails from '@salesforce/label/c.TR_Driver_details';
import Selectadriverfromyouraccount from '@salesforce/label/c.TR_Select_a_driver_from_your_account';
import Thereshouldbesingleowner from '@salesforce/label/c.TR_There_should_be_single_owner';
import driverhassome from '@salesforce/label/c.TR_Driver_s_0_has_some_missing_info_kindly_add_them_to_proceed';

export default class DriverRegistered extends LightningElement {
     label = {
        Driverdetails,Selectadriverfromyouraccount,ownerof,name,dob,license,oradda,prev,next,Thereshouldbesingleowner,driverhassome,
    };
    @api changeprevscreen;
    @api changesnextscreen;
    @api handleInsertData;
    @api driverList = [];
    @api editDriverData = {};
    @api leaddata;
    @api policyType;
    @api isEdit = false;
    @api isOwner;

    @api oldpolicydata;
    @api editpolicydata;
    @api customerRecord;
    @api communityUser;
    @api driverData;
    @api reviewVehicleData;

    disableEditDriver;
    newDriverSectionOpen = false;
    editIndex;
    loginUserDriverOption;
    getLoginAllDrivers;
    activeAccordinSection;


    isEditSectionOpen = false;
    async connectedCallback() {
        try {
            if(this.communityUser){
                this.getAllDriverData();
            }
            if (this.editpolicydata != null) {
                this.driverList = [...this.editpolicydata.DriverData];
                this.reviewVehicleData = this.editpolicydata.vehicleData;
            } else {
                const fetchDatareturn = await this.fetchData();
                if (!this.communityUser) {
                    this.reviewVehicleData = this.leaddata?.reviewVehicle;
                } else {
                    if (this.customerRecord != null) this.reviewVehicleData = this.customerRecord?.vehicleData;
                }
                if (fetchDatareturn == 'success') {
                    this.ifIsOwner();
                }
            }
        } catch (error) {
            this.generateLogs();
            console.log('---error---', error);
        }

    }
    getAllDriverData= async () =>{
        try{
           
            let loginUserDrivers = [{'value': '', 'label': '--None--'}];
            if(this.driverData != null){
                this.getLoginAllDrivers = this.driverData;
                this.driverData.forEach( function(item){
                    console.log('--getAllVehiclesData item---', item);
                    let label = item.Name + ' - '+item.Dob__c+ ' - '+item.license_number__c;
                    loginUserDrivers.push({'value': item.Id, 'label': label });
                });
                this.loginUserDriverOption = loginUserDrivers;
            }
        }catch(ex){
            console.log('errod ::: ', ex);
            this.generateLogs();
        }
    }
    changeDriverOption = async(event) =>{
        let DriverId = event.target.value;
        console.log('---DriverId--', DriverId);
        let filterDriverDetail = this.getLoginAllDrivers.filter(item =>{
            console.log('--item---', item);
            return item.Id == DriverId;
        })
        console.log('---filterVehicleDetail---', filterDriverDetail);
        // filterDriverDetail.map((data)=>{
        //     data.Vehicle_sub_type__c = data.Vehicle_Type__c;
        //     data.Is_this_a_Rental_Vehicle__c = data.Rental__c == 'No' ? false : true;
        //     data.Is_there_a_driver_under_21__c = false;
        // })
        this.editDriverData =  filterDriverDetail[0];
       
        // this.handleSectionToggle();
         this.newDriverSectionOpen = true;
        this.activeAccordinSection = 'A';
        console.log('---editDriverData---', this.editDriverData);
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


        this.isEdit = false;
        this.disableEditDriver = false;
        this.newDriverSectionOpen = false;
    }
    handleSectionToggle() {
        this.newDriverSectionOpen = !this.newDriverSectionOpen;
        this.editDriverData = {};
        this.isEdit = false;
        this.disableEditDriver = !this.disableEditDriver;
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

    get Year() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Year__c : '';
    }
    get Make() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Make__c : '';
    }
    get Model() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Model__c : '';
    }
    get VehicleValue() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Value__c : '';
    }
    get VINNumber() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Vin__c : '';
    }
    get RegisteredCountry() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Registered_Country__c : '';
    }
    get RegisteredState() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Registered_State__c : '';
    }
    get LicensePlate() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Registered_Plate__c : '';
    }
    get vehicleRegistered() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Is_the_vehicle_registered_to_a_business__c : '';
    }
    get vehicleInfo() {
        return this.reviewVehicle != undefined ? this.reviewVehicle.Is_Lienholder__c : '';
    }
    get selectedDriverId (){
        return this.driverDetail?.Id;
    }


    editDriverDetail(event) {
        let index = event.target.dataset.index;
        console.log('OUTPUT name : ', event.target.name);
        console.log('OUTPUT idex: ', index);
        console.log('OUTPUT dataId: ', event.target.dataset.id);
        console.log('OUTPUT detail: ', event.currentTarget.dataset.id);
        this.editIndex = index;
        this.editDriverData = this.driverList[index];
        console.log('data editDriverData--- ', this.editDriverData);
        // this.driverList.map((data) => {
        //     if (data.license_number__c == editDriver) {
        //         
        //         this.editDriverData = data;
        //     }
        // })
        this.isEdit = true;
        this.disableEditDriver = true;
        this.newDriverSectionOpen = true;
        this.isEditSectionOpen = true;

    }

    deleteDriver(event) {
        console.log("this is delete function");
        let index = event.target.dataset.index;
        console.log('delete  dataId: ', index);
        this.driverList.splice(index, 1);
        this.driverList = this.driverList;
    }


    handleNextClick = async () => {
        try {
            let ownerCount = 0;
            let missingInfo = [];
            this.driverList.map((driver) => {
                if (driver.license_number__c == '' || driver.License_Number__c == '' || driver.License_state__c == '' || driver.License_State__c == '' || driver.License_Country__c == '') {
                    missingInfo.push(`${driver.First_Name__c} ${driver.Last_Name__c}`);
                }
            });

            if (missingInfo.length > 0) {
                const errEvt = new ShowToastEvent({
                    title: 'Error',
                    message: this.label.driverhassome,
                    variant: 'error',
                    messageData: [
                        missingInfo.slice(0, missingInfo.length),
                    ],
                });
                this.dispatchEvent(errEvt);
               
                return;
            }

            this.driverList.map((data) => {
                if (data.Driver_Type__c == "Owner" || data.Driver_Type__c == "Owner & Driver") {
                    ownerCount += 1;
                }
            });

         

            if ((ownerCount == 1 || (this.policyType!='Watercraft' && this.reviewVehicleData.Is_the_vehicle_registered_to_a_business__c == true)) && (this.driverList.length > 0)) {
                if (this.editpolicydata != null) {
                    this.editpolicydata = { ...this.editpolicydata, ['DriverData']: [...this.driverList] };
                    console.log('--edit policy driver list--', this.editpolicydata);
                    const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
                        detail: this.editpolicydata,
                    });

                    // let eventExist = window.dataLayer.find((data) => data.step_number === 'step_9');
                    // if (eventExist == undefined){
                    //     window.dataLayer.push({
                    //         'event': 'funnel_step',
                    //         'step_number': 'step_9',
                    //         'step_name': 'driver_details', 
                    //         'insurance_category': this.policyType
                    //         });
                    // }
                    this.dispatchEvent(editPolicyChange);
                    this.changesnextscreen();
                } else {
                    this.template.querySelector('.buttonNext').classList.add('loading');
                    this.template.querySelector('.buttonNext').setAttribute('disabled', true);

                    const data = await validateFormData({ "objData": JSON.stringify({ ['Driver_details__c']: this.driverList }), "objName": 'driverDetails' });

                    if (data.status == 'success') {
                        if (this.communityUser != null && this.communityUser) {

                            let driverDataUpdate = (this.policyType == 'Watercraft')?
                            await updateWatercraftQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord }), "watercraftRecord": JSON.stringify({ ...this.customerRecord?.watercraftData }),"driversRecord": this.driverList.length > 0 ? JSON.stringify(this.driverList) : '' })
                           :await updateQuoteRecordData({ "quoteRecord": JSON.stringify({ ...this.customerRecord?.quoteRecord }), "vehicleRecord": JSON.stringify({ ...this.customerRecord?.vehicleData }), "towedUnitRecord": '', "driversRecord": this.driverList.length > 0 ? JSON.stringify(this.driverList) : '' })

                            if (driverDataUpdate.status == 'success') {
                                this.customerRecord = { ...this.customerRecord, ['DriverData']: [...driverDataUpdate.DriversData] };
                                const customerRecordChange = new CustomEvent('customerecordchange', {
                                    detail: this.customerRecord,
                                });
                                console.log('driverDataUpdate' + driverDataUpdate)
                                this.dispatchEvent(customerRecordChange);
                            }else{
                                console.log('driverDataUpdate else DR 286' + driverDataUpdate)
                                this.generateLogs();
                            }
                        } else {
                            const res = await InsertLeadData({ 'leadData': JSON.stringify({ ['Driver_details__c']: JSON.stringify(this.driverList), ['Id']: this.leaddata?.Id }) });
                            if (res.status == 'Success') {
                                console.log('communityUser if DR 292' + res)
                                this.leaddata = { ...this.leaddata, ['DriverData']: this.driverList };
                                const leadChange = new CustomEvent('leadvaluechange', {
                                    detail: this.leaddata,
                                });
                                
                                this.dispatchEvent(leadChange);

                                let eventExist = window.dataLayer.find((data) => data.step_number === 'step_9');
                                if (eventExist == undefined){
                                    window.dataLayer.push({
                                        'event': 'funnel_step',
                                        'step_number': 'step_9',
                                        'step_name': 'driver_details', 
                                        'insurance_category': this.policyType
                                        });
                                }
                            } else {
                                console.log('Else InsertLeadData 300' + res)
                                this.generateLogs();
                                this.template.querySelector('.buttonNext').classList.remove('loading');
                                this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                                // error...
                            }
                        }
                        
                        this.changesnextscreen();
                    } else {
                        console.log(data);
                        console.log(JSON.stringify(data));
                        this.generateLogs();
                        this.template.querySelector('.buttonNext').classList.remove('loading');
                        this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
                        // error...
                    }
                }
            } else {
               // this.generateLogs();
               console.log('Else InsertLeadData 317')
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: this.label.Thereshouldbesingleowner,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }


        } catch (error) {
            console.log('Catch DR 321 '+ error);
            this.generateLogs();
            this.template.querySelector('.buttonNext').classList.remove('loading');
            this.template.querySelector('.buttonNext').removeAttribute('disabled', false);
            // handle errors if any...
        }

    }

    fetchData = async () => {
        if (this.leaddata?.Id != undefined && !this.communityUser) {
            try {
                const data = await fetchDataFromLead({ "LeadId": this.leaddata?.Id, "screenName": "Driver_details__c" });
                console.log("---data fetch--", data);
                if (data.status == 'success') {
                    if (data.data[0].Driver_details__c != undefined) {
                        let parseDriverDetailData = JSON.parse(data.data[0].Driver_details__c);
                        let prevPolicyType = data.data[0].Insurance_Type__c;

                        this.driverList = this.leaddata?.Policy_Type__c == prevPolicyType ? parseDriverDetailData : {};
                    }
                    return data.status;
                } else {
                    return 'error';
                }
            } catch (ex) {
                console.log('error : ', ex);
            }
        } else {
            if (this.communityUser != null && this.communityUser && this.customerRecord != null) {
                this.driverList = this.customerRecord?.DriverData?.length ? [...this.customerRecord?.DriverData] : [];
                this.policyType = this.customerRecord?.policyType;
                return 'success';
            }
        }
    }

    handlePrevClick() {
        console.log('--call handlePrevClick---');
        if (this.editpolicydata != null) {
            this.editpolicydata = { ...this.editpolicydata, ['DriverData']: [...this.driverList] };
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
                this.dispatchEvent(leadChange);
            }
        }

        this.changeprevscreen();
    }
    generateLogs(){
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }
}