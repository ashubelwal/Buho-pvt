@isTest
private class ContactCSVProcessorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        Account testAccount1 = new Account(Name = 'John Smith', Email__c = 'john.smith@example.com');
        Account testAccount2 = new Account(Name = 'Mary Johnson', Email__c = 'mary.johnson@example.com');
        insert new List<Account>{testAccount1, testAccount2};
        
        // Create a test contact with existing policy number
        Contact testContact = new Contact(
            LastName = 'Smith',
            FirstName = 'John',
            Policy_Number__c = 'POL-12345',
            Phone = '555-123-4567',
            Email = 'john.smith@example.com',
            Type_of_Domestic__c = 'Auto',
            Street__c = '123 Main St',
            City__c = 'Phoenix',
            State__c = 'Arizona',
            Postal_Code__c = '85001',
            Quote_Effective_Date__c = Date.newInstance(2023, 5, 15),
            Policy_Status__c = 'Cancelled',
            Source__c = 'Dairyland Contact Import',
            AccountId = testAccount1.Id
        );
        insert testContact;
    }
    
    @isTest
    static void testProcessCSVHappyPath() {
        // Create a valid CSV content with headers and a couple of records
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Johnson,Mary,POL-67890,555-987-6543,mary.johnson@example.com,,Auto,456 Oak Ave,Tucson,AZ,85701,05/20/2023,Expired\n' +
                           'Davis,Robert,POL-54321,555-456-7890,robert.davis@example.com,,Home,789 Pine St,Flagstaff,Arizona,86001,06/15/2023,Cancelled';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(2, resultIds.size(), 'Should have created 2 contacts');
        
        // Query the contacts to verify they were created/updated correctly
        List<Contact> contacts = [
            SELECT Id, LastName, FirstName, Policy_Number__c, Phone, Email, 
                   Type_of_Domestic__c, Street__c, City__c, State__c, Postal_Code__c,
                   Quote_Effective_Date__c, Policy_Status__c, Source__c, AccountId
            FROM Contact 
            WHERE Policy_Number__c IN ('POL-67890', 'POL-54321')
            ORDER BY Policy_Number__c
        ];
        
        System.assertEquals(2, contacts.size(), 'Two contacts should have been upserted');
        
        // Verify first contact details
        Contact contact1 = contacts[0];
        System.assertEquals('Davis', contact1.LastName);
        System.assertEquals('Robert', contact1.FirstName);
        System.assertEquals('POL-54321', contact1.Policy_Number__c);
        System.assertEquals('555-456-7890', contact1.Phone);
        System.assertEquals('robert.davis@example.com', contact1.Email);
        System.assertEquals('Home', contact1.Type_of_Domestic__c);
        System.assertEquals('789 Pine St', contact1.Street__c);
        System.assertEquals('Flagstaff', contact1.City__c);
        System.assertEquals('Arizona', contact1.State__c);
        System.assertEquals('86001', contact1.Postal_Code__c);
        System.assertEquals(Date.newInstance(2023, 6, 15), contact1.Quote_Effective_Date__c);
        System.assertEquals('Cancelled', contact1.Policy_Status__c);
        System.assertEquals('Dairyland Contact Import', contact1.Source__c);
        
        // Verify second contact details
        Contact contact2 = contacts[1];
        System.assertEquals('Johnson', contact2.LastName);
        System.assertEquals('Mary', contact2.FirstName);
        System.assertEquals('POL-67890', contact2.Policy_Number__c);
        System.assertEquals('555-987-6543', contact2.Phone);
        System.assertEquals('mary.johnson@example.com', contact2.Email);
        System.assertEquals('Auto', contact2.Type_of_Domestic__c);
        System.assertEquals('456 Oak Ave', contact2.Street__c);
        System.assertEquals('Tucson', contact2.City__c);
        System.assertEquals('Arizona', contact2.State__c);
        System.assertEquals('85701', contact2.Postal_Code__c);
        System.assertEquals(Date.newInstance(2023, 5, 20), contact2.Quote_Effective_Date__c);
        System.assertEquals('Expired', contact2.Policy_Status__c);
        System.assertEquals('Dairyland Contact Import', contact2.Source__c);
    }
    
    @isTest
    static void testUpdateExistingContact() {
        // Create a CSV content that includes the existing contact
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Smith,John,POL-12345,555-999-8888,john.smith@example.com,,Home,555 Updated St,Mesa,AZ,85201,04/30/2023,Expired';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(1, resultIds.size(), 'Should have updated 1 contact');
        
        // Query the contact to verify it was updated correctly
        Contact updatedContact = [
            SELECT Id, LastName, FirstName, Policy_Number__c, Phone, Email, 
                   Type_of_Domestic__c, Street__c, City__c, State__c, Postal_Code__c,
                   Quote_Effective_Date__c, Policy_Status__c
            FROM Contact 
            WHERE Policy_Number__c = 'POL-12345'
        ];
        
        System.assertEquals('Smith', updatedContact.LastName);
        System.assertEquals('John', updatedContact.FirstName);
        System.assertEquals('POL-12345', updatedContact.Policy_Number__c);
        System.assertEquals('555-999-8888', updatedContact.Phone);
        System.assertEquals('john.smith@example.com', updatedContact.Email);
        System.assertEquals('Home', updatedContact.Type_of_Domestic__c);
        System.assertEquals('555 Updated St', updatedContact.Street__c);
        System.assertEquals('Mesa', updatedContact.City__c);
        System.assertEquals('Arizona', updatedContact.State__c);
        System.assertEquals('85201', updatedContact.Postal_Code__c);
        System.assertEquals(Date.newInstance(2023, 4, 30), updatedContact.Quote_Effective_Date__c);
        System.assertEquals('Expired', updatedContact.Policy_Status__c);
    }
    
    @isTest
    static void testStateAbbreviations() {
        // Test CSV with state abbreviations
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Wilson,James,POL-99999,555-111-2222,james.wilson@example.com,,Auto,100 Elm St,Sacramento,CA,95814,07/01/2023,Cancelled\n' +
                           'Garcia,Maria,POL-88888,555-222-3333,maria.garcia@example.com,,Home,200 Maple Ave,Atlanta,GA,30301,08/15/2023,Expired';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Verify state abbreviations were properly converted
        List<Contact> contacts = [
            SELECT Id, LastName, State__c, Policy_Number__c
            FROM Contact 
            WHERE Policy_Number__c IN ('POL-99999', 'POL-88888')
            ORDER BY Policy_Number__c
        ];
        
        System.assertEquals(2, contacts.size(), 'Two contacts should have been created');
        System.assertEquals('Georgia', contacts[0].State__c, 'GA should be converted to Georgia');
        System.assertEquals('California', contacts[1].State__c, 'CA should be converted to California');
    }
    
    @isTest
    static void testAccountAssignment() {
        // Test CSV with a contact that should match an existing account by email
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Johnson,Mary,POL-ACCT1,555-444-5555,mary.johnson@example.com,,Auto,789 New St,Phoenix,AZ,85001,09/10/2023,Cancelled\n' +
                           'Brown,Michael,POL-ACCT2,555-666-7777,michael.brown@example.com,,Home,321 Cedar St,Tempe,AZ,85281,10/20/2023,Expired';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Query the contacts and verify account assignment
        List<Contact> contacts = [
            SELECT Id, LastName, FirstName, Email, AccountId, Account.Name, Account.Email__c
            FROM Contact 
            WHERE Policy_Number__c IN ('POL-ACCT1', 'POL-ACCT2')
            ORDER BY Policy_Number__c
        ];
        
        System.assertEquals(2, contacts.size(), 'Two contacts should have been created');
        
        // First contact should be linked to existing account
        Contact contact1 = contacts[0];
        System.assertEquals('mary.johnson@example.com', contact1.Email);
        
        Account linkedAccount = [SELECT Id, Name FROM Account WHERE Email__c = 'mary.johnson@example.com' LIMIT 1];
        System.assertEquals(linkedAccount.Id, contact1.AccountId, 'Contact should be linked to existing account by email');
        
        // Second contact should have a new account created
        Contact contact2 = contacts[1];
        System.assertEquals('michael.brown@example.com', contact2.Email);
        System.assertNotEquals(null, contact2.AccountId, 'Contact should have an account assigned');
        System.assertEquals('Michael Brown', contact2.Account.Name, 'New account should be created with proper name');
        System.assertEquals('michael.brown@example.com', contact2.Account.Email__c, 'New account should have email assigned');
    }
    
    @isTest
    static void testHandlingOfGenericEmails() {
        // Test CSV with generic emails that should be ignored for account matching
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Taylor,Sarah,POL-GEN1,555-888-9999,none@email.com,,Auto,111 Oak Dr,Scottsdale,AZ,85250,11/05/2023,Cancelled\n' +
                           'Miller,David,POL-GEN2,555-777-6666,unknown@email.com,,Home,222 Pine Rd,Glendale,AZ,85301,12/15/2023,Expired';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Query the contacts and verify accounts
        List<Contact> contacts = [
            SELECT Id, LastName, FirstName, Email, AccountId, Account.Name, Account.Email__c
            FROM Contact 
            WHERE Policy_Number__c IN ('POL-GEN1', 'POL-GEN2')
            ORDER BY LastName
        ];
        
        System.assertEquals(2, contacts.size(), 'Two contacts should have been created');
        
        // Both contacts should have accounts, but the accounts should not have emails
        for (Contact c : contacts) {
            System.assertNotEquals(null, c.AccountId, 'Contact should have an account assigned');
            System.assertEquals(null, c.Account.Email__c, 'Account should not have a generic email assigned');
        }
    }
    
    // @isTest
    // static void testMissingRequiredFields() {
    //     // Test a CSV missing required fields
    //     String csvContent = 'First Name,Email,Phone,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
    //                        'Thomas,thomas@example.com,555-123-4567,,Auto,123 Street,Phoenix,AZ,85001,01/15/2023,Cancelled';
        
    //     Test.startTest();
    //     try {
    //         List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
    //         System.assert(false, 'Should have thrown an exception for missing required fields');
    //     } catch (AuraHandledException e) {
    //         System.assert(e.getMessage().contains('Missing required column: Last Name') || 
    //                      e.getMessage().contains('Missing required column: Policy Number'), 
    //                      'Exception should mention missing required fields');
    //     }
    //     Test.stopTest();
    // }
    
    @isTest
    static void testDuplicatePolicyNumbers() {
        // Test a CSV with duplicate policy numbers
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Martinez,Carlos,POL-DUP1,555-123-1111,carlos@example.com,,Auto,100 First St,Tucson,AZ,85701,02/10/2023,Cancelled\n' +
                           'Rodriguez,Ana,POL-DUP1,555-123-2222,ana@example.com,,Home,200 Second Ave,Phoenix,AZ,85001,03/15/2023,Expired';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Verify only one contact was created with that policy number
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Policy_Number__c = 'POL-DUP1'];
        System.assertEquals(1, contacts.size(), 'Only one contact should exist with the duplicate policy number');
    }
    
    @isTest
    static void testDateParsing() {
        // Test various date formats
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'White,Susan,POL-DATE1,555-123-3333,susan@example.com,,Auto,300 Third Blvd,Mesa,AZ,85201,4/5/23,Cancelled\n' +
                           'Lee,Kevin,POL-DATE2,555-123-4444,kevin@example.com,,Home,400 Fourth Ct,Chandler,AZ,85224,12/31/2023,Expired';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Verify dates were parsed correctly
        List<Contact> contacts = [
            SELECT Id, Policy_Number__c, Quote_Effective_Date__c
            FROM Contact 
            WHERE Policy_Number__c IN ('POL-DATE1', 'POL-DATE2')
            ORDER BY Policy_Number__c
        ];
        
        System.assertEquals(2, contacts.size(), 'Two contacts should have been created');
        System.assertEquals(Date.newInstance(2023, 4, 5), contacts[0].Quote_Effective_Date__c, 'Short date should be parsed correctly');
        System.assertEquals(Date.newInstance(2023, 12, 31), contacts[1].Quote_Effective_Date__c, 'Full date should be parsed correctly');
    }
    
    @isTest
    static void testInvalidDateFormat() {
        // Test invalid date format
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Black,Jack,POL-INVDATE,555-123-5555,jack@example.com,,Auto,500 Fifth Ave,Tempe,AZ,85281,2023-05-15,Cancelled';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // The contact should be created but with a null date
        Contact contact = [
            SELECT Id, Policy_Number__c, Quote_Effective_Date__c
            FROM Contact 
            WHERE Policy_Number__c = 'POL-INVDATE'
        ];
        
        System.assertEquals(null, contact.Quote_Effective_Date__c, 'Invalid date format should result in null date');
    }
    
    // @isTest
    // static void testEmptyCSV() {
    //     // Test empty CSV
    //     String csvContent = '';
        
    //     Test.startTest();
    //     try {
    //         List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
    //         System.assert(false, 'Should have thrown an exception for empty CSV');
    //     } catch (AuraHandledException e) {
    //         System.assert(e.getMessage().contains('CSV file is empty'), 
    //                      'Exception should mention empty CSV file');
    //     }
    //     Test.stopTest();
    // }
    
    @isTest
    static void testCSVWithOnlyHeaders() {
        // Test CSV with only headers
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        System.assertEquals(0, resultIds.size(), 'No contacts should be created with only headers');
    }
    
    @isTest
    static void testSpecificPolicyStatuses() {
        // Test specifically the "Cancelled" and "Expired" policy statuses
        String csvContent = 'Last Name,First Name,Policy Number,Phone,Email,Company,Domestic Policy Type,Street Address,City,State,Zip,Effective Date,Policy Status\n' +
                           'Adams,Jane,POL-STATUS1,555-111-0000,jane@example.com,,Auto,600 Sixth St,Yuma,AZ,85364,05/10/2023,Cancelled\n' +
                           'Baker,Tom,POL-STATUS2,555-222-0000,tom@example.com,,Home,700 Seventh Ave,Flagstaff,AZ,86001,06/20/2023,Expired';
        
        Test.startTest();
        List<String> resultIds = ContactCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();
        
        // Verify policy statuses were set correctly
        List<Contact> contacts = [
            SELECT Id, LastName, Policy_Number__c, Policy_Status__c
            FROM Contact 
            WHERE Policy_Number__c IN ('POL-STATUS1', 'POL-STATUS2')
            ORDER BY Policy_Number__c
        ];
        
        System.assertEquals(2, contacts.size(), 'Two contacts should have been created');
        System.assertEquals('Cancelled', contacts[0].Policy_Status__c, 'Policy status should be set to Cancelled');
        System.assertEquals('Expired', contacts[1].Policy_Status__c, 'Policy status should be set to Expired');
    }
}