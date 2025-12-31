public class TaskTriggerHandler {
	
	public static void sendEmailAlert(List<Task> taskList){
		
		Set<String> leadIds = new Set<String>();
		Set<String> contactIds = new Set<String>();
		for(Task objTask : taskList){
			if(string.valueof(objTask.WhoId.getSObjectType()) == 'Lead'){
				leadIds.add(objTask.WhoId);
			}
			if(string.valueof(objTask.WhoId.getSObjectType()) == 'Contact'){
				contactIds.add(objTask.WhoId);
			}
		}
		EmailTriggerUtility.sendEmail(leadIds, contactIds);
	}
		
		/*List<Lead> leadList = new List<Lead>([SELECT Id,Name,Email FROM Lead WHERE Id IN: leadIds AND Email != null]);
		List<Contact> contactList = new List<Contact>([SELECT Id,Name,Email FROM Contact WHERE Id IN: contactIds AND Email != null]);
		
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		List<EmailTemplate> postServiceETList = new List<EmailTemplate>([SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = 'Post Service Template']);
		
		for(Lead objLead : leadList){
			List<String> toAddresses = new List<String>();
			if(objLead.Email != null && objLead.Email != ''){
				toAddresses.add(objLead.Email);
			}
			if(toAddresses.size() > 0){
				System.debug('From Lead');
				Messaging.SingleEmailMessage mail = createEmail(toAddresses,postServiceETList[0],objLead,null);
				emails.add(mail);
			}
		}
		for(Contact objContact : contactList){
			List<String> toAddresses = new List<String>();
			if(objContact.Email != null && objContact.Email != ''){
				toAddresses.add(objContact.Email);
			}
			if(toAddresses.size() > 0){
				System.debug('From Contact');
				Messaging.SingleEmailMessage mail = createEmail(toAddresses,postServiceETList[0],null,objContact);
				emails.add(mail);
			}
		}
		
		//Send email 
        if(emails.size()>0){
            //Messaging.sendEmail(emails);
		}
        
	}
	
	public static Messaging.SingleEmailMessage createEmail(List<String> toAddresses,EmailTemplate postServiceET,Lead objLead,Contact objContact){
		Messaging.SingleEmailMessage mesg;
		if(objLead != null){
			System.debug('From Lead');
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			String htmlBody = postServiceET.HtmlValue;
			htmlBody = htmlBody.replace('{!Lead.Name}',objLead.Name);
			htmlBody = htmlBody.replace('{!Contact.Name}','');
			htmlBody = htmlBody.replace('{!Lead.Id}',objLead.Id);
			htmlBody = htmlBody.replace('{!Contact.Id}','');
			
			String plainBody = postServiceET.Body;
			plainBody = plainBody.replace('{!Lead.Name}',objLead.Name);
			plainBody = plainBody.replace('{!Contact.Name}','');
			
			System.debug('email address array '+toAddresses);
			mail.setToAddresses(toAddresses);
			mail.setSubject(postServiceET.Subject);
			mail.setHtmlBody(htmlBody);
			System.debug('HTML Body->'+htmlBody);
			mail.setPlainTextBody(plainBody);
			System.debug('Body->'+plainBody);
			mail.setSaveAsActivity(false);
			return mail;
		}else if(objContact != null){
			System.debug('From Contact');
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			String htmlBody = postServiceET.HtmlValue;
			htmlBody = htmlBody.replace('{!Contact.Name}',objContact.Name);
			htmlBody = htmlBody.replace('{!Lead.Name}','');
			htmlBody = htmlBody.replace('{!Contact.Id}',objContact.Id);
			htmlBody = htmlBody.replace('{!Lead.Id}','');
			
			String plainBody = postServiceET.Body;
			plainBody = plainBody.replace('{!Contact.Name}',objContact.Name);
			plainBody = plainBody.replace('{!Lead.Name}','');
			
			System.debug('email address array '+toAddresses);
			mail.setToAddresses(toAddresses);
			mail.setSubject(postServiceET.Subject);
			mail.setHtmlBody(htmlBody);
			System.debug('HTML Body->'+htmlBody);
			mail.setPlainTextBody(plainBody);
			System.debug('Body->'+plainBody);
			mail.setSaveAsActivity(false);
			return mail;
		}
		return null;
		
	}*/
}