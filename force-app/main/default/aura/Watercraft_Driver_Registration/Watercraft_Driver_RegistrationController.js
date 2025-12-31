({
    doInit: function (component, event, helper) {
        helper.initializeData(component, event, helper);
    },

    addDriver: function (component, event, helper) {
        helper.createDriverHelper(component, event, helper, false);
    },

    onNextClick: function (component, event, helper) {
        var driverRecord = component.get("v.driverRecord");
        if (driverRecord.First_Name__c || driverRecord.Last_Name__c) {
            helper.createDriverHelper(component, event, helper, true);
        } else {
            $A.enqueueAction(component.get("v.onNextClick"));
        }
    }
})