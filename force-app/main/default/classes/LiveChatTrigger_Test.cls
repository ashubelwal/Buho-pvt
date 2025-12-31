/*--------------------------------------------------------------------------
	* Author: Techila Global Services Pvt Ltd.
	* Test Class Name: LiveChatTrigger_Test
	* Created Date: 23-November-2017
	----------------------------------------------------------------------------*/

	@isTest
	public class LiveChatTrigger_Test {

	public static testmethod void LiveChatTriggertest(){

	Contact objcontact =new Contact();
	objcontact.FirstName = 'Test';
	objcontact.LastName = 'Name';
	objcontact.Phone = '1-555-555-55-55';
	objcontact.Email = 'email@sample.com';
	insert objcontact;

	Lead objLead =new Lead();
	objLead.State ='Working';
	objLead.LastName ='test';
	objLead.Company ='test';       
	insert objLead;

	LiveChat_transcript__c objLiveChat_transcript = new LiveChat_transcript__c();
	objLiveChat_transcript.Lead__c = objLead.Id; 
	objLiveChat_transcript.Contact__c = objcontact.Id;
	objLiveChat_transcript.LiveChat_Chat_Id__c = 'test';
	insert objLiveChat_transcript;


	}


	}