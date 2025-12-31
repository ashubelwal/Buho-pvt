({
    doInit: function (component, event, helper) {
        console.log('--drivers---', component.get("v.drivers"));
        var editPolicy = component.get("v.editPolicy");
        console.log('--editPolicy---', editPolicy);
        if( editPolicy != undefined && editPolicy == true){
            helper.initializeEditData(component, event, helper);
        }else{
            helper.initializeData(component, event, helper);
        }

        var drivers = component.get("v.drivers");
        if( drivers != undefined && drivers.length > 0 ){
            component.set("v.isDriverScreenOpen", false);
        }
        var vehicleRecord = component.get("v.vehicleRecord");
        if( vehicleRecord != undefined && vehicleRecord.Is_the_vehicle_registered_to_a_business__c != undefined 
            && vehicleRecord.Is_the_vehicle_registered_to_a_business__c == true){
                
            component.set("v.registeredVehicleHeader", "Driver Information");
        }
        
        helper.getLoginUserDriversHelper(component, event, helper);
    },

    addDriver: function (component, event, helper) {
        console.log("Click add driver function");
        let allVal = component.find("driverDetail").validateFields();
        var renewPolicy = component.get("v.renewPolicy");
        
        if( allVal ){
            if( renewPolicy != undefined && renewPolicy == true ){
                helper.createDriverHelper(component, event, helper, false);
                return;
            }

            var editPolicy = component.get("v.editPolicy");
            var iscloneConditionPass = component.get("v.iscloneConditionPass");
            console.log("Edit Policy --> ", editPolicy);
            console.log("iscloneConditionPass --> ", iscloneConditionPass);
            if( editPolicy == true && iscloneConditionPass == true ){
                console.log("Inside Driver if");
                var driverRecord = component.get("v.driverRecord")
                let drivers = component.get("v.drivers");
                drivers.push(driverRecord);
                component.set("v.drivers", drivers);
                component.set("v.driverRecord", {'sobjectType': 'Driver__c'});
            }else{
                helper.createDriverHelper(component, event, helper, false);
            }
        }
    },

    openDriverDetail : function (component, event, helper) {
        component.set("v.isDriverScreenOpen", !component.get("v.isDriverScreenOpen"));
    },

    handleChange : function (component, event, helper) {
        var driverId = event.getParam("value");
        var loginUserDrivers = component.get("v.loginUserDrivers");
        if( loginUserDrivers != undefined && loginUserDrivers.length > 0 && driverId != undefined && driverId != null && driverId != ''){
            var driverlist = loginUserDrivers.filter(item => {
                return item.Id === driverId;
            });
            if( driverlist != null && driverlist != undefined ){
                component.set("v.driverRecord", driverlist[0]);
                component.set("v.iscloneConditionPass", true);

                /*var renewPolicy = component.get("v.renewPolicy");
                if( renewPolicy != undefined && renewPolicy == true ){
                    var driverRecord = component.get("v.driverRecord")
                    let drivers = component.get("v.drivers");
                    drivers.push(driverRecord);
                    component.set("v.drivers", drivers);
                    component.set("v.driverRecord", {'sobjectType': 'Driver__c'});
                    $A.enqueueAction(component.get("v.onNextClick"));
                    return;
                }*/
                helper.createDriverHelper( component, event, helper, false);
            }
        }
    },

    onNextClick: function (component, event, helper) {
        let drivers = component.get("v.drivers");
        let ownerCount = 0;
        console.log("CA on nextClick drivers : "+JSON.stringify(drivers, null, 4));
        drivers.map((data)=>{
            if(data.Driver_Type__c == "Owner" || data.Driver_Type__c == "Owner & Driver"){
            ownerCount += 1;
        }
                    });
        
        if(ownerCount == 1 || component.get('v.policyType') == 'Driver License'){
            
            if(!component.get("v.isCommunityUser")) {
                let selectedProduct = {};
                let quoteRecord = component.get("v.quoteRecord");
                selectedProduct.item_name = quoteRecord.Policy_Type_picklist__c.toLowerCase() == "northbound" ? "Northbound" : quoteRecord.Policy_Type_picklist__c.toLowerCase() == "watercraft" ? "Watercraft" : "Automobile";
                selectedProduct.item_id = quoteRecord.Policy_Type_picklist__c == "Automobile" ? "0121C00000102F1QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "Motorcycle/Street Legal ATV" ? "0121C00000102F4QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "RV" ? "0121C00000102F6QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "Northbound" ? "0121C00000102F5QAI-" + quoteRecord.Underwriter__c : "0121C00000102F7QAI-" + quoteRecord.Underwriter__c;
                selectedProduct.price = quoteRecord.Quote_Value__c;
                selectedProduct.item_brand = "MexInsurance";
                selectedProduct.item_category = quoteRecord.Vehicle_Type__c;
                selectedProduct.item_category2 = quoteRecord.Term__c;
                selectedProduct.item_category3 = quoteRecord.Policy_Type_picklist__c != "Watercraft" ? quoteRecord.Territory_Coverage__c : "";
                selectedProduct.item_category4 = quoteRecord.Underwriter__c;
                selectedProduct.item_variant = quoteRecord.Coverage__c;
                selectedProduct.item_list_name = quoteRecord.Policy_Type_picklist__c == "Northbound" ? "Northbound Quote Page" : quoteRecord.Policy_Type_picklist__c == "Watercraft" ? "Watercraft Quote Page" : quoteRecord.Policy_Type_picklist__c + " Quote Page";
                selectedProduct.quantity = 1;
                selectedProduct.index = quoteRecord.Policy_Type_picklist__c.toLowerCase() == "northbound" || quoteRecord.Policy_Type_picklist__c.toLowerCase() == "watercraft" ? 1 : quoteRecord.Policy_Type_picklist__c.toLowerCase() != "northbound" && quoteRecord.Policy_Type_picklist__c.toLowerCase() != "watercraft" && quoteRecord.Underwriter__c.toLowerCase() == "qualitas" ? 1 : quoteRecord.Policy_Type_picklist__c.toLowerCase() != "northbound" && quoteRecord.Policy_Type_picklist__c.toLowerCase() != "watercraft" && quoteRecord.Underwriter__c.toLowerCase() == "chubb" ? 2 : 3;
                
                console.log("Selected Product Driver Information page -->", JSON.stringify(selectedProduct, null, 4));
                
                window.dataLayer.push({ ecommerce: undefined });
                window.dataLayer.push({
                    event: "add_to_cart",
                    ecommerce: {
                        items: [selectedProduct]
                    }
                });
            }


            if( drivers == undefined || drivers.length == 0 ){
                let allVal = component.find("driverDetail").validateFields();
                if( allVal ){
                    var renewPolicy = component.get("v.renewPolicy");
                    if( renewPolicy != undefined && renewPolicy == true ){
                        console.log("CA log Inside renewPolicy condition");
                        helper.createDriverHelper(component, event, helper, true);
                        return;
                    }
                    
                    var editPolicy = component.get("v.editPolicy");
                    var iscloneConditionPass = component.get("v.iscloneConditionPass");
                    if( editPolicy == true && iscloneConditionPass == true ){
                        var driverRecord = component.get("v.driverRecord")
                        let drivers = component.get("v.drivers");
                        drivers.push(driverRecord);
                        component.set("v.drivers", drivers);
                        component.set("v.driverRecord", {'sobjectType': 'Driver__c'});
                        $A.enqueueAction(component.get("v.onNextClick"));
                    }else{
                        helper.createDriverHelper(component, event, helper, true);
                    }
                }
            }else{
                console.log("CA log Inside Else");
                $A.enqueueAction(component.get("v.onNextClick"));
            }
        }else{
            helper.showToast('There should be single owner!!!', 'error');
        }
        
    },

    editDriver : function(component, event, helper) {
        var index = event.target.name;
        var drivers = component.get("v.drivers");
        var driverObject = drivers[ parseInt(index)];
        let newOptionDriverType = [];
        console.log('--driverObject---',driverObject);
        console.log('--driverObject Driver_Type__c---',driverObject.Driver_Type__c);
        console.log('--driverObject.Quote_Drivers__r ---',driverObject.Quote_Drivers__r );
        if( driverObject != undefined && driverObject.Quote_Drivers__r != undefined && driverObject.Quote_Drivers__r.length > 0 ){
            console.log('--Primary_insured__c---',driverObject.Quote_Drivers__r[0].Primary_insured__c );
            component.set("v.Primary_insured", driverObject.Quote_Drivers__r[0].Primary_insured__c);
        }
        
        
        component.set("v.driverForEdit", driverObject);
        component.set("v.isEditDriverOwner", (driverObject.Driver_Type__c == 'Owner'));
        component.set("v.isEditDriver", component.get("v.driverForEdit") != null);
    },

    deleteDriver : function(component, event, helper) {
        var driverRecordIndex = event.target.name;
        helper.deleteDriverHelper(component, event, helper, driverRecordIndex);
    },

    cancelNewDriver :function( component, event, helper ){
        component.set('v.isDriverScreenOpen',false);
    },

    cancelEdit : function(component, event, helper) {
        component.set("v.isEditDriver", false);
        component.set("v.driverForEdit", null);
    },

    updateDriver : function(component, event, helper) {
        let allVal = component.find("driverDetail").validateFields();
        if (allVal) {
            helper.updateDriverHelper( component, event, helper );
        }
    }
})