({
    updateLead : function( component, event, helper ) {
        const action = component.get("c.createOrUpdateHomeOwner");
        
        action.setParams({
            'leadrecord' :  JSON.stringify(component.get("v.leadRecord"))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    //helper.showToast('Home owner Created Successfully', 'success');
                    var url= 'https://sb.iigins.com/mexico-home-owners/quote/?aff_id=12151&agtdst=MMABK&office_code=';
                    window.open(url, "_blank");
                    window.open(window.location.origin, "_self");
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        
        $A.enqueueAction(action);

    },
    
    fetchPolicyData : function(component, event, helper){
        const action = component.get("c.initialize");

        action.setParams({
            'policyType' : 'HomeOwner',
            'quoteId' :  ''
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = JSON.parse(response.getReturnValue());
                //component.set("v.communityUser", response.loginUser);
                if( response && response.email && response.email != null ){
                    var leadRecord = component.get("v.leadRecord");
                    leadRecord['Email'] = response.email;
                    component.set("v.leadRecord", leadRecord);
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            mode: 'sticky',
            type: type,
            message: message
        }).fire();
    },
    
    validateInputFields : function(component, event, helper){
        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        return allValid;
    },
})