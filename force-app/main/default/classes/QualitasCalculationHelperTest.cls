@isTest
public class QualitasCalculationHelperTest {
    @isTest
    public static void testmethodforcalculationQualitas(){
          List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 4; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 10;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }
            discount.Daily_Discount__c = 15.85;
            listDiscount.add(discount);
        }
        
        insert listDiscount;
        
        List<Rate_Table__c> listMotorcycleRateTable = new List<Rate_Table__c>();
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate = new Rate_Table__c();
            
            if(i == 0){
                rate.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate.Underwriter__c = 'Qualitas';
            }
            rate.Risk_1_Physical_Damages__c = 15.85;
            rate.Risk_2_Total_Theft__c = 54.25;
            rate.Type__c = 'Motorcycle';
            rate.High_Value__c = 30000;
            rate.Low_Value__c  = 30000;
            listMotorcycleRateTable.add(rate);
        }
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate = new Rate_Table__c();
            
            if(i == 0){
                rate.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate.Underwriter__c = 'Qualitas';
            }
          rate.Daily_Rate__c = 90.00;     
            rate.Annual_Rate__c = 89.00;
            rate.Semi_Annual_Rate__c = 87.23;
            rate.Daily_Rate_Total_Theft__c = 9.00;
            rate.Semi_Annual_Total_Theft__c = 56.89;
            rate.Annual_Total_Theft__c =90.12;
            rate.Risk_1_Physical_Damages__c = 15.85;
            rate.Risk_2_Total_Theft__c = 54.25;
            rate.Type__c = 'Automobile';
            rate.High_Value__c = 30000;
            rate.Low_Value__c  = 30000;
            listMotorcycleRateTable.add(rate);
        }
        insert listMotorcycleRateTable;
        system.debug('--listMotorcycleRateTable--'+listMotorcycleRateTable);
        
        string requestMotorcycleBody = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfull = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyautomobile = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullauto = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
         string requestMotorcycleBodyfullliabliauto = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
         string requestMotorcycleBodyfullliabliRV = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        
        Test.startTest();
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfull,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
         Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullauto,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
          Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullliabliauto,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullliabliRV,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Test.stopTest();
    }
    @isTest
    public static void testforsemianualMotorcycle(){
                  List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 4; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 25;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }
            discount.Daily_Discount__c = 15.85;
            listDiscount.add(discount);
        }
        
        insert listDiscount;
        
        List<Rate_Table__c> listMotorcycleRateTable = new List<Rate_Table__c>();
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate = new Rate_Table__c();
            
            if(i == 0){
                rate.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate.Underwriter__c = 'Qualitas';
            }
            rate.Daily_Rate__c = 90.00;     
            rate.Annual_Rate__c = 89.00;
            rate.Semi_Annual_Rate__c = 87.23;
            rate.Daily_Rate_Total_Theft__c = 9.00;
            rate.Semi_Annual_Total_Theft__c = 56.89;
            rate.Annual_Total_Theft__c =90.12;
            rate.Risk_1_Physical_Damages__c = 15.85;
            rate.Risk_2_Total_Theft__c = 54.25;
            rate.Type__c = 'Motorcycle';
            rate.High_Value__c = 30000;
            rate.Low_Value__c  = 30000;
            listMotorcycleRateTable.add(rate);
        }
        insert listMotorcycleRateTable;
        
        
        string requestMotorcycleBodysemi = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-07-16","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullsemi = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-07-16","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyautomobilesemi = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-07-16","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullautosemi = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-16","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullLibibiltyautosemi = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-16","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        
       Test.startTest();
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodysemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
         Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullsemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobilesemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
         Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullautosemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullLibibiltyautosemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Test.stopTest();
    }
     @isTest
    public static void testforDailyMotorcycle(){
                  List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 4; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 10;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }
            discount.Daily_Discount__c = 15.85;
            listDiscount.add(discount);
        }
        
        insert listDiscount;
        
        List<Rate_Table__c> listMotorcycleRateTable = new List<Rate_Table__c>();
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate = new Rate_Table__c();
            
            if(i == 0){
                rate.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate.Underwriter__c = 'Qualitas';
            }
            rate.Daily_Rate__c = 90.00;     
            rate.Annual_Rate__c = 89.00;
            rate.Semi_Annual_Rate__c = 87.23;
            rate.Daily_Rate_Total_Theft__c = 9.00;
            rate.Semi_Annual_Total_Theft__c = 56.89;
            rate.Annual_Total_Theft__c =90.12;
            rate.Risk_1_Physical_Damages__c = 15.85;
            rate.Risk_2_Total_Theft__c = 54.25;
            rate.Type__c = 'Motorcycle';
            rate.High_Value__c = 30000;
            rate.Low_Value__c  = 30000;
            listMotorcycleRateTable.add(rate);
        }
        insert listMotorcycleRateTable;
        
        
        string requestMotorcycleBodyDaily = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-27","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullDaily = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-27","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyautomobileDaily = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-27","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullautoDaily = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-27","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
       Test.startTest();
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyDaily,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
         Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullDaily,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobileDaily,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
         Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullautoDaily,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Test.stopTest();
    }

}