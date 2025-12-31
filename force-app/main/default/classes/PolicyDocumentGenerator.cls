public without sharing class PolicyDocumentGenerator {
    @AuraEnabled
    public static Boolean generateGreenCardfromPolicyId(String policyId){
        try {
            if(String.isNotBlank(policyId)){
                Policy__c policyDetail = [Select Id, Policy_Type_picklist__c from Policy__c Where Id =:policyId LIMIT 1];
            PageReference pref2;
            if (policyDetail.Policy_Type_picklist__c == 'Northbound') {
                return true;                  
            }
        }
            
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
        }
        return false;
    }
    @AuraEnabled 
    public static string validateandGenerateQuotePDF(String policyId) {
        String pref;
        try {
            // Replace Visualforce(AccountDetails) page with your visualforce page
            if(String.isNotBlank(policyId)){
                Policy__c policyDetail = [Select Id, Policy_Type_picklist__c, Underwriter_picklist__c from Policy__c Where Id =:policyId LIMIT 1];
                String policyType = policyDetail.Policy_Type_picklist__c;
                String underWriter = policyDetail.Underwriter_picklist__c;
                

                if (policyType == 'Northbound') {
                    pref = 'Declaration_Page_Insurance_2';
                }else if ( policyType == 'Driver License') {
                    pref = 'policy_declaration_driver_license';
                }else if ( policyType == 'Watercraft') {
                    pref = 'watercraft_policy_declaration_Page';
                }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                    pref = 'Southbound_PolicyDec_Chubb';
                }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Mapfre' ){
                    pref = 'Southbound_PolicyDeclarationPage_Mapfre';
                }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Qualitas' ){
                    pref = 'Southbound_PolicyDecPage_Qualitas';
                }else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                    pref = 'Southbound_Chubb_RV';
                }else if( policyType == 'RV' && underWriter != null && underWriter == 'Mapfre' ){
                    pref = 'Southbound_Mapfre_RV';
                }else if( policyType == 'RV' && underWriter != null && underWriter == 'Qualitas' ){
                    pref = 'Southbound_Qualitas_RV';
                }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Qualitas' ){
                    pref = 'Southbound_Qualitas_Motorcycle';
                }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Mapfre' ){
                    pref = 'Southbound_Mapfre_Motorcycle';
                }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                    pref = 'Southbound_ChubbMotorcycle';
                } else if( underWriter != null && underWriter == 'Chubb' ){
                    pref = 'Southbound_PolicyDec_Chubb';
                }else if(underWriter != null && underWriter == 'Mapfre' ){
                    pref = 'Southbound_PolicyDeclarationPage_Mapfre';
                }else if(underWriter != null && underWriter == 'Qualitas' ){
                    pref = 'Southbound_PolicyDecPage_Qualitas';
                }
            }
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            System.debug('*****exception***' + e.getMessage() + '---line-' + e.getLineNumber());
        }
        return pref;
    }
}