({
    initializeData: function (component, event, helper) {
        let today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.maxBirthdayDate", today);
        let leadRecord = component.get("v.leadRecord");

        let countryOption = [
            {"value": "United States", "label": "United States"},
            {"value": "Canada", "label": "Canada"},
            {"value": "Other", "label": "Other"}
        ];

        if (component.get("v.policyType") == 'Northbound') {
            countryOption.push({"value": "Mexico", "label": "Mexico"});
        }
        component.set("v.countryOption", countryOption);

        let isCountryIncluded = countryOption.reduce(function (isIncluded, option) {
            return isIncluded || (leadRecord.Country && option.label.toLowerCase() === leadRecord.Country.toLowerCase());
        }, false);

        if (leadRecord.Country && !isCountryIncluded) {
            component.set("v.countryPicklistValue", "Other");
            component.set("v.countryInputValue", leadRecord.Country);
        } else {
            component.set("v.countryPicklistValue", leadRecord.Country);
        }
        helper.setInputComponentsVisibility(component, event, helper);
        var isCommunityUser = component.get("v.isCommunityUser");
        if( isCommunityUser != undefined && isCommunityUser == true){
            component.set("v.newSectionOpen", true);
            helper.getCurrentUserDriversAction(component, event, helper);
        }else{
            component.set("v.newSectionOpen", true);
        }
    },

    checkAllreadyUser : function( component, event, helper){
        const action = component.get('c.checkalreadyExistUserAction');
        var leadRecord = component.get("v.leadRecord");
        action.setParams({
            emailAdder: leadRecord.Email,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if(response.isExistUser){
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Please login to create a policy.',
                        messageTemplate: 'Please login to create a policy. {0}!',
                        messageTemplateData: [{
                                url: 'https://ws-mexinsurance-sandbox.cs37.force.com/login/',
                                label: 'Click here',
                            }
                        ]
                    });
                    toastEvent.fire();
                }else{
                    helper.onNextClickHelper(component, event, helper);
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },


    getCurrentUserDriversAction : function (component, event, helper) {
         console.log('-result-getCurrentUserDriversAction-');
        var action = component.get("c.getCurrentUserDrivers");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if( result != undefined && result != null ){
                    console.log('-result--',result);
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

    onNextClickHelper: function (component, event, helper) {
        let action = component.get("c.processDriverDetails");
        let leadRecord = component.get("v.leadRecord");
        let quoteRecord = component.get("v.quoteRecord");
        console.log("quoteRecord : "+ JSON.stringify(quoteRecord, null, 4));
        console.log("leadRecord : "+ JSON.stringify(leadRecord, null, 4));
        action.setParams({
            serializedLeadRecord: JSON.stringify(leadRecord),
            quoteRecord: quoteRecord
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                quoteRecord = result.quoteRecord;
                component.set("v.quoteRecord", quoteRecord);

                leadRecord = result.leadRecord;
                component.set("v.leadRecord", leadRecord);
                var driverRecord = component.get("v.driverRecord");
                if( quoteRecord != undefined && quoteRecord.Id != null && driverRecord != null && driverRecord.Id != undefined ){
                    helper.createDriverHelper( component, event, helper);
                }else{
                    $A.enqueueAction(component.get("v.onNextClick"));
                }
                
            } else {
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

    createDriverHelper : function (component, event, helper) {
        try {
            const action = component.get("c.createDriverAction");

            action.setParams({
                driverRecord: component.get("v.driverRecord"),
                quoteId: component.get("v.quoteRecord").Id,
                isOwner: true,
                watercraftId: null,
                Primary_insured : true
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === 'SUCCESS') {
                    let result = response.getReturnValue();
                    console.log('response.success : ' + result.success);
                    if (result.success) {
                        try {
                            const driverRecord = result.savedDriverRecord;
                            $A.enqueueAction(component.get("v.onNextClick"));
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

    showToast: function (message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
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

    validateInputFields: function (component, event, helper) {
        return component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    },

    setInputComponentsVisibility: function (component, event, helper) {
        let leadRecord = component.get("v.leadRecord");
        let countryPicklistValue = component.get("v.countryPicklistValue");

        if (leadRecord.Country) {
            component.set("v.showCountryInput", countryPicklistValue === 'Other');
            component.set("v.showStatePick", countryPicklistValue !== 'Other');
            helper.setStatesOptions(component, leadRecord.Country.toUpperCase(), 'v.stateOptions');
        }
    },

    setStatesOptions: function (component, country, stateOptions) {
        const canadaOptions = [
            {"value": "Alberta", "label": "Alberta"},
            {"value": "British Columbia", "label": "British Columbia"},
            {"value": "Manitoba", "label": "Manitoba"},
            {"value": "New Brunswick", "label": "New Brunswick"},
            {"value": "Newfoundland", "label": "Newfoundland"},
            {"value": "Northwest Territories", "label": "Northwest Territories"},
            {"value": "Nova Scotia", "label": "Nova Scotia"},
            {"value": "Nunavut", "label": "Nunavut"},
            {"value": "Ontario", "label": "Ontario"},
            {"value": "Prince Edward Island", "label": "Prince Edward Island"},
            {"value": "Quebec", "label": "Quebec"},
            {"value": "Saskatchewan", "label": "Saskatchewan"},
            {"value": "Yukon", "label": "Yukon"},
        ];

        const mexicoOptions = [
            {"value": "Aguascalientes", "label": "Aguascalientes"},
            {"value": "Baja California", "label": "Baja California"},
            {"value": "Baja California Sur", "label": "Baja California Sur"},
            {"value": "Campeche", "label": "Campeche"},
            {"value": "Chihuahua", "label": "Chihuahua"},
            {"value": "Chiapas", "label": "Chiapas"},
            {"value": "Coahuila", "label": "Coahuila"},
            {"value": "Colima", "label": "Colima"},
            {"value": "Distrito Federal", "label": "Distrito Federal"},
            {"value": "Durango", "label": "Durango"},
            {"value": "Guerrero", "label": "Guerrero"},
            {"value": "Guanajuato", "label": "Guanajuato"},
            {"value": "Hidalgo", "label": "Hidalgo"},
            {"value": "Jalisco", "label": "Jalisco"},
            {"value": "México", "label": "México"},
            {"value": "Michoacán", "label": "Michoacán"},
            {"value": "Morelos", "label": "Morelos"},
            {"value": "Nayarit", "label": "Nayarit"},
            {"value": "Nuevo León", "label": "Nuevo León"},
            {"value": "Oaxaca", "label": "Oaxaca"},
            {"value": "Puebla", "label": "Puebla"},
            {"value": "Querétaro", "label": "Querétaro"},
            {"value": "Quintana Roo", "label": "Quintana Roo"},
            {"value": "Sinaloa", "label": "Sinaloa"},
            {"value": "San Luís Potosí", "label": "San Luís Potosí"},
            {"value": "Sonora", "label": "Sonora"},
            {"value": "Tabasco", "label": "Tabasco"},
            {"value": "Tamaulipas", "label": "Tamaulipas"},
            {"value": "Tlaxcala", "label": "Tlaxcala"},
            {"value": "Veracruz", "label": "Veracruz"},
            {"value": "Yucatán", "label": "Yucatán"},
            {"value": "Zacatecas", "label": "Zacatecas"}
        ];

        const usOptions = [
            {"value": "Alabama", "label": "Alabama"},
            {"value": "Alaska", "label": "Alaska"},
            {"value": "Arizona", "label": "Arizona"},
            {"value": "Arkansas", "label": "Arkansas"},
            {"value": "California", "label": "California"},
            {"value": "Colorado", "label": "Colorado"},
            {"value": "Connecticut", "label": "Connecticut"},
            {"value": "Delaware", "label": "Delaware"},
            {"value": "Florida", "label": "Florida"},
            {"value": "Georgia", "label": "Georgia"},
            {"value": "Hawaii", "label": "Hawaii"},
            {"value": "Idaho", "label": "Idaho"},
            {"value": "Illinois", "label": "Illinois"},
            {"value": "Indiana", "label": "Indiana"},
            {"value": "Iowa", "label": "Iowa"},
            {"value": "Kansas", "label": "Kansas"},
            {"value": "Kentucky", "label": "Kentucky"},
            {"value": "Louisiana", "label": "Louisiana"},
            {"value": "Maine", "label": "Maine"},
            {"value": "Maryland", "label": "Maryland"},
            {"value": "Massachusetts", "label": "Massachusetts"},
            {"value": "Michigan", "label": "Michigan"},
            {"value": "Minnesota", "label": "Minnesota"},
            {"value": "Mississippi", "label": "Mississippi"},
            {"value": "Missouri", "label": "Missouri"},
            {"value": "Montana", "label": "Montana"},
            {"value": "Nebraska", "label": "Nebraska"},
            {"value": "Nevada", "label": "Nevada"},
            {"value": "New Hampshire", "label": "New Hampshire"},
            {"value": "New Jersey", "label": "New Jersey"},
            {"value": "New Mexico", "label": "New Mexico"},
            {"value": "New York", "label": "New York"},
            {"value": "North Carolina", "label": "North Carolina"},
            {"value": "North Dakota", "label": "North Dakota"},
            {"value": "Ohio", "label": "Ohio"},
            {"value": "Oklahoma", "label": "Oklahoma"},
            {"value": "Oregon", "label": "Oregon"},
            {"value": "Pennsylvania", "label": "Pennsylvania"},
            {"value": "Rhode Island", "label": "Rhode Island"},
            {"value": "South Carolina", "label": "South Carolina"},
            {"value": "South Dakota", "label": "South Dakota"},
            {"value": "Tennessee", "label": "Tennessee"},
            {"value": "Texas", "label": "Texas"},
            {"value": "Utah", "label": "Utah"},
            {"value": "Vermont", "label": "Vermont"},
            {"value": "Virginia", "label": "Virginia"},
            {"value": "Washington", "label": "Washington"},
            {"value": "West Virginia", "label": "West Virginia"},
            {"value": "Wisconsin", "label": "Wisconsin"},
            {"value": "Wyoming", "label": "Wyoming"}
        ];

        if (country.toUpperCase() === 'MEXICO') {
            component.set(stateOptions, mexicoOptions);
        } else if (country.toUpperCase() === 'CANADA') {
            component.set(stateOptions, canadaOptions);
        } else if (country.toUpperCase() === 'UNITED STATES') {
            component.set(stateOptions, usOptions);
        }
    }
})