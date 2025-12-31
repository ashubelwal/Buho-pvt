/**
* @File Name : FormatPayload.cls
* @Description : Apex class to build frontend-compatible payload from Policy ID
* @Author : Adarsh kumar
* @Last Modified By : Adarsh kumar
* @Last Modified On : July 16, 2025
* @Modification Log : 
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | July 16, 2025 |   | Initial Version
**/

public class PolicyFormatter{

        public static List<Map<String, Object>> transformPolicyData(String policyId) {
        // Step 1: Query full policy data (from your original query)
        Policy__c policy = [
            SELECT Id, Chubb_Policy_Number__c, Agent_Brokerage_Fee__c, Name, Created_At__c, CreatedDate, Issued_At__c,
                   Contact__r.Name, End_at__c, Start_at__c, Policy_Type_picklist__c,
                   Contact__r.Date_of_Birth__c, Contact__r.Street__c, Start_Time__c, End_Time__c,
                   End_Date__c, Package__c, Underwriter_picklist__c, Contact__r.Street_2__c,
                   Contact__r.State__c, Contact__r.Postal_Code__c, Contact__r.Email,
                   Contact__r.City__c, Contact__r.Country__c, Contact__r.Phone,
                   contact__r.MailingAddress, Insured_value__c,
                   Vehicle_deductible_comprehensive__c, Contact__r.MailingState,
                   Contact__r.MailingCity, Contact__r.MailingStreet, Third_Party_Bodily_Injury__c,
                   Property_Damage_Liability__c, Contact__r.MailingPostalCode,
                   Contact__r.MailingCountry, Territory_picklist__c, Surcharge__c,
                   What_is_the_purpose_of_trip__c, Net_Premium__c, Policy_Fee__c,
                   Broker_Policy_Fee__c, Total_Premium_Amount__c, Liability_picklist__c,
                   Vehicle_deductible_collision__c, Under_21__c, Watercraft__r.Year__c,
                   (SELECT Id, Id__c , Name FROM Transactions__r),
                   Watercraft__c, Watercraft__r.Make__c, Watercraft__r.Model__c,
                   (SELECT Id, Primary_insured__c, Driver__c FROM Quote_Drivers__r),
                   Quote_c__c, Quote_c__r.Is_there_a_driver_under_21__c,
                   Quote_c__r.Is_the_Maximum_Speed_more_than_50_mph__c,
                   Quote_c__r.Is_the_owner_living_in_Mexico__c,
                   Quote_c__r.Is_there_a_driver_over_75__c,
                   Quote_c__r.Coverage__c,Quote_c__r.Territory__c, 
                   Quote_c__r.Term__c,Quote_c__r.Start_Date_for_Coverage__c, Quote_c__r.End_Date_for_Coverage__c, Quote_c__r.Start_Time__c, Quote_c__r.End_Time__c,  
                   Quote_c__r.Liability__c, Quote_c__r.Medical__c,Quote_c__r.Max__c,Quote_c__r.Gold__c,Quote_c__r.Platinum__c,                  
                   Vehicle_Policy__r.Is_Lienholder__c,
                   Vehicle_Policy__r.Is_the_vehicle_registered_to_a_business__c,
                   Vehicle_Policy__r.Is_vehicle_owned_by_a_company_or_rented__c,
                   Vehicle_Policy__r.Company_Name__c, Vehicle_Policy__r.Company_Address__c,
                   Vehicle_Policy__r.Company_City__c, Vehicle_Policy__r.Company_Zip__c,
                   Vehicle_Policy__r.Company_State__c, Vehicle_Policy__r.Company_Phone__c,
                   Vehicle_Policy__r.Vehicle_Owner_Name__c,
                   Vehicle_Policy__r.Vehicle_Owner_Phone__c,
                   Vehicle_Policy__r.Vehicle_Owner_Address__c,
                   Vehicle_Policy__r.Vehicle_Owner_Postal_Code__c,
                   Vehicle_Policy__r.Vehicle_Owner_City__c,
                   Vehicle_Policy__r.Vehicle_Owner_Country__c,
                   Vehicle_Policy__r.Vehicle_Owner_State__c,
                   Vehicle_Policy__r.Lienholder_Postal_Code__c,
                   Vehicle_Policy__r.Lienholder_Phone__c,
                   Vehicle_Policy__r.Lienholder_Street__c,
                   Vehicle_Policy__r.Lienholder_Street_2__c,
                   Vehicle_Policy__r.Lienholder_State__c,
                   Vehicle_Policy__r.Lienholder_City__c,
                   Vehicle_Policy__r.Lienholder_Country__c,
                   Vehicle_Policy__c, Vehicle_Policy__r.Lienholder_name__c,
                   Vehicle_Policy__r.Year__c, Vehicle_Policy__r.Vin__c,
                   Vehicle_Policy__r.Make__c, Vehicle_Policy__r.Registered_Plate__c,
                   Vehicle_Policy__r.Model__c, Vehicle_Policy__r.Registered_State__c,
                   Vehicle_Policy__r.Value__c,Vehicle_Policy__r.Rental__c,Vehicle_Policy__r.Salvage_Vehicle__c,
                   Vehicle_Policy__r.Registered_Country__c,
                   Vehicle_Policy__r.Electric_Hybrid__c,
                   Vehicle_Policy__r.Domestic_Insurance_Name__c,
                   Vehicle_Policy__r.Domestic_Insurance_Phone__c,
                   Vehicle_Policy__r.Domestic_Insurance_Policy__c,
                   Medical_picklist__c, I_V_A_Mex_Tax__c, Term_days__c,
                   Start_Date__c, Agency__c, Agency__r.Email
            FROM Policy__c
            WHERE Id =:policyId
            LIMIT 1
        ];

        // Step 2: Query Drivers
        Set<Id> driverIds = new Set<Id>();
        for (Quote_Driver__c qd : policy.Quote_Drivers__r) {
            if (qd.Driver__c != null) {
                driverIds.add(qd.Driver__c);
            }
        }

        List<Driver__c> drivers = new List<Driver__c>();
        if (!driverIds.isEmpty()) {
            drivers = [
                SELECT Id, First_Name__c, Last_Name__c, license_number__c, DOB__c,
                       License_Country__c, License_state__c, Country__c, State_Province__c,
                       Postal_Code__c, City__c, Address__c, Driver_Type__c
                FROM Driver__c
                WHERE Id IN :driverIds
            ];
        }

        // Step 3: Query Towed Units
        List<Towed_Unit__c> towedUnits = [
            SELECT Id, name, Account__c, Contact__c, Lead__c, Make__c, Model__c, Plate__c,
                   Days_in_Tow__c, Policy__c, Quote_c__c, Street_Legal__c,
                   Towed_Unit_Type__c, Towed_Unit_Value__c, Towing_Terms__c, VIN_Number__c,
                   Year__c
            FROM Towed_Unit__c
            WHERE Id IN (
                SELECT Towed_Unit__c
                FROM Quote_Towed_Unit__c
                WHERE Policy__c = :policy.Id
            )
        ];

        // Step 4: Format using PolicyFormatter
        return format(policy, drivers, towedUnits);
    }

    public static List<Map<String, Object>> format(Policy__c policy, List<Driver__c> drivers, List<Towed_Unit__c> towedUnits) {
        Quote__c q = policy.Quote_c__r;
        Vehicle__c v = policy.Vehicle_Policy__r;

        Map<String, Object> userDetails = new Map<String, Object>{
            'Email' => policy.Contact__r.Email,
            'FirstName' => drivers.size() > 0 ? drivers[0].First_Name__c : '',
            'LastName' => drivers.size() > 0 ? drivers[0].Last_Name__c : '',
            'Phone' => policy.Contact__r.Phone
        };

        List<Map<String, Object>> towList = new List<Map<String, Object>>();
        for (Towed_Unit__c t : towedUnits) {
            towList.add(new Map<String, Object>{
                'Towed_Unit_Type__c' => t.Towed_Unit_Type__c,
                'Towed_Unit_Value__c' => t.Towed_Unit_Value__c,
                'Days_in_Tow__c' => t.Days_in_Tow__c,
                'count' => 1,
                'isDeleteButton' => true,
                'style' => '',
                'Year__c' => t.Year__c,
                'Make__c' => t.Make__c,
                'Model__c' => t.Model__c,
                'VIN_Number__c' => t.VIN_Number__c,
                'Plate__c' => t.Plate__c,
                'label' => t.Make__c + ' ' + t.Model__c + ' ' + t.Year__c + ' - ' + t.VIN_Number__c,
                'value' => t.Id,
                'Id' => t.Id
            });
        }

        Map<String, Object> vehicleDetails = new Map<String, Object>{
            'Is_the_vehicle_registered_to_a_business__c' => v.Is_the_vehicle_registered_to_a_business__c,
            'is_there_a_driver_under_21__c' => String.valueOf(q.Is_there_a_driver_under_21__c) == 'true',
            'Is_this_a_Rental_Vehicle__c' => String.valueOf(v.Rental__c) == 'Yes',
            'salvage_vehicle__c' => v.Salvage_Vehicle__c,
            'Coverage__c' => q.Coverage__c,
            'isTowing' => towedUnits.size() > 0,
            'Electric_Hybrid__c' => v.Electric_Hybrid__c,
            'towunits' => towList,
            'Liability__c' => q.Liability__c,
            'Medical__c' => q.Medical__c,
            'Year__c' => v.Year__c,
            'Vehicle_sub_type__c' => policy.Policy_Type_picklist__c,
            'Make' => v.Make__c,
            'Model' => v.Model__c,
            'Value__c' => v.Value__c,
            'Vin__c' => v.Vin__c,
            'Registered_Country__c' => v.Registered_Country__c,
            'Registered_State__c' => v.Registered_State__c,
            'licensePlate' => v.Registered_Plate__c,
            'Id' => v.Id
        };

        Map<String, Object> termOption = new Map<String, Object>{
            'Term__c' => q.Term__c,
            'Gold__c' => q.Gold__c,
            'Max__c' => q.Max__c,
            'Platinum__c' => q.Platinum__c,
            'Start_Date_for_Coverage__c' => q.Start_Date_for_Coverage__c,
            'Start_Time__c' => formatTime(q.Start_Time__c),
            'End_Date_for_Coverage__c' => q.End_Date_for_Coverage__c,
            'End_Time__c' => formatTime(q.End_Time__c)
        };

        List<Map<String, Object>> driverList = new List<Map<String, Object>>();
        for (Driver__c d : drivers) {
            driverList.add(new Map<String, Object>{
                'Id' => d.Id,
                'label' => d.First_Name__c + ' ' + d.Last_Name__c + ' - ' + String.valueOf(d.DOB__c) + ' - ' + d.license_number__c,
                'value' => d.Id,
                'First_Name__c' => d.First_Name__c,
                'Last_Name__c' => d.Last_Name__c,
                'License_Country__c' => d.License_Country__c,
                'License_state__c' => d.License_state__c,
                'license_number__c' => d.license_number__c,
                'Dob__c' => d.DOB__c,
                'Driver_Type__c' => d.Driver_Type__c == 'Owner',
                'Country__c' => d.Country__c,
                'Country_Text__c' => d.Country__c,
                'State_Province__c' => d.State_Province__c,
                'Postal_Code__c' => d.Postal_Code__c,
                'City__c' => d.City__c,
                'Address__c' => d.Address__c
            });
        }

        Map<String, Object> driverDetails = new Map<String, Object>{
            'drivers' => driverList,
            'companyInformation' => new Map<String, Object>()
        };

        return new List<Map<String, Object>>{
            new Map<String, Object>{ 'userDetails' => userDetails },
            new Map<String, Object>{ 'vehicleDetails' => vehicleDetails },
            new Map<String, Object>{ 'UserType' => new Map<String, Object>{ 'UserType' => 'Customer' } },
            new Map<String, Object>{ 'termOption' => termOption },
            new Map<String, Object>{ 'territory' => new Map<String, Object>{ 'region' => q.Territory__c } },
            new Map<String, Object>{ 'driverDetails' => driverDetails }
        };
    }

private static String formatTime(Object timeVal) {
    if (timeVal == null) return '00:00:00';

    // Handle already formatted string
    if (timeVal instanceof String) {
        String timeStr = (String)timeVal;

        // If it's in HH:mm:ss format, return as-is
        if (Pattern.matches('\\d{2}:\\d{2}:\\d{2}', timeStr)) {
            return timeStr;
        }

        // If it's in ISO format like 03:30:00.000Z
        if (Pattern.matches('\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z', timeStr)) {
            return timeStr.substring(0, 8); // Take only HH:mm:ss
        }

        // If it's only numbers in string, try parsing as milliseconds
        if (Pattern.matches('\\d+', timeStr)) {
            return convertMillisecondsToTime(Long.valueOf(timeStr));
        }

        // Fallback
        return '00:00:00';
    }

    // If it's a long (e.g., time in ms)
    if (timeVal instanceof Long) {
        return convertMillisecondsToTime((Long)timeVal);
    }

    // Fallback
    return '00:00:00';
}

private static String convertMillisecondsToTime(Long ms) {
    Long totalSeconds = ms / 1000;
    Long hours = totalSeconds / 3600;
    Long minutes = Math.mod(totalSeconds, 3600) / 60;
    Long seconds = Math.mod(totalSeconds, 60);

    String h = (hours < 10 ? '0' : '') + String.valueOf(hours);
    String m = (minutes < 10 ? '0' : '') + String.valueOf(minutes);
    String s = (seconds < 10 ? '0' : '') + String.valueOf(seconds);

    return h + ':' + m + ':' + s;
}

}