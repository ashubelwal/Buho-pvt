public without sharing class Mex_PolicyEditController {

    @AuraEnabled
    public static String getLiabilityMedicalLimitForVendors() {
        try {
            List<Map<String, String>> result = new List<Map<String, String>>();

            for (Liability_Medical_Limit__mdt record : [
                SELECT Liability__c, Medical__c, Vendor__c 
                FROM Liability_Medical_Limit__mdt
            ]) {
                Map<String, String> recordMap = new Map<String, String>{
                    'Vendor' => record.Vendor__c,
                    'Liability' => record.Liability__c,
                    'Medical' => record.Medical__c
                };
                result.add(recordMap);
            }

            return JSON.serialize(result);
        } catch (Exception e) {
            // Log the error and return a failure message (or null if preferred)
            System.debug('Error fetching Liability/Medical limits: ' + e.getMessage());
            return JSON.serialize(new Map<String, String>{
                'error' => 'Failed to fetch liability and medical limits: ' + e.getMessage()
            });
        }
    }

    @AuraEnabled
    public static map<String, Object> getEditPolicyDetail(string policyId){
        map<String, Object> responsemap = new map<String, Object>();
        Policy__c policyDetail = new Policy__c();
        try{
            if(policyId != '' && policyid != null){
                string query = getQueryWithAllFields(Policy__c.getSObjectType().getDescribe().getName());
                query += ' WHERE Id =\'' + policyId + '\'';
                policyDetail = Database.query(query);
                responseMap.put('status','success');
                responseMap.put('policyData', policyDetail);
                // get vehicle data
                Vehicle__c getVehicleData = new Vehicle__c();
                if(policyDetail.Vehicle_Policy__c != null){
                    string vehileQuery = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
                    vehileQuery += ' WHERE Id =\'' + policyDetail.Vehicle_Policy__c + '\'';
                    getVehicleData = Database.query(vehileQuery);
                    responseMap.put('vehicleData', getVehicleData);
                }

                Watercraft__c getWatercraftData = new Watercraft__c();

                if(policyDetail.Watercraft__c != null){
                    string vehileQuery = getQueryWithAllFields(Watercraft__c.getSObjectType().getDescribe().getName());
                    vehileQuery += ' WHERE Id =\'' + policyDetail.Watercraft__c + '\'';
                    getWatercraftData = Database.query(vehileQuery);
                    responseMap.put('watercraftData', getWatercraftData);
                }

                List<Driver__c> getDriverData = new List<Driver__c>();
                if(policyDetail != null){
                    List<Quote_Driver__c> qdr = [SELECT Id, Policy__c, Driver__c  FROM Quote_Driver__c WHERE Policy__c =: policyId];

                    set<String> qtrList = new set<String>();

                    for(Quote_Driver__c eachQdr : qdr){
                        qtrList.add(eachQdr.Driver__c);
                    }
                    if(!qdr.isEmpty()){
                        string driverquery = getQueryWithAllFields(Driver__c.getSObjectType().getDescribe().getName());
                    driverquery += ' WHERE Id IN ';
                    driverquery += ':qtrList';

                    getDriverData = Database.query(driverquery);
                    }
                    responseMap.put('DriverData', getDriverData);
                }
                List<Towed_Unit__c> getTwoedUnitData = new List<Towed_Unit__c>();
                if(policyDetail != null){
                    Quote_Towed_Unit__c[] qtu = [SELECT Id, Policy__c, Towed_Unit__c  FROM Quote_Towed_Unit__c WHERE Policy__c =: policyId];

                    set<String> qtuList = new set<String>();
                    for(Quote_Towed_Unit__c eachQtu : qtu){
                        qtuList.add(eachQtu.Towed_Unit__c);
                    }
                    if(!qtu.isEmpty()){
                        string towedUnitQuery = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
                        towedUnitQuery += ' WHERE Id IN ';
                        towedUnitQuery += ':qtuList';
                        getTwoedUnitData = Database.query(towedUnitQuery);
                        
                    }
                    responseMap.put('towedUnitData', getTwoedUnitData);
                }
                Quote__c getQuoteData = new Quote__c();
                if(policyDetail != null){
                    string quoteQuery = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
                    quoteQuery += ' WHERE Id =\'' + policyDetail.Quote_c__c + '\'';
                    getQuoteData = Database.query(quoteQuery);
                    responseMap.put('quoteData', getQuoteData);
                }
                List<Transaction__c> getTransactionData = new List<Transaction__c>();
                if(policyId != null){
                    getTransactionData = [SELECT Id, Id__c  FROM Transaction__c WHERE Policy_Transaction__c =: policyId];
                    responseMap.put('transactionData', getTransactionData);
                }
                
            }
        }catch(Exception ex){
            CustomErrorExceptionHandlerException.data = 'policyDetail: '+policyDetail;
            CustomErrorExceptionHandlerException.LogException(ex);
            string errorMsg =  ex.getMessage();
            responseMap.put('status','error');
            responseMap.put('message', errorMsg);
            
        }
        return responseMap;
    }
    
    
    public static String getQueryWithAllFields(String objectName) {
        return 'SELECT ' + String.join(getAllFields(objectName), ', ') + ' FROM ' + objectName;
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
    
    @AuraEnabled
    public static String preViewPdfAction( String policyId ) {
        list<Policy__c> policys = new list<Policy__c>();
        policys = [select Id, Underwriter_picklist__c, Policy_Type_picklist__c, Name  from Policy__c where Id =:policyId ];  
        if( policys != null && !policys.isEmpty()){
            String policyType = policys[0].Policy_Type_picklist__c;
            String underWriter = policys[0].Underwriter_picklist__c;

            if (policyType == 'Northbound') {
                return '/apex/Declaration_Page_Insurance_2?Id='+policyId;
            }else if ( policyType == 'Driver License') {
                return '/apex/policy_declaration_driver_license?Id='+policyId;
            }else if ( policyType == 'Watercraft') {
                    system.debug('the return value :: ->>>'+ policyId);
                return '/apex/watercraft_policy_declaration_Page?Id='+policyId;
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                return '/apex/Southbound_PolicyDec_Chubb?Id='+policyId;
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Mapfre' ){
                return '/apex/Southbound_PolicyDeclarationPage_Mapfre?Id='+policyId;
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Qualitas' ){
                return '/apex/Southbound_PolicyDecPage_Qualitas?Id='+policyId;
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                return '/apex/Southbound_Chubb_RV?Id='+policyId;
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Mapfre' ){
                return '/apex/Southbound_Mapfre_RV?Id='+policyId;
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Qualitas' ){
                return '/apex/Southbound_Qualitas_RV?Id='+policyId;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Qualitas' ){
                return '/apex/Southbound_Qualitas_Motorcycle?Id='+policyId;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Mapfre' ){
                return '/apex/Southbound_Mapfre_Motorcycle?Id='+policyId;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                return '/apex/Southbound_ChubbMotorcycle?Id='+policyId;
            }else if( underWriter != null && underWriter == 'Qualitas' ){
                return '/apex/Southbound_PolicyDecPage_Qualitas?Id='+policyId;
            }else if( underWriter != null && underWriter == 'Chubb' ){
                return '/apex/Southbound_PolicyDec_Chubb?Id='+policyId;
            }else if( underWriter != null && underWriter == 'Mapfre' ){
                return '/apex/Southbound_PolicyDeclarationPage_Mapfre?Id='+policyId;  
            }
        }
        return null;
    }


    public static Map<String, Object> getDataRealtedScreen(String policyId, String screenName){
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            if(policyId != null){
                SObject getData;
                if(screenName == 'reviewVehicle'){
                    Policy__c policyVehicle = [SELECT Id, Vehicle_Policy__c, Name FROM Policy__c WHERE Id =: policyId];
                    string query = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
                    query += ' WHERE Id =\'' + policyVehicle.Vehicle_Policy__c + '\'';
                    getData = Database.query(query);
                }else if(screenName == 'driverScreen'){
                    Quote_Driver__c qdr = [SELECT Id, Policy__c, Driver__c  FROM Quote_Driver__c WHERE Policy__c =: policyId];
                    string query = getQueryWithAllFields(Driver__c.getSObjectType().getDescribe().getName());
                    query += ' WHERE Id =\'' + qdr.Driver__c + '\'';
                    getData = Database.query(query);
                }else if(screenName == 'towedDetail'){
                    Quote_Towed_Unit__c qtu = [SELECT Id, Policy__c, Towed_Unit__c  FROM Quote_Towed_Unit__c WHERE Policy__c =: policyId];
                    string query = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
                    query += ' WHERE Id =\'' + qtu.Towed_Unit__c + '\'';
                    getData = Database.query(query);
                }
                responseMap.put('status','success');
                responseMap.put('data', getData);
            }
        }catch(Exception ex){
            CustomErrorExceptionHandlerException.data = 'policyId: '+policyId+'\nscreenName: '+screenName;
            CustomErrorExceptionHandlerException.LogException(ex);
            string errorMsg =  ex.getMessage();
            responseMap.put('status','error');
            responseMap.put('message', errorMsg);
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static map<String, Object> updatePolicyDetails(String quoteData, String DriverData, String vehicleData, String towedUnitData){
        map<String, Object> responseMap = new map<String, Object>();
        Quote__c quoteRecord;
        Vehicle__c vehicleRecord;
        List<Driver__c> driverRecord;
        List<Towed_Unit__c> towedRecord;
        Policy__c policyRecord;
        User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        try{
            if (!String.isEmpty(quoteData)) {
                quoteRecord = (Quote__c) JSON.deserialize(quoteData, Quote__c.class);
                if (quoteRecord != null) {
                    update quoteRecord;
                    
                    policyRecord = [SELECT Id, Name, Quote_c__c, Start_Time__c, End_Time__c From Policy__c Where Quote_c__c = :quoteRecord.Id];
                    
                    policyRecord.Start_Time__c = quoteRecord.Start_Time__c;
                    policyRecord.End_Time__c = quoteRecord.End_Time__c;

                    update policyRecord;
                }
            }
            
            if (!String.isEmpty(vehicleData)) {
                    vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                    Map<String, Object> rawData = (Map<String, Object>) JSON.deserializeUntyped(vehicleData);

                    Map<String, SObjectField> fieldMap = Vehicle__c.SObjectType.getDescribe().fields.getMap();

                    for (String key : rawData.keySet()) {
                        if (fieldMap.containsKey(key)) {
                            try {
                                Object value = rawData.get(key);
                                if (value != null) {
                                    vehicleRecord.put(key, value);
                                }
                            } catch (Exception e) {
                                System.debug('Could not set field: ' + key + ' - ' + e.getMessage());
                            }
                        } else {
                            System.debug('Skipping unknown field from JSON: ' + key);
                        }
                    }

                    if (vehicleRecord.Is_Lienholder__c == false) {
                            vehicleRecord.Lienholder_Name__c = null;
                            vehicleRecord.Lienholder_Phone__c = null;
                            vehicleRecord.Lienholder_Fax__c = null;
                            vehicleRecord.Lienholder_City__c = null;
                            vehicleRecord.Lienholder_Country__c = null;
                            vehicleRecord.Lienholder_Postal_Code__c = null;
                            vehicleRecord.Lienholder_State__c = null;
                            vehicleRecord.Lienholder_Street__c = null;
                            vehicleRecord.Lienholder_Street_2__c = null;
                    }

                    System.debug('Vehicle Data Deser' + JSON.serialize(vehicleRecord));
                    System.debug('Vehicle Data args' + JSON.serialize(vehicleData));
                    if (vehicleRecord != null) {
                        update vehicleRecord;
                    }
            }
            
            if (!String.isEmpty(DriverData)) {
                driverRecord = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);
                
                if (!driverRecord.isEmpty()) {
                    List<Quote_Driver__c> quoteDriverRecord = [SELECT Id, Driver__c,Quote_c__c FROM Quote_Driver__c WHERE Quote_c__c = :quoteRecord.Id];
                    for (Driver__c eachDr : driverRecord) {
                        eachDr.Contact__c = userRecord.ContactId;
                        eachDr.Account_Driver__c = userRecord.AccountId;
                        eachDr.Name = eachDr.First_Name__c + ' ' + eachDr.Last_Name__c;
                    }
                    upsert driverRecord;

                    //logic for matching existing driver list and comparing to remove it
                    List<Quote_Driver__c> deleteQuoteDriverList = new List<Quote_Driver__c>();
                    if(driverRecord.size() != quoteDriverRecord.size()){
                        for(Quote_Driver__c quoteDriver : quoteDriverRecord){
                            Boolean isAvailable = false;
                            for(Driver__c eachDriver : driverRecord){
                                if(eachDriver.Id == quoteDriver.Driver__c){
                                    isAvailable = true;
                                    break;
                                }
                            }
                            if(isAvailable == false){
                                deleteQuoteDriverList.add(quoteDriver);
                            }

                        }
                        if(deleteQuoteDriverList.size() > 0){

                            for(Integer i = 0; i <quoteDriverRecord.size() ; i ++ ){
                                Boolean isAvailable = false;
                                for(Quote_Driver__c eachDeleteQuote : deleteQuoteDriverList){
                                    if(quoteDriverRecord.get(i).Id == eachDeleteQuote.Id ){
                                        isAvailable = true;
                                        break;
                                    }
                                }
                                if(isAvailable == true){
                                    quoteDriverRecord.remove(i);
                                }
                                
                            }
                            
                            Database.delete(deleteQuoteDriverList);
                        }
                    }
                    
                    if (quoteDriverRecord.isEmpty()) {
                        List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
                        for (Driver__c eachDriver : driverRecord) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = userRecord.AccountId;
                            newQuoteDriver.Contact__c = userRecord.ContactId;
                            newQuoteDriver.Driver__c = eachDriver.Id;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Primary_insured__c = eachDriver.Primary_insured__c;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = policyRecord.Id;
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
                        
                        for (Driver__c eachDr : driverRecord) {
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
                                newQuoteDriverData.Quote_c__c = quoteRecord.Id;
                                newQuoteDriverData.Vehicle_Driver__c = vehicleRecord.Id;
                                newQuoteDriverData.Driver__c = eachNewDriver.Id;
                                newQuoteDriverData.Policy__c = policyRecord.Id;
                                quoteDriverNewList.add(newQuoteDriverData);
                            }

                            if (!quoteDriverNewList.isEmpty()) {
                                insert quoteDriverNewList;
                            }
                        }
                    }
                }
            }
            
            if (!String.isEmpty(towedUnitData)) {
                towedRecord = (List<Towed_Unit__c>) JSON.deserialize(towedUnitData, List<Towed_Unit__c>.class);
                if (quoteRecord.Towed_Unit__c == 'Yes' && !towedRecord.isEmpty()) {
                    upsert towedRecord;
                    Quote_Vehicle__c quoteVehicleRecord = [SELECT Id FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteRecord.Id LIMIT 1];
                    List<Quote_Towed_Unit__c> quoteTowRecord = [SELECT Id, Towed_Unit__c FROM Quote_Towed_Unit__c WHERE Quote_c__c = :quoteRecord.Id];
                    if (quoteTowRecord.isEmpty()) {
                        List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
                        for (Towed_Unit__c eachTow : towedRecord) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            newQuoteTowed.Account__c = userRecord.AccountId;
                            newQuoteTowed.Contact__c = userRecord.ContactId;
                            newQuoteTowed.Quote_c__c = quoteRecord.Id;
                            newQuoteTowed.Quote_Vehicle__c = quoteVehicleRecord.Id;
                            newQuoteTowed.Towed_Unit__c = eachTow.Id;
                            newQuoteTowed.Policy__c = policyRecord.Id;
                            quoteTowedList.add(newQuoteTowed);
                        }
                        
                        if (quoteTowedList != null && !quoteTowedList.isEmpty()) {
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

                        for (Towed_Unit__c eachTowedUnit : towedRecord) {
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
                                newQuoteTowedData.Quote_c__c = quoteRecord.Id;
                                newQuoteTowedData.Quote_Vehicle__c = quoteVehicleRecord.Id;
                                newQuoteTowedData.Towed_Unit__c = eachNewTow.Id;
                                newQuoteTowedData.Policy__c = policyRecord.Id;
                                quoteTowedNewList.add(newQuoteTowedData);
                            }
                            
                            if (!quoteTowedNewList.isEmpty()) {
                                upsert quoteTowedNewList;
                            }
                        }
                    }
                }
            }
            
            responseMap.put('status', 'success');
        }catch(Exception ex){
            CustomErrorExceptionHandlerException.data = 'quoteData: '+quoteData+'\nDriverData: '+DriverData+'\nvehicleData: '+vehicleData+'\ntowedUnitData: '+towedUnitData;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status','error');
            responseMap.put('message', ex.getMessage());
        }
        return responseMap;
    }

@AuraEnabled
    public static Map<String, String> createNewWatercraftEditPolicy(String watercraftData, String DriverData, String quoteId, String oldPolicyId, Boolean isRenewal) {
        Map<String, String> responseMap = new Map<String, String>();
        try {
            if (!String.isEmpty(quoteId)) {
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c ,Property_Damage_Liability__c, Third_Party_Bodily_Injury__c
                                        FROM Quote__c WHERE Id = :quoteId];
                
                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                
                if (!policyTransaction.isEmpty()) {
                    // Get Old Policy Record
                    Policy__c oldPolicy;
                    if (!String.isEmpty(oldPolicyId)) {
                        oldPolicy = [SELECT Id, Name, Quote_c__c, Affiliate_Account__c,Contact_Email__c, What_is_the_purpose_of_trip__c, RecordTypeId, 
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId];
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Watercraft__c watercraftRecord;
                    if (!String.isEmpty(watercraftData)) {
                        watercraftRecord = (Watercraft__c) JSON.deserialize(watercraftData, Watercraft__c.class);
                        upsert watercraftRecord;
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
                    newPolicy.Watercraft__c = watercraftRecord.Id;
                    newPolicy.Contact__c = quoteRecord.Contact__c;
                    newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
                    newPolicy.Account_Policy__c = quoteRecord.Account__c;
                    newPolicy.Status_picklist__c = 'Active';
                    newPolicy.Source__c = 'New Lead Flow';
                    newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                    newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                    newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                    newPolicy.Third_Party_Bodily_Injury__c = quoteRecord.Third_Party_Bodily_Injury__c;
                    newPolicy.Property_Damage_Liability__c = quoteRecord.Property_Damage_Liability__c;
                    newPolicy.Term__c = quoteRecord.Term__c;
                    
                    if (quoteRecord.Term__c != null && (quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual' )) {
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
                        // newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
                    } else {
                        newPolicy.renewed_check__c = true;
                        newPolicy.renewed_from_id__c = oldPolicy.Id;
                        newPolicy.Name = Mex_NewLeadProcess.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
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
                    
                    Quote_Watercraft__c newQuoteWatercraft = new Quote_Watercraft__c();
                    newQuoteWatercraft.Account__c = quoteRecord.Account__c;
                    newQuoteWatercraft.Contact__c = quoteRecord.Contact__c;
                    newQuoteWatercraft.Watercraft__c = watercraftRecord.Id;
                    newQuoteWatercraft.Quote_c__c = quoteRecord.Id;
                    newQuoteWatercraft.Policy__c = newPolicy.Id;
                    insert newQuoteWatercraft;

                    // Create New Quote Driver Record
                    List<Quote_Driver__c> newQuoteDriverList = new List<Quote_Driver__c>();
                    if (!driverList.isEmpty()) {
                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Watercraft__c = watercraftRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
                        }
                    }

                    // Update New Transaction Record
                    policyTransaction[0].Policy_Transaction__c = newPolicy.Id;
                    policyTransaction[0].Account_Transaction__c = quoteRecord.Account__c;
                    update policyTransaction;
                    
                    // Update the Old Policy Transaction Record
                    List<Transaction__c> oldPolicyTransactionList = [SELECT Id, Policy_Transaction__c, Quote_c__c FROM Transaction__c Where Policy_Transaction__c = :oldPolicy.Id LIMIT 500];
                    
                    if (!oldPolicyTransactionList.isEmpty() && !isRenewal) {
                        List<Transaction__c> oldPolicyTransList = new List<Transaction__c>();
                        for (Transaction__c eachTrans : oldPolicyTransactionList) {
                            eachTrans.Policy_Transaction__c = newPolicy.Id;
                            eachTrans.Quote_c__c = quoteRecord.Id;
                            eachTrans.Account_Transaction__c = quoteRecord.Account__c;
                            oldPolicyTransList.add(eachTrans);
                        }
                        
                        if (!oldPolicyTransList.isEmpty()) {
                            update oldPolicyTransList;
                        }
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
            CustomErrorExceptionHandlerException.data = 'watercraftData: '+ watercraftData +'\nDriverData: ' + DriverData + '\nquoteId: ' + quoteId + '\noldPolicyId: ' + oldPolicyId + 'isRenewal: ' + isRenewal;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        
        return responseMap;
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
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c,Gold__c,Max__c,Platinum__c
                                        FROM Quote__c WHERE Id = :quoteId];
                
                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                System.debug('policyTransaction--> '+policyTransaction);
                 System.debug('oldPolicy--> '+oldPolicyId);
                if (!policyTransaction.isEmpty()) {
                    // Get Old Policy Record
                    Policy__c oldPolicy;
                    if (String.isNotBlank(oldPolicyId)) {
                        oldPolicy = [SELECT Id, Name, Quote_c__c, Affiliate_Account__c,Contact_Email__c, What_is_the_purpose_of_trip__c, RecordTypeId, 
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId];
                        System.debug('oldPolicy--> '+oldPolicy);
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Vehicle__c vehicleRecord;
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                        Map<String, Object> rawData = (Map<String, Object>) JSON.deserializeUntyped(vehicleData);

                        Map<String, SObjectField> fieldMap = Vehicle__c.SObjectType.getDescribe().fields.getMap();

                        for (String key : rawData.keySet()) {
                            if (fieldMap.containsKey(key)) {
                                try {
                                    Object value = rawData.get(key);
                                    if (value != null) {
                                        vehicleRecord.put(key, value);
                                    }
                                } catch (Exception e) {
                                    System.debug('Could not set field: ' + key + ' - ' + e.getMessage());
                                }
                            } else {
                                System.debug('Skipping unknown field from JSON: ' + key);
                            }
                        }
                        if (vehicleRecord.Is_Lienholder__c == false) {
                            vehicleRecord.Lienholder_Name__c = null;
                            vehicleRecord.Lienholder_Phone__c = null;
                            vehicleRecord.Lienholder_Fax__c = null;
                            vehicleRecord.Lienholder_City__c = null;
                            vehicleRecord.Lienholder_Country__c = null;
                            vehicleRecord.Lienholder_Postal_Code__c = null;
                            vehicleRecord.Lienholder_State__c = null;
                            vehicleRecord.Lienholder_Street__c = null;
                            vehicleRecord.Lienholder_Street_2__c = null;
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
                    //System.debug('Picklist value length'+quoteRecord.Medical__c.length()+' '+quoteRecord.Medical__c);
                    newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                    newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                    newPolicy.Term__c = quoteRecord.Term__c;
                    
                    if (quoteRecord.Term__c != null && (quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual' )) {
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
                        // newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
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
                    // Removed code && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')
                    if (quoteRecord.Policy_Type_picklist__c != null ) {
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
                    
                    // Update the Old Policy Record...
                    if (oldPolicy != null && !isRenewal) {
                        oldPolicy.Status_picklist__c  = 'Updated';
                        oldPolicy.Policy__c = newPolicy.Id;
                        update oldPolicy;
                    }
                    
                    // update the New Quote Record
                    if (quoteRecord != null) {
                        quoteRecord.Quote_Status__c = 'Policy Created';
                        quoteRecord.Policy__c = newPolicy.Id;
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
    public static Map<String, Object> createCloneQuote(String quote){
        Map<String, String> responseMap = new Map<String, String>();
        try {

            if (!String.isEmpty(quote)) {
                Quote__c quoteRecord = (Quote__c) JSON.deserialize(quote, Quote__c.class);
                Database.SaveResult quoteData = Database.insert(quoteRecord, true);

                if (quoteData.isSuccess()) {
                    responseMap.put('status', 'success');
                    responseMap.put('data', quoteData.getId());

                } else {
                    List<Database.Error> err = new List<Database.Error>(quoteData.getErrors());
                    responseMap.put('status', 'success');
                    responseMap.put('message', err[0].getMessage());
                }
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'quote: ' + quote;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> updateQuoteData(String quote){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quote)) {
                Quote__c quoteRecord = (Quote__c) JSON.deserialize(quote, Quote__c.class);
                update quoteRecord;

                if (quoteRecord != null) {
                    responseMap.put('status', 'success');
                    responseMap.put('data', quoteRecord);
                }
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'quote: '+quote;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        return responseMap;
    }
    
    
    
    @AuraEnabled
    public static Map<String, Object> createNewRenewQuote(String quote, String oldQuoteId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quote)) {
                Quote__c quoteRecord = (Quote__c) JSON.deserialize(quote, Quote__c.class);

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
    
    @AuraEnabled
    public static Map<String, String> fetchRenewQuoteData(String renewedQuoteId) {
        Map<String, String> responseMap = new Map<String, String>();
        List<Policy__c> policyRecord = new List<Policy__c>();
        try {
            if (!String.isEmpty(renewedQuoteId)) {
                List<Quote__c> quoteRecord = new List<Quote__c>();
                string query1 = getQueryWithAllFields(Policy__c.getSObjectType().getDescribe().getName());
                query1 += ' WHERE Quote_c__c =\'' + renewedQuoteId + '\'';
                policyRecord = Database.query(query1);
                
                string query2 = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
                query2 += ' WHERE Id =\'' + renewedQuoteId + '\'';
                quoteRecord = Database.query(query2);
                
                if (!policyRecord.isEmpty()) {
                    responseMap.put('policyExist', 'true');
                    responseMap.put('policyData', JSON.serialize(policyRecord[0]));
                    
                    List<Vehicle__c> vehicleRecord = new List<Vehicle__c>();
                    string queryVeh = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
                    queryVeh += ' WHERE Id =\'' + policyRecord[0].Vehicle_Policy__c + '\'';
                    vehicleRecord = Database.query(queryVeh);
                    
                    if (!vehicleRecord.isEmpty() && vehicleRecord.size() > 0) {
                        responseMap.put('vehicleData', JSON.serialize(vehicleRecord[0]));
                    }
                    
                    List<Driver__c> driverRecord = new List<Driver__c>();
                    driverRecord = getDriver(renewedQuoteId);
                    
                    if (!driverRecord.isEmpty()) {
                        responseMap.put('DriverData', JSON.serialize(driverRecord));
                    }
                    
                    List<Towed_Unit__c> towedUnitRecord = new List<Towed_Unit__c>();
                    towedUnitRecord = getTowedUnit(renewedQuoteId);
                    
                    if (!towedUnitRecord.isEmpty()) {
                        responseMap.put('towedUnitData', JSON.serialize(towedUnitRecord));
                    }
                }

                if (!quoteRecord.isEmpty()) {
                    responseMap.put('policyExist', 'false');
                    responseMap.put('status', 'success');
                    responseMap.put('quoteData', JSON.serialize(quoteRecord[0]));
                }
            } else {
                // return error -> renewedQuoteId Missing...
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'renewedQuoteId: '+renewedQuoteId+'\npolicyRecord: '+JSON.serialize(policyRecord);
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        return responseMap;
    }
    
    public static List<Driver__c> getDriver(String quoteId) {
        list<Quote_Driver__c> quotedrivers = new list<Quote_Driver__c>();
        quotedrivers = [select Driver__c from Quote_Driver__c where Quote_c__c =: quoteId];
        if( quotedrivers != null && !quotedrivers.isEmpty()){
            set<String> driversIds = new set<String>();
            for(Quote_Driver__c qdr : quotedrivers){
                driversIds.add( qdr.Driver__c );
            }
            String query = getQueryWithAllFields(Driver__c.getSObjectType().getDescribe().getName());
            query += ' where Id IN: driversIds';
            return Database.query(query);
        }
        return new list<Driver__c>();
    }
    
    public static List<Towed_Unit__c> getTowedUnit(String quoteId) {
        list<Quote_Towed_Unit__c> quoteTowedUnits = new list<Quote_Towed_Unit__c>();
        quoteTowedUnits = [select Id, Towed_Unit__c from Quote_Towed_Unit__c where Quote_c__c =: quoteId limit 1];

        if( quoteTowedUnits != null && !quoteTowedUnits.isEmpty()){
            set<String> towedIds = new set<String>();
            for(Quote_Towed_Unit__c qtu : quoteTowedUnits){
                towedIds.add( qtu.Towed_Unit__c );
            }

            String query = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
            query += ' where Id IN: towedIds ';
            return Database.query(query);
        }
        return new list<Towed_Unit__c>();
    }
}