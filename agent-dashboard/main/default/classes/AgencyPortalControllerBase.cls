public without sharing class AgencyPortalControllerBase {
    @AuraEnabled
    public static String createAgencyUser(String firstName, String lastName, String email, String agencyContactId) {
        User agencyUser = [SELECT Id, Logo_URL__c, Partner_email__c, Partner_Id__c, 
                            Partner_Name__c, Agent_Account_Id__c, Agent_Id__c 
                            FROM User 
                            WHERE ContactId = :agencyContactId];
        // Check if email already exists
        List<User> existingUser = [SELECT Id FROM User WHERE Username = :email OR Email = :email LIMIT 1];
        if (!existingUser.isEmpty()) {
            return 'Error: Email already exists.';
        }
        User adminUser;
        if(!Test.isRunningTest()) {
            adminUser = [SELECT Id FROM User WHERE UserName = 'charles@mexinsurance.net' LIMIT 1];
        } else {
            adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        }
        Id agencyRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent RT').getRecordTypeId();
        Contact agencyContact = [SELECT Id, AccountId FROM Contact WHERE Id =: agencyContactId];
        
        Contact newContact = new Contact();
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        newContact.Email = email;
        newContact.RecordTypeId = agencyRtId;
        newContact.Agency__c = agencyContactId;
        newContact.AccountId = agencyContact.AccountId;
        insert newContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Agency Community Plus Login User' LIMIT 1];
        
        String tempAlias = '';
        if (firstName != null && firstName.length() > 0) {
            tempAlias += firstName.substring(0,1);
        }
        if (lastName != null && lastName.length() > 3) {
            tempAlias += lastName.substring(0,3);
        } else if (lastName != null) {
            tempAlias += lastName;
        }
        
        User newUser = new User(
            Username = email,
            Email = email,
            FirstName = firstName,
            LastName = lastName,
            Alias = tempAlias,
            ProfileId = portalProfile.Id,
            ContactId = newContact.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            Logo_URL__c = agencyUser.Logo_URL__c,
            Partner_email__c = agencyUser.Partner_email__c,
            Partner_Id__c = agencyUser.Partner_Id__c,
            Partner_Name__c = agencyUser.Partner_Name__c,
            Agent_Account_Id__c = agencyUser.Agent_Account_Id__c,
            Agent_Id__c = agencyUser.Agent_Id__c
        );
        insert newUser;
        
        return 'Success';
    }
}