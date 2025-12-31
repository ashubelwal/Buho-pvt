@isTest
public without sharing class AffiliatePolicyEditRenewUtilsTest {
      @isTest 
     static void policyEditControllerTwwest(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Username = 'testuser0987@example.com',
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
        qouteDetails.Vehicle_Sub_type__c = 'Automobile/Sedan';
        qouteDetails.Vehicle_Type__c = 'Car/Truck/Auto';
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
        qouteDetails2.Vehicle_Sub_type__c = 'Automobile/Sedan';
        qouteDetails2.Vehicle_Type__c = 'Car/Truck/Auto';
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
        AffiliatePolicyEditRenewUtils.createNewEditPolicy(JSON.serialize(vehiceDetails),dr,td,qouteDetails.Id,policyDetail.Id,false);
        Test.stopTest();
        }
    }
    
      @isTest
     static void fetchPolicyDetails_testCase1(){
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
        quote.Start_Time__c = Time.newInstance(1, 0, 0, 0);
        quote.End_Time__c = Time.newInstance(1, 0, 0, 0);
        
        String quoteRecord = JSON.serialize(quote);
        quote.Towed_Unit__c = 'Yes';
        insert quote;
        List<driver__c> drivers = new List<driver__c>();
        driver__c driver =new driver__c();
        driver.Quote_c__c = quote.Id;
        driver.First_Name__c='d';
        driver.Last_Name__c='s';
        driver.email__c='s@gmail.com';
        driver.Driver_Type__c='Owner';
        driver.Phone__c='123';
        driver.Address__c ='address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';
        drivers.add(driver);
        insert drivers;
        
        Quote_Driver__c qtd = new Quote_Driver__c();
        qtd.Driver__c = driver.Id;
        qtd.Quote_c__c = quote.Id;
        insert qtd;
        
        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        insert vehicle;
        
        
        Legal_Term__c legalterm = new Legal_Term__c();
        legalterm.Terms_of_Purchase_and_Use__c = 'No';
        legalterm.Underwriter__c = 'Chubb';
        legalterm.Policy_Type__c = 'Watercraft';        
        insert legalterm;
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quote.Id;
        //insert towunit;
        towedUnitsData.add(towunit);
        insert towedUnitsData;
        Quote_Towed_Unit__c towedQUotes = new Quote_Towed_Unit__c();
        towedQUotes.Towed_Unit__c = towunit.Id;
        towedQUotes.Quote_c__c = quote.Id;
        insert towedQUotes;
        
        
        Policy__c policy = new Policy__c();
        policy.Quote_c__c = quote.Id;
        insert policy;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        PolicyEditRenewUtils.fetchPolicyDetails(policy.Id);
        PolicyEditRenewUtils.fetchPolicyQuoteDetails(quote.Id);
        PolicyEditRenewUtils.fetchPolicyVehicleDetails(vehicle.Id);
        PolicyEditRenewUtils.fetchPolicyDriverDetails(quote.Id);
        PolicyEditRenewUtils.fetchPolicyTowedDetails(quote.Id);
        PolicyEditRenewUtils.fetchUpdatedDate(Date.today(),'Semi-Annual(Half a Year)');
        PolicyEditRenewUtils.fetchUpdatedDate(Date.today(),'Annual');
        PolicyEditRenewUtils.fetchDateRelatedInfo();
        AffiliatePolicyEditRenewUtils.createNewEditPolicyFromCash(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,false);
        AffiliatePolicyEditRenewUtils.createNewEditPolicyFromCash(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,true);
        AffiliatePolicyEditRenewUtils.createNewEditPolicyFromCashWithAmount(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,false,230);
        AffiliatePolicyEditRenewUtils.createNewEditPolicyFromCashWithAmount(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,true,230);
        AffiliatePolicyEditRenewUtils.fetchPolicyDetails(policy.Id);
         Test.stopTest();
    }
    
      @isTest
     public static void validateandGenerateQuotePDFTest(){
        TriggerSwitch__c  triggerSwitchRecord = new TriggerSwitch__c();
        triggerSwitchRecord.Active__c = false;
        triggerSwitchRecord.Name = 'PolicyTrigger';
        insert triggerSwitchRecord;
        
        Policy__c plcy = new Policy__c();
        plcy.Name ='Test';
        plcy.Status_picklist__c='Active';
        plcy.Policy_Type_picklist__c = 'Northbound';
        plcy.End_Date__c= system.today(); 
        insert plcy;
        
        Policy__c plcy1 = new Policy__c();
        plcy1.Name ='Test';
        plcy1.Status_picklist__c='Active';
        plcy1.Policy_Type_picklist__c = 'Driver License';
        plcy1.End_Date__c= system.today(); 
        insert plcy1;
        
        Policy__c plcy2 = new Policy__c();
        plcy2.Name ='Test';
        plcy2.Status_picklist__c='Active';
        plcy2.Policy_Type_picklist__c = 'Watercraft';
        plcy2.End_Date__c= system.today(); 
        insert plcy2;
        
        Policy__c plcy3 = new Policy__c();
        plcy3.Name ='Test';
        plcy3.Status_picklist__c='Active';
        plcy3.Policy_Type_picklist__c = 'Automobile';
        plcy3.Underwriter_picklist__c = 'Mapfre';
        plcy3.End_Date__c= system.today(); 
        insert plcy3;
        
         Policy__c plcy13 = new Policy__c();
        plcy13.Name ='Test';
        plcy13.Status_picklist__c='Active';
        plcy13.Policy_Type_picklist__c = 'Automobile';
        plcy13.Underwriter_picklist__c = 'Qualitas';
        plcy13.End_Date__c= system.today(); 
        insert plcy13;
        
        Policy__c plcy4 = new Policy__c();
        plcy4.Name ='Test';
        plcy4.Status_picklist__c='Active';
        plcy4.Policy_Type_picklist__c = 'Automobile';
        plcy4.Underwriter_picklist__c = 'Chubb';
        plcy4.End_Date__c= system.today(); 
        insert plcy4;
        
        Policy__c plcy5 = new Policy__c();
        plcy5.Name ='Test';
        plcy5.Status_picklist__c='Active';
        plcy5.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        plcy5.Underwriter_picklist__c = 'Qualitas';
        plcy5.End_Date__c= system.today(); 
        insert plcy5;
        
        Policy__c plcy6 = new Policy__c();
        plcy6.Name ='Test';
        plcy6.Status_picklist__c='Active';
        plcy6.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        plcy6.Underwriter_picklist__c = 'Chubb';
        plcy6.End_Date__c= system.today(); 
        insert plcy6;

        Policy__c plcy8 = new Policy__c();
        plcy8.Name ='Test';
        plcy8.Status_picklist__c='Active';
        plcy8.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        plcy8.Underwriter_picklist__c = 'Mapfre';
        plcy8.End_Date__c= system.today(); 
        insert plcy8;
        
        Policy__c plcy7 = new Policy__c();
        plcy7.Name ='Test';
        plcy7.Status_picklist__c='Active';
        plcy7.Policy_Type_picklist__c = 'RV';
        plcy7.Underwriter_picklist__c = 'Chubb';
        plcy7.End_Date__c= system.today(); 
        insert plcy7;
        
        Policy__c plcy9 = new Policy__c();
        plcy9.Name ='Test';
        plcy9.Status_picklist__c='Active';
        plcy9.Policy_Type_picklist__c = 'RV';
        plcy7.Underwriter_picklist__c = 'Mapfre';
        plcy9.End_Date__c= system.today(); 
        insert plcy9;
        
        Policy__c plcy11 = new Policy__c();
        plcy11.Name ='Test';
        plcy11.Status_picklist__c='Active';
        plcy11.Policy_Type_picklist__c = 'RV';
        plcy7.Underwriter_picklist__c = 'Qualitas';
        plcy11.End_Date__c= system.today(); 
        insert plcy11;
        
        Policy__c policyDetail = [Select Id, Policy_Type_picklist__c from Policy__c Where Id =:plcy.Id LIMIT 1];
        String PolicyId = policyDetail.Id;
        Test.startTest();
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy1.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy2.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy3.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy4.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy5.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy6.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy7.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy8.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy9.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy11.Id);
        AffiliatePolicyEditRenewUtils.validateandGenerateQuotePDF(plcy13.Id);
        Test.stopTest();
    }
    
   @isTest 
  public static void testgetPolicyData(){
          String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test514588498Class@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile","Is_towing__c":false}';
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
        TriggerSwitch.Active__c = false;   
        insert TriggerSwitch;
        
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        quotedata = '{"attributes":{"type":"Quote__c","url":"/services/data/v59.0/sobjects/Quote__c/'+quoteRecord.Id +'"},"Territory__c":"Baja/Sonora","Coverage__c":"Complete","Term_Days__c":12.0,"Medical__c":"5,000/25,000","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Deductible_Collision__c":"500","Vehicle_used_for_Business_Purposes__c":false,"Underwriter__c":"Chubb","Towed_Unit__c":"No","End_Date_for_Coverage__c":"2024-04-08","Vehicle_Model__c":"Integra","Total_Theft_Payment__c":0.0,"Net_Premium__c":184.2876,"Policy_Type_picklist__c":"Automobile","Platinum_Endorsment__c":0.0,"End_Time__c":"11:45:00.000","Salvage_Vehicle__c":"No","Vehicle_Type__c":"Car/Truck/Auto","Vehicle_Make__c":"Acura","Liability__c":"300,000","Vehicle_Value__c":8000.0,"Medical_Payment__c":0.0,"Broker_Policy_Fee__c":20.0,"Vehicle_Year__c":"2023","Term__c":"Semi-Annual(Half a Year)","Vehicle_Deductible_Comprehensive__c":"1000","I_V_A_Mex_Tax__c":29.486016,"Liability_Payment__c":0.0,"Is_there_a_driver_under_21__c":"No","Start_Time__c":"11:45:00.000","Start_Date_for_Coverage__c":"2023-10-11","Quote_Value__c":233.773616,"Id":"'+quoteRecord.Id+'","Vehicle_Sub_type__c":"Automobile/Sedan","Physical_Damage__c":0.0,"Lead__c":"'+leadRecord.Id+'"}';       
        Test.startTest();
        //AgentAppController.createPolicy( quoteLead.Id, false , false);
        // Id testpdf = AgentAppController.createPolicy( quoteLead.Id, false , false);
        // Id testpdf = AgentAppController.createPolicyFromContact( getContactData.Id, false , false);
        // AffiliatePolicyEditRenewUtils.getCurrentPolicyId(quotedata);
            Test.stopTest();


    }
    
    
}