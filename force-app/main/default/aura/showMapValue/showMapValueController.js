({
	doInit : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                var mapObject = component.get('v.driverAgeUnder21');
                var mapKey = component.get('v.key');
                component.set("v.value",mapObject[mapKey]);
            }), 5000
        );
		
        //
	}
})