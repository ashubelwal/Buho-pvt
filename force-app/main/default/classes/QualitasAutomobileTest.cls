@isTest
public class QualitasAutomobileTest {
	@isTest
    public static void testMethodOne(){
        
        Rate_Table__c rateTable = new Rate_Table__c();
            rateTable.Risk_1_Physical_Damages__c = 0.6315;
            rateTable.Risk_2_Total_Theft__c = 0.2665;
            rateTable.Underwriter__c = 'Qualitas';
            rateTable.type__c = 'Automobile';
            rateTable.High_Value__c = 5000;
            rateTable.Low_Value__c     = 5000;
            insert rateTable;
        
        Rate_Table__c rateTable2 = new Rate_Table__c();
            rateTable2.Risk_1_Physical_Damages__c = 0.6315;
            rateTable2.Risk_2_Total_Theft__c = 0.2665;
            rateTable2.Underwriter__c = 'Qualitas';
            rateTable2.type__c = 'Automobile';
            rateTable2.High_Value__c = 1000;
            rateTable2.Low_Value__c     = 1000;
            insert rateTable2;
        
        QualitasAutomobile.calculate('Automobile', 5000, 24, 300000, '$10,000/$50,000', TestDataService.createtowed(), 21, true, true);
        Mex_QualitasAutomobile.calculate('Baja/Sonora','Automobile', 5000, 24, 300000, '$10,000/$50,000', TestDataService.createtowed(), 21, true, true);
    }
    
    
}