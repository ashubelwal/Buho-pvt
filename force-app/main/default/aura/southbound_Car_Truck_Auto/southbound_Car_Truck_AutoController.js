({
	doInit : function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.href);
        if( sPageURL ){
          	sPageURL = sPageURL.split('/s/')[1];  
              console.log('--sPageURL--',sPageURL.toLowerCase().indexOf('motorcycle'));
            if( sPageURL.toLowerCase().includes('motorcycle')){
                component.set("v.policyType", "Motorcycle/Street Legal ATV");
            }else if( sPageURL.toLowerCase().includes('automobile') ){
               component.set("v.policyType", "Automobile"); 
            }else if( sPageURL.toLowerCase().includes('rv') ){
                component.set("v.policyType", "RV"); 
            }
        }
        
        helper.initilizeData(component, event, helper);
        component.set("v.countVehicle", parseInt('1'));
        
    },
    
    onGroup : function(component, event, helper){
        var selected = event.getSource().get("v.text");
        var quoteRecord = component.get("v.quoteRecord");
        quoteRecord['Territory_Coverage__c'] = selected;
        if( selected && selected == 'Partial (US Adjacent)' ){
            quoteRecord['Territory__c'] = 'Limited';
        }else if( selected && selected == 'Entire Mexico' ){
            quoteRecord['Territory__c'] = 'Full';
        }else if( selected && selected == 'Baja Sonora' ){
           	quoteRecord['Territory__c'] = 'Baja/Sonora';
        }
        component.set("v.quoteRecord", quoteRecord);
    },

	
    handleNext : function(component, event, helper){
        console.log('--handleNext-');
        var policyType = component.get("v.policyType");
        console.log('----policyType---'+policyType);
        if( policyType == 'Automobile' || policyType == 'RV'){
            helper.handleAutoMobileNextHelper(component, event, helper);
        }else if( policyType == 'Motorcycle/Street Legal ATV' ){
            helper.handleNextMotorCycleHelper(component, event, helper);
        }
    },

    handleBack : function(component, event, helper){
        console.log('--handleBack-');
        let communityUser = component.get("v.communityUser");

        if (!communityUser) {
            let leadRecord = component.get("v.leadRecord");
            if (leadRecord.Firstname != undefined) {
                component.set("v.updateLeadData", false);
            } else {
                component.set("v.updateLeadData", true);
            }
        }

        var policyType = component.get("v.policyType");
        if( policyType == 'Automobile' || policyType == 'RV'){
            helper.handleAutoMobileBackHelper(component, event, helper);
        }else if( policyType == 'Motorcycle/Street Legal ATV' ){
            helper.handleBackMotorCycleHelper(component, event, helper);
        }
        //helper.handleBackHelper(component, event, helper);
    },

    showSpinner : function (component, event, helper) {
        var spinner = component.get("v.spinner");
        if( !spinner ){
            component.set("v.spinner", true);
        }
        
    },
    
    hideSpinner : function (component, event, helper) {
        var spinner = component.get("v.spinner");
        if( spinner ){
            component.set("v.spinner", false);
        }
    },
    openPurchaseModal: function (component, event, helper) {
        let communityUser = component.get("v.communityUser");
        if (!communityUser) {
            component.set("v.purchaseQuotePop", true);
        } else {
            var policyType = component.get("v.policyType");
            if (policyType == 'Automobile' || policyType == 'RV') {
                helper.handleAutoMobileNextHelper(component, event, helper);
            } else if (policyType == 'Motorcycle/Street Legal ATV') {
                helper.handleNextMotorCycleHelper(component, event, helper);
            }
        }
    },
    updatePhoneValue: function (component, event, helper) {
        var value = event.getParam("value");
        if (value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        }
        component.set("v.phoneNumber", value);
    },
    closePurchaseModel: function (c, e, h) {
        c.set("v.purchaseQuotePop", false);
    },
    onUpdateleadData: function (component, event, helper) {
        let leadId = component.get("v.leadRecord").Id;
        let firstName = component.get("v.firstName");
        let lastName = component.get("v.lastName");
        let emailAdder = component.get("v.leadRecord").Email;
        let phoneNumber = component.get("v.phoneNumber");
        let policyType = component.get("v.policyType");

        var action = component.get("c.updateLeadRecord");
        action.setParams({
            leadId: leadId,
            firstName: firstName,
            lastName: lastName,
            emailAdder: emailAdder,
            phoneNumber: phoneNumber,
            quoteId: component.get("v.quoteRecord").Id,
            policyType: policyType
        });

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var responses = response.getReturnValue();
                if (responses.success) {

                    let leadRecord = component.get("v.leadRecord");
                    leadRecord['firstName'] = firstName;
                    leadRecord['lastName'] = lastName;
                    leadRecord['emailAdder'] = emailAdder;
                    leadRecord['phoneNumber'] = phoneNumber;
                    component.set("v.leadRecord", leadRecord);

                    if (policyType == 'Automobile' || policyType == 'RV') {
                        helper.handleAutoMobileNextHelper(component, event, helper);
                    } else if (policyType == 'Motorcycle/Street Legal ATV') {
                        helper.handleNextMotorCycleHelper(component, event, helper);
                    }
                    // component.get("v.updateLeadData", false);
                    component.set("v.purchaseQuotePop", false);

                } else {
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    }
})