@isTest
public class DriverLicenceFlowControllerTest {
    @isTest
    static void methodOne(){
        DriverLicenceFlowController.getInitData('Driver License');
        DriverLicenceFlowController driver = new DriverLicenceFlowController();
         DriverLicenceFlowController.getCurrentUser();
        // driver.DriverLicenseFlowData();
        DriverLicenceFlowController.createTransactionAction('Test','Test');
         Quote__c data=TestDataService.createQuote(true);  
       // DriverLicenceFlowController.updatePolicyAction(TestDataService.createContact(true),TestDataService.createPolicy(data),TestDataService.createQuote(true).Id,TestDataService.createQuote(true).Id);
        // DriverLicenceFlowController.retrieveAffiliateAccount('123456');
    }
}