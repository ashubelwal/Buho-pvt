({
	createTowedUnitHelper : function( component, event, helper ) {
		const action = component.get('c.createTowedUnit');
        console.log("CA create tow ---- ", JSON.stringify(component.get("v.towedunitRecord"), null, 4));
        action.setParams({
            towedObject : component.get("v.towedunitRecord"),
            quoteId : component.get("v.quoteRecord").Id,
            vehicleId : component.get("v.vehicleRecord").Id
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                console.log('CA log Towing response --> '+ JSON.stringify(response, null, 4));
                if( response.success){
                    var towedunitRecord = component.get("v.towedunitRecord");
                    towedunitRecord['Id'] = response.towedUnitId;
                    component.set("v.towedunitRecord",towedunitRecord);

                    //helper.showToast('towning successfully.', 'success');
					$A.enqueueAction(component.get("v.onNextClick"));
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
	},
    
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },

    /*
     * objectApiName : ObjectName
     * fieldApi : filed Api name
     * fieldAttr : save data in cmp,
     * */
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

    validateInputFields : function(component, event, helper){
        var allValid = true;
        try{
            allValid =  component.find('validateField').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }catch( ex ){

        }
        return allValid;
    },

    getLoginUserTransHelper : function (component, event, helper){
        
        var action = component.get("c.getCurrentUserTransporate");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('---result--',result);
                if( result != undefined && result != null ){
                    var loginUserTrans = [{'value': '', 'label': '--None--'}];
                    result.forEach( function(item){
                        let label = item.Make__c+' '+item.Model__c +' '+item.Year__c+ ' - '+item.VIN_Number__c+'';
                        loginUserTrans.push({'value': item.Id, 'label': label });
                    });

                    component.set("v.loginUserTransOption", loginUserTrans);
                    component.set("v.loginUserTransporates", result);
                    
                }
            }
        });
        $A.enqueueAction(action);
    },

    deleteTowedUnitHelper : function( component, event, helper, towId ) {
        var action = component.get("c.deleteTowedUnitAction");
        action.setParams({ recordId : towId, quoteId : component.get("v.quoteRecord").Id  });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') { 
                var response = response.getReturnValue();
                if( response.success){
                    component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c'});    
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
            
	},
})