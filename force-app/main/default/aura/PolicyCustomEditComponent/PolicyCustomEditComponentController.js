({
    init : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "policyedit",
                recordId: component.get("v.recordId")
            }  
        };  
        sessionStorage.setItem('policyId', component.get("v.recordId"));  
        console.log("CA log nevigation : "+ JSON.stringify(pageReference));
        navService.navigate(pageReference);
    },
    
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        helper.fetchRefundAmount(component, event, helper);
        helper.fetchPolicyInfo(component, event, helper);
    },

    showToolTip : function(component, event, helper) {
        component.set("v.tooltip" , true);
        
    },
    HideToolTip : function(component, event, helper){
        component.set("v.tooltip" , false);
    },

    goToterminate : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "terminatepolicy",
                recordId: component.get("v.recordId")
            }  
        };
        console.log("CA log record Id : ", JSON.stringify(component.get("v.recordId"), null, 4));
        sessionStorage.setItem('policyId', component.get("v.recordId"));
        navService.navigate(pageReference);
    },

    openModal : function(component, event, helper) {
        component.set("v.terminatePolicyPop", true);
    },

    closeModal : function(component, event, helper) {
        component.set("v.terminatePolicyPop", false);
    },

    terminate : function(component, event, helper) {
        component.set("v.terminatePolicyPop", false);
    },
    
    gotoPdfPage : function(component, event, helper) {
        helper.gotoPdfPageHelper( component, event, helper );
    },

    gottoReNewPolicy : function(component, event, helper) {
        console.log("CA log Renew Policy Calles from Policy Custom Edit component");
        console.log("CA log record Id ", JSON.stringify(component.get("v.recordId"), null, 4));
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "renewpolicy",
                recordId: component.get("v.recordId")
            }  
        };  
        sessionStorage.setItem('policyId', component.get("v.recordId"));  
        navService.navigate(pageReference);
    },
})