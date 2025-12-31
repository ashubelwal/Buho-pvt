({
	initilizeData : function( component, event, helper ) {
        let quoteRecord = component.get("v.quoteRecord");
        helper.setFieldRestrictions(component, event, helper);
        helper.fetchPicklist( component, event, helper , 'Quote__c', 'Type_of_Vessel__c', 'v.vesselTypes');
        if (quoteRecord['Type_of_Vessel__c'] != '' && quoteRecord['Type_of_Vessel__c'] != null && quoteRecord['Type_of_Vessel__c'] != undefined) {
            helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths', true);
        } else {
            component.set("v.quoteRecord", quoteRecord);
        }

        var communityUser = component.get("v.communityUser");
        console.log('---communityUser---'+communityUser);
        if( communityUser != undefined && communityUser == true ){
            component.set("v.newSectionOpen", true);
            helper.getCurrentUserAllWaterCraft( component, event, helper );
        }else{
            component.set("v.newSectionOpen", true);
        }

        var yesNoOptions = [{'label':'Yes','value':'Yes'},{'label':'No','value':'No'}];
        component.set("v.yesNoOptions", yesNoOptions);
	},

    setFieldRestrictions : function(component, event, helper) {
        let currentYear = (new Date()).getFullYear();
        let minYear = currentYear - 40;

        let minBirthdate = new Date();
        let maxBirthdate = new Date();
        minBirthdate.setFullYear(minBirthdate.getFullYear() - 150);
        maxBirthdate.setFullYear(maxBirthdate.getFullYear() - 16);

        component.set("v.minYear", minYear);
        component.set("v.maxYear", currentYear);

        component.set("v.minBirthDate", minBirthdate.toISOString().split('T')[0]);
        component.set("v.maxBirthDate", maxBirthdate.toISOString().split('T')[0]);
    },

    checkAllreadyUser : function( component, event, helper){
        const action = component.get('c.checkalreadyExistUserAction');
        var leadRecord = component.get("v.leadRecord");
        action.setParams({
            emailAdder: leadRecord.Email,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                console.log("CA log checkAllreadyUser -->"+ JSON.stringify(response, null, 4));
                //helper.handleClickNext(component, event, helper, 'TermOptions');
                  if( response.isExistUser){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Please login to create a policy.',
                        messageTemplate: 'You already have an account,  {0}!  If you have not logged into this new website before, {1} to initiate your account.',
                        messageTemplateData: [{
                                url: 'https://at.mexinsurance.com/login/',
                                label: 'Click here',
                            },
                                              {
                                url: 'https://at.mexinsurance.com/s/activateaccount',
                                label: 'Click here',
                            }
                        ],
                         duration:'5000'
                    });
                    toastEvent.fire();
                }else{
                    helper.handleClickNext(component, event, helper, 'TermOptions');
                } 
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    /*
     * objectApiName : ObjectName
     * fieldApi : filed Api name
     * fieldAttr : save data in cmp,
     * */
    fetchPicklist : function( component, event, helper, objectApiName, fieldApi, fieldAttr) {
        var action = component.get("c.getPicklistValues");
        
        action.setParams({
            'objectApiName' : objectApiName,
            'fieldApiName' : fieldApi
        }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.parse(JSON.stringify(response)));
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getDependentPicklistValues : function(component, event, helper, controllingField, dependentField, fieldAttr, updateQuote) {
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

            if (updateQuote) {
                component.set("v.quoteRecord", quoteRecord);
            }
        });
        $A.enqueueAction(action);
    },
     getVehicleYears : function( component, event, helper){
        var action = component.get("c.getYears");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('---getVehicleYears--',result);
                if( result != undefined && result != null ){
                    component.set("v.vehicleYears", result);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleClickNext : function( component, event, helper, next ) {
        helper.handleVehicleQuote(component, event, helper, next);
    },

    handleVehicleQuote : function( component, event, helper, next ) {
        console.log('handleVehicleQuote');
        const action = component.get('c.handleVehicleQuoteAction');
        
        console.log("Quote Record ", JSON.stringify(component.get("v.quoteRecord"), null, 4));
        console.log("lead Record ", JSON.stringify(component.get("v.leadRecord"), null, 4));
        
        action.setParams({
            quoteRecord: component.get("v.quoteRecord"),
            leadRecord: JSON.stringify(component.get("v.leadRecord"))
        });
        
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    var quoteRecord = component.get("v.quoteRecord");
                    quoteRecord['Id'] = response.quote['Id'];
                    quoteRecord['Contact__c'] = response.quote['Contact__c'];
                    quoteRecord['Account__c'] = response.quote['Account__c'];
                    component.set("v.quoteRecord",quoteRecord);

                    var leadRecord = component.get("v.leadRecord");
                    leadRecord['Id'] = response.leadId;
                    component.set("v.leadRecord",leadRecord);

                    $A.enqueueAction(component.get("v.onNextClick"));
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                console.log('---response----'+JSON.stringify(response));
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    validateInputFields: function (component, event, helper) {
        return component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    },

    getCurrentUserAllWaterCraft : function(component, event, helper) {
        const action = component.get("c.getCurrentUserWaterCraft");

        action.setCallback(this, function(response) {
            console.log('----response----'+JSON.stringify(response));
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                console.log("CA log response : "+ JSON.stringify(response, null, 4));
                
                
                    let loginUserWaterCraftOptions = [];
                    if (response != null || response != undefined) {
                        response.forEach( function(item){
                            let label = item.Make__c+' '+item.Model__c +' '+item.Year__c+ ' - '+item.VIN_Number__c+'';
                            loginUserWaterCraftOptions.push({'value': item.Id, 'label': label });
                        });
                        
                    }
                    console.log("CA log loginUserWaterCraftOptions : "+ JSON.stringify(loginUserWaterCraftOptions, null, 4));
                    component.set("v.loginUserWaterCraftOptions", loginUserWaterCraftOptions);
                    component.set("v.loginUserWaterCrafts", response);
                
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });

        $A.enqueueAction(action);
    },

    showToast: function (message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
})