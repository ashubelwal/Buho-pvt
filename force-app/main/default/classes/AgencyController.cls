public without sharing class AgencyController {
    
    public static void updatePolicyAgentAgency(String policyId, String agentUserId){
        String agentId ='';
        String policyContactId = '';
        Contact agentContact = new Contact();
        List<Contact> customerContact = new List<Contact>();
        User getUserInfo = new User();
        
        if(agentUserId != null){
            getUserInfo = [Select Id,Email,User_Type__c,ContactId, Custom_ContactId__c FROM User WHERE Id =: agentUserId LIMIT 1];
            if(getUserInfo.ContactId != null){
                agentId = getUserInfo.ContactId;
                
            }else{
                List<Contact> getContact = [Select id from contact where email =: getUserInfo.Email Limit 1];
                if(getContact.size() > 0){
                    agentId = getContact[0].Id;
                }else{
                    agentId = getUserInfo.Custom_ContactId__c;
                }
            }
        }
        
        if(agentId != null){
            agentContact = [Select id,name, Agency__c from Contact WHERE Id =: agentId LIMIT 1];
        }
        
        if(policyId != null){
            policyContactId = [Select Id,Name,Contact__c FROM Policy__c WHERE Id =: policyId LIMIT 1].Contact__c;
            
            if(policyContactId != null){
                customerContact = [Select id,name FROM Contact WHERE Id =: policyContactId AND Agency__c = null AND Agent__c = null LIMIT 1];
            }
            
            
            Policy__c policy = new Policy__c();
            policy.Id = policyId;
            if(agentContact.Agency__c != null){
                policy.Agency__c = agentContact.Agency__c;
            }else{
                policy.Agency__c = agentContact.Id;
            }
            
            policy.Agent__c = agentContact.Id;
            
            if(customerContact.size() > 0){
                Contact contact = new Contact();
                contact.Id = policyContactId;
                contact.Agency__c = policy.Agency__c;
                contact.Agent__c = policy.Agent__c;
                update contact;
            }
            
            update policy;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static User getUserData(String recordId){
        User userData =[Select Id,Primary_color__c,Partner_name__c ,Partner_Id__c,Partner_email__c,Logo_URL__c,User_Type__c from User WHERE ID =: recordId LIMIT 1];
        return userData;
    }
    
    @AuraEnabled
    public static string updateUserData(String JsonData, String recordId){
        System.debug('JsonData-->'+JsonData);
        if(JsonData != null){
            User cppdData = (User) JSON.deserialize((JsonData),User.class);
            try{
                cppdData.id = recordId;
                update cppdData;
                System.debug('cppdData-->'+cppdData);
                return 'Success';
            }catch(Exception e){
                System.debug('Error ' + e.getMessage());
                String error = e.getMessage();
                return error;
            }
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLeadId(String recordId){
        String leadId =[Select Id,Lead__c from quote__c WHERE ID =: recordId LIMIT 1].Lead__c;
        return leadId;
    }
    
    @AuraEnabled(cacheable=true)
    public static decimal getAgentFeeFromUser(String userId){
        system.debug('userId-->'+userId);
        User agentFee =[Select Id,Agent_Fee__c from user WHERE ID =: userId LIMIT 1];
        system.debug('agentFee-->'+agentFee);
        if(agentFee.Agent_Fee__c != null){
            return agentFee.Agent_Fee__c;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void updateAgentFeeFromQuote(String agentFee, String userId){
        System.debug('agentFee-->'+agentFee);
        System.debug('userId-->'+userId);
        if(agentFee != null && userId != null){
            User us = new user();
            us.Id = userId;
            us.Agent_Fee__c = Decimal.valueOf(agentFee);
            update us;
        }else{
        }
        
    }
    
    @AuraEnabled
    public static string addAgency(String leadJSON){
        try {
            System.debug(leadJSON);
            if(leadJSON != null){
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(leadJSON);
                Lead leadData = new Lead();
                leadData.FirstName = (String)resultMap.get('firstName');
                leadData.LastName = (String)resultMap.get('lastName');
                leadData.Title = (String)resultMap.get('title');
                leadData.Email = (String)resultMap.get('email');
                leadData.Phone = (String)resultMap.get('phone');
                leadData.Website = (String)resultMap.get('website');
                leadData.Company = (String) resultMap.get('company');
                leadData.Expected_Monthly_Volume__c = Decimal.valueof((String)resultMap.get('expectedMonthlyVolume'));
                
                if(resultMap.containsKey('checkboxValues')){
                    List<Object> checkboxValues = (List<Object>) resultMap.get('checkboxValues');
                    String multiPicklistValue = String.join(checkboxValues, ';');
                    leadData.Product_s_of_interest__c = multiPicklistValue ;
                }
                
                if(resultMap.containsKey('comments')){
                    leadData.Comments__c = (String) resultMap.get('comments');
                }
                
                Id recordType = [Select id FROM RecordType  Where RecordType.Name = 'Insurance Agency' LIMIT 1].id;
                leadData.RecordTypeId = recordType;
                
                if(leadData != null){
                    Database.insert(leadData);
                    AgencyController.leadToAgencyRecord(leadData.Id);
                    return 'Success';
                    
                }
            }
            return 'Failed';
            
            
        } catch (Exception e) {
            System.debug(e.getMessage() + '' + 'Line number :' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage() + '' + 'Line number :' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static string leadToAgencyRecord(Id leadId){
        try {
            if(leadId != null){
                Lead leadData = [Select id,Name FROM Lead Where Id =: leadId];
                
                if(leadData != null){
                    Agency__c agencyData = new Agency__c();
                    agencyData.Name = leadData.Name;
                    agencyData.Lead__c = leadId;
                    if(agencyData != null){
                        
                        Database.insert(agencyData);
                        return 'Success';
                    }
                    
                    
                }
            }
            return 'Failed';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // @AuraEnabled
    // public static string convertAgencyToUser(Id recordId){
    //     try { Id accountId ;
    //         Id contactId ;
    //         //Agency__c agencyData = [SELECT Id , Name , lead__c , Contact__c FROM Agency__c WHERE Id =:recordId];
    //         RecordType recordType = [SELECT Id,DeveloperName, Name,SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName ='Agency_RT' LIMIT 1];
            
    //         Lead leadData = [SELECT Id,Name,FirstName,LastName,Email,Phone,Website,Company,Product_s_of_interest__c,
    //                          Comments__c,Expected_Monthly_Volume__c,Why_Looking_to_Switch__c,Setup_Charge__c,Recurring_Charge__c,Partner_Platform__c,Eligible_Carrier__c,Default_Agent_Fee__c,Agency_Status__c,
    //                          Mexico_Experience__c,Commission_Mex_Water_Renew__c,Commission_Mex_Water_New__c,Commission_Mex_RV_Renew__c,Commission_Mex_RV_New__c,
    //                          Commission_Mex_Moto_Renew__c,Commission_Mex_Moto_New__c,Commission_Mex_Auto_Renew__c,Commission_Mex_Auto_New__c,Agent_Fee_Option__c, Underwriter_Picklist__c
    //                          FROM Lead WHERE Id =: recordId];
            
    //         if(leadData != null){
    //             List<Account> accountList = [SELECT Id, Name FROM Account WHERE Email__c = :leadData.Email ];
                
    //             if(accountList.size() > 0){
    //                 for(Account acc:accountList){
    //                     if(acc.name == leadData.Name){
    //                         accountId = acc.Id;
    //                         break;
    //                     }
    //                 }
    //             } else {
    //                 Account acc = new Account();
    //                 acc.Name = leadData.Name;
    //                 acc.Email__c = leadData.Email;
    //                 acc.Phone = leadData.Phone;
    //                 if(acc != null){
    //                     Database.insert(acc);
    //                     accountId = acc.Id;
    //                 }
    //             }
                
    //             List<Contact> contactList = [SELECT Id, Name , Email FROM Contact WHERE Email = :leadData.Email];
    //             Contact contact = new Contact();
                
    //             if(contactList.size() > 0){
    //                 for(Contact con:contactList){
    //                     if(con.name == leadData.Name){
    //                         contactId = con.Id;
    //                         break;
    //                     }
    //                 }
    //             } else {
                    
    //                 contact.FirstName = leadData.FirstName;
    //                 contact.LastName = leadData.LastName;
    //                 contact.Email = leadData.Email;
    //                 contact.AccountId = accountId;
    //                 contact.RecordTypeId = recordType.Id;
    //                 contact.Website__c = leadData.Website;
    //                 contact.Product_s_of_interest__c = leadData.Product_s_of_interest__c;
    //                 contact.Comments__c = leadData.Comments__c;
    //                 contact.Expected_Monthly_Volume__c = leadData.Expected_Monthly_Volume__c;
    //                 contact.Underwriter_Picklist__c = leadData.Underwriter_Picklist__c;
    //                 contact.Agency_Status__c = leadData.Agency_Status__c;
    //                 contact.Why_Looking_to_Switch__c = leadData.Why_Looking_to_Switch__c;
    //                 contact.Setup_Charge__c = leadData.Setup_Charge__c;
    //                 contact.Recurring_Charge__c = leadData.Recurring_Charge__c;
    //                 contact.Partner_Platform__c = leadData.Partner_Platform__c;
    //                 contact.Eligible_Carrier__c = leadData.Eligible_Carrier__c;
    //                 contact.Agent_Fee_Option__c = leadData.Agent_Fee_Option__c;
    //                 contact.Default_Agent_Fee__c = leadData.Default_Agent_Fee__c;
    //                 contact.Currently_Selling_Mexico_Insurance__c = leadData.Mexico_Experience__c;
    //                 contact.Commission_Mex_Water_Renew__c = leadData.Commission_Mex_Water_Renew__c;
    //                 contact.Commission_Mex_Water_New__c = leadData.Commission_Mex_Water_New__c;
    //                 contact.Commission_Mex_RV_Renew__c = leadData.Commission_Mex_RV_Renew__c;
    //                 contact.Commission_Mex_RV_New__c = leadData.Commission_Mex_RV_New__c;
    //                 contact.Commission_Mex_Moto_Renew__c = leadData.Commission_Mex_Moto_Renew__c;
    //                 contact.Commission_Mex_Moto_New__c = leadData.Commission_Mex_Moto_New__c;
    //                 contact.Commission_Mex_Auto_Renew__c = leadData.Commission_Mex_Auto_Renew__c;
    //                 contact.Commission_Mex_Auto_New__c = leadData.Commission_Mex_Auto_New__c;
                    
    //                 if(contact != null){
    //                     Database.insert(contact);
    //                     contactId = contact.Id;
    //                 }
    //             }
                
    //             if(accountId != null){
    //                 Opportunity opp = new Opportunity();
    //                 opp.Name = leadData.Name;
    //                 opp.StageName = 'Closed Won';
    //                 opp.CloseDate = date.today();
    //                 opp.AccountId = accountId;
    //                 opp.Amount = leadData.Expected_Monthly_Volume__c;
    //                 opp.Email__c = leadData.Email;
                    
    //                 if(opp != null){
    //                     Database.insert(opp);
    //                 }
    //             }
                
    //             Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Agency Community Plus Login User' LIMIT 1];
    //             String userFName = leadData.FirstName.substring(0,1);
    //             String userLName = leadData.LastName.length() >=3 ? leadData.LastName.substring(0, 3):leadData.LastName;
    //             User newUser = new User(
    //                 Username = leadData.Email,
    //             Email = leadData.Email,
    //             LastName = leadData.LastName,
    //             FirstName = leadData.FirstName,
    //             Phone = leadData.Phone != null ? leadData.Phone : '',
    //             Alias = (leadData.FirstName != null && leadData.LastName != null) ? userFName + ' ' + userLName : (leadData.FirstName == null && leadData.LastName != null) ? userLName : '',
    //             contactId = contactId,
    //             User_Type__c = 'Agency',
    //             Agent_Account_Id__c = accountId,
    //             profileId = portalProfile.Id,
    //             EmailEncodingKey = 'UTF-8',
    //             TimeZoneSidKey = 'America/Los_Angeles',
    //             LocaleSidKey = 'en_US',
    //             LanguageLocaleKey = 'en_US'
    //                 );
                
    //             if(newUser != null){
    //                 Database.insert(newUser);
    //                 // agencyData.Contact__c = contactId;
    //                 //Database.update(agencyData);
    //                 return 'Success';
    //             }
                
    //         }
    //         return 'Failed';
            
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    @AuraEnabled
    public static string convertAgencyToUser(Id recordId){
        try { Id accountId ;
            Id contactId ;
            //Agency__c agencyData = [SELECT Id , Name , lead__c , Contact__c FROM Agency__c WHERE Id =:recordId];
            RecordType recordType = [SELECT Id,DeveloperName, Name,SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName ='Agency_RT' LIMIT 1];
            
            Lead leadData = [SELECT Id,Name,FirstName,LastName,Email,Phone, Street, City, State, PostalCode, Country, Website,Company,Product_s_of_interest__c,
                             Comments__c,Expected_Monthly_Volume__c,Why_Looking_to_Switch__c,Setup_Charge__c,Recurring_Charge__c,Partner_Platform__c,Eligible_Carrier__c,Default_Agent_Fee__c,Agency_Status__c,
                             Mexico_Experience__c,Commission_Mex_Water_Renew__c,Commission_Mex_Water_New__c,Commission_Mex_RV_Renew__c,Commission_Mex_RV_New__c,
                             Commission_Mex_Moto_Renew__c,Commission_Mex_Moto_New__c,Commission_Mex_Auto_Renew__c,Commission_Mex_Auto_New__c,Agent_Fee_Option__c, Underwriter_Picklist__c
                             FROM Lead WHERE Id =: recordId];
            
            if(leadData != null){
                List<Account> accountList = [SELECT Id, Name FROM Account WHERE Email__c = :leadData.Email ];
                
                if(accountList.size() > 0){
                    for(Account acc:accountList){
                        if(acc.name == leadData.Name){
                            accountId = acc.Id;
                            break;
                        }
                    }
                } else {
                    Account acc = new Account();
                    acc.Name = leadData.Name;
                    acc.Email__c = leadData.Email;
                    acc.Phone = leadData.Phone;
                    if(acc != null){
                        Database.insert(acc);
                        accountId = acc.Id;
                    }
                }
                
                List<Contact> contactList = [SELECT Id, Name , Email FROM Contact WHERE Email = :leadData.Email];
                Contact contact = new Contact();
                
                if(contactList.size() > 0){
                    for(Contact con:contactList){
                        if(con.name == leadData.Name){
                            contactId = con.Id;
                            break;
                        }
                    }
                } else {
                    
                    contact.FirstName = leadData.FirstName;
                    contact.LastName = leadData.LastName;
                    contact.Email = leadData.Email;
                    contact.Phone = leadData.Phone;
                    contact.Company_details__c = leadData.Company;
                    contact.MailingStreet = leadData.Street;
                    contact.MailingCity = leadData.City;
                    contact.MailingState = leadData.State;
                    contact.MailingPostalCode = leadData.PostalCode;
                    contact.MailingCountry = leadData.Country;
                    contact.AccountId = accountId;
                    contact.RecordTypeId = recordType.Id;
                    contact.Website__c = leadData.Website;
                    contact.Product_s_of_interest__c = leadData.Product_s_of_interest__c;
                    contact.Comments__c = leadData.Comments__c;
                    contact.Expected_Monthly_Volume__c = leadData.Expected_Monthly_Volume__c;
                    contact.Underwriter_Picklist__c = leadData.Underwriter_Picklist__c;
                    contact.Agency_Status__c = leadData.Agency_Status__c;
                    contact.Why_Looking_to_Switch__c = leadData.Why_Looking_to_Switch__c;
                    contact.Setup_Charge__c = leadData.Setup_Charge__c;
                    contact.Recurring_Charge__c = leadData.Recurring_Charge__c;
                    contact.Partner_Platform__c = leadData.Partner_Platform__c;
                    contact.Eligible_Carrier__c = leadData.Eligible_Carrier__c;
                    contact.Agent_Fee_Option__c = leadData.Agent_Fee_Option__c;
                    contact.Default_Agent_Fee__c = leadData.Default_Agent_Fee__c;
                    contact.Currently_Selling_Mexico_Insurance__c = leadData.Mexico_Experience__c;
                    contact.Commission_Mex_Water_Renew__c = leadData.Commission_Mex_Water_Renew__c;
                    contact.Commission_Mex_Water_New__c = leadData.Commission_Mex_Water_New__c;
                    contact.Commission_Mex_RV_Renew__c = leadData.Commission_Mex_RV_Renew__c;
                    contact.Commission_Mex_RV_New__c = leadData.Commission_Mex_RV_New__c;
                    contact.Commission_Mex_Moto_Renew__c = leadData.Commission_Mex_Moto_Renew__c;
                    contact.Commission_Mex_Moto_New__c = leadData.Commission_Mex_Moto_New__c;
                    contact.Commission_Mex_Auto_Renew__c = leadData.Commission_Mex_Auto_Renew__c;
                    contact.Commission_Mex_Auto_New__c = leadData.Commission_Mex_Auto_New__c;
                    
                    if(contact != null){
                        Database.insert(contact);
                        contactId = contact.Id;
                    }
                }
                
                if(accountId != null){
                    Opportunity opp = new Opportunity();
                    opp.Name = leadData.Name;
                    opp.StageName = 'Closed Won';
                    opp.CloseDate = date.today();
                    opp.AccountId = accountId;
                    opp.Amount = leadData.Expected_Monthly_Volume__c;
                    opp.Email__c = leadData.Email;
                    
                    if(opp != null){
                        Database.insert(opp);
                    }
                }
                
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Agency Community Plus Login User' LIMIT 1];
                String userFName = leadData.FirstName.substring(0,1);
                String userLName = leadData.LastName.length() >=3 ? leadData.LastName.substring(0, 3):leadData.LastName;
                User newUser = new User(
                    Username = leadData.Email,
                Email = leadData.Email,
                LastName = leadData.LastName,
                FirstName = leadData.FirstName,
                Phone = leadData.Phone != null ? leadData.Phone : '',
                Alias = (leadData.FirstName != null && leadData.LastName != null) ? userFName + ' ' + userLName : (leadData.FirstName == null && leadData.LastName != null) ? userLName : '',
                contactId = contactId,
                User_Type__c = 'Agency',
                Agent_Account_Id__c = accountId,
                profileId = portalProfile.Id,
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
                    );
                
                if(newUser != null){
                    Database.insert(newUser);
                    // agencyData.Contact__c = contactId;
                    //Database.update(agencyData);
                    return 'Success';
                }
                
            }
            return 'Failed';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string convertLeadToAgent(String firstName, String lastName, String email, String phone, String agencyId, String usertype){
        
        String leadId;
        Boolean isConverted;
        String ConvertedContactId;
        String contactId;
        String agentUser;
        List<User> isExistingUser = new List<User>();
        List<Contact> fetchContact = [SELECT Id,Name,email,phone FROM Contact WHERE email = :email LIMIT 1];
        List<Lead> fetchLead = [SELECT Id,Name,email,phone,IsConverted,ConvertedContact.Id FROM Lead WHERE email = :email LIMIT 1];
        
        if(fetchContact.size() > 0){
            contactId = fetchContact[0].Id;
        }else if(fetchLead.size() > 0){
            leadId = fetchLead[0].Id;
            isConverted = fetchLead[0].IsConverted;
            ConvertedContactId = fetchLead[0].ConvertedContact.Id;
        }
        
        if(fetchContact.size() > 0){
            isExistingUser = [SELECT Id,Name FROM USER WHERE email =: email OR contactId =: contactId];
        }else{
            isExistingUser = [SELECT Id,Name FROM USER WHERE email =: email];
        }
        
        System.debug('isExistingUser:::'+isExistingUser);
        System.debug('fetchContact:::'+fetchContact);
        System.debug('fetchLead:::'+fetchLead);
        
        if(isExistingUser.size() > 0){
            return 'Exist';
        }
        
        System.debug('contactId:::'+contactId);
        if(leadId != null){
            agentUser = createAgentUser(firstName,lastName,email,phone,isConverted,ConvertedContactId,agencyId, usertype);
            
        }else if(contactId != null){
            agentUser = createAgentUser(firstName,lastName,email,phone,true,contactId,agencyId,usertype);
        }else{
            agentUser =createAgentUser(firstName,lastName,email,phone,false,'',agencyId,usertype);
        }
        return agentUser;
        
        
    }
    
    public static string createAgentUser(String fName, String lName, String email, String Phone, Boolean isConverted, String sourceId, String agencyId, String usertype){
        System.debug('TEST:::');
        
        String accountId;
        String contactId;
        RecordType recordType = [SELECT Id,DeveloperName, Name,SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName ='Agent_RT' LIMIT 1];
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Agent Community Plus Login User' LIMIT 1];
        String userFName = fName.substring(0,1);
        String userLName = lName.length() >=3 ? lName.substring(0, 3):lName;
        System.debug('TEST:::');
        if(isConverted == false){
            Account acc = new Account();
            acc.Name = fName + '' + lName;
            acc.Email__c = email;
            acc.Phone = Phone;
            
            Database.insert(acc);
            System.debug('Account:::'+acc);
            
            Contact contact = new Contact();
            contact.FirstName = fName;
            contact.LastName = lName;
            contact.Email = email;
            contact.AccountId = acc.Id;
            contact.Agency__c = agencyId;
            contact.RecordTypeId = recordType.Id;
            Database.insert(contact);
            
            System.debug('Contact:::'+contact);
            contactId = contact.Id;
            accountId = acc.Id;
        }else{
            contactId = sourceId;
            accountId = [SELECT id,AccountId FROM Contact WHERE Id =: sourceId].AccountId;
            if(accountId == null){
                Account acc = new Account();
                acc.Name = fName + '' + lName;
                acc.Email__c = email;
                acc.Phone = Phone;
                
                Database.insert(acc);
                accountId = acc.Id;
            }
        }
        
        User newUser = new User(
            Username = email,
        Email = email,
        LastName = lName,
        FirstName = fName,
        Phone = Phone != null ? Phone : '',
        Alias = (fName != null && lName != null) ? userFName + ' ' + userLName : (fName == null && lName != null) ? userLName : '',
        contactId = contactId,
        User_Type__c = usertype,
        Agent_Account_Id__c = accountId,
        profileId = portalProfile.Id,
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US'
            );
        
        Database.insert(newUser);
        
        System.debug('USER:::'+newUser);
        return 'Success';
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Affiliate__c> getAffiliateCode(String UserId){
        List<Affiliate__c> affiliateUser = new List<Affiliate__c>();
        try {
            String agentId ='';
            Contact agentContact = new Contact();
            User getUserInfo = new User();
            if(UserId != null){
                getUserInfo = [Select Id,Email,User_Type__c,ContactId, Custom_ContactId__c FROM User WHERE Id =: UserId LIMIT 1];
                if(getUserInfo.ContactId != null){
                    agentId = getUserInfo.ContactId;
                    
                }else{
                    List<Contact> getContact = [Select id from contact where email =: getUserInfo.Email Limit 1];
                    if(getContact.size() > 0){
                        agentId = getContact[0].Id;
                    }else{
                        agentId = getUserInfo.Custom_ContactId__c;
                    }
                }
            }
            
            if(agentId != null){
                agentContact = [Select id,name, Agency__c from Contact WHERE Id =: agentId LIMIT 1];
            }
            
            if(agentContact != null){
                if(agentContact.Agency__c != null){
                    affiliateUser = [Select Id,Affiliate_Id__c FROM Affiliate__c Where Agency_Contact__c=:agentContact.Agency__c AND Agent_Contact__c =: agentContact.Id];
                }else{
                    affiliateUser = [Select Id,Affiliate_Id__c FROM Affiliate__c Where Agency_Contact__c =: agentContact.Id];
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return affiliateUser;
        
    }
    
}