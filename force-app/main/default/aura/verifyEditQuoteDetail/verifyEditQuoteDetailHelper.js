({
    updateVehicleHelper: function (component, event, helper) {
        var action = component.get("c.updateVehicleAction");
        var vehicleObject = component.get("v.vehicleObject");
        action.setParams({vehicleObject: vehicleObject});

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if (response.success) {
                    var vehicles = component.get("v.vehicles");
                    vehicles.forEach(function (item) {
                        if (item.Id == vehicleObject.Id) {
                            item = vehicleObject;
                        }
                    });
                    component.set("v.vehicles", vehicles);
                    component.set("v.isEditVehicle", false);
                    component.set("v.vehicleObject", null);
                } else {
                    alert(response.message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateDriverHelper: function (component, event, helper) {
        var action = component.get("c.updateDriverAction");
        var driverObject = component.get("v.driverObject");
        action.setParams({driverObject: driverObject});

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.success) {
                    var drivers = component.get("v.drivers");
                    drivers.forEach(function (item) {
                        if (item.Id === driverObject.Id) {
                            item = driverObject;
                        }
                    });
                    component.set("v.drivers", drivers);
                    component.set("v.isEditDriver", false);
                    component.set("v.driverObject", null);
                } else {
                    alert(result.message);
                }

            }
        });
        $A.enqueueAction(action);
    },

    getDataFromRateDataTable: function (component, event, helper) {
        var action = component.get("c.getDataFromDataTable");

        action.setParams({
            quoteObject: component.get("v.quoteObject"),
            liability: component.get("v.liability")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseMain = result.getReturnValue();
                if (responseMain != null && responseMain.success ) {
                    var days = parseInt(responseMain.days) ;
                    var response = responseMain.rateData;

                    console.log("CA log getDataFromRateDataTable response : "+ JSON.stringify(response, null, 4));
                    var quoteObject = component.get("v.quoteObject");

                    var Net_Premium = (response.Net_Premium__c != null ? response.Net_Premium__c : 0);
                    var Broker_Policy_Fee = (response.Broker_Policy_Fee__c != null ? response.Broker_Policy_Fee__c : 0);
                    var IVA_Mex_Tax = (response.IVA_Mex_Tax__c != null ? response.IVA_Mex_Tax__c : 0);
					component.set("v.IVA_Mex_Tax__cValue", IVA_Mex_Tax);
                    var Vehicle_Age_20 = (response.Age_of_Vehicle_Surcharge__c != null ? response.Age_of_Vehicle_Surcharge__c : 0);
                    var Vehicle_Age_25 = (response.Age_of_Vehicle_Surcharge_25_years_old__c != null ? response.Age_of_Vehicle_Surcharge_25_years_old__c : 0);
                    var operator_Charge = (response.Age_of_Operator_Surcharge__c != null ? response.Age_of_Operator_Surcharge__c : 0);
                    var towing_Charge = (response.Trailering_Surcharge__c != null ? response.Trailering_Surcharge__c : 0);

                    var surcharge = 0;
                    var Total_Premium = Net_Premium;
                    if (quoteObject.Vehicle_Age__c && quoteObject.Vehicle_Age__c != null) {
                        if (quoteObject.Vehicle_Age__c > 20 && quoteObject.Vehicle_Age__c <= 25) {
                            surcharge += (Net_Premium * (Vehicle_Age_20 / 100));

                        } else if (quoteObject.Vehicle_Age__c > 25) {
                            surcharge += (Net_Premium * (Vehicle_Age_25 / 100));
                        }
                    }
                    if (quoteObject.Driver_Age__c && quoteObject.Driver_Age__c != null && quoteObject.Driver_Age__c < 21) {
                        surcharge += (Net_Premium * (operator_Charge / 100));
                    }

                    if (quoteObject.Towed_Unit__c && quoteObject.Towed_Unit__c != null && quoteObject.Towed_Unit__c == 'Yes') {
                        surcharge += (Net_Premium * (towing_Charge / 100));
                    }


                    Total_Premium = Total_Premium + Broker_Policy_Fee + IVA_Mex_Tax + surcharge;

                    component.set("v.rateValue", Total_Premium);
                    var rateObect = response;
                    rateObect['surcharge'] = surcharge;
                    rateObect['Total_Premium'] = Total_Premium;

                    component.set("v.rateObect", rateObect);
                } else {
                    component.set("v.rateValue", responseMain.rateData);
                    component.set("v.rateObect", responseMain.rateData);
                }


            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
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

    createQuoteHelper: function (component, event, helper) {
        var action = component.get("c.handleQuocteAction");
        var quoteObject = component.get("v.quoteObject");
        var rateObect = component.get("v.rateObect");

        quoteObject['Liability__c'] = component.get("v.liability");
        quoteObject['Quote_Value__c'] = component.get("v.rateValue");
        quoteObject['Surcharge__c'] = (rateObect ? rateObect.surcharge : 0);
        quoteObject['Net_Premium__c'] = (rateObect ? rateObect.Net_Premium__c : 0);
        quoteObject['Broker_Policy_Fee__c'] = (rateObect ? rateObect.Broker_Policy_Fee__c : 0);
        quoteObject['I_V_A_Mex_Tax__c'] = (rateObect ? rateObect.IVA_Mex_Tax__c : 0);
        quoteObject['Quote_Value__c'] = component.get("v.rateValue");
        component.set("v.quoteObject", quoteObject);

        action.setParams({quoteRecord: quoteObject});

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if (response.success) {
                    var rateObectList = component.get("v.rateObectList");
                    var Total_Premium = 0;
                    var quoteObject = component.get("v.quoteObject");

                    var tempRateObectList = [];
                    rateObectList.forEach(function (item) {

                        if (item.quoteId == component.get("v.quoteObject").Id) {
                            var leadId = item.leadId;
                            var itemTemp = component.get("v.rateObect");
                            itemTemp['leadId'] = leadId;
                            itemTemp['Liability__c'] = component.get("v.liability");
                            itemTemp['Medical__c'] = '5,000/25,000';
                            itemTemp['quoteId'] = component.get("v.quoteObject").Id;
                            itemTemp['quoteRecord'] = component.get("v.quoteObject");
							 itemTemp['IVA_Mex_Tax__c'] =  component.get("v.IVA_Mex_Tax__cValue");
                            if (itemTemp.Total_Premium != null) {
                                Total_Premium += itemTemp.Total_Premium;
                            }

                            tempRateObectList.push(itemTemp);
                        } else {
                            tempRateObectList.push(item);
                            if (item.Total_Premium != null) {
                                Total_Premium += item.Total_Premium;
                            }
                        }
                    });
                    component.set("v.Total_Premium", Total_Premium);
                    component.set("v.rateObectList", tempRateObectList);

                    component.set("v.isEditRate", false);
                    component.set("v.quoteObject", null);
                } else {
                    alert(response.message);
                }

            }
        });
        $A.enqueueAction(action);
    },

    validateInputFields: function (component, event, helper) {

        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    },
})