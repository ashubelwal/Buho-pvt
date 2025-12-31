// public class DairylandCSVProcessor {
    
//     /**
//      * Processes the contents of a CSV file to create or update leads
//      * @param csvFileContent The content of the CSV file as a String
//      * @return A list of IDs of the created/updated leads
//      */
//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         List<Lead> leadsToUpsert = new List<Lead>();
//         Map<String, Id> emailToLeadIdMap = new Map<String, Id>();
        
//         try {
//             List<String> lines = csvFileContent.split('\n');
//             String headerLine = lines[0];
//             List<String> headers = headerLine.split(',');
            
//             validateCSVFormat(headers);
            
//             List<String> emailsInCSV = new List<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 4 && String.isNotBlank(values[3])) {
//                         emailsInCSV.add(values[3].trim());
//                     }
//                 }
//             }
            
//             if (!emailsInCSV.isEmpty()) {
//                 for (Lead existingLead : [SELECT Id, Email FROM Lead WHERE Email IN :emailsInCSV]) {
//                     emailToLeadIdMap.put(existingLead.Email.toLowerCase(), existingLead.Id);
//                 }
//             }
            
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
                    
//                     // if (values.size() >= 4) {
//                     //     String firstName = values[0].trim();
//                     //     String lastName = values[1].trim();
//                     //     //I NEED TO ADD THIS FIELD: Quote_Number__c

//                     //     String phone = values[2].trim();
//                     //     String email = values[3].trim().toLowerCase();
//                     //     String company = (values.size() >= 5 && String.isNotBlank(values[4])) ? 
//                     //                      values[4].trim() : email;
//                     if (values.size() >= 4) {
//                         String firstName = values[0].trim();
//                         String lastName = values[1].trim();
//                         // Extract field Quote_Number__c
//                         String quoteNumber = (values.size() >= 6 && String.isNotBlank(values[5])) ? 
//                                             values[5].trim() : null;

//                         String phone = values[2].trim();
//                         String email = values[3].trim().toLowerCase();
//                         String company = (values.size() >= 5 && String.isNotBlank(values[4])) ? 
//                                         values[4].trim() : email;
                        
//                         if (String.isNotBlank(email)) {
//                             Lead newLead;
                            
//                             if (emailToLeadIdMap.containsKey(email)) {
//                                 newLead = new Lead(
//                                     Id = emailToLeadIdMap.get(email),
//                                     FirstName = firstName,
//                                     LastName = lastName,
//                                     Quote_Number__c = quoteNumber,
//                                     Phone = phone,
//                                     Email = email,
//                                     Company = company
                                    
//                                 );
//                             } else {
//                                 newLead = new Lead(
//                                     FirstName = firstName,
//                                     LastName = lastName,
//                                     Quote_Number__c = quoteNumber,
//                                     Phone = phone,
//                                     Email = email,
//                                     Company = company,
//                                     LeadSource = 'Dairyland Import'
//                                 );
//                             }
                            
//                             leadsToUpsert.add(newLead);
//                         }
//                     }
//                 }
//             }
            
//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;
                
//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }
            
//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }
        
//         return resultIds;
//     }
    
//     /**
//      * Parses a CSV line accounting for quotes
//      * @param line The CSV line to parse
//      * @return List of separated values
//      */
//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';
        
//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i+1);
            
//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }
        
//         result.add(currentValue);
//         return result;
//     }
    
//     /**
//      * Validates the format of the CSV headers
//      * @param headers The CSV header row
//      */
//     private static void validateCSVFormat(List<String> headers) {
//         List<String> expectedHeaders = new List<String>{'FirstName', 'LastName', 'Phone', 'Email', 'Company'};
        
//         List<String> normalizedHeaders = new List<String>();
//         for (String header : headers) {
//             normalizedHeaders.add(header.trim().toLowerCase());
//         }
        
//         Boolean hasFirstName = normalizedHeaders.contains('firstname');
//         Boolean hasLastName = normalizedHeaders.contains('lastname');
//         Boolean hasPhone = normalizedHeaders.contains('phone');
//         Boolean hasEmail = normalizedHeaders.contains('email');
        
//         if (!hasFirstName || !hasLastName || !hasPhone || !hasEmail) {
//             throw new CSVFormatException('The CSV file does not have the expected format. Required fields: FirstName, LastName, Phone, Email');
//         }
//     }

//     /**
//      * Adds leads to the Dairyland campaign (optional method, currently commented)
//      */
//     // private static void addLeadsToDairylandCampaign(List<Lead> leads) {
//     //     try {
//     //         Campaign dairylandCampaign;
//     //         List<Campaign> existingCampaigns = [SELECT Id FROM Campaign WHERE Name = 'Dairyland Leads' LIMIT 1];
            
//     //         if (existingCampaigns.isEmpty()) {
//     //             dairylandCampaign = new Campaign(
//     //                 Name = 'Dairyland Leads',
//     //                 IsActive = true,
//     //                 Type = 'Email'
//     //             );
//     //             insert dairylandCampaign;
//     //         } else {
//     //             dairylandCampaign = existingCampaigns[0];
//     //         }
            
//     //         List<CampaignMember> membersToInsert = new List<CampaignMember>();
//     //         Set<Id> leadIds = new Set<Id>();
//     //         for (Lead l : leads) {
//     //             leadIds.add(l.Id);
//     //         }
            
//     //         Map<Id, Id> existingMembers = new Map<Id, Id>();
//     //         for (CampaignMember cm : [SELECT Id, LeadId FROM CampaignMember 
//     //                                  WHERE CampaignId = :dairylandCampaign.Id AND LeadId IN :leadIds]) {
//     //             existingMembers.put(cm.LeadId, cm.Id);
//     //         }
            
//     //         for (Lead l : leads) {
//     //             if (!existingMembers.containsKey(l.Id)) {
//     //                 CampaignMember cm = new CampaignMember(
//     //                     CampaignId = dairylandCampaign.Id,
//     //                     LeadId = l.Id,
//     //                     Status = 'Sent'
//     //                 );
//     //                 membersToInsert.add(cm);
//     //             }
//     //         }
            
//     //         if (!membersToInsert.isEmpty()) {
//     //             insert membersToInsert;
//     //         }
            
//     //     } catch (Exception e) {
//     //         System.debug('Error adding leads to campaign: ' + e.getMessage());
//     //     }
//     // }
    
//     /**
//      * Custom exception class for CSV format errors
//      */
//     public class CSVFormatException extends Exception {}
// }

//SEMI ESTABLE VERSION
// public class DairylandCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         List<Lead> leadsToUpsert = new List<Lead>();
//         Map<String, Id> emailToLeadIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             List<String> emailsInCSV = new List<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 5 && String.isNotBlank(values[4])) {
//                         emailsInCSV.add(values[4].trim().toLowerCase());
//                     }
//                 }
//             }

//             if (!emailsInCSV.isEmpty()) {
//                 for (Lead existingLead : [
//                     SELECT Id, Email FROM Lead WHERE Email IN :emailsInCSV
//                 ]) {
//                     emailToLeadIdMap.put(existingLead.Email.toLowerCase(), existingLead.Id);
//                 }
//             }

//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     // Protect against missing fields
//                     String firstName = values.size() > 0 ? values[0].trim() : null;
//                     String lastName = values.size() > 1 ? values[1].trim() : null;
//                     String quoteNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() : email;
//                     String policyType = values.size() > 6 ? values[6].trim() : null;
//                     String rateState = values.size() > 7 ? values[7].trim() : null;
//                     String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;

//                     Date quoteEffectiveDate = null;
//                     if (String.isNotBlank(quoteEffectiveDateStr)) {
//                         try {
//                             quoteEffectiveDate = Date.valueOf(quoteEffectiveDateStr);
//                         } catch (Exception ex) {
//                             // Skip invalid dates silently
//                         }
//                     }

//                     if (String.isNotBlank(email)) {
//                         Lead lead;
//                         if (emailToLeadIdMap.containsKey(email)) {
//                             lead = new Lead(
//                                 Id = emailToLeadIdMap.get(email),
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate
//                             );
//                         } else {
//                             lead = new Lead(
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 LeadSource = 'Dairyland Import',
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate
//                             );
//                         }

//                         leadsToUpsert.add(lead);
//                     }
//                 }
//             }

//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;

//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';

//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i + 1);

//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.add(currentValue);
//         return result;
//     }

//     private static void validateCSVFormat(List<String> headers) {
//         List<String> requiredHeaders = new List<String>{'FirstName', 'LastName', 'Phone', 'Email'};

//         Set<String> normalizedHeaders = new Set<String>();
//         for (String h : headers) {
//             normalizedHeaders.add(h.trim().toLowerCase());
//         }

//         for (String req : requiredHeaders) {
//             if (!normalizedHeaders.contains(req.toLowerCase())) {
//                 throw new CSVFormatException('Missing required column: ' + req);
//             }
//         }
//     }

//     public class CSVFormatException extends Exception {}
// }

//THIS IS THE PREFINAL VERSION AND WORKS GOOD

//NEW VERSIONS
// BY EMAIL VALIDATION
// public class DairylandCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Lead> emailToLeadMap = new Map<String, Lead>();
//         Map<String, Id> emailToLeadIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             // Step 1: Collect unique emails from CSV
//             Set<String> uniqueEmailsInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 5 && String.isNotBlank(values[4])) {
//                         uniqueEmailsInCSV.add(values[4].trim().toLowerCase());
//                     }
//                 }
//             }

//             // Step 2: Query existing leads once
//             if (!uniqueEmailsInCSV.isEmpty()) {
//                 for (Lead existingLead : [
//                     SELECT Id, Email FROM Lead WHERE Email IN :uniqueEmailsInCSV
//                 ]) {
//                     emailToLeadIdMap.put(existingLead.Email.toLowerCase(), existingLead.Id);
//                 }
//             }

//             // Step 3: Process CSV rows, handling duplicates
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     // Protect against missing fields
//                     String firstName = values.size() > 0 ? values[0].trim() : null;
//                     String lastName = values.size() > 1 ? values[1].trim() : null;
//                     String quoteNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() : email;
//                     String policyType = values.size() > 6 ? values[6].trim() : null;
//                     String rateState = values.size() > 7 ? values[7].trim() : null;
//                     String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;

//                     Date quoteEffectiveDate = null;
//                     if (String.isNotBlank(quoteEffectiveDateStr)) {
//                         try {
//                             quoteEffectiveDate = Date.valueOf(quoteEffectiveDateStr);
//                         } catch (Exception ex) {
//                             // Skip invalid dates silently
//                         }
//                     }

//                     if (String.isNotBlank(email)) {
//                         Lead lead;
                        
//                         // Check if we've already processed a record with this email in the current import
//                         // This prevents duplicate IDs in the upsert list
//                         if (emailToLeadMap.containsKey(email)) {
//                             // We already have a lead with this email in our current batch, skip it
//                             continue;
//                         }
                        
//                         if (emailToLeadIdMap.containsKey(email)) {
//                             lead = new Lead(
//                                 Id = emailToLeadIdMap.get(email),
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate
//                             );
//                         } else {
//                             lead = new Lead(
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 LeadSource = 'Dairyland Import',
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate
//                             );
//                         }

//                         // Store in our map to prevent duplicates
//                         emailToLeadMap.put(email, lead);
//                     }
//                 }
//             }

//             // Step 4: Convert map to list for upsert
//             List<Lead> leadsToUpsert = emailToLeadMap.values();
            
//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;

//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';

//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i + 1);

//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.add(currentValue);
//         return result;
//     }

//     private static void validateCSVFormat(List<String> headers) {
//         List<String> requiredHeaders = new List<String>{'FirstName', 'LastName', 'Phone', 'Email'};

//         Set<String> normalizedHeaders = new Set<String>();
//         for (String h : headers) {
//             normalizedHeaders.add(h.trim().toLowerCase());
//         }

//         for (String req : requiredHeaders) {
//             if (!normalizedHeaders.contains(req.toLowerCase())) {
//                 throw new CSVFormatException('Missing required column: ' + req);
//             }
//         }
//     }

//     public class CSVFormatException extends Exception {}
// }
//EMD BY EMAIL VALIDATION

//BY QUOTE VALIDATION
// public class DairylandCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Lead> quoteNumberToLeadMap = new Map<String, Lead>();
//         Map<String, Id> quoteNumberToLeadIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             // Step 1: Collect unique quote numbers from CSV
//             Set<String> uniqueQuoteNumbersInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 3 && String.isNotBlank(values[2])) {
//                         uniqueQuoteNumbersInCSV.add(values[2].trim());
//                     }
//                 }
//             }

//             // Step 2: Query existing leads once
//             if (!uniqueQuoteNumbersInCSV.isEmpty()) {
//                 for (Lead existingLead : [
//                     SELECT Id, Quote_Number__c FROM Lead WHERE Quote_Number__c IN :uniqueQuoteNumbersInCSV
//                 ]) {
//                     quoteNumberToLeadIdMap.put(existingLead.Quote_Number__c, existingLead.Id);
//                 }
//             }

//             // Step 3: Process CSV rows, handling duplicates
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     // Protect against missing fields
//                     String lastName = values.size() > 1 ? values[1].trim() : null;
//                     String firstName = values.size() > 0 ? values[0].trim() : null;
//                     String quoteNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     // If the fields comes clean, we use firstName + lastName as a preset field
//                     String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() : (String.isNotBlank(firstName) && String.isNotBlank(lastName)) ? firstName + ' ' + lastName : 'Unknown';
//                     String policyType = values.size() > 6 ? values[6].trim() : null;
//                     String rateState = values.size() > 7 ? values[7].trim() : null;
//                     String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;
//                     String status = values.size() > 9 ? values[9].trim() : null;

//                     Date quoteEffectiveDate = null;
//                     if (String.isNotBlank(quoteEffectiveDateStr)) {
//                         try {
//                             quoteEffectiveDate = Date.valueOf(quoteEffectiveDateStr);
//                         } catch (Exception ex) {
//                             // Skip invalid dates silently
//                         }
//                     }

//                     if (String.isNotBlank(quoteNumber)) {  // changed the email to quoteNumber
//                         Lead lead;
                        
//                         // Check if we've already processed a record with this quote number in the current import
//                         // This prevents duplicate IDs in the upsert list
//                         if (quoteNumberToLeadMap.containsKey(quoteNumber)) {
//                             // We already have a lead with this quote number in our current batch, skip it
//                             continue;
//                         }
                        
//                         if (quoteNumberToLeadIdMap.containsKey(quoteNumber)) {
//                             lead = new Lead(
//                                 Id = quoteNumberToLeadIdMap.get(quoteNumber),
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate,
//                                 Notes__c = status
//                             );
//                         } else {
//                             lead = new Lead(
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 LeadSource = 'Dairyland Import',
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate,
//                                 Notes__c = status
//                             );
//                         }

//                         // Store in our map to prevent duplicates
//                         quoteNumberToLeadMap.put(quoteNumber, lead);
//                     }
//                 }
//             }

//             // Step 4: Convert map to list for upsert
//             List<Lead> leadsToUpsert = quoteNumberToLeadMap.values();
            
//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;

//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';

//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i + 1);

//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.add(currentValue);
//         return result;
//     }

//     private static void validateCSVFormat(List<String> headers) {
//         List<String> requiredHeaders = new List<String>{'Last Name','First Name', 'Quote Number', 'Phone', 'Email'};

//         Set<String> normalizedHeaders = new Set<String>();
//         for (String h : headers) {
//             normalizedHeaders.add(h.trim().toLowerCase());
//         }

//         for (String req : requiredHeaders) {
//             if (!normalizedHeaders.contains(req.toLowerCase())) {
//                 throw new CSVFormatException('Missing required column: ' + req);
//             }
//         }
//     }

//     public class CSVFormatException extends Exception {}
// }
//END BY QUOTE VALIDATION
// public class DairylandCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Lead> quoteNumberToLeadMap = new Map<String, Lead>();
//         Map<String, Id> quoteNumberToLeadIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             // Step 1: Collect unique quote numbers from CSV
//             Set<String> uniqueQuoteNumbersInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 3 && String.isNotBlank(values[2])) {
//                         uniqueQuoteNumbersInCSV.add(values[2].trim());
//                     }
//                 }
//             }

//             // Step 2: Query existing leads once
//             if (!uniqueQuoteNumbersInCSV.isEmpty()) {
//                 for (Lead existingLead : [
//                     SELECT Id, Quote_Number__c FROM Lead WHERE Quote_Number__c IN :uniqueQuoteNumbersInCSV
//                 ]) {
//                     quoteNumberToLeadIdMap.put(existingLead.Quote_Number__c, existingLead.Id);
//                 }
//             }

//             // Step 3: Process CSV rows, handling duplicates
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     // Protect against missing fields
//                     String lastName = values.size() > 1 ? values[1].trim() : null;
//                     String firstName = values.size() > 0 ? values[0].trim() : null;
//                     String quoteNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     // If the fields comes clean, we use firstName + lastName as a preset field
//                     String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() : (String.isNotBlank(firstName) && String.isNotBlank(lastName)) ? firstName + ' ' + lastName : 'Unknown';
//                     String policyType = values.size() > 6 ? values[6].trim() : null;
//                     String rateState = values.size() > 7 ? values[7].trim() : null;
//                     String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;
//                     String status = values.size() > 9 ? values[9].trim() : null;
//                     //new field for Insurance_Type__c
//                     String insuranceType = values.size() > 10 ? values[10].trim() : null;


//                     Date quoteEffectiveDate = null;
//                     if (String.isNotBlank(quoteEffectiveDateStr)) {
//                         try {
//                             // Parse date in format MM/dd/yy or M/d/yy
//                             quoteEffectiveDate = parseDate(quoteEffectiveDateStr);
//                         } catch (Exception ex) {
//                             // Skip invalid dates silently
//                             System.debug('Failed to parse date: ' + quoteEffectiveDateStr + '. Error: ' + ex.getMessage());
//                         }
//                     }

//                     if (String.isNotBlank(quoteNumber)) {  // changed the email to quoteNumber
//                         Lead lead;
                        
//                         // Check if we've already processed a record with this quote number in the current import
//                         // This prevents duplicate IDs in the upsert list
//                         if (quoteNumberToLeadMap.containsKey(quoteNumber)) {
//                             // We already have a lead with this quote number in our current batch, skip it
//                             continue;
//                         }
                        
//                         if (quoteNumberToLeadIdMap.containsKey(quoteNumber)) {
//                             lead = new Lead(
//                                 Id = quoteNumberToLeadIdMap.get(quoteNumber),
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate,
//                                 Notes__c = status,
//                             //new field for Insurance_Type__c
//                                 Insurance_Type__c = insuranceType

//                             );
//                         } else {
//                             lead = new Lead(
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 LeadSource = 'Dairyland Import',
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate,
//                                 Notes__c = status,
//                             //new field for Insurance_Type__c
//                                 Insurance_Type__c = insuranceType
//                             );
//                         }

//                         // Store in our map to prevent duplicates
//                         quoteNumberToLeadMap.put(quoteNumber, lead);
//                     }
//                 }
//             }

//             // Step 4: Convert map to list for upsert
//             List<Lead> leadsToUpsert = quoteNumberToLeadMap.values();
            
//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;

//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     // New method to parse date from MM/dd/yy format to a Date object
//     private static Date parseDate(String dateStr) {
//         // Check if the date is in expected format (M/d/yy or MM/dd/yy)
//         if (dateStr == null || dateStr.trim() == '') {
//             return null;
//         }
        
//         // Split the date string by '/'
//         List<String> dateParts = dateStr.split('/');
//         if (dateParts.size() != 3) {
//             throw new DateFormatException('Invalid date format. Expected MM/DD/YY but got: ' + dateStr);
//         }
        
//         // Parse individual components
//         Integer month = Integer.valueOf(dateParts[0]);
//         Integer day = Integer.valueOf(dateParts[1]);
//         Integer year = Integer.valueOf(dateParts[2]);
        
//         // Handle 2-digit year (assume 20xx if yy < 50, 19xx if yy >= 50)
//         if (year < 100) {
//             year = year < 50 ? 2000 + year : 1900 + year;
//         }
        
//         // Create and return Date object
//         try {
//             return Date.newInstance(year, month, day);
//         } catch (Exception e) {
//             throw new DateFormatException('Invalid date components: month=' + month + ', day=' + day + ', year=' + year);
//         }
//     }

//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';

//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i + 1);

//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.add(currentValue);
//         return result;
//     }

//     private static void validateCSVFormat(List<String> headers) {
//         List<String> requiredHeaders = new List<String>{'Last Name','First Name', 'Quote Number', 'Phone', 'Email'};

//         Set<String> normalizedHeaders = new Set<String>();
//         for (String h : headers) {
//             normalizedHeaders.add(h.trim().toLowerCase());
//         }

//         for (String req : requiredHeaders) {
//             if (!normalizedHeaders.contains(req.toLowerCase())) {
//                 throw new CSVFormatException('Missing required column: ' + req);
//             }
//         }
//     }

//     public class CSVFormatException extends Exception {}
//     public class DateFormatException extends Exception {}
// }
// public class DairylandCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Lead> quoteNumberToLeadMap = new Map<String, Lead>();
//         Map<String, Id> quoteNumberToLeadIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             // Step 1: Collect unique quote numbers from CSV
//             Set<String> uniqueQuoteNumbersInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 3 && String.isNotBlank(values[2])) {
//                         uniqueQuoteNumbersInCSV.add(values[2].trim());
//                     }
//                 }
//             }

//             // Step 2: Query existing leads once
//             if (!uniqueQuoteNumbersInCSV.isEmpty()) {
//                 for (Lead existingLead : [
//                     SELECT Id, Quote_Number__c FROM Lead WHERE Quote_Number__c IN :uniqueQuoteNumbersInCSV
//                 ]) {
//                     quoteNumberToLeadIdMap.put(existingLead.Quote_Number__c, existingLead.Id);
//                 }
//             }

//             // Step 3: Process CSV rows, handling duplicates
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     // Protect against missing fields
//                     String lastName = values.size() > 1 ? values[1].trim() : null;
//                     String firstName = values.size() > 0 ? values[0].trim() : null;
//                     String quoteNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     // If the fields come clean, we use firstName + lastName as a preset field
//                     String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() : (String.isNotBlank(firstName) && String.isNotBlank(lastName)) ? firstName + ' ' + lastName : 'Unknown';
//                     String policyType = values.size() > 6 ? values[6].trim() : null;
//                     String rateState = values.size() > 7 ? values[7].trim() : null;
//                     String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;
//                     String status = values.size() > 9 ? values[9].trim() : null;
//                     // new field for Insurance_Type__c
//                     String insuranceType = values.size() > 10 ? values[10].trim() : null;


//                     Date quoteEffectiveDate = null;
//                     if (String.isNotBlank(quoteEffectiveDateStr)) {
//                         try {
//                             // Parse date in format MM/dd/yy or M/d/yy
//                             quoteEffectiveDate = parseDate(quoteEffectiveDateStr);
//                         } catch (Exception ex) {
//                             // Skip invalid dates silently
//                             System.debug('Failed to parse date: ' + quoteEffectiveDateStr + '. Error: ' + ex.getMessage());
//                         }
//                     }

//                     if (String.isNotBlank(quoteNumber)) {  // changed the email to quoteNumber
//                         Lead lead;
                        
//                         // Check if we've already processed a record with this quote number in the current import
//                         // This prevents duplicate IDs in the upsert list
//                         if (quoteNumberToLeadMap.containsKey(quoteNumber)) {
//                             // We already have a lead with this quote number in our current batch, skip it
//                             continue;
//                         }
                        
//                         if (quoteNumberToLeadIdMap.containsKey(quoteNumber)) {
//                             lead = new Lead(
//                                 Id = quoteNumberToLeadIdMap.get(quoteNumber),
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 Policy_Type__c = 'Automobile-Van-Minivan', // default for automovile
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate,
//                                 Notes__c = status,
//                                 // new field for Insurance_Type__c
//                                 Insurance_Type__c = insuranceType
//                             );
//                         } else {
//                             lead = new Lead(
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 LeadSource = 'Dairyland Import',
//                                 Policy_Type__c = 'Automobile-Van-Minivan', // default for automovile
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate,
//                                 Notes__c = status,
//                                 // new field for Insurance_Type__c
//                                 Insurance_Type__c = insuranceType
//                             );
//                         }

//                         // Store in our map to prevent duplicates
//                         quoteNumberToLeadMap.put(quoteNumber, lead);
//                     }
//                 }
//             }

//             // Step 4: Convert map to list for upsert
//             List<Lead> leadsToUpsert = quoteNumberToLeadMap.values();
            
//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;

//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     // New method to parse date from MM/dd/yy format to a Date object
//     private static Date parseDate(String dateStr) {
//         // Check if the date is in expected format (M/d/yy or MM/dd/yy)
//         if (dateStr == null || dateStr.trim() == '') {
//             return null;
//         }
        
//         // Split the date string by '/'
//         List<String> dateParts = dateStr.split('/');
//         if (dateParts.size() != 3) {
//             throw new DateFormatException('Invalid date format. Expected MM/DD/YY but got: ' + dateStr);
//         }
        
//         // Parse individual components
//         Integer month = Integer.valueOf(dateParts[0]);
//         Integer day = Integer.valueOf(dateParts[1]);
//         Integer year = Integer.valueOf(dateParts[2]);
        
//         // Handle 2-digit year (assume 20xx if yy < 50, 19xx if yy >= 50)
//         if (year < 100) {
//             year = year < 50 ? 2000 + year : 1900 + year;
//         }
        
//         // Create and return Date object
//         try {
//             return Date.newInstance(year, month, day);
//         } catch (Exception e) {
//             throw new DateFormatException('Invalid date components: month=' + month + ', day=' + day + ', year=' + year);
//         }
//     }

//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';

//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i + 1);

//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.add(currentValue);
//         return result;
//     }

//     private static void validateCSVFormat(List<String> headers) {
//         List<String> requiredHeaders = new List<String>{'Last Name','First Name', 'Quote Number', 'Phone', 'Email'};

//         Set<String> normalizedHeaders = new Set<String>();
//         for (String h : headers) {
//             normalizedHeaders.add(h.trim().toLowerCase());
//         }

//         for (String req : requiredHeaders) {
//             if (!normalizedHeaders.contains(req.toLowerCase())) {
//                 throw new CSVFormatException('Missing required column: ' + req);
//             }
//         }
//     }

//     public class CSVFormatException extends Exception {}
//     public class DateFormatException extends Exception {}
// }
//END NEW VERSION
// NEW VERSION V2 ESTABLE
public class DairylandCSVProcessor {

    @AuraEnabled
    public static List<String> processCSVFile(String csvFileContent) {
        List<String> resultIds = new List<String>();
        Map<String, Lead> quoteNumberToLeadMap = new Map<String, Lead>();
        Map<String, Id> quoteNumberToLeadIdMap = new Map<String, Id>();

        try {
            // ----------------------------
            // LIMPIAR LEADS ANTIGUOS "Auto"
            // ----------------------------
            List<Lead> oldLeadsToUpdate = [
                SELECT Id
                FROM Lead
                WHERE Policy_Type__c = 'Auto' AND LeadSource = 'Dairyland Import'
            ];
            for (Lead l : oldLeadsToUpdate) {
                l.Policy_Type__c = 'Automobile-Van-Minivan';
                l.Vehicle_Type__c = 'Automobile-Van-Minivan';
                l.Insurance_Type__c = 'Automobile-Van-Minivan';
            }
            if (!oldLeadsToUpdate.isEmpty()) {
                update oldLeadsToUpdate;
                System.debug('Updated ' + oldLeadsToUpdate.size() + ' old leads from Auto -> Automobile-Van-Minivan');
            }

            // ----------------------------
            // PROCESAR EL CSV COMO ANTES
            // ----------------------------
            List<String> lines = csvFileContent.split('\n');
            if (lines.isEmpty()) {
                throw new AuraHandledException('CSV file is empty.');
            }

            List<String> headers = parseCSVLine(lines[0]);
            validateCSVFormat(headers);

            // Step 1: Collect unique quote numbers from CSV
            Set<String> uniqueQuoteNumbersInCSV = new Set<String>();
            for (Integer i = 1; i < lines.size(); i++) {
                if (String.isNotBlank(lines[i])) {
                    List<String> values = parseCSVLine(lines[i]);
                    if (values.size() >= 3 && String.isNotBlank(values[2])) {
                        uniqueQuoteNumbersInCSV.add(values[2].trim());
                    }
                }
            }

            // Step 2: Query existing leads once
            if (!uniqueQuoteNumbersInCSV.isEmpty()) {
                for (Lead existingLead : [
                    SELECT Id, Quote_Number__c FROM Lead WHERE Quote_Number__c IN :uniqueQuoteNumbersInCSV
                ]) {
                    quoteNumberToLeadIdMap.put(existingLead.Quote_Number__c, existingLead.Id);
                }
            }

            // Step 3: Process CSV rows, handling duplicates
            for (Integer i = 1; i < lines.size(); i++) {
                if (String.isNotBlank(lines[i])) {
                    List<String> values = parseCSVLine(lines[i]);

                    // Protect against missing fields
                    String lastName = values.size() > 1 ? values[1].trim() : null;
                    String firstName = values.size() > 0 ? values[0].trim() : null;
                    String quoteNumber = values.size() > 2 ? values[2].trim() : null;
                    String phone = values.size() > 3 ? values[3].trim() : null;
                    String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
                    String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() :
                                     (String.isNotBlank(firstName) && String.isNotBlank(lastName)) ? firstName + ' ' + lastName : 'Unknown';
                    String rateState = values.size() > 7 ? values[7].trim() : null;
                    String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;
                    String status = values.size() > 9 ? values[9].trim() : null;

                    Date quoteEffectiveDate = null;
                    if (String.isNotBlank(quoteEffectiveDateStr)) {
                        try {
                            quoteEffectiveDate = parseDate(quoteEffectiveDateStr);
                        } catch (Exception ex) {
                            System.debug('Failed to parse date: ' + quoteEffectiveDateStr + '. Error: ' + ex.getMessage());
                        }
                    }

                    if (String.isNotBlank(quoteNumber)) {
                        Lead lead;

                        if (quoteNumberToLeadMap.containsKey(quoteNumber)) {
                            continue; // skip duplicates in current batch
                        }

                        if (quoteNumberToLeadIdMap.containsKey(quoteNumber)) {
                            // Update existing lead
                            lead = new Lead(
                                Id = quoteNumberToLeadIdMap.get(quoteNumber),
                                LastName = lastName,
                                FirstName = firstName,
                                Quote_Number__c = quoteNumber,
                                Phone = phone,
                                Email = email,
                                Company = company,
                                Policy_Type__c = 'Automobile-Van-Minivan',
                                Vehicle_Type__c = 'Automobile-Van-Minivan',
                                Insurance_Type__c = 'Automobile-Van-Minivan',
                                Rate_State__c = rateState,
                                Quote_Effective_Date__c = quoteEffectiveDate,
                                Notes__c = status
                            );
                        } else {
                            // Insert new lead
                            lead = new Lead(
                                FirstName = firstName,
                                LastName = lastName,
                                Quote_Number__c = quoteNumber,
                                Phone = phone,
                                Email = email,
                                Company = company,
                                LeadSource = 'Dairyland Import',
                                Policy_Type__c = 'Automobile-Van-Minivan',
                                Vehicle_Type__c = 'Automobile-Van-Minivan',
                                Insurance_Type__c = 'Automobile-Van-Minivan',
                                Rate_State__c = rateState,
                                Quote_Effective_Date__c = quoteEffectiveDate,
                                Notes__c = status
                            );
                        }

                        quoteNumberToLeadMap.put(quoteNumber, lead);
                    }
                }
            }

            // Step 4: Upsert
            List<Lead> leadsToUpsert = quoteNumberToLeadMap.values();
            if (!leadsToUpsert.isEmpty()) {
                upsert leadsToUpsert;
                for (Lead l : leadsToUpsert) {
                    resultIds.add(l.Id);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
        }

        return resultIds;
    }

    private static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr)) return null;
        List<String> dateParts = dateStr.split('/');
        if (dateParts.size() != 3) {
            throw new DateFormatException('Invalid date format. Expected MM/DD/YY but got: ' + dateStr);
        }
        Integer month = Integer.valueOf(dateParts[0]);
        Integer day = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        if (year < 100) year = year < 50 ? 2000 + year : 1900 + year;
        try {
            return Date.newInstance(year, month, day);
        } catch (Exception e) {
            throw new DateFormatException('Invalid date components: month=' + month + ', day=' + day + ', year=' + year);
        }
    }

    private static List<String> parseCSVLine(String line) {
        List<String> result = new List<String>();
        Boolean inQuotes = false;
        String currentValue = '';
        for (Integer i = 0; i < line.length(); i++) {
            String currentChar = line.substring(i, i + 1);
            if (currentChar == '"') {
                inQuotes = !inQuotes;
            } else if (currentChar == ',' && !inQuotes) {
                result.add(currentValue);
                currentValue = '';
            } else {
                currentValue += currentChar;
            }
        }
        result.add(currentValue);
        return result;
    }

    private static void validateCSVFormat(List<String> headers) {
        List<String> requiredHeaders = new List<String>{'Last Name','First Name', 'Quote Number', 'Phone', 'Email'};
        Set<String> normalizedHeaders = new Set<String>();
        for (String h : headers) {
            normalizedHeaders.add(h.trim().toLowerCase());
        }
        for (String req : requiredHeaders) {
            if (!normalizedHeaders.contains(req.toLowerCase())) {
                throw new CSVFormatException('Missing required column: ' + req);
            }
        }
    }

    public class CSVFormatException extends Exception {}
    public class DateFormatException extends Exception {}
}
// EMD NEW VERSION V2 ESTABLE



//OLD VERSIONS

// public class DairylandCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         List<Lead> leadsToUpsert = new List<Lead>();
//         Map<String, Id> emailToLeadIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             List<String> emailsInCSV = new List<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 5 && String.isNotBlank(values[4])) {
//                         emailsInCSV.add(values[4].trim().toLowerCase());
//                     }
//                 }
//             }

//             if (!emailsInCSV.isEmpty()) {
//                 for (Lead existingLead : [
//                     SELECT Id, Email FROM Lead WHERE Email IN :emailsInCSV
//                 ]) {
//                     emailToLeadIdMap.put(existingLead.Email.toLowerCase(), existingLead.Id);
//                 }
//             }

//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     // Protect against missing fields
//                     String firstName = values.size() > 0 ? values[0].trim() : null;
//                     String lastName = values.size() > 1 ? values[1].trim() : null;
//                     String quoteNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() : email;
//                     String policyType = values.size() > 6 ? values[6].trim() : null;
//                     String rateState = values.size() > 7 ? values[7].trim() : null;
//                     String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;

//                     Date quoteEffectiveDate = null;
//                     if (String.isNotBlank(quoteEffectiveDateStr)) {
//                         try {
//                             quoteEffectiveDate = Date.valueOf(quoteEffectiveDateStr);
//                         } catch (Exception ex) {
//                             // Skip invalid dates silently
//                         }
//                     }

//                     if (String.isNotBlank(email)) {
//                         Lead lead;
//                         if (emailToLeadIdMap.containsKey(email)) {
//                             lead = new Lead(
//                                 Id = emailToLeadIdMap.get(email),
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate
//                             );
//                         } else {
//                             lead = new Lead(
//                                 FirstName = firstName,
//                                 LastName = lastName,
//                                 Quote_Number__c = quoteNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Company = company,
//                                 LeadSource = 'Dairyland Import',
//                                 Policy_Type__c = policyType,
//                                 Rate_State__c = rateState,
//                                 Quote_Effective_Date__c = quoteEffectiveDate
//                             );
//                         }

//                         leadsToUpsert.add(lead);
//                     }
//                 }
//             }

//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;

//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';

//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i + 1);

//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.add(currentValue);
//         return result;
//     }

//     private static void validateCSVFormat(List<String> headers) {
//         List<String> requiredHeaders = new List<String>{'FirstName', 'LastName', 'Phone', 'Email'};

//         Set<String> normalizedHeaders = new Set<String>();
//         for (String h : headers) {
//             normalizedHeaders.add(h.trim().toLowerCase());
//         }

//         for (String req : requiredHeaders) {
//             if (!normalizedHeaders.contains(req.toLowerCase())) {
//                 throw new CSVFormatException('Missing required column: ' + req);
//             }
//         }
//     }

//     public class CSVFormatException extends Exception {}
// }


// public class DairylandCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         List<Lead> leadsToUpsert = new List<Lead>();
//         Map<String, Id> emailToLeadIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             List<String> emailsInCSV = new List<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 5 && String.isNotBlank(values[4])) {
//                         emailsInCSV.add(values[4].trim().toLowerCase());
//                     }
//                 }
//             }

//             if (!emailsInCSV.isEmpty()) {
//                 for (Lead existingLead : [
//                     SELECT Id, Email FROM Lead WHERE Email IN :emailsInCSV
//                 ]) {
//                     emailToLeadIdMap.put(existingLead.Email.toLowerCase(), existingLead.Id);
//                 }
//             }

//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     // Protect against missing fields
//                     String firstName = values.size() > 0 ? values[0].trim() : null;
//                     String lastName = values.size() > 1 ? values[1].trim() : null;
//                     String quoteNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 && String.isNotBlank(values[5]) ? values[5].trim() : email;
//                     String policyType = values.size() > 6 ? values[6].trim() : null;
//                     String rateState = values.size() > 7 ? values[7].trim() : null;
//                     String quoteEffectiveDateStr = values.size() > 8 ? values[8].trim() : null;

//                     Date quoteEffectiveDate = null;
//                     if (String.isNotBlank(quoteEffectiveDateStr)) {
//                         try {
//                             quoteEffectiveDate = Date.valueOf(quoteEffectiveDateStr);
//                         } catch (Exception ex) {
//                             // Skip invalid dates silently
//                         }
//                     }

//                     // Asignar valores por defecto si faltan
//                     String emailToUse = String.isNotBlank(email) ? email : 'no-email@dairyland.com';
//                     String phoneToUse = String.isNotBlank(phone) ? phone : '0000000000'; // Asignamos un teléfono por defecto si está vacío

//                     Lead lead;
//                     if (emailToLeadIdMap.containsKey(emailToUse)) {
//                         lead = new Lead(
//                             Id = emailToLeadIdMap.get(emailToUse),
//                             FirstName = firstName,
//                             LastName = lastName,
//                             Quote_Number__c = quoteNumber,
//                             Phone = phoneToUse,
//                             Email = emailToUse,
//                             Company = company,
//                             Policy_Type__c = policyType,
//                             Rate_State__c = rateState,
//                             Quote_Effective_Date__c = quoteEffectiveDate
//                         );
//                     } else {
//                         lead = new Lead(
//                             FirstName = firstName,
//                             LastName = lastName,
//                             Quote_Number__c = quoteNumber,
//                             Phone = phoneToUse,
//                             Email = emailToUse,
//                             Company = company,
//                             LeadSource = 'Dairyland Import',
//                             Policy_Type__c = policyType,
//                             Rate_State__c = rateState,
//                             Quote_Effective_Date__c = quoteEffectiveDate
//                         );
//                     }

//                     leadsToUpsert.add(lead);
//                 }
//             }

//             if (!leadsToUpsert.isEmpty()) {
//                 upsert leadsToUpsert;

//                 for (Lead l : leadsToUpsert) {
//                     resultIds.add(l.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static List<String> parseCSVLine(String line) {
//         List<String> result = new List<String>();
//         Boolean inQuotes = false;
//         String currentValue = '';

//         for (Integer i = 0; i < line.length(); i++) {
//             String currentChar = line.substring(i, i + 1);

//             if (currentChar == '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar == ',' && !inQuotes) {
//                 result.add(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.add(currentValue);
//         return result;
//     }

//     private static void validateCSVFormat(List<String> headers) {
//         List<String> requiredHeaders = new List<String>{'FirstName', 'LastName', 'Phone', 'Email'};

//         Set<String> normalizedHeaders = new Set<String>();
//         for (String h : headers) {
//             normalizedHeaders.add(h.trim().toLowerCase());
//         }

//         for (String req : requiredHeaders) {
//             if (!normalizedHeaders.contains(req.toLowerCase())) {
//                 throw new CSVFormatException('Missing required column: ' + req);
//             }
//         }
//     }

//     public class CSVFormatException extends Exception {}
// }