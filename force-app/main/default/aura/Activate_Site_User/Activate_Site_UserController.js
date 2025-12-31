({
    doInit : function(component, event, helper) {
        // window.open("https://at.mexinsurance.com/s/activateaccount", "_blank");
        // 
        helper.reloadPaeFirstTime(component, event, helper);
       
    },

    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        if( name == "Email"){
            let Emailvalue =  event.getParam("value");
            component.set("v.Email", Emailvalue);
        }
    },

    onNextClick : function(component, event, helper) {
        let getEmailValue = component.get("v.Email");
        
        let emailregx = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var allValid = helper.validateInputFields(component, event, helper);
        if(emailregx.test(getEmailValue)){
            
            let action = component.get('c.activateUser');
            
            action.setParams({email : getEmailValue});
            
            action.setCallback(this, function(response) {
                console.log("status : " +response.getState());
                if (response.getState() === 'SUCCESS'){
                    helper.showToast(response.getReturnValue(), 'Success');
                   	component.set("v.Email", '');
                }else{
                    component.set("v.Email", '');
                    helper.showError(response.getError());
                }
                
            });
            $A.enqueueAction(action);
        }
    },
})