trigger ContactTrigger on Contact (after insert, after update, before delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        ContactTriggerHandler.onAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.updateLeadData(Trigger.newMap);
    }
}