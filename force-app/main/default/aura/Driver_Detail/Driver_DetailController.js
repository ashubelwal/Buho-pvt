({
    doInit: function (component, event, helper) {
        helper.initializeData(component, event, helper);
    },

    handleSectionToggle : function (component, event, helper) {
        var iscommunityUser = component.get("v.isCommunityUser");
        if( iscommunityUser != undefined && iscommunityUser == true ){
            component.set("v.newSectionOpen", !component.get("v.newSectionOpen"));
            console.log('--0000--'+component.get("v.newSectionOpen"));
        }
    },

    handleChange : function (component, event, helper) {
        var driverId = event.getParam("value");
        var loginUserDrivers = component.get("v.loginUserDrivers");
        if( loginUserDrivers != undefined && loginUserDrivers.length > 0 && driverId != undefined){
            var driverlist = loginUserDrivers.filter(item => {
                return item.Id === driverId;
            });
            if( driverlist != null && driverlist != undefined ){
                component.set("v.driverRecord", driverlist[0]);
                var leadRecord = component.get('v.leadRecord');
                var driverRecord = component.get('v.driverRecord');
                console.log('---driverRecord--',driverRecord);
                leadRecord['FirstName'] = driverRecord.First_Name__c;
                leadRecord['LastName'] = driverRecord.Last_Name__c;
                leadRecord['Phone'] = driverRecord.Phone__c;
                leadRecord['Street'] = driverRecord.Address__c;
                leadRecord['City'] = driverRecord.City__c;
                leadRecord['Country'] = driverRecord.Country__c;
                leadRecord['State'] = driverRecord.State_Province__c;
                leadRecord['PostalCode'] = driverRecord.Postal_Code__c;
                leadRecord['Date_of_Birth__c'] = driverRecord.Dob__c;
                component.set("v.countryPicklistValue", driverRecord.Country__c);
                 
                component.set("v.leadRecord",leadRecord);
                 

                var customValidateField = component.find("customValidateField");
                if( customValidateField != null && customValidateField != undefined ){
                    customValidateField.updateDateOnChange();
                }
            }
        }else{
            component.set("v.driverRecord", { 'sobjectType': 'Driver__c'});
        }
    },

    updateLeadValue: function (component, event, helper) {
        let name = event.getSource().get("v.name");
        let value = event.getParam("value");
        let leadRecord = component.get("v.leadRecord");
         if(/^\s/.test(value)){
                value = '';
         }
        if (name === 'Country') {
            leadRecord['State'] = undefined;
        }else if( name === 'Phone' ){
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        }
        leadRecord[name] = value;
        component.set("v.leadRecord", leadRecord);
        helper.setInputComponentsVisibility(component, event, helper);
    },

    onNextClick: function (component, event, helper) {
        var isCommunityUser = component.get("v.isCommunityUser");
        var driverRecord = component.get("v.driverRecord");
        if( driverRecord != undefined && driverRecord.Id == undefined ){
            var allVal = helper.validateInputFields(component, event, helper);
            let allValCustDt = component.find("customValidateField").validateFields();
            allVal = (allVal && allValCustDt);
            
            if ( allVal ) {
                if( isCommunityUser != undefined && !isCommunityUser) {
                    helper.checkAllreadyUser(component, event, helper);
                }else{
                    helper.onNextClickHelper(component, event, helper);
                }
            }
        }else if( driverRecord != undefined && driverRecord.Id != undefined ){
            let drivers = component.get("v.drivers");
            if( drivers == undefined || drivers.length == 0 ){
                drivers.push(driverRecord);
                component.set("v.drivers", drivers);
            }
            if( isCommunityUser != undefined && !isCommunityUser) {
                helper.checkAllreadyUser(component, event, helper);
            }else{
                helper.onNextClickHelper(component, event, helper);
            }
        }
    }
})