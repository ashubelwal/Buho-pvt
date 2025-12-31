({
    initilizeData : function( component, event, helper ) {
        try{

                var policyType = component.get('v.policyType');
                if(  policyType != undefined && policyType != ''){
                    helper.getDependentPicklistValues(component, event, helper, 'Policy_Type_picklist__c', 'Time_Zone__c', 'v.timeZones');
                }
        }catch( ex ){
            console.log('--ex--',ex);
        }
        
    },
    
    msToTime : function(component, event, helper, s){
        //&& !String(scheduleData.Start_Time).includes(':')
        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;
        hrs = hrs < 10 ? '0' + hrs : hrs;
        mins = mins < 10 ? '0' + mins : mins;
        return hrs+':' + mins + ':00.000Z';
    },
    
    getDaysDifferent : function(component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
        if( startDayForCoverage != null && startDayForCoverage != undefined ){
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            let todaysDate = new Date(component.get("v.serverDateTime"));
            todaysDate = new Date (todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate());
            
            var Difference_In_Time = startDayForCoverage.getTime() - todaysDate.getTime();
            var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            return Difference_In_Days;
        }
        return null;
    },

    getDependentPicklistValues : function(component, event, helper, controllingFiled, dependentField, fieldAttr) {
        console.log('time zone'+fieldAttr);
        //timeZones
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : { 'sobjectType': 'Quote__c'},
            'contrfieldApiName': controllingFiled,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var storeResponse = response.getReturnValue();
                //console.log('--storeResponse----'+JSON.stringify(storeResponse));
                var policyType = component.get('v.policyType');
                console.log('--policyType----'+policyType);
                console.log('--pstoreResponse[policyType]olicyType----'+JSON.stringify(storeResponse[policyType]));
                if(policyType != null && storeResponse && storeResponse[policyType] != null ){
                    var options = [];
                    storeResponse[policyType].forEach(function(item){
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
    
    updateQuoteHelper : function( component, event, helper, next ) {
        try{
            const action = component.get('c.handleQuocteAction');
            action.setParams({
                quoteRecord: component.get("v.quoteRecord")
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        console.log('---response--',response);
                        
                        var quoteRecord = component.get("v.quoteRecord");
                        quoteRecord['Id'] = response.quoteId;
                        if (component.get("v.policyType") === 'Watercraft') {
                            quoteRecord['Annual'] = component.get("v.annaul");
                        }
                        component.set("v.quoteRecord",quoteRecord);
                        
                        // helper.showToast('Quote updated successfully.', 'success');
                        
                        if( next != null && next != ''){
                            $A.enqueueAction(component.get("v.onNextClick"));
                        }
                        
                    }else{
                        helper.showToast(response.message, 'error');
                    }
                } else {
                    helper.showToast(response.getError(), 'error');
                }
            });
            $A.enqueueAction(action);
            
        }catch(ex){
            console.log('--ex---+');
            console.log(ex);
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
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    /*
        this method is used to validate field
    */
    validateInputFields : function(component, event, helper){
        
        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        return allValid;
    },
    
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
    
})