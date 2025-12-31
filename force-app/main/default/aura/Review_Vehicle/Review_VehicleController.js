({
	doInit : function(component, event, helper) {
		helper.initilizeData(component, event, helper);
    },
    
    onCountryChange : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var value = event.getParam("value");
        var vehicleRecord = component.get("v.vehicleRecord");
        if( value && value != 'Other'){
            vehicleRecord[name] = value;
            helper.setCountryAndStates(component, event, helper, value );
            component.set("v.showStatePick", true);
        }else{
            vehicleRecord[name] = '';
            component.set("v.showStatePick", false);
        }
        component.set("v.vehicleRecord", vehicleRecord);
    },
    
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var vehicleRecord = component.get("v.vehicleRecord");
        
        if(name == 'Is_the_vehicle_used_for_business_purpose__c'
           || name == 'Salvage_Vehicle__c' ){
            
            var value = event.getParam("checked");
            vehicleRecord[name] = value;
            
        }else if( name == 'Is_the_vehicle_registered_to_a_business__c' || name == 'Is_Lienholder__c' ){
            var value = event.getParam("value");
            if( value  == 'Yes'){
                vehicleRecord[name] = true;
            }else{
                vehicleRecord[name] = false;
            }
        }else if(name == 'Rental__c'){
            var value = event.getParam("checked");
            if( value ){
                vehicleRecord[name]= 'Yes';
            }else{
                vehicleRecord[name] = 'No';
            }
        }else{
            var value = event.getParam("value");
            if(/^\s/.test(value)){
                value = '';
            }
            if( (name == 'Registered_Plate__c' || name == 'Vin__c') && value && value.length > 0){
                value = value.toUpperCase();
            }

            if( name == 'Registered_Country__c'){
                if( value  && value != null 
                        && ( value.toUpperCase() == 'MEXICO' || value.toUpperCase() == 'US'
                            || value.toUpperCase() == 'UNITED STATES' 
                            || value.toUpperCase() == 'CANADA') ){
                    component.set("v.showStatePick", true);
                    if( value.toUpperCase() == 'US' || value.toUpperCase() == 'UNITED STATES' ){
                        helper.setCountryAndStates(component, event, helper, 'UNITED STATES' );
                    }else{
                        helper.setCountryAndStates(component, event, helper, value );
                    }
                }else{
                    component.set("v.showStatePick", false);
                } 
            }
            vehicleRecord[name] = value;
        }
        var editPolicy = component.get("v.editPolicy");
        var quoteRecord = component.get("v.quoteRecord");
        let renewPolicy = component.get("v.renewPolicy");
        if( editPolicy != undefined && editPolicy == true){
            try{
                var vehicleValue =  vehicleRecord.Value__c != undefined ? vehicleRecord.Value__c : 0;
                var clonedvehicleRecord = component.get("v.clonedvehicleRecord");
                console.log('---clonedvehicleRecord--'+JSON.stringify(clonedvehicleRecord));
                var clonedvehicleValue = clonedvehicleRecord.Value__c != undefined ? clonedvehicleRecord.Value__c : 0;
    
                if( vehicleValue != clonedvehicleValue){
                    component.set("v.vehicleValueChange", true);
                    quoteRecord['Vehicle_Value__c'] = vehicleValue;
                }else{
                    component.set("v.vehicleValueChange", false);
                    quoteRecord['Vehicle_Value__c'] = clonedvehicleValue;
                }
                component.set("v.quoteRecord",quoteRecord);
            }catch( ex ){
                console.log('--ex--',ex);
            }
            
        }
     
        component.set("v.vehicleRecord", vehicleRecord);
    },
    
    onNextClick : function(component, event, helper) {
        var allValid = helper.validateInputFields(component, event, helper);
        var renewPolicy = component.get("v.renewPolicy");
        /*if( renewPolicy != undefined && renewPolicy == true ){
            if( allValid ){
                helper.handleVehicleDetail(component, event, helper);
            }
            return;
        }*/
        let vehicleRecord = component.get("v.vehicleRecord");
        let quoteRecord = component.get("v.quoteRecord");
        if(renewPolicy = true && renewPolicy != undefined){
            
            quoteRecord['Vehicle_Value__c'] =  vehicleRecord.Value__c != undefined ? vehicleRecord.Value__c : 0;
            
            console.log('--Vehicle_Value__c--'+quoteRecord['Vehicle_Value__c'] );
        }
        component.set("v.quoteRecord",quoteRecord);
        
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