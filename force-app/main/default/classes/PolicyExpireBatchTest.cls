@isTest 
public class PolicyExpireBatchTest {
    @isTest 
    static void TestMethodOne(){
      TriggerSwitch__c  triggerSwitchRecord = new TriggerSwitch__c();
      triggerSwitchRecord.Active__c = true;
      triggerSwitchRecord.Name = 'PolicyTrigger';
      insert triggerSwitchRecord;
        List<Policy__c> policyList = new  List<Policy__c>(); 
        for(integer i=0; i<100; i++){
             Policy__c plcy = new Policy__c();
             plcy.Name ='test'+i;
             plcy.Status_picklist__c='Active';
             plcy.End_Date__c= system.today()+i; 
            policyList.add(plcy);
         }
        insert policyList;
            Test.startTest();
            PolicyExpireBatch obj = new PolicyExpireBatch();
            DataBase.executeBatch(obj); 
           Test.stopTest();
    }

}