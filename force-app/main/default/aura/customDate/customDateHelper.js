({
    initData : function( component, event, helper ) {
        helper.calculateDateOptions( component, event, helper );
    },
    
    calculateDateOptions: function( component, event, helper ) {
        var currentDate = new Date();
        let currentYear = currentDate.getFullYear()-16;
         let startFrom = currentDate.getFullYear()-90;
        let currentMonth = currentDate.getMonth();
        let currentDay = currentDate.getDate();
        var years = [];
        for( startFrom ; startFrom <= currentYear; startFrom++) {
            years.push({
                'label' : startFrom.toString(),
                'value': startFrom.toString()
            });
        }
        component.set("v.years",years);
        
        var months = [];
        for(var i= 1; i <= 12; i++ ){
            var mon = i;
            if( i <= 9 ){
                mon = '0'+i.toString();
            }
            mon = mon.toString()
            months.push({
                'label' : mon,
                'value': i.toString()
            });
        }
        component.set("v.months",months);
        
        var days = [];
        for(var i= 1; i <= 31; i++ ){
            var dy = i;
            if( i <= 9 ){
                dy = '0'+i.toString();
            }
            dy = dy.toString()
            days.push({
                'label' : dy,
                'value': i.toString()
            });
        }
        component.set("v.days",days);
        
        helper.setInitDate( component, event, helper );
    },
    
    setInitDate : function( component, event, helper ) {
        var custDate = component.get("v.custDate");
        if( custDate != null && custDate != undefined ){
            custDate = new Date(custDate);
            console.log('-custDate---',custDate);
            
            let currentYear = custDate.getFullYear();
            let currentMonth = custDate.getMonth();
            let currentDay = custDate.getDate();
            console.log('-year---'+currentYear+'-month--'+currentMonth+'--day--'+currentDay);
            
            
            component.set("v.day", currentDay.toString());
            component.set("v.month", (currentMonth + 1).toString());
            component.set("v.year", currentYear.toString());
        }
    },

    validateInputFields: function (component, event, helper) {
        return component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    },
})