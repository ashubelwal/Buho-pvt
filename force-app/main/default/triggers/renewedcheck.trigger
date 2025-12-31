trigger renewedcheck on Policy__c (before update) {
   
   public boolean sendrenew= FALSE ;
   try{
    Policy__c oldpol;
    for(Policy__c pol: trigger.new)
   {
   oldpol = Trigger.oldMap.get(pol.Id);
       if(oldpol.renewed_check__c == false && pol.renewed_check__c== true){
           sendrenew = true;
           
       }
   }
   
    if(sendrenew)
    { 
         List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et=[Select id from EmailTemplate where name=:'NonRenewal Survey Template' limit 1]; 
    integer policycount = [SELECT count() FROM Policy__c where renewed_from_id__c =:String.valueof(oldpol.Id__c) ];
        if(policycount==0)
        {
            map<id,contact> cnt= new map<id,contact>([select email, id  from contact where Accountid=:oldpol.Account_Policy__c ]);
            
             for(id cnt1:cnt.keySet())
       {
         
             Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
             //set object Id
             singleMail.setTargetObjectId(cnt1);
                    //singleMail.setTargetObjectId('003q000000Ry6pt');
            //set template Id
                    singleMail.setTemplateId(et.Id);
                    singleMail.setWhatid(oldpol.id);
            //add mail
                    emails.add(singleMail);
    
                    //send mail
                    
        }
            Messaging.sendEmail(emails);
        }
        
    }
    }
     catch(Exception e){
        
    }
}