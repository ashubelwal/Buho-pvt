public without sharing class Mex_existingCustomerFlowController {
    @AuraEnabled
    public static String checkCommunityUserAndFetchDetails() {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            String userType = UserInfo.getUserType();
            responseMap.put('userType', !userType.equalsIgnoreCase('Guest'));
            if (userType != null && (!userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                responseMap.put('email', UserInfo.getUserEmail());
                List<User> loginUserList = new List<User>();
                loginUserList = getloginUser();
                
                if (loginUserList != null && !loginUserList.isEmpty()) {
                    List<Driver__c> driversList = new List<Driver__c>();
                    List<Vehicle__c> vehicleList = new List<Vehicle__c>();
                    List<Watercraft__c> watercraftList = new List<Watercraft__c>();
                    List<Towed_Unit__c> towedUnitList = new List<Towed_Unit__c>();

                    driversList = getDrivers(loginUserList[0].ContactId);
                    if (driversList != null && !driversList.isEmpty()) {
                        responseMap.put('drivers', driversList);
                    }
                    vehicleList = getVehicles(loginUserList[0].contactId);
                    if (vehicleList != null && !vehicleList.isEmpty()) {
                        responseMap.put('vehicles', vehicleList);
                    }

                    watercraftList = getWatercrafts(loginUserList[0].contactId);
                    if (watercraftList != null && !watercraftList.isEmpty()) {
                        responseMap.put('watercrafts', watercraftList);
                    }
                    
                    towedUnitList = getTowedUnits(loginUserList[0].contactId);
                    if (towedUnitList != null && !towedUnitList.isEmpty()) {
                        responseMap.put('towedUnits', towedUnitList);
                    }
                }
            }
            responseMap.put('status', 'success'); } catch (Exception ex) { responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); CustomErrorExceptionHandlerException.LogException(ex); }
        return JSON.serialize(responseMap);
    }


    
    @AuraEnabled
    public static Map<String, Object> saveQuoteRecordData(String quoteRecord, String vehicleRecord, String towedUnitRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quoteRecord) && !String.isEmpty(vehicleRecord)) {
                Vehicle__c vehicleData = (Vehicle__c) JSON.deserialize(vehicleRecord, Vehicle__c.class);
                Quote__c quoteData = (Quote__c) JSON.deserialize(quoteRecord, Quote__c.class);
                List<Towed_Unit__c> towedUnitsData;
                User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                if (String.isNotEmpty(towedUnitRecord)) {
                    towedUnitsData = (List<Towed_Unit__c>) JSON.deserialize(towedUnitRecord, List<Towed_Unit__c>.class);
                }
                if (quoteData != null && vehicleData != null) {
                    quoteData.Account__c = userRecord.AccountId;
                    quoteData.Contact__c = userRecord.ContactId;
                    quoteData.Quote_Status__c = 'Draft';
                    quoteData.Towed_Unit__c = quoteData.Towed_Unit__c;
                    quoteData.Medical__c = quoteData.Policy_Type_picklist__c == 'Motorcycle' || quoteData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' ? '' : quoteData.Medical__c;
                    upsert quoteData;

                    if(vehicleData.Id != null){
                        QuickQuotationCtrl.vechileTriggerAction = false;
                    }
                    vehicleData.Account_Vehicle__c = userRecord.AccountId;
                    vehicleData.Contact__c = userRecord.ContactId;
                    vehicleData.Name = vehicleData.Model__c + ' ' + vehicleData.Make__c + ' ' + vehicleData.Year__c;
                    vehicleData.Rental__c = quoteData.Is_this_a_Rental_Vehicle__c ? 'Yes' : 'No';
                    vehicleData.Vehicle_Type__c = quoteData.Vehicle_Sub_type__c;
                    upsert vehicleData;
                    
                    responseMap.put('status', 'success');
                    responseMap.put('quoteData', quoteData);
                    responseMap.put('vehicleData', vehicleData);
                }
                
                if (quoteData.Towed_Unit__c == 'Yes' && towedUnitsData != null && towedUnitsData.size() > 0) {
                    for (Towed_Unit__c et : towedUnitsData) {
                        et.Account__c = userRecord.AccountId;
                        et.Contact__c = userRecord.ContactId;
                    }
                    upsert towedUnitsData;
                    responseMap.put('towedUnitData', towedUnitsData);
                }
                
                if (vehicleData != null) {
                    Quote_Vehicle__c newQuoteVehicle = new Quote_Vehicle__c();
                    newQuoteVehicle.Account__c = userRecord.AccountId;
                    newQuoteVehicle.Contact__c = userRecord.ContactId;
                    newQuoteVehicle.Quote_c__c = quoteData.Id;
                    newQuoteVehicle.Vehicle__c = vehicleData.Id;
                    
                    insert newQuoteVehicle;
                    
                    if (towedUnitsData != null && towedUnitsData.size() > 0) {
                        List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
                        for (Towed_Unit__c eachTow : towedUnitsData) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            newQuoteTowed.Account__c = userRecord.AccountId;
                            newQuoteTowed.Contact__c = userRecord.ContactId;
                            newQuoteTowed.Quote_c__c = quoteData.Id;
                            newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
                            newQuoteTowed.Towed_Unit__c = eachTow.Id;
                            
                            quoteTowedList.add(newQuoteTowed);
                        }
                        
                        if (quoteTowedList != null && quoteTowedList.size() > 0) {
                            insert quoteTowedList;
                        }
                    }
                }
            } else {
                responseMap.put('status', 'error');
                responseMap.put('message', 'Either Quote or Vehicle record is missing.');
            } } catch (Exception ex) { responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); CustomErrorExceptionHandlerException.LogException(ex); }
        return responseMap;
    }
    @AuraEnabled
    public static Map<String, Object> saveWatercraftQuoteRecordData(String quoteRecord, String watercraftRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quoteRecord) && !String.isEmpty(watercraftRecord)) {
                Watercraft__c watercraftData = (Watercraft__c) JSON.deserialize(watercraftRecord, Watercraft__c.class);
                Quote__c quoteData = (Quote__c) JSON.deserialize(quoteRecord, Quote__c.class);
                User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

                if (quoteData != null && watercraftData != null) {
                    quoteData.Account__c = userRecord.AccountId;
                    quoteData.Contact__c = userRecord.ContactId;
                    quoteData.Quote_Status__c = 'Draft';
                    quoteData.Towed_Unit__c = 'No';
                    upsert quoteData;

                    watercraftData.Account__c = userRecord.AccountId;
                    watercraftData.Contact__c = userRecord.ContactId;
                    upsert watercraftData;

                    responseMap.put('status', 'success');
                    responseMap.put('quoteData', quoteData);
                    responseMap.put('watercraftData', watercraftData);
                }
                
                if (watercraftData != null) {
                    Quote_Watercraft__c newQuotewatercraft = new Quote_Watercraft__c();
                    newQuotewatercraft.Account__c = userRecord.AccountId;
                    newQuotewatercraft.Contact__c = userRecord.ContactId;
                    newQuotewatercraft.Quote_c__c = quoteData.Id;
                    newQuotewatercraft.Watercraft__c = watercraftData.Id;
                    
                    insert newQuotewatercraft;
                }
            } else {
                responseMap.put('status', 'error');
                responseMap.put('message', 'Either Quote or Vehicle record is missing.');
            } } catch (Exception ex) { responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); CustomErrorExceptionHandlerException.LogException(ex); }
        return responseMap;
    }
    @AuraEnabled
    public static String createWatercraftPolicyForExistingCustomer(String quoteId, String watercraftId, String termAgreement) {
        Map<String, Object> responseMap = new Map<String, Object>();
        Mex_NewLeadProcess.TermAndConditionWrapper termConditionRecord = new Mex_NewLeadProcess.TermAndConditionWrapper();
        try {
            if (!String.isEmpty(quoteId)) {
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c,Third_Party_Bodily_Injury__c,Property_Damage_Liability__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Contact__r.Source__c, Contact__r.Email, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c 
                                        FROM Quote__c WHERE Id = :quoteId];
                
                if (String.isNotEmpty(termAgreement)) {
                    termConditionRecord = (Mex_NewLeadProcess.TermAndConditionWrapper) JSON.deserialize(termAgreement.replaceAll('__c', '_Tempc'), Mex_NewLeadProcess.TermAndConditionWrapper.class);
                }
                if(String.isNotBlank(quoteRecord.Contact__c)){
                    Contact con = new Contact();
                    con.Id = quoteRecord.Contact__c;
                    con.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                    con.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                    con.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
                    //con.Newsletter__c = termConditionRecord.Newsletter_Tempc != null ? termConditionRecord.Newsletter_Tempc : 'No';
                    //con.Announcements__c = termConditionRecord.Announcements_Tempc != null ? termConditionRecord.Announcements_Tempc : 'No';
                    //con.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null ? termConditionRecord.Travel_Alerts_Tempc : 'No';
                    update con;
                }
                
                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                if (policyTransaction.size() > 0) {
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
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
                    newPolicy.Watercraft__c = watercraftId;
                    newPolicy.Contact__c = quoteRecord.Contact__c;
                    newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
                    newPolicy.Account_Policy__c = quoteRecord.Account__c;
                    newPolicy.Status_picklist__c = 'Active';
                    newPolicy.Source__c = quoteRecord.Contact__r.Source__c;
                    newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                    newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                    newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                    newPolicy.Term__c = quoteRecord.Term__c;
                    newPolicy.Third_Party_Bodily_Injury__c = quoteRecord.Third_Party_Bodily_Injury__c;
                    newPolicy.Property_Damage_Liability__c = quoteRecord.Property_Damage_Liability__c;
                    
                    
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
                    newPolicy.Name = Mex_NewLeadProcess.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                    newPolicy.What_is_the_purpose_of_trip__c = termConditionRecord.What_is_the_purpose_of_trip_Tempc != null ? termConditionRecord.What_is_the_purpose_of_trip_Tempc : '';
                    newPolicy.What_is_your_trip_destination_in_US__c = termConditionRecord.What_is_your_trip_destination_in_US_Tempc != null ? termConditionRecord.What_is_your_trip_destination_in_US_Tempc : '';
                    newPolicy.Terms_of_Purchase_Confirmed__c = termConditionRecord.Terms_of_Purchase_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Purchase_Confirmed_Tempc : false;
                    newPolicy.Terms_of_Cancellation_Confirmed__c = termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc : false;
                    newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                    newPolicy.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                    newPolicy.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
                    if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    } else {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    }
                    newPolicy.Contact_Email__c = quoteRecord.Contact__r.Email;
                    insert newPolicy;

                    if (newPolicy.Id != null) {
                        quoteRecord.Quote_Status__c = 'Policy Created';
                        update quoteRecord;
                        List<Quote_Watercraft__c> quoteVehicleRecord = [SELECT Id, Policy__c, Quote_c__c FROM Quote_Watercraft__c WHERE Quote_c__c = :quoteRecord.Id LIMIT 1];
                        if (quoteVehicleRecord.size() > 0) {
                            quoteVehicleRecord[0].Policy__c = newPolicy.Id;
                            update quoteVehicleRecord;
                        }
                        List<Quote_Driver__c> quoteDrivers = [SELECT ID, Quote_c__c FROM Quote_Driver__c WHERE Quote_c__c = :quoteRecord.Id];
                        if (quoteDrivers.size() > 0) {
                            for (Quote_Driver__c eachDriver : quoteDrivers) {
                                eachDriver.Policy__c = newPolicy.Id;
                            }
                            update quoteDrivers;
                        }

                        for (Transaction__c eachTransaction : policyTransaction) {
                            eachTransaction.Policy_Transaction__c = newPolicy.Id;
                            eachTransaction.Account_Transaction__c = quoteRecord.Account__c;
                        }

                        update policyTransaction;
                        
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
                        responseMap.put('data', String.valueOf(newPolicy.Name));
                        responseMap.put('email', String.valueOf(newPolicy.Contact_Email__c));
                        responseMap.put('PolicyId', String.valueOf(newPolicy.Id));
                    }
                }
            } } catch (Exception ex) { responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); CustomErrorExceptionHandlerException.LogException(ex); }
        return JSON.serialize(responseMap);
    }

    @AuraEnabled
    public static String createPolicyForExistingCustomer(String quoteId, String vehicleId, String termAgreement) {
        Map<String, Object> responseMap = new Map<String, Object>();
        Mex_NewLeadProcess.TermAndConditionWrapper termConditionRecord = new Mex_NewLeadProcess.TermAndConditionWrapper();
        try {
            if (!String.isEmpty(quoteId)) {
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Contact__r.Email,Contact__r.Source__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, End_Date_for_Coverage__c, Quote_Status__c, End_Time__c, Vehicle_Value__c,Gold__c,Max__c,Platinum__c
                                        FROM Quote__c WHERE Id = :quoteId];
                
                if (String.isNotEmpty(termAgreement)) {
                    termConditionRecord = (Mex_NewLeadProcess.TermAndConditionWrapper) JSON.deserialize(termAgreement.replaceAll('__c', '_Tempc'), Mex_NewLeadProcess.TermAndConditionWrapper.class);
                }
                
                if(String.isNotBlank(quoteRecord.Contact__c)){
                    Contact con = new Contact();
                    con.Id = quoteRecord.Contact__c;
                    con.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                    con.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                    con.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
                    //con.Newsletter__c = termConditionRecord.Newsletter_Tempc != null ? termConditionRecord.Newsletter_Tempc : 'No';
                    //con.Announcements__c = termConditionRecord.Announcements_Tempc != null ? termConditionRecord.Announcements_Tempc : 'No';
                    //con.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null ? termConditionRecord.Travel_Alerts_Tempc : 'No';
                    update con;
                }

                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                if (policyTransaction.size() > 0) {
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
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
                    newPolicy.Vehicle_Policy__c = vehicleId;
                    newPolicy.Contact__c = quoteRecord.Contact__c;
                    newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
                    newPolicy.Account_Policy__c = quoteRecord.Account__c;
                    newPolicy.Status_picklist__c = 'Active';
                    
                    newPolicy.Source__c = quoteRecord.Contact__r.Source__c;
                    
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
                    if(quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual'){
                        //newPolicy.Start_Time__c = newPolicy.Start_Time__c.addHours(-8);
                        //newPolicy.End_Time__c = newPolicy.End_Time__c.addHours(-8);
                    }
                    
                    newPolicy.Underwriter_picklist__c = quoteRecord.Underwriter__c;
                    newPolicy.Vehicle_type__c = quoteRecord.Vehicle_Type__c;
                    newPolicy.Insured_value__c = quoteRecord.Vehicle_Value__c;
                    newPolicy.Name = Mex_NewLeadProcess.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                    newPolicy.What_is_the_purpose_of_trip__c = termConditionRecord.What_is_the_purpose_of_trip_Tempc != null ? termConditionRecord.What_is_the_purpose_of_trip_Tempc : '';
                    newPolicy.What_is_your_trip_destination_in_US__c = termConditionRecord.What_is_your_trip_destination_in_US_Tempc != null ? termConditionRecord.What_is_your_trip_destination_in_US_Tempc : '';
                    newPolicy.Terms_of_Purchase_Confirmed__c = termConditionRecord.Terms_of_Purchase_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Purchase_Confirmed_Tempc : false;
                    newPolicy.Terms_of_Cancellation_Confirmed__c = termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc : false;
                   	newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                    newPolicy.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                    newPolicy.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
                    // newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null ? termConditionRecord.Newsletter_Tempc : 'No';
                    //newPolicy.Announcements__c = termConditionRecord.Announcements_Tempc != null ? termConditionRecord.Announcements_Tempc : 'No';
                    //newPolicy.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null ? termConditionRecord.Travel_Alerts_Tempc : 'No';
                    // Commented Code  && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')
                    if (quoteRecord.Policy_Type_picklist__c != null) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                        newPolicy.Yellow_Card__c = String.isNotEmpty(termConditionRecord.Yellow_Card_Tempc) ? termConditionRecord.Yellow_Card_Tempc : 'No';
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }

                    if(quoteRecord.Gold__c != null){
                        newPolicy.Gold__c = quoteRecord.Gold__c; 
                    }
                    if(quoteRecord.Max__c != null){
                        newPolicy.Max__c = quoteRecord.Max__c; 
                    }
                    if(quoteRecord.Platinum__c != null){
                        newPolicy.Platinum__c = quoteRecord.Platinum__c; 
                    }
                    

                    // Handle for new policy type
                    // if(quoteRecord.Policy_Type_picklist__c != null) {
                    //     newPolicy.RecordTypeId = '0121C00000102F1QAI';
                    // }

                    newPolicy.Contact_Email__c = quoteRecord.Contact__r.Email;
                    insert newPolicy;
                    
                    if (newPolicy.Id != null) {
                        quoteRecord.Quote_Status__c = 'Policy Created';
                        quoteRecord.Policy__c = newPolicy.Id;
                        update quoteRecord;
                        List<Quote_Vehicle__c> quoteVehicleRecord = [SELECT Id, Policy__c, Quote_c__c, Vehicle__c FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteRecord.Id LIMIT 1];
                        List<String> vehicleRelatedId = new List<String>();
                        if (!quoteVehicleRecord.isEmpty() && quoteVehicleRecord.size() > 0) {
                            quoteVehicleRecord[0].Policy__c = newPolicy.Id;
                            if(quoteVehicleRecord[0].Vehicle__c != null ){
                                vehicleRelatedId.add(quoteVehicleRecord[0].Vehicle__c);
                            }
                            if(vehicleRelatedId.size()>0){
                                List<Vehicle__c> vehicleList = [Select Id,Policy__c FROM Vehicle__c Where Id IN :vehicleRelatedId];
                                if(vehicleList.size()>0){
                                    for(Vehicle__c eachveh : vehicleList){
                                        eachveh.Policy__c = newPolicy.Id;
                                    }
                                    update vehicleList;
                                }
                            }
                            update quoteVehicleRecord;
                        }

                        List<Quote_Towed_Unit__c> quoteTowedRecord = [SELECT ID, Quote_c__c FROM Quote_Towed_Unit__c WHERE Quote_c__c = :quoteRecord.Id];
                        if (!quoteTowedRecord.isEmpty() && quoteTowedRecord.size() > 0) {
                            for (Quote_Towed_Unit__c eachTow : quoteTowedRecord) {
                                eachTow.Policy__c = newPolicy.Id;
                            }
                            update quoteTowedRecord;
                        }

                        List<Quote_Driver__c> quoteDrivers = [SELECT ID, Quote_c__c FROM Quote_Driver__c WHERE Quote_c__c = :quoteRecord.Id];
                        if (!quoteDrivers.isEmpty() && quoteDrivers.size() > 0) {
                            for (Quote_Driver__c eachDriver : quoteDrivers) {
                                eachDriver.Policy__c = newPolicy.Id;
                            }
                            update quoteDrivers;
                        }

                        for (Transaction__c eachTransaction : policyTransaction) {
                            eachTransaction.Policy_Transaction__c = newPolicy.Id;
                            eachTransaction.Account_Transaction__c = quoteRecord.Account__c;
                        }
                        update policyTransaction;
                        
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
                        responseMap.put('data', String.valueOf(newPolicy.Name));
                        responseMap.put('email', String.valueOf(newPolicy.Contact_Email__c));
                        responseMap.put('PolicyId', String.valueOf(newPolicy.Id));
                    }
                }
            } } catch (Exception ex) { responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); CustomErrorExceptionHandlerException.LogException(ex); }
        return JSON.serialize(responseMap);
    }

     @AuraEnabled
    public static map<String, Object> updateWatercraftQuoteRecordData(String quoteRecord, String watercraftRecord, String driversRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quoteRecord) && !String.isEmpty(watercraftRecord)) {
                Watercraft__c watercraftData = (Watercraft__c) JSON.deserialize(watercraftRecord, Watercraft__c.class);
                Quote__c quoteData = (Quote__c) JSON.deserialize(quoteRecord, Quote__c.class);
                User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                
                if (quoteData != null && quoteData.Id != null) {
                    update quoteData;
                    responseMap.put('status', 'success');
                    responseMap.put('quoteData', quoteData);
                }
                
                if (watercraftData != null && watercraftData.Id != null) {
                    update watercraftData;
                    responseMap.put('watercraftData', watercraftData);
                }
                
                if (String.isNotEmpty(driversRecord)) {
                    List<Driver__c> driversData = (List<Driver__c>) JSON.deserialize(driversRecord, List<Driver__c>.class);
                    List<Quote_Driver__c> quoteDriverRecord = [SELECT Id, Driver__c FROM Quote_Driver__c WHERE Quote_c__c = :quoteData.Id];
                    
                    if (driversData != null && !driversData.isEmpty()) {
                        for (Driver__c eachDr : driversData) {
                            eachDr.Contact__c = userRecord.ContactId;
                            eachDr.Account_Driver__c = userRecord.AccountId;
                            eachDr.Name = eachDr.First_Name__c + ' ' + eachDr.Last_Name__c;
                        }
                        upsert driversData;
                        responseMap.put('DriversData', driversData);

                        if (quoteDriverRecord.isEmpty()) {
                            List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
                            for (Driver__c eachDriver : driversData) {
                                Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                                newQuoteDriver.Account_Driver__c = userRecord.AccountId;
                                newQuoteDriver.Contact__c = userRecord.ContactId;
                                newQuoteDriver.Driver__c = eachDriver.Id;
                                newQuoteDriver.Quote_c__c = quoteData.Id;
                                newQuoteDriver.Primary_insured__c = eachDriver.Primary_insured__c;
                                newQuoteDriver.Watercraft__c = watercraftData.Id;
                                
                                quoteDriversList.add(newQuoteDriver);
                            }
                            
                            if (!quoteDriversList.isEmpty()) {
                                insert quoteDriversList;
                            }
                        } else {
                            Map<Id, Quote_Driver__c> quoteDriverMap = new Map<Id, Quote_Driver__c>();
                            List<Driver__c> newDriverToInsert = new List<Driver__c>();
                            for (Quote_Driver__c eachQuoteDriver : quoteDriverRecord) {
                                if (!quoteDriverMap.containsKey(eachQuoteDriver.Id)) {
                                    quoteDriverMap.put(eachQuoteDriver.Driver__c, eachQuoteDriver);
                                }
                            }
                            
                            for (Driver__c eachDr : driversData) {
                                if (!quoteDriverMap.containsKey(eachDr.Id)) {
                                    newDriverToInsert.add(eachDr);
                                }
                            }
                            
                            if (!newDriverToInsert.isEmpty()) {
                                List<Quote_Driver__c> quoteDriverNewList = new List<Quote_Driver__c>();
                                for (Driver__c eachNewDriver : newDriverToInsert) {
                                    Quote_Driver__c newQuoteDriverData = new Quote_Driver__c();
                                    newQuoteDriverData.Account_Driver__c = userRecord.AccountId;
                                    newQuoteDriverData.Contact__c = userRecord.ContactId;
                                    newQuoteDriverData.Quote_c__c = quoteData.Id;
                                    newQuoteDriverData.Watercraft__c = watercraftData.Id;
                                    newQuoteDriverData.Driver__c = eachNewDriver.Id;
                                    quoteDriverNewList.add(newQuoteDriverData);
                                }
                                
                                if (!quoteDriverNewList.isEmpty()) {
                                    insert quoteDriverNewList;
                                }
                            }
                        }
                    }
                }
            } else {
                responseMap.put('status', 'error');
                responseMap.put('message', 'Either Quote or Vehicle record is missing.');
            }
        } catch (Exception ex) {
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        return responseMap;
    }

    @AuraEnabled
    public static map<String, Object> updateQuoteRecordData(String quoteRecord, String vehicleRecord, String towedUnitRecord, String driversRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quoteRecord) && !String.isEmpty(vehicleRecord)) {
                vehicleRecord = vehicleRecord.replaceAll('\\{\\}', 'null');
                Vehicle__c vehicleData = (Vehicle__c) JSON.deserialize(vehicleRecord, Vehicle__c.class);

                quoteRecord = quoteRecord.replaceAll('\\{\\}', 'null');
                Quote__c quoteData = (Quote__c) JSON.deserialize(quoteRecord, Quote__c.class);
                
                List<Towed_Unit__c> towedUnitsData;
                User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                towedUnitRecord = towedUnitRecord.replaceAll('\\{\\}', 'null');
                if (String.isNotEmpty(towedUnitRecord)) {
                    towedUnitsData = (List<Towed_Unit__c>) JSON.deserialize(towedUnitRecord, List<Towed_Unit__c>.class);
                }

                if (quoteData != null && quoteData.Id != null) {
                    update quoteData;
                    responseMap.put('status', 'success');
                    responseMap.put('quoteData', quoteData);
                }
                
                if (vehicleData != null && vehicleData.Id != null) {
                    QuickQuotationCtrl.vechileTriggerAction = false;
                    vehicleData.Rental__c = quoteData.Is_this_a_Rental_Vehicle__c ? 'Yes' : 'No';
                    vehicleData.Vehicle_Type__c = quoteData.Vehicle_Sub_type__c;
                    update vehicleData;
                    responseMap.put('vehicleData', vehicleData);
                }
                
                if (quoteData.Towed_Unit__c == 'Yes' && towedUnitsData != null && !towedUnitsData.isEmpty()) {
                    upsert towedUnitsData;
                    responseMap.put('towedUnitData', towedUnitsData);
                    
                    Quote_Vehicle__c quoteVehicleRecord = [SELECT Id FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteData.Id LIMIT 1];
                    List<Quote_Towed_Unit__c> quoteTowRecord = [SELECT Id, Towed_Unit__c FROM Quote_Towed_Unit__c WHERE Quote_c__c = :quoteData.Id];
                    if (quoteTowRecord.isEmpty()) {
                        List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
                        for (Towed_Unit__c eachTow : towedUnitsData) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            newQuoteTowed.Account__c = userRecord.AccountId;
                            newQuoteTowed.Contact__c = userRecord.ContactId;
                            newQuoteTowed.Quote_c__c = quoteData.Id;
                            newQuoteTowed.Quote_Vehicle__c = quoteVehicleRecord.Id;
                            newQuoteTowed.Towed_Unit__c = eachTow.Id;

                            quoteTowedList.add(newQuoteTowed);
                        }
                        
                        if (!quoteTowedList.isEmpty()) {
                            upsert quoteTowedList;
                        }
                    } else {
                        Map<Id, Quote_Towed_Unit__c> quoteTowedMap = new Map<Id, Quote_Towed_Unit__c>();
                        List<Towed_Unit__c> newTowedToInsert = new List<Towed_Unit__c>();
                        for (Quote_Towed_Unit__c eachQuoteTowed : quoteTowRecord) {
                            if (!quoteTowedMap.containsKey(eachQuoteTowed.Id)) {
                                quoteTowedMap.put(eachQuoteTowed.Towed_Unit__c, eachQuoteTowed);
                            }
                        }
                        for (Towed_Unit__c eachTowedUnit : towedUnitsData) {
                            if (!quoteTowedMap.containsKey(eachTowedUnit.Id)) {
                                newTowedToInsert.add(eachTowedUnit);
                            }
                        }

                        if (!newTowedToInsert.isEmpty()) {
                            List<Quote_Towed_Unit__c> quoteTowedNewList = new List<Quote_Towed_Unit__c>();
                            for (Towed_Unit__c eachNewTow : newTowedToInsert) {
                                Quote_Towed_Unit__c newQuoteTowedData = new Quote_Towed_Unit__c();
                                newQuoteTowedData.Account__c = userRecord.AccountId;
                                newQuoteTowedData.Contact__c = userRecord.ContactId;
                                newQuoteTowedData.Quote_c__c = quoteData.Id;
                                newQuoteTowedData.Quote_Vehicle__c = quoteVehicleRecord.Id;
                                newQuoteTowedData.Towed_Unit__c = eachNewTow.Id;
                                quoteTowedNewList.add(newQuoteTowedData);
                            }
                            
                            if (!quoteTowedNewList.isEmpty()) {
                                upsert quoteTowedNewList;
                            }
                        }
                    }
                }
                
                if (String.isNotEmpty(driversRecord)) {
                    List<Driver__c> driversData = (List<Driver__c>) JSON.deserialize(driversRecord, List<Driver__c>.class);
                    List<Quote_Driver__c> quoteDriverRecord = [SELECT Id, Driver__c,Quote_c__c FROM Quote_Driver__c WHERE Quote_c__c = :quoteData.Id];
                    
                    if (driversData != null && !driversData.isEmpty()) {
                        for (Driver__c eachDr : driversData) {
                            eachDr.Contact__c = userRecord.ContactId;
                            eachDr.Account_Driver__c = userRecord.AccountId;
                            eachDr.Name = eachDr.First_Name__c + ' ' + eachDr.Last_Name__c;
                        }
                        upsert driversData;
                        responseMap.put('DriversData', driversData);
                        
                        if (quoteDriverRecord.size() == 0) {
                            List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
                            for (Driver__c eachDriver : driversData) {
                                Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                                newQuoteDriver.Account_Driver__c = userRecord.AccountId;
                                newQuoteDriver.Contact__c = userRecord.ContactId;
                                newQuoteDriver.Driver__c = eachDriver.Id;
                                newQuoteDriver.Quote_c__c = quoteData.Id;
                                newQuoteDriver.Primary_insured__c = eachDriver.Primary_insured__c;
                                newQuoteDriver.Vehicle_Driver__c = vehicleData.Id;
                                quoteDriversList.add(newQuoteDriver);
                            }
                            
                            if (!quoteDriversList.isEmpty()) {
                                upsert quoteDriversList;
                            }
                        } else {
                            Map<Id, Quote_Driver__c> quoteDriverMap = new Map<Id, Quote_Driver__c>();
                            List<Driver__c> newDriverToInsert = new List<Driver__c>();
                            for (Quote_Driver__c eachQuoteDriver : quoteDriverRecord) {
                                if (!quoteDriverMap.containsKey(eachQuoteDriver.Id)) {
                                    quoteDriverMap.put(eachQuoteDriver.Driver__c, eachQuoteDriver);
                                }
                            }
                            
                            for (Driver__c eachDr : driversData) {
                                if (!quoteDriverMap.containsKey(eachDr.Id)) {
                                    newDriverToInsert.add(eachDr);
                                }
                            }
                            
                            if (!newDriverToInsert.isEmpty()) {
                                List<Quote_Driver__c> quoteDriverNewList = new List<Quote_Driver__c>();
                                for (Driver__c eachNewDriver : newDriverToInsert) {
                                    Quote_Driver__c newQuoteDriverData = new Quote_Driver__c();
                                    newQuoteDriverData.Account_Driver__c = userRecord.AccountId;
                                    newQuoteDriverData.Contact__c = userRecord.ContactId;
                                    newQuoteDriverData.Quote_c__c = quoteData.Id;
                                    newQuoteDriverData.Vehicle_Driver__c = vehicleData.Id;
                                    newQuoteDriverData.Driver__c = eachNewDriver.Id;
                                    quoteDriverNewList.add(newQuoteDriverData);
                                }
                                
                                if (!quoteDriverNewList.isEmpty()) {
                                    upsert quoteDriverNewList;
                                }
                            }
                        }
                    }
                }
            } else {
                responseMap.put('status', 'error');
                responseMap.put('message', 'Either Quote or Vehicle record is missing.');
            }
        } catch (Exception ex) {
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static List<Address__c> getAddressData (String country, String postalCode, String stateCode, String cityCode){
        
        String Condition = ' where Name =:country AND ';
        if(String.isNotBlank(PostalCode)){
            Condition+='Postal_Code__c =: postalCode AND ';
        }
        if(String.isNotBlank(stateCode)){
            Condition+='State__c =: stateCode AND ';
        }
        if(String.isNotBlank(cityCode)){
            Condition+='City__c =: cityCode AND ';
        }
        Condition = Condition.removeEnd('AND ');
        return Database.query('Select Id, Name, City__c,Postal_Code__c,State__c from Address__c '+Condition+' LIMIT 5');
    }
    
    @AuraEnabled
    public static List<Lienholder__c> getLienholderData (String recordId){
        return [Select Id, Name__c,City__c,Country__c,Fax__c,LH_Code__c,Phone__c,State__c,Street__c,Street2__c,Zip__c from Lienholder__c where Id =: recordId];
    }
        
    @AuraEnabled
    public static List<Address__c> getPostalCodesData (String postalCode){
        return [Select Id, Name, City__c,Postal_Code__c,State__c from Address__c where Postal_Code__c like : '%'+postalCode+'%' order by Postal_Code__c asc];
    }
    @AuraEnabled
    public static List<Address__c> getstateData (String state){
        return [Select Id, Name, City__c,Postal_Code__c,State__c from Address__c where State__c like : '%'+state+'%' order by State__c asc];
    }
    
    @AuraEnabled
    public static List<Address__c> getcityData (String city){
        return [Select Id, Name,Postal_Code__c from Address__c where City__c like : '%'+city+'%'];
    }
    
    private static List<User> getLoginUser() {
        return [SELECT Id, FirstName, LastName, Email, Phone, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }
    
    private static List<Driver__c> getDrivers(String contactId) {
        String query = getQueryWithAllFields(Driver__c.getSObjectType().getDescribe().getName());
        query += ' WHERE Contact__c = :contactId';
        
        return Database.query(query);
    }
    
    private static List<Vehicle__c> getVehicles(String contactId) {
        String query = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
        query += ' WHERE Contact__c = :contactId';
        
        return Database.query(query);
    }
    
    private static List<Watercraft__c> getWatercrafts(String contactId) {
        String query = getQueryWithAllFields(Watercraft__c.getSObjectType().getDescribe().getName());
        query += ' WHERE Contact__c = :contactId';
        
        return Database.query(query);
    }
    

    private static List<Towed_Unit__c> getTowedUnits(String contactId) {
        String query = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
        query += ' WHERE Contact__c = :contactId';
        
        return Database.query(query);
    }
    
    private static String getQueryWithAllFields(String objName) {
        return 'SELECT ' + String.join(getAllFields(objName), ', ') + ' FROM ' + objName;
    }
    
    private static Set<String> removeFields = new Set<String>{
        'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastvieweddate',
            'lastreferenceddate'
            };
                
                private static List<String> getAllFields(String objectName) {
                    SObjectType objectType = describeObject(objectName);
                    Map<String, Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
                    
                    List<String> fieldsSet = new List<String>();
                    for (String s : mfields.keySet()) {
                        if ((mfields.get(s).getDescribe().isAccessible() && !removeFields.contains(String.valueOf(s).toLowerCase())) || Test.isRunningTest()) {
                            fieldsSet.add(s);
                        }
                    }
                    
                    if (fieldsSet != null && !fieldsSet.contains('id')) {
                        fieldsSet.add('id');
                    }
                    return fieldsSet;
                }
    
    private static SObjectType describeObject(String objectName) {
        return Schema.getGlobalDescribe().get(objectName);
    }
}