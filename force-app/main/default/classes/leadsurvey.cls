public with sharing class leadsurvey {

   

    public string leadid{get;set;}

    public leadsurvey(){
    selectedans = 'I plan to purchase Mex-Insurance, just not right now.';
    leadid = ApexPages.currentPage().getParameters().get('leadid');
    thankYou = false;
    mform = true;
    }
    
    
    public String selectedans { get; set; }
    public String whccom{ get; set; }
    public String explain{ get; set; }
    public Boolean thankYou{get;set;}
     public Boolean mform{get;set;}

    public PageReference save() {
    
    Survey__c survey = [select id from Survey__c where name=:'Lead' ];
    list<Survey_Question__c>  surevyquestion =[SELECT Name,OrderNumber__c,Survey__c FROM Survey_Question__c where Survey__c=:survey.id  ORDER BY OrderNumber__c ASC NULLS LAST];
    map<Decimal,Survey_Question__c> surveyquestionmap= new map<Decimal,Survey_Question__c>();
    for(Survey_Question__c surveyq :surevyquestion )
    {
       surveyquestionmap.put(surveyq.OrderNumber__c, surveyq );
    }
    system.debug(surveyquestionmap.get(0).id);
    
       SurveyTaker__c sur = new SurveyTaker__c();
       sur.Lead__c = leadid;
       sur.Taken__c = 'false' ;
       sur.Survey__c = survey.id; //'a0RP0000001Uw6XMAS';
       insert sur;
       id que = sur.Id;
       List<SurveyQuestionResponse__c> surveyquesresplist = new List<SurveyQuestionResponse__c>();
       SurveyQuestionResponse__c queres;
      queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(0).id, Response__c = selectedans );
      surveyquesresplist.add(queres);
      if(whccom != ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(1).id, Response__c = whccom);
         surveyquesresplist.add(queres);
       }
       if(explain != ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(2).id, Response__c = explain);
         surveyquesresplist.add(queres);
       }
      insert surveyquesresplist ;
      mform = false;
      thankYou = true;
        return null;
    }

   
    
    public List<SelectOption> getItems() {
    
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('I plan to purchase Mex-Insurance, just not right now.','I plan to purchase Mex-Insurance, just not right now.')); 
        options.add(new SelectOption('I went with another company.','I went with another company.')); 
        options.add(new SelectOption('Mex-Insurance didn’t meet my needs.','Mex-Insurance didn’t meet my needs.')); return options; 
    }
    
    
}