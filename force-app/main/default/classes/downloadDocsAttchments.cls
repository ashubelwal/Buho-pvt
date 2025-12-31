public without sharing class  downloadDocsAttchments {
    @AuraEnabled
    public static List<Attachment> downloadDocs(){
        List<Attachment> allAttachment = [SELECT Id, Name, Body, BodyLength, ContentType, CreatedDate FROM Attachment Where ParentId = 'a0H6R00000pcPXlUAM' Order by CreatedDate Desc];
    	return allAttachment;
    }
}