@istest
public class AccountHelperTest 
{
	@istest 
    public static void testFormatPhoneNumber()
    {
        Account acc = new Account (Name = 'Test1' + system.now());
        insert acc;
        
        acc.Phone = '7604022704';
        update acc;
        
        acc.Phone = '+17604022704';
        update acc;
        
        acc.Phone = '+50487326045';
        update acc;
        
    }
    
    @istest
    public static void testFormatPhone() {
        Test.startTest();
        String resp = AccountHelper.formatPhone('7604022704');
        String resp2 = AccountHelper.formatPhone('+50487326045');
        Test.stopTest();
    }
    
    @istest 
    public static void testFormatPhoneNumber2()
    {
     Account acc = new Account (Name = 'Test' + system.now(), country__c = 'US');
        insert acc;
        
        acc.Phone = '7604022704';
        update acc;
        
        acc.Phone = '+17604022704';
        update acc;
        
        acc.Phone = '+50487326045';
        update acc;
    }
    
    @isTest
    public static void validateTransactionTrigger(){
        //Create account record
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        insert objAccount;
        
        //Create account record
        Account objAccount2 = new Account();
        objAccount2.Name = 'Test';
        objAccount2.ParentId = objAccount.Id;
        insert objAccount2;
       
        //Create Transaction record
        Transaction__c objTransaction = new Transaction__c();
        objTransaction.Name = '12345';
        objTransaction.Account_Transaction__c = objAccount.Id;
        objTransaction.Amount__c = 900;
        objTransaction.Created_At__c = system.now();
        insert objTransaction;
        
        //Create Transaction record
        Transaction__c objTransaction2 = new Transaction__c();
        objTransaction2.Name = '12345';
        objTransaction2.Account_Transaction__c = objAccount.Id;
        objTransaction2.Amount__c = 800;
        objTransaction2.Created_At__c = system.now();
        insert objTransaction2;
        
        //Create Transaction record
        Transaction__c objTransaction21 = new Transaction__c();
        objTransaction21.Name = '12345';
        objTransaction21.Account_Transaction__c = objAccount.Id;
        objTransaction21.Amount__c = 700;
        objTransaction21.Created_At__c = system.now();
        insert objTransaction21;
        
        //Create Transaction record
        Transaction__c objTransaction22 = new Transaction__c();
        objTransaction22.Name = '12345';
        objTransaction22.Account_Transaction__c = objAccount2.Id;
        objTransaction22.Amount__c = 600;
        objTransaction22.Created_At__c = system.now();
        insert objTransaction22;
        
        Test.startTest();
        objTransaction21.Account_Transaction__c = objAccount2.Id;
        update objTransaction21;
        
        objAccount2.ParentId = null;
        update objAccount2;
        
        objAccount2.ParentId = objAccount.Id;
        update objAccount2;
        
        delete objAccount2;
        
        delete objTransaction;
        
        undelete objTransaction;
        test.stopTest();
    }
}