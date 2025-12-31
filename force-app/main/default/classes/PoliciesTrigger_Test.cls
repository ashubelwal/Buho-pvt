/*--------------------------------------------------------------------------
* Author: Techila Global Services Pvt Ltd.
* Test Class Name: PoliciesTrigger_Test
* Created Date: 23-November-2017
----------------------------------------------------------------------------*/

@isTest
public class PoliciesTrigger_Test {
	public static testmethod void PolicyRenewalEmailAlerttest(){
		Account objAccount =new Account();
		objAccount.Name = 'test';
		objAccount.Email__c = 'test@test.com';
        objAccount.Created_At__c = System.today();
		insert objAccount;
		
		Contact objcontact =new Contact();
		objcontact.FirstName = 'Test';
		objcontact.LastName = 'Name';
		objcontact.Phone = '1-555-555-55-55';
		objcontact.Email = 'email@sample.com';
		insert objcontact;
	  	
        TriggerSwitch__c objTriggerSwitch = new TriggerSwitch__c();
        objTriggerSwitch.Name = 'PolicyTrigger';
        insert objTriggerSwitch;
        
		Policy__c objPolicy =new Policy__c();
		objPolicy.Name = 'test';
		//objPolicy.Contact__c = objcontact.Id;
		objPolicy.Account_Policy__c = objAccount.Id;
		objPolicy.End_at__c=system.today();        	
		insert objPolicy;     
        
        Policy__c objPolicy1 =new Policy__c();
		objPolicy1.Name = 'test';
		objPolicy1.Contact__c = objcontact.Id;
		objPolicy1.Account_Policy__c = objAccount.Id;
	    objPolicy1.End_at__c=system.today();        	
		insert objPolicy1;  
		
	}    
}