public without sharing class AffiliatePolicyEditRenewUtils {
    
    @AuraEnabled(cacheable=true)
    public static Policy__c fetchPolicyDetails(String policyId){
        try {
            List<Policy__c> policies = new List<Policy__c>();
            policies = [Select Id, Name,Quote_c__c, Underwriter_picklist__c,Contact__c,Account_Policy__c, Policy_Type_picklist__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,Agent_Fee__c
            , Term__c, Medical_picklist__c, Liability_picklist__c, Vehicle_Policy__c, Vehicle_type__c,Net_Premium__c,Surcharge__c,Broker_Policy_Fee__c,I_V_A_Mex_Tax__c,Total_Premium_Amount__c, Total_Transaction_Amount__c
            , Agent__c, Agency__c
            from Policy__c 
            Where Name =:policyId OR Id =:policyId LIMIT 1];
            return policies.get(0);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getAffiliateUser(String agencyId, String agentId){
        try {
            if(agencyId != null & agentId != null){
                List<Affiliate__c> affiliateUserList = [SELECT Affiliate_Id__c, Agency_Logo__c, 
                                                        Agent_Id__c, Agency_Contact__c, 
                                                        Agent_Contact__c,
                                                        Agent_Fee__c ,
                                                        Agency_Id__c, 
                                                        Owner_Name__c, 
                                                        Owner_Photo__c
                                                        FROM Affiliate__c Where Agent_Contact__c =: agentId AND Agency_Contact__c =: agencyId];
                
                
                
                if(affiliateUserList.size() > 0){
                    if(affiliateUserList[0].Agent_Fee__c == null){
                        affiliateUserList[0].Agent_Fee__c = 0;
                    }
                }
                
                System.debug(affiliateUserList);
                if(affiliateUserList.size() > 0){
                    return JSON.serialize(affiliateUserList[0]);
                }
                return '';
            }
            
        } catch (Exception ex) {
            System.debug('Exception occures in AffiliatePolicyEditrenew Class. Exception message:'+ex.getMessage());
            
        }
        return '';
        
    }
    
    @AuraEnabled
    public static Map<String, String> createNewEditPolicy(String vehicleData, String DriverData, String towedUnitData, String quoteId, String oldPolicyId, Boolean isRenewal) {
        Map<String, String> responseMap = new Map<String, String>();
        
        try {
            if (String.isNotBlank(quoteId)) {
                SYstem.debug('inside QuoteId');
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c 
                                        FROM Quote__c WHERE Id = :quoteId];
                
                
                
                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                policyTransaction[0].Payment_Type__c = 'Card';
                
                System.debug('policyTransaction--> '+policyTransaction);
                System.debug('oldPolicy--> '+oldPolicyId);
                if (!policyTransaction.isEmpty()) {
                    // Get Old Policy Record
                    Policy__c oldPolicy;
                    if (String.isNotBlank(oldPolicyId)) {
                        oldPolicy = [SELECT Id, Name, Quote_c__c, Affiliate_Account__c,Contact_Email__c, What_is_the_purpose_of_trip__c, RecordTypeId, 
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c,Agency__c ,Agent__c 
                                     FROM Policy__c 
                                     WHERE Name = :oldPolicyId OR Id=:oldPolicyId];
                        System.debug('oldPolicy--> '+oldPolicy);
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Vehicle__c vehicleRecord;
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
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
                    
                    if (quoteRecord.Term__c != null && quoteRecord.Term__c == 'Annual(One Year)') {
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
                        newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
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
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }
                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;
                    
                    if(oldPolicy.Agency__c != null && oldPolicy.Agent__c != null){
                        newPolicy.Agency__c = oldPolicy.Agency__c;
                        newPolicy.Agent__c = oldPolicy.Agent__c;
                    }
                    
                    insert newPolicy;
                    
                    Id loggedInUserId = UserInfo.getUserId();
                    if(oldPolicy.Agency__c == null && oldPolicy.Agent__c == null){
                        AgencyController.updatePolicyAgentAgency(newPolicy.Id,loggedInUserId);
                    }
                    
                    
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
                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
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
                } else {
                    // return error -> Transaction missing;
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
    public static Map<String, String> createNewEditPolicyFromCash(String vehicleData, String DriverData, String towedUnitData, String quoteId, String oldPolicyId, Boolean isRenewal) {
        Map<String, String> responseMap = new Map<String, String>();
        
        try {
            if (String.isNotBlank(quoteId)) {
                SYstem.debug('inside QuoteId createNewEditPolicyFromCash');
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c , Date_of_Birth__c
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
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c,Agency__c,Agent__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId OR Name =:oldPolicyId];
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Vehicle__c vehicleRecord;
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
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
                    
                    if (quoteRecord.Term__c != null && quoteRecord.Term__c == 'Annual(One Year)') {
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
                        newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
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
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }
                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;
                    
                    if(oldPolicy.Agency__c != null && oldPolicy.Agent__c != null){
                        newPolicy.Agency__c = oldPolicy.Agency__c;
                        newPolicy.Agent__c = oldPolicy.Agent__c;
                    }
                    
                    insert newPolicy;
                    
                    
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
                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
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
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c 
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
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c,Agency__c,Agent__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId OR Name =: oldPolicyId];
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Vehicle__c vehicleRecord;
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
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
                    
                    if (quoteRecord.Term__c != null && quoteRecord.Term__c == 'Annual(One Year)') {
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
                        newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
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
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }
                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;
                    
                    if(oldPolicy.Agency__c != null && oldPolicy.Agent__c != null){
                        newPolicy.Agency__c = oldPolicy.Agency__c;
                        newPolicy.Agent__c = oldPolicy.Agent__c;
                    }
                    
                    insert newPolicy;
                    
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
                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
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
    public static Id getCurrentPolicyId(String quoteData){
        Quote__c quoteRecord;
        Policy__c policyRecord;
        
        if (!String.isEmpty(quoteData)) {
            system.debug('quoteData: updatePolicyDetails---->'+quoteData);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quoteData);
            String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
            String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
            jsonMap.put('Start_Time__c', startTime);
            jsonMap.put('End_Time__c', endTime);
            quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
            system.debug('quoteRecord--- updatePolicyDetails:---->'+quoteRecord);
            if (quoteRecord != null) {
                
                policyRecord = [SELECT Id, Name, Quote_c__c, Start_Time__c, End_Time__c From Policy__c Where Quote_c__c = :quoteRecord.Id];
                
                if(policyRecord != null){
                    return  policyRecord.Id;
                }
                return '';
                
                
                
            }
            
            return '';
            
        }
        return '';
    }
    
    @AuraEnabled
    public static string validateandGenerateQuotePDF(String policyId) {
        String pref;
        try {
            // Replace Visualforce(AccountDetails) page with your visualforce page
            if(String.isNotBlank(policyId)){
                Policy__c policyDetail = [Select Id, Policy_Type_picklist__c, Underwriter_picklist__c from Policy__c Where Name =:policyId OR Id =:policyId LIMIT 1];
                String policyType = policyDetail.Policy_Type_picklist__c;
                String underWriter = policyDetail.Underwriter_picklist__c;
                
                
                if (policyType == 'Northbound') {
                    pref = 'Declaration_Page_Insurance_2';
                }else if ( policyType == 'Driver License') {
                    pref = 'policy_declaration_driver_license';
                }else if ( policyType == 'Watercraft') {
                    pref = 'watercraft_policy_declaration_Page';
                }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                    pref = 'Southbound_PolicyDec_Chubb';
                }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Mapfre' ){
                    pref = 'Southbound_PolicyDeclarationPage_Mapfre';
                }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Qualitas' ){
                    pref = 'Southbound_PolicyDecPage_Qualitas';
                }else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                    pref = 'Southbound_Chubb_RV';
                }else if( policyType == 'RV' && underWriter != null && underWriter == 'Mapfre' ){
                    pref = 'Southbound_Mapfre_RV';
                }else if( policyType == 'RV' && underWriter != null && underWriter == 'Qualitas' ){
                    pref = 'Southbound_Qualitas_RV';
                }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Qualitas' ){
                    pref = 'Southbound_Qualitas_Motorcycle';
                }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Mapfre' ){
                    pref = 'Southbound_Mapfre_Motorcycle';
                }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                    pref = 'Southbound_ChubbMotorcycle';
                }
            }
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            System.debug('*****exception***' + e.getMessage() + '---line-' + e.getLineNumber());
        }
        return pref;
    }
    
    
}