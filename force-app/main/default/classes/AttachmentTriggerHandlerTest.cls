@isTest
public class AttachmentTriggerHandlerTest {
    @isTest static void updateAttachmentRecordTest() {
        // Switch off PolicyTrigger
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        Quote__c qtRec = TestDataService.createQuote(true);
        Policy__c polRec = TestDataService.createPolicy(qtRec);

        Attachment newAtt = new Attachment();
        newAtt.Name = 'test attachment';
        newAtt.Body = Blob.valueOf('Test body data');
        newAtt.ParentId = polRec.Id;

        Test.startTest();
        insert newAtt;

        if (newAtt.Id != null) {
            newAtt.Description = 'Success';
            update newAtt;
        }
        Test.stopTest();
    }
}