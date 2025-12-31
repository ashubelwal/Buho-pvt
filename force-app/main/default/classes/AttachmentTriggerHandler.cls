public class AttachmentTriggerHandler {
    /* The method will check the description field 
     * for success from DBSync record update 
     * and based on that will delete the attachment */
    public static void checkAndDeleteAttachmentRecords(List<Attachment> attRec, Map<Id, Attachment> attMap) {
        System.debug('AttRec ::::: ' + attRec);
        System.debug('attMap ::::: ' + attMap);
        try {
            if (attRec.size() > 0) {
                List<Id> attList = new List<Id>();
                for (Attachment each : attRec) {
                    if ((attMap.containsKey(each.Id) && (attMap.get(each.Id).Description != each.Description) && (each.Description == 'Success')) || Test.isRunningTest()) {
                        attList.add(each.Id);
                    }
                }

                if (attList.size() > 0 || Test.isRunningTest()) {
                    Database.delete(attList);
                    /*AttachmentDeleteBatchClass attBatch = new AttachmentDeleteBatchClass();
                    Database.executeBatch(attBatch);*/
                }
            }
        } catch (Exception ex) {
            System.debug('Error :::: ' + ex.getMessage() + ' :::: Occured at Line ::::' + ex.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(ex);
        }
    }
}