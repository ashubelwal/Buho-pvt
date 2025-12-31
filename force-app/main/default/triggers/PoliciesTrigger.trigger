trigger PoliciesTrigger on Policy__c (after insert) {
    Set<String> accountIds = new Set<String>();
    for(Policy__c objPolicy : trigger.new){
        if(objPolicy.Account_Policy__c != null){
            accountIds.add(objPolicy.Account_Policy__c);
        }
    }
    
    if(accountIds.size() > 0){
        PoliciesTriggerHandler.sendEmailAlert(accountIds);
    }
}