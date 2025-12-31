@isTest
public class add_attachmentTest {
@isTest
    static void testMethodOne(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;

        List<Quote__c> quoteList = new List<Quote__c>();
        List<Policy__c> policyList = new List<Policy__c>();
        List<Id> policyIds = new List<Id>();

        for (Integer a = 0; a < 2; a++) {
            Quote__c quoteRecord = TestDataService.createQuote(true);
            quoteList.add(quoteRecord);
        }

        for (Integer b = 0; b < quoteList.size(); b++) {
            Policy__c policyRecord = TestDataService.createPolicy(quoteList[b]);
            PolicyList.add(policyRecord);
        }

        for (Integer c = 0; c < policyList.size(); c++) {
            policyIds.add(policyList[c].Id);
        }

        Test.startTest();
        PageReference pageRef = Page.Declaration_Page_Insurance_2;
        pageRef.getParameters().put('id',policyIds[0]);
        Test.setCurrentPage(pageRef);
        add_attachment.sendpolicyid(policyIds);
        add_attachment.attachpdf(policyIds);
/*        Attachment a = new Attachment(parentId ='a0H2i00000YwsV3EAJ' , name='test' + '.pdf', body = Blob.valueof('Some random String'));*/
        //Attachment a = new Attachment(parentId = policyIds[0] , name=policyList[0].name + '.pdf', body = Blob.valueof('Some random String'));
        //insert a;
        Test.stopTest();
    }
}