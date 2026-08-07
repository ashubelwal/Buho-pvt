@isTest
public class AffiliateControllerTest {
    @testSetup
    static void setup() {
        Contact agency = new Contact(LastName = 'Agency');
        insert agency;
        
        Contact agent = new Contact(LastName = 'Agent');
        agent.agency__c = agency.Id;
        insert agent;
        // Create test Affiliate records
        Affiliate__c affiliate1 = new Affiliate__c(
        Agency_Logo__c = 'TestLogo1',
        Agent_Id__c = 'AG001',
        Agent_Contact__c = agent.Id,
        Agency_Contact__c = agency.Id,
        Agent_Fee__c = 50,
        Agency_Id__c = 'Agency001',
        Owner_Name__c = 'Owner One',
        Owner_Photo__c = 'Photo1'
            );
        insert affiliate1;
    }
    
    @isTest
    static void testGetAffiliateUser() {
        Test.startTest();
        // Test with valid affiliate ID
        List<Affiliate__c> affiliateUserList = [SELECT Id,Affiliate_Id__c FROM Affiliate__c LIMIT 1];
        String result = AffiliateController.getAffiliateUser(affiliateUserList[0].Affiliate_Id__c);        
        // Test with invalid affiliate ID
        try {
            AffiliateController.getAffiliateUser('INVALID_ID');
        } catch (AffiliateController.MyCustomException ex) {
        }
        
        // Test with null affiliate ID
        try {
            AffiliateController.getAffiliateUser(null);
        } catch (AffiliateController.MyCustomException ex) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveLeadDetails() {
        Test.startTest();
        List<Affiliate__c> affiliateUserList = [SELECT Id,Affiliate_Id__c FROM Affiliate__c LIMIT 1];
        // Prepare a sample lead JSON
        String leadJson = '{"FirstName":"Test","LastName":"Data twlv","Email":"test55fse655e5566@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJSON = ' {"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"06:00:00","Start_Time__c":"06:00:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_sub_type__c":"Pickup Truck w or w/o Camper Shell","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJSON = '{"Coverage__c":"Complete","Vehicle_Type__c":"Car/Truck/Auto","Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Salvage_Vehicle__c":false,"Is_there_a_driver_under_21__c":false,"Value__c":"20000","Model__c":"MDX","Make__c":"Acura","Year__c":"2024","Vehicle_sub_type__c":"Automobile/Sedan","Registered_Country__c":"United States","Is_the_vehicle_registered_to_a_business__c":false,"Vin__c":"3GCPYCEF5LG352691","Registered_State__c":"Alaska","Registered_Plate__c":"TEST123","Is_Lienholder__c":false,"BusinessAddress__c":{},"Is_Account_Company_Named__c":false}';
        String towedlistJSON = '';
        String affiliateCode = affiliateUserList[0].Affiliate_Id__c;
        
        // Test valid scenario
        String result = AffiliateController.saveLeadDetails(leadJson, quoteJSON, vehicleJSON, towedlistJSON, affiliateCode);
        System.assertNotEquals(null, result);
        Lead savedLead = (Lead)JSON.deserialize(result, Lead.class);
        System.assertNotEquals(null, savedLead.Id);
        
        Lead dbLead = [SELECT Affiliate__c FROM Lead WHERE Id = :savedLead.Id];
        System.assertEquals(affiliateUserList[0].Id, dbLead.Affiliate__c);
        
        // Test with null affiliate code
        try {
            AffiliateController.saveLeadDetails(leadJson, quoteJSON, vehicleJSON, towedlistJSON, null);
        } catch (AuraHandledException ex) {
        }
        
        // Test with invalid affiliate code
        try {
            AffiliateController.saveLeadDetails(leadJson, quoteJSON, vehicleJSON, towedlistJSON, 'INVALID_CODE');
        } catch (AuraHandledException ex) {
        }
        
        Test.stopTest();
    }
}