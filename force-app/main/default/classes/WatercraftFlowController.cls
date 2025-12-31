public without sharing class WatercraftFlowController {

    @AuraEnabled
    public static String initializeFlow(String quoteId) {
        System.debug('--initialize---');
        System.debug('--initialize quoteId---'+ quoteId);
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            String userType = UserInfo.getUserType();
            responseMap.put('isCommunityUser', !userType.equalsIgnoreCase('Guest'));
            if (userType != null && (!userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                system.debug('userInfo --> email   ->'+UserInfo.getUserEmail());
                User loginUser = (getloginUser())[0];
                system.debug('loginUser--->'+ loginUser);
                if (loginUser != null) {
                    responseMap.put('email', loginUser.Email);
                    responseMap.put('dob', loginUser?.Contact?.Date_of_Birth__c);
                }
                
                if (quoteId != null && quoteId != '') {
                    Quote__c quoteRecord = getQuoteWithAllFields(quoteId);
                    system.debug('CA log quoteRecord : '+ quoteRecord);
                    if (quoteRecord != null) {
                        responseMap.put('quoteRecord', quoteRecord);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('--exception---' + e.getMessage());
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
        return [SELECT Id, Name, LastName, Email, FirstName, Phone, IsConverted, ConvertedContactId, ConvertedAccountId, Company FROM Lead WHERE Id IN:recordIds];
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
    // @AuraEnabled
    // public static Quote__c getQuoteWithAllFields(String quoteId) {
    //     List<Quote__c> quotes = new List<Quote__c>();
    //     if (String.isNotBlank(quoteId)) {
    //         String query = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
    //         query += ' WHERE Id=\'' + quoteId + '\'';
    //         quotes = Database.query(query);
    //     }
    //     return !quotes.isEmpty() ? quotes[0] : null;
    // }
public static String getQueryWithAllFields(String objectName) {
        return 'SELECT ' + String.join(getAllFields(objectName), ', ') + ' FROM ' + objectName;
    }
    // private static String getQueryWithAllFields(String objectName) {
    //     return 'SELECT ' + String.join(getAllFields(objectName), ', ') + ' FROM ' + objectName;
    // }

    // private static Set<String> removeFields = new Set<String>{
    //         'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastvieweddate',
    //         'lastreferenceddate'
    // };
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
    // private static List<String> getAllFields(String objectName) {
    //     System.debug('--objectName--' + objectName);
    //     SObjectType objectType = describeObject(objectName);
    //     Map<String, Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();

    //     List<String> fieldsSet = new List<String>();
    //     for (String s : mfields.keySet()) {
    //         if ((mfields.get(s).getDescribe().isAccessible() && !removeFields.contains(String.valueOf(s).toLowerCase())) || Test.isRunningTest()) {
    //             fieldsSet.add(s);
    //         }
    //     }

    //     if (fieldsSet != null && !fieldsSet.contains('id')) {
    //         fieldsSet.add('id');
    //     }
    //     return fieldsSet;
    // }

     private static SObjectType describeObject(String objectName) {
         return Schema.getGlobalDescribe().get(objectName);
     }

    @AuraEnabled
    public static List<Object> getDataFromDataTable(Quote__c quoteObject, Boolean annualTerm) {
        try {
            List<Rate_Table__c> rateTables = new List<Rate_Table__c>();
		system.debug('quoteObject------> '+quoteObject);
            String term = null;
            if (annualTerm) {
                term = 'Annual';
            } else {
                term = 'Daily';
            }

            String rateQuery = 'select id, Total_Premium__c, Net_Premium__c, Broker_Policy_Fee__c, Package__c, Type__c, Days__c, Trailering_Surcharge__c, Term__c,';
            rateQuery += ' IVA_Mex_Tax__c, Underwriter__c, Age_of_Vehicle_Surcharge_25_years_old__c, Age_of_Vehicle_Surcharge__c, Age_of_Operator_Surcharge__c ';
            rateQuery += ' from Rate_Table__c ';
            rateQuery += ' where Type_of_Vessel__c = \'' + quoteObject.Type_of_Vessel__c + '\'';
            rateQuery += ' and Vessel_Length__c = \'' + String.escapeSingleQuotes(quoteObject.Vessel_Length__c) + '\'';
            rateQuery += ' and Third_Party_Bodily_Injury__c = \'' + quoteObject.Third_Party_Bodily_Injury__c + '\' and Property_Damage_Liability__c = \'' + quoteObject.Property_Damage_Liability__c + '\'';
            rateQuery += ' and Underwriter__c = \'' + 'Chubb' + '\' and Type__c = \'' + quoteObject.Policy_Type_picklist__c + '\'';
            if(quoteObject.Towed_Unit__c == 'Yes'){
                rateQuery += 'ORDER BY Term__c Desc';
            }else{
                rateQuery += 'ORDER BY Term__c ASC';
            }
            
            System.debug('rateQuery--->' + rateQuery);
            rateTables = Database.query(rateQuery);

            System.debug('**rateTables***' + rateTables);
            if (rateTables != null && !rateTables.isEmpty()) {
                return rateTables;
            }
            return null;
        } catch (Exception e) {
            System.debug('***Exception****' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String, Object> updateWatercraftAction(Watercraft__c watercraftRecord, Quote__c quoteRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            upsert watercraftRecord Id;
            upsert quoteRecord Id;

            responseMap.put('success', true);
            responseMap.put('watercraftId', watercraftRecord.Id);
            responseMap.put('quoteId', quoteRecord.Id);

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

            if (driverObject.Driver_Type__c == 'Owner') {
                if (String.isNotBlank(driverObject.Contact__c)) {
                    Contact contactRecord = updateRelatedContact(driverObject);
                    responseMap.put('contactUpdated', contactRecord);
                } else if(String.isNotBlank(driverObject.Lead__c) && UserInfo.getUserType().equalsIgnoreCase('Guest') ) {
                    Lead leadRecord = updateRelatedLead(driverObject);
                    responseMap.put('leadUpdated', leadRecord);
                }
            }

        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Map<String, Object> createWatercraftAction(Watercraft__c watercraftObject, Quote__c quoteObject, String leadId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            List<Watercraft__c> watercrafts = new List<Watercraft__c>();
            if (watercraftObject.VIN_Number__c != null) {
                watercrafts = [SELECT Id, VIN_Number__c FROM Watercraft__c WHERE VIN_Number__c = :watercraftObject.VIN_Number__c LIMIT 1];
            }

            if (!watercrafts.isEmpty()) {
                watercraftObject.Id = watercrafts[0].Id;
            }

            if (quoteObject.Id != null) {
                upsert quoteObject Id;
                
                /*watercraftObject.Quote_c__c = quoteObject.Id;
                watercraftObject.Account__c = quoteObject.Account__c;
                watercraftObject.Contact__c = quoteObject.Contact__c;*/
            } else if (String.isNotBlank(leadId)) {
                watercraftObject.Lead__c = leadId;
            }

            upsert watercraftObject Id;

            if (watercraftObject.Id != null && quoteObject.Id != null) {
                List<Quote_Watercraft__c> quoteVehicleList = new List<Quote_Watercraft__c>();
                quoteVehicleList = [SELECT Id FROM Quote_Watercraft__c WHERE Quote_c__c = :quoteObject.Id AND Watercraft__c = :watercraftObject.Id];

                if (quoteVehicleList == null || quoteVehicleList.isEmpty()) {
                    Quote_Watercraft__c quoteVehicle = new Quote_Watercraft__c();
                    quoteVehicle.Quote_c__c = quoteObject.Id;
                    quoteVehicle.Watercraft__c = watercraftObject.Id;
                    if (quoteVehicle.Contact__c == null && quoteVehicle.Account__c == null) {
                        if (quoteObject != null) {
                            quoteVehicle.Contact__c = quoteObject.Contact__c;

                            if (UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                                quoteVehicle.Lead__c = quoteObject.Lead__c;
                            }
                            quoteVehicle.Account__c = quoteObject.Account__c;
                        }
                    }
                    insert quoteVehicle;
                }

            }

            responseMap.put('success', true);
            responseMap.put('watercraftId', watercraftObject.Id);

        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static List<Driver__c> getRelatedDrivers(String quoteId) {
        List<Driver__c> drivers = new List<Driver__c>();
        if (String.isNotBlank(quoteId)) {
            drivers = [
                    SELECT Id, First_Name__c, Last_Name__c, license_number__c,
                            Email__c, Phone__c, Dob__c, Driver_Type__c, Address__c,
                            Address_Line_2__c, City__c, Country__c, Postal_Code__c,
                            State_Province__c, License_Country__c, License_state__c
                    FROM Driver__c
                    WHERE Quote_c__c = :quoteId
            ];
        }
        return drivers;
    }

    @AuraEnabled
    public static Map<String, Object> createDriverAction(Driver__c driverRecord, String quoteId, 
        Boolean isOwner, String watercraftId, Boolean Primary_insured) {
        Map<String, Object> responseMap = new Map<String, Object>();
        Database.UpsertResult upsertDriverRecord;
        String errorMessage = '';

        try {
            
            /*List<Driver__c> drivers = [
                SELECT Id, First_Name__c, Last_Name__c, Driver_Type__c, Email__c, Phone__c, Dob__c,
                        License_Country__c, License_state__c, license_number__c, Address__c, Address_Line_2__c,
                        City__c, Country__c, Postal_Code__c, State_Province__c
                FROM Driver__c
                WHERE license_number__c = :driverRecord.license_number__c
            ];*/
            /*if (!drivers.isEmpty()) {
                driverRecord.Id = drivers[0].Id;
            }else{*/
                upsert driverRecord;
            //}
        
            List<Quote__c> quoteRecords = [
                    SELECT Id, Vehicle__c, Lead__c, Account__c, Contact__c
                    FROM Quote__c
                    WHERE Id = :quoteId
                    LIMIT 1
            ];
    
            if (String.isNotBlank(quoteId) && !quoteRecords.isEmpty()) {
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
                
                responseMap.put('savedDriverRecord', driverRecord);
                if (isOwner) {
                    if (String.isNotBlank(driverRecord.Contact__c)) {
                        //Contact contactRecord = updateRelatedContact(driverRecord);
                        //responseMap.put('contactUpdated', contactRecord);
                    } else if(String.isNotBlank(driverRecord.Lead__c) && UserInfo.getUserType().equalsIgnoreCase('Guest')) {
                        Lead leadRecord = updateRelatedLead(driverRecord);
                        responseMap.put('leadUpdated', leadRecord);
                    }
                }

            } else {
                responseMap.put('success', false);
                responseMap.put('message', 'The quote record was not found');
            }
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }

        responseMap.put('success', String.isBlank(errorMessage));
        responseMap.put('message', errorMessage);
        return responseMap;
    }

    private static Lead updateRelatedLead(Driver__c driverRecord){
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

            leadForUpdate.Company = leadForUpdate.FirstName + ' ' + leadForUpdate.LastName;

            Database.upsert(leadForUpdate);
        }
        return leadForUpdate;
    }

    @TestVisible 
    private static Contact updateRelatedContact(Driver__c driverRecord){
        List<Contact> contactRecords = [
                SELECT Id, FirstName, LastName, Email, Phone, Date_of_Birth__c, MailingStreet,
                        MailingCountry, MailingCity, MailingState, MailingPostalCode
                FROM Contact
                WHERE Id = :driverRecord.Contact__c
                LIMIT 1
        ];
        Contact contactForUpdate;
        if (!contactRecords.isEmpty()) {
            contactForUpdate = contactRecords[0];
            contactForUpdate.FirstName = driverRecord.First_Name__c;
            contactForUpdate.LastName = driverRecord.Last_Name__c;
            contactForUpdate.Phone = driverRecord.Phone__c;
            contactForUpdate.Email = driverRecord.Email__c;
            contactForUpdate.Date_of_Birth__c = driverRecord.Dob__c;
            contactForUpdate.MailingStreet = driverRecord.Address__c + (String.isNotBlank(driverRecord.Address_Line_2__c) ? ' ' + driverRecord.Address_Line_2__c : '');
            contactForUpdate.MailingCity = driverRecord.City__c;
            contactForUpdate.MailingState = driverRecord.State_Province__c;
            contactForUpdate.MailingPostalCode = driverRecord.Postal_Code__c;
            contactForUpdate.MailingCountry = driverRecord.Country__c;

            Database.upsert(contactForUpdate);
        }
        return contactForUpdate;
    }

    @AuraEnabled
    public static Map<String, Object> saveQuoteAction(String leadId, String firstName, String lastName, 
        String emailAdder, String quoteId, String phoneNumber) {

        System.debug('saveQuoteAction');
        Map<String, Object> responseMap = new Map<String, Object>();
        String userType = UserInfo.getUserType();

        if (userType != null && userType.equalsIgnoreCase('Guest')) {
            responseMap = saveQuoteActionByAdmin(leadId, firstName, lastName, emailAdder, quoteId, phoneNumber);
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
        return responseMap;
    }

    public static void updateQuoteContactAndAccount(String quoteId, String accountId, String contactId) {
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

    @AuraEnabled
    public static Map<String, Object> saveQuoteActionByAdmin(String leadId, String firstName, String lastName, 
        String emailAdder, String quoteId, String phoneNumber) {

        System.debug('--leadId---' + leadId);
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
// Account account = [select id, Name from Account where IsPartner = true LIMIT 1];
            Lead ldObj = [SELECT Id, Name, LastName, Email, FirstName,Phone, Company, IsConverted, ConvertedContactId, ConvertedAccountId FROM Lead WHERE Id = :leadId LIMIT 1];
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];

            if (ldObj != null && !ldObj.IsConverted) {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(leadId);
                lc.setDoNotCreateOpportunity(true);

             /*   if (firstName != null || lastName != null) {
                    if (firstName != null && firstName != '') {
                        ldObj.FirstName = firstName;
                        ldObj.Company = firstName;
                    }
                    if (lastName != null && lastName != '') {
                        ldObj.LastName = lastName;
                        ldObj.Company = lastName;
                    }
                    if (emailAdder != null && emailAdder != '') {
                        ldObj.Email = emailAdder;
                    }
                    if (phoneNumber != null && phoneNumber != '') {
                        ldObj.Phone = phoneNumber;
                    } 

                    if (String.isNotBlank(firstName) && String.isNotBlank(lastName)) {
                        ldObj.Company = firstName + ' ' + lastName;
                    }
                    update ldObj;
                }
*/
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);

                Database.LeadConvertResult lcr = Database.convertLead(lc);
                if (lcr.isSuccess() && lcr.getContactId() != null) {
                    User user1 = new User(
                            Username = ldObj.Email,
                            LastName = ldObj.LastName,
                            Email = ldObj.Email,
                            Phone = ldObj.Phone,
                            ContactId = lcr.getContactId(),
                            ProfileId = portalProfile.Id,
                            EmailEncodingKey = 'UTF-8',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US'
                    );

                    if( ldObj.FirstName != null ){
                        user1.FirstName =  ldObj.FirstName;
                    }
                    if (String.isNotBlank(ldObj.Email)) {
                        user1.Alias = (ldObj.Email).substringBeforeLast('@').left(8);
                    } else {
                        user1.Alias = ldObj.FirstName.charAt(0) + ldObj.LastName.substring(0, 5);
                    }

                    Database.insert(user1);
                    String userId = user1.Id;

                    if (userId != null) {
                        //***********update quote contact and account lookups */
                        updateQuoteContactAndAccount(quoteId, lcr.getAccountId(), lcr.getContactId());

                        Account AccObj = new Account();
                        AccObj.Name = (String.isNotBlank(ldObj.FirstName) ? ldObj.FirstName + ' ' : '') + (String.isNotBlank(ldObj.LastName) ? ldObj.LastName : '');
                        AccObj.Id = lcr.getAccountId();
                        AccObj.Email__c = ldObj.Email;
                        update AccObj;

                        responseMap.put('success', true);
                        responseMap.put('isCommunityUser', true);
                        responseMap.put('lead', ldObj);
                        responseMap.put('contactId', lcr.getContactId());
                        responseMap.put('accountId', lcr.getAccountId());
                        responseMap.put('message', 'Quote saved successfully.');
                    }

                }
            } else if (ldObj.ConvertedContactId != null) {
                List<User> userList = new List<User>();
                userList = [SELECT Id, ContactId FROM User WHERE ContactId = :ldObj.ConvertedContactId LIMIT 1];

                String userId = null;
                User user1 = new User();
                if (userList == null || userList.isEmpty()) {
                    user1 = new User(
                            Username = ldObj.Email,
                            LastName = ldObj.LastName,
                            Email = ldObj.Email,
                            ContactId = ldObj.ConvertedContactId,
                            ProfileId = portalProfile.Id,
                            EmailEncodingKey = 'UTF-8',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US'
                    );

                    if( ldObj.FirstName != null ){
                        user1.FirstName =  ldObj.FirstName;
                    }
                    if (String.isNotBlank(ldObj.Email)) {
                        user1.Alias = (ldObj.Email).substringBeforeLast('@').left(8);
                    } else {
                        user1.Alias = ldObj.FirstName.charAt(0) + ldObj.LastName.substring(0, 5);
                    }
                    
                    Database.insert(user1);
                    userId = user1.Id;
                } else if (!userList.isEmpty()) {
                    userId = userList[0].Id;
                }
                
                if (userId != null) {
                    
                    //***********update quote contact and account lookups */
                    updateQuoteContactAndAccount(quoteId, ldObj.ConvertedAccountId, ldObj.ConvertedContactId);
                    
                    responseMap.put('success', true);
                    responseMap.put('isCommunityUser', true);
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
            if (userType != null && userType.equalsIgnoreCase('Guest')) {
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
            for (Policy__c plo : [SELECT Id, Name, Contact__r.Email FROM Policy__c WHERE Quote_c__c IN:quoteIdList]) {
                if (policyRecord != null) {
                    Policy__c tempPol = policyRecord;
                    tempPol.Id = plo.Id;
                    tempPol.Name = plo.Name;
                    tempPol.Contact_Email__c = plo.Contact__r.Email;
                    PolicyMap.put(tempPol.Id, tempPol);
                }

                Map<String, Object> policyMapTemp = new Map<String, Object>();
                policyMapTemp.put('email', plo.Contact__r.Email);
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


            responseMap.put('success', true);
            responseMap.put('policyMapList', policyMapList);

        }
        return responseMap;
    }


    @AuraEnabled
    public static Map<String, Object> createTransactionAction(String rateRecordList, String affiliateAccountString, Watercraft__c watercraftRecord) {

        System.debug('-rateRecordList---' + rateRecordList);

        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Transaction__c> transactionMap = new Map<String, Transaction__c>();
        Map<String, String> quoteVsContactIdMap = new Map<String, String>();
        Map<String, String> quoteVsAccountIdMap = new Map<String, String>();
        Map<String, Policy__c> policyMap = new Map<String, Policy__c>();
        Map<String, List<Quote_Driver__c>> driverlistMap = new Map<String, List<Quote_Driver__c>>();
        Map<String, Quote_Watercraft__c> quoteVehicleMap = new Map<String, Quote_Watercraft__c>();

        try {
//********login user Id */
            String userType = UserInfo.getUserType();
            if (rateRecordList != null && rateRecordList != '') {

                List<Object> rateObjList = new List<Object>();
                rateObjList = (List<Object>) JSON.deserializeUntyped(rateRecordList);
                Account affiliateAccount = (Account) JSON.deserialize(affiliateAccountString, Account.class);
                Set<String> quoteIds = new Set<String>();
                Map<String, String> leadIdVsQuoteIdMap = new Map<String, String>();

                for (Object rate : rateObjList) {
                    Map<String, Object> rateMap = new Map<String, Object>();
                    rateMap = (Map<String, Object>) rate;
                    if (rateMap != null && !rateMap.isEmpty()) {
                        String quoteId;
                        String leadId;
                        if (rateMap.containsKey('quoteId')) {
                            quoteId = String.valueOf(rateMap.get('quoteId'));
                        }

                        if (rateMap.containsKey('leadId') && rateMap.get('leadId') != null) {
                            leadId = String.valueOf(rateMap.get('leadId'));
                        }
                        Boolean bool = quoteId != null && leadId != null;
                        if (quoteId != null && leadId != null) {
                            leadIdVsQuoteIdMap.put(leadId, quoteId);
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
                    List<Lead> leadlist = getleads(leadIdVsQuoteIdMap.keySet()); //[select id, Name, LastName, Email, FirstName, isconverted, convertedContactId, convertedAccountId from Lead where Id IN: leadIdVsQuoteIdMap.keyset()];
                    for (Lead ldObj : leadlist) {
                        if (ldObj.IsConverted) {
                            quoteVsContactIdMap.put(leadIdVsQuoteIdMap.get(ldObj.Id), ldObj.ConvertedContactId);
                            quoteVsAccountIdMap.put(leadIdVsQuoteIdMap.get(ldObj.Id), ldObj.ConvertedAccountId);
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
                System.debug('<<<<<<<  Crate Transaction     <<<<<<<<<<<<<<<<<quoteVsContactIdMap>>>>>>>>>>>>>>>>>>>>' + quoteVsContactIdMap);
                System.debug('<<<<<<<  Crate Transaction     <<<<<<<<<<<<<<<<<leadIdVsQuoteIdMap.keyset()>>>>>>>>>>>>>>>>>>>>' + leadIdVsQuoteIdMap.keySet());


//*********************convert lead if not converted** */
                for (String ldId : leadIdVsQuoteIdMap.keySet()) {
                    if (!quoteVsContactIdMap.containsKey(leadIdVsQuoteIdMap.get(ldId))) {
                        Map<String, Object> responseTempMap = new Map<String, Object>();
                        responseTempMap = saveQuoteAction(ldId, null, null, null, leadIdVsQuoteIdMap.get(ldId), null);
                        if (responseTempMap != null && !responseTempMap.isEmpty()) {
                            if (Boolean.valueOf(responseTempMap.get('success'))) {
                                if (responseTempMap.containsKey('contactId')) {
                                    quoteVsContactIdMap.put(leadIdVsQuoteIdMap.get(ldId), String.valueOf(responseTempMap.get('contactId')));
                                }

                                if (responseTempMap.containsKey('accountId')) {
                                    quoteVsAccountIdMap.put(leadIdVsQuoteIdMap.get(ldId), String.valueOf(responseTempMap.get('accountId')));
                                }

                            } else {
                                responseMap = responseTempMap;
                                break;
                            }
                        }
                    }
                }

                System.debug('--quoteVsContactIdMap--' + quoteVsContactIdMap);
                System.debug('--quoteVsAccountIdMap--' + quoteVsAccountIdMap);
                List<Quote_Watercraft__c> quotevehicleList = new List<Quote_Watercraft__c>();
                quotevehicleList = [SELECT Id, Watercraft__c, Policy__c, Quote_c__c, Account__c, Contact__c FROM Quote_Watercraft__c WHERE Quote_c__c IN:quoteIds];
                for (Quote_Watercraft__c vehicle : quotevehicleList) {
                    if( vehicle.Contact__c == null && quoteVsContactIdMap != null && quoteVsContactIdMap.containsKey(vehicle.Quote_c__c) ){
                        vehicle.Contact__c = quoteVsContactIdMap.get(vehicle.Quote_c__c);
                    }
                    if( vehicle.Account__c == null && quoteVsAccountIdMap != null && quoteVsAccountIdMap.containsKey(vehicle.Quote_c__c) ){
                        vehicle.Account__c = quoteVsAccountIdMap.get(vehicle.Quote_c__c);
                    }
                    quoteVehicleMap.put(vehicle.Quote_c__c, vehicle);
                }


                map<String, driver__c> driverMap = new map<String, driver__c>();
                list<Quote_Driver__c> qDrivers =new list<Quote_Driver__c>();
                qDrivers = [select Id, Policy__c, Quote_c__c, Account_Driver__c, Vehicle_Driver__c, Contact__c,  Watercraft__c,
                            Driver__c, Driver__r.Contact__c, Driver__r.Account_Driver__c from Quote_Driver__c where Quote_c__c In: quoteIds ];

                for (Quote_Driver__c driver : qDrivers) {
                    if (driver.Contact__c == null && quoteVsContactIdMap != null && quoteVsContactIdMap.containsKey(driver.Quote_c__c)) {
                        driver.Contact__c = quoteVsContactIdMap.get(driver.Quote_c__c);
                    }
                    if (driver.Account_Driver__c == null && quoteVsAccountIdMap != null && quoteVsAccountIdMap.containsKey(driver.Quote_c__c)) {
                        driver.Account_Driver__c = quoteVsAccountIdMap.get(driver.Quote_c__c);
                    }
                    if (driver.Watercraft__c == null && String.isNotBlank(watercraftRecord?.Id)) {
                        driver.Watercraft__c = watercraftRecord.Id;
                    }
                    if (driverlistMap.containsKey(driver.Quote_c__c)) {
                        driverlistMap.get(driver.Quote_c__c).add(driver);
                    } else {
                        driverlistMap.put(driver.Quote_c__c, new List<Quote_Driver__c>{
                            driver
                        });
                    }
                }

                Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                    policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                }
                for (Quote__c qtObj : [
                        SELECT Id, Driver_Age__c, Underwriter__c, Policy_Type_picklist__c, Coverage__c, Territory__c, Broker_Policy_Fee__c, Surcharge__c,
                                I_V_A_Mex_Tax__c, Net_Premium__c, Term__c, Term_Days__c, Vehicle_Type__c, Start_Date_for_Coverage__c, End_Date_for_Coverage__c,
                                End_Time__c, Start_Time__c, Quote_Value__c, Medical__c, Liability__c, Vehicle_Value__c, Third_Party_Bodily_Injury__c, Property_Damage_Liability__c
                        FROM Quote__c
                        WHERE Id IN:quoteIds
                ]) {

                    Policy__c newPolicy = new Policy__c();

                    newPolicy.Broker_Policy_Fee__c = qtObj.Broker_Policy_Fee__c;
                    newPolicy.I_V_A_Mex_Tax__c = qtObj.I_V_A_Mex_Tax__c;
                    newPolicy.Net_Premium__c = qtObj.Net_Premium__c;
                    newPolicy.Surcharge__c = qtObj.Surcharge__c;
                    newPolicy.Policy_Type_picklist__c = qtObj.Policy_Type_picklist__c;
                    newPolicy.Quote_c__c = qtObj.Id;
                    newPolicy.Total_Transaction_Amount__c = qtObj.Quote_Value__c;
                    newPolicy.Medical_picklist__c = qtObj.Medical__c;
                    newPolicy.Liability_picklist__c = qtObj.Liability__c;
                    newPolicy.Package__c = qtObj.Coverage__c;
                    newPolicy.Property_Damage_Liability__c = qtObj.Property_Damage_Liability__c;
                    newPolicy.Third_Party_Bodily_Injury__c = qtObj.Third_Party_Bodily_Injury__c;
                    newPolicy.Territory_picklist__c = qtObj.Territory__c;
                    newPolicy.Term__c = qtObj.Term__c;
                    
                    if (newPolicy.Policy_Type_picklist__c != null && newPolicy.Policy_Type_picklist__c == 'Watercraft'
                            && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }

                    if (quoteVsContactIdMap != null && quoteVsContactIdMap.containsKey(qtObj.Id)) {
                        newPolicy.Contact__c = quoteVsContactIdMap.get(qtObj.Id);
                    }
                    if (quoteVsAccountIdMap != null && quoteVsAccountIdMap.containsKey(qtObj.Id)) {
                        newPolicy.Policy_Parent_Account__c = quoteVsAccountIdMap.get(qtObj.Id);
                        newPolicy.Account_Policy__c = quoteVsAccountIdMap.get(qtObj.Id);
                    }

                    newPolicy.Status_picklist__c = 'Active';
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

                    if (qtObj.Term__c != null && qtObj.Term__c == 'Annual(One Year)') {
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

                    if (String.isNotBlank(watercraftRecord?.Id)) {
                        newPolicy.Watercraft__c = watercraftRecord.Id;
                    }

                    policyMap.put(qtObj.Id, newPolicy);
                    policyMap.get(qtObj.Id).Name = generatePolicyName(qtObj.Underwriter__c, qtObj.Policy_Type_picklist__c, qtObj.Coverage__c, qtObj.Term__c, qtObj.Territory__c);
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

                        if (policyMap.get(quoteId).Id != null && transactionMap != null && transactionMap.containsKey(quoteId)) {
                            transactionMap.get(quoteId).Policy_Transaction__c = policyMap.get(quoteId).Id ;
                        }

                        if (policyMap.get(quoteId).Id != null && quoteVehicleMap != null && quoteVehicleMap.containsKey(quoteId)) {
                            quoteVehicleMap.get(quoteId).Policy__c = policyMap.get(quoteId).Id ;
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
                    }

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

                    if (customerProfiles != null && !customerProfiles.isEmpty()) {
                        update customerProfiles;
                    }
                    if (subscriptions != null && !subscriptions.isEmpty()) {
                        update subscriptions;
                    }

                    if( quoteVehicleMap != null && !quoteVehicleMap.isEmpty()){
                        try{
                            update quoteVehicleMap.values();
                        }catch(exception ex ){

                        }
                    }

                    if (policyIdset != null && !policyIdset.isEmpty()) {
                        Boolean add_attachment = true;
                        Mex_Insurance_Calloututility.sendEmail(policyIdset, add_attachment);
                    }
                }
            }
            responseMap.put('success', true);
        } catch (Exception e) {
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
    public static List<object> getYears(){
        return VehicalAPIController.getYears();
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
                system.debug('Towed_Units ->'+ Towed_Units);
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
            system.debug('terms_towded date --> '+additional_towunitMap.get('Days_in_Tow__c'));
            daysBetween = Integer.valueOf(additional_towunitMap.get('Days_in_Tow__c'));
           /* if( quoteObj.Start_Date_for_Coverage__c != null && quoteObj.End_Date_for_Coverage__c != null ){
                daysBetween = quoteObj.Start_Date_for_Coverage__c.daysBetween(quoteObj.End_Date_for_Coverage__c );
            } */
            quoteObj.Term_Days__c = daysBetween;
            if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c <= 30) {
                quoteObj.Term__c = 'Daily';
            } else if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c > 30 && quoteObj.Term_Days__c <= 90) {
                quoteObj.Term__c = '90 Day';
            } else if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c > 90 && quoteObj.Term_Days__c <= 180) {
                quoteObj.Term__c = 'Semi-Annual(Half a Year)';
            } else if (quoteObj.Term_Days__c != null && quoteObj.Term_Days__c > 180) {
                quoteObj.Term__c = 'Annual(One Year)';
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
                system.debug('message : '+ ex.getMessage() + '  cause : '+ ex.getCause() + ' line number : '+ ex.getLineNumber());
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
    public static Map<String, Object> handleQuoteAction(Quote__c quoteRecord, Boolean annualTerm) {
        System.debug('@@@ inside handleQuocteAction');
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if( annualTerm == null ){
                annualTerm = false;
            }
            if (quoteRecord.Start_Date_for_Coverage__c != null && quoteRecord.End_Date_for_Coverage__c != null) {
                quoteRecord.Term_Days__c = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
            }

            if (quoteRecord.Term_Days__c != null && !annualTerm) {
                quoteRecord.Term__c = 'Daily';
            } else if (quoteRecord.Term_Days__c != null && annualTerm) {
                quoteRecord.Term__c = 'Annual(One Year)';
            }

            if (quoteRecord.Id == null) {
                quoteRecord.Quote_Status__c = 'Draft';
            }

            upsert quoteRecord Id;

            responseMap.put('success', true);
            responseMap.put('quote', quoteRecord);

        } catch (Exception e) {
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

            String userType = UserInfo.getUserType();
            if ((leadId == null || leadId == '') && (userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                if (ldObjectMap.containsKey('sobjectType')) {
                    ldObjectMap.remove('sobjectType');
                }

                leadId = Mex_Insurance_Calloututility.createLead_Record(ldObjectMap);
            }

            system.debug('--leadId--'+leadId);
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
                System.debug('loginUser');
                List<User> loginUserList = new List<User>();
                loginUserList = getloginUser();
                System.debug('loginUserList : ' + loginUserList);
                if (loginUserList != null && !loginUserList.isEmpty()) {
                    quoteRecord.Contact__c = loginUserList[0].ContactId;
                    quoteRecord.Account__c = loginUserList[0].Contact.AccountId;
                }
            }

            if (quoteRecord.Id == null) {
                quoteRecord.Quote_Status__c = 'Draft';
            }


            upsert quoteRecord Id;

            responseMap.put('success', true);
            responseMap.put('leadId', leadId);
            responseMap.put('quote', quoteRecord);

        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled
    public static List<Coverage_Detail__c> getCoverageDetail(Quote__c quoteRecord) {
        System.debug('quoteRecord : ' + quoteRecord);
        List<Coverage_Detail__c> Coverage_Details = new List<Coverage_Detail__c>();
        try {
            String query = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c,IsDeleted, ';
            query += 'Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query += 'SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, Roadside_Details__c, ';
            query += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c ';
            query += 'FROM Coverage_Detail__c where Underwriter__c = \'' + quoteRecord.Underwriter__c + '\' and Policy_Type__c =  \'' + quoteRecord.Policy_Type_picklist__c + '\' LIMIT 1';

            Coverage_Details = Database.query(query);

        } catch (Exception e) {
            System.debug('Exception--' + e.getMessage());
        }
        return Coverage_Details;
    }

    @AuraEnabled
    public static Map<String, List<String>> getDependentMap(SObject objDetail, String contrfieldApiName, String depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();

        Map<String, List<String>> objResults = new Map<String, List<String>>();
system.debug('objType ---> '+ objDetail.getSObjectType());
        Schema.SObjectType objType =  objDetail.getSObjectType();
        system.debug('objType ---> '+ objType);
        if (objType == null) {
            return objResults;
        }

        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
		system.debug('objFieldMap ---> '+ objFieldMap);
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
            return objResults;
        }

        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
		system.debug('theField ---> '+ theField);
        system.debug('ctrlField ---> '+ ctrlField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        system.debug('contrEntries ---> '+ contrEntries);
        system.debug('depEntries ---> '+ depEntries);
        
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
        system.debug('objResults ---> '+ objResults);
        return objResults;
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
    public static Map<String, Object> checkalreadyExistUserAction(String emailAdder) {
        return QuickQuotationCtrl.checkalreadyExistUserAction(emailAdder);
    }


    @AuraEnabled
    public static List<Watercraft__c> getCurrentUserWaterCraft() {
        list<User> users = new list<User>();
        users = [select Id, contactId from User where Id=: UserInfo.getUserId() limit 1];
        system.debug('users :: '+ users);
        if( users != null && !users.isEmpty() && users[0].contactId != null ){
            list<Quote_Watercraft__c> quoteWatercrafts = new list<Quote_Watercraft__c>();
            quoteWatercrafts = [select Watercraft__c from Quote_Watercraft__c where Contact__c =: users[0].contactId or createdbyId =: UserInfo.getUserId() ];
            if( quoteWatercrafts != null && !quoteWatercrafts.isEmpty()){
                set<String> WatercraftIds = new set<String>();
                for(Quote_Watercraft__c qdr : quoteWatercrafts){
                    system.debug('qdr.Watercraft__c : '+ qdr.Watercraft__c);
                    WatercraftIds.add( qdr.Watercraft__c );
                }
                String query = QuickQuotationCtrl.getQueryWithAllFields(Watercraft__c.getSObjectType().getDescribe().getName());
                query += ' where Id IN: WatercraftIds';
                
                List<Watercraft__c> waterCraftList = Database.query(query);
                system.debug('watercraft list : '+ waterCraftList);
                
                return Database.query(query);
            }

            /*list<Watercraft__c> watercrafts = new list<Watercraft__c>();
            watercrafts = [SELECT Id, VIN_Number__c, Year__c, Make__c, Model__c, Value__c, Type_of_Vessel__c, Vessel_Length__c FROM Watercraft__c WHERE Contact__c = :users[0].contactId or createdbyId =: UserInfo.getUserId() ];
            return watercrafts;*/
        }
        return null;
    }
}