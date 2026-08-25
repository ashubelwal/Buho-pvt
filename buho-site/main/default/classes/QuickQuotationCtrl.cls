public  without sharing class QuickQuotationCtrl {
    public static Boolean vechileTriggerAction = true;
    
    @AuraEnabled
    public static String getTimeZone() {
        Datetime dt = System.now();
        
        //Convert it into Pacific Standard Time(PST).
        String dtPST = dt.format('yyyy-MM-dd HH:mm:ss', 'PST');
        System.debug('dt-' + dt);
        System.debug('dtPST-' + dtPST);
        return dtPST;
    }
    
    @AuraEnabled
    public static String initialize(String policyType, String quoteId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            
            String userType = UserInfo.getUserType();
            responseMap.put('loginUser', !userType.equalsIgnoreCase('Guest'));
            if (userType != null && (!userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                responseMap.put('email', UserInfo.getUserEmail());
                
                List<User> loginUserList = new List<User>();
                loginUserList = getloginUser();
                if (loginUserList != null && !loginUserList.isEmpty()) {
                    responseMap.put('driverAsUser', loginUserList[0]);
                }
                
                if (quoteId != null && quoteId != '') {
                    Quote__c quoteRecord = getQuoteWithAllFields(quoteId);
                    if (quoteRecord != null) {
                        responseMap.put('quoteRecord', quoteRecord);
                    }
                    
                    List<Towed_Unit__c> towed_UnitList = new List<Towed_Unit__c>();
                    towed_UnitList = getTowedUnit(quoteId);
                    if (towed_UnitList != null && !towed_UnitList.isEmpty() && quoteRecord != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' ) {
                        responseMap.put('towedunitRecord', towed_UnitList[0]);
                    }else if( towed_UnitList != null && !towed_UnitList.isEmpty() ){
                        responseMap.put('transporates', towed_UnitList);
                    }
                    
                    List<Vehicle__c> vehicleList = new List<Vehicle__c>();
                    vehicleList = getVehicle(quoteId);
                    if (vehicleList != null && !vehicleList.isEmpty()) {
                        responseMap.put('vehicleRecord', vehicleList[0]);
                    }
                    
                    List<Driver__c> driverList = new List<Driver__c>();
                    driverList = getDriver(quoteId);
                    if (driverList != null && !driverList.isEmpty()) {
                        responseMap.put('driverRecord', driverList[0]);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('--exception---' + e.getMessage());
            CustomErrorExceptionHandlerException.LogException(e);
            //throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(responseMap);
    }
    
    @AuraEnabled
    public static List<User> getloginUser() {
        return [
            SELECT Id, Email, FirstName, LastName, Phone, ContactId, Contact.Email, Contact.Birthdate, Contact.Date_of_Birth__c, Contact.AccountId,
            Contact.MailingState, Contact.MailingCity, Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCountry
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }
    
    public static List<Lead> getleads(Set<String> recordIds) {
        return [SELECT Id, Name, LastName, Email, FirstName, IsConverted, ConvertedContactId, ConvertedAccountId, Company FROM Lead WHERE Id IN:recordIds];
    }
    
    @AuraEnabled
    public static Quote__c getQuoteWithAllFields(String quoteId) {
        List<Quote__c> quotes = new List<Quote__c>();
        if (String.isNotBlank(quoteId)) {
            String query = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
            query += ' WHERE Id=\'' + quoteId + '\'';
            quotes = Database.query(query);
        }
        return !quotes.isEmpty() ? quotes[0] : null;
    }
    
    @AuraEnabled
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
            System.debug('--query--'+query);
            return Database.query(query);
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Vehicle__c> getVehicle(String quoteId) {
        list<Quote_Vehicle__c> quoteVechiles = new list<Quote_Vehicle__c>();
        quoteVechiles = [select Vehicle__c from Quote_Vehicle__c where Quote_c__c =:quoteId ];
        
        if( quoteVechiles != null && !quoteVechiles.isEmpty() ){
            set<String> vechileIds = new set<String>();
            for(Quote_Vehicle__c qvl : quoteVechiles){
                vechileIds.add( qvl.Vehicle__c );
            }
            
            String query = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
            query += ' where Id IN: vechileIds';
            return Database.query(query);
        }
        
        return null;
    }
    
    @AuraEnabled
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
        return null;
    }
    
    public static String getQueryWithAllFields(String objectName) {
        return 'SELECT ' + String.join(getAllFields(objectName), ', ') + ' FROM ' + objectName;
    }
    
    public static List<Contact> getContact(String quoteId) {
        list<Quote_Driver__c> quotedrivers = new list<Quote_Driver__c>();
        quotedrivers = [select Contact__c, Driver__r.Driver_Type__c from Quote_Driver__c where Quote_c__c =: quoteId];
        
        if (quotedrivers != null && !quotedrivers.isEmpty()) {
            set<String> conIds = new Set<String>();
            for (Quote_Driver__c qdr : quotedrivers) {
                if (qdr.Driver__r.Driver_Type__c == 'Owner' || qdr.Driver__r.Driver_Type__c == 'Owner & Driver') {
                    conIds.add(qdr.Contact__c);
                }
            }
            String query = getQueryWithAllFields(Contact.getSObjectType().getDescribe().getName());
            query += ' Where Id In: conIds';
            return Database.query(query);
        }
        return null;
    }
    
    private static Set<String> removeFields = new Set<String>{
        'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastvieweddate',
        'lastreferenceddate'
    };
    
    private static List<String> getAllFields(String objectName) {
        System.debug('--objectName--' + objectName);
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
    public static Map<String, Object> getQuoteDetails(String quoteIds) {
        try {
            System.debug('--quoteIds--'+quoteIds);
            List<String> quoteIdlist = new List<String>();
            quoteIdlist = (List<String>) JSON.deserialize(quoteIds, List<String>.class);
            
            Set<String> vehicleIdset = new Set<String>();
            Set<String> driverIdset = new Set<String>();
            
            Map<String, Boolean> driverAgeUnder21 = new Map<String, Boolean>();
            
            map<String,Quote_Vehicle__c> quoteVehicleMap = new map<String,Quote_Vehicle__c>();
            for (Quote_Vehicle__c vehicle : [SELECT Id, Quote_c__c, Quote_c__r.Driver_Age__c, Vehicle__c FROM Quote_Vehicle__c WHERE Quote_c__c IN:quoteIdlist order by createddate desc]) {
                vehicleIdset.add(vehicle.Vehicle__c);
                if (vehicle.Quote_c__r.Driver_Age__c < 21) {
                    driverAgeUnder21.put(vehicle.Vehicle__c, true);
                } else {
                    driverAgeUnder21.put(vehicle.Vehicle__c, false);
                }
                
                quoteVehicleMap.put(vehicle.Id, vehicle);
            }
            
            /*for( Quote_Driver__c driver : [select id, Quote_c__c, Driver__c from Quote_Driver__c where Quote_c__c IN: quoteIdlist ]){
                driverIdset.add( driver.Driver__c );
            }*/
            
            Map<String, Object> responseMap = new Map<String, Object>();
            List<Vehicle__c> vehicles = new List<Vehicle__c>();
            
            vehicles = [
                SELECT Id, Company_Address__c, Company_Name__c, Company_Phone__c, Domestic_Insurance_Name__c, Domestic_Insurance_Phone__c, Domestic_Insurance_Policy__c, ID__c, Is_Lienholder__c, Quote_c__r.Driver_Age__c,
                Is_the_vehicle_registered_to_a_business__c, Is_the_vehicle_used_for_business_purpose__c, Lead__c, Lienholder_City__c, Lienholder_Country__c, Lienholder_name__c, Lienholder_Phone__c,
                Lienholder_Postal_Code__c, Lienholder_State__c, Lienholder_Street__c, Lienholder_Street_2__c, Make__c, Model__c, OwnerId, owner_id__c, Registered_Country__c, Registered_Plate__c,
                Registered_State__c, Rental__c, Rental_Tbd__c, Salvage_Vehicle__c, Site__c, SystemModstamp, Tax_ID__c, Type__c, Updated_At__c, User_ID__c, Account_Vehicle__c, Value__c, Name,
                Vehicle_Owner_Address__c, Vehicle_Owner_Driver_License__c, Vehicle_Owner_Driver_License_State__c, Vehicle_Owner_Driver_Licenses_Expiration__c, Vehicle_Owner_Name__c, Vehicle_Owner_Phone__c,
                Vehicle_Type__c, Vin__c, Vin_Counter__c, Year__c
                FROM Vehicle__c
                WHERE Id IN:vehicleIdset
            ];
            
            for (Vehicle__c vehicle : vehicles) {
                if (vehicle.Quote_c__r.Driver_Age__c < 21) {
                    driverAgeUnder21.put(vehicle.Id, true);
                } else {
                    driverAgeUnder21.put(vehicle.Id, false);
                }
            }
            
            
            List<Driver__c> drivers = new List<Driver__c>();
            drivers = [
                SELECT Id, Address__c, Address_Line_2__c, Age_Range__c, City__c, Country__c, default__c, IsDeleted, Dob__c, Name, Driver_Type__c, Email__c, First_Name__c, Id__c, Last_Name__c,
                License_Country__c, License_Expire__c, license_number__c, LN_With_Country__c, license_number_counter__c, License_state__c, OwnerId, Phone__c, Postal_Code__c, Site__c, State_Province__c, Account_Driver__c,
                User_id__c, Vehicle_Driver__c
                FROM Driver__c
                WHERE Id IN ( Select Driver__c from Quote_Driver__c where Quote_c__c IN: quoteIdlist ) order by Email__c desc NULLS LAST
            ];
            System.debug('drivers : ' + drivers);
            
            System.debug('--quoteIdlist--'+quoteIdlist);
            list<Quote_Towed_Unit__c> quoteTowedUnits = new list<Quote_Towed_Unit__c>();
            quoteTowedUnits = [select Id, Towed_Unit__c, Quote_Vehicle__c from Quote_Towed_Unit__c where Quote_c__c IN:quoteIdlist];
            System.debug('--quoteTowedUnits--'+quoteTowedUnits);
            
            String tempvehicleId;
            if( quoteTowedUnits != null && !quoteTowedUnits.isEmpty()){
                set<String> towedIds = new set<String>();
                for(Quote_Towed_Unit__c qtu : quoteTowedUnits){
                    towedIds.add( qtu.Towed_Unit__c );
                    if( qtu.Quote_Vehicle__c != null && quoteVehicleMap != null && quoteVehicleMap.containskey(qtu.Quote_Vehicle__c)){
                        responseMap.put('vehicleid', quoteVehicleMap.get(qtu.Quote_Vehicle__c).Vehicle__c);
                        tempvehicleId = quoteVehicleMap.get(qtu.Quote_Vehicle__c).Vehicle__c;
                    }
                }
                System.debug('--towedIds--'+towedIds);
                
                String query = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
                query += ' where Id IN: towedIds ';
                System.debug('--query--'+query);
                list<Towed_Unit__c> Towed_Units = new list<Towed_Unit__c>();
                Towed_Units =  Database.query(query);
                
                responseMap.put('towed_Units', Towed_Units);
            }
            
            List<Vehicle__c> Tempvehicles = new List<Vehicle__c>();
            for (Vehicle__c vehicle : vehicles) {
                if( tempvehicleId != null && vehicle.Id == tempvehicleId){
                    if( !Tempvehicles.isEmpty()){
                        Tempvehicles.add(0,vehicle);
                    }else{
                        Tempvehicles.add(vehicle);
                    }
                }else{
                    Tempvehicles.add(vehicle);
                }
            }
            responseMap.put('vehicles', Tempvehicles);
            
            responseMap.put('drivers', drivers);
            responseMap.put('driverAgeUnder21', driverAgeUnder21);
            
            
            return responseMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static map<String,object> getDataFromDataTable(Quote__c quoteObject, String liability) {
        
        map<String,object> returnMap = new map<String,object>();
        try {
            
            List<Rate_Table__c> rateTables = new List<Rate_Table__c>();
            Integer days = 0 ;
            if (quoteObject != null
            && quoteObject.Start_Date_for_Coverage__c != null && quoteObject.End_Date_for_Coverage__c != null) {
                
                days = quoteObject.Start_Date_for_Coverage__c.daysBetween(quoteObject.End_Date_for_Coverage__c);
            }
            
            if(liability != null && liability == '50000'){
                liability = '50,000';
            }else if(liability != null && liability == '70000'){
                liability = '70,000';
            }else if(liability != null && liability == '100000'){
                liability = '100,000';
            }else if(liability != null && liability == '150000'){
                liability = '150,000';
            }else if(liability != null && liability == '200000'){
                liability = '200,000';
            }else if(liability != null && liability == '300000'){
                liability = '300,000';
            }else if(liability != null && liability == '500000'){
                liability = '500,000';
            }
            
            
            String term = null;
            if (days != null && days <= 30) {
                term = 'Daily';
            } else if (days != null && days > 30 && days <= 90) {
                term = '90 Days';
            } else if (days != null && days > 90 && days <= 180) {
                term = 'Semi-Annual';
            } else if (days != null && days > 180) {
                term = 'Annual';
            }
            
            String rateQuery = 'select id, Total_Premium__c, Net_Premium__c, Broker_Policy_Fee__c, Package__c, Type__c, Days__c, Trailering_Surcharge__c, Term__c,';
            rateQuery += ' IVA_Mex_Tax__c, Underwriter__c, Age_of_Vehicle_Surcharge_25_years_old__c, Age_of_Vehicle_Surcharge__c, Age_of_Operator_Surcharge__c ';
            rateQuery += ' from Rate_Table__c ';
            
            if (quoteObject.Policy_Type_picklist__c == 'Northbound') {
                rateQuery += ' where Risk_3_Third_Party_Liability_Insured_Sum__c = \'' + liability + '\'';
                if (days != null && days <= 30) {
                    rateQuery += ' and Days__c = ' + days;
                } else if (days != null && days > 30) {
                    rateQuery += ' and Term__c = \'' + term + '\'';
                }
                rateQuery += ' and Underwriter__c = \'' + quoteObject.Underwriter__c + '\' and Direction__c = \'' + quoteObject.Policy_Type_picklist__c + '\'';
            } else if (quoteObject.Policy_Type_picklist__c == 'Driver License') {
                rateQuery += ' where Underwriter__c = \'' + quoteObject.Underwriter__c + '\'';
                rateQuery += ' AND Type__c = \'' + quoteObject.Policy_Type_picklist__c + '\'';
                rateQuery += ' AND Risk_3_Third_Party_Liability_Insured_Sum__c = \'' + liability + '\'';
            }
            /*rateTables = [select id, Total_Premium__c, Net_Premium__c, Broker_Policy_Fee__c, Package__c, Type__c, Days__c,
IVA_Mex_Tax__c, Underwriter__c, Age_of_Vehicle_Surcharge_25_years_old__c, Age_of_Vehicle_Surcharge__c, Age_of_Operator_Surcharge__c
from Rate_Table__c where (Days__c =: days or Term__c =:term) and Risk_3_Third_Party_Liability_Insured_Sum__c =: liability
and Underwriter__c =: quoteObject.Underwriter__c and Direction__c =: quoteObject.Policy_Type_picklist__c]; */
            
            
            System.debug('rateQuery--->' + rateQuery);
            rateTables = Database.query(rateQuery);
            
            returnMap.put('days', days);
            returnMap.put('success', true);
            System.debug('**rateTables***' + rateTables);
            if (rateTables != null && !rateTables.isEmpty()) {
                //return rateTables[0];
                returnMap.put('rateData', rateTables);
            }
            return returnMap;
        } catch (Exception e) {
            System.debug('***Exception****' + e.getMessage());
            //throw new AuraHandledException(e.getMessage());
            returnMap.put('success', false);
            returnMap.put('message', e.getMessage());
            return returnMap;
        }
        
    }
    
    
    @AuraEnabled
    public static Map<String, Object> updateVehicleAction(Vehicle__c vehicleObject) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            QuickQuotationCtrl.vechileTriggerAction = false; // to stop trigger
            
            upsert vehicleObject Id;
            System.debug('--vehicleObject--' + vehicleObject);
            if (UserInfo.getUserType().equalsIgnoreCase('Guest') && vehicleObject.Company_Name__c != null) {
                List<Vehicle__c> vehicleList = [SELECT Id, Lead__c, Company_Name__c FROM Vehicle__c WHERE Id = :vehicleObject.Id];
                if (vehicleList != null && !vehicleList.isEmpty() && vehicleList[0].Lead__c != null) {
                    List<Lead> ldObjlist = getleads(new Set<String>{
                        vehicleList[0].Lead__c
                    }); //[select id, Name, LastName, Email, FirstName, isconverted, convertedContactId, convertedAccountId, company from Lead where Id =: vehicleObject.Lead__c LIMIT 1];
                    System.debug('--ldObj--' + ldObjlist);
                    if (ldObjlist != null && !ldObjlist.isEmpty() && !ldObjlist[0].IsConverted) {
                        ldObjlist[0].Company = vehicleObject.Company_Name__c;
                        update ldObjlist;
                    }
                }
                
            }
            responseMap.put('success', true);
            responseMap.put('vehicleId', vehicleObject.Id);
            
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> updateDriverAction(Driver__c driverObject) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            System.debug('*****driverObject***' + driverObject);
            driverObject.Name = driverObject.First_Name__c + ' ' + driverObject.Last_Name__c;
            upsert driverObject Id;
            
            responseMap.put('success', true);
            
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> deleteDriverAction(Driver__c driverObject, String quoteId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            list<Quote_Driver__c> qDrvs = new list<Quote_Driver__c> ();
            qDrvs = [select Id from Quote_Driver__c where Driver__c =: driverObject.Id and Quote_c__c =: quoteId];
            if( qDrvs != null && !qDrvs.isEmpty()) {
                delete qDrvs;
            }
            responseMap.put('success', true);
            
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> createVehicleNorthAction(Vehicle__c vehicleObject, String quoteId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
            String name = '';
            if (vehicleObject.Model__c != null) {
                name += vehicleObject.Model__c;
            }
            if (vehicleObject.Make__c != null) {
                name += (name != '' ? ', ' : '') + vehicleObject.Make__c;
            }
            if (vehicleObject.Year__c != null) {
                name += (name != '' ? ', ' : '') + vehicleObject.Year__c;
            }
            if (name.trim() == '') {
                name = 'NorthBound New Vehicle';
            }
            Quote__c quoteRecord = getQuoteWithAllFields(quoteId);
            
            List<Vehicle__c> vehicles = new List<Vehicle__c>();
            if (vehicleObject.Vin__c != null) {
                vehicles = [SELECT Id, Vin__c FROM Vehicle__c WHERE Vin__c != NULL AND Vin__c = :vehicleObject.Vin__c];
            }
            String vehicleId = null;
            if (vehicles != null && !vehicles.isEmpty()) {
                //vehicleObject = vehicles[0];
                vehicleId = vehicleObject.Id;
                vehicleObject.Id = vehicleId;
                upsert vehicleObject Id;
            } else {
                vehicleObject.Name = name;
                
                if (quoteRecord != null && vehicleObject.Contact__c == null && vehicleObject.Account_Vehicle__c == null ) {
                    /*vehicleObject.Contact__c = quoteRecord.Contact__c;
                    
                    if (UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                        vehicleObject.Lead__c = quoteRecord.Lead__c;
                    }
                    vehicleObject.Account_Vehicle__c = quoteRecord.Account__c;*/
                }
                
                upsert vehicleObject Id;
                vehicleId = vehicleObject.Id;
            }
            
            if (vehicleId != null && vehicleId != null && quoteId != null) {
                List<Quote_Vehicle__c> quoteVehicleList = new List<Quote_Vehicle__c>();
                quoteVehicleList = [SELECT Id FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteId AND Vehicle__c = :vehicleId];
                
                if (quoteVehicleList == null || quoteVehicleList.isEmpty()) {
                    Quote_Vehicle__c quoteVehicle = new Quote_Vehicle__c();
                    quoteVehicle.Quote_c__c = quoteId;
                    quoteVehicle.Vehicle__c = vehicleId;
                    if (quoteVehicle.Contact__c == null && quoteVehicle.Account__c == null) {
                        if (quoteRecord != null) {
                            quoteVehicle.Contact__c = quoteRecord.Contact__c;
                            
                            if (UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                                quoteVehicle.Lead__c = quoteRecord.Lead__c;
                            }
                            quoteVehicle.Account__c = quoteRecord.Account__c;
                        }
                    }
                    insert quoteVehicle;
                }
                
            }
            
            responseMap.put('success', true);
            responseMap.put('vehicleId', vehicleId);
            
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        
        return responseMap;
    }
    
    @AuraEnabled
    public static List<Driver__c> getRelatedDrivers(String quoteId) {
        System.debug('--quoteId---'+quoteId);
        List<Driver__c> drivers = new List<Driver__c>();
        if (String.isNotBlank(quoteId)) {
            list<Quote_Driver__c> qDrivers = new list<Quote_Driver__c>();
            qDrivers = [Select Driver__c from Quote_Driver__c where Quote_c__c =: quoteId];
            System.debug('--qDrivers--'+qDrivers);
            if( qDrivers != null && !qDrivers.isEmpty() ){
                set<String> driverIds = new set<String>();
                for(Quote_Driver__c QD : qDrivers ){
                    driverIds.add( QD.Driver__c );
                }
                
                drivers = [
                    SELECT Id, First_Name__c, Last_Name__c, Driver_Type__c, Email__c, Phone__c, Dob__c,
                    License_Country__c, License_state__c, license_number__c, LN_With_Country__c, Address__c, Address_Line_2__c,
                    City__c, Country__c, Postal_Code__c, State_Province__c, (select Id, Primary_insured__c from Quote_Drivers__r where Quote_c__c =: quoteId limit 1)
                    FROM Driver__c
                    WHERE Id IN: driverIds
                ];
            }
        }
        return drivers;
    }
    
    @AuraEnabled
    public static Map<String, Object> createDriverAction(Driver__c driverRecord, String quoteId, Boolean isOwner, String watercraftId, Boolean Primary_insured) {
        
        QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
        
        Map<String, Object> responseMap = new Map<String, Object>();
        //quoteId = 'a0S2i000001a9L8';
        Database.UpsertResult upsertDriverRecord;
        String errorMessage = '';
        System.debug('---quoteId---'+quoteId);
        System.debug('---driverRecord---'+driverRecord);
        
        //added at 9 nov 2021 all to create duplicate driver
        /*List<Driver__c> drivers = [
        SELECT Id, First_Name__c, Last_Name__c, Driver_Type__c, Email__c, Phone__c, Dob__c,
        License_Country__c, License_state__c, license_number__c, Address__c, Address_Line_2__c,
        City__c, Country__c, Postal_Code__c, State_Province__c
        FROM Driver__c
        WHERE license_number__c = :driverRecord.license_number__c
        ];*/
        
        
        List<Quote__c> quoteRecords = [
            SELECT Id, Vehicle__c, Lead__c, Account__c, Contact__c
            FROM Quote__c
            WHERE Id = :quoteId
            LIMIT 1
        ];
        
        list<Vehicle__c> vehicleRecords = new list<Vehicle__c>();
        vehicleRecords = [select Id, Vehicle_Owner_Name__c, Vehicle_Owner_Phone__c, 
                        Vehicle_Owner_Address__c, Vehicle_Owner_Driver_License__c, Vehicle_Owner_Driver_License_State__c,
                        Vehicle_Owner_City__c, Vehicle_Owner_State__c, Vehicle_Owner_Country__c, Vehicle_Owner_Postal_Code__c
                        from Vehicle__c where Id IN ( Select Vehicle__c from Quote_Vehicle__c where Quote_c__c =:quoteId ) limit 1 ];
        
        if( vehicleRecords != null && !vehicleRecords.isEmpty() && driverRecord.Driver_Type__c != null
        && ( driverRecord.Driver_Type__c == 'Owner' || driverRecord.Driver_Type__c == 'Owner & Driver')  ){
            try{
                vehicleRecords[0].Vehicle_Owner_Name__c = driverRecord.First_Name__c + ' ' + driverRecord.Last_Name__c;
                vehicleRecords[0].Vehicle_Owner_Phone__c = driverRecord.Phone__c;
                vehicleRecords[0].Vehicle_Owner_Address__c = driverRecord.Address__c;
                vehicleRecords[0].Vehicle_Owner_City__c = driverRecord.City__c;
                vehicleRecords[0].Vehicle_Owner_State__c = driverRecord.State_Province__c;
                vehicleRecords[0].Vehicle_Owner_Postal_Code__c = driverRecord.Postal_Code__c;
                vehicleRecords[0].Vehicle_Owner_Country__c = driverRecord.Country__c;
                vehicleRecords[0].Vehicle_Owner_Driver_License__c = driverRecord.license_number__c;
                vehicleRecords[0].Vehicle_Owner_Driver_License_State__c = driverRecord.License_state__c;
                
                update vehicleRecords;
            }catch (Exception  e) {
                System.debug('e.getMessage(): ' + e.getMessage());
                System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            }
        }
        
        /*if (!drivers.isEmpty()) {
            driverRecord.Id = drivers[0].Id;
            responseMap.put('savedDriverRecord', driverRecord);
        }else*/
        
        if (String.isNotBlank(quoteId) && !quoteRecords.isEmpty()) {
            Quote__c quoteRecord = quoteRecords[0];
            
            driverRecord.Name = driverRecord.First_Name__c + ' ' + driverRecord.Last_Name__c;
            
            if( UserInfo.getUserType().equalsIgnoreCase('Guest') && driverRecord.Lead__c == null ){
                driverRecord.Lead__c = quoteRecord.Lead__c;
            }
            
            if( driverRecord.Account_Driver__c == null ){
                driverRecord.Account_Driver__c = quoteRecord.Account__c;
            }
            
            if( driverRecord.Contact__c == null ){
                driverRecord.Contact__c = quoteRecord.Contact__c;
            }
            
            upsertDriverRecord = Database.upsert(driverRecord, false);
            if (upsertDriverRecord.isSuccess()) {
                responseMap.put('savedDriverRecord', driverRecord);
                if (isOwner) {
                    Lead leadRecord = updateRelatedLead(driverRecord);
                    responseMap.put('leadUpdated', leadRecord);
                }
            } else {
                errorMessage += upsertDriverRecord != null && !upsertDriverRecord.getErrors().isEmpty() ?
                    'upsertDriverRecord : ' + upsertDriverRecord.getErrors()[0].getMessage() + '. ' : '';
            }
        }
        
        if( driverRecord.Id != null  && !quoteRecords.isEmpty() ){
            Quote__c quoteRecord = quoteRecords[0];
            list<Quote_Driver__c> qDrivers = new list<Quote_Driver__c>();
            qDrivers = [select Id from Quote_Driver__c where Driver__c=:  driverRecord.Id and Quote_c__c =: quoteRecord.Id limit 1 ];
            if( qDrivers == null || qDrivers.isEmpty()){
                Quote_Driver__c qDr = new Quote_Driver__c();
                qDr.Driver__c = driverRecord.Id;
                qDr.Quote_c__c = quoteRecord.Id;
                qDr.Vehicle_Driver__c = quoteRecord.Vehicle__c;
                qDr.Lead__c = quoteRecord.Lead__c;
                qDr.Account_Driver__c = quoteRecord.Account__c;
                qDr.Contact__c = quoteRecord.Contact__c;
                qDr.Primary_insured__c = Primary_insured;
                qDr.Watercraft__c = String.isNotBlank(watercraftId) ? watercraftId : null;
                
                Database.insert(qDr, false);
            }else if( !qDrivers.isEmpty() ){
                qDrivers[0].Primary_insured__c = Primary_insured;
                Database.update(qDrivers, false);
            }
        }
        
        responseMap.put('success', String.isBlank(errorMessage));
        responseMap.put('message', errorMessage);
        return responseMap;
    }
    
    private static Lead updateRelatedLead(Driver__c driverRecord) {
        List<Lead> leadRecords = [
            SELECT Id, Name, LastName, Email, FirstName, IsConverted, ConvertedContactId,
            ConvertedAccountId, Company
            FROM Lead
            WHERE Id = :driverRecord.Lead__c
            LIMIT 1
        ];
        Lead leadForUpdate;
        if (!leadRecords.isEmpty() && !leadRecords[0].IsConverted) {
            leadForUpdate = leadRecords[0];
            leadForUpdate.FirstName = driverRecord.First_Name__c;
            leadForUpdate.LastName = driverRecord.Last_Name__c;
            leadForUpdate.Phone = driverRecord.Phone__c;
            leadForUpdate.Email = driverRecord.Email__c;
            leadForUpdate.Date_of_Birth__c = driverRecord.Dob__c;
            leadForUpdate.Street = driverRecord.Address__c + (String.isNotBlank(driverRecord.Address_Line_2__c) ? ' ' + driverRecord.Address_Line_2__c : '');
            leadForUpdate.City = driverRecord.City__c;
            leadForUpdate.State = driverRecord.State_Province__c;
            leadForUpdate.PostalCode = driverRecord.Postal_Code__c;
            leadForUpdate.Country = driverRecord.Country__c;
            leadForUpdate.Company = driverRecord.First_Name__c + ' ' + driverRecord.Last_Name__c;
            /*    if (String.isBlank(leadRecords[0].Company) ||
            (String.isNotBlank(leadRecords[0].Company) && String.valueOf(leadRecords[0].Company).equalsIgnoreCase('NorthBound Insurance'))) {
                leadForUpdate.Company = leadForUpdate.FirstName + ' ' + leadForUpdate.LastName;
            } */
            
            Database.upsert(leadForUpdate);
        }
        return leadForUpdate;
    }
    
    @AuraEnabled
    public static Map<String, Object> checkalreadyExistUserAction(String emailAdder) {
        Map<String, Object> returnMap = new map<String,Object>();
        list<User> userList = new list<User>();
        userList = [select Id, UserName, Email from User where Email =: emailAdder and Isactive = true limit 1];
        returnMap.put('isExistUser', false);
        if( userList != null && !userList.isEmpty() ){
            returnMap.put('isExistUser', true);
        }
        return returnMap;
    }
    
    @AuraEnabled
    public static String checkUserLicenceSendMail(){
        
        AggregateResult UserLicence = [SELECT Count(Id) From User Where Profile.UserLicense.Name = 'Customer Community Plus login' AND IsActive=True];
        
        Integer NumberOfUserLicence = Integer.valueOf(UserLicence.get('expr0')) ;
        
        UserLicense numberOfTotalLicence = [SELECT TotalLicenses FROM UserLicense where name = 'Customer Community Plus Login'];
        
        system.debug( numberOfTotalLicence.TotalLicenses - NumberOfUserLicence);
        Integer LeftNumberOfUserLicence =( numberOfTotalLicence.TotalLicenses - NumberOfUserLicence);
        if(LeftNumberOfUserLicence < 20 || Test.isRunningTest()){
            Profile profileData = [SELECT Name, Id FROM Profile where Name = 'System Administrator'];
            List<User> userData = [SELECT Id, Username, LastName, FirstName, Name, Email, IsActive FROM User where ProfileId =: profileData.Id];
            
            List<String> userEmails = new List<String>();
            for(user eachUser : userData){
                userEmails.add(eachUser.Email);
            }
            
            user userId = [SELECT Id, Name FROM User where UserType  = 'Standard' And Name = 'Mexinsurance'];
            
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            
            String wideOrgEmail = System.Label.RemainderEmail;
            OrgWideEmailAddress[] senderEmail = [select Id from OrgWideEmailAddress where Address =: wideOrgEmail];
            semail.setOrgWideEmailAddressId(senderEmail.get(0).Id);
            
            EmailTemplate emailTemplate = [SELECT Id, Subject,Description, HtmlValue,Name, Body FROM EmailTemplate WHERE Name = 'UserLicense SendEmail'];
            semail.setTemplateId(emailTemplate.Id);
            //semail.setToAddresses(userEmails);
            semail.setToAddresses(
                userEmails
                );
            semail.setTargetObjectId(userId.Id);
            semail.setUseSignature(false);
            semail.setBccSender(false);
            semail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                semail
            });
            
            if(LeftNumberOfUserLicence <= 0 ){
                throw new UserLicenseExceedException('Exceed User License contact to System Administrator');
                
            }
            
        }else{
            system.debug('user of license are more than 20');
        }
        
        return 'sentmail';
    }
    @AuraEnabled
    public static Map<String, Object>  updateLeadRecord(String leadId, String firstName, String lastName, String emailAdder, String phoneNumber, String quoteId, String policyType ){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Lead ldObj = [SELECT Id, Name,Insurance_Type__c, LastName, Email, FirstName, Phone, IsConverted, ConvertedContactId, ConvertedAccountId, Source__c FROM Lead WHERE Id = :leadId LIMIT 1];
            if (firstName != null || lastName != null) {
                if (firstName != null && firstName != '') {
                    ldObj.FirstName = firstName;
                }
                if (lastName != null && lastName != '') {
                    ldObj.LastName = lastName;
                }
                if (emailAdder != null && emailAdder != '') {
                    ldObj.Email = emailAdder;
                }
                if (phoneNumber != null && phoneNumber != '') {
                    ldObj.Phone = phoneNumber;
                }
                if (policyType != null && policyType != '') {
                    ldObj.Insurance_Type__c = policyType;
                }
                ldObj.Source__c = 'Portal';
                
                update ldObj;
                
                responseMap.put('success', true);
                responseMap.put('Lead',ldObj);
                responseMap.put('message', 'Lead update successfully.');
            }
            
        } catch (Exception e) {
            responseMap.put('message', e.getMessage() + ' at line number ' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> saveQuoteAction(String leadId, String firstName, String lastName,
    String emailAdder, String phoneNumber, String quoteId) {
        
        Map<String, Object> responseMap = new Map<String, Object>();
        String userType = UserInfo.getUserType();
        
        if (userType != null && userType.equalsIgnoreCase('Guest')) {
            responseMap = saveQuoteActionByAdmin(leadId, firstName, lastName, emailAdder, phoneNumber,  quoteId);
        } else {
            List<User> userList = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            
            if (userList != null && !userList.isEmpty()) {
                responseMap.put('success', true);
                responseMap.put('contactId', userList[0].ContactId);
                
                if (userList[0].Contact.AccountId != null) {
                    responseMap.put('accountId', userList[0].Contact.AccountId);
                }
                responseMap.put('message', 'Quote saved successfully.');
            }
        }
        system.debug('responseMap---------->719  '+ responseMap);
        return responseMap;
    }
    
    public static void updateQuoteContact(String quoteId, String accountId, String contactId) {
        try {
            Quote__c quote = new Quote__c();
            quote.Id = quoteId;
            quote.Contact__c = contactId;
            quote.Account__c = accountId;
            update quote;
        } catch (Exception e) {
            System.debug('----exception---' + e.getMessage());
        }
    }
    
    public static void updateTowedunitContact(String quoteId, String accountId, String contactId) {
        try {
            List<Towed_Unit__c> towed_UnitList = new List<Towed_Unit__c>();
            towed_UnitList = getTowedUnit(quoteId);
            if (towed_UnitList != null && !towed_UnitList.isEmpty() && towed_UnitList[0].Contact__c == null) {
                towed_UnitList[0].Contact__c = contactId;
                towed_UnitList[0].Account__c = accountId;
                
                update towed_UnitList;
            }
        } catch (Exception e) {
            System.debug('----exception---' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveQuoteActionByAdmin(String leadId, String firstName, String lastName,
                                                             String emailAdder, String phoneNumber, String quoteId) {
        
        System.debug('--leadId---' + leadId);
        Map<String, Object> responseMap = new Map<String, Object>();
        Profile portalProfile; 
        try {
            // Account account = [select id, Name from Account where IsPartner = true LIMIT 1];
            Lead ldObj = [SELECT Id, Name, LastName, Email, FirstName, Phone, IsConverted, ConvertedContactId, ConvertedAccountId, Source__c, Agency__c FROM Lead WHERE Id = :leadId LIMIT 1];

            
            
            if (ldObj != null && !ldObj.IsConverted) {
                Database.LeadConvert lc = new Database.LeadConvert();
                
                lc.setLeadId(leadId);
                lc.setDoNotCreateOpportunity(true);
                
                
                /*
                if (firstName != null || lastName != null) {
                    if (firstName != null && firstName != '') {
                        ldObj.FirstName = firstName;
                    }
                    if (lastName != null && lastName != '') {
                        ldObj.LastName = lastName;
                    }
                    if (emailAdder != null && emailAdder != '') {
                        ldObj.Email = emailAdder;
                    }
                    if (phoneNumber != null && phoneNumber != '') {
                        ldObj.Phone = phoneNumber;
                    }
                    ldObj.Source__c = 'Portal';
                    
                    update ldObj;
                } */
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                if (lcr.isSuccess() && lcr.getContactId() != null) {
                    setupEmailParams(lcr.getContactId());  
                    portalProfile = [SELECT Id FROM Profile WHERE Name = :userCommunityProfileName LIMIT 1];
                    User user1 = new User(
                        Username = ldObj.Email,
                        LastName = ldObj.LastName,
                        Email = ldObj.Email,
                        Phone = ldObj.Phone,
                        Alias = ldObj.FirstName.charAt(0)+ldObj.LastName.substring(0,5),
                        ContactId = lcr.getContactId(),
                        ProfileId = portalProfile.Id,
                        EmailEncodingKey = 'UTF-8',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        LocaleSidKey = 'en_US',
                        LanguageLocaleKey = 'en_US'
                    );
                    
                    if( ldObj.FirstName != null ){
                        user1.FirstName = ldObj.FirstName;
                    }
                    
                    Database.insert(user1);
                    String userId = user1.Id;
                    
                    if (userId != null) {
                        //***********update quote contact */
                        updateQuoteContact(quoteId, lcr.getAccountId(), lcr.getContactId());
                        updateTowedunitContact(quoteId, lcr.getAccountId(), lcr.getContactId());
                        
                        responseMap.put('success', true);
                        responseMap.put('contactId', lcr.getContactId());
                        responseMap.put('accountId', lcr.getAccountId());
                        responseMap.put('message', 'Quote saved successfully.');
                        
                        Account AccObj = new Account();
                        AccObj.Name = (ldObj.FirstName != null ? ldObj.FirstName + ' ' : '') + (ldObj.LastName != null ? ldObj.LastName : '');
                        AccObj.Id = lcr.getAccountId();
                        AccObj.Email__c = ldObj.Email;
                        update AccObj;
                        
                    }
                    
                }
            } else if (ldObj.ConvertedContactId != null) {
                List<User> userList = new List<User>();
                userList = [SELECT Id, ContactId FROM User WHERE ContactId = :ldObj.ConvertedContactId LIMIT 1];
                setupEmailParams(ldObj.ConvertedContactId);  
                portalProfile = [SELECT Id FROM Profile WHERE Name = :userCommunityProfileName LIMIT 1];
                String userId = null;
                User user1 = new User();
                if (userList == null || userList.isEmpty()) {
                    user1 = new User(
                        Username = ldObj.Email,
                        LastName = ldObj.LastName,
                        Email = ldObj.Email,
                        Phone = ldObj.Phone,
                        Alias = 'test123',
                        ContactId = ldObj.ConvertedContactId,
                        ProfileId = portalProfile.Id,
                        EmailEncodingKey = 'UTF-8',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        LocaleSidKey = 'en_US',
                        LanguageLocaleKey = 'en_US'
                        );
                    
                    if( ldObj.FirstName != null ){
                        user1.FirstName = ldObj.FirstName;
                    }
                    
                    Database.insert(user1);
                    userId = user1.Id;
                    
                } else if (!userList.isEmpty()) {
                    userId = userList[0].Id;
                }
                
                if (userId != null) {
                    
                    //***********update quote contact */
                    updateQuoteContact(quoteId, ldObj.ConvertedAccountId, ldObj.ConvertedContactId);
                    updateTowedunitContact(quoteId, ldObj.ConvertedAccountId, ldObj.ConvertedContactId);
                    
                    responseMap.put('success', true);
                    responseMap.put('accountId', ldObj.ConvertedAccountId);
                    responseMap.put('contactId', ldObj.ConvertedContactId);
                    responseMap.put('message', 'Quote saved successfully.');
                }
            }
        } catch (Exception e) {
            System.debug('**Exception**' + e.getMessage() + '**Line**' + e.getLineNumber());
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        
        return responseMap;
    }
    
    
    @AuraEnabled
    public static Map<String, Object> updatePolicyAction(Contact contactRecord, Policy__c policyRecord, String leadIds, String quoteIds) {
        Map<String, Object> responseMap = new Map<String, Object>();
        System.debug('-----quoteIds----' + quoteIds);
        if (quoteIds != null && quoteIds != '') {
            List<String> quoteIdList = new List<String>();
            quoteIdList = (List<String>) JSON.deserialize(quoteIds, List<String>.class);
            System.debug('-----quoteIdList----' + quoteIdList);
            
            Set<String> contactIdset = new Set<String>();
            
            String userType = UserInfo.getUserType();
            if ((userType != null && userType.equalsIgnoreCase('Guest')) || Test.isRunningTest()) {
                List<String> leadIdList = new List<String>();
                leadIdList = (List<String>) JSON.deserialize(leadIds, List<String>.class);
                for (Lead ldObj : [SELECT Id, ConvertedContactId FROM Lead WHERE Id IN:leadIdList AND ConvertedContactId != NULL]) {
                    contactIdset.add(ldObj.ConvertedContactId);
                }
            } else {
                String userId = UserInfo.getUserId();
                List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :userId LIMIT 1];
                if (userList != null && !userList.isEmpty()) {
                    contactIdset.add(userList[0].ContactId);
                }
                
            }
            
            System.debug('----policyRecord----' + policyRecord);
            System.debug('----contactRecord----' + contactRecord);
            
            Map<String, String> emailVsPolicyName = new Map<String, String>();
            Map<String, Policy__c> PolicyMap = new Map<String, Policy__c>();
            List<Object> policyMapList = new List<Object>();
            list<Policy__c> Policys = new list<Policy__c>();
            Policys = [SELECT Id, Name, Contact__r.Email FROM Policy__c WHERE Quote_c__c IN:quoteIdList];
            map<String,boolean> userMap = new map<String,Boolean>();
            for (Policy__c plo : Policys) {
                userMap.put(plo.Contact__r.Email, false );
            }
            
            
            for(User usObj : [select Id, Email from User where Email In: userMap.keyset() 
                              and CreatedDate <: System.now().addMinutes(-10)]){
                userMap.put(usObj.Email, true );
            }
            
            for (Policy__c plo : Policys) {
                if (policyRecord != null) {
                    Policy__c tempPol = policyRecord;
                    tempPol.Id = plo.Id;
                    tempPol.Name = plo.Name;
                    tempPol.Contact_Email__c = plo.Contact__r.Email;
                    PolicyMap.put(tempPol.Id, tempPol);
                }
                
                Map<String, Object> policyMapTemp = new Map<String, Object>();
                policyMapTemp.put('email', plo.Contact__r.Email);
                if( userMap != null && userMap.containsKey(plo.Contact__r.Email)){
                    policyMapTemp.put('isUserExist', userMap.get(plo.Contact__r.Email));
                }else{
                    policyMapTemp.put('isUserExist', false);
                }
                policyMapTemp.put('name', plo.Name);
                policyMapTemp.put('Id', plo.Id);
                policyMapList.add(policyMapTemp);
            }
            
            List<Contact> contactList = new List<Contact>();
            for (String key : contactIdset) {
                if (contactRecord != null && key != null) {
                    Contact tempCon = contactRecord;
                    tempCon.Id = key;
                    contactList.add(tempCon);
                }
                
            }
            //temp added try and catch block
            if (contactList != null && !contactList.isEmpty()) {
                update contactList;
            }
            
            if (PolicyMap != null && !PolicyMap.isEmpty()) {
                update PolicyMap.values();
            }
            
            System.debug('---policyMapList---'+policyMapList);
            responseMap.put('success', true);
            responseMap.put('policyMapList', policyMapList);
            
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static map<String,object> handleQuoteForTowUnitAction( String additional_towunit, Quote__c quoteObj ){
        QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
        
        map<String,object> responseMap = new map<String,Object>();
        try {
            System.debug('---additional_towunit---'+JSON.serializePretty(additional_towunit));
            map<String,object> additional_towunitMap = new map<String,Object>();
            additional_towunitMap = (map<String,object>)JSON.deserializeUntyped(additional_towunit);
            
            String vehicle_Id;
            if( additional_towunitMap != null && additional_towunitMap.containsKey('vehicle_Id')
            && additional_towunitMap.get('vehicle_Id') != null ){
                vehicle_Id = String.valueOf(additional_towunitMap.get('vehicle_Id'));
            }
            String towId;
            if( additional_towunitMap != null && additional_towunitMap.containsKey('Id')
            && additional_towunitMap.get('Id') != null ){
                towId = String.valueOf(additional_towunitMap.get('Id'));
            }
            
            Vehicle__c vehicleObj = new Vehicle__c();
            if( towId != null && towId != ''){
                list<Towed_Unit__c> Towed_Units = new list<Towed_Unit__c>();
                String query = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
                query += ' where Id=\'' + towId + '\'';
                Towed_Units = Database.query(query);
                
                if( Towed_Units != null && !Towed_Units.isEmpty() ){
                    if (UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                        quoteObj.Lead__c = Towed_Units[0].Lead__c;
                        vehicleObj.Lead__c = Towed_Units[0].Lead__c;
                    }
                    quoteObj.Account__c = Towed_Units[0].Account__c;
                    quoteObj.Contact__c = Towed_Units[0].Contact__c;
                    
                    vehicleObj.Account_Vehicle__c = Towed_Units[0].Account__c;
                    vehicleObj.Contact__c = Towed_Units[0].Contact__c;
                }
                
            }
            
            Integer daysBetween = 0;
            if( quoteObj.Start_Date_for_Coverage__c != null && quoteObj.End_Date_for_Coverage__c != null ){
                daysBetween = quoteObj.Start_Date_for_Coverage__c.daysBetween(quoteObj.End_Date_for_Coverage__c );
            }
            quoteObj.Term_Days__c = daysBetween;
            if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c <= 30) {
                quoteObj.Term__c = 'Daily';
            } else if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c > 30 && quoteObj.Term_Days__c <= 90) {
                quoteObj.Term__c = '90 Day';
            } else if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c > 90 && quoteObj.Term_Days__c <= 180) {
                quoteObj.Term__c = 'Semi-Annual';
            } else if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c > 180) {
                quoteObj.Term__c = 'Annual';
            }
            
            quoteObj.Vehicle_Sub_type__c = null;
            upsert quoteObj;
            
            if( additional_towunitMap != null && additional_towunitMap.containsKey('VIN_Number__c') ){
                vehicleObj.Vin__c = String.valueOf(additional_towunitMap.get('VIN_Number__c'));
                List<Vehicle__c> vehicles = new List<Vehicle__c>();
                if (vehicleObj.Vin__c != null) {
                    vehicles = [SELECT Id, Vin__c FROM Vehicle__c WHERE Vin__c != NULL AND Vin__c = :vehicleObj.Vin__c];
                }
                if (vehicles != null && !vehicles.isEmpty() ) {
                    vehicle_Id = vehicles[0].Id;
                }
                
            }
            if( vehicle_Id != null && vehicleObj.Id == null ){
                vehicleObj.Id = vehicle_Id;
            }
            if( quoteObj.Id != null ){
                additional_towunitMap.put('quoteRecord',quoteObj);
                
                vehicleObj.Quote_c__c = quoteObj.Id;
                
                if( additional_towunitMap != null && additional_towunitMap.containsKey('Year__c')){
                    vehicleObj.Year__c = String.valueOf(additional_towunitMap.get('Year__c'));
                }
                if( additional_towunitMap != null && additional_towunitMap.containsKey('Make__c')){
                    vehicleObj.Make__c = String.valueOf(additional_towunitMap.get('Make__c'));
                }
                if( additional_towunitMap != null && additional_towunitMap.containsKey('Model__c')){
                    vehicleObj.Model__c = String.valueOf(additional_towunitMap.get('Model__c'));
                }
                if( additional_towunitMap != null && additional_towunitMap.containsKey('Plate__c')){
                    vehicleObj.Registered_Plate__c = String.valueOf(additional_towunitMap.get('Plate__c'));
                }
                if( additional_towunitMap != null && additional_towunitMap.containsKey('Towed_Unit_Value__c')){
                    vehicleObj.Value__c = decimal.valueOf(String.valueOf(additional_towunitMap.get('Towed_Unit_Value__c')));
                }
                
                if( additional_towunitMap != null && additional_towunitMap.containsKey('Towed_Unit_Type__c')){
                    system.debug('Towed_Unit_Type__c -->'+String.valueOf(additional_towunitMap.get('Towed_Unit_Type__c')));
                    vehicleObj.Vehicle_Type__c = String.valueOf(additional_towunitMap.get('Towed_Unit_Type__c'));
                }
                
                String name = '';
                if (vehicleObj.Model__c != null) {
                    name += vehicleObj.Model__c;
                }
                if (vehicleObj.Make__c != null) {
                    name += (name != '' ? ', ' : '') + vehicleObj.Make__c;
                }
                if (vehicleObj.Year__c != null) {
                    name += (name != '' ? ', ' : '') + vehicleObj.Year__c;
                }
                vehicleObj.Name = name;
                
                //this is not need towed unit will be created as vehicle 17 aug 2021 //
                upsert vehicleObj;
                quoteObj.Vehicle__c = vehicleObj.Id;
                additional_towunitMap.put('vehicle_Id',vehicleObj.Id);
            }
            
            try{
                update quoteObj;
            }catch( exception ex){
                
            }
            
            if (vehicleObj.Id != null && quoteObj.Id != null) {
                List<Quote_Vehicle__c> quoteVehicleList = new List<Quote_Vehicle__c>();
                quoteVehicleList = [SELECT Id FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteObj.Id AND Vehicle__c = :vehicleObj.Id];
                
                if (quoteVehicleList == null || quoteVehicleList.isEmpty()) {
                    Quote_Vehicle__c quoteVehicle = new Quote_Vehicle__c();
                    quoteVehicle.Quote_c__c = quoteObj.Id;
                    quoteVehicle.Vehicle__c = vehicleObj.Id;
                    if (quoteVehicle.Contact__c == null && quoteVehicle.Account__c == null) {
                        quoteVehicle.Contact__c = vehicleObj.Contact__c;
                        
                        if (UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                            quoteVehicle.Lead__c = vehicleObj.Lead__c;
                        }
                        quoteVehicle.Account__c = vehicleObj.Account_Vehicle__c;
                    }
                    
                    insert quoteVehicle;
                }
                
            }
            
            responseMap.put('daysBetween',daysBetween);
            responseMap.put('additional_towunit',additional_towunitMap);
            responseMap.put('success', true);
        } catch (Exception e) {
            System.debug('----exception------'+e.getMessage()+'--line--'+e.getLineNumber());
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage()+'---line--'+e.getLineNumber());
        }
        
        return responseMap;
    }
    
    
    @AuraEnabled
    public static Map<String, Object> createTransactionAction(String rateRecordList, String affiliateAccountString) {
        
        QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
        System.debug('-rateRecordList---' + rateRecordList);
        
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Transaction__c> transactionMap = new Map<String, Transaction__c>();
        Map<String, Quote_Vehicle__c> quoteVehicleMap = new Map<String, Quote_Vehicle__c>();
        Map<String, String> quoteVsContactIdMap = new Map<String, String>();
        Map<String, String> quoteVsAccountIdMap = new Map<String, String>();
        Map<String, Policy__c> policyMap = new Map<String, Policy__c>();
        Map<String, List<Quote_Driver__c>> driverlistMap = new Map<String, List<Quote_Driver__c>>();
        try {
            //********login user Id */
            String userType = UserInfo.getUserType();
            if (rateRecordList != null && rateRecordList != '') {
                
                List<Object> rateObjList = new List<Object>();
                rateObjList = (List<Object>) JSON.deserializeUntyped(rateRecordList);
                Account affiliateAccount = (Account) JSON.deserialize(affiliateAccountString, Account.class);
                Set<String> quoteIds = new Set<String>();
                Map<String, set<String>> leadIdVsQuotesIdMap = new Map<String, set<String>>();
                
                Map<String, String> quoteIDVsPackageMap = new Map<String, String>();
                for (Object rate : rateObjList) {
                    Map<String, Object> rateMap = new Map<String, Object>();
                    rateMap = (Map<String, Object>) rate;
                    if (rateMap != null && !rateMap.isEmpty()) {
                        String quoteId;
                        String leadId;
                        if (rateMap.containsKey('quoteId')) {
                            quoteId = String.valueOf(rateMap.get('quoteId'));
                            
                            if (rateMap.containsKey('Package__c')) {
                                quoteIDVsPackageMap.put(quoteId, String.valueOf(rateMap.get('Package__c')));
                            }
                        }
                        
                        if (rateMap.containsKey('leadId') && rateMap.get('leadId') != null) {
                            leadId = String.valueOf(rateMap.get('leadId'));
                        }
                        Boolean bool = quoteId != null && leadId != null;
                        if (quoteId != null && leadId != null) {
                            if( leadIdVsQuotesIdMap != null && leadIdVsQuotesIdMap.containskey(leadId) ){
                                leadIdVsQuotesIdMap.get(leadId).add(quoteId);
                            }else{
                                leadIdVsQuotesIdMap.put(leadId, new set<String>{quoteId});
                            }
                            
                        }
                        
                        if (quoteId != null) {
                            quoteIds.add(quoteId);
                        }
                    }
                }
                
                
                for (Transaction__c trans : [SELECT Id, Policy_Transaction__c, Quote_c__c, Account_Transaction__c FROM Transaction__c WHERE Quote_c__c IN:quoteIds]) {
                    transactionMap.put(trans.Quote_c__c, trans);
                }
                System.debug('--transactionMap--' + transactionMap);
                
                List<User> userList = new List<User>();
                if (userType != null && userType.equalsIgnoreCase('Guest')) {
                    List<Lead> leadlist = getleads(leadIdVsQuotesIdMap.keySet()); //[select id, Name, LastName, Email, FirstName, isconverted, convertedContactId, convertedAccountId from Lead where Id IN: leadIdVsQuoteIdMap.keyset()];
                    for (Lead ldObj : leadlist) {
                        if (ldObj.IsConverted && leadIdVsQuotesIdMap.containsKey( ldObj.Id )) {
                            for(String quoteId : leadIdVsQuotesIdMap.get( ldObj.Id )){
                                quoteVsContactIdMap.put(quoteId, ldObj.ConvertedContactId);
                                quoteVsAccountIdMap.put(quoteId, ldObj.ConvertedAccountId);
                            }
                        }
                    }
                } else {
                    userList = getloginUser();
                    if (userList != null && !userList.isEmpty()) {
                        for (String quoteId : quoteIds) {
                            quoteVsContactIdMap.put(quoteId, userList[0].ContactId);
                            quoteVsAccountIdMap.put(quoteId, userList[0].Contact.AccountId);
                        }
                    }
                }
                System.debug('<<<<<<<<quoteVsContactIdMap>>>>>>>>>>>>' + quoteVsContactIdMap);
                System.debug('<<<<<<<<leadIdVsQuoteIdMap.keyset()>>>>>>>>' + leadIdVsQuotesIdMap.keySet());
                
                //*********************convert lead if not converted** */
                for (String ldId : leadIdVsQuotesIdMap.keySet()) {
                    for(String quoteId : leadIdVsQuotesIdMap.get( ldId )){
                        if (!quoteVsContactIdMap.containsKey( quoteId )) {
                            Map<String, Object> responseTempMap = new Map<String, Object>();
                            responseTempMap = saveQuoteAction(ldId, null, null,null, null, quoteId);
                            if (responseTempMap != null && !responseTempMap.isEmpty()) {
                                if (Boolean.valueOf(responseTempMap.get('success'))) {
                                    if (responseTempMap.containsKey('contactId')) {
                                        quoteVsContactIdMap.put(quoteId, String.valueOf(responseTempMap.get('contactId')));
                                    }
                                    
                                    if (responseTempMap.containsKey('accountId')) {
                                        quoteVsAccountIdMap.put(quoteId, String.valueOf(responseTempMap.get('accountId')));
                                    }
                                    
                                } else {
                                    responseMap = responseTempMap;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                set<String> vechicleIds = new set<String>();
                List<Quote_Vehicle__c> quotevehicleList = new List<Quote_Vehicle__c>();
                quotevehicleList = [SELECT Id, Vehicle__c, Vehicle__r.Rental__c, Quote_c__c, Account__c, Contact__c FROM Quote_Vehicle__c WHERE Quote_c__c IN:quoteIds];
                for (Quote_Vehicle__c vehicle : quotevehicleList) {
                    quoteVehicleMap.put(vehicle.Quote_c__c, vehicle);
                    vechicleIds.add( vehicle.Vehicle__c);
                }
                
                map<String, Vehicle__c> vehicleMap = new map<String, Vehicle__c>();
                for( Vehicle__c veh : [ select Id, Contact__c, Lead__c, Account_Vehicle__c from Vehicle__c where Id IN:vechicleIds and Contact__c = null and Account_Vehicle__c = null  ]){
                    vehicleMap.put(veh.Id, veh);
                }
                
                map<String, driver__c> driverMap = new map<String, driver__c>();
                list<Quote_Driver__c> qDrivers =new list<Quote_Driver__c>();
                qDrivers = [select Id, Policy__c, Quote_c__c, Account_Driver__c, Vehicle_Driver__c, Contact__c,  Primary_insured__c,
                            Driver__c, Driver__r.Contact__c, Driver__r.Account_Driver__c from Quote_Driver__c where Quote_c__c In: quoteIds ];
                
                set<String> tempQuoteIds = new set<String>();
                tempQuoteIds.addAll(quoteIds);
                for (Quote_Driver__c driver : qDrivers) {
                    if( quoteIds.contains(driver.Quote_c__c) && tempQuoteIds != null && !tempQuoteIds.isEmpty()){
                        tempQuoteIds.remove(driver.Quote_c__c);
                    }
                }
                list<Quote_Driver__c> newDriverQuoteList = new list<Quote_Driver__c>();
                if( tempQuoteIds != null && !tempQuoteIds.isEmpty() ){
                    for(String quoteIdtemp : tempQuoteIds){
                        if( quoteIdtemp != null ){
                            for (Quote_Driver__c driver : qDrivers) {
                                Quote_Driver__c cloneDr = driver.clone();
                                cloneDr.Quote_c__c = quoteIdtemp;
                                cloneDr.Primary_insured__c =driver.Primary_insured__c;
                                newDriverQuoteList.add(cloneDr);
                            }
                        }
                    }
                    
                    try{
                        if( newDriverQuoteList != null && !newDriverQuoteList.isEmpty()){
                            insert newDriverQuoteList;
                            qDrivers.addAll(newDriverQuoteList);
                        }
                    }catch( exception ex ){
                        System.debug('-ex----'+ex.getMessage());
                    }
                }
                for (Quote_Driver__c driver : qDrivers) {
                    if (driver.Contact__c == null && quoteVsContactIdMap != null && quoteVsContactIdMap.containsKey(driver.Quote_c__c)) {
                        driver.Contact__c = quoteVsContactIdMap.get(driver.Quote_c__c);
                    }
                    if (driver.Account_Driver__c == null && quoteVsAccountIdMap != null && quoteVsAccountIdMap.containsKey(driver.Quote_c__c)) {
                        driver.Account_Driver__c = quoteVsAccountIdMap.get(driver.Quote_c__c);
                    }
                    
                    if( driver.Vehicle_Driver__c == null && quoteVehicleMap != null && quoteVehicleMap.containsKey(driver.Quote_c__c)){
                        driver.Vehicle_Driver__c = quoteVehicleMap.get(driver.Quote_c__c).Vehicle__c;
                    }
                    
                    if (driverlistMap.containsKey(driver.Quote_c__c)) {
                        driverlistMap.get(driver.Quote_c__c).add(driver);
                    } else {
                        driverlistMap.put(driver.Quote_c__c, new List<Quote_Driver__c>{
                            driver
                        });
                    }
                    
                    if( driverMap != null && !driverMap.containskey( driver.driver__c) && driver.driver__r.Contact__c == null ){
                        Driver__c tempDriver = new Driver__c();
                        tempDriver.Id = driver.driver__c;
                        tempDriver.Contact__c = driver.Contact__c;
                        tempDriver.Account_Driver__c = driver.Account_Driver__c;
                        driverMap.put(tempDriver.Id, tempDriver);
                    }
                }
                
                Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                    policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                }
                System.debug('--quoteIds---'+quoteIds);
                for (Quote__c qtObj : [
                    SELECT Id, Driver_Age__c, Underwriter__c, Policy_Type_picklist__c, Surcharge__c, Coverage__c, Territory__c, Broker_Policy_Fee__c,
                    I_V_A_Mex_Tax__c, Net_Premium__c, Term__c, Term_Days__c, Vehicle_Type__c, Start_Date_for_Coverage__c, End_Date_for_Coverage__c,
                    End_Time__c, Start_Time__c, Quote_Value__c, Medical__c, Liability__c, Vehicle_Value__c,
                    Territory_Coverage__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c,
                    (select Id from Policies__r limit 1)
                    FROM Quote__c
                    WHERE Id IN:quoteIds
                ]) {
                    if( qtObj.Policies__r != null && !qtObj.Policies__r.isEmpty() ){
                        continue;
                    }
                    Policy__c newPolicy = new Policy__c();
                    newPolicy.Broker_Policy_Fee__c = qtObj.Broker_Policy_Fee__c;
                    newPolicy.I_V_A_Mex_Tax__c = qtObj.I_V_A_Mex_Tax__c;
                    newPolicy.Net_Premium__c = qtObj.Net_Premium__c;
                    newPolicy.Policy_Type_picklist__c = qtObj.Policy_Type_picklist__c;
                    newPolicy.Quote_c__c = qtObj.Id;
                    newPolicy.Package__c = qtObj.Coverage__c;
                    newPolicy.Territory_picklist__c = qtObj.Territory__c;
                    newPolicy.Surcharge__c = qtObj.Surcharge__c;
                    newPolicy.Vehicle_deductible_collision__c = qtObj.Vehicle_Deductible_Collision__c;
                    newPolicy.Vehicle_deductible_comprehensive__c = qtObj.Vehicle_Deductible_Comprehensive__c;
                    if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'Automobile'
                    && policyDeveloperNameVsId.containsKey('Automobile')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    } else if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'Driver License'
                    && policyDeveloperNameVsId.containsKey('Driver_License')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                    } else if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'Homeowners'
                    && policyDeveloperNameVsId.containsKey('Homeowners')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                    } else if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV'
                    && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                    } else if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'Northbound'
                    && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    } else if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'RV'
                    && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'Watercraft'
                    && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }
                    
                    if (quoteVehicleMap != null && quoteVehicleMap.containsKey(qtObj.Id)) {
                        newPolicy.Rental__c = quoteVehicleMap.get(qtObj.Id).Vehicle__r.Rental__c;
                        newPolicy.Vehicle_Policy__c = quoteVehicleMap.get(qtObj.Id).Vehicle__c;
                    }
                    
                    if (quoteIDVsPackageMap != null && quoteIDVsPackageMap.containsKey(qtObj.Id)) {
                        newPolicy.Package__c = quoteIDVsPackageMap.get(qtObj.Id);
                    }
                    
                    if (quoteVsContactIdMap != null && quoteVsContactIdMap.containsKey(qtObj.Id)) {
                        newPolicy.Contact__c = quoteVsContactIdMap.get(qtObj.Id);
                    }
                    if (quoteVsAccountIdMap != null && quoteVsAccountIdMap.containsKey(qtObj.Id)) {
                        newPolicy.Policy_Parent_Account__c = quoteVsAccountIdMap.get(qtObj.Id);
                        newPolicy.Account_Policy__c = quoteVsAccountIdMap.get(qtObj.Id);
                    }
                    
                    newPolicy.Status_picklist__c = 'Active';
                    newPolicy.Source__c = 'Portal';
                    Date myDate = Date.newInstance(2011, 11, 18);
                    
                    if (qtObj.Start_Date_for_Coverage__c != null) {
                        newPolicy.Start_Date__c = qtObj.Start_Date_for_Coverage__c;
                    }
                    if (qtObj.Start_Time__c != null) {
                        newPolicy.Start_Time__c = qtObj.Start_Time__c;
                    }
                    if (qtObj.End_Date_for_Coverage__c != null) {
                        newPolicy.End_Date__c = qtObj.End_Date_for_Coverage__c;
                    }
                    if (qtObj.End_Time__c != null) {
                        newPolicy.End_Time__c = qtObj.End_Time__c;
                    }
                    
                    newPolicy.Total_Transaction_Amount__c = qtObj.Quote_Value__c;
                    newPolicy.Medical_picklist__c = qtObj.Medical__c;
                    newPolicy.Liability_picklist__c = qtObj.Liability__c;
                    newPolicy.Territory_picklist__c = qtObj.Territory__c;
                    newPolicy.Term__c = qtObj.Term__c;
                    
                    if (qtObj.Term__c != null && (qtObj.Term__c == 'Annual(One Year)' || qtObj.Term__c == 'Annual')) {
                        newPolicy.Term_days__c = 365;
                    } else {
                        newPolicy.Term_days__c = qtObj.Term_Days__c;
                    }
                    
                    newPolicy.Underwriter_picklist__c = qtObj.Underwriter__c;
                    newPolicy.Vehicle_type__c = qtObj.Vehicle_Type__c;
                    newPolicy.Insured_value__c = qtObj.Vehicle_Value__c;
                    
                    if (String.isNotBlank(affiliateAccount?.Id)) {
                        newPolicy.Affiliate_Account__c = affiliateAccount.Id;
                    }
                    
                    policyMap.put(qtObj.Id, newPolicy);
                    policyMap.get(qtObj.Id).Name = generatePolicyName(qtObj.Underwriter__c, qtObj.Policy_Type_picklist__c, qtObj.Coverage__c, qtObj.Term__c, qtObj.Territory__c);
                }
                
                map<String, Towed_Unit__c> towedUnitMap = new map<String, Towed_Unit__c>();
                Map<String, list<Quote_Towed_Unit__c>> Towed_UnitMap = new Map<String, list<Quote_Towed_Unit__c>>();
                for (Quote_Towed_Unit__c unit : [SELECT Id, Contact__c, Account__c, Quote_c__c, Policy__c, Lead__c, Towed_Unit__c, Towed_Unit__r.Account__c, Towed_Unit__r.Contact__c FROM Quote_Towed_Unit__c WHERE Quote_c__c IN:quoteIds]) {
                    if (quoteVsContactIdMap.containsKey(unit.Quote_c__c)) {
                        unit.Contact__c = quoteVsContactIdMap.get(unit.Quote_c__c);
                    }
                    if (quoteVsAccountIdMap.containsKey(unit.Quote_c__c)) {
                        unit.Account__c = quoteVsAccountIdMap.get(unit.Quote_c__c);
                    }
                    
                    if (Towed_UnitMap.containsKey(unit.Quote_c__c)) {
                        Towed_UnitMap.get(unit.Quote_c__c).add(unit);
                    } else {
                        Towed_UnitMap.put(unit.Quote_c__c, new List<Quote_Towed_Unit__c>{
                            unit
                        });
                    }
                    
                    if( towedUnitMap != null && !towedUnitMap.containskey(unit.Towed_Unit__c) && unit.Towed_Unit__r.Contact__c == null ){
                        Towed_Unit__c tempTow = new Towed_Unit__c();
                        tempTow.Id = unit.Towed_Unit__c;
                        tempTow.Account__c = unit.Account__c;
                        tempTow.Contact__c = unit.Contact__c;
                        towedUnitMap.put(tempTow.Id, tempTow);
                    }
                }
                
                List<Authorize_Net_Customer_Profile__c> customerProfiles = new List<Authorize_Net_Customer_Profile__c>();
                for (Authorize_Net_Customer_Profile__c customerProfile : [
                    SELECT Id, Contact__c, Quote__c
                    FROM Authorize_Net_Customer_Profile__c
                    WHERE Quote__c IN:quoteIds
                ]) {
                    
                    if (quoteVsContactIdMap.containsKey(customerProfile.Quote__c)) {
                        customerProfile.Contact__c = quoteVsContactIdMap.get(customerProfile.Quote__c);
                    }
                    customerProfiles.add(customerProfile);
                }
                
                List<Subscription__c> subscriptions = new List<Subscription__c>();
                for (Subscription__c subscription : [
                    SELECT Id, Contact__c, Quote__c
                    FROM Subscription__c
                    WHERE Quote__c IN:quoteIds
                ]) {
                    
                    if (quoteVsContactIdMap.containsKey(subscription.Quote__c)) {
                        subscription.Contact__c = quoteVsContactIdMap.get(subscription.Quote__c);
                    }
                    subscriptions.add(subscription);
                }
                
                List<Quote_Driver__c> driverlistTemp = new List<Quote_Driver__c>();
                Set<String> policyIdset = new Set<String>();
                if (policyMap != null && !policyMap.isEmpty()) {
                    insert policyMap.values();
                    
                    List<Quote__c> QuoteList = new List<Quote__c>();
                    
                    
                    for (String quoteId : policyMap.keySet()) {
                        if (policyMap.get(quoteId).Id != null) {
                            policyIdset.add(policyMap.get(quoteId).Id);
                            Quote__c tempQuote = new Quote__c();
                            tempQuote.Id = quoteId;
                            if (quoteVsContactIdMap.containsKey(quoteId)) {
                                tempQuote.Contact__c = quoteVsContactIdMap.get(quoteId);
                            }
                            if (quoteVsAccountIdMap.containsKey(quoteId)) {
                                tempQuote.Account__c = quoteVsAccountIdMap.get(quoteId);
                            }
                            tempQuote.Quote_Status__c = 'Policy Created';
                            QuoteList.add(tempQuote);
                        }
                        
                        if (quoteVehicleMap != null && quoteVehicleMap.containsKey(quoteId)) {
                            quoteVehicleMap.get(quoteId).Policy__c = policyMap.get(quoteId).Id;
                            if (quoteVehicleMap.get(quoteId).Account__c == null && quoteVsAccountIdMap.containsKey(quoteId)) {
                                quoteVehicleMap.get(quoteId).Account__c = quoteVsAccountIdMap.get(quoteId);
                                if( vehicleMap != null && vehicleMap.containskey( quoteVehicleMap.get(quoteId).Vehicle__c ) ){
                                    vehicleMap.get( quoteVehicleMap.get(quoteId).Vehicle__c ).Account_Vehicle__c = quoteVehicleMap.get(quoteId).Account__c;
                                }
                            }
                            if (quoteVehicleMap.get(quoteId).Contact__c == null && quoteVsContactIdMap.containsKey(quoteId)) {
                                quoteVehicleMap.get(quoteId).Contact__c = quoteVsContactIdMap.get(quoteId);
                                if( vehicleMap != null && vehicleMap.containskey( quoteVehicleMap.get(quoteId).Vehicle__c ) ){
                                    vehicleMap.get( quoteVehicleMap.get(quoteId).Vehicle__c ).Contact__c = quoteVehicleMap.get(quoteId).Contact__c;
                                }
                            }
                            
                            
                        }
                        if (policyMap.get(quoteId).Id != null && transactionMap != null && transactionMap.containsKey(quoteId)) {
                            transactionMap.get(quoteId).Policy_Transaction__c = policyMap.get(quoteId).Id ;
                        }
                        
                        if (quoteVsAccountIdMap != null && quoteVsAccountIdMap.containsKey(quoteId) &&
                        transactionMap != null && transactionMap.containsKey(quoteId)) {
                            transactionMap.get(quoteId).Account_Transaction__c = quoteVsAccountIdMap.get(quoteId) ;
                        }
                        
                        if (driverlistMap != null && driverlistMap.containsKey(quoteId)) {
                            for (Quote_Driver__c driver : driverlistMap.get(quoteId)) {
                                driver.Policy__c = policyMap.get(quoteId).Id;
                                driverlistTemp.add(driver);
                            }
                        }
                        
                        if( Towed_UnitMap != null && !Towed_UnitMap.isEmpty() && Towed_UnitMap.containskey(quoteId) ){
                            for (Quote_Towed_Unit__c unit : Towed_UnitMap.get(quoteId)) {
                                unit.Policy__c = policyMap.get(quoteId).Id;
                            }
                        }
                    }
                    
                    System.debug('--Towed_UnitMap--' + Towed_UnitMap);
                    System.debug('--driverlistTemp--' + driverlistTemp);
                    
                    if (QuoteList != null && !QuoteList.isEmpty()) {
                        update QuoteList;
                    }
                    if (transactionMap != null && !transactionMap.isEmpty()) {
                        update transactionMap.values();
                    }
                    
                    if (driverlistTemp != null && !driverlistTemp.isEmpty()) {
                        update driverlistTemp;
                    }
                    if (quoteVehicleMap != null && !quoteVehicleMap.isEmpty()) {
                        update quoteVehicleMap.values();
                    }
                    
                    if( vehicleMap != null && !vehicleMap.isEmpty() ){
                        try{
                            update vehicleMap.values();
                        }catch(Exception ex){
                            System.debug('--Exception----'+ex.getMessage());
                        }
                    }
                    
                    if( towedUnitMap != null && !towedUnitMap.isEmpty() ){
                        try{
                            update towedUnitMap.values();
                        }catch(Exception ex){
                            System.debug('--Exception----'+ex.getMessage());
                        }
                    }
                    
                    if( driverMap != null && !driverMap.isEmpty() ){
                        try{
                            update driverMap.values();
                        }catch(Exception ex){
                            System.debug('--Exception----'+ex.getMessage());
                        }
                    }
                    
                    if (Towed_UnitMap != null && !Towed_UnitMap.isEmpty()) {
                        list<Quote_Towed_Unit__c> tempList = new list<Quote_Towed_Unit__c>();
                        for( list<Quote_Towed_Unit__c> qtuL : Towed_UnitMap.values()){
                            tempList.addAll( qtuL );
                        }
                        try{
                            update tempList;
                        }catch(Exception ex){
                            
                        }
                    }
                    
                    if (customerProfiles != null && !customerProfiles.isEmpty()) {
                        update customerProfiles;
                    }
                    if (subscriptions != null && !subscriptions.isEmpty()) {
                        update subscriptions;
                    }
                    
                    System.debug('-policyIdset---' + policyIdset);
                    if (policyIdset != null && !policyIdset.isEmpty()) {
                        Boolean add_attachment = true;
                        Mex_Insurance_Calloututility.sendEmail(policyIdset, add_attachment);
                    }
                }
            }
            responseMap.put('success', true);
        } catch (Exception e) {
            system.debug('message : --'+e.getMessage() + ' at line : '+e.getLineNumber() + ' cause : '+ e.getCause());
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        
        return responseMap;
    }
    
    public static String generatePolicyName(String underWriter, String policyType, String coverageType, String term, String territory) {
        
        String policyName = '';
        
        //1 Letter
        if (underWriter != null && underWriter != '') {
            policyName += underWriter.substring(0, 1).toUpperCase();
        }
        
        //2 Letter
        if (policyType != null && policyType != '') {
            policyName += policyType.substring(0, 1).toUpperCase();
        }
        
        //3 Letter
        if (coverageType != null && coverageType != '') {
            policyName += coverageType.substring(0, 1).toUpperCase();
        }
        
        //4 Letter
        if (term != null && term != '') {
            policyName += term.substring(0, 1).toUpperCase();
        }
        
        //5 Letter
        if (territory != null && territory != '') {
            policyName += territory.substring(0, 1).toUpperCase();
        }
        
        //6 - 8Letter
        policyName += '-' + String.valueOf(System.today().year()).substring(2, 4) + '-' + generateRandomString(5).toUpperCase();
        
        return policyName;
        
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
    
    @AuraEnabled
    public static List<Object> getPicklistValues(String objectApiName, String fieldApiName) {
        List<Object> options = new List<Object>();
        
        Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
        Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
        Map<String, Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            Map<String, String> optionMap = new Map<String, String>();
            optionMap.put('value', f.getValue());
            optionMap.put('label', f.getLabel());
            options.add(optionMap);
        }
        return options;
    }
    
    @AuraEnabled
    public static List<Object> getBoatPicklistValues(String objectApiName, String fieldApiName) {
        List<Object> options = new List<Object>();
        options = WatercraftFlowController.getPicklistValues( objectApiName, fieldApiName);
        system.debug('options : ->>>>>>>>>1680 line '+ options);
        return options;
    }
    @AuraEnabled
    public static Map<String, List<String>> getBoatDependentMap(SObject objDetail, String contrfieldApiName, String depfieldApiName) {
        
        Map<String, List<String>> objResults = new Map<String, List<String>>();
        objResults = WatercraftFlowController.getDependentMap(objDetail, contrfieldApiName, depfieldApiName);
        system.debug('objResults :---> '+ objResults);
        return objResults;
    }
    @AuraEnabled
    public static Map<String, Object> handleQuocteAction(Quote__c quoteRecord) {
        System.debug('@@@ inside handleQuocteAction');
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (quoteRecord.Start_Date_for_Coverage__c != null && quoteRecord.End_Date_for_Coverage__c != null) {
                quoteRecord.Term_Days__c = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
            }
            System.debug('quoteRecord.Term_Days__c : ' + quoteRecord.Term_Days__c);
            
            if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c <= 30) {
                quoteRecord.Term__c = 'Daily';
            } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 30 && quoteRecord.Term_Days__c <= 90) {
                quoteRecord.Term__c = '90 Day';
            } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 90 && quoteRecord.Term_Days__c <= 180) {
                quoteRecord.Term__c = 'Semi-Annual';
            } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 180) {
                quoteRecord.Term__c = 'Annual';
            }
            
            if (quoteRecord.Id == null) {
                quoteRecord.Quote_Status__c = 'Draft';
            }
            
            upsert quoteRecord Id;
            
            responseMap.put('success', true);
            responseMap.put('quoteId', quoteRecord.Id);
            responseMap.put('quoteRecord', quoteRecord);
            
        } catch (Exception e) {
            System.debug('---Exception---' + e.getMessage() + '--;=line--' + e.getLineNumber());
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> handleDeleteTowedUnitAction(Quote__c quoteRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            list<Quote_Towed_Unit__c> Qtunits = new list<Quote_Towed_Unit__c>();
            Qtunits = [select Id, Quote_Vehicle__c from Quote_Towed_Unit__c where Quote_c__c =: quoteRecord.Id ];
            
            if( Qtunits != null && !Qtunits.isEmpty() ){
                delete Qtunits;
            }
            responseMap.put('success', true);
        }catch (Exception e) {
            System.debug('---Exception---' + e.getMessage() + '--;=line--' + e.getLineNumber());
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> handleVehicleQuoteAction(Quote__c quoteRecord, String leadRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Map<String, Object> ldObjectMap = new Map<String, Object>();
            ldObjectMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord);
            String leadId = Mex_Insurance_Calloututility.getLeadId(ldObjectMap);
            System.debug('--ldObjectMap 00--'+ ldObjectMap);
            System.debug('--ldObjectMap leadId--'+ leadId);
            String userType = UserInfo.getUserType();
            if ((leadId == null || leadId == '') && (userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                
                if (quoteRecord.Policy_Type_picklist__c == 'Northbound') {
                    ldObjectMap.put('Company', 'NorthBound Insurance');
                } else if (quoteRecord.Policy_Type_picklist__c == 'Automobile') {
                    ldObjectMap.put('Company', 'Southbound Insurance');
                } else if (quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV') {
                    ldObjectMap.put('Company', 'Motorcycle/Street Legal ATV Insurance');
                }else if (quoteRecord.Policy_Type_picklist__c == 'RV') {
                    ldObjectMap.put('Company', 'RV Insurance');
                    
                }else if (quoteRecord.Policy_Type_picklist__c == 'Watercraft') {
                    ldObjectMap.put('Company', 'Watercraft Insurance');
                    
                }
                
                ldObjectMap.put('Date_of_Birth__c', quoteRecord.Date_of_Birth__c);
                
                ldObjectMap.put('Status', 'New');
                ldObjectMap.put('Source__c', 'Portal');
                if (ldObjectMap.containsKey('sobjectType')) {
                    ldObjectMap.remove('sobjectType');
                }
                System.debug('--ldObjectMap--'+ ldObjectMap);
                leadId = Mex_Insurance_Calloututility.createLead_Record(ldObjectMap);
                System.debug('--ldObjectMap leadId--'+ leadId);
            }
            
            if (leadId != null && userType.equalsIgnoreCase('Guest')) {
                quoteRecord.Lead__c = leadId;
                
                List<Lead> leads = new List<Lead>();
                leads = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leadId AND IsConverted = TRUE LIMIT 1];
                if (leads != null && !leads.isEmpty()) {
                    quoteRecord.Contact__c = leads[0].ConvertedContactId;
                    quoteRecord.Account__c = leads[0].ConvertedAccountId;
                }
            }
            if (userType != null && !userType.equalsIgnoreCase('Guest')) {
                List<User> loginUserList = new List<User>();
                loginUserList = getloginUser();
                if (loginUserList != null && !loginUserList.isEmpty()) {
                    quoteRecord.Contact__c = loginUserList[0].ContactId;
                    quoteRecord.Account__c = loginUserList[0].Contact.AccountId;
                }
            }
            
            /*if (quoteRecord.Date_of_Birth__c != null) {
                Integer year = System.today().year() - quoteRecord.Date_of_Birth__c.year();
                if (year != null && year < 21) {
                    quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
                } else {
                    quoteRecord.Is_there_a_driver_under_21__c = 'No';
                }
                
                if (year != null && year > 75) {
                    quoteRecord.Is_there_a_driver_over_75__c = 'Yes';
                } else {
                    quoteRecord.Is_there_a_driver_over_75__c = 'No';
                }
                
            }*/
            
            if (quoteRecord.Id == null) {
                quoteRecord.Quote_Status__c = 'Draft';
            }
            
            
            upsert quoteRecord Id;
            
            responseMap.put('success', true);
            responseMap.put('leadId', leadId);
            responseMap.put('quoteId', quoteRecord.Id);
            
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> createTowedUnit(Towed_Unit__c towedObject, String quoteId, String vehicleId) {
        QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
        system.debug('towedObject-->'+towedObject );
        system.debug('towedObject quoteId-->'+quoteId );
        system.debug('towedObject vehicleId-->'+vehicleId );
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if( towedObject.VIN_Number__c != null ){
                list<Towed_Unit__c> tunits = new list<Towed_Unit__c>();
                tunits = [select Id from Towed_Unit__c where VIN_Number__c =: towedObject.VIN_Number__c limit 1];
                if( tunits != null && !tunits.isEmpty() ){
                    towedObject.Id = tunits[0].Id;
                }
            }
            
            list<Quote_Vehicle__c> quoteVechiles = new list<Quote_Vehicle__c>();
            if( quoteId != null && vehicleId != null ){
                quoteVechiles = [select Id from Quote_Vehicle__c where Quote_c__c =: quoteId and Vehicle__c =: vehicleId limit 1 ];
            }
            //VIN_Number__c
            if (towedObject != null) {
                /*towedObject.Quote_c__c = quoteId;*/
                Quote__c quoteRecord = getQuoteWithAllFields(quoteId);
                if (towedObject.Contact__c == null && towedObject.Lead__c == null) {
                    if (quoteRecord != null && towedObject.Contact__c == null && towedObject.Account__c == null ) {
                        towedObject.Contact__c = quoteRecord.Contact__c;
                        
                        if (UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                            towedObject.Lead__c = quoteRecord.Lead__c;
                        }
                        towedObject.Account__c = quoteRecord.Account__c;
                    }
                }
                system.debug('towedObject-->'+ towedObject);
                upsert towedObject Id;
                
                if( towedObject.Id != null && quoteId != null  ){
                    list<Quote_Towed_Unit__c> Qtunits = new list<Quote_Towed_Unit__c>();
                    Qtunits = [select Id, Quote_Vehicle__c from Quote_Towed_Unit__c where Quote_c__c =: quoteId and Towed_Unit__c=:towedObject.Id  limit 1];
                    System.debug('---Qtunits--'+Qtunits);
                    if( Qtunits == null || Qtunits.isEmpty() ){
                        Quote_Towed_Unit__c qtunt = new Quote_Towed_Unit__c();
                        qtunt.Quote_c__c = quoteId;
                        qtunt.Towed_Unit__c = towedObject.Id;
                        
                        if (quoteRecord != null) {
                            qtunt.Contact__c = quoteRecord.Contact__c;
                            
                            if (UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                                qtunt.Lead__c = quoteRecord.Lead__c;
                            }
                            qtunt.Account__c = quoteRecord.Account__c;
                        }
                        if( quoteVechiles != null && !quoteVechiles.isEmpty() ){
                            qtunt.Quote_Vehicle__c = quoteVechiles[0].Id;
                        }
                        
                        Database.SaveResult svRes = Database.insert(qtunt, false);
                        System.debug('--svRes--'+svRes);
                    }else{
                        if( quoteVechiles != null && !quoteVechiles.isEmpty() ){
                            Qtunits[0].Quote_Vehicle__c = quoteVechiles[0].Id;
                            Database.update(Qtunits, false);
                        }
                    }
                }
                System.debug('--towedObject.Id--'+towedObject.Id);
                responseMap.put('towedUnitId', towedObject.Id);
                responseMap.put('success', true);
            }
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> deleteTowedUnitAction(String recordId, String quoteId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (recordId != null) {
                list<Quote_Towed_Unit__c> towedObjects = new list<Quote_Towed_Unit__c>();
                towedObjects =  [select Id from Quote_Towed_Unit__c where Quote_c__c =: quoteId and Towed_Unit__c=: recordId ];
                
                System.debug('-towedObjects---'+towedObjects);
                if( towedObjects != null && !towedObjects.isEmpty() ){
                    delete towedObjects;
                }
                responseMap.put('success', true);
            }
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        
        return responseMap;
    }
    
    @AuraEnabled
    public static List<Coverage_Detail__c> getCoverageDetail(Quote__c quoteRecord) {
        List<Coverage_Detail__c> Coverage_Details = new List<Coverage_Detail__c>();
        try {
            String query = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c,';
            query += 'IsDeleted, Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query += 'Roadside_Details__c, SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, ';
            query += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c, Total_Theft_Deductible__c';
            //query += ' FROM Coverage_Detail__c where Underwriter__c = \'Chubb\' and Policy_Type__c =  \'Northbound\' limit 1';
            query += ' FROM Coverage_Detail__c where Underwriter__c = \'' + quoteRecord.Underwriter__c + '\' and Policy_Type__c =  \'' + quoteRecord.Policy_Type_picklist__c + '\' limit 1';
            
            Coverage_Details = Database.query(query);
            System.debug('quoteRecord.Underwriter__c--' +quoteRecord+ ' quoteRecord.Policy_Type_picklist__c ='+quoteRecord.Policy_Type_picklist__c );
            System.debug('Coverage_Details--' +Coverage_Details );
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            System.debug('Exception--' + e.getMessage());
        }
        return Coverage_Details;
    }
    
    @AuraEnabled
    public static map<string, list<Coverage_Detail__c>> getCoverageDetailForSouthbound(Quote__c quoteRecord) {
        List<Coverage_Detail__c> Coverage_Details = new List<Coverage_Detail__c>();
        map<string, list<Coverage_Detail__c>> coverageDetailsMap = new map<string, list<Coverage_Detail__c>>();
        system.debug('quoteRecord : ->>'+ quoteRecord);
        try {
            String query = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c, Package__c, ';
            query += 'IsDeleted, Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query += 'Roadside_Details__c, SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, ';
            query += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c, Total_Theft_Deductible__c';
            query += ' FROM Coverage_Detail__c where Policy_Type__c =  \'' + quoteRecord.Policy_Type_picklist__c + '\' ORDER BY SystemModstamp DESC';
            
            Coverage_Details = Database.query(query);
            System.debug('quoteRecord.Underwriter__c--' +quoteRecord+ ' quoteRecord.Policy_Type_picklist__c ='+quoteRecord.Policy_Type_picklist__c );
            System.debug('Coverage_Details--' +Coverage_Details );
            
            
            for(Coverage_Detail__c c : Coverage_Details){
                if( c.Underwriter__c != null && !coverageDetailsMap.containskey( c.Underwriter__c ) ){
                    coverageDetailsMap.put( c.Underwriter__c, new list<Coverage_Detail__c>{c} );
                }else if( c.Underwriter__c != null ) {
                    coverageDetailsMap.get(c.Underwriter__c).add(c);
                }
            }
            
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            System.debug('Exception--' + e.getMessage());
        }
        return coverageDetailsMap;
    }
    
    public static List<Lead> getLeadRecord(String whereClose) {
        String leadQuery = 'select Id, Name, convertedContactId, convertedAccountId from Lead';
        if (whereClose != null) {
            leadQuery += ' where ' + whereClose;
        }
        return Database.query(leadQuery);
    }
    
    @AuraEnabled
    public static String sendEmailDocumentAction(String policyIds) {
        try {
            System.debug('******policyIds****' + policyIds);
            if (policyIds != null && policyIds != '') {
                Set<String> policyIdList = new Set<String>();
                policyIdList = (Set<String>) JSON.deserialize(policyIds, Set<String>.class);
                system.debug('policyIdList---->'+policyIdList);
                Boolean add_attachment = false;
                Mex_Insurance_Calloututility.sendEmail(policyIdList, add_attachment);
                //Database.executeBatch(new BatchTosendQuoteEmail(policyIdList), 1);
            }
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            throw new AuraHandledException(e.getMessage());
        }
        
        return null;
    }
    private static Map<String, String> keyVsTemplates;
    private static String policyFromEmailAddress;
    private static String userCommunityProfileName;
    
    public static void setupEmailParams(String contactId ) {
        keyVsTemplates = new Map<String, String>();
        Contact objContact = [
                            SELECT  Id, Agency__c, 
                                    Agency__r.Driver_License_Policy_Purchase_Template__c,
                                    Agency__r.Northbound_Policy_Purchase_Template__c, 
                                    Agency__r.Policy_Purchase_Template__c, 
                                    Agency__r.Policy_Email_From_Address__c,
                                    Agency__r.Watercraft_Policy_Purchase_Template__c,
                                    Agency__r.Agency_Community_Profile__c
                            FROM Contact 
                            WHERE Id =: contactId
                            LIMIT 1];

        if(objContact.Agency__c != null && !String.isBlank(objContact.Agency__r.Policy_Email_From_Address__c)) {
            policyFromEmailAddress = objContact.Agency__r.Policy_Email_From_Address__c;
        } else{
            policyFromEmailAddress = System.Label.RemainderEmail;
        }

        if(objContact.Agency__c != null && !String.isBlank(objContact.Agency__r.Driver_License_Policy_Purchase_Template__c)) {
            keyVsTemplates.put('Driver_License_Policy_Purchase_Template', objContact.Agency__r.Driver_License_Policy_Purchase_Template__c );
        } else {
            keyVsTemplates.put('Driver_License_Policy_Purchase_Template', System.Label.DriverLicense_New_Policy_Purchase_TemplateName);
        }

        if(objContact.Agency__c != null &&  !String.isBlank(objContact.Agency__r.Northbound_Policy_Purchase_Template__c)) {
            keyVsTemplates.put('Northbound_Policy_Purchase_Template', objContact.Agency__r.Northbound_Policy_Purchase_Template__c);
        } else {
            keyVsTemplates.put('Northbound_Policy_Purchase_Template', System.Label.Northbound_New_Policy_Purchase_TemplateName);
        }

        if(objContact.Agency__c != null && !String.isBlank(objContact.Agency__r.Policy_Purchase_Template__c)) {
            keyVsTemplates.put('Policy_Purchase_Template', objContact.Agency__r.Policy_Purchase_Template__c);
        } else {
            keyVsTemplates.put('Policy_Purchase_Template', System.Label.New_Policy_Purchase_TemplateName);
        }

        if(objContact.Agency__c != null && !String.isBlank(objContact.Agency__r.Watercraft_Policy_Purchase_Template__c)) {
            keyVsTemplates.put('Watercraft_Policy_Purchase_Template', objContact.Agency__r.Watercraft_Policy_Purchase_Template__c);
        } else {
            keyVsTemplates.put('Watercraft_Policy_Purchase_Template',  System.Label.Watercraft_New_Policy_Purchase_TemplateName);
        }

        if(objContact.Agency__c != null && !String.isBlank(objContact.Agency__r.Agency_Community_Profile__c)) {
            userCommunityProfileName = objContact.Agency__r.Agency_Community_Profile__c;
        } else {
            userCommunityProfileName = 'Mex Insurance Customer Community Plus Login User';
        }
        
    }
    
    
    
    public static void sendQuoteEmail(String policyId, String policyName, String contactId, String EmailAddress, String policyType, String underWriter) {
        try {
            setupEmailParams(contactId);
            List<Messaging.EmailFileAttachment> EmailFileAttachments = new List<Messaging.EmailFileAttachment>();
            System.debug('--policyId--' + policyId);
            System.debug('--EmailAddress--' + EmailAddress);
            System.debug('--policyType--' + policyType);
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            // Replace Visualforce(AccountDetails) page with your visualforce page
            PageReference pref;
            
            String englishFileName,spanishFileName;
            if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                englishFileName = System.Label.Chubb_English_Automobile;
                spanishFileName = System.Label.Chubb_Spanish_Automobile;
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                englishFileName = System.Label.Chubb_English_RV;
                spanishFileName = System.Label.Chubb_Spanish_RV;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                englishFileName = System.Label.Chubb_English_Motorcycle;
                spanishFileName = System.Label.Chubb_Spanish_Motorcycle;
            }
            if(underWriter != null && underWriter == 'Chubb'){
                List<ContentVersion> contentVersions = new List<ContentVersion>([
                Select Id,ContentDocument.Title,Title,VersionData,FileExtension from ContentVersion Where 
                                ContentDocument.Title =:englishFileName OR 
                                ContentDocument.Title =:spanishFileName]);
                for(ContentVersion eachCv : contentVersions ){
                    Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();emlAtt.setFilename(eachCv.title+'.' + eachCv.FileExtension);Blob fileData = eachCv.VersionData;emlAtt.setBody(fileData);EmailFileAttachments.add(emlAtt);
                }
            }
            
            
            
            
            String pageName='';
            set<String> documentNames = new set<String>();
            String DeveloerName = '';
            String developerNameChubbSpanish = '';
            if (policyType == 'Northbound') {
                pref = Page.Declaration_Page_Insurance_2;
                pageName = 'Declaration_Page_Insurance_2';
                DeveloerName = 'Terms_and_Conditions_Northbound';
                documentNames.add('Terms_and_Conditions_Northbound_Spanish');
                
            }else if ( policyType == 'Driver License') {
                pref = Page.policy_declaration_driver_license;
                DeveloerName = 'Terms_and_Conditions_Driver_License';
                pageName = 'policy_declaration_driver_license';
                
            }else if ( policyType == 'Watercraft') {
                pref = Page.watercraft_policy_declaration_Page;
                DeveloerName = 'Terms_and_Conditions_Watercraft';
                pageName = 'watercraft_policy_declaration_Page';
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                pref = page.Southbound_PolicyDec_Chubb;
                DeveloerName = 'Terms_and_Conditions_Automobile_Chubb';
                developerNameChubbSpanish = 'Terms_and_Conditions_Southbound_Chubb_Spanish';
                pageName = 'Southbound_PolicyDec_Chubb';
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Mapfre' ){
                pref = page.Southbound_PolicyDeclarationPage_Mapfre;
                DeveloerName = 'Terms_and_Conditions_Automobile_Mapfre';
                pageName = 'Southbound_PolicyDeclarationPage_Mapfre';
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Qualitas' ){
                pref = page.Southbound_PolicyDecPage_Qualitas;
                DeveloerName = 'Terms_and_Conditions_Automobile_Qualitas';
                pageName = 'Southbound_PolicyDecPage_Qualitas';
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                pref = page.Southbound_Chubb_RV;
                DeveloerName = 'Terms_and_Conditions_RV_Chubb';
                developerNameChubbSpanish = 'Terms_and_Conditions_Southbound_Chubb_Spanish';
                pageName = 'Southbound_Chubb_RV';
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Mapfre' ){
                pref = page.Southbound_Mapfre_RV;
                DeveloerName = 'Terms_and_Conditions_RV_Mapfre';
                pageName = 'Southbound_Mapfre_RV';
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Qualitas' ){
                pref = page.Southbound_Qualitas_RV;
                DeveloerName = 'Terms_and_Conditions_RV_Qualitas';
                pageName = 'Southbound_Qualitas_RV';
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Qualitas' ){
                pref = page.Southbound_Qualitas_Motorcycle;
                DeveloerName = 'Terms_and_Conditions_Motorcycle_Qualitas';
                pageName = 'Southbound_Qualitas_Motorcycle';
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Mapfre' ){
                pref = page.Southbound_Mapfre_Motorcycle;
                DeveloerName = 'Terms_and_Conditions_Motorcycle_Mapfre';
                pageName = 'Southbound_Mapfre_Motorcycle';
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                pref = page.Southbound_ChubbMotorcycle;
                DeveloerName = 'Terms_and_Conditions_Motorcycle_Chubb';
                developerNameChubbSpanish = 'Terms_and_Conditions_Southbound_Chubb_Spanish';
                pageName = 'Southbound_ChubbMotorcycle'; 
            }else if( underWriter != null && underWriter == 'Qualitas' ){ // Updated condition according to the new policy type
                pref = page.Southbound_PolicyDecPage_Qualitas;
                DeveloerName = 'Terms_and_Conditions_Automobile_Qualitas';
                pageName = 'Southbound_PolicyDecPage_Qualitas';
            }else if( underWriter != null && underWriter == 'Mapfre' ){
                pref = page.Southbound_PolicyDeclarationPage_Mapfre;
                DeveloerName = 'Terms_and_Conditions_Automobile_Mapfre';
                pageName = 'Southbound_PolicyDeclarationPage_Mapfre';
            }else if( underWriter != null && underWriter == 'Chubb' ){
                // pref = page.Southbound_ChubbMotorcycle;
                // DeveloerName = 'Terms_and_Conditions_Motorcycle_Chubb';
                // developerNameChubbSpanish = 'Terms_and_Conditions_Southbound_Chubb_Spanish';
                // pageName = 'Southbound_ChubbMotorcycle';
                pref = page.Southbound_PolicyDec_Chubb;
                DeveloerName = 'Terms_and_Conditions_Automobile_Chubb';
                developerNameChubbSpanish = 'Terms_and_Conditions_Southbound_Chubb_Spanish';
                pageName = 'Southbound_PolicyDec_Chubb';
            }
            
            pref.getParameters().put('id', policyId);
            pref.setRedirect(true);
            Blob b = null;
            if (!Test.isRunningTest()) {
                System.debug('User::::'+UserInfo.getuserType());
                String usertype = UserInfo.getuserType();
                if(usertype.toLowerCase() !='guest'){
                    b = pref.getContentAsPDF();
                }
                else{
                    String siteurl = System.label.MySiteURL;
                    String url =siteurl+pageName+'?id='+policyId;
                    PageReference pageRef = new PageReference(URL);
                    b = pageRef.getContentAsPdf();
                }
            } else if (Test.isRunningTest()) {
                b = Blob.valueOf('Testing');
            }
            attach.setFileName(policyName);
            attach.setBody(b);
            EmailFileAttachments.add(attach);
            
            documentNames.add(DeveloerName);
            if(underWriter != null && underWriter == 'Chubb'){
                documentNames.add(developerNameChubbSpanish);
            }
            System.debug('documentNames:::'+documentNames);
            
            List<Document> DocumentList = new List<Document>();
            if( DeveloerName != null && DeveloerName != '' && underWriter != null ){
                DocumentList = [SELECT Id, Body, Name, DeveloperName FROM Document WHERE DeveloperName IN: documentNames];
            }
            System.debug('DocumentList:::'+DocumentList);
            
            for (Document doc : DocumentList) {
                attach = new Messaging.EmailFileAttachment();
                attach.setFileName(doc.DeveloperName + '.pdf');
                attach.setBody(doc.Body);
                EmailFileAttachments.add(attach);
            }
            System.debug('attach:::'+attach);
            System.debug('EmailFileAttachments:::'+EmailFileAttachments);
            
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            /*
            EmailTemplate emailTemplate;
            if (policyType == 'Northbound') {
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Northbound_Policy_Purchase_Template')];
            } else if (policyType == 'Driver License') {
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Driver_License_Policy_Purchase_Template')];
            } else if (policyType == 'Watercraft') {
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Watercraft_Policy_Purchase_Template')];
            } else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Mapfre' ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Qualitas' ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Qualitas' ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else if( policyType == 'RV' && underWriter != null && underWriter == 'Qualitas' ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else if( policyType == 'RV' && underWriter != null && underWriter == 'Mapfre' ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && (underWriter == 'Chubb' || underWriter == 'Mapfre') ){
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            } else {
                emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =: keyVsTemplates.get('Policy_Purchase_Template')];
            }
            System.debug('@@@'+emailTemplate.DeveloperName);
            semail.setTemplateId(emailTemplate.Id);
            */
            Map<String, String> policyTemplateMap = new Map<String, String>{
                'Northbound' => 'Northbound_Policy_Purchase_Template',
                'Driver License' => 'Driver_License_Policy_Purchase_Template',
                'Watercraft' => 'Watercraft_Policy_Purchase_Template'
            };
            String templateKey;
            if (policyTemplateMap.containsKey(policyType)) {
                templateKey = policyTemplateMap.get(policyType);
            } else {
                // All other combinations default to Policy_Purchase_Template
                templateKey = 'Policy_Purchase_Template';
            }
            String templateName = keyVsTemplates.get(templateKey);
            EmailTemplate emailTemplate = [
                SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
                FROM EmailTemplate 
                WHERE DeveloperName = :templateName
                LIMIT 1
            ];

            System.debug('emailTemplate.DeveloperName@@@' + emailTemplate.DeveloperName);
            semail.setTemplateId(emailTemplate.Id);
            System.debug('policyFromEmailAddress@@@@'+policyFromEmailAddress);
            //semail.setSubject('Quote Details');
            OrgWideEmailAddress[] senderEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: policyFromEmailAddress];
            semail.setOrgWideEmailAddressId(senderEmail.get(0).Id);
            System.debug('@@@@contactId'+contactId);
            semail.setToAddresses(new List<String>{ EmailAddress });
            semail.setTargetObjectId(contactId);
            semail.setUseSignature(false);
            semail.setBccSender(false);
            semail.setSaveAsActivity(false);
            //semail.setPlainTextBody('Please find the attached Quote details');
            semail.setFileAttachments(EmailFileAttachments);
            System.debug('@@@semail'+semail);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ semail });
            System.debug('results@@@@'+results);
            
        } catch (Exception e) {CustomErrorExceptionHandlerException.data = 'policyId: '+ policyId+ '\npolicyName: '+ policyName + '\ncontactId: ' + contactId + '\nEmailAddress: ' + EmailAddress + '\npolicyType: '+policyType +'underWriter: ' +  underWriter;CustomErrorExceptionHandlerException.LogException(e);
            System.debug('*****exception***' + e.getMessage() + '---line-' + e.getLineNumber());}
    }
    
    public static void sendQuoteEmailWithYellowCard(String policyId, String policyName, String contactId, String EmailAddress, String policyType, String underWriter, String attachmentName2) {
        try {
            List<Messaging.EmailFileAttachment> EmailFileAttachments = new List<Messaging.EmailFileAttachment>();
            System.debug('--policyId--' + policyId);
            System.debug('--EmailAddress--' + EmailAddress);
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            // Replace Visualforce(AccountDetails) page with your visualforce page
            PageReference pref;
            PageReference pref2;
            
            String englishFileName,spanishFileName;
            if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                englishFileName = System.Label.Chubb_English_Automobile;
                spanishFileName = System.Label.Chubb_Spanish_Automobile;
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                englishFileName = System.Label.Chubb_English_RV;
                spanishFileName = System.Label.Chubb_Spanish_RV;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                englishFileName = System.Label.Chubb_English_Motorcycle;
                spanishFileName = System.Label.Chubb_Spanish_Motorcycle;
            }
            if(underWriter != null && underWriter == 'Chubb'){
                List<ContentVersion> contentVersions = new List<ContentVersion>([
                Select Id,ContentDocument.Title,Title,VersionData,FileExtension from ContentVersion Where 
                                ContentDocument.Title =:englishFileName OR 
                                ContentDocument.Title =:spanishFileName]);
                for(ContentVersion eachCv : contentVersions ){
                    Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                    emlAtt.setFilename(eachCv.title+'.' + eachCv.FileExtension);
                    Blob fileData = eachCv.VersionData;
                    emlAtt.setBody(fileData);
                    EmailFileAttachments.add(emlAtt);
                }
            }
            
            set<String> documentNames = new set<String>();
            String DeveloerName = '';
            if (policyType == 'Northbound') {
                pref = Page.Declaration_Page_Insurance_2;
                pref2 = Page.renderAsPdf;
                DeveloerName = 'Terms_and_Conditions_Northbound';
                documentNames.add('Terms_and_Conditions_Northbound_Spanish');
                
            }else if ( policyType == 'Driver License') {
                pref = Page.policy_declaration_driver_license;
                DeveloerName = 'Terms_and_Conditions_Driver_License';
                
            }else if ( policyType == 'Watercraft') {
                pref = Page.watercraft_policy_declaration_Page;
                DeveloerName = 'Terms_and_Conditions_Watercraft';
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                pref = page.Southbound_PolicyDec_Chubb;
                DeveloerName = 'Terms_and_Conditions_Automobile_Chubb';
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Mapfre' ){
                pref = page.Southbound_PolicyDeclarationPage_Mapfre;
                DeveloerName = 'Terms_and_Conditions_Automobile_Mapfre';
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Qualitas' ){
                pref = page.Southbound_PolicyDecPage_Qualitas;
                DeveloerName = 'Terms_and_Conditions_Automobile_Qualitas';
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                pref = page.Southbound_Chubb_RV;
                DeveloerName = 'Terms_and_Conditions_RV_Chubb';
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Mapfre' ){
                pref = page.Southbound_Mapfre_RV;
                DeveloerName = 'Terms_and_Conditions_RV_Mapfre';
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Qualitas' ){
                pref = page.Southbound_Qualitas_RV;
                DeveloerName = 'Terms_and_Conditions_RV_Qualitas';
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Qualitas' ){
                pref = page.Southbound_Qualitas_Motorcycle;
                DeveloerName = 'Terms_and_Conditions_Motorcycle_Qualitas';
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Mapfre' ){
                pref = page.Southbound_Mapfre_Motorcycle;
                DeveloerName = 'Terms_and_Conditions_Motorcycle_Mapfre';
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                pref = page.Southbound_ChubbMotorcycle;
                DeveloerName = 'Terms_and_Conditions_Motorcycle_Chubb';
            }
            
            pref.getParameters().put('id', policyId);
            pref2.getParameters().put('id', policyId);
            pref.setRedirect(true);
            pref2.setRedirect(true);
            
            Blob b = null;
            Blob yellowCardDoc = null;
            if (!Test.isRunningTest()) {
                b = pref.getContent();
                yellowCardDoc = pref2.getContent();
            } else if (Test.isRunningTest()) {
                b = Blob.valueOf('Testing');
                yellowCardDoc = Blob.valueOf('Testing');
            }
            attach.setFileName(policyName);
            attach.setBody(b);
            EmailFileAttachments.add(attach);
            
            Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
            attach2.setFileName(attachmentName2 + '.Pdf');
            attach2.setBody(yellowCardDoc);
            EmailFileAttachments.add(attach2);
            
            documentNames.add(DeveloerName);
            List<Document> DocumentList = new List<Document>();
            if( DeveloerName != null && DeveloerName != '' && underWriter != null && underWriter != 'Chubb'){
                DocumentList = [SELECT Id, Body, Name, DeveloperName FROM Document WHERE DeveloperName IN: documentNames];
            }
            
            for (Document doc : DocumentList) {
                attach = new Messaging.EmailFileAttachment();
                attach.setFileName(doc.DeveloperName + '.pdf');
                attach.setBody(doc.Body);
                EmailFileAttachments.add(attach);
            }
            setupEmailParams(contactId);
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            if (policyType == 'Northbound') {
                EmailTemplate emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :keyVsTemplates.get('Northbound_Policy_Purchase_Template')];
                semail.setTemplateId(emailTemplate.Id);
            } else if (policyType == 'Driver License') {
                EmailTemplate emailTemplate = [SELECT Id, Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :keyVsTemplates.get('Driver_License_Policy_Purchase_Template')];
                semail.setTemplateId(emailTemplate.Id);
            }
            
            //semail.setSubject('Quote Details');
            OrgWideEmailAddress[] senderEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: policyFromEmailAddress];
            semail.setOrgWideEmailAddressId(senderEmail.get(0).Id);
            
            semail.setToAddresses(new List<String>{
                EmailAddress
            });
            semail.setTargetObjectId(contactId);
            semail.setUseSignature(false);
            semail.setBccSender(false);
            semail.setSaveAsActivity(false);
            //semail.setPlainTextBody('Please find the attached Quote details');
            semail.setFileAttachments(EmailFileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                semail
            });
            
            
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            System.debug('*****exception***' + e.getMessage() + '---line-' + e.getLineNumber());
        }
    }
    @AuraEnabled
    public static String getPolicyDetails(String quoteIds) {
        try {
            if (quoteIds != null && quoteIds != '') {
                Set<String> quoteIdList = new Set<String>();
                quoteIdList = (Set<String>) JSON.deserialize(quoteIds, Set<String>.class);
                
                List<Transaction__c> tranList = [SELECT Id, Amount__c, Tax_Iva__c From Transaction__c Where Quote_c__c In :quoteIdList Order By CreatedDate Desc Limit 1];
                
                if (tranList != null && tranList.size() > 0) {
                    return JSON.serialize(tranList);
                }
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }
    
    
    //*******************Driver License******************** */
    @AuraEnabled
    public static String driverLicenseQuote(String leadRecord, Quote__c quoteRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            
            Map<String, Object> ldObjectMap = new Map<String, Object>();
            ldObjectMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord);
            String leadId;
            if(!Test.isRunningTest()) {
                leadId = Mex_Insurance_Calloututility.getLeadId(ldObjectMap);
            }
            
            
            String userType = UserInfo.getUserType();
            if ((leadId == null || leadId == '') && (userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                
                ldObjectMap.put('Company', 'Driver Licence Insurance');
                ldObjectMap.put('Date_of_Birth__c', quoteRecord.Date_of_Birth__c);
                ldObjectMap.put('Status', 'New');
                
                if (ldObjectMap.containsKey('sobjectType')) {
                    ldObjectMap.remove('sobjectType');
                }
                leadId = Mex_Insurance_Calloututility.createLead_Record(ldObjectMap);
            }
            
            if (leadId != null && userType.equalsIgnoreCase('Guest')) {
                quoteRecord.Lead__c = leadId;
                List<Lead> leads = new List<Lead>();
                leads = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leadId AND IsConverted = TRUE LIMIT 1];
                if (leads != null && !leads.isEmpty()) {
                    quoteRecord.Contact__c = leads[0].ConvertedContactId;
                    quoteRecord.Account__c = leads[0].ConvertedAccountId;
                }
            }
            if (userType != null && !userType.equalsIgnoreCase('Guest')) {
                List<User> loginUserList = new List<User>();
                loginUserList = getloginUser();
                if (loginUserList != null && !loginUserList.isEmpty()) {
                    quoteRecord.Contact__c = loginUserList[0].ContactId;
                    quoteRecord.Account__c = loginUserList[0].Contact.AccountId;
                }
            }
            
            if (quoteRecord.Date_of_Birth__c != null) {
                Integer year = System.today().year() - quoteRecord.Date_of_Birth__c.year();
                if (year != null && year < 21) {
                    quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
                } else {
                    quoteRecord.Is_there_a_driver_under_21__c = 'No';
                }
                
                if (year != null && year > 75) {
                    quoteRecord.Is_there_a_driver_over_75__c = 'Yes';
                } else {
                    quoteRecord.Is_there_a_driver_over_75__c = 'No';
                }
                
            }
            
            if (quoteRecord.Id == null) {
                quoteRecord.Quote_Status__c = 'Draft';
            }
            
            
            upsert quoteRecord Id;
            
            responseMap.put('success', true);
            responseMap.put('leadId', leadId);
            responseMap.put('quoteId', quoteRecord.Id);
            
            
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return JSON.serialize(responseMap);
    }
    
    
    /*
    method : getquickQuoteDataSouthBound
        description: get rate data for south bound
         */
    @AuraEnabled
    public static String getquickQuoteDataSouthBound(Quote__c quoteRecord, String qualitasLiability,
    String chubbLiability, String mapfreLiability,
    String qualitasMedical, String chubbMedical, String mapfreMedical,
    String twoedunitId ) {
        
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            
            System.debug('--qualitasLiability--' + qualitasLiability);
            System.debug('--chubbLiability--' + chubbLiability);
            System.debug('--mapfreLiability--' + mapfreLiability);
            
            System.debug('--qualitasMedical--' + qualitasMedical);
            System.debug('--chubbMedical--' + chubbMedical);
            System.debug('--mapfreMedical--' + mapfreMedical);
            System.debug('--twoedunitId--' + twoedunitId);
            Integer days = 0 ;
            if (quoteRecord != null
            && quoteRecord.Start_Date_for_Coverage__c != null && quoteRecord.End_Date_for_Coverage__c != null) {
                
                days = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
            }
            
            System.debug('--days--' + days);
            System.debug('--quoteRecord.Vehicle_Value__c--' + quoteRecord);
            list<Towed_Unit__c> towedUnits = new list<Towed_Unit__c>();
            //towedUnits = QuickQuotationCtrl.getTowedUnit(quoteRecord.Id);
            list<Quote_Towed_Unit__c> quoteTowedUnits = new list<Quote_Towed_Unit__c>();
            
            
            if( twoedunitId != null && twoedunitId != ''){
                towedUnits = [SELECT id, ownerid,Days_in_Tow__c, name, lastactivitydate, policy__c, towed_unit_type__c, towed_unit_value__c, towing_terms__c, street_legal__c, vin_number__c, year__c, make__c, model__c, quote_c__c, plate__c, contact__c, account__c, lead__c FROM Towed_Unit__c where Id =: twoedunitId ];
                
            }else{
                //towedUnits = [SELECT id, ownerid,Days_in_Tow__c, name, lastactivitydate, policy__c, towed_unit_type__c, towed_unit_value__c, towing_terms__c, street_legal__c, vin_number__c, year__c, make__c, model__c, quote_c__c, plate__c, contact__c, account__c, lead__c FROM Towed_Unit__c where Quote_c__c =:quoteRecord.Id ];
                towedUnits = [SELECT id, ownerid,Days_in_Tow__c, name, lastactivitydate, policy__c, towed_unit_type__c, towed_unit_value__c, towing_terms__c, street_legal__c, vin_number__c, year__c, make__c, model__c, quote_c__c, plate__c, contact__c, account__c, lead__c FROM Towed_Unit__c where id IN (select Towed_Unit__c from Quote_Towed_Unit__c where Quote_c__c =:quoteRecord.Id) ];
            }
            system.debug('@@@ towedUnits = '+towedUnits);
            decimal tempDriverAge = 21;
            if(quoteRecord != null && quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                tempDriverAge = 19;
            }
            system.debug('--VehicleType-- '+quoteRecord.Vehicle_Type__c);
            if(quoteRecord.Vehicle_Type__c != null && quoteRecord.Vehicle_Type__c == 'Car/Truck/Auto' ){
                ChubbAutomobile.QuotesChubbwrapper QuotesChubbData = ChubbAutomobile.calculate(quoteRecord.Vehicle_Value__c, days, decimal.valueof(chubbLiability), chubbMedical, quoteRecord.Territory_Coverage__c, quoteRecord.Vehicle_Sub_type__c, towedUnits);
                responseMap.put('ChubbData', QuotesChubbData);
                
                MapfreAutomobile.Quoteswrapper QuotesMapfreData = MapfreAutomobile.calculate('Automobile',quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(mapfreLiability), mapfreMedical, quoteRecord.Vehicle_Sub_type__c, towedUnits);
                responseMap.put('MapfreData', QuotesMapfreData);
                
                QualitasAutomobile.QuotesQualitasWrapper QuotesData = QualitasAutomobile.calculate('Automobile',quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(qualitasLiability), qualitasMedical, towedUnits, tempDriverAge, quoteRecord.Vehicle_used_for_Business_Purposes__c, quoteRecord.Is_this_a_Rental_Vehicle__c);
                responseMap.put('qualitasData', QuotesData);
            }
            else if(quoteRecord.Vehicle_Type__c != null && quoteRecord.Vehicle_Type__c == 'Motorcycle/Street Legal ATV' ){
                ChubbMotorcycle.QuotesChubbwrapper QuotesChubbData = ChubbMotorcycle.calculate(quoteRecord.Vehicle_Value__c, days, decimal.valueof(chubbLiability), chubbMedical, quoteRecord.Territory_Coverage__c, 'Motorcycle', towedUnits);
                responseMap.put('ChubbData', QuotesChubbData);
                
                MapfreMotorcycle.Quoteswrapper QuotesMapfreData = MapfreMotorcycle.calculate('Motorcycle', quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(mapfreLiability), mapfreMedical, quoteRecord.Vehicle_Sub_type__c, towedUnits);
                responseMap.put('MapfreData', QuotesMapfreData);
                
                QualitasMotorcycle.QuotesQualitasWrapper QuotesData = QualitasMotorcycle.calculate('Motorcycle', quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(qualitasLiability), qualitasMedical, towedUnits, tempDriverAge, quoteRecord.Vehicle_used_for_Business_Purposes__c, quoteRecord.Is_this_a_Rental_Vehicle__c);
                responseMap.put('qualitasData', QuotesData);
            }
            else if(quoteRecord.Vehicle_Type__c != null && quoteRecord.Vehicle_Type__c == 'RV' ){
                
                ChubbRV.QuotesChubbwrapper QuotesChubbData = ChubbRV.calculate(quoteRecord.Vehicle_Value__c, days, decimal.valueof(chubbLiability), chubbMedical, quoteRecord.Territory_Coverage__c, 'RV', towedUnits);
                system.debug('--QuotesChubbData-- ' + QuotesChubbData);
                responseMap.put('ChubbData', QuotesChubbData);
                
                MapfreRV.Quoteswrapper QuotesMapfreData = MapfreRV.calculate('RV',quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(mapfreLiability), mapfreMedical, quoteRecord.Vehicle_Sub_type__c, towedUnits);
                responseMap.put('MapfreData', QuotesMapfreData);
                
                QualitasRV.QuotesQualitasWrapper QuotesData = QualitasRV.calculate('RV',quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(qualitasLiability), qualitasMedical, towedUnits, tempDriverAge, quoteRecord.Vehicle_used_for_Business_Purposes__c, quoteRecord.Is_this_a_Rental_Vehicle__c);
                responseMap.put('qualitasData', QuotesData);
            }
            else{
                ChubbAutomobile.QuotesChubbwrapper QuotesChubbData = ChubbAutomobile.calculate(quoteRecord.Vehicle_Value__c, days, decimal.valueof(chubbLiability), chubbMedical, quoteRecord.Territory_Coverage__c, quoteRecord.Vehicle_Sub_type__c, towedUnits);
                responseMap.put('ChubbData', QuotesChubbData);
                
                MapfreAutomobile.Quoteswrapper QuotesMapfreData = MapfreAutomobile.calculate('Automobile',quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(mapfreLiability), mapfreMedical, quoteRecord.Vehicle_Sub_type__c, towedUnits);
                responseMap.put('MapfreData', QuotesMapfreData);
                
                QualitasAutomobile.QuotesQualitasWrapper QuotesData = QualitasAutomobile.calculate('Automobile',quoteRecord.Vehicle_Value__c, days, Decimal.valueOf(qualitasLiability), qualitasMedical, towedUnits, tempDriverAge, quoteRecord.Vehicle_used_for_Business_Purposes__c, quoteRecord.Is_this_a_Rental_Vehicle__c);
                responseMap.put('qualitasData', QuotesData);
            }
            
            
            
            responseMap.put('days', days);
            
        } catch (Exception e) {
            System.debug('--exception--' + e.getMessage() + '---line--' + e.getLineNumber() + '---track' + e.getStackTraceString());
        }
        
        System.debug('--responseMap---' + responseMap);
        return JSON.serialize(responseMap);
    }
    
    @AuraEnabled
    public static Map<String, Object> createOrUpdateHomeOwner(String leadrecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Map<String, Object> ldObjectMap = new Map<String, Object>();
            ldObjectMap = (Map<String, Object>) JSON.deserializeUntyped(leadrecord);
            String leadId = Mex_Insurance_Calloututility.getLeadId(ldObjectMap);
            
            String userType = UserInfo.getUserType();
            if ((leadId == null || leadId == '') && (userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                
                ldObjectMap.put('Company', 'HomeOwners Insurance');
                ldObjectMap.put('Status', 'New');
                ldObjectMap.put('LeadSource', 'Homeowners Policy');
                ldObjectMap.put('Insurance_Type__c', 'Homeowners');
                
                if (ldObjectMap.containsKey('sobjectType')) {
                    ldObjectMap.remove('sobjectType');
                }
                leadId = Mex_Insurance_Calloututility.createLead_Record(ldObjectMap);
            }
            
            if (leadId != null && ( userType.equalsIgnoreCase('Guest') || Test.isRunningTest() )  ) {
                List<Lead> leads = new List<Lead>();
                leads = [SELECT Id, FirstName, LastName, Phone, Company, LeadSource, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leadId AND IsConverted = FALSE LIMIT 1];
                if (leads != null && !leads.isEmpty()) {
                    leads[0].FirstName = String.valueOf(ldObjectMap.get('FirstName'));
                    leads[0].LastName = String.valueOf(ldObjectMap.get('LastName'));
                    leads[0].Phone = String.valueOf(ldObjectMap.get('Phone'));
                    leads[0].LeadSource = 'Homeowners Policy';
                    leads[0].Company = 'HomeOwners Insurance';
                    leads[0].Insurance_Type__c = 'Homeowners';
                    
                    update leads;
                }
            }
            responseMap.put('success', true);
            responseMap.put('leadId', leadId);
            
        } catch (Exception e) {
            System.debug('@@@2846'+e.getMessage()+e.getStackTraceString());
            CustomErrorExceptionHandlerException.LogException(e);
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }
    
    
    @AuraEnabled
    public static Map<String, List<String>> getDependentMap(SObject objDetail, String contrfieldApiName, String depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String, List<String>> objResults = new Map<String, List<String>>();
        
        Schema.SObjectType objType = objDetail.getSObjectType();
        if (objType == null) {
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
            return objResults;
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    @AuraEnabled
    public static Map<String, Object> createNewDriver(Driver__c driverRecord){
        QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            
            list<User> userList = new list<User>();
            userList = [select Id, contactId, Contact.accountId from User where Id=: UserInfo.getUserId() and contactId != null ];
            if(userList != null && !userList.isEmpty() ){
                driverRecord.Name = driverRecord.First_Name__c + ' ' + driverRecord.Last_Name__c;
                
                if( driverRecord.Account_Driver__c == null ){
                    driverRecord.Account_Driver__c = userList[0].Contact.accountId;
                }
                
                if( driverRecord.Contact__c == null ){
                    driverRecord.Contact__c = userList[0].contactId;
                }
                
                Database.upsert(driverRecord, false);
                if( driverRecord != null && driverRecord.Id != null ){
                    responseMap.put('success',true);
                    responseMap.put('driverId',driverRecord.Id);
                }
            }
        }catch(exception ex ){
            System.debug('-ex--'+ex.getMessage());
            responseMap.put('success',false);
            responseMap.put('message',ex.getMessage());
        }
        
        return responseMap;
    }
    
    @AuraEnabled
    public static Quote__c getQuoteRecord(String quoteId) {
        try {
            Quote__c quote = [
                SELECT Id, Driver_Age__c, Underwriter__c, Policy_Type_picklist__c, Coverage__c, Territory__c,Broker_Policy_Fee__c,
                I_V_A_Mex_Tax__c, Net_Premium__c, Term__c, Term_Days__c, Vehicle_Type__c, Start_Date_for_Coverage__c, End_Date_for_Coverage__c,
                End_Time__c, Start_Time__c, Quote_Value__c, Medical__c, Liability__c, Vehicle_Value__c
                FROM Quote__c
                WHERE Id = :quoteId
                LIMIT 1
            ];
            
            return quote;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Driver__c> getCurrentUserDrivers() {
        list<User> users = new list<User>();
        users = [select Id, contactId from User where Id=: UserInfo.getUserId() limit 1];
        if( users != null && !users.isEmpty() && users[0].contactId != null ){
            list<Quote_Driver__c> quotedrivers = new list<Quote_Driver__c>();
            quotedrivers = [select Driver__c from Quote_Driver__c where Contact__c =: users[0].contactId or createdbyId =: UserInfo.getUserId() ];
            set<String> driversIds = new set<String>();
            if( quotedrivers != null && !quotedrivers.isEmpty()){
                for(Quote_Driver__c qdr : quotedrivers){
                    driversIds.add( qdr.Driver__c );
                }
            }
            String query = getQueryWithAllFields(Driver__c.getSObjectType().getDescribe().getName());
            query += ' where Id IN: driversIds or createdbyId=\''+UserInfo.getUserId()+'\'';
            return Database.query(query);
            //return [Select Id, Name, First_Name__c, Last_Name__c, license_number__c, Driver_Type__c From Driver__c where Id IN ( select Driver__c from Quote_Driver__c where Contact__c =: users[0].contactId ) limit 1000];
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Towed_Unit__c> getCurrentUserTransporate() {
        list<User> users = new list<User>();
        users = [select Id, contactId from User where Id=: UserInfo.getUserId() limit 1];
        if( users != null && !users.isEmpty() && users[0].contactId != null ){
            list<Quote_Towed_Unit__c> quoteTowedUnits = new list<Quote_Towed_Unit__c>();
            quoteTowedUnits = [select Id, Towed_Unit__c from Quote_Towed_Unit__c where Contact__c =: users[0].contactId or createdbyId =: UserInfo.getUserId()];
            //return [Select Id, Name, VIN_Number__c, Make__c, Model__c From Towed_Unit__c where Id IN ( select Towed_Unit__c from Quote_Towed_Unit__c where Contact__c =: users[0].contactId ) limit 1000];
            set<String> towedIds = new set<String>();
            if( quoteTowedUnits != null && !quoteTowedUnits.isEmpty()){
                for(Quote_Towed_Unit__c qtu : quoteTowedUnits){
                    towedIds.add( qtu.Towed_Unit__c );
                }
            }
            String query = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
            query += ' where Id IN: towedIds or createdbyId=\''+UserInfo.getUserId()+'\'';
            return Database.query(query);
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Vehicle__c> getCurrentUserVehicles( String policyType ) {
        list<User> users = new list<User>();
        users = [select Id, contactId from User where Id=: UserInfo.getUserId() limit 1];
        
        set<String> vehicletypeFilters;
        if( policyType != null && policyType.equalsIgnoreCase('Automobile')){
            vehicletypeFilters = new set<String>{'Automobile/Sedan', 'Pickup Truck w or w/o Camper Shell', 'SUV', 'Van'};
        }else if( policyType != null && policyType.equalsIgnoreCase('Motorcycle/Street Legal ATV') ){
            vehicletypeFilters = new set<String>{'Motorcycle', 'Street Legal ATV'};
        }else if( policyType != null && policyType.equalsIgnoreCase('RV') ){
            vehicletypeFilters = new set<String>{'Motor Home / RV'};
        }
        if( users != null && !users.isEmpty() && users[0].contactId != null ){
            list<Quote_Vehicle__c> quoteVechiles = new list<Quote_Vehicle__c>();
            quoteVechiles = [select Vehicle__c from Quote_Vehicle__c where Contact__c =: users[0].contactId or createdbyId =: UserInfo.getUserId() ];
            //return [Select Id, Name, VIN_Number__c, Make__c, Model__c From Towed_Unit__c where Id IN ( select Towed_Unit__c from Quote_Towed_Unit__c where Contact__c =: users[0].contactId ) limit 1000];
            set<String> vechileIds = new set<String>();
            if( quoteVechiles != null && !quoteVechiles.isEmpty() ){
                
                for(Quote_Vehicle__c qvl : quoteVechiles){
                    vechileIds.add( qvl.Vehicle__c );
                }
                System.debug('--vechileIds---'+vechileIds);
                System.debug('--vehicletypeFilters---'+vehicletypeFilters);
            }
            String query = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
            query += ' where ( Id IN: vechileIds or createdbyId=\''+UserInfo.getUserId()+'\' )';
            if( vehicletypeFilters != null && !vehicletypeFilters.isEmpty()){
                query += ' And Vehicle_Type__c IN: vehicletypeFilters';
            }
            if( policyType != null && policyType.equalsIgnoreCase('Northbound')){
                query += ' And Registered_Country__c = \'Mexico\'';
            }else {
                query += ' And Registered_Country__c != \'Mexico\'';
            }
            System.debug('--query---'+query);
            return Database.query(query);
        }
        return null;
    }
    
    @AuraEnabled
    public static boolean checkRateTableExist( decimal vehicleValue, String mainvehicleType ) {
        list<Rate_Table__c> mapfreRate = new list<Rate_Table__c>();
        list<Rate_Table__c> ChubbRate = new list<Rate_Table__c>();
        list<Rate_Table__c> QualitasRate = new list<Rate_Table__c>();
        system.debug('@@ mainvehicleType '+mainvehicleType);
        if(mainvehicleType != null && mainvehicleType == 'Motorcycle/Street Legal ATV'){
            mainvehicleType = 'Motorcycle';
        }
        mapfreRate = [Select Risk_1_Physical_Damages__c,Risk_2_Total_Theft__c from Rate_Table__c 
                      where Underwriter__c = 'Mapfre' and type__c =: mainvehicleType and High_Value__c >=: vehicleValue and Low_Value__c <=: vehicleValue limit 1];
        
        ChubbRate = [Select Daily_Rate__c, Semi_Annual_Rate__c, Annual_Rate__c, Daily_Rate_Total_Theft__c, Semi_Annual_Total_Theft__c, Annual_Total_Theft__c  from Rate_Table__c 
                     where Underwriter__c = 'Chubb' and type__c =: mainvehicleType and High_Value__c >=: vehicleValue and Low_Value__c <=: vehicleValue];
        
        QualitasRate = [Select Daily_Rate__c, Semi_Annual_Rate__c, Annual_Rate__c, Daily_Rate_Total_Theft__c,               Semi_Annual_Total_Theft__c, Annual_Total_Theft__c  
                        from Rate_Table__c where Underwriter__c = 'Qualitas' and type__c =: mainvehicleType and High_Value__c >=: vehicleValue 
                        and Low_Value__c <=: vehicleValue];
        
        if( mapfreRate.isEmpty() && ChubbRate.isEmpty() && QualitasRate.isEmpty() ){
            return true;
        }
        return false;
    }
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper {
        public String active {
            get;
            set;
        }
        public String defaultValue {
            get;
            set;
        }
        public String label {
            get;
            set;
        }
        public String value {
            get;
            set;
        }
        public String validFor { get; set; }
        public PicklistEntryWrapper() {
        }
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    @AuraEnabled
    public static Account retrieveAffiliateAccount(String affiliateNumber) {
        Account acc = [
            SELECT Id
            FROM Account
            WHERE Affiliate_Number__c = :affiliateNumber
            LIMIT 1
        ];
        
        return acc;
    }
    
    @AuraEnabled
    public static Legal_Term__c retrieveLegalTermDetails(String policyType, String underwriter){
        Legal_Term__c legalTerm = [
            SELECT Id, Terms_of_Purchase_and_Use__c, Terms_of_Cancellation__c, Daily_Policy_Cancellation__c, Semi_Annual_and_Annual_Policy_Cancellati__c
            FROM Legal_Term__c
            WHERE Policy_Type__c = :policyType
            AND Underwriter__c = :underwriter
            LIMIT 1
        ];
        
        return legalTerm;
    }
    
    @AuraEnabled
    public static List<Transaction__c> retrieveTransactionDetailsByQuoteId(String quoteId){
        List<Transaction__c> transactions = [
            SELECT Id, Id__c
            FROM Transaction__c
            WHERE Quote_c__c = :quoteId
            LIMIT 1
        ];
        
        return transactions;
    }
    
    @AuraEnabled
    public static List<Watercraft__c> retrieveWatercraftDetailsByQuoteId(String quoteId){
        
        list<Quote_Watercraft__c> quoteWatercrafts = new list<Quote_Watercraft__c>();
        
        quoteWatercrafts = [select Watercraft__c, Quote_c__c from Quote_Watercraft__c where Policy__c =: quoteId OR Quote_c__c =: quoteId ];
        system.debug(quoteWatercrafts);
        if( quoteWatercrafts != null && !quoteWatercrafts.isEmpty()){
            set<String> WatercraftIds = new set<String>();
            for(Quote_Watercraft__c qdr : quoteWatercrafts){
                WatercraftIds.add( qdr.Watercraft__c );
            }
            String query = QuickQuotationCtrl.getQueryWithAllFields(Watercraft__c.getSObjectType().getDescribe().getName());
            query += ' where Id IN: WatercraftIds';
            system.debug(query);
            return Database.query(query);
        }
        
        /*List<Watercraft__c> watercrafts = [
        SELECT Id, Year__c, Make__c, Model__c, Value__c, Type_of_Vessel__c, 
        Vessel_Length__c, VIN_Number__c, Beam__c, Flag__c, Engine_Type__c
        FROM Watercraft__c
        WHERE Quote_c__c = :quoteId
        LIMIT 1
        ];*/
        
        return null;
    }
    
    @AuraEnabled
    public static List<object> getYears(){
        return VehicalAPIController.getYears();
    }
    
    @AuraEnabled
    public static List<object> getMakes(string year){
        return VehicalAPIController.getMakes(year);
    }
    
    @AuraEnabled
    public static List<object> getModels(string year, string make){
        return VehicalAPIController.getModels(year, make);
    }
    public class UserLicenseExceedException extends Exception {}
    public static String getCountryCode(String country ){
        if( country != null ){
            country = country.trim().toLowerCase();
            map<String,String> countryVsCodeMap = new map<String,String>();
            countryVsCodeMap.put('united states', 'US');
            countryVsCodeMap.put('unitedstates', 'US');
            countryVsCodeMap.put('canada', 'CA');
            countryVsCodeMap.put('mexico', 'MX');
            
            if( countryVsCodeMap.containsKey(country)){
                return countryVsCodeMap.get(country);
            }
        }
        return null;
    }
    
    public static String getStateCode(String state ){
        if( state != null ){
            state = state.trim().toLowerCase();
            map<String,String> stateVsCodeMap = new map<String,String>();
            stateVsCodeMap.put('alberta', 'AB');
            stateVsCodeMap.put('british columbia', 'BC');
            stateVsCodeMap.put('manitoba', 'MB');
            stateVsCodeMap.put('new brunswick', 'NB');
            stateVsCodeMap.put('newfoundland', 'NL');
            stateVsCodeMap.put('northwest territories', 'NT');
            stateVsCodeMap.put('nova scotia', 'NS');
            stateVsCodeMap.put('nunavut', 'NU');
            stateVsCodeMap.put('ontario', 'ON');
            stateVsCodeMap.put('prince edward island', 'PE');
            stateVsCodeMap.put('quebec', 'QC');
            stateVsCodeMap.put('saskatchewan', 'SK');
            stateVsCodeMap.put('yukon', 'YT');
            
            stateVsCodeMap.put('alabama', 'AL');
            stateVsCodeMap.put('alaska', 'AK');
            stateVsCodeMap.put('arizona', 'AZ');
            stateVsCodeMap.put('arkansas', 'AR');
            stateVsCodeMap.put('california', 'CA');
            stateVsCodeMap.put('colorado', 'CO');
            stateVsCodeMap.put('connecticut', 'CT');
            stateVsCodeMap.put('delaware', 'DE');
            stateVsCodeMap.put('florida', 'FL');
            stateVsCodeMap.put('georgia', 'GA');
            stateVsCodeMap.put('hawaii', 'HI');
            stateVsCodeMap.put('idaho', 'ID');
            stateVsCodeMap.put('illinois', 'IL');
            stateVsCodeMap.put('indiana', 'IN');
            stateVsCodeMap.put('iowa', 'IA');
            stateVsCodeMap.put('kansas', 'KS');
            stateVsCodeMap.put('kentucky', 'KY');
            stateVsCodeMap.put('louisiana', 'LA');
            stateVsCodeMap.put('maine', 'ME');
            stateVsCodeMap.put('maryland', 'MD');
            stateVsCodeMap.put('massachusetts', 'MA');
            stateVsCodeMap.put('michigan', 'MI');
            stateVsCodeMap.put('minnesota', 'MN');
            stateVsCodeMap.put('mississippi', 'MS');
            stateVsCodeMap.put('missouri', 'MO');
            stateVsCodeMap.put('montana', 'MT');
            stateVsCodeMap.put('nebraska', 'NE');
            stateVsCodeMap.put('nevada', 'NV');
            stateVsCodeMap.put('new hampshire', 'NH');
            stateVsCodeMap.put('new jersey', 'NJ');
            stateVsCodeMap.put('new mexico', 'NM');
            stateVsCodeMap.put('new york', 'NY');
            stateVsCodeMap.put('north carolina', 'NC');
            stateVsCodeMap.put('ohio', 'OH');
            stateVsCodeMap.put('north dakota', 'ND');
            stateVsCodeMap.put('oklahoma', 'OK');
            stateVsCodeMap.put('oregon', 'OR');
            stateVsCodeMap.put('pennsylvania', 'PA');
            stateVsCodeMap.put('rhode island', 'RI');
            stateVsCodeMap.put('south carolina', 'SC');
            stateVsCodeMap.put('south dakota', 'SD');
            stateVsCodeMap.put('tennessee', 'TN');
            stateVsCodeMap.put('texas', 'TX');
            stateVsCodeMap.put('utah', 'UT');
            stateVsCodeMap.put('vermont', 'VT');
            stateVsCodeMap.put('virginia', 'OR');
            stateVsCodeMap.put('washington', 'WA');
            stateVsCodeMap.put('west virginia', 'WV');
            stateVsCodeMap.put('wisconsin', 'WI');
            stateVsCodeMap.put('wyoming', 'WY');
            
            stateVsCodeMap.put('aguascalientes', 'AG');
            stateVsCodeMap.put('baja california', 'BN');
            stateVsCodeMap.put('baja california sur', 'BS');
            stateVsCodeMap.put('campeche', 'CP');
            stateVsCodeMap.put('chihuahua', 'CI');
            stateVsCodeMap.put('chiapas', 'CS');
            stateVsCodeMap.put('coahuila', 'CH');
            stateVsCodeMap.put('colima', 'CL');
            stateVsCodeMap.put('distrito federal', 'DF');
            stateVsCodeMap.put('durango', 'DG');
            stateVsCodeMap.put('guerrero', 'GE');
            stateVsCodeMap.put('guanajuato', 'GJ');
            stateVsCodeMap.put('hidalgo', 'HD');
            stateVsCodeMap.put('jalisco', 'JA');
            stateVsCodeMap.put('méxico', 'MX');
            stateVsCodeMap.put('michoacán', 'MC');
            stateVsCodeMap.put('morelos', 'MR');
            stateVsCodeMap.put('nayarit', 'NA');
            stateVsCodeMap.put('nuevo leónn', 'NL');
            stateVsCodeMap.put('oaxaca', 'OA');
            stateVsCodeMap.put('puebla', 'PU');
            stateVsCodeMap.put('querétaro', 'QE');
            stateVsCodeMap.put('quintana roo', 'QI');
            stateVsCodeMap.put('sinaloa', 'SI');
            stateVsCodeMap.put('san luís potosí', 'SL');
            stateVsCodeMap.put('sonora', 'SO');
            stateVsCodeMap.put('tabasco', 'TB');
            stateVsCodeMap.put('tamaulipas', 'TA');
            stateVsCodeMap.put('tlaxcala', 'TL');
            stateVsCodeMap.put('veracruz",', 'VC');
            stateVsCodeMap.put('yucatán', 'YU');
            stateVsCodeMap.put('zacatecas', 'ZA');
            
            
            if( stateVsCodeMap.containsKey(state)){
                return stateVsCodeMap.get(state);
            }
        }
        return null;
    }
    
}