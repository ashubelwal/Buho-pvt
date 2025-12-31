public without sharing class TermOptionFlow {
    
    // Get the list of term days from Custom metadata
    @AuraEnabled
    public static Map<String,Object> getTermDaysMetadata(){
        try {
            Map<String,Object> response = new Map<String,Object>();
            List<Map<String, String>> termDays = new List<Map<String, String>>();
            for (Term_day__mdt type : [SELECT Label__c, Value__c FROM Term_day__mdt  Order By Id desc]) {
                Map<String, String> entry = new Map<String, String>();
                entry.put('label', type.Label__c);
                entry.put('value', type.Value__c);
                termDays.add(entry);
            }
            if(termDays.size() > 0) {
                // Populate the response map with data and status
                response.put('Data', termDays);
                response.put('Status', 'Success');
            } else {response.put('Status', 'Error'); response.put('Message', 'No Vehicle Types found');
            }
            
            // Return the response map to the caller
            return response;
        } catch (CustomErrorExceptionHandlerException e) { CustomErrorExceptionHandlerException.LogException(e); throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage());
        } catch (Exception e) { CustomErrorExceptionHandlerException.LogException(e);throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage());}
    }
    
    // Use metadata to add days to the term selected by the user.
    // Not appplicable for daily term option.
    // Only for those whose no of days are fixed i.e Annual,Sem-Annual,Quaterly
    @AuraEnabled
    public static Map<String,Object> getTermAndDaysMetadata(){
        try {
            Map<String,Object> response = new Map<String,Object>();
            List<Map<String, String>> termDays = new List<Map<String, String>>();
           for (Term_and_Day__mdt type : [SELECT Id, Label,Term__c, Day__c FROM Term_and_Day__mdt  Order By Id desc]) {
                Map<String, String> entry = new Map<String, String>(); 
                entry.put('Term', type.Term__c);
                entry.put('Day', String.valueOf(type.Day__c));                
                termDays.add(entry);
            }
            
            if(termDays.size() > 0) {
                response.put('Data', termDays);
                response.put('Status', 'Success');
            } else {
                response.put('Status', 'Error');response.put('Message', 'No term and days data found.');
            }
            return response;
        } catch (CustomErrorExceptionHandlerException e) { CustomErrorExceptionHandlerException.LogException(e);throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage());
        } catch (Exception e) { CustomErrorExceptionHandlerException.LogException(e);throw new CustomErrorExceptionHandlerException('An unexpected error occurred: ' + e.getMessage()); }
    }
    // New lead for inserting policy terms
    // Add policy terms such as Annual,Semi-Annual,Daily,Start date and end Date
    @AuraEnabled
    public static Map<String, Object> saveLeadPolicyTerms(String strLeadDetails){
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            System.debug('String lead details in the termoption save method: ' + strLeadDetails);
            
            if (String.isNotBlank(strLeadDetails)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
                
                // Extract user details and vehicle details
                Map<String,Object>  userDetails = new Map<String, Object>();
                Map<String, Object> vehicleDetails = new Map<String, Object>();
                Map<String, Object> termDetails = new Map<String, Object>();
                
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
                    } catch (Exception e) { 
                        System.debug('Skipping non-map entry: ' + e.getMessage());
                    }
                }
                
                // Check if Lead ID is provided in userDetails
                String leadId = (String) userDetails.get('Id');
                Lead existingLead;
                
                if (String.isNotBlank(leadId)) {
                    existingLead = [SELECT Id, Term_options__c FROM Lead WHERE Id = :leadId LIMIT 1];
                } else {
                    // If LeadId is not provided, find Lead by email
                    String email = (String) userDetails.get('Email');
                    if (String.isNotBlank(email)) {
                        List<Lead> leadsByEmail = [SELECT Id, Term_options__c FROM Lead WHERE Email = :email LIMIT 1];
                        if (!leadsByEmail.isEmpty()) {
                            existingLead = leadsByEmail[0];
                        }else{
                            // If Lead by email is not found,throw an error.
                            response.put('Message', 'Lead record not found. Please check again.');
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
                    //termDetails = calculateEndTimeForTerm(termDetails);
                    return updateTermOptionDetails(existingLead, termDetails);
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
        }catch (CustomErrorExceptionHandlerException ex){ CustomErrorExceptionHandlerException.LogException(ex);throw new CustomErrorExceptionHandlerException(ex.getMessage());
        }
        catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            throw new CustomErrorExceptionHandlerException(e.getMessage());
        }
    }
    
    
    // Helper method to update term details
    private static Map<String, Object> updateTermOptionDetails(Lead lead, Map<String, Object> termDetails) {
        Map<String, Object> response = new Map<String, Object>();
        System.debug('@@@@@'+termDetails);
        try {
            List<Map<String, Object>> termOptionList = new List<Map<String, Object>>();
            termOptionList.add(termDetails); 

            lead.Term_options__c = JSON.serialize(termOptionList);
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
            response.put('Message', 'Error during update: ' + e.getMessage());response.put('Status', 'Error');
        }
        
        return response;
    }


    
    // Method to set the end time based on the Term type selected by the user
    // Yearly,Semi-annual and Daily - If Start Date is today then it will start from the time selected by user and end date would be same
    // Yearly,Semi-Annual - IF start date is future then start time should be 12 AM TO 12AM. If Daily - Start time is selcted by the user
    /**
     * Helper method to calculate the end time for term details based on CMDT.
     */
    private static Map<String, Object> calculateEndTimeForTerm(Map<String, Object> termDetails) {
        // Fetch the term type from the term details
        String termType = (String) termDetails.get('Term__c');
        
        // Fetch CMDT record for the term type
        Term_Type_Metadata__mdt metadata = [
            SELECT Future_Start_Time_is_Midnight__c 
            FROM Term_Type_Metadata__mdt 
            WHERE Label = :termType 
            LIMIT 1
        ];
        String endTime;
        // Calculate start and end times based on metadata
        if (Boolean.valueOf(metadata.Future_Start_Time_is_Midnight__c)) {
            endTime = '12:00:00';
        } else {
            endTime = (String)termDetails.get('Start_Time__c');
        }
        
        // Update term details with calculated times
        termDetails.put('End_Time__c', endTime);
        
        return termDetails;
    }

    // For explicitly calculating the end time for the Term- Contact
    @AuraEnabled
    public static String getCalculatedTermEndTime(String strTermDetailsJson) {
        Map<String, Object> termDetails = (Map<String, Object>) JSON.deserializeUntyped(strTermDetailsJson);
        Map<String, Object> updatedDetails = calculateEndTimeForTerm(termDetails);
        return (String) updatedDetails.get('End_Time__c');
    }
    
}