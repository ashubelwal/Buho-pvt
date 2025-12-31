({
    doInit : function(component, event, helper) {
        console.log('here----');
    },
    
    onGroup : function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        component.set("v.insuranceItem", selected);
    },
    
    onGroup2 : function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        component.set("v.insuranceType", selected);
    },
    
    handleNextClick: function(component, event, helper) {
        event.preventDefault();  
        var screenName = component.get("v.screenName");
        if( screenName == "lineInsurance"){
            var insuranceItem =  component.get("v.insuranceItem");
            console.log("--insuranceItem--"+insuranceItem);
            
            if( insuranceItem == 'VEHICLE'){
                component.set("v.screenName", 'needInsurance');
            }else if( insuranceItem == 'HOUSE' ){
                var navService = component.find("navService");
                var pageReference = {
                    type: "comm__namedPage", 
                    attributes: {
                        pageName: 'quick-home' // pageName must be lower case
                    }
                };
                navService.navigate(pageReference);
            }else if( insuranceItem == 'WATERCRAFT'){
                console.log("--WATERCRAFT--");
                var navService = component.find("navService");
                var pageReference = {
                    type: "comm__namedPage",
                    attributes: {
                        pageName: 'watercraft'
                    }
                };

                navService.navigate(pageReference);
            }
            //
        }else if( screenName == "needInsurance" ){
            var insuranceType = component.get("v.insuranceType");
            console.log('--insuranceType---'+insuranceType);
            
            try{
                var navService = component.find("navService");
                var pageReference;
                if( insuranceType == 'Northbound'){
                    pageReference = {
                        type: "comm__namedPage", 
                        attributes: {
                            pageName: 'northbound' // pageName must be lower case
                        }
                    };

                    let affiliateNumber = helper.getUrlParameter('aid');

                    if (affiliateNumber != "") {
                        pageReference.state = {
                            c__aid: affiliateNumber
                        };
                    }
                }else if( insuranceType == 'DRIVER LICENSE'){
                    pageReference = {
                        type: "comm__namedPage", 
                        attributes: {
                            pageName: 'drivers-license' // pageName must be lower case
                        }
                    };
                }else if( insuranceType == 'Car/Truck/Auto' || insuranceType == 'RV' || insuranceType == 'Motorcycle' ){
                    var policyType = '';
                    
                    var pagename = '';
                    if( insuranceType == 'Car/Truck/Auto'){
                        pagename = 'automobile';
                    }else if( insuranceType == 'RV'){
                        pagename = 'rv';
                    }else  if( insuranceType == 'Motorcycle'){
                        pagename = 'motorcycle';
                    }
                    
                    pageReference = {
                        type: "comm__namedPage", 
                        attributes: {
                            pageName: pagename // pageName must be lower case
                        }
                    };
                }
                navService.navigate(pageReference);
            }catch(ex){
                console.log(ex);
            }
            
        }
    },
    
    showSpinner : function (component, event, helper) {
        component.set("v.spinner", true);
    },
    
    hideSpinner : function (component, event, helper) {
        component.set("v.spinner", false);
    },
})