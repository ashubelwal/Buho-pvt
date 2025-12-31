({
    initilizeData : function( component, event, helper ) {
        try{
            helper.checkUrlForQuoteId(component, event, helper);
            helper.fetchPolicyData( component, event, helper );
            helper.checkUrlForAffiliateNumber(component, event, helper);
            
            
        }catch(ex){
            console.log('*******ex****' + ex);
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
    fetchPicklist : function( component, event, helper, objectApiName, fieldApi, fieldAttr) {
        var action = component.get("c.getPicklistValues");
        
        action.setParams({  'objectApiName' : objectApiName,
                            'fieldApiName'  : fieldApi }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }, 

    fetchPolicyData : function(component, event, helper){
        const action = component.get("c.initializeFlow");
		
         action.setParams({
            'quoteId' :  component.get("v.recordId")
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === 'SUCCESS') {
                var response = JSON.parse(response.getReturnValue());
                console.log('response---' + JSON.stringify(response));
                
                var quoteRecord = component.get("v.quoteRecord");
                var leadRecord = component.get("v.leadRecord");

                leadRecord['Company']   = 'Watercraft Insurance';
                leadRecord['Status']    = 'New';
                
                if( response && response.email != null ){
                    leadRecord['Email'] = response.email;
                }
                
                if( response && response.dob != null ){
                    leadRecord['Date_of_Birth__c']  = response.dob;
                    quoteRecord['Date_of_Birth__c'] = response.dob;
                }

                component.set("v.communityUser", response.isCommunityUser);
                component.set("v.quoteRecord", quoteRecord);
                component.set("v.leadRecord", leadRecord);
                if( response && response.quoteRecord){
                    quoteRecord = response.quoteRecord;
                    delete quoteRecord['attributes'];

                    component.set("v.quoteRecord", quoteRecord );
                    component.set("v.screenName", 'QuickQuote');
                } else {
                    quoteRecord['Vehicle_Type__c']         = 'Watercraft';
                    quoteRecord['Vehicle_Sub_type__c']     = 'Watercraft';
                    quoteRecord['Underwriter__c']          = 'Chubb';
                    quoteRecord['Policy_Type_picklist__c'] = 'Watercraft';
                    quoteRecord['Quote_Status__c']         = 'Draft';
                    quoteRecord['Coverage__c']             = 'Liability';
                    
                    quoteRecord['Is_the_Maximum_Speed_more_than_50_mph__c'] = 'No';
                    quoteRecord['Is_the_owner_living_in_Mexico__c']         = 'No';
                    quoteRecord['Any_Boat_Operator_Under_22__c']            = 'No';
                    let iscommunity = component.get("v.communityUser");
                    if(!iscommunity){
                        component.set("v.screenName", 'UserInfo');
                    }else{
                        component.set("v.screenName", 'waterCraftDetail');
                    }
                }
            } else {
                console.log('--response---');
                // console.log(response);
                // helper.showToast(response.getError(), 'error');
            }
            //component.set("v.screenName", 'QuickQuote');
            
        });
        $A.enqueueAction(action);
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

        console.log('screenName', component.get("v.screenName"));
	},

    handleNextHelper : function(component, event, helper){
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var leadRecord = component.get("v.leadRecord");
            var watercraftRecord = component.get("v.watercraftRecord");
            
            var screenName = component.get("v.screenName");
            if (screenName == 'UserInfo') {
                helper.updateScreen(component, event, helper, 'waterCraftDetail');
            }else if( screenName == 'waterCraftDetail'){
                helper.updateScreen(component, event, helper, 'TermOptions');
            }else if( screenName == 'TermOptions'){
                helper.updateScreen(component, event, helper, 'QuickQuote');
            }else if( screenName == 'QuickQuote'){
                var rateRecordList = component.get("v.rateRecordList");
                var rateRecord = component.get("v.rateRecord");
                rateRecord['Package__c'] = component.get("v.quoteRecord")['Coverage__c'];
                component.set("v.rateRecord", rateRecord);

                if( rateRecordList && rateRecordList.length > 0 ){
                    var checkAlreadyRateTable = rateRecordList.filter(function(item){
                        return item.quoteId == quoteRecord.Id;
                    });

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
                helper.updateScreen(component, event, helper, 'RegisteredVehicle');
            }else if( screenName == 'RegisteredVehicle'){
                let quoteIds = component.get("v.quoteIds");
                if (quoteRecord && quoteRecord.Id && !quoteIds.includes(quoteRecord.Id)) {
                    quoteIds.push(quoteRecord.Id);
                }
                component.set("v.quoteIds", quoteIds);

                helper.updateScreen(component, event, helper, 'QuoteDetail');
            }else if( screenName == 'QuoteDetail'){
                helper.updateScreen(component, event, helper, 'InsuranceFinalDetail');
            }else if( screenName == 'InsuranceFinalDetail'){
                helper.updateScreen(component, event, helper, 'PaymentDetail');
            }else if( screenName == 'PaymentDetail'){
                helper.createTransactionRecord(component, event, helper);
            }else if( screenName == 'PolicyDetail'){
            }
        }catch(ex){
            console.log('exce---'+ex);
        }
    	
    },

    handleBackHelper : function(component, event, helper){
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var watercraftRecord = component.get("v.watercraftRecord");
            
            var screenName = component.get("v.screenName");

            if(screenName == 'UserInfo'){
            }else if(screenName == 'waterCraftDetail'){
                 helper.updateScreen(component, event, helper, 'UserInfo');
            }else if( screenName == 'TermOptions'){
                helper.updateScreen(component, event, helper, 'waterCraftDetail');
            }else if( screenName == 'QuickQuote'){
                helper.updateScreen(component, event, helper, 'TermOptions');
            }else if( screenName == 'ReviewVehicle'){
                helper.updateScreen(component, event, helper, 'QuickQuote');
            }else if( screenName == 'RegisteredVehicle'){
                helper.updateScreen(component, event, helper, 'ReviewVehicle');
            }else if( screenName == 'QuoteDetail'){
                helper.updateScreen(component, event, helper, 'RegisteredVehicle');
            }else if( screenName == 'InsuranceFinalDetail'){
                helper.updateScreen(component, event, helper, 'QuoteDetail');
            }else if( screenName == 'PaymentDetail'){
                helper.updateScreen(component, event, helper, 'InsuranceFinalDetail');
            }else if( screenName == 'PolicyDetail'){
            }
        }catch(exc){
            console.log('exce---'+exc);
        }
    	
    },

    checkUrlForAffiliateNumber : function(component, event, helper) {
        let affiliateNumber = helper.getUrlParameter('c__aid');

        if (affiliateNumber != "") {
            component.set("v.affiliateNumber", affiliateNumber);
            helper.fetchAffiliateAccount(component, event, helper);
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

    createTransactionRecord : function(component, event, helper){
        var rateRecordList =  component.get("v.rateRecordList");
        var affiliateAccount =  component.get("v.affiliateAccount");
        const action = component.get("c.createTransactionAction");

        action.setParams({
            rateRecordList : JSON.stringify(rateRecordList),
            affiliateAccountString : JSON.stringify(affiliateAccount),
            watercraftRecord: component.get("v.watercraftRecord")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    //helper.showToast('Policy Created Successfully', 'success');
                    
                    helper.updatePolicyRecord( component, event, helper );
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    updatePolicyRecord : function(component, event, helper) {
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
            console.log('----response----'+JSON.stringify(response));
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    component.set("v.policyMapList", response.policyMapList);
                    helper.updateScreen(component, event, helper, 'PolicyDetail');
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });

        $A.enqueueAction(action);
    }
})