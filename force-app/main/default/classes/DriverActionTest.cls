@isTest
public class DriverActionTest {
    Public static testMethod void DriverAction(){
        test.startTest();
        Driver__c driver = new Driver__c();
        driver.License_Country__c = 'testcountry';
        driver.License_state__c ='teststate';
        driver.license_number__c ='testlicense number';
         insert driver;
        test.stopTest();
    }
}