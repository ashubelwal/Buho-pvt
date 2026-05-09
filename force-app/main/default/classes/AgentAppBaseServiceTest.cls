@isTest
public class AgentAppBaseServiceTest {
    /**
     * Covers the null/blank-leadJson early-return path (returns null).
     */
    @isTest
    static void testSaveLeadDetails_blankInput_returnsNull() {
        Test.startTest();
        String result = AgentAppBaseService.saveLeadDetails(null, null, null, null);
        Test.stopTest();
        System.assertEquals(null, result, 'Should return null for blank leadJson');
    }

    /**
     * Covers the happy-path: a valid Lead JSON is provided, the method
     * resolves the running user's context and upserts the Lead.
     * The test runs as an admin-type user so User_Type__c is null,
     * exercising the Customer / null branch (which then resolves agentId
     * from Contact.Email).
     */
    @isTest
    static void testSaveLeadDetails_validInput_returnsSerializedLead() {
        // Minimal lead JSON — only fields needed for the upsert
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName  = 'Agent',
            Company   = 'Test Agent',
            Email     = 'test.agent.bsvc@example.com'
        );
        String leadJson    = JSON.serialize(testLead);
        String quoteJson   = '{}';
        String vehicleJson = '{}';
        String towedJson   = '{}';

        Test.startTest();
        String resultJson = AgentAppBaseService.saveLeadDetails(leadJson, quoteJson, vehicleJson, towedJson);
        Test.stopTest();

        // Result should be a non-null serialised Lead with an Id
        System.assertNotEquals(null, resultJson, 'Should return serialised lead JSON');
        Lead returned = (Lead) JSON.deserialize(resultJson, Lead.class);
        System.assertEquals('Test', returned.FirstName);
    }
}