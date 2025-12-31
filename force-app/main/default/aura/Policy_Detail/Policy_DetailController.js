({
	doInit : function(component, event, helper) {
		var policyMapList = component.get("v.policyMapList");
		var policyIds = [];
		var userExist = false;
		console.log('--policyMapList---'+policyMapList);

        if (!component.get("v.iscommunityUser")) {
            let act = component.get("c.getPolicyDetails");
            act.setParams({ 'quoteIds': JSON.stringify(component.get("v.quoteIds")) });
            act.setCallback(this, function(res) {
                if (res.getState() == 'SUCCESS') {
                    console.log("Res ---> ", JSON.stringify(res.getReturnValue()));
                    let result = JSON.parse(res.getReturnValue());
                    let quoteRecord = component.get("v.quoteRecord");
                    let selectedProduct = {};
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

                    console.log("Selected Product Policy Purchase page -->", JSON.stringify(selectedProduct, null, 4));
                    window.dataLayer.push({ ecommerce: undefined });
                    window.dataLayer.push({
                        event: "purchase",
                        ecommerce: {
                            transaction_id: result[0].Id,
                            affiliation: "",
                            value: result[0].Amount__c,
                            tax: result[0].Tax_Iva__c,
                            shipping: "",
                            currency: "USD",
                            coupon: "",
                            items: [selectedProduct]
                        }
                    });
                } else {
                    console.log("Error");
                }
            });
            $A.enqueueAction(act);
        }

		policyMapList.forEach(function(item){
			policyIds.push( item.Id );
			if( item.isUserExist != undefined && item.isUserExist == true ){
				userExist = true;
			}
		});
		console.log('--userExist---'+userExist);
		component.set("v.userExist",userExist);

		console.log('--policyIds---',policyIds);
		
		if( policyIds  && policyIds.length > 0 ){
			var action = component.get("c.sendEmailDocumentAction");
        
			action.setParams({ 'policyIds' : JSON.stringify(policyIds) }); 
			
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$A.get('e.force:showToast').setParams({
						type: 'success',
						message: 'Email sent successfully!'
					}).fire();
				}
			});
			$A.enqueueAction(action);
		}
    },

	gotohome : function(component, event, helper) {
		window.open( $A.get("$Label.c.community_Url") , "_blank")
	},	

	sendEmailDocument : function(component, event, helper) {
		var policyMapList = component.get("v.policyMapList");
		var policyIds = [];
		policyMapList.forEach(function(item){
			policyIds.push( item.Id );
		});
		
		if( policyIds  && policyIds.length > 0 ){
			var action = component.get("c.sendEmailDocumentAction");
        
			action.setParams({ 'policyIds' : JSON.stringify(policyIds) }); 
			
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$A.get('e.force:showToast').setParams({
						type: 'success',
						message: 'Email sent successfully!'
					}).fire();
				}
			});
			$A.enqueueAction(action);
		}
	},
    
    closeTabAction : function(component, event, helper) {
		console.log('---closeTab--');
		window.close();
        
    },
})