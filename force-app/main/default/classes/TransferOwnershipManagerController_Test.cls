@isTest
public class TransferOwnershipManagerController_Test {

    @testSetup
    static void setupData() {
        Contact agencyContact = new Contact(
            FirstName = 'Agency',
            LastName = 'Contact',
            Email = 'agency@example.com'
        );
        insert agencyContact;

        Contact agentContact = new Contact(
            FirstName = 'Agent',
            LastName = 'Contact',
            Email = 'agent@example.com',
            Agency__c = agencyContact.Id
        );
        insert agentContact;

        Contact clientContact = new Contact(
            FirstName = 'Client',
            LastName = 'Contact',
            Email = 'client@example.com'
        );
        insert clientContact;
    }

    @isTest
    static void testGetClientContact() {
        

        Contact testContact = new Contact(
            FirstName = 'Client',
            LastName = 'Contact',
            Email = 'client@example.com'
        );
        insert testContact;

        Test.startTest();
        String result = TransferOwnershipManagerController.getClientContact(testContact.Id);
        Test.stopTest();
    }

    @isTest
    static void testTransferOwnership() {
        
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        insert getLeadData;
        
        AgencyController.convertAgencyToUser(getLeadData.Id);

        Contact con = [SELECT Id FROM Contact WHERE Email = 'test@data8.com'];
        Contact clientContact  = [SELECT Id FROM Contact WHERE Email = 'client@example.com'];
        User testUser = [SELECT Id FROM User WHERE Email = 'test@data8.com'];
        
     
        Test.startTest();
        TransferOwnershipManagerController.trasferOnwership(
            clientContact.Id, 
            'updatedclient@example.com', 
            testUser.Id,
                'Test@gmail.com',
                'Test'
        );
        Test.stopTest();

    }

    @isTest
    static void testGetUserData() {
        String leadJson = '{"FirstName":"Test","LastName":"Data Eight","Email":"test@data8.com","Phone":"1234567890","Liability__c":true,"Policy_Type__c":"Automobile","Is_towing__c":false}';
        Lead getLeadData = new Lead();
        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
        getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        insert getLeadData;
        
        AgencyController.convertAgencyToUser(getLeadData.Id);
        User testUser = [SELECT Id FROM User WHERE Email = 'test@data8.com'];

        Test.startTest();
        String result = TransferOwnershipManagerController.getUserData(testUser.Id);
        Test.stopTest();

    }

    
}