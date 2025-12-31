({
	initilizeData : function( component, event, helper ) {
        try{
            var vehicleType = 'Vehicle_Type__c';
            var policyType = component.get("v.policyType");
            var quoteRecord = component.get("v.quoteRecord");
            if( policyType && policyType.toLowerCase() != 'northbound'){
                vehicleType = 'Vehicle_Sub_type__c';
                if( quoteRecord.Is_there_a_driver_under_21__c == undefined){
                    quoteRecord['Is_there_a_driver_under_21__c'] = 'No';
                }
            }
            if( quoteRecord.Salvage_Vehicle__c == undefined){
                quoteRecord['Salvage_Vehicle__c'] = 'No';
            }
            if( quoteRecord.Vehicle_used_for_Business_Purposes__c == undefined){
                quoteRecord['Vehicle_used_for_Business_Purposes__c'] = false;
            }
            if( quoteRecord.Is_this_a_Rental_Vehicle__c == undefined){
                quoteRecord['Is_this_a_Rental_Vehicle__c'] = false;
            }
            component.set("v.quoteRecord",quoteRecord);
    
            //helper.fetchPicklist( component, event, helper , 'Quote__c', vehicleType, 'v.vehicleTypeQuoteOptions');
            console.log('---vehicleType--',vehicleType);
            if( vehicleType == 'Vehicle_Sub_type__c' ){
                helper.getDependentPicklistValues(component, event, helper, 'Vehicle_Type__c', 'Vehicle_Sub_type__c', 'v.vehicleTypeQuoteOptions');
            }else{
                helper.fetchPicklist( component, event, helper , 'Quote__c', vehicleType, 'v.vehicleTypeQuoteOptions');
            }
        }catch(ex){
            console.log('---exception--',ex);
        }
        
        
        var under21Options = [{'label':'Yes','value':'Yes'},{'label':'No','value':'No'}];
        component.set("v.under21Options", under21Options);
        
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
                 if( response.isExistUser){
                    //helper.showToast('Please login to create a policy.', 'error');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Please login to create a policy.',
                        messageTemplate: 'You already have an account {0}, If you have not logged into this new website before {1} to initiate your account, or check your email for Account Activation Link',
                        messageTemplateData: [{
                               	url: 'https://at.mexinsurance.com/login/',
                                label: 'Click here',
                            },
                            {
                                url: 'https://at.mexinsurance.com/s/activateaccount/',
                                label: 'Click here',
                            }
                        ],
                         duration:'10000'
                    });
                    toastEvent.fire();
                }else{ 
                    helper.handleVehicleQuote(component, event, helper, 'TermOptions');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    handleVehicleQuote : function( component, event, helper, next ) {
        const action = component.get('c.handleVehicleQuoteAction');
        console.log('---'+JSON.stringify(component.get("v.quoteRecord")));
        action.setParams({
            quoteRecord: component.get("v.quoteRecord"),
            leadRecord: JSON.stringify(component.get("v.leadRecord"))
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                console.log('---response----'+JSON.stringify(response));
                if( response.success){
                    var quoteRecord = component.get("v.quoteRecord");
                    quoteRecord['Id'] = response.quoteId;
                    component.set("v.quoteRecord",quoteRecord);

                    var leadRecord = component.get("v.leadRecord");
                    leadRecord['Id'] = response.leadId;
                    component.set("v.leadRecord",leadRecord);
                    //helper.showToast('Quote created successfully.', 'success');
                    helper.createVechicleRecord( component, event, helper, next);
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

    createVechicleRecord : function( component, event, helper, next ){
        var quoteRecord = component.get("v.quoteRecord");
        var vehicleRecord = component.get("v.vehicleRecord");
        console.log('---vehicleRecord--'+JSON.stringify(vehicleRecord));
        vehicleRecord['Value__c'] = quoteRecord.Vehicle_Value__c;
        if( vehicleRecord != undefined ) {
            vehicleRecord['Year__c'] = quoteRecord.Vehicle_Year__c;
            vehicleRecord['Make__c'] = quoteRecord.Vehicle_Make__c;
            vehicleRecord['Model__c'] = quoteRecord.Vehicle_Model__c;

            if( quoteRecord.Is_this_a_Rental_Vehicle__c != undefined && quoteRecord.Is_this_a_Rental_Vehicle__c == true  ){
                vehicleRecord['Rental__c'] = 'Yes';
            }else{
                vehicleRecord['Rental__c'] = 'No';
            }
            
            vehicleRecord['Salvage_Vehicle__c'] = (quoteRecord.Salvage_Vehicle__c == 'Yes'? true : false );


            var policyType = component.get("v.policyType");
            if( policyType != 'Northbound' && ( policyType == 'Motorcycle/Street Legal ATV' || policyType == 'Automobile' || policyType == 'RV' )){
                vehicleRecord['Vehicle_Type__c'] = quoteRecord.Vehicle_Sub_type__c;
            }else{
                if( quoteRecord.Vehicle_Type__c == 'Motorcycle/Street Legal ATV'){
                    vehicleRecord['Vehicle_Type__c'] = 'Street Legal ATV';
                }else if( quoteRecord.Vehicle_Type__c == 'Car/Truck/Auto' ) {
                    vehicleRecord['Vehicle_Type__c'] = 'Automobile/Sedan';
                }else{
                    vehicleRecord['Vehicle_Type__c'] = 'Automobile/Sedan';
                }
            }

            component.set("v.vehicleRecord",vehicleRecord);

            console.log('---createVechice--');
            const action = component.get("c.createVehicleNorthAction");
            action.setParams({  
                vehicleObject : component.get("v.vehicleRecord"),
                quoteId : component.get("v.quoteRecord").Id
            });

            action.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        var vehicleRecord = component.get("v.vehicleRecord");
                        vehicleRecord['Id'] = response.vehicleId;
                        component.set("v.vehicleRecord",vehicleRecord);

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
        }else{
            component.set("v.vehicleRecord",vehicleRecord);
            if( next != null && next != ''){
                $A.enqueueAction(component.get("v.onNextClick"));
            }
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
                var responses = response.getReturnValue();
                var policyType = component.get('v.policyType');
                console.log('--policyType--'+policyType);
                var filterOption = [];
                responses.forEach(function(item){
                    if( policyType && policyType.toLowerCase() == 'northbound' && item.value != 'Watercraft'
                        && item.value != 'RV' && item.value != 'Driver License' ){
                        filterOption.push(item);
                    }else if( policyType && ( policyType.toLowerCase() == 'automobile' 
                             || policyType.toLowerCase() == 'rv' 
                                             || policyType.toLowerCase() == 'motorcycle/street legal atv')
                             && item.value != 'Watercraft' ){
                        filterOption.push(item);
                    }
                });
                component.set(fieldAttr, filterOption);
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

    getVehicleMakes : function( component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        var action = component.get("c.getMakes");
        action.setParams({
            'year' : quoteRecord.Vehicle_Year__c
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('---getVehicleMakes--',result);
                if( result != undefined && result != null ){
                   component.set("v.vehicleMakes", result);
                   component.set("v.disableMake", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getVehicleModels : function( component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        var action = component.get("c.getModels");
        action.setParams({
            'year' : quoteRecord.Vehicle_Year__c,
            'make' : component.get("v.vehicleMake")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if( result != undefined && result != null ){
                    component.set("v.vehicleModels", result);
                    component.set("v.disableModel", false);
                }
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
                var vehicleType = component.get("v.policyType");
                if( vehicleType == 'Automobile'){
                    vehicleType = 'Car/Truck/Auto';
                }
                console.log('--storeResponse----',storeResponse);
                console.log('--vehicleType----'+vehicleType);
                if(vehicleType != null && storeResponse && storeResponse[vehicleType.trim()] != null ){
                    var options = [];
                    storeResponse[vehicleType].forEach(function(item){
                        /**logic here !*/
                        options.push({
                            'label':item,
                            'value':item
                        })
                    });
                    console.log('--options----',options);
                    component.set(fieldAttr, options);
                    if( options && options.length == 1){
                        var quoteRecord = component.get("v.quoteRecord");
                        quoteRecord['Vehicle_Sub_type__c'] = options[0].value;
                        component.set("v.quoteRecord",quoteRecord);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    validateInputFields : function(component, event, helper){
        var allValid = true; 
        try{
            allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }catch(ex){
            
        }
        return allValid;
    },

    getLoginUserVehiclesHelper : function(component, event, helper){
        var action = component.get("c.getCurrentUserVehicles");
        action.setParams({
            'policyType' : component.get("v.policyType")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result ', result);
                if( result != undefined && result != null ){
                    var loginUserVechicles = [{'value': '', 'label': '--None--'}];
                    result.forEach( function(item){
                        let label = item.Make__c+' '+item.Model__c +' '+item.Year__c+ ' - '+(item.Vin__c != undefined ? item.Vin__c : '')+'';
                        loginUserVechicles.push({'value': item.Id, 'label': label });
                    });
                    component.set("v.loginUserVehicleOption", loginUserVechicles);
                    component.set("v.loginUserVehicles", result);
                    
                }
            }
        });
        $A.enqueueAction(action);
    },

    checkRateExistHelper : function(component, event, helper){
        var action = component.get("c.checkRateTableExist");
        action.setParams({
            'vehicleValue' : component.get("v.quoteRecord").Vehicle_Value__c,
            'mainvehicleType' : component.get("v.policyType")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('--checkRateTableExist----'+result);
                if( result != undefined && result != null && result == true){
                    component.set("v.RestrictliabiltyOnly", true);
                    $A.get('e.force:showToast').setParams({
                        type: 'error',
                        message: 'We cannot offer coverage online for that value. Please continue with a liability only quote, adjust your value, or call us for manual underwriting approval (858) 663-6453.',
                      }).fire();
                }else{ 
                    component.set("v.liabiltyOnly", false);
                    component.set("v.RestrictliabiltyOnly", false);

                    var allValid = helper.validateInputFields(component, event, helper);
                    var newSectionOpen = component.get("v.newSectionOpen");
                    var vehicleRecord = component.get("v.vehicleRecord");
                    var iscommunityUser = component.get("v.iscommunityUser");
                    if( allValid && newSectionOpen ){
                        if( iscommunityUser != undefined && !iscommunityUser ){
                            helper.checkAllreadyUser(component, event, helper);
                        }else{
                            helper.handleVehicleQuote(component, event, helper, 'TermOptions');
                        }
                    }else if( vehicleRecord.Id != null ){
                        if( iscommunityUser != undefined && !iscommunityUser ){
                            helper.checkAllreadyUser(component, event, helper);
                        }else{
                            helper.handleVehicleQuote(component, event, helper, 'TermOptions');
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})