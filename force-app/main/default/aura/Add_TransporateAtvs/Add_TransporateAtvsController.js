({
    doInit : function(component, event, helper) {
        var transporates = component.get("v.transporates");
        console.log('--transporates---',transporates);
        if( transporates != undefined && transporates.length > 0 ){
            component.set("v.isTransScreenOpen", false);
        }
        component.set("v.registeredVehicleHeader", component.get("v.title"));
        var Towed_Unit_Types = component.get("v.Towed_Unit_Types");
        var Street_Legals = component.get("v.Street_Legals");

        if( $A.util.isEmpty(Towed_Unit_Types)){
            helper.fetchPicklist( component, event, helper , 'Towed_Unit__c', 'Towed_Unit_Type__c', 'v.Towed_Unit_Types');
        }

        if( $A.util.isEmpty(Street_Legals)){
            helper.fetchPicklist( component, event, helper , 'Towed_Unit__c', 'Street_Legal__c', 'v.Street_Legals');
        }
        component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c', 'Towed_Unit_Value__c': component.get("v.quoteRecord").Towed_Unit_Value__c}); 

        var isCommunityUser = component.get("v.isCommunityUser");
        console.log('----isCommunityUser--',isCommunityUser);
        if( isCommunityUser != undefined && isCommunityUser){
            helper.getLoginUserTransHelper( component, event, helper );
        }
    },
    
    addOther : function(component, event, helper) {
        var towedunitRecord = component.get("v.towedunitRecord");
        let allVal = component.find("transporateDetail").validateFields();
        if( allVal ){
            var renewPolicy = component.get("v.renewPolicy");
            if( renewPolicy != undefined && renewPolicy == true ){
                helper.createTowedUnitHelper( component, event, helper, null);
                return;
            }
            var editPolicy = component.get("v.editPolicy");
            var iscloneConditionPass = component.get("v.iscloneConditionPass");
            if( editPolicy == true && iscloneConditionPass == true ){
                var transporates = component.get("v.transporates");
                var towedunitRecord = component.get("v.towedunitRecord");
                transporates.push(towedunitRecord);
                component.set("v.transporates", transporates);
                component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c', 'Towed_Unit_Value__c': component.get("v.quoteRecord").Towed_Unit_Value__c}); 

            }else{
                helper.createTowedUnitHelper( component, event, helper, null);
            }
        }
    },

    openTransUnitDetail : function (component, event, helper) {
        component.set("v.isTransScreenOpen", !component.get("v.isTransScreenOpen"));
    },

    handleChange : function (component, event, helper) {
        var towUnitId = event.getParam("value");
        var loginUserTransporates = component.get("v.loginUserTransporates");
        if( loginUserTransporates != undefined && loginUserTransporates.length > 0 && towUnitId != undefined){
            var transporates = loginUserTransporates.filter(item => {
                return item.Id === towUnitId;
            });
            console.log('--transporates---'+transporates);
            if( transporates != null && transporates != undefined ){
                component.set("v.towedunitRecord", transporates[0]);
                var renewPolicy = component.get("v.renewPolicy");
                /*if( renewPolicy != undefined && renewPolicy == true ){
                    var transporates = component.get("v.transporates");
                    var towedunitRecord = component.get("v.towedunitRecord");
                    transporates.push(towedunitRecord);
                    component.set("v.transporates", transporates);
                    component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c', 'Towed_Unit_Value__c': component.get("v.quoteRecord").Towed_Unit_Value__c}); 
                    return;
                }*/
                helper.createTowedUnitHelper( component, event, helper, null);
            }
        }
    },

    updateUnit : function(component, event, helper) {
        let allVal = component.find("transporateDetail").validateFields();
        if(allVal){
            helper.createTowedUnitHelper( component, event, helper, null);
        }
        
    },
    
    onNextClick : function(component, event, helper) {
        var transporates = component.get("v.transporates");
        if( transporates == undefined || transporates.length == 0 ){
            let allVal = component.find("transporateDetail").validateFields();
            if( allVal ){
                var renewPolicy = component.get("v.renewPolicy");
                if( renewPolicy != undefined && renewPolicy == true ){
                    helper.createTowedUnitHelper( component, event, helper, 'TerritoryCoverage' );
                    return;
                }

                var editPolicy = component.get("v.editPolicy");
                var iscloneConditionPass = component.get("v.iscloneConditionPass");
                if( editPolicy == true && iscloneConditionPass == true ){
                    
                    var towedunitRecord = component.get("v.towedunitRecord");
                    transporates.push(towedunitRecord);
                    component.set("v.transporates", transporates);
                    $A.enqueueAction(component.get("v.onNextClick"));
                }else{
                    helper.createTowedUnitHelper( component, event, helper, 'TerritoryCoverage' );
                }
            }
        }else{
            $A.enqueueAction(component.get("v.onNextClick"));
        }
    },

    editTowedUnit : function(component, event, helper) {
        component.set("v.isEdit", true);
        var towId = event.getSource().get('v.name');
        var transporates = component.get("v.transporates");
        var filterTrans = transporates.filter(function( item ){
            return item.Id == towId;
        });

        if( filterTrans != null && filterTrans.length > 0 ){
            component.set("v.towedunitRecord", filterTrans[0]); 
        }
    },

    cancelEdit : function(component, event, helper) {
        component.set("v.isEdit", false);
        component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c', 'Towed_Unit_Value__c': component.get("v.quoteRecord").Towed_Unit_Value__c}); 

    },

    cancelNewUnit : function(component, event, helper) {
        component.set("v.isTransScreenOpen",false);
    },

    deleteTowedUnit : function(component, event, helper) { 
        var towId = event.getSource().get('v.name');
        helper.deleteTowedUnitHelper( component, event, helper, towId );
    },

})