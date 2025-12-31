@isTest
public class MapfreMotorcycleTest {
    @isTest
    static void testMethodOne(){
        try{
            
            
           /*MapfreMotorcycle.calculatePhysicalDamage(20.00,20,20.00);
            MapfreMotorcycle.calculateMaxCoverageAddOns(20.00,20,20.00);
            MapfreMotorcycle.calculateDeductiblesPhysicalDamage(20.00);
            MapfreMotorcycle.calculateTotalTheft(20.00,20,20.00);
            MapfreMotorcycle.calculateDeductiblesTotalTheft(20.00);
            MapfreMotorcycle.calculateLiability(20.00,20,20.00);
            MapfreMotorcycle.calculateMedicalPayments(20.00,20,20.00);
            MapfreMotorcycle.calculateLegalAssist(20,20.00,20.00); 
            MapfreMotorcycle.calculateTravelAssistance(20,20.00,20.00);
            MapfreMotorcycle.calculateLiabilityOnlyTotal(20,20.00,20.00,20.00,20.00);
            MapfreMotorcycle.calculatelimitedcoveragetotal(20.00,20.00,20.00,20.00,20);
            MapfreMotorcycle.calculatefullcoveragetotal(20.00,20.00,20.00,20.00,20.00,20,20.00);
            MapfreMotorcycle.calculateMaxcoveragetotal(20.00,20.00,20.00,20.00);*/
            
            
            Rate_Table__c rateTable = new Rate_Table__c();
            rateTable.Risk_1_Physical_Damages__c = 0.6315;
            rateTable.Risk_2_Total_Theft__c = 0.2665;
            rateTable.Underwriter__c = 'Mapfre';
            rateTable.type__c = 'Motorcycle';
            rateTable.High_Value__c = 5000;
            rateTable.Low_Value__c = 5000;
            insert rateTable;
            
            Rate_Table__c ratesTable2 = new Rate_Table__c();
            ratesTable2.Risk_1_Physical_Damages__c = 1.2087;
            ratesTable2.Risk_2_Total_Theft__c = 0.5610;
            ratesTable2.Underwriter__c = 'Mapfre';
            ratesTable2.type__c = 'Motorcycle';
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
                    discountObj.No_of_Days__c = 365; 
                } else {
                    discountObj.No_of_Days__c = 4; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
            
            MapfreMotorcycle.calculate('Motorcycle',5000, 25, 100000, '$4,000/$20,000', 'Motorcycle',TestDataService.createtowed());
            MapfreMotorcycle.calculate(null,null, null, null, null, null,null);
            Mex_MapfreMotorcycle.calculate('Motorcycle',5000, 25, 100000, '$4,000/$20,000', 'Motorcycle',TestDataService.createtowed());
            Mex_MapfreMotorcycle.calculate(null,null, null, null, null, null,null);
        }catch(exception ex){
            system.debug('exception'+ ex.getMessage()+'at'+ex.getLineNumber());
            
            
        }
        
    }
}