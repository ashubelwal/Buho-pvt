({
    initilizeData : function( component, event, helper ) {
        
        /* var quoteRecord = component.get("v.quoteRecord");
        quoteRecord['Vehicle_Type__c'] = 'Automobile';
        quoteRecord['Policy_Type_picklist__c'] = 'Automobile';
        quoteRecord['Vehicle_Value__c'] = 5000;
        quoteRecord['Id'] = 'a0S2i000001YXPh';
        component.set("v.quoteRecord", quoteRecord);*/
        
        
        
        var policyType = component.get("v.policyType");
        if( policyType == 'Motorcycle/Street Legal ATV' ){
            component.set("v.qualitasLiability", '100000');
            component.set("v.chubbLiability", '100000');
            component.set("v.mapfreLiability", '100000');
            
            component.set("v.qualitasMedical", null);
            component.set("v.chubbMedical", null);
            component.set("v.mapfreMedical", null);
        }
        
        helper.getquickQuoteData(component, event, helper);
        helper.fetchCoverageDetail( component, event, helper );
        
        
        //console.log(component.get("v.mapfreLiability"));
    },
    
    fetchCoverageDetail : function( component, event, helper ){
        console.log('here---fetchCoverageDetail-');
        var quoteRecord = component.get("v.quoteRecord");
        component.set("v.policyType", quoteRecord['Policy_Type_picklist__c']);
        const action = component.get('c.getCoverageDetailForSouthbound');
        action.setParams({
            quoteRecord: component.get("v.quoteRecord")
        });
        action.setCallback(this, function (response) {
            
            if (response.getState() === 'SUCCESS') {
                console.log("@@@@ coverage map");
                
                var response = response.getReturnValue();
                if( response != null ){
                    component.set("v.maincoverageMap", response); 
                    helper.calculateCoverageDetail( component, event, helper );
                }
            } else {
                helper.showToast(response.getError().message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    calculateCoverageDetail : function( component, event, helper ){
        var maincoverageMap = component.get('v.maincoverageMap');
        console.log('--maincoverageMap--',maincoverageMap);
        
        var coverageMap ={};
        var qualitasLiablityOnly = component.get("v.qualitasLiablityOnly");
        var chubbLiablityOnly = component.get("v.chubbLiablityOnly");
        var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");
        var quoteRecord = component.get("v.quoteRecord");
        maincoverageMap.Qualitas.forEach(currentItem => {
            if( qualitasLiablityOnly && currentItem.Package__c == 'Liability'){
            if( ( quoteRecord.Territory_Coverage__c == 'Baja Sonara' 
            || quoteRecord.Territory_Coverage__c == 'Partial (US Adjacent)' ) 
            && currentItem.Territory_Discount__c == 'Yes' ){
            
            coverageMap['Qualitas'] = currentItem;
        }else{
                                         coverageMap['Qualitas'] = currentItem;
                                         }
                                         }else if( !qualitasLiablityOnly ){
            coverageMap['Qualitas'] = currentItem;
        }
    });
    
    maincoverageMap.Chubb.forEach(currentItem => {
    console.log("Chubb Map  ----> ", currentItem);
    if( chubbLiablityOnly && currentItem.Package__c == 'Liability'){
    console.log('Inside If');
    coverageMap['Chubb'] = currentItem;
}else if( !chubbLiablityOnly ) {
    console.log('Inside Else');
    coverageMap['Chubb'] = currentItem;
}
});

maincoverageMap.Mapfre.forEach(currentItem => {
    if( mapfreLiablityOnly == 'Liability' && currentItem.Package__c == 'Liability'){
    coverageMap['Mapfre'] = currentItem;
}else if( mapfreLiablityOnly == 'Max' && currentItem.Package__c == 'Max'  ) {
    coverageMap['Mapfre'] = currentItem;
}else if( mapfreLiablityOnly == 'Complete' && currentItem.Package__c == 'Complete'  ) {
    coverageMap['Mapfre'] = currentItem;
}else if( mapfreLiablityOnly == 'LiabilityTheft' && currentItem.Package__c == 'LiabilityTheft'  ) {
    coverageMap['Mapfre'] = currentItem;
}
});

console.log('--coverageMap--',coverageMap);
component.set('v.coverageMap', coverageMap);

},
    
    getquickQuoteData : function( component, event, helper ) {
        var quoteRecord = component.get("v.quoteRecord");
        //console.log('here---getquickQuoteData-',quoteRecord);
        //
        console.log("---- changes in liability in qualitasLiability-- "+  component.get("v.qualitasLiability"));
        console.log("---- changes in liability in chubbLiability-- "+  component.get("v.chubbLiability"));
        console.log("---- changes in liability in mapfreLiability-- "+  component.get("v.mapfreLiability"));
        var action = component.get("c.getquickQuoteDataSouthBound");
        var twoedunitId = '';
        var additional_towunit = component.get("v.additional_towunit");
        console.log("additional_towunit ", additional_towunit);
        if( additional_towunit && additional_towunit != null  ){
            twoedunitId = additional_towunit.Id;
        }
        
        
        action.setParams({  quoteRecord : component.get("v.quoteRecord"),
                          qualitasLiability : component.get("v.qualitasLiability"),
                          chubbLiability : component.get("v.chubbLiability"),
                          mapfreLiability : component.get("v.mapfreLiability"),
                          qualitasMedical : component.get("v.qualitasMedical"),
                          chubbMedical : component.get("v.chubbMedical"),
                          mapfreMedical : component.get("v.mapfreMedical"),
                          twoedunitId : twoedunitId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('----response--->>',response);
                if( response != null ){
                    response = JSON.parse(response);
                    component.set("v.rateRecord", response);
                    
                    helper.calculateRate( component, event, helper );
                }else{
                    component.set("v.qualitasRateValue", parseInt('0'));
                    component.set("v.chubbRateValue", parseInt('0'));
                    component.set("v.mapfreRateValue", parseInt('0'));
                } 
            }else{
                console.log('----response---',response);
            }
        });
        $A.enqueueAction(action);
    },
        
        updateQuoteHelper : function(component, event, helper) {
            const action = component.get('c.handleQuocteAction');
            action.setParams({
                quoteRecord: component.get("v.quoteRecord")
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        var quoteRecord = component.get("v.quoteRecord");
                        quoteRecord['Id'] = response.quoteId;
                        quoteRecord['Term_Days__c'] = response.quoteRecord.Term_Days__c;
                        quoteRecord['Term__c'] = response.quoteRecord.Term__c;
                        component.set("v.quoteRecord",quoteRecord);
                        
                        var name = event.target.name;
                        var response = component.get("v.rateRecord");
                        response['purchase'] = name;
                        response['Net_Premium__c'] = quoteRecord['Net_Premium__c'];
                        response['quoteId'] = quoteRecord.Id;
                        response['Type__c'] = component.get("v.policyType");
                        response['Underwriter__c'] = quoteRecord['Underwriter__c'];
                        response['quoteRecord'] = quoteRecord;
                        response['Total_Premium']= quoteRecord['Quote_Value__c'];
                        response['leadId'] = component.get("v.leadRecord").Id;
                        response['Broker_Policy_Fee__c']= quoteRecord['Broker_Policy_Fee__c'];
                        response['Package__c']= quoteRecord['Coverage__c'];
                        response['Medical__c']= quoteRecord['Medical__c'];
                        response['surcharge']= (quoteRecord['Surcharge__c'] != undefined ? quoteRecord['Surcharge__c'] : 0 );
                        response['IVA_Mex_Tax__c']= quoteRecord['I_V_A_Mex_Tax__c'];
                        response['Liability__c']= quoteRecord['Liability__c'];
                        response['year'] = quoteRecord['Vehicle_Year__c'];
                        response['model'] = quoteRecord['Vehicle_Model__c'];
                        response['make'] = quoteRecord['Vehicle_Make__c'];
                        
                        component.set("v.rateRecord", response);
                        
                        //helper.showToast('Quote updated successfully.', 'success');
                        
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
            
            updateQuoteForTowUnitHelper : function(component, event, helper) {
                console.log('---updateQuoteForTowUnitHelper--');
                const action = component.get('c.handleQuoteForTowUnitAction');
                var additional_towunit = component.get("v.additional_towunit");
                action.setParams({
                    additional_towunit: JSON.stringify(additional_towunit),
                    quoteObj: component.get("v.quoteRecord")
                });
                action.setCallback(this, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        var response = response.getReturnValue();
                        console.log('--additional_towunit---',response);
                        if( response.success){
                            try{
                                var additional_towunit = response.additional_towunit;
                                var quoteRecord = component.get("v.quoteRecord");
                                //quoteRecord['Id'] = additional_towunit.quoteRecord.Id;
                                //quoteRecord['Term_Days__c'] = response.daysBetween;
                                component.set("v.quoteRecord",quoteRecord);
                                
                                var returnQuoteRecord = additional_towunit.quoteRecord;
                                returnQuoteRecord['Start_Time__c'] = quoteRecord.Start_Time__c;
                                returnQuoteRecord['End_Time__c'] = quoteRecord.End_Time__c;
                                returnQuoteRecord['Term__c'] = quoteRecord.Term__c;
                                
                                quoteRecord = returnQuoteRecord;
                                component.set("v.quoteRecord",quoteRecord);
                                
                                var name = event.target.name;
                                console.log('name--->'+ name);
                                var response = component.get("v.rateRecord");
                                response['purchase'] = name;
                                response['Net_Premium__c'] = quoteRecord['Net_Premium__c'];
                                response['quoteId'] = quoteRecord.Id;
                                response['Type__c'] = component.get("v.policyType");
                                response['Underwriter__c'] = quoteRecord['Underwriter__c'];
                                response['quoteRecord'] = quoteRecord;
                                response['Total_Premium']= quoteRecord['Quote_Value__c'];
                                response['leadId'] = component.get("v.leadRecord").Id;
                                response['Broker_Policy_Fee__c']= quoteRecord['Broker_Policy_Fee__c'];
                                response['Package__c']= quoteRecord['Coverage__c'];
                                response['Medical__c']= quoteRecord['Medical__c'];
                                response['IVA_Mex_Tax__c']= quoteRecord['I_V_A_Mex_Tax__c'];
                                response['surcharge']= (quoteRecord['Surcharge__c'] != undefined ? quoteRecord['Surcharge__c'] : 0 );
                                response['Liability__c']= quoteRecord['Liability__c'];
                                
                                response['year'] = additional_towunit['Year__c'];
                                response['make'] = additional_towunit['Make__c'];
                                response['model'] = additional_towunit['Model__c'];
                                
                                additional_towunit['rateRecord'] = response;
                                additional_towunit['quoteRecord'] = quoteRecord;
                                component.set("v.rateRecord", response);
                                component.set("v.additional_towunit", additional_towunit);
                                //helper.showToast('Quote updated successfully.', 'success');
                                
                                $A.enqueueAction(component.get("v.onNextClick"));
                            }catch(ex){
                                console.log('----exception--',ex);
                            }
                            
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
                    
                    checkalreadyExistUser : function (component, event, helper) {
                        
                        var action = component.get("c.checkalreadyExistUserAction");
                        action.setParams({
                            emailAdder: component.get("v.emailAdder")
                        });
                        
                        action.setCallback(this, function (result) {
                            if (result.getState() === 'SUCCESS') {
                                var response = result.getReturnValue();
                                if (response.isExistUser) {
                                    helper.showToast('Please login to save your quote.', 'success');
                                } else {
                                    helper.saveQuoteHelper(component, event, helper, 'saveQuote');
                                }
                            } else {
                                helper.showToast(result.getError(), 'error');
                            }
                        });
                        $A.enqueueAction(action);
                    },
                        
                        saveQuoteHelper : function(component, event, helper, name) {
                            var action = component.get("c.saveQuoteAction");
                            
                            action.setParams({  
                                leadId : component.get("v.leadRecord").Id,
                                firstName :  component.get("v.leadRecord").Firstname,
                                lastName :  component.get("v.leadRecord").Lastname,
                                emailAdder: component.get("v.leadRecord").Email,
                                phoneNumber: component.get("v.leadRecord").Phone,
                                quoteId : component.get("v.quoteRecord").Id 
                            });
                            
                            action.setCallback(this, function(response) {
                                if (response.getState() === 'SUCCESS') {
                                    var response = response.getReturnValue();
                                    if( response.success){
                                        component.set("v.firstName", null);
                                        component.set("v.lastName", null);
                                        component.set("v.saveQuotePop", false);
                                        
                                        if(name == 'saveQuote'){
                                            helper.showToast( response.message, 'success');
                                        }
                                    }else{
                                        helper.showToast(response.message, 'error');
                                    }
                                } else {
                                    helper.showToast(response.getError(), 'error');
                                }
                            });
                            $A.enqueueAction(action);
                        },
                            
                            /* calculateRate : function(component, event, helper){
        try{
            var territoryCoverage = component.get("v.quoteRecord.Territory_Coverage__c");
            var response = component.get("v.rateRecord");
            var qualitasLiablityOnly = component.get("v.qualitasLiablityOnly");
            var chubbLiablityOnly = component.get("v.chubbLiablityOnly");
            var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");

            console.log('--response---',JSON.stringify(response, null, 4));
            var days = parseInt(response.days);
            var liabiltyOnly = component.get("v.liabiltyOnly");
            console.log('--liabiltyOnly---',liabiltyOnly);
            if( liabiltyOnly != null && liabiltyOnly != false ){
                component.set("v.showMapfre", response.MapfreData.showMapfre);
                component.set("v.showChubb", response.ChubbData.showChubb);
                component.set("v.showQualitas", response.qualitasData.showQualitas);
            }
            component.set("v.liabilityshowMapfre", response.MapfreData.showMapfre);
            component.set("v.liabilityshowChubb", response.ChubbData.showChubb);
            component.set("v.liabilityshowQualitas", response.qualitasData.showQualitas);
            

            component.set("v.rateRecord", response);
            console.log('@@territoryCoverage '+territoryCoverage);
            if( !days ){
                component.set("v.qualitasRateValue", parseInt('0'));
                component.set("v.chubbRateValue", parseInt('0'));
                component.set("v.mapfreRateValue", parseInt('0'));
                component.set("v.qualitas_Iva", parseInt('0'));
                
            }

            var qualitasDays = days;
            if( response && response.qualitasData ){
                if( qualitasLiablityOnly ){
                    var totalPremiumLiabilityOnly;
                    if(territoryCoverage && (territoryCoverage == "Partial (US Adjacent)" || territoryCoverage == "Baja Sonara")){
                        totalPremiumLiabilityOnly = response.qualitasData.LiabilityOnlyLimitedTerritory;
                    }
                    else{
                        totalPremiumLiabilityOnly = response.qualitasData.TotalPremiumLiabilityOnly;
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
                        
                        component.set("v.qualitasRateValue", qualitasRateValue);
                    }else{
                        component.set("v.qualitasRateValue", parseInt('0'));
                    }

                    if( response.qualitasData.IVALiabilityOnly ){
                        var IVALiabilityOnly = response.qualitasData.IVALiabilityOnly;

                        if( qualitasDays && qualitasDays <= 30 && IVALiabilityOnly.Daily ){
                            component.set("v.qualitas_Iva", parseFloat(IVALiabilityOnly.Daily));
                        }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180 && IVALiabilityOnly.Semi_annual ){
                            component.set("v.qualitas_Iva", parseFloat(IVALiabilityOnly.Semi_annual));
                        }else if( qualitasDays && qualitasDays > 180 && IVALiabilityOnly.Annual ){
                            component.set("v.qualitas_Iva", parseFloat(IVALiabilityOnly.Annual));
                        }

                      
                    }
                }else{
                    var totalCompleteCoverage;
                    if(territoryCoverage && (territoryCoverage == "Partial (US Adjacent)" || territoryCoverage == "Baja Sonara")){
                        totalCompleteCoverage = response.qualitasData.CompleteCoverageLimited;
                    }else{
                        totalCompleteCoverage = response.qualitasData.TotalCompleteCoverage;
                    }
                    if( totalCompleteCoverage ){
                       

                        var qualitasRateValue = 0;
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
                            }
                        }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                            qualitasRateValue = ( parseFloat(totalCompleteCoverage.Annual));
                        }
                        
                        component.set("v.qualitasRateValue", qualitasRateValue);

                    }else{
                        component.set("v.qualitasRateValue", parseInt('0'));
                    }

                    if( response.qualitasData.IVACompleteCoverage ){
                        var IVACompleteCoverage = response.qualitasData.IVACompleteCoverage;
                        if( qualitasDays && qualitasDays <= 30 && IVACompleteCoverage.Daily ){
                            component.set("v.qualitas_Iva", parseFloat(IVACompleteCoverage.Daily));
                        }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180 && IVACompleteCoverage.Semi_annual ){
                            component.set("v.qualitas_Iva", parseFloat(IVACompleteCoverage.Semi_annual));
                        }else if( qualitasDays && qualitasDays > 180 && IVACompleteCoverage.Annual ){
                            component.set("v.qualitas_Iva", parseFloat(IVACompleteCoverage.Annual));
                        }
                       
                    }

                }

                var brokerFee = response.qualitasData.brokerFee;
                if( qualitasDays && qualitasDays <= 30 && brokerFee && brokerFee.Daily && brokerFee.Daily != null  ){
                    component.set("v.qualitasBroker_Policy_Fee", parseFloat(brokerFee.Daily));
                }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && brokerFee.Semi_annual != null ){
                    component.set("v.qualitasBroker_Policy_Fee", parseFloat(brokerFee.Semi_annual));
                }else if( qualitasDays && qualitasDays > 180  && brokerFee.Annual != null ){
                    component.set("v.qualitasBroker_Policy_Fee", parseFloat(brokerFee.Annual));
                }else{
                    component.set("v.qualitasBroker_Policy_Fee", parseInt('0'));
                }

                var bsurcharge = 0;
                var businessSurcharge = response.qualitasData.businessSurcharge;
                if( qualitasDays && qualitasDays <= 30 && businessSurcharge && businessSurcharge.Daily && businessSurcharge.Daily != null  ){
                    bsurcharge = parseFloat(businessSurcharge.Daily);
                }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && businessSurcharge.Semi_annual != null ){
                    bsurcharge = parseFloat(businessSurcharge.Semi_annual);
                }else if( qualitasDays && qualitasDays > 180  && businessSurcharge.Annual != null ){
                    bsurcharge = parseFloat(businessSurcharge.Annual);
                }

                var ageSurcharge = response.qualitasData.ageSurcharge;
                var asurcharge = 0;
                if( qualitasDays && qualitasDays <= 30 && ageSurcharge && ageSurcharge.Daily && ageSurcharge.Daily != null  ){
                    asurcharge = parseFloat(ageSurcharge.Daily);
                }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && ageSurcharge.Semi_annual != null ){
                    asurcharge = parseFloat(ageSurcharge.Semi_annual);
                }else if( qualitasDays && qualitasDays > 180  && ageSurcharge.Annual != null ){
                    asurcharge = parseFloat(ageSurcharge.Annual);
                }
                console.log('-asurcharge---'+asurcharge);
                console.log('-bsurcharge---'+bsurcharge);
                component.set("v.qualitas_Surcharge", (asurcharge+bsurcharge));

            }   

            var chubDays = days;
            if( response && response.ChubbData ){
                if( chubbLiablityOnly ){
                    var totalPremiumLiabilityOnly = response.ChubbData.TotalPremiumLiabilityOnly;
                    if( totalPremiumLiabilityOnly ){
                     

                        var chubbRateValue = 0;
                        if( days && days <= 30 ){
                            if(totalPremiumLiabilityOnly.Daily ){
                                chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Daily);
                            }
                            if( totalPremiumLiabilityOnly.Semi_annual && ( parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                chubDays = 180;
                            }
                            if( totalPremiumLiabilityOnly.Annual && ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                chubDays = 365;
                            }
                        }else if( days && days > 30 && days <= 180 ){
                            if( totalPremiumLiabilityOnly.Semi_annual ){
                                chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                            }
                            if( totalPremiumLiabilityOnly.Annual && ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                chubDays = 365;
                            }
                        }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                            chubbRateValue = ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual));
                        }
                        console.log("CA log chubbRateValue 572 "+ chubbRateValue);
                        component.set("v.chubbRateValue", chubbRateValue );
                    }else{
                        component.set("v.chubbRateValue", parseInt('0'));
                    }
                }else{
                    var totalCompleteCoverage = response.ChubbData.TotalCompleteCoverage;
                    if( totalCompleteCoverage ){
                       

                        var chubbRateValue = 0;
                        if( days && days <= 30 ){
                            if(totalCompleteCoverage.Daily ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Daily);
                            }
                            if( totalCompleteCoverage.Semi_annual && ( parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Semi_annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Semi_annual);
                                chubDays = 180;
                            }
                            if( totalCompleteCoverage.Annual && ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual);
                                chubDays = 365;
                            }
                        }else if( days && days > 30 && days <= 180 ){
                            if( totalCompleteCoverage.Semi_annual ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Semi_annual);
                            }
                            console.log('@@ chubbRateValue'+chubbRateValue+'@@ annual='+parseFloat(totalCompleteCoverage.Annual)+' dis='+parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual)+' total='+(parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ));
                            if( totalCompleteCoverage.Annual && ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual);
                                chubDays = 365;
                            }
                        }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                            chubbRateValue = ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ) ;
                        }
                        
                        component.set("v.chubbRateValue", chubbRateValue );
                    }else{
                        component.set("v.chubbRateValue", parseInt('0'));
                    }
                }

                var brokerFee = response.ChubbData.brokerFee;
                if( chubDays && chubDays <= 30 && brokerFee && brokerFee.Daily != null  ){
                    component.set("v.chubbBroker_Policy_Fee", parseFloat(brokerFee.Daily));
                }else if( chubDays && chubDays > 30 && chubDays <= 180  && brokerFee.Semi_annual != null ){
                    component.set("v.chubbBroker_Policy_Fee", parseFloat(brokerFee.Semi_annual));
                }else if( chubDays && chubDays > 180  && brokerFee.Annual != null ){
                    component.set("v.chubbBroker_Policy_Fee", parseFloat(brokerFee.Annual));
                }else{
                    component.set("v.chubbBroker_Policy_Fee", parseInt('0'));
                }
                var chubbRateValue = component.get("v.chubbRateValue");
                var chubbBroker_Policy_Fee = component.get("v.chubbBroker_Policy_Fee");
                console.log('@@@ chubbRateValue '+chubbRateValue);
                console.log('@@@ chubbBroker_Policy_Fee '+chubbBroker_Policy_Fee);
                if( chubbRateValue != null && chubbRateValue > 0 ){
                    var quoteRecord = component.get("v.quoteRecord");
                    if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                        var chub_SurCharge = chubbRateValue - ( chubbBroker_Policy_Fee != null ? chubbBroker_Policy_Fee : 0);
                        chubbRateValue += chub_SurCharge;
                        console.log('@@ chub_SurCharge '+chub_SurCharge);
                        component.set("v.chubbRateValue", chubbRateValue); 
                        component.set("v.chub_SurCharge", chub_SurCharge); 
                    }
                }
            }

            var mapfreDays = days;
            console.log('mapfreLiablityOnly == '+mapfreLiablityOnly);
            if( response && response.MapfreData ){
                if( mapfreLiablityOnly == 'Liability' ){
                    var totalPremiumLiabilityOnly = response.MapfreData.liabilityOnlyTotal;
                    if( totalPremiumLiabilityOnly ){
                        console.log('inside 587'+JSON.stringify(totalPremiumLiabilityOnly));
                       

                        var mapfreRateValue = 0;
                        console.log('@@ days = '+days);
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
                            mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                            //component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Annual));
                        }
                        console.log(' mapfreRateValue '+JSON.stringify(mapfreRateValue));        
                        component.set("v.mapfreRateValue", mapfreRateValue );
                    }else{
                        component.set("v.mapfreRateValue", parseInt('0'));
                    }
                }
                else if( mapfreLiablityOnly == 'LiabilityTheft' ){
                    var totalPremiumLiabilityOnly = response.MapfreData.liabilityOnlyTotal;
                    var totalTheftVar = response.MapfreData.totalTheft;
                    if( totalPremiumLiabilityOnly ){
                       

                        var mapfreRateValue = 0;
                        if( days && days <= 30 ){
                            if( totalPremiumLiabilityOnly.Daily ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Daily + totalTheftVar.Daily);
                            }
                            if( totalPremiumLiabilityOnly.Days90 && parseFloat(totalPremiumLiabilityOnly.Days90 + totalTheftVar.Days90) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days90 + totalTheftVar.Days90);
                                mapfreDays = 90;
                            }
                            if( totalPremiumLiabilityOnly.Days180 && parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180) < mapfreRateValue){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180);
                                mapfreDays = 180;
                            }
                            if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                                mapfreDays = 365;
                            }
                        }else if( days && days > 30 && days <= 90 ){
                            if( totalPremiumLiabilityOnly.Days90  ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days90 + totalTheftVar.Days90);
                            }
                            if( totalPremiumLiabilityOnly.Days180 && parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180) < mapfreRateValue){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180);
                                mapfreDays = 180;
                            }
                            if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                                mapfreDays = 365;
                            }
                        }else if( days && days > 90 && days <= 180 ){
                            if( totalPremiumLiabilityOnly.Days180 ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180);
                                mapfreDays = 180;
                            }
                            if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                                mapfreDays = 365;
                            }
                        }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                            mapfreRateValue =  parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                        }
                        
                        component.set("v.mapfreRateValue", mapfreRateValue );
                    }else{
                        component.set("v.mapfreRateValue", parseInt('0'));
                    }
                }
                else if( mapfreLiablityOnly == 'Complete' ){
                    var totalCompleteCoverage = response.MapfreData.fullCoverageTotal;
                    console.log('#@@ mapfree '+JSON.stringify(totalCompleteCoverage));
                    console.log('-days---'+days);
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
                            console.log('--under 90---');
                            if( totalCompleteCoverage.Days90 ){
                                mapfreRateValue = parseFloat(totalCompleteCoverage.Days90);
                            }
                            console.log('--mapfreRateValue--'+mapfreRateValue);
                            if( totalCompleteCoverage.Days180 && totalCompleteCoverage.Days180 < mapfreRateValue){
                                mapfreRateValue = parseFloat(totalCompleteCoverage.Days180);
                                mapfreDays = 180;
                            }
                            console.log('--mapfreRateValue--'+mapfreRateValue);
                            if( totalCompleteCoverage.Annual && totalCompleteCoverage.Annual < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalCompleteCoverage.Annual);
                                mapfreDays = 365;
                            }
                            console.log('--mapfreRateValue--'+mapfreRateValue);
                        }else if( days && days > 90 && days <= 180 ){
                            console.log('--under 180---');
                            if( totalCompleteCoverage.Days180 ){
                                mapfreRateValue = parseFloat(totalCompleteCoverage.Days180);
                            }
                            if( totalCompleteCoverage.Annual && totalCompleteCoverage.Annual < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalCompleteCoverage.Annual);
                                mapfreDays = 365;
                            }
                        }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                            mapfreRateValue =  parseFloat(totalCompleteCoverage.Annual);
                        }
                        
                        component.set("v.mapfreRateValue", mapfreRateValue );
                    }else{
                        component.set("v.mapfreRateValue", parseInt('0'));
                    }
                }
                else if( mapfreLiablityOnly == 'Max' ){
                    var MaxCoverageTotal = response.MapfreData.MaxCoverageTotal;
                    console.log('#@@ mapfree '+JSON.stringify(MaxCoverageTotal));
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
                        
                        component.set("v.mapfreRateValue", mapfreRateValue );

                    }else{
                        component.set("v.mapfreRateValue", parseInt('0'));
                    }
                }

                var brokerFee = response.MapfreData.brokerFee;
                if( mapfreDays && mapfreDays <= 30 && brokerFee && brokerFee.Daily && brokerFee.Daily != null  ){
                    component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Daily));
                }else if( mapfreDays && mapfreDays > 30 && mapfreDays <= 90 && brokerFee.Daily && brokerFee.Days90 != null ){
                    component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Days90));
                }else if( mapfreDays && mapfreDays > 90 && mapfreDays <= 180 && brokerFee.Daily && brokerFee.Days180 != null ){
                    component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Days180));
                }else if( mapfreDays && mapfreDays > 180  && brokerFee.Daily && brokerFee.Annual != null ){
                    component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Annual));
                }else{
                    component.set("v.mapfreBroker_Policy_Fee", parseInt('0'));
                }
            }

            component.set('v.days',days);
            response['Days__c'] = days;
            if( days && days <= 30 ){
                response['Term__c'] = 'Daily';
            }else if( days && days > 30 && days <= 90 ){
                response['Term__c'] = '90 Days';
            }else if( days && days > 90 && days <= 180 ){
                response['Term__c'] = 'Semi-Annual';
            }else if( days && days > 180 ){
                response['Term__c'] = 'Annual';
            }


            var quoteRecord = component.get("v.quoteRecord");
            var totalvalue = 0;
            if( response.MapfreData && response.MapfreData.totalvalue != undefined){
                totalvalue = response.MapfreData.totalvalue;
            }
            
            var collision_deductible = 0;
            var theft_Total = 0;
            if( totalvalue != null  ){
                collision_deductible = totalvalue;
            }
            theft_Total = collision_deductible;

            var policyType = component.get("v.policyType");
            if( policyType == 'Automobile' ){
                collision_deductible =  collision_deductible * 0.02;
                theft_Total = theft_Total * 0.05;
                if( collision_deductible && collision_deductible > 500 ){
                    component.set("v.auto_collision_deductible", collision_deductible);
                }else if( policyType == 'Automobile' ){
                    component.set("v.auto_collision_deductible", 500);
                }
                if( theft_Total && theft_Total > 1000 ){
                    component.set("v.auto_theft_Total", theft_Total);
                }else if( policyType == 'Automobile' ){
                    component.set("v.auto_theft_Total", 1000);
                }
                
                helper.automobileMapfreCal(component, event, helper, totalvalue);

            }else if( policyType == 'RV' ){
                collision_deductible =  collision_deductible * 0.05;
                theft_Total = theft_Total * 0.05;
                
                if( collision_deductible && collision_deductible > 1000 ){
                    component.set("v.rv_collision_deductible", collision_deductible);
                }else{
                    component.set("v.rv_collision_deductible", 1000);
                }
                if( theft_Total && theft_Total > 1000 ){
                    component.set("v.rv_theft_Total", theft_Total);
                }else{
                    component.set("v.rv_theft_Total", 1000);
                }
            }else if( policyType == 'Motorcycle/Street Legal ATV' ){
                var moto_qual_collision_deductible = collision_deductible;
                var moto_qual_theft_Total = collision_deductible;

                var moto_map_collision_deductible = collision_deductible;
                var moto_map_theft_Total = collision_deductible;

                moto_qual_collision_deductible = moto_qual_collision_deductible * 0.02;
                moto_qual_theft_Total = moto_qual_collision_deductible * 0.05;
                if( moto_qual_collision_deductible && moto_qual_collision_deductible > 500 ){
                    component.set("v.moto_qual_collision_deductible", moto_qual_collision_deductible);
                    //component.set("v.moto_qual_theft_Total", moto_map_theft_Total);
                }else{
                    component.set("v.moto_qual_collision_deductible", 500);
                    //component.set("v.moto_qual_theft_Total", 500);
                }
                if( moto_qual_theft_Total && moto_qual_theft_Total > 1000 ){
                    component.set("v.moto_qual_theft_Total", moto_qual_theft_Total);
                }else{
                    component.set("v.moto_qual_theft_Total", 1000);
                }

                moto_map_collision_deductible = moto_map_collision_deductible * 0.02;
                moto_map_theft_Total = moto_map_collision_deductible * 0.05;
                if( moto_map_collision_deductible && moto_map_collision_deductible > 1000 ){
                    component.set("v.moto_map_collision_deductible", moto_map_collision_deductible);
                    //component.set("v.moto_map_theft_Total", moto_map_theft_Total);
                }else{
                    component.set("v.moto_map_collision_deductible", 1000);
                    //component.set("v.moto_map_theft_Total", 1000);
                }

                if( moto_map_theft_Total && moto_map_theft_Total > 1000 ){
                    component.set("v.moto_map_theft_Total", moto_map_theft_Total);
                }else{
                    component.set("v.moto_map_theft_Total", 1000);
                }

            }
            
        }catch( e ){
            console.log(e);
        }
    },
    */
                            calculateRate : function(component, event, helper){
                                let item1 = {};
                                let item2 = {};
                                let item3 = {};
                                try{
                                    var territoryCoverage = component.get("v.quoteRecord.Territory_Coverage__c");
                                    let polType = component.get("v.quoteRecord.Policy_Type_picklist__c");
                                    var response = component.get("v.rateRecord");
                                    var qualitasLiablityOnly = component.get("v.qualitasLiablityOnly");
                                    var chubbLiablityOnly = component.get("v.chubbLiablityOnly");
                                    var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");
                                    
                                    let itemId = polType.toLowerCase() == 'automobile' ? '0121C00000102F1QAI' : polType.toLowerCase() == 'rv' ? '0121C00000102F6QAI' : '0121C00000102F4QAI';
                                    
                                    console.log('--response---',JSON.stringify(response, null, 4));
                                    var days = parseInt(response.days);
                                    var liabiltyOnly = component.get("v.liabiltyOnly");
                                    console.log('--liabiltyOnly---',liabiltyOnly);
                                    if( liabiltyOnly != null && liabiltyOnly != false ){
                                        component.set("v.showMapfre", response.MapfreData.showMapfre);
                                        component.set("v.showChubb", response.ChubbData.showChubb);
                                        component.set("v.showQualitas", response.qualitasData.showQualitas);
                                    }else{
                                        component.set("v.showMapfre", response.MapfreData.showMapfre);
                                        component.set("v.showChubb", response.ChubbData.showChubb);
                                        component.set("v.showQualitas", response.qualitasData.showQualitas);
                                    }
                                    component.set("v.liabilityshowMapfre", response.MapfreData.showMapfre);
                                    component.set("v.liabilityshowChubb", response.ChubbData.showChubb);
                                    component.set("v.liabilityshowQualitas", response.qualitasData.showQualitas);
                                    
                                    
                                    component.set("v.rateRecord", response);
                                    console.log('@@territoryCoverage '+territoryCoverage);
                                    if( !days ){
                                        component.set("v.qualitasRateValue", parseInt('0'));
                                        component.set("v.chubbRateValue", parseInt('0'));
                                        component.set("v.mapfreRateValue", parseInt('0'));
                                        component.set("v.qualitas_Iva", parseInt('0'));
                                        
                                    }
                                    
                                    let q = component.get("v.showQualitas");
                                    let c = component.get("v.showChubb");
                                    let m = component.get("v.showMapfre");
                                    
                                    var qualitasDays = days;
                                    item1.item_name = "Automobile";
                                    item2.item_name = "Automobile";
                                    item3.item_name = "Automobile";
                                    
                                    item1.item_id = itemId + '-Qualitas';
                                    item2.item_id = itemId + '-Chubb';
                                    item3.item_id = itemId + '-Mapfre';
                                    
                                    item1.item_brand = "MexInsurance";
                                    item2.item_brand = "MexInsurance";
                                    item3.item_brand = "MexInsurance";
                                    
                                    item1.item_category = component.get("v.quoteRecord.Vehicle_Type__c");
                                    item2.item_category = component.get("v.quoteRecord.Vehicle_Type__c");
                                    item3.item_category = component.get("v.quoteRecord.Vehicle_Type__c");
                                    
                                    item1.item_category2 = days > 0 && days <= 30 ? "Daily" : days > 30 && days <= 180 ? "Semi-Annual(Half a Year)" : "Annual(One Year)";
                                    item2.item_category2 = days > 0 && days <= 30 ? "Daily" : days > 30 && days <= 180 ? "Semi-Annual(Half a Year)" : "Annual(One Year)";
                                    item3.item_category2 = days > 0 && days <= 30 ? "Daily" : days > 30 && days <= 180 ? "Semi-Annual(Half a Year)" : "Annual(One Year)";
                                    
                                    item1.item_category3 = territoryCoverage;
                                    item2.item_category3 = territoryCoverage;
                                    item3.item_category3 = territoryCoverage;
                                    
                                    item1.item_category4 = "Qualitas";
                                    item2.item_category4 = "Chubb";
                                    item3.item_category4 = "MapFre";
                                    
                                    item1.item_list_name = polType + " Quote Page";
                                    item2.item_list_name = polType + " Quote Page";
                                    item3.item_list_name = polType + " Quote Page";

                                    item1.quantity = 1;
                                    item2.quantity = 1;
                                    item1.quantity = 1;
                                    
                                    item1.index = q ? 1 : "";
                                    item2.index = q && c ? 2 : !q && c ? 1 : "";
                                    item3.index = q && c && m ? 3 : q || c && m ? 2 : 1;

                                    if( response && response.qualitasData ){
                                        if( qualitasLiablityOnly ){
                                            var totalPremiumLiabilityOnly;
                                            item1.item_variant = "Liability";
                                            if(territoryCoverage && (territoryCoverage == "Partial (US Adjacent)" || territoryCoverage == "Baja Sonora")){
                                                totalPremiumLiabilityOnly = response.qualitasData.LiabilityOnlyLimitedTerritory;
                                            }
                                            else{
                                                totalPremiumLiabilityOnly = response.qualitasData.TotalPremiumLiabilityOnly;
                                            }
                                            if( totalPremiumLiabilityOnly ){
                                                /*if( days && days <= 30 && totalPremiumLiabilityOnly.Daily ){
                            component.set("v.qualitasRateValue", parseFloat(totalPremiumLiabilityOnly.Daily));
                        }else if( days && days > 30 && days <= 180 && totalPremiumLiabilityOnly.Semi_annual ){
                            component.set("v.qualitasRateValue", parseFloat(totalPremiumLiabilityOnly.Semi_annual));
                        }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                            component.set("v.qualitasRateValue", parseFloat(totalPremiumLiabilityOnly.Annual));
                        }*/
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
                                                
                                                item1.price = qualitasRateValue;
                                                component.set("v.qualitasRateValue", qualitasRateValue);
                                            }else{
                                                component.set("v.qualitasRateValue", parseInt('0'));
                                            }
                                            
                                            if( response.qualitasData.IVALiabilityOnly ){
                                                var IVALiabilityOnly = response.qualitasData.IVALiabilityOnly;
                                                
                                                if( qualitasDays && qualitasDays <= 30 && IVALiabilityOnly.Daily ){
                                                    component.set("v.qualitas_Iva", parseFloat(IVALiabilityOnly.Daily));
                                                }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180 && IVALiabilityOnly.Semi_annual ){
                                                    component.set("v.qualitas_Iva", parseFloat(IVALiabilityOnly.Semi_annual));
                                                }else if( qualitasDays && qualitasDays > 180 && IVALiabilityOnly.Annual ){
                                                    component.set("v.qualitas_Iva", parseFloat(IVALiabilityOnly.Annual));
                                                }
                                                
                                                /*var qualitas_Iva = 0;
                        if( IVALiabilityOnly.Daily ){
                            qualitas_Iva = parseFloat(IVALiabilityOnly.Daily);
                        }
                        if( IVALiabilityOnly.Semi_annual && parseFloat(IVALiabilityOnly.Semi_annual) < qualitas_Iva ){
                            qualitas_Iva = parseFloat(IVALiabilityOnly.Semi_annual);
                        }
                        if( IVALiabilityOnly.Annual && parseFloat(IVALiabilityOnly.Annual) < qualitas_Iva ){
                            qualitas_Iva = parseFloat(IVALiabilityOnly.Annual);
                        }
                        component.set("v.qualitas_Iva",qualitas_Iva);*/
                        }
                                        }else{
                                            var totalCompleteCoverage;
                                            item1.item_variant = "Complete";
                                            if(territoryCoverage && (territoryCoverage == "Partial (US Adjacent)" || territoryCoverage == "Baja Sonora")){
                                                totalCompleteCoverage = response.qualitasData.CompleteCoverageLimited;
                                            }else{
                                                totalCompleteCoverage = response.qualitasData.TotalCompleteCoverage;
                                            }
                                            if( totalCompleteCoverage ){
                                                /*if( days && days <= 30 && totalCompleteCoverage.Daily ){
                            component.set("v.qualitasRateValue", parseFloat(totalCompleteCoverage.Daily));
                        }else if( days && days > 30 && days <= 180 && totalCompleteCoverage.Semi_annual ){
                            component.set("v.qualitasRateValue", parseFloat(totalCompleteCoverage.Semi_annual));
                        }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                            component.set("v.qualitasRateValue", parseFloat(totalCompleteCoverage.Annual));
                        }*/
                            
                            var qualitasRateValue = 0;
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
                                }
                            }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                                qualitasRateValue = ( parseFloat(totalCompleteCoverage.Annual));
                            }
                            
                            item1.price = qualitasRateValue;                        
                            component.set("v.qualitasRateValue", qualitasRateValue);
                            
                        }else{
                            component.set("v.qualitasRateValue", parseInt('0'));
                        }
                        
                        if( response.qualitasData.IVACompleteCoverage ){
                            var IVACompleteCoverage = response.qualitasData.IVACompleteCoverage;
                            if( qualitasDays && qualitasDays <= 30 && IVACompleteCoverage.Daily ){
                                component.set("v.qualitas_Iva", parseFloat(IVACompleteCoverage.Daily));
                            }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180 && IVACompleteCoverage.Semi_annual ){
                                component.set("v.qualitas_Iva", parseFloat(IVACompleteCoverage.Semi_annual));
                            }else if( qualitasDays && qualitasDays > 180 && IVACompleteCoverage.Annual ){
                                component.set("v.qualitas_Iva", parseFloat(IVACompleteCoverage.Annual));
                            }
                            /*var qualitas_Iva = 0;
                        if( IVACompleteCoverage.Daily ){
                            qualitas_Iva = parseFloat(IVACompleteCoverage.Daily);
                        }
                        if( IVACompleteCoverage.Semi_annual && parseFloat(IVACompleteCoverage.Semi_annual) < qualitas_Iva ){
                            qualitas_Iva = parseFloat(IVACompleteCoverage.Semi_annual);
                        }
                        if( IVACompleteCoverage.Annual && parseFloat(IVACompleteCoverage.Annual) < qualitas_Iva ){
                            qualitas_Iva = parseFloat(IVACompleteCoverage.Annual);
                        }
                        component.set("v.qualitas_Iva",qualitas_Iva);*/
                    }
                        
                    }
                                        
                                        var brokerFee = response.qualitasData.brokerFee;
                                        if( qualitasDays && qualitasDays <= 30 && brokerFee && brokerFee.Daily && brokerFee.Daily != null  ){
                                            component.set("v.qualitasBroker_Policy_Fee", parseFloat(brokerFee.Daily));
                                        }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && brokerFee.Semi_annual != null ){
                                            component.set("v.qualitasBroker_Policy_Fee", parseFloat(brokerFee.Semi_annual));
                                        }else if( qualitasDays && qualitasDays > 180  && brokerFee.Annual != null ){
                                            component.set("v.qualitasBroker_Policy_Fee", parseFloat(brokerFee.Annual));
                                        }else{
                                            component.set("v.qualitasBroker_Policy_Fee", parseInt('0'));
                                        }
                                        
                                        var bsurcharge = 0;
                                        var businessSurcharge = response.qualitasData.businessSurcharge;
                                        if( qualitasDays && qualitasDays <= 30 && businessSurcharge && businessSurcharge.Daily && businessSurcharge.Daily != null  ){
                                            bsurcharge = parseFloat(businessSurcharge.Daily);
                                        }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && businessSurcharge.Semi_annual != null ){
                                            bsurcharge = parseFloat(businessSurcharge.Semi_annual);
                                        }else if( qualitasDays && qualitasDays > 180  && businessSurcharge.Annual != null ){
                                            bsurcharge = parseFloat(businessSurcharge.Annual);
                                        }
                                        
                                        var ageSurcharge = response.qualitasData.ageSurcharge;
                                        var asurcharge = 0;
                                        if( qualitasDays && qualitasDays <= 30 && ageSurcharge && ageSurcharge.Daily && ageSurcharge.Daily != null  ){
                                            asurcharge = parseFloat(ageSurcharge.Daily);
                                        }else if( qualitasDays && qualitasDays > 30 && qualitasDays <= 180  && ageSurcharge.Semi_annual != null ){
                                            asurcharge = parseFloat(ageSurcharge.Semi_annual);
                                        }else if( qualitasDays && qualitasDays > 180  && ageSurcharge.Annual != null ){
                                            asurcharge = parseFloat(ageSurcharge.Annual);
                                        }
                                        console.log('-asurcharge---'+asurcharge);
                                        console.log('-bsurcharge---'+bsurcharge);
                                        component.set("v.qualitas_Surcharge", (asurcharge+bsurcharge));
                                        
                                    }   
                                    
                                    var chubDays = days;
                                    let physical_damage_payment = 0;
                                    let Liability_payment = 0;
                                    let medical_payment = 0;
                                    let platinum_endorsement_payment = 0;
                                    let total_theft_payment = 0;
                                    if( response && response.ChubbData ){
                                        if( chubbLiablityOnly ){
                                            item2.item_variant = "Liability";
                                            var totalPremiumLiabilityOnly = response.ChubbData.TotalPremiumLiabilityOnly;
                                            if( totalPremiumLiabilityOnly ){
                                                /*if( days && days <= 30 && totalPremiumLiabilityOnly.Daily ){
                            component.set("v.chubbRateValue", parseFloat(totalPremiumLiabilityOnly.Daily));
                        }else if( days && days > 30 && days <= 180 && totalPremiumLiabilityOnly.Semi_annual ){
                            component.set("v.chubbRateValue", parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual));
                        }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                            component.set("v.chubbRateValue", parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual));
                        }*/
                            
                            var brokerFee = response.ChubbData.brokerFee;
                            
                            var quoteRecord = component.get("v.quoteRecord");
                            var chubbRateValue = 0;
                            if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                
                                if( days && days <= 30 ){
                                    if(totalPremiumLiabilityOnly.Daily ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Daily);
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Daily);
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Daily) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Daily);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Daily);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Daily);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Daily) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                            var chub_SurCharge = chubbRateValue - ( parseFloat(brokerFee.Daily));
                                            chubbRateValue += chub_SurCharge;
                                            console.log('@@ chub_SurCharge '+chub_SurCharge);
                                            component.set("v.chubbRateValue", chubbRateValue); 
                                            component.set("v.chub_SurCharge", chub_SurCharge); 
                                        }
                                    }
                                    if( totalPremiumLiabilityOnly.Semi_annual && ( 
                                        (parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual) ) + 
                                        ( parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual) -  parseFloat(brokerFee.Semi_annual))
                                        
                                    ) < chubbRateValue ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                        chubDays = 180;
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Semi_annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Semi_annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Semi_annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Semi_annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        
                                        if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                            var chub_SurCharge = chubbRateValue - (parseFloat(brokerFee.Semi_annual));
                                            chubbRateValue += chub_SurCharge;
                                            console.log('@@ chub_SurCharge '+chub_SurCharge);
                                            component.set("v.chubbRateValue", chubbRateValue); 
                                            component.set("v.chub_SurCharge", chub_SurCharge); 
                                        }
                                    }
                                    if( totalPremiumLiabilityOnly.Annual && ( 
                                        (parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual)) + 
                                        (parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) - parseFloat(brokerFee.Annual))
                                    ) < chubbRateValue ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                        chubDays = 365;
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        
                                        if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                            var chub_SurCharge = chubbRateValue - (  parseFloat(brokerFee.Annual));
                                            chubbRateValue += chub_SurCharge;
                                            console.log('@@ chub_SurCharge '+chub_SurCharge);
                                            component.set("v.chubbRateValue", chubbRateValue); 
                                            component.set("v.chub_SurCharge", chub_SurCharge); 
                                        }
                                        
                                    }
                                }else if( days && days > 30 && days <= 180 ){
                                    if( totalPremiumLiabilityOnly.Semi_annual ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Semi_annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Semi_annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Semi_annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Semi_annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        
                                        
                                        if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                            var chub_SurCharge = chubbRateValue - ( parseFloat(brokerFee.Semi_annual));
                                            chubbRateValue += chub_SurCharge;
                                            console.log('@@ chub_SurCharge '+chub_SurCharge);
                                            component.set("v.chubbRateValue", chubbRateValue); 
                                            component.set("v.chub_SurCharge", chub_SurCharge); 
                                        }
                                    }
                                    if( totalPremiumLiabilityOnly.Annual && (
                                        (parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual)) + 
                                        (parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) - parseFloat(brokerFee.Annual))
                                    ) < chubbRateValue ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                        chubDays = 365;
                                        
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        
                                        
                                        if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                            var chub_SurCharge = chubbRateValue - ( parseFloat(brokerFee.Annual));
                                            chubbRateValue += chub_SurCharge;
                                            console.log('@@ chub_SurCharge '+chub_SurCharge);
                                            component.set("v.chubbRateValue", chubbRateValue); 
                                            component.set("v.chub_SurCharge", chub_SurCharge); 
                                        }
                                    }
                                }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                                    chubbRateValue = ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual));
                                    physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                    Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                    medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                    platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                    total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                    
                                    
                                    if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                        var chub_SurCharge = chubbRateValue - ( parseFloat(brokerFee.Annual));
                                        chubbRateValue += chub_SurCharge;
                                        console.log('@@ chub_SurCharge '+chub_SurCharge);
                                        component.set("v.chubbRateValue", chubbRateValue); 
                                        component.set("v.chub_SurCharge", chub_SurCharge); 
                                    }
                                }
                                item2.price = chubbRateValue;
                                
                            }else{
                                
                                if( days && days <= 30 ){
                                    if(totalPremiumLiabilityOnly.Daily ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Daily);
                                        
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Daily) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Daily);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Daily);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Daily);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Daily) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                    }
                                    if( totalPremiumLiabilityOnly.Semi_annual && ( parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual) ) < chubbRateValue ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                        chubDays = 180;
                                        
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Semi_annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Semi_annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Semi_annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Semi_annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        
                                    }
                                    if( totalPremiumLiabilityOnly.Annual && ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) ) < chubbRateValue ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                        chubDays = 365;
                                        
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                    }
                                }else if( days && days > 30 && days <= 180 ){
                                    if( totalPremiumLiabilityOnly.Semi_annual ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                        
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Semi_annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Semi_annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Semi_annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Semi_annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        
                                    }
                                    if( totalPremiumLiabilityOnly.Annual && ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) ) < chubbRateValue ){
                                        chubbRateValue = parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                        chubDays = 365;
                                        physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                        Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                        medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                        platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                        total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                        
                                    }
                                }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                                    chubbRateValue = ( parseFloat(totalPremiumLiabilityOnly.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual));
                                    
                                    physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                    Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                    medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                    platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                    total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                    
                                }
                                
                            }
                            console.log("CA log chubbRateValue 572 "+ chubbRateValue);
                            item2.price = chubbRateValue;
                            component.set("v.chubbRateValue", chubbRateValue );
                            
                            component.set("v.physicalDamagePayment", physical_damage_payment );
                            component.set("v.LiabilityPayment", Liability_payment );
                            component.set("v.medicalPayment", medical_payment );
                            component.set("v.platinumEndorsementPayment", platinum_endorsement_payment );
                            component.set("v.totalTheftPayment", total_theft_payment );
                        }else{
                            component.set("v.chubbRateValue", parseInt('0'));
                            
                            component.set("v.physicalDamagePayment", parseInt('0') );
                            component.set("v.LiabilityPayment", parseInt('0') );
                            component.set("v.medicalPayment", parseInt('0') );
                            component.set("v.platinumEndorsementPayment", parseInt('0') );
                            component.set("v.totalTheftPayment", parseInt('0') );
                        }
                    }else{
                        item2.item_variant = "Complete";
                        var totalCompleteCoverage = response.ChubbData.TotalCompleteCoverage;
                        if( totalCompleteCoverage ){
                            /*if( days && days <= 30 && totalCompleteCoverage.Daily ){
                            component.set("v.chubbRateValue", parseFloat(totalCompleteCoverage.Daily));
                        }else if( days && days > 30 && days <= 180 && totalCompleteCoverage.Semi_annual ){
                            component.set("v.chubbRateValue", parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Semi_annual));
                        }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                            component.set("v.chubbRateValue", parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual));
                        }*/
                        
                        var chubbRateValue = 0;
                        if( days && days <= 30 ){
                            if(totalCompleteCoverage.Daily ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Daily);
                                
                                physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Daily) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                Liability_payment = parseFloat(response.ChubbData.Liability.Daily);
                                medical_payment = parseFloat(response.ChubbData.Medical.Daily);
                                platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementCompleteCoverage.Daily);
                                total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Daily) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                
                            }
                            if( totalCompleteCoverage.Semi_annual && ( parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Semi_annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Semi_annual);
                                chubDays = 180;
                                
                                physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Semi_annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                Liability_payment = parseFloat(response.ChubbData.Liability.Semi_annual);
                                medical_payment = parseFloat(response.ChubbData.Medical.Semi_annual);
                                platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementCompleteCoverage.Semi_annual);
                                total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Semi_annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                
                            }
                            if( totalCompleteCoverage.Annual && ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual);
                                chubDays = 365;
                                
                                physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementCompleteCoverage.Annual);
                                total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                
                            }
                        }else if( days && days > 30 && days <= 180 ){
                            if( totalCompleteCoverage.Semi_annual ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Semi_annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Semi_annual);
                                
                                physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Semi_annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                Liability_payment = parseFloat(response.ChubbData.Liability.Semi_annual);
                                medical_payment = parseFloat(response.ChubbData.Medical.Semi_annual);
                                platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementCompleteCoverage.Semi_annual);
                                total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Semi_annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                
                            }
                            console.log('@@ chubbRateValue'+chubbRateValue+'@@ annual='+parseFloat(totalCompleteCoverage.Annual)+' dis='+parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual)+' total='+(parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ));
                            if( totalCompleteCoverage.Annual && ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ) < chubbRateValue ){
                                chubbRateValue = parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual);
                                chubDays = 365;
                                
                                physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                                Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                                medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                                platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementCompleteCoverage.Annual);
                                total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                                
                            }
                        }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                            chubbRateValue = ( parseFloat(totalCompleteCoverage.Annual) - parseFloat(response.ChubbData.BajaSonaraDiscountComplete.Annual) ) ;
                            
                            physical_damage_payment = parseFloat(response.ChubbData.PhysicalDamage.Annual) + parseFloat(response.ChubbData.TowedUnitPhysicalDamage != null ? response.ChubbData.TowedUnitPhysicalDamage : 0);
                            Liability_payment = parseFloat(response.ChubbData.Liability.Annual);
                            medical_payment = parseFloat(response.ChubbData.Medical.Annual);
                            platinum_endorsement_payment = parseFloat(response.ChubbData.PlatinumEndorsementCompleteCoverage.Annual);
                            total_theft_payment = parseFloat(response.ChubbData.TotalTheft.Annual) + parseFloat(response.ChubbData.TowedUnitTotalTheft != null ? response.ChubbData.TowedUnitTotalTheft : 0);
                            
                        }
                        
                        item2.price = chubbRateValue;
                        component.set("v.chubbRateValue", chubbRateValue );
                        
                        component.set("v.physicalDamagePayment", physical_damage_payment );
                        component.set("v.LiabilityPayment", Liability_payment );
                        component.set("v.medicalPayment", medical_payment );
                        component.set("v.platinumEndorsementPayment", platinum_endorsement_payment );
                        component.set("v.totalTheftPayment", total_theft_payment );
                    }else{
                        component.set("v.chubbRateValue", parseInt('0'));
                        component.set("v.physicalDamagePayment", parseInt('0') );
                        component.set("v.LiabilityPayment", parseInt('0') );
                        component.set("v.medicalPayment", parseInt('0') );
                        component.set("v.platinumEndorsementPayment", parseInt('0') );
                        component.set("v.totalTheftPayment", parseInt('0') );
                    }
                }
                    
                    if(!chubbLiablityOnly || (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c != 'Yes')){
                        var brokerFee = response.ChubbData.brokerFee;
                        if( chubDays && chubDays <= 30 && brokerFee && brokerFee.Daily != null  ){
                            component.set("v.chubbBroker_Policy_Fee", parseFloat(brokerFee.Daily));
                        }else if( chubDays && chubDays > 30 && chubDays <= 180  && brokerFee.Semi_annual != null ){
                            component.set("v.chubbBroker_Policy_Fee", parseFloat(brokerFee.Semi_annual));
                        }else if( chubDays && chubDays > 180  && brokerFee.Annual != null ){
                            component.set("v.chubbBroker_Policy_Fee", parseFloat(brokerFee.Annual));
                        }else{
                            component.set("v.chubbBroker_Policy_Fee", parseInt('0'));
                        }
                        var chubbRateValue = component.get("v.chubbRateValue");
                        var chubbBroker_Policy_Fee = component.get("v.chubbBroker_Policy_Fee");
                        console.log('@@@ chubbRateValue '+chubbRateValue);
                        console.log('@@@ chubbBroker_Policy_Fee '+chubbBroker_Policy_Fee);
                        if( chubbRateValue != null && chubbRateValue > 0 ){
                            var quoteRecord = component.get("v.quoteRecord");
                            if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                var chub_SurCharge = chubbRateValue - ( chubbBroker_Policy_Fee != null ? chubbBroker_Policy_Fee : 0);
                                chubbRateValue += chub_SurCharge;
                                console.log('@@ chub_SurCharge '+chub_SurCharge);
                                component.set("v.chubbRateValue", chubbRateValue); 
                                component.set("v.chub_SurCharge", chub_SurCharge); 
                            }
                        }
                    }
                    
                }
                                    
                                    var mapfreDays = days;
                                    console.log('mapfreLiablityOnly == '+mapfreLiablityOnly);
                                    if( response && response.MapfreData ){
                                        if( mapfreLiablityOnly == 'Liability' ){
                                            item3.item_variant = "Liability";
                                            var totalPremiumLiabilityOnly = response.MapfreData.liabilityOnlyTotal;
                                            if( totalPremiumLiabilityOnly ){
                                                console.log('inside 587'+JSON.stringify(totalPremiumLiabilityOnly));
                                                /*if( days && days <= 30 && totalPremiumLiabilityOnly.Daily ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Daily));
                        }else if( days && days > 30 && days <= 90 && totalPremiumLiabilityOnly.Days90 ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Days90));
                        }else if( days && days > 30 && days <= 180 && totalPremiumLiabilityOnly.Days180 ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Days180));
                        }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Annual));
                        }*/
                            
                            var mapfreRateValue = 0;
                            console.log('@@ days = '+days);
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
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual);
                                //component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Annual));
                            }
                            console.log(' mapfreRateValue '+JSON.stringify(mapfreRateValue));
                            item3.price = mapfreRateValue;
                            component.set("v.mapfreRateValue", mapfreRateValue );
                        }else{
                            component.set("v.mapfreRateValue", parseInt('0'));
                        }
                        
                        if (response.MapfreData.IVAliabilityOnlyTotal) {
                            let IVALiabilityOnlyTotal = response.MapfreData.IVAliabilityOnlyTotal;
                            
                            if (mapfreDays && mapfreDays <=30 && IVALiabilityOnlyTotal.Daily) {
                                component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Daily));
                            } else if (mapfreDays && mapfreDays > 30 && mapfreDays <=90 && IVALiabilityOnlyTotal.Days90) {
                                component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Days90));
                            } else if (mapfreDays && mapfreDays > 90 && mapfreDays <=180 && IVALiabilityOnlyTotal.Days180) {
                                component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Days180));
                            } else if (mapfreDays && mapfreDays > 180 && IVALiabilityOnlyTotal.Annual) {
                                component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Annual));
                            }
                        }
                    }
                    else if( mapfreLiablityOnly == 'LiabilityTheft' ){
                        item3.item_variant = "LiabilityTheft";
                        var totalPremiumLiabilityOnly = response.MapfreData.liabilityOnlyTotal;
                        var totalTheftVar = response.MapfreData.totalTheft;
                        if( totalPremiumLiabilityOnly ){
                            /*if( days && days <= 30 && totalPremiumLiabilityOnly.Daily ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Daily + totalTheftVar.Daily));
                        }else if( days && days > 30 && days <= 90 && totalPremiumLiabilityOnly.Days90 ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Days90 + totalTheftVar.Days90));
                        }else if( days && days > 30 && days <= 180 && totalPremiumLiabilityOnly.Days180 ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180));
                        }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                            component.set("v.mapfreRateValue", parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual));
                        }*/
                        
                        var mapfreRateValue = 0;
                        if( days && days <= 30 ){
                            if( totalPremiumLiabilityOnly.Daily ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Daily + totalTheftVar.Daily);
                            }
                            if( totalPremiumLiabilityOnly.Days90 && parseFloat(totalPremiumLiabilityOnly.Days90 + totalTheftVar.Days90) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days90 + totalTheftVar.Days90);
                                mapfreDays = 90;
                            }
                            if( totalPremiumLiabilityOnly.Days180 && parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180) < mapfreRateValue){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180);
                                mapfreDays = 180;
                            }
                            if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                                mapfreDays = 365;
                            }
                        }else if( days && days > 30 && days <= 90 ){
                            if( totalPremiumLiabilityOnly.Days90  ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days90 + totalTheftVar.Days90);
                            }
                            if( totalPremiumLiabilityOnly.Days180 && parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180) < mapfreRateValue){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180);
                                mapfreDays = 180;
                            }
                            if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                                mapfreDays = 365;
                            }
                        }else if( days && days > 90 && days <= 180 ){
                            if( totalPremiumLiabilityOnly.Days180 ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Days180 + totalTheftVar.Days180);
                                mapfreDays = 180;
                            }
                            if( totalPremiumLiabilityOnly.Annual && parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual) < mapfreRateValue ){
                                mapfreRateValue = parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                                mapfreDays = 365;
                            }
                        }else if( days && days > 180 && totalPremiumLiabilityOnly.Annual ){
                            mapfreRateValue =  parseFloat(totalPremiumLiabilityOnly.Annual + totalTheftVar.Annual);
                        }
                        
                        item3.price = mapfreRateValue;
                        component.set("v.mapfreRateValue", mapfreRateValue );
                    }else{
                        component.set("v.mapfreRateValue", parseInt('0'));
                    }
                    
                    if (response.MapfreData.IVAliabilityOnlyTotal) {
                        let IVALiabilityOnlyTotal = response.MapfreData.IVAliabilityOnlyTotal;
                        
                        if (mapfreDays && mapfreDays <=30 && IVALiabilityOnlyTotal.Daily) {
                            component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Daily));
                        } else if (mapfreDays && mapfreDays > 30 && mapfreDays <=90 && IVALiabilityOnlyTotal.Days90) {
                            component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Days90));
                        } else if (mapfreDays && mapfreDays > 90 && mapfreDays <=180 && IVALiabilityOnlyTotal.Days180) {
                            component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Days180));
                        } else if (mapfreDays && mapfreDays > 180 && IVALiabilityOnlyTotal.Annual) {
                            component.set('v.mapfre_iva', parseFloat(IVALiabilityOnlyTotal.Annual));
                        }
                    }
                }
                    else if( mapfreLiablityOnly == 'Complete' ){
                        item3.item_variant = "Complete";
                        var totalCompleteCoverage = response.MapfreData.fullCoverageTotal;
                        console.log('#@@ mapfree '+JSON.stringify(totalCompleteCoverage));
                        console.log('-days---'+days);
                        if( totalCompleteCoverage ){
                            /*if( days && days <= 30 && totalCompleteCoverage.Daily ){
                            component.set("v.mapfreRateValue", parseFloat(totalCompleteCoverage.Daily));
                        }else if( days && days > 30 && days <= 90 && totalCompleteCoverage.Days90 ){
                            component.set("v.mapfreRateValue", parseFloat(totalCompleteCoverage.Days90));
                        }else if( days && days > 30 && days <= 180 && totalCompleteCoverage.Days180 ){
                            component.set("v.mapfreRateValue", parseFloat(totalCompleteCoverage.Days180));
                        }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                            component.set("v.mapfreRateValue", parseFloat(totalCompleteCoverage.Annual));
                        }*/
                            
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
                                console.log('--under 90---');
                                if( totalCompleteCoverage.Days90 ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days90);
                                }
                                console.log('--mapfreRateValue--'+mapfreRateValue);
                                if( totalCompleteCoverage.Days180 && totalCompleteCoverage.Days180 < mapfreRateValue){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days180);
                                    mapfreDays = 180;
                                }
                                console.log('--mapfreRateValue--'+mapfreRateValue);
                                if( totalCompleteCoverage.Annual && totalCompleteCoverage.Annual < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Annual);
                                    mapfreDays = 365;
                                }
                                console.log('--mapfreRateValue--'+mapfreRateValue);
                            }else if( days && days > 90 && days <= 180 ){
                                console.log('--under 180---');
                                if( totalCompleteCoverage.Days180 ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Days180);
                                }
                                if( totalCompleteCoverage.Annual && totalCompleteCoverage.Annual < mapfreRateValue ){
                                    mapfreRateValue = parseFloat(totalCompleteCoverage.Annual);
                                    mapfreDays = 365;
                                }
                            }else if( days && days > 180 && totalCompleteCoverage.Annual ){
                                mapfreRateValue =  parseFloat(totalCompleteCoverage.Annual);
                            }
                            
                            item3.price = mapfreRateValue;
                            component.set("v.mapfreRateValue", mapfreRateValue );
                        }else{
                            component.set("v.mapfreRateValue", parseInt('0'));
                        }
                        
                        if (response.MapfreData.IVAFullCoverage) {
                            let IVAFullCoverageTotal = response.MapfreData.IVAFullCoverage;
                            
                            if (mapfreDays && mapfreDays <=30 && IVAFullCoverageTotal.Daily) {
                                component.set('v.mapfre_iva', parseFloat(IVAFullCoverageTotal.Daily));
                            } else if (mapfreDays && mapfreDays > 30 && mapfreDays <=90 && IVAFullCoverageTotal.Days90) {
                                component.set('v.mapfre_iva', parseFloat(IVAFullCoverageTotal.Days90));
                            } else if (mapfreDays && mapfreDays > 90 && mapfreDays <=180 && IVAFullCoverageTotal.Days180) {
                                component.set('v.mapfre_iva', parseFloat(IVAFullCoverageTotal.Days180));
                            } else if (mapfreDays && mapfreDays > 180 && IVAFullCoverageTotal.Annual) {
                                component.set('v.mapfre_iva', parseFloat(IVAFullCoverageTotal.Annual));
                            }
                        }
                    }
                        else if( mapfreLiablityOnly == 'Max' ){
                            item3.item_variant = "Max";
                            var MaxCoverageTotal = response.MapfreData.MaxCoverageTotal;
                            console.log('#@@ mapfree '+JSON.stringify(MaxCoverageTotal));
                            if( MaxCoverageTotal ){
                                /*if( days && days <= 30 && MaxCoverageTotal.Daily ){
                            component.set("v.mapfreRateValue", parseFloat(MaxCoverageTotal.Daily));
                        }else if( days && days > 30 && days <= 90 && MaxCoverageTotal.Days90 ){
                            component.set("v.mapfreRateValue", parseFloat(MaxCoverageTotal.Days90));
                        }else if( days && days > 30 && days <= 180 && MaxCoverageTotal.Days180 ){
                            component.set("v.mapfreRateValue", parseFloat(MaxCoverageTotal.Days180));
                        }else if( days && days > 180 && MaxCoverageTotal.Annual ){
                            component.set("v.mapfreRateValue", parseFloat(MaxCoverageTotal.Annual));
                        }*/
                                
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
                                
                                item3.price = mapfreRateValue;
                                component.set("v.mapfreRateValue", mapfreRateValue );
                                
                            }else{
                                component.set("v.mapfreRateValue", parseInt('0'));
                            }
                            
                            if (response.MapfreData.IVAMexCoverage) {
                                let IVAMexCoverageTotal = response.MapfreData.IVAMexCoverage;
                                
                                if (mapfreDays && mapfreDays <=30 && IVAMexCoverageTotal.Daily) {
                                    component.set('v.mapfre_iva', parseFloat(IVAMexCoverageTotal.Daily));
                                } else if (mapfreDays && mapfreDays > 30 && mapfreDays <=90 && IVAMexCoverageTotal.Days90) {
                                    component.set('v.mapfre_iva', parseFloat(IVAMexCoverageTotal.Days90));
                                } else if (mapfreDays && mapfreDays > 90 && mapfreDays <=180 && IVAMexCoverageTotal.Days180) {
                                    component.set('v.mapfre_iva', parseFloat(IVAMexCoverageTotal.Days180));
                                } else if (mapfreDays && mapfreDays > 180 && IVAMexCoverageTotal.Annual) {
                                    component.set('v.mapfre_iva', parseFloat(IVAMexCoverageTotal.Annual));
                                }
                            }
                        }
                    
                    var brokerFee = response.MapfreData.brokerFee;
                    if( mapfreDays && mapfreDays <= 30 && brokerFee && brokerFee.Daily && brokerFee.Daily != null  ){
                        component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Daily));
                    }else if( mapfreDays && mapfreDays > 30 && mapfreDays <= 90 && brokerFee.Daily && brokerFee.Days90 != null ){
                        component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Days90));
                    }else if( mapfreDays && mapfreDays > 90 && mapfreDays <= 180 && brokerFee.Daily && brokerFee.Days180 != null ){
                        component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Days180));
                    }else if( mapfreDays && mapfreDays > 180  && brokerFee.Daily && brokerFee.Annual != null ){
                        component.set("v.mapfreBroker_Policy_Fee", parseFloat(brokerFee.Annual));
                    }else{
                        component.set("v.mapfreBroker_Policy_Fee", parseInt('0'));
                    }
                }
                                    
                                    component.set('v.days',days);
                                    response['Days__c'] = days;
                                    if( days && days <= 30 ){
                                        response['Term__c'] = 'Daily';
                                    }else if( days && days > 30 && days <= 90 ){
                                        response['Term__c'] = '90 Days';
                                    }else if( days && days > 90 && days <= 180 ){
                                        response['Term__c'] = 'Semi-Annual';
                                    }else if( days && days > 180 ){
                                        response['Term__c'] = 'Annual';
                                    }
                                    
                                    let itemsArray = [];
                                    if (!component.get("v.communityUser")) {
                                        if (component.get("v.showQualitas")) {
                                            itemsArray.push(item1);
                                        }
                                        if (component.get("v.showChubb")) {
                                            itemsArray.push(item2);
                                        }
                                        if (component.get("v.showMapfre")) {
                                            itemsArray.push(item3);
                                        }
                                        this.pushDataLayer(component, event, helper, itemsArray);
                                    }
                                    
                                    var quoteRecord = component.get("v.quoteRecord");
                                    var totalvalue = 0;
                                    if( response.MapfreData && response.MapfreData.totalvalue != undefined){
                                        totalvalue = response.MapfreData.totalvalue;
                                    }
                                    
                                    var collision_deductible = 0;
                                    var theft_Total = 0;
                                    if( totalvalue != null  ){
                                        collision_deductible = totalvalue;
                                        console.log('Collision Deductible', collision_deductible);
                                    }
                                    theft_Total = collision_deductible;
                                    console.log('Theft Total', theft_Total);
                                    
                                    var policyType = component.get("v.policyType");
                                    if( policyType == 'Automobile' ){
                                        collision_deductible =  collision_deductible * 0.02;
                                        theft_Total = theft_Total * 0.05;
                                        if( collision_deductible && collision_deductible > 500 ){
                                            console.log('Inside If Collision Deductible ', collision_deductible);
                                            component.set("v.auto_collision_deductible", collision_deductible);
                                        }else if( policyType == 'Automobile' ){
                                            console.log('Else Collision Deductible ', collision_deductible);
                                            component.set("v.auto_collision_deductible", 500);
                                        }
                                        if( theft_Total && theft_Total > 1000 ){
                                            console.log('Inside If Theft Total ', theft_Total);
                                            component.set("v.auto_theft_Total", theft_Total);
                                        }else if( policyType == 'Automobile' ){
                                            console.log('Inside Else Theft total ', collision_deductible);
                                            component.set("v.auto_theft_Total", 1000);
                                        }
                                        
                                        helper.automobileMapfreCal(component, event, helper, totalvalue);
                                        
                                    }else if( policyType == 'RV' ){
                                        collision_deductible =  collision_deductible * 0.05;
                                        theft_Total = theft_Total * 0.05;
                                        
                                        if( collision_deductible && collision_deductible > 1000 ){
                                            component.set("v.rv_collision_deductible", collision_deductible);
                                        }else{
                                            component.set("v.rv_collision_deductible", 1000);
                                        }
                                        if( theft_Total && theft_Total > 1000 ){
                                            component.set("v.rv_theft_Total", theft_Total);
                                        }else{
                                            component.set("v.rv_theft_Total", 1000);
                                        }
                                    }else if( policyType == 'Motorcycle/Street Legal ATV' ){
                                        var moto_qual_collision_deductible = collision_deductible;
                                        var moto_qual_theft_Total = collision_deductible;
                                        
                                        var moto_map_collision_deductible = collision_deductible;
                                        var moto_map_theft_Total = collision_deductible;
                                        
                                        moto_qual_collision_deductible = moto_qual_collision_deductible * 0.02;
                                        moto_qual_theft_Total = moto_qual_collision_deductible * 0.05;
                                        if( moto_qual_collision_deductible && moto_qual_collision_deductible > 1000 ){
                                            component.set("v.moto_qual_collision_deductible", moto_qual_collision_deductible);
                                            //component.set("v.moto_qual_theft_Total", moto_map_theft_Total);
                                        }else{
                                            component.set("v.moto_qual_collision_deductible", 1000);
                                            //component.set("v.moto_qual_theft_Total", 500);
                                        }
                                        if( moto_qual_theft_Total && moto_qual_theft_Total > 1000 ){
                                            component.set("v.moto_qual_theft_Total", moto_qual_theft_Total);
                                        }else{
                                            component.set("v.moto_qual_theft_Total", 1000);
                                        }
                                        
                                        moto_map_collision_deductible = moto_map_collision_deductible * 0.02;
                                        moto_map_theft_Total = moto_map_collision_deductible * 0.05;
                                        if( moto_map_collision_deductible && moto_map_collision_deductible > 1000 ){
                                            component.set("v.moto_map_collision_deductible", moto_map_collision_deductible);
                                            //component.set("v.moto_map_theft_Total", moto_map_theft_Total);
                                        }else{
                                            component.set("v.moto_map_collision_deductible", 1000);
                                            //component.set("v.moto_map_theft_Total", 1000);
                                        }
                                        
                                        if( moto_map_theft_Total && moto_map_theft_Total > 1000 ){
                                            component.set("v.moto_map_theft_Total", moto_map_theft_Total);
                                        }else{
                                            component.set("v.moto_map_theft_Total", 1000);
                                        }
                                        
                                    }
                                    
                                }catch( e ){
                                    console.log(e);
                                }
                            },
                                
                                pushDataLayer: function (c, e, h, itemsArray) {
                                    if (itemsArray.length > 0) {
                                        window.dataLayer.push({ ecommerce: undefined });
                                        window.dataLayer.push({
                                            event: "view_item_list",
                                            ecommerce: {
                                                items: itemsArray
                                            }
                                        });
                                    }
                                },
                                    
                                    automobileMapfreCal : function(component, event, helper, totalvalue){
                                        var quoteRecord = component.get("v.quoteRecord");
                                        var vehicleSubType = quoteRecord.Vehicle_Sub_type__c;
                                        var auto_mapfre_collision_deductible = 0;
                                        var auto_mapfre_theft_Total = 0;
                                        if( quoteRecord && quoteRecord.Vehicle_Value__c ){
                                            auto_mapfre_collision_deductible = quoteRecord.Vehicle_Value__c;
                                            auto_mapfre_theft_Total = quoteRecord.Vehicle_Value__c;
                                        }
                                        if(totalvalue != null ){
                                            auto_mapfre_collision_deductible = totalvalue;
                                            auto_mapfre_theft_Total = totalvalue;
                                        }
                                        
                                        var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");
                                        if( mapfreLiablityOnly == 'Max'){
                                            if( vehicleSubType == 'Automobile/Sedan'){
                                                component.set("v.auto_mapfre_collision_deductible", 500);
                                                component.set("v.auto_mapfre_theft_Total", 1000);
                                            }else if( vehicleSubType == 'Pickup Truck w or w/o Camper Shell'){
                                                component.set("v.auto_mapfre_collision_deductible", 1000);
                                                component.set("v.auto_mapfre_theft_Total", 1000);
                                            }else if( vehicleSubType == 'SUV'){
                                                component.set("v.auto_mapfre_collision_deductible", 1000);
                                                component.set("v.auto_mapfre_theft_Total", 1000);
                                            }else if( vehicleSubType == 'Van'){
                                                component.set("v.auto_mapfre_collision_deductible", 1000);
                                                component.set("v.auto_mapfre_theft_Total", 1000);
                                            }
                                        } else if( mapfreLiablityOnly == 'Complete'){
                                            if( vehicleSubType == 'Automobile/Sedan'){
                                                auto_mapfre_collision_deductible = auto_mapfre_collision_deductible * 0.02;
                                                auto_mapfre_theft_Total = auto_mapfre_theft_Total * 0.05;
                                                
                                                if( auto_mapfre_collision_deductible > 500 ){
                                                    component.set("v.auto_mapfre_collision_deductible", auto_mapfre_collision_deductible);
                                                }else{
                                                    component.set("v.auto_mapfre_collision_deductible", 500);
                                                }
                                                
                                                if( auto_mapfre_theft_Total > 1000 ){
                                                    component.set("v.auto_mapfre_theft_Total", auto_mapfre_theft_Total);
                                                }else{
                                                    component.set("v.auto_mapfre_theft_Total", 1000);
                                                }
                                                
                                            }else if( vehicleSubType == 'Pickup Truck w or w/o Camper Shell' || vehicleSubType == 'SUV'
                                                     || vehicleSubType == 'Van'  ){
                                                auto_mapfre_collision_deductible = auto_mapfre_collision_deductible * 0.05;
                                                auto_mapfre_theft_Total = auto_mapfre_theft_Total * 0.05;
                                                
                                                if( auto_mapfre_collision_deductible > 1000 ){
                                                    component.set("v.auto_mapfre_collision_deductible", auto_mapfre_collision_deductible);
                                                }else{
                                                    component.set("v.auto_mapfre_collision_deductible", 1000);
                                                }
                                                
                                                if( auto_mapfre_theft_Total > 1000 ){
                                                    component.set("v.auto_mapfre_theft_Total", auto_mapfre_theft_Total);
                                                }else{
                                                    component.set("v.auto_mapfre_theft_Total", 1000);
                                                }
                                            }
                                        }
                                    },
                                        
                                        validateInputFields : function(component, event, helper){
                                            var allValid = true;
                                            try{
                                                allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
                                                    inputCmp.reportValidity();
                                                    return validSoFar && inputCmp.checkValidity();
                                                }, true);
                                            }catch( ex ){
                                                
                                            }
                                            return allValid;
                                        },
})