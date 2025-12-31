({
	doInit : function(component, event, helper) {
		helper.initializeData(component, event, helper);
	},

    onNextClick : function(component, event, helper) {

        let communityUser = component.get("v.communityUser");
        let quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());

        let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
        endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());

        var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        if( Difference_In_Days != null && Difference_In_Days > 365 ){
            helper.showToast('Total days cannot equal more than 365', 'error');
            return ;
        }

        if (Difference_In_Days != null && Difference_In_Days == 0) {
            helper.showToast('Total days cannot be less than 1', 'error');
            return;
        }

        let allValid = helper.validateInputFields(component, event, helper);
        if( allValid ){
            var renewPolicy = component.get("v.renewPolicy");
            if( renewPolicy != undefined && renewPolicy == true ){
                helper.updateQuoteHelper(component, event, helper);
                $A.enqueueAction(component.get("v.onNextClick"));
                return;
            }

            helper.updateQuoteHelper(component, event, helper);
            if (!communityUser) {
                let selectedProduct = {};
                selectedProduct.item_name = "Northbound";
                selectedProduct.item_id = "0121C00000102F5QAI-Chubb";
                selectedProduct.price = quoteRecord.Quote_Value__c;
                selectedProduct.item_brand= "MexInsurance";
                selectedProduct.item_category = quoteRecord.Vehicle_Type__c;
                selectedProduct.item_category2 = quoteRecord.Term_Days__c > 0 && quoteRecord.Term_Days__c <= 30 ? "Daily" : quoteRecord.Term_Days__c > 30 && quoteRecord.Term_Days__c <= 90 ? "90 Day" : quoteRecord.Term_Days__c > 90 && quoteRecord.Term_Days__c <= 180 ? "Semi-Annual(Half a Year)" : "Annual(One Year)";
                selectedProduct.item_category3 = quoteRecord.Territory_Coverage__c;
                selectedProduct.item_category4 = "Chubb";
                selectedProduct.item_variant = quoteRecord.Coverage__c;
                selectedProduct.item_list_name = "Northbound Quote Page";
                selectedProduct.quantity = 1;
                selectedProduct.index = 1;

                console.log("Selected Product --->",  JSON.stringify(selectedProduct, null, 4));
                window.dataLayer.push({ ecommerce: undefined });
                window.dataLayer.push({
                    event: "select_item",
                    ecommerce: {
                        items: [selectedProduct]
                    }
                });

               // Lead create for new user
               helper.saveQuoteHelper(component, event, helper, 'purchase');  
            }
            
        }
    },

    updatePhoneValue : function(component, event, helper) {
        var value = event.getParam("value");
        if( value && value.length > 0 ){
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        }
        component.set("v.phoneNumber", value);
    },
    
    saveQuote : function(component, event, helper) {
        let quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());

        let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
        endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());

        var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        if( Difference_In_Days != null && Difference_In_Days > 365 ){
            helper.showToast('Total days cannot equal more than 365', 'error');
            return ;
        }
        
        if (Difference_In_Days != null && Difference_In_Days == 0) {
            helper.showToast('Total days cannot be less than 1', 'error');
            return;
        }
        
        let allValid = helper.validateInputFields(component, event, helper);
        if( allValid ){
            helper.checkalreadyExistUser( component, event, helper );
            //helper.saveQuoteHelper(component, event, helper);
        }
        
    },
    
    highlightView : function (component, event, helper) {
        component.set("v.highlightView", true);
        component.set("v.normalView", false);
    },
    
    normalView : function (component, event, helper) {
        component.set("v.normalView", true);
        component.set("v.highlightView", false);
    },
    
    updateLiability : function (component, event, helper) {
        try{
            var policyType = component.get("v.policyType");
            var liabilityOptions = [];
            if (policyType === 'Northbound') {
                liabilityOptions = ['100,000', '200,000', '300,000'];
            } else if (policyType === 'Driver License') {
                liabilityOptions = ['300,000', '500,000'];
            }
            
            
            var type = event.target.dataset.type;
            var liability = component.get("v.liability");
            var length = liabilityOptions.length;
    
            var updatelibality;
            if( type && type == 'high' ){
                var index = liabilityOptions.indexOf(liability);
                if( length != index ){
                    updatelibality = liabilityOptions[index+1];
                }
            }else if( type && type == 'low' ){
                var index = liabilityOptions.indexOf(liability);
                if( index != 0 ){
                    updatelibality = liabilityOptions[index-1] ;
                }
            }
            if( updatelibality != undefined){
                component.set("v.liability", updatelibality);
                helper.getDataFromRateDataTable( component, event, helper );
            }
            
        }catch( ex ){
            console.log('--ex--', ex);
        }
        
    },
    
    fetchRateData :function (component, event, helper) {
        let name = event.getSource().get("v.name");
        
        let quoteRecord = component.get("v.quoteRecord");
        let value = event.getParam("value");
        quoteRecord[name] =  value;
        component.set("v.quoteRecord", quoteRecord);

        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']); 
        startDayForCoverage = new Date (startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());

        let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']); 
        endDayForCoverage = new Date (endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());

        if( startDayForCoverage != undefined ){
            var  endMinDate = startDayForCoverage;
            endMinDate = endMinDate.setDate(endMinDate.getDate() + 1);
            component.set("v.endMinDate", $A.localizationService.formatDate(endMinDate, "YYYY-MM-DD"));
        }
        

        var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        if( Difference_In_Days != null && Difference_In_Days > 365 ){
            helper.showToast('Total days cannot equal more than 365', 'error');
            return ;
        }
        
        if (Difference_In_Days != null && Difference_In_Days == 0) {
            helper.showToast('Total days cannot be less than 1', 'error');
            return;
        }
        helper.getDataFromRateDataTable( component, event, helper );
    },
    
    openSaveQuoteModal : function(component, event, helper) {
        let communityUser = component.get("v.communityUser");
        let leadRecord = component.get("v.leadRecord");
        component.set("v.firstName", leadRecord.FirstName);
        component.set("v.lastName", leadRecord.LastName);
        component.set("v.QuoteSaveDisable", true);

        if( !communityUser ){
            component.set("v.saveQuotePop", true);
        }else{
            helper.showToast( 'Quote Saved!', 'success');
        }

    },
    
    openPurchaseModal: function (c, e, h) {
        let communityUser = c.get("v.communityUser");

        if (!communityUser) {
            c.set("v.purchaseQuotePop", true);
        }
    },
    
    closePurchaseModel: function (c, e, h) {
        c.set("v.purchaseQuotePop", false);
    },

    closeSaveQuoteModal : function (component, event, helper) {
        component.set("v.saveQuotePop", false);
    }
})