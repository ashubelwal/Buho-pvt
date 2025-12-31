@isTest
public class Mex_NewLeadProcessTest {
    @isTest static void positiveTest() {
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        Lead leadData = new Lead();
        leadData.Email = 'tgfgfest@tfgfgst.com';
        leadData.Policy_Type__c = 'Automobile';
        
        Quote__c quoteData = new Quote__c();
        quoteData.Underwriter__c = 'Chubb';
        

        
        Test.startTest();
        
        Mex_NewLeadProcess.getTimeZone();
        Mex_NewLeadProcess.checkalreadyExistUserAction(JSON.serialize(leadData));
        Mex_NewLeadProcess.getDateForQuoteScreen('00Q8M000002uYTnUGJ', 'newLead');
        Mex_NewLeadProcess.insertNewQuotes(JSON.serialize(quoteData), '00Q8M000002uYTnUGJ');
        Mex_NewLeadProcess.sendEmailQuoteDetails('00Q8M000002uYTnUGJ');
        Mex_NewLeadProcess.fetchDataFromLead('00Q8M000002uYTnUGJ', 'Quote_Details__c');
        Mex_NewLeadProcess.getQuoteDataToContinueQuote(quoteData.Id);
        //Mex_NewLeadProcess.createWaterCraftPolicy('00Q8M000002uYTnUGJ');
        //Mex_NewLeadProcess.createPolicy('00Q8M000002uYTnUGJ');
       
        
        Test.stopTest();
    }
    @isTest static void negativeTest() {
        // Lead...
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'teffgst@tefdfddst.com';
        leadData.Phone = '6745344';
        leadData.IsConverted = false;
        leadData.Term_options__c = '{"Start_Date__c":"2022-09-30","Start_Time__c":"00:00:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2022-10-07","term__c":"Annual(One Year)","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Watercraft_Detail__c = '{"Type_of_Vessel__c":"Powerboat","Vessel_Length__c":"Less than 27\' long","Year__c":"2024","Make__c":"MAKE","Model__c":"testModel","Value__c":"5000","Any_Boat_Operator_Under_22__c":"No","Is_the_Maximum_Speed_more_than_50_mph__c":"No","Is_the_owner_living_in_Mexico__c":"No","Dob__c":"1936-04-02"}';
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;
        
        // Contact...
        Contact cntData = new Contact();
        cntData.LastName = 'Test';
        cntData.Email = 'tgfgest@tefgst.com';
        cntData.Phone = '7575643';
        insert cntData;
        
        // Quote...
        Quote__c quoteData = new Quote__c();
        quoteData.Underwriter__c = 'Chubb';
        
        Quote__c quoteData2 = new Quote__c();
        quoteData2.Underwriter__c = 'Qualitas';
        quoteData2.Lead__c = leadData.Id;
        quoteData2.Contact__c = cntData.Id;
        quoteData2.Territory__c = 'Limited';
        quoteData2.Coverage__c = 'Complete';
        quoteData2.Term_Days__c = 365.0;
        quoteData2.Medical__c = '10,000/50,000';
        quoteData2.Is_this_a_Rental_Vehicle__c = false;
        quoteData2.Policy_Type_picklist__c = 'Watercraft';
        quoteData2.Lead__c = leadData.Id;
        insert quoteData2;
        
        leadData.Quote_Details__c = JSON.serialize(quoteData2);
        update leadData;
        
        Test.startTest();
        Mex_NewLeadProcess.checkalreadyExistUserAction(JSON.serialize(leadData));
        Mex_NewLeadProcess.getDateForQuoteScreen(leadData.Id, 'newLead');
        Mex_NewLeadProcess.insertNewQuotes(JSON.serialize(quoteData), leadData.Id);
        Mex_NewLeadProcess.sendEmailQuoteDetails(quoteData2.Id);
        Mex_NewLeadProcess.fetchDataFromLead(leadData.Id, 'Quote_Details__c');
        Test.stopTest();
    }
    
    @isTest static void createWaterCraftPolicyTest() {
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        //Lead...
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'tddest@tvfevttrest.com';
        leadData.IsConverted = false;
        leadData.Phone = '234432';
        leadData.Term_options__c = '{"Start_Date__c":"2022-09-30","Start_Time__c":"00:00:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2022-10-07","term__c":"Annual(One Year)","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Watercraft_Detail__c = '{"Type_of_Vessel__c":"Powerboat","Vessel_Length__c":"Less than 27\' long","Year__c":"2024","Make__c":"MAKE","Model__c":"testModel","Value__c":"5000","Any_Boat_Operator_Under_22__c":"No","Is_the_Maximum_Speed_more_than_50_mph__c":"No","Is_the_owner_living_in_Mexico__c":"No","Dob__c":"1936-04-02"}';
        leadData.Driver_details__c = '[{"First_Name__c":"teggfstdev","Last_Name__c":"new","Email__c":"testgfdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;
        
        //Account...
        Account testAccount = new Account(
            Name = 'Test Account',
            Email__c = 'tddest@tvfevttrest.com'
        );
        insert testAccount;
        
        // Contact...
        Contact cntData = new Contact();
        cntData.LastName = 'Test';
        cntData.Email = 'tegdsst@test.com';
        cntData.Phone = '345224';
        cntData.AccountId=testAccount.Id;
        insert cntData;
        
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
        quoteData2.Contact__c = cntData.Id;
        quoteData2.Territory__c = 'Limited';
        quoteData2.Coverage__c = 'Complete';
        quoteData2.Term_Days__c = 365.0;
        quoteData2.Medical__c = '10,000/50,000';
        quoteData2.Is_this_a_Rental_Vehicle__c = false;
        quoteData2.Policy_Type_picklist__c = 'Watercraft';
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
        
        leadData.Quote_Details__c = JSON.serialize(quoteData2);
        update leadData;
        
        // Transaction...
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quoteData2.Id;
        insert trans;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        Mex_NewLeadProcess.createWaterCraftPolicy(leadData.Id);
        Test.stopTest();
    }
    
    @isTest static void createPolicyTest() {
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
        Mex_NewLeadProcess.createPolicy(leadData.Id);
        
        Test.stopTest();
    }
    
    @isTest static void createPolicydsdswithUnkTest() {
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        //Lead...
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'teghfgsddt@thtfgdfeeedrfest.com';
        leadData.IsConverted = false;
        leadData.Phone = '4564353';
        leadData.Is_towing__c = true;
        leadData.Lienholder_info__c = '{"Lienholder_name__c":"erte","Lienholder_Phone__c":"rrer","Lienholder_Street__c":"ere","Lienholder_Fax__c":"ere","Lienholder_Street_2__c":"ttere","Lienholder_Country__c":"yes","Lienholder_State__c":"erere","Lienholder_City__c":"erwe","Lienholder_Postal_Code__c":"fgfdgfdgfdgfdfdgd"}';
        leadData.Company_details__c = '{"Company_Name__c":"fghfg","Company_Phone__c":"fghgf","Company_Country__c":"no","Tax_ID__c":"fgdgf","Company_State__c":"no","Company_City__c":"dfgfdg","Company_Zip__c":"dgdf","Company_Address__c":"dfgdf"}';
        leadData.Terms_Alert__c = '{"Terms_of_Purchase_Confirmed__c":true,"Terms_of_Cancellation_Confirmed__c":true}';
        leadData.Vehicle_details__c = '{"Is_Account_Company_Named__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Year__c":"2020","Make__c":"Acura","Model__c":"MDX","Value__c":"10000","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vin__c":"VIN1234NUMB","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","Registered_Plate__c":"SDHFFFHD","Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Vehicle_sub_type__c":"Automobile/Sedan","Coverage__c":"Complete"}';
        leadData.Towing__c = '[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Camper","Street_Legal__c":"no"}]';
        leadData.Term_options__c = '{"Start_Date__c":"2022-09-30","Start_Time__c":"00:00:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2022-10-07","term__c":"Annual(One Year)","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;

        Contact conn = new Contact();
        conn.FirstName = 'Dev';
        conn.LastName = 'Test';
        conn.Email = 'teghfgsddt@thtfgdfeeedrfest.com';
        conn.Phone = '786786';
        insert conn;
        
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
        
        leadData.Quote_Details__c = JSON.serialize(quoteData2);
        update leadData;
        system.debug('--leadData--'+ leadData);
        
        // Transaction...
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quoteData2.Id;
        insert trans;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        Mex_NewLeadProcess.createPolicy(leadData.Id);
        Test.stopTest();
    }
    
     @isTest static void createPolicywithUnkTest() {
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        //Lead...
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'teghfgst@thtfgdfeeedrfest.com';
        leadData.Phone = '5675643';
        leadData.IsConverted = false;
        leadData.Is_towing__c = true;
        leadData.Lienholder_info__c = '{"Lienholder_name__c":"erte","Lienholder_Phone__c":"rrer","Lienholder_Street__c":"ere","Lienholder_Fax__c":"ere","Lienholder_Street_2__c":"ttere","Lienholder_Country__c":"yes","Lienholder_State__c":"erere","Lienholder_City__c":"erwe","Lienholder_Postal_Code__c":"fgfdgfdgfdgfdfdgd"}';
        leadData.Company_details__c = '{"Company_Name__c":"fghfg","Company_Phone__c":"fghgf","Company_Country__c":"no","Tax_ID__c":"fgdgf","Company_State__c":"no","Company_City__c":"dfgfdg","Company_Zip__c":"dgdf","Company_Address__c":"dfgdf"}';
        leadData.Terms_Alert__c = '{"Terms_of_Purchase_Confirmed__c":true,"Terms_of_Cancellation_Confirmed__c":true}';
        leadData.Vehicle_details__c = '{"Is_Account_Company_Named__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Year__c":"2020","Make__c":"Acura","Model__c":"MDX","Value__c":"10000","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vin__c":"VIN1234NUMB","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","Registered_Plate__c":"SDHFFFHD","Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Vehicle_sub_type__c":"Automobile/Sedan","Coverage__c":"Complete"}';
        leadData.Towing__c = '[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Camper","Street_Legal__c":"no"}]';
        leadData.Term_options__c = '{"Start_Date__c":"2022-09-30","Start_Time__c":"00:00:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2022-10-07","term__c":"Annual(One Year)","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;
        
        Account ac = new Account();
        ac.Name = 'Dev Test';
        ac.Email__c = 'teghfgst@thtfgdfeeedrfest.com';
        insert ac;
        Contact conn = new Contact();
        conn.FirstName = 'Dev';
        conn.LastName = 'Test';
        conn.Email = 'teghfgst@thtfgdfeeedrfest.com';
        conn.Phone = '4323432';
        conn.AccountId = ac.Id;
        insert conn;
        
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
        
        leadData.Quote_Details__c = JSON.serialize(quoteData2);
        update leadData;
        system.debug('--leadData--'+ leadData);
        
        // Transaction...
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quoteData2.Id;
        insert trans;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        Mex_NewLeadProcess.createPolicy(leadData.Id);
        Test.stopTest();
    }
    
    @istest static void continueQuoteTest() {
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Profile profileid = [SELECT Id FROM Profile WHERE userType = 'Guest' LIMIT 1];  
        /*id pid ;
        for(Profile k:profileId)
        {
          pid = k.id;  
        }*/
          
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact',Phone = '5644324');
        insert testContact;
        
        User myuser = new user();
        myuser.LastName = 'Test Code';
        myuser.Email = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.Alias = 'Tcode';
        myuser.Username = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.CommunityNickname = 'test12';
        myuser.LocaleSidKey = 'en_US';
        myuser.TimeZoneSidKey = 'GMT';
        myuser.ProfileID =profileid.Id;
        myuser.LanguageLocaleKey = 'en_US';
        myuser.EmailEncodingKey = 'UTF-8';
        insert myuser;

        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        ldObj.Phone = '2343443';
        insert ldObj; 

        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.lead__c = ldObj.Id;
        quoteRecord.End_Date_for_Coverage__c= system.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Northbound';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='2,000/10,000';
        quoteRecord.Liability__c='100,000'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);

        insert quoteRecord;
        
        Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Automobile';
        rate.Days__c = 10;
        rate.Trailering_Surcharge__c = 35;
        rate.IVA_Mex_Tax__c = 100;
        rate.Underwriter__c = quoteRecord.Underwriter__c;
        rate.Age_of_Vehicle_Surcharge_25_years_old__c = 10;
        rate.Age_of_Vehicle_Surcharge__c = 25; 
        rate.Age_of_Operator_Surcharge__c = 20;
        rate.Risk_3_Third_Party_Liability_Insured_Sum__c = '100,000';
        rate.Days__c = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
        rate.Term__c = 'Daily';//have to take care of this and quoteObject.Policy_Type_picklist__c == 'Driver License'
        rate.Underwriter__c = quoteRecord.Underwriter__c;
        rate.Direction__c =quoteRecord.Policy_Type_picklist__c;
        insert rate; 

        String leadString = '{ "Email": "testNewUser@gmail.com"}';

        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = ldObj.Id;
        insert vehicle;

        Watercraft__c wtr = new Watercraft__c();
        wtr.Make__c = 'daw';
        wtr.Model__c = 'model';
        wtr.Year__c = '2019';
        insert wtr;

        driver__c driver =new driver__c();
        driver.lead__c = ldObj.id;
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
        insert driver;
        
        Quote_Vehicle__c qvrec = new Quote_Vehicle__c();
        qvrec.Lead__c = ldObj.Id;
        qvrec.Quote_c__c = quoteRecord.Id;
        qvrec.Vehicle__c = vehicle.id;
        insert qvrec;
        
        Quote_Driver__c qdrec= new Quote_Driver__c();
        qdrec.Lead__c = ldObj.Id;
        qdrec.Quote_c__c = quoteRecord.Id;
        qdrec.Driver__c = driver.Id;
        qdrec.Vehicle_Driver__c = vehicle.Id;
        qdrec.Watercraft__c = wtr.Id;
        insert qdrec;

        Quote_Watercraft__c qwrec = new Quote_Watercraft__c();
        qwrec.Lead__c = ldObj.Id;
        qwrec.Quote_c__c = quoteRecord.Id;
        qwrec.Watercraft__c = wtr.Id;
        insert qwrec;

        Authorize_Net_Customer_Profile__c auth=new Authorize_Net_Customer_Profile__c();
        auth.Quote__c=quoteRecord.id;
        insert auth;
          
        Subscription__c subs = new Subscription__c();
        subs.quote__c=quoteRecord.id;
        insert subs;

        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c= quoteRecord.id;
        insert trans;
		
        
        Vehicle__c vehicle1 = new Vehicle__c(Contact__c = testContact.Id, Vehicle_Type__c = 'Automobile/Sedan');
        Vehicle__c vehicle2 = new Vehicle__c(Contact__c = testContact.Id, Vehicle_Type__c = 'SUV');
        List<Vehicle__c> vList = new List<Vehicle__c>();
        insert vehicle1;
        insert vehicle2;
        vList.add(vehicle1);
        vList.add(vehicle2);
        
        test.startTest();
        system.runAs(myuser){
          Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            Mex_NewLeadProcess.getQuoteDataToContinueQuote(quoteRecord.Id);
            Mex_NewLeadProcess.getCurrentUserVehicles('Automobile');
            Mex_NewLeadProcess.getCurrentUserVehicles('Motorcycle/Street Legal ATV');
            Mex_NewLeadProcess.getCurrentUserVehicles('RV');
            
            List<Vehicle__c> vehicles = Mex_NewLeadProcess.getCurrentUserVehicles('Automobile');
            System.assertNotEquals(null, vList, 'The vehicles list should not be null');
            System.assertEquals(2, vList.size(), 'The vehicles list should contain two vehicles');
           
        }
        test.stopTest();
    }
}