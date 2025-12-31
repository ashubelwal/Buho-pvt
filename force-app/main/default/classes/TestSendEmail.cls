@isTest(seeAllData=true) 
private class TestSendEmail {
  //condition 1
     Static testmethod void test1(){
    EmailTemplate e = new EmailTemplate (developerName = 'Loyal_Client_Feedback',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'Loyal Client Feedback'); // plus any other fields that you want to set
     insert e;

     EmailTemplate e1 = new EmailTemplate (developerName = 'Survey_Template',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'Survey_Template'); // plus any other fields that you want to set
     insert e1;
    user usr=[select id from user where id=:UserInfo.getUserId()];
      Test.startTest();
         System.runAs ( usr) {
       
        id antid;
       boolean send = true;
         //Account 1
        Account a = new Account();
        a.name = 'aacccount';
        a.Email__c='yuvraj@gmail.com';
        insert a;
      
  /*Contact c = new Contact();
        c.LastName='test con ';
        c.Email='yuvraj@gmail.com';
        c.AccountId=a.id;
        insert c;    */     
         //policy 1
        Policy__c po= new Policy__c();
        po.Account_Policy__c= a.id;
        po.Term__c='daily';
        po.Loyal_Client_Survey_Check__c=false;
        po.Send_Survey__c=false;
        insert po; 
         po.Send_Survey__c=true;
        update po;
     
            
             Policy__c pol1 = new Policy__c();
        pol1.Account_Policy__c=a.id;
        pol1.Send_Survey__c=false;  
        pol1.Term__c='semi';
        insert pol1; 
         //policy 2
        Policy__c po2= new Policy__c();
        po2.Account_Policy__c= a.id;
        po2.Term__c='annual';
        po2.Loyal_Client_Survey_Check__c=false;
             // po2.Send_Survey__c=true;
        insert po2;
         //contact 1
      
         
        Test.stopTest();
         }
    }
  //condition 2
    static testmethod void te2(){
        EmailTemplate e = new EmailTemplate (developerName = 'Loyal_Client_Feedback',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'Loyal Client Feedback'); // plus any other fields that you want to set
     insert e;

     EmailTemplate e1 = new EmailTemplate (developerName = 'Survey_Template',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'Survey_Template'); // plus any other fields that you want to set
     insert e1;
    user usr=[select id from user where id=:UserInfo.getUserId()];
      Test.startTest();
         System.runAs ( usr) {
        Account a = new Account();
        a.name='test';
       a.Email__c='acbccb@gmail.com';
        insert a;
        
       /* Contact c = new Contact ();
        c.LastName='test con';
        c.Email='abcdgdf@gmail.com';
        c.AccountId=a.id;
        insert c;
        
          Contact c2 = new Contact ();
        c2.LastName='test con';
        c2.Email='abcdgdf@gmail.com';
        c2.AccountId=a.id;
        insert c2;*/
        
        Policy__c pol = new Policy__c();
        pol.Account_Policy__c=a.id;
        pol.Send_Survey__c=false;  
        insert pol;     
        
             
     
        Policy__c pol3 = new Policy__c();
        pol3.Account_Policy__c=a.id;
        pol3.Send_Survey__c=false;  
        pol3.Term__c='daily';
        insert pol3;
             
        Policy__c pol4 = new Policy__c();
        pol4.Account_Policy__c=a.id;
        pol4.Send_Survey__c=false;  
        pol4.Term__c='daily';
        insert pol4;
        Test.stopTest();
         }
    }   
}