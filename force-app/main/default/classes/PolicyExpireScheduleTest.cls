@isTest
public class PolicyExpireScheduleTest {
    @IsTest
    public static void testschedule() {
        Test.StartTest();
        PolicyExpireSchedule policyBatch = new PolicyExpireSchedule();
        
        String sch = '0 0 23 * * ?';
        
        system.schedule('Test Territory Check', sch, policyBatch);
        
        Test.stopTest();
    
    }
}