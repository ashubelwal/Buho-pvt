@isTest
public class salesurvey_test {
      public static testmethod void getItems(){
       
          Account acc = new Account ();
          acc.Name ='test account';          
          insert acc;
          
          Contact con = new Contact();
          con.FirstName = 'test';
          con.LastName = 'contact';
          con.AccountId = acc.id;
          insert con;
          
          PageReference pageRef = Page.salesurvey;
           Test.setCurrentPage(pageRef);
           System.currentPageReference().getParameters().put('conid', con.id);
          
          Survey__c survey = new Survey__c();
          survey.Name='Post Sale';
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
          
           SurveyTaker__c sur = new SurveyTaker__c();
           sur.Contact__c = con.id;
           sur.Taken__c = 'false' ;
           sur.Survey__c = survey.id; //'a0RP0000001Uw6XMAS';
           insert sur;
          salesurvey cls = new salesurvey();
          cls.getItems();
          cls.save();
          cls.mform = true;
          cls.thankYou = false;
          cls.selectedans = 'myselected';
          cls.selectedspeed  = 'selectedspeed';
          cls.selectedservice  = 'selectedservice ';
          cls.selectedrate  = 'selectedrate ';
          cls.explain = 'Please Explain';
        
          
          
          
          
          cls.conid = con.id;
         
      }
}