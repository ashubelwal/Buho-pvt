@isTest
private class ContactTriggerHandlerTest {
    
    // ── Helper: Agency RT Id via Schema describe (no SOQL) ───────────────────
    private static Id getAgencyRTId() {
        Schema.RecordTypeInfo rti = Schema.SObjectType.Contact
            .getRecordTypeInfosByName()
            .get('Agency RT');
        return rti != null ? rti.getRecordTypeId() : null;
    }
    
    @testSetup
    static void setup() {
        Account agencyAccount = new Account(
            Name = 'Test Agency Account'
        );
        insert agencyAccount;
        
        Contact agencyCon = new Contact(
            LastName  = 'TestAgencyRoot',
            AccountId = agencyAccount.Id
        );
        insert agencyCon;
        
        Group agencyGrp = new Group(
            Name          = 'TestAgencyRoot',
            DeveloperName = 'Agc_' + agencyCon.Id.to15(),
            Type          = 'Regular'
        );
        insert agencyGrp;
        
        
        
        Profile portalProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Agency Community Plus Login User'
            LIMIT 1
        ];
        
        User portalUser = new User(
            FirstName         = 'Portal',
            LastName          = 'User',
            Alias             = 'puser',
            Email             = 'portaluser@example.com',
            Username          = 'portaluser+' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'portaluser' + System.currentTimeMillis(),
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = portalProfile.Id,
            ContactId         = agencyCon.Id
        );
        
        insert portalUser;
        
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName  = 'Doe',
            Phone     = '1234567890',
            Email     = 'john.doe@example.com',
            Company   = 'Test Company',
            Agency__c = agencyCon.Id
        );
        insert testLead;
        
        LeadStatus convertedStatus = [
            SELECT MasterLabel 
            FROM LeadStatus 
            WHERE IsConverted = true 
            LIMIT 1
        ];
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setConvertedStatus(convertedStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(true);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
    }
    
    // ── After Update: lead-sync (Agency__c populated contact) ────────────────
    @isTest
    static void test_updateLeadData() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        con.FirstName = 'Jane';
        con.LastName  = 'Smith';
        con.Phone     = '0987654321';
        con.Email     = 'jane.smith@example.com';
        
        Test.startTest();
        update con;
        Test.stopTest();
        
        Lead updatedLead = [SELECT FirstName FROM Lead WHERE ConvertedContactId = :con.Id LIMIT 1];
        System.assertEquals('Jane', updatedLead.FirstName);
    }
    
    // ── After Insert: Agency RT contact – group creation path ────────────────
    @isTest
    static void test_afterInsert_agencyGroup() {
        Id rtId = getAgencyRTId();
        
        Test.startTest();
        Contact agencyCon = new Contact(LastName = 'TestAgency', RecordTypeId = rtId);
        Database.SaveResult sr = Database.insert(agencyCon, false);
        Test.stopTest();
        
        System.assert(sr.isSuccess(), 'Contact insert should succeed: ' + sr.getErrors());
    }
    
    // ── Before Delete: group deletion path ───────────────────────────────────
    @isTest
    static void test_beforeDelete_agencyGroup() {
        Id rtId = getAgencyRTId();
        Contact agencyCon = new Contact(LastName = 'DeleteAgency', RecordTypeId = rtId);
        insert agencyCon;
        
        Test.startTest();
        delete agencyCon;
        Test.stopTest();
        
        List<Group> grps = [
            SELECT Id FROM Group
            WHERE DeveloperName = :('Agc_' + agencyCon.Id.to15()) AND Type = 'Regular'
        ];
        System.assertEquals(0, grps.size(), 'Group should not exist after contact deletion');
    }
    
    // ── After Insert: Agency RT + Agency__c set – portal-user group path ─────
    @isTest
    static void test_afterInsert_withAgency() {
        Contact agencyRoot = [SELECT Id FROM Contact WHERE LastName = 'TestAgencyRoot' LIMIT 1];
        Id rtId = getAgencyRTId();
        
        Test.startTest();
        // Contact with Agency__c pointing at agencyRoot and Agency RT – hits addPortalUsersToAgencyGroup
        Contact subCon = new Contact(
            LastName     = 'SubContact',
            Agency__c    = agencyRoot.Id,
            RecordTypeId = rtId
        );
        Database.SaveResult sr = Database.insert(subCon, false);
        Test.stopTest();
        
        System.assert(sr.isSuccess(), 'Sub-contact insert should succeed: ' + sr.getErrors());
    }
    
    // ── After Insert: no Agency__c – covers the isEmpty() fast-exit ──────────
    @isTest
    static void test_afterInsert_noAgency() {
        Test.startTest();
        Contact plain = new Contact(LastName = 'NoAgency');
        Database.SaveResult sr = Database.insert(plain, false);
        Test.stopTest();
        
        System.assert(sr.isSuccess(), 'Plain contact insert should succeed');
    }
}