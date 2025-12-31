@isTest
public class GenerateTextFileBatchScheduler_Test {
     @isTest
	public static void testschedule() {
		Test.StartTest();
		GenerateTextFileBatchScheduler testsche = new GenerateTextFileBatchScheduler();
		String sch = '0 5 0 1/1 * ? *';
		system.schedule('Test status Check', sch, testsche);
		Test.stopTest();
	}
}