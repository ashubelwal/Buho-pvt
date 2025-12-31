public with sharing class TestDataService {

    public static ContactService.CreditCard createCreditCard() {
        ContactService.CreditCard creditCard = new ContactService.CreditCard();
        creditCard.cardId = '10000000';
        creditCard.name = 'Test Test';
        creditCard.address1 = 'Test Address';
        creditCard.address2='Test Address 2';
        creditCard.code='205201';
        creditCard.city = 'Los Angeles';
        creditCard.state = 'CA';
        creditCard.zip = '1111111';
        creditCard.country = 'US';
        creditCard.cardNumber = '4111111111111111';
        creditCard.cardType = 'Visa';
        creditCard.year = '2024';
        creditCard.month = '11';
        return creditCard;
    }

    public static Contact createContact(Boolean performInsert) {
        Contact contact = new Contact(
            Email = 'test@test.test',
            LastName = 'Test',
            MailingCity = 'Test'
        );
        if (performInsert) {
            insert contact;
        }
        return contact;
    }

    public static Authorize_Net_Customer_Profile__c createCustomerProfile(Boolean performInsert, Id contactId) {
        Authorize_Net_Customer_Profile__c customerProfile = new Authorize_Net_Customer_Profile__c(
            Contact__c = contactId,
            Profile_Id__c = '11111'
        );
        if (performInsert) {
            insert customerProfile;
        }
        return customerProfile;
    }

    public static Authorize_Net_Payment_Profile__c createPaymentProfile(Boolean performInsert, Id customerProfileId) {
        Authorize_Net_Payment_Profile__c paymentProfile = new Authorize_Net_Payment_Profile__c(
            Authorize_Net_Customer_Profile__c = customerProfileId,
            Payment_Profile_Id__c = '22222'
        );
        if (performInsert) {
            insert paymentProfile;
        }
        return paymentProfile;
    }

    public static Quote__c createQuote(Boolean performInsert) {
        Quote__c quote = new Quote__c(
            Policy_Type_picklist__c = 'Driver License',
            Quote_Value__c = 130.50,
            Start_Date_for_Coverage__c = Date.today(),
            End_Date_for_Coverage__c = Date.today().addYears(1),
            I_V_A_Mex_Tax__c = 13.50,
            Broker_Policy_Fee__c = 50,
            Term__c = 'Annual(One Year)'
        );
        if (performInsert) {
            insert quote;
        }
        return quote;
    }
     public static Quote__c createQuoteTest1(Boolean performInsert, string picklist, string leadId, string accId) {
        Quote__c quote = new Quote__c(
            Policy_Type_picklist__c = picklist,
            Lead__c = leadId,
            contact__c = createContact(true).Id,
            Account__c = accId,
            Quote_Value__c = 130.50,
            Start_Date_for_Coverage__c = Date.today(),
            End_Date_for_Coverage__c = Date.today().addYears(1),
            I_V_A_Mex_Tax__c = 13.50,
            Broker_Policy_Fee__c = 50,
            Term__c = 'Annual(One Year)'
        );
        if (performInsert) {
            insert quote;
        }
        return quote;
    }
    public static list<Towed_Unit__c> createtowed(){
        List<Towed_Unit__c> ListTowedUnit = new List<Towed_Unit__c>();
        for(integer i=0;i<=5;i++){
        Towed_Unit__c newtowed= new Towed_Unit__c(); 
        newtowed.Make__c='BMW'+i;
        newtowed.Model__c='X7'+i;
        newtowed.Towed_Unit_Value__c=40+i;
        newtowed.Days_in_Tow__c=4+i;
        ListTowedUnit.add(newtowed);
        }
       
        insert ListTowedUnit;
        return ListTowedUnit; 
    }
    
    public static Driver__c createDriver(){
         Driver__c dreiver = new Driver__c();
          dreiver.Name='test';
          dreiver.Address__c='test Address';
          insert dreiver;
         return dreiver;
        
    }
    
    
    
    
    public static TransactionService.PaymentTransaction createPaymentTransaction(String quoteId, String customerProfileId, String paymentProfileId) {
        TransactionService.PaymentTransaction paymentTransaction = new TransactionService.PaymentTransaction();
        paymentTransaction.quoteIds = new List<String>{quoteId};
        paymentTransaction.customerProfileId = customerProfileId;
        paymentTransaction.paymentProfileId = paymentProfileId;
        return paymentTransaction;
    }

    public static Authorize_Net_Log_Event__e createAuthorizeNetLogEvent(Boolean publishEvent) {
        Authorize_Net_Log_Event__e event = new Authorize_Net_Log_Event__e(
            Type__c = 'error',
            Contact__c = null,
            Description__c = 'error',
            Full_Message__c = 'error'
        );
        if (publishEvent) {
            EventBus.publish(event);
        }
        return event;
    }

    public static List<Subscription__c> createSubscriptions(Integer numberOfRecords, Id parentQuoteId, Id parentContactId) {
        List<Subscription__c> subscriptions = new List<Subscription__c>();

        for (Integer i = 0; i < numberOfRecords; i++) {
            subscriptions.add(new Subscription__c(
                Subscription_Id__c = String.valueOf(1234567 + i),
                Description__c = 'Test Subscription ' + i,
                Contact__c = parentContactId,
                Amount__c = 200 + i,
                Trial_Amount__c = 0,
                Total_Occurrences__c = 0,
                Trial_Occurrences__c = 0,
                Start_Date__c = Date.today(),
                Next_Payment_Date__c = Date.today(),
                Length__c = 12,
                Unit__c = 'months',
                Quote__c = parentQuoteId
            ));
        }

        insert subscriptions;

        return subscriptions;
    }

    public static Policy__c createPolicy(Quote__c quote) {
        Policy__c policy = new Policy__c();
        policy.Broker_Policy_Fee__c = quote.Broker_Policy_Fee__c;
        policy.I_V_A_Mex_Tax__c = quote.I_V_A_Mex_Tax__c;
        policy.Net_Premium__c = quote.Net_Premium__c;
        policy.Policy_Type_picklist__c = quote.Policy_Type_picklist__c;
        policy.Quote_c__c = quote.Id;

        policy.Status_picklist__c = 'Active';
        
        if( quote.Start_Date_for_Coverage__c != null ){
            policy.Start_Date__c = quote.Start_Date_for_Coverage__c;
        }
        
        if( quote.End_Date_for_Coverage__c != null ){
            policy.End_Date__c = quote.End_Date_for_Coverage__c;
        }

        policy.Total_Transaction_Amount__c = quote.Quote_Value__c;
        policy.Medical_picklist__c = quote.Medical__c;
        policy.Liability_picklist__c = quote.Liability__c;
        policy.Territory_picklist__c = quote.Territory__c;
        policy.Term__c = quote.Term__c;
        policy.Term_days__c = quote.Term_days__c; 
        policy.Underwriter_picklist__c = quote.Underwriter__c;
        policy.Vehicle_type__c = quote.Vehicle_type__c;
        policy.Insured_value__c = quote.Vehicle_Value__c;

        insert policy;

        return policy;
    }
}