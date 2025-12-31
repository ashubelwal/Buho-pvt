public with sharing class AuthorizeNetEventTriggerHandler {

    public static void handleAfterInsert(List<Authorize_Net_Log_Event__e> events) {
        List<Authorize_Net_Log__c> logs = new List<Authorize_Net_Log__c>();
        for (Authorize_Net_Log_Event__e event : events) {
            logs.add(new Authorize_Net_Log__c(
                Type__c = event.Type__c,
                Contact__c = event.Contact__c,
                Description__c = event.Description__c,
                Full_Message__c = event.Full_Message__c
            ));
        }
        insert logs;
    }
}