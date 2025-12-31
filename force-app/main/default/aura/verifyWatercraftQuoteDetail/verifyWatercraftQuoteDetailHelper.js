({
    updateWatercraftHelper : function( component, event, helper ) {
        var tempWatercraftObject = component.get("v.tempWatercraftRecord");
        var tempQuoteObject = component.get("v.tempQuoteRecord");
        var watercraftObject = component.get("v.watercraftRecord");
        var quoteObject = component.get("v.quoteRecord");
        var action = component.get("c.updateWatercraftAction");

        action.setParams({
            'watercraftRecord' : tempWatercraftObject,
            'quoteRecord' : tempQuoteObject
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    watercraftObject = Object.assign(watercraftObject, tempWatercraftObject);
                    quoteObject = Object.assign(quoteObject, tempQuoteObject);

                    component.set("v.watercraftRecord", watercraftObject);
                    component.set("v.quoteRecord", quoteObject);

                    component.set("v.isEditWatercraft", false);
                    component.set("v.tempWatercraftRecord", null);
                    component.set("v.quoteObject", null);
                }else{
                    alert( response.message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updateRateHelper : function( component, event, helper) {
        var action = component.get("c.handleQuoteAction");
        var quoteObject = component.get("v.rateQuoteRecord");
        console.log('rateQuoteRecord : ' + JSON.stringify(quoteObject));
        
        action.setParams({
            'quoteRecord' : quoteObject,
            'annualTerm'  : component.get("v.annualTerm")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    var rateRecordList = component.get("v.rateRecordList");
                    var Total_Premium = 0;
                    quoteObject = response.quote;
                    console.log('rateRecordList : ' + JSON.stringify(rateRecordList));
                    console.log('response.quote : ' + JSON.stringify(response.quote));
                    console.log('response.rateQuoteRecord : ' + JSON.stringify(quoteObject));
                    
                    rateRecordList.forEach(function(item){
                        if( item.quoteId == component.get("v.rateRecord").quoteId ) {
                            var rateRecord = component.get("v.rateRecord");
                            item = Object.assign(item, rateRecord);

                            if( item.Total_Premium != null ){
                                Total_Premium += item.Total_Premium;
                            }
                        }
                    });

                    component.set("v.quoteRecord", Object.assign({}, quoteObject));
                    component.set("v.rateRecordList", rateRecordList);
                    component.set("v.Total_Premium", Total_Premium);
                    console.log('quoteRecord : ' + JSON.stringify(component.get("v.quoteRecord")));
                    console.log('merged rateRecordList : ' + JSON.stringify(rateRecordList));
                    
                    component.set("v.rateQuoteRecord", null);
                    component.set("v.rateRecord", null);
                    component.set("v.isEditRate", false);
                }else{
                    alert( response.message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updateDriverHelper : function( component, event, helper ) {
        var driverObject = component.get("v.driverObject");
        var driverObjectToUpdate = Object.assign({}, driverObject);
        delete driverObjectToUpdate['formattedDob'];
        console.log('driverObject : ' + JSON.stringify(driverObject));
        console.log('driverObjectToUpdate : ' + JSON.stringify(driverObjectToUpdate));

        var action = component.get("c.updateDriverAction");
        action.setParams({'driverObject' : driverObject});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if( response.success ){
                    var drivers = component.get("v.drivers");
                    console.log('drivers : ' + JSON.stringify(drivers));
                    drivers.forEach(function(item){
                        if (item.Id == driverObject.Id) {
                            item = Object.assign(item, driverObject);
                        }
                    });
                    console.log('merged drivers : ' + JSON.stringify(drivers));
                    component.set("v.drivers", drivers);
                    component.set("v.isEditDriver", false);
                    component.set("v.driverObject", null);
                }else{
                    alert( response.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    },

    calculateDays: function (component, event, helper) {
        var quoteRecord = component.get("v.rateQuoteRecord");
        var difference_In_Days = 0;
        if (quoteRecord && quoteRecord.Start_Date_for_Coverage__c && quoteRecord.End_Date_for_Coverage__c) {
            var date1 = new Date(quoteRecord.Start_Date_for_Coverage__c + 'T00:00:00');
            var date2 = new Date(quoteRecord.End_Date_for_Coverage__c + 'T00:00:00');

            // To calculate the time difference of two dates 
            var Difference_In_Time = date2.getTime() - date1.getTime();

            // To calculate the no. of days between two dates 
            difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            component.set("v.difference_In_Days", difference_In_Days);
        }
        console.log('--difference_In_Days--' + difference_In_Days);
    },

    getDataFromRateDataTable: function (component, event, helper) {
        var action = component.get("c.getDataFromDataTable");

        action.setParams({
            'quoteObject': component.get("v.rateQuoteRecord"),
            'annualTerm': component.get("v.annualTerm")
        });

        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var response = result.getReturnValue();
                if (response != null) {
                    try {
                        var quoteObject = component.get("v.rateQuoteRecord");
                        var rateRecord = response;

                        var Net_Premium = (rateRecord.Net_Premium__c != null ? rateRecord.Net_Premium__c : 0);
                        var Broker_Policy_Fee = (rateRecord.Broker_Policy_Fee__c != null ? rateRecord.Broker_Policy_Fee__c : 0);
                        var IVA_Mex_Tax = (rateRecord.IVA_Mex_Tax__c != null ? rateRecord.IVA_Mex_Tax__c : 0);

                        var Term__c = (rateRecord.Term__c != null ? rateRecord.Term__c : null);

                        var Liability_Limit_Selection = Net_Premium;

                        if (Term__c == 'Daily') {
                            Liability_Limit_Selection = Liability_Limit_Selection * component.get("v.difference_In_Days");
                        }

                        var surcharge = 0;
                        var Total_Premium = Liability_Limit_Selection;
                        
                        if (quoteObject.Is_the_Maximum_Speed_more_than_50_mph__c == 'Yes') {
                            surcharge += (Liability_Limit_Selection * 0.5);
                        }
                        if (quoteObject.Any_Boat_Operator_Under_22__c == 'Yes') {
                            surcharge += (Liability_Limit_Selection * 2);
                        }
                        if (quoteObject.Is_the_owner_living_in_Mexico__c == 'Yes') {
                            surcharge += (Liability_Limit_Selection * 0.5);
                        }

                        Total_Premium = Total_Premium + Broker_Policy_Fee + IVA_Mex_Tax + surcharge;
                        component.set("v.rateValue", Total_Premium);

                        quoteObject['Quote_Value__c'] = Total_Premium;
                        quoteObject['Net_Premium__c'] = (rateRecord ? rateRecord.Net_Premium__c : null);
                        quoteObject['Broker_Policy_Fee__c'] = (rateRecord ? rateRecord.Broker_Policy_Fee__c : null);
                        quoteObject['I_V_A_Mex_Tax__c'] = (rateRecord ? rateRecord.IVA_Mex_Tax__c : null);
                        component.set("v.rateQuoteRecord", quoteObject);

                        rateRecord['surcharge'] = surcharge;
                        rateRecord['Total_Premium'] = Total_Premium;
                        rateRecord['Liability__c'] = quoteObject['Liability__c'];
                        rateRecord['quoteRecord'] = quoteObject;
                        rateRecord['quoteId'] = quoteObject.Id;
                        rateRecord['leadId'] = component.get("v.leadRecord").Id;

                        component.set("v.rateRecord", rateRecord);
                    } catch (ex) {
                        console.log('******exception****');
                        console.log(ex);
                    }
                } else {
                    component.set("v.rateValue", response);
                    component.set("v.rateRecord", response);
                }
            }
        });
        $A.enqueueAction(action);
    },

    validateInputFields: function (component, event, helper) {
        return component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    },

    fetchPicklist : function( component, event, helper, objectApiName, fieldApi, fieldAttr) {
        var action = component.get("c.getPicklistValues");
        
        action.setParams({ 'objectApiName' : objectApiName,
                            'fieldApiName' : fieldApi }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getDependentPicklistValues : function(component, event, helper, controllingField, dependentField, fieldAttr) {
        var action = component.get("c.getDependentMap");
        var quoteRecord = component.get("v.quoteRecord");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : quoteRecord,
            'contrfieldApiName': controllingField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var storeResponse = response.getReturnValue();
                console.log('--storeResponse----'+JSON.stringify(storeResponse));
                var vesselType = quoteRecord['Type_of_Vessel__c'];
                console.log('--vesselType----'+JSON.stringify(vesselType));
                if(vesselType != null && storeResponse && storeResponse[vesselType] != null ){
                    var options = [];
                    storeResponse[vesselType].forEach(function(item){
                        /**logic here !*/
                        options.push({
                            'label':item,
                            'value':item
                        })
                    });
                    component.set(fieldAttr, options);
                }
            }
        });
        $A.enqueueAction(action);
    },
})