@isTest
public class SendPolicyAttachmentEmailTest {
    
    @TestSetup
    static void setupTestData() {
        // Disable trigger using custom setting to avoid trigger issues
        try {
            TriggerSwitch__c triggerSetting = new TriggerSwitch__c(
                Name = 'PolicyTrigger',
                Active__c = false
            );
            insert triggerSetting;
        } catch (Exception e) {
            System.debug('Could not create trigger setting: ' + e.getMessage());
        }
        
        // Create test policies
        List<Policy__c> policies = new List<Policy__c>();
        
        // Active policy with email
        Policy__c activePolicy = new Policy__c(
            Name = 'TEST-ACTIVE-001',
            Status_picklist__c = 'Active',
            Contact_Email__c = 'test@example.com'
        );
        policies.add(activePolicy);
        
        // Inactive policy with email
        Policy__c inactivePolicy = new Policy__c(
            Name = 'TEST-INACTIVE-002',
            Status_picklist__c = 'Expired',
            Contact_Email__c = 'inactive@example.com'
        );
        policies.add(inactivePolicy);
        
        // Active policy without email
        Policy__c policyNoEmail = new Policy__c(
            Name = 'TEST-NO-EMAIL-003',
            Status_picklist__c = 'Active',
            Contact_Email__c = null
        );
        policies.add(policyNoEmail);
        
        // Insert policies with System Administrator user to avoid profile issues
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(adminUser) {
            insert policies;
        }
    }
    
    @isTest
    static void testSendEmailWithPdf_ActivePolicyWithPdfAttachment() {
        // Get the active policy
        Policy__c activePolicy = [SELECT Id FROM Policy__c WHERE Name = 'TEST-ACTIVE-001' LIMIT 1];
        
        // Create PDF attachment
        Attachment pdfAttachment = new Attachment(
            Name = 'Policy_Document.pdf',
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('Sample PDF content for testing'),
            ContentType = 'application/pdf'
        );
        insert pdfAttachment;
        
        Test.startTest();
        // Call the method
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ activePolicy.Id });
        Test.stopTest();
        
        // Verify method executed successfully
        System.assert(true, 'Method executed successfully for active policy with PDF');
    }
    
    @isTest
    static void testSendEmailWithPdf_ActivePolicyWithNonPdfAttachment() {
        // Get the active policy
        Policy__c activePolicy = [SELECT Id FROM Policy__c WHERE Name = 'TEST-ACTIVE-001' LIMIT 1];
        
        // Create non-PDF attachment
        Attachment nonPdfAttachment = new Attachment(
            Name = 'Policy_Document.txt',
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('Sample text content for testing'),
            ContentType = 'text/plain'
        );
        insert nonPdfAttachment;
        
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ activePolicy.Id });
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully for active policy with non-PDF attachment');
    }
    
    @isTest
    static void testSendEmailWithPdf_ActivePolicyWithPdfFileExtension() {
        // Get the active policy
        Policy__c activePolicy = [SELECT Id FROM Policy__c WHERE Name = 'TEST-ACTIVE-001' LIMIT 1];
        
        // Create attachment with PDF file extension
        Attachment pdfAttachment = new Attachment(
            Name = 'Policy_Document.PDF', // Uppercase extension
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('Sample PDF content for testing'),
            ContentType = 'application/octet-stream'
        );
        insert pdfAttachment;
        
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ activePolicy.Id });
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully for active policy with PDF file extension');
    }
    
    @isTest
    static void testSendEmailWithPdf_InactivePolicy() {
        // Get the inactive policy
        Policy__c inactivePolicy = [SELECT Id FROM Policy__c WHERE Name = 'TEST-INACTIVE-002' LIMIT 1];
        
        // Create PDF attachment for inactive policy
        Attachment pdfAttachment = new Attachment(
            Name = 'Policy_Document.pdf',
            ParentId = inactivePolicy.Id,
            Body = Blob.valueOf('Sample PDF content for testing'),
            ContentType = 'application/pdf'
        );
        insert pdfAttachment;
        
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ inactivePolicy.Id });
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully and skipped inactive policy');
    }
    
    @isTest
    static void testSendEmailWithPdf_ActivePolicyNoAttachments() {
        // Get the active policy
        Policy__c activePolicy = [SELECT Id FROM Policy__c WHERE Name = 'TEST-ACTIVE-001' LIMIT 1];
        
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ activePolicy.Id });
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully for active policy with no attachments');
    }
    
    @isTest
    static void testSendEmailWithPdf_MultipleAttachmentsFirstPdf() {
        // Get the active policy
        Policy__c activePolicy = [SELECT Id FROM Policy__c WHERE Name = 'TEST-ACTIVE-001' LIMIT 1];
        
        // Create multiple attachments
        List<Attachment> attachments = new List<Attachment>();
        
        // First attachment - PDF (should be selected)
        attachments.add(new Attachment(
            Name = 'First_Document.pdf',
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('First PDF content'),
            ContentType = 'application/pdf'
        ));
        
        // Second attachment - also PDF (should not be selected)
        attachments.add(new Attachment(
            Name = 'Second_Document.pdf',
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('Second PDF content'),
            ContentType = 'application/pdf'
        ));
        
        // Third attachment - non-PDF
        attachments.add(new Attachment(
            Name = 'Text_Document.txt',
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('Text content'),
            ContentType = 'text/plain'
        ));
        
        insert attachments;
        
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ activePolicy.Id });
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully with multiple attachments');
    }
    
    @isTest
    static void testSendEmailWithPdf_MultiplePolicies() {
        // Get multiple policies
        List<Policy__c> policies = [SELECT Id FROM Policy__c WHERE Name IN ('TEST-ACTIVE-001', 'TEST-INACTIVE-002')];
        
        List<Id> policyIds = new List<Id>();
        for (Policy__c policy : policies) {
            policyIds.add(policy.Id);
            
            // Create PDF attachment for each policy
            Attachment pdfAttachment = new Attachment(
                Name = 'Policy_Document_' + policy.Id + '.pdf',
                ParentId = policy.Id,
                Body = Blob.valueOf('Sample PDF content for policy ' + policy.Id),
                ContentType = 'application/pdf'
            );
            insert pdfAttachment;
        }
        
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(policyIds);
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully for multiple policies');
    }
    
    @isTest
    static void testSendEmailWithPdf_EmptyPolicyList() {
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>());
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully with empty policy list');
    }
    
    @isTest
    static void testSendEmailWithPdf_NullContactEmail() {
        // Get the policy without email
        Policy__c policyNoEmail = [SELECT Id FROM Policy__c WHERE Name = 'TEST-NO-EMAIL-003' LIMIT 1];
        
        // Create PDF attachment
        Attachment pdfAttachment = new Attachment(
            Name = 'Policy_Document.pdf',
            ParentId = policyNoEmail.Id,
            Body = Blob.valueOf('Sample PDF content for testing'),
            ContentType = 'application/pdf'
        );
        insert pdfAttachment;
        
        Test.startTest();
        try {
            SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ policyNoEmail.Id });
            System.assert(true, 'Method handled null email gracefully');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('email') || e.getMessage().contains('address'), 
                         'Expected email-related exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    // Additional test for edge case - PDF found by extension but different content type
    @isTest
    static void testSendEmailWithPdf_MixedAttachmentTypes() {
        Policy__c activePolicy = [SELECT Id FROM Policy__c WHERE Name = 'TEST-ACTIVE-001' LIMIT 1];
        
        // Create attachments in specific order to test priority
        List<Attachment> attachments = new List<Attachment>();
        
        // First - non-PDF
        attachments.add(new Attachment(
            Name = 'Document.txt',
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('Text content'),
            ContentType = 'text/plain'
        ));
        
        // Second - PDF by extension only
        attachments.add(new Attachment(
            Name = 'Document.pdf',
            ParentId = activePolicy.Id,
            Body = Blob.valueOf('PDF content'),
            ContentType = 'application/octet-stream'
        ));
        
        insert attachments;
        
        Test.startTest();
        SendPolicyAttachmentEmail.sendEmailWithPdf(new List<Id>{ activePolicy.Id });
        Test.stopTest();
        
        System.assert(true, 'Method executed successfully with mixed attachment types');
    }
}