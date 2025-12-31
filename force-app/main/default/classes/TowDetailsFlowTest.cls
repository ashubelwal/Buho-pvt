@isTest
private class TowDetailsFlowTest {

    @isTest
    static void testSaveTowDetails_withLeadId() {
        // Step 1: Create a test Lead
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'john.doe@example.com'
        );
        insert testLead;

        // Step 2: Prepare towDetails and userDetails in required JSON structure
        Map<String, Object> userDetails = new Map<String, Object>{
            'Id' => testLead.Id,
            'Email' => testLead.Email
        };

        Map<String, Object> towDetail = new Map<String, Object>{
            'Towed_Unit_Type__c' => 'Trailer',
            'Towed_Unit_Value__c' => 15000,
            'Days_in_Tow__c' => 3,
            'Year__c' => '2020',
            'Make__c' => 'Ford',
            'Model__c' => 'F-150',
            'VIN_Number__c' => '1FTFW1ET1EFA12345',
            'Plate__c' => 'ABC1234'
        };

        List<Object> towDetailsList = new List<Object>{ towDetail };

        List<Object> fullPayload = new List<Object>{
            new Map<String, Object>{
                'userDetails' => userDetails,
                'towDetails' => towDetailsList
            }
        };

        // Step 3: Serialize to JSON string
        String jsonPayload = JSON.serialize(fullPayload);

        // Step 4: Call the method
        Test.startTest();
        Map<String, Object> response = TowDetailsFlow.saveTowDetails(jsonPayload);
        Test.stopTest();

        // Step 5: Assert the results
        System.assertEquals('Success', response.get('Status'), 'Expected successful save');
        System.assertEquals('Tow details saved successfully.', response.get('Message'));

        Lead updatedLead = [SELECT Towing__c, Is_Towing__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, updatedLead.Is_Towing__c, 'Lead should be marked as towing');
        System.assertNotEquals(null, updatedLead.Towing__c, 'Towing details should be stored');
    }

    @isTest
    static void testSaveTowDetails_withMissingEmail() {
        // Test with missing email and no lead ID

        Map<String, Object> userDetails = new Map<String, Object>{};
        Map<String, Object> towDetail = new Map<String, Object>{
            'Towed_Unit_Type__c' => 'Truck'
        };

        List<Object> towDetailsList = new List<Object>{ towDetail };

        List<Object> fullPayload = new List<Object>{
            new Map<String, Object>{
                'userDetails' => userDetails,
                'towDetails' => towDetailsList
            }
        };

        String jsonPayload = JSON.serialize(fullPayload);

        Test.startTest();
        Map<String, Object> response = TowDetailsFlow.saveTowDetails(jsonPayload);
        Test.stopTest();

        System.assertEquals('Error', response.get('Status'));
        System.assertEquals('Lead record not found. Email is required.', response.get('Message'));
    }

    @isTest
    static void testSaveTowDetails_withInvalidJson() {
        // Pass blank string to test no data path
        Test.startTest();
        Map<String, Object> response = TowDetailsFlow.saveTowDetails('');
        Test.stopTest();

        System.assertEquals('Error', response.get('Status'));
        System.assertEquals('No data found.', response.get('Message'));
    }

}