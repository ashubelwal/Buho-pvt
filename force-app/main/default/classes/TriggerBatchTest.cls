@isTest
public class TriggerBatchTest {
    @isTest
    public static void validateTrigger(){
        Account objAccount = new Account(Name = 'Test Driver', Email__c = 'test@test.com', Username__c = 'test@test.com');
        insert objAccount;
        Contact objContact = new Contact(LastName = 'Test Driver', Email = 'test@test.com');
        insert objContact;
        Driver__C objDriver = new Driver__c(Account_Driver__c = objAccount.Id, Name = 'Test Driver', Dob__c = system.today(), default__c = 'Yes');
        insert objDriver;
        
        objContact.Date_Of_Birth__c = system.today().addDays(-10);
        update objContact;
        objDriver.Dob__c = system.today().addDays(-20);
        update objDriver;
    }
    @isTest
    public static void validateBatch(){
        Account objAccount = new Account(Name = 'Test Driver', Email__c = 'test@test.com', Username__c = 'test@test.com');
        insert objAccount;
        Contact objContact = new Contact(LastName = 'Test Driver', Email = 'test@test.com');
        insert objContact;
        Driver__C objDriver = new Driver__c(Account_Driver__c = objAccount.Id, Name = 'Test Driver', Dob__c = system.today(), default__c = 'Yes');
        insert objDriver;
        
        UpdateBirthdateOnContactBatch objBatch = new UpdateBirthdateOnContactBatch();
        database.executeBatch(objBatch);
    }
}