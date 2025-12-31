@isTest
private class TermOptionFlowTest {

    @testSetup
    static void setupData() {
        // Insert lead record
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'sdfsdu@sdff.com',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert lead;
    }

    @isTest
    static void testGetTermDaysMetadata() {
        Test.startTest();
        Map<String, Object> result = TermOptionFlow.getTermDaysMetadata();
        Test.stopTest();

        System.assertEquals('Success', result.get('Status'));
        System.assertNotEquals(null, result.get('Data'));
    }

    @isTest
    static void testGetTermAndDaysMetadata() {
        Test.startTest();
        Map<String, Object> result = TermOptionFlow.getTermAndDaysMetadata();
        Test.stopTest();

        System.assertEquals('Success', result.get('Status'));
        System.assertNotEquals(null, result.get('Data'));
    }

    @isTest
    static void testGetCalculatedTermEndTime() {
        String input = '{"Term__c":"Annual","Start_Date_for_Coverage__c":"2025-06-21","Start_Time__c":"13:30"}';
        Test.startTest();
        String endTime = TermOptionFlow.getCalculatedTermEndTime(input);
        Test.stopTest();

        System.assertEquals('12:00:00', endTime);
    }

    @isTest
    static void testSaveLeadPolicyTermsSuccess() {
        String payload = '[{"userDetails":{"Company":"Test Company","Email":"sdfsdu@sdff.com","FirstName":"dsvds","Phone":"","LastName":"dsdsf"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"10,000/50,000","Year__c":"2023","Make":"Acura","Model":"Integra","Value__c":"15000","Make__c":"Acura","Model__c":"Integra","Vehicle_sub_type__c":"Automobile-Van-Minivan"}},{"termOption":{"Term__c":"Annual","Start_Date_for_Coverage__c":"2025-06-21","Start_Time__c":"13:30","End_Date_for_Coverage__c":"2026-06-21"}}]';

        Test.startTest();
        Map<String, Object> result = TermOptionFlow.saveLeadPolicyTerms(payload);
        Test.stopTest();

        System.assertEquals('Success', result.get('Status'));
        System.assert(result.containsKey('LeadId'));
    }

    @isTest
    static void testSaveLeadPolicyTermsNoEmail() {
        String payload = '[{"userDetails":{"FirstName":"NoEmail"}},{"termOption":{"Term__c":"Annual"}}]';

        Test.startTest();
        Map<String, Object> result = TermOptionFlow.saveLeadPolicyTerms(payload);
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('Lead record not found.Email is required.', result.get('Message'));
    }

    @isTest
    static void testSaveLeadPolicyTermsEmptyInput() {
        Test.startTest();
        Map<String, Object> result = TermOptionFlow.saveLeadPolicyTerms('');
        Test.stopTest();

        System.assertEquals('Error', result.get('Status'));
        System.assertEquals('No data found.', result.get('Message'));
    }
}