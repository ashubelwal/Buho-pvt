@IsTest
public class TestBatchTosendQuoteEmailControllerTest {

    @IsTest
    static void testRunBatch() {

        // Create test controller instance
        TestBatchTosendQuoteEmailController controller =
            new TestBatchTosendQuoteEmailController();

        controller.policyId = 'a001234567890ABC';

        Test.startTest();

        controller.runBatch();
        try{
            controller.getContact();
        } catch(exception ex){}

        Test.stopTest();
    }

    @IsTest
    static void testRunBatch_BlankPolicyId() {

        TestBatchTosendQuoteEmailController controller =
            new TestBatchTosendQuoteEmailController();

        controller.policyId = '';

        Test.startTest();

        PageReference result = controller.runBatch();

        Test.stopTest();
    }
}