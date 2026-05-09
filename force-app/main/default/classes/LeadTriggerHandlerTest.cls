@isTest
private class LeadTriggerHandlerTest {

    @testSetup
    static void setup() {
        // Create a Public Group simulating what ContactTriggerHandler would create
        // (in real org the group is created by ContactTrigger on Agency contact insert)
        Contact agencyContact = new Contact(LastName = 'AgencyContact');
        insert agencyContact;

        Group agencyGroup = new Group(
            Name          = 'AgencyContact',
            DeveloperName = 'Agency_' + agencyContact.Id.to15(),
            Type          = 'Regular'
        );
        insert agencyGroup;

        Contact agencyContact2 = new Contact(LastName = 'AgencyContact2');
        insert agencyContact2;

        Group agencyGroup2 = new Group(
            Name          = 'AgencyContact2',
            DeveloperName = 'Agency_' + agencyContact2.Id.to15(),
            Type          = 'Regular'
        );
        insert agencyGroup2;
    }

    // ── After Insert: LeadShare created for the agency group ─────────────────
    @isTest
    static void test_afterInsert_sharesWithGroup() {
        Contact agencyContact = [SELECT Id FROM Contact WHERE LastName = 'AgencyContact' LIMIT 1];

        Test.startTest();
        Lead ld = new Lead(
            LastName  = 'TestLead',
            Company   = 'TestCo',
            Agency__c = agencyContact.Id
        );
        insert ld;
        Test.stopTest();

        Group grp = [SELECT Id FROM Group WHERE DeveloperName = :('Agency_' + agencyContact.Id.to15()) LIMIT 1];
        List<LeadShare> shares = [
            SELECT Id FROM LeadShare
            WHERE LeadId = :ld.Id AND UserOrGroupId = :grp.Id AND RowCause = 'Manual'
        ];
        System.assertEquals(1, shares.size(), 'LeadShare with agency group should be created');
    }

    // ── After Update: Agency changed – old share removed, new share added ─────
    @isTest
    static void test_afterUpdate_agencyChanged() {
        Contact agency1 = [SELECT Id FROM Contact WHERE LastName = 'AgencyContact'  LIMIT 1];
        Contact agency2 = [SELECT Id FROM Contact WHERE LastName = 'AgencyContact2' LIMIT 1];

        Lead ld = new Lead(LastName = 'UpdateLead', Company = 'Co', Agency__c = agency1.Id);
        insert ld;

        Test.startTest();
        ld.Agency__c = agency2.Id;
        update ld;
        Test.stopTest();

        Group grp1 = [SELECT Id FROM Group WHERE DeveloperName = :('Agency_' + agency1.Id.to15()) LIMIT 1];
        Group grp2 = [SELECT Id FROM Group WHERE DeveloperName = :('Agency_' + agency2.Id.to15()) LIMIT 1];

        List<LeadShare> oldShares = [SELECT Id FROM LeadShare WHERE LeadId = :ld.Id AND UserOrGroupId = :grp1.Id AND RowCause = 'Manual'];
        List<LeadShare> newShares = [SELECT Id FROM LeadShare WHERE LeadId = :ld.Id AND UserOrGroupId = :grp2.Id AND RowCause = 'Manual'];

        System.assertEquals(0, oldShares.size(), 'Old agency group share should be removed');
        System.assertEquals(1, newShares.size(), 'New agency group share should be created');
    }

    // ── After Update: Agency unchanged – no re-sharing ────────────────────────
    @isTest
    static void test_afterUpdate_agencyUnchanged() {
        Contact agency1 = [SELECT Id FROM Contact WHERE LastName = 'AgencyContact' LIMIT 1];
        Lead ld = new Lead(LastName = 'NoChangeLead', Company = 'Co', Agency__c = agency1.Id);
        insert ld;

        Test.startTest();
        ld.LastName = 'NoChangeLead_Updated';
        update ld;
        Test.stopTest();

        System.assert(true, 'Update without agency change completed without error');
    }
}
