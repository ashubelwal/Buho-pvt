({
    doInit : function(component, event, helper) {
        helper.initilizeData(component, event, helper);
		helper.getVehicleYears( component, event, helper );
        var iscommunityUser = component.get("v.iscommunityUser");
        var policyType = component.get("v.policyType");
        console.log('--iscommunityUser---'+iscommunityUser);
        console.log('--policyType---'+policyType);
        if( iscommunityUser != undefined && iscommunityUser ){
            component.set("v.newSectionOpen", true);
            helper.getLoginUserVehiclesHelper(component, event, helper);
        }else{
            component.set("v.newSectionOpen", true);
        }

        
        if( policyType != 'RV' && policyType != 'Motorcycle/Street Legal ATV' && policyType != 'Northbound'){
            
            var quoteRecord = component.get("v.quoteRecord");
            if( quoteRecord != undefined && quoteRecord.Vehicle_Year__c != undefined  ){
                helper.getVehicleMakes(component, event, helper);
            }
            if( quoteRecord != undefined && quoteRecord.Vehicle_Year__c != undefined  && quoteRecord.Vehicle_Model__c != undefined  ){
                helper.getVehicleModels(component, event, helper);
            }
            
            var vehicleMake = component.get("v.vehicleMake");
            var vehicleModel = component.get("v.vehicleModel");
            if( vehicleMake != undefined && vehicleMake == '<Manually Enter>'){
                component.set("v.showManualMake", true);
                component.set("v.showManualModel", true);
            }else{
                component.set("v.showManualMake", false);
                component.set("v.showManualModel", false);
            }
            if( vehicleModel != undefined && vehicleModel == '<Manually Enter>'){
                component.set("v.showManualModel", true);
            }else{
                component.set("v.showManualModel", false);
            }
        }else{
            component.set("v.showYearPicklist",false);
        }
    },

    handleSectionToggle : function(component, event, helper) {
        var iscommunityUser = component.get("v.iscommunityUser");
        if( iscommunityUser != undefined && iscommunityUser == true ){
            component.set("v.newSectionOpen", !component.get("v.newSectionOpen"));
        }
    },

    handleChange : function(component, event, helper) {
        var vechileId = event.getParam("value");
        var loginUserVehicles = component.get("v.loginUserVehicles");
        if( loginUserVehicles != undefined && loginUserVehicles.length > 0 && vechileId != undefined && vechileId != ''){
            var filterVechiles = loginUserVehicles.filter(item => {
                return item.Id === vechileId;
            });
            console.log('--filterVechiles---',filterVechiles);
            if( filterVechiles != null && filterVechiles != undefined ){
                component.set("v.vehicleRecord", filterVechiles[0]);

                var policyType = component.get("v.policyType");
                var vehicleRecord = component.get("v.vehicleRecord");
                console.log('--vehicleRecord---',vehicleRecord);

                var quoteRecord = component.get("v.quoteRecord");
                quoteRecord['Vehicle_Year__c'] = vehicleRecord.Year__c;
                if( vehicleRecord.Year__c != null ){
                   helper.getVehicleMakes(component, event, helper);
                }
                quoteRecord['Vehicle_Make__c'] = vehicleRecord.Make__c;
                component.set("v.vehicleMake", vehicleRecord.Make__c);
                if( vehicleRecord.Make__c != null ){
                   helper.getVehicleModels(component, event, helper);
                }
                console.log("Ca log today wednesday --> "+ vehicleRecord.Model__c);
                quoteRecord['Vehicle_Model__c'] = vehicleRecord.Model__c;
                component.set("v.vehicleModel",vehicleRecord.Model__c);
                quoteRecord['Vehicle_Value__c'] = vehicleRecord.Value__c;
                if( vehicleRecord.Salvage_Vehicle__c != undefined && vehicleRecord.Salvage_Vehicle__c){
                    quoteRecord['Salvage_Vehicle__c'] = 'Yes';
                }else{
                    quoteRecord['Salvage_Vehicle__c'] = 'No';
                }

                if( vehicleRecord.Is_the_vehicle_used_for_business_purpose__c != undefined 
                        && vehicleRecord.Is_the_vehicle_used_for_business_purpose__c == true ){
                    quoteRecord['Vehicle_used_for_Business_Purposes__c'] = true;
                }

                if( vehicleRecord.Rental__c != undefined 
                    && vehicleRecord.Rental__c == 'Yes' ){
                    quoteRecord['Is_this_a_Rental_Vehicle__c'] = true;
                }

                if( policyType != 'Northbound' && ( policyType == 'Motorcycle/Street Legal ATV' || policyType == 'Automobile' || policyType == 'RV' )){
                    quoteRecord['Vehicle_Sub_type__c'] = vehicleRecord.Vehicle_Type__c;
                }else if( policyType == 'Northbound' ) {
                    quoteRecord['Vehicle_Type__c'] = vehicleRecord.Vehicle_Type__c;
                }
                component.set("v.quoteRecord", quoteRecord);
                helper.getLoginUserVehiclesHelper(component, event, helper);
                component.set("v.newSectionOpen", true);
            }
        }else{
            component.set("v.vehicleRecord", { 'sobjectType': 'Vehicle__c'});
        }
    },
    
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var quoteRecord = component.get("v.quoteRecord");
        var leadRecord = component.get("v.leadRecord");
        
        
        if( name == "Email"){
            leadRecord[name] = event.getParam("value");
        }/*else if( name == "Salvage_Vehicle__c"){
            var value = event.getParam("checked");
            if( value ){
                quoteRecord[name] = 'Yes';
            }else{
                quoteRecord[name] = 'No';
            }
        }else if( name == "Is_there_a_driver_under_21__c"){
            var value = event.getParam("checked");
            if( value ){
                quoteRecord[name] = 'Yes';
            }else{
                quoteRecord[name] = 'No';
            }
        }*/else if( name == "Vehicle_used_for_Business_Purposes__c" || name == "Is_this_a_Rental_Vehicle__c" ){
            var value = event.getParam("value");
            if( value  == 'Yes'){
                quoteRecord[name] = true;
            }else{
                quoteRecord[name] = false;
            }
            //quoteRecord[name] = event.getParam("checked");
        } else if (name == "Vehicle_Make__c") {
            let value = event.getParam("value");
            if(/^\s/.test(value)){
                value = '';
            } 
             quoteRecord[name] = value;
        } else if (name == "Vehicle_Model__c") {
            let value = event.getParam("value");
            if(/^\s/.test(value)){
                value = '';
            }
                quoteRecord[name] = value;

        } else{
            var value = event.getParam("value");
            if( name == "Date_of_Birth__c" ){
                if( value != null ){
                    var year = parseInt( value.split('-')[0] );
                    var currentYear = (new Date()).getFullYear();
                    quoteRecord['Driver_Age__c'] = (currentYear - year);
                }
            }else if( name == "Vehicle_Year__c" ){
                if( value != null ){
                    var currentYear = (new Date()).getFullYear();
                    
                    var year = parseInt( value );
                    quoteRecord['Vehicle_Age__c'] = (currentYear - year);
                } 
                
            }
            if( ( name == 'Vehicle_Model__combobox' || name == 'Vehicle_Make__combobox' ) && value == '<Manually Enter>'){
                value = null;
            }else{
                quoteRecord[name] = value;
            }
            
        }
        if( name == 'Vehicle_Year__c'){
            quoteRecord['Vehicle_Make__c'] = null;
            quoteRecord['Vehicle_Model__c'] = null;
            component.set("v.vehicleMake", null);
            component.set("v.vehicleModel", null);
        }else if( name == 'Vehicle_Make__combobox' ){
            quoteRecord['Vehicle_Model__c'] = null;
            component.set("v.vehicleModel", null);
        }
        //console.log('--quoteRecord---', JSON.stringify(quoteRecord));
        component.set("v.quoteRecord", quoteRecord);
        component.set("v.leadRecord", leadRecord);

        var policyType = component.get("v.policyType");
        var showManualMake = component.get("v.showManualMake");
        var showManualModel = component.get("v.showManualModel");
        if( policyType != 'RV' && policyType != 'Motorcycle/Street Legal ATV' && policyType != 'Northbound'){
            var value = event.getParam("value");
            if( name == 'Vehicle_Year__c'){
                component.set("v.disableMake", true);
                helper.getVehicleMakes( component, event, helper );
            }else if( name == 'Vehicle_Make__combobox'){
                component.set("v.disableModel", true);
                if( value != '<Manually Enter>'){
                    component.set("v.vehicleModel", null);
                    component.set("v.showManualMake", false);
                    component.set("v.showManualModel", false);
                   	helper.getVehicleModels( component, event, helper ); 
                }else{
                    component.set("v.vehicleModel", '<Manually Enter>');
                    component.set("v.showManualMake", true);
                    component.set("v.showManualModel", true);
                }
            }else if( name == 'Vehicle_Model__combobox'){
                if( value == '<Manually Enter>'){
                    component.set("v.showManualModel", true);
                }else{
                    component.set("v.showManualModel", false);
                }
            }
        }
        console.log('--vehicleModel--', component.get("v.vehicleModel"));

        if( name == 'Vehicle_Value__c' && policyType != 'Northbound' ){
            //helper.checkRateExistHelper(component, event, helper);
        }
        
    },

    handleDateOfBirth : function(component, event, helper) {
        var quoteRecord = component.get("v.quoteRecord");
        console.log('--handleDateOfBirth--');
        if( quoteRecord != null && quoteRecord.Date_of_Birth__c != undefined && quoteRecord.Date_of_Birth__c != null ){
            var dateOfBitrh = new Date( quoteRecord.Date_of_Birth__c  );
            var year = dateOfBitrh.getFullYear();
            var currentYear = (new Date()).getFullYear();
            console.log('--currentYear--',currentYear);
            quoteRecord['Driver_Age__c'] = (currentYear - year);
            component.set("v.quoteRecord", quoteRecord);
        }
    },

    updateLiabilityValue : function(component, event, helper) {
        component.set("v.liabiltyOnly", event.getParam("checked"));
    },

    updateVehicleValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var value = event.getParam("checked");
        var vehicleRecord = component.get("v.vehicleRecord");
        if( name == "Rental__c"){
            if( value ){
                vehicleRecord[name] = 'Yes';
            }else{
                vehicleRecord[name] = 'No';
            }
        }else{
            vehicleRecord[name] = value;
        }
        component.set("v.vehicleRecord",vehicleRecord);
    },

    onNextClick : function(component, event, helper) {
        var quoteRecord = component.get("v.quoteRecord");
        var policyType = component.get("v.policyType");
        var vehicleMake = component.get("v.vehicleMake");
        var vehicleModel = component.get("v.vehicleModel");
        var customValidateField = component.find("customValidateField");
        console.log('--customValidateField--',customValidateField);
        if( policyType != 'RV' && policyType != 'Motorcycle/Street Legal ATV' && policyType != 'Northbound'){
            if( vehicleMake != undefined && vehicleMake != '<Manually Enter>'){
                quoteRecord['Vehicle_Make__c'] =  vehicleMake;              
            }
            if( vehicleModel != undefined && vehicleModel != '<Manually Enter>'){
                quoteRecord['Vehicle_Model__c'] =  vehicleModel;              
            }
            component.set("v.quoteRecord",quoteRecord);
        }
        
        var liabiltyOnly = component.get("v.liabiltyOnly");
        var restrictliabiltyOnly = component.get("v.RestrictliabiltyOnly");

        if( policyType != undefined && policyType.toLowerCase() == 'northbound' ){
            var driverage = quoteRecord['Driver_Age__c'];
            if( driverage != undefined && driverage != null && ( driverage < 16 || driverage > 85 )){
                if( driverage < 16 ){
                    helper.showToast('We do not have a program available for drivers under age 16.  Please email broker@mexinsurance.com to make a special request.', 'error');
                }else{
                    helper.showToast('We do not have a program available for drivers over the age of 84.  Please email broker@mexinsurance.com to make a special request.', 'error');
                }
                return ;
            }
        }else{
            if( liabiltyOnly != null && liabiltyOnly == false ){
                helper.checkRateExistHelper(component, event, helper);
            }
        }
        var iscommunityUser = component.get("v.iscommunityUser");
        if( policyType.toLowerCase() == 'northbound' || liabiltyOnly != null && liabiltyOnly == true ){
            var allValid = helper.validateInputFields(component, event, helper);
            if( customValidateField != null && customValidateField != undefined ){
                allValid = ( allValid && customValidateField.validateFields());
            }
            var newSectionOpen = component.get("v.newSectionOpen");
            var vehicleRecord = component.get("v.vehicleRecord");
            if( allValid && newSectionOpen ){
                if( iscommunityUser != undefined && !iscommunityUser ){
                    helper.checkAllreadyUser(component, event, helper);
                }else{
                    helper.handleVehicleQuote(component, event, helper, 'TermOptions');
                }
            }else if( allValid && vehicleRecord.Id != null ){
                if( iscommunityUser != undefined && !iscommunityUser ){
                    helper.checkAllreadyUser(component, event, helper);
                }else{
                    helper.handleVehicleQuote(component, event, helper, 'TermOptions');
                }
            }
        }
    }
})