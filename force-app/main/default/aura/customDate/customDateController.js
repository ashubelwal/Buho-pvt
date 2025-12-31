({
	doInit : function(component, event, helper) {
		helper.initData(component, event, helper);
	},
    
    handleChange : function(component, event, helper) {
        var day = component.get("v.day");
        var month = component.get("v.month");
        var year = component.get("v.year");
        
        try{
            const d = new Date(parseInt(year), (parseInt(month) - 1), parseInt(day), 0, 0, 0, 0);
            console.log('-d--',d);
            var errorBody = component.find("errorBody");
            var element = document.getElementById("myId");
            if( d != undefined && d != 'Invalid Date') {
                let currentYear = d.getFullYear();
                let currentMonth = (d.getMonth() + 1);
                let currentDay = d.getDate();
                console.log('-year---'+currentYear+'-month--'+currentMonth+'--day--'+currentDay);

                if( day == currentDay.toString() && month == currentMonth.toString() && year == currentYear.toString() ){
                    component.set("v.message", null );
                    component.set("v.custDate", $A.localizationService.formatDate(d, "YYYY-MM-DD"));
                    $A.enqueueAction(component.get("v.onDateChange"));
                }else{
                    component.set("v.message", 'Invalid Date' );
                    component.set("v.day", null );
                }
            }
        }catch(ex){
            console.log('--ex--',ex);
        }
    },

    updateDateOnChangeAction : function(component, event, helper) {
        helper.setInitDate( component, event, helper );
    },

    vaildateField : function(component, event, helper) {
        return helper.validateInputFields(component, event, helper);
    },
})