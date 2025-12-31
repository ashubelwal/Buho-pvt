@IsTest
public with sharing class AuthorizeNetEventTriggerHandlerTest {

    @IsTest
    private static void insertLog_positive() {
        Test.startTest();
        TestDataService.createAuthorizeNetLogEvent(true);
        Test.stopTest();
        System.assert(![SELECT Id FROM Authorize_Net_Log__c].isEmpty());
    }
}