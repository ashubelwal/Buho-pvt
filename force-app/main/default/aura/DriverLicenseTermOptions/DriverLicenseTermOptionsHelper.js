({
    initializeData: function (component, event, helper) {
        try{
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            component.set("v.minStartDate", today);
            component.set("v.endMinDate", today);
    
            var myDate = new Date();
            var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
            component.set("v.minTime", time);
    
    
            let quoteRecord = component.get("v.quoteRecord");
            console.log('--quoteRecord--',quoteRecord);
            if (quoteRecord != null && quoteRecord.Start_Date_for_Coverage__c != null && quoteRecord.Start_Date_for_Coverage__c != undefined ) {
                component.set("v.startDateCoverage", this.getDateForInputComponent(quoteRecord.Start_Date_for_Coverage__c));
            }
            if (quoteRecord != null && quoteRecord.End_Date_for_Coverage__c != null && quoteRecord.End_Date_for_Coverage__c != undefined) {
                component.set("v.endDateCoverage", this.getDateForInputComponent(quoteRecord.End_Date_for_Coverage__c));
            }
            
            quoteRecord['Start_Time__c'] = time;
            quoteRecord['End_Time__c'] = '23:59:00.000';
            component.set("v.quoteRecord", quoteRecord);
    
            helper.setTimeZonePicklistValues(component, event);
        }catch( ex ){
            console.log('-ex--', ex)
        }
    },

    getDateForInputComponent: function (inputDate) {
        const dateInDate = new Date(inputDate);
        let dateString = dateInDate.getFullYear() + '-';
        dateString += (dateInDate.getMonth() + 1) < 10 ? '0' : '';
        dateString += (dateInDate.getMonth() + 1) + '-';
        dateString += dateInDate.getDate();
        return dateString;
    },

    setTimeZonePicklistValues: function (component, event) {
        let action = component.get("c.getDependentPicklistValues");
        let policyType = component.get('v.policyType');
        action.setParams({
            'sObjectApiName': 'Quote__c',
            'dependentFieldApiName': 'Time_Zone__c'
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                let returnValues = response.getReturnValue();
                component.set("v.timeZones", returnValues[policyType]);
            } else {
                this.showErrorsInConsole(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    updateQuoteHelper: function (component, event, helper) {
        let quoteRecord = component.get("v.quoteRecord");
        const action = component.get('c.handleQuoteAction');
        action.setParams({
            quoteRecord: quoteRecord
        });
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var response = result.getReturnValue();
                if (response.success) {
                    var quoteRecord = component.get("v.quoteRecord");
                    quoteRecord.Term_Days__c = response.quoteRecord.Term_Days__c;
                    quoteRecord.Term__c = response.quoteRecord.Term__c;
                    quoteRecord.Quote_Status__c = response.quoteRecord.Quote_Status__c;
                    component.set("v.quoteRecord", quoteRecord);

                    $A.enqueueAction(component.get("v.onNextClick"));

                } else {
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(result.getError(), 'error');
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

    showErrorsInConsole: function (errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log(errors[0].message, 'error');
            }
        } else {
            console.log("Unknown error");
        }
    },

    showToast: function (message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
})