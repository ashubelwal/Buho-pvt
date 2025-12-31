@isTest
public class Mex_LogACaseHandlerTest {
@isTest 
    public static void testMethodPostive(){
        Test.startTest();
        Mex_LogACaseHandler.getCaseTypeCustomSettings();
        Mex_LogACaseHandler.createLogACaseMethod('New', 'test', 'test@gmail.com');
         Mex_LogACaseHandler.createLogACaseMethod(Null, Null, Null);
        Mex_LogACaseHandler.checkCommunityUserAndFetchDetails();
        Mex_LogACaseHandler.fetchAllCaseRealtedContact();
        Test.stopTest();
    }
}