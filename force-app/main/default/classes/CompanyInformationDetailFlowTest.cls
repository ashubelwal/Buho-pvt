@isTest
private class CompanyInformationDetailFlowTest {
    
    @isTest
    static void testSaveCompanyInformationWithValidLeadId() {
        // Step 1: Create a test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'sdfsdu@sdff.com',
            Company = 'Test Company'
        );
        insert testLead;

        // Step 2: Prepare sample companyInformation JSON
        Map<String, Object> userDetails = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Lead',
            'Email' => testLead.Email,
            'Company' => testLead.Company,
            'Id' => testLead.Id
        };

        Map<String, Object> companyInfo = new Map<String, Object>{
            'Company_Name__c' => 'wfwef',
            'Company_Phone__c' => 'wefewf',
            'Tax_ID__c' => 'wefewf',
            'Company_Country__c' => 'United States',
            'Company_Address__c' => 'sdsfsdfdsf',
            'Company_Zip__c' => '123213',
            'Company_State__c' => 'dssdf',
            'Company_City__c' => 'sfdsfdsf'
        };

        Map<String, Object> driverDetails = new Map<String, Object>{
            'companyInformation' => companyInfo
        };

        List<Object> requestPayload = new List<Object>{
            new Map<String, Object>{ 'userDetails' => userDetails },
            new Map<String, Object>{ 'driverDetails' => driverDetails }
        };

        String jsonInput = JSON.serialize(requestPayload);

        // Step 3: Call the method
        Test.startTest();
        Map<String, Object> response = CompanyInformationDetailFlow.saveCompanyInformationDetails(jsonInput);
        Test.stopTest();

        // Step 4: Verify response
        System.debug('Response: ' + response);
        System.debug('Updated Lead: ' + [SELECT Company_details__c FROM Lead WHERE Id = :testLead.Id].Company_details__c);
    }

    @isTest
    static void testSaveCompanyInformationWithMissingLeadId() {
        // Setup userDetails with no Id
        Map<String, Object> userDetails = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'NoID',
            'Email' => 'notfound@example.com',
            'Company' => 'No Company'
        };

        Map<String, Object> driverDetails = new Map<String, Object>{
            'companyInformation' => new Map<String, Object>{
                'Company_Name__c' => 'wfwef'
            }
        };

        List<Object> requestPayload = new List<Object>{
            new Map<String, Object>{ 'userDetails' => userDetails },
            new Map<String, Object>{ 'driverDetails' => driverDetails }
        };

        String jsonInput = JSON.serialize(requestPayload);

        Test.startTest();
        Map<String, Object> response = CompanyInformationDetailFlow.saveCompanyInformationDetails(jsonInput);
        Test.stopTest();

        System.debug('Response for missing lead: ' + response);
    }

    @isTest
    static void testSaveCompanyInformationWithEmptyPayload() {
        Test.startTest();
        Map<String, Object> response = CompanyInformationDetailFlow.saveCompanyInformationDetails('');
        Test.stopTest();

        System.debug('Response for empty payload: ' + response);
    }

    @isTest
    static void testSaveCompanyInformationWithMalformedJSON() {
        Test.startTest();
        try {
            CompanyInformationDetailFlow.saveCompanyInformationDetails('{badJson}');
        } catch (Exception e) {
            System.debug('Expected error from malformed JSON: ' + e.getMessage());
        }
        Test.stopTest();
    }
}