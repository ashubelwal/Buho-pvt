({
	doInit : function(component, event, helper) {
        console.log('here--doinit');
        var quoteRecord = component.get("v.quoteRecord");
        if( !( quoteRecord.Towed_Unit__c && quoteRecord.Towed_Unit__c != null ) ){
            quoteRecord['Towed_Unit__c'] = 'No';
            component.set("v.quoteRecord", quoteRecord);
        }
        
	},
    
    onGroup : function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        var quoteRecord = component.get("v.quoteRecord");
        quoteRecord['Towed_Unit__c'] = selected;
        component.set("v.quoteRecord", quoteRecord);
    },
    
    onNextClick : function(component, event, helper) {
        try{
            var iscloneConditionPass = component.get("v.iscloneConditionPass")
            var renewPolicy = component.get("v.renewPolicy");
            console.log('--iscloneConditionPass--'+iscloneConditionPass);
            if( iscloneConditionPass != undefined && iscloneConditionPass == true ){
                $A.enqueueAction(component.get("v.onNextClick"));
            }else{
                var quoteRecord = component.get("v.quoteRecord");
                if( quoteRecord.Towed_Unit__c != undefined && quoteRecord.Towed_Unit__c == 'No'){
                    helper.deleteTowedHelper(component, event, helper);
                }else{
                    helper.updateQuoteHelper(component, event, helper);
                }
            }  
        }catch( ex ){
            console.log(ex);
        }
    }
})