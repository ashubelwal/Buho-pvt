global class PolicyExpireBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date todayDate = System.today();
        String query = 'SELECT Id, Name, Status_picklist__c, End_Date__c  FROM Policy__c Where Status_picklist__c = \'Active\' AND End_Date__c <=:todayDate LIMIT 50000';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Policy__c> scope)
    {
        for (Policy__c each : scope) {
            each.Status_picklist__c = 'Expired';
        }

        update scope;
    }  

    global void finish(Database.BatchableContext BC)
    {
    }
}