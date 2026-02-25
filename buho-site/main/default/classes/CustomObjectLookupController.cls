public without sharing class CustomObjectLookupController {
    @AuraEnabled
    Public static List<sObject> lookup(String objectType, String searchText, String searchAgainst, String secondaryField, Integer maxResults, string filterValue, string filterApi){
        // objectType : Object for which we need to search for 
        // searchText : text that we need to search for
        // searchAgainst : Field in which we need to search the text (Expected fields types are String, Picklist or Email or any other field which can be filtered using the like opertaor.)
        // secondaryField : Field that will be used as a meta field on the lookup results, this is an optional field.
        
        List<sObject> results = new List<sObject>();
        String Query='SELECT Id,Name ';
        
        if(String.isNotBlank(searchAgainst) && searchAgainst != 'Name'){
            Query = Query + ','+searchAgainst;
        }
        if(String.isNotBlank(secondaryField)){
            Query = Query + ','+secondaryField;
        }
        if(String.isNotBlank(objectType)){
            Query = Query + ' FROM '+objectType;
        }else{
            return null;
        }
        if(String.isNotBlank(searchText)){
            
            if(String.isNotBlank(filterApi)){
                Query = Query + ' WHERE '+filterApi+' = '+'\''+filterValue+'\''+' AND '+ searchAgainst +' LIKE '+'\''+'%'+ searchText+'%'+'\'' +' LIMIT '+maxResults;  
            }else{
                Query = Query + ' WHERE '+ searchAgainst +' LIKE '+'\''+'%'+ searchText+'%'+'\'' +' LIMIT '+maxResults;
            }
        }else{
            
            if(String.isNotBlank(filterApi)){
                Query = Query + ' WHERE '+filterApi+' = '+'\''+filterValue+'\''+ ' ORDER BY Name ASC ' +' LIMIT '+maxResults;
            }else{
                Query = Query + ' LIMIT '+ maxResults;
            }
        }

        for(sObject obj : Database.query(Query)) {
            results.add(obj);
        }
        
        return results;
        
    }
}