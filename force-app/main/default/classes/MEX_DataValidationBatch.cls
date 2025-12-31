public without sharing class MEX_DataValidationBatch implements Database.Batchable<sObject> {
    public EmailTemplate NotificationEmailTemplate;
    public Boolean isRunningForAccount = false;
    public set<String> duplicatePhones = new Set<String>();
    
    public class ExceptionLog{
        public String errorMessage;
        public Boolean isSuccess;
    }
    
    @AuraEnabled
    public static String updateAccountRecords(String statusValue, String recordId){
        ExceptionLog ex = new ExceptionLog();
        try{
            Blob key = Crypto.generateAesKey(128);
            Blob ciphertextAndIV =
                Crypto.encryptWithManagedIV('AES128', key, EncodingUtil.base64Decode(recordId));
            Blob plaintext = Crypto.decryptWithManagedIV('AES128', key, ciphertextAndIV);
            Id decryptRecordId = Id.valueOf(plaintext.toString());
            
            if(String.valueOf(decryptRecordId.getSobjectType()).equalsIgnoreCase('User')){
                User ussRec = [SELECT Id, Name, Status_Confirmation__c From User Where Id = :decryptRecordId];
                if (ussRec != null && (ussRec.Status_Confirmation__c == 'Pending' || String.isEmpty(ussRec.Status_Confirmation__c))) {
                    ussRec.Status_Confirmation__c = statusValue;
                    update ussRec;
                    ex.isSuccess = true;
                    return JSON.serialize(ex);
                } else {
                     ex.isSuccess = false;
                    return JSON.serialize(ex);
                } 
            }else{
                Account accRec = [SELECT Id, Name, Status_Confirmation__c From Account Where Id = :decryptRecordId];
                if (accRec != null && (accRec.Status_Confirmation__c == 'Pending' || String.isEmpty(accRec.Status_Confirmation__c))) {
                    accRec.Status_Confirmation__c = statusValue;
                    update accRec;
                     ex.isSuccess = true;
                    return JSON.serialize(ex);
                } else {
                    ex.isSuccess = false;
                    return JSON.serialize(ex);
                }
            }
            
        }catch(Exception e){
            system.debug('error: '+e.getMessage()+' at line: '+e.getLineNumber());
             ex.isSuccess = false;
            ex.errorMessage = ('error: '+e.getMessage()+' at line: '+e.getLineNumber());
             return JSON.serialize(ex);
        } 
    }
    
    public MEX_DataValidationBatch(Boolean isRunningForAccount){
        this.isRunningForAccount = isRunningForAccount;
        this.NotificationEmailTemplate =  [select id, name, HTMLValue from EmailTemplate where developername = 'Account_Status_Confirmation_Email' LIMIT 1];
        fetchDuplicatePhones();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String AccountQuery = 'SELECT Id, Name, Email__c,Status_Confirmation__c FROM Account Where (Status_Confirmation__c = null OR Status_Confirmation__c = \'Pending\') AND Phone NOT IN :duplicatePhones AND ID NOT IN (Select AccountId from User)';
        String UserQuery = 'SELECT Id, FirstName, LastName, Name, Email, Status_Confirmation__c FROM User Where (Status_Confirmation__c = null OR Status_Confirmation__c = \'Pending\') AND AccountId NOT IN (Select Id from Account)' +(Test.isRunningTest()?' LIMIT 200':'');
        return isRunningForAccount?Database.getQueryLocator(AccountQuery):Database.getQueryLocator(UserQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> recordList) {
        try{
            System.debug('data-> '+recordList);
            if(!recordList.isEmpty()){
                List<Messaging.SingleEmailMessage> Emails = new List<Messaging.SingleEmailMessage>();
                
                if(isRunningForAccount){
                    System.debug('running true-> '+recordList);
                    String wideOrgEmail = System.Label.RemainderEmail;
                    OrgWideEmailAddress[] senderEmail = [select Id from OrgWideEmailAddress where Address =: wideOrgEmail];

                    for(Account eachAccount : (List<Account>)recordList){
                        if(String.isNotBlank(eachAccount.Email__c)){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                           
                            mail.setOrgWideEmailAddressId(senderEmail.get(0).Id);

                            mail.setToAddresses(new List<String>{eachAccount.Email__c});
                            mail.setSubject('IMPORTANT - Action Required');
                            String htmlBody = NotificationEmailTemplate.HTMLValue;
                            htmlBody = htmlBody.replace('{ACCOUNT_FIRSTNAME}',eachAccount.Name);
                            htmlBody = htmlBody.replace('{CONFIRM_EMAIL}', eachAccount.Email__c);
                            
                            String text = eachAccount.Id;
                            Blob key = Crypto.generateAesKey(128);
                            Blob data = Blob.valueOf(text);
                            String b64Data = EncodingUtil.base64Encode(data);
                            
                            htmlBody = htmlBody.replace('{CONFIRM_LINK}','https://mexinsurance--ca.sandbox.my.salesforce-sites.com/Acknowledged?Id='+b64Data+'&status=Confirmed');
                            htmlBody = htmlBody.replace('{REJECT_LINK}','https://mexinsurance--ca.sandbox.my.salesforce-sites.com/Acknowledged?Id='+b64Data+'&status=Rejected');
                            mail.setHtmlBody(htmlBody);
                            Emails.add(mail);
                        }
                    }
                }else{
                    System.debug('running false-> '+recordList);
                    String wideOrgEmail = System.Label.RemainderEmail;
                    OrgWideEmailAddress[] senderEmail = [select Id from OrgWideEmailAddress where Address =: wideOrgEmail];
                    
                    for(User eachUser : (List<User>)recordList){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                        
                        mail.setOrgWideEmailAddressId(senderEmail.get(0).Id);

                        mail.setToAddresses(new List<String>{eachUser.Email});
                        mail.setSubject('IMPORTANT - Action Required');
                        String htmlBody = NotificationEmailTemplate.HTMLValue;
                        htmlBody = htmlBody.replace('{ACCOUNT_FIRSTNAME}',eachUser.FirstName);
                        htmlBody = htmlBody.replace('{CONFIRM_EMAIL}',eachUser.Email);
                        
                        String text = eachUser.Id;
                        Blob key = Crypto.generateAesKey(128);
                        Blob data = Blob.valueOf(text);
                        String b64Data = EncodingUtil.base64Encode(data);
                        
                        htmlBody = htmlBody.replace('{CONFIRM_LINK}',System.Label.Public_Site_URL+'/Acknowledged?Id='+b64Data+'&status=Confirmed');
                        htmlBody = htmlBody.replace('{REJECT_LINK}',System.Label.Public_Site_URL+'/Acknowledged?Id='+b64Data+'&status=Rejected');
                        mail.setHtmlBody(htmlBody);
                        Emails.add(mail);
                    } 
                }
                
                if(!Emails.isEmpty() && !Test.isRunningTest()){
                    Messaging.sendEmail(Emails);
                }
                
            }
        }catch(Exception e){
            system.debug('error: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
    } 
    
    public void fetchDuplicatePhones(){
        AggregateResult[] results = [Select Count(Id), Phone from Account Group by Phone Having Count(Id) > 1 LIMIT 50000];
        for (AggregateResult ar : results)  {
            this.duplicatePhones.add(String.valueOf(ar.get('Phone')));
        }
    }
    
    
    public void finish(Database.BatchableContext BC) {
    }
}