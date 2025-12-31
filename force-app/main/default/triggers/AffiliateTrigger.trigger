trigger AffiliateTrigger on Affiliate__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        AffiliateTriggerHandler.getUniqueAffiliateId(Trigger.new);
    }
}