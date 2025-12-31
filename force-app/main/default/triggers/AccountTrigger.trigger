//Date 		: 8/28/2017
//Author	: Henry Caballero - hdcaballero@techsforce.net	
trigger AccountTrigger on Account (before update, after update, after delete, after undelete) 
{
    
    if(trigger.isUpdate && trigger.isBefore){
        AccountHelper.updatePhone(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUndelete){
        AccountHelper.UpdateParentAccount(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        set<Id> parentAccountIdSet = new set<Id>();
        for(account objAccount : trigger.new){
            if(objAccount.parentId != trigger.oldMap.get(objAccount.Id).parentId || 
               objAccount.Total__c != trigger.oldMap.get(objAccount.Id).Total__c ||
               objAccount.Total_Cumulative__c != trigger.oldMap.get(objAccount.Id).Total_Cumulative__c ||
               objAccount.Total_Cumulative_This_Year__c != trigger.oldMap.get(objAccount.Id).Total_Cumulative_This_Year__c ||
               objAccount.Total_Cumulative_This_Year_Child__c != trigger.oldMap.get(objAccount.Id).Total_Cumulative_This_Year_Child__c ||
               objAccount.Transaction_Count_This_Year_Child__c != trigger.oldMap.get(objAccount.Id).Transaction_Count_This_Year_Child__c ||
               objAccount.Transaction_Count_This_Year__c != trigger.oldMap.get(objAccount.Id).Transaction_Count_This_Year__c
              ){
                   if(objAccount.parentId != null){
                       parentAccountIdSet.add(objAccount.parentId);
                   }
                       system.debug('1==> '+trigger.oldMap.get(objAccount.Id));
                   if(trigger.oldMap.get(objAccount.Id).parentId != null){
                       system.debug('2==> '+trigger.oldMap.get(objAccount.Id).parentId);
                       parentAccountIdSet.add(trigger.oldMap.get(objAccount.Id).parentId);
                   }
               }
        }
        if(!parentAccountIdSet.isEmpty()){
            AccountHelper.UpdateParentAccountTotal(parentAccountIdSet);
        }
    }
    
    if(trigger.isAfter && trigger.isDelete){
        AccountHelper.UpdateParentAccount(trigger.old);
    }
    
}