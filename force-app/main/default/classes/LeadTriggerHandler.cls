public without sharing class LeadTriggerHandler {

    // ─── After Insert ────────────────────────────────────────────────────────
    public static void onAfterInsert(List<Lead> newLeads) {
        shareLeadsWithAgencyGroup(newLeads, null);
    }

    // ─── After Update ────────────────────────────────────────────────────────
    public static void onAfterUpdate(List<Lead> newLeads, Map<Id, Lead> oldMap) {
        List<Lead> agencyChangedLeads = new List<Lead>();
        for (Lead ld : newLeads) {
            if (ld.Agency__c != oldMap.get(ld.Id).Agency__c) {
                agencyChangedLeads.add(ld);
            }
        }
        if (!agencyChangedLeads.isEmpty()) {
            removeOldAgencyGroupShares(agencyChangedLeads, oldMap);
            shareLeadsWithAgencyGroup(agencyChangedLeads, null);
        }
    }

    // ─── Share leads with the Public Group that represents Lead.Agency__c ────
    private static void shareLeadsWithAgencyGroup(List<Lead> leads, Object unused) {
        Set<Id> agencyContactIds = new Set<Id>();
        for (Lead ld : leads) {
            if (ld.Agency__c != null) {
                agencyContactIds.add(ld.Agency__c);
            }
        }
        if (agencyContactIds.isEmpty()) { return; }

        // Build developer names and query the corresponding Public Groups
        List<String> groupDevNames = new List<String>();
        for (Id agencyId : agencyContactIds) {
            groupDevNames.add('Agency_' + agencyId.to15());
        }

        List<Group> agencyGroups = [
            SELECT Id, DeveloperName FROM Group
            WHERE DeveloperName IN :groupDevNames
              AND Type = 'Regular'
        ];

        // Map: agencyContactId (15-char) -> Group Id
        Map<String, Id> devNameToGroupId = new Map<String, Id>();
        for (Group g : agencyGroups) {
            devNameToGroupId.put(g.DeveloperName, g.Id);
        }

        List<LeadShare> sharesToInsert = new List<LeadShare>();
        for (Lead ld : leads) {
            if (ld.Agency__c == null) { continue; }
            Id groupId = devNameToGroupId.get('Agency_' + ld.Agency__c.to15());
            if (groupId == null) { continue; }
            sharesToInsert.add(new LeadShare(
                LeadId          = ld.Id,
                UserOrGroupId   = groupId,
                LeadAccessLevel = 'Edit',
                RowCause        = 'Manual'
            ));
        }

        if (!sharesToInsert.isEmpty()) {
            Database.insert(sharesToInsert, false);
        }
    }

    // ─── Remove shares from old agency group before re-sharing ───────────────
    private static void removeOldAgencyGroupShares(List<Lead> leads, Map<Id, Lead> oldMap) {
        Set<Id> oldAgencyContactIds = new Set<Id>();
        Set<Id> leadIds             = new Set<Id>();

        for (Lead ld : leads) {
            Id oldAgency = oldMap.get(ld.Id).Agency__c;
            if (oldAgency != null) {
                oldAgencyContactIds.add(oldAgency);
            }
            leadIds.add(ld.Id);
        }
        if (oldAgencyContactIds.isEmpty()) { return; }

        List<String> oldGroupDevNames = new List<String>();
        for (Id agencyId : oldAgencyContactIds) {
            oldGroupDevNames.add('Agency_' + agencyId.to15());
        }

        List<Group> oldGroups = [
            SELECT Id FROM Group
            WHERE DeveloperName IN :oldGroupDevNames
              AND Type = 'Regular'
        ];

        Set<Id> oldGroupIds = new Set<Id>();
        for (Group g : oldGroups) {
            oldGroupIds.add(g.Id);
        }

        List<LeadShare> sharesToDelete = [
            SELECT Id FROM LeadShare
            WHERE LeadId        IN :leadIds
              AND UserOrGroupId IN :oldGroupIds
              AND RowCause       = 'Manual'
        ];

        if (!sharesToDelete.isEmpty()) {
            Database.delete(sharesToDelete, false);
        }
    }
}
