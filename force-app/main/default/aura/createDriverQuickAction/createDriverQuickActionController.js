({
	doInit : function(component, event, helper) {
		helper.initializeData(component, event, helper);
	},

    updateDriverField:function(component, event, helper) {
        try{
            let name = event.getSource().get("v.name");
            let driverObject = component.get("v.driverObject");
    
            if(name == 'Primary_insured__c'){
                driverObject[name] = event.getParam("checked");
            }else{
                var value = event.getParam("value");
                if( name == 'license_number__c' && value && value.length > 0 ){
                    value = value.toUpperCase();
                }
                if( name == 'Phone__c' && value && value.length > 0 ){
                    const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
                    value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
                }
                driverObject[name] = value;
            }
    
            if (name === 'Country__c') {
                driverObject['State_Province__c'] = undefined;
            }
            if (name === 'License_Country__c') {
                driverObject['License_state__c'] = undefined;
            }
    
            if( name === 'Country__c' &&  value != undefined ){
                driverObject['License_Country__c'] = value;
                component.set("v.policyCountryLicense", value);
            }
    
            if( name === 'State_Province__c' && driverObject.State_Province__c != undefined ){
                driverObject['License_state__c'] = driverObject.State_Province__c;
            }
    
            component.set("v.driverObject", driverObject);
            helper.setInputComponentsVisibility(component, event, helper);
        }catch( ex ){
            console.log('--ex-',ex);
        }
    },

	handleSubmit : function(component, event, helper) {
        var allVal = helper.validateInputFields(component, event, helper);
        if( allVal ){
            helper.createDriverRecord(component, event, helper);
        }
    },
     
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    
})