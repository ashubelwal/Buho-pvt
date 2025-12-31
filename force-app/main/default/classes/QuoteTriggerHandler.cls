public class QuoteTriggerHandler {
    public static void UpdateLeadFromQuote(List<Quote__c> objQuoteList, Map<Id, Quote__c> oldQuoteMap){
        Set<Id> parentLeadIdSet = new Set<Id>();
        List<Lead> objUpdateLeadList = new List<Lead>();
        
        Map<String, Schema.SObjectType> schemaMapLead = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchemaLead = schemaMapLead.get('Lead');
        Map<String, Schema.SObjectField> fieldMapLead = ObjectSchemaLead.getDescribe().fields.getMap();
        DescribeSObjectResult describeResultLead = Lead.getSObjectType().getDescribe();
        List<String> objLeadfieldNames = new List<String>(describeResultLead.fields.getMap().keySet());
        
        Map<String, Schema.SObjectType> schemaMapQuote = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchemaQuote = schemaMapQuote.get('Quote__c');
        Map<String, Schema.SObjectField> fieldMapQuote = ObjectSchemaQuote.getDescribe().fields.getMap();
        DescribeSObjectResult describeResultQuote = Quote__c.getSObjectType().getDescribe();
        List<String> quoteFieldNames = new List<String>(describeResultQuote.fields.getMap().keySet());
       
        Map<String, String> objQuoteToLeadMappingMap = new Map<String, String>();
        for(QuoteToLeadMapping__c  objQLM : [SELECT Id, Name, Quote_API__c, Lead_API__c FROM QuoteToLeadMapping__c]){
            if(!string.isBlank(objQLM.Lead_API__c) && !string.isBlank(objQLM.Quote_API__c)){
                objQuoteToLeadMappingMap.put(objQLM.Quote_API__c.toLowerCase(), objQLM.Lead_API__c.toLowerCase());
            }
        }
        
        For(Quote__c objQuote : objQuoteList){
            if(objQuote.Lead__c != null){
                parentLeadIdSet.add(objQuote.Lead__c);
            }
        }
        
        if(oldQuoteMap.size() > 0){
            for(Quote__c objQuote : oldQuoteMap.Values()){
                if(objQuote.Lead__c != null){
                    parentLeadIdSet.add(objQuote.Lead__c);
                }
            }
        }
        
        String Query = 'SELECT ' + String.join(objLeadfieldNames, ',' ) + ', (SELECT ' + String.join(quoteFieldNames, ',' );
        Query += ' FROM Quotes__r ORDER BY CreatedDate DESC LIMIT 1) FROM Lead WHERE Id IN: parentLeadIdSet';
        
        List<Lead> objLeadWithQuoteList = new List<Lead>();
        if(parentLeadIdSet.size()>0){
            objLeadWithQuoteList = Database.query(Query);
        }

        if(objLeadWithQuoteList.size()>0 && objQuoteToLeadMappingMap.size()>0){
            for(Lead objLead : objLeadWithQuoteList){
                if(objLead.Quotes__r.size()>0){
                    for(Quote__c objQuote : objLead.Quotes__r){
                        for(String objQuoteAPI : objQuoteToLeadMappingMap.keySet()){
                            if(quoteFieldNames.contains(objQuoteAPI) && 
                               !string.isBlank(objQuoteToLeadMappingMap.get(objQuoteAPI)) && 
                               objLeadfieldNames.contains(objQuoteToLeadMappingMap.get(objQuoteAPI))){
                                   objLead.put(objQuoteToLeadMappingMap.get(objQuoteAPI), objQuote.get(objQuoteAPI));
                               }
                        }
                    }
                }else{
                    for(String objQuoteAPI : objQuoteToLeadMappingMap.keySet()){
                        if(quoteFieldNames.contains(objQuoteAPI) && !string.isBlank(objQuoteToLeadMappingMap.get(objQuoteAPI)) 
                           && objLeadfieldNames.contains(objQuoteToLeadMappingMap.get(objQuoteAPI))){
                               objLead.put(objQuoteToLeadMappingMap.get(objQuoteAPI), null);
                           }
                    }
                }
                objUpdateLeadList.add(objLead);
            }
        }
        
        if(objUpdateLeadList.size()>0){
            update objUpdateLeadList;
        }
    }
}