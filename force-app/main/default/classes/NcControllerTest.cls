@isTest
private class NcControllerTest {
    
    @testSetup
    static void setupData() {
        // Setup test data for Feedback__c object
        // No data needed for getOrgDatetime() and getTowMetadataRecords()
        
        // Insert custom metadata using Metadata API or Tooling API if required
        // For test coverage, insert test Tow_Type_mdt__mdt using SeeAllData=true (if needed)
    }

    @isTest
    static void testGetOrgDatetime() {
        Test.startTest();
        Datetime result = NcController.getOrgDatetime();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Org Datetime should not be null');
    }

    @isTest
    static void testSubmitFeedback() {
        Test.startTest();
        Integer testRating = 5;
        String testComment = 'Great service!';
        
        Feedback__c result = NcController.submitFeedback(testRating, testComment);
        Test.stopTest();

        System.assertNotEquals(null, result.Id, 'Feedback record should have been inserted');
        System.assertEquals(testRating, result.Rating__c);
        System.assertEquals(testComment, result.Comments__c);
    }

    @isTest
    static void testGetTowMetadataRecords() {
        // Insert a test custom metadata record if possible
        // NOTE: Custom metadata cannot be inserted via Apex directly. If required, use SeeAllData=true
        
        // Use SeeAllData only if the org contains required custom metadata records
        Test.startTest();
        List<Map<String, String>> results = NcController.getTowMetadataRecords();
        Test.stopTest();

        System.assertNotEquals(null, results, 'Result list should not be null');
    }
}