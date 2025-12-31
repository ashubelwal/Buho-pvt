({
    init : function(component, event, helper) {
        helper.fetchQuoteData(component, event, helper);
    },

    redirectToQuickQuote : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: 'The feature is currently unavailable. We regret for the inconvenience caused!',
        });
        toastEvent.fire();
        /*var policyTypePageMap = new Map();
        policyTypePageMap.set('Northbound', 'Northbound__c');
        policyTypePageMap.set('Watercraft', 'Watercraft__c');
		policyTypePageMap.set('RV', 'rv__c');
        policyTypePageMap.set('Motorcycle/Street Legal ATV', 'motorcycle__c');
        policyTypePageMap.set('Driver License', 'drivers_license__c');
        policyTypePageMap.set('Automobile', 'automobile__c');
        var quoteRecord = component.get("v.quoteRecord");
        
        var pageName = policyTypePageMap.get(quoteRecord.Policy_Type_picklist__c);
        
        if ( pageName ) {
            var navService = component.find("navService");

            var pageReference = {
                "type" : "comm__namedPage",
                "attributes" : {
                    "name" : pageName
                },
                "state" : {
                    "c__ID" : quoteRecord.Id
                }
            };
            event.preventDefault();
            navService.navigate(pageReference);
        }*/
    },
})