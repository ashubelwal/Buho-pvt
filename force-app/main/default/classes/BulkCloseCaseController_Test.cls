@isTest
public class BulkCloseCaseController_Test {
    @isTest
    public static void ValidateTest(){
        List<Case> objCaseList = new List<Case>();
        
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        Contact objContact = new contact(LastName = 'Testing', AccountId = objAccount.Id);
        insert objContact;
        Case objCase = new Case(AccountId = objAccount.Id, ContactId = objContact.Id);
        objCaseList.add(objCase);
        
        insert objCaseList;
        
        test.startTest();
            Test.setCurrentPage(Page.BulkCloseCase);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(objCaseList);
            stdSetController.setSelected(objCaseList);
            BulkCloseCaseController objBulkCloseCaseController = new BulkCloseCaseController(stdSetController);
        	objBulkCloseCaseController.UpdateStatusToClose();
        test.stopTest();
        
    }
}