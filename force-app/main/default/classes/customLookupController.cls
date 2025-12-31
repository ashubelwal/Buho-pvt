public  without sharing class customLookupController {
    
    
    @AuraEnabled 
    Public static List<IdandName> lookup(String objectType, String searchText, String searchAgainst, String secondaryField, Integer maxResults, string filterValue, string filterApi, String PostalCode, String StateName, String CityName){
        // objectType : Object for which we need to search for 
        // searchText : text that we need to search for
        // searchAgainst : Field in which we need to search the text (Expected fields types are String, Picklist or Email or any other field which can be filtered using the like opertaor.)
        // secondaryField : Field that will be used as a meta field on the lookup results, this is an optional field.
        
        List<IdandName> idnList = new  List<IdandName>();
        
        if(objectType == 'Address__c' && searchAgainst == 'State__c'){
            String searchStringMerged = '\''+String.escapeSingleQuotes(searchText)+'%\'';
            String Condition = ' where State__c LIKE '+searchStringMerged+' AND ';
            if(String.isNotBlank(PostalCode)){
                Condition+='Postal_Code__c =: PostalCode AND ';
            }
            if(String.isNotBlank(StateName)){
                Condition+='State__c =: StateName AND ';
            }
            if(String.isNotBlank(CityName)){
                Condition+='City__c =: CityName AND ';
            }
            Condition+='Name =: filterValue AND ';
            Condition = Condition.removeEnd('AND ');
            System.debug('Condition=='+ Condition);
            AggregateResult[] groupedResults = Database.query('SELECT State__c, COUNT(Name) FROM address__c '+Condition+' GROUP BY State__c LIMIT 15');
            
            for (AggregateResult ar : groupedResults)  {
                IdandName idn = new IdandName();
                idn.id = (String)ar.get('State__c');
                idn.Name = (String)ar.get('State__c');  
                idnList.add(idn);
            }
        }
        if(objectType == 'Address__c' && searchAgainst == 'City__c'){
            String searchStringMerged = '\''+String.escapeSingleQuotes(searchText)+'%\'';
            
            String Condition = ' where City__c LIKE '+searchStringMerged+' AND ';
            if(String.isNotBlank(PostalCode)){
                Condition+='Postal_Code__c =: PostalCode AND ';
            }
            if(String.isNotBlank(StateName)){
                Condition+='State__c =: StateName AND ';
            }
            if(String.isNotBlank(CityName)){
                Condition+='City__c =: CityName AND ';
            }
            Condition+='Name =: filterValue AND ';
            Condition = Condition.removeEnd('AND ');
            
            System.debug('Condition=='+ Condition);
            AggregateResult[] groupedResults = Database.query('SELECT  City__c, COUNT(Name) FROM address__c '+Condition+' GROUP BY City__c LIMIT 15');
            
            for (AggregateResult ar : groupedResults)  {
                IdandName idn = new IdandName();
                idn.id = (String)ar.get('City__c');
                idn.Name = (String)ar.get('City__c');  
                idnList.add(idn);
            }
        }
        if(objectType == 'Address__c' && searchAgainst == 'Postal_Code__c'){
            String searchStringMerged = '\''+String.escapeSingleQuotes(searchText)+'%\'';
            
            String Condition = ' where Postal_Code__c LIKE '+searchStringMerged+' AND ';
            if(String.isNotBlank(PostalCode)){
                Condition+='Postal_Code__c =: PostalCode AND ';
            }
            if(String.isNotBlank(StateName)){
                Condition+='State__c =: StateName AND ';
            }
            if(String.isNotBlank(CityName)){
                Condition+='City__c =: CityName AND ';
            }
            Condition+='Name =: filterValue AND ';
            Condition = Condition.removeEnd('AND ');
            
            System.debug('Condition=='+ Condition);
            AggregateResult[] groupedResults = Database.query('SELECT Postal_Code__c, COUNT(Name) FROM address__c '+Condition+' GROUP BY Postal_Code__c LIMIT 15');
            
            for (AggregateResult ar : groupedResults)  {
                IdandName idn = new IdandName();
                idn.id = (String)ar.get('Postal_Code__c');
                idn.Name = (String)ar.get('Postal_Code__c');  
                idnList.add(idn);
            }
        }
        
        return idnList;
    }    
    class IdandName{
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string Name;
    }
}