public class UserTriggerHandler {

    // ─── Existing: update promo code on account ───────────────────────────────
    public static void updatePromoCode(List<User> userList) {
        Set<String> accountIdSet = new Set<String>();
        for (User userInstance : userList) {
            if (userInstance.AccountId != null) {
                accountIdSet.add(userInstance.AccountId);
            }
        }
        if (!accountIdSet.isEmpty()) {
            UserTriggerHandler.futureUpdateAccount(accountIdSet);
        }
    }

    @future
    public static void futureUpdateAccount(Set<String> accountIdSet) {
        if (accountIdSet != null && !accountIdSet.isEmpty()) {
            List<Account> accountListToUpdate = new List<Account>();
            for (Account accountInstance : [
                SELECT Id, Name, Affiliate_Number__c
                FROM Account
                WHERE Id IN :accountIdSet AND Affiliate_Number__c = null
            ]) {
                Integer len = 6;
                Blob blobKey = Crypto.generateAesKey(128);
                String key   = EncodingUtil.convertToHex(blobKey);
                accountInstance.Affiliate_Number__c = key.substring(0, len);
                accountListToUpdate.add(accountInstance);
            }
            if (!accountListToUpdate.isEmpty()) {
                update accountListToUpdate;
            }
        }
    }

    // ─── New: add portal user to their agency's Public Group on insert ────────
    // Called from UserTrigger after insert.
    // When a User is created for a Contact that has Agency__c set,
    // find the group named Agc_{agencyContactId15} and add the user to it.
    public static void addUsersToAgencyGroup(List<User> newUsers) {
        // Collect ContactIds of portal users that have an associated contact
        Set<Id> contactIds = new Set<Id>();
        for (User u : newUsers) {
            if (u.IsPortalEnabled && u.ContactId != null) {
                contactIds.add(u.ContactId);
            }
        }
        if (contactIds.isEmpty()) { return; }

        // Fetch the Agency__c field from those contacts
        List<Contact> contacts = [
            SELECT Id, Agency__c
            FROM Contact
            WHERE Id IN :contactIds
              AND Agency__c != null
        ];
        if (contacts.isEmpty()) { return; }

        // Build group developer names from Agency__c
        Map<Id, Id> contactToAgency = new Map<Id, Id>(); // contactId -> agencyContactId
        List<String> groupDevNames  = new List<String>();
        for (Contact con : contacts) {
            contactToAgency.put(con.Id, con.Agency__c);
            groupDevNames.add('Agency_' + ((Id)con.Agency__c).to15());
        }

        List<Group> groups = [
            SELECT Id, DeveloperName FROM Group
            WHERE DeveloperName IN :groupDevNames
              AND Type = 'Regular'
        ];
        if (groups.isEmpty()) { return; }

        Map<String, Id> devNameToGroupId = new Map<String, Id>();
        for (Group g : groups) {
            devNameToGroupId.put(g.DeveloperName, g.Id);
        }

        // Build a contactId -> userId map from the incoming users
        Map<Id, Id> contactToUser = new Map<Id, Id>();
        for (User u : newUsers) {
            if (u.IsPortalEnabled && u.ContactId != null) {
                contactToUser.put(u.ContactId, u.Id);
            }
        }

        List<GroupMember> membersToInsert = new List<GroupMember>();
        for (Contact con : contacts) {
            Id agencyId = contactToAgency.get(con.Id);
            Id groupId  = devNameToGroupId.get('Agency_' + ((Id)agencyId).to15());
            Id userId   = contactToUser.get(con.Id);
            if (groupId != null && userId != null) {
                membersToInsert.add(new GroupMember(
                    GroupId       = groupId,
                    UserOrGroupId = userId
                ));
            }
        }
        if (!membersToInsert.isEmpty()) {
            Database.insert(membersToInsert, false);
        }
    }
}