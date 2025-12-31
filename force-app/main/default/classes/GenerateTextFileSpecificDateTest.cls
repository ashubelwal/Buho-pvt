@IsTest
public class GenerateTextFileSpecificDateTest {
    @testSetup
    public static void setup(){
        Date yesterdayDate = Date.today().addDays(-1);
        
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
        insert quoteofPolicy;
        
        TriggerSwitch__c triggerSwitchObj = new TriggerSwitch__c();
        triggerSwitchObj.Name = 'PolicyTrigger';
        triggerSwitchObj.Active__c = true;
        insert triggerSwitchObj;
        
        Policy__c policyObject = new Policy__c();
        policyObject.Policy_Type_picklist__c = 'Northbound';
        policyObject.Chubb_Policy_Number__c = 'NZ 42339002';
        policyObject.Vehicle_Policy__c = vehiclePolicy.Id;
        policyObject.Vehicle_type__c = 'SUV';
        policyObject.Status_picklist__c = 'Active';
        policyObject.Name = 'Policies_Attachment_Records';
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
        policyObject.Start_Date__c = Date.today().addDays(-4);
        insert policyObject;
        
        Test.setCreatedDate(policyObject.Id, yesterdayDate);
        
        Quote_Driver__c quoteDriver = new Quote_Driver__c();
        quoteDriver.Quote_c__c = quoteofPolicy.Id;
        quoteDriver.Driver__c = vehicleDriver.Id;
        quoteDriver.Policy__c = policyObject.Id;
        quoteDriver.Primary_insured__c = true;
        insert quoteDriver;
    }
    @isTest
    public static void generateTextFileBatchTestMethod(){
        Test.startTest();
        GenerateTextFileSpecificDate eventbriteBatchObj = new GenerateTextFileSpecificDate(Date.today(), Date.today().addDays(-1));
        Id batchId = Database.executeBatch(eventbriteBatchObj);
        
        List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
        quoteDriversList = [SELECT Id FROM Quote_Driver__c];
        
        System.assertEquals(1,quoteDriversList.size());
        Test.stopTest();
    }
}