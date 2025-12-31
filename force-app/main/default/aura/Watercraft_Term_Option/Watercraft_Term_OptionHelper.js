({
	initilizeData : function( component, event, helper ) {
		var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.minDate", today);
        
        var myDate = new Date();
        

        var after15Date = myDate;
        after15Date.setMinutes( after15Date.getMinutes() - 15 );
        var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
        var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
        
        var newTimeDiff = helper.getDaysDifferent(component, event, helper); 
        if( newTimeDiff != null && newTimeDiff != undefined && newTimeDiff != 0){
            component.set("v.minTime", '00:00:00.000Z');
        }else{
            component.set("v.minTime", timeafter15);
        }

        var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
        var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
        component.set("v.pstTime", (new Date()).getTime());


        var quoteRecord = component.get("v.quoteRecord");
        if( quoteRecord.Start_Time__c == undefined ){
            quoteRecord['Start_Time__c'] = time;
            quoteRecord['End_Time__c'] = time;
        }     
        component.set("v.quoteRecord",quoteRecord);

        //helper.getDependentPicklistValues(component, event, helper, 'Policy_Type_picklist__c', 'Time_Zone__c', 'v.timeZones');
    },
    
    getDaysDifferent : function(component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        if( startDayForCoverage != null && startDayForCoverage != undefined ){
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            let todaysDate = new Date();
            todaysDate = new Date (todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate());
            var Difference_In_Time = startDayForCoverage.getTime() - todaysDate.getTime();
            var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            component.set("v.days", Difference_In_Days);
            return Difference_In_Days;
        }
        return null;
    },

    calculateDays : function(component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        var difference_In_Days = 0;
        if (quoteRecord && quoteRecord.Start_Date_for_Coverage__c && quoteRecord.End_Date_for_Coverage__c) {
            var startDate = quoteRecord['Start_Date_for_Coverage__c'] + 'T00:00:00';
            var endDate = quoteRecord['End_Date_for_Coverage__c'] + 'T00:00:00';
            var date1 = new Date(startDate);
            var date2 = new Date(endDate);

            // To calculate the time difference of two dates 
            var Difference_In_Time = date2.getTime() - date1.getTime();

            // To calculate the no. of days between two dates 
            difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            component.set("v.difference_In_Days", difference_In_Days);
        }

        if( difference_In_Days != null && difference_In_Days != undefined){
            try{
                component.set("v.days", parseInt(difference_In_Days));
            }catch(ex){
                console.log(ex);
            }
        }
        
    },

    getDependentPicklistValues : function(component, event, helper, controllingFiled, dependentField, fieldAttr) {
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : component.get("v.quoteRecord"),
            'contrfieldApiName': controllingFiled,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var storeResponse = response.getReturnValue();
                var policyType = component.get('v.policyType');
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
            const action = component.get('c.handleQuoteAction');
            action.setParams({
                quoteRecord: component.get("v.quoteRecord"),
                annualTerm: component.get("v.annualTerm")
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        var quoteRecord = component.get("v.quoteRecord");
                        quoteRecord['Id']           = response.quote['Id'];
                        quoteRecord['Term_Days__c'] = response.quote['Term_Days__c'];
                        quoteRecord['Term__c']      = response.quote['Term__c'];
                        
                        component.set("v.quoteRecord",quoteRecord);

                        $A.enqueueAction(component.get("v.onNextClick"));
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