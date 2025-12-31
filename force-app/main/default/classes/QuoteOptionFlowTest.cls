@isTest
private class QuoteOptionFlowTest {

    @testSetup
    static void setupData() {
        // Insert a test Lead
        Lead testLead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Acme Inc',
            Email = 'jane.doe@example.com'
        );
        insert testLead;

        // Insert a test Vendor__c record
        Vendor__c vendor = new Vendor__c(Name = 'TestVendor');
        insert vendor;

        // NOTE: Custom Metadata records like Vendor_List__mdt must be deployed separately
        // For getVendors test to fully work, relevant metadata should be present in org
    }

    @isTest
    static void testSaveQuoteDetails_withLeadId() {
        Lead lead = [SELECT Id, Email FROM Lead WHERE Email = 'jane.doe@example.com' LIMIT 1];

        // Construct userDetails map
        Map<String, Object> userDetails = new Map<String, Object>{
            'Id' => lead.Id,
            'Email' => lead.Email
        };

        // Construct quoteDetails map
        Map<String, Object> quoteDetails = new Map<String, Object>{
            'Start_Date__c' => '2025-06-22',
            'End_Date__c' => '2025-06-23',
            'Start_Time__c' => '08:00:00',
            'End_Time__c' => '20:00:00',
            'Term_Type__c' => 'Daily'
        };

        List<Object> inputList = new List<Object>{
            new Map<String, Object>{
                'userDetails' => userDetails,
                'quotePage' => quoteDetails
            }
        };

        String inputJson = JSON.serialize(inputList);

        Test.startTest();
        Map<String, Object> result = QuoteOptionFlow.saveQuoteDetails(inputJson);
        Test.stopTest();

        System.assertEquals('Success', result.get('Status'), 'Expected a successful response');
        System.assertNotEquals(null, result.get('LeadId'), 'LeadId should be returned');
    }

    @isTest
    static void testSaveQuoteRecord_LeadContext() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        Map<String, Object> quoteDetails = new Map<String, Object>{
            'Start_Date__c' => '2025-06-22',
            'End_Date__c' => '2025-06-23',
            'Start_Time__c' => '10:00:00',
            'End_Time__c' => '18:00:00',
            'Term_Type__c' => 'Annual'
        };

        String quoteJson = JSON.serialize(quoteDetails);

        Test.startTest();
        Quote__c quote = QuoteOptionFlow.saveQuoteRecord(quoteJson, lead.Id, true);
        Test.stopTest();

        System.assertNotEquals(null, quote.Id, 'Quote record should be inserted');
        System.assertEquals(lead.Id, quote.Lead__c, 'Lead should be associated with quote');
    }

    @isTest
    static void testSaveQuoteDetails_withMissingData() {
        Test.startTest();
        Map<String, Object> result = QuoteOptionFlow.saveQuoteDetails('');
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('No data found.', result.get('Message'));
    }

    @isTest
    static void testGetVendors() {
        Test.startTest();
        Map<String, Vendor__c> result = QuoteOptionFlow.getVendors();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Vendor map should not be null');
        // Depending on org state, this could be empty or populated
    }
}