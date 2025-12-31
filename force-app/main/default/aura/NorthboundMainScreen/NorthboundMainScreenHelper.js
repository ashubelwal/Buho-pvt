({
	initilizeData : function( component, event, helper ) {
        try{
            var driverOptions = component.get("v.driverOptions");
            if( $A.util.isEmpty(driverOptions) ){
                helper.fetchPicklist( component, event, helper , 'Driver__c', 'Driver_Type__c', 'v.driverOptions');
            }
            var vehicleTypeOptions = component.get("v.vehicleTypeOptions");
            if( $A.util.isEmpty(vehicleTypeOptions) ){
                helper.fetchPicklist( component, event, helper , 'Vehicle__c', 'Vehicle_Type__c', 'v.vehicleTypeOptions');
            }

            helper.checkUrlForAffiliateNumber(component, event, helper);
            helper.checkUrlForQuoteId( component, event, helper );
            helper.fetchPolicyData( component, event, helper );
        }catch(ex){
            console.log('*******ex****'+ex);
        }
    },

    handleBackHelper : function(component, event, helper){
        var quoteObject = component.get("v.quoteRecord");
        var vehicleObject = component.get("v.vehicleRecord");
        
        var screenName = component.get("v.screenName");
        if( screenName == 'InsuranceToday'){
        }else if( screenName == 'WhereInsurance'){
        }else if( screenName == 'UserInfo'){
        }else if( screenName == 'VehicleOptions'){
            component.set("v.screenName", 'UserInfo');
        }else if( screenName == 'TermOptions'){
            component.set("v.screenName", 'VehicleOptions');
        }else if( screenName == 'TowningAnything'){
            component.set("v.screenName", 'TermOptions');
        }else if( screenName == 'TowningInfo'){
            component.set("v.screenName", 'TowningAnything');
        }else if( screenName == 'QuickQuote'){
             if( quoteObject && quoteObject.Towed_Unit__c && quoteObject.Towed_Unit__c == 'Yes' ){
                 component.set("v.screenName", 'TowningInfo');
             }else{
                 component.set("v.screenName", 'TowningAnything');
             }
             //component.set("v.screenName", 'TermOptions');
        }else if( screenName == 'ReviewVehicle'){
             component.set("v.screenName", 'QuickQuote');
        }else if( screenName == 'CompanyInfo'){
            component.set("v.screenName", 'ReviewVehicle');
        }else if( screenName == 'LienHolder'){
            if( vehicleObject.Is_the_vehicle_registered_to_a_business__c ||  vehicleObject.Is_the_vehicle_used_for_business_purpose__c){
                component.set("v.screenName", 'CompanyInfo');
            }else{
                component.set("v.screenName", 'ReviewVehicle');
            }
        }else if( screenName == 'RegisteredVehicle'){
            if( vehicleObject.Is_Lienholder__c ){
                component.set("v.screenName", 'LienHolder');
            }else if( vehicleObject.Is_the_vehicle_registered_to_a_business__c ||  vehicleObject.Is_the_vehicle_used_for_business_purpose__c){
                component.set("v.screenName", 'CompanyInfo');
            }else{
                component.set("v.screenName", 'ReviewVehicle');
            }
        }else if( screenName == 'AnotherVehicle'){
            component.set("v.screenName", 'RegisteredVehicle');
        }else if( screenName == 'QuoteDetail'){
            //component.set("v.screenName", 'AnotherVehicle');
            component.set("v.screenName", 'RegisteredVehicle');
        }else if( screenName == 'InsuranceFinalDetail'){
            component.set("v.screenName", 'QuoteDetail');
        }else if( screenName == 'PaymentDetail'){
            component.set("v.screenName", 'InsuranceFinalDetail');
        }else if( screenName == 'PolicyDetail'){
        }
    },

    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            mode: 'sticky',
            type: type,
            message: message
        }).fire();
    },
    
    updateScreen : function(component, event, helper, next){
    	component.set("v.screenName", next);
    },

    fetchPolicyData : function(component, event, helper){
        const action = component.get("c.initialize");

        action.setParams({
            'policyType' : 'NothBound',
            'quoteId' :  component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var quoteRecord = component.get("v.quoteRecord");
                var response = JSON.parse(response.getReturnValue());
                component.set("v.communityUser", response.loginUser);
                

                if( response && response.quoteRecord){
                    var quoteRecord = response.quoteRecord;
                    delete quoteRecord['attributes'];

                    component.set("v.quoteRecord", quoteRecord );
                    component.set("v.screenName", 'QuickQuote');
                } else {
                    quoteRecord['Underwriter__c'] = 'Chubb';
                    quoteRecord['Coverage__c'] = 'Liability';
                    quoteRecord['Territory_Coverage__c'] = 'PARTIAL(US ADJACENT)';
                    quoteRecord['Medical__c'] = '5,000/25,000';
                    quoteRecord['Territory__c'] = 'Northbound';
                    quoteRecord['Policy_Type_picklist__c'] = 'Northbound';
                    component.set("v.quoteRecord",quoteRecord);
                }
                if( response && response.email && response.email != null ){
                    var leadRecord = component.get("v.leadRecord");
                    leadRecord['Email'] = response.email;
                    component.set("v.leadRecord", leadRecord);
                }
                if( response && response.driverAsUser && response.driverAsUser != null ){
                    var driverRecord = component.get("v.driverRecord");
                    var driverAsUser = response.driverAsUser;
                    driverRecord['First_Name__c'] = driverAsUser.FirstName;
                    driverRecord['Last_Name__c'] = driverAsUser.LastName;
                    driverRecord['Email__c'] = driverAsUser.Email;
                    driverRecord['Dob__c'] = driverAsUser.Contact.Date_of_Birth__c;
                    quoteRecord['Date_of_Birth__c'] = driverAsUser.Contact.Date_of_Birth__c;
                    driverRecord['Phone__c'] = driverAsUser.Phone;
                    driverRecord['Address__c'] = driverAsUser.Contact.MailingStreet;
                    driverRecord['City__c'] = driverAsUser.Contact.MailingCity;
                    driverRecord['State_Province__c'] = driverAsUser.Contact.MailingState;
                    driverRecord['Postal_Code__c'] = driverAsUser.Contact.MailingPostalCode;
                    driverRecord['Country__c'] = driverAsUser.Contact.MailingCountry;

                    component.set("v.driverRecord", driverRecord);
                }

                let iscommunity = component.get("v.communityUser");
                if(!iscommunity){
                    component.set("v.screenName", 'UserInfo');
                }else{
                    component.set("v.screenName", 'VehicleOptions');
                }
                //component.set("v.screenName", 'QuoteDetail');
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    createTransactionRecord : function(component, event, helper, nextScreen){
        var rateRecordList =  component.get("v.rateRecordList");
        var affiliateAccount =  component.get("v.affiliateAccount");
        const action = component.get("c.createTransactionAction");

        action.setParams({
            rateRecordList : JSON.stringify(rateRecordList),
            affiliateAccountString : JSON.stringify(affiliateAccount)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    //helper.showToast('Policy Created Successfully', 'success');
                    
                    helper.updatePolicyRecord( component, event, helper, nextScreen );
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    updatePolicyRecord : function(component, event, helper, nextScreen) {
        var rateRecordList =  component.get("v.rateRecordList");
        
        var leadList = [];
        rateRecordList.forEach(function(item){
            leadList.push(item.leadId);
        });
        
        const action = component.get("c.updatePolicyAction");
        action.setParams({  
            contactRecord : component.get("v.contactRecord"),
            policyRecord : component.get("v.policyRecord"),
            leadIds : JSON.stringify(leadList),
            quoteIds : JSON.stringify(component.get('v.quoteIds'))
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    component.set("v.policyMapList", response.policyMapList);
                    
                    if( nextScreen != null && nextScreen.trim() != '' ){
                        helper.updateScreen(component, event, helper, nextScreen);
                    }

                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    
    handleNextHelper : function(component, event, helper){
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var vehicleRecord = component.get("v.vehicleRecord");
            
            var screenName = component.get("v.screenName");
            var nextScreen;
            if( screenName == 'InsuranceToday'){
                
            }else if( screenName == 'WhereInsurance'){
            }else if(screenName == 'UserInfo'){
                helper.updateScreen(component, event, helper, 'VehicleOptions');
            }else if( screenName == 'VehicleOptions'){
                helper.updateScreen(component, event, helper, 'TermOptions');
            }else if( screenName == 'TermOptions'){
                helper.updateScreen(component, event, helper, 'TowningAnything');
                //helper.updateScreen(component, event, helper, 'QuickQuote');
            }else if( screenName == 'TowningAnything'){
                if( quoteRecord && quoteRecord.Towed_Unit__c && quoteRecord.Towed_Unit__c == 'Yes' ){
                    nextScreen = 'TowningInfo'; 
                }else{
                    nextScreen = 'QuickQuote'; 
                }
                helper.updateScreen(component, event, helper, nextScreen);
                
            }else if( screenName == 'TowningInfo'){
                helper.updateScreen(component, event, helper, 'QuickQuote');
            }else if( screenName == 'QuickQuote'){
                var rateRecordList = component.get("v.rateRecordList");
                if( rateRecordList && rateRecordList.length > 0 ){
                    var checkAlreadyRateTable = rateRecordList.filter(function(item){
                        return item.quoteId == quoteRecord.Id;
                    });
                    
                    var rateRecord = component.get("v.rateRecord")
                    if( checkAlreadyRateTable && checkAlreadyRateTable.length == 0){
                        rateRecordList.push(rateRecord);
                        component.set("v.rateRecordList", rateRecordList);
                    }
                }else{
                    rateRecordList.push(component.get("v.rateRecord"));
                    component.set("v.rateRecordList", rateRecordList);
                }

                helper.updateScreen(component, event, helper, 'ReviewVehicle');

            }else if( screenName == 'ReviewVehicle'){
                nextScreen = 'RegisteredVehicle';
                if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                    nextScreen = 'CompanyInfo';
                }else if( vehicleRecord.Is_Lienholder__c ){
                    nextScreen = 'LienHolder';
                }
                
                helper.updateScreen(component, event, helper, nextScreen);

            }else if( screenName == 'CompanyInfo'){
                nextScreen = 'RegisteredVehicle';
                if( vehicleRecord.Is_Lienholder__c ){
                    nextScreen = 'LienHolder';
                }
                helper.updateScreen(component, event, helper, nextScreen );
            }else if( screenName == 'LienHolder'){
                helper.updateScreen(component, event, helper, 'RegisteredVehicle' );
            }else if( screenName == 'RegisteredVehicle'){
                //nextScreen = 'AnotherVehicle';
                nextScreen = 'QuoteDetail';
                var quoteIds = component.get("v.quoteIds");
                if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                    quoteIds.push( quoteRecord.Id );
                }
                component.set("v.quoteIds", quoteIds); 

                helper.updateScreen(component, event, helper, nextScreen);
            }else if( screenName == 'AnotherVehicle'){
                var anotherVehicle = component.get("v.anotherVehicle");
                if( anotherVehicle == 'Yes' ){
                    nextScreen = 'VehicleOptions';
                    var countVehicle = parseInt(component.get("v.countVehicle"));
                    countVehicle += 1;
                    component.set("v.countVehicle", countVehicle)
                    component.set("v.anotherVehicle", 'No');
                    
                    component.set("v.quoteRecord", { 'sobjectType': 'Quote__c'});
                    component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c'});
                    component.set("v.vehicleRecord", { 'sobjectType': 'Vehicle__c'});
                    //component.set("v.leadRecord", { 'sobjectType': 'Lead'});
                    component.set("v.rateRecord", { 'sobjectType': 'Rate_Table__c'});
                    component.set("v.driverRecord", { 'sobjectType': 'Driver__c'});
                    helper.fetchPolicyData( component, event, helper );

                }else{
                    nextScreen = 'QuoteDetail';
                }

                var quoteIds = component.get("v.quoteIds");
                if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                    quoteIds.push( quoteRecord.Id );
                }
                component.set("v.quoteIds", quoteIds);
                
                helper.updateScreen(component, event, helper, nextScreen);
                
            }else if( screenName == 'QuoteDetail'){
                nextScreen = 'InsuranceFinalDetail';
                helper.updateScreen(component, event, helper, nextScreen);
                
            }else if( screenName == 'InsuranceFinalDetail'){
                nextScreen = 'PaymentDetail';
                helper.updateScreen(component, event, helper, nextScreen);
                
            }else if( screenName == 'PaymentDetail'){
                nextScreen = 'PolicyDetail';
                helper.createTransactionRecord(component, event, helper, nextScreen);
            }else if( screenName == 'PolicyDetail'){
            }
        }catch(ex){
            console.log('exce---'+ex);
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

    checkUrlForAffiliateNumber : function(component, event, helper) {
        let affiliateNumber = helper.getUrlParameter('c__aid');

        if (affiliateNumber != "") {
            component.set("v.affiliateNumber", affiliateNumber);
            helper.fetchAffiliateAccount(component, event, helper);
        }
    },

    checkUrlForQuoteId : function(component, event, helper) {
        let quoteId = helper.getUrlParameter('c__ID');

        if (quoteId != "") {
            component.set("v.recordId", quoteId);
        }
    },

    getUrlParameter : function(param) {
        let sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&');

        for (let i = 0; i < sURLVariables.length; i++) {
            let sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === param) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }

        return "";
    },

    fetchAffiliateAccount : function(component, event, helper){
        const action = component.get("c.retrieveAffiliateAccount");

        action.setParams({
            'affiliateNumber' :  component.get("v.affiliateNumber")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var account = response.getReturnValue();
                if( account ){
                    component.set("v.affiliateAccount", account);
                }            
            } else {
                console.log(response);
            }
        });

        $A.enqueueAction(action);
    },
})