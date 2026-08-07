// Controller: TestBatchTosendQuoteEmailController
public without sharing class TestBatchTosendQuoteEmailController {

    public String policyId { get; set; }
    public String contactId {get; set;}
    public User userRecord {get; set;}

    public TestBatchTosendQuoteEmailController() {
        userRecord = new User();
    }


    public PageReference runBatch() {

        if(String.isBlank(policyId)) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Please enter Policy Id'
                )
            );
            return null;
        }

        Set<String> policyIds = new Set<String>();
        policyIds.add(policyId);

        Database.executeBatch(
            new BatchTosendQuoteEmail(policyIds),
            1
        );

        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.CONFIRM,
                'Batch started successfully'
            )
        );

        return null;
    }

    public PageReference getContact() {
        List<User> usr = [SELECT Id, Email FROM User WHERE ContactId = :contactId];
        System.debug('@@@USR>>>>>'+usr);
        if(usr.size() >0){
            userRecord = usr[0];
        }
        return null;
    }
}