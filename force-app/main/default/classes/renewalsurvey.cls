public with sharing class renewalsurvey{

   

    public string conid{get;set;}

    public renewalsurvey(){
    selectedans = 'I just haven’t gotten around to it yet thanks for the reminder.';
    conid = ApexPages.currentPage().getParameters().get('conid');
    thankYou = false;
    mform = true;
    }
    
    
    public String selectedans { get; set; }
    public String whccom{ get; set; }
    public String why{ get; set; }
    public String explain{ get; set; }
     public String better{ get; set; }
     public String getback{ get; set; }
      public String provide{ get; set; }
    public Boolean thankYou{get;set;}
     public Boolean mform{get;set;}

    public PageReference save() {
    
    Survey__c survey = [select id from Survey__c where name=:'NonRenewal Survey' ];
    list<Survey_Question__c>  surevyquestion =[SELECT Name,OrderNumber__c,Survey__c FROM Survey_Question__c where Survey__c=:survey.id  ORDER BY OrderNumber__c ASC NULLS LAST];
    map<Decimal,Survey_Question__c> surveyquestionmap= new map<Decimal,Survey_Question__c>();
    for(Survey_Question__c surveyq :surevyquestion )
    {
       surveyquestionmap.put(surveyq.OrderNumber__c, surveyq );
    }
    system.debug(surveyquestionmap.get(0).id);
    
       SurveyTaker__c sur = new SurveyTaker__c();
       sur.Account__c = conid;
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
       
       if(why != ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(2).id, Response__c = why);
         surveyquesresplist.add(queres);
       }
       if(explain != ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(3).id, Response__c = explain);
         surveyquesresplist.add(queres);
       }
        if(getback!= ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(4).id, Response__c = getback);
         surveyquesresplist.add(queres);
       }
        if(better != ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(5).id, Response__c = better);
         surveyquesresplist.add(queres);
       }
        if(provide != ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(6).id, Response__c = provide);
         surveyquesresplist.add(queres);
       }
      insert surveyquesresplist ;
      mform = false;
      thankYou = true;
        return null;
    }

   
    
    public List<SelectOption> getItems() {
    
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('I went with another company.','I went with another company.')); 
        options.add(new SelectOption('I am not in Mexico anymore.','I am not in Mexico anymore.')); 
        options.add(new SelectOption('I just haven’t gotten around to it yet thanks for the reminder.','I just haven’t gotten around to it yet thanks for the reminder.'));
         options.add(new SelectOption('I’m going rogue without insurance.','I’m going rogue without insurance.')); 
         options.add(new SelectOption('Other.','Other.')); 
        return options; 
    }
    
    
}