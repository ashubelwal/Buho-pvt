@isTest
private class GoogleRegistrationHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create Contact for Community User
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Get community profile
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Buho Customer Community Plus Login User' LIMIT 1];
        
        // Create active user (username matches email for login verification lookup)
        User activeUser = new User(
            ContactId = testContact.Id,
            FirstName = testContact.FirstName,
            LastName = testContact.LastName,
            Email = testContact.Email,
            Username = testContact.Email,
            Alias = 'tuser',
            CommunityNickname = 'testuser' + System.currentTimeMillis(),
            ProfileId = communityProfile.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert activeUser;
    }
    
    @isTest
    static void testCreateUserSuccess() {
        GoogleRegistrationHandler handler = new GoogleRegistrationHandler();
        Auth.UserData data = new Auth.UserData(
            'testId', 
            'Test', 
            'User', 
            'Test User', 
            'testuser@example.com', 
            null, 
            'testuser@example.com', 
            'en_US', 
            'Google', 
            null, 
            new Map<String, String>()
        );
        
        Test.startTest();
        User resultUser = handler.createUser(null, data);
        Test.stopTest();
        
        System.assertNotEquals(null, resultUser, 'User should be found and returned');
    }
    
    @isTest
    static void testCreateUserFailure() {
        GoogleRegistrationHandler handler = new GoogleRegistrationHandler();
        Auth.UserData data = new Auth.UserData(
            'testId', 
            'Nonexistent', 
            'User', 
            'Nonexistent User', 
            'nonexistent@example.com', 
            null, 
            'nonexistent@example.com', 
            'en_US', 
            'Google', 
            null, 
            new Map<String, String>()
        );
        
        Test.startTest();
        try {
            handler.createUser(null, data);
            System.assert(false, 'Should throw an AuthProviderPluginException');
        } catch (Auth.AuthProviderPluginException e) {
            System.assert(e.getMessage().contains('No Buho user exists'), 'Exception message should match expected text');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateUser() {
        GoogleRegistrationHandler handler = new GoogleRegistrationHandler();
        Auth.UserData data = new Auth.UserData(
            'testId', 
            'Test', 
            'User', 
            'Test User', 
            'testuser@example.com', 
            null, 
            'testuser@example.com', 
            'en_US', 
            'Google', 
            null, 
            new Map<String, String>()
        );
        
        Test.startTest();
        handler.updateUser(null, null, data);
        Test.stopTest();
        
        System.assert(true, 'updateUser should execute without error');
    }
    
    @isTest
    static void testCreateUserAppleNullEmail() {
        GoogleRegistrationHandler handler = new GoogleRegistrationHandler();
        Auth.UserData data = new Auth.UserData(
            'testId', 
            'Priyanka', 
            'Rawat', 
            'Priyanka Rawat', 
            null, 
            null, 
            null, 
            'en_US', 
            'Apple', 
            null, 
            new Map<String, String>()
        );
        
        Test.startTest();
        try {
            handler.createUser(null, data);
            System.assert(false, 'Should throw an AuthProviderPluginException');
        } catch (Auth.AuthProviderPluginException e) {
            System.assert(e.getMessage().contains('Apple did not share your email address'), 'Exception message should guide Apple user on resetting settings');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateUserGenericNullEmail() {
        GoogleRegistrationHandler handler = new GoogleRegistrationHandler();
        Auth.UserData data = new Auth.UserData(
            'testId', 
            'Test', 
            'User', 
            'Test User', 
            null, 
            null, 
            null, 
            'en_US', 
            'Google', 
            null, 
            new Map<String, String>()
        );
        
        Test.startTest();
        try {
            handler.createUser(null, data);
            System.assert(false, 'Should throw an AuthProviderPluginException');
        } catch (Auth.AuthProviderPluginException e) {
            System.assert(e.getMessage().contains('Email address is required'), 'Exception message should complain about missing email');
        }
        Test.stopTest();
    }
}
