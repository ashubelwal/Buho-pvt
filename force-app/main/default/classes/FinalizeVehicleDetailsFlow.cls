public without sharing class FinalizeVehicleDetailsFlow {
    // New Lead for inserting vehicle details in the lead
    // Add vehicle data as a string in the lead details
    @AuraEnabled
    public static Map<String, Object> saveFinalizeVehicleDetails(String strLeadDetails) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            System.debug('String lead details in the vehicle save method: ' + strLeadDetails);
            
            if (String.isNotBlank(strLeadDetails)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
                
                // Initialize maps to store extracted data
                Map<String, Object> userDetails = new Map<String, Object>();
                Map<String, Object> vehicleDetails = new Map<String, Object>();
                Map<String, Object> vehicleDetailsOld = new Map<String, Object>();

                
                // Iterate over the leadDetails list
                // Iterate over the leadDetails list
                for (Object detail : leadDetails) {
                    try {
                        // Try casting the detail to a Map
                        Map<String, Object> dataMap = (Map<String, Object>) detail;
                        
                        if (dataMap.containsKey('userDetails')) {
                            userDetails = (Map<String, Object>) dataMap.get('userDetails');
                        }
                        if (dataMap.containsKey('vehicleDetails')) {
                            vehicleDetailsOld = (Map<String, Object>) dataMap.get('vehicleDetails');
                        }
                        if (dataMap.containsKey('finalizeVehicleDetails')) {
                            vehicleDetails = (Map<String, Object>) dataMap.get('finalizeVehicleDetails');
                        }
                    } catch (Exception e) {
                        System.debug('Skipping non-map entry: ' + e.getMessage());
                    }
                }
                
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
                            
                            response.put('Message', 'No lead found and Error in creating new Lead record.');
                            response.put('Status', 'Error');
                            return response;
                            
                        }
                    }else{
                        response.put('Message', 'Lead record not found.Email is required.');
                        response.put('Status', 'Error');
                        return response;
                    }
                }
                
                if (existingLead != null) {
                    return updateVehicleDetails(existingLead, vehicleDetails,vehicleDetailsOld);
                } else {
                    response.put('Message', 'Lead record not found using provided details.');
                    response.put('Status', 'Error');
                    return response;
                }
            } else {
                response.put('Message', 'No data found.');
                response.put('Status', 'Error');
                return response;
            }
        }catch (CustomErrorExceptionHandlerException ex){
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new CustomErrorExceptionHandlerException(ex.getMessage());
        }
        catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            throw new CustomErrorExceptionHandlerException(e.getMessage());
        }
    }
    
    // Helper method to update vehicle details
private static Map<String, Object> updateVehicleDetails(Lead lead, Map<String, Object> vehicleDetails, Map<String, Object> vehicleDetailsOld) {
    Map<String, Object> response = new Map<String, Object>();
    
    try {
        // Transform to match your exact desired format
        Map<String, Object> transformedData = new Map<String, Object>{
            'Coverage__c' => vehicleDetails.get('Coverage__c'),
            'Vehicle_Type__c' => vehicleDetails.get('Vehicle_sub_type__c'),
            'Is_the_vehicle_used_for_business_purpose__c' => vehicleDetails.get('is_the_vehicle_used_for_business_purpose__c'),
            'Is_this_a_Rental_Vehicle__c' => vehicleDetailsOld.get('Is_this_a_Rental_Vehicle__c'),
            'Salvage_Vehicle__c' => vehicleDetails.get('salvage_vehicle__c'),
            'Is_there_a_driver_under_21__c' => vehicleDetails.get('is_there_a_driver_under_21__c'),
            'Value__c' => String.valueOf(vehicleDetails.get('Value__c')),
            'Model__c' => vehicleDetails.get('Model__c'),
            'Make__c' => vehicleDetails.get('Make__c'),
            'Year__c' => String.valueOf(vehicleDetails.get('Year__c')),
            'Vehicle_sub_type__c' => vehicleDetails.get('Vehicle_sub_type__c'),
            'Registered_Country__c' => vehicleDetails.get('Registered_Country__c'),
            'Vin__c' => vehicleDetails.get('Vin__c'),
            'Registered_State__c' => vehicleDetails.get('Registered_State__c'),
            'Registered_Plate__c' => vehicleDetails.get('licensePlate'),
            'Is_the_vehicle_registered_to_a_business__c' => vehicleDetails.get('Is_the_vehicle_registered_to_a_business__c') != null ? vehicleDetails.get('Is_the_vehicle_registered_to_a_business__c') : false,
            'Is_Lienholder__c' => vehicleDetails.get('Is_Lienholder__c'),
            'BusinessAddress__c' => vehicleDetails.get('BusinessAddress__c'),
            'Is_Account_Company_Named__c' => false,
            'Vehicle_sub_type__c' => vehicleDetails.get('Vehicle_sub_type__c'),
            'isTowing' => vehicleDetails.get('isTowing'),
            'towunits' => vehicleDetails.get('towunits'),
            'Liability' => vehicleDetails.get('Liability__c'),
            'Medical' => vehicleDetails.get('Medical__c')
        }; 

        // OVERWRITE (not append) the Vehicle_Details__c field with the single object
        lead.Vehicle_Details__c = JSON.serialize(transformedData);
        
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

    // Method to fetch the country and the states
    @AuraEnabled(cacheable=true)
    public static List<String> getCountries() {
        // Get unique countries from metadata
        List<Country_State_Metadata__mdt> records = [
            SELECT Country__c 
            FROM Country_State_Metadata__mdt
            ORDER BY Country__c DESC
            LIMIT 10000
        ];
        
        Set<String> countrySet = new Set<String>();
        for (Country_State_Metadata__mdt record : records) {
            countrySet.add(record.Country__c);
        }
        
        return new List<String>(countrySet);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getStatesByCountry(String country) {
        if (String.isBlank(country)) {
            return new List<String>();
        }
        
        // Get states for selected country
        List<Country_State_Metadata__mdt> records = [
            SELECT State__c 
            FROM Country_State_Metadata__mdt 
            WHERE Country__c = :country 
            ORDER BY State__c
            LIMIT 1000
        ];
        
        List<String> states = new List<String>();
        for (Country_State_Metadata__mdt record : records) {
            states.add(record.State__c);
        }
        
        return states;
    }
}