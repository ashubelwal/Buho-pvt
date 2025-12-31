({
	doInit : function(component, event, helper) {
		helper.initilizeData(component, event, helper);
	},
    
    updatePolicyField : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        
        var policyRecord = component.get("v.policyRecord");
        if( name == 'Terms_of_Purchase_Confirmed__c' || name == 'Terms_of_Cancellation_Confirmed__c' ){
            var value = event.getParam("checked");
            policyRecord[name] = value;
        }else{
            var value = event.getParam("value");
            policyRecord[name] = value;
        }
        
        component.set("v.policyRecord", policyRecord);
    },
    
    updateContactField : function(component, event, helper) {
        var contObject = component.get("v.contactRecord");
        var name = event.getSource().get("v.name");
        if( name == 'Newsletter__c'|| name == 'Announcements__c' || name == 'Travel_Alerts__c' ){
            var value = event.getParam("checked");
            if(value){
                contObject[name] = 'Yes';
            }else{
                contObject[name] = 'No';
            }
        }else{
            var value = event.getParam("value");
            contObject[name] = value;
        }
        
        component.set("v.contactRecord", contObject);
    },
    
    onNextClick : function(component, event, helper) {
        var allVail = helper.validateInputFields(component, event, helper);
        if( allVail ){
            if (!component.get("v.isCommunityUser")) {
                let quoteRecord = component.get("v.quoteRecord");
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
                
                console.log("Selected Product Insurance Final Details page -->", JSON.stringify(selectedProduct, null, 4));
                window.dataLayer.push({ ecommerce: undefined });
                window.dataLayer.push({
                    event: "begin_checkout",
                    ecommerce: {
                        items: [selectedProduct]
                    }
                });
            }
            //helper.updatePolicyRecord(component, event, helper);
            $A.enqueueAction(component.get("v.onNextClick"));
        }
    }
})