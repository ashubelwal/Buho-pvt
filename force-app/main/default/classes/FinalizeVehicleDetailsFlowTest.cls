@isTest
public class FinalizeVehicleDetailsFlowTest {
    
    @testSetup
    static void setup() {
        // Create test Lead with the same ID used in the payload
        Lead testLead = new Lead(
            // Match with payload
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test Company',
            Email = 'sdfsdu@sdff.com'
        );
        insert testLead;
    }

    @isTest
    static void testSaveFinalizeVehicleDetails_Positive() {
          Lead testLead = [SELECT Id, Email FROM Lead WHERE Email = 'sdfsdu@sdff.com' LIMIT 1];

        String payload = '[{"userDetails":{"Company":"Test Company","Email":"sdfsdu@sdff.com","FirstName":"dsvds","Phone":"","LastName":"dsdsf","Id":"' + 
            testLead.Id + 
            '"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"10,000/50,000","Year__c":"2023","Make":"Acura","Model":"Integra","Value__c":"15000","Make__c":"Acura","Model__c":"Integra","Vehicle_sub_type__c":"Automobile-Van-Minivan"}},{"finalizeVehicleDetails":{"Is_Lienholder__c":true,"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"10,000/50,000","Year__c":"2023","Make":"Acura","Model":"Integra","Value__c":"15000","Make__c":"Acura","Model__c":"Integra","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vin__c":"1232333","Registered_Country__c":"United States","Registered_State__c":"Alabama","licensePlate":"HSS3443"}}]';

        Test.startTest();
        Map<String, Object> result = FinalizeVehicleDetailsFlow.saveFinalizeVehicleDetails(payload);
        Test.stopTest();

        System.assertEquals('Success', (String) result.get('Status'), 'Expected success status');
        System.assertNotEquals(null, result.get('Data'), 'Lead should be returned');
    }

    @isTest
    static void testSaveFinalizeVehicleDetails_InvalidEmail() {
        String invalidPayload = '[{"userDetails":{"Company":"Test Company","Email":"invalid@email.com","FirstName":"Test","LastName":"User"}},{"vehicleDetails":{"Coverage__c":"Complete"}},{"finalizeVehicleDetails":{"Coverage__c":"Complete"}}]';
        
        Test.startTest();
        Map<String, Object> result = FinalizeVehicleDetailsFlow.saveFinalizeVehicleDetails(invalidPayload);
        Test.stopTest();

        System.assertEquals('Error', (String) result.get('Status'), 'Expected error for missing Lead');
        System.assertEquals('No lead found and Error in creating new Lead record.', (String) result.get('Message'));
    }

    @isTest
    static void testGetCountriesAndStates() {
        Test.startTest();
        List<String> countries = FinalizeVehicleDetailsFlow.getCountries();
        List<String> states = FinalizeVehicleDetailsFlow.getStatesByCountry('United States');
        Test.stopTest();

        System.assert(!countries.isEmpty(), 'Expected at least one country');
        System.assertEquals('Alabama', states[0], 'Expected Alabama as state');
    }

    @isTest
    static void testGetStatesByCountry_EmptyInput() {
        Test.startTest();
        List<String> states = FinalizeVehicleDetailsFlow.getStatesByCountry('');
        Test.stopTest();

        System.assertEquals(0, states.size(), 'Expected no states for blank country');
    }
}