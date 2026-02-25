/**
 * @File Name : BuhoQuoteFlowTest.cls
 * @Description : Test class for BuhoQuoteFlow
 * @Author : System
 * @Last Modified On : January 30, 2026
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | January 30, 2026 |   | Initial Version
 **/

@isTest
private class BuhoQuoteFlowTest {
    
    // Test data setup
    @TestSetup
    static void setupTestData() {
        // Create TriggerSwitch custom setting to disable triggers during test
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = FALSE;
        insert customset;
        
        // Create Profile for community user
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Buho Customer Community Plus Login User' LIMIT 1];
        
        // Create Account
        Account testAccount = new Account(
            Name = 'Test Account',
            AnnualRevenue = 2000
        );
        insert testAccount;
        
        // Create Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Phone = '1234567890',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create User
        User testUser = new User();
        testUser.LastName = 'Test Code';
        testUser.Email = 'test' + String.valueOf(System.today()) + '@test.com';
        testUser.Alias = 'Tcode';
        testUser.Username = 'test' + String.valueOf(System.today()) + '@test.com';
        testUser.CommunityNickname = 'test12';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.ProfileID = profileId.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ContactId = testContact.Id;
        insert testUser;
        
        // Create Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'testlead@example.com',
            Phone = '9876543210',
            Company = 'Test Company',
            Status = 'New'
        );
        insert testLead;
        
        // Create Quote
        Quote__c testQuote = new Quote__c(
            Lead__c = testLead.Id,
            Contact__c = testContact.Id,
            Account__c = testAccount.Id,
            Start_Date_for_Coverage__c = System.today(),
            End_Date_for_Coverage__c = System.today() + 5,
            Start_Time__c = Time.newInstance(10, 00, 00, 00),
            End_Time__c = Time.newInstance(10, 00, 00, 00),
            Driver_Age__c = 80,
            Underwriter__c = 'Chubb',
            Coverage__c = 'Complete',
            Territory__c = 'Full',
            Term__c = 'Daily',
            Policy_Type_picklist__c = 'Automobile',
            Vehicle_Type__c = 'Automobile',
            Medical__c = '2,000/10,000',
            Liability__c = '100,000',
            Date_of_Birth__c = Date.newInstance(1950, 10, 12),
            Towed_Unit__c = 'Yes'
        );
        insert testQuote;
        
        // Create Vehicle
        Vehicle__c testVehicle = new Vehicle__c(
            Contact__c = testContact.Id,
            Account_Vehicle__c = testAccount.Id,
            Lead__c = testLead.Id,
            Year__c = '2020',
            Make__c = 'Ford',
            Model__c = 'SUV',
            Type__c = 'Car',
            Company_Name__c = 'Test Company',
            Company_Address__c = 'Test Address'
        );
        insert testVehicle;
        
        // Create Driver
        Driver__c testDriver = new Driver__c(
            Contact__c = testContact.Id,
            Account_Driver__c = testAccount.Id,
            Lead__c = testLead.Id,
            First_Name__c = 'Test',
            Last_Name__c = 'Driver',
            Email__c = 's@gmail.com',
            Driver_Type__c = 'Owner',
            Phone__c = '123',
            Address__c = 'address',
            Address_Line_2__c = 'address',
            City__c = 'city',
            Country__c = 'country',
            Default__c = 'Yes'
        );
        insert testDriver;
        
        // Create Towed Unit
        Towed_Unit__c testTowedUnit = new Towed_Unit__c(
            Contact__c = testContact.Id,
            Account__c = testAccount.Id,
            Quote_c__c = testQuote.Id,
            Year__c = '2019',
            Make__c = 'Trailer',
            Model__c = 'Cargo'
        );
        insert testTowedUnit;
    }
    
    /**
     * Test checkCommunityUserAndFetchDetails - Guest User Scenario
     */
    @isTest
    static void testCheckCommunityUserAndFetchDetails_GuestUser() {
        Test.startTest();
        String result = BuhoQuoteFlow.checkCommunityUserAndFetchDetails();
        Test.stopTest();
        
        // Parse the result
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        // Verify results for guest user
        System.assertEquals('success', responseMap.get('status'), 'Status should be success');
        System.assertNotEquals(null, responseMap, 'Response should not be null');
    }
    
    /**
     * Test checkCommunityUserAndFetchDetails - Logged In User Scenario
     */
    @isTest
    static void testCheckCommunityUserAndFetchDetails_LoggedInUser() {
        User testUser = [SELECT Id FROM User WHERE Alias = 'Tcode' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            String result = BuhoQuoteFlow.checkCommunityUserAndFetchDetails();
            Test.stopTest();
            
            // Parse the result
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            
            // Verify results
            System.assertEquals('success', responseMap.get('status'), 'Status should be success');
            System.assertNotEquals(null, responseMap.get('email'), 'Email should not be null');
            System.assertNotEquals(null, responseMap.get('contact'), 'Contact should not be null');
            
        }
    }
    
    /**
     * Test saveLeadUserDetails - Successful Insert
     */
    @isTest
    static void testSaveLeadUserDetails_SuccessfulInsert() {
        // Create test lead data
        Lead testLead = new Lead(
            FirstName = 'New',
            LastName = 'Lead',
            Email = 'newlead@example.com',
            Phone = '5555555555',
            Company = 'New Company',
            Status = 'Open'
        );
        
        String leadJson = JSON.serialize(testLead);
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.saveLeadUserDetails(leadJson);
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Success', result.get('Status'), 'Status should be Success');
        System.assertNotEquals(null, result.get('LeadId'), 'LeadId should not be null');
        
        // Verify lead was created
        List<Lead> leads = [SELECT Id, Email FROM Lead WHERE Email = 'newlead@example.com'];
        System.assertEquals(1, leads.size(), 'One lead should be created');
    }
    
    /**
     * Test saveLeadUserDetails - Successful Update
     */
    @isTest
    static void testSaveLeadUserDetails_SuccessfulUpdate() {
        // Get existing lead
        Lead existingLead = [SELECT Id, FirstName, LastName, Email FROM Lead LIMIT 1];
        existingLead.FirstName = 'Updated';
        
        String leadJson = JSON.serialize(existingLead);
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.saveLeadUserDetails(leadJson);
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Success', result.get('Status'), 'Status should be Success');
        
        // Verify lead was updated
        Lead updatedLead = [SELECT Id, FirstName FROM Lead WHERE Id = :existingLead.Id];
        System.assertEquals('Updated', updatedLead.FirstName, 'FirstName should be updated');
    }
    
    /**
     * Test saveLeadUserDetails - Null Data
     */
    @isTest
    static void testSaveLeadUserDetails_NullData() {
        Test.startTest();
        try {
            BuhoQuoteFlow.saveLeadUserDetails(null);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No data found'), 'Exception message should contain "No data found"');
        }
        Test.stopTest();
    }
    
    /**
     * Test checkalreadyExistUserAction - Existing Lead Found
     */
    @isTest
    static void testCheckAlreadyExistUserAction_ExistingLead() {
        // Get existing lead
        Lead existingLead = [SELECT Id, Email FROM Lead LIMIT 1];
        
        Lead searchLead = new Lead(
            Email = existingLead.Email
        );
        
        String leadJson = JSON.serialize(searchLead);
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.checkalreadyExistUserAction(leadJson);
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Success', result.get('status'), 'Status should be Success');
        System.assertNotEquals(null, result.get('LeadInfo'), 'LeadInfo should not be null');
        System.assertNotEquals(null, result.get('QuoteInfo'), 'QuoteInfo should not be null');
    }
    
    /**
     * Test checkalreadyExistUserAction - Existing Contact Found
     */
    @isTest
    static void testCheckAlreadyExistUserAction_ExistingContact() {
        // Get existing contact
        Contact existingContact = [SELECT Id, Email FROM Contact LIMIT 1];
        
        Lead searchLead = new Lead(
            Email = existingContact.Email
        );
        
        String leadJson = JSON.serialize(searchLead);
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.checkalreadyExistUserAction(leadJson);
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Success', result.get('status'), 'Status should be Success');
        System.assertEquals(true, result.get('isExistContact'), 'isExistContact should be true');
        System.assertNotEquals(null, result.get('contactData'), 'contactData should not be null');
    }
    
    /**
     * Test checkalreadyExistUserAction - No Records Found
     */
    @isTest
    static void testCheckAlreadyExistUserAction_NoRecordsFound() {
        Lead searchLead = new Lead(
            Email = 'nonexistent@example.com'
        );
        
        String leadJson = JSON.serialize(searchLead);
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.checkalreadyExistUserAction(leadJson);
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Error', result.get('status'), 'Status should be Error');
        System.assertEquals(null, result.get('LeadInfo'), 'LeadInfo should be null');
    }
    
    /**
     * Test checkalreadyExistUserAction - Update Lead with Name and Phone
     */
    @isTest
    static void testCheckAlreadyExistUserAction_UpdateLeadDetails() {
        // Get existing lead
        Lead existingLead = [SELECT Id, Email FROM Lead LIMIT 1];
        
        Lead searchLead = new Lead(
            Email = existingLead.Email,
            FirstName = 'Updated First',
            LastName = 'Updated Last',
            Phone = '1111111111'
        );
        
        String leadJson = JSON.serialize(searchLead);
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.checkalreadyExistUserAction(leadJson);
        Test.stopTest();
        
        // Verify lead was updated
        Lead updatedLead = [SELECT Id, FirstName, LastName, Phone FROM Lead WHERE Id = :existingLead.Id];
        System.assertEquals('Updated First', updatedLead.FirstName, 'FirstName should be updated');
        System.assertEquals('Updated Last', updatedLead.LastName, 'LastName should be updated');
        System.assertEquals('1111111111', updatedLead.Phone, 'Phone should be updated');
    }
    
    /**
     * Test checkalreadyExistUserAction - Search by Lead Id
     */
    @isTest
    static void testCheckAlreadyExistUserAction_SearchById() {
        // Get existing lead
        Lead existingLead = [SELECT Id, Email FROM Lead LIMIT 1];
        
        Lead searchLead = new Lead(
            Id = existingLead.Id,
            Email = existingLead.Email
        );
        
        String leadJson = JSON.serialize(searchLead);
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.checkalreadyExistUserAction(leadJson);
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Success', result.get('status'), 'Status should be Success');
        System.assertNotEquals(null, result.get('LeadInfo'), 'LeadInfo should not be null');
    }
    
    /**
     * Test createNewUser - Successful User Creation
     */
    @isTest
    static void testCreateNewUser_Success() {
        // Create a new contact for user creation
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact newContact = new Contact(
            FirstName = 'New',
            LastName = 'UserContact',
            Email = 'newusercontact' + System.currentTimeMillis() + '@example.com',
            Phone = '9999999999',
            AccountId = testAccount.Id
        );
        insert newContact;
        
        Map<String, Object> contactData = new Map<String, Object>{
            'Id' => newContact.Id,
            'FirstName' => newContact.FirstName,
            'LastName' => newContact.LastName,
            'Email' => newContact.Email
        };
        
        String contactJson = JSON.serialize(contactData);
        
        Test.startTest();
        Map<String, Boolean> result = BuhoQuoteFlow.createNewUser(contactJson);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(true, result.get('Success'), 'User creation should be successful');
        
        // Verify user was created
        List<User> users = [SELECT Id, Email FROM User WHERE Email = :newContact.Email];
        System.assertEquals(1, users.size(), 'One user should be created');
    }
    
    /**
     * Test createNewUser - Invalid Contact Data
     */
    @isTest
    static void testCreateNewUser_InvalidData() {
        Map<String, Object> contactData = new Map<String, Object>{
            'Id' => null,
            'FirstName' => 'Test',
            'LastName' => 'User',
            'Email' => 'invalid@example.com'
        };
        
        String contactJson = JSON.serialize(contactData);
        
        Test.startTest();
        Map<String, Boolean> result = BuhoQuoteFlow.createNewUser(contactJson);
        Test.stopTest();
        
        // Verify results - should fail due to invalid contact ID
        System.assertEquals(false, result.get('Success'), 'User creation should fail with invalid contact');
    }
    
    /**
     * Test createNewUser - Duplicate Username
     */
    @isTest
    static void testCreateNewUser_DuplicateUsername() {
        // Get existing user contact (already has a user from setup)
        Contact testContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'testuser@example.com' LIMIT 1];
        User existingUser = [SELECT Id, Email FROM User WHERE ContactId = :testContact.Id LIMIT 1];
        
        // Try to create another user with same email/username
        Map<String, Object> contactData = new Map<String, Object>{
            'Id' => testContact.Id,
            'FirstName' => testContact.FirstName,
            'LastName' => testContact.LastName,
            'Email' => existingUser.Email
        };
        
        String contactJson = JSON.serialize(contactData);
        
        Test.startTest();
        Map<String, Boolean> result = BuhoQuoteFlow.createNewUser(contactJson);
        Test.stopTest();
        
        // Verify results - should fail due to duplicate username
        System.assertEquals(false, result.get('Success'), 'User creation should fail with duplicate username');
    }
    
    /**
     * Test Exception Handling in checkalreadyExistUserAction
     */
    @isTest
    static void testCheckAlreadyExistUserAction_ExceptionHandling() {
        // Pass invalid JSON to trigger exception
        String invalidJson = 'invalid json';
        
        Test.startTest();
        Map<String, Object> result = BuhoQuoteFlow.checkalreadyExistUserAction(invalidJson);
        Test.stopTest();
        
        // Verify error response
        System.assertEquals('Error', result.get('status'), 'Status should be Error');
        System.assertNotEquals(null, result.get('message'), 'Error message should not be null');
    }
    
    /**
     * Test Coverage for Helper Methods
     * These are implicitly tested through the main methods, but adding explicit test for completeness
     */
    @isTest
    static void testHelperMethodsCoverage() {
        // This test ensures the private helper methods are covered
        // They are called implicitly by checkCommunityUserAndFetchDetails
        
        Test.startTest();
        String result = BuhoQuoteFlow.checkCommunityUserAndFetchDetails();
        Test.stopTest();
        
        // Verify the method executed successfully
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals('success', responseMap.get('status'), 'Status should be success');
    }
    
    /**
     * Test saveLeadUserDetails with Invalid JSON
     */
    @isTest
    static void testSaveLeadUserDetails_InvalidJSON() {
        String invalidJson = 'invalid json structure';
        
        Test.startTest();
        try {
            BuhoQuoteFlow.saveLeadUserDetails(invalidJson);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('unexpected error'), 'Exception message should mention unexpected error');
        }
        Test.stopTest();
    }
}