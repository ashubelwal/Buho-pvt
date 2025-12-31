global class UpdateContactFromPolicyBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Name, Vehicle_type__c,Contact__c FROM Policy__c WHERE Contact__c != null';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Policy__c> objPolicyList) {
        try{
            Set<Id> parentContactIdSet = new Set<Id>();
            //process each batch of records default size is 200
            for(Policy__c objPolicy : objPolicyList) {        
                //Getting parent Contact Id 
                if(objPolicy.Contact__c != null){
                    parentContactIdSet.add(objPolicy.Contact__c);
                }
            }
            if(parentContactIdSet.size() > 0){
                //Update Parent Contacts
                PolicyTrigger_Handler.UpdateContact(parentContactIdSet);
            }
        }catch(Exception e) {
            System.debug('---> '+e);
        }
    }   
     
    global void finish(Database.BatchableContext BC) {}
}