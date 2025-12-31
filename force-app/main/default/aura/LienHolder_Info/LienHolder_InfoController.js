({
	doInit : function(component, event, helper) {
		helper.initilizeData(component, event, helper);
        //component.set("v.vehicleRecord.Lienholder_Country__c", "USA");
	},
    
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var vehicleRecord = component.get("v.vehicleRecord");
        var value = event.getParam("value");
        if( ( name == 'Lienholder_Phone__c' || name == 'Lienholder_Fax__c' ) && value && value.length > 0 ){
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        }
        if(/^\s/.test(value)){
                value = '';
            }
        vehicleRecord[name] = value;
        component.set("v.vehicleRecord", vehicleRecord);
    },

    onCountryChange : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var value = event.getParam("value");
        var vehicleRecord = component.get("v.vehicleRecord");
        if( value && value != 'Other'){
            vehicleRecord[name] = value;
            helper.setCountryAndStates(component, event, helper, value );
            component.set("v.showStatePick", true);
        }else{
            vehicleRecord[name] = '';
            component.set("v.showStatePick", false);
        }
        component.set("v.vehicleRecord", vehicleRecord);
    },

    onNextClick : function(component, event, helper) {
        var allValid = helper.validateInputFields(component, event, helper);
        if( allValid ){
            helper.updateVehicleHelper(component, event, helper);
        }
    }
})