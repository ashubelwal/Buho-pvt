@isTest
public class AfterPolicyCreatedTest {
    @isTest
    public static void testgetPolicyData(){
          String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_sub_type__c":"Automobile/Sedan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile/Sedan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_sub_type__c":"Automobile/Sedan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
        
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
        
        
        String quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":180.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Qualitas","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile/Sedan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';
        String vehicledata = '{"Vehicle_sub_type__c":"Automobile/Sedan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"SALAE24486A349448","Registered_Country__c":"Test","Registered_State__c":"Test","Registered_Plate__c":"Test","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
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
        quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":12.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Chubb","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile/Sedan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';       
        Test.startTest();
        //AgentAppController.createPolicy( quoteLead.Id, false , false);
         Id testpdf = AgentAppController.createPolicyFromContact( getContactData.Id, false , false);
         AfterPolicyCreated.getPolicyData(testpdf);
         AfterPolicyCreated.getContactEmail(testpdf);
         AfterPolicyCreated.emailServices(testpdf,true);
        testpdf = AgentAppController.createPolicyFromContact( getContactData.Id, true , false);
           AgentAppController.updateQuoteTime( quotedata,quoteRecord.Id);
           AgentAppController.createCloneQuote( quoteJson);
            Test.stopTest();

    }
      @isTest
      public static void testgetupdatedPolicyData(){
          String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_sub_type__c":"Automobile/Sedan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile/Sedan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_sub_type__c":"Automobile/Sedan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual(Half a Year)","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
        
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
        
        
        String quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":180.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Qualitas","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile/Sedan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';
        String vehicledata = '{"Vehicle_sub_type__c":"Automobile/Sedan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Vin__c":"SALAE24486A349448","Registered_Country__c":"Test","Registered_State__c":"Test","Registered_Plate__c":"Test","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
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
        quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":12.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Chubb","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile/Sedan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';       
        Test.startTest();
        //AgentAppController.createPolicy( quoteLead.Id, false , false);
         Id testpdf = AgentAppController.createPolicyFromContact( getContactData.Id, false , false);
         AfterPolicyCreated.getUpdatedPolicyData(quotedata);
            Test.stopTest();


    }
    
}