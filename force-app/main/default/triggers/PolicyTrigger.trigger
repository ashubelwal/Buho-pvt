trigger PolicyTrigger on Policy__c (before insert, before update) {
    if(Test.isRunningTest()){
        
    }
    if(TriggerSwitch__c.getValues('PolicyTrigger').Active__c)
    {
    
            PolicyTriggerHandler  triggerHandler = new PolicyTriggerHandler();
         
         /*    if(Trigger.isAfter && Trigger.isInsert){
                //triggerHandler.OnAfterInsert(trigger.new, null);
            }
            
            if(Trigger.isAfter && Trigger.isUpdate){
                //triggerHandler.OnAfterUpdate(trigger.new, Trigger.oldMap,trigger.old);
            }
            
            if(trigger.isBefore && trigger.isDelete){
               // triggerHandler.OnBeforeDelete(trigger.old, trigger.oldMap);
            }
            
            if(trigger.isAfter && trigger.isDelete){
                //triggerHandler.OnAfterDelete(trigger.old, trigger.oldMap);
            }
         */   
            if(trigger.isBefore ){
                triggerHandler.OnBeforeInsert(trigger.new);
                
            }
         /*   if(trigger.isBefore && trigger.isupdate){
                //triggerHandler.OnBeforeUpdate(trigger.new,trigger.oldmap);
               
            }
            */
    }
}