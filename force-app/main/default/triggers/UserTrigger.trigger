trigger UserTrigger on User (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            if (SiteUserController.stopUserTrigger) {
                System.debug('Inside trigger if');
                UserTriggerHandler.updatePromoCode(Trigger.new);
            }
        }
        // Add portal users to their agency's Public Group on creation
        if (Trigger.isInsert) {
            UserTriggerHandler.addUsersToAgencyGroup(Trigger.new);
        }
    }
}