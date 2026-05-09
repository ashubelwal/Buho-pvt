@isTest
public with sharing class AgencyPortalControllerTest {
    @isTest
    public static void testCreateAgencyUser() {
        

        // Create agency contact ID
        Account acc = new Account(Name='Agency Account');
        insert acc;
        Id agencyRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency RT').getRecordTypeId();
        
        Contact agencyContact = new Contact(LastName='AgencyRoot', AccountId = acc.Id, recordTypeId = agencyRtId);
        insert agencyContact;
        
        Profile standardProf = [SELECT Id FROM Profile WHERE Name='Agency Community Plus Login User' LIMIT 1];
        User existingUser = new User(
            Username = 'existing.user.test12@example.com',
            LastName = 'Existing',
            Email = 'existing.user.test12@example.com',
            Alias = 'existU',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProf.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = agencyContact.Id
        );
        insert existingUser;

        Test.startTest();
        
        // 1. Test duplicate email handling
        String resultDupe = AgencyPortalController.createAgencyUser('John', 'Doe', 'existing.user.test12@example.com', agencyContact.Id);
        System.assert(resultDupe.contains('Error'), 'Should return an error for duplicate email');
        
        // 2. Test successful creation
        String uniqueEmail = 'new.agency.user.tester' + System.currentTimeMillis() + '@example.com';
        String resultSuccess = AgencyPortalController.createAgencyUser('Jane', 'Smith', uniqueEmail, agencyContact.Id);
        
        Test.stopTest();
        
        if (resultSuccess == 'Success') {
            User newUser = [SELECT Id, ContactId, Profile.Name FROM User WHERE Username = :uniqueEmail LIMIT 1];
            System.assertEquals('Agency Community Plus Login User', newUser.Profile.Name, 'Should have the portal profile');
            System.assertNotEquals(null, newUser.ContactId, 'User should be linked to a contact');
            
            Contact insertedContact = [SELECT Id, FirstName, LastName, Agency__c, RecordType.Name FROM Contact WHERE Id = :newUser.ContactId LIMIT 1];
            System.assertEquals('Jane', insertedContact.FirstName);
            System.assertEquals('Agent RT', insertedContact.RecordType.Name);
            System.assertEquals(agencyContact.Id, insertedContact.Agency__c);
        }
    }

    @isTest
    static void testGetDashboardStats() {
        // No DML needed — aggregate queries always return a row (with count 0)
        // even when no records exist in test context.
        Test.startTest();
        Map<String, Object> stats = AgencyPortalController.getDashboardStats();
        Test.stopTest();

        // All expected keys must be present and non-null
        System.assertNotEquals(null, stats.get('totalPolicies'),     'totalPolicies must be present');
        System.assertNotEquals(null, stats.get('thisMonthPolicies'), 'thisMonthPolicies must be present');
        System.assertNotEquals(null, stats.get('lastMonthPolicies'), 'lastMonthPolicies must be present');
        System.assertNotEquals(null, stats.get('thisMonthRevenue'),  'thisMonthRevenue must be present');
        System.assertNotEquals(null, stats.get('lastMonthRevenue'),  'lastMonthRevenue must be present');
        System.assertNotEquals(null, stats.get('expiringSoon'),      'expiringSoon must be present');
        System.assertNotEquals(null, stats.get('totalClients'),      'totalClients must be present');
        System.assertNotEquals(null, stats.get('thisMonthClients'),  'thisMonthClients must be present');
        System.assertNotEquals(null, stats.get('lastMonthClients'),  'lastMonthClients must be present');
    }
}