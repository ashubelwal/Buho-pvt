import { LightningElement, api } from 'lwc';
import getEditPolicyDetail from '@salesforce/apex/Mex_PolicyEditController.getEditPolicyDetail';
import checkCommunityUserAndFetchDetails from '@salesforce/apex/Mex_existingCustomerFlowController.checkCommunityUserAndFetchDetails';
import LetstacklethePaymentnow from '@salesforce/label/c.TR_Let_s_tackle_the_Payment_now';


export default class Nc_policyEditMainScreen extends LightningElement {
    label = {
        LetstacklethePaymentnow,
    };
    @api screenname;
    @api recordId;
    @api oldPolicy = {};
    @api editPolicy = {};
    @api disableDate = false;
    @api connectedcallback = false;
    @api refundAmount;
    @api isEditPolicy = 'Yes';
    @api isCommunityUser = false;
    @api driverData;
    @api towedUnitData;
    policyType;
    isShowCaseLog = false;
    isOpenLogCaseModal = false;
    async connectedCallback() {
        this.isOpenLogCaseModal = false;
        const recordId = sessionStorage.getItem('recordId');
        this.recordId = recordId;
        console.log(this.recordId);
        // this.disableDate = true;
        // this.isEditPolicy = true;
        //if (Object.keys(this.oldPolicy).length > 0 && Object.keys(this.editPolicy).length > 0) return;
        const data = await checkCommunityUserAndFetchDetails();
        const parsedData = JSON.parse(data);
        console.log(JSON.stringify(parsedData, null, 4));
        if (parsedData.status == 'success' && parsedData.userType == true) {
            this.isCommunityUser = parsedData.userType;
            this.driverData = parsedData.drivers && parsedData.drivers.length > 0 ? parsedData.drivers : [];
            this.towedUnitData = parsedData.towedUnits && parsedData.towedUnits.length > 0 ? parsedData.towedUnits : [];
            await this.fetchPolicyData();
        }
    }

    handleEditPolicyChange(event) {
        console.log('recieved data ');
        console.log('recieved data ' + JSON.stringify(event.detail));
        this.editPolicy = { ...this.editPolicy, ...event.detail };
    }

    handleRefundAmountChange(event) {
        this.refundAmount = event.detail;
    }

    renewconnectedcallback(event) {
        console.log('recieved data ' + JSON.stringify(event.detail));
        if (event.detail == true) {
            this.connectedcallback = true;
        } else {
            this.connectedcallback = false;
        }
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
        const transformedData = this.transformPolicyData(this.editPolicy);
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
        return this.screenname == 'confirmScreen';
    }
    get isPaymentDetail() {
        return this.screenname == 'paymentDetail';
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
    changeNextScreen = (val) => {
        console.log('new logs ');
        console.log('--next screen --', this.screenname);
        if (this.screenname == 'termOptions') {
            if (this.policyType == 'Watercraft') {
                this.screenname = 'ReviewWatercraft';
            } else {
                this.screenname = 'ReviewVehicle';
            }
        } else if (this.screenname == 'ReviewVehicle' && this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'ReviewVehicle' && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && !this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'ReviewVehicle' && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c && this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'ReviewWatercraft') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'companyInfo' && this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'companyInfo' && !this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'lienholderDetails') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'DriverDetail' && this.policyType != 'Watercraft' && this.policyType != 'Motorcycle/Street Legal ATV') {
            this.screenname = 'isTowing';
        } else if (this.screenname == 'DriverDetail' && (this.policyType == 'Watercraft' || this.policyType == 'Motorcycle/Street Legal ATV')) {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'isTowing') {
            if (this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'confirmScreen';
            }
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'confirmScreen') {
            if (this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetailsFinal';
            } else {
                this.screenname = 'paymentDetail';
            }
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'paymentDetail';
        }
    }

    changePrevScreen = () => {
        if (this.screenname == 'termOptions') {
        } else if (this.screenname == 'ReviewWatercraft') {
            this.screenname = 'termOptions';
        } else if (this.screenname == 'ReviewVehicle') {
            this.screenname = 'termOptions';
        } else if (this.screenname == 'companyInfo') {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'lienholderDetails' && this.editPolicy.vehicleData && this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'lienholderDetails' && this.editPolicy.vehicleData && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'ReviewVehicle';
        } else if (this.screenname == 'DriverDetail' && this.editPolicy.vehicleData && this.editPolicy.vehicleData.Is_Lienholder__c) {
            this.screenname = 'lienholderDetails';
        } else if (this.screenname == 'DriverDetail' && this.editPolicy.vehicleData && !this.editPolicy.vehicleData.Is_Lienholder__c && this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            this.screenname = 'companyInfo';
        } else if (this.screenname == 'DriverDetail' && this.editPolicy.vehicleData && !this.editPolicy.vehicleData.Is_Lienholder__c && !this.editPolicy.vehicleData.Is_the_vehicle_registered_to_a_business__c) {
            // this.screenname = 'ReviewVehicle';
            if (this.policyType == 'Watercraft') {
                this.screenname = 'ReviewWatercraft';
            } else {
                this.screenname = 'ReviewVehicle';
            }
        } else if (this.screenname == 'DriverDetail' && this.policyType == 'Watercraft') {
            this.screenname = 'ReviewWatercraft';
        } else if (this.screenname == 'isTowing') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetails') {
            this.screenname = 'isTowing';
        } else if (this.screenname == 'confirmScreen' && this.policyType != 'Watercraft') {
            if (this.policyType == 'Motorcycle/Street Legal ATV') {
                this.screenname = 'ReviewVehicle';
            } else if (this.policyType != 'Motorcycle/Street Legal ATV' && this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetails';
            } else {
                this.screenname = 'isTowing';
            }
        } else if (this.screenname == 'confirmScreen' && this.policyType == 'Watercraft') {
            this.screenname = 'DriverDetail';
        } else if (this.screenname == 'towedDetailsFinal') {
            this.screenname = 'confirmScreen';
        } else if (this.screenname == 'paymentDetail') {
            if (this.editPolicy.Is_Towing__c) {
                this.screenname = 'towedDetailsFinal';
            } else {
                this.screenname = 'confirmScreen';
            }
        }
    }

    fetchPolicyData = async () => {
        try {
            const { status, ...rest } = await getEditPolicyDetail({ policyId: this.recordId });
            console.log('Res--->', rest);

            // Normalize Medical values
            if (rest.quoteData?.Medical__c === '4,000/20,000') {
                rest.quoteData.Medical__c = '4,000/16,000';
            }
            if (rest.policyData?.Medical_picklist__c === '4,000/20,000') {
                rest.policyData.Medical_picklist__c = '4,000/16,000';
            }

            console.log('Res--->', rest);
            if (status === 'success') {
                this.oldPolicy = { ...rest };
                this.editPolicy = { ...rest };
                this.policyType = rest.policyData.Policy_Type_picklist__c;
            } else {
                console.log('Inside Else ::: ', status);
            }

            this.screenname = 'termOptions';
        } catch (error) {
            console.log(error);
            if (error.status === 500 && error.statusText === 'Server Error') {
                // handle server error
            }
        }
    };

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
            Is_the_vehicle_registered_to_a_business__c: getSafe(inputData, 'vehicleData.Is_the_vehicle_registered_to_a_business__c', false),
            Is_this_a_Rental_Vehicle__c: isRental,
            salvage_vehicle__c: isSalvage,
            Coverage__c: getSafe(inputData, 'quoteData.Coverage__c', 'Complete'),
            isTowing: isTowing,
            Electric_Hybrid__c: isElectric,
            towunits: towunitsList,
            Liability__c: getSafe(inputData, 'policyData.Liability_picklist__c', '300000'),
            Medical__c: getSafe(inputData, 'policyData.Medical_picklist__c', '10000/50000'),
            Year__c: getSafe(inputData, 'vehicleData.Year__c', ''),
            Vehicle_sub_type__c: getSafe(inputData, 'policyData.Policy_Type_picklist__c', 'Automobile-Van-Minivan'),
            Make: getSafe(inputData, 'vehicleData.Make__c', ''),
            Model: getSafe(inputData, 'vehicleData.Model__c', ''),
            Value__c: getSafe(inputData, 'vehicleData.Value__c', '0'),
            towunitsList: towunitsList,
            vehicleList: [
                {
                    Id: getSafe(inputData, 'vehicleData.Id', ''),
                    label: `${getSafe(inputData, 'vehicleData.Make__c', '')} ${getSafe(inputData, 'vehicleData.Model__c', '')} ${getSafe(inputData, 'vehicleData.Year__c', '')} - ${getSafe(inputData, 'vehicleData.Vin__c', '')}`,
                    value: getSafe(inputData, 'vehicleData.Id', ''),
                    Coverage__c: getSafe(inputData, 'quoteData.Coverage__c', 'Complete'),
                    Electric_Hybrid__c: isElectric,
                    Liability__c: getSafe(inputData, 'policyData.Liability_picklist__c', '300000'),
                    Medical__c: getSafe(inputData, 'policyData.Medical_picklist__c', '10000/50000'),
                    Year__c: getSafe(inputData, 'vehicleData.Year__c', ''),
                    Vehicle_sub_type__c: getSafe(inputData, 'policyData.Policy_Type_picklist__c', 'Automobile-Van-Minivan'),
                    Make: getSafe(inputData, 'vehicleData.Make__c', ''),
                    Model: getSafe(inputData, 'vehicleData.Model__c', ''),
                    Value__c: getSafe(inputData, 'vehicleData.Value__c', '0'),
                    Vin__c: getSafe(inputData, 'vehicleData.Vin__c', ''),
                    Registered_Country__c: getSafe(inputData, 'vehicleData.Registered_Country__c', ''),
                    Registered_State__c: getSafe(inputData, 'vehicleData.Registered_State__c', ''),
                    licensePlate: getSafe(inputData, 'vehicleData.Registered_Plate__c', '')
                }
            ],
            Vin__c: getSafe(inputData, 'vehicleData.Vin__c', ''),
            Registered_Country__c: getSafe(inputData, 'vehicleData.Registered_Country__c', ''),
            Registered_State__c: getSafe(inputData, 'vehicleData.Registered_State__c', ''),
            licensePlate: getSafe(inputData, 'vehicleData.Registered_Plate__c', ''),
            Id: getSafe(inputData, 'vehicleData.Id', ''),
            Make__c: getSafe(inputData, 'vehicleData.Make__c', ''),
            Model__c: getSafe(inputData, 'vehicleData.Model__c', ''),
            Account_Vehicle__c: getSafe(inputData, 'vehicleData.Account_Vehicle__c', ''),
            Contact__c: getSafe(inputData, 'vehicleData.Contact__c', '')
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
            }),
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
            driverList: (this.driverData || []).map(driver => ({
                Id: getSafe(driver, 'Id', ''),
                label: `${getSafe(driver, 'First_Name__c', '')} ${getSafe(driver, 'Last_Name__c', '')} - ${getSafe(driver, 'Dob__c', '')} - ${getSafe(driver, 'license_number__c', '')}`,
                value: getSafe(driver, 'Id', ''),
                First_Name__c: getSafe(driver, 'First_Name__c', ''),
                Last_Name__c: getSafe(driver, 'Last_Name__c', ''),
                License_Country__c: getSafe(driver, 'License_Country__c', ''),
                License_state__c: getSafe(driver, 'License_state__c', ''),
                license_number__c: getSafe(driver, 'license_number__c', ''),
                Dob__c: getSafe(driver, 'Dob__c', ''),
                Driver_Type__c: getDriverType(driver.Driver_Type__c), 
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
            Term__c: getSafe(inputData, 'policyData.Term__c', 'Daily'),
            Start_Date_for_Coverage__c: getSafe(inputData, 'policyData.Start_Date__c', ''),
            Start_Time__c: formatTime(getSafe(inputData, 'policyData.Start_Time__c', '19800000')),
            End_Date_for_Coverage__c: getSafe(inputData, 'policyData.End_Date__c', ''),
            End_Time__c: formatTime(getSafe(inputData, 'policyData.End_Time__c', '19800000'))
        };

        return [
            { userDetails },
            { vehicleDetails },
            { UserType: { UserType: "Customer" } },
            { termOption },
            { territory: { region: getSafe(inputData, 'policyData.Territory_picklist__c', '') } },
            { driverDetails }
        ];
    }
}