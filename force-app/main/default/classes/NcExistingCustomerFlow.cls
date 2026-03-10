/**
* @File Name : NcExistingCustomerFlow.cls
* @Description :
* @Author : A Singh
* @Last Modified By :
* @Last Modified On : April 30, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 30, 2025 |   | Initial Version
**/

public without sharing class NcExistingCustomerFlow {

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
                    List<Contact> contactList = new List<Contact>();

                    contactList = getContact(loginUserList[0].ContactId);
                    if (contactList != null && !contactList.isEmpty()) {
                        responseMap.put('contact', contactList);
                    }

                    driversList = getDrivers(loginUserList[0].ContactId);
                    if (driversList != null && !driversList.isEmpty()) {
                        responseMap.put('drivers', driversList);
                    }
                    vehicleList = getVehicles(loginUserList[0].contactId);
                    System.debug('vehicleList@@@@'+vehicleList);
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
            
            responseMap.put('status', 'success'); } catch (Exception ex) { 
                responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); 
                CustomErrorExceptionHandlerException.LogException(ex); 
            }
        return JSON.serialize(responseMap);
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
    
    private static List<Contact> getContact(String contactId) {
        String query = getQueryWithAllFields(Contact.getSObjectType().getDescribe().getName());
        query += ' WHERE Id = :contactId';
        
        return Database.query(query);
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
        System.debug('@@@@query'+query);
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


    @AuraEnabled
    public static Map<String, Object> saveQuoteRecordData(String quoteRecord, String vehicleRecord, String towedUnitRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (!String.isEmpty(quoteRecord) && !String.isEmpty(vehicleRecord)) {
                Vehicle__c vehicleData = (Vehicle__c) JSON.deserialize(vehicleRecord, Vehicle__c.class);
                Quote__c quoteData = (Quote__c) JSON.deserialize(quoteRecord, Quote__c.class);
                List<Towed_Unit__c> towedUnitsData;
                User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId,UserType FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                if (String.isNotEmpty(towedUnitRecord)) {
                    towedUnitsData = (List<Towed_Unit__c>) JSON.deserialize(towedUnitRecord, List<Towed_Unit__c>.class);
                }
                if (quoteData != null && vehicleData != null) {
                    quoteData.Account__c = userRecord.AccountId;
                    quoteData.Contact__c = userRecord.ContactId;
                    quoteData.Quote_Status__c = 'Draft';
                    quoteData.Towed_Unit__c = quoteData.Towed_Unit__c;
                    quoteData.Medical__c = quoteData.Policy_Type_picklist__c == 'Motorcycle' || quoteData.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' ? '' : quoteData.Medical__c;
                    Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quoteRecord);
                    // Get raw time strings
                    String startTimeStr = (String)jsonMap.get('Start_Time__c');
                    String endTimeStr = (String)jsonMap.get('End_Time__c');

                    String[] strTimeSplit = startTimeStr.split(':');
                    Time timeStartChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                        ,Integer.valueOf(strTimeSplit[1]) //min
                                                        ,0                                //sec
                                                        ,0);   
                    String[] strEndSplit = endTimeStr.split(':');
                    Time timeEndChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                        ,Integer.valueOf(strTimeSplit[1]) //min
                                                        ,0                                //sec
                                                        ,0);   

                    quoteData.Start_Time__c = timeStartChange;
                    quoteData.End_Time__c = timeEndChange;
                    upsert quoteData;
                    
                    if(vehicleData.Id != null && UserInfo.getuserType() != 'Guest'){
                        QuickQuotationCtrl.vechileTriggerAction = false;
                    }else{
                        vehicleData.Id = null;
                    }
                    vehicleData.Account_Vehicle__c = userRecord.AccountId;
                    vehicleData.Contact__c = userRecord.ContactId;
                    vehicleData.Name = vehicleData.Model__c + ' ' + vehicleData.Make__c + ' ' + vehicleData.Year__c;
                    vehicleData.Rental__c = quoteData.Is_this_a_Rental_Vehicle__c ? 'Yes' : 'No';
                    vehicleData.Vehicle_Type__c = quoteData.Vehicle_Sub_type__c;
                    if(UserInfo.getuserType() != 'Guest'){
                        upsert vehicleData;
                    }else{
                        insert vehicleData;
                    }
                    
                    
                    responseMap.put('status', 'success');
                    responseMap.put('quoteData', quoteData);
                    responseMap.put('vehicleData', vehicleData);
                }
                
                if ((quoteData.Towed_Unit__c == 'Yes' || quoteData.Towed_Unit__c == 'true')  && towedUnitsData != null && towedUnitsData.size() > 0) {
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

    // @AuraEnabled
    // public static map<String, Object> updateQuoteRecordData(String quoteRecord, String vehicleRecord, String towedUnitRecord, String driversRecord) {
    //     Map<String, Object> responseMap = new Map<String, Object>();
    //     try {
    //         if (!String.isEmpty(quoteRecord) && !String.isEmpty(vehicleRecord)) {
    //             vehicleRecord = vehicleRecord.replaceAll('\\{\\}', 'null');
    //             Vehicle__c vehicleData = (Vehicle__c) JSON.deserialize(vehicleRecord, Vehicle__c.class);

    //             quoteRecord = quoteRecord.replaceAll('\\{\\}', 'null');
    //             Quote__c quoteData = (Quote__c) JSON.deserialize(quoteRecord, Quote__c.class);
                
    //             List<Towed_Unit__c> towedUnitsData;
    //             User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    //             towedUnitRecord = towedUnitRecord.replaceAll('\\{\\}', 'null');
    //             if (String.isNotEmpty(towedUnitRecord)) {
    //                 towedUnitsData = (List<Towed_Unit__c>) JSON.deserialize(towedUnitRecord, List<Towed_Unit__c>.class);
    //             }

    //             if (quoteData != null && quoteData.Id != null) {
    //                 update quoteData;
    //                 responseMap.put('status', 'success');
    //                 responseMap.put('quoteData', quoteData);
    //             }
                
    //             if (vehicleData != null && vehicleData.Id != null) {
    //                 QuickQuotationCtrl.vechileTriggerAction = false;
    //                 vehicleData.Rental__c = quoteData.Is_this_a_Rental_Vehicle__c ? 'Yes' : 'No';
    //                 vehicleData.Vehicle_Type__c = quoteData.Vehicle_Sub_type__c;
    //                 update vehicleData;
    //                 responseMap.put('vehicleData', vehicleData);
    //             }
                
    //             if ((quoteData.Towed_Unit__c == 'Yes' || quoteData.Towed_Unit__c == 'true') && towedUnitsData != null && !towedUnitsData.isEmpty()) {
    //                 upsert towedUnitsData;
    //                 responseMap.put('towedUnitData', towedUnitsData);
                    
    //                 Quote_Vehicle__c quoteVehicleRecord = [SELECT Id FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteData.Id LIMIT 1];
    //                 List<Quote_Towed_Unit__c> quoteTowRecord = [SELECT Id, Towed_Unit__c FROM Quote_Towed_Unit__c WHERE Quote_c__c = :quoteData.Id];
    //                 if (quoteTowRecord.isEmpty()) {
    //                     List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
    //                     for (Towed_Unit__c eachTow : towedUnitsData) {
    //                         Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
    //                         newQuoteTowed.Account__c = userRecord.AccountId;
    //                         newQuoteTowed.Contact__c = userRecord.ContactId;
    //                         newQuoteTowed.Quote_c__c = quoteData.Id;
    //                         newQuoteTowed.Quote_Vehicle__c = quoteVehicleRecord.Id;
    //                         newQuoteTowed.Towed_Unit__c = eachTow.Id;

    //                         quoteTowedList.add(newQuoteTowed);
    //                     }
                        
    //                     if (!quoteTowedList.isEmpty()) {
    //                         upsert quoteTowedList;
    //                     }
    //                 } else {
    //                     Map<Id, Quote_Towed_Unit__c> quoteTowedMap = new Map<Id, Quote_Towed_Unit__c>();
    //                     List<Towed_Unit__c> newTowedToInsert = new List<Towed_Unit__c>();
    //                     for (Quote_Towed_Unit__c eachQuoteTowed : quoteTowRecord) {
    //                         if (!quoteTowedMap.containsKey(eachQuoteTowed.Id)) {
    //                             quoteTowedMap.put(eachQuoteTowed.Towed_Unit__c, eachQuoteTowed);
    //                         }
    //                     }
    //                     for (Towed_Unit__c eachTowedUnit : towedUnitsData) {
    //                         if (!quoteTowedMap.containsKey(eachTowedUnit.Id)) {
    //                             newTowedToInsert.add(eachTowedUnit);
    //                         }
    //                     }

    //                     if (!newTowedToInsert.isEmpty()) {
    //                         List<Quote_Towed_Unit__c> quoteTowedNewList = new List<Quote_Towed_Unit__c>();
    //                         for (Towed_Unit__c eachNewTow : newTowedToInsert) {
    //                             Quote_Towed_Unit__c newQuoteTowedData = new Quote_Towed_Unit__c();
    //                             newQuoteTowedData.Account__c = userRecord.AccountId;
    //                             newQuoteTowedData.Contact__c = userRecord.ContactId;
    //                             newQuoteTowedData.Quote_c__c = quoteData.Id;
    //                             newQuoteTowedData.Quote_Vehicle__c = quoteVehicleRecord.Id;
    //                             newQuoteTowedData.Towed_Unit__c = eachNewTow.Id;
    //                             quoteTowedNewList.add(newQuoteTowedData);
    //                         }
                            
    //                         if (!quoteTowedNewList.isEmpty()) {
    //                             upsert quoteTowedNewList;
    //                         }
    //                     }
    //                 }
    //             }
                
    //             if (String.isNotEmpty(driversRecord)) {
    //                 List<Driver__c> driversData = (List<Driver__c>) JSON.deserialize(driversRecord, List<Driver__c>.class);
    //                 List<Quote_Driver__c> quoteDriverRecord = [SELECT Id, Driver__c,Quote_c__c FROM Quote_Driver__c WHERE Quote_c__c = :quoteData.Id];
                    
    //                 if (driversData != null && !driversData.isEmpty()) {
    //                     for (Driver__c eachDr : driversData) {
    //                         eachDr.Contact__c = userRecord.ContactId;
    //                         eachDr.Account_Driver__c = userRecord.AccountId;
    //                         eachDr.Name = eachDr.First_Name__c + ' ' + eachDr.Last_Name__c;
    //                     }
    //                     upsert driversData;
    //                     responseMap.put('DriversData', driversData);
                        
    //                     if (quoteDriverRecord.size() == 0) {
    //                         List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
    //                         for (Driver__c eachDriver : driversData) {
    //                             Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
    //                             newQuoteDriver.Account_Driver__c = userRecord.AccountId;
    //                             newQuoteDriver.Contact__c = userRecord.ContactId;
    //                             newQuoteDriver.Driver__c = eachDriver.Id;
    //                             newQuoteDriver.Quote_c__c = quoteData.Id;
    //                             newQuoteDriver.Primary_insured__c = eachDriver.Primary_insured__c;
    //                             newQuoteDriver.Vehicle_Driver__c = vehicleData.Id;
    //                             quoteDriversList.add(newQuoteDriver);
    //                         }
                            
    //                         if (!quoteDriversList.isEmpty()) {
    //                             upsert quoteDriversList;
    //                         }
    //                     } else {
    //                         Map<Id, Quote_Driver__c> quoteDriverMap = new Map<Id, Quote_Driver__c>();
    //                         List<Driver__c> newDriverToInsert = new List<Driver__c>();
    //                         for (Quote_Driver__c eachQuoteDriver : quoteDriverRecord) {
    //                             if (!quoteDriverMap.containsKey(eachQuoteDriver.Id)) {
    //                                 quoteDriverMap.put(eachQuoteDriver.Driver__c, eachQuoteDriver);
    //                             }
    //                         }
                            
    //                         for (Driver__c eachDr : driversData) {
    //                             if (!quoteDriverMap.containsKey(eachDr.Id)) {
    //                                 newDriverToInsert.add(eachDr);
    //                             }
    //                         }
                            
    //                         if (!newDriverToInsert.isEmpty()) {
    //                             List<Quote_Driver__c> quoteDriverNewList = new List<Quote_Driver__c>();
    //                             for (Driver__c eachNewDriver : newDriverToInsert) {
    //                                 Quote_Driver__c newQuoteDriverData = new Quote_Driver__c();
    //                                 newQuoteDriverData.Account_Driver__c = userRecord.AccountId;
    //                                 newQuoteDriverData.Contact__c = userRecord.ContactId;
    //                                 newQuoteDriverData.Quote_c__c = quoteData.Id;
    //                                 newQuoteDriverData.Vehicle_Driver__c = vehicleData.Id;
    //                                 newQuoteDriverData.Driver__c = eachNewDriver.Id;
    //                                 quoteDriverNewList.add(newQuoteDriverData);
    //                             }
                                
    //                             if (!quoteDriverNewList.isEmpty()) {
    //                                 upsert quoteDriverNewList;
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         } else {
    //             responseMap.put('status', 'error');
    //             responseMap.put('message', 'Either Quote or Vehicle record is missing.');
    //         }
    //     } catch (Exception ex) {
    //         responseMap.put('status', 'error');
    //         responseMap.put('message', ex.getMessage());
    //         CustomErrorExceptionHandlerException.LogException(ex);
    //     }
    //     return responseMap;
    // }

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
                
                if ((quoteData.Towed_Unit__c == 'Yes' || quoteData.Towed_Unit__c == 'true') && towedUnitsData != null && !towedUnitsData.isEmpty()) {
                    upsert towedUnitsData;
                    responseMap.put('towedUnitData', towedUnitsData);
                    
                    Quote_Vehicle__c quoteVehicleRecord = [SELECT Id FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteData.Id LIMIT 1];
                    List<Quote_Towed_Unit__c> quoteTowRecord = [SELECT Id, Towed_Unit__c FROM Quote_Towed_Unit__c WHERE Quote_c__c = :quoteData.Id];
                    if (quoteTowRecord.isEmpty()) {
                        List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
                        for (Towed_Unit__c eachTow : towedUnitsData) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            //NULL CHECK ADDED
                            if(userRecord.AccountId != null){
                                newQuoteTowed.Account__c = userRecord.AccountId;
                            }
                            if(userRecord.ContactId != null){
                                newQuoteTowed.Contact__c = userRecord.ContactId;
                            }
                            if(quoteData.Id != null){
                                newQuoteTowed.Quote_c__c = quoteData.Id;
                            }
                            if(quoteVehicleRecord.Id != null){
                                newQuoteTowed.Quote_Vehicle__c = quoteVehicleRecord.Id;
                            }
                            if(eachTow.Id != null){
                                newQuoteTowed.Towed_Unit__c = eachTow.Id;
                            }                                                     
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
                                //NULL CHECK ADDED
                                if(userRecord.AccountId != null){
                                    newQuoteTowedData.Account__c = userRecord.AccountId;
                                }
                                if(userRecord.ContactId != null){
                                    newQuoteTowedData.Contact__c = userRecord.ContactId;
                                }
                                if(quoteData.Id != null){
                                    newQuoteTowedData.Quote_c__c = quoteData.Id;
                                }
                                if(quoteVehicleRecord.Id != null){
                                    newQuoteTowedData.Quote_Vehicle__c = quoteVehicleRecord.Id;
                                }
                                if(eachNewTow.Id != null){
                                    newQuoteTowedData.Towed_Unit__c = eachNewTow.Id;
                                }                                
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
                            //NULL CHECK ADDED
                            if(userRecord.ContactId != null){
                                eachDr.Contact__c = userRecord.ContactId;
                            }
                            if(userRecord.AccountId != null){
                                eachDr.Account_Driver__c = userRecord.AccountId;
                            }
                            eachDr.Name = eachDr.First_Name__c + ' ' + eachDr.Last_Name__c;
                        }
                        upsert driversData;
                        responseMap.put('DriversData', driversData);
                        
                        if (quoteDriverRecord.size() == 0) {
                            List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
                            for (Driver__c eachDriver : driversData) {
                                Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                                //NULL CHECK ADDED
                                if(userRecord.AccountId != null){
                                    newQuoteDriver.Account_Driver__c = userRecord.AccountId;
                                }
                                if(userRecord.ContactId != null){
                                    newQuoteDriver.Contact__c = userRecord.ContactId;
                                }
                                if(eachDriver.Id != null){
                                    newQuoteDriver.Driver__c = eachDriver.Id;
                                }
                                if(quoteData.Id != null){
                                    newQuoteDriver.Quote_c__c = quoteData.Id;
                                }
                                if(eachDriver.Primary_insured__c != null){
                                    newQuoteDriver.Primary_insured__c = eachDriver.Primary_insured__c;
                                }
                                if(vehicleData.Id != null){
                                    newQuoteDriver.Vehicle_Driver__c = vehicleData.Id;
                                }
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
                                    //NULL CHECK ADDED
                                    if(userRecord.AccountId != null){
                                        newQuoteDriverData.Account_Driver__c = userRecord.AccountId;
                                    }
                                    if(userRecord.ContactId != null){
                                        newQuoteDriverData.Contact__c = userRecord.ContactId;
                                    }
                                    if(quoteData.Id != null){
                                        newQuoteDriverData.Quote_c__c = quoteData.Id;
                                    }
                                    if(vehicleData.Id != null){
                                        newQuoteDriverData.Vehicle_Driver__c = vehicleData.Id;
                                    }
                                    if(eachNewDriver.Id != null){
                                        newQuoteDriverData.Driver__c = eachNewDriver.Id;
                                    }
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


}