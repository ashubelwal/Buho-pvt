@isTest
public class PolicyTriggerHandlerTest
{
   static testMethod void TestContactUpdate()
   {
   
     TriggerSwitch__c  tr = new TriggerSwitch__c ();
       tr.Name='PolicyTrigger';
       tr.Active__c= true;
       insert tr;
   
     	Account act = new Account();
       act.name='Test Insurance Account';
       act.Email__c='sks18889@gmail.com';
       insert act;
       
       Contact newContact = new Contact();
       newContact.LastName = 'ABC Insurance Contact';
       newContact.AccountId = act.Id;
       insert newContact;
       
       Driver__c newDriver = new Driver__c();
       newDriver.Name = 'ABC';
       newDriver.First_Name__c = 'ABC';
       newDriver.Last_Name__c = 'DEF';
       newDriver.Phone__c = '123456789';
       newDriver.Email__c = 'sks18889@gmail.com';
       newDriver.Address__c = 'Blue Street';
       newDriver.Address_Line_2__c = 'Downtown Road';
       newDriver.City__c = 'California';
       newDriver.Country__c = 'US';
       newDriver.Postal_Code__c = '12345';
       newDriver.State_Province__c = 'New State';
       newDriver.Contact__c = newContact.Id;
       newDriver.Driver_Type__c = 'Owner & Driver';
       insert newDriver;
       
       Test.startTest();
       Policy__c policy = new Policy__c();
       policy.Name = 'test policy';
       policy.Account_Policy__c= act.id;
       policy.Contact__c = newContact.Id;
       policy.Underwriter_picklist__c = 'Chubb';
       policy.Policy_Type_picklist__c = 'Northbound';
       insert policy;
       
       Policy__c policy2 = new Policy__c();
       policy2.Name = 'test policy2';
       policy2.Account_Policy__c= act.id;
       policy2.Contact__c = newContact.Id;
       policy2.Underwriter_picklist__c = 'Chubb';
       policy2.Policy_Type_picklist__c = 'Watercraft';
       insert policy2;
       
       Policy__c policy3 = new Policy__c();
       policy3.Name = 'test policy3';
       policy3.Account_Policy__c= act.id;
       policy3.Contact__c = newContact.Id;
       policy3.Underwriter_picklist__c = 'Chubb';
       policy3.Policy_Type_picklist__c = 'Automobile';
       insert policy3;
       Test.stopTest();
   }

}