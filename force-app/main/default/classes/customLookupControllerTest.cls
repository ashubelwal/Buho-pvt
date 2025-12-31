@IsTest
public class customLookupControllerTest { 
    @testSetup static void methodName() {
        Account acc = new Account(Name='University',phone='9898989');
        insert acc;
        Address__c add = new Address__c(Postal_code__c = '99950',Name = 'United States', city__c = 'Test', state__c  = 'Test');
        insert add;
    }
    
    @IsTest
    public static void lookupTest(){
        Address__c add = [Select Id, Name, Postal_code__c from Address__c];
        Test.startTest();
        customLookupController.lookup('Address__c', '99', 'City__c', 'Name', 10, '', '', '99950', 'Test', 'Test');
        CustomObjectLookupController.lookup('Address__c', '99', 'City__c', '', 10, '', '');
        Test.stopTest();
    }
    @IsTest
    public static void lookupTest1(){
        Address__c add = [Select Id, Name, Postal_code__c from Address__c];
        Test.startTest();
        customLookupController.lookup('Address__c', '99', 'Postal_code__c', '', 10, '', '', '99950', 'Test', 'Test');
        CustomObjectLookupController.lookup('Address__c', '99', 'Postal_code__c', '', 10, '', '');
        
        Test.stopTest(); 
    }
    
    @IsTest
    public static void lookupTest2(){
        Account acc = [Select Id, Name,Phone from Account];
        Test.startTest();
        customLookupController.lookup('Account', '', 'phone', '', 10, '', '', '99950', 'Test', 'Test');
        CustomObjectLookupController.lookup('Account', '', 'phone', '', 10, '', '');
        Test.stopTest();
    }
    @IsTest
    public static void lookupTest3(){
        Account acc = [Select Id, Name,Phone from Account];
        Test.startTest();
        customLookupController.lookup('Account', 'Uni', 'phone', '', 10, '', '', '99950', 'Test', 'Test');
        CustomObjectLookupController.lookup('Account', 'Uni', 'phone', '', 10, '', '');
        Test.stopTest();
    }
    
    @IsTest
    public static void lookupTest4(){
        Address__c add = [Select Id, Name, Postal_code__c from Address__c];
        Test.startTest();
        customLookupController.lookup('Address__c', 'Test', 'State__c', '', 10, '','','99950', 'Test', 'Test');
        CustomObjectLookupController.lookup('Address__c', 'Test', 'State__c', '', 10, '', '');
        Test.stopTest(); 
    }
}