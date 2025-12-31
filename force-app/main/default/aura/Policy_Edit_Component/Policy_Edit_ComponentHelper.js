({
	initilizeData : function(component, event, helper) {
		helper.fetchEditPolicy(component, event, helper);
	},


	fetchEditPolicy : function(component, event, helper) {
		console.log('---here--fetchEditPolicy');
		var action = component.get("c.fetchEditPolicyAction");
        action.setParams({ 
			'policyId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
				// console.log("CA log response : "+ JSON.stringify(response.getReturnValue()));
                if( response.success){
                    console.log('---response---',JSON.stringify(response, null , 4));
					component.set("v.policyType", response.policyType);
					var quoteRecord = response.quoteRecord;
					component.set("v.quoteRecord", quoteRecord );
					if( quoteRecord.Term__c == 'Annual(One Year)'){
						component.set("v.annualTerm", true);
					}
					var clonedquoteRecord =  Object.assign({}, quoteRecord);
					component.set("v.clonedquoteRecord", clonedquoteRecord);
					component.set("v.oldQuoteId", quoteRecord.Id);
					if( response.driverRecords != undefined && response.driverRecords != null ){
						component.set("v.drivers", response.driverRecords);
						console.log('drivers : ' + JSON.stringify(response.driverRecords));
					} 
					if( response.transactionRecords != undefined && response.transactionRecords != null ){
						component.set("v.transactions", response.transactionRecords);
						component.set("v.transactionRecord", response.transactionRecords[0]);
					} 
					if( response.watercraftRecords != undefined && response.watercraftRecords != null ){
						component.set("v.watercrafts", response.watercraftRecords);
						component.set("v.watercraftRecord", response.watercraftRecords[0]);
					} 
					if( response.vehicleRecords != undefined && response.vehicleRecords != null ){
						component.set("v.vehicleRecord", response.vehicleRecords[0]);
						component.set("v.clonedvehicleRecord", Object.assign({}, response.vehicleRecords[0]));
						
					}

					if( response.policyType == 'Automobile' || response.policyType == 'RV' ){
						console.log('---response.towedunitRecords---',response.towedunitRecords);
						if( response.towedunitRecords != undefined && response.towedunitRecords != null && response.towedunitRecords.length > 0){
							component.set("v.transporates", response.towedunitRecords);
						}
					}else{
						if( response.towedunitRecords != undefined && response.towedunitRecords != null && response.towedunitRecords.length > 0 ){
							component.set("v.towedunitRecord", response.towedunitRecords[0]);
						} 
					}
					
					var transporates = component.get("v.transporates");
					console.log('v.transporates'+JSON.stringify(transporates));
					component.set("v.editPolicyName", response.policyName);
					component.set("v.policyRecord", response.policyRecord);
					console.log('--response.policyRecord---'+JSON.stringify(response.policyRecord));
					component.set("v.screenName", 'TermOptions');
					
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

	handleBackHelper : function(component, event, helper){
		try{
			var policyType = component.get("v.policyType");
			var quoteObject = component.get("v.quoteRecord");
			var vehicleObject = component.get("v.vehicleRecord");
			var screenName = component.get("v.screenName");
			
			if( screenName == 'TermOptions'){
				//helper.updateScreen(component, event, helper, 'ReviewVehicle');
			}else if( screenName == 'ReviewVehicle' ){
				helper.updateScreen(component, event, helper, 'TermOptions');
			}else if( screenName == 'ReviewWatercraft' ){
				helper.updateScreen(component, event, helper, 'TermOptions');
			}else if( screenName == 'RegisteredVehicle' ){
				if (policyType === 'Watercraft') {
					helper.updateScreen(component, event, helper, 'ReviewWatercraft');
					return;
				}
                if (policyType === 'Driver License') {
                    helper.updateScreen(component, event, helper, 'TermOptions');
                    return;
                }
				helper.updateScreen(component, event, helper, 'ReviewVehicle');
			}else if( screenName == 'TowningAnything' ){
				helper.updateScreen(component, event, helper, 'RegisteredVehicle');
			}else if( screenName == 'TowningInfo' ){
				helper.updateScreen(component, event, helper, 'RegisteredVehicle');
			}else if( screenName == 'confirmScreen'  ){
				if (policyType === 'Driver License' || policyType === 'Watercraft' || policyType == 'Motorcycle/Street Legal ATV') {
					helper.updateScreen(component, event, helper, 'RegisteredVehicle');
				}else{
					var towedunitRecord = component.get("v.towedunitRecord");
					var transporates = component.get("v.transporates");
					console.log('-transporates--'+transporates);
					console.log('-towedunitRecord--'+towedunitRecord);
					if( policyType == 'Northbound' && ( towedunitRecord == undefined || towedunitRecord.Id == undefined ) ){
						helper.updateScreen(component, event, helper, 'TowningAnything');
					}else if(  policyType != 'Northbound' && policyType != 'WaterCraft' && ( transporates == undefined 
							|| transporates.length == undefined || transporates.length == 0 ) ){
						helper.updateScreen(component, event, helper, 'TowningAnything');
					}else{
						helper.updateScreen(component, event, helper, 'TowningInfo');
					}
				}
				
			}else if( screenName == 'PaymentDetail'  ){
				helper.updateScreen(component, event, helper, 'confirmScreen');
			}
		}catch( ex ){
			console.log('-ex--',ex);
		}	
    },

	handleNextHelper : function(component, event, helper){
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var vehicleRecord = component.get("v.vehicleRecord");
            
            var screenName = component.get("v.screenName");
            var nextScreen;

			var policyType = component.get("v.policyType");

			if( screenName == 'TermOptions'){
				if (policyType === 'Driver License') {
					helper.updateScreen(component, event, helper, 'RegisteredVehicle');
					return;
				}
				if (policyType == 'Watercraft') {
					helper.updateScreen(component, event, helper, 'ReviewWatercraft');
					return;
				}
				helper.updateScreen(component, event, helper, 'ReviewVehicle');
			}else if( screenName == 'ReviewVehicle' || screenName == 'ReviewWatercraft' ){
				helper.updateScreen(component, event, helper, 'RegisteredVehicle');
			}else if( screenName == 'RegisteredVehicle' ){
				if (policyType == 'Driver License' || policyType == 'Watercraft' || policyType == 'Motorcycle/Street Legal ATV') {
					helper.updateScreen(component, event, helper, 'confirmScreen');
					return;
				}
				try{
					var towedunitRecord = component.get("v.towedunitRecord");
					var transporates = component.get("v.transporates");
					if( policyType == 'Northbound' && ( towedunitRecord == undefined || towedunitRecord.Id == undefined ) ){
						helper.updateScreen(component, event, helper, 'TowningAnything');
					}else if(  policyType != 'Northbound' && policyType != 'WaterCraft' && ( transporates == undefined 
							|| transporates.length == undefined || transporates.length == 0 ) ){
						helper.updateScreen(component, event, helper, 'TowningAnything');
					}else{
						helper.updateScreen(component, event, helper, 'TowningInfo');
					}
				}catch( ex ){
					console.log('--ex--',ex);
				}
			}else if( screenName == 'TowningAnything' ){
				if( quoteRecord != undefined && quoteRecord.Towed_Unit__c != undefined && quoteRecord.Towed_Unit__c == 'Yes'){
					helper.updateScreen(component, event, helper, 'TowningInfo');
				}else{
					helper.updateScreen(component, event, helper, 'confirmScreen');
				}
			}else if( screenName == 'TowningInfo' ){
				helper.updateScreen(component, event, helper, 'confirmScreen');
			}else if( screenName == 'confirmScreen' ){
				var refundAmount = component.get("v.refundAmount");
                console.log('CA log refundAmount --->'+ refundAmount);
				var iscloneConditionPass = component.get("v.iscloneConditionPass");
				console.log('--refundAmount-' + refundAmount);
        		console.log('--iscloneConditionPass-' + iscloneConditionPass);
				if(( refundAmount >= 1 || refundAmount <= -1)){
                    console.log(' comes inside first condition');
					helper.updateScreen(component, event, helper, 'PaymentDetail');
				}else if( iscloneConditionPass ) {
                    console.log(' comes inside second condition');
					helper.createNewPolicy( component, event, helper );
				}else{
                    console.log(' comes inside third condition');
					helper.goToDetailPage(component, event, helper);
				}
			}else if( screenName == 'PaymentDetail' ) {
				helper.goToDetailPage(component, event, helper);
			}
            
        }catch(ex){
            console.log('exce---'+ex);
        }
    },

	createNewPolicy : function(component, event, helper){
		var quoteRecord = component.get("v.quoteRecord");
        var oldQuoteId = component.get("v.oldQuoteId");
		console.log('--oldQuoteId--'+oldQuoteId);
		console.log('--quoteRecord--',quoteRecord);

		var action = component.get("c.createPolicy");
        action.setParams({ 
            'quoteRecord' : quoteRecord,
            'oldQuoteId' : oldQuoteId,
            'IsRenew': false
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                console.log("CA log response ", response);
                if( response.success){
                    console.log("CA log Inside response success");
                    component.set("v.newPolicyId",response.policyNewId);
                    helper.goToDetailPage(component, event, helper);
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
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

	updateScreen : function(component, event, helper, next){
        console.log('----next-->'+next);
    	component.set("v.screenName", next);
    },

    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            mode: 'sticky',
            type: type,
            message: message
        }).fire();
    },

	goToDetailPage : function(component, event, helper) {
		console.log('goToDetailPage start');
		var recordId = component.get("v.recordId");

		//added by dev to redirect to new policy record
		var newPolicyId = component.get("v.newPolicyId");
		if( newPolicyId !=  undefined && newPolicyId != null ){
			recordId = newPolicyId;
		}
        
		var pageName = '/policy/';
		var currentPagePrefix = '/policyedit';
		var urlString = window.location.href;
		var communityUrl = urlString.substring(0, urlString.indexOf(currentPagePrefix));

		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({ 
			"url": (communityUrl + pageName + recordId)
		});
		urlEvent.fire();
    },
})