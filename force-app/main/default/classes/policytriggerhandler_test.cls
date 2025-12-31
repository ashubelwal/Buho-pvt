@isTest
public class policytriggerhandler_test {
    public static testMethod void sendEmailAlert(){
          TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        Date myDate = Date.newInstance(2015, 1, 1);
        DateTime myDateTime = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
        Set <String > acid = new Set <String>(); 
       // Set<string Id> acid = new Set <String Id>();
         Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        acObj.Created_At__c = myDate;
        acObj.Email__c = 'asdf@gmail.com';
        insert acObj;
        acid.add(acObj.Id); 
        
        List<Policy__c> policyList = new List<Policy__c>();
        
        Policy__c policydata = new Policy__c();
       // for(Integer i= 0; i < 2; i++ ){
        policydata.Account_Policy__c = acObj.Id;
            policydata.Affiliate_Account__c = acObj.Id;
        policydata.End_at__c = myDateTime;
        policydata.Name = 'Policy';
        policyList.add(policydata);
      //  }
     //   insert policydata;
        Policy__c policyObj= new Policy__c();
         policyObj.Account_Policy__c = acObj.Id;
            policyObj.Affiliate_Account__c = acObj.Id;
        policyObj.End_at__c = myDateTime;
        policyObj.Name = 'Policy1';
        policyList.add(policyObj);
        
        insert policyList;
        
        
        //List<EmailTemplate> postServiceETList = new List<EmailTemplate>([SELECT Id, DeveloperName, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Loyal_Client_Feedback']);
        test.startTest();
        PoliciesTriggerHandler.sendEmailAlert(acid);
        test.stopTest();
    }
}