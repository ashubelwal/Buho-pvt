public class PolicyHandlerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful {
    public static Date pastTwoYEars = Date.newInstance(2022, 1, 1);
    public List<Contact> finalContactList = new List<Contact>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('Select Id, Name,Email,(Select Id, CreatedDate, Status_picklist__c from Policies__r)'+ 
                                        ' from Contact '+
                                        ' Where Id IN (Select ContactId from User Where isActive = true) ORDER BY CreatedDate DESC ');
    }
    public void execute(Database.BatchableContext bc, List<Contact> records){
        
        if(records.size()> 0){
            
            for(Contact each : records){
                Boolean isCheck = false;
                if(each.Policies__r.size() == 0){
                    isCheck = true;
                }
                for(Policy__c eachPolicy : each.Policies__r){
                    if(eachPolicy.CreatedDate >= pastTwoYEars){
                        isCheck = true; 
                    }
                }
                
                if(!isCheck){
                    finalContactList.add(each);
                }
            }
            
        }
    }    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
        mymail.setToAddresses(new List<String>{'saurabh.rawat@cloudanalogy.com','atul.rai@cloudanalogy.com'});
        mymail.setSubject('Post Processing Completed: Action Required');
        String mailBody = '';
        mailBody += '<p>Hi Team,<p>'+
            '<p>Records has been processed and we have found ' +finalContactList.size()+' matching the criteria. Please find the list below:<p>';
        mailBody = '<table border="1" style="border-collapse:collapse;width:100%;">'+
            '<tr style="font-weight:bold;">'+
            '<td>Name</td><td>Email</td><td>Id</td>'+
            '</tr>';
        for(Contact each : finalContactList){
            mailBody += '<tr>'+
                '<td>'+each.Name+'</td><td>'+each.Email+'</td><td>'+each.Id+'</td>'+
                '</tr>';
        }
        mailBody += '</table>';
        mymail.setHtmlBody(mailBody);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });    
        }
        
        
    }  
}