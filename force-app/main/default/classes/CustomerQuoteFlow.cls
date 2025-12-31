public without sharing class CustomerQuoteFlow {
    
    // New Lead Flow for customer quote
    // Inserting new Lead details
    @AuraEnabled
    public static Map<String,Object> saveLeadUserDetails(String strLeadDetails) {
        try {
            // Initialize a response map to store the result and any relevant data
            Map<String,Object> response = new Map<String,Object>();
            
            // Check if the input string (strLeadDetails) is not null
            if (strLeadDetails != null) {
                System.debug('Payload data: ' + strLeadDetails);
                
                // Deserialize the input string into a Lead object
                Lead leadData = (Lead) JSON.deserialize(strLeadDetails, Lead.class);
                
                // Verify if the deserialized Lead object is valid
                if (leadData != null) {
                    // Attempt to insert the Lead record with partial DML (false to allow partial success)
                    Database.UpsertResult  sr = Database.upsert(leadData, false);
                    
                    // Check if the insert operation was successful
                    if (sr.isSuccess()) {
                        System.debug('Record inserted successfully. ID: ' + sr.getId());
                        
                        // Populate the response map with success data
                        response.put('LeadId', sr.getId()); // ID of the inserted Lead record
                        response.put('Data', leadData); // The Lead object with data
                        response.put('Status', 'Success'); // Status indicating a successful operation
                        return response; // Return the response map
                    } else {
                        // Handle errors from the SaveResult in case the insert fails
                        for (Database.Error error : sr.getErrors()) {
                            System.debug('Error message: ' + error.getMessage());
                            
                            // Populate the response map with error details
                            response.put('Message', error.getMessage()); // Error message from SaveResult
                            response.put('Status', 'Error'); // Status indicating an error occurred
                            return response; // Return the response map
                        }
                    }
                }
                // Throw a custom exception if the Lead data is invalid
                throw new CustomErrorExceptionHandlerException('Invalid Lead data.');
            }
            // Throw a custom exception if no data is provided in the input string
            throw new CustomErrorExceptionHandlerException('No data found.');
        } catch (CustomErrorExceptionHandlerException e) {
            // Log the custom exception for tracking and debugging
            CustomErrorExceptionHandlerException.LogException(e);
            
            // Re-throw the custom exception with an additional message
            throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage());
        } catch (Exception e) {
            // Log any generic exception for tracking and debugging
            CustomErrorExceptionHandlerException.LogException(e);
            
            // Re-throw the exception as a custom exception with an additional message
            throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, object> checkalreadyExistUserAction(String leadDataItem) {
        Map<String, object> returnMap = new map<String,object>();
        list<Lead> leadData = new list<Lead>();
        try{
            Lead getLeadData = new Lead();
            getLeadData = (Lead)JSON.deserialize(leadDataItem, lead.class);
			System.debug('getLeadData---'+getLeadData);
            
            list<User> userList = new list<User>();
            map<string, object> insertedNewLead = new map<string, object>();
            userList = [
                    SELECT Id, UserName, Email, Isactive 
                    FROM User 
                    WHERE Email =: getLeadData.Email limit 1];
            returnMap.put('isExistUser', false);

            list<Contact> contactList = new list<Contact> ();
            contactList = [
                    SELECT Id, FirstName,LastName,Name, Email, Phone 
                    FROM Contact 
                    WHERE Email =: getLeadData.Email limit 1];
            returnMap.put('isExistContact',false);
            
			System.debug('userList---'+userList);
            
            if(userList != null && !userList.isEmpty()) {
                returnMap.put('isExistUser', true);
                returnMap.put('userData', userList[0]);
                returnMap.put('status', 'Success');
            }else if(contactList != null && !contactList.isEmpty()){
                returnMap.put('isExistContact',true);
                returnMap.put('contactData',contactList[0]);
                returnMap.put('status', 'Success');
            } else {
                String query = getQueryWithAllFields(Lead.getSObjectType().getDescribe().getName());
                query += ' WHERE';
                if (getLeadData.Id != null && !String.isEmpty(getLeadData.Id)) {
                    query += ' Id=\'' + getLeadData.Id + '\'';
                } else if (getLeadData.Email != null && !String.isEmpty(getLeadData.Email)) {
                    query += ' Email=\'' + getLeadData.Email + '\'';
                }
                System.debug('####'+query);
                leadData = Database.query(query);
				System.debug('leadData---leadData'+leadData);
                
                if(!leadData.isEmpty()){
                    if (getLeadData.FirstName != null && getLeadData.LastName != null) {
                        System.debug('Update Lead MEthod');
                        if(String.isNotBlank(getLeadData.FirstName)) {
                            leadData[0].FirstName = getLeadData.FirstName;
                        }
                        if(String.isNotBlank(getLeadData.LastName)) {
                            leadData[0].LastName = getLeadData.LastName;
                        }
                        if(String.isNotBlank(getLeadData.Phone)) {
                            leadData[0].Phone = getLeadData.Phone;
                        }
                        System.debug('###lead data before update'+leadData);
                        update leadData;
                        System.debug('leadData---'+leadData);
                    }
					System.debug('leadData---'+leadData);
                    
                    String quoteQuery = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
                    quoteQuery += ' WHERE Lead__c=\'' + leadData[0].Id + '\'';
                    list<Quote__c> QuoteData = Database.query(quoteQuery);
					System.debug('QuoteData---'+QuoteData);
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
                returnMap.put('Message','No lead and user exists');
            }

        }catch(Exception ex){
            returnMap.put('status', 'Error');
            returnMap.put('message ', ex.getMessage());
            CustomErrorExceptionHandlerException.data = 'From parameter: '+leadDataItem+'\n leadData on query: '+JSON.serialize(leadData);
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
                Alias = username.substring(0, Math.min(8, username.length())), // Alias must be <= 8 characters
                CommunityNickname = username, // Required for community users, can be same as username
                ProfileId = userProfile.Id,
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/Los_Angeles' // Adjust as needed
            );

        // Insert the new user
        
            insert newUser;
            System.debug('New user created successfully: ' + newUser.Id);
            responseMap.put('Success',true);
        } catch (DmlException e) {
            System.debug('Error creating user: ' + e.getMessage());
            responseMap.put('Success',false);
        }
        return responseMap;
    }

    public static String getQueryWithAllFields(String objectName) {
        System.debug('####all fields before query'+getAllFields(objectName));
        return 'SELECT ' + String.join(getAllFields(objectName), ', ') + ' FROM ' + objectName;
    }

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
        System.debug('####fieldsSet '+fieldsSet);
        return fieldsSet;
    }

    private static Set<String> removeFields = new Set<String>{
        'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastvieweddate',
            'lastreferenceddate'
    };


    private static SObjectType describeObject(String objectName) {
        return Schema.getGlobalDescribe().get(objectName);
    }
    
}