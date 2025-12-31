({
    doInit : function(component, event, helper) {
        helper.initilizeData(component, event, helper);
    },
    
    handleBack : function(component, event, helper) {
        helper.handleBackHelper(component, event, helper);
    },
    
    handleNext : function(component, event, helper) {
        helper.handleNextHelper(component, event, helper);
    },

    editWatercraft : function(component, event, helper) {
        helper.updateScreen(component, event, helper, 'waterCraftDetail');
    },

    editDriver : function(component, event, helper) {
        helper.updateScreen(component, event, helper, 'RegisteredVehicle');
    },

    editRateData : function(component, event, helper) {
        helper.updateScreen(component, event, helper, 'QuickQuote');
    },
})