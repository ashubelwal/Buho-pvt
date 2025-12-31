({
    InitCal :  function(  component, event, helper ) {
        let quoteRecord = component.get("v.quoteRecord");
        console.log("CA log : "+ JSON.stringify(quoteRecord, null, 4));
        var action = component.get("c.calculateNewRate");
        action.setParams({ 
			'quoteRecord' : quoteRecord
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                try{
                    var policyType = component.get("v.policyType");
                    var response = response.getReturnValue();
                    console.log('---response 15 line helper---', response);
                    response =  JSON.parse(response);
                    console.log(policyType);
                    if( policyType.toLowerCase() != 'northbound' && policyType.toLowerCase() != 'watercraft' && policyType.toLowerCase() != 'driver license' && response.success){
                        component.set("v.rateData", response.Data);
                        component.set("v.days", response.days);
                        console.log('---response---'+JSON.stringify(response, null,4));
                        helper.calculateRate(component, event, helper);
                    }else if( policyType.toLowerCase() == 'northbound'  ){
                        console.log(' inside line 27 northbound');
                        component.set("v.rateData", response.rateData[0]);
                        component.set("v.days", response.days);

                        helper.calculateNorthBoundRate(component, event, helper);
                    }else if(policyType.toLowerCase() == 'watercraft'){
                        component.set("v.rateData", response.Data);
                        component.set("v.days", response.days);
                        helper.calculateWatercraftRate(component, event, helper);
                    }else if (policyType.toLowerCase() == 'driver license') {
                        component.set("v.rateData", response.rateData[0]);
                        component.set("v.days", response.days);
                        helper.calculateDriverLicenceRate(component, event, helper);
                    } else{
                        helper.showToast(response.message, 'error');
                    }
                }catch( ex ){
                    console.log('-ex--',ex);
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

    createClonePolicyHelper : function(  component, event, helper ) {
        var quoteRecord = component.get("v.quoteRecord");
        var oldQuoteId = component.get("v.oldQuoteId");
        var towedunitRecord = component.get("v.towedunitRecord");
        var vehicleRecord = component.get("v.vehicleRecord");
        var drivers = component.get("v.drivers");
        var transporates = component.get("v.transporates");
        var policyType = component.get("v.policyType");

        var rateData = component.get("v.rateData");
        if( policyType == 'Watercraft' && rateData != null && rateData.RateResult != null ){
            var permimunRate = 0; 
            if( rateData.RateResult.NetPremium != null && rateData.RateResult.NetPremium != 0 ){
                permimunRate = rateData.RateResult.NetPremium;
            }
            var surcharge = 0;
            if( rateData.RateResult.Surcharge != null && rateData.RateResult.Surcharge != 0 ){
                surcharge = rateData.RateResult.Surcharge;
            }
            var brokerFree = 0;
            if( rateData.RateResult.BrokerPolicyFee != null && rateData.RateResult.BrokerPolicyFee != 0){
                brokerFree = rateData.RateResult.BrokerPolicyFee;
            }
            var ivaFree = 0;
            if( rateData.RateResult.IVAMexTax != null ){
                ivaFree = rateData.RateResult.IVAMexTax;
            }
            quoteRecord['Net_Premium__c'] = permimunRate; //permimunRate - ( surcharge + brokerFree);
            quoteRecord['Quote_Value__c'] = permimunRate + surcharge + brokerFree + ivaFree;
            quoteRecord['Surcharge__c'] = rateData.RateResult.Surcharge;
            quoteRecord['Broker_Policy_Fee__c'] = rateData.RateResult.BrokerPolicyFee;
            quoteRecord['I_V_A_Mex_Tax__c'] = rateData.RateResult.IVAMexTax;
        }else{
            var permimunRate = 0; 
            if( component.get("v.rateValue") != undefined && component.get("v.rateValue") != null && component.get("v.rateValue") != 0 ){
                permimunRate = component.get("v.rateValue");
            }
            var surcharge = 0;
            if( component.get("v.surcharge") != undefined && component.get("v.surcharge") != null && component.get("v.surcharge") != 0 ){
                surcharge = component.get("v.surcharge");
            }
            var brokerFree = 0;
            if( component.get("v.brokerValue") != undefined && component.get("v.brokerValue") != null && component.get("v.brokerValue") != 0){
                brokerFree = component.get("v.brokerValue");
            }
            var ivaFree = 0;
            if( component.get("v.ivrValue") != undefined && component.get("v.ivrValue") != null && component.get("v.ivrValue") != 0){
                ivaFree = component.get("v.ivrValue");
            }

            quoteRecord['Net_Premium__c'] =  permimunRate; //- ( ivaFree + brokerFree);//permimunRate + component.get("v.surcharge") //- (brokerFree);
            quoteRecord['Quote_Value__c'] = permimunRate + component.get("v.surcharge") + component.get("v.ivrValue") +component.get("v.brokerValue") ;
            quoteRecord['Surcharge__c'] = component.get("v.surcharge");
            quoteRecord['Broker_Policy_Fee__c'] = component.get("v.brokerValue");
            quoteRecord['I_V_A_Mex_Tax__c'] = component.get("v.ivrValue");
        }
        
        console.log('--quoteRecord--',JSON.stringify(quoteRecord));
        console.log('--towedunitRecord--',JSON.stringify(towedunitRecord));
        console.log('--vehicleRecord--',JSON.stringify(vehicleRecord));
        console.log('--drivers--',JSON.stringify(drivers));
        console.log('--transporates--',JSON.stringify(transporates));
        console.log('--policyType--',JSON.stringify(policyType));
        console.log("CA log --> "+ oldQuoteId + '  quoteRecord.Id   '+ quoteRecord.Id);
        
        if( oldQuoteId == quoteRecord.Id){
            quoteRecord.Id = null;
        }
        if (policyType == 'Watercraft') {
            console.log('Inside if');
            helper.createWatercraftClone(component, event, helper, quoteRecord, drivers, watercraftRecord, policyType, oldQuoteId);
        } else {
            helper.createVehicleClone(component, event, helper, quoteRecord, drivers, vehicleRecord, towedunitRecord, transporates, policyType, oldQuoteId);
        }
    },
    
    createWatercraftClone: function (component, event, helper, quoteRecord, drivers, watercraftRecord, policyType, oldQuoteId) {
        try {
            let action = component.get('c.createWatercraftClonePolicy');
            action.setParams({
                'quoteRecord' : quoteRecord,
                'driverRecords' : drivers,
                'watercraftObject' : watercraftRecord,
                'policyType' : policyType,
                'oldQuoteId' : oldQuoteId
            });
            
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        //component.set("v.newPolicyId",response.policyNewId);
                        component.set("v.quoteRecord",response.quoteRecord);
                        component.set("v.drivers",response.driverRecords);
                        
                        console.log('---response---',JSON.stringify(response, null, 4));
                        $A.enqueueAction(component.get("v.onNextClick"));
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
        } catch (e) {
            console.log('Error ---> ', e);
        }
    },
    
    createVehicleClone: function(component, event, helper, quoteRecord, drivers, vehicleRecord, towedunitRecord, transporates, policyType, oldQuoteId) {
        var action = component.get("c.createClonePolicy");
        action.setParams({ 
            'quoteRecord' : quoteRecord,
            'driverRecords' : drivers,
            'vehicleObject' : vehicleRecord,
            'towedObject' : towedunitRecord,
            'transporates' : transporates,
            'policyType' : policyType,
            'oldQuoteId' : oldQuoteId
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                console.log("CA Log inside response");
                console.log("CA Log inside response", JSON.stringify(response, null, 4));
                if( response.success){
                    //component.set("v.newPolicyId",response.policyNewId);
                    component.set("v.quoteRecord",response.quoteRecord);
                    component.set("v.drivers",response.driverRecords);
                    component.set("v.towedunitRecord",response.towedObject);
                    component.set("v.transporates",response.transporates);
                    
                    console.log('---response---',JSON.stringify(response));
                    $A.enqueueAction(component.get("v.onNextClick"));
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
    
    calculateRate : function(  component, event, helper ) {
        try{
            var policyType = component.get("v.policyType");
            console.log('---policyType--'+policyType);
            if( policyType != null && policyType.toLowerCase() != 'northbound'){
                var quoteRecord = component.get("v.quoteRecord");
                var rateData = component.get("v.rateData");
                var coverage = quoteRecord.Coverage__c;
                var territoryCoverage = quoteRecord.Territory_Coverage__c;
                var days = parseInt(component.get("v.days"));

                console.log('---days--'+days);
                console.log('---quoteRecord--',quoteRecord);
                console.log('---rateData--',rateData);
                console.log('---coverage--',coverage);
                console.log('---territoryCoverage--',territoryCoverage);

                if( quoteRecord.Underwriter__c != null && quoteRecord.Underwriter__c == 'Qualitas' ){
                    var qualitasDays = days;
                    if( coverage != null && coverage == 'Liability'){
                        var totalPremiumLiabilityOnly;
                        if(territoryCoverage && (territoryCoverage == "Partial (US Adjacent)" || territoryCoverage == "Baja Sonora")){
                            totalPremiumLiabilityOnly = rateData.LiabilityOnlyLimitedTerritory;
                        }
                        else{
                            totalPremiumLiabilityOnly = rateData.TotalPremiumLiabilityOnly;
                        }
                        if( totalPremiumLiabilityOnly ){
                            var qualitasRateValue = 0;
                            if( days && days <= 30 ){
                                if( totalPremiumLiabilityOnly.Daily ){
                                    qualitasRateValue = parseFloat(totalPremiumLiabilityOnly.Daily);
                                }
                                if( totalPremiumLiabilityOnly.Semi_annual && parseFloat(totalPremiumLiabilityOnly.Semi_annual) < qualitasRateValue ){
                                    qualitasRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual);
                                    qualitasDays = 180;
                                }
                                if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual) < qualitasRateValue ){
                                    qualitasRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                                    qualitasDays = 365;
                                }
                            }else if( days && days > 30 && days <= 180 ){
                                if( totalPremiumLiabilityOnly.Semi_annual ){
                                    qualitasRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual);
                                }
                                if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual) < qualitasRateValue ){
                                    qualitasRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                                    qualitasDays = 365;
                                }
                            }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                                qualitasRateValue = ( parseFloat(totalPremiumLiabilityOnly.Annual));
                            }
                            
                            component.set("v.rateValue", qualitasRateValue);
                        }else{
                            component.set("v.rateValue", parseInt('0'));
                        }
                        
                        if( rateData.IVALiabilityOnly ){
                            var IVALiabilityOnly = rateData.IVALiabilityOnly;
                            
                            if( qualitasDays && qualitasDays <= 30 && IVALiabilityOnly.Daily ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnly.Daily));
                            }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180 && IVALiabilityOnly.Semi_annual ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnly.Semi_annual));
                            }else if( qualitasDays && qualitasDays > 180 && IVALiabilityOnly.Annual ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnly.Annual));
                            }
                        }
                    }else{
                        var totalCompleteCoverage;
                        if(territoryCoverage && (territoryCoverage == "Partial (US Adjacent)" || territoryCoverage == "Baja Sonora")){
                            totalCompleteCoverage = rateData.CompleteCoverageLimited;
                        }else{
                            totalCompleteCoverage = rateData.TotalCompleteCoverage;
                        }
                        if( totalCompleteCoverage ){
                            var qualitasRateValue = 0;
                            console.log("CA log rateValue "+ totalCompleteCoverage.Annual);
                            if( days && days <= 30 ){
                                if( totalCompleteCoverage.Daily ){
                                    qualitasRateValue = parseFloat(totalCompleteCoverage.Daily);
                                }
                                if( totalCompleteCoverage.Semi_annual && parseFloat(totalCompleteCoverage.Semi_annual) < qualitasRateValue ){
                                    qualitasRateValue = parseFloat(totalCompleteCoverage.Semi_annual);
                                    qualitasDays = 180;
                                }
                                if( totalCompleteCoverage.Annual && parseFloat(totalCompleteCoverage.Annual) < qualitasRateValue ){
                                    qualitasRateValue = parseFloat(totalCompleteCoverage.Annual);
                                    qualitasDays = 365;
                                }
                            }else if( days && days > 30 && days <= 180 ){
                                if( totalCompleteCoverage.Semi_annual ){
                                    qualitasRateValue = parseFloat(totalCompleteCoverage.Semi_annual);
                                    
                                }
                                if( totalCompleteCoverage.Annual && parseFloat(totalCompleteCoverage.Annual) < qualitasRateValue ){
                                    qualitasRateValue = parseFloat(totalCompleteCoverage.Annual);
                                    qualitasDays = 365;
                                    console.log("CA log rateValue "+ qualitasRateValue);
                                }
                            }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                                qualitasRateValue = ( parseFloat(totalCompleteCoverage.Annual));
                                console.log("CA log rateValue > 180 "+ qualitasRateValue);
                            }
                            console.log("CA log rateValue "+ qualitasRateValue);
                            component.set("v.rateValue", qualitasRateValue);
                        }else{
                            component.set("v.rateValue", parseInt('0'));
                        }
                        
                        if(territoryCoverage && (territoryCoverage == "Partial (US Adjacent)" || territoryCoverage == "Baja Sonora")){
                            if( rateData.IVACompleteCoverage ){
                                var IVACompleteCoverage = rateData.IVACompleteCoverage;
                                if( qualitasDays && qualitasDays <= 30 && IVACompleteCoverage.Daily ){
                                    component.set("v.ivrValue", parseFloat(IVACompleteCoverage.Daily));
                                }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180 && IVACompleteCoverage.Semi_annual ){
                                    component.set("v.ivrValue", parseFloat(IVACompleteCoverage.Semi_annual));
                                }else if( qualitasDays && qualitasDays > 180 && IVACompleteCoverage.Annual ){
                                    component.set("v.ivrValue", parseFloat(IVACompleteCoverage.Annual));
                                }
                            }
                        }else{
                            if( rateData.IVACompleteCoverage ){
                                var IVACompleteCoverage = rateData.IVACompleteCoverage;
                                if( qualitasDays && qualitasDays <= 30 && IVACompleteCoverage.Daily ){
                                    component.set("v.ivrValue", parseFloat(IVACompleteCoverage.Daily));
                                }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180 && IVACompleteCoverage.Semi_annual ){
                                    component.set("v.ivrValue", parseFloat(IVACompleteCoverage.Semi_annual));
                                }else if( qualitasDays && qualitasDays > 180 && IVACompleteCoverage.Annual ){
                                    component.set("v.ivrValue", parseFloat(IVACompleteCoverage.Annual));
                                }
                            }
                        }
                        
                    }
                    console.log('@@@ qualitasDays '+qualitasDays);
                    var brokerFee = rateData.brokerFee;
                    console.log('@@  brokerFee rateData.brokerFee '+ rateData.brokerFee);
                    if( qualitasDays && qualitasDays <= 30 && brokerFee && brokerFee.Daily && brokerFee.Daily != null  ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Daily));
                        console.log(' inside 298');
                    }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && brokerFee.Semi_annual != null ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Semi_annual));
                    }else if( qualitasDays && qualitasDays > 180  && brokerFee.Daily && brokerFee.Annual != null ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Annual));
                    }else{
                        component.set("v.brokerValue", parseInt('0'));
                        console.log(' inside 305');
                    }
                    console.log('@@@ brokerValue '+component.get("v.brokerValue"));
                    var bsurcharge = 0;
                    var businessSurcharge = rateData.businessSurcharge;
                    if( qualitasDays && qualitasDays <= 30 && businessSurcharge && businessSurcharge.Daily && businessSurcharge.Daily != null  ){
                        bsurcharge = parseFloat(businessSurcharge.Daily);
                    }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && businessSurcharge.Semi_annual != null ){
                        bsurcharge = parseFloat(businessSurcharge.Semi_annual);
                    }else if( qualitasDays && qualitasDays > 180  && businessSurcharge.Annual != null ){
                        bsurcharge = parseFloat(businessSurcharge.Annual);
                    }

                    var ageSurcharge = rateData.ageSurcharge;
                    var asurcharge = 0;
                    if( qualitasDays && qualitasDays <= 30 && ageSurcharge && ageSurcharge.Daily && ageSurcharge.Daily != null  ){
                        asurcharge = parseFloat(ageSurcharge.Daily);
                    }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && ageSurcharge.Semi_annual != null ){
                        asurcharge = parseFloat(ageSurcharge.Semi_annual);
                    }else if( qualitasDays && qualitasDays > 180  && ageSurcharge.Annual != null ){
                        asurcharge = parseFloat(ageSurcharge.Annual);
                    }
                    
                    component.set("v.surcharge", (asurcharge+bsurcharge));
                    var tempPremium = (component.get("v.rateValue") - (asurcharge+bsurcharge + component.get("v.ivrValue") + component.get("v.brokerValue") ));
                    component.set("v.rateValue", tempPremium);
                    console.log('@@@@@ tempPremium' +tempPremium);

                }else if( quoteRecord.Underwriter__c != null && quoteRecord.Underwriter__c == 'Chubb' ){
                    var chubDays = days;
                    if( coverage != null && coverage == 'Liability'){
                        var totalPremiumLiabilityOnly = rateData.TotalPremiumLiabilityOnly;
                        if( totalPremiumLiabilityOnly ){
                            var chubbRateValue = 0;
                            if( days && days <= 30 ){
                                if(totalPremiumLiabilityOnly.Daily ){
                                    chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Daily);
                                }
                                if( totalPremiumLiabilityOnly.Semi_annual && ( parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Semi_annual) ) < chubbRateValue ){
                                    chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                    chubDays = 180;
                                }
                                if( totalPremiumLiabilityOnly.Annual && ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Annual) ) < chubbRateValue ){
                                    chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Annual);
                                    chubDays = 365;
                                }
                            }else if( days && days > 30 && days <= 180 ){
                                if( totalPremiumLiabilityOnly.Semi_annual ){
                                    chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                }
                                if( totalPremiumLiabilityOnly.Annual && ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Annual) ) < chubbRateValue ){
                                    chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Annual);
                                    chubDays = 365;
                                }
                            }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                                chubbRateValue = ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(rateData.BajaSonaraDiscountLiabilityOnly.Annual));
                            }
                            
                            component.set("v.rateValue", chubbRateValue );
                            //component.set("v.rateValue", chubbRateValue - );
                        }else{
                            component.set("v.rateValue", parseInt('0'));
                        }
                    }else{
                        var totalCompleteCoverage = rateData.TotalCompleteCoverage;
                        if( totalCompleteCoverage ){
                            var chubbRateValue = 0;
                            if( days && days <= 30 ){
                                if(totalCompleteCoverage.Daily ){
                                    chubbRateValue = parseFloat(totalCompleteCoverage.Daily);
                                }
                                if( totalCompleteCoverage.Semi_annual && ( parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Semi_annual) ) < chubbRateValue ){
                                    chubbRateValue = parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Semi_annual);
                                    chubDays = 180;
                                }
                                if( totalCompleteCoverage.Annual && ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Annual) ) < chubbRateValue ){
                                    chubbRateValue = parseFloat(totalCompleteCoverage.Annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Annual);
                                    chubDays = 365;
                                }
                            }else if( days && days > 30 && days <= 180 ){
                                if( totalCompleteCoverage.Semi_annual ){
                                    chubbRateValue = parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Semi_annual);
                                }
                                if( totalCompleteCoverage.Annual && ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Annual) ) < chubbRateValue ){
                                    chubbRateValue = parseFloat(totalCompleteCoverage.Annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Annual);
                                    chubDays = 365;
                                }
                            }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                                chubbRateValue = ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(rateData.BajaSonaraDiscountComplete.Annual) ) ;
                            }
                            
                            component.set("v.rateValue", chubbRateValue );
                        }else{
                            component.set("v.rateValue", parseInt('0'));
                        }
                    }
                    var brokerFee = rateData.brokerFee;
                    if( chubDays && chubDays <= 30 && brokerFee && brokerFee.Daily && brokerFee.Daily != null  ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Daily));
                    }else if( chubDays && chubDays > 30 && chubDays <= 180 && brokerFee.Semi_annual != null ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Semi_annual));
                    }else if( chubDays && chubDays > 180  && brokerFee.Annual != null ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Annual));
                    }else{
                        component.set("v.brokerValue", parseInt('0'));
                    }

                    chubbRateValue = component.get("v.rateValue");
                    var chubbBroker_Policy_Fee = component.get("v.brokerValue");
                    if( chubbRateValue != null && chubbRateValue > 0 ){
                        /*if (quoteRecord.Driver_Age__c != null && quoteRecord.Driver_Age__c < 21){
                            var chub_SurCharge = chubbRateValue - ( chubbBroker_Policy_Fee != null ? chubbBroker_Policy_Fee : 0);
                            chubbRateValue -= component.get("v.brokerValue");
                            component.set("v.rateValue", chubbRateValue); 
                            component.set("v.surcharge", chub_SurCharge); 
                        }*/
                        if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes') {
                            var chub_SurCharge = chubbRateValue - ( chubbBroker_Policy_Fee != null ? chubbBroker_Policy_Fee : 0);
                            chubbRateValue += chub_SurCharge;
                            component.set("v.rateValue", chubbRateValue); 
                            component.set("v.surcharge", chub_SurCharge); 
                        }
                    }
                    var tempIVRate = component.get("v.ivrValue");
                    if(tempIVRate == null || tempIVRate == undefined){
                        component.set("v.ivrValue", 0); 
                    }

                    var tempSurcharge = component.get("v.surcharge");
                    if(tempSurcharge == null || tempSurcharge == undefined){
                        component.set("v.surcharge", 0);
                    }
                    var tempChubbTotal = component.get("v.ivrValue") + component.get("v.surcharge") + component.get("v.brokerValue");
                    console.log(tempChubbTotal);
                    component.set("v.rateValue", chubbRateValue - ( tempChubbTotal ) );
                }else if( quoteRecord.Underwriter__c != null && quoteRecord.Underwriter__c == 'Mapfre' ){
                    var mapfreDays = days;
                    if( coverage != null && coverage == 'Liability'){
                        var totalPremiumLiabilityOnly = rateData.liabilityOnlyTotal;
                        if( totalPremiumLiabilityOnly ){
                            var mapfreRateValue = 0;
                            if( days && days <= 30){
                                if( totalPremiumLiabilityOnly.Daily ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Daily);
                                }
                                if( totalPremiumLiabilityOnly.Days90 && parseFloat(totalPremiumLiabilityOnly.Days90) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days90);
                                    mapfreDays = 90;
                                }
                                if( totalPremiumLiabilityOnly.Days180 && parseFloat(totalPremiumLiabilityOnly.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180);
                                    mapfreDays = 180;
                                }
                                if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                                    mapfreDays = 360;
                                }
                            }else if( days && days > 30 && days <= 90){
                                if( totalPremiumLiabilityOnly.Days90 ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days90);
                                }
                                if( totalPremiumLiabilityOnly.Days180 && parseFloat(totalPremiumLiabilityOnly.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180);
                                    mapfreDays = 180;
                                }
                                if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                                    mapfreDays = 360;
                                }
                            }else if( days && days > 90 && days <= 180){
                                if( totalPremiumLiabilityOnly.Days180 ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180);
                                }
                                if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                                    mapfreDays = 360;
                                }
                            }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                                //component.set("v.rateValue", parseFloat(totalPremiumLiabilityOnly.Annual));
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                            }
                            
                            component.set("v.rateValue", mapfreRateValue );
                        }else{
                            component.set("v.rateValue", parseInt('0') );
                        }
                        
                        if( rateData.IVAliabilityOnlyTotal ){
                            var IVALiabilityOnlyCoverage = rateData.IVAliabilityOnlyTotal;
                            if( mapfreDays && mapfreDays <= 30 && IVALiabilityOnlyCoverage.Daily ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Daily));
                            }else if( mapfreDays && mapfreDays > 30 && mapfreDays <= 90 && IVALiabilityOnlyCoverage.Days90 ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Days90));
                            }else if( mapfreDays && mapfreDays > 90 && mapfreDays <= 180 && IVALiabilityOnlyCoverage.Days180 ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Days180));
                            } else if (mapfreDays && mapfreDays > 180 && IVALiabilityOnlyCoverage.Annual) {
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Annual));
                            }
                        }
                    } else if (coverage != null && coverage == 'LiabilityTheft') {
                        var totalPremiumLiabilityTheftOnly = rateData.liabilityOnlyTotal;
                        var totalTheftVar = rateData.totalTheft;
                        
                        if (totalPremiumLiabilityTheftOnly) {
                            var mapfreRateValue = 0;
                            if (days && days <= 30) {
                                if (totalPremiumLiabilityTheftOnly.Daily) {
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Daily + totalTheftVar.Daily);
                                }
                                if( totalPremiumLiabilityTheftOnly.Days90 && parseFloat(totalPremiumLiabilityTheftOnly.Days90 + totalTheftVar.Days90) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Days90 + totalTheftVar.Days90);
                                    mapfreDays = 90;
                                }
                                if( totalPremiumLiabilityTheftOnly.Days180 && parseFloat(totalPremiumLiabilityTheftOnly.Days180 + totalTheftVar.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Days180 + totalTheftVar.Days180);
                                    mapfreDays = 180;
                                }
                                if( totalPremiumLiabilityTheftOnly.Annual && parseFloat(totalPremiumLiabilityTheftOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Annual + totalTheftVar.Annual);
                                    mapfreDays = 365;
                                }
                            } else if( days && days > 30 && days <= 90 ) {
                                if( totalPremiumLiabilityTheftOnly.Days90  ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Days90 + totalTheftVar.Days90);
                                }
                                if( totalPremiumLiabilityTheftOnly.Days180 && parseFloat(totalPremiumLiabilityTheftOnly.Days180 + totalTheftVar.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Days180 + totalTheftVar.Days180);
                                    mapfreDays = 180;
                                }
                                if( totalPremiumLiabilityTheftOnly.Annual && parseFloat(totalPremiumLiabilityTheftOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Annual + totalTheftVar.Annual);
                                    mapfreDays = 365;
                                }
                            } else if( days && days > 90 && days <= 180 ) {
                                if( totalPremiumLiabilityTheftOnly.Days180 ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Days180 + totalTheftVar.Days180);
                                    mapfreDays = 180;
                                }
                                if( totalPremiumLiabilityTheftOnly.Annual && parseFloat(totalPremiumLiabilityTheftOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalPremiumLiabilityTheftOnly.Annual + totalTheftVar.Annual);
                                    mapfreDays = 365;
                                }
                            } else if( days && days > 180 && totalPremiumLiabilityTheftOnly.Annual ) {
                                mapfreRateValue =  parseFloat(totalPremiumLiabilityTheftOnly.Annual + totalTheftVar.Annual);
                            }
                            
                            component.set("v.rateValue", mapfreRateValue);
                        } else {
                            component.set("v.rateValue", parseInt('0') );
                        }
                        
                        if( rateData.IVAliabilityOnlyTotal ){
                            var IVALiabilityOnlyCoverage = rateData.IVAliabilityOnlyTotal;
                            if( mapfreDays && mapfreDays <= 30 && IVALiabilityOnlyCoverage.Daily ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Daily));
                            }else if( mapfreDays && mapfreDays > 30 && mapfreDays <= 90 && IVALiabilityOnlyCoverage.Days90 ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Days90));
                            }else if( mapfreDays && mapfreDays > 90 && mapfreDays <= 180 && IVALiabilityOnlyCoverage.Days180 ){
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Days180));
                            } else if (mapfreDays && mapfreDays > 180 && IVALiabilityOnlyCoverage.Annual) {
                                component.set("v.ivrValue", parseFloat(IVALiabilityOnlyCoverage.Annual));
                            }
                        }
                    } else if( coverage != null && coverage == 'Complete' ){
                        var totalCompleteCoverage = rateData.fullCoverageTotal;
                        if( totalCompleteCoverage ){
                            var mapfreRateValue = 0;
                            if( days && days <= 30 ){
                                console.log('--under 30---');
                                if( totalCompleteCoverage.Daily ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Daily);
                                }
                                if( totalCompleteCoverage.Days90 && parseFloat(totalCompleteCoverage.Days90) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days90);
                                    mapfreDays = 90;
                                }
                                if( totalCompleteCoverage.Days180 && parseFloat(totalCompleteCoverage.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days180);
                                    mapfreDays = 180;
                                }
                                if( totalCompleteCoverage.Annual && parseFloat(totalCompleteCoverage.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Annual);
                                    mapfreDays = 365;
                                }
                            }else if( days && days > 30 && days <= 90 ){
                                if( totalCompleteCoverage.Days90 ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days90);
                                }
                                if( totalCompleteCoverage.Days180 && parseFloat(totalCompleteCoverage.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days180);
                                    mapfreDays = 180;
                                }
                                if( totalCompleteCoverage.Annual && parseFloat(totalCompleteCoverage.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Annual);
                                    mapfreDays = 365;
                                }
                            }else if( days && days > 90 && days <= 180 ){
                                console.log('--under 180---');
                                if( totalCompleteCoverage.Days180 ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days180);
                                }
                                if( totalCompleteCoverage.Annual && parseFloat(totalCompleteCoverage.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Annual);
                                    mapfreDays = 365;
                                }
                            }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                                mapfreRateValue =  parseFloat(totalCompleteCoverage.Annual);
                            }
                            
                            component.set("v.rateValue", mapfreRateValue );
                        }else{
                            component.set("v.rateValue", parseInt('0') );
                        }
                        
                        if( rateData.IVAFullCoverage ){
                            var IVAFullCoverageTotal = rateData.IVAFullCoverage;
                            if( mapfreDays && mapfreDays <= 30 && IVAFullCoverageTotal.Daily ){
                                component.set("v.ivrValue", parseFloat(IVAFullCoverageTotal.Daily));
                            }else if( mapfreDays && mapfreDays > 30 && mapfreDays <= 90 && IVAFullCoverageTotal.Days90 ){
                                component.set("v.ivrValue", parseFloat(IVAFullCoverageTotal.Days90));
                            }else if( mapfreDays && mapfreDays > 90 && mapfreDays <= 180 && IVAFullCoverageTotal.Days180 ){
                                component.set("v.ivrValue", parseFloat(IVAFullCoverageTotal.Days180));
                            } else if (mapfreDays && mapfreDays > 180 && IVAFullCoverageTotal.Annual) {
                                component.set("v.ivrValue", parseFloat(IVAFullCoverageTotal.Annual));
                            }
                        }
                    }else if( coverage != null && coverage == 'Max' ){
                        var MaxCoverageTotal = rateData.MaxCoverageTotal;
                        if( MaxCoverageTotal ){
                            var mapfreRateValue = 0;
                            if( days && days <= 30 ){
                                if( MaxCoverageTotal.Daily ){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Daily);
                                }
                                if( MaxCoverageTotal.Days90 && parseFloat(MaxCoverageTotal.Days90) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Days90);
                                    mapfreDays = 90;
                                }
                                if( MaxCoverageTotal.Days180 && parseFloat(MaxCoverageTotal.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Days180);
                                    mapfreDays = 180;
                                }
                                if( MaxCoverageTotal.Annual && parseFloat(MaxCoverageTotal.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Annual);
                                    mapfreDays = 365;
                                }
                            }else if( days && days > 30 && days <= 90 ){
                                if( MaxCoverageTotal.Days90 ){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Days90);
                                }
                                if( MaxCoverageTotal.Days180 && parseFloat(MaxCoverageTotal.Days180) < mapfreRateValue){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Days180);
                                    mapfreDays = 180;
                                }
                                if( MaxCoverageTotal.Annual && parseFloat(MaxCoverageTotal.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Annual);
                                    mapfreDays = 365;
                                }
                            }else if( days && days > 90 && days <= 180 ){
                                if( MaxCoverageTotal.Days180 ){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Days180);
                                }
                                if( MaxCoverageTotal.Annual && parseFloat(MaxCoverageTotal.Annual) < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(MaxCoverageTotal.Annual);
                                    mapfreDays = 365;
                                }
                                
                            }else if( days && days > 180 && MaxCoverageTotal.Annual ){
                                mapfreRateValue =  parseFloat(MaxCoverageTotal.Annual);
                            }
                            component.set("v.rateValue", mapfreRateValue );
                        }else{
                            component.set("v.rateValue", parseInt('0') );
                        }
                        
                        if( rateData.IVAMexCoverage ){
                            var IVAMexCoverageTotal = rateData.IVAMexCoverage;
                            if( mapfreDays && mapfreDays <= 30 && IVAMexCoverageTotal.Daily ){
                                component.set("v.ivrValue", parseFloat(IVAMexCoverageTotal.Daily));
                            }else if( mapfreDays && mapfreDays > 30 && mapfreDays <= 90 && IVAMexCoverageTotal.Days90 ){
                                component.set("v.ivrValue", parseFloat(IVAMexCoverageTotal.Days90));
                            }else if( mapfreDays && mapfreDays > 90 && mapfreDays <= 180 && IVAMexCoverageTotal.Days180 ){
                                component.set("v.ivrValue", parseFloat(IVAMexCoverageTotal.Days180));
                            } else if (mapfreDays && mapfreDays > 180 && IVAMexCoverageTotal.Annual) {
                                component.set("v.ivrValue", parseFloat(IVAMexCoverageTotal.Annual));
                            }
                        }
                    }
                    
                    var brokerFee = rateData.brokerFee;
                    if( mapfreDays && mapfreDays <= 30 && brokerFee && brokerFee.Daily && brokerFee.Daily != null  ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Daily));
                    }else if( mapfreDays && mapfreDays > 30 && mapfreDays <= 90 && brokerFee.Daily && brokerFee.Days90 != null ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Days90));
                    }else if( mapfreDays && mapfreDays > 90 && mapfreDays <= 180 && brokerFee.Daily && brokerFee.Days180 != null ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Days180));
                    }else if( mapfreDays && mapfreDays > 180  && brokerFee.Daily && brokerFee.Annual != null ){
                        component.set("v.brokerValue", parseFloat(brokerFee.Annual));
                    }else{
                        component.set("v.brokerValue", parseInt('0'));
                    }
                    component.set("v.rateValue", mapfreRateValue - component.get("v.brokerValue") );
                }

                var tempIVRate = component.get("v.ivrValue");
                if(tempIVRate == null || tempIVRate == undefined){
                    component.set("v.ivrValue", 0); 
                }

            }
            if (component.get("v.surcharge") == undefined){
                component.set("v.surcharge",0);
            }

            let quoteRecordData = component.get('v.quoteRecord');
            var tempnewTotal;
            if (quoteRecordData.Underwriter__c == 'Mapfre') {
                tempnewTotal = component.get("v.rateValue") + component.get("v.brokerValue") + component.get("v.surcharge");
                component.set('v.IsMapfrePolicy', true);
            } else {
                tempnewTotal = component.get('v.ivrValue') + component.get("v.rateValue") + component.get("v.brokerValue") + component.get("v.surcharge");
            }
            component.set("v.newTotal", tempnewTotal);

            var refundAmount = 0;
            var oldNetAmopunt = 0;
            var newNewAmount = 0;
            var policyRecord = component.get("v.policyRecord");
            if( policyRecord && policyRecord.Total_Transaction_Amount__c && policyRecord.Total_Transaction_Amount__c != null ){
                oldNetAmopunt = parseFloat(policyRecord.Total_Transaction_Amount__c);
            }

            if( tempnewTotal != null){
                newNewAmount = parseFloat(tempnewTotal);
            }
            if(newNewAmount < oldNetAmopunt){
                component.set("v.isRefund", true);
                refundAmount = newNewAmount - oldNetAmopunt;
            }else{
                component.set("v.isRefund", false);
                refundAmount = newNewAmount - oldNetAmopunt;
            }
            console.log('@@@ refundAmount '+refundAmount);
            component.set("v.refundAmount",refundAmount);
        }catch(ex){
            console.log('--ex--',ex);
        }
        
    },
    
    calculateDriverLicenceRate : function (component, event, helper) {
        try {
            let quoteObject = component.get("v.quoteRecord");
            console.log(' inside quoteObject'+JSON.stringify(quoteObject, null, 4));
            let response = component.get("v.rateData");
            
            let Net_Premium = response.Net_Premium__c != null ? response.Net_Premium__c : 0;
            let Broker_Policy_Fee = response.Broker_Policy_Fee__c != null ? response.Broker_Policy_Fee__c : 30;
            let IVA_Mex_Tax = response.IVA_Mex_Tax__c != null ? response.IVA_Mex_Tax__c : 0;
            
            let operator_charge = response.Age_of_Operator_Surcharge__c != null ? response.Age_of_Operator_Surcharge__c : 0;
            
            let surcharge = 0;
            let Total_Premium = Net_Premium;
            if (quoteObject.Driver_Age__c != null) {
                if (quoteObject.Driver_Age__c < 21 || quoteObject.Driver_Age__c > 75) {
                    surcharge += Net_Premium * (operator_charge/100);
                } else {
                    surcharge += 0;
                }
            }
            
            component.set("v.rateValue", Total_Premium);
            component.set("v.surcharge", surcharge);
            component.set("v.brokerValue", Broker_Policy_Fee);
            component.set("v.ivrValue", IVA_Mex_Tax);


            var refundAmount = 0;
            var oldNetAmount = 0;
            var newNewAmount = 0;
            var policyRecord = component.get("v.policyRecord");
            if( policyRecord && policyRecord.Total_Transaction_Amount__c && policyRecord.Total_Transaction_Amount__c != null ){
                oldNetAmount = parseFloat(policyRecord.Total_Transaction_Amount__c);
            }

            var rateValue = component.get("v.rateValue");
            if( rateValue != null){
                newNewAmount = parseFloat(Total_Premium + surcharge + Broker_Policy_Fee + IVA_Mex_Tax);
            }

            if(newNewAmount < oldNetAmount){
                component.set("v.isRefund", true);
                refundAmount = newNewAmount - oldNetAmount;
            }else{
                component.set("v.isRefund", false);
                refundAmount = newNewAmount - oldNetAmount;
            }
            
            component.set("v.refundAmount",refundAmount);
        } catch (err) {
            console.log('-err--',err);
        }
    },

    calculateNorthBoundRate : function(  component, event, helper ) {
        try{
            var quoteObject = component.get("v.quoteRecord");
            console.log(' inside calculateNorthBoundRate line 560');
            console.log(' inside quoteObject'+JSON.stringify(quoteObject, null, 4));
            var response = component.get("v.rateData");
            console.log(JSON.stringify(response, null, 4));
            var Net_Premium = (response.Net_Premium__c != null ? response.Net_Premium__c : 0);
            var Broker_Policy_Fee = (response.Broker_Policy_Fee__c != null ? response.Broker_Policy_Fee__c : 0);
            var IVA_Mex_Tax = (response.IVA_Mex_Tax__c != null ? response.IVA_Mex_Tax__c : 0);
    
            var Vehicle_Age_20 = (response.Age_of_Vehicle_Surcharge__c != null ? response.Age_of_Vehicle_Surcharge__c : 0);
            var Vehicle_Age_25 = (response.Age_of_Vehicle_Surcharge_25_years_old__c != null ? response.Age_of_Vehicle_Surcharge_25_years_old__c : 0);
            var operator_Charge = (response.Age_of_Operator_Surcharge__c != null ? response.Age_of_Operator_Surcharge__c : 0);
            var towing_Charge = (response.Trailering_Surcharge__c != null ? response.Trailering_Surcharge__c : 0);
    
    
            var surcharge = 0;
            var Total_Premium = Net_Premium;
            console.log('@@ Total_Premium '+Total_Premium);
            if (quoteObject.Vehicle_Age__c) {
                if (quoteObject.Vehicle_Age__c > 30 && quoteObject.Vehicle_Age__c <= 35) {
                    surcharge += Net_Premium * 0.5; // if vehicle age is somewhere between 31-35 then surcharge should be 50% of the Net Premium
    
                } else if (quoteObject.Vehicle_Age__c > 35) {
                    surcharge += Net_Premium; // if vehicle age is over 35 then surcharge should be 100% of the Net Premium or equale to the net premium
                } else {
                    surcharge += 0; // otherwise the surcharge would be 0
                }
            }
            if (quoteObject.Driver_Age__c) {
                if ((quoteObject.Driver_Age__c > 15  && quoteObject.Driver_Age__c <= 18) || (quoteObject.Driver_Age__c > 79  && quoteObject.Driver_Age__c <= 84)) {
                	surcharge += Net_Premium; // if driver age is somewhere between 16-18 & 80-84 then surchage should be 100% of the Net Premium or equals to the Net Premium
                } else if ((quoteObject.Driver_Age__c > 18 && quoteObject.Driver_Age__c <= 21) || (quoteObject.Driver_Age__c > 74 && quoteObject.Driver_Age__c <= 79)) {
                    surcharge += Net_Premium * 0.5; // if driver age is somewhere between 19-21 & 75-79 then surchage should be 50% of the Net Premium
                } else if (quoteObject.Driver_Age__c > 21 && quoteObject.Driver_Age__c <= 74) {
                    surcharge += 0; // if driver age is somewhere between 22-74 the surcharge would be 0
                }
            }

            if (quoteObject.Towed_Unit__c && quoteObject.Towed_Unit__c === 'Yes') {
                console.log('@ towing_Charge '+towing_Charge);
                console.log('@ Net_Premium '+Net_Premium);
                surcharge += Net_Premium * 0.5;
            }
            console.log(' surcharge '+surcharge);
    
            //Total_Premium = Total_Premium + Broker_Policy_Fee + IVA_Mex_Tax + surcharge;
            component.set("v.rateValue", Total_Premium);
            component.set("v.surcharge", surcharge);
            component.set("v.brokerValue", Broker_Policy_Fee);
            component.set("v.ivrValue", IVA_Mex_Tax);


            var refundAmount = 0;
            var oldNetAmopunt = 0;
            var newNewAmount = 0;
            var policyRecord = component.get("v.policyRecord");
            if( policyRecord && policyRecord.Total_Transaction_Amount__c && policyRecord.Total_Transaction_Amount__c != null ){
                oldNetAmopunt = parseFloat(policyRecord.Total_Transaction_Amount__c);
            }

            var rateValue = component.get("v.rateValue");
            if( rateValue != null){
                newNewAmount = parseFloat(Total_Premium + surcharge + Broker_Policy_Fee + IVA_Mex_Tax);
            }

            if(newNewAmount < oldNetAmopunt){
                component.set("v.isRefund", true);
                refundAmount = newNewAmount - oldNetAmopunt;
            }else{
                component.set("v.isRefund", false);
                refundAmount = newNewAmount - oldNetAmopunt;
            }
            
            component.set("v.refundAmount",refundAmount);
        }catch( ex ){
            console.log('-ex--',ex);
        }
    },

    calculateWatercraftRate : function(  component, event, helper ) {
        try{            
            var rateData = component.get("v.rateData");
            var policyRecord = component.get("v.policyRecord");
            let days =  component.get("v.days");
            let totatRateValue = rateData.RateResult.LiabilityLimitSelection;
            console.log("CA log Days : "+ days);
            console.log("CA log totatRateValue : "+ totatRateValue);
            /*if(days < 31){
         		let quoteRecord = component.get("v.quoteRecord");
                if(quoteRecord['Liability__c'] == '400,000'){
                    totatRateValue = (totatRateValue * 137)/100;
                }else if(quoteRecord['Liability__c'] == '750,000'){
                    totatRateValue = (totatRateValue * 157)/100;
                }
                console.log("CA log rateData "+ totatRateValue);
            }*/
            
            component.set("v.rateValue", totatRateValue);
            component.set("v.surcharge", rateData.RateResult.Surcharge);
            component.set("v.brokerValue", rateData.RateResult.BrokerPolicyFee);
            component.set("v.ivrValue", rateData.RateResult.IVAMexTax);

            var refundAmount = 0; 
            var oldNetAmopunt = 0;
            var newNetAmount = 0;
            //var quoteRecord = component.get("v.quoteRecord");
            if( policyRecord && policyRecord.Total_Transaction_Amount__c && policyRecord.Total_Transaction_Amount__c != null ){
                oldNetAmopunt = parseFloat(policyRecord.Total_Transaction_Amount__c);
            }
            
            var rateValue = component.get("v.rateValue");
            
            var surcharge = rateData.RateResult.Surcharge;
            var brokerCharge = rateData.RateResult.BrokerPolicyFee;
            var ivaTax = rateData.RateResult.IVAMexTax;
            
            if( rateValue != null){
            var ivaTax = rateData.RateResult.IVAMexTax;
                newNetAmount = parseFloat(rateValue) + surcharge + brokerCharge+ ivaTax;
            }
            
            console.log('@@ watervraft refund amounts');
            console.log(' newNetAmount '+newNetAmount);
            console.log('oldNetAmopunt '+oldNetAmopunt);
            if(newNetAmount < oldNetAmopunt){
                component.set("v.isRefund", true);
                refundAmount = newNetAmount - oldNetAmopunt;
            }else{
                component.set("v.isRefund", false);
                refundAmount = newNetAmount - oldNetAmopunt;
            }
            component.set("v.refundAmount", refundAmount);
        }catch( ex ){
            console.log('-ex--',ex);
        }
    }
})