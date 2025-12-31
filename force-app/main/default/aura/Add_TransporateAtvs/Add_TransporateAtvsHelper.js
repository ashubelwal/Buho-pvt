({
    
    createTowedUnitHelper : function( component, event, helper, next ) {

        var towedObject = component.get("v.towedunitRecord")
        var transporates = component.get("v.transporates");

        var vaildate = true;
        if( transporates != undefined && transporates.length > 0 ){
            transporates.forEach(function(item){
                if( towedObject.Id != item.Id && item.Street_Legal__c != undefined && item.Street_Legal__c == 'Yes'
                    && towedObject.Street_Legal__c == 'Yes' ){
                    vaildate = false;
                }
            });
        }

        if( vaildate ){
            const action = component.get('c.createTowedUnit');
            console.log("Ca log --> "+ JSON.stringify(action, null, 4));
            action.setParams({
                towedObject : towedObject,
                quoteId : component.get("v.quoteRecord").Id,
                vehicleId : component.get("v.vehicleRecord").Id
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        var towedunitRecord = component.get("v.towedunitRecord");
                        towedunitRecord['Id'] = response.towedUnitId;
                        component.set("v.towedunitRecord",towedunitRecord);

                        var transporates = component.get("v.transporates");

                        var objIndex
                        if( transporates && transporates.length > 0 ){
                            objIndex  = transporates.findIndex((obj => obj.Id == response.towedUnitId ));
                        }
                        
                        console.log('---objIndex--'+objIndex);
                        if( objIndex != null  && parseInt(objIndex) >= 0 ){
                            console.log('--transporates---'+JSON.stringify(transporates[objIndex]));
                            transporates[objIndex] = towedunitRecord;
                        }else{
                            transporates.push(towedunitRecord);
                        }

                        if( transporates != undefined && transporates.length > 0 ){
                            component.set("v.isTransScreenOpen", false);
                        }
                        console.log('--transporates---'+JSON.stringify(transporates));
                        component.set("v.transporates", transporates);
                        component.set("v.isEdit", false);
                        component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c', 'Towed_Unit_Value__c': component.get("v.quoteRecord").Towed_Unit_Value__c}); 
                        if( next != null && next != ''){
                            $A.enqueueAction(component.get("v.onNextClick"));
                        }
                    }else{
                        helper.showToast(response.message, 'error');
                    }
                } else {
                    helper.showToast(response.getError(), 'error');
                }
            });
            $A.enqueueAction(action);
        }else{
            helper.showToast('You already have insurable towed', 'error');
        }
	},

    deleteTowedUnitHelper : function( component, event, helper, towId ) {
        console.log('---recordId--',towId);
        var action = component.get("c.deleteTowedUnitAction");
        action.setParams({ recordId : towId, quoteId : component.get("v.quoteRecord").Id  });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') { 
                var response = response.getReturnValue();
                console.log('--response--'+JSON.stringify(response));
                if( response.success){
                    var transporates = component.get("v.transporates");
                    var filterTrans = transporates.filter(function( item ){
                        return item.Id != towId;
                    });
                    component.set("v.transporates", filterTrans);
                    if( filterTrans != undefined && filterTrans.length > 0 ){
                        component.set("v.isTransScreenOpen", false);
                    }
                    //component.set("v.registeredVehicleHeader", "Additional Driver Information");
                    component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c', 'Towed_Unit_Value__c': component.get("v.quoteRecord").Towed_Unit_Value__c}); 
                    
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
})