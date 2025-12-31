@isTest
public class TranscationUpdateOnceBatch_Test {
    
    static testMethod void testMethod1(){
        Account objacc = new Account();
        objacc.Name = 'TEST ACC';
        
        insert objacc;
            
        List<Transaction__c> transacList = new List<Transaction__c>();
        
        Transaction__c  objTransac = new Transaction__c();
        objTransac.Name = 'Test1';
        objTransac.Account_Transaction__c = objacc.id;
        objTransac.Amount__c = 100;
        objTransac.Created_At__c = System.today()+1;
        objTransac.Updated_At__c = System.today()+500;
        transacList.add(objTransac);
        
        Transaction__c  objTransac1 = new Transaction__c();
        objTransac1.Name = 'Test2';
        objTransac1.Account_Transaction__c = objacc.id;
        objTransac1.Amount__c = 100;
        objTransac1.Created_At__c = System.today()+2;
        objTransac1.Updated_At__c = System.today()+300;
        transacList.add(objTransac1);
        
        insert transacList;
        
        test.startTest();
        System.schedule('Test CRON1', '0 0 12 1 1 ? *', new ScheduleTranscationUpdateOnceBatch());
        test.stopTest();
        
    }

}