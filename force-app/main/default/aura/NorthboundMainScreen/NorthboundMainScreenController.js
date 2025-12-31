({
    /*
     * 1. What would you like to insure today? : screenName == InsuranceToday
        2. Where would you like your vehicle insurance to apply? : screenName == WhereInsurance
        3. Please fill in vehicle options below? : screenName == VehicleOptions
        4. Please select term options? : screenName == TermOptions
        5. Get your quick quote! : screenName == QuickQuote
        6. Review vehicle information : screenName == ReviewVehicle
        7. Are you towning anything? : screenName == TowningAnything
        8. Tell us more about what you're towning? : screenName == TowningInfo
        9. Company information : screenName == CompanyInfo
        10. Owner of the Registered Vehicle : screenName == RegisteredVehicle
        11. Would you like to insure another vehicle? : screenName == AnotherVehicle
        12.  Quote Detail 1 Page : screenName == QuoteDetail
        13. Online Insurance Final Details : screenName == InsuranceFinalDetail
        14. Let's tackle the Payment now : screenName == PaymentDetail
        14. lastPage : screenName == PolicyDetail
     * 
     * */
    doInit : function(component, event, helper) {
        component.set("v.policyType", "Northbound");
        //component.set("v.policyType", "Driver License");
        //component.set("v.screenName", 'QuickQuote'); 
        //component.set("v.screenName", 'RegisteredVehicle');
        component.set("v.countVehicle", parseInt('1'));
        
        helper.initilizeData(component, event, helper);
    },
    
    
    handleNext : function(component, event, helper){
        helper.handleNextHelper(component, event, helper);
    },

    handleBack : function(component, event, helper){
        helper.handleBackHelper(component, event, helper);
    },

    showSpinner : function (component, event, helper) {
        var spinner = component.get("v.spinner");
        if( !spinner ){
            component.set("v.spinner", true);
        }
    },
    
    hideSpinner : function (component, event, helper) {
        var spinner = component.get("v.spinner");
        if( spinner ){
            component.set("v.spinner", false);
        }
    },
})