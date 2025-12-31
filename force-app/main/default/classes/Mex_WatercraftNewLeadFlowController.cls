public class Mex_WatercraftNewLeadFlowController {

    @AuraEnabled
    public static List<Object> getPicklistValues(String objectApiName, String fieldApiName) {
        List<Object> options = new List<Object>();
        
        Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
        Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
        Map<String, Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            Map<String, String> optionMap = new Map<String, String>();
            optionMap.put('value', f.getValue());
            optionMap.put('label', f.getLabel());
            options.add(optionMap);
        }
        return options;
    }
}