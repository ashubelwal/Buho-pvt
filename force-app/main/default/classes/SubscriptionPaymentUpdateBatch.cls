global class SubscriptionPaymentUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        return Database.getQueryLocator([SELECT Id, Next_Payment_Date__c, Quote__c, Subscription_Id__c FROM Subscription__c WHERE Next_Payment_Date__c =: Date.today()]);
    }

    global void execute(Database.BatchableContext bc, List<Subscription__c> scope) {
        TransactionService.processSubscriptionPayment(scope);
    }

    global void finish(Database.BatchableContext bc) {

    }
}