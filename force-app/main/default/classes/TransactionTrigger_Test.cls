@isTest
public class TransactionTrigger_Test {
    @isTest
    public static void validateTransactionTrigger(){
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        insert objAccount;
        
        Account objAccount2 = new Account();
        objAccount2.Name = 'Test';
        objAccount2.ParentId = objAccount.Id;
        insert objAccount2;
       
        Transaction__c objTransaction = new Transaction__c();
        objTransaction.Name = '12345';
        objTransaction.Account_Transaction__c = objAccount.Id;
        objTransaction.Amount__c = 900;
        objTransaction.Created_At__c = system.now();
        insert objTransaction;
        
        Transaction__c objTransaction2 = new Transaction__c();
        objTransaction2.Name = '12345';
        objTransaction2.Account_Transaction__c = objAccount.Id;
        objTransaction2.Amount__c = 800;
        objTransaction2.Created_At__c = system.now();
        insert objTransaction2;
        
        Transaction__c objTransaction21 = new Transaction__c();
        objTransaction21.Name = '12345';
        objTransaction21.Account_Transaction__c = objAccount.Id;
        objTransaction21.Amount__c = 700;
        objTransaction21.Created_At__c = system.now();
        insert objTransaction21;
        
        Transaction__c objTransaction22 = new Transaction__c();
        objTransaction22.Name = '12345';
        objTransaction22.Account_Transaction__c = objAccount2.Id;
        objTransaction22.Amount__c = 600;
        objTransaction22.Created_At__c = system.now();
        insert objTransaction22;
        
        objTransaction21.Account_Transaction__c = objAccount2.Id;
        update objTransaction21;
        
        delete objTransaction;
        
        undelete objTransaction;
    }
}