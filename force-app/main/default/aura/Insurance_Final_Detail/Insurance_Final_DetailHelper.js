({
    initilizeData : function(component, event, helper) {
        // helper.fetchPicklist( component, event, helper , 'Policy__c', 'What_is_your_trip_destination_in_US__c', 'v.usDestinations');
        helper.getDependentPicklistValues(component, event, helper, 'Policy_Type_picklist__c', 'What_is_your_trip_destination_in_US__c', 'v.usDestinations');
        helper.fetchPicklist( component, event, helper , 'Policy__c', 'What_is_the_purpose_of_trip__c', 'v.tripPurposes');
        helper.fetchPicklist( component, event, helper , 'contact', 'How_did_you_hear_about_us__c', 'v.aboutusOption');
		var quoteIds = component.get("v.quoteIds");
        console.log('-quoteIds---',quoteIds);
        if (component.get("v.policyType") === 'Watercraft' || component.get("v.policyType") === 'Driver License'
            || component.get("v.policyType") === 'Automobile' || component.get("v.policyType") === 'RV' 
            || component.get("v.policyType") === 'Motorcycle/Street Legal ATV' || component.get("v.policyType") === 'Northbound') {
            console.log('initilizeData');
            if( quoteIds != null && quoteIds.length > 0){
                helper.getQuoteHelper(component, event, helper, quoteIds[0]);
            }else{
                component.set("v.underwriter", 'Chubb');
                helper.getLegalTerm(component, event, helper);
            }
        }
    },
    
    getQuoteHelper : function(component, event, helper, quoteId){
        var action = component.get("c.getQuoteRecord");
        
        action.setParams({ 'quoteId' : quoteId }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('--result--',result);
                if( result != null && result.Underwriter__c ){
                    component.set("v.underwriter", result.Underwriter__c );
                }else{
                    component.set("v.underwriter", 'Chubb');
                }
                helper.getLegalTerm(component, event, helper);
            }
        });
        $A.enqueueAction(action);
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

    getDependentPicklistValues : function(component, event, helper, controllingField, dependentField, fieldAttr) {
        var action = component.get("c.getDependentMap");
        var policyRecord = component.get("v.policyRecord");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function
        action.setParams({
            'objDetail' : policyRecord,
            'contrfieldApiName': controllingField,
            'depfieldApiName': dependentField
        });
        //set callback
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)
                var storeResponse = response.getReturnValue();
                var policyType = component.get("v.policyType");
                if(policyType != null && storeResponse && storeResponse[policyType] != null ){
                    var options = [];
                    storeResponse[policyType].forEach(function(item){
                        /**logic here !*/
                        options.push({
                            'label':item,
                            'value':item
                        })
                    });
                    component.set(fieldAttr, options);
                }
            }
        });
        $A.enqueueAction(action);
    },

    updatePolicyRecord : function(component, event, helper) {
        var rateRecordList =  component.get("v.rateRecordList");
        
        var leadList = [];
        rateRecordList.forEach(function(item){
            leadList.push(item.leadId);
        });
        
        const action = component.get("c.updatePolicyAction");
        action.setParams({  
            contactRecord : component.get("v.contactRecord"),
            policyRecord : component.get("v.policyRecord"),
            leadIds : JSON.stringify(leadList),
            quoteIds : JSON.stringify(component.get('v.quoteIds'))
        });
        
        action.setCallback(this, function(response) {
            console.log('----response----'+JSON.stringify(response));
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    component.set("v.policyMapList", response.policyMapList);
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
    
    validateInputFields : function(component, event, helper){

        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        return allValid;
    },

    getLegalTerm : function(component, event, helper){
        var action = component.get("c.retrieveLegalTermDetails");

        action.setParams({
            'policyType'  : component.get("v.policyType"),
            'underwriter' : component.get("v.underwriter")
        });
        //set callback
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)
                var legalTerm = response.getReturnValue();
                console.log('legalTerm');
                console.log(legalTerm);

                if( legalTerm ){
                    component.set("v.legalTermRecord", legalTerm);
                }
            } else {
                helper.showToast(response.getError(), 'error');
                console.log('retrieveLegalTermDetails error: ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})