trigger QuoteTrigger on Quote__c (before insert, after insert, after update, after delete, after undelete) {
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUndelete){
            QuoteTriggerHandler.UpdateLeadFromQuote(trigger.new, new Map<Id, Quote__c>());
        }
        if(trigger.isUpdate){
            QuoteTriggerHandler.UpdateLeadFromQuote(trigger.new, trigger.oldMap);
        }
        if(trigger.isDelete){
            QuoteTriggerHandler.UpdateLeadFromQuote(trigger.old, new Map<Id, Quote__c>());
        }
    }if(trigger.isBefore){
        for(Quote__c quote : trigger.new ){
            if( quote.Lead_Id__c != null && quote.Lead_Id__c != ''){
                quote.lead__c = quote.Lead_Id__c;
            }
        }
    }
}