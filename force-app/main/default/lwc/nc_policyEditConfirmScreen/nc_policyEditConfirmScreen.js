import { api, LightningElement } from 'lwc';
import getQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getQuote';
import getNorthboundQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getNorthboundQuote';
import getWatercraftQuote from '@salesforce/apex/Mex_QuickQuoteCommonController.getWatercraftQuote';
import calculateTotalCoverage from '@salesforce/apex/CalculateCoverage.calculateTotalCoverage';
import updatePolicyDetails from '@salesforce/apex/Mex_PolicyEditController.updatePolicyDetails';
import saveQuoteRecordData from '@salesforce/apex/NcExistingCustomerFlow.saveQuoteRecordData';
import { NavigationMixin } from 'lightning/navigation';
import OriginalPolicy from '@salesforce/label/c.TR_Original_Policy';
import Summary from '@salesforce/label/c.TR_Summary';
import Premium from '@salesforce/label/c.TR_Premium';
import Surcharge from '@salesforce/label/c.TR_Surcharge';
import Medical from '@salesforce/label/c.TR_Medical';
import Liability from '@salesforce/label/c.TR_Liability';
import BrokerCharge from '@salesforce/label/c.TR_Broker_Charge';
import MexicanIVATax from '@salesforce/label/c.TR_Mexican_IVA_TAX';
import TOTAL from '@salesforce/label/c.TR_TOTAL';
import ModifiedPolicy from '@salesforce/label/c.TR_Modified_Policy';
import Refundamount from '@salesforce/label/c.TR_Refund_Amount';
import Amountowed from '@salesforce/label/c.TR_Amount_towed';
import Prev from '@salesforce/label/c.TR_Prev';
import Confirm from '@salesforce/label/c.TR_Confirm';
import AmountDueMessage from '@salesforce/label/c.AmountDueMessage';

export default class Nc_policyEditConfirmScreen extends NavigationMixin(LightningElement) {
    label = {
        OriginalPolicy, Summary, AmountDueMessage, Premium, Surcharge, Medical, Liability, BrokerCharge, MexicanIVATax, TOTAL, ModifiedPolicy, Refundamount, Amountowed, Prev, Confirm,
    };
    @api oldpolicydata;
    @api editpolicydata;
    @api policyType;
    @api changeprevscreen;
    @api changesnextscreen;
    @api refundAmount;
    @api selectedQuote;
    medicalValue;
    policyRecord;
    quickQuoteDetail;
    quoteId;
    isRefund;
    isGettingError = false;
    isSpinLoad = false;

    async connectedCallback() {
        console.log('--oldpolicydata--', this.oldpolicydata);
        console.log('---EditPolicyData---', this.editpolicydata);
        console.log('---Policy Type---', this.policyType);
        this.policyRecord = this.oldpolicydata.policyData;
        if (this.editpolicydata != '' && this.editpolicydata != null) {
            if (this.policyType == 'Watercraft') {
                this.fetchWatercraftpolicyDetail(this.editpolicydata);
            } else {
                this.fetchPolicyDetail(this.editpolicydata);
            }
        }
    }

    get showMedical() {

        return this.policyType != 'Motorcycle/Street Legal ATV' && this.policyType != 'Watercraft';
    }

    get showWatercraft() {
        return this.policyType == 'Watercraft';
    }
    async fetchWatercraftpolicyDetail(quoteDetails) {
        console.log('---quoteDetails---' + JSON.stringify(quoteDetails));





        let qt = {
            Policy_Type_picklist: "Watercraft",
            Vehicle_Type__c: "Watercraft",
            Type_of_Vessel__c: quoteDetails.quoteData.Type_of_Vessel__c,
            Vessel_Length__c: quoteDetails.quoteData.Vessel_Length__c,
            Start_Date_for_Coverage: quoteDetails.quoteData.Start_Date_for_Coverage__c,
            End_Date_for_Coverage: quoteDetails.quoteData.End_Date_for_Coverage__c,
            Is_the_Maximum_Speed_more_than_50_mph__c: quoteDetails.quoteData.Is_the_Maximum_Speed_more_than_50_mph__c,
            Any_Boat_Operator_Under_22__c: quoteDetails.quoteData.Any_Boat_Operator_Under_22__c,
            Is_the_owner_living_in_Mexico__c: quoteDetails.quoteData.Is_the_owner_living_in_Mexico__c,
            Liability__c: quoteDetails.quoteData.Liability__c,
            Third_Party_Bodily_Injury__c: quoteDetails.quoteData.Third_Party_Bodily_Injury__c,
            Property_Damage_Liability__c: quoteDetails.quoteData.Property_Damage_Liability__c,
            Towed_Unit__c: 'No',
            // Liability__c:quoteDetails.Liability__c
        };

        console.log('Quote Data ::::: ', qt);
        const res = await getWatercraftQuote({
            'requestBody': JSON.stringify(qt),
            'annualTerm': quoteDetails.Term__c != "Annual" ? false : true,
        });


        console.log('Res ::::::  ', res);
        console.log('Res Parsed :::: ', JSON.parse(res));
        let parseRes = JSON.parse(res)

        this.quickQuoteDetail = {
            ...this.quickQuoteDetail,
            ['Third_Party_Bodily_Injury__c']: this.policyRecord?.Third_Party_Bodily_Injury__c,
            ['iva']: parseRes.rateRecord.I_V_A_Mex_Tax__c,
            ['Policy_Fee']: parseRes.rateRecord.Broker_Policy_Fee__c,
            ['rateValue']: parseRes.rateRecord.Quote_Value__c,
            ['surcharge']: parseRes.rateRecord.Surcharge__c,
            ['net_premium']: parseRes.rateRecord.Net_Premium__c,
        };
        console.log('--quickQuoteDetail--', this.quickQuoteDetail);

        this.refundAmount = this.quickQuoteDetail.rateValue.toFixed(2) - this.policyRecord.Total_Transaction_Amount__c.toFixed(2);
        this.editpolicydata = {
            ...this.editpolicydata,
            ['quoteData']: {
                ...this.editpolicydata.quoteData,
                ['I_V_A_Mex_Tax__c']: this.quickQuoteDetail.iva,
                ['Broker_Policy_Fee__c']: this.quickQuoteDetail.Policy_Fee,
                ['Term__c']: this.quickQuoteDetail.Term__c == 'Annual' ? 'Annual' : this.quickQuoteDetail.Term__c == 'Semi-Annual' ? 'Semi-Annual' : 'Daily',
                ['Net_Premium__c']: this.quickQuoteDetail.net_premium,
                ['Vehicle_Deductible_Collision__c']: this.quickQuoteDetail.collision_deductible,
                ['Vehicle_Deductible_Comprehensive__c']: this.quickQuoteDetail.theft_Total,
                ['Quote_Value__c']: this.quickQuoteDetail.rateValue,
                ['Term_Days__c']: parseInt(this.quickQuoteDetail.days), ['Surcharge__c']: this.quickQuoteDetail.surcharge || 0
            }
        }


        console.log('--after update value-- 1 ', this.editpolicydata);
    }

    async fetchPolicyDetail(quoteDetails) {
        // let policyData = await getEditPolicyDetail({'policyid':this.policyId});
        //  console.log('---policyId---', policyData);
        // if(policyData.status == 'success'){
        //     this.policyRecord = policyData.data;
        // }
        // console.log('--policyreacord--', this.policyRecord);
        // for new quote rate calcluate
        let liabilityChange;
        let startDateChange;
        let endDateChange;
        let medicalChange;
        let territoryChange;
        let towUnitChange;
        console.log('fetching quote details ');
        console.log(JSON.stringify(quoteDetails));
        const normalizeBoolean = (val) => {
            if (typeof val === 'string') {
                val = val.trim().toLowerCase();
            }
            return val === true || val === 'true' || val === 'yes';
        };

        const isTowing = normalizeBoolean(this.quoteDetails?.Is_Towing__c) ||
            normalizeBoolean(this.quoteDetails?.quoteData?.Towed_Unit__c)
            ? 'Yes' : 'No';

        const oldTowedUnit = normalizeBoolean(this.oldpolicydata?.quoteData?.Towed_Unit__c)
            ? 'Yes' : 'No';
        if (quoteDetails.quoteData.Medical__c != undefined && quoteDetails.quoteData.Medical__c != '') {
            let splitMedicalValue = quoteDetails.quoteData.Medical__c.split('/');
            this.medicalValue = '$' + splitMedicalValue[0] + '/$' + splitMedicalValue[1];
        } else {
            this.medicalValue = "$5,000/$25,000";
        }

        if (this.oldpolicydata != undefined && this.editpolicydata != undefined) {
            liabilityChange = this.oldpolicydata.quoteData?.Liability__c != this.editpolicydata.quoteData?.Liability__c ? true : false;
            startDateChange = this.oldpolicydata.quoteData?.Start_Date_for_Coverage__c != this.editpolicydata.quoteData?.Start_Date_for_Coverage__c ? true : false;
            endDateChange = this.oldpolicydata.quoteData?.End_Date_for_Coverage__c != this.editpolicydata.quoteData?.End_Date_for_Coverage__c ? true : false;
            medicalChange = this.oldpolicydata.quoteData?.Medical__c != this.editpolicydata.quoteData?.Medical__c ? true : false;
            territoryChange = this.oldpolicydata.quoteData?.Territory__c != this.editpolicydata.quoteData?.Territory__c ? true : false;
            towUnitChange = isTowing !== oldTowedUnit;
        }

        console.log('quoteDetails check->', quoteDetails);

        let Underwriter = quoteDetails.quoteData.Underwriter__c;

        console.log('Underwriter check->', Underwriter);

        let qt = {
            Policy_Type_picklist: quoteDetails.quoteData.Vehicle_Type__c == '' ? 'Automobile-Van-Minivan' : quoteDetails.quoteData.Vehicle_Type__c,
            Vehicle_Type: quoteDetails.quoteData.Vehicle_Type__c,
            Vehicle_Sub_Type: quoteDetails.quoteData.Vehicle_Sub_type__c || quoteDetails.quoteData.Vehicle_Type__c
        };

        // console.log('qt check->', JSON.stringify(qt));

        const transformedPayload = this.transformPolicyData(this.editpolicydata, this.oldpolicydata);
        console.log(JSON.stringify(transformedPayload, null, 2));

        const res = await calculateTotalCoverage({ jsonString: JSON.stringify(transformedPayload) });

        let parseRes = res;

        this.selectedQuote = parseRes[Underwriter];
        this.selectedQuote = { ...this.selectedQuote, ['Vendor']: Underwriter };

        let quoteDataMapped = await this.createDataForQuoteSave(transformedPayload);
        this.quickQuoteDetail = { ...this.quickQuoteDetail, ...quoteDataMapped, ...this.selectedQuote };

        console.log('parseRes Data->', parseRes);
        console.log('quickQuoteDetail Data->', this.quickQuoteDetail);
        console.log('Transformed Data->', quoteDataMapped);
        console.log('policyRecord Data->', this.policyRecord.Total_Transaction_Amount__c);

        if (liabilityChange || startDateChange || endDateChange || medicalChange || territoryChange || towUnitChange) {
            const total = parseFloat(this.quickQuoteDetail?.Total);
            const transactionTotal = parseFloat(this.policyRecord?.Total_Transaction_Amount__c);

            if (!isNaN(total) && !isNaN(transactionTotal)) {
                this.refundAmount = (total - transactionTotal).toFixed(2);
            } else {
                this.refundAmount = 0; // or 0, or handle error appropriately
            }
            console.log('refundAmount Data With Amount->', this.refundAmount);

            this.quickQuoteDetail = { ...this.quickQuoteDetail, ['surcharge']: this.quickQuoteDetail?.TotalSurcharges || 0 }
            this.editpolicydata = {
                ...this.editpolicydata,
                ['quoteData']: {
                    ...this.editpolicydata?.quoteData,
                    ...quoteDataMapped,
                    ...qt
                }
            }
        } else {
            this.refundAmount = 0;
            this.editpolicydata = { ...this.editpolicydata };
            this.quickQuoteDetail = {
                ...this.quickQuoteDetail,
                ['net_premium']: this.policyRecord?.Net_Premium__c,
                ['rateValue']: this.policyRecord?.Total_Premium_Amount__c,
                ['surcharge']: this.policyRecord?.Surcharge__c,
                ['Policy_Fee']: this.policyRecord?.Broker_Policy_Fee__c,
                ['iva']: this.policyRecord?.I_V_A_Mex_Tax__c,
            }
        }

        console.log('Test Refund value ', this.refundAmount);


        console.log('--after update value--', this.editpolicydata);
    }
    handleNext = async () => {
        console.log('--call the payment method--');
        console.log('this.editpolicydata--', JSON.stringify(this.editpolicydata));
        console.log('this.editpolicydata--', JSON.stringify(this.oldpolicydata.quoteData, null, 4));
        this.isSpinLoad = true;
        let quoteCompare = this.compareData(this.oldpolicydata?.quoteData, this.editpolicydata?.quoteData);
        let vehicleCompare;
        if (this.policyType != 'Watercraft') {
            vehicleCompare = this.compareData(this.oldpolicydata?.vehicleData, this.editpolicydata?.vehicleData);
        } else {
            vehicleCompare = this.compareData(this.oldpolicydata?.watercraftData, this.editpolicydata?.watercraftData);
        }
        console.log('--changesValue quoteCompare--', quoteCompare);
        console.log('--changesValue vehicleCompare--', vehicleCompare);
        const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
            detail: this.editpolicydata,
        });

        this.dispatchEvent(editPolicyChange);
        const refundAmountChange = new CustomEvent('refundamountchange', {
            detail: this.refundAmount,
        });
        this.dispatchEvent(refundAmountChange);

        if (this.refundAmount == 0) {
            console.log('comes inside only for update data',JSON.stringify(this.editpolicydata));
            const data = await updatePolicyDetails({ 'quoteData': JSON.stringify(this.editpolicydata.quoteData), 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'vehicleData': JSON.stringify(this.editpolicydata.vehicleData), 'towedUnitData': this.editpolicydata.towedUnitData.length > 0 ? JSON.stringify(this.editpolicydata.towedUnitData) : '' });

            if (data.status == 'success') {
                this.goToDetailPage();
            } else {
                this.generateLogs();
                console.log('occur error', JSON.stringify(data, null, 4));
            }
        } else if (this.refundAmount > 0) {
            this.changesnextscreen();
            console.log('comes inside create transaction for charge');
            // const data = await updatePolicyDetails({'quoteData':quoteCompare ? JSON.stringify(this.editpolicydata.quoteData) : null, 'DriverData': JSON.stringify(this.editpolicydata.DriverData), 'vehicleData': vehicleCompare ? JSON.stringify(this.editpolicydata.vehicleData) : null , 'towedUnitData':  this.editpolicydata.towedUnitData.length() > 0 ? JSON.stringify(this.editpolicydata.towedUnitData) : null})

        } else if (this.refundAmount < 0) {
            this.changesnextscreen();
            console.log('comes inside create transaction for refund');
        }
        this.isSpinLoad = false;

    }

    compareData(oldData, newData) {
        let abc = oldData != undefined && Object.keys(oldData);
        let policyCompare = [];

        abc.map((key) => {
            if (oldData[key] != newData[key]) {
                policyCompare.push(false);
            }
        })

        let changesValue = policyCompare.includes(false);
        return changesValue;
    }

    goToDetailPage() {
        console.log('goToDetailPage start');
        let recordId = this.oldpolicydata.policyData.Id;
        window.location.href = `/policy/${recordId}`;

    }

    handlePrevClick = () => {
        console.log('clicked on previous page: ');
        const editPolicyChange = new CustomEvent('editpolicyvaluechange', {
            detail: this.editpolicydata,
        });
        this.dispatchEvent(editPolicyChange);
        console.log('clicked on previous page: ');
        this.changeprevscreen();

    }
    generateLogs() {
        this.dispatchEvent(new CustomEvent('errorgenerated'));
    }

    transformPolicyData(editPolicyData, oldPolicyData) {
        console.log('Data in transformPolicyData editPolicyData', editPolicyData);
        console.log('Data in transformPolicyData oldPolicyData', oldPolicyData);
        const getSafe = (primary, secondary, path, defaultValue = null) => {
            const traverse = (obj, p) =>
                p.split('.').reduce((acc, part) => (acc && acc[part] !== undefined) ? acc[part] : undefined, obj);

            const primaryValue = traverse(primary, path);
            if (primaryValue !== undefined && primaryValue !== null) return primaryValue;

            const secondaryValue = traverse(secondary, path);
            return (secondaryValue !== undefined && secondaryValue !== null) ? secondaryValue : defaultValue;
        };

        const formatTime = (timeInMs) => {
            if (!timeInMs) return '00:00:00';
            // If it's a string in HH:MM:SS format, return as-is
            if (typeof timeInMs === 'string' && /^\d{2}:\d{2}:\d{2}$/.test(timeInMs)) {
                return timeInMs;
            }
            const totalSeconds = Math.floor(timeInMs / 1000);
            const hours = Math.floor(totalSeconds / 3600);
            const minutes = Math.floor((totalSeconds % 3600) / 60);
            const seconds = totalSeconds % 60;
            return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
        };

        const inputPrimary = editPolicyData || {};
        const inputFallback = oldPolicyData || {};

        const userDetails = {
            Email: getSafe(inputPrimary, inputFallback, 'policyData.Contact_Email__c', ''),
            FirstName: getSafe(inputPrimary, inputFallback, 'DriverData.0.First_Name__c', ''),
            LastName: getSafe(inputPrimary, inputFallback, 'DriverData.0.Last_Name__c', ''),
            Phone: '',
            Id: getSafe(inputPrimary, inputFallback, 'DriverData.0.Contact__c', '')
        };

        console.log('user DEtails', userDetails);

        const isBusinessUse = getSafe(inputPrimary, inputFallback, 'vehicleData.Is_the_vehicle_used_for_business_purpose__c', false);
        const isRental = getSafe(inputPrimary, inputFallback, 'vehicleData.Rental__c', 'No') === 'Yes';
        const isSalvage = getSafe(inputPrimary, inputFallback, 'vehicleData.Salvage_Vehicle__c', false);
        const isElectric = getSafe(inputPrimary, inputFallback, 'vehicleData.Electric_Hybrid__c', false);
        const isTowing = getSafe(inputPrimary, inputFallback, 'Is_Towing__c', false)
            || ((inputPrimary.towedUnitData || inputFallback.towedUnitData || []).length > 0);

        const towunitsRaw = inputPrimary.towedUnitData || inputFallback.towedUnitData || [];

        const towunitsList = towunitsRaw.map(towUnit => ({
            Towed_Unit_Type__c: towUnit.Towed_Unit_Type__c || '',
            Towed_Unit_Value__c: towUnit.Towed_Unit_Value__c || '0',
            Days_in_Tow__c: towUnit.Days_in_Tow__c || '1',
            count: 1,
            isDeleteButton: true,
            style: "",
            Year__c: towUnit.Year__c || '',
            Make__c: towUnit.Make__c || '',
            Model__c: towUnit.Model__c || '',
            VIN_Number__c: towUnit.VIN_Number__c || '',
            Plate__c: towUnit.Plate__c || '',
            label: `${towUnit.Make__c || ''} ${towUnit.Model__c || ''} ${towUnit.Year__c || ''} - ${towUnit.VIN_Number__c || ''}`,
            value: towUnit.Id || '',
            Id: towUnit.Id || ''
        }));
        console.log('Towed Unit List', towunitsList);

        const vehicleDetails = {
            is_the_vehicle_used_for_business_purpose__c: isBusinessUse,
            is_there_a_driver_under_21__c: getSafe(inputPrimary, inputFallback, 'quoteData.Is_there_a_driver_under_21__c', 'false') === 'true',
            Is_this_a_Rental_Vehicle__c: isRental,
            salvage_vehicle__c: isSalvage,
            Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.Coverage__c', 'Complete'),
            isTowing: isTowing,
            Electric_Hybrid__c: isElectric,
            towunits: towunitsList,
            Liability__c: getSafe(inputPrimary, inputFallback, 'quoteData.Liability__c', '100,000'),
            Medical__c: getSafe(inputPrimary, inputFallback, 'quoteData.Medical__c', '10,000/50,000'),
            Year__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Year__c', ''),
            Vehicle_sub_type__c: getSafe(inputPrimary, inputFallback, 'policyData.Policy_Type_picklist__c', 'Automobile-Van-Minivan'),
            Make: getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', ''),
            Model: getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', ''),
            Value__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Value__c', '0'),
            towunitsList: towunitsList,
            vehicleList: [
                {
                    Id: getSafe(inputPrimary, inputFallback, 'vehicleData.Id', ''),
                    label: `${getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', '')} ${getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', '')} ${getSafe(inputPrimary, inputFallback, 'vehicleData.Year__c', '')} - ${getSafe(inputPrimary, inputFallback, 'vehicleData.Vin__c', '')}`,
                    value: getSafe(inputPrimary, inputFallback, 'vehicleData.Id', ''),
                    Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.Coverage__c', 'Complete'),
                    Electric_Hybrid__c: isElectric,
                    Liability__c: getSafe(inputPrimary, inputFallback, 'quoteData.Liability__c', '100,000'),
                    Medical__c: getSafe(inputPrimary, inputFallback, 'quoteData.Medical__c', '10,000/50,000'),
                    Year__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Year__c', ''),
                    Vehicle_sub_type__c: getSafe(inputPrimary, inputFallback, 'policyData.Policy_Type_picklist__c', 'Automobile-Van-Minivan'),
                    Make: getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', ''),
                    Model: getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', ''),
                    Value__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Value__c', '0'),
                    Vin__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Vin__c', ''),
                    Registered_Country__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Country__c', ''),
                    Registered_State__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_State__c', ''),
                    licensePlate: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Plate__c', '')
                }
            ],
            Vin__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Vin__c', ''),
            Registered_Country__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Country__c', ''),
            Registered_State__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_State__c', ''),
            licensePlate: getSafe(inputPrimary, inputFallback, 'vehicleData.Registered_Plate__c', ''),
            Id: getSafe(inputPrimary, inputFallback, 'vehicleData.Id', ''),
            Make__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Make__c', ''),
            Model__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Model__c', ''),
            Account_Vehicle__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Account_Vehicle__c', ''),
            Contact__c: getSafe(inputPrimary, inputFallback, 'vehicleData.Contact__c', '')
        };
        console.log('Vehicle Details', vehicleDetails);

        const driverRaw = getSafe(inputPrimary, inputFallback, 'DriverData', []);
        const driverDetails = {
            drivers: driverRaw.map(driver => ({
                Id: driver.Id || '',
                label: `${driver.First_Name__c || ''} ${driver.Last_Name__c || ''} - ${driver.Dob__c || ''} - ${driver.license_number__c || ''}`,
                value: driver.Id || '',
                First_Name__c: driver.First_Name__c || '',
                Last_Name__c: driver.Last_Name__c || '',
                License_Country__c: driver.License_Country__c || '',
                License_state__c: driver.License_state__c || '',
                license_number__c: driver.license_number__c || '',
                Dob__c: driver.Dob__c || '',
                Driver_Type__c: driver.Driver_Type__c === 'Owner',
                Country__c: driver.Country__c || '',
                Country_Text__c: driver.Country__c || '',
                State_Province__c: driver.State_Province__c || '',
                Postal_Code__c: driver.Postal_Code__c || '',
                City__c: driver.City__c || '',
                Address__c: driver.Address__c || '',
                diff: Date.now()
            })),
            companyInformation: {},
        };

        const termOption = {
            Term__c: getSafe(inputPrimary, inputFallback, 'quoteData.Term__c', 'Daily'),
            Start_Date_for_Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.Start_Date_for_Coverage__c', ''),
            Start_Time__c: formatTime(getSafe(inputPrimary, inputFallback, 'quoteData.Start_Time__c', '19800000')),
            End_Date_for_Coverage__c: getSafe(inputPrimary, inputFallback, 'quoteData.End_Date_for_Coverage__c', ''),
            End_Time__c: formatTime(getSafe(inputPrimary, inputFallback, 'quoteData.End_Time__c', '19800000')),
            
            Gold__c: getSafe(inputPrimary, inputFallback, 'quoteData.Gold__c', false),
            Max__c: getSafe(inputPrimary, inputFallback, 'quoteData.Max__c', false),
            Platinum__c: getSafe(inputPrimary, inputFallback, 'quoteData.Platinum__c', false)
        };

        return [
            { userDetails },
            { vehicleDetails },
            { UserType: { UserType: "Customer" } },
            { termOption },
            { territory: { region: getSafe(inputPrimary, inputFallback, 'quoteData.Territory__c', '') } },
            { driverDetails }
        ];
    }

    async createDataForQuoteSave(transformedData) {
        const dataMap = {};
        const finalJson = transformedData;

        finalJson.forEach((entry) => {
            const [key, value] = Object.entries(entry)[0];
            dataMap[key] = value;
        });

        const calculateDaysWithNewDate = (startDateStr, endDateStr) => {
            const startDate = new Date(startDateStr);
            const endDate = new Date(endDateStr);
            const diffMs = endDate - startDate;
            return diffMs / (1000 * 60 * 60 * 24);
        };

        const termDays = calculateDaysWithNewDate(
            dataMap?.termOption?.Start_Date_for_Coverage__c,
            dataMap?.termOption?.End_Date_for_Coverage__c
        );

        const selectedQuote = this.selectedQuote || {}; // Use selectedQuote from component context
        const agentFee = this.agentFee || 0;
        const underwriter = this.selectedQuote?.Vendor != null ? this.selectedQuote?.Vendor : 'Error Vendor';
        const company = dataMap?.territory?.region;
        const dataId = dataMap?.userDetails?.Id;

        const dataMapped = {
            Start_Date_for_Coverage__c: dataMap?.termOption?.Start_Date_for_Coverage__c,
            End_Date_for_Coverage__c: dataMap?.termOption?.End_Date_for_Coverage__c,
            Start_Time__c: dataMap?.termOption?.Start_Time__c,
            End_Time__c: dataMap?.termOption?.End_Time__c,

            Vehicle_used_for_Business_Purposes__c: dataMap?.vehicleDetails?.is_the_vehicle_used_for_business_purpose__c || false,
            Is_there_a_driver_under_21__c: dataMap?.vehicleDetails?.is_there_a_driver_under_21__c || false,
            Is_this_a_Rental_Vehicle__c: dataMap?.vehicleDetails?.Is_this_a_Rental_Vehicle__c === 'Yes',

            Vehicle_Make__c: dataMap?.vehicleDetails?.Make__c,
            Vehicle_Model__c: dataMap?.vehicleDetails?.Model__c,
            Salvage_Vehicle__c: dataMap?.vehicleDetails?.salvage_vehicle__c,
            Vehicle_Value__c: dataMap?.vehicleDetails?.Value__c,
            Vehicle_Year__c: dataMap?.vehicleDetails?.Year__c,

            // Vehicle_Type__c: dataMap?.vehicleDetails?.Vehicle_sub_type__c,
            // Policy_Type_picklist__c: dataMap?.vehicleDetails?.Vehicle_sub_type__c,

            Term__c: dataMap?.termOption?.Term__c,
            Territory__c: company,

            Net_Premium__c: parseFloat(selectedQuote?.Total) - parseFloat(selectedQuote?.IVA) - parseFloat(selectedQuote?.BrokerFee)-parseFloat(selectedQuote?.TotalSurcharges),
            Broker_Policy_Fee__c: selectedQuote?.BrokerFee,
            Term_Days__c: termDays != null ? termDays : '0', // Add Days
            I_V_A_Mex_Tax__c: selectedQuote?.IVA,
            Quote_Value__c: agentFee !== null ? parseFloat(selectedQuote?.Total || 0) + parseFloat(agentFee) : selectedQuote?.Total,
            Surcharge__c: selectedQuote?.TotalSurcharges,

            Underwriter__c: underwriter,

            Coverage__c: dataMap?.vehicleDetails?.Coverage__c,
            Towed_Unit__c: dataMap?.vehicleDetails?.isTowing,

            Vehicle_deductible_comprehensive__c: selectedQuote?.TotalTheft,

            Physical_Damage__c: selectedQuote?.PropertyDamage || '',
            Total_Theft_Payment__c: selectedQuote?.TotalTheft || '',
            Liability_Payment__c: selectedQuote?.Liability || '',
            Medical_Payment__c: selectedQuote?.Medical || '',
            Platinum_Endorsment__c: selectedQuote?.platinumEndorsementPayment || '',

            Liability__c: dataMap?.vehicleDetails?.Liability__c,
            Medical__c: dataMap?.vehicleDetails?.Medical__c,

            Agent_Fee__c: agentFee,
            Old_Net_Premium__c: agentFee !== null ? parseFloat(selectedQuote?.Total || 0) + parseFloat(agentFee) : selectedQuote?.Total
        };

        console.log('Final Payload Object and Data Mapped:', dataMapped);
        return dataMapped;
    }

}