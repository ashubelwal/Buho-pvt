@isTest
public class AgentAppControllerTest {
    
    private static User getUser(Boolean isAdmin) {
        String profileName = isAdmin ? 'System Administrator' : 'Standard User';
        Profile prof = [SELECT Id FROM Profile WHERE Name = :profileName];
        User testUser = new User(
            Username = 'testuser0sdcd987@example.com',
            LastName = 'Test Last Name',
            Email = 'atul.rai+1ddd5@cloudanalogy.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = prof.Id,
            LanguageLocaleKey = 'en_US',
            Primary_color__c = 'Test Color',
            Partner_name__c = 'Test Partner Name',
            Partner_Id__c = 'Test Partner ID',
            Partner_email__c = 'testdcdc@example.com',
            Logo_URL__c = 'https://www.google.com',
            Agent_Fee__c=100.00,
            User_Type__c = 'External'
        );
        insert testUser;
        return testUser;
    }
    
    @isTest
    public static void testUserExternal(){
        
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Van","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Van","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJSON;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJSON;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJSON;
        }
        
        getLeadData.Towing__c = towedJson;
        upsert getLeadData;
        
        Database.LeadConvert leadConvertInst = new Database.LeadConvert();
        leadConvertInst.setLeadId(getLeadData.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
        string contactId =leadConvertRslt.getContactId();
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];
        String userFName = getLeadData.FirstName.substring(0,1);
        String userLName = getLeadData.LastName.length() >=3 ? getLeadData.LastName.substring(0, 3):getLeadData.LastName;
        User newUser = new User(
            Username = getLeadData.Email,
            Email = getLeadData.Email,
            LastName = getLeadData.LastName,
            FirstName = getLeadData.FirstName != null ? getLeadData.FirstName : '',
            Phone = getLeadData.Phone != null ? getLeadData.Phone : '',
            Alias = (getLeadData.FirstName != null && getLeadData.LastName != null) ? userFName + ' ' + userLName : (getLeadData.FirstName == null && getLeadData.LastName != null) ? userLName : '',
            contactId = leadConvertRslt.getContactId(),
            profileId = portalProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            User_Type__c= 'External'
        );
        System.debug('newUser--->'+newUser);
        Database.insert(newUser);
        
        leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        System.debug(leadJson);
        getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        
        
        getLeadData.Agent__c = leadConvertRslt.getContactId();
        getLeadData.Company='TestComp';
        upsert getLeadData;
        
        Test.StartTest();
        AgentAppController.getDataByObj('',newUser.Id);
        Test.stopTest();
    }  
    
    @isTest
    public static void testUserAgency(){
        
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Van","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Van","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJSON;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJSON;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJSON;
        }
        
        getLeadData.Towing__c = towedJson;
        upsert getLeadData;
        
        Database.LeadConvert leadConvertInst = new Database.LeadConvert();
        leadConvertInst.setLeadId(getLeadData.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
        string contactId =leadConvertRslt.getContactId();
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];
        String userFName = getLeadData.FirstName.substring(0,1);
        String userLName = getLeadData.LastName.length() >=3 ? getLeadData.LastName.substring(0, 3):getLeadData.LastName;
        User newUser = new User(
            Username = getLeadData.Email,
            Email = getLeadData.Email,
            LastName = getLeadData.LastName,
            FirstName = getLeadData.FirstName != null ? getLeadData.FirstName : '',
            Phone = getLeadData.Phone != null ? getLeadData.Phone : '',
            Alias = (getLeadData.FirstName != null && getLeadData.LastName != null) ? userFName + ' ' + userLName : (getLeadData.FirstName == null && getLeadData.LastName != null) ? userLName : '',
            contactId = leadConvertRslt.getContactId(),
            profileId = portalProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            User_Type__c= 'Agency'
        );
        System.debug('newUser--->'+newUser);
        Database.insert(newUser);
        
        leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        System.debug(leadJson);
        getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        
        
        getLeadData.Agency__c = leadConvertRslt.getContactId();
        getLeadData.Company='TestComp';
        upsert getLeadData;
        
        Test.StartTest();
        AgentAppController.getDataByObj('Test Two',newUser.Id);
        Test.stopTest();
    }  
    
    @isTest
    public static void testSaveLeadDetails() {
        
        User testUser = getUser(false);
        
        System.runAs(testUser) {
            String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile-Van-Minivan","Is_towing__c":false}';
            String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Van","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
            String vehicleJson = '{"Vehicle_sub_type__c":"Van","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
            String towedJson = '';
            
            Test.startTest();
            String result = AgentAppController.saveLeadDetails( leadJson, quoteJson, vehicleJson, towedJson);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testPurchaseSaveDetails() {
        
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data98.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile-Van-Minivan","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile-Van-Minivan","Term__c":"Semi-Annual"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJSON;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJSON;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJSON;
        }
        
        getLeadData.Towing__c = towedJson;
        upsert getLeadData;
        
        String quotes = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"06:00:00","Start_Time__c":"06:00:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":300.888,"Broker_Policy_Fee__c":15,"Term_Days__c":"180","I_V_A_Mex_Tax__c":0,"Quote_Value__c":315.888,"Surcharge__c":0,"Underwriter__c":"Chubb","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":57.29,"Total_Theft_Payment__c":57.29,"Liability_Payment__c":105.03,"Medical_Payment__c":5.11,"Platinum_Endorsment__c":94.296,"Liability__c":"500,000","Medical__c":"10,000/50,000"}';
        
        Test.startTest();
        try {
            String result = AgentAppController.purchaseSaveDetails( quotes, getLeadData.Id, true);
        } catch(Exception ex){}
        try {
            AgentAppController.purchaseSaveDetails( quotes, getLeadData.Id, false);
        } catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    public static void testPurchaseSaveDetails2() {
        
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile-Van-Minivan","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile-Van-Minivan","Term__c":"Semi-Annual"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJSON;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJSON;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJSON;
        }
        
        getLeadData.Towing__c = towedJson;
        upsert getLeadData;
        
        Database.LeadConvert leadConvertInst = new Database.LeadConvert();
        leadConvertInst.setLeadId(getLeadData.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
        string contactId =leadConvertRslt.getContactId();
        
        List<Contact> contactRecords = [SELECT Id, Watercraft_Detail__c, Vehicle_details__c, Quote_Details__c  FROM Contact Where Id = :contactId LIMIT 1];
        Contact contactRecord = contactRecords.get(0);
        Contact getContactData = new Contact();
        getContactData.Id = contactId;
        getContactData.Quote_Details__c = quoteJSON;
        if(contactRecord.Watercraft_Detail__c != null){
            getContactData.Watercraft_Detail__c = vehicleJSON;
        }else{
            getContactData.Vehicle_Details__c = vehicleJSON;
        }
        
        getContactData.Towing__c = towedJson;
        upsert getContactData;
        
        
        String quotes = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"06:00:00","Start_Time__c":"06:00:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Pickup Truck w or w/o Camper Shell","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":300.888,"Broker_Policy_Fee__c":15,"Term_Days__c":"180","I_V_A_Mex_Tax__c":0,"Quote_Value__c":315.888,"Surcharge__c":0,"Underwriter__c":"Chubb","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":57.29,"Total_Theft_Payment__c":57.29,"Liability_Payment__c":105.03,"Medical_Payment__c":5.11,"Platinum_Endorsment__c":94.296,"Liability__c":"500,000","Medical__c":"10,000/50,000"}';
        
        Test.startTest(); 
        //String result = AgentAppController.purchaseSaveDetails( quotes, getLeadData.Id, true);
        try{
        AgentAppController.purchaseSaveDetails( quotes, getContactData.Id, false);
        }catch(Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    public static void testSaveInfoBeforePayment() {
        
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Van","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJSON;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJSON;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJSON;
        }
        
        getLeadData.Towing__c = towedJson;
        upsert getLeadData;
        
        String quoteData = ' {"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"06:00:00","Start_Time__c":"06:00:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String VehicleData = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"Testh","Lienholder_Country__c":"USAa","Lienholder_Postal_Code__c":"1234567","Lienholder_State__c":"USAh","Vin__c":"SALAE24486A349448","Registered_Country__c":"Testa","Registered_State__c":"DLSP","Registered_Plate__c":"SDHFFFH222","Lienholder_City__c":"testa","Lienholder_Street__c":"Test3","Lienholder_Phone__c":123456789077","Is_Lienholder__c":true,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String termOptions = '{"Term__c":"Semi-Annual","Start_Date_for_Coverage__c":"2023-10-10","End_Date_for_Coverage__c":"2024-04-07","Start_Time__c":"06:00:00","End_Time__c":"06:00:00"}';
        String termAndAlerts = '{"Terms_of_Cancellation_Confirmed__c":"true","Terms_of_Purchase_Confirmed__c":"true"}';
        String driverData = '[{"Dob__c":"2008-10-09","First_Name__c":"Test","Last_Name__c":"Test","License_Country__c":"Test","License_state__c":"Test","license_number__c":"09876543","Driver_Type__c":"Owner & Driver","Country__c":"Test","Postal_Code__c":"","State_Province__c":"Test","City__c":"Test","Address__c":"TestAdd3","Phone__c":"1234567897","Email__c":"test@data6.com"}]';
        String towedDetails = '';
        String termsAndAlerts = '{"Terms_of_Cancellation_Confirmed__c":true,"Terms_of_Purchase_Confirmed__c":true}';
        
        
        Test.startTest();
        Boolean result = AgentAppController.saveInfoBeforePayment( getLeadData.id, quoteData, VehicleData, termAndAlerts, driverData, termOptions, towedDetails);
        Boolean result2 = AgentAppController.saveLeadDestinationInfoBeforePayment( getLeadData.id, termAndAlerts);
        Test.stopTest();
    }
    
    @isTest
    public static void testPaymentThroughCard(){
        
        String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        // Create a map with proper boolean values
        Map<String, Object> termsAndAlertsMap = new Map<String, Object>{
            'Terms_of_Cancellation_Confirmed__c' => true,
                'Terms_of_Purchase_Confirmed__c' => true
                };
                    
                    // Serialize the map into a JSON string
                    String termsAndAlerts = JSON.serialize(termsAndAlertsMap);
        System.debug(termsAndAlerts);
        String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJson;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJson;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJson;
        }
        getLeadData.Towing__c = towedJson;
        insert getLeadData;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord = (Quote__c)JSON.deserialize(quoteGenerate, Quote__c.class);
        quoteRecord.Lead__c = getLeadData.Id;
        insert quoteRecord;
        
        String transcationDetails = '{"ip":"103.113.65.58","quoteIds":["'+ quoteRecord.Id +'"]}';
        String paymentDetails = '{"Payment_Type__c":"Card","Mode__c":"New","Street__c":"Test","Country__c":"Test","State__c":"Test","City__c":"Test","Postal_Code__c":"123456","name":"Test","cardNumber":"4242424242424242","month":"01","year":"2024","code":"121"}';
        String email = '';
        
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        conObj.Phone = '796543';
        insert conObj;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        insert policyrecord;
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Id quoteId = TestDataService.createQuote(true).Id;
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteId, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        
        Test.startTest();
        AgentAppController.paymentThroughCard( transcationDetails, paymentDetails, email);
        String result2 = AgentAppController.updateContactDestinationDetails( conObj.id, termsAndAlerts);
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }
    
    @isTest
    public static void updateContactDetails(){
        
        String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJson;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJson;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJson;
        }
        getLeadData.Towing__c = towedJson;
        insert getLeadData;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord = (Quote__c)JSON.deserialize(quoteGenerate, Quote__c.class);
        quoteRecord.Lead__c = getLeadData.Id;
        insert quoteRecord;
        
        List<Lead> leadRecords = [SELECT Id, Insurance_Type__c, Vehicle_Details__c,Watercraft_Detail__c,  Quote_Details__c FROM Lead Where Id = :getLeadData.Id LIMIT 1];
        Map<String, Object> vehicleDetailsMap;
        Lead leadRecord = leadRecords.get(0);
        
        if(leadRecord.Insurance_Type__c == 'Watercraft'){
            vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Watercraft_Detail__c);
        }else{
            vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Vehicle_Details__c);
        }
        
        vehicleDetailsMap.put('Coverage__c', quoteRecord.Coverage__c);
        leadRecord.Vehicle_details__c = JSON.serialize(vehicleDetailsMap);
        leadRecord.Quote_Details__c = JSON.serialize(quoteRecord);
        update leadRecord;
        
        String quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":180.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Mapfre","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000Z","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000Z","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile-Van-Minivan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';
        String vehicledata = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"SALAE24486A349448","Registered_Country__c":"Test","Registered_State__c":"Test","Registered_Plate__c":"Test","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String driverdetails = '[{"Dob__c":"2008-10-11","First_Name__c":"Test","Last_Name__c":"Class","License_Country__c":"Test","License_state__c":"Test","license_number__c":"Test","Driver_Type__c":"Owner & Driver","Country__c":"Test","Postal_Code__c":"12345","State_Province__c":"Test","City__c":"Test","Address__c":"Test","Phone__c":"1234567890","Email__c":"test5testClass@data.com"}]';
        String toweddetails = '';
        String termoptions = '{"Term__c":"Semi-Annual(Half a Year)","Start_Date_for_Coverage__c":"2023-10-11","End_Date_for_Coverage__c":"2024-04-08","Start_Time__c":"03:45:00","End_Time__c":"03:45:00"}';
        String termsAndAlerts = '{"Terms_of_Cancellation_Confirmed__c":"true","Terms_of_Purchase_Confirmed__c":"true"}';
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName = 'Test';
        newContact.AccountId = acc.Id;
        newContact.Phone = '34234333';
        insert newContact;
        
        TriggerSwitch__c TriggerSwitch = new TriggerSwitch__c();
        TriggerSwitch.Name = 'PolicyTrigger'; 
        TriggerSwitch.Active__c = true;   
        insert TriggerSwitch;
        
        
        
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        
        Test.startTest();
        AgentAppController.updateContactDetails( false ,newContact.id, termoptions, driverdetails, termsAndAlerts, toweddetails, '', vehicledata, quotedata);
        Test.stopTest();
        AgentAppController.getVendorInfo();
    }
    
    @isTest
    public static void testCreatepolicy(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Username = 'testuser09ceec87@example.com',
            LastName = 'Test Last Name',
            Email = 'atul.raid+15cdcdc@cloudanalogy.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = prof.Id,
            LanguageLocaleKey = 'en_US',
            Primary_color__c = 'Test Color',
            Partner_name__c = 'Test Partner Name',
            Partner_Id__c = 'Test Partner ID',
            Partner_email__c = 'testdcdc@example.com',
            Logo_URL__c = 'https://www.google.com',
            Agent_Fee__c=100.00,
            User_Type__c = 'External'
        );
        insert testUser;
        
        System.runAs(testUser) {
            String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
            String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
            String quoteJsonError = '{"Start_Date_for_Coverage__c":"0000-00-00","End_Time__c":"33:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
            String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
            String towedJson = '';
            String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
            
            Lead getLeadData = new Lead();
            getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
            getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
            getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
            getLeadData.Quote_Details__c = quoteJson;
            if(getLeadData.Policy_Type__c == 'Watercraft'){
                getLeadData.Watercraft_Detail__c = vehicleJson;
            }else{
                getLeadData.Vehicle_Details__c = vehicleJson;
            }
            getLeadData.Towing__c = towedJson;
            insert getLeadData;
            
            Quote__c quoteRecord = new Quote__c();
            quoteRecord = (Quote__c)JSON.deserialize(quoteGenerate, Quote__c.class);
            quoteRecord.Lead__c = getLeadData.Id;
            insert quoteRecord;
            
            List<Lead> leadRecords = [SELECT Id, Insurance_Type__c, Vehicle_Details__c,Watercraft_Detail__c,  Quote_Details__c FROM Lead Where Id = :getLeadData.Id LIMIT 1];
            Map<String, Object> vehicleDetailsMap;
            Lead leadRecord = leadRecords.get(0);
            
            if(leadRecord.Insurance_Type__c == 'Watercraft'){
                vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Watercraft_Detail__c);
            }else{
                vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Vehicle_Details__c);
            }
            
            vehicleDetailsMap.put('Coverage__c', quoteRecord.Coverage__c);
            leadRecord.Vehicle_details__c = JSON.serialize(vehicleDetailsMap);
            leadRecord.Quote_Details__c = JSON.serialize(quoteRecord);
            update leadRecord;
            
            
            String quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":180.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Qualitas","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile-Van-Minivan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';
            String vehicledata = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"SALAE24486A349448","Registered_Country__c":"Test","Registered_State__c":"Test","Registered_Plate__c":"Test","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
            String driverdetails = '[{"Dob__c":"2008-10-11","First_Name__c":"Test","Last_Name__c":"Class","License_Country__c":"Test","License_state__c":"Test","license_number__c":"Test","Driver_Type__c":"Owner & Driver","Country__c":"Test","Postal_Code__c":"12345","State_Province__c":"Test","City__c":"Test","Address__c":"Test","Phone__c":"1234567890","Email__c":"test5testClass@data.com"}]';
            String toweddetails = '';
            String termoptions = '{"Term__c":"Semi-Annual(Half a Year)","Start_Date_for_Coverage__c":"2023-10-11","End_Date_for_Coverage__c":"2024-04-08","Start_Time__c":"03:45:00","End_Time__c":"03:45:00"}';
            String termsAndAlerts = '{"Terms_of_Cancellation_Confirmed__c":"true","Terms_of_Purchase_Confirmed__c":"true"}';
            
            Quote__c quoteDetails = new Quote__c();
            quoteDetails = (Quote__c)JSON.deserialize(quotedata, Quote__c.class);
            upsert quoteDetails;
            
            Lead quoteLead = new Lead();
            quoteLead.Id = getLeadData.Id;
            if(String.isNotBlank(quotedata)){
                quoteLead.Quote_Details__c = quotedata;
            }
            if(String.isNotBlank(vehicledata)){
                quoteLead.Vehicle_details__c = vehicledata;
            }
            if(String.isNotBlank(driverdetails)){
                quoteLead.Driver_details__c = driverdetails;
            }
            if(String.isNotBlank(towedJson)){
                quoteLead.Towing__c = towedJson;
            }
            if(String.isNotBlank(termoptions)){
                quoteLead.Term_options__c = termoptions;
            }
            if(String.isNotBlank(termsAndAlerts)){
                quoteLead.Terms_Alert__c = termsAndAlerts;
            }
            update quoteLead;
            
            Database.LeadConvert leadConvertInst = new Database.LeadConvert();
            leadConvertInst.setLeadId(getLeadData.Id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
            leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
            string contactId =leadConvertRslt.getContactId();
            
            List<Contact> contactRecords = [SELECT Id, Watercraft_Detail__c, Vehicle_details__c, Quote_Details__c  FROM Contact Where Id = :contactId LIMIT 1];
            Contact contactRecord = contactRecords.get(0);
            Contact getContactData = new Contact();
            getContactData.Id = contactId;
            getContactData.Quote_Details__c = quotedata;
            if(contactRecord.Watercraft_Detail__c != null){
                getContactData.Watercraft_Detail__c = vehicledata;
            }else{
                getContactData.Vehicle_Details__c = vehicledata;
            }
            getContactData.Towing__c = towedJson;
            getContactData.Terms_Alert__c = termsAndAlerts;
            getContactData.Driver_details__c = driverdetails;
            getContactData.Term_options__c = termoptions;
            getContactData.Is_towing__c = false;
            upsert getContactData;
            
            TriggerSwitch__c TriggerSwitch = new TriggerSwitch__c();
            TriggerSwitch.Name = 'PolicyTrigger'; 
            TriggerSwitch.Active__c = true;   
            insert TriggerSwitch;
            
            Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            
            Test.startTest();
            //AgentAppController.createPolicy( quoteLead.Id, false , false);
            AgentAppController.createPolicyFromContact( getContactData.Id, false , false);
            AgentAppController.createPolicyFromContact( getContactData.Id, true , false);
            AgentAppController.updateQuoteTime( quotedata,quoteRecord.Id);
            AgentAppController.createCloneQuote( quoteJson);
            AgentAppController.createCloneQuote( quoteJsonError);
            
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testCreatepolicy3(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Username = 'testusecsdcdr0987@example.com',
            LastName = 'Test Last Name',
            Email = 'atul.rai+15sdcdsc@cloudanalogy.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = prof.Id,
            LanguageLocaleKey = 'en_US',
            Primary_color__c = 'Test Color',
            Partner_name__c = 'Test Partner Name',
            Partner_Id__c = 'Test Partner ID',
            Partner_email__c = 'test@dddexample.com',
            Logo_URL__c = 'https://www.google.com',
            Agent_Fee__c=100.00,
            User_Type__c = 'External'
        );
        insert testUser;
        
        System.runAs(testUser) {
            String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
            String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
            String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
            String towedJson = '';
            String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
            
            Lead getLeadData = new Lead();
            getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
            getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
            getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
            getLeadData.Quote_Details__c = quoteJson;
            if(getLeadData.Policy_Type__c == 'Watercraft'){
                getLeadData.Watercraft_Detail__c = vehicleJson;
            }else{
                getLeadData.Vehicle_Details__c = vehicleJson;
            }
            getLeadData.Towing__c = towedJson;
            insert getLeadData;
            
            Quote__c quoteRecord = new Quote__c();
            quoteRecord = (Quote__c)JSON.deserialize(quoteGenerate, Quote__c.class);
            quoteRecord.Lead__c = getLeadData.Id;
            insert quoteRecord;
            
            List<Lead> leadRecords = [SELECT Id, Insurance_Type__c, Vehicle_Details__c,Watercraft_Detail__c,  Quote_Details__c FROM Lead Where Id = :getLeadData.Id LIMIT 1];
            Map<String, Object> vehicleDetailsMap;
            Lead leadRecord = leadRecords.get(0);
            
            if(leadRecord.Insurance_Type__c == 'Watercraft'){
                vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Watercraft_Detail__c);
            }else{
                vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Vehicle_Details__c);
            }
            
            vehicleDetailsMap.put('Coverage__c', quoteRecord.Coverage__c);
            leadRecord.Vehicle_details__c = JSON.serialize(vehicleDetailsMap);
            leadRecord.Quote_Details__c = JSON.serialize(quoteRecord);
            update leadRecord;
            
            
            String quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":180.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Mapfre","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000Z","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000Z","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile-Van-Minivan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';
            String vehicledata = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"SALAE24486A349448","Registered_Country__c":"Test","Registered_State__c":"Test","Registered_Plate__c":"Test","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
            String driverdetails = '[{"Dob__c":"2008-10-11","First_Name__c":"Test","Last_Name__c":"Class","License_Country__c":"Test","License_state__c":"Test","license_number__c":"Test","Driver_Type__c":"Owner & Driver","Country__c":"Test","Postal_Code__c":"12345","State_Province__c":"Test","City__c":"Test","Address__c":"Test","Phone__c":"1234567890","Email__c":"test5testClass@data.com"}]';
            String toweddetails = '';
            String termoptions = '{"Term__c":"Semi-Annual(Half a Year)","Start_Date_for_Coverage__c":"2023-10-11","End_Date_for_Coverage__c":"2024-04-08","Start_Time__c":"03:45:00","End_Time__c":"03:45:00"}';
            String termsAndAlerts = '{"Terms_of_Cancellation_Confirmed__c":"true","Terms_of_Purchase_Confirmed__c":"true"}';
            
            Quote__c quoteDetails = new Quote__c();
            quoteDetails = (Quote__c)JSON.deserialize(quotedata, Quote__c.class);
            upsert quoteDetails;
            
            Lead quoteLead = new Lead();
            quoteLead.Id = getLeadData.Id;
            if(String.isNotBlank(quotedata)){
                quoteLead.Quote_Details__c = quotedata;
            }
            if(String.isNotBlank(vehicledata)){
                quoteLead.Vehicle_details__c = vehicledata;
            }
            if(String.isNotBlank(driverdetails)){
                quoteLead.Driver_details__c = driverdetails;
            }
            if(String.isNotBlank(towedJson)){
                quoteLead.Towing__c = towedJson;
            }
            if(String.isNotBlank(termoptions)){
                quoteLead.Term_options__c = termoptions;
            }
            if(String.isNotBlank(termsAndAlerts)){
                quoteLead.Terms_Alert__c = termsAndAlerts;
            }
            update quoteLead;
            
            
            TriggerSwitch__c TriggerSwitch = new TriggerSwitch__c();
            TriggerSwitch.Name = 'PolicyTrigger'; 
            TriggerSwitch.Active__c = true;   
            insert TriggerSwitch;
            
            Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            
            Test.startTest();
            AgentAppController.createPolicy( quoteLead.Id, false , false);
            //AgentAppController.createPolicyFromContact( getContactData.Id, false , false);
            Test.stopTest();
        }
    }
    @isTest
    public static void testCreatepolicy2(){
        
        String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test6testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":true}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-10-09","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Annual(One Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":"112","Days_in_Tow__c":"12","towedCount":1,"isDeleteTowedButton":true}]';
        String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-10-09","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Annual(One Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"365","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"Yes","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJson;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJson;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJson;
        }
        getLeadData.Towing__c = towedJson;
        insert getLeadData;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord = (Quote__c)JSON.deserialize(quoteGenerate, Quote__c.class);
        quoteRecord.Lead__c = getLeadData.Id;
        insert quoteRecord;
        
        List<Lead> leadRecords = [SELECT Id, Insurance_Type__c, Vehicle_Details__c,Watercraft_Detail__c,  Quote_Details__c FROM Lead Where Id = :getLeadData.Id LIMIT 1];
        Map<String, Object> vehicleDetailsMap;
        Lead leadRecord = leadRecords.get(0);
        
        if(leadRecord.Insurance_Type__c == 'Watercraft'){
            vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Watercraft_Detail__c);
        }else{
            vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Vehicle_Details__c);
        }
        
        vehicleDetailsMap.put('Coverage__c', quoteRecord.Coverage__c);
        leadRecord.Vehicle_details__c = JSON.serialize(vehicleDetailsMap);
        leadRecord.Quote_Details__c = JSON.serialize(quoteRecord);
        update leadRecord;
        
        
        String quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":365.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Mapfre","Towed_Unit__c":"Yes","End_Date_for_Coverage__c":"2024-10-09","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000Z","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Annual(One Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000Z","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id +'","Vehicle_Sub_type__c":"Automobile-Van-Minivan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';
        String vehicledata = '{"Vehicle_sub_type__c":"Automobile-Van-Minivan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"SALAE24486A349448","Registered_Country__c":"Test","Registered_State__c":"Test","Registered_Plate__c":"Test","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String driverdetails = '[{"Dob__c":"2008-10-11","First_Name__c":"Test","Last_Name__c":"Class","License_Country__c":"Test","License_state__c":"Test","license_number__c":"Test","Driver_Type__c":"Owner & Driver","Country__c":"Test","Postal_Code__c":"12345","State_Province__c":"Test","City__c":"Test","Address__c":"Test","Phone__c":"1234567890","Email__c":"test6testClass@data.com"}]';
        String toweddetails = '[{"Towed_Unit_Type__c":"ATV-UTV","Towed_Unit_Value__c":"112","Days_in_Tow__c":"12","towedCount":1,"isDeleteTowedButton":true}]';
        String termoptions = '{"Term__c":"Annual(One Year)","Start_Date_for_Coverage__c":"2023-10-11","End_Date_for_Coverage__c":"2024-10-09","Start_Time__c":"03:45:00","End_Time__c":"03:45:00"}';
        String termsAndAlerts = '{"Terms_of_Cancellation_Confirmed__c":"true","Terms_of_Purchase_Confirmed__c":"true"}';
        
        Quote__c quoteDetails = new Quote__c();
        quoteDetails = (Quote__c)JSON.deserialize(quotedata, Quote__c.class);
        upsert quoteDetails;
        
        Lead quoteLead = new Lead();
        quoteLead.Id = getLeadData.Id;
        if(String.isNotBlank(vehicledata)){
            quoteLead.Vehicle_details__c = vehicledata;
        }
        if(String.isNotBlank(quotedata)){
            quoteLead.Quote_Details__c = quotedata;
        }
        if(String.isNotBlank(driverdetails)){
            quoteLead.Driver_details__c = driverdetails;
        }
        if(String.isNotBlank(towedJson)){
            quoteLead.Towing__c = towedJson;
        }
        if(String.isNotBlank(termoptions)){
            quoteLead.Term_options__c = termoptions;
        }
        if(String.isNotBlank(termsAndAlerts)){
            quoteLead.Terms_Alert__c = termsAndAlerts;
        }
        update quoteLead;
        
        TriggerSwitch__c TriggerSwitch = new TriggerSwitch__c();
        TriggerSwitch.Name = 'PolicyTrigger'; 
        TriggerSwitch.Active__c = true;   
        insert TriggerSwitch;
        
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        
        Test.startTest();
        AgentAppController.createPolicy( quoteLead.Id, true , false);
        Test.stopTest();
    }
    
    @isTest
    public static void testSearchDetails(){
        String searchKey= 'test@data.com';
        
        Test.startTest();
        AgentAppController.searchDetails(searchKey,'');
        Test.stopTest();
    }
    
    @isTest
    public static void testFetchExistingLead(){
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-10","End_Time__c":"02:45:00","Start_Time__c":"02:45:00","End_Date_for_Coverage__c":"2024-04-07","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Alfa Romeo","Vehicle_Model__c":"Giulia","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Van","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Van","Year__c":"2023","Make__c":"Alfa Romeo","Model__c":"Giulia","Value__c":"8000","Coverage__c":"Liability","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Automobile-Van-Minivan","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"","Registered_Country__c":"","Registered_State__c":"","Registered_Plate__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c = quoteJSON;
        if(getLeadData.Policy_Type__c == 'Watercraft'){
            getLeadData.Watercraft_Detail__c = vehicleJSON;
        }else{
            getLeadData.Vehicle_Details__c = vehicleJSON;
        }
        
        getLeadData.Towing__c = towedJson;
        upsert getLeadData;
        
        Test.startTest();
        AgentAppController.fetchExistingLead( '', getLeadData.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testFetchContactDetails(){
        User user = getUser(true);
        System.runAs(user) {
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'TestLast';
            con.Phone = '6745322';
            insert con;
            
            Test.StartTest();
            AgentAppController.fetchContactDetails(con.Id);
            AgentAppController.updateContactRecord(con);
            try{
            AgentAppController.getLoggedInContactData(UserInfo.getUserId());
            }catch(Exception e){}
            Test.stopTest();
        }    
    }
    
    @isTest
    public static void testinsertContactsFeature(){
        String contactDetails = '{"FirstName":"Test","LastName":"Record","Email":"test@record1.com","Phone":"(777) 777-7777777","Type_of_Services__c":"Renewal","Street__c":"Test","Street_2__c":"Test","City__c":"Test","State__c":"Test","Postal_Code__c":"23443","Driver_License_State__c":"Test","License__c":"Test","Type_of_Domestic__c":"","Contact_Type__c":"DMV Service"}';
        Test.startTest();
        AgentAppController.insertContactsFeature( contactDetails);
        AgentAppController.portalAccessForUser('Test@record.com');
        Test.stopTest();
    }
    
    
    @isTest Static void policyEditControllerTwwest(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Username = 'testuser098ewrer7@example.com',
            LastName = 'Test Last Name',
            Email = 'atul.rai+2233315@cloudanalogy.com',
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
            Agent_Fee__c=100.00,
            User_Type__c = 'External'
        );
        insert testUser;
        
        System.runAs(testUser) {
            
            Vehicle__c vehiceDetails=new Vehicle__c();
            vehiceDetails.Make__c = 'Audi';
            insert vehiceDetails;            
            Account accObj = new Account();
            accObj.Name= 'Test';
            insert accObj;
            
            Contact con=new Contact();
            con.LastName='Testlast';
            con.AccountId=accObj.Id;
            con.Phone = '6543221';
            insert con;
            
            Contact cons=new Contact();
            cons.FirstName='first';
            cons.LastName='Testlastee';
            cons.Email = 'test@123.com';
            cons.Phone = '111111';
            insert cons;
            
            String end_time = '01:45:00.000Z';
            String start_time = '01:45:00.000Z';
            
            String[] strTimeSplit = end_time.split(':');
            String[] strTimeSplit2 = start_time.split(':');
            Time endtimeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                  ,Integer.valueOf(strTimeSplit[1]) //min
                                                  ,0                                //sec
                                                  ,0);
            Time starttimeChange = Time.newInstance( Integer.valueOf(strTimeSplit2[0]) //hour
                                                    ,Integer.valueOf(strTimeSplit2[1]) //min
                                                    ,0                                //sec
                                                    ,0);
            
            Quote__c qouteDetails = new Quote__c();
            qouteDetails.Vehicle_Make__c = 'Audi';
            qouteDetails.Quote_Status__c = 'Policy Created';
            qouteDetails.Underwriter__c = 'Chubb';
            qouteDetails.Policy_Type_picklist__c = 'Automobile';
            qouteDetails.Net_Premium__c = 132.00;
            qouteDetails.Broker_Policy_Fee__c = 10.00;
            qouteDetails.I_V_A_Mex_Tax__c = 19.00;
            qouteDetails.Quote_Value__c = 210.00;
            qouteDetails.Surcharge__c =0;
            qouteDetails.Account__c = accObj.Id;
            qouteDetails.Contact__c =con.Id;
            qouteDetails.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
            qouteDetails.Vehicle_Type__c = 'Automobile-Van-Minivan';
            qouteDetails.Vehicle_Deductible_Collision__c = '500';
            qouteDetails.Vehicle_Deductible_Comprehensive__c = '500';
            qouteDetails.Physical_Damage__c=0;
            qouteDetails.Total_Theft_Payment__c=0;
            qouteDetails.Liability_Payment__c=0;
            qouteDetails.Medical_Payment__c=0;
            qouteDetails.Coverage__c='Complete';
            qouteDetails.Territory__c='Baja/Sonora';
            qouteDetails.Medical__c='10,000/50,000';
            qouteDetails.Liability__c='100,000';
            qouteDetails.Term__c='Daily';
            qouteDetails.Term_Days__c=2;
            qouteDetails.Start_Date_for_Coverage__c=date.parse('01/01/2022');
            qouteDetails.End_Date_for_Coverage__c=date.parse('01/03/2022');
            qouteDetails.Start_Time__c=starttimeChange;
            qouteDetails.End_Time__c=endtimeChange;
            qouteDetails.Vehicle_Value__c=10000.00;
            qouteDetails.Towed_Unit__c = 'Yes';
            insert qouteDetails;
            
            Quote__c qouteDetails2 = new Quote__c();
            qouteDetails2.Vehicle_Make__c = 'BMW';
            qouteDetails2.Quote_Status__c = 'Policy Created';
            qouteDetails2.Underwriter__c = 'Chubb';
            qouteDetails2.Policy_Type_picklist__c = 'Automobile';
            qouteDetails2.Net_Premium__c = 132.00;
            qouteDetails2.Broker_Policy_Fee__c = 10.00;
            qouteDetails2.I_V_A_Mex_Tax__c = 19.00;
            qouteDetails2.Quote_Value__c = 210.00;
            qouteDetails2.Surcharge__c =0;
            qouteDetails2.Account__c = accObj.Id;
            qouteDetails2.Contact__c =con.Id;
            qouteDetails2.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
            qouteDetails2.Vehicle_Type__c = 'Automobile-Van-Minivan';
            qouteDetails2.Vehicle_Deductible_Collision__c = '500';
            qouteDetails2.Vehicle_Deductible_Comprehensive__c = '500';
            qouteDetails2.Physical_Damage__c=0;
            qouteDetails2.Total_Theft_Payment__c=0;
            qouteDetails2.Liability_Payment__c=0;
            qouteDetails2.Medical_Payment__c=0;
            qouteDetails2.Coverage__c='Complete';
            qouteDetails2.Territory__c='Baja/Sonora';
            qouteDetails2.Medical__c='10,000/50,000';
            qouteDetails2.Liability__c='100,000';
            qouteDetails2.Term__c='Daily';
            qouteDetails2.Term_Days__c=2;
            qouteDetails2.Start_Date_for_Coverage__c=date.parse('01/01/2022');
            qouteDetails2.End_Date_for_Coverage__c=date.parse('01/03/2022');
            qouteDetails2.Start_Time__c=starttimeChange;
            qouteDetails2.End_Time__c=endtimeChange;
            qouteDetails2.Vehicle_Value__c=10000.00;
            qouteDetails2.Towed_Unit__c = 'Yes';
            qouteDetails2.Renew_Quote__c = qouteDetails.Id;
            insert qouteDetails2;
            
            Watercraft__c watercraftdetails = new Watercraft__c();
            watercraftdetails.Make__c = 'Audi';
            insert watercraftdetails;
            
            List<driver__c> updatedrivers = new List<driver__c>();
            Driver__c driverDetails = new Driver__c();
            driverDetails.Name = 'd s';
            driverDetails.First_Name__c='d';
            driverDetails.Last_Name__c='s';
            driverDetails.email__c='s@gmail.com';
            driverDetails.Driver_Type__c='Owner';
            driverDetails.Phone__c='123';
            driverDetails.Address__c ='address';
            driverDetails.Address_Line_2__c = 'address';
            driverDetails.City__c = 'city';
            driverDetails.Country__c = 'country';
            driverDetails.default__c = 'Yes';
            insert driverDetails;
            updatedrivers.add(driverDetails);
            
            List<driver__c> updatedrivers2 = new List<driver__c>();
            Driver__c driverDetails1 = new Driver__c();
            driverDetails1.Name = 'd s12';
            driverDetails1.First_Name__c='d';
            driverDetails1.Last_Name__c='s12';
            driverDetails1.email__c='s12@gmail.com';
            driverDetails1.Driver_Type__c='Owner';
            driverDetails1.Phone__c='123';
            driverDetails1.Address__c ='address';
            driverDetails1.Address_Line_2__c = 'address';
            driverDetails1.City__c = 'city';
            driverDetails1.Country__c = 'country';
            driverDetails1.default__c = 'Yes';
            insert driverDetails1;
            updatedrivers2.add(driverDetails1);
            
            List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
            Towed_Unit__c towunitsDetails =new Towed_Unit__c();
            towunitsDetails.Make__c = 'Audi';
            insert towunitsDetails;
            towedUnitsData.add(towunitsDetails);
            
            List<Towed_Unit__c> towedUnitsData2 = new List<Towed_Unit__c>();
            Towed_Unit__c towunitsDetails2 =new Towed_Unit__c();
            towunitsDetails2.Make__c = 'BMW';
            insert towunitsDetails2;
            towedUnitsData2.add(towunitsDetails2);
            
            Policy__c policyDetail = new Policy__c();
            policyDetail.Name='CNLDN-22-XYRGH';
            policyDetail.Vehicle_Policy__c=vehiceDetails.Id;
            policyDetail.Watercraft__c = watercraftdetails.Id;
            policyDetail.Quote_c__c = qouteDetails.Id;
            policyDetail.Status_picklist__c = 'Active';
            policyDetail.Term__c = 'Daily';
            policyDetail.Underwriter_picklist__c='Chubb';
            Insert policyDetail;
            
            Quote_Driver__c qoutedriverDetails = new Quote_Driver__c();
            qoutedriverDetails.Policy__c = policyDetail.Id;
            qoutedriverDetails.Driver__c = driverDetails.Id;
            qoutedriverDetails.Quote_c__c = qouteDetails.Id;
            insert qoutedriverDetails;
            Quote_Driver__c qoutedriverDetailss = new Quote_Driver__c();
            qoutedriverDetailss.Policy__c = policyDetail.Id;
            qoutedriverDetailss.Driver__c = driverDetails1.Id;
            qoutedriverDetailss.Quote_c__c = qouteDetails.Id;
            insert qoutedriverDetailss;
            
            Quote_Towed_Unit__c quoteTowedUnitDetails = new Quote_Towed_Unit__c();
            quoteTowedUnitDetails.Policy__c = policyDetail.Id;
            quoteTowedUnitDetails.Towed_Unit__c= towunitsDetails.Id;
            quoteTowedUnitDetails.Quote_c__c = qouteDetails.Id;
            insert quoteTowedUnitDetails;
            
            Transaction__c transactionDetails = new Transaction__c();
            transactionDetails.Policy_Transaction__c = policyDetail.Id;
            transactionDetails.Quote_c__c = qouteDetails.Id;
            transactionDetails.Amount__c = 350.00;
            insert transactionDetails;
            
            String jsonQouteDetails = JSON.serialize(qouteDetails);
            
            Map<String, Object> quoteMap = (Map<String, Object>)JSON.deserializeUntyped(jsonQouteDetails);
            
            String startTime = (String)quoteMap.get('Start_Time__c');
            String endTime = (String)quoteMap.get('End_Time__c');
            startTime = startTime.replace('Z', '');
            startTime = startTime.replace('Z', '');
            endTime = endTime.replace('Z', '');
            quoteMap.put('Start_Time__c', startTime);
            quoteMap.put('End_Time__c', endTime);
            
            String updatedQuoteData = JSON.serialize(quoteMap);
            
            
            //System.debug('Serialized JSON without Z timezone indicator: ' + jsonQouteDetails.replace('Z', ''));
            //String removeZFromJSon = jsonQouteDetails.replace('Z', '');
            String dr='[{"mailto:first_name__c":"testnamefirst","last_name__c":"testlastname","email__c":"kr.1235gfgfdgf@gmail.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"addressline1","Address_Line_2__c":"addressline2","License_Country__c":"Canada","Country__c":"Canada","City__c":"testcity","Postal_Code__c":"00810","License_state__c":"British Columbia","State_Province__c":"British Columbia","license_number__c":"FGHGFHFVCCVD","Dob__c":"1934-03-03"}]';
            
            String td='[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"}]';
            
            Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            Test.startTest();
            
            AgentAppController.updatePolicyDetails(updatedQuoteData,JSON.serialize(updatedrivers2),JSON.serialize(vehiceDetails),JSON.serialize(towedUnitsData));
            //Mex_PolicyEditController.createNewWatercraftEditPolicy(JSON.serialize(watercraftdetails),dr,qouteDetails.Id,policyDetail.Id,false);
            AgentAppController.createNewEditPolicy(JSON.serialize(vehiceDetails),dr,td,qouteDetails.Id,policyDetail.Id,false);
            AgentAppController.createUserForContact(cons.Id);
            AgentAppController.updateContactEmail('teeeee@testing.com',cons.Id);
            AgentAppController.getDriverData(con.Id);
            AgentAppController.getVehicleData(cons.Id);
            //AgentAppController.searchUserDetails(cons.Email);
            
            Test.stopTest();}
    }
    
    @isTest
    static void testUpdatePolicyDetails() {
        // Setup test data
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = FALSE;
        insert customset;
        
        Vehicle__c vehicleDetails = new Vehicle__c();
        vehicleDetails.Make__c = 'Audi';
        insert vehicleDetails;
        
        Account accObj = new Account();
        accObj.Name = 'Test';
        insert accObj;
        
        Contact con = new Contact();
        con.LastName = 'Testlast';
        con.AccountId = accObj.Id;
        con.Phone = '6543221';
        insert con;
        
        Contact cons = new Contact();
        cons.FirstName = 'first';
        cons.LastName = 'Testlastee';
        cons.Email = 'test@123.com';
        cons.Phone = '111111';
        insert cons;
        
        String end_time = '01:45:00.000Z';
        String start_time = '01:45:00.000Z';
        String[] strTimeSplit = end_time.split(':');
        String[] strTimeSplit2 = start_time.split(':');
        Time endtimeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);
        Time starttimeChange = Time.newInstance(Integer.valueOf(strTimeSplit2[0]), Integer.valueOf(strTimeSplit2[1]), 0, 0);
        
        Quote__c qouteDetails = new Quote__c();
        qouteDetails.Vehicle_Make__c = 'Audi';
        qouteDetails.Quote_Status__c = 'Policy Created';
        qouteDetails.Underwriter__c = 'Chubb';
        qouteDetails.Policy_Type_picklist__c = 'Automobile';
        qouteDetails.Net_Premium__c = 132.00;
        qouteDetails.Broker_Policy_Fee__c = 10.00;
        qouteDetails.I_V_A_Mex_Tax__c = 19.00;
        qouteDetails.Quote_Value__c = 210.00;
        qouteDetails.Surcharge__c = 0;
        qouteDetails.Account__c = accObj.Id;
        qouteDetails.Contact__c = con.Id;
        qouteDetails.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
        qouteDetails.Vehicle_Type__c = 'Automobile-Van-Minivan';
        qouteDetails.Vehicle_Deductible_Collision__c = '500';
        qouteDetails.Vehicle_Deductible_Comprehensive__c = '500';
        qouteDetails.Physical_Damage__c = 0;
        qouteDetails.Total_Theft_Payment__c = 0;
        qouteDetails.Liability_Payment__c = 0;
        qouteDetails.Medical_Payment__c = 0;
        qouteDetails.Coverage__c = 'Complete';
        qouteDetails.Territory__c = 'Baja/Sonora';
        qouteDetails.Medical__c = '10,000/50,000';
        qouteDetails.Liability__c = '100,000';
        qouteDetails.Term__c = 'Daily';
        qouteDetails.Term_Days__c = 2;
        qouteDetails.Start_Date_for_Coverage__c = Date.parse('01/01/2022');
        qouteDetails.End_Date_for_Coverage__c = Date.parse('01/03/2022');
        qouteDetails.Start_Time__c = starttimeChange;
        qouteDetails.End_Time__c = endtimeChange;
        qouteDetails.Vehicle_Value__c = 10000.00;
        qouteDetails.Towed_Unit__c = 'Yes';
        insert qouteDetails;
        
        Quote__c qouteDetails2 = new Quote__c();
        qouteDetails2.Vehicle_Make__c = 'BMW';
        qouteDetails2.Quote_Status__c = 'Policy Created';
        qouteDetails2.Underwriter__c = 'Chubb';
        qouteDetails2.Policy_Type_picklist__c = 'Automobile';
        qouteDetails2.Net_Premium__c = 132.00;
        qouteDetails2.Broker_Policy_Fee__c = 10.00;
        qouteDetails2.I_V_A_Mex_Tax__c = 19.00;
        qouteDetails2.Quote_Value__c = 210.00;
        qouteDetails2.Surcharge__c = 0;
        qouteDetails2.Account__c = accObj.Id;
        qouteDetails2.Contact__c = con.Id;
        qouteDetails2.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
        qouteDetails2.Vehicle_Type__c = 'Automobile-Van-Minivan';
        qouteDetails2.Vehicle_Deductible_Collision__c = '500';
        qouteDetails2.Vehicle_Deductible_Comprehensive__c = '500';
        qouteDetails2.Physical_Damage__c = 0;
        qouteDetails2.Total_Theft_Payment__c = 0;
        qouteDetails2.Liability_Payment__c = 0;
        qouteDetails2.Medical_Payment__c = 0;
        qouteDetails2.Coverage__c = 'Complete';
        qouteDetails2.Territory__c = 'Baja/Sonora';
        qouteDetails2.Medical__c = '10,000/50,000';
        qouteDetails2.Liability__c = '100,000';
        qouteDetails2.Term__c = 'Daily';
        qouteDetails2.Term_Days__c = 2;
        qouteDetails2.Start_Date_for_Coverage__c = Date.parse('01/01/2022');
        qouteDetails2.End_Date_for_Coverage__c = Date.parse('01/03/2022');
        qouteDetails2.Start_Time__c = starttimeChange;
        qouteDetails2.End_Time__c = endtimeChange;
        qouteDetails2.Vehicle_Value__c = 10000.00;
        qouteDetails2.Towed_Unit__c = 'Yes';
        qouteDetails2.Renew_Quote__c = qouteDetails.Id;
        insert qouteDetails2;
        
        Watercraft__c watercraftdetails = new Watercraft__c();
        watercraftdetails.Make__c = 'Audi';
        insert watercraftdetails;
        
        List<Driver__c> updatedrivers = new List<Driver__c>();
        Driver__c driverDetails = new Driver__c();
        driverDetails.Name = 'd s';
        driverDetails.First_Name__c = 'd';
        driverDetails.Last_Name__c = 's';
        driverDetails.Email__c = 's@gmail.com';
        driverDetails.Driver_Type__c = 'Owner';
        driverDetails.Phone__c = '123';
        driverDetails.Address__c = 'address';
        driverDetails.Address_Line_2__c = 'address';
        driverDetails.City__c = 'city';
        driverDetails.Country__c = 'country';
        driverDetails.Default__c = 'Yes';
        insert driverDetails;
        updatedrivers.add(driverDetails);
        
        List<Driver__c> updatedrivers2 = new List<Driver__c>();
        Driver__c driverDetails1 = new Driver__c();
        driverDetails1.Name = 'd s12';
        driverDetails1.First_Name__c = 'd';
        driverDetails1.Last_Name__c = 's12';
        driverDetails1.Email__c = 's12@gmail.com';
        driverDetails1.Driver_Type__c = 'Owner';
        driverDetails1.Phone__c = '123';
        driverDetails1.Address__c = 'address';
        driverDetails1.Address_Line_2__c = 'address';
        driverDetails1.City__c = 'city';
        driverDetails1.Country__c = 'country';
        driverDetails1.Default__c = 'Yes';
        insert driverDetails1;
        updatedrivers2.add(driverDetails1);
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunitsDetails = new Towed_Unit__c();
        towunitsDetails.Make__c = 'Audi';
        insert towunitsDetails;
        towedUnitsData.add(towunitsDetails);
        
        List<Towed_Unit__c> towedUnitsData2 = new List<Towed_Unit__c>();
        Towed_Unit__c towunitsDetails2 = new Towed_Unit__c();
        towunitsDetails2.Make__c = 'BMW';
        insert towunitsDetails2;
        towedUnitsData2.add(towunitsDetails2);
        
        Policy__c policyDetail = new Policy__c();
        policyDetail.Name = 'CNLDN-22-XYRGH';
        policyDetail.Vehicle_Policy__c = vehicleDetails.Id;
        policyDetail.Watercraft__c = watercraftdetails.Id;
        policyDetail.Quote_c__c = qouteDetails.Id;
        policyDetail.Status_picklist__c = 'Active';
        policyDetail.Term__c = 'Daily';
        policyDetail.Underwriter_picklist__c = 'Chubb';
        insert policyDetail;
        
        Quote_Driver__c qoutedriverDetails = new Quote_Driver__c();
        qoutedriverDetails.Policy__c = policyDetail.Id;
        qoutedriverDetails.Driver__c = driverDetails.Id;
        qoutedriverDetails.Quote_c__c = qouteDetails.Id;
        insert qoutedriverDetails;
        
        Quote_Driver__c qoutedriverDetailss = new Quote_Driver__c();
        qoutedriverDetailss.Policy__c = policyDetail.Id;
        qoutedriverDetailss.Driver__c = driverDetails1.Id;
        qoutedriverDetailss.Quote_c__c = qouteDetails.Id;
        insert qoutedriverDetailss;
        
        Quote_Towed_Unit__c quoteTowedUnitDetails = new Quote_Towed_Unit__c();
        quoteTowedUnitDetails.Policy__c = policyDetail.Id;
        quoteTowedUnitDetails.Towed_Unit__c = towunitsDetails.Id;
        quoteTowedUnitDetails.Quote_c__c = qouteDetails.Id;
        insert quoteTowedUnitDetails;
        
        Transaction__c transactionDetails = new Transaction__c();
        transactionDetails.Policy_Transaction__c = policyDetail.Id;
        transactionDetails.Quote_c__c = qouteDetails.Id;
        transactionDetails.Amount__c = 350.00;
        insert transactionDetails;
        
        // Serialize test data into JSON strings
        String quoteData = JSON.serialize(qouteDetails);
        String vehicleData = JSON.serialize(vehicleDetails);
        String driverData = JSON.serialize(updatedrivers);
        String towedUnitData = JSON.serialize(towedUnitsData);
        
        // Modify JSON to remove timezone indicator
        Map<String, Object> quoteMap = (Map<String, Object>)JSON.deserializeUntyped(quoteData);
        String startTime = (String)quoteMap.get('Start_Time__c');
        String endTime = (String)quoteMap.get('End_Time__c');
        startTime = startTime.replace('Z', '');
        endTime = endTime.replace('Z', '');
        quoteMap.put('Start_Time__c', startTime);
        quoteMap.put('End_Time__c', endTime);
        String updatedQuoteData = JSON.serialize(quoteMap);
        
        String dr = '[{"First_Name__c":"d","Last_Name__c":"s","Email__c":"s@gmail.com","Phone__c":"123","Driver_Type__c":"Owner","Address__c":"address","Address_Line_2__c":"address","City__c":"city","Country__c":"country"}]';
        String td = '[{"Make__c":"Audi","Model__c":"testModel","Towed_Unit_Value__c":"10000"}]';
        
        // Set Mock Callout
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        
        // Run the method under test
        Test.startTest();
        AgentappController.updatePolicyDetails(
            updatedQuoteData, 
            vehicleData, 
            dr, 
            td
        );
        Test.stopTest();
        
    }
    
    @isTest
    public static void getUserInfoTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        AgentappController.getUserInfo();
        AgentappController.getVendorInfo();
        AgentappController.returnAccessToken();
        
        Test.StopTest();
    }
    
    @isTest
    public static void chartPolicyTest(){
        
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        upsert getLeadData;

        Database.LeadConvert leadConvertInst = new Database.LeadConvert();
        leadConvertInst.setLeadId(getLeadData.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
        string contactId =leadConvertRslt.getContactId();
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Agency Community Plus Login User' LIMIT 1];
        String userFName = getLeadData.FirstName.substring(0,1);
        String userLName = getLeadData.LastName.length() >=3 ? getLeadData.LastName.substring(0, 3):getLeadData.LastName;
        User newUser = new User(
            Username = getLeadData.Email,
            Email = getLeadData.Email,
            LastName = getLeadData.LastName,
            FirstName = getLeadData.FirstName != null ? getLeadData.FirstName : '',
            Phone = getLeadData.Phone != null ? getLeadData.Phone : '',
            Alias = (getLeadData.FirstName != null && getLeadData.LastName != null) ? userFName + ' ' + userLName : (getLeadData.FirstName == null && getLeadData.LastName != null) ? userLName : '',
            contactId = leadConvertRslt.getContactId(),
            profileId = portalProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            User_Type__c= 'External'
        );
        System.debug('newUser--->'+newUser);
        Database.insert(newUser);
        
        Test.StartTest();
        AgentAppController.getPolicyDataforPieChart('',newUser.Id);
        AgentAppController.getPolicyDataforBarChart('',newUser.Id);
        Test.stopTest();
    }  
    
    

    @isTest
    public static void testMissingBranches() {
        Account acc = new Account(Name = 'Test Agency');
        insert acc;

        Contact agencyContact = new Contact(
            FirstName = 'Agency',
            LastName = 'Contact',
            Email = 'agency@testbranch.com',
            Phone = '1112223333',
            AccountId = acc.Id
        );
        insert agencyContact;

        Contact dupContact = new Contact(
            FirstName = 'Dup',
            LastName = 'Email',
            Email = 'dup@testbranch.com',
            Phone = '9998887777',
            AccountId = acc.Id
        );
        insert dupContact;

        Test.startTest();

        // searchDetails with a non-empty agencyId exercises the if(agencyId != null) branch
        AgentAppController.searchDetails('agency', agencyContact.Id);

        // updateContactDestinationDetails with null contactId returns 'Error'
        String errResult = AgentAppController.updateContactDestinationDetails(null, '{}');
        System.assertEquals('Error', errResult);

        // saveLeadDestinationInfoBeforePayment with blank leadId returns false
        Boolean bResult = AgentAppController.saveLeadDestinationInfoBeforePayment(null, '{}');
        System.assertEquals(false, bResult);

        // insertContactsFeature duplicate email returns 'False'
        String dupContactJson = JSON.serialize(new Contact(
            FirstName = 'Dup', LastName = 'Email2', Email = 'dup@testbranch.com',
            Phone = '9998887777', AccountId = acc.Id
        ));
        String dupResult = AgentAppController.insertContactsFeature(dupContactJson);
        System.assertEquals('False', dupResult);

        // updateContactEmail with an already-existing email returns error string
        String emailResult = AgentAppController.updateContactEmail('dup@testbranch.com', agencyContact.Id);
        System.assert(emailResult.containsIgnoreCase('Error'));

        // fetchContactDetails with null returns 'Error'
        String fetchErr = AgentAppController.fetchContactDetails(null);
        System.assertEquals('Error', fetchErr);

        // updateContactDetails with null contactId returns 'Error'
        String updateErr = AgentAppController.updateContactDetails(false, null, null, null, null, null, null, null, null);
        System.assertEquals('Error', updateErr);

        Test.stopTest();
    }

}
