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
            if (!component.get("v.communityUser")) {
                let quoteRecord = component.get("v.quoteRecord");
                let selectedProduct = {};
                selectedProduct.item_name = "Watercraft";
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
                
                console.log("Selected Product Insurance Final Details page --> ", JSON.stringify(selectedProduct, null, 4));
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