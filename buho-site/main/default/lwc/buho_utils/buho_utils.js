// ---------- Generic safe JSON parser ----------
export function safeParseJson(value, logLabel = 'JSON') {
    try {
        return value ? JSON.parse(value) : null;
    } catch (e) {
        console.error(`Error parsing ${logLabel}:`, e);
        return null;
    }
}

// ---------- Transform Towed Units ----------
export function transformTowedUnits(unitsArray = []) {
    if (!Array.isArray(unitsArray)) return [];

    return unitsArray.map(towDetail => ({
        Towed_Unit_Type__c: towDetail.Towed_Unit_Type__c || null,
        Towed_Unit_Value__c: towDetail.Towed_Unit_Value__c || null,
        Days_in_Tow__c: towDetail.Days_in_Tow__c || null,
        count: towDetail.towedCount || null,
        isDeleteButton: towDetail.isDeleteTowedButton !== false,
        style: towDetail.selectedStyle || '',
        Year__c: towDetail.Year__c || null,
        Make__c: towDetail.Make__c || null,
        Model__c: towDetail.Model__c || null,
        VIN_Number__c: towDetail.VIN_Number__c || null,
        Plate__c: towDetail.Plate__c || null
    }));
}

// ---------- Main reusable transformer ----------
export function createTransformedData(returnLeadValue) {
    console.log('@@@returnLeadValue', returnLeadValue);
    const leadInfo = returnLeadValue?.LeadInfo || {};
    const quoteInfo = returnLeadValue?.QuoteInfo || {};

    const vehicleData = safeParseJson(leadInfo.Vehicle_details__c, 'Vehicle_details__c');
    const driverDetails = safeParseJson(leadInfo.Driver_details__c, 'Driver_details__c');
    const companyDetails = safeParseJson(leadInfo.Company_details__c, 'Company_details__c');
    const lienholderDetails = safeParseJson(leadInfo.Lienholder_info__c, 'Lienholder_info__c');
    const termsAndAlerts = safeParseJson(leadInfo.Terms_Alert__c, 'Terms_Alert__c');
    const termDetails = safeParseJson(leadInfo.Term_options__c, 'Term_options__c')?.[0];
    const rawTowDetails = safeParseJson(leadInfo.Towing__c, 'Towing__c');
    const towData = rawTowDetails
        ? transformTowedUnits(rawTowDetails)
        : [];
    const vehicleInstance = {
        is_the_vehicle_used_for_business_purpose__c:
            vehicleData?.Is_the_vehicle_used_for_business_purpose__c ?? false,
        Is_the_vehicle_registered_to_a_business__c:
            vehicleData?.Is_the_vehicle_used_for_business_purpose__c ?? false,
        is_there_a_driver_under_21__c:
            vehicleData?.Is_there_a_driver_under_21__c ?? false,
        Is_this_a_Rental_Vehicle__c:
            vehicleData?.Is_this_a_Rental_Vehicle__c ?? false,
        salvage_vehicle__c: vehicleData?.Salvage_Vehicle__c ?? false,
        Coverage__c: quoteInfo?.Coverage__c ?? 'Complete',
        isTowing: vehicleData?.isTowing ?? false,
        Electric_Hybrid__c: vehicleData?.Electric_Hybrid__c ?? false,
        towunits: towData.length ? towData : (vehicleData?.towunits ?? []),
        Liability__c:
            quoteInfo.Liability__c ??
            (vehicleData?.Liability ? parseInt(vehicleData.Liability) : '100,000'),
        Medical__c:
            quoteInfo.Medical__c ?? vehicleData?.Medical ?? '10,000/50,000',
        Year__c: vehicleData?.Year__c ?? '2025',
        Vehicle_sub_type__c:
            vehicleData?.Vehicle_sub_type__c ?? 'Automobile-Van-Minivan',
        Make: vehicleData?.Make__c ?? vehicleData?.Make ?? null,
        Make__c: vehicleData?.Make__c ?? vehicleData?.Make ?? null,
        Model__c: vehicleData?.Model__c ?? vehicleData?.Model ?? null,
        Model: vehicleData?.Model__c ?? vehicleData?.Model ?? null,
        Value__c: vehicleData?.Value__c ?? null,
        licensePlate: vehicleData?.Registered_Plate__c ?? null,
        Registered_Plate__c: vehicleData?.Registered_Plate__c ?? null,
        Vin__c: vehicleData?.Vin__c ?? null,
        Registered_Country__c: vehicleData?.Registered_Country__c ?? null,
        Registered_State__c: vehicleData?.Registered_State__c ?? null,
        isOtherModel: vehicleData?.isOtherModel ?? null
    };

    const finalizeVehicleDetails = { ...vehicleInstance };

    if (vehicleData.BusinessAddress__c) {
        finalizeVehicleDetails.BusinessAddress__c = vehicleData.BusinessAddress__c;
    }

    return [
        {
            userDetails: {
                Company: leadInfo.Company ?? null,
                Email: leadInfo.Email ?? null,
                FirstName: leadInfo.FirstName ?? null,
                LastName: leadInfo.LastName ?? null,
                Phone: leadInfo.Phone ?? null,
                Id: leadInfo.Id ?? null,
                LeadSource: leadInfo.LeadSource ?? null,
            }
        },
        {
            vehicleDetails: vehicleInstance
        },
        {
            finalizeVehicleDetails: finalizeVehicleDetails
        },
        {
            territory: {
                region: leadInfo.Territory_Options__c ?? null
            }
        },
        {
            lienholderInformation: {
                ...lienholderDetails
            }
        },
        {
            driverDetails: {
                drivers: driverDetails ?? [],
                companyInformation: { ...companyDetails }
            }
        },
        {
            finalDetails: {
                ...termsAndAlerts
            }
        },
        {
            termOption: {
                ...termDetails
            }
        },
        {
            quotePage: {
                QuoteData: {
                    ...quoteInfo
                }
            }
        }
    ];
}

export function getCustomerRecord(data) {
    let customerRecord = {};

    // 1. User Details
    const userDetails = data.find(d => d.userDetails)?.userDetails;
    if (userDetails) {
        customerRecord = { ...customerRecord, ...userDetails };
    }

    // 2. Policy Type
    const quoteData = data.find(d => d.quotePage)?.quotePage?.QuoteData;
    if (quoteData) {
        customerRecord = {
            ...customerRecord,
            policyType: quoteData.Policy_Type_picklist__c
        };
    }

    // 3. Quote Record (destructure term__c, add back as Term__c)
    if (quoteData) {
        const { term__c, ...rest } = quoteData;
        customerRecord = {
            ...customerRecord,
            quoteRecord: {
                ...customerRecord.quoteRecord,
                ...rest,
                Term__c: term__c !== undefined ? term__c : 'Daily'
            }
        };
    }

    // 4. Watercraft Data (index 0 if exists)
    const watercraftRecord = data.find(d => d.watercraftRecord)?.watercraftRecord;
    if (watercraftRecord !== undefined) {
        customerRecord = {
            ...customerRecord,
            watercraftData: {
                ...customerRecord.watercraftData,
                ...watercraftRecord[0]
            }
        };
    }

    // 5. Driver Data
    const driverDetails = data.find(d => d.driverDetails)?.driverDetails;
    customerRecord = {
        ...customerRecord,
        DriverData: driverDetails?.drivers?.length > 0
            ? [...driverDetails.drivers]
            : []
    };

    // 6. Vehicle Details
    const vehicleDetails = data.find(d => d.vehicleDetails)?.vehicleDetails;
    if (vehicleDetails) {
        customerRecord = {
            ...customerRecord,
            vehicleData: {
                Id: vehicleDetails.Id,
                Make__c: vehicleDetails.Make__c,
                Model__c: vehicleDetails.Model__c,
                Year__c: vehicleDetails.Year__c,
                Vin__c: vehicleDetails.Vin__c,
                Coverage__c: vehicleDetails.Coverage__c,
                Liability__c: vehicleDetails.Liability__c,
                Medical__c: vehicleDetails.Medical__c,
                Vehicle_sub_type__c: vehicleDetails.Vehicle_sub_type__c,
                Value__c: vehicleDetails.Value__c,
                licensePlate: vehicleDetails.licensePlate,
                Registered_Country__c: vehicleDetails.Registered_Country__c,
                Registered_State__c: vehicleDetails.Registered_State__c,
                isTowing: vehicleDetails.isTowing,
                Electric_Hybrid__c: vehicleDetails.Electric_Hybrid__c,
                salvage_vehicle__c: vehicleDetails.salvage_vehicle__c,
                Is_this_a_Rental_Vehicle__c: vehicleDetails.Is_this_a_Rental_Vehicle__c,
                is_there_a_driver_under_21__c: vehicleDetails.is_there_a_driver_under_21__c,
                is_the_vehicle_used_for_business_purpose__c: vehicleDetails.is_the_vehicle_used_for_business_purpose__c,
                Account_Vehicle__c: vehicleDetails.Account_Vehicle__c,
                Contact__c: vehicleDetails.Contact__c,
                vehicleList: vehicleDetails.vehicleList ?? [],
                towunitsList: vehicleDetails.towunitsList ?? [],
                towunits: vehicleDetails.towunits ?? []
            }
        };
    }

    // 7. Term Options
    const termOption = data.find(d => d.termOption)?.termOption;
    if (termOption) {
        customerRecord = {
            ...customerRecord,
            termOption: { ...termOption }
        };
    }

    // 8. Territory
    const territory = data.find(d => d.territory)?.territory;
    if (territory) {
        customerRecord = {
            ...customerRecord,
            territory: { ...territory }
        };
    }

    // 9. Tow Details
    const towDetails = data.find(d => d.towDetails)?.towDetails;
    if (towDetails) {
        customerRecord = {
            ...customerRecord,
            towDetails: [...towDetails]
        };
    }

    // 10. Finalize Vehicle Details
    const finalizeVehicleDetails = data.find(d => d.finalizeVehicleDetails)?.finalizeVehicleDetails;
    if (finalizeVehicleDetails) {
        customerRecord = {
            ...customerRecord,
            finalizeVehicleDetails: { ...finalizeVehicleDetails }
        };
    }

    // 11. User Type
    const userType = data.find(d => d.UserType)?.UserType;
    if (userType) {
        customerRecord = {
            ...customerRecord,
            userType: userType.UserType  // "Customer"
        };
    }

    return customerRecord;
}

export function log(...args) {
    console.log(...args);
}