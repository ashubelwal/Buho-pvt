global class PopulatePaymentDetailClassbatch implements Database.Batchable<SObject>, Schedulable {
    
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM Account limit 1');
    } 
    global void execute(Database.BatchableContext BC, List<Account> AccUp){
        try{
            PopulatePaymentDetail.calculateAndPopulateData();
            
        }catch(Dmlexception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    global void finish(Database.BatchableContext BC){
        system.debug('Batch finished');
    }
    
     global void execute(SchedulableContext sc) {
         PopulatePaymentDetailClassbatch b = new PopulatePaymentDetailClassbatch();
         database.executebatch(b);
     }
    
    
    
    
    
    
}