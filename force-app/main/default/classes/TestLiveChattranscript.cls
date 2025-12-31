@istest
public class TestLiveChattranscript {

    public static testMethod void test()
    {
     EmailTemplate e = new EmailTemplate (developerName = 'Post_Service_Template',IsActive=true , Folderid =UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
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
      
      LiveChat_transcript__c lct= new LiveChat_transcript__c();
      lct.Lead__c=ld.id;
      lct.Post_Service__c = false;
      lct.LiveChat_Chat_Id__c='asdgl123';
      
      insert lct;
      
         lct.Post_Service__c = True;
         update lct;

  
      test.Stoptest();
 }
}
}