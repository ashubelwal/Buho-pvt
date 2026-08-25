public with sharing class AgencyPortalController {
    @AuraEnabled
    public static String createAgencyUser(String firstName, String lastName, String email, String agencyContactId) {
        try {
            return AgencyPortalControllerBase.createAgencyUser(firstName, lastName, email, agencyContactId);
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