@isTest
public class CreateMessagingUserWithContactAsyncTest {

    @isTest
    static void testCreateMessagingUserAsync() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        List<Contact> conLeads = new List<Contact>();
        for(Integer i = 0; i < 5; i++) {
            conLeads.add(new contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                AccountId = acc.id,
               // Company = 'TestCompany' + i,
                Phone = '123456789' + i
               
            ));
        }
        insert conleads;
        
    }
}

/* 
 










/*@isTest
private class CreateMessagingUserWithContactAsyncTest {

    @isTest
    static void  testCreateMessagingUserWithContactAsync() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Phone = '1234567890', AccountId = '001xx000003DjjaAAC');
        insert testContact;

        // Query Messaging Channel Id metadata records
        List<Messaging_Channel_Id__mdt> messagingChannelIds = [SELECT Messaging_Channel_Id__c, Type__c FROM Messaging_Channel_Id__mdt];

        Test.startTest();
        // Enqueue the queueable job
        Test.setMock(Queueable.class, new MockQu


 }


*/










/*@isTest
private class CreateMessagingUserWithContactAsyncTest {

    @isTest
    static void testCreateMessagingUserWithContactAsync() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Phone = '1234567890', AccountId = '001xx000003DjjaAAC');
        insert testContact;
        
        // Create Messaging Channel Id metadata records
        Messaging_Channel_Id__mdt messagingChannel1 = new Messaging_Channel_Id__mdt(Messaging_Channel_Id__c = '1', Type__c = 'WhatsApp');
        Messaging_Channel_Id__mdt messagingChannel2 = new Messaging_Channel_Id__mdt(Messaging_Channel_Id__c = '2', Type__c = 'SMS');
        insert new List<Messaging_Channel_Id__mdt>{messagingChannel1, messagingChannel2};
        
        Test.startTest();
        // Enqueue the queueable job
        Test.setMock(Queueable.class, new MockQueueable());
        CreateMessagingUserWithContactAsync asyncJob = new CreateMessagingUserWithContactAsync(new List<Contact>{testContact});
        System.enqueueJob(asyncJob);
        Test.stopTest();
        
        // Assert that the new MessagingEndUser records are created
        List<MessagingEndUser> messagingEndUsers = [SELECT Name, IsoCountryCode, MessageType, MessagingChannelId, MessagingConsentStatus, MessagingPlatformKey, ContactId, AccountId FROM MessagingEndUser];
        System.assertEquals(2, messagingEndUsers.size()); // Assuming there are two records created for each type in the messaging channel id map
    }
    
    // Mock Queueable class for testing
    private class MockQueueable implements Queueable {
        public void execute(QueueableContext context) {
            // Mock implementation
        }
    }
}
 */

/*
@IsTest
public class CreateMessagingUserWithContactAsyncTest {
    @IsTest
    static void testCreateMessagingUserWithContactAsync() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '1234567890',
            AccountId = testAccount.Id
        );
        insert testContact;

         Test.startTest();
        CreateMessagingUserWithContactAsync queueable = new CreateMessagingUserWithContactAsync(new List<Contact>{testContact});
        System.enqueueJob(queueable);
        Test.stopTest();

        // Validate results
        System.assertEquals(1, [SELECT count() FROM MessagingEndUser]);
        MessagingEndUser messagingUser = [SELECT Id, Name, MessageType, MessagingChannelId, MessagingConsentStatus, MessagingPlatformKey, ContactId, AccountId FROM MessagingEndUser LIMIT 1];
        System.assertEquals('Test Contact', messagingUser.Name);
        System.assertEquals('ImplicitlyOptedIn', messagingUser.MessagingConsentStatus);
        System.assertEquals('1234567890', messagingUser.MessagingPlatformKey);
        System.assertEquals(testContact.Id, messagingUser.ContactId);
        System.assertEquals(testAccount.Id, messagingUser.AccountId);
    }

    @IsTest
    static void testCreateMessagingUserWithMultipleContacts() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        List<Contact> testContacts = new List<Contact>{
            new Contact(
                FirstName = 'Test1',
                LastName = 'Contact1',
                Phone = '1234567890',
                AccountId = testAccount.Id
            ),
            new Contact(
                FirstName = 'Test2',
                LastName = 'Contact2',
                Phone = '0987654321',
                AccountId = testAccount.Id
            )
        };
        insert testContacts;


        // Validate results
        System.assertEquals(2, [SELECT count() FROM MessagingEndUser]);
    }

    // Add more test methods to cover additional scenarios...
}



/*  
@isTest
    static void testCreateMessagingUserWithContactAsync() {
       
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '1234567890',
            AccountId = testAccount.Id
        );
        insert testContact;
        
      
        Test.startTest();
        CreateMessagingUserWithContactAsync queueable = new CreateMessagingUserWithContactAsync(new List<Contact>{testContact});
        System.enqueueJob(queueable);
        Test.stopTest();
        
        
        List<MessagingEndUser> messagingUsers = [SELECT Id FROM MessagingEndUser WHERE ContactId = :testContact.Id];
        System.assertEquals(1, messagingUsers.size(), 'Expected one MessagingEndUser record to be created');
    }
    

*/


/*  @IsTest
    static void testCreateMessagingUserWithContactAsync() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '1234567890',
            AccountId = testAccount.Id
        );
        insert testContact;

        Test.startTest();
        CreateMessagingUserWithContactAsync queueable = new CreateMessagingUserWithContactAsync(new List<Contact>{testContact});
        System.enqueueJob(queueable);
        Test.stopTest();
        

        // Validate results
        System.assertEquals(1, [SELECT count() FROM MessagingEndUser]);
        MessagingEndUser messagingUser = [SELECT Id, Name, MessageType, MessagingChannelId, MessagingConsentStatus, MessagingPlatformKey, ContactId, AccountId FROM MessagingEndUser LIMIT 1];
        System.assertEquals('Test Contact', messagingUser.Name);
        System.assertEquals('ImplicitlyOptedIn', messagingUser.MessagingConsentStatus);
        System.assertEquals('1234567890', messagingUser.MessagingPlatformKey);
        System.assertEquals(testContact.Id, messagingUser.ContactId);
        System.assertEquals(testAccount.Id, messagingUser.AccountId);   
 
   


*/