@IsTest
public with sharing class ContactServiceTest {

    @IsTest
    private static void createProfile_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PROFILE_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        List<String> quoteIds = new List<String> {TestDataService.createQuote(true).Id};
        Test.startTest();
        ContactService.createProfile(TestDataService.createCreditCard(), quoteIds);
      //  ContactService.createProfileForGuest(TestDataService.createCreditCard(), quoteIds);
        Test.stopTest();
        System.assert(![SELECT Id FROM Authorize_Net_Customer_Profile__c].isEmpty());
    }

    @IsTest
    private static void createPaymentProfile_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        TestDataService.createCustomerProfile(true, ContactService.contactId);
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.CREATE_PAYMENT_PROFILE_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        List<String> quoteIds = new List<String> {TestDataService.createQuote(true).Id};
        Test.startTest();
        ContactService.createProfile(TestDataService.createCreditCard(), quoteIds);
        Test.stopTest();
        System.assert(![SELECT Id FROM Authorize_Net_Payment_Profile__c].isEmpty());
    }

    @IsTest
    private static void getPaymentProfiles_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        Id customerProfileId = TestDataService.createCustomerProfile(true, ContactService.contactId).Id;
        TestDataService.createPaymentProfile(true, customerProfileId);
        Id quoteId = TestDataService.createQuote(true).Id;
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.GET_CUSTOMER_PROFILE);
        Test.setMock(HttpCalloutMock.class, generator);
        Test.startTest();
        ContactService.PaymentInfo paymentInfo = ContactService.getPaymentInfo(new List<String>{quoteId});
        Test.stopTest();
        System.assert(!paymentInfo.creditCards.isEmpty());
    }

    @IsTest
    private static void getAddress_positive() {
        ContactService.contactId = TestDataService.createContact(true).Id;
        System.assert(String.isNotBlank(ContactService.getAddress().city));
    }
}