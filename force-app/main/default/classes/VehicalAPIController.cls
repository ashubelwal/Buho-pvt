public with sharing class VehicalAPIController {
    @AuraEnabled
    public static List<object> getYears(){
        /*  HttpRequest httpRequest = new HttpRequest();  
system.debug('label.URL_To_Get_Years ->'+ label.URL_To_Get_Years);
httpRequest.setEndpoint(label.URL_To_Get_Years);
httpRequest.setMethod('GET');
String strResponse = null;
Http http = new Http();   
HttpResponse httpResponse = http.send(httpRequest);  
strResponse = httpResponse.getBody();  
system.debug('>>> strResponse... '+strResponse);
string formattedResponse = strResponse.replace('?(','');
formattedResponse = formattedResponse.replace(');','');
JSON2GetYearsApex myClass = JSON2GetYearsApex.parse(formattedResponse);
system.debug('>>> myClass... ' + myClass);*/
        Integer minYear = integer.valueof(label.URL_To_Get_Years);
        Integer maxYear = system.today().Year(); //2022;//integer.valueof(myClass.Years.max_year);
        
        List<object> yearsList = new List<object>();
        for(Integer i = (maxYear+1) ;i >= minYear;i--){
            yearsList.add( new map<String,object>{ 'label' => String.valueOf(i), 'value' => String.valueOf(i)});
        } 
        return yearsList;
    }
    public Class CarAPIAuthWrap{
        public string api_token;
        public String api_secret;
        public CarAPIAuthWrap(){
            
            this.api_token = CarApi_Config__c.getOrgDefaults().Client_Token__c;
            this.api_secret = CarApi_Config__c.getOrgDefaults().Client_Secret__c;
        }
    }
    public Class CarAPIMake{
        public List<MakeData> data;
    }
    public class MakeData{
        public String name;
    }  
    
    public static String fetchCarAPIAuthToken(){
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setEndpoint('https://carapi.app/api/auth/login');
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Content-Type','application/json');
        httpRequest.setHeader('accept','text/plain');
        httpRequest.setBody(JSON.serialize(new CarAPIAuthWrap()));
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequest);  
        String jwtToken = httpResponse.getBody();  
        if(String.isNotBlank(jwtToken)){
            return jwtToken;
        }else{
            return null;    
        }
        
    }
    
    
    public static List<object> getMakesfromCarAPI(String year){
        List<object> makesList = new List<object>();
        makesList.add( new map<String,String>{ 'label' => '<Manually Enter>', 'value' => '<Manually Enter>'});
        //fetch makes from CAR API
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setEndpoint('https://carapi.app/api/makes?year='+year);
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('accept','application/json');
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequest);  
        String makeResponse = httpResponse.getBody();  
        if(String.isNotBlank(makeResponse)){
            CarAPIMake makes = (CarAPIMake)JSON.deserialize(makeResponse, CarAPIMake.class);
            if(makes!= null){
                for(MakeData dat : makes?.data){
                    System.debug(dat);
                    makesList.add( new map<String,String>{ 'label' => dat.name, 'value' => dat.name});
                }
            }
            
        }
        return makesList;
    }
    
    public static List<object> getMakes(string year){
        if(CarApi_Config__c.getOrgDefaults().Enable_Make_Finder__c){
            return getMakesfromCarAPI(year);
        }else{
            HttpRequest httpRequest = new HttpRequest();  
            string makeURL = label.URL_To_Get_Makes;
            httpRequest.setEndpoint(makeURL);
            httpRequest.setMethod('GET');
            httpRequest.setTimeout(120000);
            String strResponse = null;
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            strResponse = httpResponse.getBody();  
            system.debug('>>> strResponse... '+strResponse);
            string formattedResponse = strResponse.replace('?(','');
            formattedResponse = formattedResponse.replace(');','');
            JSON2MakesApex json2MakesObj = JSON2MakesApex.parse(formattedResponse);
            system.debug('>>> json2MakesObj... ' + json2MakesObj.Results);
            
            List<object> makesList = new List<object>();
            makesList.add( new map<String,String>{ 'label' => '<Manually Enter>', 'value' => '<Manually Enter>'});
            List<String> allmakeVal = new List<String>();
            for(JSON2MakesApex.Result mk : json2MakesObj.Results){
                if(!mk.MakeName.contains(' ')){
                    allmakeVal.add(mk.MakeName);
                }
            }
            allmakeVal.sort();
            for(String makeName : allmakeVal){
                makesList.add( new map<String,String>{ 'label' => makeName.substring(0,1).toUpperCase() + makeName.substring(1,makeName.length()).toLowerCase(), 'value' => makeName });               
            }
            
            return makesList;
        }
        
    }
    
    @AuraEnabled
    public static List<object> fetchModelfromCarAPI(string year, string make){
        List<object> modelList = new List<object>();
        modelList.add( new map<String,object>{ 'label' => '<Manually Enter>', 'value' => '<Manually Enter>'});
        //fetch auth jwt token
        String jwtToken = fetchCarAPIAuthToken();
        if(String.isNotBlank(jwtToken)){
            // making models callouts
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setEndpoint('https://carapi.app/api/models?year='+year+'&make='+make);
            httpRequest.setMethod('GET');
            httpRequest.setTimeout(120000);
            httpRequest.setHeader('accept','application/json');
            httpRequest.setHeader('Authorization','Bearer '+jwtToken);
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            String strResponse = httpResponse.getBody();  
            
            if(String.isNotBlank(strResponse)){
                CarAPIMake modelWrap = new CarAPIMake();
                modelWrap = (CarAPIMake)JSON.deserialize(strResponse, CarAPIMake.class);
                if(modelWrap!= null){
                    for(MakeData eachModel : modelWrap?.data){
                        modelList.add( new map<String,object>{ 'label' => eachModel.name, 'value' =>  eachModel.name});
                    }
                }
                
            }
            
        }
        return modelList;
    }
    
    @AuraEnabled
    public static List<object> getModels(string year, string make){
        System.debug('year ==>'+year);
        System.debug('make ==>'+make);
        if(CarApi_Config__c.getOrgDefaults().Enable_Model_Finder__c){
            return fetchModelfromCarAPI(year,make);
        }else{
            HttpRequest httpRequest = new HttpRequest();  
            string makeURL = label.URL_To_Get_Models + '/make/'+make+'/modelyear/'+year+'?format=json';// &make=' +make + '&year=' + year + '&sold_in_us=1';
            httpRequest.setEndpoint(makeURL);
            httpRequest.setMethod('GET');
            httpRequest.setTimeout(120000);
            String strResponse = null;
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            strResponse = httpResponse.getBody();  
            system.debug('>>> strResponse... '+strResponse);
            string formattedResponse = strResponse.replace('?(','');
            formattedResponse = formattedResponse.replace(');','');
            JSON2ModelApex json2ModelObj = JSON2ModelApex.parse(formattedResponse.trim());
            system.debug('>>> json2ModelObj... ' + json2ModelObj.Results);
            
            List<object> modelList = new List<object>();
            modelList.add( new map<String,object>{ 'label' => '<Manually Enter>', 'value' => '<Manually Enter>'});
            for(JSON2ModelApex.Result mk : json2ModelObj.Results){
                modelList.add( new map<String,object>{ 'label' => mk.Model_Name, 'value' => mk.Model_Name});
            }
            
            return modelList;
        }
        
    }
    
    /* @AuraEnabled
public static List<object> getMakes(string year){
HttpRequest httpRequest = new HttpRequest();  
string makeURL = label.URL_To_Get_Makes + '&year=' + year + '&sold_in_us=1';
httpRequest.setEndpoint(makeURL);
httpRequest.setMethod('GET');
String strResponse = null;
Http http = new Http();   
HttpResponse httpResponse = http.send(httpRequest);  
strResponse = httpResponse.getBody();  
system.debug('>>> strResponse... '+strResponse);
string formattedResponse = strResponse.replace('?(','');
formattedResponse = formattedResponse.replace(');','');
JSON2MakesApex json2MakesObj = JSON2MakesApex.parse(formattedResponse);
system.debug('>>> json2MakesObj... ' + json2MakesObj.Makes);

List<object> makesList = new List<object>();
makesList.add( new map<String,object>{ 'label' => '<Manually Enter>', 'value' => '<Manually Enter>'});
for(JSON2MakesApex.Makes mk : json2MakesObj.Makes){
makesList.add( new map<String,object>{ 'label' => mk.make_display, 'value' => mk.make_display});
}

return makesList;
}*/
    
    /*   @AuraEnabled
public static List<object> getModels(string year, string make){
HttpRequest httpRequest = new HttpRequest();  
string makeURL = label.URL_To_Get_Models + '&make=' +make + '&year=' + year + '&sold_in_us=1';
httpRequest.setEndpoint(makeURL);
httpRequest.setMethod('GET');
String strResponse = null;
Http http = new Http();   
HttpResponse httpResponse = http.send(httpRequest);  
strResponse = httpResponse.getBody();  
system.debug('>>> strResponse... '+strResponse);
string formattedResponse = strResponse.replace('?(','');
formattedResponse = formattedResponse.replace(');','');
JSON2ModelApex json2ModelObj = JSON2ModelApex.parse(formattedResponse);
system.debug('>>> json2ModelObj... ' + json2ModelObj.Models);

List<object> modelList = new List<object>();
modelList.add( new map<String,object>{ 'label' => '<Manually Enter>', 'value' => '<Manually Enter>'});
for(JSON2ModelApex.Models mk : json2ModelObj.Models){
modelList.add( new map<String,object>{ 'label' => mk.model_name, 'value' => mk.model_name});
}

return modelList;
}*/
}