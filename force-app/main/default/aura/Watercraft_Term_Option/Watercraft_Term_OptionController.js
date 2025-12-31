({
	doInit : function(component, event, helper) {
		helper.initilizeData(component, event, helper);
    },
    
    onGroup : function(component, event, helper) {
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var selected = event.getSource().get("v.name");
            var value = event.getParam("checked");
            console.log('--selected--'+selected);
            if( selected == 'Annual' ){
                component.set("v.semiAnnualTerm", false);
            }else{
                component.set("v.annualTerm", false); 
            }

            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);

            if( startDayForCoverage && value ){
                startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());

                let endDayForCoverage = startDayForCoverage;
                if( selected == 'Annual' ){
                    endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
                }else{
                    endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
                }
                
                var finaldate = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
                quoteRecord['End_Date_for_Coverage__c'] = finaldate;
            }else{
                quoteRecord['End_Date_for_Coverage__c'] = null;
            }

            startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
            var newTimeDiff ;//= 
            if( startDayForCoverage != null && startDayForCoverage != undefined ){
                startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                let todaysDate = new Date();
                todaysDate = new Date (todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate());
                
                var Difference_In_Time = startDayForCoverage.getTime() - todaysDate.getTime();
                newTimeDiff = Difference_In_Time / (1000 * 3600 * 24);
            }
            if( newTimeDiff != undefined && newTimeDiff != null && newTimeDiff != 0){
                component.set("v.minTime", '00:00:00.000');
                //when only annual or semi 
                quoteRecord['Start_Time__c'] = "00:00:00.000";
                quoteRecord['End_Time__c'] = "00:00:00.000";
                
            }else{
                var myDate = new Date()
                var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
                quoteRecord['Start_Time__c'] = time;
                quoteRecord['End_Time__c'] = time;

                var after15Date = myDate;
                after15Date.setMinutes( after15Date.getMinutes() - 15 );
                var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
                component.set("v.minTime", timeafter15);
            }
            component.set("v.quoteRecord", quoteRecord);
        }catch( ex ){
            console.log( ex );
        }

        helper.calculateDays(component, event, helper);
        
    },
    
    updateValue : function(component, event, helper) {
        try{
            var name = event.getSource().get("v.name");
            var quoteRecord = component.get("v.quoteRecord");        
            quoteRecord[name] = event.getParam("value"); 
            if( name == 'Start_Time__c'){
                quoteRecord['End_Time__c'] = event.getParam("value");
            }

            var annual = component.get("v.annualTerm");
            var semiAnnual = component.get("v.semiAnnualTerm");
            var date = quoteRecord['Start_Date_for_Coverage__c'] + 'T00:00:00';
            var diffInDates = 0;
            if( date ){
                var result = new Date(date);
                if( annual ){
                    result.setDate(result.getDate() + 365);
                }else if( semiAnnual ) {
                    result.setDate(result.getDate() + 180);
                }
                
                if( semiAnnual || annual){
                    var finaldate = $A.localizationService.formatDate(result, "YYYY-MM-DD");
                    quoteRecord['End_Date_for_Coverage__c'] = finaldate;
                }
            }

            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
            var newTimeDiff ;//= helper.getDaysDifferent(component, event, helper);
            if( startDayForCoverage != null && startDayForCoverage != undefined ){
                startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                let todaysDate = new Date();
                todaysDate = new Date (todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate());

                var startDate = $A.localizationService.formatDate(new Date(startDayForCoverage), "YYYY-MM-DD");
             	component.set("v.minDate", startDate);//this for disabled before date of startday.
                var Difference_In_Time = startDayForCoverage.getTime() - todaysDate.getTime();
                newTimeDiff = Difference_In_Time / (1000 * 3600 * 24);
            }

            if( newTimeDiff != undefined && newTimeDiff != null && newTimeDiff != 0){
                component.set("v.minTime", '00:00:00.000');
                if( name == 'Start_Date_for_Coverage__c' ){
                    quoteRecord['Start_Time__c'] = "00:00:00.000";
                    quoteRecord['End_Time__c'] = "00:00:00.000";
                    console.log('-here updated--'+diffInDates);
                }
            }else{
                var myDate = new Date()
                var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
                if( name == 'Start_Date_for_Coverage__c' ){
                    quoteRecord['Start_Time__c'] = time;
                    quoteRecord['End_Time__c'] = time;
                }

                var after15Date = myDate;
                after15Date.setMinutes( after15Date.getMinutes() - 15 );
                var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
                component.set("v.minTime", timeafter15);
            }
            component.set("v.quoteRecord", quoteRecord);
        }catch( ex ){
            console.log( ex );
        }

        helper.calculateDays(component, event, helper);
    },

    onNextClick : function(component, event, helper) {
        var allVail = helper.validateInputFields(component, event, helper);
        console.log('---allVail-'+allVail);
        if( allVail ){
            var quoteRecord = component.get("v.quoteRecord");
            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());

            let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
            endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());

            var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
            var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            if( Difference_In_Days != null && Difference_In_Days > 365 ){
                helper.showToast('Total days cannot equal more than 365', 'error');
                return ;
            }

            helper.updateQuoteHelper(component, event, helper, 'QuickQuote');
        }
    }
})