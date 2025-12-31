({
    doInit: function (component, event, helper) {
        helper.initializeData(component, event, helper);
    },

    updateDriverField: function (component, event, helper) {
        try{
            let name = event.getSource().get("v.name");
            let driverObject = component.get("v.driverObject");
    		let value = event.getParam("value");
            
           console.log('name-->'+ name);
            
            if(name == 'Primary_insured__c'){
                driverObject[name] = event.getParam("checked");
            }else{
                if(/^\s/.test(value)){
                    value = '';
                }
                if( name == 'license_number__c' && value && value.length > 0 ){
                    value = value.toUpperCase();
                }
                if( name == 'Phone__c' && value && value.length > 0 ){
                    const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
                    value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
                }
                driverObject[name] = value;
                component.set("v.iscloneConditionPass", true);
            }
            
            if (name === 'Country__c') {
                 if(/^\s/.test(value)){
                    value = '';
                }
                component.set("v.policyCountryInput", value)
                driverObject['State_Province__c'] = undefined;
            }
            if (name === 'License_Country__c') {
                driverObject['License_state__c'] = undefined;
            }
    
            if( name === 'Country__c' &&  value != undefined ){
                if(/^\s/.test(value)){
                    value = '';
                }
               component.set("v.policyCountryInput", value)
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

    validateInputFields : function(component, event, helper){
       
        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if(allValid){
            var customValidateField = component.find("customValidateField");
            if( customValidateField != null && customValidateField != undefined ){
                allValid = ( allValid && customValidateField.validateFields());
            }
        }
        return allValid;
    },
})