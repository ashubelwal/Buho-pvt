({
	doInit : function(component, event, helper) {
        var policyId = sessionStorage.getItem( 'policyId' );  
        console.log('---policyId---'+policyId);
        //policyId = 'a0H2i000003HjtZ';
        console.log('*****doInit*****');
        var recordId = component.get("v.recordId");
        if( recordId == undefined ){
            component.set("v.recordId",policyId);
        }
		console.log('--recordId---',component.get("v.recordId"));
        component.set("v.countVehicle", parseInt('1'));
        //component.set("v.screenName", 'TermOptions');
        helper.initilizeData(component, event, helper);
		
    },

	handleNext : function(component, event, helper){
        try{
            var iscloneConditionPass = component.get("v.iscloneConditionPass");
        
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
    
            component.set("v.iscloneConditionPass", iscloneConditionPass);
            console.log('---iscloneConditionPass--'+iscloneConditionPass);
            helper.handleNextHelper(component, event, helper);
        }catch( ex ){
            console.log('--ex-', ex);
        }
    },

    onPayamneNext : function(component, event, helper){
        helper.createNewPolicy(component, event, helper);
    },

    handleBack : function(component, event, helper){
        helper.handleBackHelper(component, event, helper); 
    },

    showSpinner : function (component, event, helper) {
        component.set("v.spinner", true);
    },
    
    hideSpinner : function (component, event, helper) {
        component.set("v.spinner", false);
    },
})