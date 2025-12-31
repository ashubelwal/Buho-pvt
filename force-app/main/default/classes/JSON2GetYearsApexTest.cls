@isTest
public class JSON2GetYearsApexTest {
    @isTest static void testMethod1(){
        CarApi_Config__c carApi = new CarApi_Config__c();
        carApi.Enable_Make_Finder__c = True;
        carApi.Enable_Model_Finder__c = True;
        carApi.Client_Token__c = '549baecd-b9eb-4c4f-b644-90d6d88883ca';
        carApi.Client_Secret__c  = 'd78736d1e6941b5c434f90b1d06e0222';
        
        insert carApi;
        test.startTest();
        
       // Test.setMock(HttpCalloutMock.class, new JSON2GetYearsApexMock());
        VehicalAPIController.getYears();
        Test.setMock(HttpCalloutMock.class, new JSON2GetModelApexMock());
        VehicalAPIController.getModels('2018', 'volkswagen');
        
        
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
        VehicalAPIController.getYears();
        Test.setMock(HttpCalloutMock.class, new JSON2MakesApexMock());
        VehicalAPIController.getMakes('2018');
        
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
        VehicalAPIController.getYears();
        Test.setMock(HttpCalloutMock.class, new JSON2MakesApexMock());
        VehicalAPIController.getMakes('2018');
        
        Test.setMock(HttpCalloutMock.class, new JSON2GetModelApexMock());
        VehicalAPIController.getModels('2018', 'volkswagen');
        
        test.stopTest();
    }
}