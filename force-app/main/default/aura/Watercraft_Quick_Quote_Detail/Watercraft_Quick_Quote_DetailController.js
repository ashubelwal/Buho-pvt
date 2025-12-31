({
    doInit: function (component, event, helper) {
        var additional_towunit = component.get("v.additional_towunit");
        if (additional_towunit && additional_towunit != null) {
            // helper.updateQuoteForTowUnitHelper(component, event, helper);
            
            var primaryquoteRecord = component.get("v.primaryquoteRecord");
            var title= 'You indicated your ' + additional_towunit.Towed_Unit_Type__c + ' was street legal.  Once it is removed from the '+primaryquoteRecord.Vehicle_Make__c+' '+primaryquoteRecord.Vehicle_Model__c+' it will need it’s own Mexico insurance policy.  Purchasing both at the same time qualifies you for multiple vehicle discount.'; //+additional_towunit.Towed_Unit_Type__c;
            component.set('v.title', title);
            
            var daysTootip = 'The number of days this vehicle will need its own insurance once it is removed from the '+primaryquoteRecord.Vehicle_Model__c+'.';//  Another way to put it, how many days removed from the '+primaryquoteRecord.Vehicle_Make__c+' '+additional_towunit.Model__c+'.';
            
            component.set("v.daysTootip", daysTootip);
            
            /*var daysIntowTootip = 'Number of days vehicle will be covered under the '+additional_towunit.Make__c+' '+additional_towunit.Model__c+' policy as a towed unit';*/
            
            var daysIntowTootip = 'Number of days vehicle will be covered under the '+primaryquoteRecord.Vehicle_Make__c+' '+primaryquoteRecord.Vehicle_Model__c+' policy as a towed unit';
            component.set("v.daysIntowTootip", daysIntowTootip);
            //component.set("v.countVehicle", parseInt('2'));
            
            if( additional_towunit.Towed_Unit_Type__c 
               && ( additional_towunit.Towed_Unit_Type__c == 'Motorcycle'
                   || additional_towunit.Towed_Unit_Type__c == 'ATV' ) ){
                
                component.set('v.isMedicalPayment', false);
                component.set("v.qualitasMedical", null);
                component.set("v.chubbMedical", null);
                component.set("v.mapfreMedical", null);
            }
            
            console.log('-additional_towunit.Towed_Unit_Type__c---'+additional_towunit.Towed_Unit_Type__c);
            if( additional_towunit.Towed_Unit_Type__c != undefined ){
                if( additional_towunit.Towed_Unit_Type__c == 'Motorcycle' || additional_towunit.Towed_Unit_Type__c == 'ATV'){
                    component.set('v.policyType', 'Motorcycle/Street Legal ATV');
                }else if( additional_towunit.Towed_Unit_Type__c == 'Camper' ){
                    component.set('v.policyType', 'RV');
                }else if( additional_towunit.Towed_Unit_Type__c == 'Boat' ){
                    component.set('v.policyType', 'WaterCraft');
                }
                    else if( additional_towunit.Towed_Unit_Type__c == 'Towed Automobile' ){
                        component.set('v.policyType', 'Automobile');
                    }else {
                        component.set('v.policyType', null);
                    }
            }
            
            var mapfreLiablityOnly = component.get("v.mapfreLiablityOnly");
            var policyType = component.get("v.policyType")
            if( (mapfreLiablityOnly == undefined || mapfreLiablityOnly == 'Max') 
               && ( policyType == 'Motorcycle/Street Legal ATV' || policyType == 'RV' )){
                component.set("v.mapfreLiablityOnly", "Complete");
            }else if( policyType == 'Automobile' ){
                component.set("v.mapfreLiablityOnly", "Max");
            }
            
            if( additional_towunit.quoteRecord && additional_towunit.quoteRecord != null  ){
                var quoteRecord = additional_towunit.quoteRecord;
                quoteRecord['Policy_Type_picklist__c'] = component.get("v.policyType");
                component.set("v.quoteRecord", quoteRecord );
            }
        }
        helper.initializeData(component, event, helper); 
        
        
    },
    
    onNextClick: function (component, event, helper) {
        var renewPolicy = component.get("v.renewPolicy");
        let communityUser = component.get("v.communityUser");
        var name = event.target.name;
        
        let finalValueWaterCraft = component.get("v.rateValue");
        var additional_towunit = component.get("v.additional_towunit");
        let quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
        startDayForCoverage = new Date(startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
        
        let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']);
        endDayForCoverage = new Date(endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());
        
        var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        if (Difference_In_Days != null && Difference_In_Days > 365) {
            helper.showToast('Total days cannot equal more than 365', 'error');
            return;
        }
        
        if (Difference_In_Days != null && Difference_In_Days == 0) {
            helper.showToast('Total days cannot be less than 1', 'error');
            return;
        }
        
        component.set("v.Final_total_Premium", finalValueWaterCraft);
        
        var allVail = helper.validateInputFields(component, event, helper);
        if (allVail) {
            
            if( renewPolicy != undefined && renewPolicy == true  ){
                if (additional_towunit && additional_towunit != null) {
                    helper.updateQuoteForTowUnitHelper(component, event, helper);
                } else {
                    helper.updateQuoteHelper(component, event, helper);
                }
                //helper.updateQuoteHelper(component, event, helper);
                $A.enqueueAction(component.get("v.onNextClick"));
                return;
            }
            
            if (!communityUser) {
                let selectedProduct = {};
                selectedProduct.item_name = "Watercraft";
                selectedProduct.item_id = "0121C00000102F7QAI-Chubb";
                selectedProduct.price = quoteRecord.Quote_Value__c;
                selectedProduct.item_brand = "MexInsurance";
                selectedProduct.item_category = quoteRecord.Vehicle_Type__c;
                selectedProduct.item_category2 = quoteRecord.Term__c;
                selectedProduct.item_category3 = "";
                selectedProduct.item_category4 = "Chubb";
                selectedProduct.item_variant = quoteRecord.Coverage__c;
                selectedProduct.item_list_name = "Watercraft Quote Page";
                selectedProduct.quantity = 1;
                selectedProduct.index = 1;
                
                console.log("Selected Product --->", JSON.stringify(selectedProduct, null, 4));
                
                window.dataLayer.push({ecommerce: undefined});
                window.dataLayer.push({
                    event: "select_item",
                    ecommerce: {
                        items: [selectedProduct]
                    }
                });
                
                // Lead create for new user
                helper.saveQuoteHelper(component, event, helper, name);  
            }
            
            if( additional_towunit && additional_towunit != null  ){
                helper.updateQuoteForTowUnitHelper(component, event, helper);
            }else{
                helper.updateQuoteHelper(component, event, helper);
            }
        }
    },
    
    updatePhoneValue: function (component, event, helper) {
        var value = event.getParam("value");
        if (value && value.length > 0) {
            const x = value.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            value = !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
        }
        component.set("v.phoneNumber", value);
    },
    
    saveQuote: function (component, event, helper) {
        let quoteRecord = component.get("v.quoteRecord");
        let startDayForCoverage = new Date(quoteRecord['Start_Date_for_Coverage__c']);
        startDayForCoverage = new Date(startDayForCoverage.getUTCFullYear(), startDayForCoverage.getUTCMonth(), startDayForCoverage.getUTCDate());
        
        let endDayForCoverage = new Date(quoteRecord['End_Date_for_Coverage__c']);
        endDayForCoverage = new Date(endDayForCoverage.getUTCFullYear(), endDayForCoverage.getUTCMonth(), endDayForCoverage.getUTCDate());
        
        var Difference_In_Time = endDayForCoverage.getTime() - startDayForCoverage.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        if (Difference_In_Days != null && Difference_In_Days > 365) {
            helper.showToast('Total days cannot equal more than 365', 'error');
            return;
        }
        
        if (Difference_In_Days != null && Difference_In_Days == 0) {
            helper.showToast('Total days cannot be less than 1', 'error');
            return;
        }
        
        let allValid = helper.validateInputFields(component, event, helper);
        if (allValid) {
            helper.checkAllreadyUser(component, event, helper);
            //helper.saveQuoteHelper(component, event, helper, 'saveQuote');
        }
    },
    
    highlightView: function (component, event, helper) {
        component.set("v.highlightView", true);
        component.set("v.normalView", false);
    },
    
    normalView: function (component, event, helper) {
        component.set("v.normalView", true);
        component.set("v.highlightView", false);
    },
    
    highLiability: function (component, event, helper) {
        
        var quoteRecord = component.get("v.quoteRecord");
        var liability = quoteRecord['Liability__c'];
        
        if (liability !== event.target.name) {
            if (liability === '200,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$100,000 / $300,000';
                quoteRecord['Property_Damage_Liability__c'] = '$100,000';
                quoteRecord['Liability__c'] = '400,000';
            } else if (liability === '400,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$250,000 / $500,000';
                quoteRecord['Property_Damage_Liability__c'] = '$250,000';
                quoteRecord['Liability__c'] = '750,000';
            }
            component.set("v.quoteRecord", quoteRecord);
            
            helper.getDataFromRateDataTable(component, event, helper);
        }
    },
    
    lowLiability: function (component, event, helper) {
        
        var quoteRecord = component.get("v.quoteRecord");
        var liability = quoteRecord['Liability__c'];
        
        if (liability !== event.target.name) {
            if (liability === '400,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$50,000 / $100,000';
                quoteRecord['Property_Damage_Liability__c'] = '$100,000';
                quoteRecord['Liability__c'] = '200,000';
            } else if (liability === '750,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$100,000 / $300,000';
                quoteRecord['Property_Damage_Liability__c'] = '$100,000';
                quoteRecord['Liability__c'] = '400,000';
            }
            component.set("v.quoteRecord", quoteRecord);
            
            helper.getDataFromRateDataTable(component, event, helper);
        }
    },
    
    fetchRateDate: function (component, event, helper) {
        let name = event.getSource().get("v.name");
        
        let quoteRecord = component.get("v.quoteRecord");
        let value = event.getParam("value");
        quoteRecord[name] = value;
        component.set("v.quoteRecord", quoteRecord);
        
        helper.calculateDays(component, event, helper, true);
        helper.getDataFromRateDataTable(component, event, helper);
    },
    
    openSaveQuoteModal: function (component, event, helper) {
        let communityUser = component.get("v.communityUser");
        let leadRecord = component.get("v.leadRecord");
        
        //let QuoteSave = component.get("v.QuoteSave");
        
        component.set("v.QuoteSave", true);
        component.set("v.firstName", leadRecord.FirstName);
        component.set("v.lastName", leadRecord.LastName);
        
        if (!communityUser) {
            component.set("v.saveQuotePop", true);
        } else {
            helper.showToast('Quote Saved!', 'success');
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
    
    closeSaveQuoteModal: function (component, event, helper) {
        component.set("v.saveQuotePop", false);
    }
})