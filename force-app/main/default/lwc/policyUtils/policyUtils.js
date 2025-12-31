import { LightningElement, track, wire } from 'lwc';
import getExactCoverageDetailForSouthbound from '@salesforce/apex/Mex_QuickQuoteCommonController.getExactCoverageDetailForSouthbound';
import getNorthboundCoverage from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundCoverage';
import getAgentFeeFRomUser from '@salesforce/apex/AgencyController.getAgentFeeFromUser';
import updateAgentFeeFromQuote from '@salesforce/apex/AgencyController.updateAgentFeeFromQuote';
import saveLeadDetails from '@salesforce/apex/AgentAppController.saveLeadDetails';
import getDriverDataFromContact from '@salesforce/apex/AgentAppController.getDriverData';
import getVehicleData from '@salesforce/apex/AgentAppController.getVehicleData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';


export default class PolicyUtils extends LightningElement {
    @track isShowToast = false;
    @track toastVariant;
    @track toastHeading;
    @track agentFee = 0;
    @track isDisabled = true;
    @track termAgreement = {
        'Terms_of_Cancellation_Confirmed__c': true,
        'Terms_of_Purchase_Confirmed__c': true
    };
    medicallist = ['$2,000/$10,000', '$3,000/$15,000', '$4,000/$20,000', '$5,000/$25,000', '$10,000/$50,000', '$15,000/$75,000', '$20,000/$100,000'];
    chubbmedicallist = ['$10,000/$50,000', '$15,000/$75,000', '$20,000/$100,000'];
    liabilitylist = [100000, 200000, 300000, 500000, 1000000];
    Chubbliabilitylist = [500000, 1000000];
    qualitasLiability = 500000;
    chubbLiability = 500000;
    mapfreLiability = 300000;
    qualitasMedical = '$10,000/$50,000';
    mapfreMedical = '$5,000/$25,000';
    chubbMedical = '$10,000/$50,000';
    DMVDomesticContactId;
    driversOptions = [];
    driversData;
    vehiclesOptions = [];
    vehiclesData;

    // Towed units
    newTowed = {}
    updatedTowed;
    addedTowed = [];
    towedCount = 0;
    paymentDetails = {};
    renewdPolicyId;

    @track booleanVar = {
        showMapfre: false, showChubb: false, showQualitas: false, isAutomobile: false, motorcyclePolicy: false, showCardPayment: false, cardPayment: false, cashPayment: false,
        disableMake: true, isTowingCheckbox: false, isTowing: false, editDriverBtn: false, showPolicyform: false, isAnnual: false, isSemiAnnual: false, isDaily: true,
        editTowedBtn: false, isOwner: false, lienholderOption: false, companyAddressOption: false, isBaja: true, isLimited: false, isTerritory: false, isTowingChecked: false,
        isShowingEndTerm: true, annual: false, semiAnnual: false, portalAccessYes: false, isModelDisabled: false, isPolicyDisabled: false, isRequiredTowed: false, isNorthbound: false, isContactType: false,
        registeredOwner: false, companyRegisteredOption: false, isLoading: false, showManualMake: false, showManualModel: false, isPolicyAutomobile: false, isEndDateDisabled: false, isDMVService: false, isDomesticInsurance: false,
        isPolicyNorthbound: false, isPolicyRV: false, isPolicyMotorcycle: false, isPolicyWatercraft: false, isLienholderChecked: false, isVehicleRentedChecked: false,
        isportalAccessHide: false, portalAccessNo: true, checkPortalAcccess: false, isUserDeactivated: false, disableEmail: false, emailService: false, isQuoteLoaded: false
    }

    @track trackVar = {
        startDate: '', endDate: '', startTime: '', endTime: '', vehicleValue: '', qualitasRatevalue: '', qualitasDays: '', chubbDays: '', chubbRateValue: '', mapfreRatevalue: '',
        mapfreDays: '', Is_there_a_driver_under_21__c: '', Salvage_Vehicle__c: '', Is_the_vehicle_used_for_business_purpose__c: '', Is_this_a_Rental_Vehicle__c: '', MannualMake: '',
        vehicleType: '', FirstName: '', LastName: '', Is_towing__c: '', Liability__c: '', Policy_Type__c: '', Make__c: '', Model__c: '', Vehicle_Type__c: '', MannualModel: '',
        Value__c: '', Year__c: '', Electric_Hybrid__c : false, Coverage__c: false, Territory__c: '', Vehicle_sub_type__c: '', Email: '', Phone: '', Vin__c: '', Registered_Country__c: '', Registered_State__c: '', Registered_Plate__c: '',
        paymentZip: '', paymentCity: '', paymentState: '', paymentCountry: '', paymentStreet: '', vehicleDob: '', lienHolderCountrycmbx: '', companyCountrycmbx: ''
    }

    policyTypeOptions = [
        { 'label': 'Automobile', 'value': 'Automobile' },
        { 'label': 'RV', 'value': 'RV' },
        { 'label': 'Motorcycle/ATV', 'value': 'Motorcycle/Street Legal ATV' },
        { 'label': 'Mexican Vehicles', 'value': 'Northbound' },
        { 'label': 'Watercraft', 'value': 'Watercraft' }
    ];

    TowedVehicleOptions = [
        { label: 'Motorcycle', value: 'Motorcycle' },
        { label: 'ATV_UTV', value: 'ATV-UTV' },
        { label: 'Boat', value: 'Boat' },
        { label: 'Camper', value: 'Camper' },
        { label: 'Utility_Misc_Trailer', value: 'Utility/Misc Trailer' },
        { label: 'Towed_Automobile', value: 'Towed Automobile' },
    ];
    @track
    mexicoStateList = [
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
    @track
    unitedStatesList = [
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
    @track
    canadaStateList = [
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

    // coverage deatails getter for northbound...

    get northboundDeductibles() {
        return this.coverageMap.Deductibles__c == 'Yes' ? true : false;
    }

    get northboundUninsuredMotoristDeductibleWavier() {
        return this.coverageMap.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }
    get northboundGlassBreakage() {
        return this.coverageMap.Glass_Breakage__c == 'Yes' ? true : false;
    }
    get northboundRoadsideAssistance() {
        return this.coverageMap.Roadside_Assistance__c == "Yes" ? true : false;
    }
    get northboundRentalCar() {
        return this.coverageMap.Rental_Car__c == "Yes" ? true : false;
    }
    get northboundLegalDefenseandBail() {
        return this.coverageMap.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }
    get northboundVandalism() {
        return this.coverageMap.Vandalism__c == 'Yes' ? true : false;
    }
    get northboundPartialTheft() {
        return this.coverageMap.Partial_Theft__c == 'Yes' ? true : false;
    }
    get northboundPlaneTicketsHome() {
        return this.coverageMap.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }

    // coverage detail variables
    get qualitasDeductibles() {
        return (this.coverageMap && this.coverageMap?.Qualitas?.Deductibles__c == 'Yes') ? true : false;
    }

    get qualitasUninsuredMotoristDeductibleWavier() {
        return this.coverageMap?.Qualitas?.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }

    get qualitasGlassBreakage() {
        return this.coverageMap?.Qualitas?.Glass_Breakage__c == 'Yes' ? true : false;
    }

    get qualitasRoadsideAssistance() {
        return this.coverageMap?.Qualitas?.Roadside_Assistance__c == "Yes" ? true : false;
    }

    get qualitasRentalCar() {
        return this.coverageMap?.Qualitas?.Rental_Car__c == "Yes" ? true : false;
    }

    get qualitasLegalDefenseandBail() {
        return this.coverageMap?.Qualitas?.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }

    get qualitasVandalism() {
        return this.coverageMap?.Qualitas?.Vandalism__c == 'Yes' ? true : false;
    }

    get qualitasPartialTheft() {
        return this.coverageMap?.Qualitas?.Partial_Theft__c == 'Yes' ? true : false;
    }

    get qualitasPlaneTicketsHome() {
        return this.coverageMap?.Qualitas?.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }

    get vehicleType() {
        return this.customerData.Policy_Type__c != 'Motorcycle/Street Legal ATV' || this.customerData.Policy_Type__c != 'Motorcycle' ? 'Vehicle : ' : '';
    }

    get chubbDeductibles() {
        return (this.coverageMap && this.coverageMap?.Chubb?.Deductibles__c == 'Yes') ? true : false;
    }

    get chubbUninsuredMotoristDeductibleWavier() {
        return this.coverageMap?.Chubb?.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }

    get chubbGlassBreakage() {
        return this.coverageMap?.Chubb?.Glass_Breakage__c == 'Yes' ? true : false;
    }

    get chubbRoadsideAssistance() {
        return this.coverageMap?.Chubb?.Roadside_Assistance__c == "Yes" ? true : false;
    }

    get chubbRentalCar() {
        return this.coverageMap?.Chubb?.Rental_Car__c == "Yes" ? true : false;
    }

    get chubbLegalDefenseandBail() {
        return this.coverageMap?.Chubb?.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }

    get chubbVandalism() {
        return this.coverageMap?.Chubb?.Vandalism__c == 'Yes' ? true : false;
    }

    get chubbPartialTheft() {
        return this.coverageMap?.Chubb?.Partial_Theft__c == 'Yes' ? true : false;
    }

    get chubbPlaneTicketsHome() {
        return this.coverageMap?.Chubb?.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }

    get mapfreDeductibles() {
        return (this.coverageMap && this.coverageMap?.Mapfre?.Deductibles__c == 'Yes') ? true : false;
    }

    get uninsuredMotoristDeductibleWavier() {
        return this.coverageMap?.Mapfre?.Uninsured_Motorist_Deductible_Waiver__c == 'Yes' ? true : false;
    }

    get mapFreGlassBreakage() {
        return this.coverageMap?.Mapfre?.Glass_Breakage__c == 'Yes' ? true : false;
    }

    get mapfreRoadsideAssistance() {
        return this.coverageMap?.Mapfre?.Roadside_Assistance__c == "Yes" ? true : false;
    }

    get isTowing() {
        return this.customerData.Is_towing__c == "Yes" ? true : false;
    }

    get isTowingMapfre() {
        if (this.isAutomobile || this.motorcyclePolicy) {
            return true;
        }
        else {
            return false;
        }
        //  return this.customerData.Is_towing__c == "Yes" ? true : false;
    }

    get isTowingChubb() {
        if (this.isAutomobile || this.motorcyclePolicy) {
            return true;
        }
        else {
            return false;
        }
        //  return this.customerData.Is_towing__c == "Yes" ? true : false;
    }

    get isTowingQualitas() {
        if (this.isAutomobile || this.motorcyclePolicy) {
            console.log('Towing Qualitas if');
            return true;
        }
        else {
            console.log('Towing Qualitas else');
            return false;
        }
        // return this.customerData.Is_towing__c == "Yes" ? true : false;
    }

    get mapfreRentalCar() {
        return this.coverageMap?.Mapfre?.Rental_Car__c == "Yes" ? true : false;
    }

    get mapfreLegalDefenseandBail() {
        return this.coverageMap?.Mapfre?.Legal_Defense_and_Bail__c == 'Yes' ? true : false;
    }

    get mapfreVandalism() {
        return this.coverageMap?.Mapfre?.Vandalism__c == 'Yes' ? true : false;
    }

    get mapfrePartialTheft() {
        return this.coverageMap?.Mapfre?.Partial_Theft__c == 'Yes' ? true : false;
    }

    get mapfrePlaneTicketsHome() {
        return this.coverageMap?.Mapfre?.Plane_Tickets_Home__c == 'Yes' ? true : false;
    }

    get isAutomobile() {
        return this.customerData.Policy_Type__c == 'Automobile';
    }

    get rvPolicy() {
        return this.customerData.Policy_Type__c == 'RV';
    }

    get motorcyclePolicy() {
        return this.customerData.Policy_Type__c == 'Motorcycle/Street Legal ATV';
    }

    get northBoundPolicy() {
        return this.customerData.Policy_Type__c == 'Northbound';
    }

    get liablityType() {
        return this.customerData?.Coverage__c != undefined && this.customerData?.Coverage__c == 'Liability' ? true : false;
    }

    get liabilityTheftCoverage() {
        return this.customerData?.Coverage__c != undefined && this.customerData?.Coverage__c == 'LiabilityTheft' ? true : false;
    }

    get maxCoverage() {
        return this.customerData?.Coverage__c != undefined && this.customerData?.Coverage__c == 'Max' ? true : false;
    }

    get fullAndCompleteCoverage() {
        return this.customerData?.Coverage__c != undefined && this.customerData?.Coverage__c == 'Complete' ? true : false;
    }


    get countryoptions() {
        if (this.customerData.Policy_Type__c == 'Northbound') {
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


    get stateOption() {
        if (this.customerData.Registered_Country__c == 'Mexico') {
            return this.mexicoStateList;
        }
        else if (this.customerData.Registered_Country__c == 'United States') {
            return this.unitedStatesList;
        }
        else if (this.customerData.Registered_Country__c == 'Canada') {
            return this.canadaStateList;
        }
    }

    get lienholderStateOption() {
        if (this.customerData.Lienholder_Country__c == 'Mexico') {
            return this.mexicoStateList;
        }
        else if (this.customerData.Lienholder_Country__c == 'United States') {
            return this.unitedStatesList;
        }
        else if (this.customerData.Lienholder_Country__c == 'Canada') {
            return this.canadaStateList;
        }
    }

    get CompanyStateOption() {
        if (this.customerData.Company_Country__c == 'Mexico') {
            return this.mexicoStateList;
        }
        else if (this.customerData.Company_Country__c == 'United States') {
            return this.unitedStatesList;
        }
        else if (this.customerData.Company_Country__c == 'Canada') {
            return this.canadaStateList;
        }
    }

    get paymentStateOption() {
        if (this.paymentDetails.Country__c == 'Mexico') {
            return this.mexicoStateList;
        }
        else if (this.paymentDetails.Country__c == 'United States') {
            return this.unitedStatesList;
        }
        else if (this.paymentDetails.Country__c == 'Canada') {
            return this.canadaStateList;
        }
    }

    // get vehicleStateOption() {
    //     console.log('this.newDriver---->>>',this.newDriver);
    //     if (this.newDriver.License_Country__cmbx == 'Mexico' ) {
    //         return this.mexicoStateList;
    //     }
    //     else if (this.newDriver.License_Country__cmbx == 'United States') {
    //         return this.unitedStatesList;
    //     }
    //     else if (this.newDriver.License_Country__cmbx == 'Canada') {
    //         return this.canadaStateList;
    //     }
    // }



    handleReset() {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.type === 'checkbox' || element.type === 'checkbox-button') {
                element.checked = false;
            } else {
                element.value = null;
            }
        });
    }

    handleContactType(event) {

        let currentUrl = window.location.origin;
        location.replace(`${currentUrl}/lightning/o/Contact/new?count=1&nooverride=1&useRecordTypeCheck=1&navigationLocation=LIST_VIEW&uid=171154053952787398&backgroundContext=%2Flightning%2Fo%2FContact%2Flist%3FfilterName%3DRecent&recordTypeId=012VA00000077rBYAQ`);


        // this.booleanVar.isContactType = true;
        // this.booleanVar.isportalAccessHide = false;
        // this.booleanVar.isTowingCheckbox = false;
        // this.booleanVar.showPolicyform = false;

        // this.booleanVar.isPolicyAutomobile = false;
        // this.booleanVar.isPolicyMotorcycle = false;
        // this.booleanVar.isPolicyRV = false;
        // this.booleanVar.isPolicyNorthbound = false;
        // this.booleanVar.isPolicyWatercraft = false;

        // this.contactype = event.target.value;

        // if(event.target.value == 'DMV Service'){
        //     this.booleanVar.isDMVService = true;
        //     this.booleanVar.isDomesticInsurance = false;
        // }else if(event.target.value == 'Domestic Insurance'){
        //     this.booleanVar.isDomesticInsurance = true;
        //     this.booleanVar.isDMVService = false;
        // }

    }

    handleContactChange(event) {
        let contactData = event.detail;
        if (contactData != null) {
            this.DMVDomesticContactId = contactData;
            this.isContactCreated = true;
        }
    }

    navigateToContact() {
        window.open(('/' + this.DMVDomesticContactId), '_blank');
    }

    handleInputChange = (event) => {
        if (event.target.name == 'End_Date_for_Coverage__c') {
            //Added this on 13 sep 
            const sdate = new Date(this.trackVar.endDate);
            const edate = new Date(event.target.value);
            if (sdate >= edate) {
                if (this.cmpSource == 'comm') {
                    this.showToastmethod('error', 'The Coverage End Date is earlier than the Start Date for Coverage.', 'Wrong date selected');

                } else {
                    this.showToastEvent('Wrong date selected', 'The Coverage End Date is earlier than the Start Date for Coverage.', 'error');
                }
            }
        }
        console.log('Customer data 1', JSON.stringify(this.customerData));
        this.customerData = { ...this.customerData, [event.target?.name]: event.target?.value };
        this.trackVar = { ...this.trackVar, [event.target?.name]: event.target?.value };
        console.log('Event name', JSON.stringify(event.target?.name));
        console.log('Track var data in Input Change', JSON.stringify(this.trackVar));
        if (event.target?.name === 'FirstName') {
            this.newDriver = { ...this.newDriver, ['First_Name__c']: event.target?.value };
        }
        if (event.target?.name === 'LastName') {
            this.newDriver = { ...this.newDriver, ['Last_Name__c']: event.target?.value };
        }

        if (event.target?.name == 'Policy_Type__c') {
            console.log('this.contactId-->', this.contactId);
            this.getDriverData(this.contactId);
            this.getVehiclesOptions(this.contactId);
            this.trackVar = { ...this.trackVar, ['Vehicle_sub_type__c']: '' };
            console.log('this.booleanVar.checkPortalAcccess : ', this.booleanVar.checkPortalAcccess);
            if (this.booleanVar.checkPortalAcccess == true) {
                this.booleanVar.isportalAccessHide = false;
                this.booleanVar.portalAccessYes = false;
                this.booleanVar.portalAccessNo = true;
            }
            console.log('this.booleanVar.isUserDeactivated', this.booleanVar.isUserDeactivated);
            if (this.booleanVar.isUserDeactivated == true) {
                console.log('Inside USSER  TESTT!!!');
                this.booleanVar.showPolicyform = false;
            } else {
                this.booleanVar.showPolicyform = true;
            }

            console.log('this.booleanVar.isportalAccessHide222 : ', this.booleanVar.isportalAccessHide);
            if (event.target.value == 'Automobile' || event.target.value === 'Automobile-Van-Minivan') {
                this.booleanVar.isNorthbound = false;
                this.booleanVar.isPolicyAutomobile = true;
                this.booleanVar.isPolicyMotorcycle = false;
                this.booleanVar.isPolicyRV = false;
                this.booleanVar.isPolicyNorthbound = false;
                this.booleanVar.isPolicyWatercraft = false;
                this.booleanVar.isDMVService = false;
                this.booleanVar.isDomesticInsurance = false;
                this.booleanVar.isContactType = false;

                this.customerData = { ...this.customerData, ['Coverage__c']: "Max" };
            } else if (event.target.value == 'Motorcycle/Street Legal ATV' || event.target.value === 'Motorcycle') {
                this.booleanVar.isNorthbound = false;
                this.booleanVar.isPolicyAutomobile = false;
                this.booleanVar.isPolicyMotorcycle = true;
                this.booleanVar.isPolicyRV = false;
                this.booleanVar.isPolicyNorthbound = false;
                this.booleanVar.isPolicyWatercraft = false;
                this.booleanVar.isDMVService = false;
                this.booleanVar.isDomesticInsurance = false;
                this.booleanVar.isContactType = false;

                this.customerData = { ...this.customerData, ['Coverage__c']: "Complete" };
            } else if (event.target.value == 'Motorhome') {
                this.booleanVar.isNorthbound = false;
                this.booleanVar.isPolicyAutomobile = false;
                this.booleanVar.isPolicyMotorcycle = false;
                this.booleanVar.isPolicyRV = true;
                this.booleanVar.isPolicyNorthbound = false;
                this.booleanVar.isPolicyWatercraft = false;
                this.booleanVar.isDMVService = false;
                this.booleanVar.isDomesticInsurance = false;
                this.booleanVar.isContactType = false;
                this.customerData = { ...this.customerData, ['Coverage__c']: "Complete" };
                this.trackVar = { ...this.trackVar, ['Vehicle_sub_type__c']: 'Motorhome' };
                this.customerData = { ...this.customerData, ['Vehicle_sub_type__c']: "Motorhome" };
            } else if (event.target.value == 'Northbound') {
                this.booleanVar.isNorthbound = true;
                this.booleanVar.isPolicyAutomobile = false;
                this.booleanVar.isPolicyMotorcycle = false;
                this.booleanVar.isPolicyRV = false;
                this.booleanVar.isPolicyNorthbound = true;
                this.booleanVar.isPolicyWatercraft = false;
                this.booleanVar.isDMVService = false;
                this.booleanVar.isDomesticInsurance = false;
                this.booleanVar.isContactType = false;
            } else {
                this.booleanVar.isNorthbound = false;
                this.booleanVar.isPolicyAutomobile = false;
                this.booleanVar.isPolicyMotorcycle = false;
                this.booleanVar.isPolicyRV = false;
                this.booleanVar.isPolicyNorthbound = false;
                this.booleanVar.isPolicyWatercraft = true;
                this.booleanVar.isDMVService = false;
                this.booleanVar.isDomesticInsurance = false;
                this.booleanVar.isContactType = false;
            }


            this.activeSectionName = 'getAQuote';
            let openAccordion = this.template.querySelector('.agentDashboard');
            openAccordion.activeSectionName = this.activeSectionName;
            //this.booleanVar.showPolicyform = true;
            if (event.target.value == 'Northbound') {
                this.fetchPicklist('Quote__c', 'Vehicle_Type__c');
            } else {
                this.getDependentPicklistValues('Quote__c', 'Vehicle_Type__c', 'Vehicle_Sub_type__c');
            }

            this.policyType = event.target.value;
            if (event.target?.value == 'Automobile-Van-Minivan' || event.target?.value == 'Motorhome') {
                this.booleanVar.isTowingCheckbox = true;
            } else {
                this.booleanVar.isTowingCheckbox = false;
                this.booleanVar.isTowing = false;
            }
            this.customerData = { ...this.customerData, ['Is_towing__c']: this.trackVar.Is_towing__c == true ? 'Yes' : 'No' };
            const combobox = this.template.querySelector('[data-id="vehicleTypeCombobox"]');

            if (combobox != null) {

                combobox.value = null;

            }
        }

        if(event.target?.name == 'Vehicle_sub_type__c'){
            this.policyType = event.target?.value;
            this.customerData = { ...this.customerData, ['Policy_Type__c']: event.target?.value };
            this.customerData = { ...this.customerData, ['Vehicle_sub_type__c']: event.target?.value };
            this.customerData = { ...this.customerData, ['Vehicle_Type__c']: event.target?.value };

            this.trackVar = { ...this.trackVar, ['Policy_Type__c']: event.target?.value };
            this.trackVar = { ...this.trackVar, ['Vehicle_sub_type__c']: event.target?.value };
            this.trackVar = { ...this.trackVar, ['Vehicle_Type__c']: event.target?.value };
        }



        if (event.target?.name == 'Is_towing__c') {
            if (event.target.checked) {
                this.customerData = { ...this.customerData, ['Is_towing__c']: "Yes" };
                this.booleanVar.isTowingChecked = true;
                this.trackVar.Is_towing__c = true;
                this.booleanVar.isTowing = true;
            } else {
                this.customerData = { ...this.customerData, ['Is_towing__c']: "No" };
                this.booleanVar.isTowingChecked = false;
                this.booleanVar.isTowing = false;
            }
        }

        if (event.target?.name === 'Electric_Hybrid__c') {
            this.customerData = { ...this.customerData,  Electric_Hybrid__c: event.target.checked };
            this.trackVar = { ...this.trackVar, Electric_Hybrid__c: event.target.checked };
        }

        if (this.customerData.Policy_Type__c == 'Northbound') {
            if (event.target.name === 'Vehicle_sub_type__c' && event.target.value === 'Car/Truck/Auto') {
                this.booleanVar.isTowingCheckbox = true;
            } else {
                this.booleanVar.isTowingCheckbox = false;
            }
        }

        if (event.target.name == 'Coverage__c') {
            if (event.target.checked == true) {
                this.trackVar.Coverage__c = true;
                this.customerData = { ...this.customerData, ['Coverage__c']: "Liability" };
            } else {
                this.trackVar.Coverage__c = false;
                this.customerData = { ...this.customerData, ['Coverage__c']: "Complete" };
            }
        }

        if (event.target.name == 'Is_this_a_Rental_Vehicle__c') {
            this.customerData = { ...this.customerData, ['Is_this_a_Rental_Vehicle__c']: event.target?.value };
        }

        if (event.target.name == 'Is_the_vehicle_used_for_business_purpose__c') {
            this.customerData = { ...this.customerData, ['Is_the_vehicle_used_for_business_purpose__c']: event.target?.value };
        }

        if (event.target.name == 'Salvage_Vehicle__c') {
            this.customerData = { ...this.customerData, ['Salvage_Vehicle__c']: event.target?.value };
        }

        if (event.target.name == 'Is_there_a_driver_under_21__c') {
            this.customerData = { ...this.customerData, ['Is_there_a_driver_under_21__c']: event.target?.value };
        }

        if (event.target.name == 'territory') {
            this.customerData = { ...this.customerData, ['territory']: event.target?.value };
            if (event.target.value == 'Baja/Sonora') {
                this.booleanVar.isBaja = true;
            } else if (event.target.value == 'Limited') {
                this.booleanVar.isLimited = true;
            } else {
                this.booleanVar.isTerritory = true;
            }
        }

        if (event.target.name == 'Start_Date_for_Coverage__c') {
            this.onGroup('Term__c', this.customerData.Term__c);
        }


        if (event.target.name == 'Start_Time__c') {
            this.customerData = { ...this.customerData, ['Start_Time__c']: event.target.value };
            this.customerData = { ...this.customerData, ['End_Time__c']: event.target.value };
            this.trackVar.startTime = this.customerData.Start_Time__c;
            this.trackVar.endTime = this.customerData.End_Time__c;
        }

        if (event.target.name == 'Term__c') {
            this.customerData = { ...this.customerData, ['Term__c']: event.target.value };
            if (event.target.value == 'Annual(One Year)' || event.target.value == 'Annual') {
                this.onGroup(event.target.name, event.target.value);
                this.booleanVar.isAnnual = true;
                this.booleanVar.isEndDateDisabled = true;
                this.customerData = { ...this.customerData, ['Start_Time__c']: '00:00:00' };
                this.customerData = { ...this.customerData, ['End_Time__c']: '00:00:00' };
                this.trackVar.startTime = '00:00:00';
                this.trackVar.endTime = '00:00:00';
            } else if (event.target.value == 'Semi-Annual') {
                this.onGroup(event.target.name, event.target.value);
                this.booleanVar.isSemiAnnual = true;
                this.booleanVar.isEndDateDisabled = true;
                this.customerData = { ...this.customerData, ['Start_Time__c']: '00:00:00' };
                this.customerData = { ...this.customerData, ['End_Time__c']: '00:00:00' };
                this.trackVar.startTime = '00:00:00';
                this.trackVar.endTime = '00:00:00';
            } else {
                this.onGroup(event.target.name, event.target.value);
                this.booleanVar.isDaily = true;
                this.booleanVar.isEndDateDisabled = false;
            }
        }

        if (event.target.name == 'Coverage__c') {
            if (event.target.checked == true) {
                this.customerData = { ...this.customerData, ['Coverage__c']: "Liability" };
            } else {
                this.customerData = { ...this.customerData, ['Coverage__c']: "Complete" };
            }
        }



        if (event.target?.name == 'Lienholder_Country__cmbx') {
            this.customerData = { ...this.customerData, ['Lienholder_Country__c']: event.target.value };
            if (event.target.value == 'Other') {
                this.otherCountrylienholder = true;
            } else {
                this.otherCountrylienholder = false;
            }
        }

        if (event.target?.name == 'Company_Country__cmbx') {
            this.customerData = { ...this.customerData, ['Company_Country__c']: event.target.value };
            if (event.target.value == 'Other') {
                this.otherCountryCompany = true;
            } else {
                this.otherCountryCompany = false;
            }
        }

        if (event.target?.name == 'Registered_Country__cmbx') {
            this.customerData = { ...this.customerData, ['Registered_Country__c']: event.target.value };
            if (event.target.value == 'Other') {
                this.otherCountryRegister = true;
            } else {
                this.otherCountryRegister = false;
            }
        }

        if (event.target?.name == 'Is_Lienholder__c') {

            if (event.target.checked) {
                this.booleanVar.lienholderOption = true;
                this.booleanVar.isLienholderChecked = true;
                this.customerData = { ...this.customerData, ['Is_Lienholder__c']: true };
            } else {
                this.booleanVar.lienholderOption = false;
                this.booleanVar.isLienholderChecked = false;
                this.customerData = {
                    ...this.customerData,
                    ['Is_Lienholder__c']: false,
                    ['Lienholder_name__c']: "",
                    ['Lienholder_Country__c']: "",
                    ['Lienholder_Postal_Code__c']: "",
                    ['Lienholder_State__c']: "",
                    ['Lienholder_City__c']: "",
                    ['Lienholder_Street__c']: "",
                    ['Lienholder_Phone__c']: ""
                };
            }
        }

        if (event.target?.name == 'Is_vehicle_owned_by_a_company_or_rented__c') {

            if (event.target.checked) {
                this.booleanVar.companyAddressOption = true;
                this.booleanVar.isVehicleRentedChecked = true;
                this.booleanVar.registeredOwner = true;
                this.customerData = { ...this.customerData, ['Is_vehicle_owned_by_a_company_or_rented__c']: true };
            } else {
                this.booleanVar.companyAddressOption = false;
                this.booleanVar.registeredOwner = false;
                this.booleanVar.isVehicleRentedChecked = false;
                this.customerData = {
                    ...this.customerData,
                    ['Is_vehicle_owned_by_a_company_or_rented__c']: false,
                    ['Company_Name__c']: "",
                    ['Company_Country__c']: "",
                    ['Company_Zip__c']: "",
                    ['Company_State__c']: "",
                    ['Company_City__c']: "",
                    ['Company_Address__c']: "",
                    ['Company_Phone__c']: "",
                };
                this.trackVar.Company_Name__c = '';
                this.trackVar.Company_Address__c = '';
                this.trackVar.Company_City__c = '';
                this.trackVar.Company_Country__c = '';
                this.trackVar.Company_Phone__c = '';
                this.trackVar.Company_State__c = '';
                this.trackVar.Company_Zip__c = '';

            }
        }

        if (event.target.name == 'Make__c') {
            this.trackVar.Model__c = '';
            this.customerData = { ...this.customerData, ['Model__c']: "" };

            if (event.target.value == '<Manually Enter>') {
                this.booleanVar.showManualMake = true;
                this.booleanVar.isModelDisabled = true;
                this.booleanVar.showManualModel = true;
            } else {
                this.booleanVar.showManualModel = false;
                this.booleanVar.showManualMake = false;
                this.booleanVar.isModelDisabled = false;
            }

        }

        if (event.target.name == 'MannualMake') {
            this.customerData = { ...this.customerData, ['Make__c']: event.target.value };
            this.trackVar.MannualMake = this.customerData.MannualMake;

        }

        if (event.target.name == 'MannualModel') {
            this.customerData = { ...this.customerData, ['Model__c']: event.target.value };
            this.trackVar.MannualModel = this.customerData.MannualModel;
        }

        if (event.target.name == 'Model__c') {
            if (event.target.value == '<Manually Enter>') {
                this.booleanVar.showManualModel = true;
            } else {
                this.booleanVar.showManualModel = false;
            }

        }

        if (event.target.name == 'portalAccess') {
            if (event.target.value == 'Yes') {
                this.booleanVar.portalAccessYes = true;
                this.booleanVar.portalAccessNo = false;
            } else if (event.target.value == 'No') {
                this.booleanVar.portalAccessYes = false;
                this.booleanVar.portalAccessNo = true;
            }
        }

        if (event.target.name == 'Phone') {
            this.formatNumber(event.target.value, 'Phone');
        }

        if (event.target.name == 'Company_Phone__c') {
            this.formatNumber(event.target.value, 'Company_Phone__c');
        }

        if (event.target.name == 'Lienholder_Phone__c') {
            this.formatNumber(event.target.value, 'Lienholder_Phone__c');
        }

        this.termDateTime(event.target.name, event.target.value);

        if (event.target?.name == 'Year__c') {
            this.getVehicleMakes();
        }

        if (event.target?.name == 'Make__c') {
            this.getVehicleModels();
        }
    }

    handleTowedInputChange = (event) => {
        this.newTowed[event.target?.name] = event.target.value;
    }

    handleAddNewTowed = () => {

        this.booleanVar.isRequiredTowed = true;
        let status = this.isInputValid('.cTowed');
        console.log('---------->', status);
        console.log('this.booleanVar.isRequiredTowed----->', this.booleanVar.isRequiredTowed);
        if (status) {
            if (this.addedTowed && this.addedTowed.length > 0) {
                const firstTowed = this.addedTowed[0];
                if (firstTowed.Days_in_Tow__c !== this.newTowed.Days_in_Tow__c) {
                    this.isDaysInTowInvalid = true;
                    return;
                }
            }

            this.isDaysInTowInvalid = false;
            if (this.addedTowed != null) {
                this.addedTowed.map((towed) => {
                    if (towed.towedCount > this.towedCount) {
                        this.towedCount = towed.towedCount;
                    }
                });
            }

            this.newTowed.towedCount = this.towedCount + 1;
            this.newTowed.isDeleteTowedButton = true;
            this.addedTowed = [...this.addedTowed, this.newTowed];
            this.towedCount++;
            this.newTowed = {};

            // Create a separate method and pass the class to reset
            this.template.querySelectorAll(".cTowed").forEach((inputField) => {
                inputField.value = null;
            });
            this.booleanVar.isRequiredTowed = false;
        } else {
            this.booleanVar.isRequiredTowed = false;
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Please add the towed unit; otherwise, make the towing unchecked.', 'Add Towed unit');

            } else {
                this.showToastEvent('Add Towed unit', 'Please add the towed unit; otherwise, make the towing unchecked.', 'error');
            }

        }
    }

    handleEditTowed = (event) => {
        this.newTowed = {};
        this.addedTowed.map(towedUnit => {
            if (event.target.dataset?.id == towedUnit?.towedCount) {
                this.newTowed = { ...towedUnit };
                this.booleanVar.editTowedBtn = true;
                towedUnit.isDeleteTowedButton = false;
                towedUnit.selectedStyle = 'background:#feded8';
            } else {
                towedUnit.isDeleteTowedButton = true;
                towedUnit.selectedStyle = '';
            }
        })

    }

    handleDeleteTowned = (event) => {
        this.addedTowed = this.addedTowed.filter(towedUnit => {
            return towedUnit.towedCount != event.target.dataset.id
        })
    }

    handleUpdateTowed = () => {
        console.log('this.addedTowed-->' + this.addedTowed);
        if (this.addedTowed && this.addedTowed.length > 0) {
            const firstTowed = this.addedTowed[0];
            if (firstTowed.Days_in_Tow__c !== this.newTowed.Days_in_Tow__c) {
                this.isDaysInTowInvalid = true;
                return;
            }
        }
        this.booleanVar.editTowedBtn = false;
        this.isDaysInTowInvalid = false;

        for (let each of this.addedTowed) {
            if (each.towedCount == this.newTowed.towedCount) {
                each.Days_in_Tow__c = this.newTowed.Days_in_Tow__c;
                each.Towed_Unit_Type__c = this.newTowed.Towed_Unit_Type__c;
                each.Towed_Unit_Value__c = this.newTowed.Towed_Unit_Value__c;
                each.year__c = this.newTowed.year__c;
                each.Make__c = this.newTowed.Make__c;
                each.Model__c = this.newTowed.Model__c;
                each.Vin__c = this.newTowed.Vin__c;
                each.Registered_Plate__c = this.newTowed.Registered_Plate__c;
                each.towedCount = this.newTowed.towedCount;
                each.selectedStyle = '';
                each.isDeleteTowedButton = true
            }
        }
        this.newTowed = {};

        // Create a seprate method and pass the class to reset
        this.template.querySelectorAll('.cTowed').forEach(inputField => {
            inputField.value = null;
        });
    }

    fetchCoverageQuote = async () => {
        console.log('this.customerData.Policy_Type__c', this.customerData.Policy_Type__c);
        console.log('this.customerData.Coverage__c ' + this.customerData.Coverage__c);

        // by pass policy type
        // let mainCoverageMap = await getExactCoverageDetailForSouthbound({ 'pickList': this.customerData.Policy_Type__c, 'packageType': this.customerData.Coverage__c });

        let mainCoverageMap = await getExactCoverageDetailForSouthbound({ 'pickList': 'Automobile', 'packageType': this.customerData.Coverage__c }); console.log('mainCoverageMap', mainCoverageMap);
        if (mainCoverageMap != undefined && mainCoverageMap != null) {
            //this.quickQuoteDetail = { ...this.quickQuoteDetail, ['Coverage']: mainCoverageMap }
            mainCoverageMap.Qualitas.map((data) => {
                if (data.Package__c == "Liability" && this.customerData.Coverage__c == 'Liability') {
                    if ((this.customerData.territory == 'Baja Sonora' || this.customerData.territory == 'Baja/Sonora' || this.customerData.territory == 'Limited' || this.customerData.territory == 'Full')
                        && data.Territory_Discount__c == 'Yes') {
                        this.coverageMap = { ...this.coverageMap, ['Qualitas']: data };
                    } else {
                        this.coverageMap = { ...this.coverageMap, ['Qualitas']: data };
                    }
                } else if (this.customerData.Coverage__c != 'Liability') {
                    this.coverageMap = { ...this.coverageMap, ['Qualitas']: data };
                }
                console.log('coveragemAp--->>>>>>>>', this.coverageMap);
            })

            if (mainCoverageMap.Chubb != undefined) {
                mainCoverageMap.Chubb.map((data) => {
                    if (data.Package__c == "Liability" && this.customerData.Coverage__c == 'Liability') {
                        this.coverageMap = { ...this.coverageMap, ['Chubb']: data };
                    } else if (this.customerData.Coverage__c != 'Liability') {
                        this.coverageMap = { ...this.coverageMap, ['Chubb']: data };
                    }
                });
            }


            console.log('mainCoverageMap MAPFRE-->', mainCoverageMap.Mapfre);
            if (mainCoverageMap.Mapfre != undefined) {
                mainCoverageMap.Mapfre.forEach(currentItem => {
                    if (this.customerData.Coverage__c == 'Liability' && currentItem.Package__c == 'Liability') {
                        this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                    } else if (this.customerData.Coverage__c == 'Max' && currentItem.Package__c == 'Max') {
                        this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                    } else if (this.customerData.Coverage__c == 'Complete' && currentItem.Package__c == 'Complete') {
                        this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                    } else if (this.customerData.Coverage__c == 'Full' && currentItem.Package__c == 'Full') {
                        this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                    } else if (this.customerData.Coverage__c == 'LiabilityTheft' && currentItem.Package__c == 'LiabilityTheft') {
                        this.coverageMap = { ...this.coverageMap, ['Mapfre']: currentItem };

                    }
                });
            }

        }
        console.log('retrieved final json-> ' + JSON.stringify(this.coverageMap));
    }

    fetchNorthBoundCoverageQuote = async () => {
        try {
            const resp = await getNorthboundCoverage();

            console.log(JSON.stringify(resp, null, 4));

            if (resp.length) {
                this.coverageMap = { ...resp[0] };
            }
            console.log('this.coverageMap', this.coverageMap);
        } catch (error) {
            console.log('Error :::: ', error);
        }
    }

    // Apex JSON Methods.....
    fetchLeadData() {
        let data = {
            'FirstName': this.customerData?.FirstName,
            'LastName': this.customerData?.LastName,
            'Email': this.customerData?.Email,
            'Phone': this.customerData?.Phone,
            'Policy_Type__c': this.customerData?.Policy_Type__c,
            'Vehicle_Type__c': this.customerData?.Policy_Type__c,
            'Vehicle_sub_type__c' : this.customerData?.Policy_Type__c,
            'Liability__c': this.customerData?.Coverage__c == 'Complete' ? false : true,
            'Is_towing__c': this.customerData?.Is_towing__c == 'Yes' ? true : false,
        };

        if (this.booleanVar.isNorthbound === true) {
            data['Liability__c'] = true;
        }

        if (this.customerData?.Id !== null && this.customerData?.Id !== undefined) {
            data['Id'] = this.customerData?.Id;
        } else if (this.leadId != null || this.leadId != '') {
            data['Id'] = this.leadId;
        }

        return data;
    }

    fetchQuoteData() {
        console.log('Inside fetched quote data');
        let data = {
            'Start_Date_for_Coverage__c': this.customerData?.Start_Date_for_Coverage__c,
            'End_Time__c': this.customerData?.End_Time__c,
            'Start_Time__c': this.customerData?.Start_Time__c,
            'End_Date_for_Coverage__c': this.customerData?.End_Date_for_Coverage__c,
            'Vehicle_used_for_Business_Purposes__c': this.customerData?.Is_the_vehicle_used_for_business_purpose__c == 'Yes' ? true : false,
            'Is_there_a_driver_under_21__c': this.customerData?.Is_there_a_driver_under_21__c,
            'Is_this_a_Rental_Vehicle__c': this.customerData?.Is_this_a_Rental_Vehicle__c == 'Yes' ? true : false,
            'Vehicle_Make__c': this.customerData?.Make__c,
            'Vehicle_Model__c': this.customerData?.Model__c,
            'Salvage_Vehicle__c': this.customerData?.Salvage_Vehicle__c,
            'Vehicle_Value__c': this.customerData?.Value__c,
            'Vehicle_Type__c': this.customerData?.Policy_Type__c == 'Automobile' ? 'Car/Truck/Auto' : this.customerData?.Policy_Type__c,
            'Vehicle_Year__c': this.customerData?.Year__c,
            'Policy_Type_picklist__c': this.customerData?.Policy_Type__c,
            'Term__c': this.customerData?.Term__c,
            'Territory__c': this.customerData?.territory,
        }

        if (this.booleanVar.isNorthbound === true) {
            data['Territory__c'] = 'Northbound';
        }

        if (this.booleanVar.isNorthbound === false) {
            data['Vehicle_sub_type__c'] = this.customerData?.Vehicle_sub_type__c;
        }
        console.log('Output customerData', JSON.stringify(this.customerData));        
        console.log('Exist quote deta', JSON.stringify(this.existQuoteDetails));
        if (this.customerData?.QuoteId !== null && this.customerData?.QuoteId !== undefined) {
            data['Id'] = this.customerData?.QuoteId;
            if (this.existQuoteDetails !== undefined) {
                data['Old_Net_Premium__c'] = this.existQuoteDetails?.Old_Net_Premium__c;
                data['Agent_Fee__c'] = this.existQuoteDetails.Agent_Fee__c;
            }
        }
        console.log('Inside return fetched quote data' + JSON.stringify(data));
        return data;
    }

    fetchVehicleData() {
        console.log('Inside vehicle data');
        let data = {
            'Vehicle_sub_type__c': this.customerData?.Vehicle_sub_type__c,
            'Year__c': this.customerData?.Year__c,
            'Make__c': this.customerData?.Make__c,
            'Model__c': this.customerData?.Model__c,
            'Value__c': this.customerData?.Value__c,
            'Coverage__c': this.customerData?.Coverage__c,
            'Electric_Hybrid__c': this.customerData?.Electric_Hybrid__c != null
                ? this.customerData.Electric_Hybrid__c
                : false,
            'Salvage_Vehicle__c': this.customerData?.Salvage_Vehicle__c == 'Yes' ? true : false,
            'Is_the_vehicle_used_for_business_purpose__c': this.customerData?.Is_the_vehicle_used_for_business_purpose__c == 'Yes' ? true : false,
            'Is_there_a_driver_under_21__c': this.customerData?.Is_there_a_driver_under_21__c == 'Yes' ? true : false,
            'Is_this_a_Rental_Vehicle__c': this.customerData?.Is_this_a_Rental_Vehicle__c == 'Yes' ? true : false,
            'Vehicle_Type__c': this.customerData?.Policy_Type__c == 'Automobile' ? 'Car/Truck/Auto' : this.customerData?.Policy_Type__c,
            "Lienholder_name__c": this.customerData?.Lienholder_name__c ? this.customerData.Lienholder_name__c : '',
            "Lienholder_Country__c": this.customerData?.Lienholder_Country__c ? this.customerData.Lienholder_Country__c : '',
            "Lienholder_Postal_Code__c": this.customerData?.Lienholder_Postal_Code__c ? this.customerData.Lienholder_Postal_Code__c : '',
            "Lienholder_State__c": this.customerData?.Lienholder_State__c ? this.customerData.Lienholder_State__c : '',
            "Vin__c": this.customerData?.Vin__c,
            "Registered_Country__c": this.customerData?.Registered_Country__c,
            "Registered_State__c": this.customerData?.Registered_State__c,
            "Registered_Plate__c": this.customerData?.Registered_Plate__c,
            "Lienholder_City__c": this.customerData?.Lienholder_City__c ? this.customerData.Lienholder_City__c : '',
            "Lienholder_Street__c": this.customerData?.Lienholder_Street__c ? this.customerData.Lienholder_Street__c : '',
            "Lienholder_Phone__c": this.customerData?.Lienholder_Phone__c ? this.customerData.Lienholder_Phone__c : '',
            "Is_Lienholder__c": this.booleanVar.isLienholderChecked,
            "Is_vehicle_owned_by_a_company_or_rented__c": this.booleanVar.isVehicleRentedChecked,
            "Company_Name__c": this.customerData?.Company_Name__c ? this.customerData.Company_Name__c : '',
            "Company_Country__c": this.customerData?.Company_Country__c ? this.customerData.Company_Country__c : '',
            "Company_Zip__c": this.customerData?.Company_Zip__c ? this.customerData.Company_Zip__c : '',
            "Company_State__c": this.customerData?.Company_State__c ? this.customerData.Company_State__c : '',
            "Company_City__c": this.customerData?.Company_City__c ? this.customerData.Company_City__c : '',
            "Company_Address__c": this.customerData?.Company_Address__c ? this.customerData.Company_Address__c : '',
            "Company_Phone__c": this.customerData?.Company_Phone__c ? this.customerData.Company_Phone__c : '',
            "Dob__c": this.customerData?.Dob__c ? this.customerData.Dob__c : '',
        }

        if (this.customerData?.vehicleId != null) {
            data = { ...data, "Id": this.customerData.vehicleId };
        }

        console.log('Inside return vehicle data');


        return data;
    }

    fetchDriverData() {
        console.log('Fetched driver data');
        this.addedDriver = this.addedDriver.map(driver => ({
            ...driver, Email__c: this.customerData?.Email
        }));

        this.addedDriver = this.addedDriver.map(function (item) {
            delete item.owner
            return item;
        });
        console.log('Fetched driver data return');
        return this.addedDriver;
    }

    fetchTermAndAlert() {
        return {
            'Terms_of_Cancellation_Confirmed__c': 'true',
            'Terms_of_Purchase_Confirmed__c': 'true',
        }
    }

    fetchTermOptions() {
        return {
            'Term__c': this.customerData?.Term__c,
            'Start_Date_for_Coverage__c': this.customerData?.Start_Date_for_Coverage__c,
            'End_Date_for_Coverage__c': this.customerData?.End_Date_for_Coverage__c,
            'Start_Time__c': this.customerData?.Start_Time__c,
            'End_Time__c': this.customerData?.End_Time__c,
        }
    }

    searchandUpdateStateOptions(stateValue, countryValue) {
        let isOptionFound = false;
        if (countryValue.toLowerCase() == 'mexico') {
            for (let each of this.mexicoStateList) {
                if (each.value.toLowerCase() == stateValue.toLowerCase()) {
                    isOptionFound = true;
                    break;
                }
            }
            if (isOptionFound == false) {
                this.mexicoStateList.push({
                    'value': stateValue,
                    'label': stateValue
                });
            }
        }
        else if (countryValue.toLowerCase() == 'united states') {
            for (let each of this.unitedStatesList) {
                if (each.value.toLowerCase() == stateValue.toLowerCase()) {
                    isOptionFound = true;
                    break;
                }
            }
            if (isOptionFound == false) {
                this.unitedStatesList.push({
                    'value': stateValue,
                    'label': stateValue
                });
            }
        }
        else if (countryValue.toLowerCase() == 'canada') {
            for (let each of this.canadaStateList) {
                if (each.value.toLowerCase() == stateValue.toLowerCase()) {
                    isOptionFound = true;
                    break;
                }
            }
            if (isOptionFound == false) {
                this.canadaStateList.push({
                    'value': stateValue,
                    'label': stateValue
                });
            }
        }
    }

    //Apex invocations
    async saveLeadDetailsintoApex(leadJSON, quoteJSON, vechileJSON, towedJSON) {
        console.log('leadJSON', leadJSON);
        console.log('quoteJSON', quoteJSON);
        console.log('vechileJSON', vechileJSON);
        console.log('towedJSON', towedJSON);
        
        try {
            const result = await saveLeadDetails({ 
                'leadJson': leadJSON, 
                'quoteJSON': quoteJSON, 
                'vehicleJSON': vechileJSON, 
                'towedlistJSON': towedJSON 
            });
            
            if (result) {
                console.log('Lead has been saved');
                const data = JSON.parse(result);
                console.log('data', data);
                this.leadId = data.Id;
                console.log('Lead ID ', this.leadId);
                return 'success'; // Return the parsed data
            }
            return null; // In case result is falsy
        } catch (error) {
            console.log('Error in saving quote--->', error.message);
            throw error; // Re-throw the error to be caught by the caller
        }
    }

    // Validations methods...
    validateBeforeQuoteGenerationDrivers() {
        let countOwner = 0;
        for (let eachDriver of this.addedDriver) {
            if (eachDriver.Driver_Type__c == 'Owner & Driver' || eachDriver.Driver_Type__c == 'Owner' || eachDriver.Driver_Type__c == true || eachDriver.Driver_Type__c == 'true') {
                console.log('Reached in driver count');
                countOwner++;
            }
            console.log('Count owner', countOwner);
        }

        if (countOwner == 0 && this.booleanVar.isVehicleRentedChecked == false) {
            this.showToastEvent('Driver details are not correct!', 'Please check if your insurance has at least 1 owner.', 'error');
            return false;
        } else if (countOwner > 1 && this.booleanVar.isVehicleRentedChecked == false) {
            this.showToastEvent('Driver details are not correct!', 'Your insurance quote cannot have more than 1 owner.', 'error');
            return false;
        } else if (countOwner == 1 && this.booleanVar.isVehicleRentedChecked == false) {
            return true;
        } else if (this.booleanVar.isVehicleRentedChecked == true && countOwner > 0) {
            this.showToastEvent('Driver details are not correct!', 'Your vehicle is company owned, you cannot add owner to this insurance.', 'error');
            return false;
        }
        else if (this.booleanVar.isVehicleRentedChecked == true && countOwner == 0) {
            return true;
        }
        else {
            this.showToastEvent('Driver details are not correct!', 'Something wrong with the drivers, please contact administrator.', 'error');
            return false;
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

    formatNumber(phone, name) {
        let cleaned = ('' + phone).replace(/\D/g, '');
        let match = cleaned.match(/^(\d{3})(\d{3})(\d{4,7})$/);
        if (match) {
            if (name == 'Phone') {
                this.trackVar.Phone = '(' + match[1] + ') ' + match[2] + '-' + match[3];
            }

            if (name == 'Phone__c') {
                this.newDriver.Phone__c = '(' + match[1] + ') ' + match[2] + '-' + match[3];
            }

            if (name == 'Company_Phone__c') {
                this.trackVar.Company_Phone__c = '(' + match[1] + ') ' + match[2] + '-' + match[3];
            }

            if (name == 'Lienholder_Phone__c') {
                this.trackVar.Lienholder_Phone__c = '(' + match[1] + ') ' + match[2] + '-' + match[3];
            }

        }
    }

    isInputValid(className) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(className);
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        console.log('In invalid check---->', JSON.stringify(this.trackVar));
        console.log('Is valid', JSON.stringify(isValid));
        return isValid;
    }

    showToastEvent(label, message, variant) {
        const errMsg = new ShowToastEvent({
            title: label,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(errMsg);
    }


    getDriverData(contactId) {
        if (contactId) {
            console.log('fetched driver');
            console.log(contactId);
            getDriverDataFromContact({ 'contactId': contactId }).then((data) => {
                console.log(data);
                let drivers = JSON.parse(data);
                this.driversData = JSON.parse(data);
                let contactDrivers = [{ 'value': '', 'label': '--None--' }];
                drivers.map((item) => {
                    let label = item.Name + ' - ' + item.Dob__c + ' - ' + item.license_number__c;
                    contactDrivers.push({ 'value': item.license_number__c, 'label': label });
                });

                this.driversOptions = contactDrivers;
                console.log('driversOptions----', this.driversOptions);

            })
        } else {
            console.log('contactId is null');
        }
    }

    getVehiclesOptions(vehicleId) {
        if (vehicleId) {
            console.log('fetched vehicle Id--->', vehicleId);
            console.log('Customer data in the vehicle get section--->', this.customerData);
            let dropdownOptions = [];
            // if (this.customerData.Policy_Type__c == 'Automobile') {
            //     dropdownOptions = [
            //         { label: 'Automobile/Sedan', value: 'Automobile/Sedan' },
            //         { label: 'Pickup Truck w or w/o Camper Shell', value: 'Car/Truck/Auto' },
            //         { label: 'Van', value: 'Van' },
            //         { label: 'SUV', value: 'SUV' }
            //     ];
            // } else if (this.customerData.Policy_Type__c == 'Motorcycle/Street Legal ATV') {
            //     dropdownOptions = [
            //         { label: 'Motorcycle', value: 'Motorcycle' },
            //         { label: 'Street Legal ATV', value: 'Street Legal ATV' },
            //         { label: 'Motorcycle/Street Legal ATV', value: 'Motorcycle/Street Legal ATV' }
            //     ];
            // } else if (this.customerData.Policy_Type__c == 'RV') {
            //     dropdownOptions = [
            //         { label: 'Motor Home / RV', value: 'Motor Home / RV' },
            //         { label: 'Motor Home / RV', value: 'RV' }
            //     ];
            // } else if (this.customerData.Policy_Type__c == 'Northbound') {
            //     dropdownOptions = [
            //         { label: 'Car/Truck/Auto', value: 'Car/Truck/Auto' },
            //         { label: 'Motorcycle/Street Legal ATV', value: 'Motorcycle/Street Legal ATV' }
            //     ];
            // }

            console.log('dropdownOptions', dropdownOptions);
            console.log('GetVehicledata is executing-->', vehicleId);
            getVehicleData({ 'vehicleId': vehicleId }).then((data) => {
                console.log('Vehicle data from apex--->', JSON.parse(data));
                let vehicles = JSON.parse(data);
                this.vehiclesData = JSON.parse(data);
                let contactVehicles = [{ 'value': '', 'label': '--None--' }];

                vehicles.map((item) => {
                    // let valueExists = dropdownOptions.some(option =>
                    //     option.label == item.Vehicle_Type__c || option.value == item.Vehicle_Type__c
                    // );
                    console.log('item.Vehicle_Type__c.toLowerCase()', item.Vehicle_Type__c);
                    // if (valueExists) {
                        let label = item.Make__c + ' ' + item.Model__c + ' ' + item.Year__c + ' - ' + (item.Vin__c != undefined ? item.Vin__c : '') + '';
                        contactVehicles.push({ 'value': item.Id, 'label': label });
                    // }

                });

                this.vehiclesOptions = contactVehicles;
                console.log('contactVehicles----', this.vehiclesOptions);

            })
        } else {
            console.log('vehicleId is null');
        }
    }

    changeDriverOption = async (event) => {
        let DriverId = event.target.value;
        console.log('---DriverId--', DriverId);

        this.newDriver = {};
        this.countOwner = 0;
        this.countDriver = 0;
        this.driversData.map((driver, index) => {
            console.log('Inside handleEditDriver Added Driver Map ', driver);
            if (driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == true || driver.Driver_Type__c == 'true') {
                this.countOwner++;
            } else {
                this.countDriver++;
            }

            if (DriverId === driver?.license_number__c) {
                this.booleanVar.registeredOwner = false;

                if (driver.Driver_Type__c == 'Owner & Driver' || driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == true || driver.Driver_Type__c == 'true') {
                    this.booleanVar.registeredOwner = false;
                    this.booleanVar.isOwner = true;
                    driver.owner = true;
                } else {
                    this.booleanVar.isOwner = false;
                    this.booleanVar.registeredOwner = true;
                }

                if (driver.License_Country__c == 'United States' || driver.License_Country__c == 'Canada' || driver.License_Country__c == 'Mexico' || driver.License_Country__c == 'Other') {
                    driver.otherCountryVehicle = false;
                    driver = { ...driver, ['License_Country__cmbx']: driver.License_Country__c };
                } else {
                    driver = { ...driver, ['License_Country__cmbx']: 'Other' };
                    driver.otherCountryVehicle = true;
                }

                if (driver.Country__c == 'United States' || driver.Country__c == 'Canada' || driver.Country__c == 'Mexico' || driver.Country__c == 'Other') {
                    driver.otherCountryDriver = false;
                    driver = { ...driver, ['Country__cmbx']: driver.Country__c };
                } else {
                    driver = { ...driver, ['Country__cmbx']: 'Other' };
                    driver.otherCountryDriver = true;
                }


                if (driver.License_Country__cmbx == 'Mexico') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                }
                else if (driver.License_Country__cmbx == 'United States') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                }
                else if (driver.License_Country__cmbx == 'Canada') {
                    this.vehicleStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }

                if (driver.Country__c == 'Mexico') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.mexicoStateList));
                }
                else if (driver.Country__c == 'United States') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.unitedStatesList));
                }
                else if (driver.Country__c == 'Canada') {
                    this.driverStateOption = JSON.parse(JSON.stringify(this.canadaStateList));
                }

                driver.showDeleteButton = false;
                this.newDriver = { ...driver };
                console.log('Selected Driver : ',this.newDriver);
                this.selectedDriverLicense = DriverId;
            }
        })

        if (this.countOwner == 0 && this.countDriver > 0) {
            this.booleanVar.registeredOwner = false;
        }
        this.booleanVar.editDriverBtn = false;

        console.log('this.newDriver---', this.newDriver);
    }

    changeVehiclesOption(event) {
        let vehicleId = event.target.value;
        console.log('---vehicleId--', vehicleId);

        this.vehiclesData.map((item) => {
            console.log('item', item);
            if (item) {
                if (item.Id == vehicleId) {
                    this.trackVar.Vehicle_sub_type__c = item.Vehicle_Type__c ? (item.Vehicle_Type__c == 'Car/Truck/Auto' ? 'Pickup Truck w or w/o Camper Shell' : item.Vehicle_Type__c) : '';
                    this.trackVar.Vin__c = item.Vin__c ? item.Vin__c : '';
                    this.trackVar.Year__c = item.Year__c ? item.Year__c : '';
                    this.trackVar.Value__c = item.Value__c ? item.Value__c : '';
                    this.trackVar.Registered_Plate__c = item?.Registered_Plate__c ? item.Registered_Plate__c : '';
                    this.trackVar.Salvage_Vehicle__c = item.Salvage_Vehicle__c == true ? 'Yes' : 'No';
                    this.trackVar.Is_the_vehicle_used_for_business_purpose__c = item.Is_the_vehicle_used_for_business_purpose__c == true ? 'Yes' : 'No';
                    this.trackVar.Is_this_a_Rental_Vehicle__c = item.Is_this_a_Rental_Vehicle__c == true ? 'Yes' : 'No';
                    this.trackVar.Is_there_a_driver_under_21__c = item.Is_there_a_driver_under_21__c == true ? 'Yes' : 'No';
                    this.trackVar.Registered_Country__c = item?.Registered_Country__c ? item.Registered_Country__c : '';
                    this.trackVar.Registered_State__c = item?.Registered_State__c ? item.Registered_State__c : '';
                    if (this.trackVar.Registered_Country__c == 'Other') {
                        this.otherCountryRegister = true;
                    } else {
                        this.otherCountryRegister = false;
                    }
                    if (item.Vehicle_Type__c === 'RV') {
                        this.trackVar.Vehicle_sub_type__c = 'Motor Home / RV';
                        console.log('Inside item value', JSON.stringify(this.trackVar));
                    }
                    this.customerData = { ...this.customerData, ['Registered_Country__c']: this.trackVar.Registered_Country__c };
                    this.customerData = { ...this.customerData, ['Registered_State__c']: this.trackVar.Registered_State__c };
                    this.customerData = { ...this.customerData, ['Vehicle_sub_type__c']: this.trackVar.Vehicle_sub_type__c };
                    this.customerData = { ...this.customerData, ['Vin__c']: this.trackVar.Vin__c };
                    this.customerData = { ...this.customerData, ['Year__c']: this.trackVar.Year__c };
                    this.customerData = { ...this.customerData, ['Value__c']: this.trackVar.Value__c };
                    this.customerData = { ...this.customerData, ['Salvage_Vehicle__c']: this.trackVar.Salvage_Vehicle__c };
                    this.customerData = { ...this.customerData, ['Is_the_vehicle_used_for_business_purpose__c']: this.trackVar.Is_the_vehicle_used_for_business_purpose__c };
                    this.customerData = { ...this.customerData, ['Is_this_a_Rental_Vehicle__c']: this.trackVar.Is_this_a_Rental_Vehicle__c };
                    this.customerData = { ...this.customerData, ['Is_there_a_driver_under_21__c']: this.trackVar.Is_there_a_driver_under_21__c };
                    this.customerData = { ...this.customerData, ['vehicleId']: vehicleId };

                    console.log('Inside item value customer data', JSON.stringify(this.customerData));

                    this.getVehicleMakes()
                        .then((result) => {
                            console.log('resultt------', result);
                            if (result) {
                                if (item.Make__c) {
                                    const valueExists = this.makeOptions.some(option => option.value.toLowerCase() === item.Make__c.toLowerCase());

                                    const makeOptionsLowercase = this.makeOptions.map(option => ({
                                        label: option.label,
                                        value: option.value.toLowerCase()
                                    }));
                                    this.makeOptions = makeOptionsLowercase;

                                    if (!valueExists) {
                                        this.booleanVar.showManualMake = true;
                                        this.booleanVar.isModelDisabled = true;
                                        this.booleanVar.showManualModel = true;
                                        this.trackVar.Make__c = '<manually enter>';
                                        this.trackVar.Model__c = '<Manually Enter>';
                                        this.trackVar.MannualMake = item.Make__c;
                                        this.customerData = { ...this.customerData, ['Make__c']: item.MannualMake };
                                        this.trackVar.MannualModel = item.Model__c;
                                        this.customerData = { ...this.customerData, ['Model__c']: item.MannualModel };
                                        this.getVehicleModels()
                                            .then((result) => {
                                                if (result) {
                                                    if (item.Model__c) {
                                                        const valueExists = this.modelOptions.some(option => option.value.toLowerCase() === item.Model__c.toLowerCase());
                                                        if (!valueExists) {
                                                            this.booleanVar.showManualModel = true;
                                                            this.trackVar.Model__c = '<Manually Enter>';
                                                            this.trackVar.MannualModel = item.Model__c;
                                                            this.customerData = { ...this.customerData, ['Model__c']: item.MannualModel };
                                                        } else {
                                                            this.booleanVar.showManualModel = false;
                                                            this.trackVar.Model__c = item.Model__c;
                                                            this.customerData = { ...this.customerData, ['Model__c']: item.Model__c };
                                                        }
                                                    }
                                                }
                                            })
                                    } else {
                                        this.booleanVar.showManualModel = false;
                                        this.booleanVar.showManualMake = false;
                                        this.booleanVar.isModelDisabled = false;
                                        this.trackVar.Make__c = item.Make__c.toLowerCase();
                                        this.trackVar.Model__c = item.Model__c;
                                        this.customerData = { ...this.customerData, ['Make__c']: item.Make__c };
                                        this.customerData = { ...this.customerData, ['Model__c']: item.Model__c };
                                        this.getVehicleModels()
                                            .then((result) => {
                                                if (result) {
                                                    if (item.Model__c) {
                                                        const valueExists = this.modelOptions.some(option => option.value.toLowerCase() === item.Model__c.toLowerCase());

                                                        if (!valueExists) {
                                                            this.booleanVar.showManualModel = true;
                                                            this.trackVar.Model__c = '<Manually Enter>';
                                                            this.trackVar.MannualModel = item.Model__c;
                                                            this.customerData = { ...this.customerData, ['Model__c']: item.MannualModel };
                                                        } else {
                                                            this.booleanVar.showManualModel = false;
                                                            this.trackVar.Model__c = item.Model__c;
                                                            this.customerData = { ...this.customerData, ['Model__c']: item.Model__c };
                                                        }
                                                    }
                                                }
                                            })
                                    }

                                }
                            }
                        })
                }
            }
        });
        console.log('this.modelOptions', this.modelOptions);
        console.log('this.makeOptions', this.makeOptions);
        console.log('this.customerData', this.customerData);
    }

    @wire(getAgentFeeFRomUser, { 'userId': USER_ID })
    getAgentFee({ data, error }) {
        if (data) {
            console.log('data--->', error);
            console.log('Agent fee in wire--->', JSON.stringify(data));
            this.agentFee = data;
        } else {
            console.log('error--------------------->', error);
            console.log('Data--------->', JSON.stringify(data));
            if (data === 0) {
                this.agentFee = 0;
            }
            console.log('User Id', JSON.stringify(USER_ID));
        }
    }

    async handleAgentFee(event) {
        console.log('AGENT VALUE IN CHANGE --->', event.target.value);
        console.log('Type of Update fee-->', typeof (event.target.value));
        if (event.target.value != '') {
            const parsedFee = parseFloat(event.target.value);
            this.agentFee = parsedFee; // now stored as a number
            console.log('this.agentfee', this.agentFee);

            if (!isNaN(parsedFee) && parsedFee >= 0) {
                this.isDisabled = false;
            } else {
                this.isDisabled = true;
            }

            // if ( this.agentFee !== '' && parseFloat(this.agentFee) >= 0) {
            //     this.isDisabled = false;
            // } else {
            //     this.isDisabled = true;
            // }
        }
        else {
            if (this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Only except numbers in agent fee.', 'Agent fee update failed');
            } else {
                this.showToastEvent('Agent fee update failed', 'Only except numbers in agent fee.', 'error');
            }
        }
    }

    closeToastEvent(event) {
        this.isShowToast = false;
    }

    updateTowedController(event) {
        let updatedToweddetail = event.detail;
        this.addedTowed = updatedToweddetail;
    }

    handleDestinationInfo(event) {
        console.log('Data in the parent', event.detail);
        this.termAgreement = { ...this.termAgreement, ...event.detail };
    }

    handlePaymentInputChange = (event) => {
        this.paymentDetails[event.target.name] = event.target.value;

        if (event.target?.name == 'paymentCountrycmbx') {
            this.paymentDetails = { ...this.paymentDetails, ['Country__c']: event.target.value };
            if (event.target.value == 'Other') {
                this.otherCountrypayment = true;
            } else {
                this.otherCountrypayment = false;
            }
        }

        if (event.target.name == 'Payment_Type__c') {
            if (event.target.value == 'Cash') {
                this.booleanVar.showCardPayment = false;
            } else if (event.target.value == 'Card') {
                this.booleanVar.showCardPayment = true;
            }
        }

        if (event.target?.name == 'year') {
            if (event.target?.value == this.currentDate.getFullYear()) {
                this.startMonthNumber = this.currentDate.getMonth() + 1;
                this.months = [];
                this.template.querySelectorAll('lightning-combobox').forEach(each => {
                    if (each.name == 'month') {
                        each.value = '';
                    }
                });
                this.MM;
            } else {
                this.months = [];
                this.startMonthNumber = 1;
                this.MM;
            }
        }

        if (event.target.name == 'month' || event.target.name == 'year') {
            if (event.target.value != '') {
                this.template.querySelector('[data-id="month"]').required = true;
                this.template.querySelector('[data-id="month"]').className = 'validate';
                this.template.querySelector('[data-id="year"]').required = true;
                this.template.querySelector('[data-id="year"]').className = 'validate';
            } else {
                this.template.querySelector('[data-id="month"]').required = false;
                this.template.querySelector('[data-id="month"]').className = '';
                this.template.querySelector('[data-id="year"]').required = false;
                this.template.querySelector('[data-id="year"]').className = '';
            }
        }

        if (event.target.name == 'cardNumber') {
            const rawNumber = event.target.value.replace(/ /g, '');
            const formattedNumber = this.formatCreditCardNumber(rawNumber);
            this.formattedCreditCardNumber = formattedNumber;
            let cardNum = this.template.querySelector('[data-id="cardNumber"]')
            let expMonth = this.template.querySelector('[data-id="month"]')
            let expYear = this.template.querySelector('[data-id="year"]')
            this.paymentDetails = { ...this.paymentDetails, ['cardNumber']: rawNumber };
            if (event.target.value != '') {
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

    timeToMilliseconds(timeStr) {
        let timeParts = timeStr.split(':');
        let hours = parseInt(timeParts[0]);
        let minutes = parseInt(timeParts[1]);
        let secondsParts = timeParts[2].split('.');
        let seconds = parseInt(secondsParts[0]);
        let totalMilliseconds = (hours * 60 * 60 * 1000) +
            (minutes * 60 * 1000) +
            (seconds * 1000);
        return totalMilliseconds;
    }

    handleStartTimeValidation(event) {
        // 17 Sep

        let apexdata = JSON.parse(JSON.stringify(this.apextimedata));
        let data = event.target.value;
        let converted = this.timeToMilliseconds(data);
        let timeinapex = JSON.parse(JSON.stringify(apexdata.nextMin));
        let timedataconverted = this.timeToMilliseconds(timeinapex);
        let customerDate = this.customerData.Start_Date_for_Coverage__c;
        let dateParts = customerDate.split('-');
        let localDate = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);

        let datefromapex = apexdata.dtPST.split(' ')[0];
        let apexdateparts = datefromapex.split('-');
        let todaycheck = new Date(apexdateparts[0], apexdateparts[1] - 1, apexdateparts[2]);

        if (
            localDate.getFullYear() === todaycheck.getFullYear() &&
            localDate.getMonth() === todaycheck.getMonth() &&
            localDate.getDate() === todaycheck.getDate() && this.cmpSource == 'comm') {
            if (converted < timedataconverted && this.cmpSource == 'comm') {
                this.showToastmethod('error', 'Start time is already passed. Please select the next time slot.', 'Wrong time selected');
                return false;
            }
            return true;
        }
        return true;
    }
}