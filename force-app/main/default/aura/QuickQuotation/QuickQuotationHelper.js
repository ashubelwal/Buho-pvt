({
	createQuoteHelper : function( component, event, helper , steps, step, nextstep) {
        var action = component.get("c.createQuickQuoteAction");

        action.setParams({  quoteObject : component.get("v.quoteObject")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    
                    if( step != null && nextstep != null ){
                        steps[step] = false;
                        steps[nextstep] = true;
                        component.set("v.steps", steps);
                    }
                    
                    var quoteObject = component.get("v.quoteObject");
                    quoteObject['Id'] = response.quoteId;
                    component.set("v.quoteObject", quoteObject);
                    
                    component.set("v.quoteId", response.quoteId);
                }else{
                    alert( response.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    createVehicleHelper : function( component, event, helper , steps, step, nextstep) {
        var action = component.get("c.createVehicleAction");
		console.log('vehicleObject->'+JSON.stringify(component.get("v.vehicleObject")));
        action.setParams({  vehicleObject : component.get("v.vehicleObject"),
                          	leadEmail : component.get("v.leadEmail"),
                         	quoteId : component.get("v.quoteId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    if( step != null && nextstep != null ){
                        steps[step] = false;
                        steps[nextstep] = true;
                        component.set("v.steps", steps);
                    }
                    
                    component.set("v.vehicleId", response.vehicleId);
                    component.set("v.leadId", response.leadId);
                }else{
                    alert( response.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    }, 

    updateVehicleHelper : function( component, event, helper , steps, step, nextstep) {
        var action = component.get("c.updateVehicleAction");
		console.log('vehicleObject->'+JSON.stringify(component.get("v.vehicleObject")));
        action.setParams({  vehicleObject : component.get("v.vehicleObject")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    if( step != null && nextstep != null ){
                        steps[step] = false;
                        steps[nextstep] = true;
                        component.set("v.steps", steps);
                    }
                    
                    //component.set("v.vehicleId", response.vehicleId);
                    //component.set("v.leadId", response.leadId);
                }else{
                    alert( response.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    createTowedUnitHelper : function( component, event, helper , steps, step, nextstep) {
        var action = component.get("c.createTowedUnit");
        action.setParams({  towedObject : component.get("v.towedUnitObject"),
                         	quoteId : component.get("v.quoteId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    if( step != null && nextstep != null ){
                        steps[step] = false;
                        steps[nextstep] = true;
                        component.set("v.steps", steps);
                        
                        if( step === 'step_7' ){
                            var quoteObject = component.get("v.quoteObject");
                            quoteObject['Territory_Coverage__c'] = 'PARTIAL(US ADJACENT)';
                            component.set("v.quoteObject", quoteObject);
                        }
                        
                    }
                    
                    component.set("v.towedUnitId", response.towedUnitId);
                }else{
                    alert( response.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    }, 
    
    createDriverHelper : function( component, event, helper , steps, step, nextstep) {
        var action = component.get("c.createDriverAction");
        action.setParams({  driverObject : component.get("v.driverObject"),
                         	quoteId : component.get("v.quoteId"),
                         	isOwner : component.get("v.isOwner")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    if( step != null && nextstep != null ){
                        steps[step] = false;
                        steps[nextstep] = true;
                        component.set("v.steps", steps);
                    }else{
                        component.set("v.registeredVehicleHeader", "Additional Driver Information");
                    }
                    
                    var driverObject = component.get("v.driverObject");
                    driverObject['Id'] = response.driverId;
                    
                    var drivers = component.get("v.drivers");
                    drivers.push(driverObject);
                    
                    component.set("v.drivers", drivers);
                    component.set("v.isOwner", false);
                    
                    component.set("v.driverObject", { 'sobjectType': 'Driver__c'});
                }else{
                    alert( response.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    }, 
    
    createTransportedUnitHelper : function( component, event, helper , steps, step, nextstep) {
    },
    
    fetchPicklist : function( component, event, helper, objectApiName, fieldApi, fieldAttr) {
        var action = component.get("c.getPicklistValues");
        
        action.setParams({ 'objectApiName' : objectApiName,
                          'fieldApiName' : fieldApi }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    

    updateQuoteHelper : function( component, event, helper , steps, step) {
        var action = component.get("c.updateQuickQuote");

        action.setParams({  termQuoteObject : JSON.stringify(component.get("v.termQuoteObject")),
                            quoteId : component.get("v.quoteId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //alert("From server: " + response.getReturnValue());
                var response = response.getReturnValue();
                console.log( JSON.stringify(response) );
                if( response.success ){
                    steps[step] = false;
                    steps['step_6'] = true;
                    component.set("v.steps", steps);
                }else{
                    alert( response.message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updateTowedQuoteHelper : function( component, event, helper , steps, step) {
        console.log('*****updateTowedQuoteHelper***');
        var action = component.get("c.updateTowedQuickQuote");

        action.setParams({  towedQuoteObject : JSON.stringify(component.get("v.towedQuoteObject")),
                            quoteId : component.get("v.quoteId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //alert("From server: " + response.getReturnValue());
                var response = response.getReturnValue();
                console.log( JSON.stringify(response) );
                if( response.success ){
                    steps[step] = false;
                    steps['step_7'] = true;
                    component.set("v.steps", steps);
                }else{
                    alert( response.message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updateTerCoverageHelper : function( component, event, helper , steps, step) {
        var action = component.get("c.updateTerCoverage");

        action.setParams({  territorycoverage : component.get("v.territorycoverage"),
                            quoteId : component.get("v.quoteId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //alert("From server: " + response.getReturnValue());
                var response = response.getReturnValue();
                console.log( JSON.stringify(response) );
                if( response.success ){
                    steps[step] = false;
                    steps['step_9'] = true;
                    component.set("v.steps", steps);
                }else{
                    alert( response.message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getUrlParameter : function(param) {
        let sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&');

        for (let i = 0; i < sURLVariables.length; i++) {
            let sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === param) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }

        return "";
    },
})