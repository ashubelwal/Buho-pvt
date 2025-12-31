global class AttachmentDeleteBatchClass implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       // String query = 'SELECT Id FROM Attachment WHERE Description = \'Success\' AND ParentID='a0H6R00000pcPXlUAM'';
        return Database.getQueryLocator([SELECT Id FROM Attachment WHERE Description = 'Success']);
    }

    global void execute(Database.BatchableContext BC, List<Attachment> scope)
    {
        system.debug('scope--'+scope);
        Database.delete(scope);
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}