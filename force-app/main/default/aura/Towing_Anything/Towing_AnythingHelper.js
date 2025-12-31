({
    updateQuoteHelper : function( component, event, helper ) {
        const action = component.get('c.handleQuocteAction');
        console.log("CA Log add tow --- ", JSON.stringify(component.get("v.quoteRecord"), null, 4));
        action.setParams({
            quoteRecord: component.get("v.quoteRecord")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    var quoteRecord = component.get("v.quoteRecord");
                    quoteRecord['Id'] = response.quoteId;
                    component.set("v.quoteRecord",quoteRecord);
                    
                    $A.enqueueAction(component.get("v.onNextClick"));
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    deleteTowedHelper: function( component, event, helper ) {
        const action = component.get('c.handleDeleteTowedUnitAction');
        action.setParams({
            quoteRecord: component.get("v.quoteRecord")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    var transporates = [];
                    component.set("v.transporates",transporates);
                    component.set("v.towedunitRecord",{ 'sobjectType': 'Towed_Unit__c'});
                    helper.updateQuoteHelper(component, event, helper);
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
})