trigger CreateMessagingUser on Lead (after insert) { 
    
    if(trigger.isAfter){ 
        
         CreateMessagingUserAsync cmu = new CreateMessagingUserAsync(trigger.new);
         ID jobID = System.enqueueJob(cmu);
        System.debug('test' +jobID);
       
    }

   
   
}