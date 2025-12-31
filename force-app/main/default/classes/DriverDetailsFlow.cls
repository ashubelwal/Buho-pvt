public without sharing class DriverDetailsFlow {
    @AuraEnabled
    public static Map<String, Object> saveDriverDetails(String strLeadDetails) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            System.debug('Received lead details: ' + strLeadDetails);
            
            if (String.isNotBlank(strLeadDetails)) {
                // Parse the JSON payload
                List<Object> payload = (List<Object>) JSON.deserializeUntyped(strLeadDetails);
                
                // Initialize data containers
                Map<String, Object> userDetails = new Map<String, Object>();
                List<Map<String, Object>> drivers = new List<Map<String, Object>>();
                Map<String, Object> companyInformation = new Map<String, Object>();
                Set<String> licenseNumbersSeen = new Set<String>();
                // Process each item in payload
                for (Object item : payload) {
                    Map<String, Object> data = (Map<String, Object>) item;
                    System.debug('Data name' + data);
                    if (data.containsKey('userDetails')) {
                        userDetails = (Map<String, Object>) data.get('userDetails');
                    }
                    else if (data.containsKey('driverDetails')) {
                        Map<String, Object> driverPage = (Map<String, Object>) data.get('driverDetails');
                        
                        // Extract drivers
                        // if (driverPage.containsKey('drivers')) {
                        //     List<Object> driverList = (List<Object>) driverPage.get('drivers');
                        //     for (Object driver : driverList) {
                        //         drivers.add((Map<String, Object>) driver);
                        //     }
                        // } 
                        // Extract and deduplicate drivers
                        if (driverPage.containsKey('drivers')) {
                            List<Object> driverList = (List<Object>) driverPage.get('drivers');
                            
                            // Deduplicate by license_number__c
                            

                            for (Object driver : driverList) {
                                Map<String, Object> driverMap = (Map<String, Object>) driver;

                                String licenseNumber = driverMap.containsKey('license_number__c') && driverMap.get('license_number__c') != null
                                    ? String.valueOf(driverMap.get('license_number__c')).trim()
                                    : null;
                                system.debug('licenseNumber@@#'+ licenseNumber);
                                if (String.isNotBlank(licenseNumber) && !licenseNumbersSeen.contains(licenseNumber)) {
                                    licenseNumbersSeen.add(licenseNumber);
                                    drivers.add(driverMap); // Only add if it's not a duplicate license
                                    system.debug('licenseNumbersSeen@@##'+ licenseNumbersSeen);
                                }
                            }
                            
                        }
                        if (driverPage.containsKey('companyInformation')) {
                            companyInformation = (Map<String, Object>) driverPage.get('companyInformation');
                        }
                        
                    } 
                    else if (data.containsKey('license_number__c')) {
                        String licenseNumber = data.get('license_number__c') != null
                            ? String.valueOf(data.get('license_number__c')).trim()
                            : null;

                        if (String.isNotBlank(licenseNumber) && !licenseNumbersSeen.contains(licenseNumber)) {
                            licenseNumbersSeen.add(licenseNumber);
                            drivers.add(data); // Add directly since data itself is a driver map
                        }
                    }
                }
                system.debug('drivers :: '+ json.serialize(drivers));
                
                // Find or create lead record
                String leadId = (String) userDetails.get('Id');
                Lead leadRecord;
                
                if (String.isNotBlank(leadId)) {
                    leadRecord = [SELECT Id, Driver_details__c, Company_details__c 
                                 FROM Lead WHERE Id = :leadId LIMIT 1];
                } else {
                    String email = (String) userDetails.get('Email');
                    if (String.isNotBlank(email)) {
                        List<Lead> leads = [SELECT Id, Driver_details__c, Company_details__c 
                                          FROM Lead WHERE Email = :email LIMIT 1];
                        if (!leads.isEmpty()) {
                            leadRecord = leads[0];
                        }
                    }
                }
                
                if (leadRecord == null) {
                    response.put('Message', 'Lead record not found');
                    response.put('Status', 'Error');
                    return response;
                }
                
                // Update driver details
                system.debug('drivers@@###'+ Json.serialize(drivers));
                if (!drivers.isEmpty()) {
                    leadRecord.Driver_details__c = JSON.serialize(drivers);
                        Object companyNameObj = companyInformation.get('Company_Name__c');
                        system.debug('companyNameObj@@@#'+companyNameObj);
                        String companyName = companyNameObj != null ? String.valueOf(companyNameObj) : '';
                        if (String.isBlank(companyName)) {
                            leadRecord.Company_details__c = '';
                        }
                }
                
                system.debug('leadRecord@@###'+ leadRecord);
                // Save changes
                Database.SaveResult sr = Database.update(leadRecord, false);
                
                if (sr.isSuccess()) {
                    response.put('LeadId', sr.getId());
                    response.put('Status', 'Success');
                    System.debug('Successfully updated lead: ' + sr.getId());
                } else {
                    response.put('Status', 'Error');
                    response.put('Message', sr.getErrors()[0].getMessage());
                    System.debug('Error updating lead: ' + sr.getErrors());
                }
            } else {
                response.put('Message', 'No data received');
                response.put('Status', 'Error');
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
            response.put('Message', 'Error processing request: ' + e.getMessage());
            response.put('Status', 'Error');
            // Log exception if you have a logging framework
        }
        
        return response;
    }
}