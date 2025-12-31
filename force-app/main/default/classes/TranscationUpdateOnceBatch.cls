global class TranscationUpdateOnceBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        return Database.getQueryLocator([SELECT id FROM Transaction__c WHERE Created_At__c != null]);
    }
    global void execute(Database.BatchableContext bc, List<Transaction__c> scope){   
        try{
            Update scope;
        }Catch(Exception e){
            system.debug('Cause---> '+e.getCause());
            system.debug('LineNumber---> '+e.getLineNumber());
            system.debug('StackTraceString---> '+e.getStackTraceString());
        }
    }
    global void finish(Database.BatchableContext bc){}
}