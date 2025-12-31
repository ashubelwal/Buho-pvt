trigger AuthorizeNetEventTrigger on Authorize_Net_Log_Event__e (after insert) {

    AuthorizeNetEventTriggerHandler.handleAfterInsert(Trigger.new);
}