public without sharing class EmailService {
    @AuraEnabled
    public static string emailServices(String policyId , Boolean emailService){
        try {
            if (policyId != null) {
                Set<String> policyIdList = new Set<String>();
                policyIdList.add(policyId);
                Boolean add_attachment = false;
                Mex_Insurance_Calloututility.sendEmail(policyIdList, add_attachment);
            }
        } catch (Exception e) { CustomErrorExceptionHandlerException.LogException(e); throw new AuraHandledException(e.getMessage());}
        return null;
    }
}