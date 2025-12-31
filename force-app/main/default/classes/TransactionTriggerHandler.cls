public class TransactionTriggerHandler {
    public static void UpdateParentAccount(List<Transaction__c> objTransactionList, Map<Id, Transaction__c> oldMapTransaction){
        //For Account Ids
        set<Id> objAccountIdSet = new set<Id>();
        List<account> accountListToUpdate = new List<account>();
        for(Transaction__c objTransaction : objTransactionList){
            if(objTransaction.Account_Transaction__c != null){
                objAccountIdSet.add(objTransaction.Account_Transaction__c);
            }
            if(oldMapTransaction.containskey(objTransaction.Id)){
                if(oldMapTransaction.get(objTransaction.Id).Account_Transaction__c != null){
                    objAccountIdSet.add(oldMapTransaction.get(objTransaction.Id).Account_Transaction__c);
                }
            }
        }
        
        //For Account Update 
        List<Account> objAccountList = [SELECT Id, Total__c, Transaction_Count__c, Latest_Transaction_Date__c, Total_Cumulative__c,
                                        Total_Cumulative_This_Year__c, Transaction_Count_This_Year__c, ParentId,
                                        (SELECT Id, Premium_Amount__c,Tax_Iva__c, Account_Transaction__c, Created_At__c FROM Transactions__r 
                                         WHERE Created_At__c != null AND Premium_Amount__c != null order by Created_At__c DESC)
                                        FROM Account WHERE ID IN: objAccountIdSet];
        
        for(Account objAccount : objAccountList){
            decimal totalCumulativeThisYear = 0.0;
            Integer transactionCountThisYear = 0;
            Integer Count = 0;
            dateTime yearOfLatestTransaction;
            objAccount.Total__c = 0.0;
            for(Transaction__c objTransaction : objAccount.Transactions__r){
                if(objTransaction.Created_At__c != null && objTransaction.Created_At__c.year() == system.today().year()){
                    if(objTransaction.Premium_Amount__c != null){
                        totalCumulativeThisYear += objTransaction.Premium_Amount__c;
                    }
                    transactionCountThisYear++;
                }
                if(Count == 0){
                    yearOfLatestTransaction = objTransaction.Created_At__c;
                }else if(objTransaction.Created_At__c > yearOfLatestTransaction){
                    yearOfLatestTransaction = objTransaction.Created_At__c;
                }
                
                if(objTransaction.Premium_Amount__c != null ){
                    Count++;
                    objAccount.Total__c += objTransaction.Premium_Amount__c;
                    
                }
            }

            objAccount.Transaction_Count_This_Year__c = transactionCountThisYear;
            objAccount.Total_Cumulative_This_Year__c = totalCumulativeThisYear;
            objAccount.Latest_Transaction_Date__c = yearOfLatestTransaction;
            objAccount.Transaction_Count__c = Count;
            accountListToUpdate.add(objAccount);
        }
        
        //For Policy Ids
        set<Id> objPolicyIdSet = new set<Id>();
        for(Transaction__c objTransaction : objTransactionList){
            if(objTransaction.Policy_Transaction__c != null){
                objPolicyIdSet.add(objTransaction.Policy_Transaction__c);
            }
        }
        
        if(oldMapTransaction.size() > 0){
            for(Transaction__c objTransaction : oldMapTransaction.Values()){
                if(objTransaction.Policy_Transaction__c != null){
                    objPolicyIdSet.add(objTransaction.Policy_Transaction__c);
                }
            }
        }
        
        //For Policy Update 
        List<Policy__c> objPolicyList = [SELECT Id, Total_Transaction_Amount__c,I_V_A_Mex_Tax__c,
                                         (SELECT Id, Premium_Amount__c, Mode__c,Tax_Iva__c FROM Transactions__r WHERE Premium_Amount__c != null)
                                         FROM Policy__c  WHERE ID IN: objPolicyIdSet];
        
        for(Policy__c objPolicy: objPolicyList){
            decimal totalTransactionAmount = 0.0;
            decimal totalIVAAmount = 0.0;
            for(Transaction__c objTransaction : objPolicy.Transactions__r){
                if(objTransaction.Premium_Amount__c != null){
                    totalTransactionAmount += objTransaction.Premium_Amount__c;
                    totalIVAAmount += (objTransaction.Tax_Iva__c != null ? objTransaction.Tax_Iva__c : 0);
                }
            }
            //20 Aug update on wrong transaction Amount
            //objPolicy.Total_Transaction_Amount__c = totalTransactionAmount;
            //Update Amount IVA Issue regarding edit policy
            // objPolicy.I_V_A_Mex_Tax__c = totalIVAAmount;
        }
        
        if(objPolicyList.size()>0){
            update objPolicyList;
        }
        
        if(!accountListToUpdate.isEmpty()){
            update accountListToUpdate;
        }
        
    }
    
}