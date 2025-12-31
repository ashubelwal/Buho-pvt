({
	initilizeData : function(component, event, helper) {
		helper.fetchEditPolicy(component, event, helper, 'TermOptions');
	},


	fetchEditPolicy : function(component, event, helper, nextScreen) {
		var action = component.get("c.fetchEditPolicyAction");
        action.setParams({ 
			'policyId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
					component.set("v.policyType", response.policyType);
                    var quoteRecord = response.quoteRecord;
					component.set("v.oldQuoteId", quoteRecord.Id);
					if( quoteRecord.Renew_Quote__c == undefined || quoteRecord.Renew_Quote__c == null  ){
						quoteRecord['Quote_Value__c']       = 0;
						quoteRecord['Net_Premium__c']       = 0;
						quoteRecord['Surcharge__c']         = 0;
						quoteRecord['I_V_A_Mex_Tax__c']     = 0;
						quoteRecord['Broker_Policy_Fee__c'] = 0;

                        let todaysDate = new Date();
						let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']);

                        if (endDayForCoverage < todaysDate) {
                            endDayForCoverage = todaysDate;
                        }
						let startDayForCoverage = endDayForCoverage;
						startDayForCoverage.setDate(startDayForCoverage.getDate() + 1);
						quoteRecord['Start_Date_for_Coverage__c'] = $A.localizationService.formatDate(startDayForCoverage, "YYYY-MM-DD");
	
						let termsdays = quoteRecord.Term_Days__c;
						startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
						endDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
						if( termsdays != null ){
							endDayForCoverage.setDate(endDayForCoverage.getDate() + parseInt(termsdays));
							quoteRecord['End_Date_for_Coverage__c'] = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
						}

						if( quoteRecord.Term__c == 'Annual(One Year)'){
							component.set("v.annualTerm", true);
						}
						component.set("v.quoteRecord",quoteRecord);

						var clonedquoteRecord =  Object.assign({}, quoteRecord);
						if( response.driverRecords != undefined && response.driverRecords != null ){
							component.set("v.drivers", response.driverRecords);
						} 
						if( response.transactionRecords != undefined && response.transactionRecords != null ){
							component.set("v.transactions", response.transactionRecords);
							component.set("v.transactionRecord", response.transactionRecords[0]);
						}

						if( response.vehicleRecords != undefined && response.vehicleRecords != null ){
							component.set("v.vehicleRecord", response.vehicleRecords[0]);
							component.set("v.clonedvehicleRecord", Object.assign({}, response.vehicleRecords[0]));
							
						}
                        
                        if( response.watercraftRecords != undefined && response.watercraftRecords != null ){
                            component.set("v.watercrafts", response.watercraftRecords);
                            component.set("v.watercraftRecord", response.watercraftRecords[0]);
                        }
	
						if( response.policyType == 'Automobile' || response.policyType == 'RV' ){
							if( response.towedunitRecords != undefined && response.towedunitRecords != null && response.towedunitRecords.length > 0){
								component.set("v.transporates", response.towedunitRecords);
							}
						}else{
							if( response.towedunitRecords != undefined && response.towedunitRecords != null && response.towedunitRecords.length > 0 ){
								component.set("v.towedunitRecord", response.towedunitRecords[0]);
							} 
						}
						component.set("v.screenName", nextScreen);
					}else{
						helper.fetchRenewQuoteData( component, event, helper, quoteRecord.Renew_Quote__c, nextScreen );
					}
					 
					if( response.watercraftRecords != undefined && response.watercraftRecords != null ){
						component.set("v.watercrafts", response.watercraftRecords);
						component.set("v.watercraftRecord", response.watercraftRecords[0]);
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

	fetchRenewQuoteData : function(component, event, helper, newQuoteId, nextScreen) {
		var action = component.get("c.fetchRenewPolicyAction");
        action.setParams({ 
			'renewQuoteId' : newQuoteId
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
					var quoteRecord = response.quoteRecord;
					quoteRecord['Quote_Value__c']       = 0;
					quoteRecord['Net_Premium__c']       = 0;
					quoteRecord['Surcharge__c']         = 0;
					quoteRecord['I_V_A_Mex_Tax__c']     = 0;
					quoteRecord['Broker_Policy_Fee__c'] = 0;
                    
                    let todaysDate = new Date();
                    let endDayForCoverage;
                    let startDayForCoverage;
                    if (response.policyExist) {
                        endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']);
                        if (endDayForCoverage < todaysDate) {
                            endDayForCoverage = todaysDate;
                        }
                        startDayForCoverage = endDayForCoverage;
                        startDayForCoverage.setDate(startDayForCoverage.getDate() + 1);
                        quoteRecord['Start_Date_for_Coverage__c'] = $A.localizationService.formatDate(startDayForCoverage, "YYYY-MM-DD");
                        
                        let termsdays = quoteRecord.Term_Days__c;
                        startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
                        endDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                        if( termsdays != null ){
                            endDayForCoverage.setDate(endDayForCoverage.getDate() + parseInt(termsdays));
                            quoteRecord['End_Date_for_Coverage__c'] = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
                        }
                    } else {
                        startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
                        if(startDayForCoverage < todaysDate) {
                            startDayForCoverage = todaysDate;
                            startDayForCoverage.setDate(startDayForCoverage.getDate() + 1);
                        }
                        quoteRecord['Start_Date_for_Coverage__c'] = $A.localizationService.formatDate(startDayForCoverage, "YYYY-MM-DD");
                        
                        let termsdays = quoteRecord.Term_Days__c;
                        startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
                        endDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                        if( termsdays != null ){
                            endDayForCoverage.setDate(endDayForCoverage.getDate() + parseInt(termsdays));
                            quoteRecord['End_Date_for_Coverage__c'] = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
                        }
                    }

					if( quoteRecord.Term__c == 'Annual(One Year)'){
						component.set("v.annualTerm", true);
					}
					component.set("v.quoteRecord",quoteRecord);

					if( response.driverRecords != undefined && response.driverRecords != null ){
						component.set("v.drivers", response.driverRecords);
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

					if( quoteRecord.Policy_Type_picklist__c == 'Automobile' || quoteRecord.Policy_Type_picklist__c == 'RV' ){
						if( response.towedunitRecords != undefined && response.towedunitRecords != null && response.towedunitRecords.length > 0){
							component.set("v.transporates", response.towedunitRecords);
						}
					}else{
						if( response.towedunitRecords != undefined && response.towedunitRecords != null && response.towedunitRecords.length > 0 ){
							component.set("v.towedunitRecord", response.towedunitRecords[0]);
						} 
					}

					if( nextScreen != null && nextScreen != undefined){
						component.set("v.screenName", nextScreen);
					}
					
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
				if (policyType === 'Watercraft') {
					helper.updateScreen(component, event, helper, 'ReviewWatercraft');
					return;
				}
				helper.updateScreen(component, event, helper, 'ReviewVehicle');
			}else if( screenName == 'ReviewVehicle' || screenName == 'ReviewWatercraft' ){
				helper.updateScreen(component, event, helper, 'RegisteredVehicle');
			}else if( screenName == 'RegisteredVehicle' ){
                let quoteIds = component.get("v.quoteIds");
                if (quoteRecord && quoteRecord.Id && !quoteIds.includes(quoteRecord.Id)) {
                    quoteIds.push(quoteRecord.Id);
                }
                component.set("v.quoteIds", quoteIds);
				if (policyType === 'Driver License' || policyType === 'Watercraft' || policyType == 'Motorcycle/Street Legal ATV') {
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
				helper.updateScreen(component, event, helper, 'PaymentDetail');
			}else if( screenName == 'PaymentDetail' ) {
				helper.createNewPolicy( component, event, helper );
			}
            
        }catch(ex){
            console.log('exce---'+ex);
        }
    },
	

	updateScreen : function(component, event, helper, next){
    	component.set("v.screenName", next);
    },

    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            mode: 'sticky',
            type: type,
            message: message
        }).fire();
    },

	createNewPolicy : function(component, event, helper){
		var quoteRecord = component.get("v.quoteRecord");
        var oldQuoteId = component.get("v.oldQuoteId");
		var action = component.get("c.createPolicy");
        action.setParams({ 
            'quoteRecord' : quoteRecord,
            'oldQuoteId' : oldQuoteId,
            'IsRenew': true
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    component.set("v.newPolicyId",response.policyNewId);
                    helper.goToDetailPage(component, event, helper);
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else if (state === "INCOMPLETE") {
                console.log("Incomplete");
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

	goToDetailPage : function(component, event, helper) {
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