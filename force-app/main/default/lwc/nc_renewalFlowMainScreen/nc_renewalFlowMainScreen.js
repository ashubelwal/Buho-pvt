import { api,track, LightningElement } from 'lwc';
import getEditPolicyDetail from '@salesforce/apex/Mex_PolicyEditController.getEditPolicyDetail';
import fetchRenewQuoteData from '@salesforce/apex/Mex_PolicyEditController.fetchRenewQuoteData';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/Mex_existingCustomerFlowController.checkCommunityUserAndFetchDetails';
import updateQuoteData from '@salesforce/apex/Mex_PolicyEditController.updateQuoteData';
import LetstacklethePaymentnow from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';
import RenewPolicy from '@salesforce/label/c.TR_Renew_Policy';


export default class RenewalFlowMainScreen extends LightningElement {

    // IF DATA ERROR OCCURS 
    // CHECK FOR THE METHOD transformData...Check the mapping if it is from Quote or FROM Policy

    label = {
        LetstacklethePaymentnow, RenewPolicy,
    };
    @api isRenewalPolicy = 'Yes';
    @api renewalPolicyName;
    @api recordId;
    @api changeprevscreen;
    @api changesnextscreen;
    @api policyType;
    @api disableDate;
    @api screenname;
    @api renewalPolicy = {};
    @api renewQuoteId;
    @api annualTerm = false;
    @api semiAnnualTerm = false;
    @api oldPolicy = {};
    @api policyExist = false;
    @api isCommunityUser = false;
    @api DriverData;
    @api towedUnitData;
    @api connectedcallback = false;
    @api payload;
    @api spinner = false;
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    @track checkedData = {
        "Gold__c": true,
        "Max__c": true,
        "Platinum__c": true
    }
    async connectedCallback() {
        // this.isRenewalPolicy = true;
        this.spinner = false;
        this.isOpenLogCaseModal = false;
        console.log("Is Renewal Policy", this.isRenewalPolicy);
        const recordId = sessionStorage.getItem('recordId');
        this.recordId = recordId;
        console.log('Record Id', JSON.stringify(this.recordId));
        const data = await checkCommunityUserAndFetchDetails();
        const parsedData = JSON.parse(data);
        console.log(JSON.stringify(parsedData, null, 4));
        if (parsedData.status == 'success' && parsedData.userType == true) {
            this.isCommunityUser = parsedData.userType;
            this.DriverData = parsedData.drivers && parsedData.drivers.length > 0 ? parsedData.drivers : [];
            console.log('This.driverData',this.DriverData);
            this.towedUnitData = parsedData.towedUnits && parsedData.towedUnits.length > 0 ? parsedData.towedUnits : [];
            await this.fetchPolicyData();
        }
        this.spinner = true;
    }

    renewconnectedcallback(event) {
        console.log('recieved data ' + JSON.stringify(event.detail));
        if (event.detail == true) {
            this.connectedcallback = true;
        } else {
            this.connectedcallback = false;
        }
    }

    handleEditPolicyChange(event) {
        this.spinner = false;
        this.renewalPolicy = { ...this.renewalPolicy, ...event.detail };
        console.log('Renwal Event :::: ', JSON.stringify(this.renewalPolicy, null, 4));
        this.spinner = true;
    }

    handleRefundAmountChange(event) {
        this.refundAmount = event.detail;
    }

    handleLoadingStatus(event){
        this.spinner = event.detail;
    }

    get isTermOptions() {
        return this.screenname == 'termOptions';
    }
    get isReviewVehicle() {
        return this.screenname == 'ReviewVehicle';
    }
    get isReviewWatercraft() {
        return this.screenname == 'ReviewWatercraft';
    }
    get isCompanyInfo() {
        return this.screenname == 'companyInfo';
    }
    get isLienholderDetails() {
        return this.screenname == 'lienholderDetails';
    }
    get isDriverDetail() {
        console.log('This isDriverDegtails',this.renewalPolicy);
        const transformedData = this.transformPolicyData(this.renewalPolicy);
        this.payload = transformedData;
        console.log('Transformed Data in driver', transformedData);
        return this.screenname == 'DriverDetail';
    }
    get isTowingAnything() {
        return this.screenname == 'isTowing';
    }
    get isTowedDetails() {
        return this.screenname == 'towedDetails';
    }
    get isTowedDetailsFinal() {
        return this.screenname == 'towedDetailsFinal';
    }
    get isConfirmScreen() {
        const transformedData = this.transformPolicyData(this.renewalPolicy);
        this.payload = transformedData;
        console.log('Transformed Data', transformedData);
        return this.screenname == 'confirmScreen';
    }
    get isPaymentDetail() {
        return this.screenname == 'paymentDetail';
    }
    get isSouthboundpolicy() {
        return (this.policyType == 'Automobile' || this.policyType == 'RV' || this.policyType == 'Motorcycle/Street Legal ATV');
    }
    get isNorthbound() {
        return this.policyType == 'Northbound';
    }
    get isWatercraft() {
        return this.policyType == 'Watercraft';
    }
    changeNextScreen = (val) => {
        console.log('Change Next Screen Called');
        this.spinner = false;
        if (this.screenname == 'termOptions') {
            if (this.policyType == 'Watercraft') {
                this.screenname = 'ReviewWatercraft';
            } else {
                this.screenname = 'ReviewVehicle';
            }

        } else if (this.screenname == 'ReviewVehicle' && this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'ReviewVehicle' && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && !this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'ReviewVehicle' && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'companyInfo' && this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'companyInfo' && !this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'lienholderDetails') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'ReviewWatercraft') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'DriverDetail' && this.policyType != 'Watercraft' && this.policyType != 'Motorcycle/Street Legal ATV') {
            this.screenname = 'isTowing';
        } else if (this.screenname == 'DriverDetail' && this.policyType == 'Watercraft') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'DriverDetail' && this.policyType == 'Motorcycle/Street Legal ATV') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'isTowing') {
            if (this.renewalPolicy.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'confirmScreen';
            }
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'confirmScreen') {
            if (this.renewalPolicy.Is_Towing__c) {
                this.renewQuoteId = val;
                this.screenname = 'towedDetailsFinal';
            } else {
                this.renewQuoteId = val;
                this.screenname = 'paymentDetail';
            }
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'paymentDetail';
        }
        this.spinner = true;
    }
    @api
    showLogaCase(event) {
        this.isShowCaseLog = true;
        setTimeout(() => {
            if (!this.isOpenLogCaseModal) {
                this.isShowCaseLog = false;
            }
        }, 7800);
    }
    @api openModalLogCase(event) {
        console.log('event.detail--', event.detail)
        if (event.detail == 'delayClose') {
            this.isOpenLogCaseModal = true;
        } else if (event.detail == 'quickClose') {
            this.isShowCaseLog = false;
        } else if (event.detail == 'OnloadedComponent') {
            this.isOpenLogCaseModal = false;
        }

    }
    changePrevScreen = () => {
        console.log('Change Previous Screen called');
        this.spinner = false;
        if (this.screenname == 'termOptions') {
        } else if (this.screenname == 'ReviewVehicle' || this.screenname == 'ReviewWatercraft') {
            this.screenname = 'termOptions';
        } else if (this.screenname == 'companyInfo') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'lienholderDetails' && this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'lienholderDetails' && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'ReviewVehicle';
        } else if (this.policyType != 'Watercraft' && this.screenname == 'DriverDetail' && this.renewalPolicy.vehicleData.Is_Lienholder__c) {
            console.log('Inside 1');
            this.screenname = 'lienholderDetails';
        } else if (this.policyType != 'Watercraft' && this.screenname == 'DriverDetail' && !this.renewalPolicy.vehicleData.Is_Lienholder__c && this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            console.log('Inside 2');
            this.screenname = 'companyInfo';
        } else if (this.policyType != 'Watercraft' && this.screenname == 'DriverDetail' && !this.renewalPolicy.vehicleData.Is_Lienholder__c && !this.renewalPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            console.log('Inside 3');
            this.screenname = 'ReviewVehicle';
        } else if (this.policyType == 'Watercraft' && this.screenname == 'DriverDetail') {
            console.log('Inside 4');
            this.screenname = 'ReviewWatercraft';
        } else if (this.screenname == 'isTowing') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'isTowing';
        } else if (this.policyType != 'Watercraft' && this.screenname == 'confirmScreen') {
            if (this.renewalPolicy.Is_Towing__c && this.policyType != 'Watercraft' && this.policyType != 'Motorcycle/Street Legal ATV') {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'isTowing';
            }
        } else if (this.policyType == 'Watercraft' && this.screenname == 'confirmScreen') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'paymentDetail') {
            if (this.renewalPolicy.Is_Towing__c) {
                this.screenname = 'towedDetailsFinal'
            } else {
                this.screenname = 'confirmScreen';
            }
        }
        this.spinner = true;
    }




    handleQuoteEvent(event) {
        const payload = event.detail;
        console.log('Received updatedPayload from child:', payload);
        this.payload = payload;

        // Do whatever you want with the data
    }


    async handlePayloadUpdate(event) {
        try {
            const { updates } = event.detail;
            
            // Create a deep copy of the current quoteData to avoid proxy issues
            const updatedQuoteData = JSON.parse(JSON.stringify(this.renewalPolicy.quoteData));
            
            // Iterate through the updates
            Object.keys(updates).forEach(key => {
                try {
                    const updateData = updates[key];
                    
                    // Process any key and update quoteData accordingly
                    Object.keys(updateData).forEach(fieldName => {
                        try {
                            // Update the corresponding field in the copy
                            if (updatedQuoteData.hasOwnProperty(fieldName)) {
                                console.log('Inside update ');
                                updatedQuoteData[fieldName] = updateData[fieldName];
                                this.checkedData[fieldName] = updateData[fieldName];
                                console.log(`Updated ${fieldName} in quoteData:`, updateData[fieldName]);
                            } else {
                                console.warn(`Field ${fieldName} not found in quoteData`);
                                this.checkedData[fieldName] = updateData[fieldName];
                            }
                        } catch (fieldError) {
                            console.error('Error stack:', fieldError.stack);
                        }
                    });
                } catch (keyError) {
                    console.error('Error stack:', keyError.stack);
                }
            });
            
            console.log('About to update renewalPolicy',this.renewalPolicy);
            // Update the entire renewalPolicy object with the new quoteData
            this.renewalPolicy = {
                ...this.renewalPolicy,
                quoteData: updatedQuoteData
            };
            console.log('After updating the renewal policy',this.renewalPolicy);
            const updatedTransformedData = await this.transformPolicyData(this.renewalPolicy);
            this.payload = updatedTransformedData;
            console.log('Updated transformed data',this.payload);
            console.log('renewalPolicy updated successfully');
            
        } catch (mainError) {
            console.error('Main error in handlePayloadUpdate:', mainError);
        }
    }


    fetchPolicyData = async () => {
        try {
            const { status, ...rest } = await getEditPolicyDetail({ 'policyId': this.recordId });

            // Normalize Medical values
            if (rest.quoteData?.Medical__c === '4,000/20,000') {
                rest.quoteData.Medical__c = '4,000/16,000';
            }
            if (rest.policyData?.Medical_picklist__c === '4,000/20,000') {
                rest.policyData.Medical_picklist__c = '4,000/16,000';
            }
            
            if (status == 'success') {
                this.renewalPolicy = { ...rest };
                console.log('--this.renewalPolicy----', this.renewalPolicy);
                console.log('--this.renewalPolicy----', JSON.stringify(this.oldPolicy));
                this.oldPolicy = { ...rest };
                this.policyType = rest.policyData.Policy_Type_picklist__c;
                this.renewalPolicyName = rest.policyData.Name;
                if (true) {
                    console.log('creating renewed Quote from Policy');
                    let newQuoteReacord = {
                        Quote_Value__c: 0,
                        Net_Premium__c: 0,
                        Surcharge__c: 0,
                        I_V_A_Mex_Tax__c: 0,
                        Broker_Policy_Fee__c: 0

                    };
                    let todaysDate = new Date();
                    let endDayForCoverage = new Date(rest.quoteData.End_Date_for_Coverage__c);
                    if (endDayForCoverage < todaysDate) {
                        endDayForCoverage = todaysDate;
                    }
                    let startDayForCoverage = endDayForCoverage;
                    startDayForCoverage.setDate(startDayForCoverage.getDate() + 1);
                    const date = new Date(startDayForCoverage);
                    let month = date.getMonth() + 1;
                    let day = date.getDate();

                    let startDateFormated = date.getFullYear() + '-' + this.toDigitFormate(month) + '-' + this.toDigitFormate(day);

                    newQuoteReacord['Start_Date_for_Coverage__c'] = startDateFormated;

                    console.log('-before set end date--', newQuoteReacord);
                    let termsdays = rest.quoteData.Term_Days__c;
                    console.log('-termsdays-', termsdays);
                    startDayForCoverage = new Date(newQuoteReacord.Start_Date_for_Coverage__c);
                    endDayForCoverage = new Date(startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                    if (termsdays != null) {
                        endDayForCoverage.setDate(endDayForCoverage.getDate() + parseInt(termsdays));

                        const dateFormate = new Date(endDayForCoverage);
                        let endMonthFormate = dateFormate.getMonth() + 1;
                        let endDayFormate = dateFormate.getDate();
                        let endDateFormated = dateFormate.getFullYear() + '-' + this.toDigitFormate(endMonthFormate) + '-' + this.toDigitFormate(endDayFormate);
                        newQuoteReacord['End_Date_for_Coverage__c'] = endDateFormated;

                    }
                    if (rest.quoteData.Term__c == 'Annual(One Year)' || rest.quoteData.Term__c == 'Annual') {
                        this.annualTerm = true;
                    } else if (rest.quoteData.Term__c == 'Semi-Annual(Half a Year)' || rest.quoteData.Term__c == 'Semi-Annual') {
                        this.semiAnnualTerm = true
                    }
                    this.policyExist = true;
                    this.renewalPolicy = { ...this.renewalPolicy, ['quoteData']: { ...this.renewalPolicy.quoteData, ...newQuoteReacord } };

                } else {
                    console.log('calling renewed Quote from Policy');
                    // call renewed quote data...
                    const fetchdata = await fetchRenewQuoteData({ 'renewedQuoteId': rest.quoteData.Renew_Quote__c });
                    console.log('--fetchdata--', fetchdata);
                    if (fetchdata.status == 'success') {
                        this.policyExist = fetchdata.policyExist == 'true' ? true : false;
                        let resParsequoteData = JSON.parse(fetchdata.quoteData);
                        // let resParsevehicleData = fetchdata.vehicleData ? JSON.parse(fetchdata.vehicleData) : {};
                        // let resParseDriverData = fetchdata.DriverData ? JSON.parse(fetchdata.DriverData) : {};
                        // let resParseTowedUnitData = fetchdata.towedUnitData ? JSON.parse(fetchdata.towedUnitData) : {};
                        // let resParsePolicyData = fetchdata.policyData ? JSON.parse(fetchdata.policyData) : {};


                        this.renewalPolicy = {
                            ...this.renewalPolicy, ['quoteData']: { ...resParsequoteData },
                            // ['vehicleData']: { ...this.renewalPolicy?.vehicleData, ...resParsevehicleData },
                            // ['DriverData']: { ...this.renewalPolicy?.DriverData, ...resParseDriverData },
                            // ['towedUnitData']: { ...this.renewalPolicy?.towedUnitData, ...resParseTowedUnitData },
                            // ['policyData']: { ...this.renewalPolicy?.policyData, ...resParsePolicyData },
                        };
                        this.renewalPolicy.quoteData = { ...this.renewalPolicy.quoteData, ['Start_Time__c']: this.renewalPolicy.policyData.Start_Time__c }
                        this.renewalPolicy.quoteData = { ...this.renewalPolicy.quoteData, ['End_Time__c']: this.renewalPolicy.policyData.End_Time__c }
                    }

                    console.log('-- fetch renewalPolicy--', this.renewalPolicy);

                }
                console.log('--> renewal policy ---> ', JSON.stringify(this.renewalPolicy));
            } else {
                // error -> something went wrong...
                console.log(status);
            }
            this.screenname = 'termOptions';
        } catch (error) {
            console.log(error);
            if (error.status === 500 && error.statusText === 'Server Error') {
                // something went wrong. Please try again...
            }
        }
    }

    toDigitFormate(n) {
        return n > 9 ? "" + n : "0" + n;
    }

    async buyQuote() {
        const childCmp = this.template.querySelector('c-nc_quote-page');
        if (childCmp) {
            if (childCmp.setData != undefined) {
                console.log('CQ - capturePayload Data');
                await childCmp.setData(this.payload);
            }
            const result = await childCmp.getData();
            console.log('Child data:', result);
            if (result) {
                if (result?.QuoteData) {
                    this.renewalPolicy = { ...this.renewalPolicy, ['quoteData']: { ...result.QuoteData } }
                    console.log('After the renewal policy Update', this.renewalPolicy);
                    this.changeNextScreen();
                }
            }
        } else {
            console.error('Child component not found!');
        }
    }

    transformPolicyData(inputData) {
        if (!inputData) return [];

        const getSafe = (obj, path, defaultValue = null) => {
            return path.split('.').reduce((acc, part) => (acc && acc[part] !== undefined) ? acc[part] : defaultValue, obj);
        };

        const formatTime = (timeInMs) => {
            if (!timeInMs) return '00:00:00';

            const totalSeconds = Math.floor(timeInMs / 1000);
            const hours = Math.floor(totalSeconds / 3600);
            const minutes = Math.floor((totalSeconds % 3600) / 60);
            const seconds = totalSeconds % 60;

            return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
        };

        const userDetails = {
            Email: getSafe(inputData, 'policyData.Contact_Email__c', ''),
            FirstName: getSafe(inputData, 'DriverData.0.First_Name__c', ''),
            LastName: getSafe(inputData, 'DriverData.0.Last_Name__c', ''),
            Phone: '', // Placeholder
            Id: getSafe(inputData, 'DriverData.0.Contact__c', '')
        };

        const isWatercraft = this.policyType === 'Watercraft';
        const activeVehicleSource = isWatercraft ? 'watercraftData' : 'vehicleData';

        const isBusinessUse = getSafe(inputData, 'vehicleData.Is_the_vehicle_used_for_business_purpose__c', false);
        const isRental = getSafe(inputData, 'vehicleData.Rental__c', 'No') === 'Yes';
        const isSalvage = getSafe(inputData, 'vehicleData.Salvage_Vehicle__c', false);
        const isElectric = getSafe(inputData, 'vehicleData.Electric_Hybrid__c', false);
        const isTowing = getSafe(inputData, 'Is_Towing__c', false) || (inputData.towedUnitData && inputData.towedUnitData.length > 0);

        const towunitsList = (inputData.towedUnitData || []).map(towUnit => ({
            Towed_Unit_Type__c: getSafe(towUnit, 'Towed_Unit_Type__c', ''),
            Towed_Unit_Value__c: getSafe(towUnit, 'Towed_Unit_Value__c', '0'),
            Days_in_Tow__c: getSafe(towUnit, 'Days_in_Tow__c', '1'),
            count: 1,
            isDeleteButton: true,
            style: "",
            Year__c: getSafe(towUnit, 'Year__c', ''),
            Make__c: getSafe(towUnit, 'Make__c', ''),
            Model__c: getSafe(towUnit, 'Model__c', ''),
            VIN_Number__c: getSafe(towUnit, 'VIN_Number__c', ''),
            Plate__c: getSafe(towUnit, 'Plate__c', ''),
            label: `${getSafe(towUnit, 'Make__c', '')} ${getSafe(towUnit, 'Model__c', '')} ${getSafe(towUnit, 'Year__c', '')} - ${getSafe(towUnit, 'VIN_Number__c', '')}`,
            value: getSafe(towUnit, 'Id', ''),
            Id: getSafe(towUnit, 'Id', '')
        }));

        const vehicleDetails = {
            is_the_vehicle_used_for_business_purpose__c: isBusinessUse,
            is_there_a_driver_under_21__c: getSafe(inputData, 'quoteData.Is_there_a_driver_under_21__c', 'false') === 'true',
            Is_this_a_Rental_Vehicle__c: isRental,
            salvage_vehicle__c: isSalvage,
            Coverage__c: getSafe(inputData, 'quoteData.Coverage__c', 'Complete'),
            isTowing: isTowing,
            Electric_Hybrid__c: isElectric,
            towunits: towunitsList,
            Liability__c: getSafe(inputData, 'quoteData.Liability__c', '300000'),
            Medical__c: getSafe(inputData, 'quoteData.Medical__c', '10,000/50,000'),
            Year__c: getSafe(inputData, `${activeVehicleSource}.Year__c`, ''),
            Vehicle_sub_type__c: isWatercraft ? 'Watercraft' : getSafe(inputData, `${activeVehicleSource}.Vehicle_Type__c`, 'Automobile-Van-Minivan'),
            Make: getSafe(inputData, `${activeVehicleSource}.Make__c`, ''),
            Model: getSafe(inputData, `${activeVehicleSource}.Model__c`, ''),
            Value__c: getSafe(inputData, `${activeVehicleSource}.Value__c`, '0'),
            towunitsList: towunitsList,
            vehicleList: [
                {
                    Id: getSafe(inputData, `${activeVehicleSource}.Id`, ''),
                    label: `${getSafe(inputData, `${activeVehicleSource}.Make__c`, '')} ${getSafe(inputData, `${activeVehicleSource}.Model__c`, '')} ${getSafe(inputData, `${activeVehicleSource}.Year__c`, '')} - ${getSafe(inputData, `${activeVehicleSource}.Vin__c`, '') || getSafe(inputData, `${activeVehicleSource}.VIN_Number__c`, '')}`,
                    value: getSafe(inputData, `${activeVehicleSource}.Id`, ''),
                    Coverage__c: getSafe(inputData, 'quoteData.Coverage__c', 'Complete'),
                    Electric_Hybrid__c: isElectric,
                    Liability__c: getSafe(inputData, 'policyData.Liability_picklist__c', '300000'),
                    Medical__c: getSafe(inputData, 'policyData.Medical_picklist__c', '10,000/50,000'),
                    Year__c: getSafe(inputData, `${activeVehicleSource}.Year__c`, ''),
                    Vehicle_sub_type__c: isWatercraft ? 'Watercraft' : getSafe(inputData, `${activeVehicleSource}.Vehicle_Type__c`, 'Automobile-Van-Minivan'),
                    Make: getSafe(inputData, `${activeVehicleSource}.Make__c`, ''),
                    Model: getSafe(inputData, `${activeVehicleSource}.Model__c`, ''),
                    Value__c: getSafe(inputData, `${activeVehicleSource}.Value__c`, '0'),
                    Vin__c: getSafe(inputData, `${activeVehicleSource}.Vin__c`, '') || getSafe(inputData, `${activeVehicleSource}.VIN_Number__c`, ''),
                    Registered_Country__c: getSafe(inputData, `${activeVehicleSource}.Registered_Country__c`, '') || getSafe(inputData, `${activeVehicleSource}.Flag__c`, ''),
                    Registered_State__c: getSafe(inputData, `${activeVehicleSource}.Registered_State__c`, ''),
                    licensePlate: getSafe(inputData, `${activeVehicleSource}.Registered_Plate__c`, '')
                }
            ],
            Vin__c: getSafe(inputData, `${activeVehicleSource}.Vin__c`, '') || getSafe(inputData, `${activeVehicleSource}.VIN_Number__c`, ''),
            Registered_Country__c: getSafe(inputData, `${activeVehicleSource}.Registered_Country__c`, '') || getSafe(inputData, `${activeVehicleSource}.Flag__c`, ''),
            Registered_State__c: getSafe(inputData, `${activeVehicleSource}.Registered_State__c`, ''),
            licensePlate: getSafe(inputData, `${activeVehicleSource}.Registered_Plate__c`, ''),
            Id: getSafe(inputData, `${activeVehicleSource}.Id`, ''),
            Make__c: getSafe(inputData, `${activeVehicleSource}.Make__c`, ''),
            Model__c: getSafe(inputData, `${activeVehicleSource}.Model__c`, ''),
            Account_Vehicle__c: getSafe(inputData, `${activeVehicleSource}.Account_Vehicle__c`, ''),
            Contact__c: getSafe(inputData, `${activeVehicleSource}.Contact__c`, ''),
            Type_of_Vessel__c: getSafe(inputData, `${activeVehicleSource}.Type_of_Vessel__c`, ''),
            Vessel_Length__c: getSafe(inputData, `${activeVehicleSource}.Vessel_Length__c`, ''),
            Is_the_Maximum_Speed_more_than_50_mph__c: getSafe(inputData, 'quoteData.Is_the_Maximum_Speed_more_than_50_mph__c', 'No'),
            Any_Boat_Operator_Under_22__c: getSafe(inputData, 'quoteData.Any_Boat_Operator_Under_22__c', 'No'),
            Is_the_owner_living_in_Mexico__c: getSafe(inputData, 'quoteData.Is_the_owner_living_in_Mexico__c', 'No')
        };

        // Helper function to determine Driver_Type__c
        const getDriverType = (driverType) => {
            if (driverType === undefined || driverType === null) return false;
            if (typeof driverType === 'boolean') return driverType;
            if (typeof driverType === 'string') {
                return driverType.toLowerCase() === 'true' ||
                    driverType.toLowerCase() === 'owner' ||
                    driverType.toLowerCase() === 'owner & driver';
            }
            return false;
        };

    // Create driverDetails object
        const driverDetails = {
            drivers: (inputData.DriverData || []).map(driver => {
                const driverObj = {
                    First_Name__c: driver.First_Name__c || '',
                    Last_Name__c: driver.Last_Name__c || '',
                    License_Country__c: driver.License_Country__c || '',
                    License_state__c: driver.License_state__c || '',
                    license_number__c: driver.license_number__c || '',
                    Dob__c: driver.Dob__c || '',
                    Driver_Type__c: getDriverType(driver.Driver_Type__c),
                    Country__c: driver.Country__c || '',
                    Country_Text__c: driver.Country_Text__c || '',
                    State_Province__c: driver.State_Province__c || '',
                    Postal_Code__c: driver.Postal_Code__c || '',
                    City__c: driver.City__c || '',
                    Address__c: driver.Address__c || ''
                };

                // Only include Id if present
                if (driver.Id) {
                    driverObj.Id = driver.Id;
                }

                return driverObj;
            }), // Empty array as per example
            companyInformation: {
                Company_Name__c: getSafe(inputData, 'vehicleData.Company_Name__c', ''),
                Company_Address__c: getSafe(inputData, 'vehicleData.Company_Address__c', ''),
                Company_Phone__c: getSafe(inputData, 'vehicleData.Company_Phone__c', ''),
                Company_Country__c: getSafe(inputData, 'vehicleData.Company_Country__c', ''),
                Company_State__c: getSafe(inputData, 'vehicleData.Company_State__c', ''),
                Company_City__c: getSafe(inputData, 'vehicleData.Company_City__c', ''),
                Company_Zip__c: getSafe(inputData, 'vehicleData.Company_Zip__c', ''),
                Tax_ID__c: getSafe(inputData, 'vehicleData.Tax_ID__c', ''),
                Is_the_vehicle_registered_to_a_business__c: getSafe(inputData, 'vehicleData.Is_the_vehicle_registered_to_a_business__c', false)
            }, // Empty object as per example
            driverList: (this.DriverData || []).map(driver => ({
                Id: getSafe(driver, 'Id', ''),
                label: `${getSafe(driver, 'First_Name__c', '')} ${getSafe(driver, 'Last_Name__c', '')} - ${getSafe(driver, 'Dob__c', '')} - ${getSafe(driver, 'license_number__c', '')}`,
                value: getSafe(driver, 'Id', ''),
                First_Name__c: getSafe(driver, 'First_Name__c', ''),
                Last_Name__c: getSafe(driver, 'Last_Name__c', ''),
                License_Country__c: getSafe(driver, 'License_Country__c', ''),
                License_state__c: getSafe(driver, 'License_state__c', ''),
                license_number__c: getSafe(driver, 'license_number__c', ''),
                Dob__c: getSafe(driver, 'Dob__c', ''),
                Driver_Type__c: getDriverType(driver.Driver_Type__c), // Convert to boolean
                Country__c: getSafe(driver, 'Country__c', ''),
                Country_Text__c: getSafe(driver, 'Country__c', ''), // Same as Country__c
                State_Province__c: getSafe(driver, 'State_Province__c', ''),
                Postal_Code__c: getSafe(driver, 'Postal_Code__c', ''),
                City__c: getSafe(driver, 'City__c', ''),
                Address__c: getSafe(driver, 'Address__c', ''),
                diff: Date.now() // Current timestamp
            }))
        };

        const termOption = {
            Term__c: getSafe(inputData, 'quoteData.Term__c', 'Daily'),
            Start_Date_for_Coverage__c: getSafe(inputData, 'quoteData.Start_Date_for_Coverage__c', ''),
            Start_Time__c: formatTime(getSafe(inputData, 'quoteData.Start_Time__c', '19800000')),
            End_Date_for_Coverage__c: getSafe(inputData, 'quoteData.End_Date_for_Coverage__c', ''),
            End_Time__c: formatTime(getSafe(inputData, 'quoteData.End_Time__c', '19800000')),
            Max__c: this.checkedData?.Max__c,
            Gold__c:this.checkedData?.Gold__c,
            Platinum__c:true
        };

        return [
            { userDetails },
            { vehicleDetails },
            { UserType: { UserType: "Customer" } },
            { termOption },
            { territory: { region: getSafe(inputData, 'quoteData.Territory__c', '') } },
            { driverDetails }
        ];
    }
}