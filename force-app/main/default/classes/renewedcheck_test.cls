@isTest(seealldata=true)
public class renewedcheck_test{


 static testmethod void testemail()
 {
     
 EmailTemplate e = new EmailTemplate (developerName = 'NonRenewal_Survey_Template',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
insert e;

user usr=[select id from user where id=:UserInfo.getUserId()];
test.starttest();
  System.runAs ( usr) {
     
     Account act= new Account();
      act.Name='Test Account';
      act.Email__c='sumitksingh1990@yahoo.in';
      insert act;
      
      Policy__c policy = new Policy__c();
      policy.Account_Policy__c= act.id;
      policy.Name='123445555';
      policy.id__c='123456';
      policy.renewed_check__c= false;
      insert policy;
      
      contact cont = new contact();
      cont.AccountId = act.Id;
      cont.LastName = 'testlastname';
      
      insert cont;
      
      
      
      policy.renewed_check__c= true;
      update policy;
      
  }
     
     test.Stoptest();
      
 }


}