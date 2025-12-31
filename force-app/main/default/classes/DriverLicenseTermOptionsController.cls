public without sharing class DriverLicenseTermOptionsController {
    @AuraEnabled
    public static Map<String, Object> handleQuoteAction(Quote__c quoteRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (quoteRecord.Start_Date_for_Coverage__c != null && quoteRecord.End_Date_for_Coverage__c != null) {
                quoteRecord.Term_Days__c = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
            }
            System.debug('quoteRecord.Term_Days__c : ' + quoteRecord.Term_Days__c);

            if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c <= 30) {
                quoteRecord.Term__c = 'Daily';
            } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 30 && quoteRecord.Term_Days__c <= 90) {
                quoteRecord.Term__c = '90 Day';
            } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 90 && quoteRecord.Term_Days__c <= 180) {
                quoteRecord.Term__c = 'Semi-Annual(Half a Year)';
            } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 180) {
                quoteRecord.Term__c = 'Annual(One Year)';
            }

            if (quoteRecord.Id == null) {
                quoteRecord.Quote_Status__c = 'Draft';
            }

            upsert quoteRecord Id;

            responseMap.put('success', true);
            responseMap.put('quoteId', quoteRecord.Id);
            responseMap.put('quoteRecord', quoteRecord);

        } catch (Exception e) {
            System.debug('---Exception---' + e.getMessage() + '--;=line--' + e.getLineNumber());
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled
    public static List<PicklistEntryWrapper> getPicklistValues(String currentObjectApiName, String fieldApiName) {
        system.debug('fieldApiName--->'+ fieldApiName);
        try{
             List<PicklistEntryWrapper> picklistValues = new List<PicklistEntryWrapper>();

        Map<String, Schema.SObjectField> currentObjectFieldsMap = Schema.getGlobalDescribe().get(currentObjectApiName).getDescribe().fields.getMap();
        List<Schema.PicklistEntry> fieldPicklistEntries = currentObjectFieldsMap.get(fieldApiName).getDescribe().getPicklistValues();

        for (Schema.PicklistEntry fieldPicklistEntry : fieldPicklistEntries) {
            picklistValues.add(new PicklistEntryWrapper(fieldPicklistEntry.getLabel(), fieldPicklistEntry.getValue()));
        }
        return picklistValues;
        } catch (Exception e) {
            System.debug('---Exception---' + e.getMessage() + '--;=line--' + e.getLineNumber());
             return null;
        }
        
       
    }

    @AuraEnabled
    public static Map<String, List<PicklistEntryWrapper>> getDependentPicklistValues(String sObjectApiName, String dependentFieldApiName) {
        try{
             Map<String, List<PicklistEntryWrapper>> dependentPicklistValues = new Map<String, List<PicklistEntryWrapper>>();
        Map<String, Schema.SObjectField> currentSObjectFieldMap = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
        if (!currentSObjectFieldMap.containsKey(dependentFieldApiName)) {
            return dependentPicklistValues;
        }

        Schema.DescribeFieldResult dependentFieldResult = currentSObjectFieldMap.get(dependentFieldApiName).getDescribe();
        Schema.DescribeFieldResult controllerFieldResult = dependentFieldResult.getController().getDescribe();
             system.debug('controllerFieldResult::::::::::'+controllerFieldResult);

        if (controllerFieldResult == null) {
            return dependentPicklistValues;
        }
        List<Schema.PicklistEntry> controllerFieldEntries = controllerFieldResult.getPicklistValues();
        List<String> controllingValues = new List<String>();
        for (Schema.PicklistEntry controllerFieldEntry : controllerFieldEntries) {
            controllingValues.add(controllerFieldEntry.getLabel());
        }

        if (controllerFieldEntries != null && !controllerFieldEntries.isEmpty()) {
            String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            List<PicklistEntryWrapper> dependentFieldEntries = (List<PicklistEntryWrapper>)
                    JSON.deserialize(JSON.serialize(dependentFieldResult.getPicklistValues()), List<PicklistEntryWrapper>.class);
            for (PicklistEntryWrapper dependentEntry : dependentFieldEntries) {
                if (!dependentEntry.active) {
                    continue;
                }
                List<String> base64chars = String.valueOf(dependentEntry.validFor).split('');

                for (Integer i = 0; i < controllerFieldEntries.size(); i++) {
                    String controllerPicklistLabel = controllerFieldEntries[i].isActive() ? controllerFieldEntries[i].getLabel() : '';
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6);
                    if (String.isBlank(controllerPicklistLabel) || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) {
                        continue;
                    }
                    if (!dependentPicklistValues.containsKey(controllerPicklistLabel)) {
                        dependentPicklistValues.put(controllerPicklistLabel, new List<PicklistEntryWrapper>());
                    }
                    dependentPicklistValues.get(controllerPicklistLabel).add(new PicklistEntryWrapper(dependentEntry.label, dependentEntry.label));
                }
            }
        }
        return dependentPicklistValues;
        }catch (Exception e) {
            System.debug('---Exception---' + e.getMessage() + '--line--' + e.getLineNumber());
              return null;
        }  
        
        
       
    }

    public class PicklistEntryWrapper {
        public Boolean active { get; set; }
        public Boolean defaultValue { get; set; }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        public String validFor { get; set; }

        public PicklistEntryWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}