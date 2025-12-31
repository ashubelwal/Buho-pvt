@isTest
public class ContactTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '1234567890',
            Email = 'john.doe@example.com',
            Company = 'Test Company'
        );
        insert testLead;
        
        LeadStatus convertedStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(testLead.Id);
        leadConvert.setConvertedStatus(convertedStatus.MasterLabel);
        leadConvert.setDoNotCreateOpportunity(true); 

        Database.LeadConvertResult convertResult = Database.convertLead(leadConvert);
        
        System.assert(convertResult.isSuccess(), 'Lead was not converted successfully');
    }

    @isTest
    static void testContactUpdateAndLeadSync() {
        Contact testContact = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact LIMIT 1];

        testContact.FirstName = 'Jane';
        testContact.LastName = 'Smith';
        testContact.Phone = '0987654321';
        testContact.Email = 'jane.smith@example.com';
        update testContact;
        
        testContact.FirstName = 'Jane';
        testContact.LastName = 'Smith';
        testContact.Phone = '';
        testContact.Email = 'jane.smith@example.com';
        update testContact;
        
        testContact.FirstName = 'Jane';
        testContact.LastName = 'Smith';
        testContact.Phone = '0987654321';
        testContact.Email = '';
        update testContact;

        Lead updatedLead = [SELECT FirstName, LastName, Phone, Email FROM Lead WHERE ConvertedContactId = :testContact.Id LIMIT 1];

    }
}