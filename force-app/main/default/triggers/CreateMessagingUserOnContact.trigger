trigger CreateMessagingUserOnContact on Contact (after insert) {
     if(trigger.isAfter){ 
        
         CreateMessagingUserWithContactAsync cmu = new CreateMessagingUserWithContactAsync(trigger.new);
         ID jobID = System.enqueueJob(cmu);
        System.debug('test' +jobID);
       
    }
   
   
}