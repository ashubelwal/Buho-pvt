@isTest
public class TestupdatePolicy {
    Public Static testmethod void testforupdate(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;
    Account a = new Account();
    a.Name='test';
    insert a;
    
    Policy__c p = new Policy__c ();
    p.Account_Policy__c=a.id;
    p.Name='637428';
    p.Term__c='semi';
    insert p;
        
     Policy__c p2 = new Policy__c ();
    p2.Account_Policy__c=a.id;
    p2.Name='637428';
    p2.Term__c='daily';
    insert p2;
        
         Policy__c p21 = new Policy__c ();
    p21.Account_Policy__c=a.id;
    p21.Name='637428';
    p21.Term__c='daily';
    insert p21;
    }
}