public without sharing class AgencyPortalController {
    @AuraEnabled
    public static String createAgencyUser(String firstName, String lastName, String email, String agencyContactId) {
        try {
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
        } catch (Exception e) {
            throw new  AuraHandledException(e.getMessage());
        }
    }

    /**
   * @description Returns dashboard statistics aggregated via SOQL.
   *   All counts are unbounded (no LIMIT), so they reflect every accessible record.
   *   Returns a Map with the following keys:
   *     totalPolicies         – all-time Policy__c count
   *     thisMonthPolicies     – policies created in the current calendar month
   *     lastMonthPolicies     – policies created in the previous calendar month
   *     thisMonthRevenue      – sum of Total_Transaction_Amount__c for this month
   *     lastMonthRevenue      – sum of Total_Transaction_Amount__c for last month
   *     expiringSoon          – policies expiring within the next 30 days
   *     totalClients          – all-time Contact count
   *     thisMonthClients      – contacts created in the current calendar month
   *     lastMonthClients      – contacts created in the previous calendar month
   * @return Map<String, Object>
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getDashboardStats() {
    Map<String, Object> result = new Map<String, Object>();

    // ── Date boundaries ──────────────────────────────────────────────────────
    Date today           = Date.today();
    Date firstOfThisMonth = Date.newInstance(today.year(), today.month(), 1);
    Date firstOfNextMonth = firstOfThisMonth.addMonths(1);
    Date firstOfLastMonth = firstOfThisMonth.addMonths(-1);
    Date thirtyDaysOut   = today.addDays(30);

    // ── Policy aggregates ─────────────────────────────────────────────────────
    // Total all-time
    AggregateResult[] totalPolicyAgg = [
      SELECT COUNT(Id) cnt FROM Policy__c
    ];
    result.put('totalPolicies', (Integer) totalPolicyAgg[0].get('cnt'));

    // This month
    AggregateResult[] thisMonthPolicyAgg = [
      SELECT COUNT(Id) cnt, SUM(Total_Transaction_Amount__c) rev
      FROM Policy__c
      WHERE CreatedDate >= :DateTime.newInstance(firstOfThisMonth, Time.newInstance(0,0,0,0))
        AND CreatedDate <  :DateTime.newInstance(firstOfNextMonth, Time.newInstance(0,0,0,0))
    ];
    result.put('thisMonthPolicies', (Integer) thisMonthPolicyAgg[0].get('cnt'));
    result.put('thisMonthRevenue',  thisMonthPolicyAgg[0].get('rev') != null
        ? ((Decimal) thisMonthPolicyAgg[0].get('rev')).setScale(0)
        : 0);

    // Last month
    AggregateResult[] lastMonthPolicyAgg = [
      SELECT COUNT(Id) cnt, SUM(Total_Transaction_Amount__c) rev
      FROM Policy__c
      WHERE CreatedDate >= :DateTime.newInstance(firstOfLastMonth, Time.newInstance(0,0,0,0))
        AND CreatedDate <  :DateTime.newInstance(firstOfThisMonth, Time.newInstance(0,0,0,0))
        WITH USER_MODE
    ];
    result.put('lastMonthPolicies', (Integer) lastMonthPolicyAgg[0].get('cnt'));
    result.put('lastMonthRevenue',  lastMonthPolicyAgg[0].get('rev') != null
        ? ((Decimal) lastMonthPolicyAgg[0].get('rev')).setScale(0)
        : 0);

    // Expiring within next 30 days
    AggregateResult[] expiringAgg = [
      SELECT COUNT(Id) cnt
      FROM Policy__c
      WHERE End_Date__c >= :today
        AND End_Date__c <= :thirtyDaysOut
    ];
    result.put('expiringSoon', (Integer) expiringAgg[0].get('cnt'));

    // ── Contact aggregates ────────────────────────────────────────────────────
    AggregateResult[] totalClientAgg = [
      SELECT COUNT(Id) cnt FROM Contact
    ];
    result.put('totalClients', (Integer) totalClientAgg[0].get('cnt'));

    AggregateResult[] thisMonthClientAgg = [
      SELECT COUNT(Id) cnt
      FROM Contact
      WHERE CreatedDate >= :DateTime.newInstance(firstOfThisMonth, Time.newInstance(0,0,0,0))
        AND CreatedDate <  :DateTime.newInstance(firstOfNextMonth, Time.newInstance(0,0,0,0))
    ];
    result.put('thisMonthClients', (Integer) thisMonthClientAgg[0].get('cnt'));

    AggregateResult[] lastMonthClientAgg = [
      SELECT COUNT(Id) cnt
      FROM Contact
      WHERE CreatedDate >= :DateTime.newInstance(firstOfLastMonth, Time.newInstance(0,0,0,0))
        AND CreatedDate <  :DateTime.newInstance(firstOfThisMonth, Time.newInstance(0,0,0,0))
        WITH USER_MODE
    ];
    result.put('lastMonthClients', (Integer) lastMonthClientAgg[0].get('cnt'));

    return result;
  }
}