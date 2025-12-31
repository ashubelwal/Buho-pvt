({  
    fetchRefundAmount : function(component, event, helper) {
        var action = component.get("c.refundCalculation");
        action.setParams({ 
            'policyId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            console.log(JSON.stringify(response.getReturnValue()));
            //{"Data":324.11328}
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    console.log('---refundCalculation response---',JSON.stringify(response));
                    
                    if( response.error != undefined && response.error != null ){
                        var msg = response.error;
                        var button = component.find("terminateButtonId");
                        button.set('v.disabled',true);
                        component.find("terminateButtonHelpTextId").set("v.content", msg);
                    }

                    if( response.Data != undefined ){
                        var res = response.Data;
                        //console.log(res.oldPremium);
                        if(res.total != undefined && res.oldPremium != undefined && res.total > res.oldPremium){
                            console.log(' disable button ');
                            var msg = "Terminating this policy and re-rating your days at the daily rate would result in underpayment by you. This policy is fully earned.";
                            var button = component.find("terminateButtonId");
                            button.set('v.disabled',true);
                            component.find("terminateButtonHelpTextId").set("v.content", msg);
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);

    },
    
    fetchPolicyInfo : function(component, event, helper) {
        var action = component.get("c.fetchPolicyInfo");
        action.setParams({ 
            'policyId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            console.log(JSON.stringify(response.getReturnValue()));
            //{"Data":324.11328}
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response != null ){
                    let todaysDate = new Date();
                    if( response.Status_picklist__c != undefined && response.Status_picklist__c != 'Active' ){
                        var button = component.find("editButtonId");
                        button.set('v.disabled',true);
                        
                        var button = component.find("terminateButtonId");
                        button.set('v.disabled',true);
                        
                    }else if( response.End_Date__c != undefined && response.End_Date__c < todaysDate){
                        var button = component.find("editButtonId");
                        button.set('v.disabled',true);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    gotoPdfPageHelper : function(component, event, helper) {
        var action = component.get("c.preViewPdfAction");
        action.setParams({ 
            'policyId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response != null ){
                    console.log('-response---'+response);
                    window.open(response, "_blank");
                }
            }
        });
        $A.enqueueAction(action);
    },
})