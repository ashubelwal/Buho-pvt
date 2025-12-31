public with sharing class servicesurvey {

   
public string leadid{get;set;}
    public string conid{get;set;}

    public servicesurvey (){
    //selectedans = 'Fast';
    selectedrate = '10';
    selectedfriend = '10';
   selecteknowledge= '10';
  // selectedcare = 'Yes' ;
   
    conid = ApexPages.currentPage().getParameters().get('conid');
    leadid = ApexPages.currentPage().getParameters().get('leadid'); 
    thankYou = false;
    mform = true;
    }
    
    public String selectedrate { get; set; }
    public String selectedfriend { get; set; }
    public String selecteknowledge{ get; set; }
    public String selectedcare{ get; set; }
    public String selectedans { get; set; }
    public String explain{ get; set; }
    public Boolean thankYou{get;set;}
     public Boolean mform{get;set;}

    public PageReference save() {
    
    Survey__c survey = [select id from Survey__c where name=:'Post Service' ];
    list<Survey_Question__c>  surevyquestion =[SELECT Name,OrderNumber__c,Survey__c FROM Survey_Question__c where Survey__c=:survey.id  ORDER BY OrderNumber__c ASC NULLS LAST];
    map<Decimal,Survey_Question__c> surveyquestionmap= new map<Decimal,Survey_Question__c>();
    for(Survey_Question__c surveyq :surevyquestion )
    {
       surveyquestionmap.put(surveyq.OrderNumber__c, surveyq );
    }
    system.debug(surveyquestionmap.get(0).id);
    
       SurveyTaker__c sur = new SurveyTaker__c();
      if(leadid !=''){
sur.Lead__c = leadid;
}
if(conid !=''){
sur.Contact__c = conid;
}
       sur.Taken__c = 'false' ;
       sur.Survey__c = survey.id; //'a0RP0000001Uw6XMAS';
       insert sur;
       id que = sur.Id;
       List<SurveyQuestionResponse__c> surveyquesresplist = new List<SurveyQuestionResponse__c>();
       SurveyQuestionResponse__c queres;
      queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(0).id, Response__c = selectedans );
      surveyquesresplist.add(queres);
      queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(1).id, Response__c = selectedrate);
         surveyquesresplist.add(queres);
      queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(2).id, Response__c = selectedfriend);
         surveyquesresplist.add(queres);
      queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(3).id, Response__c = selecteknowledge);
         surveyquesresplist.add(queres);
      queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(3).id, Response__c = selectedcare);
         surveyquesresplist.add(queres);
      if(explain!= ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(4).id, Response__c = explain);
         surveyquesresplist.add(queres);
       }
      insert surveyquesresplist ;
      mform = false;
      thankYou = true;
        return null;
    }

   
    
    public List<SelectOption> getItems() {
    
        List<SelectOption> options = new List<SelectOption>(); 
    for (Integer i = 1; i <= 10; i++){
    options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
    }
         return options; 
    }
  
  
}