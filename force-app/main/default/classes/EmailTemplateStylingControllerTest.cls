@isTest
private class EmailTemplateStylingControllerTest {
    @isTest
    static void testController() {
        // Create test user with custom fields populated
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            Logo_URL__c = 'https://logo.com',
            Partner_Id__c = 'partner id',
            Partner_Name__c = 'Partner Name',
            Website__c = 'www.partner.com',
            Agent_Id__c = '12345',
            Street = 'Street',
            City = 'City',
            State = 'State',
            PostalCode = '12345',
            Country = 'USA'
        );
        insert u;
        
        System.runAs(u) {
            EmailTemplateStylingController controller = new EmailTemplateStylingController();
            
            System.assertEquals('https://logo.com', controller.getLogoUrl());
            System.assertEquals('Partner Name', controller.getPartnerName());
            System.assertEquals('PARTNER ID', controller.getPartnerId());
            System.assertEquals('12345', controller.getAgentId());
            System.assertEquals('https://www.partner.com', controller.getWebsite());
            System.assertEquals('PARTNER.COM', controller.getWebsiteLabel());
            System.assert(controller.getAddress().contains('City'));
            System.assertEquals('Test User', controller.getUserName());
        }
    }
    
    @isTest
    static void testFallbacks() {
        // Test with a user that has no branding info
        User u = new User(
            FirstName = 'Fallback',
            LastName = 'User',
            Email = 'fallback@example.com',
            Username = 'fallback' + DateTime.now().getTime() + '@example.com',
            Alias = 'fuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert u;

        System.runAs(u) {
            EmailTemplateStylingController controller = new EmailTemplateStylingController();
            System.assertEquals('https://www.mexinsurance.com/wp-content/uploads/2023/11/cropped-Logo-1-2048x312.png', controller.getLogoUrl());
            System.assertEquals('MexInsurance®', controller.getPartnerName());
            System.assertEquals('MEXICO INSURANCE SERVICES, INC.', controller.getPartnerId());
            System.assertEquals('0G35864', controller.getAgentId());
            System.assertEquals('https://www.mexinsurance.com/', controller.getWebsite());
            System.assertEquals('MEXINSURANCE.COM', controller.getWebsiteLabel());
            System.assertEquals('', controller.getAddress());
        }
    }
}
