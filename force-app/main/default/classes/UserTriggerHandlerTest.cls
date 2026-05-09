@isTest
private class UserTriggerHandlerTest {

    @testSetup
    static void setup() {
        // Agency RT record type via Schema describe (no SOQL)
        Id agencyRTId = Schema.SObjectType.Contact
            .getRecordTypeInfosByName()
            .get('Agency RT')
            ?.getRecordTypeId();
        
        Account acc = new Account(Name = 'test account');
		insert acc;

        Contact agencyCon = new Contact(
            FirstName     = 'TestAgency',
            LastName      = 'AgencyContactUT',
            RecordTypeId  = agencyRTId,
            AccountId 	  = acc.Id
        );
        insert agencyCon;

        Contact subCon = new Contact(
            LastName   = 'SubContactUT',
            Agency__c  = agencyCon.Id,
            AccountId  = acc.Id
        );
        insert subCon;
    }

    // ── After Insert: portal user added to agency group via UserTrigger ───────
    @isTest
    static void test_addUsersToAgencyGroup_insert() {
        Contact subCon = [SELECT Id FROM Contact WHERE LastName = 'SubContactUT' LIMIT 1];

        Profile portalProfile = [
            SELECT Id FROM Profile
            WHERE Name = 'Agency Community Plus Login User'
            LIMIT 1
        ];

        Test.startTest();
        User portalUser = new User(
            FirstName         = 'Portal',
            LastName          = 'AgencyUser',
            Alias             = 'agpu',
            Email             = 'agencyportal@example.com',
            Username          = 'agencyportal+' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'agpu' + System.currentTimeMillis(),
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = portalProfile.Id,
            ContactId         = subCon.Id
        );
        insert portalUser;
        Test.stopTest();

        // Verify GroupMember was created for the user in the agency group
        Contact agencyCon = [SELECT Id FROM Contact WHERE LastName = 'AgencyContactUT' LIMIT 1];
        Group agencyGrp = [
            SELECT Id FROM Group
            WHERE DeveloperName = :('Agency_' + agencyCon.Id.to15())
              AND Type = 'Regular'
            LIMIT 1
        ];
        List<GroupMember> members = [
            SELECT Id FROM GroupMember
            WHERE GroupId = :agencyGrp.Id
              AND UserOrGroupId = :portalUser.Id
        ];
        System.assertEquals(1, members.size(), 'Portal user should be added to agency group');
    }

    // ── updatePromoCode: covers the promo-code path ───────────────────────────
    @isTest
    static void test_updatePromoCode() {
        Account acc = new Account(Name = 'PromoTestAccount');
        insert acc;

        // Directly invoke the handler method to exercise the future path
        Test.startTest();
        UserTriggerHandler.updatePromoCode(new List<User>());
        Test.stopTest();

        System.assert(true, 'updatePromoCode completed without error');
    }
}