public class PolicyAutoRenewNotificationScheduler implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        System.debug('SchedulableContext');
        sendNotificationEmails(30);
        sendNotificationEmails(15);
    }
    
    public void sendNotificationEmails(Integer daysBeforeExpiry) {
        List<Policy__c> policyList = new List<Policy__c>();
        Set<Id> policyIdSet = new Set<Id>();
        Map<Id, Id> policyVsContact = new Map<Id, Id>();
        Map<Id, String> policyVsContactName = new Map<Id, String>();
        
        Date expiryDate = Date.today().addDays(daysBeforeExpiry);
        String daysBodyMessage = '';
        String query = 'SELECT Id, Contact__c, Contact__r.Name FROM Policy__c WHERE Auto_renew__c = true AND End_Date__c = :expiryDate AND (Term__c = \'Annual(One Year)\' OR Term__c = \'Annual\' OR Term__c = \'annual\') LIMIT 50000';
		policyList = Database.query(query);
        
        if (!policyList.isEmpty()) {
            for (Policy__c policy : policyList) {
                policyIdSet.add(policy.Id);
                policyVsContact.put(policy.Id, policy.Contact__c);
                policyVsContactName.put(policy.Id, policy.Contact__r.Name);
            }
            
            if(daysBeforeExpiry == 15){
                daysBodyMessage = 'We would like to bring to your attention that your current policy with us is set to expire in the next 15 days';
            }else{
                daysBodyMessage = 'We would like to bring to your attention that your current policy with us is set to expire in the next 30 days';
            }
            
            EmailTemplate emailTemplate = [SELECT Id,HtmlValue,Body,Subject  FROM EmailTemplate WHERE DeveloperName = 'PolicyAutoRenewal' LIMIT 1];
            System.debug('emailTemplate'+emailTemplate);
            String htmlBody = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            System.debug('plainBody'+plainBody);
            System.debug('htmlBody'+htmlBody);
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            for (Id policyId : policyIdSet) {
                Id contactId = policyVsContact.get(policyId);
                String contactName = policyVsContactName.get(policyId);
                String getHTML = htmlBody;
                String getPlain = plainBody;
                system.debug('contactId-----'+contactId);
                system.debug('contactName-----'+contactName);
                system.debug('policyId-----'+policyId);
                getHTML = getHTML.replace('{!Contact.Name}', contactName);
                getHTML = getHTML.replace('{!Policy__c.Id}', policyId);
                getHTML = getHTML.replace('{!mailType}', daysBodyMessage);
                getPlain = getPlain.replace('{!mailType}', daysBodyMessage);
                getPlain = getPlain.replace('{!Contact.Name}', contactName);
                getPlain = getPlain.replace('{!Policy__c.Id}', policyId);
                
                system.debug('getHTML-----'+getHTML);
                system.debug('getPlain-----'+getPlain);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate.Id);
                email.setTargetObjectId(contactId);
                email.setWhatId(policyId);
                email.setHtmlBody(getHTML);
    			email.setPlainTextBody(getPlain);
                email.setSubject(emailTemplate.Subject);
                emails.add(email);
                
                System.debug('emails-------'+emails);
            }
            
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
}