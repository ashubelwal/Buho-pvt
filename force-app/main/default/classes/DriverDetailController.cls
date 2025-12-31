public without sharing class DriverDetailController {

    @AuraEnabled 
    public static DriverDetailResponse processDriverDetails(String serializedLeadRecord, Quote__c quoteRecord) {
        try{
             Database.UpsertResult leadUpsertResult;
        Database.UpsertResult quoteUpsertResult;
        DriverDetailResponse detailResponse = new DriverDetailResponse();

        Map<String, Object> ldObjectMap = new Map<String, Object>();
        ldObjectMap = (Map<String, Object>) JSON.deserializeUntyped(serializedLeadRecord);
            System.debug('Line 12 Running '+ldObjectMap);
        String leadId = Mex_Insurance_Calloututility.getLeadId(ldObjectMap);
                        System.debug('Line 13 Running '+leadId);

        String userType = UserInfo.getUserType();

        Lead leadRecord = (Lead) JSON.deserialize(serializedLeadRecord, Lead.class);

        if( (userType.equalsIgnoreCase('Guest') && (leadId == null || leadId == '')) || Test.isRunningTest() ){
            leadRecord.Company = 'Driver Licence Insurance';
            leadRecord.Status = 'New';
            leadUpsertResult = Database.upsert(leadRecord, Lead.Email, false);
            leadId = leadRecord.Id;
        }

        if (leadId != null ) {
            quoteRecord.Lead__c = leadId;

            List<Lead> leads = new List<Lead>();
            leads = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leadId AND IsConverted = TRUE LIMIT 1];
            if (leads != null && !leads.isEmpty()) {
                quoteRecord.Contact__c = leads[0].ConvertedContactId;
                quoteRecord.Account__c = leads[0].ConvertedAccountId;
            }
            quoteRecord.Lead__c = leadId;
            leadRecord.Id = leadId;
        }

        if (leadId != null) {
            
            quoteRecord.Date_of_Birth__c = leadRecord.Date_of_Birth__c;
            quoteRecord.Underwriter__c = 'Chubb';
            quoteRecord.Policy_Type_picklist__c = 'Driver License';
            quoteRecord.Quote_Status__c = 'Draft';

            /*if (leadRecord.IsConverted) {
                quoteRecord.Contact__c = leadRecord.ConvertedContactId;
                quoteRecord.Account__c = leadRecord.ConvertedAccountId;
            } else {
                List<User> currentUser = [
                        SELECT Id, ContactId, Contact.AccountId
                        FROM User
                        WHERE Id = :UserInfo.getUserId()
                        LIMIT 1
                ];
                if (!currentUser.isEmpty()) {
                    quoteRecord.Contact__c = currentUser[0].ContactId;
                    quoteRecord.Account__c = currentUser[0].Contact.AccountId;
                }
            }*/

            if (quoteRecord.Date_of_Birth__c != null) {
                Integer year = System.today().year() - quoteRecord.Date_of_Birth__c.year();
                quoteRecord.Is_there_a_driver_under_21__c = year < 21 ? 'Yes' : 'No';
                quoteRecord.Is_there_a_driver_over_75__c = year > 75 ? 'Yes' : 'No';
                quoteRecord.Driver_Age__c = year;
            }
            quoteUpsertResult = Database.upsert(quoteRecord);
        }

        if ( quoteUpsertResult != null && quoteUpsertResult.isSuccess()) {
            detailResponse.leadRecord = leadRecord;
            detailResponse.quoteRecord = quoteRecord;
        } else {
            String errorMessage = '';
            if (!leadUpsertResult.isSuccess() && !leadUpsertResult.getErrors().isEmpty()) {
                errorMessage += 'Lead insert issue: ' + leadUpsertResult.getErrors()[0].getMessage();
            }

            if (quoteUpsertResult != null && !quoteUpsertResult.isSuccess() && !quoteUpsertResult.getErrors().isEmpty()) {
                errorMessage += 'Quote upsert issue: ' + quoteUpsertResult.getErrors()[0].getMessage();
            }
            detailResponse.errorMessage = errorMessage;
        }

        System.debug('detailResponse : ' + detailResponse);
        return detailResponse;
        }catch( Exception ex){
             system.debug('Exception'+ex.getMessage()+'at'+ex.getLineNumber());
             return null ;
            
        }
    }

    @AuraEnabled
    public static List<Driver__c> getCurrentUserDrivers() {
        return QuickQuotationCtrl.getCurrentUserDrivers();
    }

    @AuraEnabled
    public static Map<String, Object> createDriverAction(Driver__c driverRecord, String quoteId, 
        Boolean isOwner, String watercraftId, Boolean Primary_insured) {
        return QuickQuotationCtrl.createDriverAction( driverRecord, quoteId, isOwner, watercraftId,  Primary_insured);
    }

    @AuraEnabled
    public static Map<String, Object> checkalreadyExistUserAction(String emailAdder) {
        return QuickQuotationCtrl.checkalreadyExistUserAction(emailAdder);
    }

    public class DriverDetailResponse {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public Lead leadRecord;
        @AuraEnabled
        public Quote__c quoteRecord;
        @AuraEnabled
        public String errorMessage;
        public DriverDetailResponse() {
        }
    }
}