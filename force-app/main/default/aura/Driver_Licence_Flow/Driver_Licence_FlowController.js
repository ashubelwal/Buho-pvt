({
    doInit: function (component, event, helper) {
        helper.initData(component, event, helper);
    },

    handleNext: function (component, event, helper) {
        helper.handleNextHelper(component, event, helper);
    },

    handleBack: function (component, event, helper) {
        helper.handleBackHelper(component, event, helper);
    },

    showSpinner: function (component) {
        component.set("v.spinner", true);
    },

    hideSpinner: function (component) {
        component.set("v.spinner", false);
    },
})