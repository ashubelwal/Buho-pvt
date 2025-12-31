trigger TransactionTrigger on Transaction__c (after insert, after update, after delete, after undelete) {
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUndelete){
            TransactionTriggerHandler.UpdateParentAccount(trigger.new, new Map<Id, Transaction__c>());
        }
        if(trigger.isUpdate){
            TransactionTriggerHandler.UpdateParentAccount(trigger.new, trigger.oldMap);
        }
        if(trigger.isDelete){
            TransactionTriggerHandler.UpdateParentAccount(trigger.old, new Map<Id, Transaction__c>());
        }
    }
}