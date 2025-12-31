({
    fetchQuoteData : function(component, event, helper){
        const action = component.get("c.getQuoteRecord");

        action.setParams({
            'quoteId' :  component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                component.set("v.quoteRecord", response.getReturnValue());
            } else {
                console.log('--response---');
                console.log(response);
            }
        });

        $A.enqueueAction(action);
    }
})