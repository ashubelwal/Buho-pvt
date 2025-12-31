@IsTest
public with sharing class TransactionServiceTest {

    @IsTest
    private static void createPaymentProfileTransaction_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Id quoteId = TestDataService.createQuote(true).Id;
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteId, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        TransactionService.createPaymentProfileTransaction(paymentTransaction);
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
        Policy__c policyRecord = TestDataService.createPolicy(quoteRecord);
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteRecord.Id, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        TransactionService.createAdditionalPaymentProfileTransaction(paymentTransaction, 250.00, policyRecord.Id);
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }

    @IsTest
    private static void createPaymentTransaction_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        Authorize_Net_Customer_Profile__c customerProfile = TestDataService.createCustomerProfile(true, ContactService.contactId);
        Authorize_Net_Payment_Profile__c paymentProfile = TestDataService.createPaymentProfile(true, customerProfile.Id);
        Id quoteId = TestDataService.createQuote(true).Id;
        TransactionService.PaymentTransaction paymentTransaction = TestDataService.createPaymentTransaction(quoteId, customerProfile.Profile_Id__c, paymentProfile.Payment_Profile_Id__c);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_TRANSACTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        TransactionService.createPaymentTransaction(TestDataService.createCreditCard(), paymentTransaction, 'kshitij.saini@cloudanalogy.com');
       //  TransactionService.createPaymentTransactionWithPredefinedAmount(TestDataService.createCreditCard(),paymentTransaction,20.00,'a0H2i00000TUU2oEAH');
        // TransactionService.refundPaymentTransaction(TestDataService.createCreditCard(),paymentTransaction,20.00,'a0H2i00000TUU2oEAH');
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }
    
    @IsTest
    private static void refundPaymentTransaction_positive() {
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
        TransactionService.refundPaymentTransaction(TestDataService.createCreditCard(), paymentTransaction, 250.00, policyRecord.Id,'');
        AuthorizeNetClient.testMethodForCallClass();
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
    }
    
    @IsTest
    private static void createPaymentTransactionWithPredefinedAmount_positive() {
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
        TransactionService.createPaymentTransactionWithPredefinedAmount(TestDataService.createCreditCard(), paymentTransaction, 250.00, policyRecord.Id, 'kshitij.saini@cloudanalogy.com');
        Test.stopTest();
        System.assert(![SELECT Id FROM Transaction__c].isEmpty());
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
        TransactionService.createProfileSubscription(paymentTransaction, 12, 'months', 1, 9999, 0.0);
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
        TransactionService.createSubscription(TestDataService.createCreditCard(), paymentTransaction, 12, 'months', 1, 9999, 0.0);
        Test.stopTest();
        
    }

    @IsTest
    private static void processSubscriptionPayment_positive() {
        insert new TriggerSwitch__c(Name = 'PolicyTrigger');

        Quote__c quote   = TestDataService.createQuote(true);
        Contact contact  = TestDataService.createContact(true);
        Policy__c policy = TestDataService.createPolicy(quote);
        List<Subscription__c> subscriptions = TestDataService.createSubscriptions(50, quote.Id, contact.Id);

        AuthorizeNetMockGenerator getSubscriptionGenerator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.GET_SUBSCRIPTION_OK);
        AuthorizeNetMockGenerator getTransactionGenerator  = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.GET_TRANSACTION_DETAILS_OK);

        Map<String, HttpCalloutMock> testResponsesMap = new Map<String, HttpCalloutMock>();
        testResponsesMap.put(AuthorizeNetMockGenerator.Callout.GET_SUBSCRIPTION_OK.name(), getSubscriptionGenerator);
        testResponsesMap.put(AuthorizeNetMockGenerator.Callout.GET_TRANSACTION_DETAILS_OK.name(), getTransactionGenerator);
        
        HttpCalloutMock multiCalloutMock = new AuthorizeNetMultiRequestMock(testResponsesMap);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
            TransactionService.processSubscriptionPayment(subscriptions);
        Test.stopTest();

        System.assertEquals(50, [SELECT Id FROM Subscription__c WHERE Next_Payment_Date__c =: Date.today().addYears(1)].size());
        System.assertEquals(51, [SELECT Id FROM Policy__c].size());
        System.assertEquals(50, [SELECT Id FROM Transaction__c].size());
    }

    @isTest
    static void testGetDateString() {
        Date dates = Date.newInstance(2025, 6, 4);  // Expected: 2025-06-04
        String formattedDate = TransactionService.getDateString(dates);
        System.assertEquals('2025-06-04', formattedDate, 'Date should be formatted as yyyy-MM-dd');
    }
    @isTest
    static void bypass(){
       TransactionService.bypassTest();
    }
}