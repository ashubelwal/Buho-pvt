@isTest
public class QualitasMotorcycleTest {
    @isTest
    public static void testMethodOne(){
        try{
            Rate_Table__c rateTable = new Rate_Table__c();
            rateTable.Risk_1_Physical_Damages__c = 0.6315;
            rateTable.Daily_Rate_Total_Theft__c = 0.85;
            rateTable.Semi_Annual_Total_Theft__c = 34.94;
            rateTable.Annual_Total_Theft__c = 41.56;
            rateTable.Daily_Rate__c = 0.85;
            rateTable.Semi_Annual_Rate__c = 34.94;
            rateTable.Annual_Rate__c = 41.56;
            rateTable.Risk_2_Total_Theft__c = 0.2665;
            rateTable.Underwriter__c = 'Qualitas';
            rateTable.type__c = 'Motorcycle';
            rateTable.High_Value__c = 5000;
            rateTable.Low_Value__c     = 5000;
            insert rateTable;
            
            Rate_Table__c rateTable2 = new Rate_Table__c();
            rateTable2.Risk_1_Physical_Damages__c = 0.6315;
            rateTable2.Daily_Rate_Total_Theft__c = 0.85;
            rateTable2.Semi_Annual_Total_Theft__c = 34.94;
            rateTable2.Annual_Total_Theft__c = 41.56;
            rateTable2.Daily_Rate__c = 0.85;
            rateTable2.Semi_Annual_Rate__c = 34.94;
            rateTable2.Annual_Rate__c = 41.56;
            rateTable2.Risk_2_Total_Theft__c = 0.2665;
            rateTable2.Underwriter__c = 'Qualitas';
            rateTable2.type__c = 'Motorcycle';
            rateTable2.High_Value__c = 1000;
            rateTable2.Low_Value__c     = 1000;
            insert rateTable2;
            
            QualitasMotorcycle.calculate('Motorcycle', 5000, 25,100000,'$3,000/$15,000', TestDataService.createtowed(), 21, true, true);
            Mex_QualitasMotorcycle.calculate('Baja/Sonora','Motorcycle', 5000, 25,100000,'$3,000/$15,000', TestDataService.createtowed(), 21, true, true);
        }catch(Exception ex){
            system.debug('Message : '+ ex.getMessage() + ' at line : '+ ex.getLineNumber());
        }
    }
}