public without sharing class TerritoryOptionFlow {
    // Insert territory in the backend
    // Query the data based on the ID and the Email and update the Lead record
    // New lead for inserting policy terms
    // Add policy terms such as Annual,Semi-Annual,Daily,Start date and end Date
    @AuraEnabled
    public static Map<String, Object> saveTerritoryDetails(String strLeadDetails){
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            System.debug('String lead details in the territory save method: ' + strLeadDetails);
            
            if (String.isNotBlank(strLeadDetails)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
                
                // Extract user details and vehicle details
                Map<String,Object>  userDetails = new Map<String, Object>();
                Map<String, Object> vehicleDetails = new Map<String, Object>();
                Map<String, Object> termDetails = new Map<String, Object>();
                Map<String,Object> territoryDetails = new Map<String, Object>();
                
                // Iterate over the leadDetails list
                for (Object detail : leadDetails) {
                    try {
                        // Try casting the detail to a Map
                        Map<String, Object> dataMap = (Map<String, Object>) detail;
                        
                        if (dataMap.containsKey('userDetails')) {
                            userDetails = (Map<String, Object>) dataMap.get('userDetails');
                        }
                        if (dataMap.containsKey('vehicleDetails')) {
                            vehicleDetails = (Map<String, Object>) dataMap.get('vehicleDetails');
                        }
                        if (dataMap.containsKey('termOption')) {
                            termDetails = (Map<String, Object>) dataMap.get('termOption');
                        }
                        if (dataMap.containsKey('territory')) {
                            territoryDetails = (Map<String, Object>) dataMap.get('territory');
                        }
                    } catch (Exception e) {
                        System.debug('Skipping non-map entry: ' + e.getMessage());
                    }
                }
                // Check if Lead ID is provided in userDetails
                String leadId = (String) userDetails.get('Id');
                Lead existingLead;
                
                if (String.isNotBlank(leadId)) {
                    existingLead = [SELECT Id, Territory_Options__c FROM Lead WHERE Id = :leadId LIMIT 1];
                } else {
                    // If LeadId is not provided, find Lead by email
                    String email = (String) userDetails.get('Email');
                    if (String.isNotBlank(email)) {
                        List<Lead> leadsByEmail = [SELECT Id, Territory_Options__c FROM Lead WHERE Email = :email LIMIT 1];
                        if (!leadsByEmail.isEmpty()) {
                            existingLead = leadsByEmail[0];
                        }else{ response.put('Message', 'Lead record not found. Please check again.');response.put('Status', 'Error');return response;}
                    }else{
                        response.put('Message', 'Lead record not found.Email is required.');response.put('Status', 'Error');return response;
                    }
                }
                
                if (existingLead != null) {
                    return updateTerritoryDetails(existingLead, territoryDetails);
                } else {response.put('Message', 'Lead record not found using provided details.');response.put('Status', 'Error'); return response;}
            } else {  response.put('Message', 'No data found.');response.put('Status', 'Error');return response;
            }
        }catch (CustomErrorExceptionHandlerException ex){CustomErrorExceptionHandlerException.LogException(ex);throw new CustomErrorExceptionHandlerException(ex.getMessage());}
        catch (Exception e) {CustomErrorExceptionHandlerException.LogException(e);throw new CustomErrorExceptionHandlerException(e.getMessage());}
    }
    
    // Helper method to update territory details
    private static Map<String, Object> updateTerritoryDetails(Lead lead, Map<String, Object> territoryDetails) {
        Map<String, Object> response = new Map<String, Object>();
        
        try { 
            // Serialize back to JSON and update the field
            lead.Territory_Options__c =(String)territoryDetails.get('region');
            
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
            System.debug('Exception occurred during update: ' + e.getMessage());response.put('Message', 'Error during update: ' + e.getMessage());response.put('Status', 'Error');
        }
        
        return response;
    }
    
}