@isTest
public class CustomErrorExceptionHandlerExceptionTest {
    @isTest
    public static void testmethodPostive(){
        try{
            contact con = new Contact();
        con.FirstName = 'test';
        
        insert con;
        }catch(Exception ex){
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        
        
    }
    @IsTest
    public static void testLwcErrorLogs(){
        CustomErrorExceptionHandlerException.logClientError('Test','Test','Test','Test','Test','Test');
    }

}