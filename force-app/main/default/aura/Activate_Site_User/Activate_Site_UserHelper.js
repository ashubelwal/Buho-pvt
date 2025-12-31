({
	validateInputFields : function(component, event, helper){
        var allValid = true; 
        try{
            allValid = component.find('validateField')
            
            let checkValid = allValid.reportValidity();
                return checkValid.checkValidity();
            
        }catch(ex){
            
        }
        return allValid;
    },

    showError: function(errorList) {
        if (errorList.length > 0 && errorList[0].message) {
            this.showToast(errorList[0].message, 'error');
        }
    },

     showToast: function(message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
     reloadPaeFirstTime: function(component, event, helper){
       if(!window.location.hash) {
        window.location = window.location + '#s';
        window.location.reload();
    }
    },
    

})