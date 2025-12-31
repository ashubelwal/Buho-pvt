//Date 		: 8/28/2017
//Author	: Henry Caballero - hdcaballero@techsforce.net	

public class AccountHelper 
{
    
    public static void updatePhone(list<account> accounts)
    {
        if (!Trigger.isExecuting) {
            for (account acc : accounts)
            {
                system.debug('Entro al ciclo' + acc);
                if(acc.Country__c == 'US' || acc.Country__c == 'CA')
                    acc.phone = formatPhone(acc.phone);
                system.debug('Entro y Actualizo' + acc.Phone);
            }
        }
    }
    
    public static String formatPhone(String Phone)
    {
        string nondigits = '[^0-9]';
        string PhoneDigits;
        
        // remove all non numeric
        PhoneDigits = Phone.replaceAll(nondigits,'');
        
        // 10 digit: reformat with dashes
        if (PhoneDigits.length() == 10) 
            return '(' + PhoneDigits.substring(0,3) + ') ' +
            PhoneDigits.substring(3,6) + '-' +
            PhoneDigits.substring(6,10);
        // 11 digit: if starts with 1, format as 10 digit 
        if (PhoneDigits.length() == 11) {
            if (PhoneDigits.substring(0,1) == '1') {
                return '(' + PhoneDigits.substring(1,4) + ') ' +
                    PhoneDigits.substring(4,7) + '-' +
                    PhoneDigits.substring(7,11);
            }
        }
        
        // if it isn't a 10 or 11 digit number, return the original because
        // it may contain an extension or special information
        return Phone ;
    }
    
    public static void UpdateParentAccount(list<account> accountList){
        set<Id> parentAccountIdSet = new set<Id>();
        List<account> AccountListToUpdate = new List<account>();
        for(account objAccount : accountList){
            if(objAccount.parentId != null){
                parentAccountIdSet.add(objAccount.parentId);
            }
        }
        if(!parentAccountIdSet.isEmpty()){
            //For Account Update 
            List<Account> objAccountList = [SELECT Id, Total__c, Transaction_Count__c, Latest_Transaction_Date__c, Total_Cumulative__c,
                                            Total_Cumulative_This_Year__c, Transaction_Count_This_Year__c, ParentId, Total_Cumulative_Amount__c, Transaction_Count_This_Year_Child__c, Total_Cumulative_This_Year_Child__c, Total_Cumulative_This_Year_Amount__c, Transaction_Count_This_Year_Total__c, 
                                            (SELECT Id, Total__c, Total_Cumulative__c, Total_Cumulative_Amount__c, Transaction_Count_This_Year_Child__c, Total_Cumulative_This_Year_Child__c,Total_Cumulative_This_Year__c, Total_Cumulative_This_Year_Amount__c, Transaction_Count_This_Year_Total__c  FROM ChildAccounts),
                                            (SELECT Id, Premium_Amount__c, Account_Transaction__c, Created_At__c FROM Transactions__r 
                                             WHERE Created_At__c != null AND Premium_Amount__c != null AND Premium_Amount__c > 0.0 order by Created_At__c DESC)
                                            FROM Account WHERE ID IN: parentAccountIdSet];
            
            for(account objAccount : objAccountList){
                Decimal objTotalAmount = 0.0;
                Decimal objTotalCumulativeThisYearChild = 0.0;
                Decimal objTransactionCountThisYearChild = 0;
                for(account objChildAccount : objAccount.ChildAccounts){
                    if(objChildAccount.Total_Cumulative_Amount__c != null && objChildAccount.Total_Cumulative_Amount__c > 0.0){
                        objTotalAmount = objTotalAmount + objChildAccount.Total_Cumulative_Amount__c;
                    }
                    if(objChildAccount.Total_Cumulative_This_Year_Amount__c != null && objChildAccount.Total_Cumulative_This_Year_Amount__c > 0.0){
                        objTotalCumulativeThisYearChild = objTotalCumulativeThisYearChild + objChildAccount.Total_Cumulative_This_Year_Amount__c;
                    }
                    if(objChildAccount.Transaction_Count_This_Year_Total__c != null && objChildAccount.Transaction_Count_This_Year_Total__c > 0){
                        objTransactionCountThisYearChild = objTransactionCountThisYearChild + objChildAccount.Transaction_Count_This_Year_Total__c;
                    }
                }
                objAccount.Total_Cumulative__c = objTotalAmount;
                objAccount.Total_Cumulative_This_Year_Child__c = objTotalCumulativeThisYearChild;
                objAccount.Transaction_Count_This_Year_Child__c = objTransactionCountThisYearChild;
                AccountListToUpdate.add(objAccount);
            }
        }
        if(!AccountListToUpdate.isEmpty()){
            Update AccountListToUpdate;
        }
    }
    
    public static void UpdateParentAccountTotal(Set<id> parentAccountIdSet){
        List<account> AccountListToUpdate = new List<account>();
        if(!parentAccountIdSet.isEmpty()){
            List<Account> objAccountList = [SELECT Id, Total__c, Transaction_Count__c, Latest_Transaction_Date__c, Total_Cumulative__c,
                                            Total_Cumulative_This_Year__c, Transaction_Count_This_Year__c, ParentId,Total_Cumulative_Amount__c, Transaction_Count_This_Year_Child__c, Total_Cumulative_This_Year_Child__c, Total_Cumulative_This_Year_Amount__c, Transaction_Count_This_Year_Total__c, 
                                            (SELECT Id, Total__c, Total_Cumulative__c, Total_Cumulative_Amount__c, Transaction_Count_This_Year_Child__c, Total_Cumulative_This_Year_Child__c,Total_Cumulative_This_Year__c, Total_Cumulative_This_Year_Amount__c, Transaction_Count_This_Year_Total__c FROM ChildAccounts),
                                            (SELECT Id, Premium_Amount__c, Account_Transaction__c, Created_At__c FROM Transactions__r 
                                             WHERE Created_At__c != null AND Premium_Amount__c != null AND Premium_Amount__c > 0.0 order by Created_At__c DESC)
                                            FROM Account WHERE ID IN: parentAccountIdSet];
            system.debug('objAccountList=>'+objAccountList);
            for(account objAccount : objAccountList){
                Decimal objTotalAmount = 0.0;
                Decimal objTotalCumulativeThisYearChild = 0.0;
                Decimal objTransactionCountThisYearChild = 0;                
                for(account objChildAccount : objAccount.ChildAccounts){
                    if(objChildAccount.Total_Cumulative_Amount__c != null && objChildAccount.Total_Cumulative_Amount__c > 0.0){
                        objTotalAmount = objTotalAmount + objChildAccount.Total_Cumulative_Amount__c;
                    }
                    if(objChildAccount.Total_Cumulative_This_Year_Amount__c != null && objChildAccount.Total_Cumulative_This_Year_Amount__c > 0.0){
                        objTotalCumulativeThisYearChild += objChildAccount.Total_Cumulative_This_Year_Amount__c;
                    }
                    if(objChildAccount.Transaction_Count_This_Year_Total__c != null && objChildAccount.Transaction_Count_This_Year_Total__c > 0){
                        objTransactionCountThisYearChild += objChildAccount.Transaction_Count_This_Year_Total__c;
                    }
                }
                objAccount.Total_Cumulative__c = objTotalAmount;
                objAccount.Total_Cumulative_This_Year_Child__c = objTotalCumulativeThisYearChild;
                objAccount.Transaction_Count_This_Year_Child__c = objTransactionCountThisYearChild;                
                AccountListToUpdate.add(objAccount);
                system.debug('objAccount=>'+objAccount);
            }
        }
        if(!AccountListToUpdate.isEmpty()){
            Update AccountListToUpdate;
        }
    }
    
}