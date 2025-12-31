({
	doInit : function(component, event, helper) {
        var policyId = sessionStorage.getItem( 'policyId' );
        console.log("CA lg Policy ID: ", policyId);
        var recordId = component.get("v.recordId");
        if( recordId == undefined ){
            component.set("v.recordId",policyId);
        }
        helper.initilizeData(component, event, helper);
		
    },
    
    handleBack : function(component, event, helper){
        var recordId = component.get("v.recordId");
        var pageName = '/policy/';
		var currentPagePrefix = '/terminatepolicy';
		var urlString = window.location.href;
		var communityUrl = urlString.substring(0, urlString.indexOf(currentPagePrefix));

		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({ 
			"url": (communityUrl + pageName + recordId)
		});
		urlEvent.fire();
        //window.open('/policy/'+recordId);
    },
    
    handleNext : function(component, event, helper) {
        helper.handleNextHelper(component, event, helper);
    },
    
    showDetail : function(component, event, helper){
        var toggleDetailOpen = component.get("v.toggleDetailOpen");
        var cmpTarget = component.find('toggleDetail'); 
        var showDetailButton = component.find('showDetailButton'); 
        if( toggleDetailOpen ){
            $A.util.removeClass(cmpTarget, 'detailsShow');
            $A.util.removeClass(showDetailButton, 'open');
        }else{
            $A.util.addClass(cmpTarget, 'detailsShow');
            $A.util.addClass(showDetailButton, 'open');
        }
        component.set("v.toggleDetailOpen", !toggleDetailOpen);
    },

    showSpinner : function (component, event, helper) {
        component.set("v.spinner", true);
    },
    
    hideSpinner : function (component, event, helper) {
        component.set("v.spinner", false);
    },
})