@isTest
public class PoilcyEditControllerTest {
    
    @isTest
    static void positivTesting(){
        AuthorizeNetMockGenerator postiveMockgenerator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, postiveMockgenerator);
        TriggerSwitch__c customset1 = new TriggerSwitch__c();
        customset1.Name = 'PolicyTrigger';
        customset1.Active__c = false;
        insert customset1;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today() + 1 ;
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Vehicle_Value__c = 10000;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c = 'Complete';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        quoteRecord.Vehicle_Type__c = 'Automobile-Van-Minivan';
        quoteRecord.Liability__c = '200,000'; 
        quoteRecord.Medical__c = '10,000/50,000';
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Driver_Age__c = 22;
        quoteRecord.Vehicle_used_for_Business_Purposes__c = True;
        quoteRecord.Is_this_a_Rental_Vehicle__c = true;
        quoteRecord.Is_there_a_driver_under_21__c = 'false';
        
        insert quoteRecord;  

        Quote__c quoteRecord1 = new Quote__c();
        quoteRecord1.Start_Date_for_Coverage__c = date.today() +1;
        quoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord1.Driver_Age__c = 80;
        quoteRecord1.Lead__c = ldObj.Id;
        quoteRecord1.contact__c = conObj.Id;
        quoteRecord1.Account__c = acObj.Id;
        quoteRecord1.Underwriter__c ='Qualitas';
        quoteRecord1.Coverage__c = 'Liability';
        quoteRecord1.Term__c=  'Daily';
        quoteRecord1.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        quoteRecord1.Vehicle_Type__c = 'Motorcycle/Street Legal ATV';
        quoteRecord1.Liability__c = '200,000'; 
        quoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert quoteRecord1; 
        
        
        
        
        
        List<driver__c> driverList = new List<driver__c>();
        
        driver__c driver = new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c = 'd';
        driver.Last_Name__c = 's';
        driver.email__c = 's@gmail.com';
        driver.Driver_Type__c = 'Owner';
        driver.Phone__c = '123';
        driver.Address__c = 'address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';
        
        driverList.add(driver);
        insert driverList;
        
        Date testDate1 = system.today().addDays(-10);
        
        Policy__c policyrecord1 = new policy__c();
        policyrecord1.Name = 'testPolicy1';
        policyrecord1.Quote_c__c = quoteRecord.Id;
        policyrecord1.contact__c = conObj.id;
        policyrecord1.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyrecord1.Underwriter_picklist__c = 'Mapfre';
        policyrecord1.Term__c='Annual(One Year)';
        policyrecord1.Start_Date__c= testDate1;
        policyrecord1.End_Date__c = testDate1.addDays(180);
        policyrecord1.Liability_picklist__c = '200,000';
        policyrecord1.Medical_picklist__c = '10,000/50,000';
        policyrecord1.Surcharge__c = 15;
        policyrecord1.I_V_A_Mex_Tax__c = 35;
        policyrecord1.Net_Premium__c = 50;
        policyrecord1.Broker_Policy_Fee__c = 10;
        policyrecord1.Total_Transaction_Amount__c =  110;
        policyrecord1.Package__c = 'Max';
        
        insert policyrecord1;
        
        
        
        Date testDate = system.today().addDays(1);
        
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='Yes';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        Vehicle__c vehicaldata = new Vehicle__c();
        vehicaldata.Rental__c = 'No';
        vehicaldata.Salvage_Vehicle__c = false;
        vehicaldata.Electric_Hybrid__c = false;
        vehicaldata.Is_the_vehicle_registered_to_a_business__c = true;
        vehicaldata.Name='test';
        vehicaldata.Make__c='BMW';
        vehicaldata.Year__c='2022';
        vehicaldata.Model__c='x7';
        vehicaldata.Value__c=2000;
        vehicaldata.Vin__c='test';
        vehicaldata.Vehicle_Type__c='Motorcycle';
        vehicaldata.Policy__c = policyrecord.Id;
        vehicaldata.Registered_Country__c = 'USA';
        vehicaldata.Registered_State__c = 'California';
        vehicaldata.Registered_Plate__c = 'AB123CD';
        insert vehicaldata;
        
        Quote_Vehicle__c quoteVehicle = new Quote_Vehicle__c();
        quoteVehicle.Vehicle__c = vehicaldata.Id;
        quoteVehicle.Quote_c__c = quoteRecord.Id;
        
        insert quoteVehicle; 
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
  
        
        
        Quote_Driver__c QuoteDriver = new Quote_Driver__c();
        QuoteDriver.Driver__c = driver.Id;
        QuoteDriver.Quote_c__c = quoteRecord.Id;
        insert QuoteDriver;
        
        Rate_Table__c rate = new Rate_Table__c();
        rate.Rental_Car__c =212;
        rate.Type__c='Motorcycle';
        insert rate; 
        
        
        Transaction__c transactionObjs = new Transaction__c();
        transactionObjs.Amount__c= 110;
        transactionObjs.Quote_c__c = quoteRecord.Id;
        
        insert transactionObjs;
        
        
        Transaction__c transactionObj = new Transaction__c();
        transactionObj.Id__c = transactionObj.Id;
        transactionObj.Quote_c__c = quoteRecord.Id;
        
        insert transactionObj;
        
       // PoilcyEditController.createPolicy(quoteRecord, quoteRecord.Id, false);
       // PoilcyEditController.fetchPolicyInfo(policyrecord.Id);
       // PoilcyEditController.preViewPdfAction(policyrecord.Id);
        

       // PoilcyEditController.fetchEditPolicyAction(policyrecord.Id);
       // PoilcyEditController.fetchEditPolicyAction(policyrecord1.Id);
      	
        
        
       // PoilcyEditController.calculateNewRate(quoteRecord);
        //PoilcyEditController.calculateNewRate(quoteRecord1);
        

        policyrecord.Vehicle_Policy__c = vehicaldata.Id;
        update policyrecord;
        
        
        //PoilcyEditController.handleQuocteAction(quoteRecord);
        PoilcyEditController.createClonePolicy(quoteRecord,driverList,vehicaldata,towed,TestDataService.createtowed(),'Automobile-Van-Minivan',quoteRecord.Id);
        Quote__c quoteRecord11 = new Quote__c();
        quoteRecord11.Start_Date_for_Coverage__c = date.today();
        quoteRecord11.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord11.Driver_Age__c = 80;
        quoteRecord11.Lead__c = ldObj.Id;
        quoteRecord11.contact__c = conObj.Id;
        quoteRecord11.Account__c = acObj.Id;
        quoteRecord11.Underwriter__c ='Qualitas';
        quoteRecord11.Coverage__c = 'Liability';
        quoteRecord11.Term__c=  'Daily';
        quoteRecord11.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        quoteRecord11.Vehicle_Type__c = 'Motorcycle/Street Legal ATV';
        quoteRecord11.Liability__c = '200,000'; 
        quoteRecord11.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert quoteRecord11; 
          PoilcyEditController.createRenewQuoteAction(quoteRecord11,quoteRecord.Id);
       // PoilcyEditController.refundCalculation(policyrecord1.Id); 
        //PoilcyEditController.refundCalculation(policyrecord.Id);
       // PoilcyEditController.getTimeZone();
       // Test.stopTest();
       // // //
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        //Lead...
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'teghfgst@thtfgdfdrfest.com';
        leadData.IsConverted = false;
        leadData.Is_towing__c = true;
        leadData.Phone = '787777';
        leadData.Lienholder_info__c = '{"Lienholder_name__c":"erte","Lienholder_Phone__c":"rrer","Lienholder_Street__c":"ere","Lienholder_Fax__c":"ere","Lienholder_Street_2__c":"ttere","Lienholder_Country__c":"yes","Lienholder_State__c":"erere","Lienholder_City__c":"erwe","Lienholder_Postal_Code__c":"fgfdgfdgfdgfdfdgd"}';
        leadData.Company_details__c = '{"Company_Name__c":"fghfg","Company_Phone__c":"fghgf","Company_Country__c":"no","Tax_ID__c":"fgdgf","Company_State__c":"no","Company_City__c":"dfgfdg","Company_Zip__c":"dgdf","Company_Address__c":"dfgdf"}';
        leadData.Terms_Alert__c = '{"Terms_of_Purchase_Confirmed__c":true,"Terms_of_Cancellation_Confirmed__c":true}';
        leadData.Vehicle_details__c = '{"Is_Account_Company_Named__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Year__c":"2020","Make__c":"Acura","Model__c":"MDX","Value__c":"10000","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vin__c":"VIN1234NUMB","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","Registered_Plate__c":"SDHFFFHD","Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Vehicle_sub_type__c":"Automobile/Sedan","Coverage__c":"Complete"}';
        leadData.Towing__c = '[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Camper","Street_Legal__c":"no"}]';
        leadData.Term_options__c = '{"Start_Date__c":"2022-09-30","Start_Time__c":"00:00:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2022-10-07","term__c":"Annual(One Year)","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;
        
        // Quote...
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
        
        Quote__c quoteData = new Quote__c();
        quoteData.Underwriter__c = 'Chubb';
        
        Quote__c quoteData2 = new Quote__c();
        quoteData2.Underwriter__c = 'Qualitas';
        quoteData2.Lead__c = leadData.Id;
        quoteData2.Territory__c = 'Limited';
        quoteData2.Coverage__c = 'Complete';
        quoteData2.Term_Days__c = 365.0;
        quoteData2.Medical__c = '10,000/50,000';
        quoteData2.Is_this_a_Rental_Vehicle__c = false;
        quoteData2.Policy_Type_picklist__c = 'Automobile';
        quoteData2.Underwriter__c = 'Mapfre';
        quoteData2.End_Date_for_Coverage__c = date.parse('11/29/2023');
        quoteData2.Start_Date_for_Coverage__c = date.parse('11/29/2023');
        quoteData2.Vehicle_Model__c = 'MDX';
        quoteData2.Towed_Unit__c = 'No';
        quoteData2.Vehicle_used_for_Business_Purposes__c = false;
        quoteData2.Net_Premium__c = 258.367878;
        quoteData2.End_Time__c = endtimeChange;
        quoteData2.Start_Time__c = starttimeChange;
        quoteData2.Salvage_Vehicle__c = 'No';
        quoteData2.Vehicle_Make__c = 'Acura';
        quoteData2.Liability__c = '300,000';
        quoteData2.Vehicle_Value__c = 10000.00;
        quoteData2.Broker_Policy_Fee__c = 30.00;
        quoteData2.Vehicle_Year__c = '2020';
        quoteData2.Term__c = 'Annual(One Year)';
        quoteData2.I_V_A_Mex_Tax__c = 41.338;
        quoteData2.Is_there_a_driver_under_21__c = 'No';
        quoteData2.Quote_Value__c = 329.70;
        quoteData2.Surcharge__c = 0.00;
        insert quoteData2;
        Mex_NewLeadProcess.fetchPolicyDetails(TestDataService.createPolicy(quoteData2).Id);
        
        leadData.Quote_Details__c = JSON.serialize(quoteData2);
        update leadData;
        system.debug('--leadData--'+ leadData);
        
        // Transaction...
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quoteData2.Id;
        insert trans;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        String data = Mex_NewLeadProcess.createPolicy(leadData.Id);
        Map<String,Object> mapData = (Map<String,Object>) JSON.deserializeUntyped(data);
        String polId = (String) mapdata.get('PolicyId'); 
        System.debug('PolicyId0000'+polId);
        PoilcyEditController.refundCalculation(polId);
        PoilcyEditController.getTimeZone();
        PoilcyEditController.createPolicy(quoteData2,quoteData2.Id,true);
        PoilcyEditController.fetchPolicyInfo(polId);
        PoilcyEditController.preViewPdfAction(polId);
        PoilcyEditController.terminatedPolicy(polId,'Testing');
        Test.stopTest();
        
    }

    @IsTest
    static void positiveTesting2(){
         TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        //Lead...
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'teghfgst@thtfgdfdrfest.com';
        leadData.IsConverted = false;
        leadData.Is_towing__c = true;
        leadData.Phone = '787777';
        leadData.Lienholder_info__c = '{"Lienholder_name__c":"erte","Lienholder_Phone__c":"rrer","Lienholder_Street__c":"ere","Lienholder_Fax__c":"ere","Lienholder_Street_2__c":"ttere","Lienholder_Country__c":"yes","Lienholder_State__c":"erere","Lienholder_City__c":"erwe","Lienholder_Postal_Code__c":"fgfdgfdgfdgfdfdgd"}';
        leadData.Company_details__c = '{"Company_Name__c":"fghfg","Company_Phone__c":"fghgf","Company_Country__c":"no","Tax_ID__c":"fgdgf","Company_State__c":"no","Company_City__c":"dfgfdg","Company_Zip__c":"dgdf","Company_Address__c":"dfgdf"}';
        leadData.Terms_Alert__c = '{"Terms_of_Purchase_Confirmed__c":true,"Terms_of_Cancellation_Confirmed__c":true}';
        leadData.Vehicle_details__c = '{"Is_Account_Company_Named__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Year__c":"2020","Make__c":"Acura","Model__c":"MDX","Value__c":"10000","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vin__c":"VIN1234NUMB","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","Registered_Plate__c":"SDHFFFHD","Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Vehicle_sub_type__c":"Automobile/Sedan","Coverage__c":"Complete"}';
        leadData.Towing__c = '[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Camper","Street_Legal__c":"no"}]';
        leadData.Term_options__c = '{"Start_Date__c":"2022-09-30","Start_Time__c":"00:00:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2022-10-07","term__c":"Daily","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;
        
        // Quote...
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
        
        Quote__c quoteData = new Quote__c();
        quoteData.Underwriter__c = 'Chubb';
        
        Quote__c quoteData2 = new Quote__c();
        quoteData2.Underwriter__c = 'Qualitas';
        quoteData2.Lead__c = leadData.Id;
        quoteData2.Territory__c = 'Limited';
        quoteData2.Coverage__c = 'Complete';
        quoteData2.Term_Days__c = 365.0;
        quoteData2.Medical__c = '10,000/50,000';
        quoteData2.Is_this_a_Rental_Vehicle__c = false;
        quoteData2.Policy_Type_picklist__c = 'Automobile';
        quoteData2.Underwriter__c = 'Mapfre';
        quoteData2.End_Date_for_Coverage__c = date.parse('11/18/2025');
        quoteData2.Start_Date_for_Coverage__c = date.parse('11/30/2025');
        quoteData2.Vehicle_Model__c = 'MDX';
        quoteData2.Towed_Unit__c = 'No';
        quoteData2.Vehicle_used_for_Business_Purposes__c = false;
        quoteData2.Net_Premium__c = 258.367878;
        quoteData2.End_Time__c = endtimeChange;
        quoteData2.Start_Time__c = starttimeChange;
        quoteData2.Salvage_Vehicle__c = 'No';
        quoteData2.Vehicle_Make__c = 'Acura';
        quoteData2.Liability__c = '300,000';
        quoteData2.Vehicle_Value__c = 10000.00;
        quoteData2.Broker_Policy_Fee__c = 30.00;
        quoteData2.Vehicle_Year__c = '2020';
        quoteData2.Term__c = 'Daily';
        quoteData2.I_V_A_Mex_Tax__c = 41.338;
        quoteData2.Is_there_a_driver_under_21__c = 'No';
        quoteData2.Quote_Value__c = 329.70;
        quoteData2.Surcharge__c = 0.00;
        insert quoteData2;
        Mex_NewLeadProcess.fetchPolicyDetails(TestDataService.createPolicy(quoteData2).Id);
        
        leadData.Quote_Details__c = JSON.serialize(quoteData2);
        update leadData;
        system.debug('--leadData--'+ leadData);
        
        // Transaction...
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quoteData2.Id;
        insert trans;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        String data = Mex_NewLeadProcess.createPolicy(leadData.Id);
        Map<String,Object> mapData = (Map<String,Object>) JSON.deserializeUntyped(data);
        String polId = (String) mapdata.get('PolicyId'); 
        System.debug('PolicyId0000'+polId);
        PoilcyEditController.refundCalculation(polId);
        PoilcyEditController.getTimeZone();
        PoilcyEditController.createPolicy(quoteData2,quoteData2.Id,true);
        PoilcyEditController.fetchPolicyInfo(polId);
        PoilcyEditController.preViewPdfAction(polId);
        PoilcyEditController.terminatedPolicy(polId,'Testing');
        Test.stopTest();
    }

    @IsTest
    static void positiveTesting3(){
         TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        //Lead...
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'teghfgst@thtfgdfdrfest.com';
        leadData.IsConverted = false;
        leadData.Is_towing__c = true;
        leadData.Phone = '787777';
        leadData.Lienholder_info__c = '{"Lienholder_name__c":"erte","Lienholder_Phone__c":"rrer","Lienholder_Street__c":"ere","Lienholder_Fax__c":"ere","Lienholder_Street_2__c":"ttere","Lienholder_Country__c":"yes","Lienholder_State__c":"erere","Lienholder_City__c":"erwe","Lienholder_Postal_Code__c":"fgfdgfdgfdgfdfdgd"}';
        leadData.Company_details__c = '{"Company_Name__c":"fghfg","Company_Phone__c":"fghgf","Company_Country__c":"no","Tax_ID__c":"fgdgf","Company_State__c":"no","Company_City__c":"dfgfdg","Company_Zip__c":"dgdf","Company_Address__c":"dfgdf"}';
        leadData.Terms_Alert__c = '{"Terms_of_Purchase_Confirmed__c":true,"Terms_of_Cancellation_Confirmed__c":true}';
        leadData.Vehicle_details__c = '{"Is_Account_Company_Named__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Year__c":"2020","Make__c":"Acura","Model__c":"MDX","Value__c":"10000","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vin__c":"VIN1234NUMB","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","Registered_Plate__c":"SDHFFFHD","Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Vehicle_sub_type__c":"Automobile/Sedan","Coverage__c":"Complete"}';
        leadData.Towing__c = '[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Camper","Street_Legal__c":"no"}]';
        leadData.Term_options__c = '{"Start_Date__c":"2025-08-20","Start_Time__c":"04:40:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2025-10-07","term__c":"Daily","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;
        
        // Quote...
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
        
        Quote__c quoteData = new Quote__c();
        quoteData.Underwriter__c = 'Chubb';
        
        Quote__c quoteData2 = new Quote__c();
        quoteData2.Underwriter__c = 'Qualitas';
        quoteData2.Lead__c = leadData.Id;
        quoteData2.Territory__c = 'Limited';
        quoteData2.Coverage__c = 'Complete';
        quoteData2.Term_Days__c = 365.0;
        quoteData2.Medical__c = '10,000/50,000';
        quoteData2.Is_this_a_Rental_Vehicle__c = false;
        quoteData2.Policy_Type_picklist__c = 'Automobile';
        quoteData2.Underwriter__c = 'Mapfre';
        quoteData2.End_Date_for_Coverage__c = date.parse('11/20/2025');
        quoteData2.Start_Date_for_Coverage__c = date.parse('11/30/2025');
        quoteData2.Vehicle_Model__c = 'MDX';
        quoteData2.Towed_Unit__c = 'No';
        quoteData2.Vehicle_used_for_Business_Purposes__c = false;
        quoteData2.Net_Premium__c = 258.367878;
        quoteData2.End_Time__c = endtimeChange;
        quoteData2.Start_Time__c = starttimeChange;
        quoteData2.Salvage_Vehicle__c = 'No';
        quoteData2.Vehicle_Make__c = 'Acura';
        quoteData2.Liability__c = '300,000';
        quoteData2.Vehicle_Value__c = 10000.00;
        quoteData2.Broker_Policy_Fee__c = 30.00;
        quoteData2.Vehicle_Year__c = '2020';
        quoteData2.Term__c = 'Daily';
        quoteData2.I_V_A_Mex_Tax__c = 41.338;
        quoteData2.Is_there_a_driver_under_21__c = 'No';
        quoteData2.Quote_Value__c = 329.70;
        quoteData2.Surcharge__c = 0.00;
        insert quoteData2;
        Mex_NewLeadProcess.fetchPolicyDetails(TestDataService.createPolicy(quoteData2).Id);
        
        leadData.Quote_Details__c = JSON.serialize(quoteData2);
        update leadData;
        system.debug('--leadData--'+ leadData);
        
        // Transaction...
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quoteData2.Id;
        insert trans;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        String data = Mex_NewLeadProcess.createPolicy(leadData.Id);
        Map<String,Object> mapData = (Map<String,Object>) JSON.deserializeUntyped(data);
        String polId = (String) mapdata.get('PolicyId'); 
        System.debug('PolicyId0000'+polId);
        PoilcyEditController.refundCalculation(polId);
        PoilcyEditController.getTimeZone();
        PoilcyEditController.createPolicy(quoteData2,quoteData2.Id,true);
        PoilcyEditController.fetchPolicyInfo(polId);
        PoilcyEditController.preViewPdfAction(polId);
        PoilcyEditController.terminatedPolicy(polId,'Testing');
        Test.stopTest();
    }
    
    @ISTest
    static void fetcthcTestingPart(){
          lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Beam__c = 'beam';
        watercraft.Engine_Type__c = 'engine';
        watercraft.Flag__c = 'flag';
        watercraft.Make__c = 'make';
        watercraft.Model__c = 'model';
        watercraft.Type_of_Vessel__c = 'Sailboat';
        watercraft.VIN_Number__c = '1325';
        watercraft.Value__c = 1000;
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Year__c = '2000';
        watercraft.Lead__c = ldObj.Id;
        
        insert watercraft;
        
        PoilcyEditController.fetchEditPolicyAction(watercraft.Id);
    }
    @IsTest
    static void renewQuoteFetchTest() {
        Test.startTest();
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today();
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Vehicle_Value__c = 10000;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Qualitas';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        quoteRecord.Vehicle_Type__c = 'Automobile-Van-Minivan';
        quoteRecord.Liability__c = '200,000'; 
        quoteRecord.Medical__c = '10,000/50,000';
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Driver_Age__c = 22;
        quoteRecord.Vehicle_used_for_Business_Purposes__c = True;
        quoteRecord.Is_this_a_Rental_Vehicle__c = true;
        
        insert quoteRecord;
        PoilcyEditController.fetchRenewPolicyAction(quoteRecord.Id);
        Test.stopTest();
    }
    @IsTest
    static void createRenewTestingPart(){
         lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
         Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today();
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Vehicle_Value__c = 10000;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Qualitas';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        quoteRecord.Vehicle_Type__c = 'Automobile-Van-Minivan';
        quoteRecord.Liability__c = '200,000'; 
        quoteRecord.Medical__c = '10,000/50,000';
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Driver_Age__c = 22;
        quoteRecord.Vehicle_used_for_Business_Purposes__c = True;
        quoteRecord.Is_this_a_Rental_Vehicle__c = true;
        
        insert quoteRecord;  
        
        
        
        

        
        Quote__c quoteRecord1 = new Quote__c();
        quoteRecord1.Start_Date_for_Coverage__c = date.today();
        quoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord1.Driver_Age__c = 80;
        quoteRecord1.Lead__c = ldObj.Id;
        quoteRecord1.contact__c = conObj.Id;
        quoteRecord1.Account__c = acObj.Id;
        quoteRecord1.Underwriter__c ='Qualitas';
        quoteRecord1.Coverage__c = 'Liability';
        quoteRecord1.Term__c=  'Daily';
        quoteRecord1.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        quoteRecord1.Vehicle_Type__c = 'Motorcycle/Street Legal ATV';
        quoteRecord1.Liability__c = '200,000'; 
        quoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert quoteRecord1; 
          PoilcyEditController.createRenewQuoteAction(quoteRecord, quoteRecord1.Id);
        PoilcyEditController.createRenewQuoteAction(quoteRecord, quoteRecord.Id);
    }
    
    /**
    
    @IsTest
    static void NorthBoundTetstingPart2(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        Quote__c NorthboundquoteRecord = new Quote__c();
        NorthboundquoteRecord.Start_Date_for_Coverage__c = date.today();
        NorthboundquoteRecord.End_Date_for_Coverage__c = date.today()+5;
        NorthboundquoteRecord.Driver_Age__c = 80;
        NorthboundquoteRecord.Vehicle_Value__c = 10000;
        NorthboundquoteRecord.Lead__c = ldObj.Id;
        NorthboundquoteRecord.contact__c = conObj.Id;
        NorthboundquoteRecord.Account__c = acObj.Id;
        NorthboundquoteRecord.Underwriter__c ='Chubb';
        NorthboundquoteRecord.Coverage__c = 'Liability';
        NorthboundquoteRecord.Term__c=  'Daily';
        NorthboundquoteRecord.Policy_Type_picklist__c = 'Northbound';
        NorthboundquoteRecord.Liability__c = '200,000'; 
        NorthboundquoteRecord.Medical__c = '10,000/50,000';
        NorthboundquoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        NorthboundquoteRecord.Driver_Age__c = 22;
        NorthboundquoteRecord.Vehicle_used_for_Business_Purposes__c = True;
        NorthboundquoteRecord.Is_this_a_Rental_Vehicle__c = true;
        
        insert NorthboundquoteRecord;
        
            
       Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Automobile-Van-Minivan';
        rate.Days__c = 10;
        rate.Trailering_Surcharge__c = 35;
        rate.IVA_Mex_Tax__c = 100;
        rate.Underwriter__c = NorthboundquoteRecord.Underwriter__c;
        rate.Age_of_Vehicle_Surcharge_25_years_old__c = 10;
        rate.Age_of_Vehicle_Surcharge__c = 25; 
        rate.Age_of_Operator_Surcharge__c = 20;
        rate.Risk_3_Third_Party_Liability_Insured_Sum__c = '200,000';
        rate.Days__c = 11;
        rate.Term__c = 'Daily';//have to take care of this and quoteObject.Policy_Type_picklist__c == 'Driver License'
        rate.Direction__c =NorthboundquoteRecord.Policy_Type_picklist__c;
        insert rate; 
        
        
        
        
        
		Date testDate = system.today().addDays(-10);
        
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = NorthboundquoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Northbound';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Vehicle_type__c = 'Northbound';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        insert policyrecord;
        
       
        //Id, Territory_picklist__c, Term__c, Term_days__c, Start_Date__c, End_Date__c, Vehicle_type__c, Package__c, Quote_c__c, Underwriter_picklist__c, Net_Premium__c,
        //    I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Surcharge__c, Liability_picklist__c, Medical_picklist__c, Policy_Type_picklist__c, Name, Total_Transaction_Amount__c
        
        PoilcyEditController.calculateNewRate(NorthboundquoteRecord);
        
       PoilcyEditController.refundCalculation(policyrecord.Id);
       // PoilcyEditController.refundCalculation(policyrecord1.Id);
    }
    */

    @IsTest
    static void watercraftTesting(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today();
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Vehicle_Value__c = 10000;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Qualitas';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        quoteRecord.Vehicle_Type__c = 'Automobile-Van-Minivan';
        quoteRecord.Liability__c = '200,000'; 
        quoteRecord.Medical__c = '10,000/50,000';
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Driver_Age__c = 22;
        quoteRecord.Vehicle_used_for_Business_Purposes__c = True;
        quoteRecord.Is_this_a_Rental_Vehicle__c = true;
        
        insert quoteRecord;
        
        Quote__c waterquoteRecord = new Quote__c();
        waterquoteRecord.Start_Date_for_Coverage__c = date.today();
        waterquoteRecord.End_Date_for_Coverage__c = date.today()+5;
        waterquoteRecord.Driver_Age__c = 80;
        waterquoteRecord.Vehicle_Value__c = 10000;
        waterquoteRecord.Lead__c = ldObj.Id;
        waterquoteRecord.contact__c = conObj.Id;
        waterquoteRecord.Account__c = acObj.Id;
        waterquoteRecord.Underwriter__c ='Chubb';
        waterquoteRecord.Coverage__c = 'Liability';
        waterquoteRecord.Type_of_Vessel__c = 'Sailboat';
        waterquoteRecord.Vessel_Length__c = 'Less than 27\' long';
        waterquoteRecord.Term__c=  'Daily';
        waterquoteRecord.Policy_Type_picklist__c = 'Watercraft';
        waterquoteRecord.Liability__c = '200,000'; 
        waterquoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        waterquoteRecord.Driver_Age__c = 22;
        waterquoteRecord.Third_Party_Bodily_Injury__c = '$50,000 / $100,000';
        waterquoteRecord.Property_Damage_Liability__c = '$100,000';
        waterquoteRecord.Vehicle_used_for_Business_Purposes__c = True;
        waterquoteRecord.Is_this_a_Rental_Vehicle__c = true;
        waterquoteRecord.Vehicle_Type__c = 'Watercraft';
        insert waterquoteRecord;

          
        
        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Beam__c = 'beam';
        watercraft.Engine_Type__c = 'engine';
        watercraft.Flag__c = 'flag';
        watercraft.Make__c = 'make';
        watercraft.Model__c = 'model';
        watercraft.Type_of_Vessel__c = 'Powerboat';
        watercraft.VIN_Number__c = '1325';
        watercraft.Value__c = 1000;
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Year__c = '2000';
        watercraft.Lead__c = ldObj.Id;
        watercraft.Quote_c__c = waterquoteRecord.Id;
        insert watercraft;
            
       Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Watercraft';
        rate.Days__c = 10;
        rate.Trailering_Surcharge__c = 35;
        rate.IVA_Mex_Tax__c = 100;
        rate.Underwriter__c = waterquoteRecord.Underwriter__c;
        rate.Age_of_Vehicle_Surcharge_25_years_old__c = 10;
        rate.Age_of_Vehicle_Surcharge__c = 25; 
        rate.Age_of_Operator_Surcharge__c = 20;
        rate.Days__c = 11;
        rate.Term__c = 'Daily';//have to take care of this and quoteObject.Policy_Type_picklist__c == 'Driver License'
        
        insert rate; 
        
        List<driver__c> driverList = new List<driver__c>();
        
        driver__c driver = new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c = 'd';
        driver.Last_Name__c = 's';
        driver.email__c = 's@gmail.com';
        driver.Driver_Type__c = 'Owner';
        driver.Phone__c = '123';
        driver.Address__c = 'address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';
        
        driverList.add(driver);
        insert driverList;

		Date testDate = system.today().addDays(-10);
        
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = waterquoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Watercraft';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyRecord.Watercraft__c = watercraft.Id;
        policyrecord.Vehicle_type__c = 'Boat';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        insert policyrecord;
        
       
        //Id, Territory_picklist__c, Term__c, Term_days__c, Start_Date__c, End_Date__c, Vehicle_type__c, Package__c, Quote_c__c, Underwriter_picklist__c, Net_Premium__c,
        //    I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Surcharge__c, Liability_picklist__c, Medical_picklist__c, Policy_Type_picklist__c, Name, Total_Transaction_Amount__c
        
        PoilcyEditController.calculateNewRate(waterquoteRecord);
        PoilcyEditController.createWatercraftClonePolicy(waterquoteRecord, driverList, watercraft, 'Watercraft', quoteRecord.Id);
        
        //PoilcyEditController.refundCalculation(policyrecord.Id);
    }
    
    /*
    @IsTest
    static void DlTetstingPart2(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        Quote__c DlquoteRecord = new Quote__c();
        
         
        
        DlquoteRecord.Start_Date_for_Coverage__c = date.today();
        DlquoteRecord.End_Date_for_Coverage__c = date.today()+5;
        DlquoteRecord.Driver_Age__c = 80;
        DlquoteRecord.Vehicle_Value__c = 10000;
        DlquoteRecord.Lead__c = ldObj.Id;
        DlquoteRecord.contact__c = conObj.Id;
        DlquoteRecord.Account__c = acObj.Id;
        DlquoteRecord.Underwriter__c ='Chubb';
        DlquoteRecord.Coverage__c = 'Liability';
        DlquoteRecord.Term__c=  'Daily';
        DlquoteRecord.Policy_Type_picklist__c = 'Driver License';
        DlquoteRecord.Vehicle_Type__c = 'Automobile-Van-Minivan';
        DlquoteRecord.Liability__c = '200,000'; 
        DlquoteRecord.Medical__c = '10,000/50,000';
        DlquoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        DlquoteRecord.Driver_Age__c = 22;
        DlquoteRecord.Vehicle_used_for_Business_Purposes__c = True;
        DlquoteRecord.Is_this_a_Rental_Vehicle__c = true;
        
        insert DlquoteRecord;
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = DlquoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        policyrecord.Underwriter_picklist__c = 'Qualitas';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Max';
        insert policyrecord;
        
        
        PoilcyEditController.calculateNewRate(DlquoteRecord);
        
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
    }
    
    @IsTest
    static void RVTetstingPart2(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        Quote__c RVquoteRecord1 = new Quote__c();
        RVquoteRecord1.Start_Date_for_Coverage__c = date.today();
        RVquoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        RVquoteRecord1.Driver_Age__c = 80;
        RVquoteRecord1.Lead__c = ldObj.Id;
        RVquoteRecord1.contact__c = conObj.Id;
        RVquoteRecord1.Account__c = acObj.Id;
        RVquoteRecord1.Underwriter__c ='Qualitas';
        RVquoteRecord1.Coverage__c = 'Liability';
        RVquoteRecord1.Vehicle_Value__c = 5000;
        RVquoteRecord1.Term__c=  'Daily';
        RVquoteRecord1.Policy_Type_picklist__c = 'RV';
        RVquoteRecord1.Vehicle_Type__c = 'RV';
        RVquoteRecord1.Liability__c = '200,000'; 
        RVquoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert RVquoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = RVquoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'RV';
        policyrecord.Underwriter_picklist__c = 'Qualitas';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
           Quote__c RVquoteRecord = new Quote__c();
        RVquoteRecord.Start_Date_for_Coverage__c = date.today();
        RVquoteRecord.End_Date_for_Coverage__c = date.today()+5;
        RVquoteRecord.Driver_Age__c = 80;
        RVquoteRecord.Lead__c = ldObj.Id;
        RVquoteRecord.contact__c = conObj.Id;
        RVquoteRecord.Account__c = acObj.Id;
        RVquoteRecord.Underwriter__c ='Chubb';
        RVquoteRecord.Coverage__c = 'Liability';
        RVquoteRecord.Vehicle_Value__c = 5000;
        RVquoteRecord.Term__c=  'Daily';
        RVquoteRecord.Policy_Type_picklist__c = 'RV';
        RVquoteRecord.Vehicle_Type__c = 'RV';
        RVquoteRecord.Liability__c = '200,000'; 
        RVquoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert RVquoteRecord;
        
        Date testDate1 = system.today().addDays(10);
        Policy__c policyrecord1 = new policy__c();
        policyrecord1.Name = 'testPolicy';
        policyrecord1.Quote_c__c = RVquoteRecord.Id;
        policyrecord1.contact__c = conObj.id;
        policyrecord1.Policy_Type_picklist__c = 'RV';
        policyrecord1.Underwriter_picklist__c = 'Chubb';
        policyrecord1.Territory_picklist__c = 'Full';
        policyrecord1.Package__c = 'Liability';
        policyrecord1.Term__c='Daily';
        policyrecord1.Start_Date__c= testDate;
        policyrecord1.End_Date__c = testDate1.addDays(20);
        policyrecord1.Liability_picklist__c = '200,000';
        policyrecord1.Medical_picklist__c = '10,000/50,000';
        policyrecord1.Surcharge__c = 15;
        policyrecord1.I_V_A_Mex_Tax__c = 35;
        policyrecord1.Net_Premium__c = 50;
        policyrecord1.Broker_Policy_Fee__c = null;
        policyrecord1.Total_Transaction_Amount__c =  110;
        policyrecord1.Package__c = 'Complete';
        insert policyrecord1;
        PoilcyEditController.calculateNewRate(RVquoteRecord1);
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
        policyrecord.Territory_picklist__c = 'Full';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
       
    }
    @IsTest
    static void RvChubbTestPart(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        Quote__c RVquoteRecord1 = new Quote__c();
        RVquoteRecord1.Start_Date_for_Coverage__c = date.today();
        RVquoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        RVquoteRecord1.Driver_Age__c = 80;
        RVquoteRecord1.Lead__c = ldObj.Id;
        RVquoteRecord1.contact__c = conObj.Id;
        RVquoteRecord1.Account__c = acObj.Id;
        RVquoteRecord1.Underwriter__c ='Chubb';
        RVquoteRecord1.Coverage__c = 'Liability';
        RVquoteRecord1.Vehicle_Value__c = 5000;
        RVquoteRecord1.Term__c=  'Daily';
        RVquoteRecord1.Policy_Type_picklist__c = 'RV';
        RVquoteRecord1.Vehicle_Type__c = 'RV';
        RVquoteRecord1.Liability__c = '200,000'; 
        RVquoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert RVquoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = RVquoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'RV';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
         PoilcyEditController.calculateNewRate(RVquoteRecord1);
         PoilcyEditController.refundCalculation(policyrecord.Id);
        
        policyrecord.Package__c ='Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
    }
     @IsTest
    static void RvMapfreTestPart(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
        
        
        Quote__c RVquoteRecord1 = new Quote__c();
        RVquoteRecord1.Start_Date_for_Coverage__c = date.today();
        RVquoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        RVquoteRecord1.Driver_Age__c = 60;
        RVquoteRecord1.Lead__c = ldObj.Id;
        RVquoteRecord1.contact__c = conObj.Id;
        RVquoteRecord1.Account__c = acObj.Id;
        RVquoteRecord1.Underwriter__c ='Mapfre';
        RVquoteRecord1.Coverage__c = 'Liability';
        RVquoteRecord1.Vehicle_Value__c = 5000;
        RVquoteRecord1.Medical__c = '10,000/50,000';
        RVquoteRecord1.Term__c=  'Daily';
        RVquoteRecord1.Policy_Type_picklist__c = 'RV';
        RVquoteRecord1.Vehicle_Type__c = 'RV';
        RVquoteRecord1.Liability__c = '200,000';
        RVquoteRecord1.Vehicle_Sub_type__c ='Motor Home / RV';
        //RVquoteRecord1.Policy_Type__c ='RV';
        RVquoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert RVquoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = RVquoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'RV';
        policyrecord.Underwriter_picklist__c = 'Mapfre';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
        List<Discount__c> discountList = new List<Discount__c>();
        
        for(integer i = 0; i <=  3; i++){
            Discount__c discount = new Discount__c();
            discount.Underwriter__c = 'Mapfre';
            discount.Daily_Discount__c = 0;
            if(i == 0){
                discount.No_of_Days__c = 90;
            }else if(i == 1){
                discount.No_of_Days__c = 180;
            }else if(i == 2){
                discount.No_of_Days__c = 365;
            }else{
                discount.No_of_Days__c = 11;
            }
            discountList.add(discount);
        }
        
        insert discountList;
        
        PoilcyEditController.calculateNewRate(RVquoteRecord1);
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Max';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
    }
    */
    @IsTest
    static void AutomobileTetstingPart2(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        Quote__c AutomobilequoteRecord1 = new Quote__c();
        AutomobilequoteRecord1.Start_Date_for_Coverage__c = date.today();
        AutomobilequoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        AutomobilequoteRecord1.Driver_Age__c = 80;
        AutomobilequoteRecord1.Lead__c = ldObj.Id;
        AutomobilequoteRecord1.contact__c = conObj.Id;
        AutomobilequoteRecord1.Account__c = acObj.Id;
        AutomobilequoteRecord1.Underwriter__c ='Qualitas';
        AutomobilequoteRecord1.Coverage__c = 'Liability';
        AutomobilequoteRecord1.Vehicle_Value__c = 5000;
        AutomobilequoteRecord1.Term__c=  'Daily';
        AutomobilequoteRecord1.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        AutomobilequoteRecord1.Vehicle_Type__c = 'Automobile-Van-Minivan';
        AutomobilequoteRecord1.Liability__c = '200,000'; 
        AutomobilequoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert AutomobilequoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = AutomobilequoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        policyrecord.Underwriter_picklist__c = 'Qualitas';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
        
        
        Quote__c RVquoteRecord = new Quote__c();
        RVquoteRecord.Start_Date_for_Coverage__c = date.today();
        RVquoteRecord.End_Date_for_Coverage__c = date.today()+5;
        RVquoteRecord.Driver_Age__c = 80;
        RVquoteRecord.Lead__c = ldObj.Id;
        RVquoteRecord.contact__c = conObj.Id;
        RVquoteRecord.Account__c = acObj.Id;
        RVquoteRecord.Underwriter__c ='Chubb';
        RVquoteRecord.Coverage__c = 'Liability';
        RVquoteRecord.Vehicle_Value__c = 5000;
        RVquoteRecord.Term__c=  'Daily';
        RVquoteRecord.Policy_Type_picklist__c = 'Motorhome';
        RVquoteRecord.Vehicle_Type__c = 'Motorhome';
        RVquoteRecord.Liability__c = '200,000'; 
        RVquoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        RVquoteRecord.Is_there_a_driver_under_21__c = 'false';
        insert RVquoteRecord;

Vehicle__c vehicaldata = new Vehicle__c();

// Basic info
vehicaldata.Name = 'Test Vehicle';

// Boolean fields
vehicaldata.Is_the_vehicle_registered_to_a_business__c = true;
vehicaldata.Rental__c = 'No';
vehicaldata.Salvage_Vehicle__c = false;
vehicaldata.Electric_Hybrid__c = false;

// Text / Picklist fields
vehicaldata.Year__c = '2022';
vehicaldata.Vehicle_Type__c = 'Motorhome';
vehicaldata.Make__c = 'BMW';
vehicaldata.Model__c = 'X7';
vehicaldata.Vin__c = 'TESTVIN123456789';
vehicaldata.Registered_Country__c = 'USA';
vehicaldata.Registered_State__c = 'California';
vehicaldata.Registered_Plate__c = 'AB123CD';

// Numeric fields
vehicaldata.Value__c = 25000;

// Parent relationship
insert vehicaldata;

// Quote-Vehicle linking
Quote_Vehicle__c quoteVehicle = new Quote_Vehicle__c();
quoteVehicle.Vehicle__c = vehicaldata.Id;
quoteVehicle.Quote_c__c = RVquoteRecord.Id;

insert quoteVehicle;

        
        
        Date testDate1 = system.today().addDays(10);
        Policy__c policyrecord1 = new policy__c();
        policyrecord1.Name = 'testPolicy';
        policyrecord1.Quote_c__c = RVquoteRecord.Id;
        policyrecord1.contact__c = conObj.id;
        policyrecord1.Policy_Type_picklist__c = 'RV';
        policyrecord1.Underwriter_picklist__c = 'Chubb';
        policyrecord1.Territory_picklist__c = 'Full';
        policyrecord1.Package__c = 'Liability';
        policyrecord1.Term__c='Daily';
        policyrecord1.Start_Date__c= testDate;
        policyrecord1.End_Date__c = testDate1.addDays(20);
        policyrecord1.Liability_picklist__c = '200,000';
        policyrecord1.Medical_picklist__c = '10,000/50,000';
        policyrecord1.Surcharge__c = 15;
        policyrecord1.I_V_A_Mex_Tax__c = 35;
        policyrecord1.Net_Premium__c = 50;
        policyrecord1.Broker_Policy_Fee__c = null;
        policyrecord1.Total_Transaction_Amount__c =  110;
        policyrecord1.Package__c = 'Complete';
        insert policyrecord1;
        PoilcyEditController.calculateNewRate(AutomobilequoteRecord1);

        policyrecord.Quote_c__c = RVquoteRecord.Id;
        policyrecord.Vehicle_Policy__c = vehicaldata.Id;
        update policyrecord;

        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Territory_picklist__c = 'Full';
        update policyrecord;
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Liability';
        update policyrecord;

        PoilcyEditController.refundCalculation(policyrecord.Id);
    }
     @IsTest
    static void AutomobileTetstingPart2s(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
       Rate_Table__c rateTable = new Rate_Table__c();
            rateTable.Risk_1_Physical_Damages__c = 0.6315;
            rateTable.Risk_2_Total_Theft__c = 0.2665;
            rateTable.Underwriter__c = 'Chubb';
            rateTable.type__c = 'Automobile';
            rateTable.High_Value__c = 5000;
            rateTable.Low_Value__c     = 5000;
            insert rateTable;
            
            List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 6; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 11;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 5; 
                }else if(i == 2){
                   discountObj.No_of_Days__c = 30; 
                }else if(i == 3){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 4){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Quote__c AutomobilequoteRecord1 = new Quote__c();
        AutomobilequoteRecord1.Start_Date_for_Coverage__c = date.today();
        AutomobilequoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        AutomobilequoteRecord1.Driver_Age__c = 80;
        AutomobilequoteRecord1.Lead__c = ldObj.Id;
        AutomobilequoteRecord1.contact__c = conObj.Id;
        AutomobilequoteRecord1.Account__c = acObj.Id;
        AutomobilequoteRecord1.Underwriter__c ='Chubb';
        AutomobilequoteRecord1.Coverage__c = 'Liability';
        AutomobilequoteRecord1.Vehicle_Value__c = 5000;
        AutomobilequoteRecord1.Term__c=  'Daily';
        AutomobilequoteRecord1.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        AutomobilequoteRecord1.Vehicle_Type__c = 'Automobile-Van-Minivan';
        AutomobilequoteRecord1.Liability__c = '200,000'; 
        AutomobilequoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert AutomobilequoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = AutomobilequoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
        
        
        Quote__c RVquoteRecord = new Quote__c();
        RVquoteRecord.Start_Date_for_Coverage__c = date.today();
        RVquoteRecord.End_Date_for_Coverage__c = date.today()+5;
        RVquoteRecord.Driver_Age__c = 80;
        RVquoteRecord.Lead__c = ldObj.Id;
        RVquoteRecord.contact__c = conObj.Id;
        RVquoteRecord.Account__c = acObj.Id;
        RVquoteRecord.Underwriter__c ='Chubb';
        RVquoteRecord.Coverage__c = 'Liability';
        RVquoteRecord.Vehicle_Value__c = 5000;
        RVquoteRecord.Term__c=  'Daily';
        RVquoteRecord.Policy_Type_picklist__c = 'RV';
        RVquoteRecord.Vehicle_Type__c = 'RV';
        RVquoteRecord.Liability__c = '200,000'; 
        RVquoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        RVquoteRecord.Is_there_a_driver_under_21__c = 'false';
        insert RVquoteRecord;
        
        Vehicle__c vehicaldata = new Vehicle__c();

// Basic info
vehicaldata.Name = 'Test Vehicle';

// Boolean fields
vehicaldata.Is_the_vehicle_registered_to_a_business__c = true;
vehicaldata.Rental__c = 'No';
vehicaldata.Salvage_Vehicle__c = false;
vehicaldata.Electric_Hybrid__c = false;

// Text / Picklist fields
vehicaldata.Year__c = '2022';
vehicaldata.Vehicle_Type__c = 'Motorhome';
vehicaldata.Make__c = 'BMW';
vehicaldata.Model__c = 'X7';
vehicaldata.Vin__c = 'TESTVIN123456789';
vehicaldata.Registered_Country__c = 'USA';
vehicaldata.Registered_State__c = 'California';
vehicaldata.Registered_Plate__c = 'AB123CD';

// Numeric fields
vehicaldata.Value__c = 25000;

// Parent relationship
insert vehicaldata;

// Quote-Vehicle linking
Quote_Vehicle__c quoteVehicle = new Quote_Vehicle__c();
quoteVehicle.Vehicle__c = vehicaldata.Id;
quoteVehicle.Quote_c__c = RVquoteRecord.Id;

insert quoteVehicle;
        
        Date testDate1 = system.today().addDays(10);
        Policy__c policyrecord1 = new policy__c();
        policyrecord1.Name = 'testPolicy';
        policyrecord1.Quote_c__c = RVquoteRecord.Id;
        policyrecord1.contact__c = conObj.id;
        policyrecord1.Policy_Type_picklist__c = 'RV';
        policyrecord1.Underwriter_picklist__c = 'Chubb';
        policyrecord1.Territory_picklist__c = 'Full';
        policyrecord1.Package__c = 'Liability';
        policyrecord1.Term__c='Daily';
        policyrecord1.Start_Date__c= testDate;
        policyrecord1.End_Date__c = testDate1.addDays(20);
        policyrecord1.Liability_picklist__c = '200,000';
        policyrecord1.Medical_picklist__c = '10,000/50,000';
        policyrecord1.Surcharge__c = 15;
        policyrecord1.I_V_A_Mex_Tax__c = 35;
        policyrecord1.Net_Premium__c = 50;
        policyrecord1.Broker_Policy_Fee__c = null;
        policyrecord1.Total_Transaction_Amount__c =  110;
        policyrecord1.Package__c = 'Complete';
        insert policyrecord1;
        PoilcyEditController.calculateNewRate(AutomobilequoteRecord1);
        
        policyrecord.Quote_c__c = RVquoteRecord.Id;
        policyrecord.Vehicle_Policy__c = vehicaldata.Id;
        update policyrecord;
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
        policyrecord.Territory_picklist__c = 'Full';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Max';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
        
    }
    @IsTest
    static void AutomobileTetstingPart3(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
       Rate_Table__c rateTable = new Rate_Table__c();
            rateTable.Risk_1_Physical_Damages__c = 0.6315;
            rateTable.Risk_2_Total_Theft__c = 0.2665;
            rateTable.Underwriter__c = 'Mapfre';
            rateTable.type__c = 'Automobile';
            rateTable.High_Value__c = 5000;
            rateTable.Low_Value__c     = 5000;
            insert rateTable;
            
            List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 6; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 11;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 5; 
                }else if(i == 2){
                   discountObj.No_of_Days__c = 30; 
                }else if(i == 3){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 4){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Quote__c AutomobilequoteRecord1 = new Quote__c();
        AutomobilequoteRecord1.Start_Date_for_Coverage__c = date.today();
        AutomobilequoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        AutomobilequoteRecord1.Driver_Age__c = 80;
        AutomobilequoteRecord1.Lead__c = ldObj.Id;
        AutomobilequoteRecord1.contact__c = conObj.Id;
        AutomobilequoteRecord1.Account__c = acObj.Id;
        AutomobilequoteRecord1.Underwriter__c ='Mapfre';
        AutomobilequoteRecord1.Coverage__c = 'Liability';
        AutomobilequoteRecord1.Vehicle_Value__c = 5000;
        AutomobilequoteRecord1.Term__c=  'Daily';
        AutomobilequoteRecord1.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        AutomobilequoteRecord1.Vehicle_Type__c = 'Automobile-Van-Minivan';
        AutomobilequoteRecord1.Liability__c = '200,000'; 
        AutomobilequoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert AutomobilequoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = AutomobilequoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile-Van-Minivan';
        policyrecord.Underwriter_picklist__c = 'Mapfre';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
        
        
        Quote__c RVquoteRecord = new Quote__c();
        RVquoteRecord.Start_Date_for_Coverage__c = date.today();
        RVquoteRecord.End_Date_for_Coverage__c = date.today()+5;
        RVquoteRecord.Driver_Age__c = 80;
        RVquoteRecord.Lead__c = ldObj.Id;
        RVquoteRecord.contact__c = conObj.Id;
        RVquoteRecord.Account__c = acObj.Id;
        RVquoteRecord.Underwriter__c ='Mapfre';
        RVquoteRecord.Coverage__c = 'Liability';
        RVquoteRecord.Vehicle_Value__c = 5000;
        RVquoteRecord.Term__c=  'Daily';
        RVquoteRecord.Policy_Type_picklist__c = 'RV';
        RVquoteRecord.Vehicle_Type__c = 'RV';
        RVquoteRecord.Liability__c = '200,000'; 
        RVquoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        RVquoteRecord.Is_there_a_driver_under_21__c = 'false';
        insert RVquoteRecord;
        
        Vehicle__c vehicaldata = new Vehicle__c();

// Basic info
vehicaldata.Name = 'Test Vehicle';

// Boolean fields
vehicaldata.Is_the_vehicle_registered_to_a_business__c = true;
vehicaldata.Rental__c = 'No';
vehicaldata.Salvage_Vehicle__c = false;
vehicaldata.Electric_Hybrid__c = false;

// Text / Picklist fields
vehicaldata.Year__c = '2022';
vehicaldata.Vehicle_Type__c = 'Motorhome';
vehicaldata.Make__c = 'BMW';
vehicaldata.Model__c = 'X7';
vehicaldata.Vin__c = 'TESTVIN123456789';
vehicaldata.Registered_Country__c = 'USA';
vehicaldata.Registered_State__c = 'California';
vehicaldata.Registered_Plate__c = 'AB123CD';

// Numeric fields
vehicaldata.Value__c = 25000;

// Parent relationship
insert vehicaldata;

// Quote-Vehicle linking
Quote_Vehicle__c quoteVehicle = new Quote_Vehicle__c();
quoteVehicle.Vehicle__c = vehicaldata.Id;
quoteVehicle.Quote_c__c = RVquoteRecord.Id;

insert quoteVehicle;
        
        Date testDate1 = system.today().addDays(10);
        Policy__c policyrecord1 = new policy__c();
        policyrecord1.Name = 'testPolicy';
        policyrecord1.Quote_c__c = RVquoteRecord.Id;
        policyrecord1.contact__c = conObj.id;
        policyrecord1.Policy_Type_picklist__c = 'RV';
        policyrecord1.Underwriter_picklist__c = 'Mapfre';
        policyrecord1.Territory_picklist__c = 'Full';
        policyrecord1.Package__c = 'Liability';
        policyrecord1.Term__c='Daily';
        policyrecord1.Start_Date__c= testDate;
        policyrecord1.End_Date__c = testDate1.addDays(20);
        policyrecord1.Liability_picklist__c = '200,000';
        policyrecord1.Medical_picklist__c = '10,000/50,000';
        policyrecord1.Surcharge__c = 15;
        policyrecord1.I_V_A_Mex_Tax__c = 35;
        policyrecord1.Net_Premium__c = 50;
        policyrecord1.Broker_Policy_Fee__c = null;
        policyrecord1.Total_Transaction_Amount__c =  110;
        policyrecord1.Package__c = 'Complete';
        insert policyrecord1;
        PoilcyEditController.calculateNewRate(AutomobilequoteRecord1);
        
        policyrecord.Quote_c__c = RVquoteRecord.Id;
        policyrecord.Vehicle_Policy__c = vehicaldata.Id;
        update policyrecord;
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
        policyrecord.Territory_picklist__c = 'Full';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Max';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
        
    }
   
    /*@IsTest
    static void motorQualitasTetstingPart(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        Quote__c motorquoteRecord1 = new Quote__c();
        motorquoteRecord1.Start_Date_for_Coverage__c = date.today();
        motorquoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        motorquoteRecord1.Driver_Age__c = 80;
        motorquoteRecord1.Lead__c = ldObj.Id;
        motorquoteRecord1.contact__c = conObj.Id;
        motorquoteRecord1.Account__c = acObj.Id;
        motorquoteRecord1.Underwriter__c ='Qualitas';
        motorquoteRecord1.Coverage__c = 'Liability';
        motorquoteRecord1.Vehicle_Value__c = 5000;
        motorquoteRecord1.Term__c=  'Daily';
        motorquoteRecord1.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        motorquoteRecord1.Vehicle_Type__c = 'Motorcycle/Street Legal ATV';
        motorquoteRecord1.Liability__c = '200,000'; 
        motorquoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert motorquoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = motorquoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyrecord.Underwriter_picklist__c = 'Qualitas';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
        
        PoilcyEditController.calculateNewRate(motorquoteRecord1);
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
        policyrecord.Territory_picklist__c = 'Full';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        policyrecord.Package__c = 'Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
        
    }
    
    @IsTest
    static void motorMapfreTetstingPart(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        Quote__c motorquoteRecord1 = new Quote__c();
        motorquoteRecord1.Start_Date_for_Coverage__c = date.today();
        motorquoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        motorquoteRecord1.Driver_Age__c = 80;
        motorquoteRecord1.Lead__c = ldObj.Id;
        motorquoteRecord1.contact__c = conObj.Id;
        motorquoteRecord1.Account__c = acObj.Id;
        motorquoteRecord1.Underwriter__c ='Mapfre';
        motorquoteRecord1.Coverage__c = 'Liability';
        motorquoteRecord1.Vehicle_Value__c = 5000;
        motorquoteRecord1.Medical__c = '10,000/50,000';
        motorquoteRecord1.Term__c=  'Daily';
        motorquoteRecord1.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        motorquoteRecord1.Vehicle_Type__c = 'Motorcycle/Street Legal ATV';
        motorquoteRecord1.Liability__c = '200,000'; 
        motorquoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert motorquoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = motorquoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyrecord.Underwriter_picklist__c = 'Mapfre';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
          List<Discount__c> discountList = new List<Discount__c>();
        
        for(integer i = 0; i <=  3; i++){
            Discount__c discount = new Discount__c();
            discount.Underwriter__c = 'Mapfre';
            discount.Daily_Discount__c = 0;
            if(i == 0){
                discount.No_of_Days__c = 90;
            }else if(i == 1){
                discount.No_of_Days__c = 180;
            }else if(i == 2){
                discount.No_of_Days__c = 365;
            }else{
                discount.No_of_Days__c = 11;
            }
            discountList.add(discount);
        }
        
        insert discountList;
          
        PoilcyEditController.calculateNewRate(motorquoteRecord1);
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
       
        policyrecord.Package__c = 'Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
       
    }
    
     @IsTest
    static void motorChubbTetstingPart(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        Quote__c motorquoteRecord1 = new Quote__c();
        motorquoteRecord1.Start_Date_for_Coverage__c = date.today();
        motorquoteRecord1.End_Date_for_Coverage__c = date.today()+5;
        motorquoteRecord1.Driver_Age__c = 80;
        motorquoteRecord1.Lead__c = ldObj.Id;
        motorquoteRecord1.contact__c = conObj.Id;
        motorquoteRecord1.Account__c = acObj.Id;
        motorquoteRecord1.Underwriter__c ='Chubb';
        motorquoteRecord1.Coverage__c = 'Liability';
        motorquoteRecord1.Vehicle_Value__c = 5000;
        motorquoteRecord1.Term__c=  'Daily';
        motorquoteRecord1.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        motorquoteRecord1.Vehicle_Type__c = 'Motorcycle/Street Legal ATV';
        motorquoteRecord1.Vehicle_Sub_type__c = 'Motorcycle';
        motorquoteRecord1.Liability__c = '200,000'; 
        motorquoteRecord1.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert motorquoteRecord1; 
        
        Date testDate = system.today().addDays(-10);
        Policy__c policyrecord = new policy__c();
        policyrecord.Name = 'testPolicy';
        policyrecord.Quote_c__c = motorquoteRecord1.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Territory_picklist__c = 'Limited';
        policyrecord.Term__c='Daily';
        policyrecord.Start_Date__c= testDate;
        policyrecord.End_Date__c = testDate.addDays(20);
        policyrecord.Liability_picklist__c = '200,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Surcharge__c = 15;
        policyrecord.I_V_A_Mex_Tax__c = 35;
        policyrecord.Net_Premium__c = 50;
        policyrecord.Broker_Policy_Fee__c = 10;
        policyrecord.Total_Transaction_Amount__c =  110;
        policyrecord.Package__c = 'Complete';
        insert policyrecord;
        
          
        PoilcyEditController.calculateNewRate(motorquoteRecord1);
        
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
       
        policyrecord.Package__c = 'Liability';
        update policyrecord;
        PoilcyEditController.refundCalculation(policyrecord.Id);
        
       
    }
    
    @isTest
    static void positivTetstingPart2(){
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        String leadString = '{ "Email": "testNewUser@gmail.com"}';
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today();
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Watercraft';
        quoteRecord.Vehicle_Type__c = 'Watercraft';
        quoteRecord.Liability__c = '200,000'; 
        quoteRecord.Third_Party_Bodily_Injury__c = '$250,000 / $500,000';
        quoteRecord.Property_Damage_Liability__c = '$250,000';
        quoteRecord.Type_of_Vessel__c = 'Powerboat/Yacht'; 
        quoteRecord.Vessel_Length__c = 'Between 27\' and 45\' long';
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        
        insert quoteRecord;  
        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Beam__c = 'beam';
        watercraft.Engine_Type__c = 'engine';
        watercraft.Flag__c = 'flag';
        watercraft.Make__c = 'make';
        watercraft.Model__c = 'model';
        watercraft.Type_of_Vessel__c = 'Sailboat';
        watercraft.VIN_Number__c = '1325';
        watercraft.Value__c = 1000;
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Year__c = '2000';
        watercraft.Lead__c = ldObj.Id;
        watercraft.Quote_c__c = quoteRecord.Id;
        List<driver__c> drvList = new List<driver__c>();
        driver__c driver = new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c = 'd';
        driver.Last_Name__c = 's';
        driver.email__c = 's@gmail.com';
        driver.Driver_Type__c = 'Owner';
        driver.Phone__c = '123';
        driver.Address__c = 'address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';
        drvList.add(driver);
        
      Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Homeowners';
        policyrecord.Start_Date__c = date.newInstance(2021, 03, 14);
        insert policyrecord;
        
          Date testDate1 = system.today().addDays(10);
        Policy__c policyrecord1 = new policy__c();
        policyrecord1.Name = 'testPolicy';
        policyrecord1.Quote_c__c = quoteRecord.Id;
        policyrecord1.contact__c = conObj.id;
        policyrecord1.Policy_Type_picklist__c = 'Watercraft';
        policyrecord1.Underwriter_picklist__c = 'Chubb';
        policyrecord1.Territory_picklist__c = 'Full';
        policyrecord1.Package__c = 'Liability';
        policyrecord1.Term__c='Daily';
        policyrecord1.Start_Date__c= testDate1;
        policyrecord1.End_Date__c = testDate1.addDays(20);
        policyrecord1.Liability_picklist__c = '200,000';
        policyrecord1.Surcharge__c = 15;
        policyrecord1.I_V_A_Mex_Tax__c = 35;
        policyrecord1.Net_Premium__c = 50;
        policyrecord1.Broker_Policy_Fee__c = 10;
        policyrecord1.Total_Transaction_Amount__c =  110;
        insert policyrecord1;
        
        
        list<Towed_Unit__c> towedList= new list<Towed_Unit__c>();
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='Yes';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towedList.add(towed);
        insert towedList;
        
        Vehicle__c vehicaldata = new Vehicle__c();
        vehicaldata.Name='test';
        vehicaldata.Make__c='BMW';
        vehicaldata.Year__c='2022';
        vehicaldata.Model__c='x7';
        vehicaldata.Value__c=2000;
        vehicaldata.Vin__c='test';
        vehicaldata.Vehicle_Type__c='Automobile-Van-Minivan';
        insert vehicaldata;
        Rate_Table__c rate = new Rate_Table__c();
        rate.Rental_Car__c =212;
        rate.Type__c='Automobile';
        insert rate;  
        PoilcyEditController.calculateNewRate(quoteRecord);
        PoilcyEditController.terminatedPolicy(policyrecord1.Id, 'policy purchased by mistake');
        
        
        Quote__c quoteRecordCreatePolicy = new Quote__c();
        quoteRecordCreatePolicy.Start_Date_for_Coverage__c = date.today();
        quoteRecordCreatePolicy.End_Date_for_Coverage__c = date.today()+5;
        quoteRecordCreatePolicy.Driver_Age__c = 80;
        quoteRecordCreatePolicy.Lead__c = ldObj.Id;
        quoteRecordCreatePolicy.contact__c = conObj.Id;
        quoteRecordCreatePolicy.Account__c = acObj.Id;
        quoteRecordCreatePolicy.Underwriter__c ='Chubb';
        quoteRecordCreatePolicy.Coverage__c = 'Liability';
        quoteRecordCreatePolicy.Term__c=  'Daily';
        quoteRecordCreatePolicy.Policy_Type_picklist__c = 'Watercraft';
        quoteRecordCreatePolicy.Vehicle_Type__c = 'Watercraft';
        quoteRecordCreatePolicy.Liability__c = '400,000';
        quoteRecordCreatePolicy.Third_Party_Bodily_Injury__c = '$250,000 / $500,000';
        quoteRecordCreatePolicy.Property_Damage_Liability__c = '$250,000';
        quoteRecordCreatePolicy.Type_of_Vessel__c = 'Powerboat/Yacht'; 
        quoteRecordCreatePolicy.Vessel_Length__c = 'Between 27\' and 45\' long'; 
        quoteRecordCreatePolicy.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert quoteRecordCreatePolicy;


        //PoilcyEditController.createPolicy(quoteRecord, quoteRecord.Id, false);
        PoilcyEditController.fetchPolicyInfo(policyrecord1.Id);
        PoilcyEditController.preViewPdfAction(policyrecord1.Id);
        PoilcyEditController.fetchEditPolicyAction(policyrecord1.Id);
        PoilcyEditController.createRenewQuoteAction(quoteRecord,quoteRecord.Id);
        PoilcyEditController.handleQuocteAction(quoteRecord);
        PoilcyEditController.createClonePolicy(quoteRecord,drvList,vehicaldata,towed,TestDataService.createtowed(),'Homeowners',quoteRecord.Id);
        PoilcyEditController.refundCalculation(policyrecord1.Id);
        PoilcyEditController.calculateNewRateForRefundFromRateTable(rate,30,quoteRecord);
        PoilcyEditController.getDependentMap(vehicaldata,'test','test');
        Test.stopTest();
    }
*/
}