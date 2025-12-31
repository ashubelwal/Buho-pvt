trigger Policy_Trigger on Policy__c (after insert, after update, after delete, after undelete , before insert) {
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUndelete){
            PolicyTrigger_Handler.ManagePolicy(trigger.new, null);
            
        }
        if(trigger.isUpdate){
            System.debug('Reached in trigger IsUPdate');
            PolicyTrigger_Handler.ManagePolicy(trigger.new, trigger.oldMap);
            PolicyTrigger_Handler.updateContactDestionations(trigger.new);
        }
        if(trigger.isDelete){
            PolicyTrigger_Handler.ManagePolicy(trigger.old, null);
        }

        if( trigger.isInsert ){
            system.debug('trigger.isInsert : '+ trigger.new);
            PolicyTrigger_Handler.updatePolicyId(trigger.new);
            PolicyTrigger_Handler.sendPolicyEmail(trigger.new);
            PolicyTrigger_Handler.updateContactDestionations(trigger.new);

        }
    }
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('Reached in trigger');
            // Update the Agent And Agency for the policies
            Id currentUserId = UserInfo.getUserId();
            User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
            String profileName = currentUser.Profile.Name;
            if(profileName == 'Mex Insurance Customer Community Plus Login User' || profileName == 'MexInsurance Profile' || profileName == 'Mexinsurance Customer community Profile' ) {
                PolicyTrigger_Handler.updateAgentAgency(trigger.new);
            }

            
    }
}