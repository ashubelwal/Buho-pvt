@isTest
public class LienholderDetailFlowTest {

    @testSetup
    static void setupData() {
        // Insert test Lead without specifying Id
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test Company',
            Email = 'sdfsdu@sdff.com'
        );
        insert lead;

        // Store Lead Id in custom setting or custom label if needed across methods
    }

    @isTest
    static void testSaveLienholderDetails_Success() {
        // Get inserted lead
        Lead testLead = [SELECT Id FROM Lead WHERE Email = 'sdfsdu@sdff.com' LIMIT 1];

        // Inject the dynamic Id into the payload
        String payload = '[{"userDetails":{"Company":"Test Company","Email":"sdfsdu@sdff.com","FirstName":"dsvds","Phone":"","LastName":"dsdsf","Id":"'
            + testLead.Id +
            '"}},{"lienholderInformation":{"Lienholder_Country__c":"234345","Lienholder_Country__cmbx":"Canada","Lienholder_name__c":"ADDISON AVENUE FCU (ALL TITLES) (FORMERLY HPEFCU)","Lienholder_Phone__c":"(989) 999-9999","Lienholder_Fax__c":"(989) 999-9999","Lienholder_Street__c":"NOW KNOWN AS FIRST TECHNOLOGY FEDERAL CREDIT UNION","Lienholder_Postal_Code__c":"234345","Lienholder_State__c":"Unites States","Lienholder_City__c":"Alabama"}}]';

        Test.startTest();
        Map<String, Object> result = LienholderDetailFlow.saveLienholderDetails(payload);
        Test.stopTest();

        System.assertEquals('Success', result.get('Status'), 'Expected success response');
        System.assertEquals(testLead.Id, result.get('LeadId'), 'Lead Id should match');
        
        // Verify field is updated
        Lead updatedLead = [SELECT Lienholder_info__c FROM Lead WHERE Id = :testLead.Id];
        System.assertNotEquals(null, updatedLead.Lienholder_info__c, 'Lienholder info should be populated');
        System.assert(!updatedLead.Lienholder_info__c.contains('Lienholder_Country__cmbx'), 'Should not contain removed key');
    }

    @isTest
    static void testSaveLienholderDetails_NoEmailOrId() {
        String invalidPayload = '[{"userDetails":{"Company":"Test Company"}}]';

        Test.startTest();
        Map<String, Object> result = LienholderDetailFlow.saveLienholderDetails(invalidPayload);
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'), 'Expected error for missing Id and Email');
        System.assertEquals('Lead record not found. Email is required.', result.get('Message'));
    }

    @isTest
    static void testSaveLienholderDetails_LeadNotFoundByEmail() {
        String payload = '[{"userDetails":{"Company":"Test Company","Email":"notfound@example.com"}}]';

        Test.startTest();
        Map<String, Object> result = LienholderDetailFlow.saveLienholderDetails(payload);
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('No lead found.', result.get('Message'));
    }

    @isTest
    static void testSaveLienholderDetails_EmptyPayload() {
        Test.startTest();
        Map<String, Object> result = LienholderDetailFlow.saveLienholderDetails('');
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('No data found.', result.get('Message'));
    }
}