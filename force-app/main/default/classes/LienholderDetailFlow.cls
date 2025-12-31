public without sharing class LienholderDetailFlow {
    @AuraEnabled
    public static Map<String, Object> saveLienholderDetails(String strLeadDetails) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            System.debug('String lead details in the lienholder save method: ' + strLeadDetails);
            
            if (String.isNotBlank(strLeadDetails)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
                
                // Initialize maps to store extracted data
                Map<String, Object> userDetails = new Map<String, Object>();
                Map<String, Object> lienholderDetails = new Map<String, Object>();

                // Iterate over the leadDetails list
                for (Object detail : leadDetails) {
                    try {
                        Map<String, Object> dataMap = (Map<String, Object>) detail;
                        
                        if (dataMap.containsKey('userDetails')) {
                            userDetails = (Map<String, Object>) dataMap.get('userDetails');
                        }
                        if (dataMap.containsKey('lienholderInformation')) {
                            lienholderDetails = (Map<String, Object>) dataMap.get('lienholderInformation');
                        }
                    } catch (Exception e) {
                        System.debug('Skipping non-map entry: ' + e.getMessage());
                    }
                }
                
                // Check if Lead ID is provided in userDetails
                String leadId = (String) userDetails.get('Id');
                Lead existingLead;
                
                if (String.isNotBlank(leadId)) {
                    existingLead = [SELECT Id, Lienholder_info__c FROM Lead WHERE Id = :leadId LIMIT 1];
                } else {
                    // If LeadId is not provided, find Lead by email
                    String email = (String) userDetails.get('Email');
                    if (String.isNotBlank(email)) {
                        List<Lead> leadsByEmail = [SELECT Id, Lienholder_info__c FROM Lead WHERE Email = :email LIMIT 1];
                        if (!leadsByEmail.isEmpty()) {
                            existingLead = leadsByEmail[0];
                        } else {
                            response.put('Message', 'No lead found.');
                            response.put('Status', 'Error');
                            return response;
                        }
                    } else {
                        response.put('Message', 'Lead record not found. Email is required.');
                        response.put('Status', 'Error');
                        return response;
                    }
                }
                
                if (existingLead != null) {
                    return updateLienholderDetails(existingLead, lienholderDetails);
                } else { response.put('Message', 'Lead record not found using provided details.');response.put('Status', 'Error');return response;
                }
            } else {
                response.put('Message', 'No data found.'); response.put('Status', 'Error');
                return response;
            }
        } catch (CustomErrorExceptionHandlerException ex) {CustomErrorExceptionHandlerException.LogException(ex); throw new CustomErrorExceptionHandlerException(ex.getMessage());
        } catch (Exception e) {CustomErrorExceptionHandlerException.LogException(e);throw new CustomErrorExceptionHandlerException(e.getMessage()); }
    }
    
    private static Map<String, Object> updateLienholderDetails(Lead lead, Map<String, Object> lienholderDetails) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            if (lienholderDetails.containsKey('Lienholder_Country__cmbx')) {
                lienholderDetails.remove('Lienholder_Country__cmbx');
            }
            lead.Lienholder_info__c = JSON.serialize(lienholderDetails);
            Database.SaveResult sr = Database.update(lead, false);
            if (sr.isSuccess()) {
                System.debug('Lead updated successfully. ID: ' + sr.getId());
                response.put('LeadId', sr.getId());
                response.put('Data', lead);
                response.put('Status', 'Success');
            } else {
                for (Database.Error error : sr.getErrors()) {
                    System.debug('Error message: ' + error.getMessage());
                    response.put('Message', error.getMessage());
                    response.put('Status', 'Error');
                }
            }
        } catch (Exception e) { System.debug('Exception occurred during update: ' + e.getMessage()); response.put('Message', 'Error during update: ' + e.getMessage());response.put('Status', 'Error');
        }
        return response;
    }
}