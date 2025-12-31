({
    initilizeData : function(component, event, helper) {
        // helper.fetchPicklist( component, event, helper , 'Policy__c', 'What_is_your_trip_destination_in_US__c', 'v.usDestinations');
        helper.getDependentPicklistValues(component, event, helper, 'Policy_Type_picklist__c', 'What_is_your_trip_destination_in_US__c', 'v.usDestinations');
        helper.fetchPicklist( component, event, helper , 'Policy__c', 'What_is_the_purpose_of_trip__c', 'v.tripPurposes');
        helper.fetchPicklist( component, event, helper , 'contact', 'How_did_you_hear_about_us__c', 'v.aboutusOption');

        var contact = component.get("v.contactRecord");
        if (contact['Newsletter__c'] == null) {
            contact['Newsletter__c'] = 'No';
        }
        if (contact['Announcements__c'] == null) {
            contact['Announcements__c'] = 'No';
        }
        if (contact['Travel_Alerts__c'] == null) {
            contact['Travel_Alerts__c'] = 'No';
        }
        component.set("v.contactRecord", contact);

        if (component.get("v.policyType") == 'Watercraft') {
            console.log('initilizeData');
            component.set("v.underwriter", 'Chubb');
            helper.getLegalTerm(component, event, helper);
        }
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
            }
        });
        $A.enqueueAction(action);
    },
})