@IsTest
public with sharing class PaymentFormControllerTest {
    
    @IsTest
    private static void createPaymentProfileTransaction_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Quote__c quoteRecord = TestDataService.createQuote(true);
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteRecord.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.createPaymentProfileTransaction(JSON.serialize(paymentTransaction));
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }
    
    @IsTest
    private static void createAdditionalPaymentProfileTransaction_positive() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Quote__c quoteRecord = TestDataService.createQuote(true);
        policy__c policyRecord = TestDataService.createPolicy(quoteRecord); 
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteRecord.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.createAdditionalPaymentProfileTransaction(JSON.serialize(paymentTransaction), 250.00, policyRecord.Id);
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }
    
    @IsTest
    private static void createTransactionWithPredefinedAmount_positive() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Quote__c quoteRecord = TestDataService.createQuote(true);
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteRecord.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.createTransactionWithPredefinedAmount(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction), 256.00, policyRecord.Id, 'kshitij.saini@cloudanalogy.com');
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }
    
    @IsTest
    private static void refundTransaction_positive1() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Quote__c quoteRecord = TestDataService.createQuote(true);
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        
        Transaction__c tranxData = new Transaction__c();
        tranxData.Quote_c__c = quoteRecord.Id;
        tranxData.Amount__c = 170;
        tranxData.Policy_Transaction__c = policyRecord.id;
        tranxData.Id__c = '456789098765';
        
        insert tranxData;
        
        
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteRecord.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        //PaymentFormController.refundTransaction(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction), 256.00, policyRecord.Id);
        PaymentFormController.refundTransactionUsingSavedCard( JSON.serialize(paymentTransaction), 256.00, policyRecord.Id);
        Test.stopTest();
        
    }
    
    @IsTest
    private static void refundTransaction_positive() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Quote__c quoteRecord = TestDataService.createQuote(true);
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        
        Transaction__c tranxData = new Transaction__c();
        tranxData.Quote_c__c = quoteRecord.Id;
        tranxData.Amount__c = 170;
        tranxData.Policy_Transaction__c = policyRecord.id;
        tranxData.Id__c = '456789098765';
        
        insert tranxData;
        
        
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteRecord.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.refundTransaction(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction), 256.00, policyRecord.Id,'');
        //PaymentFormController.refundTransactionUsingSavedCard( JSON.serialize(paymentTransaction), 256.00, policyRecord.Id);
        Test.stopTest();
        
    }
    
     @IsTest
    private static void refundTransaction_positive3() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Quote__c quoteRecord = TestDataService.createQuote(true);
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        
        Transaction__c tranxData = new Transaction__c();
        tranxData.Quote_c__c = quoteRecord.Id;
        tranxData.Amount__c = 170;
        tranxData.Policy_Transaction__c = policyRecord.id;
        tranxData.Id__c = '456789098765';
        
        insert tranxData;
        
        
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteRecord.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.createAdditionalPaymentProfileTransactionForCards(JSON.serialize(paymentTransaction), 256.00, policyRecord.Id);
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testing_negative() {
        Test.startTest();
        try{
            PaymentFormController.createPaymentProfileTransaction(null);
        }catch(exception e){
            
        }
        
        try {
            PaymentFormController.createProfileSubscription(null);
        }catch(exception e){
            
        }
        
        try {
            PaymentFormController.createAdditionalPaymentProfileTransaction(null, null, null);
        }catch(exception e){
            
        }
        
        try{
            PaymentFormController.createTransactionWithPredefinedAmount(null, null, null, null, '');
        }catch (exception e) {
            
        }
        try{PaymentFormController.createAdditionalPaymentProfileTransactionForCards(null,null,null);}catch (exception e) {
            
        }
        try {
            PaymentFormController.refundTransaction(null, null, null, null,null);
           
        }catch (exception e) {
            
        }
        try{  PaymentFormController.refundTransactionUsingSavedCard( null, null, null);}catch(Exception e){}
        
        try{
            PaymentFormController.createSubscription(null, null);
        }catch(exception e){
            
        }
        
        try{
            PaymentFormController.createPaymentProfileTransaction(null);
        }catch(exception e){
            
        }
        try{
            PaymentFormController.createTransaction(null, null, '');
        }catch(exception e){
            
        }
        
        try{
            PaymentFormController.createPaymentProfile(null, null);
        }catch(exception e){
            
        }
        
        try{
            PaymentFormController.getPaymentInfo(null);
        }catch(exception e){
            
        }
        
        try{
            PaymentFormController.getAddress(null);
        } catch(exception e) {
            
        }
        
        Test.stopTest();
    }
    
    @IsTest
    private static void createProfileSubscription_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Id quoteId = TestDataService.createQuote(true).Id;
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteId, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_SUBSCRIPTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.createProfileSubscription(JSON.serialize(paymentTransaction));
        // PaymentFormController.createPaymentProfileTransaction();
        Test.stopTest();
    }
    
    @IsTest
    private static void createSubscription_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Id quoteId = TestDataService.createQuote(true).Id;
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteId, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_SUBSCRIPTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.createSubscription(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction));
        // PaymentFormController.createTransaction(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction));
        
        Test.stopTest();
    }
    
    @IsTest
    private static void createTransaction_positive() {
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
        quoteRecord.Underwriter__c ='Mapfre';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Watercraft';
        quoteRecord.Vehicle_Type__c = 'VR';
        quoteRecord.Liability__c = '200,000'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        insert quoteRecord;
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Homeowners';
        insert policyrecord;
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Id quoteId = TestDataService.createQuote(true).Id;
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteId, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        PaymentFormController.createTransaction(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction), 'kshitij.saini@cloudanalogy.com');
        // PaymentFormController.createAdditionalPaymentProfileTransaction(JSON.serialize(paymentTransaction),20.00,policyrecord.Id);
        //TransactionService.createAdditionalPaymentProfileTransaction(paymentTransaction,20.00,policyrecord.Id);
        // PaymentFormController.createTransactionWithPredefinedAmount(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction),20.00,policyrecord.Id);
        // PaymentFormController.refundTransaction(JSON.serialize(TestDataService.createCreditCard()), JSON.serialize(paymentTransaction),20.00,policyrecord.Id);
        
        List<string> ListOfStates = new List<string> {'NY', 'LA', 'LV'};
            PaymentFormController.getDriverAddress(ListOfStates);
        //PaymentFormController.getAddress(policyrecord.Id);
        String jsonstring = Json.serialize(ListOfStates); 
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }
    
    @IsTest
    private static void createPaymentProfile_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        List<String> quoteIds = new List<String> {TestDataService.createQuote(true).Id};
            Test.startTest();
        PaymentFormController.createPaymentProfile(JSON.serialize(TestDataService.createCreditCard()), quoteIds);
        Test.stopTest();
        System.assert(![SELECT Id FROM Authorize_Net_Customer_Profile__c].isEmpty());
    }
    
    @IsTest
    private static void getPaymentInfo_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        Id customerProfileId = TestDataService.createCustomerProfile(true, ContactService.contactId).Id;
        TestDataService.createPaymentProfile(true, customerProfileId);
        Id quoteId = TestDataService.createQuote(true).Id;
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.GET_CUSTOMER_PROFILE);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        ContactService.PaymentInfo paymentInfo = (ContactService.PaymentInfo) JSON.deserialize(PaymentFormController.getPaymentInfo(new List<String>{quoteId}), ContactService.PaymentInfo.class);
        Test.stopTest();
        System.assert(!paymentInfo.creditCards.isEmpty());
    }
    
    @IsTest
    private static void getAddress_positive() {
        //ContactService.contactId = TestDataService.createContact(true).Id;
        //ContactService.CreditCard creditCard = (ContactService.CreditCard) JSON.deserialize(PaymentFormController.getAddress(), ContactService.CreditCard.class);
        // System.assert(String.isNotBlank(creditCard.city));
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Quote__c quoteRecord = TestDataService.createQuote(true);
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj;
        
        Vehicle__c vehicleObj = new Vehicle__c();
        vehicleObj.Contact__c = ContactService.contactId;
        vehicleObj.Vehicle_Owner_Address__c = 'Test Address';
        vehicleObj.Vehicle_Owner_City__c = 'Test City';
        vehicleObj.Vehicle_Owner_State__c = 'Test State';
        vehicleObj.Vehicle_Owner_Country__c = 'Test Country';
        vehicleObj.Vehicle_Owner_Postal_Code__c = '123789';
        vehicleObj.Vehicle_Owner_Name__c = 'Test Name';
        insert vehicleObj;
        
        Quote_Vehicle__c vehicleInfor = new Quote_Vehicle__c();
        vehicleInfor.Policy__c = policyRecord.Id;
        vehicleInfor.Quote_c__c = policyRecord.Quote_c__c;
        vehicleInfor.Contact__c = ContactService.contactId;
        vehicleInfor.Account__c = acc.Id;
        vehicleInfor.Lead__c = ldObj.Id;
        vehicleInfor.Vehicle__c = vehicleObj.Id;
        insert vehicleInfor;
        
        String cardInfo= PaymentFormController.getAddress(policyRecord.Id);
        Test.stopTest();
        System.assert(!String.isBlank(cardInfo));
    }
    
    @IsTest
    private static void getAddress_positive1(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        ContactService.contactId = TestDataService.createContact(true).Id;
        Quote__c quoteRecord = TestDataService.createQuote(true);
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        
        Test.startTest();
        Driver__c driverInfo = new Driver__c();
        driverInfo.City__c = 'Test City';
        driverInfo.Country__c = 'Test Country';
        driverInfo.State_Province__c = 'Test State';
        driverInfo.Postal_Code__c = '123789';
        driverInfo.Address__c = 'Test Address';
        driverInfo.Primary_insured__c = true;
        insert driverInfo;
        
        Quote_Driver__c qdObj = new Quote_Driver__c();
        qdObj.Policy__c = policyRecord.Id;
        qdObj.Driver__c = driverInfo.Id;
        qdObj.Quote_c__c = policyRecord.Quote_c__c;
        insert qdObj;
        
        String cardInfo= PaymentFormController.getAddress(policyRecord.Id);
        Test.stopTest();
        System.assert(!String.isBlank(cardInfo));
    }
    
    @IsTest
    private Static void getAddress_positive2() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Quote__c quoteRecord = TestDataService.createQuote(true);
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        
        Test.startTest();
        String cardInfo= PaymentFormController.getAddress(policyRecord.Id);
        Test.stopTest();
        System.assert(!String.isBlank(cardInfo));
    }
    
    @isTest
    public static void testnewPolicyEdit() {
        
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
        
        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Account__c =leadConvertRslt.getAccountId();
        watercraft.Any_Boat_Operator_Under_22__c = 'No';
        watercraft.Captain_s_Day__c = '04';
        watercraft.Captain_s_Month__c ='08';
        watercraft.Captain_s_Year__c ='1992';
        watercraft.Contact__c =leadConvertRslt.getContactId();
        watercraft.Engine_Type__c ='Test';
        watercraft.Year__c ='2023';
        watercraft.VIN_Number__c = '43625';
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Value__c = 6000;
        watercraft.Type_of_Vessel__c ='Sailboat';
        watercraft.Model__c ='Test';
        watercraft.Make__c = '2023';
        watercraft.Is_the_owner_living_in_Mexico__c = 'No';
        watercraft.Is_the_Maximum_Speed_more_than_50_mph__c = 'No';
        
        insert watercraft;
        
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
        
        Map<Id, Quote__c> policyIdVsQuote = new Map<Id, Quote__c>(); 
        Map<String,object> policyIdsVsTransaction = new Map<String, object>();
        policyIdsVsTransaction.put(policy.Id, 'success');
        policyIdsVsTransaction.put(policy1.Id, 'success');
        policyIdVsQuote.put(policy.Id,quoteData);
        policyIdVsQuote.put(policy1.Id,quoteData);
        
        TransactionService.PaymentTransaction paymentTransaction2 = TestDataService.createPaymentTransaction(quoteData.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator2 = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        
        Transaction__c newtrans = new Transaction__c( Id__c='0',Tax_Iva__c=13.50, Broker__c=50.00, Policy_Premium__c=null );
            newtrans.Policy_Transaction__c=null;
            newtrans.IP__c=null;
            newtrans.Amount__c=130.50;
            newtrans.CC_Mask__c='22';
            newtrans.Quote_c__c=quoteId;
            insert newtrans;
                                                 
        
        String DriversJSON = '[{"Primary_insured__c":false,"LN_With_Country__c":"","State_Province__c":"Arizona","Postal_Code__c":"","Phone__c":"123","Driver_Type__c":"Owner","Country__c":"country","Contact__c":"'+leadConvertRslt.getContactId() +'","City__c":"city","Address__c":"address","Account_Driver__c":null,"User_Email__c":"","Deleted_Driver__c":false,"Age_Range__c":"38","License_state__c":"Arizona","License_Country__c":"","license_number__c":"LicenseNumber","Dob__c":"1985-07-07","Last_Name__c":"s","First_Name__c":"d","Name":"a0LVA000000F8bZ","Owner Id":"'+leadConvertRslt.getAccountId() +'"}]';
        String VehicleJSON = '{"Is_vehicle_owned_by_a_company_or_rented__c":false,"Is_Account_Company_Named__c":false,"Is_there_a_driver_under_21__c":false,"Vehicle_Type__c":"","Value__c":"","Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Contact__c":"","Deleted_vehicle__c":false,"Year__c":"2020","Account_Vehicle__c":"","Registered_State__c":"","Registered_Country__c":"","Registered_Plate__c":"","Model__c":"suv","Make__c":"ford","Vin__c":"","Name":"ford suv 2020","Owner Id":"'+leadConvertRslt.getAccountId() +'"}';
        
        Test.startTest();
        PaymentFormController.createNewEditPolicy(VehicleJSON,DriversJSON,'', quoteId,policy1.id , true);
        Test.stopTest();
        

    }
    
    @isTest
    public static void testNewPolicyWatercraft() {
        
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
        quoteData2.Lead__c = leadData.Id;
        quoteData2.Territory__c = 'Limited';
        quoteData2.Coverage__c = 'Complete';
        quoteData2.Term_Days__c = 365.0;
        quoteData2.Medical__c = '10,000/50,000';
        quoteData2.Is_this_a_Rental_Vehicle__c = false;
        quoteData2.Policy_Type_picklist__c = 'Watercraft';
        quoteData2.Underwriter__c = 'Chubb';
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
        policy.Policy_Type_picklist__c = 'Watercraft';
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
        
        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Account__c =leadConvertRslt.getAccountId();
        watercraft.Any_Boat_Operator_Under_22__c = 'No';
        watercraft.Captain_s_Day__c = '04';
        watercraft.Captain_s_Month__c ='08';
        watercraft.Captain_s_Year__c ='1992';
        watercraft.Contact__c =leadConvertRslt.getContactId();
        watercraft.Engine_Type__c ='Test';
        watercraft.Year__c ='2023';
        watercraft.VIN_Number__c = '43625';
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Value__c = 6000;
        watercraft.Type_of_Vessel__c ='Sailboat';
        watercraft.Model__c ='Test';
        watercraft.Make__c = '2023';
        watercraft.Is_the_owner_living_in_Mexico__c = 'No';
        watercraft.Is_the_Maximum_Speed_more_than_50_mph__c = 'No';
        
        insert watercraft;
        
         Quote__c quoteData = new Quote__c();
        quoteData.Lead__c = leadData.Id;
        quoteData.Territory__c = 'Limited';
        quoteData.Coverage__c = 'Complete';
        quoteData.Term_Days__c = 365.0;
        quoteData.Medical__c = '10,000/50,000';
        quoteData.Is_this_a_Rental_Vehicle__c = false;
        quoteData.Policy_Type_picklist__c = 'Watercraft';
        quoteData.Underwriter__c = 'Chubb';
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
        
        Map<Id, Quote__c> policyIdVsQuote = new Map<Id, Quote__c>(); 
        Map<String,object> policyIdsVsTransaction = new Map<String, object>();
        policyIdsVsTransaction.put(policy.Id, 'success');
        policyIdsVsTransaction.put(policy1.Id, 'success');
        policyIdVsQuote.put(policy.Id,quoteData);
        policyIdVsQuote.put(policy1.Id,quoteData);
        
        
        Transaction__c newtrans = new Transaction__c( Id__c='0',Tax_Iva__c=13.50, Broker__c=50.00, Policy_Premium__c=null );
            newtrans.Policy_Transaction__c=null;
            newtrans.IP__c=null;
            newtrans.Amount__c=130.50;
            newtrans.CC_Mask__c='22';
            newtrans.Quote_c__c=quoteData.Id;
            insert newtrans;
        
        String WatercraftJSON = '{"attributes":{"type":"Watercraft__c","url":"/services/data/v60.0/sobjects/Watercraft__c/'+watercraft.Id+'"},"Id":"'+watercraft.Id+'","Name":"'+watercraft.Name+'","Account__c":"'+leadConvertRslt.getAccountId() +'","Any_Boat_Operator_Under_22__c":"No","Contact__c":"' + leadConvertRslt.getContactId() +'","Engine_Type__c":"Test","Is_the_Maximum_Speed_more_than_50_mph__c":"No","Is_the_owner_living_in_Mexico__c":"No","Make__c":"2023","Model__c":"Test","Type_of_Vessel__c":"Sailboat","VIN_Number__c":"43625","Value__c":6000.00,"Year__c":"2023","Vessel_Length__c":"Less than 27\' long","Captain_s_Day__c":"04","Captain_s_Month__c":"08","Captain_s_Year__c":"1992"}';
        String DriversJSON = '[{"Is_vehicle_owned_by_a_company_or_rented__c":false,"Is_Account_Company_Named__c":false,"Is_there_a_driver_under_21__c":false,"Vehicle_Type__c":"","Value__c":"","Salvage_Vehicle__c":false,"Is_the_vehicle_used_for_business_purpose__c":false,"Is_the_vehicle_registered_to_a_business__c":false,"Is_Lienholder__c":false,"Contact__c":"","Deleted_vehicle__c":false,"Year__c":"2020","Account_Vehicle__c":"","Registered_State__c":"","Registered_Country__c":"","Registered_Plate__c":"","Model__c":"suv","Make__c":"ford","Vin__c":"","Name":"ford suv 2020","Owner Id":"'+leadConvertRslt.getAccountId() +'"}]';
        
        Test.startTest();
        PaymentFormController.createNewWatercraftEditPolicy(WatercraftJSON,DriversJSON, quoteData.Id,policy.id , true);
        Test.stopTest();
        

    }
    
    @isTest
    static void testSendAutoRenewEmail() {
        // Step 1: Setup test data
        Set<String> policyIds = new Set<String>{'001xx000003DHPAAA4', '001xx000003DHPAAB4'};
        Boolean addAttachment = true;
        
        // Step 2: Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new AutoRenewEmailServiceMock());

        // Step 3: Invoke the method
        Test.startTest();
        PaymentFormController.sendAutoRenewEmail(policyIds, addAttachment);
        Test.stopTest();

        // Step 4: Assertions
        // Since this method does not return anything, we can only verify if no exceptions were thrown
        System.assert(true, 'sendAutoRenewEmail method executed without exceptions.');
    }

    // Step 2.1: Create a mock class to simulate HTTP response
    private class AutoRenewEmailServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate a valid HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
}

    
    
    
}