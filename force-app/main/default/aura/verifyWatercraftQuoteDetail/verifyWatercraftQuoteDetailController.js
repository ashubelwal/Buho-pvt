({
    doInit : function(component, event, helper) {
        var drivers = component.get("v.drivers");
        var quoteRecord = component.get("v.quoteRecord");
        console.log('drivers ', drivers);

        for (var driver of drivers) {
            console.log('driver ', driver);
            if (driver.Dob__c != null) {
                driver.Dob__c = (driver.Dob__c).split('T')[0];
                driver.formattedDob = $A.localizationService.formatDate(driver.Dob__c);
            }
        }

        component.set("v.drivers", drivers);

        var rateRecordList = component.get("v.rateRecordList");
        var Total_Premium = 0;
        console.log('rateRecordList ', rateRecordList);

        rateRecordList.forEach(function(item){
            if( item.Total_Premium != null ){
                Total_Premium += item.Total_Premium;
                console.log('rateRecord.quoteRecord.Start_Time__c : ' + item.quoteRecord.Start_Time__c);
                console.log('rateRecord.quoteRecord.End_Time__c : ' + item.quoteRecord.End_Time__c);
            }
        });
        
        component.set("v.Total_Premium", Total_Premium);
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.minDate", today);
        
        if (!component.get("v.communityUser")) {
            let selectedProduct = {};
            selectedProduct.item_Name = "Watercraft";
            selectedProduct.item_id = '0121C00000102F7QAI-Chubb';
            selectedProduct.price = quoteRecord.Quote_Value__c;
            selectedProduct.item_brand = "MexInsurance";
            selectedProduct.item_category = quoteRecord.Vehicle_Type__c;
            selectedProduct.item_category2 = quoteRecord.Term__c;
            selectedProduct.item_category3 = "";
            selectedProduct.item_category4 = "Chubb";
            selectedProduct.item_variant = quoteRecord.Coverage__c;
            selectedProduct.item_list_name = "Watercraft Quote Page";
            selectedProduct.quantity = 1;
            selectedProduct.index = 1;

            console.log("Selected Product Verify and Edit page -->", JSON.stringify(selectedProduct, null, 4));
            window.dataLayer.push({ ecommerce: undefined });
            window.dataLayer.push({
                event: "view_cart",
                ecommerce: {
                    items: [selectedProduct]
                }
            });
        }

        helper.fetchPicklist( component, event, helper , 'Quote__c', 'Type_of_Vessel__c', 'v.vesselTypes');
        helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths');
        if( rateRecordList.length > 0 ) {
            component.set("v.rateQuoteRecord", Object.assign({}, quoteRecord));
            helper.calculateDays(component, event, helper);
        }
        
        let finalRateValue = component.get("v.Total_Premium");
            
            component.set("v.Final_total_Premium", finalRateValue);
    },
    
    cancelEdit : function(component, event, helper) {
        component.set("v.isEditDriver", false);
        component.set("v.isEditWatercraft", false);
        component.set("v.isEditRate", false);
    },
    
    editWatercraft : function(component, event, helper) {
        // $A.enqueueAction(component.get("v.onEditWatercraft"));
        var tmpQuote = Object.assign({}, component.get("v.quoteRecord"));
        var tmpWatercraft = Object.assign({}, component.get("v.watercraftRecord"));

        component.set("v.tempQuoteRecord", tmpQuote);
        component.set("v.tempWatercraftRecord", tmpWatercraft);
        component.set("v.isEditWatercraft", true);
    },
    
    editRateData : function(component, event, helper) {
        // $A.enqueueAction(component.get("v.onEditRateData"));
        var index = event.target.name;
        var rateRecordList = component.get("v.rateRecordList");
        var quoteRecord = component.get("v.quoteRecord");

        if( rateRecordList.length > 0 ){
            var rateObj = rateRecordList[parseInt(index)];
        
            component.set("v.rateQuoteRecord", Object.assign({}, quoteRecord));
            component.set("v.rateRecord", Object.assign({}, rateObj));
            component.set("v.rateValue",  rateObj.Total_Premium);
            helper.calculateDays(component, event, helper);
            component.set("v.isEditRate", true);
        }
    },
    
    editDriver : function(component, event, helper) {
        // $A.enqueueAction(component.get("v.onEditDriver"));
        var index = event.target.name;
        var drivers = component.get("v.drivers");

        var driverObject = drivers[ parseInt(index)];
        
        component.set("v.isOwner", (driverObject.Driver_Type__c == 'Owner'));
        component.set("v.driverObject", Object.assign({}, driverObject));

        component.set("v.isEditDriver", true);
    },
    
    updateWatercraftField : function (component, event, helper) {
        var name = event.getSource().get("v.name");
        var value = event.getParam("value");

        var quoteRecord = component.get("v.tempQuoteRecord");
        var watercraftRecord = component.get("v.tempWatercraftRecord");
        
        if(name == 'Year__c') {
            quoteRecord['Vehicle_Year__c'] = value;
        } else if(name == 'Make__c'){
            quoteRecord['Vehicle_Make__c'] = value;
        } else if(name == 'Model__c'){
            quoteRecord['Vehicle_Model__c'] = value;
        } else if(name == 'Value__c'){
            quoteRecord['Vehicle_Value__c'] = value;
        } else if(name == 'Type_of_Vessel__c'){
            quoteRecord[name] = value;

            quoteRecord['Vessel_Length__c'] = '';
            watercraftRecord['Vessel_Length__c'] = '';
            
            helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths');
        } else if(name == 'Vessel_Length__c'){
            quoteRecord[name] = value;
        }
        
        watercraftRecord[name] = value;
        
        component.set("v.tempQuoteRecord", quoteRecord);
        component.set("v.tempWatercraftRecord", watercraftRecord);
    },
    
    fetchRateDate :function (component, event, helper) {
        let name = event.getSource().get("v.name");
        
        let quoteRecord = component.get("v.rateQuoteRecord");
        let value = event.getParam("value");
        quoteRecord[name] =  value;
        component.set("v.rateQuoteRecord", quoteRecord);
        
        helper.calculateDays(component, event, helper);
        helper.getDataFromRateDataTable( component, event, helper );
    },
    
    highLiability : function (component, event, helper) {

        var quoteRecord = component.get("v.rateQuoteRecord");
        var liability = quoteRecord['Liability__c'];

        if(liability !== event.target.name) {
            if (liability === '200,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$100,000 / $300,000';
                quoteRecord['Property_Damage_Liability__c'] = '$100,000';
                quoteRecord['Liability__c'] = '400,000';
            } else if (liability === '400,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$250,000 / $500,000';
                quoteRecord['Property_Damage_Liability__c'] = '$250,000';
                quoteRecord['Liability__c'] = '750,000';
            }
            component.set("v.rateQuoteRecord", quoteRecord);

            helper.getDataFromRateDataTable( component, event, helper );
        }
    },
    
    lowLiability : function (component, event, helper) {

        var quoteRecord = component.get("v.rateQuoteRecord");
        var liability = quoteRecord['Liability__c'];

        if(liability !== event.target.name) {
            if (liability === '400,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$50,000 / $100,000';
                quoteRecord['Property_Damage_Liability__c'] = '$100,000';
                quoteRecord['Liability__c'] = '200,000';
            } else if (liability === '750,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$100,000 / $300,000';
                quoteRecord['Property_Damage_Liability__c'] = '$100,000';
                quoteRecord['Liability__c'] = '400,000';
            }
            component.set("v.rateQuoteRecord", quoteRecord);

            helper.getDataFromRateDataTable( component, event, helper );
        }
    },
    
    updateWatercraft : function(component, event, helper) {
        if (helper.validateInputFields(component, event, helper)) {
            helper.updateWatercraftHelper( component, event, helper );
        }
    },
    
    updateRateTable : function (component, event, helper) {
        if (helper.validateInputFields(component, event, helper)) {
            helper.updateRateHelper(component, event, helper);
        }
    },
    
    updateDriver : function(component, event, helper) {
        helper.updateDriverHelper( component, event, helper );
    },
})