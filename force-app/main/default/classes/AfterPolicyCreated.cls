public without sharing class AfterPolicyCreated {
    
    @AuraEnabled
    public static void saveAsPDF(Id policyId, String pref) {
        PageReference pdfPage = new PageReference('/apex/' + pref);
        pdfPage.getParameters().put('id', policyId);
        pdfPage.setRedirect(false);
        
        Blob pdfBlob;
        try {
            if(!Test.isRunningTest()){
                pdfBlob = pdfPage.getContentAsPDF();
            }
        } catch (Exception e) {
            System.debug('Error generating PDF: ' + e.getMessage());
            return;
        }
        Policy__c policyData = [SELECT Id, Name FROM Policy__c WHERE ID =: policyId];
        // Save PDF as attachment
        Attachment attachment = new Attachment();
        attachment.Body = pdfBlob;
        attachment.Name = policyData.Name + '.pdf';
        attachment.ParentId = policyId;
        
        try {
            insert attachment;
            System.debug('PDF saved successfully.');

        } catch (Exception e) {
            System.debug('Error saving PDF as attachment: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getPolicyData(Id policyId){
        
        String result =   AfterPolicyCreated.deleteFiles(policyId);
        
        String pref = PolicyDocumentGenerator.validateandGenerateQuotePDF(policyId);
        SYstem.debug('pref value '+pref);
        if(pref !=null){
            AfterPolicyCreated.saveAsPDF(policyId,pref);
        }      
        
        return 'Success';
    }

    @AuraEnabled
    public static String getUpdatedPolicyData(String quoteData){
        Quote__c quoteRecord;
        Policy__c policyRecord;

        if (!String.isEmpty(quoteData)) {
            system.debug('quoteData: updatePolicyDetails---->'+quoteData);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quoteData);
            String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
            String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
            jsonMap.put('Start_Time__c', startTime);
            jsonMap.put('End_Time__c', endTime);
            quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
            system.debug('quoteRecord--- updatePolicyDetails:---->'+quoteRecord);
            if (quoteRecord != null) {
                
                policyRecord = [SELECT Id, Name, Quote_c__c, Start_Time__c, End_Time__c FROM Policy__c WHERE Quote_c__c = :quoteRecord.Id];

                String result =   AfterPolicyCreated.deleteFiles(policyRecord.Id);
                String pref = PolicyDocumentGenerator.validateandGenerateQuotePDF(policyRecord.Id);
                SYstem.debug('pref value '+pref);
                if(pref !=null){
                    AfterPolicyCreated.saveAsPDF(policyRecord.Id,pref);
                }
                return 'Success';
    }

            return 'Failed';
        
        }
        return 'Failed';
    }

    @AuraEnabled
    public static string emailServices(String policyId , Boolean emailService){
        try {
            
            if(emailService == true && policyId != null){
                Set<String> policySet = new Set<String>();
                policySet.add(policyId);
                Database.executeBatch( new BatchTosendQuoteEmail(policySet, false), 1);
                return 'Email sent';
            }
            return 'Not opted for email service';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String deleteFiles(String parentRecordId) {
      
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :parentRecordId];

        if(attachments.size() > 0){
             delete attachments;
             return 'Success';
        }
        return 'Failed';
    }

    @AuraEnabled
    public static Boolean getContactEmail(String policyID){
        if(policyID != null){
            List<Policy__c> data= [SELECT Id,Contact__r.Email FROM Policy__c Where Id =:policyID ];
            String email = data[0].Contact__r.Email;
            if(email != null){
                return true;
            }
            return false;
        }
        return false;
    }

}