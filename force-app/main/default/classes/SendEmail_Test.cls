@isTest
public class SendEmail_Test{

 static testmethod void testemail()
 {
 EmailTemplate e = new EmailTemplate (developerName = 'Survey_Template',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'Survey Template'); // plus any other fields that you want to set
insert e;
system.debug('UserInfo.getUserId-->'+UserInfo.getUserId());

user usr=[select id from user where id=:UserInfo.getUserId()];
 test.starttest();
  System.runAs ( usr) {
      
       TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;

      
     Account act= new Account();
      act.Name='Test Account';
      act.Email__c='sumitksingh1990@yahoo.in';
      insert act;
      
      Policy__c policy = new Policy__c();
      system.debug('act-id  '+ act.id);
      policy.Account_Policy__c= act.id;
      policy.Name='12344';
      
      insert policy;
      
      policy.Send_Survey__c= true;
      update policy;
      }

  
      test.Stoptest();
 }
}