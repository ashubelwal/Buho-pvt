public with sharing class loyalsurvey {

   

    public string conid{get;set;}

    public loyalsurvey (){
    //selectedans = '10';
    // selectedspeed = '10';
  // selectedservice = '10';
   // selectedbrand = 'Tshirt';
    conid = ApexPages.currentPage().getParameters().get('conid');
    thankYou = false;
    mform = true;
    }
    
    public String selectedbrand { get; set; }
   public String provider{ get; set; }
    public String wear{ get; set; }
   public String better { get; set; }
    public String[] selectedans { get; set; }
    public String explain{ get; set; }
    public Boolean thankYou{get;set;}
     public Boolean mform{get;set;}

    public PageReference save() {
    
    Survey__c survey = [select id from Survey__c where name=:'Loyal Client' ];
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
       
     // queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(0).id, Response__c = selectedans );
     // surveyquesresplist.add(queres);
     
     if(explain != ''){
         queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(1).id, Response__c = explain);
         surveyquesresplist.add(queres);
       }
if(better != ''){
      queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(2).id, Response__c = better);
         surveyquesresplist.add(queres);
         }
         if(selectedbrand!= ''){
     queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(3).id, Response__c = selectedbrand);
        surveyquesresplist.add(queres);
        }
         if(wear != ''){
       queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(4).id, Response__c = wear);
          surveyquesresplist.add(queres);
      }
       if(provider != ''){
       queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(5).id, Response__c = provider);
          surveyquesresplist.add(queres);
      }
      
       for(string multiselect :selectedans )
       {
        queres = new SurveyQuestionResponse__c(SurveyTaker__c = que, Survey_Question__c = surveyquestionmap.get(0).id, Response__c = multiselect );
          surveyquesresplist.add(queres);
       }
      insert surveyquesresplist ;
      mform = false;
      thankYou = true;
        return null;
    }

   
    
    public List<SelectOption> getItems() {
    selectedans = new String[0];
        List<SelectOption> options = new List<SelectOption>(); 
   
    options.add(new SelectOption('The Price','The Price'));
     options.add(new SelectOption('The Website is great','The Website is great'));
      options.add(new SelectOption('The convenience','The convenience'));
       options.add(new SelectOption('The people','The people'));
        options.add(new SelectOption('The service','The service'));
         options.add(new SelectOption('Other','Other'));
   
         return options; 
    }
  public List<SelectOption> getbrands() {
  
        List<SelectOption> options = new List<SelectOption>(); 
   
    options.add(new SelectOption('Tshirt','Tshirt'));
     options.add(new SelectOption('Hat','Hat'));
      options.add(new SelectOption('Golf Shirt','Golf Shirt'));
       options.add(new SelectOption('No I would never wear branded stuff','No I would never wear branded stuff'));
        options.add(new SelectOption('OK I might wear','OK I might wear'));
   
         return options; 
    }
  // public string getOutputText() {
  //      return String.join(selectedans, ',');
   // }
   
    
}