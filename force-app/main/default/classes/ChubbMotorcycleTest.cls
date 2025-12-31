@isTest
public class ChubbMotorcycleTest {
@isTest
    Static void testMethod1(){
         Test.startTest();
           Rate_Table__c ratesTable = new Rate_Table__c();
            ratesTable.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable.Risk_2_Total_Theft__c = 0.5610;
            ratesTable.Underwriter__c = 'Chubb';
            ratesTable.type__c = 'Motorcycle';
            ratesTable.High_Value__c = 5000;
            ratesTable.Low_Value__c = 5000;
            
            insert ratesTable;
            
            Rate_Table__c ratesTable2 = new Rate_Table__c();
            ratesTable2.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable2.Risk_2_Total_Theft__c = 0.5610;
            ratesTable2.Underwriter__c = 'Chubb';
            ratesTable2.type__c = 'Motorcycle';
            ratesTable2.High_Value__c = 10000;
            ratesTable2.Low_Value__c = 10000;
            
            insert ratesTable2;
            ChubbMotorcycle.calculate(5000.00, 25, 1000.00, '$4,000/$20,000','Baja Sonora','Motorcycle',TestDataService.createtowed());
       		Mex_ChubbMotorcycle.calculate(5000.00, 25, 1000.00, '$4,000/$20,000','Baja Sonora','Motorcycle',TestDataService.createtowed());
        	ChubbMotorcycle.calculate(null, null, null, null,null,null,null);
        	Mex_ChubbMotorcycle.calculate(null, null, null, null,null,null,null);
           Test.stopTest();
    }
}