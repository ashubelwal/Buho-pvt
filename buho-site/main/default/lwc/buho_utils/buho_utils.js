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

    return [
        {
            userDetails: {
                Company: leadInfo.Company ?? null,
                Email: leadInfo.Email ?? null,
                FirstName: leadInfo.FirstName ?? null,
                LastName: leadInfo.LastName ?? null,
                Phone: leadInfo.Phone ?? null,
                Id: leadInfo.Id ?? null
            }
        },
        {
            vehicleDetails: {
                is_the_vehicle_used_for_business_purpose__c:
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
                Model: vehicleData?.Model__c ?? vehicleData?.Model ?? null,
                Value__c: vehicleData?.Value__c ?? null
            }
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
        }
    ];
}
