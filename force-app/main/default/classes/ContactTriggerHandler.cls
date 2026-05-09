public without sharing class ContactTriggerHandler {

    public static void onAfterInsert(List<Contact> newContacts) {
        createAgencyGroups(newContacts);
    }

    public static void updateLeadData(Map<Id, Contact> condataMap) {
        try {
            if (condataMap.size() > 0) {
                Set<Id> contactIdSet = condataMap.keySet();
                List<Lead> leaddata = [
                    SELECT LastName, FirstName, Phone, Email, ConvertedContactId, Geographic_State_of_Interest__c
                    FROM Lead
                    WHERE ConvertedContactId IN :contactIdSet
                ];
                List<Lead> updatedLeadData = new List<Lead>();
                Boolean updated = false;
                for (Lead ld : leaddata) {
                    Contact con = condataMap.get(ld.ConvertedContactId);

                    if (ld.Geographic_State_of_Interest__c != con.Policy_Destinations__c && con.Policy_Destinations__c != null) {
                        ld.Geographic_State_of_Interest__c = con.Policy_Destinations__c;
                        updated = true;
                    }
                    if (ld.FirstName != con.FirstName) { ld.FirstName = con.FirstName; updated = true; }
                    if (ld.LastName  != con.LastName)  { ld.LastName  = con.LastName;  updated = true; }

                    if      (ld.Phone == null && con.Phone != null)                              { ld.Phone = con.Phone; updated = true; }
                    else if (ld.Phone != null && con.Phone != null && ld.Phone != con.Phone)     { ld.Phone = con.Phone; updated = true; }
                    else if (ld.Phone != null && con.Phone == null)                              { ld.Phone = con.Phone; updated = true; }

                    if      (ld.Email == null && con.Email != null)                              { ld.Email = con.Email; updated = true; }
                    else if (ld.Email != null && con.Email != null && ld.Email != con.Email)     { ld.Email = con.Email; updated = true; }
                    else if (ld.Email != null && con.Email == null)                              { ld.Email = con.Email; updated = true; }

                    if (updated) { updatedLeadData.add(ld); }
                    updated = false;
                }
                if (!updatedLeadData.isEmpty()) {
                    Database.update(updatedLeadData);
                }
            }
        } catch (Exception e) {
            System.debug('Exception in updateLeadData at line ' + e.getLineNumber() + ': ' + e.getMessage());
        }
    }

    // ─── Public: create a Public Group per Agency RT contact ────────────────
    public static void createAgencyGroups(List<Contact> contacts) {
        Id agencyRTId = getAgencyRecordTypeId();
        List<Group> groupsToInsert = new List<Group>();

        for (Contact con : contacts) {
            if (con.RecordTypeId == agencyRTId) {
                groupsToInsert.add(new Group(
                    Name          = (con.FirstName + ' ' + con.LastName).trim(),
                    DeveloperName = 'Agency_' + con.Id.to15(),
                    Type          = 'Regular'
                ));
            }
        }
        if (groupsToInsert.isEmpty()) { return; }
        insert groupsToInsert;
    }

    // ─── Helper: single Agency RT Id via Schema describe (no SOQL) ───────────
    private static Id getAgencyRecordTypeId() {
        Schema.RecordTypeInfo rti = Schema.SObjectType.Contact
            .getRecordTypeInfosByName()
            .get('Agency RT');
        return rti != null ? rti.getRecordTypeId() : null;
    }
}