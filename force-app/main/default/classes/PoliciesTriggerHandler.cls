public class PoliciesTriggerHandler {
    
    public static void sendEmailAlert(Set<String> accountIds){
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> postServiceETList = new List<EmailTemplate>([SELECT Id, DeveloperName, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Loyal_Client_Feedback']);
        
        List<Account> accountList = [SELECT Id, Name, Email__c,(SELECT Id, Name, Account_Policy__c, End_at__c FROM Policies__r) FROM Account WHERE Id IN: accountIds AND Email__c != null AND Created_At__c != null AND Created_At__c >= 2015-01-01];
        System.debug('accountList '+accountList);
        
        for(Account objAccount : accountList){
            System.debug('objAccount.Policies__r.size() '+objAccount.Policies__r.size());
            if(objAccount.Policies__r.size() > 1){
                Messaging.SingleEmailMessage mail = createEmail(objAccount.Email__c,postServiceETList[0],objAccount);
                emails.add(mail);
            }
        }
        
        //Send email 
        if(emails.size()>0){
            Messaging.sendEmail(emails);
        }
        
    }
    
    public static Messaging.SingleEmailMessage createEmail(String toAddress,EmailTemplate postServiceET,Account objAccount){
        List<String> toAddresses = new List<String>();
        if(toAddress != null && toAddress != ''){
            toAddresses.add(toAddress);
        }
        //Instance of Email to be sent
        Messaging.SingleEmailMessage mesg = Messaging.renderStoredEmailTemplate(postServiceET.Id, objAccount.Id, objAccount.Id);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        System.debug('email address array '+toAddresses);
        mail.setToAddresses(toAddresses);
        mail.setSubject(postServiceET.Subject);
        mail.setHtmlBody(mesg.HtmlBody);
        System.debug('HTML Body->'+mail.HtmlBody);
        mail.setPlainTextBody(mesg.PlainTextBody);
        System.debug('Body->'+mesg.PlainTextBody);
        mail.setSaveAsActivity(false);
        return mail;
    }
}