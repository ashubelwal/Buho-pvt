({
    initializeData: function (component, event, helper) {
        try {
            const action = component.get("c.getRelatedDrivers");
            let quoteRecord = component.get("v.quoteRecord")

            action.setParams({
                quoteId: quoteRecord.Id
            });

            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === 'SUCCESS') {
                    let drivers = response.getReturnValue();
                    component.set("v.drivers", drivers);

                    if (drivers && drivers.length > 0) {
                        component.set("v.registeredVehicleHeader", "Additional Driver Information");
                        component.set("v.driverRecord", {'sobjectType': 'Driver__c'});
                        component.set("v.isOwner", false);
                    } else {
                        let driverRecord = component.get("v.driverRecord");
                        let leadRecord = component.get("v.leadRecord");

                        driverRecord.Email__c = leadRecord.Email;
                        if (leadRecord['Date_of_Birth__c']) {
                            driverRecord.Dob__c = leadRecord.Date_of_Birth__c;
                        }

                        component.set('v.driverRecord', driverRecord);
                    }
                    component.set("v.goInitChildComponent", true);
                } else {
                    helper.showToast(response.getError(), 'error');
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
            console.log(ex);
        }
    },

    createDriverHelper: function (component, event, helper, goToNextStep) {
        try {
            const action = component.get("c.createDriverAction");
            let watercraftId = (component.get("v.watercraftRecord").Id || null);

            action.setParams({
                driverRecord: component.get("v.driverRecord"),
                quoteId: component.get("v.quoteRecord").Id,
                isOwner: component.get("v.isOwner"),
                watercraftId: watercraftId,
                Primary_insured : component.get("v.Primary_insured")
            });
            console.log('quoteId : ' + component.get("v.quoteRecord").Id);
            console.log('driverRecord : ' + JSON.stringify(component.get("v.driverRecord")));

            action.setCallback(this, function (response) {
                let state = response.getState();
                console.log('state : ' + state);
                if (state === 'SUCCESS') {
                    let result = response.getReturnValue();
                    console.log('response.success : ' + result.success);
                    if (result.success) {
                        try {
                            console.log('driverRecord callback : ' + JSON.stringify(result.savedDriverRecord));
                            if (result.savedDriverRecord) {
                                let driverRecord = component.get("v.driverRecord");
                                driverRecord = result.savedDriverRecord;

                                let drivers = component.get("v.drivers");
                                drivers.push(Object.assign({}, driverRecord));
                                component.set("v.drivers", drivers);

                                console.log('v.drivers : ' + JSON.stringify(drivers));
                            }
                            if (result.leadUpdated) {
                                var resultLead = Object.assign(component.get("v.leadRecord"), result.leadUpdated);
                                component.set("v.leadRecord", resultLead);
                                console.log('v.resultLead : ' + JSON.stringify(resultLead));
                            }
                            if (goToNextStep) {
                                $A.enqueueAction(component.get("v.onNextClick"));
                            } else {
                                helper.initializeData(component, event, helper);
                            }
                        } catch (e) {
                            console.log(e);
                        }
                    } else {
                        helper.showToast(result.message, 'error');
                        console.log('response.message : ' + result.message);
                    }
                } else {
                    helper.showToast(response.getError(), 'error');
                    this.showErrorsInConsole(response.getError());
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log('-----error : ' + e);
        }
    },

    showErrorsInConsole: function (errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log(errors[0].message, 'error');
            }
        } else {
            console.log("Unknown error");
        }
    },

    showToast: function (message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
})