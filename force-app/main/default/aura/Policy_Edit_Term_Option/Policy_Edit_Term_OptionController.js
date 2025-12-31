({
    doInit : function(component, event, helper) {
        helper.initilizeData(component, event, helper);
    },
    
    afterScriptsLoaded : function(component, event, helper) {
        let action = component.get('c.getTimeZone');
        action.setCallback(this, function(response) {
            let serverDateTime = moment(response.getReturnValue());
            let todayDate = serverDateTime.tz('America/Los_Angeles').format('YYYY-MM-DD');
            let hour = serverDateTime.tz('America/Los_Angeles').format('hz');
            let minute = serverDateTime.tz('America/Los_Angeles').format('mmz');
            let formattedTime = hour + ':' + minute + ":" + '00';
            component.set("v.serverDateTime", (todayDate + " " + formattedTime));

            component.set("v.pstTime", (new Date(todayDate + " " + formattedTime)).getTime());
        });
        $A.enqueueAction(action);
    },
    
    onRender : function(component, event, helper) {
        try{
            var renderInit = component.get("v.renderInit");
            var quoteRecord = component.get("v.quoteRecord");
            
            if( quoteRecord.Start_Time__c != undefined && renderInit == false){
                const DTms = quoteRecord.Start_Time__c; 
                const DTdate = new Date();
                DTdate.setHours(0,0,0,DTms);
                var pstDate = DTdate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
                //quoteRecord['Start_Time__c'] = time;
                //quoteRecord['End_Time__c'] = time;
                
                let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
                let todaysDate = new Date();
                var after15Date = todaysDate;
                after15Date.setMinutes( after15Date.getMinutes() );
                var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
                
                todaysDate = new Date(Date.UTC(todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate() ));
                startDayForCoverage  = new Date(Date.UTC(startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate() ));
                
                var newTimeDiff = helper.getDaysDifferent(component, event, helper); 
                console.log('--newTimeDiff---'+newTimeDiff);
                if( newTimeDiff != undefined && newTimeDiff != null && newTimeDiff != 0){
                    
                    component.set("v.minTime", '00:00:00.000');
                    quoteRecord['Start_Time__c'] = "00:00:00.000";
                    quoteRecord['End_Time__c'] = "00:00:00.000";
                    
                }else{
                    var myDate = new Date(component.get("v.serverDateTime"))
                    var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                    var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
                    //component.set("v.minTime", time);
                    quoteRecord['Start_Time__c'] = time;
                    quoteRecord['End_Time__c'] = time;
                    
                    var after15Date = myDate;
                    after15Date.setMinutes( after15Date.getMinutes());
                    var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                    var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
                    component.set("v.minTime", timeafter15);
                }
                
                if( ( startDayForCoverage < todaysDate ) || ( startDayForCoverage.getTime() == todaysDate.getTime() && time < timeafter15 )  ){
                    component.set("v.disableDate", true);
                }
                
                component.set("v.quoteRecord",quoteRecord);
                component.set("v.renderInit",true); 
            }
        }catch( ex ){
            console.log('--ex-',ex);
        }
        
        
        /* var timeZones = component.get("v.timeZones");
        var policyType = component.get('v.policyType');
        if( ( timeZones == undefined || timeZones.length == 0) && policyType != null && policyType != undefined ){
            //helper.getDependentPicklistValues(component, event, helper, 'Policy_Type_picklist__c', 'Time_Zone__c', 'v.timeZones');
        }*/
        
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
                console.log(endDayForCoverage);
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
            let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']);
            
            var newTimeDiff = helper.getDaysDifferent(component, event, helper); 
            console.log('--newTimeDiff---'+newTimeDiff);
            if( newTimeDiff != undefined && newTimeDiff != null && newTimeDiff != 0){
                
                component.set("v.minTime", '00:00:00.000');
                quoteRecord['Start_Time__c'] = "00:00:00.000";
                quoteRecord['End_Time__c'] = "00:00:00.000";
                
            }else{
                var myDate = new Date(component.get("v.serverDateTime"));
                var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
                //component.set("v.minTime", time);
                quoteRecord['Start_Time__c'] = time;
                quoteRecord['End_Time__c'] = time;
                
                var after15Date = myDate;
                after15Date.setMinutes( after15Date.getMinutes());
                var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
                component.set("v.minTime", timeafter15);
            }
            
            
            /*
                check data is chnaged or not
            */
            var clonedquoteRecord = component.get("v.clonedquoteRecord");
            let clonedStartDayForCoverage = new Date(clonedquoteRecord['Start_Date_for_Coverage__c']);
            let clonedEndDayForCoverage = new Date(clonedquoteRecord['End_Date_for_Coverage__c']);
            
            
            startDayForCoverage = $A.localizationService.formatDate(startDayForCoverage, "YYYY-MM-DD");
            clonedStartDayForCoverage = $A.localizationService.formatDate(clonedStartDayForCoverage, "YYYY-MM-DD");
            
            endDayForCoverage = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
            clonedEndDayForCoverage = $A.localizationService.formatDate(clonedEndDayForCoverage, "YYYY-MM-DD");
            
            if( startDayForCoverage != clonedStartDayForCoverage || endDayForCoverage != clonedEndDayForCoverage ){
                component.set("v.dateChange", true);
            }else{
                component.set("v.dateChange", false);
            }
            
            component.set("v.quoteRecord", quoteRecord);
        }catch( ex ){
            console.log( ex );
        }
        
    },
    
    updateValue : function(component, event, helper) {
        console.log("Update Value Function");
        var name = event.getSource().get("v.name");
        var quoteRecord = component.get("v.quoteRecord");        
        quoteRecord[name] = event.getParam("value"); 
        if( name == 'Start_Time__c'){
            quoteRecord['End_Time__c'] = event.getParam("value");
        }
        
        var annaul = component.get("v.annaul");
        var semiAnnual = component.get("v.semiAnnual");
        
        var newTimeDiff; //= helper.getDaysDifferent(component, event, helper); 
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        
        if( name == 'Start_Date_for_Coverage__c' && startDayForCoverage != null && startDayForCoverage != undefined ){
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            let todaysDate = new Date();
            todaysDate = new Date (todaysDate.getUTCFullYear(), todaysDate.getUTCMonth(), todaysDate.getUTCDate());
            
            var Difference_In_Time = startDayForCoverage.getTime() - todaysDate.getTime();
            newTimeDiff = Difference_In_Time / (1000 * 3600 * 24);
            console.log('@@ Difference_In_Time '+Difference_In_Time);
        }

        console.log('@newTimeDiff '+newTimeDiff);
        if( newTimeDiff != undefined && newTimeDiff != null && newTimeDiff != 0 ){
            component.set("v.minTime", '00:00:00.000');
            if( name == 'Start_Date_for_Coverage__c' ){
                quoteRecord['Start_Time__c'] = "00:00:00.000";
                quoteRecord['End_Time__c'] = "00:00:00.000";
            }
        }else if( name == 'Start_Date_for_Coverage__c' ){
            var myDate = new Date(component.get("v.serverDateTime"));
            var pstDate = myDate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var time = $A.localizationService.formatTime(pstDate, 'HH:mm:ss.000z');
            if( name == 'Start_Date_for_Coverage__c' ){
                quoteRecord['Start_Time__c'] = time;
                quoteRecord['End_Time__c'] = time;
            }
            
            var after15Date = myDate;
            after15Date.setMinutes( after15Date.getMinutes() );
            var after15PstDate = after15Date.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
            var timeafter15 = $A.localizationService.formatTime(after15PstDate, 'HH:mm:ss.000z');
            component.set("v.minTime", timeafter15);
        }
        
        startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        if( name == 'Start_Date_for_Coverage__c' && quoteRecord['Start_Date_for_Coverage__c'] && startDayForCoverage ){
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            if( name == 'Start_Date_for_Coverage__c' ){
                var  endMinDate = startDayForCoverage;
                endMinDate = endMinDate.setDate(endMinDate.getDate());
                component.set("v.endMinDate", $A.localizationService.formatDate(endMinDate, "YYYY-MM-DD"));
            }
            
            let endDayForCoverage = startDayForCoverage;
            if( annaul ){
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 365);
            }else if( semiAnnual ){
                endDayForCoverage.setDate(endDayForCoverage.getDate() + 180);
            }
            if( semiAnnual || annaul){
                quoteRecord['End_Date_for_Coverage__c'] = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
            }
        }else if( name == 'Start_Date_for_Coverage__c' ){
            quoteRecord['End_Date_for_Coverage__c'] = null;
        }
        
        /*
            check data is chnaged or not
        */
        
        var clonedquoteRecord = component.get("v.clonedquoteRecord");
        if( name == 'Start_Date_for_Coverage__c' || name == 'End_Date_for_Coverage__c' ){
            let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']);
            let clonedStartDayForCoverage = new Date(clonedquoteRecord['Start_Date_for_Coverage__c']);
            let clonedEndDayForCoverage = new Date(clonedquoteRecord['End_Date_for_Coverage__c']);
            
            startDayForCoverage = $A.localizationService.formatDate(startDayForCoverage, "YYYY-MM-DD");
            clonedStartDayForCoverage = $A.localizationService.formatDate(clonedStartDayForCoverage, "YYYY-MM-DD");
            console.log('--startDayForCoverage--'+startDayForCoverage);
            console.log('--clonedStartDayForCoverage--'+clonedStartDayForCoverage);
            
            endDayForCoverage = $A.localizationService.formatDate(endDayForCoverage, "YYYY-MM-DD");
            clonedEndDayForCoverage = $A.localizationService.formatDate(clonedEndDayForCoverage, "YYYY-MM-DD");
            console.log('--endDayForCoverage--'+endDayForCoverage);
            console.log('--clonedEndDayForCoverage--'+clonedEndDayForCoverage);
            if( ( startDayForCoverage != clonedStartDayForCoverage) || ( endDayForCoverage != clonedEndDayForCoverage) ){
                component.set("v.dateChange", true);
            }else{
                component.set("v.dateChange", false);
            }
        }
        
        
        /*
            Date of birth change
        */
        try{
            console.log('-Name--',name);
            
            if( name == 'Date_of_Birth__c'){
                let cloneDateOfBirth = new Date(clonedquoteRecord['Date_of_Birth__c']);
                cloneDateOfBirth =  $A.localizationService.formatDate(cloneDateOfBirth, "YYYY-MM-DD");
                
                let dateOfBirth = new Date(quoteRecord['Date_of_Birth__c']);
                dateOfBirth = $A.localizationService.formatDate(dateOfBirth, "YYYY-MM-DD");
                if( dateOfBirth != cloneDateOfBirth){
                    component.set("v.dateOfBirthChange", true);
                }else{
                    component.set("v.dateOfBirthChange", false);
                }
            }
            
            if( name == 'Territory_Coverage__c'){
                let territoryCoverage = quoteRecord['Territory_Coverage__c'];
                let oldterritoryCoverage = clonedquoteRecord['Territory_Coverage__c'];
                if( territoryCoverage != oldterritoryCoverage){
                    component.set("v.territoryCoverageChange", true);
                }else{
                    component.set("v.territoryCoverageChange", false);
                }
            }
            
            if( name == 'Medical__c'){
                let medical = quoteRecord['Medical__c'];
                let oldmedical = clonedquoteRecord['Medical__c'];
                if( medical != oldmedical){
                    component.set("v.medicalChange", true);
                }else{
                    component.set("v.medicalChange", false);
                }
            }
            
            if( name == 'Liability__c'){
                let liability = quoteRecord['Liability__c'];
                let oldliability = clonedquoteRecord['Liability__c'];
                let medOption = component.get("v.medicalOption");
                
                console.log('--liability---'+liability);
                console.log('--oldliability---'+oldliability);
                if( liability != oldliability){
                    
                    if(component.get("v.policyType") == 'Watercraft'){
                        if(liability == '200,000'){
                            quoteRecord['Medical__c'] = medOption[0].value;
                            
                        }else if(liability == '400,000'){
                            quoteRecord['Medical__c'] = medOption[1].value;
                        }else if(liability == '750,000'){
                            quoteRecord['Medical__c'] = medOption[2].value;
                        }
                    }

                    component.set("v.liabilityChange", true);

                }else{

                    if(component.get("v.policyType") == 'Watercraft'){
                        if(oldliability == '200,000'){
                            quoteRecord['Medical__c'] = medOption[0].value;
                            
                        }else if(oldliability == '400,000'){
                            quoteRecord['Medical__c'] = medOption[1].value;
                        }else if(oldliability == '750,000'){
                            quoteRecord['Medical__c'] = medOption[2].value;
                        }
                    }

                    component.set("v.liabilityChange", false);
                }
                console.log('--liabilityChange---'+component.get("v.liabilityChange"));
            } else {
                let oldliability = clonedquoteRecord['Liability__c'];
                let medOption = component.get("v.medicalOption");
                if(component.get("v.policyType") == 'Watercraft'){
                        if(oldliability == '200,000'){
                            quoteRecord['Medical__c'] = medOption[0].value;
                            
                        }else if(oldliability == '400,000'){
                            quoteRecord['Medical__c'] = medOption[1].value;
                        }else if(oldliability == '750,000'){
                            quoteRecord['Medical__c'] = medOption[2].value;
                        }
                    }
            }
            component.set("v.quoteRecord", quoteRecord);
            console.log("quoteRecord", quoteRecord['Liability__c']);
            
        }catch( ex ){
            console.log('--exception e--',ex);
        }
        
    },
    
    handleDateOfBirth : function(component, event, helper) {
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var clonedquoteRecord = component.get("v.clonedquoteRecord");
            
            let cloneDateOfBirth = new Date(clonedquoteRecord['Date_of_Birth__c']);
            cloneDateOfBirth =  $A.localizationService.formatDate(cloneDateOfBirth, "YYYY-MM-DD");
            
            let dateOfBirth = new Date(quoteRecord['Date_of_Birth__c']);
            dateOfBirth = $A.localizationService.formatDate(dateOfBirth, "YYYY-MM-DD");
            console.log("adhdwwawda ", dateOfBirth);
            if( dateOfBirth != cloneDateOfBirth){
                component.set("v.dateOfBirthChange", true);
            }else{
                component.set("v.dateOfBirthChange", false);
            }
        }catch( ex ){
            console.log('--exception e--',ex);
        }
    },
    
    onNextClick : function(component, event, helper) {
        try{
            var allVail = helper.validateInputFields(component, event, helper);
            
            var renewPolicy = component.get("v.renewPolicy");
            
            var quoteRecord = component.get("v.quoteRecord");
            
            var customValidateField = component.find("customValidateField");
            
            let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
            startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
            
            let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
            endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());
            
            var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
            console.log("Difference in Time ---> ", Difference_In_Time);
            var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            if( Difference_In_Days != null && Difference_In_Days > 365 ){
                helper.showToast('Total days cannot equal more than 365', 'error');
                return ;
            }
            
            if (Difference_In_Days != null && Difference_In_Days == 0) {
                helper.showToast('Total days cannot be less than 1', 'error');
                return;
            }
            
            if( customValidateField != null && customValidateField != undefined ){
                allVail = ( allVail && customValidateField.validateFields());
            }
            
            // if the policy is renew policy
            if( renewPolicy != undefined && renewPolicy == true ){
                if( allVail ){
                    console.log("Inside All Valid");
                    
                    let liability = quoteRecord['Liability__c'];
                    component.set("v.qualitasLiability", liability.replace(/,/g, ''));
                    component.set("v.chubbLiability", liability.replace(/,/g, ''));
                    component.set("v.mapfreLiability", liability.replace(/,/g, ''));
                    
                    let Medical = quoteRecord['Medical__c'];
                    if(Medical != null && Medical != undefined){
                        let medicalValue = Medical.split('/'); 
                        let updateMedicalValue = "$"+medicalValue[0]+'/'+"$"+medicalValue[1];
                        component.set("v.qualitasMedical", updateMedicalValue);
                        component.set("v.chubbMedical", updateMedicalValue);
                        component.set("v.mapfreMedical", updateMedicalValue);
                    }

                    helper.createRenewQuoteHelper(component, event, helper, 'TowningAnything');
                }
                return;
            }
            
            if( allVail ){
                var dateChange = component.get("v.dateChange");
                var vehicleValueChange = component.get("v.vehicleValueChange");
                var dateOfBirthChange = component.get("v.dateOfBirthChange");
                var territoryCoverageChange = component.get("v.territoryCoverageChange");
                var liabilityChange = component.get("v.liabilityChange");
                var medicalChange = component.get("v.medicalChange");
                var iscloneConditionPass = ( dateChange
                                            || vehicleValueChange 
                                            || iscloneConditionPass 
                                            || dateOfBirthChange 
                                            || territoryCoverageChange 
                                            || liabilityChange 
                                            || medicalChange );
                
                if( iscloneConditionPass == false ){
                    helper.updateQuoteHelper(component, event, helper, 'TowningAnything');
                }else{
                    $A.enqueueAction(component.get("v.onNextClick"));
                }
            }
        }catch( ex ){
            console.log('-ex--',ex);
        }
    }
})