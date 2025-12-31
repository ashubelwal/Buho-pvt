trigger AttachmentTrigger on Attachment (after update) {
    Switch on Trigger.operationType {
        When AFTER_UPDATE {
            AttachmentTriggerHandler.checkAndDeleteAttachmentRecords(Trigger.new, Trigger.oldMap);
        }
    }
}