@isTest
public class MapfreRVTest {
	@isTest
    static void testMethodOne() {
        try{

            /*MapfreRV.calculatePhysicalDamage(20.00,20,20.00);
            MapfreRV.calculateMaxCoverageAddOns(20.00,20,20.00);
            MapfreRV.calculateDeductiblesPhysicalDamage(20.00);
            MapfreRV.calculateTotalTheft(20.00,20,20.00);
            MapfreRV.calculateDeductiblesTotalTheft(20.00);
            MapfreRV.calculateLiability(20.00,20,20.00);
            MapfreRV.calculateMedicalPayments(20.00,20,20.00);
            MapfreRV.calculateLegalAssist(20,20.00,20.00);
            MapfreRV.calculateTravelAssistance(20,20.00,20.00);
            MapfreRV.calculateLiabilityOnlyTotal(20,20.00,20.00,20.00,20.00);
            MapfreRV.calculatelimitedcoveragetotal(20.00,20.00,20.00,20.00,20);
            MapfreRV.calculatefullcoveragetotal(20.00,20.00,20.00,20.00,20.00,20,20.00);
            MapfreRV.calculateMaxcoveragetotal(20.00,20.00,20.00,20.00);*/
            
            Rate_Table__c ratesTable = new Rate_Table__c();
            ratesTable.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable.Risk_2_Total_Theft__c = 0.5610;
            ratesTable.Underwriter__c = 'Mapfre';
            ratesTable.type__c = 'RV';
            ratesTable.High_Value__c = 1000;
            ratesTable.Low_Value__c = 1000;
            
            insert ratesTable;
            
            Rate_Table__c ratesTable2 = new Rate_Table__c();
            ratesTable2.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable2.Risk_2_Total_Theft__c = 0.5610;
            ratesTable2.Underwriter__c = 'Mapfre';
            ratesTable2.type__c = 'RV';
            ratesTable2.High_Value__c = 10000;
            ratesTable2.Low_Value__c = 10000;
            
            insert ratesTable2;
            
            List<Discount__c> discountList = new List<Discount__c>();
            for (integer a=0; a<=4; a++) {
                Discount__c discountObj = new Discount__c();
                if (a == 0) {
                    discountObj.No_of_Days__c = 20;
                }else if(a == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(a == 2){
                    discountObj.No_of_Days__c = 180; 
                }else if (a == 3){
                    discountObj.No_of_Days__c = 365; 
                } else {
                    discountObj.No_of_Days__c = 4;
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            insert discountList;
            
            MapfreRV.calculate('RV', 10000.00, 20, 100000, '$3,000/$15,000', 'RV', TestDataService.createtowed());
            Mex_MapfreRV.calculate('RV', 10000.00, 20, 100000, '$3,000/$15,000', 'RV', TestDataService.createtowed());
            MapfreRV.calculate(null, null, null, null, null, null, null);
            Mex_MapfreRV.calculate(null, null, null, null, null, null, null);

        } catch (exception ex) {
            system.debug('exception'+ ex.getMessage()+'at'+ex.getLineNumber());
        }
    }
}