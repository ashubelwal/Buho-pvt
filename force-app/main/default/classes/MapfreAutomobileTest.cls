@isTest
public class MapfreAutomobileTest {
    @isTest
    static void testMethodOne(){
        try{
            /*MapfreAutomobile MapFre = new  MapfreAutomobile();
            MapfreAutomobile.calculatePhysicalDamage(20.00,20,20.00);
            MapfreAutomobile.calculateMaxCoverageAddOns(20.00,20,20.00);
            MapfreAutomobile.calculateDeductiblesPhysicalDamage(20.00);
            MapfreAutomobile.calculateTotalTheft(20.00,20,20.00);
            MapfreAutomobile.calculateDeductiblesTotalTheft(20.00);
            MapfreAutomobile.calculateLiability(20.00,20,20.00);
            MapfreAutomobile.calculateMedicalPayments(20.00,20,20.00);
            MapfreAutomobile.calculateLegalAssist(20,20.00,20.00); 
            MapfreAutomobile.calculateTravelAssistance(20,20.00,20.00);
            MapfreAutomobile.calculateLiabilityOnlyTotal(20,20.00,20.00,20.00,20.00);
            MapfreAutomobile.calculatelimitedcoveragetotal(20.00,20.00,20.00,20.00,20);
            MapfreAutomobile.calculatefullcoveragetotal(20.00,20.00,20.00,20.00,20.00,20,20.00);
            MapfreAutomobile.calculateMaxcoveragetotal(20.00,20.00,20.00,20.00);*/
            //MapfreAutomobile.calculate('test',5000, 25, 100000,'test','test',TestDataService.createtowed());
            MapfreAutomobile.calculateTotalTheftTowedUnit(20.00,20,20.00,20.00);
            Mex_MapfreAutomobile.calculateTotalTheftTowedUnit(20.00,20,20.00,20.00);
            
            Rate_Table__c rateTable = new Rate_Table__c();
            rateTable.Risk_1_Physical_Damages__c = 0.6315;
            rateTable.Risk_2_Total_Theft__c = 0.2665;
            rateTable.Underwriter__c = 'Mapfre';
            rateTable.type__c = 'Automobile';
            rateTable.High_Value__c = 5000;
            rateTable.Low_Value__c     = 5000;
            insert rateTable;
            
            Rate_Table__c ratesTable2 = new Rate_Table__c();
            ratesTable2.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable2.Risk_2_Total_Theft__c = 0.5610;
            ratesTable2.Underwriter__c = 'Mapfre';
            ratesTable2.type__c = 'Automobile';
            ratesTable2.High_Value__c = 1000;
            ratesTable2.Low_Value__c = 1000;
            
            insert ratesTable2;
            
            List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i <= 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 25;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else if (i == 3){
                    discountObj.No_of_Days__c = 4; 
                } else {
                    discountObj.No_of_Days__c = 365;
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
            
            
            
            MapfreAutomobile.calculate('Automobile',5000, 25, 100000, '$4,000/$20,000', 'SUV',TestDataService.createtowed()); 
            Mex_MapfreAutomobile.calculate('Automobile',5000, 25, 100000, '$4,000/$20,000', 'SUV',TestDataService.createtowed());
            MapfreAutomobile.calculate(null, null, null, null, null, null, null);
            Mex_MapfreAutomobile.calculate(null, null, null, null, null, null, null);
        }catch(exception ex){
            system.debug('exception'+ ex.getMessage()+'at'+ex.getLineNumber());
        }
        
    }
}