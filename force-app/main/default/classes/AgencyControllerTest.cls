@isTest
public class AgencyControllerTest {
    
    @testSetup
    public static void testSetup(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            LastName = 'Test Last Name',
            Email = 'atul.rai+15@cloudanalogy.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = prof.Id,
            LanguageLocaleKey = 'en_US',
            Primary_color__c = 'Test Color',
            Partner_name__c = 'Test Partner Name',
            Partner_Id__c = 'Test Partner ID',
            Partner_email__c = 'test@example.com',
            Logo_URL__c = 'https://www.google.com',
            Agent_Fee__c=100.00
        );
        insert testUser;
    }
    
    @isTest
    public static void testgetAgentFeeFromUser(){
        Test.startTest();
        Decimal actualAgentFee = AgencyController.getAgentFeeFromUser(
            [SELECT Id FROM User WHERE LastName = 'Test Last Name' LIMIT 1].Id
        );
        Test.stopTest();
    }
    
    @isTest
    public static void testgetUserData(){
        Test.startTest();
        User returnedUserData = AgencyController.getUserData(
            [SELECT Id FROM User WHERE LastName = 'Test Last Name' LIMIT 1].Id
        );
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateAgentFeeFromQuote(){
        String agentFee = '100.00';
        String userId = [SELECT Id FROM User WHERE LastName = 'Test Last Name' LIMIT 1].Id;
        Test.startTest();
        AgencyController.updateAgentFeeFromQuote(agentFee, userId);
        Test.stopTest();
        User updatedUser = [SELECT Id, Agent_Fee__c FROM User WHERE Id = :userId LIMIT 1];
    }
    
    @isTest
    public static void testgetLeadId(){
        User testUser = [SELECT Id,LastName,Email FROM User WHERE LastName = 'Test Last Name' LIMIT 1];
        String jsonData = JSON.serialize(testUser);
        Test.startTest();
        String result = AgencyController.updateUserData(jsonData, testUser.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testupdatePolicyAgentAgency(){
        // Insert a trigger switch
        TriggerSwitch__c TriggerSwitch = new TriggerSwitch__c();
        TriggerSwitch.Name = 'PolicyTrigger'; 
        TriggerSwitch.Active__c = true;   
        insert TriggerSwitch;
        
        // Deserialize lead, quote and vehicle JSON
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        
        Lead getLeadData = (Lead)JSON.deserialize(leadJson, Lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJson;
        getLeadData.Vehicle_Details__c = vehicleJson;
        insert getLeadData;
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact newContact = new Contact(
            FirstName = 'Test', LastName = 'Test',
            Email = 'atul.rai+15@cloudanalogy.com',
            AccountId = acc.Id, Phone = '123456'
        );
        insert newContact;
        
        Account acc1 = new Account(Name = 'Test2');
        insert acc1;
        
        Contact newContact1 = new Contact(
            FirstName = 'Test', LastName = 'Test',
            AccountId = acc1.Id, Phone = '987665'
        );
        insert newContact1;
        
        // Convert lead to contact
        Database.LeadConvert leadConvertInst = new Database.LeadConvert();
        leadConvertInst.setLeadId(getLeadData.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
        
        String contactId = leadConvertRslt.getContactId();
        Contact testAgentContact = new Contact(
            Id = contactId,
            Agency__c = newContact.Id,
            Agent__c =  newContact1.Id
        );
        update testAgentContact;
        
        // Quote__c quoteRecord = (Quote__c)JSON.deserialize(
        //     '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Liability__c":"300,000","Medical__c":"5,000/25,000"}', 
        //     Quote__c.class
        // );
        // quoteRecord.Lead__c = getLeadData.Id;
        // insert quoteRecord;
        Quote__c quoteRecord = (Quote__c)JSON.deserialize(
            '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile-Van-Minivan","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Liability__c":"300,000","Medical__c":"5,000/25,000"}', 
            Quote__c.class
        );
        quoteRecord.Lead__c = getLeadData.Id;
        insert quoteRecord;
        
        Policy__c policyrecord = new Policy__c(
            name = 'policy',
            Quote_c__c = quoteRecord.Id,
            contact__c = contactId,
            Policy_Type_picklist__c = 'Automobile'
        );
        insert policyrecord;
        
        Test.startTest();
        List<User> userList = [SELECT Id FROM User WHERE Email = 'atul.rai+15@cloudanalogy.com' LIMIT 1];
        AgencyController.updatePolicyAgentAgency(policyrecord.Id, userList[0].Id);
        AgencyController.getLeadId((String)quoteRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testaddAgency(){
        String leadJSON = '{"checkboxValues":["Automobile","RV"],"firstName":"Test","lastName":"cewcewc","title":"wecewc","email":"HDiwiefewfug@ham.com","phone":"584-984-4898","website":"https://tey.com","company":"fewfwe","expectedMonthlyVolume":"494949494","undefined":"","comments":"oiuytfrd"}';
        AgencyController.addAgency(leadJSON);
    }
    
    @isTest
    public static void testconvertAgencyToUser(){
        Lead getLeadData = (Lead)JSON.deserialize(
            '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}', 
            Lead.class
        );
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        insert getLeadData;
        
        AgencyController.convertAgencyToUser(getLeadData.Id);
    }
    
    @isTest
    public static void testCreateAgent2(){
        Account acc1 = new Account(Name = 'Test212');
        insert acc1;
        
        Contact newContact = new Contact(FirstName = 'Test', LastName = 'Test', Phone = '987665');
        insert newContact;
        Contact newContact1 = new Contact(FirstName = 'Test1', LastName = 'Test1', Phone = '9876651');
        insert newContact1;
        
        AgencyController.convertLeadToAgent('Test', 'Test', 'Test@test12.com', '1234567890', newContact1.Id,'External');
        AgencyController.createAgentUser('Test','Test','test@test21.com','1234567890',false, newContact1.Id,newContact.Id, 'External');
    }
    
    // @isTest
    // public static void testGetAffiliateCode_WithContactAndAgency(){
    //     Contact c = new Contact(LastName='Aff Test', Email='aff@test.com', Agency__c='AgencyXYZ');
    //     insert c;
    //     User u = new User(
    //         FirstName='U1', LastName='Affiliate', Email=c.Email,
    //         Alias='aliasu1', Username='u1' + System.currentTimeMillis() + '@test.com',
    //         CommunityNickname='u1nick',
    //         ProfileId=[SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
    //         TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US',
    //         EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
    //         ContactId=c.Id
    //     );
    //     insert u;
    //     insert new Affiliate__c(Affiliate_Id__c='AFFX', Agency_Contact__c=c.Agency__c, Agent_Contact__c=c.Id);
        
    //     Test.startTest();
    //     List<Affiliate__c> result = AgencyController.getAffiliateCode(u.Id);
    //     Test.stopTest();
    //     System.assert(result.size() > 0, 'Should return at least one affiliate');
    // }
    
    @isTest
    public static void testGetAffiliateCode_WithEmailMatch(){
        Contact c = new Contact(LastName='Aff Email', Email='affemail@test.com');
        insert c;
        User u = new User(
            FirstName='U2', LastName='Affiliate', Email=c.Email,
            Alias='aliasu2', Username='u2' + System.currentTimeMillis() + '@test.com',
            CommunityNickname='u2nick',
            ProfileId=[SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US'
        );
        insert u;
        insert new Affiliate__c(Affiliate_Id__c='AFFY', Agency_Contact__c=c.Id);
        
        Test.startTest();
        List<Affiliate__c> result = AgencyController.getAffiliateCode(u.Id);
        Test.stopTest();
        System.assert(result.size() > 0, 'Should return affiliate by email match');
    }
    
    @isTest
    public static void testGetAffiliateCode_WithCustomContact(){
        Contact c = new Contact(LastName='Aff Custom');
        insert c;
        User u = new User(
            FirstName='U3', LastName='Affiliate', Email='nocontact@test.com',
            Alias='aliasu3', Username='u3' + System.currentTimeMillis() + '@test.com',
            CommunityNickname='u3nick',
            ProfileId=[SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
            Custom_ContactId__c=c.Id
        );
        insert u;
        
        Test.startTest();
        List<Affiliate__c> result = AgencyController.getAffiliateCode(u.Id);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Should return empty list if no Agency__c');
    }
    
    // @isTest
    // public static void testGetAffiliateCode_WithNullUserId(){
    //     Test.startTest();
    //     List<Affiliate__c> result = AgencyController.getAffiliateCode(null);
    //     Test.stopTest();
    //     System.assertEquals(0, result.size(), 'Should return empty list when UserId is null');
    // }
}