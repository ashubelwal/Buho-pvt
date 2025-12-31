@isTest
public class PopulatePaymentDetailClassbatchTest {
 @isTest
    public static void testMethodClass(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
         Test.startTest();
        PopulatePaymentDetailClassbatch ba= new PopulatePaymentDetailClassbatch();
        Id jobid= Database.executeBatch(ba,5);
        
        Test.stopTest();
    }
    @isTest
    public static void testMethod1() {
       
        Test.StartTest();
		PopulatePaymentDetailClassbatch testsche = new PopulatePaymentDetailClassbatch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
    }
    @isTest
    public static void testMethodClass2(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
         Test.startTest();
      PopulateSchedule.PopulateScheduleMethod();
        
        Test.stopTest();
    }
}