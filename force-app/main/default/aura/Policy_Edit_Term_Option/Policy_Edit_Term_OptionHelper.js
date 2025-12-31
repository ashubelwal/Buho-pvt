({
	initilizeData : function( component, event, helper ) {
        try{
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            component.set("v.minDate", today);
            console.log("Ca log policy Edit old Quote ID", component.get("v.oldQuoteId"));
            var editPolicy = component.get("v.editPolicy");
            var myDate = new Date(component.get("v.serverDateTime"));
            var after15Date = myDate;
            after15Date.setMinutes( after15Date.getMinutes() - 15 );
            var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
            component.set("v.minTime", timeafter15);

            var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000Z');
            console.log('-time---'+time)
            //helper.fetchPicklist( component, event, helper , 'Quote__c', 'Time_Zone__c', 'v.timeZones');
            var policyType = component.get('v.policyType');
            if(  policyType != undefined && policyType != ''){
                helper.getDependentPicklistValues(component, event, helper, 'Policy_Type_picklist__c', 'Time_Zone__c', 'v.timeZones');
            }

            var quoteRecord = component.get("v.quoteRecord");
            console.log(JSON.stringify(component.get("v.quoteRecord"), null, 4));
            if (quoteRecord['Term__c'] === 'Annual(One Year)') {
                component.set("v.annaul", true);
            }else if( quoteRecord['Term__c'] === 'Semi-Annual(Half a Year)' ){
                component.set("v.semiAnnual", true);
            }
            
            if (quoteRecord["Medical__c"] == "6,000/40,000" || quoteRecord['Medical__c'] == '') {
                quoteRecord['Medical__c'] = '4,000/20,000';
            }
            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
            let todaysDate = new Date();
            var diffInDates = startDayForCoverage.getDate() - todaysDate.getDate();
            if( diffInDates != null && diffInDates != undefined && diffInDates >= 1){
                component.set("v.minTime", '00:00:00.000');
            } 

            /*
                territoryCoverages for edit
            */
            var territoryCoverages = [{
                'label' : 'Baja Sonora', 'value': 'Baja Sonora'
            },{
                'label' : 'Partial (US Adjacent)', 'value': 'Partial (US Adjacent)'
            },{
                'label' : 'Entire Mexico', 'value': 'Entire Mexico'
            }];
            component.set("v.territoryCoverages",territoryCoverages);
            
            var medicalOption;
            var liabilityOption;
            
            if(  policyType != undefined && policyType != 'Northbound' && policyType != 'Watercraft' && policyType != 'Driver License' && policyType != 'Automobile'){
                medicalOption = [{'label': '$2,000/$10,000', 'value': '2,000/10,000'},
                                 {'label': '$3,000/$15,000', 'value': '3,000/15,000'},
                                 {'label': '$4,000/$20,000', 'value': '4,000/20,000'},
                                 {'label': '$5,000/$25,000', 'value': '5,000/25,000'},
                                 {'label': '$10,000/$50,000', 'value': '10,000/50,000'}];
                
                liabilityOption = [{'label': '$100,000', 'value': '100,000'},
                                   {'label': '$200,000', 'value': '200,000'},
                                   {'label': '$300,000', 'value': '300,000'},
                                   {'label': '$500,000', 'value': '500,000'}];
                
                if (quoteRecord['Liability__c'] == "150,000") {
                    quoteRecord['Liability__c'] = '100,000';
                }
                
                if (quoteRecord['Liability__c'] == "400,000") {
                    quoteRecord['Liability__c'] = '300,000';
                }
            } else if (policyType != undefined && policyType == 'Automobile') {
                medicalOption = [{'label': '$2,000/$10,000', 'value': '2,000/10,000'},
                                 {'label': '$3,000/$15,000', 'value': '3,000/15,000'},
                                 {'label': '$4,000/$20,000', 'value': '4,000/20,000'},
                                 {'label': '$5,000/$25,000', 'value': '5,000/25,000'},
                                 {'label': '$10,000/$50,000', 'value': '10,000/50,000'},
                                 {'label': '$15,000/$75,000', 'value': '15,000/75,000'},
                                 {'label': '$20,000/$100,000', 'value': '20,000/100,000'}];
                
                liabilityOption = [{'label': '$100,000', 'value': '100,000'},
                                   {'label': '$200,000', 'value': '200,000'},
                                   {'label': '$300,000', 'value': '300,000'},
                                   {'label': '$500,000', 'value': '500,000'},
                                   {'label': '$1,000,000', 'value': '1,000,000'}];
                
                if (quoteRecord['Liability__c'] == '150,000') {
                    quoteRecord['Liability__c'] = '100,000';
                }
                
                if (quoteRecord['Liability__c'] == "400,000") {
                    quoteRecord['Liability__c'] = '300,000';
                }
            } else if(policyType != undefined && policyType == 'Watercraft'){
                medicalOption = [
                    {'label': '$50,000/$100,000', 'value': '50,000/100,000'},
                    {'label': '$100,000/$300,000', 'value': '100,000/300,000'},
                    {'label': '$250,000/$500,000', 'value': '250,000/500,000'}];
                
                liabilityOption = [{'label': '$200,000', 'value': '200,000'},
                                   {'label': '$400,000', 'value': '400,000'},
                                   {'label': '$750,000', 'value': '750,000'}];
                
				if (quoteRecord['Liability__c'] == '150,000') {
                    quoteRecord['Liability__c'] = '200,000';
                }
            } else if( policyType != undefined && policyType == 'Northbound' ){
                liabilityOption = [{'label': '$100,000', 'value': '100,000'},
                                   {'label': '$200,000', 'value': '200,000'},
                                   {'label': '$300,000', 'value': '300,000'}];
                
                if (quoteRecord['Liability__c'] == '150,000') {
                    quoteRecord['Liability__c'] = '100,000';
                }
                
                if (quoteRecord['Liability__c'] == "400,000") {
                    quoteRecord['Liability__c'] = '300,000';
                }
            } else if( policyType != undefined && policyType == 'Driver License' ){
                liabilityOption = [{'label': '$300,000', 'value': '300,000'},
                                   {'label': '$500,000', 'value': '500,000'}];
                
                if (quoteRecord['Liability__c'] == '150,000') {
                    quoteRecord['Liability__c'] = '300,000';
                }
                
                if (quoteRecord['Liability__c'] == "400,000") {
                    quoteRecord['Liability__c'] = '300,000';
                }
            }
            
            component.set("v.quoteRecord", quoteRecord);
            component.set("v.medicalOption",medicalOption);
            component.set("v.liabilityOption",liabilityOption);
            
            var yesNoOptions = [{'label':'Yes','value':'Yes'},{'label':'No','value':'No'}];
            component.set("v.yesNoOptions", yesNoOptions);
        }catch( ex ){
            console.log('--ex--',ex);
        }
		
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
                        /*if (component.get("v.policyType") === 'Watercraft') {
                            quoteRecord['Annual'] = component.get("v.annaul");
                        }*/
                        component.set("v.quoteRecord",quoteRecord);
                        console.log("dwadjjkfjfh ", JSON.stringify(quoteRecord, null, 4));

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

    createRenewQuoteHelper : function(component, event, helper, next){
        try{
            console.log("Inside Create renew Quote Helper");
            const action = component.get('c.createRenewQuoteAction');
            action.setParams({
                quoteRecord: component.get("v.quoteRecord"),
                oldQuoteId : component.get("v.oldQuoteId")
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        console.log('----response--',response);
                        var quoteRecord = component.get("v.quoteRecord");
                        var startTime = quoteRecord.Start_Time__c;
                        var endtime = quoteRecord.End_Time__c;
                        if( response.quoteId != undefined && response.quoteId != null ){
                            quoteRecord['Id'] = response.quoteId;
                            
                        }else if( response.quoteRecord != undefined && response.quoteRecord != null ){
                            quoteRecord = response.quoteRecord;
                            quoteRecord['Start_Time__c'] = startTime;
                            quoteRecord['End_Time__c'] = endtime;

                            if( response.driverRecords != undefined && response.driverRecords != null ){
                                component.set("v.drivers", response.driverRecords);
                            } 

                            /*if( response.watercraftRecords != undefined && response.watercraftRecords != null ){
                                component.set("v.watercrafts", response.watercraftRecords);
                                component.set("v.watercraftRecord", response.watercraftRecords[0]);
                            } */
                            if( response.vehicleObject != undefined && response.vehicleObject != null ){
                                component.set("v.vehicleRecord", response.vehicleObject);
                                
                            }
        
                            if( quoteRecord.Policy_Type_picklist__c  == 'Automobile' ||quoteRecord.Policy_Type_picklist__c  == 'RV' ){
                                if( response.transporates != undefined && response.transporates != null && response.transporates.length > 0){
                                    component.set("v.transporates", response.transporates);
                                }
                            }else{
                                if( response.towedObject != undefined && response.towedObject != null ){
                                    component.set("v.towedunitRecord", response.towedObject);
                                } 
                            }
                        }
                        if (component.get("v.policyType") === 'Watercraft' && component.get("v.annaul") ) {
                            //quoteRecord['Annual'] = component.get("v.annaul");
                        }
                        component.set("v.quoteRecord",quoteRecord);

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