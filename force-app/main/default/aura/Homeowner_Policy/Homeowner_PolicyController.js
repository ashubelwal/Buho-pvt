({
	updateValue : function(component, event, helper) {
		var name = event.getSource().get("v.name");
        var leadRecord = component.get("v.leadRecord");        
        leadRecord[name] = event.getParam("value"); 
        component.set("v.leadRecord", leadRecord);
	},
    
    onNextClick : function(component, event, helper) {
        var allValid = helper.validateInputFields(component, event, helper);
        if( allValid ){
            helper.updateLead(component, event, helper);
        }
    },
    
    doInit: function(component, event, helper) {
        helper.fetchPolicyData(component, event, helper);
    },
})