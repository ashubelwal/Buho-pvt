({
    initializeData: function (component, event, helper) {
        try{
            var policyType = component.get("v.policyType");
            if (policyType === 'Northbound') {
                component.set("v.liability", "300,000");
            } else if (policyType === 'Driver License') {
                component.set("v.liability", "500,000");
            }
    
            helper.calculateDays(component, event, helper);
            helper.getDataFromRateDataTable(component, event, helper);
            helper.fetchCoverageDetail(component, event, helper);
    
            let today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            component.set("v.minStartDate", today);
        }catch(ex){
            console.log('--ex--',ex);
        }
        
    },

    calculateDays: function (component, event, helper) {
        var quoteRecord = component.get("v.quoteRecord");
        var difference_In_Days = 0;
        if (quoteRecord && quoteRecord.Start_Date_for_Coverage__c && quoteRecord.End_Date_for_Coverage__c) {
            var date1 = new Date(quoteRecord.Start_Date_for_Coverage__c);
            var date2 = new Date(quoteRecord.End_Date_for_Coverage__c);

            // To calculate the time difference of two dates 
            var Difference_In_Time = date2.getTime() - date1.getTime();

            // To calculate the no. of days between two dates 
            difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);

        }

        if (difference_In_Days < 30) {
            component.set("v.difference_In_Daysin30", true);
        } else {
            component.set("v.difference_In_Daysin30", false);
        }
        console.log('--difference_In_Days--' + difference_In_Days);
    },

    fetchCoverageDetail: function (component, event, helper) {
        const action = component.get('c.getCoverageDetail');
        action.setParams({
            quoteRecord: component.get("v.quoteRecord")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result != null && result.length > 0) {
                    component.set("v.coverageDetail", result[0]);
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    getDataFromRateDataTable: function (component, event, helper) {
        helper.calculateDays(component, event, helper);
        var action = component.get("c.getDataFromDataTable");
        let item1 = {};
        item1.item_name = "Northbound";
        item1.item_id = "0121C00000102F5QAI-Chubb";
        item1.item_brand = "MexInsurance";

        action.setParams({
            quoteObject: component.get("v.quoteRecord"),
            liability: component.get("v.liability")
        });

        action.setCallback(this, function (result) {

            var state = result.getState();
            if (state === "SUCCESS") {
                var responseMain = result.getReturnValue();
                if (responseMain != null && responseMain.success ) {
                    try {

                        var days = parseInt(responseMain.days);
                        var response = responseMain.rateData[0];
                        var quoteObject = component.get("v.quoteRecord");

                        var Net_Premium = (response.Net_Premium__c != null ? response.Net_Premium__c : 0);
                        var Broker_Policy_Fee = (response.Broker_Policy_Fee__c != null ? response.Broker_Policy_Fee__c : 0);
                        var IVA_Mex_Tax = (response.IVA_Mex_Tax__c != null ? response.IVA_Mex_Tax__c : 0);

                        var Vehicle_Age_20 = (response.Age_of_Vehicle_Surcharge__c != null ? response.Age_of_Vehicle_Surcharge__c : 0);
                        var Vehicle_Age_25 = (response.Age_of_Vehicle_Surcharge_25_years_old__c != null ? response.Age_of_Vehicle_Surcharge_25_years_old__c : 0);
                        var operator_Charge = (response.Age_of_Operator_Surcharge__c != null ? response.Age_of_Operator_Surcharge__c : 0);
                        var towing_Charge = (response.Trailering_Surcharge__c != null ? response.Trailering_Surcharge__c : 0);


                        var surcharge = 0;
                        var Total_Premium = Net_Premium;
                        if (quoteObject.Vehicle_Age__c) {
                            if (quoteObject.Vehicle_Age__c > 30 && quoteObject.Vehicle_Age__c <= 35) {
                                surcharge += (Net_Premium * (Vehicle_Age_20 / 100));

                            } else if (quoteObject.Vehicle_Age__c > 35) {
                                surcharge += (Net_Premium * (Vehicle_Age_25 / 100));
                            }
                        }
                        if (quoteObject.Policy_Type_picklist__c != 'Driver License') {
                            if (quoteObject.Driver_Age__c != null /*&& (quoteObject.Driver_Age__c < 21 || quoteObject.Driver_Age__c > 75)*/) {
                                if( quoteObject.Driver_Age__c >= 16 && quoteObject.Driver_Age__c <= 18 ){
                                    surcharge += Net_Premium;
                                }else if( quoteObject.Driver_Age__c >= 19 && quoteObject.Driver_Age__c <= 21 ){
                                    surcharge += (Net_Premium * ( 50 / 100));
                                }else if( quoteObject.Driver_Age__c >= 75 && quoteObject.Driver_Age__c <= 79 ){
                                    surcharge += (Net_Premium * ( 50 / 100));
                                }else if( quoteObject.Driver_Age__c >= 80 && quoteObject.Driver_Age__c <= 84 ){
                                    surcharge += Net_Premium;
                                }
    
                                //(Net_Premium * (operator_Charge / 100));
                            }
    
                            if (quoteObject.Towed_Unit__c && quoteObject.Towed_Unit__c === 'Yes') {
                                surcharge += (Net_Premium * (towing_Charge / 100));
                            }
                        } else {
                            if (quoteObject.Driver_Age__c < 21 || quoteObject.Driver_Age__c > 75) {
                                surcharge += Net_Premium * 0.10;
                            } else {
                                surcharge += 0;
                            }
                        }
                        
                        item1.item_category = quoteObject.Vehicle_Type__c;
                        item1.item_category2 = days > 0 && days <= 30 ? "Daily" : days > 30 && days <= 90 ? "90 Day" : days > 90 && days <= 180 ? "Semi-Annual(Half a Year)" : "Annual(One Year)";
                        item1.item_category3 = quoteObject.Territory_Coverage__c;
                        item1.item_category4 = "Chubb";
                        item1.item_list_name = "Northbound Quote Page";
                        item1.quantity = 1;
                        item1.index = 1;
                        item1.item_variant = "Liability";

                        Total_Premium = Total_Premium + Broker_Policy_Fee + IVA_Mex_Tax + surcharge;
                        component.set("v.rateValue", Total_Premium);
                        var tempNetPremium = (Total_Premium - (Broker_Policy_Fee + surcharge) );
                        var rateRecord = response;
                        
                        var quoteRecord = component.get("v.quoteRecord");
                        quoteRecord['Liability__c'] = component.get("v.liability");
                        quoteRecord['Quote_Value__c'] = Total_Premium;
                        quoteRecord['Term_Days__c'] = days;
                        quoteRecord['Surcharge__c'] = surcharge;
                        quoteRecord['Net_Premium__c'] = (tempNetPremium ? tempNetPremium : 0);
                        quoteRecord['Broker_Policy_Fee__c'] = (rateRecord ? rateRecord.Broker_Policy_Fee__c : null);
                        quoteRecord['I_V_A_Mex_Tax__c'] = (rateRecord ? rateRecord.IVA_Mex_Tax__c : null);
                        component.set("v.quoteRecord", quoteRecord);

                        rateRecord['surcharge'] = surcharge;
                        rateRecord['Total_Premium'] = Total_Premium;
                        rateRecord['Liability__c'] = component.get("v.liability");
                        rateRecord['Medical__c'] = '5,000/25,000';
                        rateRecord['quoteId'] = quoteRecord.Id;
                        rateRecord['quoteRecord'] = quoteRecord;
                        rateRecord['leadId'] = component.get("v.leadRecord").Id;

                        rateRecord['year'] = quoteRecord['Vehicle_Year__c'];
                        rateRecord['model'] = quoteRecord['Vehicle_Model__c'];
                        rateRecord['make'] = quoteRecord['Vehicle_Make__c'];  

                        component.set("v.rateRecord", rateRecord);
                        component.set("v.Final_total_Premium", Total_Premium);
                        component.set("v.days", days);
                        item1.price = Total_Premium;
                        if (!component.get("v.communityUser")) {
                            this.pushDataLayer(component, event, helper, item1);
                        }
                    } catch (ex) {
                        console.log('******exception****');
                        console.log(ex);
                    }

                } else {
                    component.set("v.rateValue", responseMain.rateData);
                    component.set("v.rateObect", responseMain.rateData);
                }
            }else{
                console.log("Line 180 -- "+ JSON.stringify(result.getReturnValue(), null, 4));
            }
        });
        $A.enqueueAction(action);
    },
    
    pushDataLayer: function (c, e, h, item1) {
        console.log("item1 ---> ", JSON.stringify(item1, null, 4));
        window.dataLayer.push({ ecommerce: undefined });
        window.dataLayer.push({
            event: "view_item_list",
            ecommerce: {
                items: [item1]
            }
        });
    },

    updateQuoteHelper: function (component, event, helper) {
        const action = component.get('c.handleQuocteAction');
        action.setParams({
            quoteRecord: component.get("v.quoteRecord")
        });
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var response = result.getReturnValue();
                if (response.success) {
                    var quoteRecordOld = component.get("v.quoteRecord");
                    var quoteRecord = response.quoteRecord;
                    quoteRecord['Start_Time__c'] = quoteRecordOld.Start_Time__c;
                    quoteRecord['End_Time__c'] = quoteRecordOld.End_Time__c;
                    component.set("v.quoteRecord", quoteRecord);

                    $A.enqueueAction(component.get("v.onNextClick"));

                } else {
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(result.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (message, type) {
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

    saveQuoteHelper: function (component, event, helper, name, popupType) {
        var action = component.get("c.saveQuoteAction");

        action.setParams({
            leadId: component.get("v.leadRecord").Id,
            firstName: component.get("v.leadRecord").Firstname,
            lastName: component.get("v.leadRecord").Lastname,
            emailAdder: component.get("v.leadRecord").Email,
            phoneNumber: component.get("v.leadRecord").Phone,
            quoteId: component.get("v.quoteRecord").Id
        });

        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var response = result.getReturnValue();
                if (response.success) {
                    component.set("v.firstName", null);
                    component.set("v.lastName", null);
                    component.set("v.saveQuotePop", false);

                    if(name == 'saveQuote'){
                         helper.showToast(response.message, 'success');
                    }
                } else {
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(result.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    validateInputFields: function (component, event, helper) {
        try{
            return component.find('validateField').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }catch(ex){
            return true;
        }
    },
})