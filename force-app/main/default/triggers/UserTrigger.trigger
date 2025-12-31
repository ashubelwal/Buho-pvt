trigger UserTrigger on User (after insert,after update) {
    if(Trigger.IsAfter){
        if(Trigger.IsInsert || Trigger.IsUpdate){
            if (SiteUserController.stopUserTrigger) {
                System.debug('Inside trigger if');
                UserTriggerHandler.updatePromoCode(Trigger.New);
            }
        }
    }
    /*if(Trigger.IsAfter && trigger.isAfter ){
        List<Messaging.SingleEmailMessage> welcomeEmails = new 
                List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> welcomeEmailTemplates = [SELECT Id FROM EmailTemplate 
                WHERE DeveloperName = 'Community_Welcome_Email_VF' LIMIT 1];
        
        for(User usr: trigger.new ){
            System.resetPassword(usr.Id, true);
			Messaging.SingleEmailMessage welcomeEmailMessage = Messaging.renderStoredEmailTemplate(welcomeEmailTemplates[0].Id, 
                        usr.Id, null);
			String [] toAddresses = new String[]{usr.Email};
			welcomeEmailMessage.setToAddresses(toAddresses);
			welcomeEmails.add(welcomeEmailMessage);
		}
        if(!welcomeEmails.isEmpty()){
                        //Sending out our custom welcome emails
			Messaging.sendEmail(welcomeEmails);
		}
    }*/
}