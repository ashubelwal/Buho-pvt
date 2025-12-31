/*--------------------------------------------------------------------------
* Author: Techila Global Services Pvt Ltd.
* Test Class Name: DeskComCaseTrigger
* Created Date: 23-November-2017
----------------------------------------------------------------------------*/

@isTest
public class DeskComCaseTrigger_Test {

	//Method to cover tasks with lead
	public static testmethod void validateLeadTask(){

	Lead objLead =new Lead();
	objLead.State ='Working';
	objLead.LastName ='test';
	objLead.Company ='test';
	objLead.Email = 'test@demo.com';
	insert objLead;

	Deskcom__Case__c objDeskcom = new Deskcom__Case__c();
	objDeskcom.Deskcom__subject__c='test';
	objDeskcom.Deskcom__status__c = 'Resolved';
	objDeskcom.Deskcom__Lead__c = objLead.id;
	insert objDeskcom; 


	}

	//Method to cover tasks with Contact
	public static testmethod void validateContactTask(){

	Contact objContact = new Contact();
	objContact.FirstName = 'test';
	objContact.LastName = 'Name';
	objContact.Email = 'test@test.com';
	insert objContact;

	Deskcom__Case__c objDeskcom = new Deskcom__Case__c();
	objDeskcom.Deskcom__subject__c='test';
	objDeskcom.Deskcom__status__c = 'Resolved';
	objDeskcom.Deskcom__Contact__c = objContact.id;
	insert objDeskcom; 


	}
}