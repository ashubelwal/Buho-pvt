public class UserTriggerHandler {
    public static void updatePromoCode(List<User> userList){
        set<String> accountIdSet = new set<String>();
        for(User userInstance : userList){
            if(userInstance.AccountId != null){
                accountIdSet.add(userInstance.AccountId);
            }
        }
        
        if(accountIdSet != null && !accountIdSet.isEmpty()){
            
            UserTriggerHandler.futureUpdateAccount(accountIdSet);
        }      
    }
    
    @future
    public static void futureUpdateAccount(set<String> accountIdSet){
        if(accountIdSet != null && !accountIdSet.isEmpty()){
            list<Account> accountListToUpdate = new list<Account>();
            for(Account accountInstance : [Select id,name, Affiliate_Number__c from Account where id in : accountIdSet and Affiliate_Number__c = null]){
                
                Integer len = 6;
                Blob blobKey = crypto.generateAesKey(128);
                String key = EncodingUtil.convertToHex(blobKey);
                String pwd = key.substring(0,len);
                
                accountInstance.Affiliate_Number__c = pwd;
                accountListToUpdate.add(accountInstance);
            }
            
            if(accountListToUpdate != null && !accountListToUpdate.isEmpty()){
                update accountListToUpdate;
            }
        }    
    }
}