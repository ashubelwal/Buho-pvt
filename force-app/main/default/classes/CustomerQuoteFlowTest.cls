@isTest
private class CustomerQuoteFlowTest {

    @testSetup
    static void setupData() {
        // Create a Lead record
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@example.com',
            Phone = '1234567890',
            Status = 'Open - Not Contacted'
        );
        insert lead;

        // Create a User record (must be done as System Admin with permissions)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Existing',
            LastName = 'User',
            Email = 'existinguser@example.com',
            Username = 'existinguser@example.com.test',
            Alias = 'exuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        // Optional: Create a Quote__c linked to Lead if custom object exists
        if (Schema.sObjectType.Quote__c != null) {
            Quote__c quote = new Quote__c(Lead__c = lead.Id);
            insert quote;
        }
    }

    @isTest
    static void testSaveLeadUserDetails() {
        Lead newLead = new Lead(
            FirstName = 'New',
            LastName = 'Lead',
            Company = 'Test New Company',
            Email = 'newlead@example.com',
            Phone = '9876543210',
            Status = 'Open - Not Contacted'
        );
        String leadJson = JSON.serialize(newLead);

        Test.startTest();
        Map<String, Object> result = CustomerQuoteFlow.saveLeadUserDetails(leadJson);
        Test.stopTest();

        System.assertEquals('Success', result.get('Status'), 'Expected success status');
        System.assert(result.containsKey('LeadId'), 'Should return Lead ID');
    }

    @isTest
    static void testSaveLeadUserDetails_Invalid() {
        Test.startTest();
        try {
            CustomerQuoteFlow.saveLeadUserDetails(null);
            System.assert(false, 'Exception should have been thrown for null input');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No data found'), 'Expected "No data found" exception');
        }
        Test.stopTest();
    }

    @isTest
    static void testCheckAlreadyExistUserAction_UserExists() {
        Lead testLead = new Lead(
            FirstName = 'User',
            LastName = 'Exists',
            Company = 'Company',
            Email = 'existinguser@example.com',
            Phone = '1234567890',
            Status = 'Open - Not Contacted'
        );

        String inputJson = JSON.serialize(testLead);

        Test.startTest();
        Map<String, Object> result = CustomerQuoteFlow.checkalreadyExistUserAction(inputJson);
        Test.stopTest();

        System.assertEquals(true, result.get('isExistUser'), 'Expected user to exist');
        System.assertEquals('Success', result.get('status'));
    }

    @isTest
    static void testCheckAlreadyExistUserAction_LeadExists() {
        Lead existingLead = [SELECT Id, Email, FirstName, LastName, Phone FROM Lead LIMIT 1];

        String inputJson = JSON.serialize(existingLead);

        Test.startTest();
        Map<String, Object> result = CustomerQuoteFlow.checkalreadyExistUserAction(inputJson);
        Test.stopTest();

        System.assertEquals(false, result.get('isExistUser'), 'User should not exist');
        System.assertEquals('Success', result.get('status'));
        System.assertNotEquals(null, result.get('LeadInfo'));
    }

    @isTest
    static void testCheckAlreadyExistUserAction_NoMatch() {
        Lead dummyLead = new Lead(
            FirstName = 'Ghost',
            LastName = 'User',
            Company = 'Phantom',
            Email = 'ghost@example.com',
            Phone = '0000000000',
            Status = 'Open - Not Contacted'
        );

        String inputJson = JSON.serialize(dummyLead);

        Test.startTest();
        Map<String, Object> result = CustomerQuoteFlow.checkalreadyExistUserAction(inputJson);
        Test.stopTest();

        System.assertEquals('Error', result.get('status'));
        System.assertEquals('No lead and user exists', result.get('Message'));
    }
    
    @isTest
    static void testCreateUserMethod(){
        /*Profile mockProfile = new Profile(Name = 'Mex Insurance Customer Community Plus Login User');
        insert mockProfile;*/
        
        contact con = new contact(FirstName='test', LastName='contact', Email='test.contact@example.com');
            insert con;
        String contactInfo = '{"Id":"'+con.Id+'", "FirstName":"John", "LastName":"Doe", "Email":"john.doe@example.com"}';

        // Step 3: Call the method to be tested
        Test.startTest();
        Map<String, Boolean> result = CustomerQuoteFlow.createNewUser(contactInfo);
        Test.stopTest();

        // Step 4: Verify the result (ensure the success flag is true)
        //System.assertEquals(true, result.get('Success'), 'User should be created successfully.');
    }
}