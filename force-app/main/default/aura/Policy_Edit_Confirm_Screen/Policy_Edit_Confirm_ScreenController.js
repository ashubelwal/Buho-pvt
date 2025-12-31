({
    doInit : function(component, event, helper) {
        helper.InitCal( component, event, helper );

        var title = 'According to information that you have provided and the policy coverage you have selected, your original and modified plans are as follows:';
        component.set("v.title",title);

        var policyRecord = component.get("v.policyRecord");
        console.log("CA log policyrecord confirm : "+ JSON.stringify(policyRecord, null, 4));
        if( policyRecord != undefined && policyRecord.Surcharge__c == undefined){
            policyRecord['Surcharge__c'] = 0;
        }
        if(  policyRecord != undefined && policyRecord.I_V_A_Mex_Tax__c == undefined){
            policyRecord['I_V_A_Mex_Tax__c'] = 0;
        }

        if( policyRecord != undefined && policyRecord.Net_Premium__c != undefined && policyRecord.Net_Premium__c != null 
            /*&& policyRecord.Surcharge__c != undefined && policyRecord.Surcharge__c != null*/ ){
            //component.set("v.oldNewPermimum", (policyRecord.Net_Premium__c - policyRecord.Surcharge__c) );
            component.set("v.oldNewPermimum", policyRecord.Net_Premium__c);
        }
        component.set("v.policyRecord", policyRecord);

    },
    
    onNextClick : function(component, event, helper) {
        var iscloneConditionPass = component.get("v.iscloneConditionPass");
        var refundAmount = component.get("v.refundAmount");
        if( refundAmount != undefined){
            refundAmount = parseInt(refundAmount);
        }
        console.log('--refundAmount-'+refundAmount);
        console.log('--iscloneConditionPass-'+iscloneConditionPass);
        if( iscloneConditionPass == true || ( refundAmount != undefined && refundAmount != 0)  ){
            helper.createClonePolicyHelper( component, event, helper );
        }else if( ( refundAmount != undefined && refundAmount == 0) ){
            $A.enqueueAction(component.get("v.onNextClick"));
        }
        
    },
})