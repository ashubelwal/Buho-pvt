@isTest
private class VehicleDetailsFlowTest {

 @testSetup
    static void setupData() {
        // Create a Lead record to update later
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Co',
            Email = 'testlead@example.com',
            Status = 'Open - Not Contacted'
        );
        insert lead;
    }


     @isTest static void testMethod1(){
        CarApi_Config__c carApi = new CarApi_Config__c();
        carApi.Enable_Make_Finder__c = True;
        carApi.Enable_Model_Finder__c = True;
        carApi.Client_Token__c = '549baecd-b9eb-4c4f-b644-90d6d88883ca';
        carApi.Client_Secret__c  = 'd78736d1e6941b5c434f90b1d06e0222';
        
        insert carApi;
        test.startTest();
        
       // Test.setMock(HttpCalloutMock.class, new JSON2GetYearsApexMock());
        VehicleDetailsFlow.getYears();
        Test.setMock(HttpCalloutMock.class, new JSON2GetModelApexMock());
        VehicleDetailsFlow.getModels('2018', 'volkswagen');
        
        
        test.stopTest();
    }
    
    @isTest static void testMethod2(){
        
        CarApi_Config__c carApi = new CarApi_Config__c();
        carApi.Enable_Make_Finder__c = True;
        carApi.Enable_Model_Finder__c = True;
        carApi.Client_Token__c = '549baecd-b9eb-4c4f-b644-90d6d88883ca';
        carApi.Client_Secret__c  = 'd78736d1e6941b5c434f90b1d06e0222';
        insert carApi;
        
        test.startTest();
        
        // Test.setMock(HttpCalloutMock.class, new JSON2GetYearsApexMock());
        VehicleDetailsFlow.getYears();
        Test.setMock(HttpCalloutMock.class, new JSON2MakesApexMock());
        VehicleDetailsFlow.getMakes('2018');
        
        test.stopTest();
    }
    
    @isTest static void testMethod3(){
        
        CarApi_Config__c carApi = new CarApi_Config__c();
        carApi.Enable_Make_Finder__c = False;
        carApi.Enable_Model_Finder__c = False;
        carApi.Client_Token__c = '549baecd-b9eb-4c4f-b644-90d6d88883ca';
        carApi.Client_Secret__c  = 'd78736d1e6941b5c434f90b1d06e0222';
        insert carApi;
        
        test.startTest();
        
        // Test.setMock(HttpCalloutMock.class, new JSON2GetYearsApexMock());
        VehicleDetailsFlow.getYears();
        Test.setMock(HttpCalloutMock.class, new JSON2MakesApexMock());
        VehicalAPIController.getMakes('2018');
        
        Test.setMock(HttpCalloutMock.class, new JSON2GetModelApexMock());
        VehicleDetailsFlow.getModels('2018', 'volkswagen');
        
        test.stopTest();
    }
    @isTest static void testMethod35(){
        
        CarApi_Config__c carApi = new CarApi_Config__c();
        carApi.Enable_Make_Finder__c = False;
        carApi.Enable_Model_Finder__c = False;
        carApi.Client_Token__c = '549baecd-b9eb-4c4f-b644-90d6d88883ca';
        carApi.Client_Secret__c  = 'd78736d1e6941b5c434f90b1d06e0222';
        insert carApi;
        
        test.startTest();
        
        // Test.setMock(HttpCalloutMock.class, new JSON2GetYearsApexMock());
        VehicleDetailsFlow.getYears();
        Test.setMock(HttpCalloutMock.class, new JSON2MakesApexMock());
        VehicalAPIController.getMakes('208');
        
        Test.setMock(HttpCalloutMock.class, new JSON2GetModelApexMock());
        VehicleDetailsFlow.getModels('201', 'volkswagen');
        
        test.stopTest();
    }

    @isTest
    static void testGetVehicleTypesMetadata() {
        Test.startTest();
        Map<String, Object> result = VehicleDetailsFlow.getVehicleTypesMetadata();
        Test.stopTest();

        System.assertEquals('Success', result.get('Status'));
        System.assertNotEquals(null, result.get('Data'));
    }

    @isTest
    static void testSaveLeadVehicleDetails_noLeadFound() {
        Map<String, Object> userDetails = new Map<String, Object>{
            'Email' => 'nonexisting@example.com'
        };

        Map<String, Object> vehicleDetails = new Map<String, Object>{
            'Vehicle_sub_type__c' => 'SUV-Crossover',
            'Make' => 'Toyota',
            'Model' => 'RAV4'
        };

        List<Object> payload = new List<Object>{
            new Map<String, Object>{ 'userDetails' => userDetails },
            new Map<String, Object>{ 'vehicleDetails' => vehicleDetails }
        };

        String jsonPayload = JSON.serialize(payload);

        Test.startTest();
        try {
            VehicleDetailsFlow.saveLeadVehicleDetails(jsonPayload);
        } catch (Exception e) {
            System.assert(e.getMessage().containsIgnoreCase('Email is required') ||
                         e.getMessage().containsIgnoreCase('Error in creating new Lead'));
        }
        Test.stopTest();
    }

    @isTest
    static void testLeadInsertUpdate(){

      String payload = ' [{"userDetails":{"Company":"Test Company","Email":"testlead@example.com","FirstName":"dsvds","Phone":"","LastName":"dsdsf"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"10,000/50,000","Year__c":"2023","Make":"Acura","Model":"Integra","Value__c":"15000","Make__c":"Acura","Model__c":"Integra","Vehicle_sub_type__c":"Automobile-Van-Minivan"}}]';
              Test.startTest();
        try {
            VehicleDetailsFlow.saveLeadVehicleDetails(payload);
        } catch (Exception e) {
            System.assert(e.getMessage().containsIgnoreCase('Email is required') ||
                         e.getMessage().containsIgnoreCase('Error in creating new Lead'));
        }
        Test.stopTest();
    }

    @isTest
    static void testLeadInsertUpdateNoEmail(){

      String payload = ' [{"userDetails":{"Company":"Test Company","FirstName":"dsvds","Phone":"","LastName":"dsdsf"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"10,000/50,000","Year__c":"2023","Make":"Acura","Model":"Integra","Value__c":"15000","Make__c":"Acura","Model__c":"Integra","Vehicle_sub_type__c":"Automobile-Van-Minivan"}}]';
              Test.startTest();
        try {
            VehicleDetailsFlow.saveLeadVehicleDetails(payload);
        } catch (Exception e) {
            System.assert(e.getMessage().containsIgnoreCase('Email is required') ||
                         e.getMessage().containsIgnoreCase('Error in creating new Lead'));
        }
        Test.stopTest();
    }

        @isTest
    static void testLeadInsertUpdateEmailWithbadId(){

      String payload = ' [{"userDetails":{"Company":"Test Company","Email":"sdfsdu@sdff.com","FirstName":"dsvds","Phone":"","LastName":"dsdsf","Id":"00QRL00000In5k92AB"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"10,000/50,000","Year__c":"2023","Make":"Acura","Model":"Integra","Value__c":"15000","Make__c":"Acura","Model__c":"Integra","Vehicle_sub_type__c":"Automobile-Van-Minivan"}}]';
              Test.startTest();
        try {
            VehicleDetailsFlow.saveLeadVehicleDetails(payload);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    
}