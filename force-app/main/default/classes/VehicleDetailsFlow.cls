public without sharing class VehicleDetailsFlow {
    
    // Method to get the vehicle types from the Custom metdata
    // Use this method to show the lsit of vehicle types in vehicle details page
    @AuraEnabled
    public static Map<String,Object> getVehicleTypesMetadata(){
        try {
            // Initialize a response map to store the result and any relevant data
            Map<String,Object> response = new Map<String,Object>();
            // List to store vehicle type data as key-value pairs (label and value)
            List<Map<String, String>> vehicleTypes = new List<Map<String, String>>();
            // Query all records from the Vehicle_Types__mdt metadata type
            for (Vehicle_Types__mdt type : [SELECT Label__c, Value__c FROM Vehicle_Types__mdt]) {
                Map<String, String> entry = new Map<String, String>();
                entry.put('label', type.Label__c);
                entry.put('value', type.Value__c);
                vehicleTypes.add(entry);
            }
            
            // Check if the vehicle types list is not empty
            if(vehicleTypes.size() > 0) {
                // Populate the response map with data and status
                response.put('Data', vehicleTypes);
                response.put('Status', 'Success');
            } else { response.put('Status', 'Error');response.put('Message', 'No Vehicle Types found'); }
            
            return response;
        } catch (CustomErrorExceptionHandlerException e) {CustomErrorExceptionHandlerException.LogException(e); throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage());
        } catch (Exception e) { CustomErrorExceptionHandlerException.LogException(e); throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage()); }
    }
    
    @AuraEnabled
    public static List<object> getYears(){
        try{
            return VehicleDetailsAPI.getYears();
        }catch(Exception e){
            CustomErrorExceptionHandlerException.LogException(e);
            throw new CustomErrorExceptionHandlerException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String,Object> getMakes(string year){
        try{
            // Initialize a response map to store the result and any relevant data
            Map<String,Object> response = new Map<String,Object>();
            
            List<Object> data = new List<Object>();
            data = VehicleDetailsAPI.getMakesFromCarAPI(year);
            
            if(data != null){
                response.put('Data', data);
                response.put('Status', 'Success');
            }else{
                response.put('Status', 'Error'); response.put('Message', 'No Makes found');
            }
            
            return response ;
            
        }catch(Exception e){
            CustomErrorExceptionHandlerException.LogException(e); 
            throw new CustomErrorExceptionHandlerException(e.getMessage()+e.getStackTraceString()); 
        }
    }
    
    @AuraEnabled
    public static Map<String,Object> getModels(string year, string make){
        try{
            Map<String,Object> response = new Map<String,Object>();
            
            List<Object> data = new List<Object>();
            data = VehicleDetailsAPI.fetchModelsFromCarAPI(year, make);
            
            if(data != null){
                response.put('Data', data);
                response.put('Status', 'Success');
            }else{
                response.put('Status', 'Error');
                response.put('Message', 'No Models found');
            }
            
            return response;
        }catch(Exception e){
            CustomErrorExceptionHandlerException.LogException(e);
            throw new CustomErrorExceptionHandlerException(e.getMessage()+e.getStackTraceString());}
    }
    
    // New Lead for inserting vehicle details in the lead
    // Add vehicle data as a string in the lead details
    @AuraEnabled
    public static Map<String, Object> saveLeadVehicleDetails(String strLeadDetails) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            System.debug('String lead details in the vehicle save method: ' + strLeadDetails);
            
            if (String.isNotBlank(strLeadDetails)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
                
                // Extract user details and vehicle details
                Map<String, Object> userData = (Map<String, Object>) leadDetails[0];
                Map<String,Object>  userDetails = (Map<String,Object>) userData.get('userDetails');
                Map<String,Object>  leadData = (Map<String,Object>) leadDetails[1];
                Map<String, Object> vehicleDetails = (Map<String, Object>) leadData.get('vehicleDetails');
                
                // Check if Lead ID is provided in userDetails
                String leadId = (String) userDetails.get('Id');
                Lead existingLead;
                
                if (String.isNotBlank(leadId)) {
                    existingLead = [SELECT Id, Vehicle_Details__c FROM Lead WHERE Id = :leadId LIMIT 1];
                } else {
                    // If LeadId is not provided, find Lead by email
                    String email = (String) userDetails.get('Email');
                    if (String.isNotBlank(email)) {
                        List<Lead> leadsByEmail = [SELECT Id, Vehicle_Details__c FROM Lead WHERE Email = :email LIMIT 1];
                        if (!leadsByEmail.isEmpty()) {
                            existingLead = leadsByEmail[0];
                        }else{
                            // If Lead by email is not found, create a new one
                            Map<String,Object> leadCreationResponse = CustomerQuoteFlow.saveLeadUserDetails(JSON.serialize(userDetails));
                            if(leadCreationResponse.get('Status') == 'Success'){
                                existingLead = (Lead)leadCreationResponse.get('Data');
                            }else{
                                response.put('Message', 'No lead found and Error in creating new Lead record.');
                                response.put('Status', 'Error');
                                return response;
                            }
                        }
                    }else{
                        response.put('Message', 'Lead record not found.Email is required.');
                        response.put('Status', 'Error');
                        return response;
                    }
                }
                
                if (existingLead != null) {
                    return updateVehicleDetails(existingLead, vehicleDetails);
                } else {
                    response.put('Message', 'Lead record not found using provided details.');response.put('Status', 'Error'); return response;
                }
            } else {
                response.put('Message', 'No data found.'); response.put('Status', 'Error');
                return response;
            }
        }catch (CustomErrorExceptionHandlerException ex){ CustomErrorExceptionHandlerException.LogException(ex); throw new CustomErrorExceptionHandlerException(ex.getMessage()); }
         catch (Exception e) { CustomErrorExceptionHandlerException.LogException(e); throw new CustomErrorExceptionHandlerException(e.getMessage()); } 
    }
    
    // Helper method to update vehicle details
private static Map<String, Object> updateVehicleDetails(Lead lead, Map<String, Object> vehicleDetails) {
    Map<String, Object> response = new Map<String, Object>();

    try {
        Map<String, Object> existingVehicleDetailsMap = new Map<String, Object>();

        if (String.isNotBlank(lead.Vehicle_Details__c)) {
            // Deserialize existing vehicle details as a Map
            existingVehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(lead.Vehicle_Details__c);
        }

        // Merge the new vehicleDetails into the existing map
        for (String key : vehicleDetails.keySet()) {
            existingVehicleDetailsMap.put(key, vehicleDetails.get(key));
        }

        // Serialize back to JSON and update the Lead record
        lead.Vehicle_Details__c = JSON.serialize(existingVehicleDetailsMap);
        lead.Vehicle_Type__c = (String)existingVehicleDetailsMap.get('Vehicle_sub_type__c');
        lead.Insurance_Type__c = (String)existingVehicleDetailsMap.get('Vehicle_sub_type__c');
        lead.Policy_Type__c = (String)existingVehicleDetailsMap.get('Vehicle_sub_type__c');
        Database.SaveResult sr = Database.update(lead, false);

        if (sr.isSuccess()) {
            response.put('LeadId', sr.getId());
            response.put('Data', lead);
            response.put('Status', 'Success');
        } else {
            for (Database.Error error : sr.getErrors()) {
                response.put('Message', error.getMessage());
                response.put('Status', 'Error');
            }
        }
    } catch (Exception e) {
        response.put('Message', 'Error during update: ' + e.getMessage());
        response.put('Status', 'Error');
    }

    return response;
}
    
    
    
    
    
}