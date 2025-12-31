public class PolicyAutoRenewScheduler implements Schedulable{
    
    public void execute(schedulableContext sc){
        List<Policy__c> policyList = new List<Policy__c>();
        Set<Id> policyIdSet = new Set<Id>();
        date todaysDate = date.today();
        policyList = [SELECT Id FROM Policy__c WHERE Auto_renew__c = true AND Auto_Renew_Confirmed__c = true AND End_Date__c =: todaysDate AND (Term__c = 'Annual(One Year)' OR Term__c = 'Annual' OR Term__c = 'annual') LIMIT 50000];
        System.debug('policyList'+policyList);
        if(policyList.size() > 0){
            for(Policy__c policy : policyList){
                policyIdSet.add(policy.Id);
            }
        }
        System.debug('policyIdSet'+policyIdSet);
        if(policyIdSet.size() > 0){
            PolicyAutoRenewQuoteGenerateBatch generateQuote = new PolicyAutoRenewQuoteGenerateBatch(policyIdSet);
            Id batchJodId = database.executeBatch(generateQuote);
        }
        
    }
}