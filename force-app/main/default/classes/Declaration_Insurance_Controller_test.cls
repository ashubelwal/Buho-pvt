@isTest
public class Declaration_Insurance_Controller_test {
    public static testMethod void Declaration_Page_Insurance_Controller(){ 
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        Watercraft__c watercraftrecord = new Watercraft__c();
        watercraftrecord.year__c = '2010';
        insert watercraftrecord;
        List <Driver__c> drive = new List <Driver__c>();
        for(integer i=0; i<2; i++){
            Driver__c drivers = new Driver__c ();
            if(i==0){
                drivers.Driver_Type__c = 'Owner';
            }else{
                drivers.Driver_Type__c = 'Driver';
            }            
            drivers.First_Name__c = 'test'+ i;
            drivers.Last_Name__c = 'test last'+ i;
            drivers.Address_Line_2__c = 'address line'+ i;
            drivers.Address__c = 'address line2'+ i;
            drive.add(drivers);
        }
        insert drive;
        /*Driver__c onlyDriver = new Driver__c();
        onlyDriver.Driver_Type__c = 'Driver';
        onlyDriver.First_Name__c = 'test Driver';
        onlyDriver.Last_Name__c = 'test Driver last';
        onlyDriver.Address_Line_2__c = 'Driver address line';
        onlyDriver.Address__c = 'Driver address line2';        
        insert onlyDriver;*/
        Account acc = new Account();
        acc.Name = 'testAccount';
        
        insert acc;
        
        Vehicle__c vehiclePolicy = new Vehicle__c();
        vehiclePolicy.Vehicle_Owner_Name__c = 'Test Owner';
        vehiclePolicy.Company_Name__c = 'Test company';
        vehiclePolicy.Vehicle_Owner_Address__c = 'Test address';
        vehiclePolicy.Company_Address__c = 'Test address';
        vehiclePolicy.Company_City__c = 'Test city';
        vehiclePolicy.Vehicle_Owner_City__c = 'Test city';
         vehiclePolicy.Vehicle_Owner_State__c = 'Test state';
         vehiclePolicy.Company_State__c = 'Test state';
        insert vehiclePolicy;
        
        Contact policyContact = new Contact();
        policyContact.FirstName = 'Test';
        policyContact.LastName = ' contact';
        policyContact.Street__c = 'Contact street';
        insert policyContact;
        
        Policy__c policyrecord=new policy__c();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        Time expected = Time.newInstance(4, 2, 3, 4);
        policyrecord.name='policy';
        policyrecord.Account_Policy__c = acc.Id;
        policyrecord.Policy_Type_picklist__c = 'Northbound';
        policyrecord.Start_Time__c =  myTime;
        policyrecord.End_Time__c =  expected;
        policyrecord.Watercraft__c = watercraftrecord.Id;
        policyRecord.Medical_picklist__c = '2,000/10,000';
        policyrecord.Vehicle_Policy__c = vehiclePolicy.Id;
        policyrecord.Contact__c = policyContact.Id;
        insert policyrecord;
        Quote__c quotes = new Quote__c ();
        date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
        insert quotes;
        
        
        List <Quote_Driver__c> quotedrive = new List <Quote_Driver__c>();
        for(integer i= 0; i<drive.size(); i++){
            Quote_Driver__c quotedriver = new Quote_Driver__c();
            quotedriver.Driver__c = drive[i].Id;
            quotedriver.Quote_c__c = quotes.id;
            quotedriver.Policy__c = policyrecord.id ;
            quotedrive.add(quotedriver);  
        }
        insert quotedrive;
        test.startTest();
        PageReference pgRef = Page.Declaration_Page_Insurance; 
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', policyrecord.Id);
        // System.currentPageReference().getParameters().put('params', 'CRLAL-22-DXQL4');
        Declaration_Page_Insurance_Controller controller = new Declaration_Page_Insurance_Controller() ; 
        test.stopTest();   
    }
    public static testMethod void getFormattedStartTime_Method(){
        test.startTest();
        PageReference pgRef = Page.Declaration_Page_Insurance; 
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', '00B1C000008UeA61');
        Declaration_Page_Insurance_Controller decl = new Declaration_Page_Insurance_Controller();
        decl.getFormattedStartTime();
        test.stopTest();  
    }
    public static testMethod void getFormattedEndTime_Method(){
        test.startTest();      
        Declaration_Page_Insurance_Controller decl = new Declaration_Page_Insurance_Controller();
        decl.getFormattedEndTime();
        test.stopTest();  
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
        String data = Mex_NewLeadProcess.createPolicy(leadData.Id);
        Map<String,Object> mapData = (Map<String,Object>) JSON.deserializeUntyped(data);
        String polId = (String) mapdata.get('PolicyId'); 
        PageReference pgRef = Page.Declaration_Page_Insurance; 
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', polId);
        Declaration_Page_Insurance_Controller controller = new Declaration_Page_Insurance_Controller() ; 
        Test.stopTest();
    }
     @isTest static void createPolicyTest2() {
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
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"},{"First_Name__c":"tesxztdev","Last_Name__c":"nesdw","Email__c":"tesdstdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Driver","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
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
        PageReference pgRef = Page.Declaration_Page_Insurance; 
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', polId);
        Declaration_Page_Insurance_Controller controller = new Declaration_Page_Insurance_Controller() ; 
        Test.stopTest();
    }
    
}