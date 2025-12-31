({
	updateVehicleHelper : function(component, event, helper) {
		var action = component.get("c.updateVehicleAction");
        action.setParams({  
            vehicleObject : component.get("v.vehicleRecord")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    var vehicleRecord = component.get("v.vehicleRecord");
                    vehicleRecord['Id'] = response.vehicleId;
                    component.set("v.vehicleRecord",vehicleRecord);

                    //helper.showToast('Quote updated successfully.', 'success');
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
    
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
    
})