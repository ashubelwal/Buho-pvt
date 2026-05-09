trigger LeadTrigger on Lead (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        LeadTriggerHandler.onAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        LeadTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
