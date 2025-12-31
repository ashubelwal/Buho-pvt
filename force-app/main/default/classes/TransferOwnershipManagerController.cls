public class TransferOwnershipManagerController{
    
    @AuraEnabled
    public static String getClientContact(String contactId){
        Contact getContact = [SELECT ID,Name,Agency__r.name, Agency__r.Email, Agent__r.Email, Agent__r.name,Email FROM Contact WHERE Id =: contactId];
        return JSON.serialize(getContact);
    }
    
    @AuraEnabled
    public static void trasferOnwership(String clientId, String clientEmail, String contactOwnerId, String oldAgencyEmail , String oldAgencyName){
        try{
            Contact agentContact = new Contact();
            Contact updatedContact = new Contact();
            List<User> currentUser = new List<User>();
            List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Id contactId;
            emailTemplate = [SELECT Id,HtmlValue,Body,Subject  FROM EmailTemplate WHERE DeveloperName =:Label.Transfer_Ownership LIMIT 1];
           
            String htmlBody = emailTemplate[0].HtmlValue;
            String plainBody = emailTemplate[0].Body;
            
            if(contactOwnerId != null){
                currentUser = [SELECT Id, Name, Email, contactId FROM User WHERE Id =: contactOwnerId];
            } else{
                throw new MyCustomException('Uable to fetch the user the user information');
            }
            if(currentUser.size() > 0){
                if(currentUser[0].contactId != null){
                    agentContact = [Select id,name, Agency__c,Agency__r.Name from Contact WHERE Id =: currentUser[0].contactId LIMIT 1];
                   
                    contactId = agentContact?.Agency__c != null ? agentContact.Agency__c : agentContact.Id;
                    
                     Contact con = new Contact();
                    con.Id = clientId;
                    con.Agent__c = agentContact.Id;
                    con.Agency__c =agentContact?.Agency__c != null ? agentContact.Agency__c : agentContact.Id;
                    
                    if(clientEmail != null){
                        con.Email = clientEmail;
                    }
                    
                    if(con != null){
                        update con;
                        
                        updatedContact = [SELECT Id,Name,Email,Agency__r.Name FROM Contact where Id =: con.Id LIMIT 1];
                        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: Label.Org_wide_Email_Address LIMIT 1];
                        
                        String contactName = updatedContact.Name;
                        String contactEmail = updatedContact.Email;
                        String newOwnerName = updatedContact.Agency__r.Name;
                        String getHTML = htmlBody;
                        String getPlain = plainBody;
                        
                        getHTML = getHTML.replace('{!agencyName}', oldAgencyName);
                        getHTML = getHTML.replace('{!contactName}', contactName);
                        getHTML = getHTML.replace('{!contactEmail}', contactEmail);
                        getHTML = getHTML.replace('{!newOwnerName}', newOwnerName);
                        
                        getPlain = getPlain.replace('{!agencyName}', oldAgencyName);
                        getPlain = getPlain.replace('{!contactName}', contactName);
                        getPlain = getPlain.replace('{!contactEmail}', contactEmail);
                        getPlain = getPlain.replace('{!newOwnerName}', newOwnerName);
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(emailTemplate[0].Id);
                        email.setTargetObjectId(contactId);
                        email.setHtmlBody(getHTML);
                        email.setPlainTextBody(getPlain);
                        email.setSubject(emailTemplate[0].Subject);
                        email.setToAddresses(new List<String>{oldAgencyEmail});
                        email.setOrgWideEmailAddressId(orgWideEmail.Id);
                        emails.add(email);
                        
                        if (!emails.isEmpty()) {
                            Messaging.sendEmail(emails);
                        }
                        
                        System.debug('emails-------'+emails);
                        
                    }else{
                        throw new MyCustomException('Contact is not being queried to be transferred');
                    
                    }
                }else{
                    throw new MyCustomException('User have no contact');
                }
               
            }else{
                throw new MyCustomException('Uable to fetch the user the user information');
            }
           
        }catch(Exception ex){
                throw new MyCustomException(ex.getMessage() + ex.getLineNumber());        }
    }
    
    @AuraEnabled
    public static string getUserData(String userId){
        try{
          if(userId != null){
            User currentUser = [SELECT Id,Name,Email,UserName FROM User Where Id =: userId];

            if(currentUser != null){
                return JSON.serialize(currentUser);
            }
          }
        }catch(Exception ex){
            System.debug('Error in the getUserData method: '+ex.getMessage()+ ' at line: '+ex.getLineNumber()+' stack trace: '+ex.getStackTraceString());
            return 'Error in the getUserData method: '+ex.getMessage()+ ' at line: '+ex.getLineNumber()+' stack trace: '+ex.getStackTraceString();
        }
        return null;
    }

    public class MyCustomException extends Exception {}

}