({
	updateValue : function(component, event, helper) {
		var name = event.getSource().get("v.name");
        var vehicleRecord = component.get("v.vehicleRecord");  
        var value = event.getParam("value");
        console.log("value-->");
        if(/^\s/.test(value)){
                value = '';
         }
        vehicleRecord[name] = value; 
         
        component.set("v.vehicleRecord", vehicleRecord);
	},
    
    onNextClick : function(component, event, helper) {
        helper.updateVehicleHelper(component, event, helper);
    },
})