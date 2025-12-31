({
    initilizeData : function( component, event, helper ) {
        var yesNoOptions = [{'label':'Yes','value':'Yes'},{'label':'No','value':'No'}];
        component.set("v.yesNoOptions", yesNoOptions);

        var quoteRecord = component.get("v.quoteRecord");
        var vehicleRecord = component.get("v.vehicleRecord");
        if( !(vehicleRecord != undefined  && vehicleRecord.Id != null) ) {
            vehicleRecord['Year__c'] = quoteRecord.Vehicle_Year__c;
            vehicleRecord['Make__c'] = quoteRecord.Vehicle_Make__c;
            vehicleRecord['Model__c'] = quoteRecord.Vehicle_Model__c;
            vehicleRecord['Value__c'] = quoteRecord.Vehicle_Value__c;

            if( quoteRecord.Is_this_a_Rental_Vehicle__c != undefined && quoteRecord.Is_this_a_Rental_Vehicle__c == true  ){
                vehicleRecord['Rental__c'] = 'Yes';
            }else{
                vehicleRecord['Rental__c'] = 'No';
            }
            
            vehicleRecord['Salvage_Vehicle__c'] = (quoteRecord.Salvage_Vehicle__c == 'Yes'? true : false );
        }
        var policyType = component.get("v.policyType");
        if( policyType != 'Northbound' && ( policyType == 'Motorcycle/Street Legal ATV' || policyType == 'Automobile' || policyType == 'RV' )){
            vehicleRecord['Vehicle_Type__c'] = quoteRecord.Vehicle_Sub_type__c;
        }else{
            if( quoteRecord.Vehicle_Type__c == 'Motorcycle/Street Legal ATV'){
                vehicleRecord['Vehicle_Type__c'] = 'Street Legal ATV';
            }else if( quoteRecord.Vehicle_Type__c == 'Car/Truck/Auto' ) {
                vehicleRecord['Vehicle_Type__c'] = 'Automobile/Sedan';
            }else{
                vehicleRecord['Vehicle_Type__c'] = 'Automobile/Sedan';
            }
        }        
        if( vehicleRecord != undefined && vehicleRecord.Registered_Country__c != undefined){
            component.set("v.policyCountry", vehicleRecord.Registered_Country__c);
        }
        
        
        helper.fetchPicklist( component, event, helper , 'Vehicle__c', 'Vehicle_Type__c', 'v.vehicleTypeOptions');
        var policyType = component.get("v.policyType");
        if( policyType && policyType.toLowerCase() == 'northbound' && !( vehicleRecord && vehicleRecord.Registered_Country__c != null )){
            vehicleRecord['Registered_Country__c'] = 'Mexico';
        }

        if( policyType && policyType == 'RV'){
            //vehicleRecord['Vehicle_Type__c'] = 'Pickup Truck w or w/o Camper Shell';// changed by vikram at 14 Nov 2021
            vehicleRecord['Vehicle_Type__c'] = 'Motor Home / RV';
        }
        
        if( policyType && policyType.toLowerCase() == 'northbound' && vehicleRecord && vehicleRecord.Registered_Country__c && vehicleRecord.Registered_Country__c.toUpperCase() == 'MEXICO'){ 
            component.set("v.disableCountry", true);
            helper.setCountryAndStates(component, event, helper, 'MEXICO' );
        }

        if( vehicleRecord && vehicleRecord.Registered_Country__c ){
            if( vehicleRecord.Registered_Country__c.toUpperCase() == 'MEXICO' ){
                component.set("v.showStatePick", true);
                helper.setCountryAndStates(component, event, helper, 'MEXICO' );
            }else if( vehicleRecord.Registered_Country__c.toUpperCase() == 'UNITED STATES' ){
                component.set("v.showStatePick", true);
                helper.setCountryAndStates(component, event, helper, 'UNITED STATES' );
            }else if( vehicleRecord.Registered_Country__c.toUpperCase() == 'CANADA' ){
                component.set("v.showStatePick", true);
                helper.setCountryAndStates(component, event, helper, 'CANADA' );
            }
            
        }
        component.set("v.vehicleRecord", vehicleRecord);

        var countryOption = [];

        if (!component.get("v.communityUser")) {
            let selectedProduct = {};
            selectedProduct.item_name = quoteRecord.Policy_Type_picklist__c.toLowerCase() == "northbound" ? "Northbound" : "Automobile";
            selectedProduct.item_id = quoteRecord.Policy_Type_picklist__c == "Automobile" ? "0121C00000102F1QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "Motorcycle/Street Legal ATV" ? "0121C00000102F4QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "RV" ? "0121C00000102F6QAI-" + quoteRecord.Underwriter__c : "0121C00000102F5QAI-" + quoteRecord.Underwriter__c;
            selectedProduct.price = quoteRecord.Quote_Value__c;
            selectedProduct.item_brand = "MexInsurance";
            selectedProduct.item_category = quoteRecord.Vehicle_Type__c;
            selectedProduct.item_category2 = quoteRecord.Term__c;
            selectedProduct.item_category3 = quoteRecord.Territory_Coverage__c;
            selectedProduct.item_category4 = quoteRecord.Underwriter__c;
            selectedProduct.item_variant = quoteRecord.Coverage__c;
            selectedProduct.item_list_name = quoteRecord.Policy_Type_picklist__c.toLowerCase() == "northbound" ? "Northbound Quote Page" : quoteRecord.Policy_Type_picklist__c + " Quote Page";
            selectedProduct.quantity = 1;
            selectedProduct.index = quoteRecord.Policy_Type_picklist__c.toLowerCase() == 'northbound' && quoteRecord.Underwriter__c.toLowerCase() == 'chubb' ? 1 : quoteRecord.Policy_Type_picklist__c.toLowerCase() != 'northbound' && quoteRecord.Underwriter__c.toLowerCase() == 'qualitas' ? 1 : quoteRecord.Policy_Type_picklist__c.toLowerCase() != 'northbound' && quoteRecord.Underwriter__c.toLowerCase() == 'chubb' ? 2 : 3;

            console.log("Selected Product Review Vehicle Page ---> ", JSON.stringify(selectedProduct, null, 4));

            window.dataLayer.push({ ecommerce: undefined });
            window.dataLayer.push({
                event: "view_item",
                ecommerce: {
                    items: [selectedProduct]
                }
            });
        }

        if( policyType && policyType.toLowerCase() == 'northbound' ){
            countryOption.push({ "value" : "Mexico", "label" : "Mexico" });
        }else{
            countryOption = [
                { "value" : "United States", "label" : "United States" },	
                { "value" : "Canada", "label" : "Canada" },
                { "value" : "Other", "label" : "Other" }	
            ];
        }

        component.set("v.countryOption", countryOption);
    },


    setCountryAndStates : function( component, event, helper, country ){
        var canadaOptions = [	
            { "value" : "Alberta", "label" : "Alberta" },	
            { "value" : "British Columbia", "label" : "British Columbia" },
            { "value" : "Manitoba", "label" : "Manitoba" },	
            { "value" : "New Brunswick", "label" : "New Brunswick" },
            { "value" : "Newfoundland", "label" : "Newfoundland" },	
            { "value" : "Northwest Territories", "label" : "Northwest Territories" },
            { "value" : "Nova Scotia", "label" : "Nova Scotia" },	
            { "value" : "Nunavut", "label" : "Nunavut" },
            { "value" : "Ontario", "label" : "Ontario" },	
            { "value" : "Prince Edward Island", "label" : "Prince Edward Island" },
            { "value" : "Quebec", "label" : "Quebec" },	
            { "value" : "Saskatchewan", "label" : "Saskatchewan" },
            { "value" : "Yukon", "label" : "Yukon" },
        ];

        var mexicoOptions = [	
            { "value" : "Aguascalientes", "label" : "Aguascalientes" },	
            { "value" : "Baja California", "label" : "Baja California" },
            { "value" : "Baja California Sur", "label" : "Baja California Sur" },
            { "value" : "Campeche", "label" : "Campeche" },
            { "value" : "Chihuahua", "label" : "Chihuahua" },
            { "value" : "Chiapas", "label" : "Chiapas" },
            { "value" : "Coahuila", "label" : "Coahuila" },
            { "value" : "Colima", "label" : "Colima" },
            { "value" : "Distrito Federal", "label" : "Distrito Federal" },
            { "value" : "Durango", "label" : "Durango" },
            { "value" : "Guerrero", "label" : "Guerrero" },
            { "value" : "Guanajuato", "label" : "Guanajuato" },
            { "value" : "Hidalgo", "label" : "Hidalgo" },
            { "value" : "Jalisco", "label" : "Jalisco" },
            { "value" : "México", "label" : "México" },
            { "value" : "Michoacán", "label" : "Michoacán" },
            { "value" : "Morelos", "label" : "Morelos" },
            { "value" : "Nayarit", "label" : "Nayarit" },
            { "value" : "Nuevo León", "label" : "Nuevo León" },
            { "value" : "Oaxaca", "label" : "Oaxaca" },
            { "value" : "Puebla", "label" : "Puebla" },
            { "value" : "Querétaro", "label" : "Querétaro" },
            { "value" : "Quintana Roo", "label" : "Quintana Roo" },
            { "value" : "Sinaloa", "label" : "Sinaloa" },
            { "value" : "San Luís Potosí", "label" : "San Luís Potosí" },
            { "value" : "Sonora", "label" : "Sonora" },
            { "value" : "Tabasco", "label" : "Tabasco" },
            { "value" : "Tamaulipas", "label" : "Tamaulipas" },
            { "value" : "Tlaxcala", "label" : "Tlaxcala" },
            { "value" : "Veracruz", "label" : "Veracruz" },
            { "value" : "Yucatán", "label" : "Yucatán" },
            { "value" : "Zacatecas", "label" : "Zacatecas" }   
        ];

        var usOptions = [	
            { "value" : "Alabama", "label" : "Alabama" },	
            { "value" : "Alaska", "label" : "Alaska" },
            { "value" : "Arizona", "label" : "Arizona" },	
            { "value" : "Arkansas", "label" : "Arkansas" },
            { "value" : "California", "label" : "California" },	
            { "value" : "Colorado", "label" : "Colorado" },
            { "value" : "Connecticut", "label" : "Connecticut" },	
            { "value" : "Delaware", "label" : "Delaware" },
            { "value" : "Florida", "label" : "Florida" },	
            { "value" : "Georgia", "label" : "Georgia" },
            { "value" : "Hawaii", "label" : "Hawaii" },	
            { "value" : "Idaho", "label" : "Idaho" },
            { "value" : "Illinois", "label" : "Illinois" },
            { "value" : "Indiana", "label" : "Indiana" },
            { "value" : "Iowa", "label" : "Iowa" },	
            { "value" : "Kansas", "label" : "Kansas" },
            { "value" : "Kentucky", "label" : "Kentucky" },	
            { "value" : "Louisiana", "label" : "Louisiana" },
            { "value" : "Maine", "label" : "Maine" },	
            { "value" : "Maryland", "label" : "Maryland" },
            { "value" : "Massachusetts", "label" : "Massachusetts" },	
            { "value" : "Michigan", "label" : "Michigan" },
            { "value" : "Minnesota", "label" : "Minnesota" },	
            { "value" : "Mississippi", "label" : "Mississippi" },
            { "value" : "Missouri", "label" : "Missouri" },	
            { "value" : "Montana", "label" : "Montana" },
            { "value" : "Nebraska", "label" : "Nebraska" },
            { "value" : "Nevada", "label" : "Nevada" },	
            { "value" : "New Hampshire", "label" : "New Hampshire" },
            { "value" : "New Jersey", "label" : "New Jersey" },	
            { "value" : "New Mexico", "label" : "New Mexico" },
            { "value" : "New York", "label" : "New York" },	
            { "value" : "North Carolina", "label" : "North Carolina" },
            { "value" : "North Dakota", "label" : "North Dakota" },	
            { "value" : "Ohio", "label" : "Ohio" },
            { "value" : "Oklahoma", "label" : "Oklahoma" },	
            { "value" : "Oregon", "label" : "Oregon" },
            { "value" : "Pennsylvania", "label" : "Pennsylvania" },
            { "value" : "Rhode Island", "label" : "Rhode Island" },
            { "value" : "South Carolina", "label" : "South Carolina" },
            { "value" : "South Dakota", "label" : "South Dakota" },	
            { "value" : "Tennessee", "label" : "Tennessee" },
            { "value" : "Texas", "label" : "Texas" },	
            { "value" : "Utah", "label" : "Utah" },
            { "value" : "Vermont", "label" : "Vermont" },	
            { "value" : "Virginia", "label" : "Virginia" },
            { "value" : "Washington", "label" : "Washington" },	
            { "value" : "West Virginia", "label" : "West Virginia" },
            { "value" : "Wisconsin", "label" : "Wisconsin" },	
            { "value" : "Wyoming", "label" : "Wyoming" }
        ];

        if( country && country.toUpperCase() == 'MEXICO'){
            component.set("v.stateOptions", mexicoOptions);
        }else if( country && country.toUpperCase() == 'CANADA'){
            component.set("v.stateOptions", canadaOptions);
        }else if( country && country.toUpperCase() == 'UNITED STATES'){
            component.set("v.stateOptions", usOptions);
        }
        
    },
    
    /*
     * objectApiName : ObjectName
     * fieldApi : filed Api name
     * fieldAttr : save data in cmp,
     * */
    fetchPicklist : function( component, event, helper, objectApiName, fieldApi, fieldAttr) {
        var action = component.get("c.getPicklistValues");
        
        action.setParams({ 'objectApiName' : objectApiName,
                          'fieldApiName' : fieldApi }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if( fieldApi == 'Vehicle_Type__c'){
                    var tempOption = response.getReturnValue();
                    var options = [];
                    var policyType = component.get("v.policyType");
                    tempOption.forEach(function(item){
                        if( policyType == 'Motorcycle/Street Legal ATV' && item.value != 'Motor Home / RV' 
                            && ( item.value == 'Motorcycle' || item.value == 'Street Legal ATV' )){
                            options.push(item);
                        }else if( policyType != 'Motorcycle/Street Legal ATV' && item.value != 'Motor Home / RV'){
                            options.push(item);
                        }
                    });
                    component.set(fieldAttr, options);
                    
                }else{
                    component.set(fieldAttr, response.getReturnValue());
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    handleVehicleDetail : function( component, event, helper ){
        
        const action = component.get("c.createVehicleNorthAction");
        action.setParams({  
            vehicleObject : component.get("v.vehicleRecord"),
            quoteId : component.get("v.quoteRecord").Id
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    var vehicleRecord = component.get("v.vehicleRecord");
                    vehicleRecord['Id'] = response.vehicleId;
                    component.set("v.vehicleRecord",vehicleRecord);

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
    
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },

    validateInputFields : function(component, event, helper){
        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        return allValid;
    },
})