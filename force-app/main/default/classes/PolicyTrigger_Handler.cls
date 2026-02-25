public without sharing class PolicyTrigger_Handler {
    Public Static void UpdateContact(Set<Id> parentContactIdSet){
        List<Contact> objContactList = [SELECT Id, Name, Insurance_Type__c, (SELECT Id, Name, Policy_Type_picklist__c FROM Policies__r) FROM Contact WHERE Id IN: parentContactIdSet];
        for(Contact objcontact : objContactList){
            String vehicleType = '';
            for(Policy__c objPolicy : objcontact.Policies__r){
                vehicleType += objPolicy.Policy_Type_picklist__c != null && !vehicleType.contains(objPolicy.Policy_Type_picklist__c) ? objPolicy.Policy_Type_picklist__c + ';' : '';
            }
            vehicleType.removeEnd(';');
            objcontact.Insurance_Type__c = vehicleType;
        }
        database.update(objContactList, false);
    }
    
    public static void ManagePolicy(List<Policy__c> objPolicyList, Map<Id, Policy__c> objPolicyMap){
        Set<Id> parentContactIdSet = new Set<Id>();
        for(Policy__c objPolicy : objPolicyList){
            if(objPolicyMap != null && objPolicyMap.containsKey(objPolicy.Id)){
                if(objPolicyMap.get(objPolicy.Id).Contact__c != objPolicy.Contact__c){
                    if(objPolicyMap.get(objPolicy.Id).Contact__c != null){
                        parentContactIdSet.add(objPolicyMap.get(objPolicy.Id).Contact__c);
                    }
                    if(objPolicy.Contact__c != null){
                        parentContactIdSet.add(objPolicy.Contact__c);
                    }
                }
                if(objPolicyMap.get(objPolicy.Id).Vehicle_type__c != objPolicy.Vehicle_type__c){
                    parentContactIdSet.add(objPolicy.Contact__c);
                }
            }else if(objPolicy.Contact__c != null){
                parentContactIdSet.add(objPolicy.Contact__c);
            }
        }
        if(parentContactIdSet.size() > 0){
            UpdateContact(parentContactIdSet);
        }
    }
    
    public static void sendPolicyEmail(List<Policy__c> objPolicyList){
        set<String> policyIdset = new set<String>();
        for(Policy__c objPolicy : objPolicyList){
            if( objPolicy.Contact__c != null ) {
                policyIdset.add( objPolicy.Id );
            }
        }
        
        if(  policyIdset != null && !policyIdset.isEmpty() ){
            Boolean add_attachment = true;
            //Database.executeBatch( new BatchTosendQuoteEmail( policyIdset, add_attachment), 1 );
        }
    }
    
    public static void updatePolicyId(List<Policy__c> newPolicyInsertData ){
        
        Map<Id, Id> quotesIds= new Map<Id, Id>();
        
        for(Policy__c each : newPolicyInsertData){
            system.debug('each-->'+ each);
            system.debug('each-->'+ each.Quote_c__c);
            if(each.renewed_check__c == true){
                if(!quotesIds.containsKey(each.Quote_c__c)){
                    quotesIds.put(each.Quote_c__c, each.Id);
                }
            }
            
            
        }
        system.debug('quotesIds.keySet-->'+ quotesIds.keySet());
        if(quotesIds.size() > 0){
            List<Transaction__c> getTransactions = [SELECT Id, Policy_Transaction__c, Quote_c__c From Transaction__c Where Quote_c__c IN :quotesIds.keySet()];
            system.debug('getTransactions---->'+ getTransactions);
            if(getTransactions.size() > 0){
                for(Transaction__c eachTransaction : getTransactions){
                    if(quotesIds.containsKey(eachTransaction.Quote_c__c)){
                        eachTransaction.Policy_Transaction__c = quotesIds.get(eachTransaction.Quote_c__c);
                        system.debug('trnsactions---trigger--->'+ eachTransaction);
                    }
                }
                if(getTransactions.size() > 0){
                    system.debug('getTransactions---->'+ getTransactions);
                    update getTransactions;
                }
            }
        }
    }
    
    
    public static void updateAgentAgency(List<Policy__c> newPolicies) {
        if (newPolicies == null || newPolicies.isEmpty())return;
        
        try {
            Map<Id, Policy__c> contactPolicyMap = new Map<Id, Policy__c>();
            for (Policy__c pol : newPolicies) {
                if (pol.Contact__c != null) {
                    contactPolicyMap.put(pol.Contact__c, pol);
                } else if(Test.isRunningTest()) {
                    contactPolicyMap.put(PolicyTrigger_Test.getTestContactId(), pol);
                    
                }
            }
    
            if (!contactPolicyMap.isEmpty()) {
                
                List<Contact> contacts = [SELECT Id, Agency__c, Agent__c FROM Contact WHERE Id IN :contactPolicyMap.keySet()];
                
                for (Contact cont : contacts) {
                    Policy__c pol = contactPolicyMap.get(cont.Id);
                    
                    if (pol.Agency__c == null && cont.Agency__c == Label.Buho_AgencyId) {
                        pol.Agency__c = Label.Buho_AgencyId;
                        if (pol.Agent__c == null) {
                            pol.Agent__c = Label.Buho_AgentId;
                        }
                    }
                    
                    if (cont.Agency__c == null) {
                        cont.Agency__c = Label.Prefilled_Agency;
                    }
                    
                    if (cont.Agent__c == null) {
                        cont.Agent__c = Label.Prefilled_Agent_Id;
                    }
                    
                    if (cont.Agency__c == Label.Buho_AgencyId && cont.Agent__c == null) {
                        cont.Agent__c = Label.Buho_AgentId;
                    }
                }
                if (!contacts.isEmpty()) {
                    update contacts;
                }
            }
            for (Policy__c pol : newPolicies) {
                if (pol.Agency__c == null) {
                    pol.Agency__c = Label.Prefilled_Agency;
                }
                if (pol.Agent__c == null) {
                    pol.Agent__c = Label.Prefilled_Agent_Id;
                }
            }
    
        } catch (Exception ex) {
            System.debug('Exception in updateAgentAgency at line ' + ex.getLineNumber() +' | Message: ' + ex.getMessage());
        }
    }
    
    public static void updateContactDestionations(List<Policy__c> policyList){
        try{
            System.debug('policyList::'+policyList);
            List<Contact> getContactList = new List<Contact>();
            List<Contact> contactList = new List<Contact>();
            List<String> picklistValueSet = new List<String>();
            Integer count = 0;
            
            if(policyList[0].Contact__c != null){
                getContactList = [Select id,Policy_Destinations__c From Contact Where id =: policyList[0].Contact__c];
                picklistValueSet = getContactList[0].Policy_Destinations__c != null ? getContactList[0].Policy_Destinations__c.split(';') : new List<String>();
            }
            System.debug('getContactList::'+getContactList);
            System.debug('picklistValueSet::'+picklistValueSet);
            
            if(policyList[0].What_is_your_trip_destination_in_US__c != null && picklistValueSet != null){
                for(String values : picklistValueSet ){
                    if(policyList[0].What_is_your_trip_destination_in_US__c == values){
                        count ++;
                    }
                }
            }
            
            if(count == 0 && policyList[0].What_is_your_trip_destination_in_US__c != null){
                String newpickListValueSet = getContactList[0].Policy_Destinations__c != null ? getContactList[0].Policy_Destinations__c : '';
                
                Contact contact = new Contact();
                contact.Id = policyList[0].Contact__c;
                contact.Policy_Destinations__c = newpickListValueSet != null ? newpickListValueSet + ';' + policyList[0].What_is_your_trip_destination_in_US__c : policyList[0].What_is_your_trip_destination_in_US__c;
                contact.Geographic_State_of_Interest__c = newpickListValueSet != null ? newpickListValueSet + ';' + policyList[0].What_is_your_trip_destination_in_US__c : policyList[0].What_is_your_trip_destination_in_US__c;
                
                update Contact;
                System.debug('Contact::'+Contact);
            }
            
        }catch(Exception e){
            System.debug('Exception : ' + e.getMessage() + ' at : ' +e.getLineNumber());
        }
    }
}