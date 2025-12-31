({
    initilizeData : function( component, event, helper ) {
        var quoteRecord = component.get("v.quoteRecord");

        console.log("CA log quoteRecords : "+ JSON.stringify(quoteRecord));
        var watercraftRecord = component.get("v.watercraftRecord");
        
        watercraftRecord['Year__c']           = quoteRecord.Vehicle_Year__c;
        watercraftRecord['Make__c']           = quoteRecord.Vehicle_Make__c;
        watercraftRecord['Model__c']          = quoteRecord.Vehicle_Model__c;
        watercraftRecord['Value__c']          = quoteRecord.Vehicle_Value__c;
        watercraftRecord['Type_of_Vessel__c'] = quoteRecord.Type_of_Vessel__c;
        watercraftRecord['Vessel_Length__c']  = quoteRecord.Vessel_Length__c;

        component.set("v.watercraftRecord", watercraftRecord);
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
            selectedProduct.item_list_name = "Watercraft Quote page";
            selectedProduct.quantity = 1;
            selectedProduct.index = 1;
            
            console.log("Selected Product Review Watercraft --> ", JSON.stringify(selectedProduct, null, 4));
            window.dataLayer.push({ ecommerce: undefined });
            window.dataLayer.push({
                event: "view_item",
                ecommerce: {
                    items: [selectedProduct]
                }
            });
        }
        
        helper.fetchPicklist( component, event, helper , 'Quote__c', 'Type_of_Vessel__c', 'v.vesselTypes');
        helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths');
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
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getDependentPicklistValues : function(component, event, helper, controllingField, dependentField, fieldAttr) {
        var action = component.get("c.getDependentMap");
        var quoteRecord = component.get("v.quoteRecord");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : quoteRecord,
            'contrfieldApiName': controllingField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var storeResponse = response.getReturnValue();
                console.log('--storeResponse----'+JSON.stringify(storeResponse));
                var vesselType = quoteRecord['Type_of_Vessel__c'];
                console.log('--vesselType----'+JSON.stringify(vesselType));
                if(vesselType != null && storeResponse && storeResponse[vesselType] != null ){
                    var options = [];
                    storeResponse[vesselType].forEach(function(item){
                        /**logic here !*/
                        options.push({
                            'label':item,
                            'value':item
                        })
                    });
                    component.set(fieldAttr, options);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleVehicleDetail : function( component, event, helper ){
        const action = component.get("c.createWatercraftAction");
        action.setParams({  
            watercraftObject : component.get("v.watercraftRecord"),
            quoteObject : component.get("v.quoteRecord"),
            leadId : component.get("v.leadRecord")["Id"]
        });

        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    var watercraftRecord = component.get("v.watercraftRecord");
                    watercraftRecord['Id'] = response.watercraftId;
                    component.set("v.watercraftRecord", watercraftRecord);

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