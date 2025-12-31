trigger PostService on LiveChat_transcript__c (before update) {
   EmailTemplate et=[Select id from EmailTemplate where name=:'Post Service Template']; 
   
   List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
 
   
    for(LiveChat_transcript__c Ld1: trigger.new)
   {
       LiveChat_transcript__c oldLead=Trigger.oldMap.get(Ld1.id);
       system.debug(oldLead );
       if(oldLead.Post_Service__c ==false && Ld1.Post_Service__c==true)  
       {
           Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
             //set object Id
              if(ld1.Contact__c!=null)
             singleMail.setTargetObjectId(ld1.Contact__c);
             else if(ld1.Lead__c!=null)
             singleMail.setTargetObjectId(ld1.Lead__c);
             
                    //singleMail.setTargetObjectId('003q000000Ry6pt');
            //set template Id
                    singleMail.setTemplateId(et.Id);
                    singleMail.setWhatId(ld1.id);
                    singleMail.setSaveAsActivity(false);
            //add mail
                    emails.add(singleMail);
           system.debug('I Am in the test');
       }
          
       
        
   }
  
    
       
        Messaging.sendEmail(emails);

}