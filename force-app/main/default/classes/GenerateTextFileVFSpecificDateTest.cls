@IsTest
public class GenerateTextFileVFSpecificDateTest {
    @testSetup
    public static void setup(){
        Datetime yesterday = Date.today().addDays(-1);
        
        Vehicle__c vehiclePolicy = new Vehicle__c();
        vehiclePolicy.Is_the_vehicle_registered_to_a_business__c = true;
        vehiclePolicy.Company_Name__c = 'Maruti'; 
        vehiclePolicy.Company_Address__c = 'Ghaziabad UP';
        vehiclePolicy.Company_City__c = 'Ghaziabad';
        vehiclePolicy.Company_Zip__c = '201307';
        vehiclePolicy.Company_State__c = 'UP';
        vehiclePolicy.Company_Phone__c = '(098)765-4321';
        vehiclePolicy.Vehicle_Owner_Name__c = 'Test Name';
        vehiclePolicy.Vehicle_Owner_Phone__c = '(098)765-4321';
        vehiclePolicy.Vehicle_Owner_Address__c = 'Ghaziabad UP';
        vehiclePolicy.Vehicle_Owner_Postal_Code__c = '201204';
        vehiclePolicy.Vehicle_Owner_City__c = 'Ghaziabad';
        vehiclePolicy.Vehicle_Owner_Country__c = 'India';
        vehiclePolicy.Vehicle_Owner_State__c = 'UP';
        vehiclePolicy.Vehicle_Type__c = 'SUV';
        vehiclePolicy.Lienholder_Phone__c = '7089764562';
        vehiclePolicy.Lienholder_Street__c = 'Street No 4';
        vehiclePolicy.Lienholder_Street_2__c = 'Street No 5';
        vehiclePolicy.Lienholder_State__c = 'UP';
        vehiclePolicy.Lienholder_City__c = 'Ghaziabad'; 
        vehiclePolicy.Lienholder_Country__c = 'India';
        vehiclePolicy.Lienholder_name__c = 'LienHolder';
        vehiclePolicy.Year__c = '2022';
        vehiclePolicy.Vin__c = 'VIN1234NUMB';
        vehiclePolicy.Make__c = 'Maruti';
        vehiclePolicy.Registered_Plate__c = 'SDHFFFH';
        vehiclePolicy.Model__c = '2022';
        vehiclePolicy.Registered_State__c = 'UP';
        vehiclePolicy.Value__c = 3000.00;
        vehiclePolicy.Domestic_Insurance_Name__c = 'Insurancer';
        vehiclePolicy.Domestic_Insurance_Phone__c = '8967546756';
        vehiclePolicy.Domestic_Insurance_Policy__c = 'QACDF-22-1F0BC';
        insert vehiclePolicy;
        
        Watercraft__c watercraftForPolicy = new Watercraft__c();
        watercraftForPolicy.Type_of_Vessel__c = 'Sailboat';
        watercraftForPolicy.Vessel_Length__c = 'Between 45-75\' long';
        watercraftForPolicy.VIN_Number__c = 'VINNumber';
        watercraftForPolicy.Year__c = '2022';
        watercraftForPolicy.Make__c = 'Ford';
        watercraftForPolicy.Model__c = 'SUV';
        insert watercraftForPolicy;
        
        Driver__c vehicleDriver = new Driver__c();
        vehicleDriver.Name = 'Driver';
        vehicleDriver.Dob__c = date.today().addYears(-30);
        vehicleDriver.Driver_Type__c = 'Owner';
        insert vehicleDriver;      
        
        Quote__c quoteofPolicy = new Quote__c();
        quoteofPolicy.Quote_Status__c = 'Policy Created';
        quoteofPolicy.Physical_Damage__c = 100.00;
        quoteofPolicy.Liability_Payment__c = 100.00;
        quoteofPolicy.Medical_Payment__c = 100.00;
        quoteofPolicy.Platinum_Endorsment__c = 100.00;
        quoteofPolicy.Total_Theft_Payment__c = 100.00;
        insert quoteofPolicy;
        
        TriggerSwitch__c triggerSwitchObj = new TriggerSwitch__c();
        triggerSwitchObj.Name = 'PolicyTrigger';
        triggerSwitchObj.Active__c = true;
        insert triggerSwitchObj;
        
        //for northbound policy
        
        Policy__c policyObject = new Policy__c();
        policyObject.Policy_Type_picklist__c = 'Northbound';
        policyObject.Chubb_Policy_Number__c = 'NZ 42339002';
        policyObject.Underwriter_picklist__c = 'Chubb';
        policyObject.Vehicle_Policy__c = vehiclePolicy.Id;
        policyObject.Vehicle_type__c = 'SUV';
        policyObject.Status_picklist__c = 'Active';
        policyObject.Name = 'QACDF-22-1F0BC';
        policyObject.Created_At__c = Date.today().addDays(-4);
        policyObject.CreatedDate = Date.today().addDays(-1);
        policyObject.Issued_At__c = Date.today().addDays(-4);
        policyObject.End_at__c = Date.today().addDays(4);
        policyObject.Start_at__c = Date.today().addDays(-4);
        policyObject.Start_Time__c = Time.newInstance(1, 2, 3, 0);
        policyObject.End_Time__c = Time.newInstance(2, 3, 4, 0);
        policyObject.End_Date__c = Date.today().addDays(4);
        policyObject.Insured_value__c = 300.00;
        policyObject.Vehicle_deductible_comprehensive__c = 'deductible';
        policyObject.Territory_picklist__c = 'Baja/Sonora';
        policyObject.Updated_At__c = Date.today();
        policyObject.Surcharge__c = 16.02;
        policyObject.Net_Premium__c = 214.05;
        policyObject.Policy_Fee__c = 15.00;
        policyObject.Broker_Policy_Fee__c = 15.00;
        policyObject.Total_Transaction_Amount__c = 255.18;
        policyObject.Liability_picklist__c = '300,000';
        policyObject.Vehicle_deductible_collision__c = '500';
        policyObject.Under_21__c = 'No';
        policyObject.Watercraft__c = watercraftForPolicy.Id;
        policyObject.Quote_c__c = quoteofPolicy.Id;
        policyObject.Medical_picklist__c = '10,000/50,000';
        policyObject.I_V_A_Mex_Tax__c = 34.248;
        policyObject.Term_days__c = 123;
        policyObject.Package__c = 'Complete';
        policyObject.Start_Date__c = Date.today().addDays(-4);
        insert policyObject;
        
        Test.setCreatedDate(policyObject.Id, yesterday);
        
        Quote_Driver__c quoteDriver = new Quote_Driver__c();
        quoteDriver.Quote_c__c = quoteofPolicy.Id;
        quoteDriver.Driver__c = vehicleDriver.Id;
        quoteDriver.Policy__c = policyObject.Id;
        quoteDriver.Primary_insured__c = true;
        insert quoteDriver;
        
        Transaction__c policyTransactions = new Transaction__c();
        policyTransactions.Id__c = 'TransactionId';
        policyTransactions.Name = 'Transaction';
        policyTransactions.Policy_Transaction__c = policyObject.Id;
        insert policyTransactions;
        
        Towed_Unit__c towedUnit = new Towed_Unit__c();
        towedUnit.Towed_Unit_Type__c = 'Utility/Misc Trailer';
        towedUnit.Towed_Unit_Value__c = 200.00;
        insert towedUnit;
        
        Quote__c quote = new Quote__c();
        quote.Policy_Type__c = 'Northbound';
        quote.Quote_Status__c = 'Draft';
        insert quote;
        
        Quote_Towed_Unit__c quoteTowed = new Quote_Towed_Unit__c();
        quoteTowed.Towed_Unit__c = towedUnit.Id;
        quoteTowed.Policy__c = policyObject.Id;
        quoteTowed.Quote_c__c = quote.Id;
        insert quoteTowed;
        
        // If coverage is Liability
        Policy__c policyObject0 = new Policy__c();
        policyObject0.Policy_Type_picklist__c = 'Northbound';
        policyObject0.Chubb_Policy_Number__c = 'NZ 42339002';
        policyObject0.Underwriter_picklist__c = 'Chubb';
        policyObject0.Vehicle_Policy__c = vehiclePolicy.Id;
        policyObject0.Vehicle_type__c = 'SUV';
        policyObject0.Status_picklist__c = 'Active';
        policyObject0.Name = 'QACDF-22-1F0BC';
        policyObject0.Created_At__c = Date.today().addDays(-4);
        policyObject0.CreatedDate = Date.today().addDays(-1);
        policyObject0.Issued_At__c = Date.today().addDays(-4);
        policyObject0.End_at__c = Date.today().addDays(4);
        policyObject0.Start_at__c = Date.today().addDays(-4);
        policyObject0.Start_Time__c = Time.newInstance(1, 2, 3, 0);
        policyObject0.End_Time__c = Time.newInstance(2, 3, 4, 0);
        policyObject0.End_Date__c = Date.today().addDays(4);
        policyObject0.Insured_value__c = 300.00;
        policyObject0.Vehicle_deductible_comprehensive__c = 'deductible';
        policyObject0.Territory_picklist__c = 'Baja/Sonora';
        policyObject0.Updated_At__c = Date.today();
        policyObject0.Surcharge__c = 16.02;
        policyObject0.Net_Premium__c = 214.05;
        policyObject0.Policy_Fee__c = 15.00;
        policyObject0.Broker_Policy_Fee__c = 15.00;
        policyObject0.Total_Transaction_Amount__c = 255.18;
        policyObject0.Liability_picklist__c = '300,000';
        policyObject0.Vehicle_deductible_collision__c = '500';
        policyObject0.Under_21__c = 'No';
        policyObject0.Watercraft__c = watercraftForPolicy.Id;
        policyObject0.Quote_c__c = quoteofPolicy.Id;
        policyObject0.Medical_picklist__c = '10,000/50,000';
        policyObject0.I_V_A_Mex_Tax__c = 34.248;
        policyObject0.Term_days__c = 123;
        policyObject0.Package__c = 'Liability';
        policyObject0.Start_Date__c = Date.today().addDays(-4);
        insert policyObject0;
        
        Test.setCreatedDate(policyObject0.Id, yesterday);
        
        Quote_Towed_Unit__c quoteTowed0 = new Quote_Towed_Unit__c();
        quoteTowed0.Towed_Unit__c = towedUnit.Id;
        quoteTowed0.Policy__c = policyObject0.Id;
        quoteTowed0.Quote_c__c = quote.Id;
        insert quoteTowed0;
        
        //for southbound policy
        
        Policy__c policyObject2 = new Policy__c();
        policyObject2.Policy_Type_picklist__c = 'Automobile';
        policyObject2.Chubb_Policy_Number__c = 'NZ 42339002';
        policyObject2.Underwriter_picklist__c = 'Chubb';        
        policyObject2.Vehicle_Policy__c = vehiclePolicy.Id;
        policyObject2.Vehicle_type__c = 'SUV';
        policyObject2.Status_picklist__c = 'Active';
        policyObject2.Name = 'QACDF-22-1F0BC';
        policyObject2.Created_At__c = Date.today().addDays(-4);
        policyObject2.CreatedDate = Date.today().addDays(-1);
        policyObject2.Issued_At__c = Date.today().addDays(-4);
        policyObject2.End_at__c = Date.today().addDays(4);
        policyObject2.Start_at__c = Date.today().addDays(-4);
        policyObject2.Start_Time__c = Time.newInstance(1, 2, 3, 0);
        policyObject2.End_Time__c = Time.newInstance(2, 3, 4, 0);
        policyObject2.End_Date__c = Date.today().addDays(4);
        policyObject2.Insured_value__c = 300.00;
        policyObject2.Vehicle_deductible_comprehensive__c = 'deductible';
        policyObject2.Territory_picklist__c = 'Baja/Sonora';
        policyObject2.Updated_At__c = Date.today();
        policyObject2.Surcharge__c = 16.02;
        policyObject2.Net_Premium__c = 214.05;
        policyObject2.Policy_Fee__c = 15.00;
        policyObject2.Broker_Policy_Fee__c = 15.00;
        policyObject2.Total_Transaction_Amount__c = 255.18;
        policyObject2.Liability_picklist__c = '300,000';
        policyObject2.Vehicle_deductible_collision__c = '500';
        policyObject2.Under_21__c = 'No';
        policyObject2.Watercraft__c = watercraftForPolicy.Id;
        policyObject2.Quote_c__c = quoteofPolicy.Id;
        policyObject2.Medical_picklist__c = '10,000/50,000';
        policyObject2.I_V_A_Mex_Tax__c = 34.248;
        policyObject2.Term_days__c = 123;
        policyObject2.Package__c = 'Complete';
        policyObject2.Start_Date__c = Date.today().addDays(-4);
        insert policyObject2;
        
        Test.setCreatedDate(policyObject2.Id, yesterday);
        
        Quote_Driver__c quoteDriver2 = new Quote_Driver__c();
        quoteDriver2.Quote_c__c = quoteofPolicy.Id;
        quoteDriver2.Driver__c = vehicleDriver.Id;
        quoteDriver2.Policy__c = policyObject2.Id;
        quoteDriver2.Primary_insured__c = true;
        insert quoteDriver2;
        
        Transaction__c policyTransactions2 = new Transaction__c();
        policyTransactions2.Id__c = 'TransactionId';
        policyTransactions2.Name = 'Transaction';
        policyTransactions2.Policy_Transaction__c = policyObject2.Id;
        insert policyTransactions2;
        
        Towed_Unit__c towedUnit2 = new Towed_Unit__c();
        towedUnit2.Towed_Unit_Type__c = 'Utility/Misc Trailer';
        towedUnit2.Towed_Unit_Value__c = 200.00;
        insert towedUnit2;
        
        Quote__c quote2 = new Quote__c();
        quote2.Policy_Type__c = 'Southbound';
        quote2.Quote_Status__c = 'Draft';
        insert quote2;
        
        Quote_Towed_Unit__c quoteTowed2 = new Quote_Towed_Unit__c();
        quoteTowed2.Towed_Unit__c = towedUnit2.Id;
        quoteTowed2.Policy__c = policyObject2.Id;
        quoteTowed2.Quote_c__c = quote2.Id;
        insert quoteTowed2;
        
        // If coverage is Liability
        Policy__c policyObject22 = new Policy__c();
        policyObject22.Policy_Type_picklist__c = 'Automobile';
        policyObject22.Chubb_Policy_Number__c = 'NZ 42339002';
        policyObject22.Underwriter_picklist__c = 'Chubb';
        policyObject22.Vehicle_Policy__c = vehiclePolicy.Id;
        policyObject22.Vehicle_type__c = 'SUV';
        policyObject22.Status_picklist__c = 'Active';
        policyObject22.Name = 'QACDF-22-1F0BC';
        policyObject22.Created_At__c = Date.today().addDays(-4);
        policyObject22.CreatedDate = Date.today().addDays(-1);
        policyObject22.Issued_At__c = Date.today().addDays(-4);
        policyObject22.End_at__c = Date.today().addDays(4);
        policyObject22.Start_at__c = Date.today().addDays(-4);
        policyObject22.Start_Time__c = Time.newInstance(1, 2, 3, 0);
        policyObject22.End_Time__c = Time.newInstance(2, 3, 4, 0);
        policyObject22.End_Date__c = Date.today().addDays(4);
        policyObject22.Insured_value__c = 300.00;
        policyObject22.Vehicle_deductible_comprehensive__c = 'deductible';
        policyObject22.Territory_picklist__c = 'Baja/Sonora';
        policyObject22.Updated_At__c = Date.today();
        policyObject22.Surcharge__c = 16.02;
        policyObject22.Net_Premium__c = 214.05;
        policyObject22.Policy_Fee__c = 15.00;
        policyObject22.Broker_Policy_Fee__c = 15.00;
        policyObject22.Total_Transaction_Amount__c = 255.18;
        policyObject22.Liability_picklist__c = '300,000';
        policyObject22.Vehicle_deductible_collision__c = '500';
        policyObject22.Under_21__c = 'No';
        policyObject22.Watercraft__c = watercraftForPolicy.Id;
        policyObject22.Quote_c__c = quoteofPolicy.Id;
        policyObject22.Medical_picklist__c = '10,000/50,000';
        policyObject22.I_V_A_Mex_Tax__c = 34.248;
        policyObject22.Term_days__c = 123;
        policyObject22.Package__c = 'Liability';
        policyObject22.Start_Date__c = Date.today().addDays(-4);
        insert policyObject22;
        
        Test.setCreatedDate(policyObject22.Id, yesterday);
        
        Quote_Towed_Unit__c quoteTowed22 = new Quote_Towed_Unit__c();
        quoteTowed22.Towed_Unit__c = towedUnit2.Id;
        quoteTowed22.Policy__c = policyObject22.Id;
        quoteTowed22.Quote_c__c = quote2.Id;
        insert quoteTowed22;
        
        //for watercraft policy
        
        Policy__c policyObject3 = new Policy__c();
        policyObject3.Policy_Type_picklist__c = 'Watercraft';
        policyObject3.Chubb_Policy_Number__c = 'NZ 42339002';
        policyObject3.Underwriter_picklist__c = 'Chubb';
        policyObject3.Vehicle_Policy__c = vehiclePolicy.Id;
        policyObject3.Vehicle_type__c = 'SUV';
        policyObject3.Status_picklist__c = 'Active';
        policyObject3.Name = 'QACDF-22-1F0BC';
        policyObject3.Created_At__c = Date.today().addDays(-4);
        policyObject3.CreatedDate = Date.today().addDays(-1);
        policyObject3.Issued_At__c = Date.today().addDays(-4);
        policyObject3.End_at__c = Date.today().addDays(4);
        policyObject3.Start_at__c = Date.today().addDays(-4);
        policyObject3.Start_Time__c = Time.newInstance(1, 2, 3, 0);
        policyObject3.End_Time__c = Time.newInstance(2, 3, 4, 0);
        policyObject3.End_Date__c = Date.today().addDays(4);
        policyObject3.Insured_value__c = 300.00;
        policyObject3.Vehicle_deductible_comprehensive__c = 'deductible';
        policyObject3.Territory_picklist__c = 'Baja/Sonora';
        policyObject3.Updated_At__c = Date.today();
        policyObject3.Surcharge__c = 16.02;
        policyObject3.Net_Premium__c = 214.05;
        policyObject3.Policy_Fee__c = 15.00;
        policyObject3.Broker_Policy_Fee__c = 15.00;
        policyObject3.Total_Transaction_Amount__c = 255.18;
        policyObject3.Liability_picklist__c = '300,000';
        policyObject3.Vehicle_deductible_collision__c = '500';
        policyObject3.Under_21__c = 'No';
        policyObject3.Watercraft__c = watercraftForPolicy.Id;
        policyObject3.Quote_c__c = quoteofPolicy.Id;
        policyObject3.Medical_picklist__c = '10,000/50,000';
        policyObject3.I_V_A_Mex_Tax__c = 34.248;
        policyObject3.Term_days__c = 123;
        policyObject3.Package__c = 'Complete';
        policyObject3.Start_Date__c = Date.today().addDays(-4);
        insert policyObject3;
        
        Test.setCreatedDate(policyObject3.Id, yesterday);
        
        Quote_Driver__c quoteDriver3 = new Quote_Driver__c();
        quoteDriver3.Quote_c__c = quoteofPolicy.Id;
        quoteDriver3.Driver__c = vehicleDriver.Id;
        quoteDriver3.Policy__c = policyObject3.Id;
        quoteDriver3.Primary_insured__c = true;
        insert quoteDriver3;
        
        Transaction__c policyTransactions3 = new Transaction__c();
        policyTransactions3.Id__c = 'TransactionId';
        policyTransactions3.Name = 'Transaction';
        policyTransactions3.Policy_Transaction__c = policyObject3.Id;
        insert policyTransactions3;
        
    }
    @isTest
    public static void GenerateTextFileController_Test(){
        Policy__c policyObject2 = new Policy__c();
        policyObject2 = [SELECT Id FROM Policy__c limit 1];
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.GenerateInformationTextFile')); 
        System.currentPageReference().getParameters().put('policyType', 'Northbound');
        System.currentPageReference().getParameters().put('count', '2');
        System.currentPageReference().getParameters().put('todayDate', String.valueOf(Date.today()));
        System.currentPageReference().getParameters().put('yesterdayDate', String.valueOf(Date.today().addDays(-1)));
        GenerateTextFileVFSpecificDate GenerateTextFileVFControllerObj = new GenerateTextFileVFSpecificDate();
        
        Test.setCurrentPageReference(new PageReference('Page.GenerateInformationTextFile')); 
        System.currentPageReference().getParameters().put('policyType', 'Southbound');
        System.currentPageReference().getParameters().put('count', '2');
        System.currentPageReference().getParameters().put('todayDate', String.valueOf(Date.today()));
        System.currentPageReference().getParameters().put('yesterdayDate', String.valueOf(Date.today().addDays(-1)));
        GenerateTextFileVFSpecificDate GenerateTextFileVFControllerObj2 = new GenerateTextFileVFSpecificDate();
        
        Test.setCurrentPageReference(new PageReference('Page.GenerateInformationTextFile')); 
        System.currentPageReference().getParameters().put('policyType', 'Watercraft');
        System.currentPageReference().getParameters().put('count', '2');
        System.currentPageReference().getParameters().put('todayDate', String.valueOf(Date.today()));
        System.currentPageReference().getParameters().put('yesterdayDate', String.valueOf(Date.today().addDays(-1)));
        GenerateTextFileVFSpecificDate GenerateTextFileVFControllerObj3 = new GenerateTextFileVFSpecificDate();
        
        List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
        quoteDriversList = [SELECT Id FROM Quote_Driver__c LIMIT 1];
        
        System.assertEquals(1,quoteDriversList.size());
        Test.stopTest();
    }
}