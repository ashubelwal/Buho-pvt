@isTest
public class Mex_QuickQuoteCommonControllerTest {
    @isTest static void postiveWatercraftTestMethod(){
        
        
        
        Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Watercraft';
        rate.Type_of_Vessel__c = 'Personal Watercraft (Jet Ski)';
        rate.Third_Party_Bodily_Injury__c = '$50,000 / $100,000';
        rate.Property_Damage_Liability__c = '$100,000';
        rate.Days__c = 10;
        rate.Trailering_Surcharge__c = 35;
        rate.IVA_Mex_Tax__c = 100;
        rate.Underwriter__c = 'Chubb';
        rate.Age_of_Vehicle_Surcharge_25_years_old__c = 10;
        rate.Age_of_Vehicle_Surcharge__c = 25; 
        rate.Age_of_Operator_Surcharge__c = 20;
        rate.Risk_3_Third_Party_Liability_Insured_Sum__c = '100,000';
        rate.Daily_Rate__c = 2.00; 
        rate.Semi_Annual_Rate__c = 2.60;
        rate.Annual_Rate__c = 3.10;
        rate.Daily_Rate_Total_Theft__c = 1.90;
        rate.Semi_Annual_Total_Theft__c = 2.10;
        rate.Annual_Total_Theft__c = 2.90;
        rate.Term__c = 'Annual';//have to take care of this and quoteObject.Policy_Type_picklist__c == 'Driver License'
        
        insert rate; 
        
        List<Coverage_Detail__c> coverageList = new List<Coverage_Detail__c>();
        for(integer i = 0; i < 3; i++){
            Coverage_Detail__c CoverageDetails = new Coverage_Detail__c();
            CoverageDetails.Policy_Type__c = 'Watercraft';
            CoverageDetails.Package__c = 'Liability';
            if(i == 0){
                CoverageDetails.Underwriter__c = 'Qualitas';
            }else if(i == 1){
                CoverageDetails.Underwriter__c = 'Chubb';
            }else if(i == 2){
                CoverageDetails.Underwriter__c = 'Mapfre';
            }
            CoverageDetails.Territory_Discount__c = 'Yes';
            coverageList.add(CoverageDetails);
        }
        
        insert coverageList;
        
        Test.startTest();
        string requestBody = '{"Policy_Type_picklist":"Watercraft","Vehicle_Type__c":"Watercraft","Type_of_Vessel__c":"Personal Watercraft (Jet Ski)","Vessel_Length__c":"","Start_Date_for_Coverage":"2023-01-04","End_Date_for_Coverage":"2024-01-04","Is_the_Maximum_Speed_more_than_50_mph__c":"No","Any_Boat_Operator_Under_22__c":"No","Is_the_owner_living_in_Mexico__c":"No","Liability__c":"200,000","Third_Party_Bodily_Injury__c":"$50,000 / $100,000","Property_Damage_Liability__c":"$100,000","Towed_Unit__c":"No"}';
        Mex_QuickQuoteCommonController.getWatercraftQuote(requestBody, true);
        Mex_QuickQuoteCommonController.getCoverageDetailForSouthbound('Watercraft');
        
        Test.stopTest();
    }
    @isTest static void postiveNorthboundTestMethod(){
        Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Northbound';
        rate.Days__c = 10;
        rate.Trailering_Surcharge__c = 35;
        rate.IVA_Mex_Tax__c = 100;
        rate.Underwriter__c = 'Chubb';
        rate.Age_of_Vehicle_Surcharge_25_years_old__c = 10;
        rate.Age_of_Vehicle_Surcharge__c = 25; 
        rate.Age_of_Operator_Surcharge__c = 20;
        rate.Risk_3_Third_Party_Liability_Insured_Sum__c = '500,000';
        rate.Direction__c = 'Northbound';
        rate.Daily_Rate__c = 2.00; 
        rate.Semi_Annual_Rate__c = 2.60;
        rate.Annual_Rate__c = 3.10;
        rate.Daily_Rate_Total_Theft__c = 1.90;
        rate.Semi_Annual_Total_Theft__c = 2.10;
        rate.Annual_Total_Theft__c = 2.90;
        rate.Term__c = 'Annual';//have to take care of this and quoteObject.Policy_Type_picklist__c == 'Driver License'
        
        insert rate; 
        
        List<Coverage_Detail__c> coverageList = new List<Coverage_Detail__c>();
        for(integer i = 0; i < 3; i++){
            Coverage_Detail__c CoverageDetails = new Coverage_Detail__c();
            CoverageDetails.Policy_Type__c = 'Northbound';
            CoverageDetails.Package__c = 'Liability';
            if(i == 0){
                CoverageDetails.Underwriter__c = 'Qualitas';
            }else if(i == 1){
                CoverageDetails.Underwriter__c = 'Chubb';
            }else if(i == 2){
                CoverageDetails.Underwriter__c = 'Mapfre';
            }
            CoverageDetails.Territory_Discount__c = 'Yes';
            coverageList.add(CoverageDetails);
        }
        
        insert coverageList;
        
        
        Test.startTest();
        string reqestBodyNorthbound = '{"Policy_Type_picklist": "Northbound","Vehicle_Type": "Northbound","Is_Towing": "No", "Is_there_a_driver_under_21": "No","Salvage_Vehicle": "No","Vehicle_used_for_Business_Purposes": "No","Is_Rental_Vehicle": "No","Vehicle_Sub_Type": "Car/Truck/Auto","Vehicle_Value": "5000","vehicle_Age": "13","driver_Age": "81","Start_Date_for_Coverage": "2023-01-04","End_Date_for_Coverage": "2024-01-04","Liability_Type": "Liability","Medical": "$5,000/$25,000","towedUnits": [{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":5000,"Days_in_Tow__c":53}]}';
        Mex_QuickQuoteCommonController.getNorthboundCoverage();
        Mex_QuickQuoteCommonController.getNorthboundQuote(reqestBodyNorthbound, '500000'); 
        Test.stopTest();
    }
    @isTest static void postiveAtuomobileTowed(){
        List<Coverage_Detail__c> coverageList = new List<Coverage_Detail__c>();
        for(integer i = 0; i < 3; i++){
            Coverage_Detail__c CoverageDetails = new Coverage_Detail__c();
            CoverageDetails.Policy_Type__c = 'Automobile';
            CoverageDetails.Package__c = 'Liability';
            if(i == 0){
                CoverageDetails.Underwriter__c = 'Qualitas';
            }else if(i == 1){
                CoverageDetails.Underwriter__c = 'Chubb';
            }else if(i == 2){
                CoverageDetails.Underwriter__c = 'Mapfre';
            }
            CoverageDetails.Territory_Discount__c = 'Yes';
            coverageList.add(CoverageDetails);
        }
        
        insert coverageList;
        
        
        
        List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 6; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 25;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }else if(i == 4){
                discount.No_of_Days__c = 53;
            }else{
                discount.No_of_Days__c = 0;
            }
            discount.Daily_Discount__c = 15.85;
            listDiscount.add(discount);
        }
        
        insert listDiscount;
        
        List<Rate_Table__c> listRateTable = new List<Rate_Table__c>();
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
            rate.Type__c = 'Automobile';
            rate.High_Value__c = 30000;
            rate.Low_Value__c  = 30000;
            rate.Daily_Rate__c = 2.00; 
            rate.Semi_Annual_Rate__c = 2.60;
            rate.Annual_Rate__c = 3.10;
            rate.Daily_Rate_Total_Theft__c = 1.90;
            rate.Semi_Annual_Total_Theft__c = 2.10;
            rate.Annual_Total_Theft__c = 2.90;
            
            listRateTable.add(rate);
        }
        insert listRateTable;
        system.debug('--listRateTable--'+listRateTable);
        
        
        
        
        
        
        
        
        string requestBody = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Automobile/Sedan","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string requestBody2 = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Automobile/Sedan","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-19","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000","towedUnits":[]}';
        
        
        Test.startTest();
        Mex_QuickQuoteCommonController.getCoverageDetailForSouthbound('Automobile');
        Mex_QuickQuoteCommonController.getExactCoverageDetailForSouthbound('Automobile','Complete');
        Mex_QuickQuoteCommonController.getExactCoverageDetailForSouthbound('Automobile','Liability');
        Mex_QuickQuoteCommonController.getExactCoverageDetailForSouthbound('Automobile','Max');
        Mex_QuickQuoteCommonController.getQuote(requestBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        
        
        
        
        
        Mex_QuickQuoteCommonController.getQuote('','300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Test.stopTest();
    }
     @isTest static void testMethodForMotorcycleIsDriver21Yes(){
        List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 8; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 25;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }else if(i == 4){
                discount.No_of_Days__c = 120;
            }
            else if(i == 5){
                discount.No_of_Days__c = 60;
            }
            else if(i == 6){
                discount.No_of_Days__c = 4;
            }else{
                discount.No_of_Days__c = 0;
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
            rate.Daily_Rate__c = 2.00; 
            rate.Semi_Annual_Rate__c = 2.60;
            rate.Annual_Rate__c = 3.10;
            rate.Daily_Rate_Total_Theft__c = 1.90;
            rate.Semi_Annual_Total_Theft__c = 2.10;
            rate.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable.add(rate);
        }
        insert listMotorcycleRateTable;
        
        
        List<Rate_Table__c> listMotorcycleRateTable1 = new List<Rate_Table__c>();
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate1 = new Rate_Table__c();
            
            if(i == 0){
                rate1.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate1.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate1.Underwriter__c = 'Qualitas';
            }
            rate1.Risk_1_Physical_Damages__c = 15.85;
            rate1.Risk_2_Total_Theft__c = 54.25;
            rate1.Type__c = 'Automobile';
            rate1.High_Value__c = 30000;
            rate1.Low_Value__c  = 30000;
            rate1.Daily_Rate__c = 2.00; 
            rate1.Semi_Annual_Rate__c = 2.60;
            rate1.Annual_Rate__c = 3.10;
            rate1.Daily_Rate_Total_Theft__c = 1.90;
            rate1.Semi_Annual_Total_Theft__c = 2.10;
            rate1.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable1.add(rate1);
        }
        insert listMotorcycleRateTable1;
        system.debug('--listMotorcycleRateTable--'+listMotorcycleRateTable);
        
        string requestMotorcycleBody = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfull = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyautomobile = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullauto = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyYear = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-21","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullsemi = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-05-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullsemi90Motor = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-03-18","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        
        string requestMotorcycleBodyautomobileSemi = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-05-18","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyautomobile90days = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-03-18","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullautodaily = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"Yes","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-21","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        
        
        Test.startTest();
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfull,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullauto,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyYear,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullsemi90Motor,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile90days,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullautodaily,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobileSemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullsemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        
        
        Test.stopTest();
    }
    @isTest static void testMethodForMotorcycle(){
        List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 8; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 25;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }else if(i == 4){
                discount.No_of_Days__c = 120;
            }
            else if(i == 5){
                discount.No_of_Days__c = 60;
            }
            else if(i == 6){
                discount.No_of_Days__c = 4;
            }else{
                discount.No_of_Days__c = 0;
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
            rate.Daily_Rate__c = 2.00; 
            rate.Semi_Annual_Rate__c = 2.60;
            rate.Annual_Rate__c = 3.10;
            rate.Daily_Rate_Total_Theft__c = 1.90;
            rate.Semi_Annual_Total_Theft__c = 2.10;
            rate.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable.add(rate);
        }
        insert listMotorcycleRateTable;
        
        
        List<Rate_Table__c> listMotorcycleRateTable1 = new List<Rate_Table__c>();
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate1 = new Rate_Table__c();
            
            if(i == 0){
                rate1.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate1.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate1.Underwriter__c = 'Qualitas';
            }
            rate1.Risk_1_Physical_Damages__c = 15.85;
            rate1.Risk_2_Total_Theft__c = 54.25;
            rate1.Type__c = 'Automobile';
            rate1.High_Value__c = 30000;
            rate1.Low_Value__c  = 30000;
            rate1.Daily_Rate__c = 2.00; 
            rate1.Semi_Annual_Rate__c = 2.60;
            rate1.Annual_Rate__c = 3.10;
            rate1.Daily_Rate_Total_Theft__c = 1.90;
            rate1.Semi_Annual_Total_Theft__c = 2.10;
            rate1.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable1.add(rate1);
        }
        insert listMotorcycleRateTable1;
        system.debug('--listMotorcycleRateTable--'+listMotorcycleRateTable);
        
        string requestMotorcycleBody = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfull = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyautomobile = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullauto = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyYear = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-21","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullsemi = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-05-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullsemi90Motor = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-03-18","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000"}';
        
        string requestMotorcycleBodyautomobileSemi = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-05-18","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyautomobile90days = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-03-18","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullautodaily = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-21","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        
        
        Test.startTest();
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfull,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullauto,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyYear,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullsemi90Motor,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile90days,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullautodaily,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobileSemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullsemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        
        
        Test.stopTest();
    }
    @istest static void testMethodForMotorcycleComplete(){
        List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 8; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 25;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }else if(i == 4){
                discount.No_of_Days__c = 120;
            }
            else if(i == 5){
                discount.No_of_Days__c = 60;
            }
            else if(i == 6){
                discount.No_of_Days__c = 4;
            }else{
                discount.No_of_Days__c = 0;
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
            rate.Daily_Rate__c = 2.00; 
            rate.Semi_Annual_Rate__c = 2.60;
            rate.Annual_Rate__c = 3.10;
            rate.Daily_Rate_Total_Theft__c = 1.90;
            rate.Semi_Annual_Total_Theft__c = 2.10;
            rate.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable.add(rate);
        }
        insert listMotorcycleRateTable;
        
        
        List<Rate_Table__c> listMotorcycleRateTable1 = new List<Rate_Table__c>();
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate1 = new Rate_Table__c();
            
            if(i == 0){
                rate1.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate1.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate1.Underwriter__c = 'Qualitas';
            }
            rate1.Risk_1_Physical_Damages__c = 15.85;
            rate1.Risk_2_Total_Theft__c = 54.25;
            rate1.Type__c = 'Automobile';
            rate1.High_Value__c = 30000;
            rate1.Low_Value__c  = 30000;
            rate1.Daily_Rate__c = 2.00; 
            rate1.Semi_Annual_Rate__c = 2.60;
            rate1.Annual_Rate__c = 3.10;
            rate1.Daily_Rate_Total_Theft__c = 1.90;
            rate1.Semi_Annual_Total_Theft__c = 2.10;
            rate1.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable1.add(rate1);
        }
        insert listMotorcycleRateTable1;
        system.debug('--listMotorcycleRateTable--'+listMotorcycleRateTable);
        
        
        
        string requestMotorcycleBodyComplete = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullComplete = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyautomobileComplete = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullautoComplete = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyYearComplete = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-21","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullsemiComplete = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-05-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullsemi90MotorComplete = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-03-18","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000"}';
        
        string requestMotorcycleBodyautomobileSemiLiblityTheft = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-05-18","Liability":"300000","Liability_Type":"LiabilityTheft","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyautomobile90daysLiblityTheft = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-03-18","Liability":"300000","Liability_Type":"LiabilityTheft","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullautodailyLiblityTheft = '{"Policy_Type_picklist":"Motorcycle/Street Legal ATV","Vehicle_Type":"Motorcycle/Street Legal ATV","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motorcycle","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-21","Liability":"300000","Liability_Type":"LiabilityTheft","Medical":"$10,000/$50,000"}';
        
        
        Test.startTest();
        
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyComplete,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullComplete,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobileComplete,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullautoComplete,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyYearComplete,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullsemiComplete,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullsemi90MotorComplete,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobileSemiLiblityTheft,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile90daysLiblityTheft,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullautodailyLiblityTheft,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        Test.stopTest();
    }
    @istest static void testMethodForAutomobileMax(){
        List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 7; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 25;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }else if(i == 4){
                discount.No_of_Days__c = 120;
            }
            else if(i == 5){
                discount.No_of_Days__c = 60;
            }
            else if(i == 6){
                discount.No_of_Days__c = 4;
            }else{
                discount.No_of_Days__c = 0;
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
            rate.Daily_Rate__c = 2.00; 
            rate.Semi_Annual_Rate__c = 2.60;
            rate.Annual_Rate__c = 3.10;
            rate.Daily_Rate_Total_Theft__c = 1.90;
            rate.Semi_Annual_Total_Theft__c = 2.10;
            rate.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable.add(rate);
        }
        insert listMotorcycleRateTable;
        
        
        List<Rate_Table__c> listMotorcycleRateTable1 = new List<Rate_Table__c>();
        for(integer i = 0; i < 3; i++){
            Rate_Table__c rate1 = new Rate_Table__c();
            
            if(i == 0){
                rate1.Underwriter__c = 'Chubb';
            }else if(i == 1){
                rate1.Underwriter__c = 'Mapfre';
            }else if(i == 2){
                rate1.Underwriter__c = 'Qualitas';
            }
            rate1.Risk_1_Physical_Damages__c = 15.85;
            rate1.Risk_2_Total_Theft__c = 54.25;
            rate1.Type__c = 'Automobile';
            rate1.High_Value__c = 30000;
            rate1.Low_Value__c  = 30000;
            rate1.Daily_Rate__c = 2.00; 
            rate1.Semi_Annual_Rate__c = 2.60;
            rate1.Annual_Rate__c = 3.10;
            rate1.Daily_Rate_Total_Theft__c = 1.90;
            rate1.Semi_Annual_Total_Theft__c = 2.10;
            rate1.Annual_Total_Theft__c = 2.90;
            listMotorcycleRateTable1.add(rate1);
        }
        insert listMotorcycleRateTable1;
        system.debug('--listMotorcycleRateTable--'+listMotorcycleRateTable);
        
        
        string requestMotorcycleBodyautomobile = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Max","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullauto = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Max","Medical":"$10,000/$50,000"}';
        
        
        string requestMotorcycleBodyautomobileSemi = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-05-18","Liability":"300000","Liability_Type":"Max","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyautomobile90days = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Limited","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-03-18","Liability":"300000","Liability_Type":"Max","Medical":"$10,000/$50,000"}';
        string requestMotorcycleBodyfullautodaily = '{"Policy_Type_picklist":"Automobile","Vehicle_Type":"Car/Truck/Auto","Territory":"Full","Is_Towing":"No","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Van","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2023-01-21","Liability":"300000","Liability_Type":"Max","Medical":"$10,000/$50,000"}';
        
        
        
        
        Test.startTest();
        
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullauto,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobile90days,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyfullautodaily,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(requestMotorcycleBodyautomobileSemi,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        
        
        Test.stopTest();
    }
    @isTest static void testMethodForRV(){
        
        List<Discount__c> listDiscount = new List<Discount__c>();
        for(integer i = 0; i < 5; i++){
            Discount__c discount = new Discount__c();
            
            if(i == 0){
                discount.No_of_Days__c = 25;
            }else if(i == 1){
                discount.No_of_Days__c = 90;
            }else if(i == 2){
                discount.No_of_Days__c = 180;
            }else if(i == 3){
                discount.No_of_Days__c = 365;
            }else if(i == 4){
                discount.No_of_Days__c = 53;
            }
            discount.Daily_Discount__c = 15.85;
            listDiscount.add(discount);
        }
        
        insert listDiscount;
        
        List<Rate_Table__c> listRVRateTable = new List<Rate_Table__c>();
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
            rate.Type__c = 'RV';
            rate.High_Value__c = 30000;
            rate.Low_Value__c  = 30000;
            rate.Daily_Rate__c = 2.00; 
            rate.Semi_Annual_Rate__c = 2.60;
            rate.Annual_Rate__c = 3.10;
            rate.Daily_Rate_Total_Theft__c = 1.90;
            rate.Semi_Annual_Total_Theft__c = 2.10;
            rate.Annual_Total_Theft__c = 2.90;
            listRVRateTable.add(rate);
        }
        insert listRVRateTable;
        system.debug('--listRVRateTable--'+listRVRateTable);
        
        
        
        string requestRVBody = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string requestRVliablityBody = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        
        Test.startTest();
        Mex_QuickQuoteCommonController.getQuote(requestRVliablityBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        //  Mex_QuickQuoteCommonController.getQuote(requestRVBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000'); 
        Test.stopTest();
    }
    @isTest static void testMethodNegative(){
        string requestRVBody = '{"Policy_Type_picklist":"RVg"}';
        string vihcletype = '{"Policy_Type_picklist":"RV", "Vehicle_Type":"RgV"}';
        string v2 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v21 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"","Territory":"Limitied","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v22 = '{"Policy_Type_picklist":"","Territory":"Limited","Is_Towing":"fg","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v23 = '{"Policy_Type_picklist":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v24 = '{"Policy_Type_picklist":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v25 = '{"Policy_Type_picklist":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[]}';
        
        string v3 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"fg","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v4 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"gj","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v5 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"jh","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v6 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"hNo","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v7 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"Nbo","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v8 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Homce / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v9 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"3y0000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v10 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v11 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":null,"Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v12 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"3j00000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v13 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Cojmplete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v14 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$5100,000/$250,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        string v15 = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limitied","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Complete","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATdvfV-UlkhgTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        
        Test.startTest();
        Mex_QuickQuoteCommonController.getQuote(requestRVBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(vihcletype,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v2,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v21,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v22,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v23,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v24,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v25,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v3,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v4,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v5,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v6,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v7,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v8,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v9,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v10,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v11,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v12,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v13,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v14,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Mex_QuickQuoteCommonController.getQuote(v15,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        
        
        
        
        Test.stopTest();
    }
    
    @isTest static void qulatiasCalculatiotest(){
        string requestRVBody = '{"Policy_Type_picklist":"RV","Vehicle_Type":"RV","Territory":"Limited","Is_Towing":"Yes","Is_there_a_driver_under_21":"No","Salvage_Vehicle":"No","Vehicle_used_for_Business_Purposes":"No","Is_Rental_Vehicle":"No","Vehicle_Sub_Type":"Motor Home / RV","Vehicle_Value":"30000","Start_Date_for_Coverage":"2023-01-17","End_Date_for_Coverage":"2024-01-17","Liability":"300000","Liability_Type":"Liability","Medical":"$10,000/$50,000","towedUnits":[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":30000,"Days_in_Tow__c":53}]}';
        Test.startTest();
        Mex_QuickQuoteCommonController.getQuote(requestRVBody,'300000' , '300000', '300000', '$10,000/$50,000', '$10,000/$50,000', '$10,000/$50,000');
        Test.stopTest();
    }
    @isTest static void testmethodLast(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        Quote__c quote = new Quote__c();
        quote.Start_Date_for_Coverage__c= system.today();
        quote.End_Date_for_Coverage__c= system.today()+5;
        quote.Driver_Age__c = 80;
        
        quote.Underwriter__c ='Chubb';
        quote.Coverage__c='Complete';
        quote.Territory__c='  Full';
        quote.Term__c='Daily';
        quote.Policy_Type_picklist__c='Northbound';
        quote.Vehicle_Type__c = 'Automobile';
        quote.Medical__c='2,000/10,000';
        quote.Liability__c='100,000'; 
        quote.Date_of_Birth__c = date.newinstance(1950,10,12);
        quote.Towed_Unit__c = 'true';
        
        String quoteRecord = JSON.serialize(quote);
        quote.Towed_Unit__c = 'Yes';
        insert quote;
        
        
        Legal_Term__c legalterm = new Legal_Term__c();
        legalterm.Terms_of_Purchase_and_Use__c = 'No';
        legalterm.Underwriter__c = 'Chubb';
        legalterm.Policy_Type__c = 'Watercraft';        
        insert legalterm;
        
        Policy__c policy = new Policy__c();
        policy.Quote_c__c = quote.Id;
        insert policy;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        Mex_QuickQuoteCommonController.getWatercraftQuote(null, false);
        Mex_QuickQuoteCommonController.getNorthboundQuote(null, '50000');
        Mex_QuickQuoteCommonController.retrieveLegalTermDetails('Watercraft', 'Chubb');
        Mex_QuickQuoteCommonController.getQuoteRecord(quote.Id);
        Mex_QuickQuoteCommonController.sendEmailDocumentAction(JSON.serialize( new set<String>{policy.Id}));
        Mex_QuickQuoteCommonController.sendEmailDocumentAction(JSON.serialize( new set<String>{}));
        Test.stopTest();
        
    }
}