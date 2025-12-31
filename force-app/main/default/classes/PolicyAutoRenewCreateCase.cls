public class PolicyAutoRenewCreateCase {
    public static void createCase(Map<Id,Object> failedTransacation){
        System.debug('PolicyAutoRenewCreateCase---');
        System.debug('failedTransacation---'+failedTransacation);
        if(failedTransacation.size() > 0){
            List<Policy__c> policyList = [SELECT Id,Name,Account_Policy__c, Contact__c FROM Policy__c WHERE Id IN: failedTransacation.keySet()];
            System.debug('policyList---'+policyList);
            List<Case> caseList = new List<Case>();
            for(policy__c policy : policyList){
                Case cs = new Case();
                if(policy.Account_Policy__c != null){
                    cs.AccountId = policy.Account_Policy__c;
                }
                if(policy.Contact__c != null){
                    cs.ContactId = policy.Contact__c;
                }
                cs.Subject = 'Transaction Failed with Policy number - '+ policy.Name;
                cs.Description = String.valueOf(failedTransacation.get(policy.Id));
                cs.Status = 'New';
                cs.Origin = 'Web';
                cs.Type = 'Problem';
                cs.Reason = 'Escalated';
                caseList.add(cs);
                
            }
            System.debug('caseList---'+caseList);
            if(caseList.size() > 0){
                insert caseList;
            }
        }
    }
}