({
    handleInit: function(component, event, helper) {
        helper.initialize(component, event);
        console.log("Final_total_Premium-->"+component.get("v.Final_total_Premium"));
    },

    onCountryChange : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var value = event.getParam("value");
        var newCreditCard = component.get('v.newCreditCard');
        if( value && value != 'Other'){
            newCreditCard[name] = value;
            helper.setCountryAndStates(component, value );
            component.set("v.showStatePick", true);
        }else{
            newCreditCard[name] = null;
            component.set("v.showStatePick", false);
        }
        component.set("v.newCreditCard", newCreditCard);
    },

    handlePayment: function (component, event, helper) {
        
       var finalTotalPremium = component.get("v.Final_total_Premium");
        
        console.log("Final_total_Premium :: "+finalTotalPremium);
        helper.makePayment(component, event);
    },

    handleAddCard: function (component, event, helper) {
        helper.showCardForm(component, event);
    },

    handleCardChange: function (component, event, helper) {
        helper.selectNewCard(component, event);
    },

    handleSetAddress: function (component, event, helper) {
        helper.setAddress(component, event);
    },

});