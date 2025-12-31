({
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        console.log("CA Log name "+ name);
        var towedunitRecord = component.get("v.towedunitRecord");
        var value = event.getParam("value");
         towedunitRecord[name] = value;
        component.set("v.iscloneConditionPass", true);
        if( name && ( name == 'Plate__c' || name == 'VIN_Number__c' ) && value && value.length > 0 ){
             if(/^\s/.test(value)){
                value = '';
            }
            value = value.toUpperCase();
            towedunitRecord[name] = value;
        }
        if((name == 'Model__c' || name == 'Make__c') && value && value.length > 0){
            if(/^\s/.test(value)){
                value = '';
            }
        } 
        if((name == 'Towed_Unit_Value__c') && value && value.length > 0){
            if(/-(?=\d)/.test(value)){
                value = '';
            }
        }
        towedunitRecord[name] = value;
        let Towed_Unit_TypeValue = '';
        if(name == 'Towed_Unit_Type__c' ){
            if(event.getParam("value") == 'Boat'){
                component.set("v.fieldShowForBoat", true);
                
            }else{
                towedunitRecord['Vessel_Length__c'] = '';
                towedunitRecord['Type_of_Vessel__c'] = '';
                component.set("v.fieldShowForBoat", false);
                
            }
             
        }
        if( name == "Type_of_Vessel__c"){
            console.log("value of type if vessel : "+ value);
            towedunitRecord[name] = value;
            console.log('towedunitRecord[name] ',towedunitRecord[name])
            if(value == 'Personal Watercraft (Jet Ski)'){
               towedunitRecord['Vessel_Length__c'] = ''; 
            }
            
            
            helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths', false);
        }
        if( name == 'Towed_Unit_Type__c' && event.getParam("value") == 'Utility/Misc Trailer'){
            towedunitRecord['Street_Legal__c'] = 'No';
        }else if( name == 'Street_Legal__c'){
            if(towedunitRecord['Towed_Unit_Type__c'] == 'Utility/Misc Trailer' && towedunitRecord['Street_Legal__c'] == 'Yes'){
                towedunitRecord['Street_Legal__c'] = 'No';
            }
        }
        
        component.set("v.towedunitRecord", towedunitRecord);
    },
    
    doInit : function(component, event, helper) {
        var daysInTow = 'How many days will the towed unit be attached to the towing vehicle?  You’ll only be charged the additional towing premium for those days in tow (as opposed to the entire term).  Keep in mind that with Qualitas and Mapfre, when a towed unit is detached from the towing vehicle, it no longer has coverage.  If you select Chubb, your towed trailer will have coverage even after it is detached if you match “days in tow” with the term.  If you are towing a travel trailer and select Chubb you should match the “Days in Tow” with the Term of the Policy.  Example 365 day policy, days in tow = 365.';
        component.set("v.daysInTwo", daysInTow);
        console.log("CA log call do init 1st log");
        helper.initilizeData(component, event, helper);
         console.log("CA log call do init 2nd log");
        
    },
    onRender : function(cmp, evt, helper){
        console.log("CA log doRendder towedunitRecord");
        let towedunitRecord = cmp.get("v.towedunitRecord");
         let fieldShowForBoat = cmp.get("v.fieldShowForBoat");
         console.log("CA log doRendder towedunitRecord "+ JSON.stringify(towedunitRecord, null, 4));
    if (towedunitRecord['Type_of_Vessel__c'] != '' && towedunitRecord['Type_of_Vessel__c'] != null && towedunitRecord['Type_of_Vessel__c'] != undefined) {
            console.log('select lhdfhdf: --',towedunitRecord['Type_of_Vessel__c']);
           
        if(fieldShowForBoat){
            helper.getDependentPicklistValues(cmp, evt, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths', true);
        }
        }
    },
    
    validateInputFields : function(component, event, helper){
        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        return allValid;
    },
    
})