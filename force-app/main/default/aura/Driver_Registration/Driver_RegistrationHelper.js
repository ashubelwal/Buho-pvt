({
    initializeData: function (component, event, helper) {
        if(component.get("v.policyType") === 'Driver License'){
            component.set("v.registeredVehicleHeader", 'Drivers');
        }
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
                    console.log('ca --drivers---',drivers);
                    component.set("v.drivers", drivers);

                    if( drivers != undefined && drivers.length > 0 ){
                        component.set("v.isDriverScreenOpen", false);
                    }

                    if (drivers && drivers.length > 0) {
                        component.set("v.registeredVehicleHeader", "Driver Information");
                        component.set("v.driverRecord", {'sobjectType': 'Driver__c'});
                        const ifIsOwner = drivers.map((driver) => {
                            if (driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == "Owner & Driver") {
                                return false;
                            }else{
                                   return true;
                                  }
                                          
                        });
            			console.log("CA log ifIsOwner : "+ ifIsOwner);
            			component.set("v.isOwner", ifIsOwner.includes(false) == true ? false : true);
                        component.set("v.Primary_insured", ifIsOwner.includes(false));
                    } else {
                        let driverRecord = component.get("v.driverRecord");
                        let leadRecord = component.get("v.leadRecord");
                        let quoteRecord = component.get("v.quoteRecord")

                        //commented by vikram at 22 nov because on driver screen its showing driver name from lead
                        //driverRecord.First_Name__c = leadRecord.FirstName;
                        //driverRecord.Last_Name__c = leadRecord.LastName;
                        driverRecord.Phone__c = leadRecord.Phone;
                        driverRecord.Email__c = leadRecord.Email;
                        driverRecord.Address__c = leadRecord.Street;
                        driverRecord.City__c = leadRecord.City;
                        driverRecord.State_Province__c = leadRecord.State;
                        driverRecord.Postal_Code__c = leadRecord.PostalCode;
                        driverRecord.Country__c = leadRecord.Country;
                        driverRecord.License_Country__c = leadRecord.Country;
                        driverRecord.License_state__c = leadRecord.State;
                        if (leadRecord['Date_of_Birth__c']) {
                            console.log('initializeData');
                            console.log(leadRecord['Date_of_Birth__c']);
                            driverRecord.Dob__c = leadRecord.Date_of_Birth__c;
                            console.log(driverRecord.Dob__c);
                        }else if( quoteRecord.Date_of_Birth__c ){
                            driverRecord.Dob__c = quoteRecord.Date_of_Birth__c;
                        }

                        component.set('v.driverRecord', driverRecord);
                        component.set("v.Primary_insured", true);
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

    initializeEditData : function (component, event, helper) {
        if(component.get("v.policyType") === 'Driver License'){
            component.set("v.registeredVehicleHeader", 'Drivers');
        }

        let drivers = component.get("v.drivers");
        console.log('initializeEditData--drivers--',drivers);

        if (drivers && drivers.length > 0) {
            component.set("v.registeredVehicleHeader", "Driver Information");
            component.set("v.driverRecord", {'sobjectType': 'Driver__c'});
            const ifIsOwner = drivers.map((driver) => {
                            if (driver.Driver_Type__c == 'Owner' || driver.Driver_Type__c == "Owner & Driver") {
                                return false;
                            }else{
                                   return true;
                                  }
                                          
                        });
            console.log("CA log ifIsOwner : "+ ifIsOwner);
            component.set("v.isOwner", ifIsOwner.includes(false) == true ? false : true);
            console.log("CA get isowner data : "+ component.get("v.isOwner"));
        } /*else {
            let driverRecord = component.get("v.driverRecord");
            let leadRecord = component.get("v.leadRecord");
            let quoteRecord = component.get("v.quoteRecord")

            driverRecord.First_Name__c = leadRecord.FirstName;
            driverRecord.Last_Name__c = leadRecord.LastName;
            driverRecord.Phone__c = leadRecord.Phone;
            driverRecord.Email__c = leadRecord.Email;
            driverRecord.Address__c = leadRecord.Street;
            driverRecord.City__c = leadRecord.City;
            driverRecord.State_Province__c = leadRecord.State;
            driverRecord.Postal_Code__c = leadRecord.PostalCode;
            driverRecord.Country__c = leadRecord.Country;
            if (leadRecord['Date_of_Birth__c']) {
                console.log('initializeData');
                console.log(leadRecord['Date_of_Birth__c']);
                driverRecord.Dob__c = leadRecord.Date_of_Birth__c;
                console.log(driverRecord.Dob__c);
            }else if( quoteRecord.Date_of_Birth__c ){
                driverRecord.Dob__c = quoteRecord.Date_of_Birth__c;
            }

            component.set('v.driverRecord', driverRecord);
        }*/
        component.set("v.goInitChildComponent", true);
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
            console.log('Primary_insured : ' + component.get("v.Primary_insured"));
            console.log('driverRecord : ' + JSON.stringify(component.get("v.driverRecord")));

            action.setCallback(this, function (response) {
                let state = response.getState();
                console.log('state : ' + state);
                if (state === 'SUCCESS') {
                    let result = response.getReturnValue();
                    console.log('response.success : ' + result.success);
                    if (result.success) {
                        try {
                            const driverRecord = result.savedDriverRecord;
                            console.log('--driverRecord--', driverRecord);
                            if (driverRecord) {
                                component.set("v.driverRecord", driverRecord);
                                let drivers = component.get("v.drivers");
                                drivers.push(driverRecord);
                                component.set("v.drivers", drivers);
                                console.log('cpm set drivers');

                                if( drivers != undefined && drivers.length > 0 ){
                                    component.set("v.isDriverScreenOpen", false);
                                }
                            }

                            component.set("v.Primary_insured", false);
                            if (result.leadUpdated) {
                                component.set("v.leadRecord", result.leadUpdated);
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

    updateDriverHelper: function (component, event, helper) {
        var action = component.get("c.updateDriverAction");
        var driverObject = component.get("v.driverForEdit");
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
                        if(item.Driver_Type__c == 'Owner' || item.Driver_Type__c == "Owner & Driver"){
                            
                            component.set("v.isOwner", false);
                        }else{
                            component.set("v.isOwner", true);
                        }
                    });
                    component.set("v.drivers", drivers);
                    if( drivers != undefined && drivers.length > 0 ){
                        component.set("v.isDriverScreenOpen", false);
                    }
                    component.set("v.isEditDriver", false);
                    component.set("v.Primary_insured", false);
                    component.set("v.driverForEdit", null);
                } else {
                    alert(result.message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    deleteDriverHelper: function (component, event, helper, driverRecordIndex) {
        var action = component.get("c.deleteDriverAction");
        var drivers = component.get("v.drivers");
        var driverObject =  drivers[ parseInt(driverRecordIndex)];
        action.setParams({
            driverObject: driverObject,
            quoteId : component.get("v.quoteRecord").Id
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.success) {
                    drivers.splice(driverRecordIndex, 1);
                    component.set("v.drivers", drivers);
                    if( drivers != undefined && drivers.length > 0 ){
                        component.set("v.isDriverScreenOpen", false);
                    }else{
                        component.set("v.isDriverScreenOpen", true);
                        component.set("v.isOwner", true);
                        component.set("v.driverRecord", {'sobjectType': 'Driver__c'});
                    }
                } else {
                    alert(result.message);
                }
            }
        });
        
        console.log("isOwner : "+ component.get("v.isOwner"));
        $A.enqueueAction(action);
    },

    getLoginUserDriversHelper : function (component, event, helper){
        
        var action = component.get("c.getCurrentUserDrivers");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if( result != undefined && result != null ){
                    var loginUserDrivers = [{'value': '', 'label': '--None--'}];
                    result.forEach( function(item){
                        var label = item.Name + ' - '+item.Dob__c+ ' - '+item.license_number__c
                        loginUserDrivers.push({'value': item.Id, 'label': label});
                    });

                    component.set("v.loginUserDriverOption", loginUserDrivers);
                    component.set("v.loginUserDrivers", result);
                    
                }
            }
        });
        $A.enqueueAction(action);
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