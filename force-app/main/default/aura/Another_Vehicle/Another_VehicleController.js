({
	onGroup : function(component, event, helper) {
		var selected = event.getSource().get("v.text");
        component.set("v.anotherVehicle",selected);
	}
})