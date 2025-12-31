@isTest
public class DriverDetailsFlowTest {
    
    @testSetup
    static void setupTestData() {
        Lead testLead = new Lead(
            FirstName = 'Driver',
            LastName = 'Tester',
            Company = 'Test Company',
            Email = 'sdfsdu@sdff.com'
        );
        insert testLead;
    }

    @isTest
    static void testSaveDriverDetailsSuccess() {
        Lead lead = [SELECT Id FROM Lead WHERE Email = 'sdfsdu@sdff.com' LIMIT 1];

        String payload = '[{"userDetails":{"Company":"Test Company","Email":"sdfsdu@sdff.com","FirstName":"dsvds","Phone":"","LastName":"dsdsf","Id":"'
            + lead.Id +
            '"}},{"driverDetails":{"drivers":[{"First_Name__c":"dsvds","Last_Name__c":"dsdsf","License_Country__c":"United States","License_state__c":"Alabama","license_number__c":"fewfew234","Dob__c":"2009-06-21","Driver_Type__c":true,"Country__c":"United States","Country_Text__c":"United States","State_Province__c":"Colorado","Postal_Code__c":"81210","City__c":"Almont","Address__c":"234 American Mountain Rd","diff":1750544749797}],"companyInformation":{"Company_Name__c":"ankittcomp","Company_Phone__c":"(454) 645-656","Tax_ID__c":"23344","Company_Country__c":"United States","Company_Address__c":"4701 Great America Way","Company_Zip__c":"95054","Company_State__c":"California","Company_City__c":"Santa Clara"},"driverList":[{"Id":"","label":"Test Policy","value":"a0LRL00000DGr4Y2AT","First_Name__c":"Test","Last_Name__c":"Policy","License_Country__c":"United States","License_state__c":"Alabama","license_number__c":"4444","Dob__c":"2002-10-31","Driver_Type__c":false,"Country__c":"United States","Country_Text__c":"United States","State_Province__c":"Colorado","Postal_Code__c":"81210","City__c":"Almont","Address__c":"226 Grand Ave","diff":1760518801935}]}}]';

        Test.startTest();
        Map<String, Object> result = DriverDetailsFlow.saveDriverDetails(payload);
        Test.stopTest();

        System.debug('Test Result - Success: ' + result);
        
        // Optionally check updated data
        Lead updatedLead = [SELECT Driver_details__c FROM Lead WHERE Id = :lead.Id];
        System.debug('Updated Driver Details: ' + updatedLead.Driver_details__c);
    }

    @isTest
    static void testSaveDriverDetails_LeadNotFound() {
        String payload = '[{"userDetails":{"Email":"notfound@example.com"}},{"driverDetails":{"drivers":[{"First_Name__c":"Missing","Last_Name__c":"Lead"}]}}]';

        Test.startTest();
        Map<String, Object> result = DriverDetailsFlow.saveDriverDetails(payload);
        Test.stopTest();

        System.debug('Test Result - Lead Not Found: ' + result);
    }

    @isTest
    static void testSaveDriverDetails_EmptyPayload() {
        Test.startTest();
        Map<String, Object> result = DriverDetailsFlow.saveDriverDetails('');
        Test.stopTest();

        System.debug('Test Result - Empty Payload: ' + result);
    }

    @isTest
    static void testSaveDriverDetails_NoDrivers() {
        Lead lead = [SELECT Id FROM Lead WHERE Email = 'sdfsdu@sdff.com' LIMIT 1];

        String payload = '[{"userDetails":{"Email":"sdfsdu@sdff.com","Id":"' + lead.Id + '"}},{"driverDetails":{"drivers":[]}}]';

        Test.startTest();
        Map<String, Object> result = DriverDetailsFlow.saveDriverDetails(payload);
        Test.stopTest();

        System.debug('Test Result - No Drivers: ' + result);
    }

    @isTest
    static void testSaveDriverDetails_InvalidJson() {
        // Invalid JSON format
        String badJson = '[{userDetails: {Company:"MissingQuotes"}}]';

        Test.startTest();
        Map<String, Object> result = DriverDetailsFlow.saveDriverDetails(badJson);
        Test.stopTest();

        System.debug('Test Result - Invalid JSON: ' + result);
    }
}