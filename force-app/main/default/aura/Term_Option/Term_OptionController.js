({
	doInit : function(component, event, helper) {
		helper.initilizeData(component, event, helper);
    },
    
    afterScriptsLoaded : function(component, event, helper) {
        let action = component.get('c.getTimeZone');
        action.setCallback(this, function(response) {
            console.log('response :::: ', response.getReturnValue());
            let serverDateTime = moment(response.getReturnValue());
            let todayDate = serverDateTime.tz('America/Los_Angeles').format('YYYY-MM-DD');
            let hour = serverDateTime.tz('America/Los_Angeles').format('hz');
            let minute = serverDateTime.tz('America/Los_Angeles').format('mmz');
            let formattedTime = hour + ':' + minute + ":" + '00';
            component.set("v.minDate", todayDate);
            component.set("v.endMinDate", todayDate);
            component.set("v.serverDateTime", (todayDate + " " + formattedTime));
            var myDate = new Date(todayDate + " " + formattedTime);
            var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var after15Date = myDate;
            after15Date.setMinutes( after15Date.getMinutes() - 15 );
            var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');

            var newTimeDiff = 0;
            var quoteRecord2 = component.get("v.quoteRecord");
            let startDayForCoverage = new Date(quoteRecord2['Start_Date_for_Coverage__c']);
            if( startDayForCoverage != null && startDayForCoverage != undefined ){
                startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                let todaysDate = new Date(todayDate + " " + formattedTime);
                todaysDate = new Date (todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate());

                var Difference_In_Time = startDayForCoverage.getTime() - todaysDate.getTime();
                newTimeDiff = Difference_In_Time / (1000 * 3600 * 24);
                console.log('@@ Difference_In_Time '+Difference_In_Time);
                //console.log('@@ Difference_In_Days '+Difference_In_Days);
                //return Difference_In_Days;
            }
            
            console.log('@newTimeDiff '+newTimeDiff);
            if( newTimeDiff != null && newTimeDiff != undefined && newTimeDiff != 0){
                component.set("v.minTime", '00:00:00.000');
                //component.set("v.minTime", '00:00:00.000');
            }else{
                component.set("v.minTime", timeafter15);
            }
            
            component.set("v.pstTime", (new Date(todayDate + " " + formattedTime)).getTime());
            console.log(' minTime '+component.get("v.minTime"));
            var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
        });
        $A.enqueueAction(action);
    },

    onRender : function(component, event, helper) {
        var renderInit = component.get("v.renderInit");
        var quoteRecord = component.get("v.quoteRecord");

        if( quoteRecord.Start_Time__c != undefined && renderInit == false){
            const DTms = quoteRecord.Start_Time__c;
            console.log('---DTms--'+DTms);
            component.set("v.renderInit",true); 
        }

        var timeZones = component.get("v.timeZones");
        var policyType = component.get('v.policyType');
        if( ( timeZones == undefined || timeZones.length == 0) && policyType != null && policyType != undefined ){
            helper.getDependentPicklistValues(component, event, helper, 'Policy_Type_picklist__c', 'Time_Zone__c', 'v.timeZones');
        }
        
    },
    
    onGroup : function(component, event, helper) {
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var selected = event.getSource().get("v.name");
            var value = event.getParam("checked");
            if( selected == 'Annual' ){
                component.set("v.semiAnnual", false);
            }else{
                component.set("v.annaul", false); 
            }
            
            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
            if( quoteRecord['Start_Date_for_Coverage__c'] && value ){
                startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
           
                let endDayForCoverage = startDayForCoverage;
                if( selected == 'Annual' ){
                    endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
                }else{
                    endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
                }
                quoteRecord['End_Date_for_Coverage__c'] = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
                component.set("v.endMinDate", quoteRecord['Start_Date_for_Coverage__c']);
            }else{
                quoteRecord['End_Date_for_Coverage__c'] = null;
            }
            
            startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
            var newTimeDiff ;//= helper.getDaysDifferent(component, event, helper);
            if( startDayForCoverage != null && startDayForCoverage != undefined ){
                startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
                let todaysDate = new Date(component.get("v.serverDateTime"));
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
                var myDate = new Date(component.get("v.serverDateTime"))
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
        
    },
    
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var quoteRecord = component.get("v.quoteRecord");        
        quoteRecord[name] = event.getParam("value"); 
        if( name == 'Start_Time__c'){
            quoteRecord['End_Time__c'] = event.getParam("value");
        }

        var annaul = component.get("v.annaul");
        var semiAnnual = component.get("v.semiAnnual");
       
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
		var newTimeDiff ;//= helper.getDaysDifferent(component, event, helper);

        if( startDayForCoverage != null && startDayForCoverage != undefined ){
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            let todaysDate = new Date(component.get("v.serverDateTime"));
            todaysDate = new Date (todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate());
            
            var Difference_In_Time = startDayForCoverage.getTime() - todaysDate.getTime();
            newTimeDiff = Difference_In_Time / (1000 * 3600 * 24);
        }

        console.log('--newTimeDiff---== '+newTimeDiff);
        if( newTimeDiff != undefined && newTimeDiff != null  && newTimeDiff != 0){
            component.set("v.minTime", '00:00:00.000');
            if( name == 'Start_Date_for_Coverage__c' ){
                quoteRecord['Start_Time__c'] = "00:00:00.000";
                quoteRecord['End_Time__c'] = "00:00:00.000";
            }
        }else{
            var myDate = new Date(component.get("v.serverDateTime"))
            var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
            if( name == 'Start_Date_for_Coverage__c' ){
                quoteRecord['Start_Time__c'] = time;
                quoteRecord['End_Time__c'] = time;
            }
            
            var after15Date = myDate;
            console.log('--after15Date---',after15Date);
            after15Date.setMinutes( after15Date.getMinutes() - 15 );
            console.log('--after15Date-2--',after15Date);
            var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
            console.log('--timeafter15---',timeafter15);
            component.set("v.minTime", timeafter15);
        }
        
        startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        if( quoteRecord['Start_Date_for_Coverage__c'] && startDayForCoverage ){
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            let endDayForCoverage = startDayForCoverage;
            if( name == 'Start_Date_for_Coverage__c' ){
                var  endMinDate = startDayForCoverage;
                endMinDate = endMinDate.setDate(endMinDate.getDate());
                component.set("v.endMinDate", $A.localizationService.formatDate(endMinDate, "YYYY-MM-DD"));
            }
            if( annaul ){
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            }else if( semiAnnual ){
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            }
            
            if( semiAnnual || annaul){
            	quoteRecord['End_Date_for_Coverage__c'] = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
            }
        }else{
            quoteRecord['End_Date_for_Coverage__c'] = null;
        }
        
        component.set("v.quoteRecord", quoteRecord);
    },

    onNextClick : function(component, event, helper) {
        var allVail = helper.validateInputFields(component, event, helper);
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
            
            if (Difference_In_Days != null && Difference_In_Days == 0) {
                helper.showToast('Total days cannot be less than 1', 'error');
                return;
            }
        }
        if( allVail ){
            helper.updateQuoteHelper(component, event, helper, 'TowningAnything');
        }
    }
})