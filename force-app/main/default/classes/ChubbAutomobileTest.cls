@isTest
public class ChubbAutomobileTest {
    @isTest
    static void testMethod1(){
           Test.startTest();
           Rate_Table__c ratesTable = new Rate_Table__c();
            ratesTable.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable.Risk_2_Total_Theft__c = 0.5610;
            ratesTable.Underwriter__c = 'Chubb';
            ratesTable.type__c = 'Automobile';
            ratesTable.High_Value__c = 1000;
            ratesTable.Low_Value__c = 1000;
            
            insert ratesTable;
            
            Rate_Table__c ratesTable2 = new Rate_Table__c();
            ratesTable2.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable2.Risk_2_Total_Theft__c = 0.5610;
            ratesTable2.Underwriter__c = 'Chubb';
            ratesTable2.type__c = 'Automobile';
            ratesTable2.High_Value__c = 7000;
            ratesTable2.Low_Value__c = 7000;
            
            insert ratesTable2;
        ChubbAutomobile.calculate(7000.00, 365, 300000.00, '$4,000/$20,000', 'Baja Sonora', 'Automobile', TestDataService.createtowed());
        Mex_ChubbAutomobile.calculate(7000.00, 365, 300000.00, '$4,000/$20,000', 'Baja Sonora', 'Automobile', TestDataService.createtowed());
        ChubbAutomobile.calculate(null, null,null, null, null,null, null);
        Mex_ChubbAutomobile.calculate(null, null,null, null, null,null, null);
           Test.stopTest();
    }
}