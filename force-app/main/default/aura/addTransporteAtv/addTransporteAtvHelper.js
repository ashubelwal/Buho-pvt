({
    initilizeData : function(component, event, helper) {
        let towedunitRecord = component.get("v.towedunitRecord");
         console.log("CA log towedunitRecord "+ JSON.stringify(towedunitRecord, null, 4));
        
        console.log("CA log addtransportaive call intilize function "+ component.get("v.fieldShowForBoat"));
        helper.fetchPicklist( component, event, helper , 'Quote__c', 'Type_of_Vessel__c', 'v.vesselTypes');
  
         console.log("CA log towedunitRecord 222"+ JSON.stringify(towedunitRecord, null, 4));
    },
    fetchPicklist : function( component, event, helper, objectApiName, fieldApi, fieldAttr) {
        console.log("CA log addtransportaive call intilize function fetchPicklistForBoat");
        var action = component.get("c.getBoatPicklistValues");
        console.log("Action :" + action);
        action.setParams({
            'objectApiName' : objectApiName,
            'fieldApiName' : fieldApi
        }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("response : "+ JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                console.log(JSON.parse(JSON.stringify(response.getReturnValue())));
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getDependentPicklistValues : function(component, event, helper, controllingField, dependentField, fieldAttr, updateQuote) {
        var action = component.get("c.getBoatDependentMap");
        var quoteRecord = component.get("v.quoteRecord");
        let towedunitRecord = component.get("v.towedunitRecord");
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
                var vesselType = towedunitRecord['Type_of_Vessel__c'];
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
                     component.set('v.fieldShowForBoat', false);
                }
            }

            if (updateQuote) {
                component.set("v.quoteRecord", quoteRecord);
            }
        });
        $A.enqueueAction(action);
    },
    
 
})