@isTest
private class ScheduleSubscriptionPaymentUpdateTest {
    @TestSetup
    static void makeData() {
        Id contactId = TestDataService.createContact(true).Id;
        Id quoteId = TestDataService.createQuote(true).Id;

        TestDataService.createSubscriptions(50, quoteId, contactId);
    }

    @IsTest
    static void executeTest() {    
        final String CRON_EXP = '0 0 0 1/1 * ? *';
        
        AuthorizeNetMockGenerator generator = new AuthorizeNetMockGenerator(AuthorizeNetMockGenerator.Callout.GET_EMPTY_SUBSCRIPTION_OK);
        Test.setMock(HttpCalloutMock.class, generator);
        
        Test.startTest();
            String jobId = System.schedule('ScheduleSubscriptionPaymentUpdateTest', CRON_EXP, new ScheduleSubscriptionPaymentUpdate());
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}