trigger vechileTriggerAction on Vehicle__c (before update) {
    if( (QuickQuotationCtrl.vechileTriggerAction && trigger.isBefore && trigger.isUpdate) || test.isRunningTest()){

        set<String> vehicleIds = new set<String>();
        for( Vehicle__c vehicle :  trigger.new ){
            if( vehicle.Vehicle_Type__c != trigger.oldMap.get(vehicle.Id).Vehicle_Type__c 
                || vehicle.Rental__c != trigger.oldMap.get(vehicle.Id).Rental__c
                || vehicle.Value__c != trigger.oldMap.get(vehicle.Id).Value__c  ){
                vehicleIds.add( vehicle.Id );
            }
        }


        map<String,String> vehicleIdVSPolicyName= new map<String,String>();
        
        set<string> policyIds = new set<string>();
        
        List<Quote_Vehicle__c> quoteVehicleList = new List<Quote_Vehicle__c>();
        
        quoteVehicleList = [select Id, Quote_c__c, Vehicle__c, Policy__c, Policy__r.Name
                                        from Quote_Vehicle__c where Vehicle__c IN: vehicleIds
                                        and Policy__r.Status_picklist__c = 'Active'];
        system.debug('quoteVehicleList: --'+ quoteVehicleList);
        
        for( Quote_Vehicle__c quoteV : quoteVehicleList){
                                        
            policyIds.add(quoteV.Policy__c);
            vehicleIdVSPolicyName.put( quoteV.Vehicle__c, quoteV.Policy__c);
        }  
        
        map<String, Policy__c > vehicleIdVSPolicy = new map<String, Policy__c >();
        for(Policy__c p : [select id, name from policy__c where id in: policyIds]){
            vehicleIdVSPolicy.put(p.Id , p);
        }
        
        for( Vehicle__c vehicle :  trigger.new ){
            if( vehicle.Vehicle_Type__c != trigger.oldMap.get(vehicle.Id).Vehicle_Type__c 
                || vehicle.Rental__c != trigger.oldMap.get(vehicle.Id).Rental__c
                || vehicle.Value__c != trigger.oldMap.get(vehicle.Id).Value__c  ){
                
                if( vehicleIdVSPolicyName != null && vehicleIdVSPolicyName.containsKey(vehicle.Id)){
                    String name = vehicleIdVSPolicy.get(vehicleIdVSPolicyName.get(vehicle.Id)).Name;
                    
                    String url = URL.getOrgDomainUrl().toExternalForm()+'/'+vehicleIdVSPolicy.get(vehicleIdVSPolicyName.get(vehicle.Id)).Id;
                    String link = '<a href="' + url + '"> '+ name + '</a>';
                   // vehicle.addError('Modifying this value will change the premium of policy '+name+'.  To make this change you will need to edit the Policy ', false );//+link
                }
            }
        }
    }
}