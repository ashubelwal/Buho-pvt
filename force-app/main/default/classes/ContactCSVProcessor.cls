// public class ContactCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Contact> policyNumberToContactMap = new Map<String, Contact>();
//         Map<String, Id> policyNumberToContactIdMap = new Map<String, Id>();

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             Set<String> uniquePolicyNumbersInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 3 && String.isNotBlank(values[2])) {
//                         uniquePolicyNumbersInCSV.add(values[2].trim());
//                     }
//                 }
//             }

//             if (!uniquePolicyNumbersInCSV.isEmpty()) {
//                 for (Contact existingContact : [
//                     SELECT Id, Policy_Number__c FROM Contact WHERE Policy_Number__c IN :uniquePolicyNumbersInCSV
//                 ]) {
//                     policyNumberToContactIdMap.put(existingContact.Policy_Number__c, existingContact.Id);
//                 }
//             }

//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     String lastName = values.size() > 0 ? values[0].trim() : null;
//                     String firstName = values.size() > 1 ? values[1].trim() : null;
//                     String policyNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 ? values[5].trim() : null;
//                     String domesticPolicyType = values.size() > 6 ? values[6].trim() : null;
//                     String streetAddress = values.size() > 7 ? values[7].trim() : null;
//                     String city = values.size() > 8 ? values[8].trim() : null;
//                     String state = values.size() > 9 ? values[9].trim() : null;
//                     String zip = values.size() > 10 ? values[10].trim() : null;
//                     String effectiveDateStr = values.size() > 11 ? values[11].trim() : null;
//                     String policyStatus = values.size() > 12 ? values[12].trim() : null;

//                     Date effectiveDate = null;
//                     if (String.isNotBlank(effectiveDateStr)) {
//                         try {
//                             effectiveDate = parseDate(effectiveDateStr);
//                         } catch (Exception ex) {
//                             System.debug('Failed to parse date: ' + effectiveDateStr + '. Error: ' + ex.getMessage());
//                         }
//                     }

//                     if (String.isNotBlank(policyNumber) && String.isNotBlank(lastName)) {
//                         if (policyNumberToContactMap.containsKey(policyNumber)) {
//                             continue;
//                         }

//                         Contact contact;
//                         if (policyNumberToContactIdMap.containsKey(policyNumber)) {
//                             contact = new Contact(
//                                 Id = policyNumberToContactIdMap.get(policyNumber),
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         } else {
//                             contact = new Contact(
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         }

//                         policyNumberToContactMap.put(policyNumber, contact);
//                     }
//                 }
//             }

//             List<Contact> contactsToUpsert = policyNumberToContactMap.values();
//             assignAccountIds(contactsToUpsert);

//             if (!contactsToUpsert.isEmpty()) {
//                 upsert contactsToUpsert;

//                 for (Contact c : contactsToUpsert) {
//                     resultIds.add(c.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//STABLE VERSION------------------------------
// public class ContactCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Contact> policyNumberToContactMap = new Map<String, Contact>();
//         Map<String, Id> policyNumberToContactIdMap = new Map<String, Id>();

//         // Mapa de abreviaturas de estado a nombre completo
//         Map<String, String> stateAbbreviations = new Map<String, String>{
//             'AL' => 'Alabama',
//             'AK' => 'Alaska',
//             'AZ' => 'Arizona',
//             'AR' => 'Arkansas',
//             'CA' => 'California',
//             'CO' => 'Colorado',
//             'CT' => 'Connecticut',
//             'DE' => 'Delaware',
//             'FL' => 'Florida',
//             'GA' => 'Georgia',
//             'HI' => 'Hawaii',
//             'ID' => 'Idaho',
//             'IL' => 'Illinois',
//             'IN' => 'Indiana',
//             'IA' => 'Iowa',
//             'KS' => 'Kansas',
//             'KY' => 'Kentucky',
//             'LA' => 'Louisiana',
//             'ME' => 'Maine',
//             'MD' => 'Maryland',
//             'MA' => 'Massachusetts',
//             'MI' => 'Michigan',
//             'MN' => 'Minnesota',
//             'MS' => 'Mississippi',
//             'MO' => 'Missouri',
//             'MT' => 'Montana',
//             'NE' => 'Nebraska',
//             'NV' => 'Nevada',
//             'NH' => 'New Hampshire',
//             'NJ' => 'New Jersey',
//             'NM' => 'New Mexico',
//             'NY' => 'New York',
//             'NC' => 'North Carolina',
//             'ND' => 'North Dakota',
//             'OH' => 'Ohio',
//             'OK' => 'Oklahoma',
//             'OR' => 'Oregon',
//             'PA' => 'Pennsylvania',
//             'RI' => 'Rhode Island',
//             'SC' => 'South Carolina',
//             'SD' => 'South Dakota',
//             'TN' => 'Tennessee',
//             'TX' => 'Texas',
//             'UT' => 'Utah',
//             'VT' => 'Vermont',
//             'VA' => 'Virginia',
//             'WA' => 'Washington',
//             'WV' => 'West Virginia',
//             'WI' => 'Wisconsin',
//             'WY' => 'Wyoming'
//         };

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             Set<String> uniquePolicyNumbersInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 3 && String.isNotBlank(values[2])) {
//                         uniquePolicyNumbersInCSV.add(values[2].trim());
//                     }
//                 }
//             }

//             if (!uniquePolicyNumbersInCSV.isEmpty()) {
//                 for (Contact existingContact : [
//                     SELECT Id, Policy_Number__c FROM Contact WHERE Policy_Number__c IN :uniquePolicyNumbersInCSV
//                 ]) {
//                     policyNumberToContactIdMap.put(existingContact.Policy_Number__c, existingContact.Id);
//                 }
//             }

//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     String lastName = values.size() > 0 ? values[0].trim() : null;
//                     String firstName = values.size() > 1 ? values[1].trim() : null;
//                     String policyNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 ? values[5].trim() : null;
//                     String domesticPolicyType = values.size() > 6 ? values[6].trim() : null;
//                     String streetAddress = values.size() > 7 ? values[7].trim() : null;
//                     String city = values.size() > 8 ? values[8].trim() : null;
//                     String state = values.size() > 9 ? values[9].trim() : null;
//                     String zip = values.size() > 10 ? values[10].trim() : null;
//                     String effectiveDateStr = values.size() > 11 ? values[11].trim() : null;
//                     String policyStatus = values.size() > 12 ? values[12].trim() : null;

                    
//                     if (String.isNotBlank(state) && stateAbbreviations.containsKey(state.toUpperCase())) {
//                         state = stateAbbreviations.get(state.toUpperCase());
//                     }

//                     Date effectiveDate = null;
//                     if (String.isNotBlank(effectiveDateStr)) {
//                         try {
//                             effectiveDate = parseDate(effectiveDateStr);
//                         } catch (Exception ex) {
//                             System.debug('Failed to parse date: ' + effectiveDateStr + '. Error: ' + ex.getMessage());
//                         }
//                     }

//                     if (String.isNotBlank(policyNumber) && String.isNotBlank(lastName)) {
//                         if (policyNumberToContactMap.containsKey(policyNumber)) {
//                             continue;
//                         }

//                         Contact contact;
//                         if (policyNumberToContactIdMap.containsKey(policyNumber)) {
//                             contact = new Contact(
//                                 Id = policyNumberToContactIdMap.get(policyNumber),
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         } else {
//                             contact = new Contact(
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         }

//                         policyNumberToContactMap.put(policyNumber, contact);
//                     }
//                 }
//             }

//             List<Contact> contactsToUpsert = policyNumberToContactMap.values();
//             assignAccountIds(contactsToUpsert);

//             if (!contactsToUpsert.isEmpty()) {
//                 upsert contactsToUpsert;

//                 for (Contact c : contactsToUpsert) {
//                     resultIds.add(c.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static void assignAccountIds(List<Contact> contacts) {
//         Map<String, Id> emailToAccountIdMap = new Map<String, Id>();
//         List<Account> accountsToInsert = new List<Account>();
//         Set<String> uniqueEmails = new Set<String>();

//         for (Contact c : contacts) {
//             if (String.isNotBlank(c.Email) && c.AccountId == null) {
//                 uniqueEmails.add(c.Email.toLowerCase());
//             }
//         }

//         if (!uniqueEmails.isEmpty()) {
//             for (Account acc : [SELECT Id, Email__c FROM Account WHERE Email__c IN :uniqueEmails]) {
//                 if (String.isNotBlank(acc.Email__c)) {
//                     emailToAccountIdMap.put(acc.Email__c.toLowerCase(), acc.Id);
//                 }
//             }
//         }

//         for (Contact c : contacts) {
//             if (c.AccountId == null && String.isNotBlank(c.Email)) {
//                 String email = c.Email.toLowerCase();

//                 if (emailToAccountIdMap.containsKey(email)) {
//                     c.AccountId = emailToAccountIdMap.get(email);
//                 } else {
//                     String accountName = (String.isNotBlank(c.FirstName) ? c.FirstName + ' ' : '') + c.LastName;
//                     Account newAccount = new Account(
//                         Name = accountName,
//                         Email__c = email
//                     );
//                     accountsToInsert.add(newAccount);
//                     emailToAccountIdMap.put(email, null);
//                 }
//             }
//         }

//         if (!accountsToInsert.isEmpty()) {
//             insert accountsToInsert;
//             for (Account acc : accountsToInsert) {
//                 emailToAccountIdMap.put(acc.Email__c.toLowerCase(), acc.Id);
//             }
//         }

//         for (Contact c : contacts) {
//             if (c.AccountId == null && String.isNotBlank(c.Email)) {
//                 Id accId = emailToAccountIdMap.get(c.Email.toLowerCase());
//                 if (accId != null) {
//                     c.AccountId = accId;
//                 }
//             }
//         }
//     }

//     private static Date parseDate(String dateStr) {
//         if (dateStr == null || dateStr.trim() == '') return null;

//         List<String> dateParts = dateStr.split('/');
//         if (dateParts.size() != 3) {
//             throw new DateFormatException('Invalid date format. Expected MM/DD/YY but got: ' + dateStr);
//         }

//         Integer month = Integer.valueOf(dateParts[0]);
//         Integer day = Integer.valueOf(dateParts[1]);
//         Integer year = Integer.valueOf(dateParts[2]);

//         if (year < 100) {
//             year = year < 50 ? 2000 + year : 1900 + year;
//         }

//         return Date.newInstance(year, month, day);
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
//         List<String> requiredHeaders = new List<String>{'Last Name', 'First Name', 'Policy Number', 'Phone', 'Email'};

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
//STABLE VERSION------------------------------

//THIS WORKS BUT PUT THE SAME ACCOUNT IN THE CONTACT ON THE GENERIC EMAILS
// public class ContactCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Contact> policyNumberToContactMap = new Map<String, Contact>();
//         Map<String, Id> policyNumberToContactIdMap = new Map<String, Id>();

//         // Mapa de abreviaturas de estado a nombre completo
//         Map<String, String> stateAbbreviations = new Map<String, String>{
//             'AL' => 'Alabama',
//             'AK' => 'Alaska',
//             'AZ' => 'Arizona',
//             'AR' => 'Arkansas',
//             'CA' => 'California',
//             'CO' => 'Colorado',
//             'CT' => 'Connecticut',
//             'DE' => 'Delaware',
//             'FL' => 'Florida',
//             'GA' => 'Georgia',
//             'HI' => 'Hawaii',
//             'ID' => 'Idaho',
//             'IL' => 'Illinois',
//             'IN' => 'Indiana',
//             'IA' => 'Iowa',
//             'KS' => 'Kansas',
//             'KY' => 'Kentucky',
//             'LA' => 'Louisiana',
//             'ME' => 'Maine',
//             'MD' => 'Maryland',
//             'MA' => 'Massachusetts',
//             'MI' => 'Michigan',
//             'MN' => 'Minnesota',
//             'MS' => 'Mississippi',
//             'MO' => 'Missouri',
//             'MT' => 'Montana',
//             'NE' => 'Nebraska',
//             'NV' => 'Nevada',
//             'NH' => 'New Hampshire',
//             'NJ' => 'New Jersey',
//             'NM' => 'New Mexico',
//             'NY' => 'New York',
//             'NC' => 'North Carolina',
//             'ND' => 'North Dakota',
//             'OH' => 'Ohio',
//             'OK' => 'Oklahoma',
//             'OR' => 'Oregon',
//             'PA' => 'Pennsylvania',
//             'RI' => 'Rhode Island',
//             'SC' => 'South Carolina',
//             'SD' => 'South Dakota',
//             'TN' => 'Tennessee',
//             'TX' => 'Texas',
//             'UT' => 'Utah',
//             'VT' => 'Vermont',
//             'VA' => 'Virginia',
//             'WA' => 'Washington',
//             'WV' => 'West Virginia',
//             'WI' => 'Wisconsin',
//             'WY' => 'Wyoming'
//         };

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             Set<String> uniquePolicyNumbersInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 3 && String.isNotBlank(values[2])) {
//                         uniquePolicyNumbersInCSV.add(values[2].trim());
//                     }
//                 }
//             }

//             if (!uniquePolicyNumbersInCSV.isEmpty()) {
//                 for (Contact existingContact : [
//                     SELECT Id, Policy_Number__c FROM Contact WHERE Policy_Number__c IN :uniquePolicyNumbersInCSV
//                 ]) {
//                     policyNumberToContactIdMap.put(existingContact.Policy_Number__c, existingContact.Id);
//                 }
//             }

//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     String lastName = values.size() > 0 ? values[0].trim() : null;
//                     String firstName = values.size() > 1 ? values[1].trim() : null;
//                     String policyNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 ? values[5].trim() : null;
//                     String domesticPolicyType = values.size() > 6 ? values[6].trim() : null;
//                     String streetAddress = values.size() > 7 ? values[7].trim() : null;
//                     String city = values.size() > 8 ? values[8].trim() : null;
//                     String state = values.size() > 9 ? values[9].trim() : null;
//                     String zip = values.size() > 10 ? values[10].trim() : null;
//                     String effectiveDateStr = values.size() > 11 ? values[11].trim() : null;
//                     String policyStatus = values.size() > 12 ? values[12].trim() : null;

                    
//                     if (String.isNotBlank(state) && stateAbbreviations.containsKey(state.toUpperCase())) {
//                         state = stateAbbreviations.get(state.toUpperCase());
//                     }

//                     Date effectiveDate = null;
//                     if (String.isNotBlank(effectiveDateStr)) {
//                         try {
//                             effectiveDate = parseDate(effectiveDateStr);
//                         } catch (Exception ex) {
//                             System.debug('Failed to parse date: ' + effectiveDateStr + '. Error: ' + ex.getMessage());
//                         }
//                     }

//                     if (String.isNotBlank(policyNumber) && String.isNotBlank(lastName)) {
//                         if (policyNumberToContactMap.containsKey(policyNumber)) {
//                             continue;
//                         }

//                         Contact contact;
//                         if (policyNumberToContactIdMap.containsKey(policyNumber)) {
//                             contact = new Contact(
//                                 Id = policyNumberToContactIdMap.get(policyNumber),
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         } else {
//                             contact = new Contact(
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         }

//                         policyNumberToContactMap.put(policyNumber, contact);
//                     }
//                 }
//             }

//             List<Contact> contactsToUpsert = policyNumberToContactMap.values();
//             assignAccountIds(contactsToUpsert);

//             if (!contactsToUpsert.isEmpty()) {
//                 upsert contactsToUpsert;

//                 for (Contact c : contactsToUpsert) {
//                     resultIds.add(c.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static void assignAccountIds(List<Contact> contacts) {
//         Map<String, Id> emailToAccountIdMap = new Map<String, Id>();
//         Map<String, Id> fullNameToAccountIdMap = new Map<String, Id>();
//         List<Account> accountsToInsert = new List<Account>();
//         Set<String> uniqueEmails = new Set<String>();
//         Set<String> uniqueFullNames = new Set<String>();

//         // Recopilar emails y nombres completos únicos
//         for (Contact c : contacts) {
//             if (c.AccountId == null) {
//                 if (String.isNotBlank(c.Email)) {
//                     uniqueEmails.add(c.Email.toLowerCase());
//                 } else if (String.isNotBlank(c.LastName)) {
//                     // Crear un nombre completo normalizado para búsqueda
//                     String fullName = normalizeFullName(c.FirstName, c.LastName);
//                     uniqueFullNames.add(fullName);
//                 }
//             }
//         }

//         // Buscar cuentas existentes por email
//         if (!uniqueEmails.isEmpty()) {
//             for (Account acc : [SELECT Id, Email__c FROM Account WHERE Email__c IN :uniqueEmails]) {
//                 if (String.isNotBlank(acc.Email__c)) {
//                     emailToAccountIdMap.put(acc.Email__c.toLowerCase(), acc.Id);
//                 }
//             }
//         }

//         // Buscar cuentas existentes por nombre
//         if (!uniqueFullNames.isEmpty()) {
//             for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :uniqueFullNames]) {
//                 if (String.isNotBlank(acc.Name)) {
//                     fullNameToAccountIdMap.put(acc.Name, acc.Id);
//                 }
//             }
//         }

//         // Asociar contactos con cuentas existentes o crear nuevas cuentas
//         for (Contact c : contacts) {
//             if (c.AccountId == null) {
//                 // Intentar asociar por email primero
//                 if (String.isNotBlank(c.Email)) {
//                     String email = c.Email.toLowerCase();
//                     if (emailToAccountIdMap.containsKey(email)) {
//                         c.AccountId = emailToAccountIdMap.get(email);
//                     } else {
//                         String accountName = (String.isNotBlank(c.FirstName) ? c.FirstName + ' ' : '') + c.LastName;
//                         Account newAccount = new Account(
//                             Name = accountName,
//                             Email__c = email
//                         );
//                         accountsToInsert.add(newAccount);
//                         emailToAccountIdMap.put(email, null);
//                     }
//                 } 
//                 // Si no hay email, intentar asociar por nombre completo
//                 else if (String.isNotBlank(c.LastName)) {
//                     String fullName = normalizeFullName(c.FirstName, c.LastName);
//                     if (fullNameToAccountIdMap.containsKey(fullName)) {
//                         c.AccountId = fullNameToAccountIdMap.get(fullName);
//                     } else {
//                         Account newAccount = new Account(
//                             Name = fullName
//                         );
//                         accountsToInsert.add(newAccount);
//                         fullNameToAccountIdMap.put(fullName, null);
//                     }
//                 }
//             }
//         }

//         // Insertar nuevas cuentas
//         if (!accountsToInsert.isEmpty()) {
//             insert accountsToInsert;
            
//             // Actualizar mapas con los IDs de las nuevas cuentas
//             for (Account acc : accountsToInsert) {
//                 if (String.isNotBlank(acc.Email__c)) {
//                     emailToAccountIdMap.put(acc.Email__c.toLowerCase(), acc.Id);
//                 } else {
//                     fullNameToAccountIdMap.put(acc.Name, acc.Id);
//                 }
//             }
//         }

//         // Asignar AccountId a los contactos que aún no tienen uno
//         for (Contact c : contacts) {
//             if (c.AccountId == null) {
//                 if (String.isNotBlank(c.Email)) {
//                     Id accId = emailToAccountIdMap.get(c.Email.toLowerCase());
//                     if (accId != null) {
//                         c.AccountId = accId;
//                     }
//                 } else if (String.isNotBlank(c.LastName)) {
//                     String fullName = normalizeFullName(c.FirstName, c.LastName);
//                     Id accId = fullNameToAccountIdMap.get(fullName);
//                     if (accId != null) {
//                         c.AccountId = accId;
//                     }
//                 }
//             }
//         }
//     }

//     // Método para normalizar el nombre completo
//     private static String normalizeFullName(String firstName, String lastName) {
//         return (String.isNotBlank(firstName) ? firstName.trim() + ' ' : '') + lastName.trim();
//     }

//     private static Date parseDate(String dateStr) {
//         if (dateStr == null || dateStr.trim() == '') return null;

//         List<String> dateParts = dateStr.split('/');
//         if (dateParts.size() != 3) {
//             throw new DateFormatException('Invalid date format. Expected MM/DD/YY but got: ' + dateStr);
//         }

//         Integer month = Integer.valueOf(dateParts[0]);
//         Integer day = Integer.valueOf(dateParts[1]);
//         Integer year = Integer.valueOf(dateParts[2]);

//         if (year < 100) {
//             year = year < 50 ? 2000 + year : 1900 + year;
//         }

//         return Date.newInstance(year, month, day);
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
//         // Nota: Ahora el email no es requerido, pero mantenemos la validación de los otros campos
//         List<String> requiredHeaders = new List<String>{'Last Name', 'First Name', 'Policy Number', 'Phone'};

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
//END 2ND VERSION

//POSSIBLE STABLE VERSION----------------------------
// public class ContactCSVProcessor {

//     @AuraEnabled
//     public static List<String> processCSVFile(String csvFileContent) {
//         List<String> resultIds = new List<String>();
//         Map<String, Contact> policyNumberToContactMap = new Map<String, Contact>();
//         Map<String, Id> policyNumberToContactIdMap = new Map<String, Id>();

//         // Map of state abbreviations to full names
//         Map<String, String> stateAbbreviations = new Map<String, String>{
//             'AL' => 'Alabama',
//             'AK' => 'Alaska',
//             'AZ' => 'Arizona',
//             'AR' => 'Arkansas',
//             'CA' => 'California',
//             'CO' => 'Colorado',
//             'CT' => 'Connecticut',
//             'DE' => 'Delaware',
//             'FL' => 'Florida',
//             'GA' => 'Georgia',
//             'HI' => 'Hawaii',
//             'ID' => 'Idaho',
//             'IL' => 'Illinois',
//             'IN' => 'Indiana',
//             'IA' => 'Iowa',
//             'KS' => 'Kansas',
//             'KY' => 'Kentucky',
//             'LA' => 'Louisiana',
//             'ME' => 'Maine',
//             'MD' => 'Maryland',
//             'MA' => 'Massachusetts',
//             'MI' => 'Michigan',
//             'MN' => 'Minnesota',
//             'MS' => 'Mississippi',
//             'MO' => 'Missouri',
//             'MT' => 'Montana',
//             'NE' => 'Nebraska',
//             'NV' => 'Nevada',
//             'NH' => 'New Hampshire',
//             'NJ' => 'New Jersey',
//             'NM' => 'New Mexico',
//             'NY' => 'New York',
//             'NC' => 'North Carolina',
//             'ND' => 'North Dakota',
//             'OH' => 'Ohio',
//             'OK' => 'Oklahoma',
//             'OR' => 'Oregon',
//             'PA' => 'Pennsylvania',
//             'RI' => 'Rhode Island',
//             'SC' => 'South Carolina',
//             'SD' => 'South Dakota',
//             'TN' => 'Tennessee',
//             'TX' => 'Texas',
//             'UT' => 'Utah',
//             'VT' => 'Vermont',
//             'VA' => 'Virginia',
//             'WA' => 'Washington',
//             'WV' => 'West Virginia',
//             'WI' => 'Wisconsin',
//             'WY' => 'Wyoming'
//         };

//         try {
//             List<String> lines = csvFileContent.split('\n');
//             if (lines.isEmpty()) {
//                 throw new AuraHandledException('CSV file is empty.');
//             }

//             List<String> headers = parseCSVLine(lines[0]);
//             validateCSVFormat(headers);

//             Set<String> uniquePolicyNumbersInCSV = new Set<String>();
//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);
//                     if (values.size() >= 3 && String.isNotBlank(values[2])) {
//                         uniquePolicyNumbersInCSV.add(values[2].trim());
//                     }
//                 }
//             }

//             if (!uniquePolicyNumbersInCSV.isEmpty()) {
//                 for (Contact existingContact : [
//                     SELECT Id, Policy_Number__c FROM Contact WHERE Policy_Number__c IN :uniquePolicyNumbersInCSV
//                 ]) {
//                     policyNumberToContactIdMap.put(existingContact.Policy_Number__c, existingContact.Id);
//                 }
//             }

//             for (Integer i = 1; i < lines.size(); i++) {
//                 if (String.isNotBlank(lines[i])) {
//                     List<String> values = parseCSVLine(lines[i]);

//                     String lastName = values.size() > 0 ? values[0].trim() : null;
//                     String firstName = values.size() > 1 ? values[1].trim() : null;
//                     String policyNumber = values.size() > 2 ? values[2].trim() : null;
//                     String phone = values.size() > 3 ? values[3].trim() : null;
//                     String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
//                     String company = values.size() > 5 ? values[5].trim() : null;
//                     String domesticPolicyType = values.size() > 6 ? values[6].trim() : null;
//                     String streetAddress = values.size() > 7 ? values[7].trim() : null;
//                     String city = values.size() > 8 ? values[8].trim() : null;
//                     String state = values.size() > 9 ? values[9].trim() : null;
//                     String zip = values.size() > 10 ? values[10].trim() : null;
//                     String effectiveDateStr = values.size() > 11 ? values[11].trim() : null;
//                     String policyStatus = values.size() > 12 ? values[12].trim() : null;

                    
//                     if (String.isNotBlank(state) && stateAbbreviations.containsKey(state.toUpperCase())) {
//                         state = stateAbbreviations.get(state.toUpperCase());
//                     }

//                     Date effectiveDate = null;
//                     if (String.isNotBlank(effectiveDateStr)) {
//                         try {
//                             effectiveDate = parseDate(effectiveDateStr);
//                         } catch (Exception ex) {
//                             System.debug('Failed to parse date: ' + effectiveDateStr + '. Error: ' + ex.getMessage());
//                         }
//                     }

//                     if (String.isNotBlank(policyNumber) && String.isNotBlank(lastName)) {
//                         if (policyNumberToContactMap.containsKey(policyNumber)) {
//                             continue;
//                         }

//                         Contact contact;
//                         if (policyNumberToContactIdMap.containsKey(policyNumber)) {
//                             contact = new Contact(
//                                 Id = policyNumberToContactIdMap.get(policyNumber),
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         } else {
//                             contact = new Contact(
//                                 LastName = lastName,
//                                 FirstName = firstName,
//                                 Policy_Number__c = policyNumber,
//                                 Phone = phone,
//                                 Email = email,
//                                 Type_of_Domestic__c = domesticPolicyType,
//                                 Street__c = streetAddress,
//                                 City__c = city,
//                                 State__c = state,
//                                 Postal_Code__c = zip,
//                                 Quote_Effective_Date__c = effectiveDate,
//                                 Policy_Status__c = policyStatus,
//                                 Source__c = 'Dairyland Contact Import'
//                             );
//                         }

//                         policyNumberToContactMap.put(policyNumber, contact);
//                     }
//                 }
//             }

//             List<Contact> contactsToUpsert = policyNumberToContactMap.values();
//             assignAccountIds(contactsToUpsert);

//             if (!contactsToUpsert.isEmpty()) {
//                 upsert contactsToUpsert;

//                 for (Contact c : contactsToUpsert) {
//                     resultIds.add(c.Id);
//                 }
//             }

//         } catch (Exception e) {
//             throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
//         }

//         return resultIds;
//     }

//     private static void assignAccountIds(List<Contact> contacts) {
//         Map<String, Id> fullNameToAccountIdMap = new Map<String, Id>();
//         Map<String, Id> validEmailToAccountIdMap = new Map<String, Id>();
//         List<Account> accountsToInsert = new List<Account>();
//         Set<String> uniqueFullNames = new Set<String>();
//         Set<String> validUniqueEmails = new Set<String>();
        
//         // Set of generic emails to ignore
//         Set<String> genericEmails = new Set<String>{
//             'none@email.com', 
//             'na@email.com', 
//             'unknown@email.com', 
//             'test@test.com',
//             'none@none.com',
//             'no@email.com'
//             // Add more generic emails as needed
//         };

//         // Recopilate unique full names and valid emails
//         for (Contact c : contacts) {
//             if (c.AccountId == null && String.isNotBlank(c.LastName)) {
//                 // Always normalize the full name
//                 String fullName = normalizeFullName(c.FirstName, c.LastName);
//                 uniqueFullNames.add(fullName);
                
//                 // just add valid emails
//                 if (String.isNotBlank(c.Email) && !genericEmails.contains(c.Email.toLowerCase()) && 
//                     !c.Email.toLowerCase().contains('none') && !c.Email.toLowerCase().contains('unknown')) {
//                     validUniqueEmails.add(c.Email.toLowerCase());
//                 }
//             }
//         }

//         // search for existing accounts by full name
//         if (!uniqueFullNames.isEmpty()) {
//             for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :uniqueFullNames]) {
//                 if (String.isNotBlank(acc.Name)) {
//                     fullNameToAccountIdMap.put(acc.Name, acc.Id);
//                 }
//             }
//         }
        
//         // search for existing accounts by email
//         if (!validUniqueEmails.isEmpty()) {
//             for (Account acc : [SELECT Id, Email__c FROM Account WHERE Email__c IN :validUniqueEmails]) {
//                 if (String.isNotBlank(acc.Email__c)) {
//                     validEmailToAccountIdMap.put(acc.Email__c.toLowerCase(), acc.Id);
//                 }
//             }
//         }

//         // Assign AccountId to contacts or create new accounts
//         for (Contact c : contacts) {
//             if (c.AccountId == null && String.isNotBlank(c.LastName)) {
//                 String fullName = normalizeFullName(c.FirstName, c.LastName);
//                 boolean accountAssigned = false;
                
//                 // First try to assign by full name
//                 if (fullNameToAccountIdMap.containsKey(fullName)) {
//                     c.AccountId = fullNameToAccountIdMap.get(fullName);
//                     accountAssigned = true;
//                 } 
                
//                 // Just in case the full name is not found, try to assign by email
//                 if (!accountAssigned && String.isNotBlank(c.Email) && 
//                     !genericEmails.contains(c.Email.toLowerCase()) && 
//                     !c.Email.toLowerCase().contains('none') && 
//                     !c.Email.toLowerCase().contains('unknown')) {
                    
//                     String email = c.Email.toLowerCase();
//                     if (validEmailToAccountIdMap.containsKey(email)) {
//                         c.AccountId = validEmailToAccountIdMap.get(email);
//                         accountAssigned = true;
//                     }
//                 }
                
//                 // If no account was assigned, create a new account
//                 if (!accountAssigned) {
//                     Account newAccount = new Account(Name = fullName);
                    
//                     // Set the email if it's valid and not generic
//                     if (String.isNotBlank(c.Email) && 
//                         !genericEmails.contains(c.Email.toLowerCase()) && 
//                         !c.Email.toLowerCase().contains('none') && 
//                         !c.Email.toLowerCase().contains('unknown')) {
//                         newAccount.Email__c = c.Email.toLowerCase();
//                     }
                    
//                     accountsToInsert.add(newAccount);
//                     fullNameToAccountIdMap.put(fullName, null);
//                 }
//             }
//         }

//         // Insert new accounts
//         if (!accountsToInsert.isEmpty()) {
//             insert accountsToInsert;
            
//             // Update maps with the IDs of the new accounts
//             for (Account acc : accountsToInsert) {
//                 fullNameToAccountIdMap.put(acc.Name, acc.Id);
//                 if (String.isNotBlank(acc.Email__c)) {
//                     validEmailToAccountIdMap.put(acc.Email__c.toLowerCase(), acc.Id);
//                 }
//             }
//         }

//         // Reassign AccountId to contacts that still don't have one
//         for (Contact c : contacts) {
//             if (c.AccountId == null && String.isNotBlank(c.LastName)) {
//                 String fullName = normalizeFullName(c.FirstName, c.LastName);
//                 Id accId = fullNameToAccountIdMap.get(fullName);
//                 if (accId != null) {
//                     c.AccountId = accId;
//                 }
//             }
//         }
//     }

//     // Method to normalize the full name
//     private static String normalizeFullName(String firstName, String lastName) {
//         return (String.isNotBlank(firstName) ? firstName.trim() + ' ' : '') + lastName.trim();
//     }

//     private static Date parseDate(String dateStr) {
//         if (dateStr == null || dateStr.trim() == '') return null;

//         List<String> dateParts = dateStr.split('/');
//         if (dateParts.size() != 3) {
//             throw new DateFormatException('Invalid date format. Expected MM/DD/YY but got: ' + dateStr);
//         }

//         Integer month = Integer.valueOf(dateParts[0]);
//         Integer day = Integer.valueOf(dateParts[1]);
//         Integer year = Integer.valueOf(dateParts[2]);

//         if (year < 100) {
//             year = year < 50 ? 2000 + year : 1900 + year;
//         }

//         return Date.newInstance(year, month, day);
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
//         // Note: Now the email is not required, but we keep the validation of the other fields
//         List<String> requiredHeaders = new List<String>{'Last Name', 'First Name', 'Policy Number'};

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
//END POSSIBLE STABLE VERSION

public class ContactCSVProcessor {

    @AuraEnabled
    public static List<String> processCSVFile(String csvFileContent) {
        List<String> resultIds = new List<String>();
        Map<String, Contact> policyNumberToContactMap = new Map<String, Contact>();
        Map<String, Id> policyNumberToContactIdMap = new Map<String, Id>();

        // Map of state abbreviations to full names
        Map<String, String> stateAbbreviations = new Map<String, String>{
            'AL' => 'Alabama',
            'AK' => 'Alaska',
            'AZ' => 'Arizona',
            'AR' => 'Arkansas',
            'CA' => 'California',
            'CO' => 'Colorado',
            'CT' => 'Connecticut',
            'DE' => 'Delaware',
            'FL' => 'Florida',
            'GA' => 'Georgia',
            'HI' => 'Hawaii',
            'ID' => 'Idaho',
            'IL' => 'Illinois',
            'IN' => 'Indiana',
            'IA' => 'Iowa',
            'KS' => 'Kansas',
            'KY' => 'Kentucky',
            'LA' => 'Louisiana',
            'ME' => 'Maine',
            'MD' => 'Maryland',
            'MA' => 'Massachusetts',
            'MI' => 'Michigan',
            'MN' => 'Minnesota',
            'MS' => 'Mississippi',
            'MO' => 'Missouri',
            'MT' => 'Montana',
            'NE' => 'Nebraska',
            'NV' => 'Nevada',
            'NH' => 'New Hampshire',
            'NJ' => 'New Jersey',
            'NM' => 'New Mexico',
            'NY' => 'New York',
            'NC' => 'North Carolina',
            'ND' => 'North Dakota',
            'OH' => 'Ohio',
            'OK' => 'Oklahoma',
            'OR' => 'Oregon',
            'PA' => 'Pennsylvania',
            'RI' => 'Rhode Island',
            'SC' => 'South Carolina',
            'SD' => 'South Dakota',
            'TN' => 'Tennessee',
            'TX' => 'Texas',
            'UT' => 'Utah',
            'VT' => 'Vermont',
            'VA' => 'Virginia',
            'WA' => 'Washington',
            'WV' => 'West Virginia',
            'WI' => 'Wisconsin',
            'WY' => 'Wyoming'
        };

        try {
            List<String> lines = csvFileContent.split('\n');
            if (lines.isEmpty()) {
                throw new AuraHandledException('CSV file is empty.');
            }

            List<String> headers = parseCSVLine(lines[0]);
            validateCSVFormat(headers);

            Set<String> uniquePolicyNumbersInCSV = new Set<String>();
            for (Integer i = 1; i < lines.size(); i++) {
                if (String.isNotBlank(lines[i])) {
                    List<String> values = parseCSVLine(lines[i]);
                    if (values.size() >= 3 && String.isNotBlank(values[2])) {
                        uniquePolicyNumbersInCSV.add(values[2].trim());
                    }
                }
            }

            if (!uniquePolicyNumbersInCSV.isEmpty()) {
                for (Contact existingContact : [
                    SELECT Id, Policy_Number__c FROM Contact WHERE Policy_Number__c IN :uniquePolicyNumbersInCSV
                ]) {
                    policyNumberToContactIdMap.put(existingContact.Policy_Number__c, existingContact.Id);
                }
            }

            for (Integer i = 1; i < lines.size(); i++) {
                if (String.isNotBlank(lines[i])) {
                    List<String> values = parseCSVLine(lines[i]);

                    String lastName = values.size() > 0 ? values[0].trim() : null;
                    String firstName = values.size() > 1 ? values[1].trim() : null;
                    String policyNumber = values.size() > 2 ? values[2].trim() : null;
                    String phone = values.size() > 3 ? values[3].trim() : null;
                    String email = values.size() > 4 ? values[4].trim().toLowerCase() : null;
                    String company = values.size() > 5 ? values[5].trim() : null;
                    String domesticPolicyType = values.size() > 6 ? values[6].trim() : null;
                    String streetAddress = values.size() > 7 ? values[7].trim() : null;
                    String city = values.size() > 8 ? values[8].trim() : null;
                    String state = values.size() > 9 ? values[9].trim() : null;
                    String zip = values.size() > 10 ? values[10].trim() : null;
                    String effectiveDateStr = values.size() > 11 ? values[11].trim() : null;
                    String policyStatus = values.size() > 12 ? values[12].trim() : null;

                    
                    if (String.isNotBlank(state) && stateAbbreviations.containsKey(state.toUpperCase())) {
                        state = stateAbbreviations.get(state.toUpperCase());
                    }

                    Date effectiveDate = null;
                    if (String.isNotBlank(effectiveDateStr)) {
                        try {
                            effectiveDate = parseDate(effectiveDateStr);
                        } catch (Exception ex) {
                            System.debug('Failed to parse date: ' + effectiveDateStr + '. Error: ' + ex.getMessage());
                        }
                    }

                    if (String.isNotBlank(policyNumber) && String.isNotBlank(lastName)) {
                        if (policyNumberToContactMap.containsKey(policyNumber)) {
                            continue;
                        }

                        Contact contact;
                        if (policyNumberToContactIdMap.containsKey(policyNumber)) {
                            contact = new Contact(
                                Id = policyNumberToContactIdMap.get(policyNumber),
                                LastName = lastName,
                                FirstName = firstName,
                                Policy_Number__c = policyNumber,
                                Phone = phone,
                                Email = email,
                                Type_of_Domestic__c = domesticPolicyType,
                                Street__c = streetAddress,
                                City__c = city,
                                State__c = state,
                                Postal_Code__c = zip,
                                Quote_Effective_Date__c = effectiveDate,
                                Policy_Status__c = policyStatus,
                                Source__c = 'Dairyland Contact Import'
                            );
                        } else {
                            contact = new Contact(
                                LastName = lastName,
                                FirstName = firstName,
                                Policy_Number__c = policyNumber,
                                Phone = phone,
                                Email = email,
                                Type_of_Domestic__c = domesticPolicyType,
                                Street__c = streetAddress,
                                City__c = city,
                                State__c = state,
                                Postal_Code__c = zip,
                                Quote_Effective_Date__c = effectiveDate,
                                Policy_Status__c = policyStatus,
                                Source__c = 'Dairyland Contact Import'
                            );
                        }

                        policyNumberToContactMap.put(policyNumber, contact);
                    }
                }
            }

            List<Contact> contactsToUpsert = policyNumberToContactMap.values();
            assignAccountIds(contactsToUpsert);

            if (!contactsToUpsert.isEmpty()) {
                // Use Database.upsert with allOrNone=false to continue processing even if some records fail
                List<Database.UpsertResult> results = Database.upsert(contactsToUpsert, false);
                
                for (Integer i = 0; i < results.size(); i++) {
                    Database.UpsertResult result = results[i];
                    if (result.isSuccess()) {
                        resultIds.add(result.getId());
                    } else {
                        // Log the error but continue processing
                        for (Database.Error err : result.getErrors()) {
                            System.debug('Error on record ' + i + ': ' + err.getStatusCode() + ' - ' + err.getMessage());
                        }
                    }
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error processing the CSV file: ' + e.getMessage());
        }

        return resultIds;
    }

    private static void assignAccountIds(List<Contact> contacts) {
        Map<String, Id> fullNameToAccountIdMap = new Map<String, Id>();
        Map<String, Id> validEmailToAccountIdMap = new Map<String, Id>();
        List<Account> accountsToInsert = new List<Account>();
        Set<String> uniqueFullNames = new Set<String>();
        Set<String> validUniqueEmails = new Set<String>();
        
        // Set of generic emails to ignore
        Set<String> genericEmails = new Set<String>{
            'none@email.com', 
            'na@email.com', 
            'unknown@email.com', 
            'test@test.com',
            'none@none.com',
            'no@email.com'
            // Add more generic emails as needed
        };

        // Recopilate unique full names and valid emails
        for (Contact c : contacts) {
            if (c.AccountId == null && String.isNotBlank(c.LastName)) {
                // Always normalize the full name
                String fullName = normalizeFullName(c.FirstName, c.LastName);
                uniqueFullNames.add(fullName);
                
                // just add valid emails
                if (String.isNotBlank(c.Email) && !genericEmails.contains(c.Email.toLowerCase()) && 
                    !c.Email.toLowerCase().contains('none') && !c.Email.toLowerCase().contains('unknown')) {
                    validUniqueEmails.add(c.Email.toLowerCase());
                }
            }
        }

        // search for existing accounts by full name
        if (!uniqueFullNames.isEmpty()) {
            for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :uniqueFullNames]) {
                if (String.isNotBlank(acc.Name)) {
                    fullNameToAccountIdMap.put(acc.Name, acc.Id);
                }
            }
        }
        
        // search for existing accounts by email
        if (!validUniqueEmails.isEmpty()) {
            for (Account acc : [SELECT Id, Email__c FROM Account WHERE Email__c IN :validUniqueEmails]) {
                if (String.isNotBlank(acc.Email__c)) {
                    validEmailToAccountIdMap.put(acc.Email__c.toLowerCase(), acc.Id);
                }
            }
        }

        // Assign AccountId to contacts or create new accounts
        Map<String, Account> emailToNewAccountMap = new Map<String, Account>();
        
        for (Contact c : contacts) {
            if (c.AccountId == null && String.isNotBlank(c.LastName)) {
                String fullName = normalizeFullName(c.FirstName, c.LastName);
                boolean accountAssigned = false;
                
                // First try to assign by full name
                if (fullNameToAccountIdMap.containsKey(fullName)) {
                    c.AccountId = fullNameToAccountIdMap.get(fullName);
                    accountAssigned = true;
                } 
                
                // Just in case the full name is not found, try to assign by email
                if (!accountAssigned && String.isNotBlank(c.Email) && 
                    !genericEmails.contains(c.Email.toLowerCase()) && 
                    !c.Email.toLowerCase().contains('none') && 
                    !c.Email.toLowerCase().contains('unknown')) {
                    
                    String email = c.Email.toLowerCase();
                    if (validEmailToAccountIdMap.containsKey(email)) {
                        c.AccountId = validEmailToAccountIdMap.get(email);
                        accountAssigned = true;
                    }
                }
                
                // If no account was assigned, create a new account
                if (!accountAssigned) {
                    // Check if we already created an account with this email to avoid duplicates
                    String email = c.Email != null ? c.Email.toLowerCase() : null;
                    Account newAccount;
                    
                    if (String.isNotBlank(email) && 
                        !genericEmails.contains(email) && 
                        !email.contains('none') && 
                        !email.contains('unknown') &&
                        emailToNewAccountMap.containsKey(email)) {
                        
                        // Use existing account to avoid duplicate email errors
                        newAccount = emailToNewAccountMap.get(email);
                        c.AccountId = null; // Will be set after insert
                    } else {
                        newAccount = new Account(Name = fullName);
                        
                        // Set the email if it's valid and not generic
                        if (String.isNotBlank(email) && 
                            !genericEmails.contains(email) && 
                            !email.contains('none') && 
                            !email.contains('unknown')) {
                            newAccount.Email__c = email;
                            emailToNewAccountMap.put(email, newAccount);
                        }
                        
                        accountsToInsert.add(newAccount);
                        fullNameToAccountIdMap.put(fullName, null);
                    }
                }
            }
        }

        // Insert new accounts
        if (!accountsToInsert.isEmpty()) {
            // Use Database.insert with allOrNone=false to prevent duplicate email errors from failing the entire operation
            List<Database.SaveResult> results = Database.insert(accountsToInsert, false);
            
            // Process results and update maps with successful inserts
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    Account acc = accountsToInsert[i];
                    fullNameToAccountIdMap.put(acc.Name, results[i].getId());
                    if (String.isNotBlank(acc.Email__c)) {
                        validEmailToAccountIdMap.put(acc.Email__c.toLowerCase(), results[i].getId());
                    }
                } else {
                    // Log errors but continue processing
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('Error creating account: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }

        // Reassign AccountId to contacts that still don't have one
        for (Contact c : contacts) {
            if (c.AccountId == null && String.isNotBlank(c.LastName)) {
                String fullName = normalizeFullName(c.FirstName, c.LastName);
                Id accId = fullNameToAccountIdMap.get(fullName);
                if (accId != null) {
                    c.AccountId = accId;
                } else if (String.isNotBlank(c.Email)) {
                    // Try to find by email one more time
                    String email = c.Email.toLowerCase();
                    if (validEmailToAccountIdMap.containsKey(email)) {
                        c.AccountId = validEmailToAccountIdMap.get(email);
                    }
                }
                
                // If still no account ID, just create a contact without an account
                // (This is a fallback to ensure contacts get created even if account creation fails)
            }
        }
    }

    // Method to normalize the full name
    private static String normalizeFullName(String firstName, String lastName) {
        return (String.isNotBlank(firstName) ? firstName.trim() + ' ' : '') + lastName.trim();
    }

    private static Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim() == '') return null;

        List<String> dateParts = dateStr.split('/');
        if (dateParts.size() != 3) {
            throw new DateFormatException('Invalid date format. Expected MM/DD/YY but got: ' + dateStr);
        }

        Integer month = Integer.valueOf(dateParts[0]);
        Integer day = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);

        if (year < 100) {
            year = year < 50 ? 2000 + year : 1900 + year;
        }

        return Date.newInstance(year, month, day);
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
        // Note: Now the email is not required, but we keep the validation of the other fields
        List<String> requiredHeaders = new List<String>{'Last Name', 'First Name', 'Policy Number'};

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