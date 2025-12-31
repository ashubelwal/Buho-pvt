@isTest
public class QualitasRVTest {
    @isTest
    static void testMethodOne(){
        try {
            Rate_Table__c ratesObj = new Rate_Table__c();
            ratesObj.Risk_1_Physical_Damages__c = 2.27;
            ratesObj.Risk_2_Total_Theft__c = 1.13;
            ratesObj.Underwriter__c = 'Qualitas';
            ratesObj.type__c = 'RV';
            ratesObj.High_Value__c = 10000;
            ratesObj.Low_Value__c = 10000;
            
            insert ratesObj;
            
            Rate_Table__c ratesTable2 = new Rate_Table__c();
            ratesTable2.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable2.Risk_2_Total_Theft__c = 0.5610;
            ratesTable2.Underwriter__c = 'Qualitas';
            ratesTable2.type__c = 'RV';
            ratesTable2.High_Value__c = 1000;
            ratesTable2.Low_Value__c = 1000;
            
            insert ratesTable2;
            
            QualitasRV.calculate('RV', 10000.00, 20, 100000, '$3,000/$15,000', TestDataService.createtowed(), 25.00, false, true);
            Mex_QualitasRV.calculate('Baja/Sonora','RV', 10000.00, 20, 100000, '$3,000/$15,000', TestDataService.createtowed(), 25.00, false, true);
        } catch (exception ex) {
            System.debug('exception'+ ex.getMessage()+'at'+ex.getLineNumber());
        }
    }
}