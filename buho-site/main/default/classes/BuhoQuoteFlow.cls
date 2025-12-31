/**
 * @File Name : BuhoQuoteFlow.cls
 * @Description : Apex controller for BÚHO quote wizard flow
 * @Author : System
 * @Last Modified On : December 14, 2024
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | December 14, 2024 |   | Initial Version (Based on NcExistingCustomerFlow)
 **/

public class BuhoQuoteFlow {

    @AuraEnabled
    public static String checkCommunityUserAndFetchDetails() {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            String userType = UserInfo.getUserType();
            responseMap.put('userType', !userType.equalsIgnoreCase('Guest'));
            
            if (userType != null && (!userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                responseMap.put('email', UserInfo.getUserEmail());
                List<User> loginUserList = getloginUser();
                
                if (loginUserList != null && !loginUserList.isEmpty()) {
                    List<Driver__c> driversList = getDrivers(loginUserList[0].ContactId);
                    List<Vehicle__c> vehicleList = getVehicles(loginUserList[0].contactId);
                    List<Towed_Unit__c> towedUnitList = getTowedUnits(loginUserList[0].contactId);
                    List<Contact> contactList = getContact(loginUserList[0].ContactId);

                    if (contactList != null && !contactList.isEmpty()) {
                        responseMap.put('contact', contactList);
                    }

                    if (driversList != null && !driversList.isEmpty()) {
                        responseMap.put('drivers', driversList);
                    }
                    
                    if (vehicleList != null && !vehicleList.isEmpty()) {
                        responseMap.put('vehicles', vehicleList);
                    }
                    
                    if (towedUnitList != null && !towedUnitList.isEmpty()) {
                        responseMap.put('towedUnits', towedUnitList);
                    }
                }
            }
            responseMap.put('status', 'success');
        } catch (Exception ex) {
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        return JSON.serialize(responseMap);
    }

    @AuraEnabled
    public static Map<String,Object> saveLeadUserDetails(String strLeadDetails) {
        try {
            Map<String,Object> response = new Map<String,Object>();
            
            if (strLeadDetails != null) {
                System.debug('BUHO Payload data: ' + strLeadDetails);
                Lead leadData = (Lead) JSON.deserialize(strLeadDetails, Lead.class);
                
                if (leadData != null) {
                    Database.UpsertResult  sr = Database.upsert(leadData, false);
                    
                    if (sr.isSuccess()) {
                        System.debug('BUHO Record inserted successfully. ID: ' + sr.getId());
                        response.put('LeadId', sr.getId());
                        response.put('Data', leadData);
                        response.put('Status', 'Success');
                        return response;
                    } else {
                        for (Database.Error error : sr.getErrors()) {
                            System.debug('BUHO Error message: ' + error.getMessage());
                            response.put('Message', error.getMessage());
                            response.put('Status', 'Error');
                            return response;
                        }
                    }
                }
                throw new CustomErrorExceptionHandlerException('Invalid Lead data.');
            }
            throw new CustomErrorExceptionHandlerException('No data found.');
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, object> checkalreadyExistUserAction(String leadDataItem) {
        Map<String, object> returnMap = new map<String,object>();
        list<Lead> leadData = new list<Lead>();
        
        try{
            Lead getLeadData = (Lead)JSON.deserialize(leadDataItem, lead.class);
            System.debug('BUHO getLeadData: ' + getLeadData);
            
            // Check for existing user
            list<User> userList = [select Id, UserName, Email, Isactive from User where Email =: getLeadData.Email limit 1];
            returnMap.put('isExistUser', false);

            // Check for existing contact
            list<Contact> contactList = [select Id, FirstName,LastName,Name, Email, Phone from Contact where Email =: getLeadData.Email limit 1];
            returnMap.put('isExistContact',false);
            
            if(userList != null && !userList.isEmpty()) {
                returnMap.put('isExistUser', true);
                returnMap.put('userData', userList[0]);
                returnMap.put('status', 'Success');
            } else if(contactList != null && !contactList.isEmpty()){
                returnMap.put('isExistContact', true);
                returnMap.put('contactData', contactList[0]);
                returnMap.put('status', 'Success');
            } else {
                string query = getQueryWithAllFields(Lead.getSObjectType().getDescribe().getName());
                query += ' WHERE';
                
                if (getLeadData.Id != null && !String.isEmpty(getLeadData.Id)) {
                    query += ' Id=\'' + getLeadData.Id + '\'';
                } else if (getLeadData.Email != null && !String.isEmpty(getLeadData.Email)) {
                    query += ' Email=\'' + getLeadData.Email + '\'';
                }
                
                leadData = Database.query(query);
                System.debug('BUHO leadData: ' + leadData);
                
                if(!leadData.isEmpty()){
                    if (getLeadData.FirstName != null && getLeadData.LastName != null) {
                        leadData[0].FirstName = getLeadData.FirstName;
                        leadData[0].LastName = getLeadData.LastName;
                        leadData[0].Phone = getLeadData.Phone;
                        update leadData;
                    }
                    
                    string quoteQuery = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
                    quoteQuery += ' WHERE Lead__c=\'' + leadData[0].Id + '\'';
                    list<Quote__c> QuoteData = Database.query(quoteQuery);
                    
                    returnMap.put('LeadInfo', leadData[0]);
                    if(!QuoteData.isEmpty()){
                        returnMap.put('QuoteInfo', QuoteData[0]);
                        returnMap.put('status', 'Success');
                    }
                }
            }

            if(userList.isEmpty() && leadData.isEmpty() && contactList.isEmpty()){
                returnMap.put('status', 'Error');
                returnMap.put('LeadInfo', null);
                returnMap.put('Message','No lead, contact and user exists');
            }

        }catch(Exception ex){
            returnMap.put('status', 'Error');
            returnMap.put('message', ex.getMessage());
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        return returnMap;
    }

    @AuraEnabled
    public static map<string,Boolean> createNewUser(String contactInfo) {
        Map<string,Boolean> responseMap = new Map<string,Boolean>();
        try {
            Map<string,Object> contactData =new Map<string,object>();
            contactData =  (Map<string,Object>)JSON.deserializeUntyped(contactInfo);
            String contactId = String.valueOf(contactData.containsKey('Id') ? contactData.get('Id') : '');
            String firstName = String.valueOf(contactData.containsKey('FirstName') ? contactData.get('FirstName') : '');
            String lastName = String.valueOf(contactData.containsKey('LastName') ? contactData.get('LastName') : '');
            String email = String.valueOf(contactData.containsKey('Email') ? contactData.get('Email') : '');
            String username = email;
            
            Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];

            User newUser = new User(
                ContactId = contactId,
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Username = username,
                Alias = username.substring(0, Math.min(8, username.length())),
                CommunityNickname = username,
                ProfileId = userProfile.Id,
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/Los_Angeles'
            );

            insert newUser;
            System.debug('BUHO New user created successfully: ' + newUser.Id);
            responseMap.put('Success',true);
        } catch (DmlException e) {
            System.debug('BUHO Error creating user: ' + e.getMessage());
            responseMap.put('Success',false);
            CustomErrorExceptionHandlerException.LogException(e);
        }
        return responseMap;
    }

    // Helper methods
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
        'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 
        'systemmodstamp', 'lastvieweddate', 'lastreferenceddate'
    };
                
    private static List<String> getAllFields(String objectName) {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
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
}

