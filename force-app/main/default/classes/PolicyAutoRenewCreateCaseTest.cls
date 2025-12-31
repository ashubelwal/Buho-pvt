@isTest
public class PolicyAutoRenewCreateCaseTest {
	@isTest
    public static void testCreateCase(){
        Lead leadData = new Lead();
        leadData.FirstName = 'Dev';
        leadData.LastName = 'Test';
        leadData.Company = 'XYZ Corp.';
        leadData.Email = 'teghfgsddt@thtfgdfeeedrfest.com';
        leadData.IsConverted = false;
        leadData.Is_towing__c = true;
        leadData.Lienholder_info__c = '{"Lienholder_name__c":"erte","Lienholder_Phone__c":"rrer","Lienholder_Street__c":"ere","Lienholder_Fax__c":"ere","Lienholder_Street_2__c":"ttere","Lienholder_Country__c":"yes","Lienholder_State__c":"erere","Lienholder_City__c":"erwe","Lienholder_Postal_Code__c":"fgfdgfdgfdgfdfdgd"}';
        leadData.Company_details__c = '{"Company_Name__c":"fghfg","Company_Phone__c":"2345","Company_Country__c":"no","Tax_ID__c":"3456","Company_State__c":"no","Company_City__c":"dfgfdg","Company_Zip__c":"235","Company_Address__c":"dfgdf"}';
        leadData.Terms_Alert__c = '{"Terms_of_Purchase_Confirmed__c":true,"Terms_of_Cancellation_Confirmed__c":true}';
        leadData.Vehicle_details__c = '{"Is_Account_Company_Named__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Year__c":"2020","Make__c":"Acura","Model__c":"MDX","Value__c":"10000","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vin__c":"VIN1234NUMB","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","Registered_Plate__c":"SDHFFFHD","Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Vehicle_sub_type__c":"Automobile/Sedan","Coverage__c":"Complete"}';
        leadData.Towing__c = '[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Camper","Street_Legal__c":"no"}]';
        leadData.Term_options__c = '{"Start_Date__c":"2022-09-30","Start_Time__c":"00:00:00.000Z","End_Time__c":"00:00:00.000Z","End_Date__c":"2022-10-07","term__c":"Annual(One Year)","Start_Date_for_Coverage__c":"2023-01-18","End_Date_for_Coverage__c":"2024-01-18"}';
        leadData.Driver_details__c = '[{"First_Name__c":"testdev","Last_Name__c":"new","Email__c":"testdev@new.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"address","City__c":"city","Postal_Code__c":"00180","License_Country__c":"United States","Country__c":"United States","License_state__c":"Arizona","State_Province__c":"Arizona","license_number__c":"LicenseNumber","Dob__c":"1985-07-07"}]';
        insert leadData;

        Database.LeadConvert leadConvertInst = new Database.LeadConvert();
        leadConvertInst.setLeadId(leadData.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
                
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
        
        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = leadData.Id;
       
        insert vehicle;
        
         List<driver__c> drivers = new List<driver__c>();
        driver__c driver =new driver__c();
        driver.lead__c = leadData.id;
        driver.Contact__c =  leadConvertRslt.getContactId();
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
        driver.License_state__c='Arizona';
        driver.State_Province__c = 'Arizona';
        driver.license_number__c = 'LicenseNumber';
        driver.Dob__c = date.newInstance(1985,7,7);
        
        
        insert driver;
        TriggerSwitch__c TriggerSwitch = new TriggerSwitch__c();
        TriggerSwitch.Name = 'PolicyTrigger'; 
        TriggerSwitch.Active__c = false;   
        insert TriggerSwitch;
        
        Policy__c policy = new Policy__c();
        policy.Policy_Type_picklist__c = 'Automobile';
        policy.End_Date__c = date.today().addDays(0);
        policy.Start_Date__c =date.today().addDays(-365);
        policy.Total_Transaction_Amount__c = quoteData2.Quote_Value__c;
        policy.Term__c = 'Annual(One Year)';
        policy.Quote_c__c = quoteData2.Id;
        policy.Auto_Renew_Confirmed__c = true;
        policy.Auto_renew__c = true;
        policy.Updated_Quote_Json__c = '';
        policy.Renew_Payment_Profile_Id__c = '22222';
        policy.Name = 'Test';
        policy.Contact__c = leadConvertRslt.getContactId();
        policy.Updated_Quote_Json__c = '{"Vehicle_Value__c":"5100","Medical__c":"10,000/50,000","Liability__c":"500,000"}';
        insert policy;
        
        Policy__c policy1 = new Policy__c();
        policy1.Policy_Type_picklist__c = 'Watercraft';
        policy1.End_Date__c = date.today().addDays(0);
        policy1.Start_Date__c =date.today().addDays(-365);
        policy1.Total_Transaction_Amount__c = quoteData2.Quote_Value__c;
        policy1.Term__c = 'Annual(One Year)';
        policy1.Quote_c__c = quoteData2.Id;
        policy1.Auto_Renew_Confirmed__c = true;
        policy1.Auto_renew__c = true;
        policy1.Updated_Quote_Json__c = '';
        policy1.Renew_Payment_Profile_Id__c = '22222';
        policy1.Name = 'Test';
        policy1.Contact__c = leadConvertRslt.getContactId();
        policy1.Updated_Quote_Json__c = '{"Vehicle_Value__c":"5100","Medical__c":"10,000/50,000","Liability__c":"500,000"}';
        insert policy1;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, leadConvertRslt.getContactId());
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        System.debug('paymentProfile--'+paymentProfile);
        System.debug('customerProfile--'+customerProfile);
        Id quoteId = quoteData2.Id;
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteId, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        

        Quote_Driver__c quoteDriver = new Quote_Driver__c();
        quoteDriver.Quote_c__c = quoteData2.Id;
        quoteDriver.Account_Driver__c = leadConvertRslt.getAccountId();
        quoteDriver.Contact__c = leadConvertRslt.getContactId();
        quoteDriver.Driver__c = driver.Id;
        quoteDriver.Vehicle_Driver__c = vehicle.Id;
        quoteDriver.Policy__c = policy.id;
        insert quoteDriver;
        
         Quote_Vehicle__c newQuoteVehicle = new Quote_Vehicle__c();
        newQuoteVehicle.Account__c = leadConvertRslt.getAccountId();
        newQuoteVehicle.Contact__c = leadConvertRslt.getContactId();
        newQuoteVehicle.Quote_c__c = quoteData2.Id;
        newQuoteVehicle.Vehicle__c = vehicle.Id;
        newQuoteVehicle.Policy__c = policy.id;
        insert newQuoteVehicle;
        
         Quote__c quoteData = new Quote__c();
        quoteData.Underwriter__c = 'Qualitas';
        quoteData.Lead__c = leadData.Id;
        quoteData.Territory__c = 'Limited';
        quoteData.Coverage__c = 'Complete';
        quoteData.Term_Days__c = 365.0;
        quoteData.Medical__c = '10,000/50,000';
        quoteData.Is_this_a_Rental_Vehicle__c = false;
        quoteData.Policy_Type_picklist__c = 'Automobile';
        quoteData.Underwriter__c = 'Mapfre';
        quoteData.End_Date_for_Coverage__c = date.parse('11/29/2023');
        quoteData.Start_Date_for_Coverage__c = date.parse('11/29/2023');
        quoteData.Vehicle_Model__c = 'MDX';
        quoteData.Towed_Unit__c = 'No';
        quoteData.Vehicle_used_for_Business_Purposes__c = false;
        quoteData.Net_Premium__c = 258.367878;
        quoteData.End_Time__c = endtimeChange;
        quoteData.Start_Time__c = starttimeChange;
        quoteData.Salvage_Vehicle__c = 'No';
        quoteData.Vehicle_Make__c = 'Acura';
        quoteData.Liability__c = '300,000';
        quoteData.Vehicle_Value__c = 10000.00;
        quoteData.Broker_Policy_Fee__c = 30.00;
        quoteData.Vehicle_Year__c = '2020';
        quoteData.Term__c = 'Annual(One Year)';
        quoteData.I_V_A_Mex_Tax__c = 41.338;
        quoteData.Is_there_a_driver_under_21__c = 'No';
        quoteData.Quote_Value__c = 329.70;
        quoteData.Surcharge__c = 0.00;
        insert quoteData;
        
        Map<Id,Object> failedTransacation = new Map<Id,Object>(); 
        failedTransacation.put(policy.Id, 'Error12');
        Test.startTest();
        PolicyAutoRenewCreateCase.createCase(failedTransacation);
        Test.stopTest();
    }
}