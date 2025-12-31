public class CustomErrorExceptionHandlerException extends Exception {
    public static String data = '';
    public static void LogException(Exception e) {
        LogException(e, '');
    }
    
    public static void LogException(Exception e, string relatedToId) {
        try {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.');	
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
            
            //Governer Limit of executingQuery 
            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far / Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
            
            Error_Handling__c exc = new Error_Handling__c();
            exc.Related_To_Number__c = relatedToId;
            exc.Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit, DMLStat, CPUT});
            exc.Exception_Message__c = e.getMessage();
            exc.Exception_Type__c = e.getTypeName();
            exc.Line_Number__c = e.getLineNumber();
            exc.StackTrace__c = e.getStackTraceString();
            exc.MethodName__c = methodName;
            exc.ClassName__c = className;
            exc.Data__c = data;
            database.insert(exc);
        } finally{
        }
    }

    // Method to log the exception created from the LWC
    @AuraEnabled
    public static void logClientError(String componentName, String errorMessage, String stackTrace, String relatedToId, String extraData, String methodName) {
        try {
            Error_Handling__c err = new Error_Handling__c();
            err.Related_Data__c = relatedToId;
            err.Exception_Message__c = errorMessage;
            err.Exception_Type__c = 'JavaScript Exception';
            err.ClassName__c = componentName;
            err.StackTrace__c = stackTrace;
            err.Data__c = extraData;
            err.MethodName__c = methodName; // No method info from JS
            err.Line_Number__c = 0;    // Not applicable from JS
            database.insert(err);
        } catch (Exception e) {
            System.debug('Failed to log JS error: ' + e.getMessage());
        }
    }
}