({
	doInit : function(component, event, helper) {
		helper.initilizeData(component, event, helper);
    },
    
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var value = event.getParam("value");

        var quoteRecord = component.get("v.quoteRecord");
        var watercraftRecord = component.get("v.watercraftRecord");
        
        if(name == 'Year__c') {
            quoteRecord['Vehicle_Year__c'] = value;
        } else if(name == 'Make__c'){
            quoteRecord['Vehicle_Make__c'] = value;
        } else if(name == 'Model__c'){
            quoteRecord['Vehicle_Model__c'] = value;
        } else if(name == 'Value__c'){
            quoteRecord['Vehicle_Value__c'] = value;
        } else if(name == 'Type_of_Vessel__c'){
            quoteRecord[name] = value;

            quoteRecord['Vessel_Length__c'] = '';
            watercraftRecord['Vessel_Length__c'] = '';
            
            helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths');
        } else if(name == 'Vessel_Length__c'){
            quoteRecord[name] = value;
        }else if(name == 'Engine_Type__c'){
            if(/^\s/.test(value)){
                value = '';
            }
        }
        if( name == 'VIN_Number__c' && value != null ){
            value = value.toUpperCase();
        }
        
        watercraftRecord[name] = value;
        
        component.set("v.quoteRecord", quoteRecord);
        component.set("v.watercraftRecord", watercraftRecord);
    },
    
    onNextClick : function(component, event, helper) {
        var allValid = helper.validateInputFields(component, event, helper);
        var renewPolicy = component.get("v.renewPolicy");
        
        if( allValid ){
            if( renewPolicy != undefined && renewPolicy == true){
                helper.handleVehicleDetail(component, event, helper);
                return;
            }
        }

        var editPolicy = component.get("v.editPolicy");
        if( editPolicy != undefined && editPolicy == true){
            var iscloneConditionPass = component.get("v.iscloneConditionPass");
            if( iscloneConditionPass == false ){
                if( allValid ){
                    helper.handleVehicleDetail(component, event, helper);
                }
            }else{
                if( allValid ){
			      $A.enqueueAction(component.get("v.onNextClick"));

                }
            }
        }else{
            if( allValid ){
                helper.handleVehicleDetail(component, event, helper);
            }
        }
    }
})