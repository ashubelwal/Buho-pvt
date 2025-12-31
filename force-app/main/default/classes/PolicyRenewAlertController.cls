public without sharing class PolicyRenewAlertController {
    
    @AuraEnabled
    public static String fetchPolicy(String policyId){
        try{
            System.debug('policyIds'+policyId);
            
            Map<string,Object> typeVsdays = new Map<string,Object>();
            List<policy__c> policyList = [SELECT Id, Name ,End_Date__c, Policy_Type_picklist__c,Status_picklist__c , Start_Date__c,Total_Premium_Amount__c,Term__c,Quote_c__c, Renew_Payment_Profile_Id__c , Auto_renew_card__c, Auto_renew__c FROM Policy__c WHERE ID =: policyId LIMIT 1];
            date todaysDate = date.today();
            
            System.debug('policyList'+policyList);
            System.debug('todaysDate'+todaysDate);
            
            for(policy__c each : policyList){
                typeVsdays.put('PolicyType' , each.Policy_Type_picklist__c);
                typeVsdays.put('Status' , each.Status_picklist__c );
                typeVsdays.put('TotalPremium' , each.Total_Premium_Amount__c);
                typeVsdays.put('QuoteID' , each.Quote_c__c  );
                typeVsdays.put('TermDays' , each.Term__c  );
                typeVsdays.put('Autorenew' , each.Auto_renew__c  );
                typeVsdays.put('paymentProfileId' , each.Renew_Payment_Profile_Id__c  );
                if(each.Term__c == 'Daily' && each.Start_Date__c <= todaysDate){
                    typeVsdays.put('isDailyPolicy' , 'True');
                }
                
                if(each.Start_Date__c <= todaysDate && each.End_Date__c >= todaysDate){
					Integer dateDifference = todaysDate.daysBetween(each.End_Date__c);
                    Integer runningDateDifference = each.Start_Date__c.daysBetween(todaysDate);
                    String dateDiff = String.valueOf(dateDifference);
                    String runningDiff = String.valueOf(runningDateDifference);
                    
                    typeVsdays.put('isRunningDays' , 'True');
                    typeVsdays.put('DaysLeft' , dateDiff);
                    typeVsdays.put('RunningDays' , runningDiff);
                    
                    System.debug('Name ' +each.name + '  Start Date' +each.Start_Date__c +'   DateDifference'+dateDifference);
                    
                }else if(each.Start_Date__c >= todaysDate){
                    Integer dateDifference = todaysDate.daysBetween(each.Start_Date__c);
                    String dateDiff = String.valueOf(dateDifference);
                    
                    typeVsdays.put('isTerminationAmount' , 'True');
                    typeVsdays.put('isStaringDays' , 'True');
                    typeVsdays.put('StartingDays' , dateDiff);
                    
                    System.debug('Name ' +each.name + '   Start Date' +each.Start_Date__c +'    NOT STARTED ---DateDifference--'+dateDifference);
                    
                }else{
                    typeVsdays.put('isExpired' , 'True');
                    System.debug('EXPIRED Name  ' +each.name + '   Start Date' +each.Start_Date__c );
                }
            }
            
            return JSON.serialize(typeVsdays);
        }catch(exception e){
            System.debug('Error -'+ e.getMessage() +' at line - '+e.getLineNumber());
            return 'ERROR';
        }
    }
    
    @AuraEnabled
    public static void saveRenewDetails(String cardJson , String policyId, String profileId, Boolean autoRenew){
        
        if(autoRenew == true && (policyId != null || policyId != '' )){
            Policy__c policy = new Policy__c();
        
            policy.Id = policyId;
            policy.Auto_renew__c = true;
            policy.Auto_renew_card__c = cardJson;
            policy.Renew_Payment_Profile_Id__c = profileId;
            
            System.debug('Policy Details--'+policy);
            update policy; 
            
        }else if(autoRenew == false && (policyId != null || policyId != '' )){
             Policy__c policy = new Policy__c();
        
            policy.Id = policyId;
            policy.Auto_renew__c = false;
            policy.Auto_renew_card__c = '';
            policy.Renew_Payment_Profile_Id__c = '';
            
            System.debug('Policy Details--'+policy);
            update policy; 
        }
    }
    
    @AuraEnabled
    public static List<Policy__c> fetchQuoteDetails(String policyId){
        if(policyId != null){
            List<Policy__c> policyList = new List<Policy__c>();
            policyList = [SELECT Policy_Type_picklist__c, Underwriter_picklist__c, Updated_Quote_Json__c, Auto_Renew_Confirmed__c, Quote_c__c,Quote_c__r.Start_Date_for_Coverage__c, Quote_c__r.End_Date_for_Coverage__c, Quote_c__r.Term_Days__c, 
                          Quote_c__r.Medical__c, Quote_c__r.Liability__c, Quote_c__r.Net_Premium__c, Quote_c__r.Total_Theft_Payment__c,Quote_c__r.Vehicle_Value__c 
                          FROM Policy__c WHERE id =: policyId LIMIT 1];
            return policyList;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static void updatedQuoteToPolicy(String quoteJson, string policyId){
        System.debug('updatedQuoteToPolicy--');
        if(quoteJson != null && policyId != null){
            Policy__c policy = new Policy__c();
            policy.Id = policyId;
            policy.Updated_Quote_Json__c = quoteJson;
            policy.Auto_Renew_Confirmed__c = true;
            update policy;
            
            String orgWideEmailAddressLabel = System.Label.userEmailForAutorenew;
            Id orgWideEmailAddress = null;
            System.debug('policy'+policy);
            System.debug('orgWideEmailAddressLabel'+orgWideEmailAddressLabel);
            
            Policy__c policyData = [SELECT Id,Name,Contact__c,Contact__r.Name,End_date__c FROM Policy__c WHERE ID =: policy.Id LIMIT 1];
            EmailTemplate emailTemplate = [SELECT Id,HtmlValue,Body,Subject FROM EmailTemplate WHERE DeveloperName = 'PolicyAutoRenewalApproved' LIMIT 1];
            if(orgWideEmailAddressLabel != null){
                orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =:orgWideEmailAddressLabel  LIMIT 1].Id;
            }
            

            String htmlBody = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            System.debug('policyData'+policyData);
            htmlBody = htmlBody.replace('{!Contact.Name}', policyData.Contact__r.Name);
            htmlBody = htmlBody.replace('{!Policy__c.Id}', policyData.Id);
            htmlBody = htmlBody.replace('{!EndDate}', String.valueof(policyData.End_Date__c));
            plainBody = plainBody.replace('{!EndDate}', String.valueof(policyData.End_Date__c));
            plainBody = plainBody.replace('{!Contact.Name}', policyData.Contact__r.Name);
            plainBody = plainBody.replace('{!Policy__c.Id}', policyData.Id);
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(emailTemplate.Id);
            email.setTargetObjectId(policyData.Contact__c);
            email.setWhatId(policyData.id);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);
            email.setSubject(emailTemplate.Subject);
            email.setOrgWideEmailAddressId(orgWideEmailAddress);
            emails.add(email);
            System.debug('emails'+emails);
            
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
        
    }
    
    @AuraEnabled
    public static void updatePolicyOnCardRemove(String paymentId){
        List<Policy__c> policyList = new List<Policy__c>();
        List<Policy__c> updatePolicyList = new List<Policy__c>();
        policyList = [SELECT Id, Name,Auto_renew__c, Auto_renew_card__c, Renew_Payment_Profile_Id__c FROM policy__c WHERE Contact__c = :ContactService.contactId AND Auto_renew__c = true AND Renew_Payment_Profile_Id__c =: paymentId];
        System.debug('policyList---'+policyList);
        
        if(policyList.Size() > 0){
            for(policy__c polObj : policyList){
                Policy__c policy = new Policy__c();
                policy.Id = polObj.id;
                policy.Auto_renew__c = False;
                policy.Auto_renew_card__c = '';
                policy.Renew_Payment_Profile_Id__c = '';
                policy.Auto_Renew_Confirmed__c = false;
                policy.Updated_Quote_Json__c = '';
                updatePolicyList.add(policy);
            }
        }
        
        if(updatePolicyList.Size() > 0){
            update updatePolicyList;
        }
        
    }

}