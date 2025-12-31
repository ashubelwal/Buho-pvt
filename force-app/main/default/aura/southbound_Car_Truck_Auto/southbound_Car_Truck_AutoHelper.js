({
    initilizeData : function(component, event, helper) {
        
        helper.checkUrlForQuoteId(component, event, helper);
        helper.fetchPolicyData(component, event, helper);
        let communityUser = component.get("v.communityUser");
        
        if(!communityUser){
            let leadRecord = component.get("v.leadRecord");
            console.log("line 851---"+ leadRecord.firstName);
            component.get("v.updateLeadData", true);
        }
    },
    checkUrlForQuoteId : function(component, event, helper) {
        let quoteId = helper.getUrlParameter('c__ID');
		console.log("CA log quoteId" + quoteId);
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
    handleBackMotorCycleHelper : function(component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        var vehicleRecord = component.get("v.vehicleRecord");
        
        var screenName = component.get("v.screenName");
        var nextScreen;
        if( screenName == 'InsuranceToday'){
            
        }else if( screenName == 'WhereInsurance'){
        }else if( screenName == 'UserInfo'){
        }else if( screenName == 'VehicleOptions'){
            helper.updateScreen(component, event, helper, 'UserInfo');
        }else if( screenName == 'TermOptions'){
            helper.updateScreen(component, event, helper, 'VehicleOptions');
        }else if( screenName == 'TerritoryCoverage'){
            helper.updateScreen(component, event, helper, 'TermOptions');
        }else if( screenName == 'southbound_Quick_Quote_Detail'){
            helper.updateScreen(component, event, helper, 'TerritoryCoverage');
        }else if( screenName == 'ReviewVehicle'){
            helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
        }else if( screenName == 'CompanyInfo'){
            helper.updateScreen(component, event, helper, 'ReviewVehicle');
        }else if( screenName == 'LienHolder'){
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                nextScreen = 'CompanyInfo';
            }else if( vehicleRecord.Is_Lienholder__c ){
                nextScreen = 'ReviewVehicle';
            }
            helper.updateScreen(component, event, helper, nextScreen );
        }else if( screenName == 'RegisteredVehicle'){
            nextScreen = 'ReviewVehicle';
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                nextScreen = 'CompanyInfo';
            }else if( vehicleRecord.Is_Lienholder__c ){
                nextScreen = 'LienHolder';
            }
            helper.updateScreen(component, event, helper, nextScreen);
        }else if( screenName == 'AnotherVehicle'){
            helper.updateScreen(component, event, helper, 'RegisteredVehicle');
        }else if( screenName == 'QuoteDetail'){
            //helper.updateScreen(component, event, helper, 'AnotherVehicle');
            helper.updateScreen(component, event, helper, 'RegisteredVehicle');
        }else if( screenName == 'InsuranceFinalDetail'){
            nextScreen = 'QuoteDetail';
            helper.updateScreen(component, event, helper, nextScreen);
            
        }else if( screenName == 'PaymentDetail'){
            nextScreen = 'InsuranceFinalDetail';
            helper.createTransactionRecord(component, event, helper, nextScreen);
        }else if( screenName == 'PolicyDetail'){
        }
        
    },
    handleAutoMobileBackHelper : function(component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        var vehicleRecord = component.get("v.vehicleRecord");
        
        var screenName = component.get("v.screenName");
        console.log('---currentScreen--'+screenName);
        var nextScreen;
        if( screenName == 'InsuranceToday'){
            
        }else if( screenName == 'WhereInsurance'){
        }else if( screenName == 'UserInfo'){

        }else if( screenName == 'VehicleOptions'){
            helper.updateScreen(component, event, helper, 'UserInfo');
        }else if( screenName == 'TermOptions'){
            helper.updateScreen(component, event, helper, 'VehicleOptions');
        }else if( screenName == 'TowningAnything'){
            helper.updateScreen(component, event, helper, 'TermOptions');
        }else if( screenName == 'TowningInfo'){
            helper.updateScreen(component, event, helper, 'TowningAnything');
        }else if( screenName == 'Transporte'){
            // helper.updateScreen(component, event, helper, 'TowningInfo');
            helper.updateScreen(component, event, helper, 'TowningAnything');
        }else if( screenName == 'TerritoryCoverage'){
            if( quoteRecord && quoteRecord.Towed_Unit__c && quoteRecord.Towed_Unit__c == 'Yes' ){
                helper.updateScreen(component, event, helper, 'Transporte');
            }else{
                helper.updateScreen(component, event, helper, 'TowningAnything');
            }
        }else if( screenName == 'southbound_Quick_Quote_Detail'){
            helper.updateScreen(component, event, helper, 'TerritoryCoverage');
        }else if( screenName == 'aditional_Quick_Quote_Detail'){
            component.set("v.countVehicle", parseInt('1'));
            helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');

        }else if( screenName == 'ReviewVehicle'){
            var transporates = component.get("v.transporates");
            if( transporates != null && transporates.length > 0 && quoteRecord.Towed_Unit__c == 'Yes'){
                var additional_towunits = transporates.filter(function(item){
                    return item.Street_Legal__c == 'Yes';
                });

                if( additional_towunits != null && additional_towunits.length > 0 ){
                    helper.updateScreen(component, event, helper, 'aditional_Quick_Quote_Detail');
                }else{
                    helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
                }
            }else{
                helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
            } 
        }else if( screenName == 'CompanyInfo'){
            helper.updateScreen(component, event, helper, 'ReviewVehicle');
        }else if( screenName == 'LienHolder'){
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                helper.updateScreen(component, event, helper, 'CompanyInfo');
            }else if( vehicleRecord.Is_Lienholder__c ){
                helper.updateScreen(component, event, helper, 'ReviewVehicle');
            }
        }else if( screenName == 'RegisteredVehicle'){
            nextScreen = 'ReviewVehicle';
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                nextScreen = 'CompanyInfo';
                if( vehicleRecord.Is_Lienholder__c ){
                    nextScreen = 'LienHolder';
                }
            }else if( vehicleRecord.Is_Lienholder__c ){
                nextScreen = 'LienHolder';
            }
            helper.updateScreen(component, event, helper, nextScreen);
        }else if( screenName == 'AnotherVehicle'){
            helper.updateScreen(component, event, helper, 'RegisteredVehicle');
        }else if( screenName == 'QuoteDetail'){
            //helper.updateScreen(component, event, helper, 'AnotherVehicle');
            helper.updateScreen(component, event, helper, 'RegisteredVehicle');
        }else if( screenName == 'InsuranceFinalDetail'){
            helper.updateScreen(component, event, helper, 'QuoteDetail');
        }else if( screenName == 'PaymentDetail'){
            helper.updateScreen(component, event, helper, 'InsuranceFinalDetail');
        }
    },
    handleBackWatercraftHelper : function(component, event, helper){
          var quoteRecord = component.get("v.quoteRecord");
        var vehicleRecord = component.get("v.vehicleRecord");
        var screenName = component.get("v.screenName");
        console.log('---currentScreen--'+screenName);
        var nextScreen;
        if( screenName == 'aditional_Quick_Quote_Detail'){
            component.set("v.countVehicle", parseInt('1'));
            helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
        }else if( screenName == 'southbound_Quick_Quote_Detail'){
            helper.updateScreen(component, event, helper, 'TerritoryCoverage');
        }else if( screenName == 'ReviewVehicle'){
            var transporates = component.get("v.transporates");
            if( transporates != null && transporates.length > 0 && quoteRecord.Towed_Unit__c == 'Yes'){
                var additional_towunits = transporates.filter(function(item){
                    return item.Street_Legal__c == 'Yes';
                });

                if( additional_towunits != null && additional_towunits.length > 0 ){
                    helper.updateScreen(component, event, helper, 'aditional_Quick_Quote_Detail');
                }else{
                    helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
                }
            }else{
                helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
            } 
        }else if( screenName == 'CompanyInfo'){
            helper.updateScreen(component, event, helper, 'ReviewVehicle');
        }else if( screenName == 'LienHolder'){
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                helper.updateScreen(component, event, helper, 'CompanyInfo');
            }else if( vehicleRecord.Is_Lienholder__c ){
                helper.updateScreen(component, event, helper, 'ReviewVehicle');
            }
        }else if( screenName == 'RegisteredVehicle'){
            nextScreen = 'ReviewVehicle';
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                nextScreen = 'CompanyInfo';
                if( vehicleRecord.Is_Lienholder__c ){
                    nextScreen = 'LienHolder';
                }
            }else if( vehicleRecord.Is_Lienholder__c ){
                nextScreen = 'LienHolder';
            }
            helper.updateScreen(component, event, helper, nextScreen);
        }else if( screenName == 'AnotherVehicle'){
            helper.updateScreen(component, event, helper, 'RegisteredVehicle');
        }else if( screenName == 'QuoteDetail'){
            //helper.updateScreen(component, event, helper, 'AnotherVehicle');
            helper.updateScreen(component, event, helper, 'RegisteredVehicle');
        }else if( screenName == 'InsuranceFinalDetail'){
            helper.updateScreen(component, event, helper, 'QuoteDetail');
        }else if( screenName == 'PaymentDetail'){
            helper.updateScreen(component, event, helper, 'InsuranceFinalDetail');
        }
    },
    showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            mode: 'sticky',
            type: type,
            message: message
        }).fire();
    },
    
    updateScreen : function(component, event, helper, next){
        console.log('----next-->'+next);
        component.set("v.screenName", next);
    },
    
    handleNextMotorCycleHelper : function(component, event, helper){
        var quoteRecord = component.get("v.quoteRecord");
        var vehicleRecord = component.get("v.vehicleRecord");
        
        var screenName = component.get("v.screenName");
        var nextScreen;
        if( screenName == 'InsuranceToday'){
            
        }else if( screenName == 'WhereInsurance'){
        }else if( screenName == 'UserInfo'){
            helper.updateScreen(component, event, helper, 'VehicleOptions');
        }else if( screenName == 'VehicleOptions'){
            helper.updateScreen(component, event, helper, 'TermOptions');
        }else if( screenName == 'TermOptions'){
            helper.updateScreen(component, event, helper, 'TerritoryCoverage');
        }else if( screenName == 'TerritoryCoverage'){
            helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
        }else if( screenName == 'southbound_Quick_Quote_Detail'){
            var rateRecord = component.get("v.rateRecord");
            var rateRecordList = component.get("v.rateRecordList");
            
            if( rateRecordList && rateRecordList.length > 0 ){
                var itemadded = false;
                var tempList = [];
                rateRecordList.forEach(function( item ){
                    if( item.quoteId == quoteRecord.Id ){
                        tempList.push(rateRecord);
                        itemadded = true;
                    }else{
                        tempList.push(item);
                    }
                });
                
                if( !itemadded ) {
                    tempList.push(rateRecord);
                }
                component.set("v.rateRecordList", tempList);
            }else{
                rateRecordList.push(rateRecord);
                component.set("v.rateRecordList", rateRecordList);
            }

            helper.updateScreen(component, event, helper, 'ReviewVehicle');
        }else if( screenName == 'ReviewVehicle'){
            nextScreen = 'RegisteredVehicle';
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                nextScreen = 'CompanyInfo';
            }else if( vehicleRecord.Is_Lienholder__c ){
                nextScreen = 'LienHolder';
            }
            
            helper.updateScreen(component, event, helper, nextScreen);
            
        }else if( screenName == 'CompanyInfo'){
            nextScreen = 'RegisteredVehicle';
            if( vehicleRecord.Is_Lienholder__c ){
                nextScreen = 'LienHolder';
            }
            helper.updateScreen(component, event, helper, nextScreen );
        }else if( screenName == 'LienHolder'){
            helper.updateScreen(component, event, helper, 'RegisteredVehicle' );
        }else if( screenName == 'RegisteredVehicle'){

            var quoteIds = component.get("v.quoteIds");
            if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                quoteIds.push( quoteRecord.Id );
            }
            component.set("v.quoteIds", quoteIds);

            //nextScreen = 'AnotherVehicle';
            nextScreen = 'QuoteDetail';
            helper.updateScreen(component, event, helper, nextScreen);
        }else if( screenName == 'AnotherVehicle'){
            var anotherVehicle = component.get("v.anotherVehicle");
            if( anotherVehicle == 'Yes' ){
                nextScreen = 'VehicleOptions';
                var countVehicle = parseInt(component.get("v.countVehicle"));
                countVehicle += 1;
                component.set("v.countVehicle", countVehicle)
                component.set("v.anotherVehicle", 'No');
                
                component.set("v.quoteRecord", { 'sobjectType': 'Quote__c'});
                component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c'});
                component.set("v.vehicleRecord", { 'sobjectType': 'Vehicle__c'});
                //component.set("v.leadRecord", { 'sobjectType': 'Lead'});
                component.set("v.rateRecord", {});
                component.set("v.driverRecord", { 'sobjectType': 'Driver__c'});
                helper.fetchPolicyData( component, event, helper );
                
            }else{
                nextScreen = 'QuoteDetail';
            }
            
            var quoteIds = component.get("v.quoteIds");
            if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                quoteIds.push( quoteRecord.Id );
            }
            component.set("v.quoteIds", quoteIds);
            
            helper.updateScreen(component, event, helper, nextScreen);
            
        }else if( screenName == 'QuoteDetail'){
            nextScreen = 'InsuranceFinalDetail';
            helper.updateScreen(component, event, helper, nextScreen);
            
        }else if( screenName == 'InsuranceFinalDetail'){
            nextScreen = 'PaymentDetail';
            helper.updateScreen(component, event, helper, nextScreen);
            
        }else if( screenName == 'PaymentDetail'){
            nextScreen = 'PolicyDetail';
            helper.createTransactionRecord(component, event, helper, nextScreen);
        }else if( screenName == 'PolicyDetail'){
        }
    },
    
    
    handleAutoMobileNextHelper : function(component, event, helper){
        try{
            var quoteRecord = component.get("v.quoteRecord");
            console.log("handleAutoMobileNextHelper quoteRecord---> " +JSON.stringify(quoteRecord, null, 4));
            var vehicleRecord = component.get("v.vehicleRecord");
            var screenName = component.get("v.screenName");
            console.log('---currentScreen--'+screenName);
            
            var nextScreen;
            if( screenName == 'InsuranceToday'){
                
            }else if( screenName == 'WhereInsurance'){
            }else if(screenName == 'UserInfo'){
                helper.updateScreen(component, event, helper, 'VehicleOptions');
            }else if( screenName == 'VehicleOptions'){
                helper.updateScreen(component, event, helper, 'TermOptions');
            }else if( screenName == 'TermOptions'){
                helper.updateScreen(component, event, helper, 'TowningAnything');
            }else if( screenName == 'TowningAnything'){
                if( quoteRecord && quoteRecord.Towed_Unit__c && quoteRecord.Towed_Unit__c == 'Yes' ){
                    // nextScreen = 'TowningInfo'; 
                    nextScreen = 'Transporte';
                }else{
                    nextScreen = 'TerritoryCoverage'; 
                }
                helper.updateScreen(component, event, helper, nextScreen);
                
            }/*else if( screenName == 'TowningInfo'){
                var addOtherUnit = component.get("v.addOtherUnit");
                if( addOtherUnit ){
                    helper.updateScreen(component, event, helper, 'Transporte');
                }else{
                    helper.updateScreen(component, event, helper, 'TerritoryCoverage');
                }
            }*/else if( screenName == 'Transporte'){
                helper.updateScreen(component, event, helper, 'TerritoryCoverage');
            }else if( screenName == 'TerritoryCoverage'){
                helper.updateScreen(component, event, helper, 'southbound_Quick_Quote_Detail');
            }else if( screenName == 'southbound_Quick_Quote_Detail'){
                try{
                    var rateRecord = component.get("v.rateRecord");
                    console.log("handleAutoMobileNextHelper rateRecord---> " +JSON.stringify(rateRecord, null, 4));
                    var rateRecordList = component.get("v.rateRecordList");
                    console.log("handleAutoMobileNextHelper rateRecordList---> " +JSON.stringify(rateRecordList, null, 4));
                    if( rateRecordList && rateRecordList.length > 0 ){
                        var itemadded = false;
                        var tempList = [];
                        rateRecordList.forEach(function( item ){
                            if( item.quoteId == quoteRecord.Id ){
                                tempList.push(rateRecord);
                                itemadded = true;
                            }else{
                                tempList.push(item);
                            }
                        });
                        
                        if( !itemadded ) {
                            tempList.push(rateRecord);
                        }
                        component.set("v.rateRecordList", tempList);
                    }else{
                        rateRecordList.push(rateRecord);
                        component.set("v.rateRecordList", rateRecordList);
                    }

                    var transporates = component.get("v.transporates")
                    if( transporates != null && transporates.length > 0 ){
                        var additional_towunits = transporates.filter(function(item){
                            return item.Street_Legal__c == 'Yes';
                        });

                        if( additional_towunits != null && additional_towunits.length > 0 ){
                            var additional_towunit = additional_towunits[0];
                            if( additional_towunit && !( additional_towunit.quoteRecord && additional_towunit.quoteRecord != null ) ){
                                var tempQuote = Object.assign({},quoteRecord); 
                                tempQuote['Id'] = null;
                                if(additional_towunit.Towed_Unit_Type__c 
                                        && ( additional_towunit.Towed_Unit_Type__c == 'Motorcycle' || additional_towunit.Towed_Unit_Type__c == 'ATV' ) ){
                                    tempQuote['Vehicle_Type__c'] = 'Motorcycle/Street Legal ATV';
                                }else if( additional_towunit.Towed_Unit_Type__c && additional_towunit.Towed_Unit_Type__c == 'Camper' ){
                                    tempQuote['Vehicle_Type__c'] = 'RV';
                                }else if( additional_towunit.Towed_Unit_Type__c && additional_towunit.Towed_Unit_Type__c == 'Towed Automobile' ){
                                    tempQuote['Vehicle_Type__c'] = 'Car/Truck/Auto';
                                }else if( additional_towunit.Towed_Unit_Type__c && additional_towunit.Towed_Unit_Type__c == 'Boat' ){
                                    tempQuote['Vehicle_Type__c']= 'Watercraft';
                                    tempQuote['Policy_Type_picklist__c']= 'Watercraft';
                                    tempQuote['Liability__c']= '200,000';
                                    tempQuote['Type_of_Vessel__c']= additional_towunit.Type_of_Vessel__c;
                                    tempQuote['Vessel_Length__c']= additional_towunit.Vessel_Length__c;
                                    tempQuote['Vehicle_Sub_type__c']= 'Watercraft';
                                }else{
                                    tempQuote['Vehicle_Type__c'] = 'Car/Truck/Auto'; 
                                }
                                tempQuote['Vehicle_Value__c'] = additional_towunit.Towed_Unit_Value__c; 

                                additional_towunit['quoteRecord'] = tempQuote;
                            
                                if( additional_towunit && !( additional_towunit.qualitasLiability && additional_towunit.qualitasLiability != null ) ){
                                    additional_towunit['qualitasLiability'] = component.get("v.qualitasLiability")
                                }
                                if( additional_towunit && !( additional_towunit.qualitasMedical && additional_towunit.qualitasMedical != null ) ){
                                    additional_towunit['qualitasMedical'] = component.get("v.qualitasMedical")
                                }
                                if( additional_towunit && !( additional_towunit.chubbLiability && additional_towunit.chubbLiability != null ) ){
                                    additional_towunit['chubbLiability'] = component.get("v.chubbLiability")
                                }
                                if( additional_towunit && !( additional_towunit.chubbMedical && additional_towunit.chubbMedical != null ) ){
                                    additional_towunit['chubbMedical'] = component.get("v.chubbMedical")
                                }
                                if( additional_towunit && !( additional_towunit.mapfreLiability && additional_towunit.mapfreLiability != null ) ){
                                    additional_towunit['mapfreLiability'] = component.get("v.mapfreLiability")
                                }
                                if( additional_towunit && !( additional_towunit.mapfreMedical && additional_towunit.mapfreMedical != null ) ){
                                    additional_towunit['mapfreMedical'] = component.get("v.mapfreMedical")
                                } 
                                if( additional_towunit && !( additional_towunit.qualitasLiablityOnly && additional_towunit.qualitasLiablityOnly != null ) ){
                                    additional_towunit['qualitasLiablityOnly'] = component.get("v.qualitasLiablityOnly")
                                } 
                                if( additional_towunit && !( additional_towunit.chubbLiablityOnly && additional_towunit.chubbLiablityOnly != null ) ){
                                    additional_towunit['chubbLiablityOnly'] = component.get("v.chubbLiablityOnly")
                                } 
                                if( additional_towunit && !( additional_towunit.mapfreLiablityOnly && additional_towunit.mapfreLiablityOnly != null ) ){
                                    additional_towunit['mapfreLiablityOnly'] = component.get("v.mapfreLiablityOnly")
                                } 
                            }
                            component.set('v.additional_towunit', additional_towunit);
                            let checkBoatTowedType = component.get('v.additional_towunit');

                            if(checkBoatTowedType.Towed_Unit_Type__c == 'Boat'){
                                component.set("v.days", checkBoatTowedType.Days_in_Tow__c);
                                if(checkBoatTowedType.Days_in_Tow__c > 30){
                                    console.log("caloag day-- "+ checkBoatTowedType.Days_in_Tow__c)
                                    component.set("v.annualTerm", true);
                                }
                            }
                            helper.updateScreen(component, event, helper, '');
                            component.set("v.countVehicle", parseInt('2'));
                            helper.updateScreen(component, event, helper, 'aditional_Quick_Quote_Detail');
                        }else{
                            helper.updateScreen(component, event, helper, 'ReviewVehicle');
                        }
                    }else{
                        helper.updateScreen(component, event, helper, 'ReviewVehicle');
                    }
                }catch(ex){
                    console.log('---exception--', ex);
                }
            }else if( screenName == 'aditional_Quick_Quote_Detail'){
                var additional_towunit = component.get("v.additional_towunit");
                var rateRecordList = component.get("v.rateRecordList");
                var transporates = component.get("v.transporates");
                if( rateRecordList && rateRecordList.length > 0 && additional_towunit.quoteRecord 
                    && additional_towunit.quoteRecord.Id != null  ){
                    var temptransporates = [];
                    transporates.forEach(function(item){
                        if( additional_towunit.Id == item.Id){
                            temptransporates.push(additional_towunit);
                        }else{
                            temptransporates.push(item);
                        }
                    });
                    component.set("v.transporates", temptransporates);

                    var rateRecord = additional_towunit.rateRecord;
                    var tempList = [];
                    var itemadded = false;
                    rateRecordList.forEach(function( item ){
                        if( item.quoteId == additional_towunit.quoteRecord.Id ){
                            tempList.push(rateRecord);
                            itemadded = true;
                        }else{
                            tempList.push(item);
                        }
                    });
                    if( !itemadded ) {
                        tempList.push(rateRecord);
                    }
                    component.set("v.rateRecordList", tempList);
                }
                 //component.set("v.rateRecordList", rateRecordList);
                helper.updateScreen(component, event, helper, 'ReviewVehicle');

            }else if( screenName == 'ReviewVehicle'){
                var quoteIds = component.get("v.quoteIds");
                var rateRecordList = component.get("v.rateRecordList");
                rateRecordList.forEach(function( item ){
                    if( item.quoteId && !quoteIds.includes( item.quoteId )){
                        quoteIds.push( item.quoteId );
                    }
                });
                component.set("v.quoteIds",quoteIds);
                nextScreen = 'RegisteredVehicle';
                if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                    nextScreen = 'CompanyInfo';
                }else if( vehicleRecord.Is_Lienholder__c ){
                    nextScreen = 'LienHolder';
                }
                helper.updateScreen(component, event, helper, nextScreen);
            }else if( screenName == 'CompanyInfo'){
                nextScreen = 'RegisteredVehicle';
                if( vehicleRecord.Is_Lienholder__c ){
                    nextScreen = 'LienHolder';
                }
                helper.updateScreen(component, event, helper, nextScreen );
            }else if( screenName == 'LienHolder'){
                helper.updateScreen(component, event, helper, 'RegisteredVehicle' );
            }else if( screenName == 'RegisteredVehicle'){
                var quoteIds = component.get("v.quoteIds");
                if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                    quoteIds.push( quoteRecord.Id );
                }
                component.set("v.quoteIds", quoteIds);
                //nextScreen = 'AnotherVehicle';
                nextScreen = 'QuoteDetail';
                helper.updateScreen(component, event, helper, nextScreen);
            }else if( screenName == 'AnotherVehicle'){
                var anotherVehicle = component.get("v.anotherVehicle");
                if( anotherVehicle == 'Yes' ){
                    nextScreen = 'VehicleOptions';
                    var countVehicle = parseInt(component.get("v.countVehicle"));
                    countVehicle += 1;
                    component.set("v.countVehicle", countVehicle)
                    component.set("v.anotherVehicle", 'No');
                    
                    component.set("v.quoteRecord", { 'sobjectType': 'Quote__c'});
                    component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c'});
                    component.set("v.vehicleRecord", { 'sobjectType': 'Vehicle__c'});
                    //component.set("v.leadRecord", { 'sobjectType': 'Lead'});
                    component.set("v.rateRecord", {});
                    component.set("v.driverRecord", { 'sobjectType': 'Driver__c'});
                    helper.fetchPolicyData( component, event, helper );
                    
                }else{
                    nextScreen = 'QuoteDetail';
                }

                var quoteIds = component.get("v.quoteIds");
                if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                    quoteIds.push( quoteRecord.Id );
                }
                component.set("v.quoteIds", quoteIds);

                helper.updateScreen(component, event, helper, nextScreen);

            }else if( screenName == 'QuoteDetail'){
                nextScreen = 'InsuranceFinalDetail';
                helper.updateScreen(component, event, helper, nextScreen);

            }else if( screenName == 'InsuranceFinalDetail'){
                nextScreen = 'PaymentDetail';
                helper.updateScreen(component, event, helper, nextScreen);

            }else if( screenName == 'PaymentDetail'){
                nextScreen = 'PolicyDetail';
                helper.createTransactionRecord(component, event, helper, nextScreen);
            }else if( screenName == 'PolicyDetail'){
            }
        }catch(ex){
            console.log('exce---',ex);
        }
        
    },
    handleNextWatercraftHelper  : function(component, event, helper){
        try{
            var quoteRecord = component.get("v.quoteRecord");
            var vehicleRecord = component.get("v.vehicleRecord");
            
            var screenName = component.get("v.screenName");

            var nextScreen;

            if( screenName == 'aditional_Quick_Quote_Detail'){
                var additional_towunit = component.get("v.additional_towunit");
                var rateRecordList = component.get("v.rateRecordList");
                var transporates = component.get("v.transporates");
                
                if( rateRecordList && rateRecordList.length > 0 && additional_towunit.quoteRecord 
                   && additional_towunit.quoteRecord.Id != null  ){
                    var temptransporates = [];
                    transporates.forEach(function(item){
                        if( additional_towunit.Id == item.Id){
                            temptransporates.push(additional_towunit);
                        }else{
                            temptransporates.push(item);
                        }
                    });
                    component.set("v.transporates", temptransporates);
                    var rateRecord = additional_towunit.rateRecord;
                    var tempList = [];
                    var itemadded = false;
                    rateRecordList.forEach(function( item ){
                        if( item.quoteId == additional_towunit.quoteRecord.Id ){
                            tempList.push(rateRecord);
                            itemadded = true;
                        }else{
                            tempList.push(item);
                        }
                    });
                    if( !itemadded ) {
                        tempList.push(rateRecord);
                    }
                    component.set("v.rateRecordList", tempList);
                }
                helper.updateScreen(component, event, helper, 'ReviewVehicle');
                
            }else if( screenName == 'ReviewVehicle'){
            nextScreen = 'RegisteredVehicle';
            if( vehicleRecord.Is_the_vehicle_registered_to_a_business__c ||  vehicleRecord.Is_the_vehicle_used_for_business_purpose__c){
                nextScreen = 'CompanyInfo';
            }else if( vehicleRecord.Is_Lienholder__c ){
                nextScreen = 'LienHolder';
            }
            
            helper.updateScreen(component, event, helper, nextScreen);
            
        }else if( screenName == 'CompanyInfo'){
                nextScreen = 'RegisteredVehicle';
                if( vehicleRecord.Is_Lienholder__c ){
                    nextScreen = 'LienHolder';
                }
                helper.updateScreen(component, event, helper, nextScreen );
            }else if( screenName == 'LienHolder'){
                helper.updateScreen(component, event, helper, 'RegisteredVehicle' );
            }else if( screenName == 'RegisteredVehicle'){

                var quoteIds = component.get("v.quoteIds");
                if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                    quoteIds.push( quoteRecord.Id );
                }
                component.set("v.quoteIds", quoteIds);
                
                //nextScreen = 'AnotherVehicle';
                nextScreen = 'QuoteDetail';
                helper.updateScreen(component, event, helper, nextScreen);

            }else if( screenName == 'AnotherVehicle'){
                var anotherVehicle = component.get("v.anotherVehicle");
                if( anotherVehicle == 'Yes' ){
                    nextScreen = 'VehicleOptions';
                    var countVehicle = parseInt(component.get("v.countVehicle"));
                    countVehicle += 1;
                    component.set("v.countVehicle", countVehicle)
                    component.set("v.anotherVehicle", 'No');
                    
                    component.set("v.quoteRecord", { 'sobjectType': 'Quote__c'});
                    component.set("v.towedunitRecord", { 'sobjectType': 'Towed_Unit__c'});
                    component.set("v.vehicleRecord", { 'sobjectType': 'Vehicle__c'});
                    //component.set("v.leadRecord", { 'sobjectType': 'Lead'});
                    component.set("v.rateRecord", {});
                    component.set("v.driverRecord", { 'sobjectType': 'Driver__c'});
                    helper.fetchPolicyData( component, event, helper );
                    
                }else{
                    nextScreen = 'QuoteDetail';
                }
                
                var quoteIds = component.get("v.quoteIds");
                if( quoteRecord && quoteRecord.Id && !quoteIds.includes( quoteRecord.Id )){
                    quoteIds.push( quoteRecord.Id );
                }
                component.set("v.quoteIds", quoteIds);
                
                helper.updateScreen(component, event, helper, nextScreen);
                
            }else if( screenName == 'QuoteDetail'){
                nextScreen = 'InsuranceFinalDetail';
                helper.updateScreen(component, event, helper, nextScreen);
                
            }else if( screenName == 'InsuranceFinalDetail'){
                nextScreen = 'PaymentDetail';
                helper.updateScreen(component, event, helper, nextScreen);
                
            }else if( screenName == 'PaymentDetail'){
                nextScreen = 'PolicyDetail';
                helper.createTransactionRecord(component, event, helper, nextScreen);
            }else if( screenName == 'PolicyDetail'){
            }
        }catch(ex){
            console.log('exce---',ex);
        }
    },
    createTransactionRecord : function(component, event, helper, nextScreen){
        var rateRecordList =  component.get("v.rateRecordList");
        var affiliateAccount =  component.get("v.affiliateAccount");
        const action = component.get("c.createTransactionAction");
        
        action.setParams({
            rateRecordList : JSON.stringify(rateRecordList),
            affiliateAccountString : JSON.stringify(affiliateAccount)
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    //helper.showToast('Policy Created Successfully', 'success');
                    
                    helper.updatePolicyRecord( component, event, helper, nextScreen );
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    updatePolicyRecord : function(component, event, helper, nextScreen) {
        
        try{
            var rateRecordList =  component.get("v.rateRecordList");
            
            var leadList = [];
            var quoteIds = [];
            rateRecordList.forEach(function(item){
                leadList.push(item.leadId);
                
                if( item.quoteId != undefined && item.quoteId  != null){
                    quoteIds.push(item.quoteId)
                }
            });
            
            if( quoteIds != null && quoteIds.length == 0 ){
                quoteIds = component.get('v.quoteIds');
            }
            
            const action = component.get("c.updatePolicyAction");
            
            action.setParams({  
                contactRecord : component.get("v.contactRecord"),
                policyRecord : component.get("v.policyRecord"),
                leadIds : JSON.stringify(leadList),
                quoteIds : JSON.stringify(quoteIds)
            });
            
            action.setCallback(this, function(response) {
                
                if (response.getState() === 'SUCCESS') {
                    var response = response.getReturnValue();
                    if( response.success){
                        component.set("v.policyMapList", response.policyMapList);
                        
                        
                        if( nextScreen != null && nextScreen.trim() != '' ){
                            helper.updateScreen(component, event, helper, nextScreen);
                        }
                        
                    }else{
                        helper.showToast(response.message, 'error');
                    }
                } else {
                    helper.showToast(response.getError(), 'error');
                }
            });
            $A.enqueueAction(action);
        }catch( ex ){
            console.log('---ex--',ex);
        }
        
    },
    
    
    /*
     * objectApiName : ObjectName
     * fieldApi : filed Api name
     * fieldAttr : save data in cmp,
     * */
    fetchPicklist : function( component, event, helper, objectApiName, fieldApi, fieldAttr) {
        var action = component.get("c.getPicklistValues");
        
        action.setParams({ 'objectApiName' : objectApiName,
                          'fieldApiName' : fieldApi }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set(fieldAttr, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchPolicyData : function(component, event, helper){
        const action = component.get("c.initialize");
        action.setParams({
            'policyType' : 'NothBound',
            'quoteId' :  component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                var quoteRecord = component.get("v.quoteRecord");
                var response = JSON.parse(response.getReturnValue());

                component.set("v.communityUser", response.loginUser);
                if( response && response.email && response.email != null ){
                    var leadRecord = component.get("v.leadRecord");
                    leadRecord['Email'] = response.email;
                    component.set("v.leadRecord", leadRecord);
                }
                if( response && response.driverAsUser && response.driverAsUser != null ){
                    var driverRecord = component.get("v.driverRecord");
                    var driverAsUser = response.driverAsUser;
                    driverRecord['First_Name__c'] = driverAsUser.FirstName != undefined ? driverAsUser.FirstName : '';
                    driverRecord['Last_Name__c'] = driverAsUser.LastName;
                    driverRecord['Email__c'] = driverAsUser.Email;
                    driverRecord['Phone__c'] = driverAsUser.Phone!= undefined ? driverAsUser.Phone : '';
                    if(driverAsUser.Contact != undefined){
                        driverRecord['Dob__c'] = driverAsUser.Contact.Date_of_Birth__c;
                        quoteRecord['Date_of_Birth__c'] = driverAsUser.Contact.Date_of_Birth__c;
                        driverRecord['Address__c'] = driverAsUser.Contact.MailingStreet;
                        driverRecord['City__c'] = driverAsUser.Contact.MailingCity;
                        driverRecord['State_Province__c'] = driverAsUser.Contact.MailingState;
                        driverRecord['Postal_Code__c'] = driverAsUser.Contact.MailingPostalCode;
                        driverRecord['Country__c'] = driverAsUser.Contact.MailingCountry;

                    }
                    
                    component.set("v.driverRecord", driverRecord);
                }
                //quoteRecord['Underwriter__c'] = 'Chubb';
                //quoteRecord['Coverage__c'] = 'Liability';
                //quoteRecord['Medical__c'] = '5,000/25,000';
                
                if( response && response.quoteRecord){
                    quoteRecord = response.quoteRecord;
                    delete quoteRecord['attributes'];

                    component.set("v.quoteRecord", quoteRecord );
                    component.set("v.screenName", 'southbound_Quick_Quote_Detail');
                } else {
                    var policyType = component.get("v.policyType");
                    quoteRecord['Policy_Type_picklist__c'] = policyType;
                    if( policyType == 'Automobile'){
                        policyType = 'Car/Truck/Auto';
                    }
                    quoteRecord['Vehicle_Type__c'] = policyType;
                    quoteRecord['Territory_Coverage__c'] = 'Entire Mexico';
                    quoteRecord['Territory__c'] = 'Full';
                    
                    component.set("v.quoteRecord",quoteRecord);
                    let iscommunity = component.get("v.communityUser");
                    if(!iscommunity){
                        component.set("v.screenName", 'UserInfo');
                    }else{
                        component.set("v.screenName", 'VehicleOptions');
                    }
                }
                
                
                
                //component.set("v.screenName", 'RegisteredVehicle');
                
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },
})