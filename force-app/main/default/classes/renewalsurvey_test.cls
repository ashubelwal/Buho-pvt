@isTest
public class renewalsurvey_test {
       public static testmethod void getItems(){
        
          Account acc = new Account ();
          acc.Name ='test account';          
          insert acc;
          
          //Contact con = new Contact();
         // con.FirstName = 'test';
         // con.LastName = 'contact';
         // con.AccountId = acc.id;
         // insert con;
          
          PageReference pageRef = Page.renewalsurvey;
           Test.setCurrentPage(pageRef);
           System.currentPageReference().getParameters().put('conid', acc.id);
           
           Survey__c survey = new Survey__c();
          survey.Name='NonRenewal Survey';
          survey.Submit_Response__c='shdhsajdhka';
          
          insert survey;
          
           Survey_Question__c squs = new Survey_Question__c();
          squs.Name='squs';
          squs.Survey__c=survey.id;
          squs.OrderNumber__c=0;
          squs.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs;
          
           Survey_Question__c squs1 = new Survey_Question__c();
          squs1.Name='squs';
          squs1.Survey__c=survey.id;
          squs1.OrderNumber__c=1;
          squs1.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs1;
          
          
           Survey_Question__c squs2 = new Survey_Question__c();
          squs2.Name='Lead';
          squs2.Survey__c=survey.id;
          squs2.OrderNumber__c=2;
          squs2.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs2;
          
          Survey_Question__c squs3 = new Survey_Question__c();
          squs3.Name='Lead';
          squs3.Survey__c=survey.id;
          squs3.OrderNumber__c=3;
          squs3.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs3;
          
          Survey_Question__c squs4 = new Survey_Question__c();
          squs4.Name='Lead';
          squs4.Survey__c=survey.id;
          squs4.OrderNumber__c=4;
          squs4.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs4;
          
          Survey_Question__c squs5 = new Survey_Question__c();
          squs5.Name='Lead';
          squs5.Survey__c=survey.id;
          squs5.OrderNumber__c=5;
          squs5.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs5;
          
          Survey_Question__c squs6 = new Survey_Question__c();
          squs6.Name='Lead';
          squs6.Survey__c=survey.id;
          squs6.OrderNumber__c=6;
          squs6.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs6;
          
          SurveyTaker__c sur = new SurveyTaker__c();
            sur.Account__c = acc.id;
           sur.Taken__c = 'false' ;
           sur.Survey__c = survey.id; //'a0RP0000001Uw6XMAS';
           insert sur;
          renewalsurvey cls = new renewalsurvey();
          cls.getItems();
          cls.save();
          
       }

}