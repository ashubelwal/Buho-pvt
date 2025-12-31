({
    initilizeData : function(component, event, helper) {
        helper.fetchEditPolicy(component, event, helper);
        helper.fetchRefundAmount(component, event, helper);
    },
    
    fetchRefundAmount : function(component, event, helper) {
        var action = component.get("c.refundCalculation");
        console.log("CA log action policy ID : "+  component.get("v.recordId"));
        
        action.setParams({ 
            'policyId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            console.log(JSON.stringify(response.getReturnValue()));
            //{"Data":324.11328}
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    console.log('---refundCalculation response---',JSON.stringify(response));
                    if (response.Data.policyType == 'Driver License' && response.Data.daysUsed <= 20) {
                        response.Data.total = response.Data.premium - ((response.Data.premium * response.Data.daysUsed)/365);
                        component.set("v.refundObj", response.Data);
                    } else if (response.Data.policyType == 'Driver License' && response.Data.daysUsed > 20) {
                        response.Data.total = 0;
                        component.set("v.refundObj", response.Data);
                    } else if (response.Data.policyType == 'Watercraft' && response.Data.daysUsed <= 20) {
                        response.Data.total = response.Data.premium * response.Data.daysUsed;
                        response.Data.premium = response.Data.premium * response.Data.daysUsed;
                        component.set("v.refundObj", response.Data);
                        component.set("v.refundWatercraft", response.Data.total - component.get("v.policyRecord").Net_Premium__c);
                    } else if (response.Data.policyType == 'Watercraft' && response.Data.daysUsed > 20) {
                        response.Data.total = 0;
                        component.set("v.refundObj", response.Data);
                        component.set("v.refundWatercraft", 0.00);
                    } else {
                        component.set("v.refundObj", response.Data);
                    }
                }
            }
        });
        $A.enqueueAction(action);

    },

    fetchEditPolicy : function(component, event, helper) {
        var action = component.get("c.fetchEditPolicyAction");
        action.setParams({ 
            'policyId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    console.log('---response---',JSON.stringify(response, null,4));
                    component.set("v.policyType", response.policyType);
                    var quoteRecord = response.quoteRecord;
                    component.set("v.quoteRecord", quoteRecord );
                    
                    var clonedquoteRecord =  Object.assign({}, quoteRecord);
                    component.set("v.clonedquoteRecord", clonedquoteRecord);
                    if( response.driverRecords != undefined && response.driverRecords != null ){
                        component.set("v.drivers", response.driverRecords);
                        console.log('drivers : ' + JSON.stringify(response.driverRecords));
                    } 
                    if( response.transactionRecords != undefined && response.transactionRecords != null ){
                        component.set("v.transactions", response.transactionRecords);
                    } 
                    if( response.watercraftRecords != undefined && response.watercraftRecords != null ){
                        component.set("v.watercrafts", response.watercraftRecords);
                    } 
                    if( response.vehicleRecords != undefined && response.vehicleRecords != null ){
                        component.set("v.vehicleRecord", response.vehicleRecords[0]);
                    }
                    
                    if( response.policyType == 'Automobile' ){
                        if( response.towedunitRecords != undefined && response.towedunitRecords != null ){
                            component.set("v.transporates", response.towedunitRecords);
                        }
                    }else{
                        if( response.towedunitRecords != undefined && response.towedunitRecords != null ){
                            component.set("v.towedunitRecord", response.towedunitRecords[0]);
                        } 
                    }
                    
                    component.set("v.editPolicyName", response.policyName);
                    component.set("v.policyRecord", response.policyRecord);
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },

    handleNextHelper : function(component, event, helper){
        try{
            var screenName = component.get("v.screenName");
            
            if( screenName == 'terminateDetails'){
                
                if (component.get("v.refundObj.total") == 0) {
                    helper.terminatePolicy(component, event, helper);
                } else {
                    helper.updateScreen(component, event, helper, 'paymentDetail');
                }
            }else if( screenName == 'paymentDetail'){
                console.log('Payementscreen call terminatane policy');
                helper.terminatePolicy(component, event, helper);
            }
        }catch(ex){
            console.log('exce---'+ex);
        }
    },

	updateScreen : function(component, event, helper, next){
        component.set("v.screenName", next);
    },

    terminatePolicy : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        var action = component.get("c.terminatedPolicy");
        action.setParams({ 
            'policyId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                console.log('Ca log call to go to detail page after succes response ');
                helper.goToDetailPage(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

	goToDetailPage : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        
		var pageName = '/policy/';
		var currentPagePrefix = '/policyedit';
		var urlString = window.location.href;
		var communityUrl = urlString.substring(0, urlString.indexOf(currentPagePrefix));
		console.log("communityUrl------->>>"+ communityUrl);
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({ 
			"url": (communityUrl + pageName + recordId)
		});
		urlEvent.fire();
        $A.get('e.force:refreshView').fire();
    },
})