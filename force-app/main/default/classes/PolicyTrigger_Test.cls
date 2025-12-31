@isTest
public class PolicyTrigger_Test {
        
   @testSetup
    static void setupTestData() {
                        // Create an Agency and Agent Contact
        Contact agency = new Contact(LastName = 'Test Agency');
        insert agency;
        
        Contact agent = new Contact(LastName = 'Test Agent');
        insert agent;
        
        System.debug('Custom Labels: ' + Label.Prefilled_Agency + ' ' + Label.Prefilled_Agent_Id);

    }
  
    
    @isTest
    static void testUpdateAgentAgency() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
           // Create a role for the test user
        UserRole testRole = [SELECT Id FROM UserRole LIMIT 1];

        // Create a user with the profile and role needed for the test
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'MexInsurance Profile' LIMIT 1];
        User communityUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserName = 'testuser6565656111123@example.com'
        );
        insert communityUser;
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'MexInsurance Profile' LIMIT 1];
        System.runAs(testUser) {
               PolicyTrigger_Test.testPaymentThroughCard();     
        }
    }
        @isTest
    public static void testPaymentThroughCard(){
        
        String leadJson = '{"FirstName":"Test Two","LastName":"Data","Email":"test5testClass@data.com","Phone":"1234567890","Liability__c":false,"Policy_Type__c":"Automobile-Van-Minivan","Is_towing__c":false}';
        String quoteJson = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile-Van-Minivan","Term__c":"Semi-Annual"}';
        String vehicleJson = '{"Vehicle_sub_type__c":"Automobile/Sedan","Year__c":"2023","Make__c":"Acura","Model__c":"Integra","Value__c":"8000","Coverage__c":"Complete","Is_there_a_driver_under_21__c":false,"Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_this_a_Rental_Vehicle__c":false,"Vehicle_Type__c":"Car/Truck/Auto","Lienholder_name__c":"","Lienholder_Country__c":"","Lienholder_Postal_Code__c":"","Lienholder_State__c":"","Lienholder_City__c":"","Lienholder_Street__c":"","Lienholder_Phone__c":"","Is_Lienholder__c":false,"Is_vehicle_owned_by_a_company_or_rented__c":false,"Company_Name__c":"","Company_Country__c":"","Company_Zip__c":"","Company_State__c":"","Company_City__c":"","Company_Address__c":"","Company_Phone__c":""}';
        String towedJson = '';
        // Create a map with proper boolean values
        Map<String, Object> termsAndAlertsMap = new Map<String, Object>{
            'Terms_of_Cancellation_Confirmed__c' => true,
                'Terms_of_Purchase_Confirmed__c' => true
                };
                    
                    // Serialize the map into a JSON string
                    String termsAndAlerts = JSON.serialize(termsAndAlertsMap);
        System.debug(termsAndAlerts);
        String quoteGenerate = '{"Start_Date_for_Coverage__c":"2023-10-11","End_Time__c":"03:45:00","Start_Time__c":"03:45:00","End_Date_for_Coverage__c":"2024-04-08","Vehicle_used_for_Business_Purposes__c":false,"Is_there_a_driver_under_21__c":"No","Is_this_a_Rental_Vehicle__c":false,"Vehicle_Make__c":"Acura","Vehicle_Model__c":"Integra","Salvage_Vehicle__c":"No","Vehicle_Value__c":"8000","Vehicle_Type__c":"Automobile-Van-Minivan","Vehicle_sub_type__c":"Automobile-Van-Minivan","Vehicle_Year__c":"2023","Territory__c":"Baja/Sonora","Policy_Type_picklist__c":"Automobile","Term__c":"Semi-Annual","Net_Premium__c":184.2876,"Broker_Policy_Fee__c":20,"Term_Days__c":"180","I_V_A_Mex_Tax__c":29.486016,"Quote_Value__c":233.773616,"Underwriter__c":"Mapfre","Coverage__c":"Complete","Towed_Unit__c":"No","Vehicle_deductible_collision__c":"500","Vehicle_deductible_comprehensive__c":"1000","Physical_Damage__c":"","Total_Theft_Payment__c":"","Liability_Payment__c":"","Medical_Payment__c":"","Platinum_Endorsment__c":"","Liability__c":"300,000","Medical__c":"5,000/25,000"}';
        
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
        //insert conObj;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
       // policyrecord.Quote_c__c = quoteRecord.Id;
       // policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        insert policyrecord;
    }
   
    @isTest
    public static void validatePolicyTrigger(){
        TriggerSwitch__c  objTriggerSwitch = new TriggerSwitch__c ();
        objTriggerSwitch.Name='PolicyTrigger';
        objTriggerSwitch.Active__c= true;
        insert objTriggerSwitch;
        
        Account objAccount = new Account();
        objAccount.name='Test Account';
        objAccount.Email__c='sks18889@gmail.com';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Contact objContact2 = new Contact();
        objContact2.LastName = 'Test2';
        objContact2.AccountId = objAccount.Id;
        insert objContact2;
        
        Test.startTest();
            Policy__c objPolicy = new Policy__c();
            objPolicy.Name = 'test policy';
        	objPolicy.Account_Policy__c= objAccount.id;
        	objPolicy.Contact__c = objContact.Id;
            insert objPolicy;
            
            objPolicy.Vehicle_type__c = 'Test';
            update objPolicy;
            objPolicy.Contact__c = objContact2.Id;
            update objPolicy;
            
            delete objPolicy;
            
            undelete objPolicy;
        
        	Database.executeBatch(new UpdateContactFromPolicyBatch());	
        
        test.stopTest();        
    }
    
    @isTest
    public static void updateContactDestionationsTest(){
        TriggerSwitch__c  objTriggerSwitch = new TriggerSwitch__c ();
        objTriggerSwitch.Name='PolicyTrigger';
        objTriggerSwitch.Active__c= true;
        insert objTriggerSwitch;
        
        Account objAccount = new Account();
        objAccount.name='Test Account';
        objAccount.Email__c='sks18889@gmail.com';
        insert objAccount;
        Contact objContact2 = new Contact();
        objContact2.LastName = 'Test2';
        objContact2.AccountId = objAccount.Id;
        objContact2.Policy_Destinations__c = 'Mexico City';
        insert objContact2;
        Test.startTest();
        
        Quote__c quote = new Quote__c();
        insert quote;
        
        Policy__c objPolicy = new Policy__c();
        objPolicy.Name = 'test policy';
        objPolicy.Account_Policy__c= objAccount.id;
        objPolicy.Contact__c = objContact2.Id;
        //objPolicy.What_is_your_trip_destination_in_US__c = 'Other';
        objPolicy.renewed_check__c = true;
        objPolicy.Quote_c__c = quote.Id;
        insert objPolicy;
        List<Policy__c> policyList = new List<Policy__c>();
        policyList.add(objPolicy);
        
        Transaction__c trans = new Transaction__c();
        trans.Policy_Transaction__c = objPolicy.Id;
        trans.Quote_c__c = quote.Id;
        insert trans;
        
        PolicyTrigger_Handler.updateContactDestionations(policyList);
        Test.stopTest(); 
        
    }
}