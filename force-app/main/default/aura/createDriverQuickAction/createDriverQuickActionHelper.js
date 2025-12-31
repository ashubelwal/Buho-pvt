({
	initializeData: function (component, event, helper) {
        try {
            let countryOption = [
                {"value": "United States", "label": "United States"},
                {"value": "Canada", "label": "Canada"}
            ];
			countryOption.push({"value": "Mexico", "label": "Mexico"});
			countryOption.push({"value": "Other", "label": "Other"});
            
            component.set("v.countryOption", countryOption);
            let driverTypeOptions = component.get("v.driverTypeOptions");
            if ($A.util.isEmpty(driverTypeOptions)) {
                helper.fetchPicklist(component, event, helper, 'Driver__c', 'Driver_Type__c', 'v.driverTypeOptions');
            }
        }catch (e) {
            console.log('driverReg : ' + e);
        }
    },

	setInputComponentsVisibility: function (component, event, helper) {
        let driverObject = component.get("v.driverObject");
        let policyCountry = component.get("v.policyCountry");
        let policyCountryLicense = component.get("v.policyCountryLicense");
        if (driverObject.Country__c) {
            if( policyCountry != undefined && policyCountry != ''){
                component.set("v.showCountryInput", policyCountry === 'Other');
                component.set("v.showStatePick", policyCountry !== 'Other');
            }
            

            let country = driverObject.Country__c.toUpperCase();
            helper.setCountryAndStates(component, country, 'v.stateOptions');
            //component.set("v.disableCountryInput", country === 'MEXICO');
        }
        if (driverObject.License_Country__c) {
            if( policyCountryLicense != undefined && policyCountryLicense != ''){
                component.set("v.showCountryLicenseInput", policyCountryLicense === 'Other');
                component.set("v.showStatePickLicense", policyCountryLicense !== 'Other');
            }
            

            let country = driverObject.License_Country__c.toUpperCase();
            helper.setCountryAndStates(component, country, 'v.stateOptionsLicense');
            //component.set("v.disableCountryLicenseInput", country === 'MEXICO');
        }
    },

	setCountryAndStates: function (component, country, stateOptions) {
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
    },

	/*
	* objectApiName : ObjectName
	* fieldApi : filed Api name
	* fieldAttr : save data in cmp,
	* */
    fetchPicklist: function (component, event, helper, objectApiName, fieldApi, fieldAttr) {
        let action = component.get("c.getPicklistValues");

        action.setParams({
            'objectApiName': objectApiName,
            'fieldApiName': fieldApi
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

	createDriverRecord : function(component, event, helper){
		
		let action = component.get("c.createNewDriver");

        action.setParams({
			driverRecord: component.get("v.driverObject")
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
				//$A.get('e.force:refreshView').fire(); 
				//$A.get("e.force:closeQuickAction").fire();
				var pageName = '/detail/';
				var currentPagePrefix = '/detail';
				var urlString = window.location.href;
				var communityUrl = urlString.substring(0, urlString.indexOf(currentPagePrefix));

				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({ 
					"url": (communityUrl + pageName + response.getReturnValue().driverId)
				});
				urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},

	validateInputFields : function(component, event, helper){
       
        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        return allValid;
    },
})