({
	doInit : function(component, event, helper) {
		helper.initilizeData(component, event, helper);
        helper.getVehicleYears( component, event, helper );
	},
    
    updateValue : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var quoteRecord = component.get("v.quoteRecord");
        var leadRecord = component.get("v.leadRecord");
       

        if( name == "Commercial_Vessel" || name == "Older_Vessel" || name == "Racing" || name == "Vessel_for_Hire" ){
            let attributeName = "v." + name;
            component.set(attributeName, event.getParam("checked"));

            return;
        } else if( name == "Date_of_Birth__c" ){
            var value = event.getParam("value");
            var year = parseInt( value.split('-')[0] );
            var currentYear = (new Date()).getFullYear();
            quoteRecord['Driver_Age__c'] = (currentYear - year);
            
            quoteRecord[name] = value;
            leadRecord[name] = value;
        } else if( name == "Vehicle_Year__c" ){
            var value = event.getParam("value");
            var currentYear = (new Date()).getFullYear();
            var year = parseInt( value );
            
            quoteRecord[name] = value;
            quoteRecord['Vehicle_Age__c'] = (currentYear - year);
        }else if( name == "Vehicle_Make__c"){
            var value = event.getParam("value");
            if(/^\s/.test(value)){
                value = '';
            }
            quoteRecord[name] = value;
        }else if( name == "Vehicle_Model__c"){
            var value = event.getParam("value");
            if(/^\s/.test(value)){
                value = '';
            }
            quoteRecord[name] = value;
        } else if( name == "Email"){
            leadRecord[name] = event.getParam("value");
        } else if( name == "Type_of_Vessel__c"){
            var value = event.getParam("value");
            console.log('Value --'+ value);
            quoteRecord[name] = event.getParam("value");
            quoteRecord['Vessel_Length__c'] = '';
            
            helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths', false);
        }/* else if(
            name == "Is_the_Maximum_Speed_more_than_50_mph__c" ||
            name == "Any_Boat_Operator_Under_22__c" ||
            name == "Is_the_owner_living_in_Mexico__c"
        ) {
            var value = event.getParam("checked");
            if( value ){
                quoteRecord[name] = 'Yes';
            }else{
                quoteRecord[name] = 'No';
            }
        }*/ else {
            quoteRecord[name] = event.getParam("value");
        }
                
        component.set("v.quoteRecord", quoteRecord);
        component.set("v.leadRecord", leadRecord);
        
    },

    handleDateOfBirth : function(component, event, helper) {
        var quoteRecord = component.get("v.quoteRecord");
        console.log('--handleDateOfBirth--');
        if( quoteRecord != null && quoteRecord.Date_of_Birth__c != undefined && quoteRecord.Date_of_Birth__c != null ){
            var dateOfBitrh = new Date( quoteRecord.Date_of_Birth__c  );
            var year = dateOfBitrh.getFullYear();
            var currentYear = (new Date()).getFullYear();
            quoteRecord['Driver_Age__c'] = (currentYear - year);
            component.set("v.quoteRecord", quoteRecord);
        }
    },

    handleChange : function(component, event, helper) {
        var waterCraftId = event.getParam("value");
        let filterWaterCrafts = [];
        
        var loginUserWaterCrafts = component.get("v.loginUserWaterCrafts");
        console.log('-waterCraftId--'+waterCraftId);
        console.log('-loginUserWaterCrafts--'+JSON.stringify(loginUserWaterCrafts, null, 4));
        if( loginUserWaterCrafts != undefined && loginUserWaterCrafts.length > 0 && waterCraftId != undefined && waterCraftId != ''){
           // filterWaterCrafts = loginUserWaterCrafts.filter(item => {
            //    return item.Id === waterCraftId;
           // });
            loginUserWaterCrafts.map((data)=>{
                if( data.Id === waterCraftId){
                	filterWaterCrafts.push(data);
            	}
                                     });
            console.log('---filterWaterCrafts--'+JSON.stringify(filterWaterCrafts, null, 4));
            if( filterWaterCrafts != null && filterWaterCrafts != undefined){
                component.set("v.waterRecord", filterWaterCrafts[0]);
                var waterRecord = component.get("v.waterRecord");
                console.log('---waterRecord--'+JSON.stringify(waterRecord, null, 4));
                var quoteRecord = component.get("v.quoteRecord");
                quoteRecord['Type_of_Vessel__c'] = waterRecord.Type_of_Vessel__c;
                if(waterRecord.Type_of_Vessel__c == 'Personal Watercraft (Jet Ski)'){
                  quoteRecord['Vessel_Length__c'] = '' ;  
                }else{
                    quoteRecord['Vessel_Length__c'] = waterRecord.Vessel_Length__c;
                }
                quoteRecord['Vehicle_Year__c'] = waterRecord.Year__c;
                
                var currentYears = (new Date()).getFullYear();
                var year = parseInt( waterRecord.Year__c );
                
                quoteRecord['Vehicle_Age__c'] = (currentYears - year);
                quoteRecord['Vehicle_Make__c'] = waterRecord.Make__c;
                quoteRecord['Vehicle_Model__c'] = waterRecord.Model__c;
                quoteRecord['Vehicle_Value__c'] = waterRecord.Value__c;
                component.set("v.quoteRecord", quoteRecord);
				component.set("v.newSectionOpen", true);
                helper.getCurrentUserAllWaterCraft( component, event, helper );
                if( waterRecord.Type_of_Vessel__c != undefined && waterRecord.Type_of_Vessel__c != 'Personal Watercraft (Jet Ski)'){
                  helper.getDependentPicklistValues(component, event, helper, 'Type_of_Vessel__c', 'Vessel_Length__c', 'v.vesselLengths', false);
                }
            }
        }else{
            component.set("v.quoteRecord", { 'sobjectType': 'Quote__c'});
        }
    },

    handleSectionToggle : function(component, event, helper) {
        var iscommunityUser = component.get("v.communityUser");
        if( iscommunityUser != undefined && iscommunityUser == true ){
            component.set("v.newSectionOpen", !component.get("v.newSectionOpen"));
        }
    },

    onNextClick : function(component, event, helper) {
        var allValid = helper.validateInputFields(component, event, helper);
        var customValidateField = component.find("customValidateField");
        if( customValidateField != null && customValidateField != undefined ){
            allValid = ( allValid && customValidateField.validateFields());
        }
        var minYear = component.get("v.minYear");
        var maxYear = component.get("v.maxYear");
        var value = component.get("v.quoteRecord").Vehicle_Year__c;
        if( allValid && value != undefined && value != '' && parseInt(value) > maxYear ){
            helper.showToast('Vessels more than 40 years old are not eligible for coverage.', 'error');
            return;
        }else if( allValid && value != undefined && value != '' && parseInt(value) <  minYear) {
            helper.showToast('Vessels more than 40 years old are not eligible for coverage.', 'error');
            return;
        }

        var communityUser = component.get("v.communityUser");
        var newSectionOpen = component.get("v.newSectionOpen");
        var waterRecord = component.get("v.waterRecord");
    		
        console.log("communityUser : "+communityUser)
        
        if( allValid && newSectionOpen ){
            if( communityUser != undefined && !communityUser){
                console.log("This 1st condition");
                helper.checkAllreadyUser(component, event, helper);
            }else{
                console.log("This 1st else condition");
                helper.handleClickNext(component, event, helper, 'TermOptions');
            }
            
        }else if( waterRecord.Id != null && allValid ){
            if( communityUser != undefined && !communityUser){
                 console.log("This 2nd else condition");
                helper.checkAllreadyUser(component, event, helper);
            }else{
                 console.log("This 2nd else condition");
                helper.handleClickNext(component, event, helper, 'TermOptions');
            }
        }
    }
})