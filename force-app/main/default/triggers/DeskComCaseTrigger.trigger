trigger DeskComCaseTrigger on Deskcom__Case__c (after insert, after update) {
	List<Deskcom__Case__c> deskCaseList = new List<Deskcom__Case__c>();
	for(Deskcom__Case__c objDeskCase : trigger.new){
		if(objDeskCase.Deskcom__status__c == 'Resolved' || objDeskCase.Deskcom__status__c == 'Closed'){
			deskCaseList.add(objDeskCase);
		}
	}
	
	if(deskCaseList.size() > 0){
		DeskComCaseTriggerHandler.sendEmailAlert(deskCaseList);
	}
}