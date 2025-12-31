@isTest
public class leadsurvey_test {
       
   
      public static testmethod void getItems(){
           Lead ld = new Lead ();
          ld.State='New';
          ld.LastName='test';
          ld.Company='test comepa';
          
          insert ld;
           PageReference pageRef = Page.leadsurvey;
           Test.setCurrentPage(pageRef);
           System.currentPageReference().getParameters().put('leadid', ld.id);

          
         
          
          Survey__c survey = new Survey__c();
          survey.Name='Lead';
          survey.Submit_Response__c='shdhsajdhka';
          
          insert survey;
          
          Survey_Question__c squs = new Survey_Question__c();
          squs.Name='squs';
          squs.Survey__c=survey.id;
          squs.OrderNumber__c=2;
          squs.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs;
          
           Survey_Question__c squs1 = new Survey_Question__c();
          squs1.Name='squs';
          squs1.Survey__c=survey.id;
          squs1.OrderNumber__c=0;
          squs1.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs1;
          
          
           Survey_Question__c squs2 = new Survey_Question__c();
          squs2.Name='Lead';
          squs2.Survey__c=survey.id;
          squs2.OrderNumber__c=1;
          squs2.Question__c='sjdhjkashkdhaskjdkasjdlas';
          insert squs2;
          
      SurveyTaker__c sur = new SurveyTaker__c();
       sur.Lead__c = ld.id;
       sur.Taken__c = 'false' ;
       sur.Survey__c = survey.id; //'a0RP0000001Uw6XMAS';
       insert sur;
          
          
         leadsurvey cls = new leadsurvey();
        cls.getItems();
         cls.whccom = 'test';
         cls.selectedans = 'myselected';
         cls.explain = 'Please Explain';
         cls.thankYou = false;
         cls.mform = true;
  		 cls.leadid = ld.id;
          cls.save();
     }
}