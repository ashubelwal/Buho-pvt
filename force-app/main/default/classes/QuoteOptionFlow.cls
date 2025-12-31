public without sharing class QuoteOptionFlow {

    //Vendor Class level Variable
    private static Map<String, Vendor__c> cachedVendors = new Map<String, Vendor__c>();
    private static List<String> vendors = new List<String>();


     // Insert territory in the backend
    // Query the data based on the ID and the Email and update the Lead record
    // New lead for inserting policy terms
    // Add policy terms such as Annual,Semi-Annual,Daily,Start date and end Date
    @AuraEnabled
    public static Map<String, Object> saveQuoteDetails(String strLeadDetails){
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            System.debug('String lead details in the vehicle save method: ' + strLeadDetails);
            
            if (String.isNotBlank(strLeadDetails)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
                
                // Initialize maps to store extracted data
                Map<String, Object> userDetails = new Map<String, Object>();
                Map<String, Object> vehicleDetails = new Map<String, Object>();
                Map<String,Object> quoteDetails = new Map<String,Object>();

                // Iterate over the leadDetails list
                for (Object detail : leadDetails) {
                    try {
                        // Try casting the detail to a Map
                        Map<String, Object> dataMap = (Map<String, Object>) detail;
                        
                        if (dataMap.containsKey('userDetails')) {
                            userDetails = (Map<String, Object>) dataMap.get('userDetails');
                        }
                        if (dataMap.containsKey('vehicleDetails')) {
                            vehicleDetails = (Map<String, Object>) dataMap.get('driverDetails');
                        }
                        if (dataMap.containsKey('quotePage')) {
                            quoteDetails = (Map<String, Object>) dataMap.get('quotePage');
                        }
                    } catch (Exception e) {
                        System.debug('Skipping non-map entry: ' + e.getMessage());
                    }
                }
                
                // Check if Lead ID is provided in userDetails
                String leadId = (String) userDetails.get('Id');
                Lead existingLead;
                
                if (String.isNotBlank(leadId)) {
                    existingLead = [SELECT Id, Quote_Details__c FROM Lead WHERE Id = :leadId LIMIT 1];
                } else {
                    // If LeadId is not provided, find Lead by email
                    String email = (String) userDetails.get('Email');
                    if (String.isNotBlank(email)) {
                        List<Lead> leadsByEmail = [SELECT Id, Quote_Details__c FROM Lead WHERE Email = :email LIMIT 1];
                        if (!leadsByEmail.isEmpty()) {
                            existingLead = leadsByEmail[0];
                        }else{response.put('Message', 'Lead record not found. Please check again.');  response.put('Status', 'Error'); return response;
                        }
                    }else{response.put('Message', 'Lead record not found.Email is required.'); response.put('Status', 'Error');return response;
                    }
                }
                
                if (existingLead != null) {
                  return updateQuoteDetails(existingLead, quoteDetails);
                } else { 
                    response.put('Message', 'Lead record not found using provided details.'); 
                    response.put('Status', 'Error');  return response;
                }
            } else { 
                response.put('Message', 'No data found.');
                response.put('Status', 'Error'); return response;
            }
        }catch (CustomErrorExceptionHandlerException ex){  
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new CustomErrorExceptionHandlerException(ex.getMessage());
        }
        
    }
    
    // Helper method to update territory details
    private static Map<String, Object> updateQuoteDetails(Lead lead, Map<String, Object> quoteDetails) {
    Map<String, Object> response = new Map<String, Object>();

    try { 
         Quote__c quoteData = saveQuoteRecord(JSON.serialize(quoteDetails),lead.Id,true);
         System.debug('Quote Data in the save Method'+ quoteData);

        // Serialize back to JSON and update the field
        lead.Quote_Details__c = JSON.serialize(quoteData);

        // Perform the update using Database.update
        Database.SaveResult sr = Database.update(lead, false);

        // Check if the update operation was successful
        if (sr.isSuccess()) {
            System.debug('Lead updated successfully. ID: ' + sr.getId());
            
            // Populate the response map with success data
            response.put('LeadId', sr.getId());
            response.put('Data', lead);
            response.put('Status', 'Success');
        } else {
            // Handle errors from the SaveResult
            for (Database.Error error : sr.getErrors()) {
                System.debug('Error message: ' + error.getMessage());
                response.put('Message', error.getMessage());
                response.put('Status', 'Error');
            }
        }
    } catch (Exception e) { 
        System.debug('Exception occurred during update: ' + e.getMessage());  
        response.put('Message', 'Error during update: ' + e.getMessage()+ ' ' + e.getStackTraceString()); 
        response.put('Status', 'Error');
    }

    return response;
}

  //Method to insert the Quote Record

    @AuraEnabled
    public static Quote__c saveQuoteRecord(String quotes, String leadId, boolean PolicyFromLead){
        Quote__c quoteRecord = new Quote__c();

        //try {
            System.debug('quotes---> '+quotes);
            
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quotes);
            //Updated the Z from here String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
            String startTime = (String)jsonMap.get('Start_Time__c') ;
            String endTime = (String)jsonMap.get('End_Time__c');
            jsonMap.put('Start_Time__c', startTime);
            jsonMap.put('End_Time__c', endTime);
            quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
            System.debug('Quote record after update the time values'+JSON.serialize(quoteRecord));  

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

            quoteRecord.Start_Time__c = timeStartChange;
            quoteRecord.End_Time__c = timeEndChange;
            

            if(PolicyFromLead == true){
                quoteRecord.Lead__c = leadId;
            }else{
                quoteRecord.Contact__c = leadId;
            } System.debug('Upserting Quote Record'+ quoteRecord);
            upsert quoteRecord;
        //} catch (Exception e) {
          //  throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        //}
        return quoteRecord;
    }



    //Method to get all the vendors
    static {
        
        // Query the custom metadata type
        List<Vendor_List__mdt> vendorMetadataList = [SELECT MasterLabel FROM Vendor_List__mdt];
        
        // Loop through the results and store labels in the list
        for (Vendor_List__mdt vendor : vendorMetadataList) {
            vendors.add(vendor.MasterLabel);
        }
        
        // Debug the output
        System.debug('Vendor Labels: ' + vendors);
        
        if (!vendors.isEmpty()) {
            // 1. Dynamically retrieve all Vendor__c fields
            Map<String, Schema.SObjectField> fields = Schema.SObjectType.Vendor__c.fields.getMap();
            List<String> fieldNames = new List<String>(fields.keySet());
            
            // 2. Build query with dynamic fields and vendor filter
            String query = 'SELECT ' + String.join(fieldNames, ', ') +
                ' FROM Vendor__c WHERE Name IN :vendors'; // Use WHERE instead of LIMIT
            
            // 3. Execute query and cache results
            for (Vendor__c vendor : Database.query(query)) {
                cachedVendors.put(vendor.Name, vendor);
            }
        }
        System.debug('Cached Vendors'+ cachedVendors);
    }
    
    @AuraEnabled
    // Get all cached vendors
    public static Map<String, Vendor__c> getVendors() {
        return cachedVendors;
    }

 
}