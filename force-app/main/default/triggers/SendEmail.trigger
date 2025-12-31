trigger SendEmail on Policy__c (before update,before insert) {
    try{
    EmailTemplate et=[Select id from EmailTemplate where name=:'Survey Template' limit 1]; 
    EmailTemplate et1=[Select id from EmailTemplate where name=:'Loyal Client Feedback' limit 1];
    
   List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
   id antid;
   boolean send= false;
     Set<ID> Daily_account = new Set<id>();
     Set<ID> Con_Final = new Set<id>();
     List<Contact> up_con = new List<Contact>();
    //for semi and annual term in policy
    map<id,contact> cnt_term= new map<id,contact>();
    if(Trigger.isUpdate){     
   for(Policy__c po1: trigger.new)
   {
       Policy__c oldpolicy =Trigger.oldMap.get(po1.id);
       system.debug(oldpolicy );
       if(oldpolicy.Send_Survey__c ==false && po1.Send_Survey__c==true)
         send= true;
       antid=po1.Account_Policy__c;    
       system.debug(antid); 
         
   }
    map<id,contact> cnt= new map<id,contact>([select email, id  from contact where Accountid=:antid And Post_Sale__c = FALSE]);
        
   if(send)
   {
     system.debug('i m in the loop to send email--->'+send);
       for(id cnt1:cnt.keySet())
       {
           cnt.get(cnt1).Post_Sale__c= true;
             Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
             //set object Id
             singleMail.setTargetObjectId(cnt1);
                    //singleMail.setTargetObjectId('003q000000Ry6pt');
            //set template Id
                    singleMail.setTemplateId(et.Id);
            //add mail
                    emails.add(singleMail);
    
                    //send mail
                    
        }
  
          //TEMP CHANGE
          //Messaging.sendEmail(emails);
          update  cnt.values();
       }  
    }
    if(Trigger.isInsert){
    for (Policy__c pol : trigger.new){
        
        if(pol.Term__c=='semi' ||pol.Term__c== 'annual'){
         antid= pol.Account_Policy__c;
         //   cnt_term= new map<id,contact>([select email, id  from contact where Accountid=:pol.Account_Policy__c]);
          //  System.debug('contact details for new'+cnt_term);
 Daily_account.add(antid);
        }
       
        else if(pol.Term__c=='daily'){
        antid= pol.Account_Policy__c ;
             List<AggregateResult> results = [Select Count(Id),Account_Policy__c,Term__c  From Policy__c  WHERE  Term__c = 'daily' AND Account_Policy__c =: antid  GROUP BY Account_Policy__c,Term__c];
           //  Set<ID> Daily_account = new Set<id>();
             for (AggregateResult ar : results)  {
             id myacc = (id)ar.get('Account_Policy__c');
                  System.debug('-----------------account id: ' +myacc);
             Integer numApps = (Integer) ar.get('expr0');
             if(numApps >= 2 ){ 
             Daily_account.add(antid);     
                             }
                             }
        System.debug('settt: account id: ' +Daily_account);
       
      
    }
         
    }
        cnt_term= new map<id,contact>([Select id,Email from Contact where accountid IN : Daily_account AND Loyal_Client__c = FALSE]); 
        System.debug('value in map'+cnt_term);
    for(id cnt1:cnt_term.keySet())
       {
            System.debug('id values of contacts '+cnt1);
             Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
             //set object Id
             singleMail.setTargetObjectId(cnt1);
             singleMail.setTemplateId(et1.Id);
             emails.add(singleMail);            
        }
            //TEMP CHANGE
            //Messaging.sendEmail(emails);
            Con_Final.addAll(cnt_term.keySet()); 
            
            up_con = [Select id,Loyal_Client__c from Contact WHERE id In :Con_Final];
            
            for(Contact c : up_con){
            c.Loyal_Client__c = TRUE;
            }
    update up_con;
   
}
    }
    catch(Exception e){
        
    }
}