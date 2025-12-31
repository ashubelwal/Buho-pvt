({
    initData: function (component, event, helper) {
        let policyType = 'Driver License';
        component.set("v.policyType", policyType);
        component.set("v.countVehicle", 1);

        component.set("v.stepList", [
            'driverDetail',
            'TermOptions',
            'QuickQuote',
            'RegisteredVehicle',
            'QuoteDetail',
            'InsuranceFinalDetail',
            'PaymentDetail',
            'PolicyDetail'
        ]);

        const action = component.get("c.getInitData");

        action.setParams({
            policyType: policyType
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let returnedData = response.getReturnValue();
                component.set("v.leadRecord", returnedData.leadRecord);
                component.set("v.quoteRecord", returnedData.quoteRecord);
                component.set("v.isCommunityUser", returnedData.isCommunityUser);
                component.set("v.driverRecord", returnedData.driverRecord);

                component.set("v.screenName", 'driverDetail');
            } else {
                helper.showErrorsInConsole(response.getError());

                helper.showToast(response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);

        let quoteRecord = component.get("v.quoteRecord");
        quoteRecord['Territory_Coverage__c'] = 'Entire Mexico';
        component.set("v.quoteRecord", quoteRecord);

        helper.checkUrlForAffiliateNumber(component, event, helper);
    },

    showErrorsInConsole: function (errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " +
                    errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
    },

    handleNextHelper: function (component, event, helper) {
        let quoteRecord = component.get("v.quoteRecord");
        const currentScreenName = component.get("v.screenName");
        const stepList = component.get("v.stepList");
        const nextScreenName = stepList[stepList.indexOf(currentScreenName) + 1];
        console.log('--nextScreenName---',nextScreenName);
        if( currentScreenName != 'PaymentDetail'){
            component.set("v.screenName", nextScreenName);
        }

        //TODO: need to refactor!!!
        if (currentScreenName === 'QuickQuote') {
            let rateRecordList = component.get("v.rateRecordList");
            if (rateRecordList && rateRecordList.length > 0) {
                let checkAlreadyRateTable = rateRecordList.filter(function (item) {
                    return item.quoteId === quoteRecord.Id;
                });

                let rateRecord = component.get("v.rateRecord")
                if (checkAlreadyRateTable && checkAlreadyRateTable.length === 0) {
                    rateRecordList.push(rateRecord);
                    component.set("v.rateRecordList", rateRecordList);
                }
            } else {
                let rateRecord = component.get("v.rateRecord");
                console.log('FLOW rateRecord.quoteRecord.Start_Time__c : ' + rateRecord.quoteRecord.Start_Time__c);
                console.log('FLOW rateRecord.quoteRecord.End_Time__c : ' + rateRecord.quoteRecord.End_Time__c);
                rateRecordList.push(component.get("v.rateRecord"));
                component.set("v.rateRecordList", rateRecordList);
            }
        }
        if (currentScreenName === 'RegisteredVehicle') {
            let quoteIds = component.get("v.quoteIds");
            if (quoteRecord && quoteRecord.Id && !quoteIds.includes(quoteRecord.Id)) {
                quoteIds.push(quoteRecord.Id);
            }
            component.set("v.quoteIds", quoteIds);
        }
        if( currentScreenName === 'PaymentDetail'){
            helper.createTransactionRecord(component, event, helper, nextScreenName);
        }
    },

    handleBackHelper: function (component) {
        const currentScreenName = component.get("v.screenName");
        const stepList = component.get("v.stepList");
        const previousScreenName = stepList[stepList.indexOf(currentScreenName) - 1];
        component.set("v.screenName", previousScreenName);
    },

    createTransactionRecord : function(component, event, helper, nextScreenName ){
        let rateRecordList =  component.get("v.rateRecordList");
        let affiliateAccount =  component.get("v.affiliateAccount");
        const action = component.get("c.createTransactionAction");

        action.setParams({
            rateRecordList : JSON.stringify(rateRecordList),
            affiliateAccountString : JSON.stringify(affiliateAccount)
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let result = response.getReturnValue();
                console.log('--result--', result);
                if( result.success){
                    helper.updatePolicyRecord(component, event, helper, nextScreenName);
                }else{
                    helper.showToast(result.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    updatePolicyRecord : function(component, event, helper, nextScreenName) {
        
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
                console.log('--response--', response);
                if( response.success){
                    component.set("v.policyMapList", response.policyMapList);

                    if( nextScreenName != null && nextScreenName.trim() != '' ){
                        component.set("v.screenName", nextScreenName);
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

    checkUrlForAffiliateNumber : function(component, event, helper) {
        let affiliateNumber = helper.getUrlParameter('c__aid');

        if (affiliateNumber !== "") {
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
            let state = response.getState();
            if (state === 'SUCCESS') {
                let account = response.getReturnValue();
                if( account ){
                    component.set("v.affiliateAccount", account);
                }
            } else {
                console.log('--response---');
                console.log(response);
            }
        });

        $A.enqueueAction(action);
    },

    showToast: function (message, type) {
        $A.get('e.force:showToast').setParams({
            mode: 'sticky',
            type: type,
            message: message
        }).fire();
    },
})