({
	doInit : function(component, event, helper) {
        var policyId = sessionStorage.getItem( 'policyId' );
        var recordId = component.get("v.recordId");
        if( recordId == undefined ){
            component.set("v.recordId",policyId);
        }
        component.set("v.countVehicle", parseInt('1'));
        //component.set("v.screenName", 'TermOptions');
        helper.initilizeData(component, event, helper);
		console.log('-- quoterecord--'+ JSON.stringify(component.get("v.quoteRecord")));
    },

	handleNext : function(component, event, helper){							
        helper.handleNextHelper(component, event, helper);
    },

    handleBack : function(component, event, helper){
        helper.handleBackHelper(component, event, helper); 
    },

    showSpinner : function (component, event, helper) {
        component.set("v.spinner", true);
    },
    
    hideSpinner : function (component, event, helper) {
        component.set("v.spinner", false);
    },
})