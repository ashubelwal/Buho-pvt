public without sharing class PolicyEditRenewUtils {

    @AuraEnabled
    public static Map<String, Object> createNewRenewQuote(String quote, String oldQuoteId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quote)) {

                // Deserialize into map to control time fields separately
                Map<String, Object> quoteMap = (Map<String, Object>) JSON.deserializeUntyped(quote);

                Quote__c quoteRecord = (Quote__c) JSON.deserialize(quote, Quote__c.class);

                // Preserve Start_Time__c exactly as passed
                if (quoteMap.containsKey('Start_Time__c') && quoteMap.get('Start_Time__c') != null) {
                    String startTimeStr = (String) quoteMap.get('Start_Time__c'); // "15:00:00.000"
                    List<String> timeParts = startTimeStr.split(':');
                    Integer hours = Integer.valueOf(timeParts[0]);
                    Integer minutes = Integer.valueOf(timeParts[1]);
                    Integer seconds = Integer.valueOf(timeParts[2].split('\\.')[0]);
                    quoteRecord.Start_Time__c = Time.newInstance(hours, minutes, seconds, 0);
                }

                if (quoteMap.containsKey('End_Time__c') && quoteMap.get('End_Time__c') != null) {
                    String endTimeStr = (String) quoteMap.get('End_Time__c');
                    List<String> timeParts = endTimeStr.split(':');
                    Integer hours = Integer.valueOf(timeParts[0]);
                    Integer minutes = Integer.valueOf(timeParts[1]);
                    Integer seconds = Integer.valueOf(timeParts[2].split('\\.')[0]);
                    quoteRecord.End_Time__c = Time.newInstance(hours, minutes, seconds, 0);
                }

                insert quoteRecord;
                Quote__c oldQuote = [SELECT Id, Name FROM Quote__c WHERE Id = :oldQuoteId];
                if (oldQuote != null) {
                    oldQuote.Renew_Quote__c = quoteRecord.Id;
                    update oldQuote;
                }
                responseMap.put('status','success');
                responseMap.put('data', quoteRecord);
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'quote: '+quote+'\noldQuoteId: '+oldQuoteId;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static Policy__c fetchPolicyDetails(String policyId){
        try {
            List<Policy__c> policies = new List<Policy__c>();
            policies = [Select Id, Name,Quote_c__c, Underwriter_picklist__c,Contact__c,Account_Policy__c, Policy_Type_picklist__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,Agent_Fee__c,Agent_Brokerage_Fee__c
            , Term__c, Medical_picklist__c, Liability_picklist__c, Vehicle_Policy__c, Vehicle_type__c,Net_Premium__c,Surcharge__c,Broker_Policy_Fee__c,I_V_A_Mex_Tax__c,Total_Premium_Amount__c, Total_Transaction_Amount__c,
            Max__c,Gold__c,Platinum__c
            from Policy__c 
            Where Id =:policyId LIMIT 1];
            return policies.get(0);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String fetchPolicyQuoteDetails(String quoteId){
        try {
            System.debug('quoteId--->'+quoteId);
            List<Quote__c> quotes = new List<Quote__c>();
            quotes = [Select Id, Name, Underwriter__c,Contact__c,Account__c, Policy_Type_picklist__c, Start_Date_for_Coverage__c, Start_Time__c, End_Date_for_Coverage__c, End_Time__c
            , Term__c, Medical__c, Is_there_a_driver_under_21__c,Liability__c,Territory__c,Vehicle_Value__c,Vehicle_Year__c,Vehicle_Make__c,Vehicle_Model__c, Towed_Unit__c, 
            Vehicle_Type__c, Vehicle_Sub_type__c,Date_of_Birth__c, Salvage_Vehicle__c, Vehicle_used_for_Business_Purposes__c, Is_this_a_Rental_Vehicle__c,Coverage__c,Net_Premium__c,Surcharge__c,Broker_Policy_Fee__c,I_V_A_Mex_Tax__c,
            Agent_Fee__c,Total_Theft_Payment__c ,Physical_Damage__c,Liability_Payment__c,Medical_Payment__c,Platinum_Endorsment__c,Max__c,Gold__c,Platinum__c
            from Quote__c 
            Where Id =:quoteId LIMIT 1];
            System.debug('quotes--->'+quotes);
            return JSON.serialize(quotes.get(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String fetchPolicyVehicleDetails(String vehicleId){
        try {
            System.debug('vehicleId--->'+vehicleId);
            List<Vehicle__c> vehicles = new List<Vehicle__c>();
            vehicles = [Select Id, Name, Vin__c, Registered_Country__c, Registered_State__c, Registered_Plate__c, Is_Lienholder__c, Lienholder_City__c, Lienholder_Country__c, Lienholder_Fax__c,
            Lienholder_name__c, Lienholder_Phone__c, Lienholder_Postal_Code__c, Lienholder_State__c, Lienholder_Street__c, Lienholder_Street_2__c, Company_Name__c, Company_Country__c, Company_Zip__c,Value__c,
            Company_State__c, Company_City__c, Company_Address__c, Company_Phone__c,Is_the_vehicle_registered_to_a_business__c, Is_vehicle_owned_by_a_company_or_rented__c,Vehicle_Type__c,Make__c,Model__c,Year__c, Electric_Hybrid__c
            from Vehicle__c 
            Where Id =:vehicleId LIMIT 1];
            System.debug('vehicles--->'+vehicles);
            return JSON.serialize(vehicles.get(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String fetchPolicyDriverDetails(String quoteId){
        try {
            List<Quote_Driver__c> quoteDrivers = [Select Id, Name, Driver__c from Quote_Driver__c Where Quote_c__c = :quoteId];
            if(quoteDrivers.size() > 0){
                
                Set<Id> driverIdSet = new Set<Id>();
                for(Quote_Driver__c qtdriver : quoteDrivers){
                    driverIdSet.add(qtdriver.Driver__c);
                }
                
                List<Driver__c> drivers = new List<Driver__c>();
                drivers = [Select Id,First_Name__c, Last_Name__c,license_number__c,License_Country__c,License_state__c,Dob__c, Driver_Type__c , Country__c, Postal_Code__c, State_Province__c,
                City__c, Address__c, Phone__c
                from Driver__c 
                Where Id =:driverIdSet];
                return JSON.serialize(drivers);
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String fetchPolicyTowedDetails(String quoteId){
        try {
            List<Quote_Towed_Unit__c > quoteToweds = [Select Id, Towed_Unit__c from Quote_Towed_Unit__c Where Quote_c__c = :quoteId];
            if(quoteToweds.size() > 0){
                
                Set<Id> towedIdSet = new Set<Id>();
                for(Quote_Towed_Unit__c  qtTowed : quoteToweds){
                    towedIdSet.add(qtTowed.Towed_Unit__c );
                }
                
                List<Towed_Unit__c> towedUnits = new List<Towed_Unit__c>();
                towedUnits = [Select Id, Name ,Towed_Unit_Type__c, Towed_Unit_Value__c, Days_in_Tow__c,Make__c, Model__c, VIN_Number__c, Year__c, Plate__c 
                from Towed_Unit__c
                Where Id =:towedIdSet];
                return JSON.serialize(towedUnits);
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Date fetchUpdatedDate(Date dateValue, String term){
        if(term == 'Semi-Annual(Half a Year)' || term == 'Semi-Annual'){
            return dateValue.addDays(180);
        }else if(term == 'Daily'){
            return dateValue.addDays(1);
        }else{
            return dateValue.addDays(365);
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static DateRecordHelper fetchDateRelatedInfo(){
        DateRecordHelper datehelper = new DateRecordHelper();
        datehelper.minDate = datehelper.todayDate;
        return datehelper;
    }
    
    public class DateRecordHelper{
        @AuraEnabled
        public Date minDate;
        @AuraEnabled
        public Date todayDate = Date.today();
    }
    
    @AuraEnabled
    public static Map<String, String> createNewEditPolicyFromCash(String vehicleData, String DriverData, String towedUnitData, String quoteId, String oldPolicyId, Boolean isRenewal) {
        Map<String, String> responseMap = new Map<String, String>();
        
        try {
            if (String.isNotBlank(quoteId)) {
                SYstem.debug('inside QuoteId createNewEditPolicyFromCash');
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c , Date_of_Birth__c,Gold__c,
                                        Max__c,Platinum__c
                                        FROM Quote__c WHERE Id = :quoteId];
                System.debug('quoteRecord-----'+quoteRecord);
                //Create new Transactions for cash
                
                List<Transaction__c> policyTransaction = new List<Transaction__c>();
                policyTransaction.add(
                    new Transaction__c(
                    Amount__c = quoteRecord.Quote_Value__c,
                Quote_c__c = quoteRecord.Id,
                Payment_Type__c = 'Cash',
                Mode__c  = (isRenewal == true?'Renew':'Edit')
                    )
                    );
                insert policyTransaction;
                System.debug('policyTransaction--> '+policyTransaction);
                if (!policyTransaction.isEmpty()) {
                    // Get Old Policy Record
                    Policy__c oldPolicy;
                    if (String.isNotBlank(oldPolicyId)) {
                        oldPolicy = [SELECT Id, Name, Quote_c__c,Contact__c,Account_Policy__c, Affiliate_Account__c,Contact_Email__c, What_is_the_purpose_of_trip__c, RecordTypeId, 
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId];
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Vehicle__c vehicleRecord;
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                        if (!String.isEmpty(vehicleRecord.Company_Name__c) && vehicleRecord.Is_vehicle_owned_by_a_company_or_rented__c == true) {
                            vehicleRecord.Vehicle_Owner_Name__c = '';
                            vehicleRecord.Vehicle_Owner_Phone__c = '';
                            vehicleRecord.Vehicle_Owner_Address__c = '';
                            vehicleRecord.Vehicle_Owner_Driver_License__c = '';
                            vehicleRecord.Vehicle_Owner_Driver_License_State__c = '';
                            vehicleRecord.Vehicle_Owner_City__c = '';
                            vehicleRecord.Vehicle_Owner_State__c = '';
                            vehicleRecord.Vehicle_Owner_Postal_Code__c = '';
                            vehicleRecord.Vehicle_Owner_Country__c = '';
                        }
                        upsert vehicleRecord;
                    } else {
                        // return error -> Vehicle record missing
                    }
                    
                    // Upsert the Driver Record
                    List<Driver__c> driverList;
                    if (!String.isEmpty(DriverData)) {
                        driverList = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);
                        
                        for (Driver__c eachDriver : driverList) {
                            eachDriver.Contact__c = quoteRecord.Contact__c;
                        }
                        
                        upsert driverList;
                    } else {
                        // return error -> Driver record missing
                    }
                    try {
                        if (String.isNotBlank(vehicleData) && !String.isEmpty(DriverData)) {
                            List<Driver__c> allDrivers = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);

                            System.debug('All drivers@@###' + allDrivers);

                            // Filter drivers by Driver_Type__c values
                            List<Driver__c> filteredDrivers = new List<Driver__c>();
                            for (Driver__c d : allDrivers) {
                                // You can adjust this condition as needed
                                String driverType = d.Driver_Type__c.toLowerCase();
                                    if (driverType == 'true' || driverType == 'owner' || driverType == 'co-owner' || driverType == 'owner & driver') {
                                        filteredDrivers.add(d);
                                    }
                            }

                            System.debug('Filtered drivers@@###' + filteredDrivers);

                            if (!filteredDrivers.isEmpty()) {
                                Driver__c ownerDriver = filteredDrivers[0];
                                vehicleRecord.Vehicle_Owner_Name__c = ownerDriver.First_Name__c + ' ' + ownerDriver.Last_Name__c;
                                vehicleRecord.Vehicle_Owner_Phone__c = ownerDriver.Phone__c;
                                vehicleRecord.Vehicle_Owner_Address__c = ownerDriver.Address__c;
                                vehicleRecord.Vehicle_Owner_Driver_License__c = ownerDriver.license_number__c;
                                vehicleRecord.Vehicle_Owner_Driver_License_State__c = ownerDriver.License_state__c;
                                vehicleRecord.Vehicle_Owner_City__c = ownerDriver.City__c;
                                vehicleRecord.Vehicle_Owner_State__c = ownerDriver.State_Province__c;
                                vehicleRecord.Vehicle_Owner_Postal_Code__c = ownerDriver.Postal_Code__c;
                                vehicleRecord.Vehicle_Owner_Country__c = ownerDriver.Country__c;
                                vehicleRecord.Is_the_vehicle_registered_to_a_business__c = false;
                                vehicleRecord.Company_Name__c = '';
                                vehicleRecord.Company_Phone__c = '';
                                vehicleRecord.Tax_ID__c = '';
                                vehicleRecord.Company_Country__c = '';
                                vehicleRecord.Company_Address__c = '';
                                vehicleRecord.Company_Zip__c = '';
                                vehicleRecord.Company_State__c = '';
                                vehicleRecord.Company_City__c = '';
                                update vehicleRecord;
                                System.debug('vehicleRecord@@###' + vehicleRecord);

                                responseMap.put('status', 'success');
                               // responseMap.put('vehicleData', vehicleRecord);
                            } 
                        } 
                    } catch (Exception e) {
                        responseMap.put('status', 'error');
                        responseMap.put('message', e.getMessage());
                    }
                    // Upsert the Towed Unit Record
                    List<Towed_Unit__c> towedUnitList;
                    if (!String.isEmpty(towedUnitData)) {
                        towedUnitList = (List<Towed_Unit__c>) JSON.deserialize(towedUnitData, List<Towed_Unit__c>.class);
                        upsert towedUnitList;
                    }
                    
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    // Create edit Policy Clone
                    Policy__c newPolicy = new Policy__c();
                    newPolicy.Broker_Policy_Fee__c = quoteRecord.Broker_Policy_Fee__c;
                    newPolicy.I_V_A_Mex_Tax__c = quoteRecord.I_V_A_Mex_Tax__c;
                    newPolicy.Net_Premium__c = quoteRecord.Net_Premium__c;
                    newPolicy.Policy_Type_picklist__c = quoteRecord.Policy_Type_picklist__c;
                    newPolicy.Quote_c__c = quoteRecord.Id;
                    newPolicy.Package__c = quoteRecord.Coverage__c;
                    newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
                    newPolicy.Surcharge__c = quoteRecord.Surcharge__c;
                    newPolicy.Vehicle_deductible_collision__c = quoteRecord.Vehicle_Deductible_Collision__c;
                    newPolicy.Vehicle_deductible_comprehensive__c = quoteRecord.Vehicle_Deductible_Comprehensive__c;
                    newPolicy.Vehicle_Policy__c = vehicleRecord.Id;
                    newPolicy.Contact__c = quoteRecord.Contact__c;
                    newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
                    newPolicy.Account_Policy__c = quoteRecord.Account__c;
                    newPolicy.Status_picklist__c = 'Active';
                    newPolicy.Source__c = 'New Lead Flow';
                    newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                    newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                    newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                    newPolicy.Term__c = quoteRecord.Term__c;
                    
                    if (quoteRecord.Term__c != null && (quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual')) {
                        newPolicy.Term_days__c = 365;
                    } else {
                        newPolicy.Term_days__c = quoteRecord.Term_Days__c;
                    }
                    
                    if (quoteRecord.Start_Date_for_Coverage__c != null) {
                        newPolicy.Start_Date__c = quoteRecord.Start_Date_for_Coverage__c;
                    }
                    if (quoteRecord.Start_Time__c != null) {
                        newPolicy.Start_Time__c = quoteRecord.Start_Time__c;
                    }
                    if (quoteRecord.End_Date_for_Coverage__c != null) {
                        newPolicy.End_Date__c = quoteRecord.End_Date_for_Coverage__c;
                    }
                    if (quoteRecord.End_Time__c != null) {
                        newPolicy.End_Time__c = quoteRecord.End_Time__c;
                    }
                    
                    newPolicy.Underwriter_picklist__c = quoteRecord.Underwriter__c;
                    newPolicy.Vehicle_type__c = quoteRecord.Vehicle_Type__c;
                    newPolicy.Insured_value__c = quoteRecord.Vehicle_Value__c;
                    if (oldPolicy != null && !isRenewal) {
                        String oldPolicyName = oldPolicy.Name;
                        
                        newPolicy.Affiliate_Account__c = oldPolicy.Affiliate_Account__c;
                        String cloneOldPolicyName = oldPolicyName.substringAfterLast('-');
                        
                        if (cloneOldPolicyName != null && cloneOldPolicyName.length() > 2) {
                            oldPolicyName += '-2';
                        } else {
                            Integer num = Integer.valueOf(cloneOldPolicyName) + 1;
                            oldPolicyName = oldPolicyName.substringBeforeLast('-') + '-' + num;
                        }
                        newPolicy.Name = oldPolicyName;
                        //newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
                    } else {
                        
                        newPolicy.renewed_check__c = true;
                        newPolicy.renewed_from_id__c = oldPolicy.Id;
                        newPolicy.Name = Mex_NewLeadProcess.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                        system.debug('New Policy-->'+newPolicy);
                    }
                    
                    newPolicy.What_is_the_purpose_of_trip__c = oldPolicy.What_is_the_purpose_of_trip__c != null ? oldPolicy.What_is_the_purpose_of_trip__c : '';
                    newPolicy.What_is_your_trip_destination_in_US__c = oldPolicy.What_is_your_trip_destination_in_US__c != null ? oldPolicy.What_is_your_trip_destination_in_US__c : '';
                    newPolicy.Terms_of_Purchase_Confirmed__c = oldPolicy.Terms_of_Purchase_Confirmed__c != null ? oldPolicy.Terms_of_Purchase_Confirmed__c : false;
                    newPolicy.Terms_of_Cancellation_Confirmed__c = oldPolicy.Terms_of_Cancellation_Confirmed__c != null ? oldPolicy.Terms_of_Cancellation_Confirmed__c : false;
                    if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                    }
                    //  else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                    //     newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    // } 
                    else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }else{
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    }
                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;

                    if(quoteRecord.Gold__c != null){
                        newPolicy.Gold__c = quoteRecord.Gold__c; 
                    }
                    if(quoteRecord.Max__c != null){
                        newPolicy.Max__c = quoteRecord.Max__c; 
                    }
                    if(quoteRecord.Platinum__c != null){
                        newPolicy.Platinum__c = quoteRecord.Platinum__c; 
                    }
                    
                    insert newPolicy;

                    //Update Quote With new Policy
                    quoteRecord.Policy__c = newPolicy.Id;
                    update quoteRecord;
                    // Update the vehicle Record for Policy looktup
                    vehicleRecord.Policy__c = newPolicy.Id;
                    update vehicleRecord;
                    
                    // Update the Old Policy Record...
                    if (oldPolicy != null && !isRenewal) {
                        oldPolicy.Status_picklist__c  = 'Updated';
                        oldPolicy.Policy__c = newPolicy.Id;
                        update oldPolicy;
                    }
                    
                    // update the New Quote Record
                    if (quoteRecord != null) {
                        quoteRecord.Quote_Status__c = 'Policy Created';
                        update quoteRecord;
                    }
                    
                    // Create New Quote Vehicle Record
                    Quote_Vehicle__c newQuoteVehicle = new Quote_Vehicle__c();
                    newQuoteVehicle.Account__c = quoteRecord.Account__c;
                    newQuoteVehicle.Contact__c = quoteRecord.Contact__c;
                    newQuoteVehicle.Quote_c__c = quoteRecord.Id;
                    newQuoteVehicle.Policy__c = newPolicy.Id;
                    newQuoteVehicle.Vehicle__c = vehicleRecord.Id;
                    insert newQuoteVehicle;
                    
                    // Create New Quote Driver Record
                    List<Quote_Driver__c> newQuoteDriverList = new List<Quote_Driver__c>();
                    if (!driverList.isEmpty() && driverList.size() > 0) {
                        List<Driver__c> updatedDriverList = new List<Driver__c>();
                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                            each.Policy__c = newPolicy.Id;
                            updatedDriverList.add(each);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
                        }
                        if(updatedDriverList.size()>0){
                            update updatedDriverList;
                        }
                    }
                    
                    // Create New Quote Towed Unit Record
                    List<Quote_Towed_Unit__c> newQuoteTowedUnitList = new List<Quote_Towed_Unit__c>();
                    if (!towedUnitList.isEmpty() && towedUnitList.size() > 0) {

                        for (Towed_Unit__c each : towedUnitList) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            newQuoteTowed.Account__c = quoteRecord.Account__c;
                            newQuoteTowed.Contact__c = quoteRecord.Contact__c;
                            newQuoteTowed.Quote_c__c = quoteRecord.Id;
                            newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
                            newQuoteTowed.Towed_Unit__c = each.Id;
                            newQuoteTowed.Policy__c = newPolicy.id;
                            newQuoteTowedUnitList.add(newQuoteTowed);
                        }
                        
                        if (!newQuoteTowedUnitList.isEmpty()) {
                            insert newQuoteTowedUnitList;
                        }
                    }
                    
                    // Update New Transaction Record
                    policyTransaction[0].Policy_Transaction__c = newPolicy.Id;
                    policyTransaction[0].Account_Transaction__c = quoteRecord.Account__c;
                    update policyTransaction;
                    
                    // Update the Old Policy Transaction Record
                    List<Transaction__c> oldPolicyTransactionList = [SELECT Id, Policy_Transaction__c, Quote_c__c FROM Transaction__c Where Policy_Transaction__c = :oldPolicy.Id LIMIT 500];
                    
                    if (!oldPolicyTransactionList.isEmpty() && isRenewal == false) {
                        List<Transaction__c> oldPolicyTransList = new List<Transaction__c>();
                        for (Transaction__c eachTrans : oldPolicyTransactionList) {
                            eachTrans.Policy_Transaction__c = newPolicy.Id;
                            eachTrans.Quote_c__c = quoteRecord.Id;
                            eachTrans.Account_Transaction__c = quoteRecord.Account__c;
                            oldPolicyTransList.add(eachTrans);
                            System.debug('oldPolicyTransList-->'+oldPolicyTransList);
                        }
                        
                        if (!oldPolicyTransList.isEmpty()) {
                            update oldPolicyTransList;
                        }
                    }else{
                        System.debug('isRenewal-->'+isRenewal);
                        
                    }
                    
                    // send email to the user along with attachment...
                    Set<String> policyIds = new Set<String>();
                    if (!String.isBlank(newPolicy.Id)) {
                        policyIds.add(newPolicy.Id);
                    }
                    
                    if (policyIds != null && !policyIds.isEmpty()) {
                        Boolean add_attachment = true;
                        Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
                    }
                    
                    responseMap.put('status', 'success');
                    responseMap.put('data', String.valueOf(newPolicy.Id));
                }
            } else {
                // return error -> quoteId missing
                responseMap.put('status', 'error');
                responseMap.put('message', 'Quote Id is missing, can\'t edit the policy.');
                return responseMap;
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'vehicleData: ' + vehicleData + '\nDriverData: ' + DriverData + '\ntowedUnitData: ' + towedUnitData + '\nquoteId: ' + quoteId + '\noldPolicyId: ' + oldPolicyId + '\nisRenewal: ' + isRenewal;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        
        return responseMap;
    }
    @AuraEnabled
    public static Map<String, String> createNewEditPolicyFromCashWithAmount(String vehicleData, String DriverData, String towedUnitData, String quoteId, String oldPolicyId, Boolean isRenewal,Decimal amountForTransaction) {
        Map<String, String> responseMap = new Map<String, String>();
        
        try {
            if (String.isNotBlank(quoteId)) {
                SYstem.debug('inside QuoteId createNewEditPolicyFromCashWithAmount');
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c,Gold__c,Max__c,Platinum__c
                                        FROM Quote__c WHERE Id = :quoteId];
                
                //Create new Transactions for cash
                
                List<Transaction__c> policyTransaction = new List<Transaction__c>();
                policyTransaction.add(
                    new Transaction__c(
                    Amount__c = amountForTransaction,
                Quote_c__c = quoteRecord.Id,
                Payment_Type__c = 'Cash',
                Mode__c  = (isRenewal == true?'Renew':'Edit')
                    )
                    );
                insert policyTransaction;
                System.debug('policyTransaction--> '+policyTransaction);
                if (!policyTransaction.isEmpty()) {
                    // Get Old Policy Record
                    Policy__c oldPolicy;
                    if (String.isNotBlank(oldPolicyId)) {
                        oldPolicy = [SELECT Id, Name, Quote_c__c, Affiliate_Account__c,Contact_Email__c, What_is_the_purpose_of_trip__c, RecordTypeId, 
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId];
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Vehicle__c vehicleRecord;
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                        if (!String.isEmpty(vehicleRecord.Company_Name__c) && vehicleRecord.Is_vehicle_owned_by_a_company_or_rented__c == true) {
                            vehicleRecord.Vehicle_Owner_Name__c = '';
                            vehicleRecord.Vehicle_Owner_Phone__c = '';
                            vehicleRecord.Vehicle_Owner_Address__c = '';
                            vehicleRecord.Vehicle_Owner_Driver_License__c = '';
                            vehicleRecord.Vehicle_Owner_Driver_License_State__c = '';
                            vehicleRecord.Vehicle_Owner_City__c = '';
                            vehicleRecord.Vehicle_Owner_State__c = '';
                            vehicleRecord.Vehicle_Owner_Postal_Code__c = '';
                            vehicleRecord.Vehicle_Owner_Country__c = '';
                        }
                        upsert vehicleRecord;
                    } else {
                        // return error -> Vehicle record missing
                    }
                    
                    // Upsert the Driver Record
                    List<Driver__c> driverList;
                    if (!String.isEmpty(DriverData)) {
                        driverList = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);
                        
                        for (Driver__c eachDriver : driverList) {
                            eachDriver.Contact__c = quoteRecord.Contact__c;
                        }
                        
                        upsert driverList;
                    } else {
                        // return error -> Driver record missing
                    }
                    try {
                        if (String.isNotBlank(vehicleData) && !String.isEmpty(DriverData)) {
                            List<Driver__c> allDrivers = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);

                            System.debug('All drivers@@###' + allDrivers);

                            // Filter drivers by Driver_Type__c values
                            List<Driver__c> filteredDrivers = new List<Driver__c>();
                            for (Driver__c d : allDrivers) {
                                // You can adjust this condition as needed
                                String driverType = d.Driver_Type__c.toLowerCase();
                                    if (driverType == 'true' || driverType == 'owner' || driverType == 'co-owner' || driverType == 'owner & driver') {
                                        filteredDrivers.add(d);
                                    }
                            }

                            System.debug('Filtered drivers@@###' + filteredDrivers);

                            if (!filteredDrivers.isEmpty()) {
                                Driver__c ownerDriver = filteredDrivers[0];
                                vehicleRecord.Vehicle_Owner_Name__c = ownerDriver.First_Name__c + ' ' + ownerDriver.Last_Name__c;
                                vehicleRecord.Vehicle_Owner_Phone__c = ownerDriver.Phone__c;
                                vehicleRecord.Vehicle_Owner_Address__c = ownerDriver.Address__c;
                                vehicleRecord.Vehicle_Owner_Driver_License__c = ownerDriver.license_number__c;
                                vehicleRecord.Vehicle_Owner_Driver_License_State__c = ownerDriver.License_state__c;
                                vehicleRecord.Vehicle_Owner_City__c = ownerDriver.City__c;
                                vehicleRecord.Vehicle_Owner_State__c = ownerDriver.State_Province__c;
                                vehicleRecord.Vehicle_Owner_Postal_Code__c = ownerDriver.Postal_Code__c;
                                vehicleRecord.Vehicle_Owner_Country__c = ownerDriver.Country__c;
                                vehicleRecord.Is_the_vehicle_registered_to_a_business__c = false;
                                vehicleRecord.Company_Name__c = '';
                                vehicleRecord.Company_Phone__c = '';
                                vehicleRecord.Tax_ID__c = '';
                                vehicleRecord.Company_Country__c = '';
                                vehicleRecord.Company_Address__c = '';
                                vehicleRecord.Company_Zip__c = '';
                                vehicleRecord.Company_State__c = '';
                                vehicleRecord.Company_City__c = '';
                                update vehicleRecord;
                                System.debug('vehicleRecord@@###' + vehicleRecord);

                                responseMap.put('status', 'success');
                               // responseMap.put('vehicleData', vehicleRecord);
                            } 
                        } 
                    } catch (Exception e) {
                        responseMap.put('status', 'error');
                        responseMap.put('message', e.getMessage());
                    }
                    // Upsert the Towed Unit Record
                    List<Towed_Unit__c> towedUnitList;
                    if (!String.isEmpty(towedUnitData)) {
                        towedUnitList = (List<Towed_Unit__c>) JSON.deserialize(towedUnitData, List<Towed_Unit__c>.class);
                        upsert towedUnitList;
                    }
                    
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    // Create edit Policy Clone
                    Policy__c newPolicy = new Policy__c();
                    newPolicy.Broker_Policy_Fee__c = quoteRecord.Broker_Policy_Fee__c;
                    newPolicy.I_V_A_Mex_Tax__c = quoteRecord.I_V_A_Mex_Tax__c;
                    newPolicy.Net_Premium__c = quoteRecord.Net_Premium__c;
                    newPolicy.Policy_Type_picklist__c = quoteRecord.Policy_Type_picklist__c;
                    newPolicy.Quote_c__c = quoteRecord.Id;
                    newPolicy.Package__c = quoteRecord.Coverage__c;
                    newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
                    newPolicy.Surcharge__c = quoteRecord.Surcharge__c;
                    newPolicy.Vehicle_deductible_collision__c = quoteRecord.Vehicle_Deductible_Collision__c;
                    newPolicy.Vehicle_deductible_comprehensive__c = quoteRecord.Vehicle_Deductible_Comprehensive__c;
                    newPolicy.Vehicle_Policy__c = vehicleRecord.Id;
                    newPolicy.Contact__c = quoteRecord.Contact__c;
                    newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
                    newPolicy.Account_Policy__c = quoteRecord.Account__c;
                    newPolicy.Status_picklist__c = 'Active';
                    newPolicy.Source__c = 'New Lead Flow';
                    newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                    newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                    newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                    newPolicy.Term__c = quoteRecord.Term__c;
                    
                    if (quoteRecord.Term__c != null && quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual') {
                        newPolicy.Term_days__c = 365;
                    } else {
                        newPolicy.Term_days__c = quoteRecord.Term_Days__c;
                    }
                    
                    if (quoteRecord.Start_Date_for_Coverage__c != null) {
                        newPolicy.Start_Date__c = quoteRecord.Start_Date_for_Coverage__c;
                    }
                    if (quoteRecord.Start_Time__c != null) {
                        newPolicy.Start_Time__c = quoteRecord.Start_Time__c;
                    }
                    if (quoteRecord.End_Date_for_Coverage__c != null) {
                        newPolicy.End_Date__c = quoteRecord.End_Date_for_Coverage__c;
                    }
                    if (quoteRecord.End_Time__c != null) {
                        newPolicy.End_Time__c = quoteRecord.End_Time__c;
                    }
                    
                    newPolicy.Underwriter_picklist__c = quoteRecord.Underwriter__c;
                    newPolicy.Vehicle_type__c = quoteRecord.Vehicle_Type__c;
                    newPolicy.Insured_value__c = quoteRecord.Vehicle_Value__c;
                    if (oldPolicy != null && !isRenewal) {
                        String oldPolicyName = oldPolicy.Name;
                        
                        newPolicy.Affiliate_Account__c = oldPolicy.Affiliate_Account__c;
                        String cloneOldPolicyName = oldPolicyName.substringAfterLast('-');
                        
                        if (cloneOldPolicyName != null && cloneOldPolicyName.length() > 2) {
                            oldPolicyName += '-2';
                        } else {
                            Integer num = Integer.valueOf(cloneOldPolicyName) + 1;
                            oldPolicyName = oldPolicyName.substringBeforeLast('-') + '-' + num;
                        }
                        newPolicy.Name = oldPolicyName;
                        //newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
                    } else {
                        
                        newPolicy.renewed_check__c = true;
                        newPolicy.renewed_from_id__c = oldPolicy.Id;
                        newPolicy.Name = Mex_NewLeadProcess.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                        system.debug('New Policy-->'+newPolicy);
                    }
                    
                    newPolicy.What_is_the_purpose_of_trip__c = oldPolicy.What_is_the_purpose_of_trip__c != null ? oldPolicy.What_is_the_purpose_of_trip__c : '';
                    newPolicy.What_is_your_trip_destination_in_US__c = oldPolicy.What_is_your_trip_destination_in_US__c != null ? oldPolicy.What_is_your_trip_destination_in_US__c : '';
                    newPolicy.Terms_of_Purchase_Confirmed__c = oldPolicy.Terms_of_Purchase_Confirmed__c != null ? oldPolicy.Terms_of_Purchase_Confirmed__c : false;
                    newPolicy.Terms_of_Cancellation_Confirmed__c = oldPolicy.Terms_of_Cancellation_Confirmed__c != null ? oldPolicy.Terms_of_Cancellation_Confirmed__c : false;
                    if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                    } 
                    // else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                    //     newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    // } 
                    else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }else{
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    }
                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;

                    if(quoteRecord.Gold__c != null){
                        newPolicy.Gold__c = quoteRecord.Gold__c; 
                    }
                    if(quoteRecord.Max__c != null){
                        newPolicy.Max__c = quoteRecord.Max__c; 
                    }
                    if(quoteRecord.Platinum__c != null){
                        newPolicy.Platinum__c = quoteRecord.Platinum__c; 
                    }
                    
                    insert newPolicy;

                    //Update Quote With new Policy
                    quoteRecord.Policy__c = newPolicy.Id;
                    update quoteRecord;

                    // Update the vehicle Record for Policy looktup
                    vehicleRecord.Policy__c = newPolicy.Id;
                    update vehicleRecord;


                    
                    // Update the Old Policy Record...
                    if (oldPolicy != null && !isRenewal) {
                        oldPolicy.Status_picklist__c  = 'Updated';
                        oldPolicy.Policy__c = newPolicy.Id;
                        update oldPolicy;
                    }
                    
                    // update the New Quote Record
                    if (quoteRecord != null) {
                        quoteRecord.Quote_Status__c = 'Policy Created';
                        update quoteRecord;
                    }
                    
                    // Create New Quote Vehicle Record
                    Quote_Vehicle__c newQuoteVehicle = new Quote_Vehicle__c();
                    newQuoteVehicle.Account__c = quoteRecord.Account__c;
                    newQuoteVehicle.Contact__c = quoteRecord.Contact__c;
                    newQuoteVehicle.Quote_c__c = quoteRecord.Id;
                    newQuoteVehicle.Policy__c = newPolicy.Id;
                    newQuoteVehicle.Vehicle__c = vehicleRecord.Id;
                    insert newQuoteVehicle;
                    
                    // Create New Quote Driver Record
                    List<Quote_Driver__c> newQuoteDriverList = new List<Quote_Driver__c>();
                    if (!driverList.isEmpty() && driverList.size() > 0) {
                        List<Driver__c> updatedDriverList = new List<Driver__c>();

                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                            each.Policy__c = newPolicy.Id;
                            updatedDriverList.add(each);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
                        }

                        if(updatedDriverList.size()>0){
                            update updatedDriverList;
                        }
                    }
                    
                    // Create New Quote Towed Unit Record
                    List<Quote_Towed_Unit__c> newQuoteTowedUnitList = new List<Quote_Towed_Unit__c>();
                    if (!towedUnitList.isEmpty() && towedUnitList.size() > 0) {
                        for (Towed_Unit__c each : towedUnitList) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            newQuoteTowed.Account__c = quoteRecord.Account__c;
                            newQuoteTowed.Contact__c = quoteRecord.Contact__c;
                            newQuoteTowed.Quote_c__c = quoteRecord.Id;
                            newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
                            newQuoteTowed.Towed_Unit__c = each.Id;
                            newQuoteTowed.Policy__c = newPolicy.id;
                            newQuoteTowedUnitList.add(newQuoteTowed);
                        }
                        
                        if (!newQuoteTowedUnitList.isEmpty()) {
                            insert newQuoteTowedUnitList;
                        }
                    }
                    
                    // Update New Transaction Record
                    policyTransaction[0].Policy_Transaction__c = newPolicy.Id;
                    policyTransaction[0].Account_Transaction__c = quoteRecord.Account__c;
                    update policyTransaction;
                    
                    // Update the Old Policy Transaction Record
                    List<Transaction__c> oldPolicyTransactionList = [SELECT Id, Policy_Transaction__c, Quote_c__c FROM Transaction__c Where Policy_Transaction__c = :oldPolicy.Id LIMIT 500];
                    
                    if (!oldPolicyTransactionList.isEmpty() && isRenewal == false) {
                        List<Transaction__c> oldPolicyTransList = new List<Transaction__c>();
                        for (Transaction__c eachTrans : oldPolicyTransactionList) {
                            eachTrans.Policy_Transaction__c = newPolicy.Id;
                            eachTrans.Quote_c__c = quoteRecord.Id;
                            eachTrans.Account_Transaction__c = quoteRecord.Account__c;
                            oldPolicyTransList.add(eachTrans);
                            System.debug('oldPolicyTransList-->'+oldPolicyTransList);
                        }
                        
                        if (!oldPolicyTransList.isEmpty()) {
                            update oldPolicyTransList;
                        }
                    }else{
                        System.debug('isRenewal-->'+isRenewal);
                        
                    }
                    
                    // send email to the user along with attachment...
                    Set<String> policyIds = new Set<String>();
                    if (!String.isBlank(newPolicy.Id)) {
                        policyIds.add(newPolicy.Id);
                    }
                    
                    if (policyIds != null && !policyIds.isEmpty()) {
                        Boolean add_attachment = true;
                        Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
                    }
                    
                    responseMap.put('status', 'success');
                    responseMap.put('data', String.valueOf(newPolicy.Id));
                }
            } else {
                // return error -> quoteId missing
                responseMap.put('status', 'error');
                responseMap.put('message', 'Quote Id is missing, can\'t edit the policy.');
                return responseMap;
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'vehicleData: ' + vehicleData + '\nDriverData: ' + DriverData + '\ntowedUnitData: ' + towedUnitData + '\nquoteId: ' + quoteId + '\noldPolicyId: ' + oldPolicyId + '\nisRenewal: ' + isRenewal;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        
        return responseMap;
    }
}