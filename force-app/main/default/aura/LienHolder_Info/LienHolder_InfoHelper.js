({
    initilizeData : function( component, event, helper ){

        var policyType = component.get("v.policyType");
        var countryOption = [];
        countryOption = [
            { "value" : "United States", "label" : "United States" },	
            { "value" : "Canada", "label" : "Canada" },
            { "value" : "Other", "label" : "Other" }	
        ];
        countryOption.push({ "value" : "Mexico", "label" : "Mexico" });
        component.set("v.countryOption", countryOption);
        var vehicleRecord = component.get('v.vehicleRecord');
        if( policyType && policyType.toLowerCase() == 'northbound' && !( vehicleRecord && vehicleRecord.Lienholder_Country__c != null )){
            vehicleRecord['Lienholder_Country__c'] = 'Mexico';
            component.set("v.vehicleRecord", vehicleRecord);
        }
        if( policyType && policyType.toLowerCase() == 'northbound' && vehicleRecord && vehicleRecord.Lienholder_Country__c && vehicleRecord.Lienholder_Country__c.toUpperCase() == 'MEXICO'){ 
            component.set("v.disableCountry", true);
            helper.setCountryAndStates(component, event, helper, 'MEXICO' );
        }

        if( vehicleRecord && vehicleRecord.Lienholder_Country__c != undefined ){
            console.log('--Lienholder_Country__c--',vehicleRecord.Lienholder_Country__c);
            if( vehicleRecord.Lienholder_Country__c.toUpperCase() == 'MEXICO' ){
                component.set("v.showStatePick", true);
                helper.setCountryAndStates(component, event, helper, 'MEXICO' );
            }else if( vehicleRecord.Lienholder_Country__c.toUpperCase() == 'UNITED STATES' ){
                component.set("v.showStatePick", true);
                helper.setCountryAndStates(component, event, helper, 'UNITED STATES' );
            }else if( vehicleRecord.Lienholder_Country__c.toUpperCase() == 'CANADA' ){
                component.set("v.showStatePick", true);
                helper.setCountryAndStates(component, event, helper, 'CANADA' );
            }
            component.set("v.policyCountry",vehicleRecord.Lienholder_Country__c);
        }
    },

    updateVehicleHelper : function( component, event, helper ){
        try{
            var action = component.get("c.updateVehicleAction");
            action.setParams({  
                vehicleObject : component.get("v.vehicleRecord")
            });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        var vehicleRecord = component.get("v.vehicleRecord");
                        vehicleRecord['Id'] = response.vehicleId;
                        component.set("v.vehicleRecord",vehicleRecord);
    
                        //helper.showToast('Quote updated successfully.', 'success');
                        $A.enqueueAction(component.get("v.onNextClick"));
                    }else{
                        helper.showToast(response.message, 'error');
                    }
                } else {
                    helper.showToast(response.getError(), 'error');
                }
            });
            $A.enqueueAction(action);

        }catch(ex){
            console.log('----ex-',ex);
        }
    },
    
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },

    setCountryAndStates : function( component, event, helper, country ){
        var canadaOptions = [	
            { "value" : "Alberta", "label" : "Alberta" },	
            { "value" : "British Columbia", "label" : "British Columbia" },
            { "value" : "Manitoba", "label" : "Manitoba" },	
            { "value" : "New Brunswick", "label" : "New Brunswick" },
            { "value" : "Newfoundland", "label" : "Newfoundland" },	
            { "value" : "Northwest Territories", "label" : "Northwest Territories" },
            { "value" : "Nova Scotia", "label" : "Nova Scotia" },	
            { "value" : "Nunavut", "label" : "Nunavut" },
            { "value" : "Ontario", "label" : "Ontario" },	
            { "value" : "Prince Edward Island", "label" : "Prince Edward Island" },
            { "value" : "Quebec", "label" : "Quebec" },	
            { "value" : "Saskatchewan", "label" : "Saskatchewan" },
            { "value" : "Yukon", "label" : "Yukon" },
        ];

        var mexicoOptions = [	
            { "value" : "Aguascalientes", "label" : "Aguascalientes" },	
            { "value" : "Baja California", "label" : "Baja California" },
            { "value" : "Baja California Sur", "label" : "Baja California Sur" },
            { "value" : "Campeche", "label" : "Campeche" },
            { "value" : "Chihuahua", "label" : "Chihuahua" },
            { "value" : "Chiapas", "label" : "Chiapas" },
            { "value" : "Coahuila", "label" : "Coahuila" },
            { "value" : "Colima", "label" : "Colima" },
            { "value" : "Distrito Federal", "label" : "Distrito Federal" },
            { "value" : "Durango", "label" : "Durango" },
            { "value" : "Guerrero", "label" : "Guerrero" },
            { "value" : "Guanajuato", "label" : "Guanajuato" },
            { "value" : "Hidalgo", "label" : "Hidalgo" },
            { "value" : "Jalisco", "label" : "Jalisco" },
            { "value" : "México", "label" : "México" },
            { "value" : "Michoacán", "label" : "Michoacán" },
            { "value" : "Morelos", "label" : "Morelos" },
            { "value" : "Nayarit", "label" : "Nayarit" },
            { "value" : "Nuevo León", "label" : "Nuevo León" },
            { "value" : "Oaxaca", "label" : "Oaxaca" },
            { "value" : "Puebla", "label" : "Puebla" },
            { "value" : "Querétaro", "label" : "Querétaro" },
            { "value" : "Quintana Roo", "label" : "Quintana Roo" },
            { "value" : "Sinaloa", "label" : "Sinaloa" },
            { "value" : "San Luís Potosí", "label" : "San Luís Potosí" },
            { "value" : "Sonora", "label" : "Sonora" },
            { "value" : "Tabasco", "label" : "Tabasco" },
            { "value" : "Tamaulipas", "label" : "Tamaulipas" },
            { "value" : "Tlaxcala", "label" : "Tlaxcala" },
            { "value" : "Veracruz", "label" : "Veracruz" },
            { "value" : "Yucatán", "label" : "Yucatán" },
            { "value" : "Zacatecas", "label" : "Zacatecas" }   
        ];

        var usOptions = [	
            { "value" : "Alabama", "label" : "Alabama" },	
            { "value" : "Alaska", "label" : "Alaska" },
            { "value" : "Arizona", "label" : "Arizona" },	
            { "value" : "Arkansas", "label" : "Arkansas" },
            { "value" : "California", "label" : "California" },	
            { "value" : "Colorado", "label" : "Colorado" },
            { "value" : "Connecticut", "label" : "Connecticut" },	
            { "value" : "Delaware", "label" : "Delaware" },
            { "value" : "Florida", "label" : "Florida" },	
            { "value" : "Georgia", "label" : "Georgia" },
            { "value" : "Hawaii", "label" : "Hawaii" },	
            { "value" : "Idaho", "label" : "Idaho" },
            { "value" : "Illinois", "label" : "Illinois" },
            { "value" : "Indiana", "label" : "Indiana" },
            { "value" : "Iowa", "label" : "Iowa" },	
            { "value" : "Kansas", "label" : "Kansas" },
            { "value" : "Kentucky", "label" : "Kentucky" },	
            { "value" : "Louisiana", "label" : "Louisiana" },
            { "value" : "Maine", "label" : "Maine" },	
            { "value" : "Maryland", "label" : "Maryland" },
            { "value" : "Massachusetts", "label" : "Massachusetts" },	
            { "value" : "Michigan", "label" : "Michigan" },
            { "value" : "Minnesota", "label" : "Minnesota" },	
            { "value" : "Mississippi", "label" : "Mississippi" },
            { "value" : "Missouri", "label" : "Missouri" },	
            { "value" : "Montana", "label" : "Montana" },
            { "value" : "Nebraska", "label" : "Nebraska" },
            { "value" : "Nevada", "label" : "Nevada" },	
            { "value" : "New Hampshire", "label" : "New Hampshire" },
            { "value" : "New Jersey", "label" : "New Jersey" },	
            { "value" : "New Mexico", "label" : "New Mexico" },
            { "value" : "New York", "label" : "New York" },	
            { "value" : "North Carolina", "label" : "North Carolina" },
            { "value" : "North Dakota", "label" : "North Dakota" },	
            { "value" : "Ohio", "label" : "Ohio" },
            { "value" : "Oklahoma", "label" : "Oklahoma" },	
            { "value" : "Oregon", "label" : "Oregon" },
            { "value" : "Pennsylvania", "label" : "Pennsylvania" },
            { "value" : "Rhode Island", "label" : "Rhode Island" },
            { "value" : "South Carolina", "label" : "South Carolina" },
            { "value" : "South Dakota", "label" : "South Dakota" },	
            { "value" : "Tennessee", "label" : "Tennessee" },
            { "value" : "Texas", "label" : "Texas" },	
            { "value" : "Utah", "label" : "Utah" },
            { "value" : "Vermont", "label" : "Vermont" },	
            { "value" : "Virginia", "label" : "Virginia" },
            { "value" : "Washington", "label" : "Washington" },	
            { "value" : "West Virginia", "label" : "West Virginia" },
            { "value" : "Wisconsin", "label" : "Wisconsin" },	
            { "value" : "Wyoming", "label" : "Wyoming" }
        ];

        if( country && country.toUpperCase() == 'MEXICO'){
            component.set("v.stateOptions", mexicoOptions);
        }else if( country && country.toUpperCase() == 'CANADA'){
            component.set("v.stateOptions", canadaOptions);
        }else if( country && country.toUpperCase() == 'UNITED STATES'){
            component.set("v.stateOptions", usOptions);
        }
        
    },

    validateInputFields : function(component, event, helper){
        var allValid = true; 
        try{
            allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }catch(ex){
            
        }
        return allValid;
    },
})