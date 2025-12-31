({
    doInit : function(component, event, helper) {
        const action = component.get("c.getQuoteDetails");
        var quoteIds  = component.get("v.quoteIds");
        let quoteRecord  = component.get("v.quoteRecord");

        if (!component.get("v.isCommunityUser")) {
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

            console.log("Selected Product Verify and edit page -->", JSON.stringify(selectedProduct, null, 4));
            window.dataLayer.push({ ecommerce: undefined });
            window.dataLayer.push({
                event: "view_cart",
                ecommerce: {
                    items: [selectedProduct]
                }
            });
        }

       console.log('--quoteRecord rateObectList---'+JSON.stringify(component.get("v.rateObectList"),null,4)); 
        console.log('--quoteIds---'+JSON.stringify(quoteIds));
        //quoteIds.push('a0S2i000001cL7XEAU');
console.log('--quoteRecord---'+JSON.stringify(quoteRecord,null,4));
        var tempQuoteIds = [];
        quoteIds.forEach(function(item){
            if( item && item != null ){
                tempQuoteIds.push(item);
            }
        });
        
        
        action.setParams({  'quoteIds' : JSON.stringify(tempQuoteIds)});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('---response--'+JSON.stringify(response));
                component.set("v.vehicles", response.vehicles);
                component.set("v.drivers", response.drivers);
                component.set("v.towed_Units", response.towed_Units);
                
                component.set("v.vehicleTempId", response.vehicleid);
                component.set("v.driverAgeUnder21", response.driverAgeUnder21);
                
            }
        });
        $A.enqueueAction(action);
        
        var rateObectList = component.get("v.rateObectList");
        console.log('--rateObectList---'+JSON.stringify(rateObectList, null, 4));
        var Total_Premium = 0;
        rateObectList.forEach(function(item){
            if( item.Total_Premium != null ){
                Total_Premium += item.Total_Premium;
                
            }
            if(item.quoteRecord != undefined){
                console.log("CA log enter in condititon");
                item.quoteRecord.I_V_A_Mex_Tax__c != null ? item.quoteRecord.I_V_A_Mex_Tax__c : 0;
            }
             console.log('rateRecord.quoteRecord : ' + JSON.stringify(item.quoteRecord, null, 4));
            console.log('rateRecord.quoteRecord.I_V_A_Mex_Tax__c : ' + item.quoteRecord.I_V_A_Mex_Tax__c );
            console.log('rateRecord.quoteRecord.End_Time__c : ' + item.quoteRecord.End_Time__c);
        });
        component.set("v.Total_Premium", Total_Premium);
        component.set("v.Final_total_Premium", Total_Premium);
         console.log('--rateObectList 2---'+JSON.stringify(rateObectList, null, 4));
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.minDate", today);

    },
    
    editVehicle : function(component, event, helper) {
        console.log(event.target.name);
        var index = event.target.name;
        var vehicles = component.get("v.vehicles");
        component.set("v.isEditVehicle", true);
        var vehicleObject = vehicles[ parseInt(index)];
        component.set("v.vehicleObject", vehicleObject);
    },
    
    editRateData : function(component, event, helper) {
        var index = event.target.name;
        var rateObectList = component.get("v.rateObectList");
        var rateObj = null;
        if( rateObectList.length > 0 ){
            rateObj = rateObectList[parseInt(index)];
        }
         
        var quoteObject = component.get("v.quoteObject");
        console.log('****rateObj.quoteRecord****'+JSON.stringify(rateObj.quoteRecord));
        component.set("v.quoteObject", rateObj.quoteRecord);
        component.set("v.liability",  rateObj.Liability__c);
        component.set("v.rateValue",  rateObj.Total_Premium);
        component.set("v.isEditRate", true);
    },
    
    editDriver : function(component, event, helper) {
        console.log(event.target.name);
        var index = event.target.name;
        var drivers = component.get("v.drivers");
        var driverObject = drivers[ parseInt(index)];
        console.log('driver record : ' + JSON.stringify(driverObject));
        component.set("v.isOwner", (driverObject.Driver_Type__c == 'Owner'));
        component.set("v.driverObject", driverObject);
        component.set("v.isEditDriver", true);
    },
    
    updateVehicleField : function (component, event, helper) {
        var name = event.getSource().get("v.name");
        var vehicleObject = component.get("v.vehicleObject");
        
        if(name == 'Is_the_vehicle_registered_to_a_business__c'
           || name == 'Is_the_vehicle_used_for_business_purpose__c'
           || name == 'Salvage_Vehicle__c'
           || name == 'Is_Lienholder__c'){
            
            var value = event.getParam("checked");
            vehicleObject[name] = value;
            
        }else if(name == 'Rental__c'){
            var value = event.getParam("checked");
            if( value ){
                vehicleObject[name]= 'Yes';
            }else{
                vehicleObject[name] = 'No';
            }
        } else if (name == 'Make__c') {
            let value = event.getParam("value");
            if(/^\s/.test(value)){
                value = '';
            }
        } else if (name == 'Model__c') {
            let value = event.getParam("value");
            if(/^\s/.test(value)){
                value = '';
            }
        } else{
            var value = event.getParam("value");
            vehicleObject[name] = value;
        }
        
        component.set("v.vehicleObject", vehicleObject);
        
    }, 
    
    cancleEdit : function(component, event, helper) {
        component.set("v.isEditDriver", false);
        component.set("v.isEditVehicle", false);
        component.set("v.isEditRate", false);
    },
    
    updateQuoteField : function (component, event, helper) {
        var name = event.getSource().get("v.name");
        var quoteObject = component.get("v.quoteObject");
        var value = event.getParam("value");
        quoteObject[name] = value;
        
        component.set("v.quoteObject", quoteObject);
        helper.getDataFromRateDataTable( component, event, helper );
    },
    
    updateDriver : function(component, event, helper) {
        helper.updateDriverHelper( component, event, helper );
    },
    
    updateVehicle : function(component, event, helper) {
        helper.updateVehicleHelper( component, event, helper );
    },
    
    updateLiability : function (component, event, helper) {
        var liability = component.get("v.liability");
        var updateLiability = '';
        if( event.target.name == 'field-plus'){
            if( liability == '100,000' ){
                updateLiability = '200,000';
            }else if( liability == '200,000' ){
                updateLiability = '300,000';
            }
        }else{
            if( liability == '300,000' ){
                updateLiability = '200,000';
            }else if( liability == '200,000' ){
                updateLiability = '100,000';
            }
        }
        component.set("v.liability", updateLiability);
        helper.getDataFromRateDataTable( component, event, helper );
    },
    
    updateRateTable : function (component, event, helper) {
        var allValidate = helper.validateInputFields(component, event, helper);
        console.log('--allValidate---'+allValidate);
        if(allValidate){
            helper.createQuoteHelper(component, event, helper);
        }
    },
    
    handleBackClick : function (component, event, helper) {
    }
})