trigger SendEmailLead on Lead (after update) {
  try{  
EmailTemplate et=[Select id from EmailTemplate where name=:'Lead Survey Template']; 
   
   List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
 
   
    for(Lead Ld1: trigger.new)
   {
       Lead oldLead=Trigger.oldMap.get(Ld1.id);
       system.debug(oldLead );
       if(oldLead.Lead_Survey__c ==false && Ld1.Lead_Survey__c==true)  
       {
           Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
             //set object Id
             singleMail.setTargetObjectId(Ld1.id);
                    //singleMail.setTargetObjectId('003q000000Ry6pt');
            //set template Id
                    singleMail.setTemplateId(et.Id);
            //add mail
                    emails.add(singleMail);
           system.debug('I Am in the test');
       }
          
       
        
   }
  
    
        //TEMP CHANGE   
        //Messaging.sendEmail(emails);
    }
     catch(Exception e){
        
    }        
}