public without sharing class TowDetailsFlow {
// Method to save the tow details in the lead.
@AuraEnabled
public static Map<String, Object> saveTowDetails(String strLeadDetails) {
    Map<String, Object> response = new Map<String, Object>();
    
    try {
        System.debug('String lead details in the tow save method: ' + strLeadDetails);
        
        if (String.isNotBlank(strLeadDetails)) {
            List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
            Map<String, Object> userDetails = new Map<String, Object>();
            List<Object> towDetailsList = new List<Object>();
            for (Object detail : leadDetails) {
                try {
                    Map<String, Object> dataMap = (Map<String, Object>) detail;
                    
                    if (dataMap.containsKey('userDetails')) {
                        userDetails = (Map<String, Object>) dataMap.get('userDetails');
                    }
                    if (dataMap.containsKey('towDetails')) {
                        towDetailsList = (List<Object>) dataMap.get('towDetails');
                    }
                } catch (Exception e) { System.debug('Skipping non-map entry: ' + e.getMessage());
                }
            }
            
            // Transform each towDetail to required structure
            List<Map<String, Object>> formattedTowDetails = new List<Map<String, Object>>();
            Integer towCount = 1;
            
            for (Object towDetailObj : towDetailsList) {
                Map<String, Object> towDetail = (Map<String, Object>) towDetailObj;
                Map<String, Object> formattedDetail = new Map<String, Object>{
                    'Towed_Unit_Type__c' => towDetail.get('Towed_Unit_Type__c'),
                    'Towed_Unit_Value__c' => towDetail.get('Towed_Unit_Value__c'),
                    'Days_in_Tow__c' => towDetail.get('Days_in_Tow__c'),
                    'towedCount' => towCount,
                    'isDeleteTowedButton' => true,
                    'selectedStyle' => '',
                    'Year__c' => towDetail.get('Year__c'),
                    'Make__c' => towDetail.get('Make__c'),
                    'Model__c' => towDetail.get('Model__c'),
                    'VIN_Number__c' => towDetail.get('VIN_Number__c'),
                    'Plate__c' => towDetail.get('Plate__c')
                };
                formattedTowDetails.add(formattedDetail);
                towCount++;
            }
            
            // Check if Lead ID is provided in userDetails
            String leadId = (String) userDetails.get('Id');
            Lead existingLead;
            
            if (String.isNotBlank(leadId)) {
                existingLead = [SELECT Id, Towing__c, Is_Towing__c FROM Lead WHERE Id = :leadId LIMIT 1];
            } else {
                String email = (String) userDetails.get('Email');
                if (String.isNotBlank(email)) {
                    List<Lead> leadsByEmail = [SELECT Id, Towing__c, Is_Towing__c FROM Lead WHERE Email = :email LIMIT 1];
                    if (!leadsByEmail.isEmpty()) {
                        existingLead = leadsByEmail[0];
                    } else {response.put('Message', 'No lead found with the provided email.');response.put('Status', 'Error');return response;
                    }
                } else { response.put('Message', 'Lead record not found. Email is required.'); response.put('Status', 'Error');return response;
                }
            }
            
            if (existingLead != null) {
                // Update Lead with all tow details in the correct array format
                existingLead.Towing__c = JSON.serialize(formattedTowDetails);
                existingLead.Is_Towing__c = true;
                update existingLead;
                
                response.put('Message', 'Tow details saved successfully.');
                response.put('Status', 'Success');
                response.put('Lead', existingLead);
                return response;
            } else { response.put('Message', 'Lead record not found using provided details.'); response.put('Status', 'Error');return response;
            }
        } else { response.put('Message', 'No data found.'); response.put('Status', 'Error');return response;
        }
    } catch (CustomErrorExceptionHandlerException ex) {  CustomErrorExceptionHandlerException.LogException(ex); throw new CustomErrorExceptionHandlerException(ex.getMessage());
    } catch (Exception e) {CustomErrorExceptionHandlerException.LogException(e);throw new CustomErrorExceptionHandlerException(e.getMessage());
    }
}
}