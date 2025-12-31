@isTest
private class TerritoryOptionFlowTest {

    @testSetup
    static void setupLeadData() {
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Co',
            Email = 'sdfsdu@sdff.com',
            Status = 'Open - Not Contacted'
        );
        insert lead;
    }

    @isTest
    static void testSaveTerritoryDetails_Success() {
        Lead testLead = [SELECT Id, Email FROM Lead WHERE Email = 'sdfsdu@sdff.com' LIMIT 1];

        String payload = '[{"userDetails":{"Company":"Test Company","Email":"sdfsdu@sdff.com","FirstName":"dsvds","Phone":"","LastName":"dsdsf","Id":"' + 
            testLead.Id + 
            '"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"10,000/50,000","Year__c":"2023","Make":"Acura","Model":"Integra","Value__c":"15000","Make__c":"Acura","Model__c":"Integra","Vehicle_sub_type__c":"Automobile-Van-Minivan"}},{"termOption":{"Term__c":"Annual","Start_Date_for_Coverage__c":"2025-06-21","Start_Time__c":"13:30","End_Date_for_Coverage__c":"2026-06-21","End_Time__c":"12:00:00"}},{"territory":{"region":"Limited"}}]';

        Test.startTest();
        Map<String, Object> result = TerritoryOptionFlow.saveTerritoryDetails(payload);
        Test.stopTest();
    }

    @isTest
    static void testSaveTerritoryDetails_InvalidId() {
        String payload = '[{"userDetails":{"Email":"sdfsdu@sdff.com"}},{"territory":{"region":"Baja/Sonora"}}]';

        Test.startTest();
        Map<String, Object> result = TerritoryOptionFlow.saveTerritoryDetails(payload);
        Test.stopTest();
    }

    @isTest
    static void testSaveTerritoryDetails_NoEmail() {
        String payload = '[{"userDetails":{"Company":"Test","FirstName":"X","LastName":"Y"}},{"territory":{"region":"Baja/Sonora"}}]';

        Test.startTest();
        Map<String, Object> result = TerritoryOptionFlow.saveTerritoryDetails(payload);
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('Lead record not found.Email is required.', result.get('Message'));
    }

    @isTest
    static void testSaveTerritoryDetails_EmailNotFound() {
        String payload = '[{"userDetails":{"Email":"no-match@example.com"}},{"territory":{"region":"Full"}}]';

        Test.startTest();
        Map<String, Object> result = TerritoryOptionFlow.saveTerritoryDetails(payload);
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('Lead record not found. Please check again.', result.get('Message'));
    }

    @isTest
    static void testSaveTerritoryDetails_EmptyPayload() {
        Test.startTest();
        Map<String, Object> result = TerritoryOptionFlow.saveTerritoryDetails('');
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('No data found.', result.get('Message'));
    }
}