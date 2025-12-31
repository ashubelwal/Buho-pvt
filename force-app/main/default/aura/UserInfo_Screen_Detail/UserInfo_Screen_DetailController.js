({
    doInit: function (component, event, helper){

    },

    updatePhoneValue: function (component, event, helper) {
        let value = event.getParam("value");
        let leadRecord = component.get("v.leadRecord");
        if (value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        }
        leadRecord['Phone'] = value;
        component.set("v.leadRecord", leadRecord);
    },

    updateValue: function(component, event, helper) {
        
    },

    onNextClick : function(component, event, helper){
        console.log("line 19--");
        let policyType = component.get("v.policyType");
        let leadRecord = component.get("v.leadRecord");
        leadRecord['Insurance_Type__c'] = policyType;
        console.log("email-->"+ JSON.stringify(leadRecord));
        let allValid = helper.validateInputFields(component, event, helper);
        if(allValid){
            helper.checkAllreadyUser(component, event, helper); 
        }
    }
})