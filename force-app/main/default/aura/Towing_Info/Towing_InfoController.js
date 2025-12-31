({
    doInit : function(component, event, helper) {
        //helper.initilizeData(component, event, helper);
        helper.fetchPicklist( component, event, helper , 'Towed_Unit__c', 'Towed_Unit_Type__c', 'v.Towed_Unit_Types');
        helper.fetchPicklist( component, event, helper , 'Towed_Unit__c', 'Street_Legal__c', 'v.Street_Legals');

        var iscommunityUser = component.get("v.iscommunityUser");
        if( iscommunityUser != undefined && iscommunityUser == true){
            component.set("v.newSectionOpen", true);
            helper.getLoginUserTransHelper( component, event, helper );
        }else{
            component.set("v.newSectionOpen", true);
        }

        var towedunitRecord = component.get("v.towedunitRecord");
        if( towedunitRecord != undefined && towedunitRecord.Id != undefined ){
            component.set("v.istowedunitRecord", true);
        }
    },

    handleSectionToggle : function(component, event, helper) {
        var iscommunityUser = component.get("v.iscommunityUser");
        if( iscommunityUser != undefined && iscommunityUser == true ){
            component.set("v.newSectionOpen", !component.get("v.newSectionOpen"));
        }
    },
    
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var towedunitRecord = component.get("v.towedunitRecord");
        var value = event.getParam("value");
          if(/^\s/.test(value)){
                value = '';
            }
        if( name != null && ( name == 'VIN_Number__c' || name == 'Plate__c' ) && value != null && value.length > 0 ){
            value = value.toUpperCase();
        }
        towedunitRecord[name] = value;
        component.set("v.iscloneConditionPass", true);
        component.set("v.towedunitRecord", towedunitRecord);
    },

    handleChange : function (component, event, helper) {
        var towUnitId = event.getParam("value");
        var loginUserTransporates = component.get("v.loginUserTransporates");
        if( loginUserTransporates != undefined && loginUserTransporates.length > 0 && towUnitId != undefined){
            var transporates = loginUserTransporates.filter(item => {
                return item.Id === towUnitId;
            });
            if( transporates != null && transporates != undefined ){
                component.set("v.towedunitRecord", transporates[0]);
                // commented by vikram
                //helper.createTowedUnitHelper( component, event, helper);
                var towedunitRecord = component.get("v.towedunitRecord");
                if( towedunitRecord != undefined && towedunitRecord.Id != undefined ){
                    component.set("v.istowedunitRecord", true);
                }
            }
        }
    },

    onNextClick : function(component, event, helper) {
        var allValid = helper.validateInputFields(component, event, helper);
        var newSectionOpen = component.get("v.newSectionOpen");
        var towedunitRecord = component.get("v.towedunitRecord");

        //console.log('--event--', event);
        try{
            var name = event.target.name;
            if( name && name == 'addOtherUnit'){
                component.set("v.addOtherUnit", true);
            }else{
                component.set("v.addOtherUnit", false);
            }
            var renewPolicy = component.get("v.renewPolicy");
            /*if( renewPolicy != undefined && renewPolicy == true ){
                if( allValid && newSectionOpen ){
                    $A.enqueueAction(component.get("v.onNextClick"));
                }else if( towedunitRecord != undefined && towedunitRecord.Id != undefined && allValid ){
                    $A.enqueueAction(component.get("v.onNextClick"));
                }
                return;
            }*/
            
            var editPolicy = component.get("v.editPolicy");
            var iscloneConditionPass = component.get("v.iscloneConditionPass");
            if( editPolicy == true && iscloneConditionPass == true ){
                if( allValid){
                    $A.enqueueAction(component.get("v.onNextClick"));
                }
            }else{
                if( allValid && newSectionOpen ){
                    helper.createTowedUnitHelper( component, event, helper );
                }else if( towedunitRecord != undefined && towedunitRecord.Id != undefined && allValid ){
                    helper.createTowedUnitHelper( component, event, helper );
                }
            }
        }catch(ex){
            console.log(ex);
        }
        
    },

    deleteTowedUnit : function(component, event, helper) {
        var towId = event.getSource().get('v.name');
        helper.deleteTowedUnitHelper( component, event, helper, towId );
    },
})