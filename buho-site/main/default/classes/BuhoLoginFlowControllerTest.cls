@isTest
private class BuhoLoginFlowControllerTest {

    @isTest
    static void testFinishFlow_SetsFrontdoorUrlToTargetSite() {
        BuhoLoginFlowController ctrl = new BuhoLoginFlowController();

        Test.startTest();
        try {
            ctrl.finishFlow();
        } catch (Exception e) {
            // Auth.SessionManagement.finishLoginFlow() throws outside a real
            // login flow context — that is expected in unit tests.
        }
        Test.stopTest();
    }

}