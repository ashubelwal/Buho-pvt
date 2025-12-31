@isTest
private class UserProfileControllerTest {

@testSetup
static void setupData() {
    // Assign a Role to the running user if not already assigned
    User sysAdmin = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
    if (sysAdmin.UserRoleId == null) {
        System.debug('⚠️ Running user must have a Role assigned.');
        return; // Or throw an exception if preferred
    }

    // Create an Account (required for Community users)
    Account account = new Account(
        Name = 'Test Community Account'
    );
    insert account;

    // Create Contact related to the above account
    Contact testContact = new Contact(
        FirstName = 'Community',
        LastName = 'User',
        Email = 'community.user@example.com',
        Phone = '1234567890',
        AccountId = account.Id,
        State__c = 'CA',
        Street__c = '123 Test Ave',
        Postal_Code__c = '90001',
        Country__c = 'USA',
        City__c = 'San Francisco',
        Date_of_Birth__c = Date.newInstance(1995, 5, 15)
    );
    insert testContact;

    // Fetch a Community profile
    Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];

    // Create the Community user linked to the contact
    User communityUser = new User(
        Username = 'testcommunityuser@example.com',
        Email = 'testcommunityuser@example.com',
        LastName = 'User',
        Alias = 'tuser',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = communityProfile.Id,
        LanguageLocaleKey = 'en_US',
        ContactId = testContact.Id
    );
    insert communityUser;
}


    @isTest
    static void testGetCurrentUserInfo() {
        // Retrieve community user
        User communityUser = [SELECT Id FROM User WHERE Username = 'testcommunityuser@example.com' LIMIT 1];

        // Run as community user
        System.runAs(communityUser) {
            Test.startTest();
            User result = UserProfileController.getCurrentUserInfo();
            Test.stopTest();

            System.assertEquals(communityUser.Id, result.Id);
            System.assertNotEquals(null, result.Contact);
            System.assertEquals('CA', result.Contact.State__c);
        }
    }
}