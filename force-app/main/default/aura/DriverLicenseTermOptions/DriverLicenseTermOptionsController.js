({
    doInit: function (component, event, helper) {
        helper.initializeData(component, event, helper);
    },

    updateValue: function (component, event, helper) {
        let name = event.getSource().get("v.name");
        let quoteRecord = component.get("v.quoteRecord");
        quoteRecord[name] = event.getParam("value");

        if (name === 'Start_Date_for_Coverage__c') {
            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c'] + 'T00:00:00');
            if (startDayForCoverage > new Date()) {
                quoteRecord['Start_Time__c'] = '00:01:00.000';
            } else {
                quoteRecord['Start_Time__c'] = $A.localizationService.formatTime(new Date(), 'HH:mm:ss.000z');
            }

            let endDayForCoverage = startDayForCoverage;
            endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            quoteRecord['End_Date_for_Coverage__c'] = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
        }

        let todaysDate = new Date();
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        var diffInDates = startDayForCoverage.getDate() - todaysDate.getDate();

        if( diffInDates != null && diffInDates != undefined && diffInDates >= 1){
            component.set("v.minTime", '00:00:00.000');
            if( name == 'Start_Date_for_Coverage__c' ){
                quoteRecord['Start_Time__c'] = "00:00:00.000";
                quoteRecord['End_Time__c'] = "00:00:00.000";
            }
        }else{
            var myDate = new Date()
            var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
            component.set("v.minTime", time);
            if( name == 'Start_Date_for_Coverage__c' ){
                quoteRecord['Start_Time__c'] = time;
                quoteRecord['End_Time__c'] = time;
            }
        }

        component.set("v.quoteRecord", quoteRecord);
        console.log('updateValue Start_Time__c : ' + component.get("v.quoteRecord").Start_Time__c);
        console.log('updateValue End_Time__c : ' + component.get("v.quoteRecord").End_Time__c);
    },

    onNextClick: function (component, event, helper) {
        if (helper.validateInputFields(component, event, helper)) {
            helper.updateQuoteHelper(component, event, helper);
        }
    }
})