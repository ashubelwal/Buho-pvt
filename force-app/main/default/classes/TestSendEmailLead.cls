@istest
public class TestSendEmailLead {

    public static testMethod void test()
    {
     EmailTemplate e = new EmailTemplate (developerName = 'Lead_Survey_Template',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
    insert e;

    user usr=[select id from user where id=:UserInfo.getUserId()];
     test.starttest();
     System.runAs ( usr) {
    
      Lead ld = new Lead();
        ld.Status='new';
         ld.FirstName='test';
         ld.Email= 'sumitksingh1990@yahoo.in';
         ld.LastName='abc';
        ld.Company='test';
        insert ld;
      
         ld.Lead_Survey__c = True;
         update ld;

  
      test.Stoptest();
 }
}
}