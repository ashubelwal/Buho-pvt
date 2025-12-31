({
    updateScreen : function(component, event, helper, next){
        console.log('----next-->'+next);
        if( next != null && next != ''){
            console.log("onNextClick---"+next);
            $A.enqueueAction(component.get("v.onNextClick"));
        }
    },
    checkAllreadyUser : function( component, event, helper){
        const action = component.get('c.checkalreadyExistUserAction');
        let leadRecord = component.get("v.leadRecord");
      
        //let email = component.get("v.emailAdder")
        action.setParams({
            emailAdder: leadRecord.Email,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.isExistUser){
                    //helper.showToast('Please login to create a policy.', 'error');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Please login to create a policy.',
                        messageTemplate: 'Please login to quote a policy. {0}!',
                        messageTemplateData: [{
                            url: 'https://at.mexinsurance.com/login/',
                            label: 'Click here',
                        }
                                             ]
                    });
                    toastEvent.fire();
                }else{ 
                    
                    helper.updateScreen(component, event, helper, 'VehicleOptions');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    validateInputFields : function(component, event, helper){
        let allValid = true; 
        try{
            allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }catch(ex){
            console.log("--error user detail helper - validate helper ---"+ ex);
        }
        return allValid;
    },
})