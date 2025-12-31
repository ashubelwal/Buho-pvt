public without sharing class DriverLicenceFlowController {
    private final static String GUEST_USER_TYPE = 'Guest';
    @AuraEnabled
    public static DriverLicenseFlowData getInitData(String policyType) {
        DriverLicenseFlowData initData = new DriverLicenseFlowData();
        String userType = UserInfo.getUserType();
        initData.isCommunityUser = !userType.equalsIgnoreCase(GUEST_USER_TYPE);
        initData.quoteRecord.Underwriter__c = 'Chubb';
        initData.quoteRecord.Coverage__c = 'Liability';
        initData.quoteRecord.Medical__c = '5,000/25,000';
        initData.quoteRecord.Policy_Type_picklist__c = policyType;

        if (initData.isCommunityUser) {
            User currentUser = getCurrentUser();
            initData.leadRecord.Date_of_Birth__c = currentUser?.Contact.Date_of_Birth__c;
            initData.leadRecord.Email = currentUser?.Email;

            initData.quoteRecord.Date_of_Birth__c = currentUser.Contact.Date_of_Birth__c;
            initData.driverRecord.First_Name__c = currentUser.FirstName;
            initData.driverRecord.Last_Name__c = currentUser.LastName;
            initData.driverRecord.Email__c = currentUser.Email;
            initData.driverRecord.Dob__c = currentUser.Contact.Date_of_Birth__c;
            initData.driverRecord.Phone__c = currentUser.Phone;
            initData.driverRecord.Address__c = currentUser.Contact.MailingStreet;
            initData.driverRecord.City__c = currentUser.Contact.MailingCity;
            initData.driverRecord.State_Province__c = currentUser.Contact.MailingState;
            initData.driverRecord.Postal_Code__c = currentUser.Contact.MailingPostalCode;
            initData.driverRecord.Country__c = currentUser.Contact.MailingCountry;
        }
        // TODO: debug only
//        initData.leadRecord.FirstName = 'John';
//        initData.leadRecord.LastName = 'Smith';
//        initData.leadRecord.Phone = '555-45-67';
//        initData.leadRecord.Email = 'example@gmail.com';
//        initData.leadRecord.Street = 'Washington st.';
//        initData.leadRecord.City = 'Austin';
//        initData.leadRecord.State = 'Texas';
//        initData.leadRecord.Country = 'United States';
//        initData.leadRecord.PostalCode = '77449';
//        initData.leadRecord.Date_of_Birth__c = Date.today().addYears(-33).addMonths(-5).addDays(-10);
//
//        initData.quoteRecord.Start_Date_for_Coverage__c = Date.today().addDays(11);
//        initData.quoteRecord.End_Date_for_Coverage__c = Date.today().addDays(376);
//         end: debug only

        return initData;
    }

    public class DriverLicenseFlowData {
        @AuraEnabled
        public Boolean isCommunityUser;
        @AuraEnabled
        public Lead leadRecord;
        @AuraEnabled
        public Driver__c driverRecord;
        @AuraEnabled
        public Quote__c quoteRecord;

        public DriverLicenseFlowData() {
            leadRecord = new Lead();
            driverRecord = new Driver__c();
            quoteRecord = new Quote__c();
        }
    }

    @AuraEnabled
    public static User getCurrentUser() {
        return [
                SELECT Id, Email, FirstName, LastName, Phone, ContactId, Contact.Email, Contact.Birthdate,
                        Contact.Date_of_Birth__c, Contact.AccountId, Contact.MailingState, Contact.MailingCity,
                        Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCountry
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ][0];
    }

    @AuraEnabled
    public static Map<String, Object> createTransactionAction(String rateRecordList, String affiliateAccountString) {
        return QuickQuotationCtrl.createTransactionAction(rateRecordList, affiliateAccountString);
    }

    @AuraEnabled
    public static Map<String, Object> updatePolicyAction(Contact contactRecord, Policy__c policyRecord, String leadIds, String quoteIds) {
        return QuickQuotationCtrl.updatePolicyAction(contactRecord, policyRecord, leadIds, quoteIds);
    }

    @AuraEnabled
    public static Account retrieveAffiliateAccount(String affiliateNumber) {
        Account acc = [
                SELECT Id
                FROM Account
                WHERE Affiliate_Number__c = :affiliateNumber
                LIMIT 1
        ];

        return acc;
    }
}