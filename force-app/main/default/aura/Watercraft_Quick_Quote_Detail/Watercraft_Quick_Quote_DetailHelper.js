({
    initializeData: function (component, event, helper) {
        
        var quoteRecord = component.get("v.quoteRecord");
        var leadRecord = component.get("v.leadRecord");
        var emailAdder = component.get("v.emailAdder");
        component.get("v.emailAdder", leadRecord.Email);

        if (quoteRecord['Third_Party_Bodily_Injury__c'] == '' ||
            quoteRecord['Third_Party_Bodily_Injury__c'] == null ||
            quoteRecord['Third_Party_Bodily_Injury__c'] == undefined
        ) {
            quoteRecord['Third_Party_Bodily_Injury__c'] = '$50,000 / $100,000';
        } else {
            if (quoteRecord['Liability__c'] == '200,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$50,000 / $100,000';
            } else if (quoteRecord['Liability__c'] == '400,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$100,000 / $300,000';
            } else if (quoteRecord['Liability__c'] == '750,000') {
                quoteRecord['Third_Party_Bodily_Injury__c'] = '$250,000 / $500,000';
            }
        }
        
        if (quoteRecord['Property_Damage_Liability__c'] == '' ||
            quoteRecord['Property_Damage_Liability__c'] == null ||
            quoteRecord['Property_Damage_Liability__c'] == undefined
        ) {
            quoteRecord['Property_Damage_Liability__c'] = '$100,000';
        } else {
            if (quoteRecord['Liability__c'] == '200,000' || quoteRecord['Liability__c'] == '400,000') {
                quoteRecord['Property_Damage_Liability__c'] = '$100,000';
            } else {
                quoteRecord['Property_Damage_Liability__c'] = '$250,000';
            }
        }
        
        if (quoteRecord['Liability__c'] == '' || quoteRecord['Liability__c'] == null || quoteRecord['Liability__c'] == undefined) {
            quoteRecord['Liability__c'] = '200,000';
        }
        
        component.set("v.highLiability", "750,000");
        component.set("v.lowLiability", "200,000");
        component.set("v.quoteRecord", quoteRecord);
        helper.calculateDays(component, event, helper, false);
        helper.getDataFromRateDataTable(component, event, helper);
        helper.fetchCoverageDetail(component, event, helper);
        
        let today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.minStartDate", today);
    },

    calculateDays: function (component, event, helper, updateDays) {
        var quoteRecord = component.get("v.quoteRecord");
        var difference_In_Days = 0;
        var additional_towunit = component.get("v.additional_towunit");
        if (additional_towunit && additional_towunit != null) {
            difference_In_Days = additional_towunit.Days_in_Tow__c;
            component.set("v.difference_In_Days", parseInt(difference_In_Days));
        }else if (quoteRecord && quoteRecord.Start_Date_for_Coverage__c && quoteRecord.End_Date_for_Coverage__c) {
            var startDate = quoteRecord['Start_Date_for_Coverage__c'];
            var endDate = quoteRecord['End_Date_for_Coverage__c'];
            var date1 = new Date(startDate);
            var date2 = new Date(endDate);
            // To calculate the time difference of two dates 
            var Difference_In_Time = date2.getTime() - date1.getTime();

            // To calculate the no. of days between two dates 
            difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            component.set("v.difference_In_Days", parseInt(difference_In_Days));
        }

        if (difference_In_Days < 30) {
            component.set("v.difference_In_Daysin30", true);
        } else {
            component.set("v.difference_In_Daysin30", false);
        }

        if( updateDays && difference_In_Days != null && difference_In_Days != undefined){
            try{
                component.set("v.days", parseInt(difference_In_Days));
            }catch(ex){
                console.log(ex);
            }
        }
    },

    fetchCoverageDetail: function (component, event, helper) {
        const action = component.get('c.getCoverageDetail');
        action.setParams({
            quoteRecord: component.get("v.quoteRecord")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result != null && result.length > 0) {
                    component.set("v.coverageDetail", result[0]);
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    getDataFromRateDataTable: function (component, event, helper) {
        var action = component.get("c.getDataFromDataTable");
        let days = component.get("v.difference_In_Days");
        let item1 = {};
        item1.item_name = "Watercraft";
        item1.item_id = "0121C00000102F7QAI-Chubb";
        item1.item_brand = "MexInsurance";

        let quoteDataRecord = component.get("v.quoteRecord"); 
        quoteDataRecord['Term_Days__c'] = days;
        	//Console.log("CA log annualTerm "+ component.get("v.annualTerm"));
        action.setParams({
            quoteObject: quoteDataRecord,
            annualTerm: component.get("v.annualTerm")
        });

        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var response = result.getReturnValue();
                if (response != null) {
                    try {
                        var quoteObject = component.get("v.quoteRecord");
                        var rateRecords = response;
                        var rateRecord  = {};

                        for (var tempRateRecord of rateRecords) {
                            var Net_Premium = (tempRateRecord.Net_Premium__c != null ? tempRateRecord.Net_Premium__c : 0);
                            var Broker_Policy_Fee = (tempRateRecord.Broker_Policy_Fee__c != null ? tempRateRecord.Broker_Policy_Fee__c : 0);
                            var IVA_Mex_Tax = (tempRateRecord.IVA_Mex_Tax__c != null ? tempRateRecord.IVA_Mex_Tax__c : 0);

                            var Term__c = (tempRateRecord.Term__c != null ? tempRateRecord.Term__c : null);

                            var Liability_Limit_Selection = Net_Premium;

                            if (Term__c == 'Daily') {
                                Liability_Limit_Selection = Liability_Limit_Selection * component.get("v.difference_In_Days");
                            }

                            var surcharge = 0;
                            var Total_Premium = Liability_Limit_Selection;
                            
                            if (quoteObject.Is_the_Maximum_Speed_more_than_50_mph__c == 'Yes') {
                                surcharge += (Liability_Limit_Selection * 0.5);
                            }
                            if (quoteObject.Any_Boat_Operator_Under_22__c == 'Yes') {
                                surcharge += (Liability_Limit_Selection * 2);
                            }
                            if (quoteObject.Is_the_owner_living_in_Mexico__c == 'Yes') {
                                surcharge += (Liability_Limit_Selection * 0.5);
                            }
                            
                            Total_Premium = Total_Premium + Broker_Policy_Fee + IVA_Mex_Tax + surcharge;
                            
                            if (rateRecord['Total_Premium'] == null || Total_Premium < rateRecord['Total_Premium']) {
                                quoteObject['Quote_Value__c']       = Total_Premium;
                                quoteObject['Net_Premium__c']       = Liability_Limit_Selection;
                                quoteObject['Surcharge__c']         = surcharge;
                                quoteObject['I_V_A_Mex_Tax__c']     = IVA_Mex_Tax;
                                quoteObject['Broker_Policy_Fee__c'] = Broker_Policy_Fee;
                                
                                if (tempRateRecord['Term__c'] === 'Annual' && quoteObject['Term__c'] === 'Daily') {
                                    var date = quoteObject['Start_Date_for_Coverage__c'] + 'T00:00:00';
                                    if( date ){
                                        var result = new Date(date);
                                        result.setDate(result.getDate() + 365);
                                        
                                        var finaldate = $A.localizationService.formatDate(result, "YYYY-MM-DD");
                                        quoteObject['End_Date_for_Coverage__c'] = finaldate;
                                        quoteObject['Term__c'] = 'Annual(One Year)';
                                        quoteObject['Term_Days__c'] = 365;
                                        component.set("v.termType", Term__c);
                                    }else{
                                        component.set("v.termType", null);
                                    }
                                }else{
                                    component.set("v.termType", null);
                                }
                                
                                rateRecord['Underwriter__c']       = tempRateRecord.Underwriter__c;
                                rateRecord['Net_Premium__c']       = Liability_Limit_Selection;
                                rateRecord['IVA_Mex_Tax__c']       = IVA_Mex_Tax;
                                rateRecord['surcharge']            = surcharge;
                                rateRecord['Broker_Policy_Fee__c'] = Broker_Policy_Fee;
                                rateRecord['Total_Premium']        = Total_Premium;
                                rateRecord['Liability__c']         = quoteObject['Liability__c'];
                                rateRecord['quoteRecord']          = quoteObject;
                                rateRecord['quoteId']              = quoteObject.Id;
                                rateRecord['leadId']               = component.get("v.leadRecord").Id;
                                
                            }
                        }
                        
                        item1.item_category = quoteObject.Vehicle_Type__c;
                        item1.item_category2 = days > 0 && days <= 30 ? "Daily" : "Annual(One Year)"; // item_category3 is not there in Watercraft policy
                        item1.item_category3 = "";
                        item1.item_category4 = "Chubb";
                        item1.item_list_name = "Watercraft Quote Page";
                        item1.quantity = 1;
                        item1.index = 1;
                        item1.item_variant = "Liability";
                        item1.price = Total_Premium;
                        if (!component.get("v.communityUser")) {
                            this.pushDataLayer(component, event, helper, item1);
                        }

                        component.set("v.rateRecord", rateRecord);
                        component.set("v.quoteRecord", quoteObject);
                        component.set("v.rateValue", rateRecord['Total_Premium']);
                        helper.calculateDays(component, event, helper, false);
                    } catch (ex) {
                        console.log('******exception****');
                        console.log(ex);
                    }

                } else {
                    component.set("v.rateValue", response);
                    component.set("v.rateRecord", response);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    pushDataLayer: function (c, e, h, item1) {
        console.log("item1 ---> ", JSON.stringify(item1, null, 4));
        window.dataLayer.push({ ecommerce: undefined });
        window.dataLayer.push({
            event: "view_item_list",
            ecommerce: {
                items: [item1]
            }
        });
    },

    updateQuoteHelper: function (component, event, helper) {
        const action = component.get('c.handleQuoteAction');
        action.setParams({
            quoteRecord: component.get("v.quoteRecord"),
            annualTerm: component.get("v.annualTerm")
        });
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var response = result.getReturnValue();
                if (response.success) {
                    var quoteRecord = component.get("v.quoteRecord");
                    quoteRecord['Id'] = response.quote['Id'];
                    component.set("v.quoteRecord", quoteRecord);

                    //helper.showToast('Quote updated successfully.', 'success');

                    $A.enqueueAction(component.get("v.onNextClick"));

                } else {
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(result.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
   	updateQuoteForTowUnitHelper : function(component, event, helper) {
        const action = component.get('c.handleQuoteForTowUnitAction');
        var additional_towunit = component.get("v.additional_towunit");
        action.setParams({
            additional_towunit: JSON.stringify(additional_towunit),
            quoteObj: component.get("v.quoteRecord")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                if( response.success){
                    try{
                        var additional_towunit = response.additional_towunit;
                        var quoteRecord = component.get("v.quoteRecord");
                        //quoteRecord['Id'] = additional_towunit.quoteRecord.Id;
                        //quoteRecord['Term_Days__c'] = response.daysBetween;
                        component.set("v.quoteRecord",quoteRecord);

                        var returnQuoteRecord = additional_towunit.quoteRecord;
                        returnQuoteRecord['Start_Time__c'] = quoteRecord.Start_Time__c;
                        returnQuoteRecord['End_Time__c'] = quoteRecord.End_Time__c;
                        returnQuoteRecord['Term__c'] = quoteRecord.Term__c;
                        
                        quoteRecord = returnQuoteRecord;
                        component.set("v.quoteRecord",quoteRecord);

                        var name = event.target.name;
                        var response = component.get("v.rateRecord");
                        response['purchase'] = name;
                        response['Net_Premium__c'] = quoteRecord['Net_Premium__c'];
                        response['quoteId'] = quoteRecord.Id;
                        response['Type__c'] = component.get("v.policyType");
                        response['Underwriter__c'] = quoteRecord['Underwriter__c'];
                        response['quoteRecord'] = quoteRecord;
                        response['Total_Premium']= quoteRecord['Quote_Value__c'];
                        response['leadId'] = component.get("v.leadRecord").Id;
                        response['Broker_Policy_Fee__c']= quoteRecord['Broker_Policy_Fee__c'];
                        response['Package__c']= quoteRecord['Coverage__c'];
                        response['Medical__c']= quoteRecord['Medical__c'];
                        response['IVA_Mex_Tax__c']= quoteRecord['I_V_A_Mex_Tax__c'];
                        response['surcharge']= (quoteRecord['Surcharge__c'] != undefined ? quoteRecord['Surcharge__c'] : 0 );
                        response['Liability__c']= quoteRecord['Liability__c'];
    
                        response['year'] = additional_towunit['Year__c'];
                        response['make'] = additional_towunit['Make__c'];
                        response['model'] = additional_towunit['Model__c'];
                        
                        additional_towunit['rateRecord'] = response;
                        additional_towunit['quoteRecord'] = quoteRecord;
                        component.set("v.rateRecord", response);
                        component.set("v.additional_towunit", additional_towunit);
                        //helper.showToast('Quote updated successfully.', 'success');
                        
                        $A.enqueueAction(component.get("v.onNextClick"));
                    }catch(ex){
                        console.log('----exception--',ex);
                    }
                    
                }else{
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast: function (message, type) {
        $A.get('e.force:showToast').setParams({
            type: type,
            message: message
        }).fire();
    },
    
    checkAllreadyUser : function( component, event, helper){
        const action = component.get('c.checkalreadyExistUserAction');

        action.setParams({
            emailAdder: component.get("v.emailAdder")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var response = response.getReturnValue();
                  if( response.isExistUser){
                    helper.showToast('Please login to save your quote.', 'success');
                }else{
                    helper.saveQuoteHelper(component, event, helper, 'saveQuote');
                } 
            } else {
                helper.showToast(response.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    saveQuoteHelper: function (component, event, helper, name) {
        var action = component.get("c.saveQuoteAction");
        action.setParams({
            leadId: component.get("v.leadRecord").Id,
            firstName: component.get("v.leadRecord").FirstName,
            lastName: component.get("v.leadRecord").LastName,
            emailAdder: component.get("v.leadRecord").Email,
            quoteId: component.get("v.quoteRecord").Id,
            phoneNumber: component.get("v.leadRecord").Phone,
        });

        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var response = result.getReturnValue();
                if (response.success) {
                    var quoteRecord = component.get("v.quoteRecord");
                    var leadRecord = component.get("v.leadRecord");

                    quoteRecord['Contact__c'] = response.contactId;
                    quoteRecord['Account__c'] = response.accountId;

                    if (response.lead) {
                        leadRecord['FirstName'] = response.lead['FirstName'];
                        leadRecord['LastName']  = response.lead['LastName'];
                        leadRecord['Company']   = response.lead['Company'];
                    }

                    if (response.isCommunityUser) {
                        component.set("v.communityUser", response.isCommunityUser);
                    }

                    component.set("v.quoteRecord", quoteRecord);
                    component.set("v.leadRecord", leadRecord);
                    component.set("v.saveQuotePop", false);

                    if(name == 'saveQuote'){
                         helper.showToast(response.message, 'success');
                    }
                } else {
                    helper.showToast(response.message, 'error');
                }
            } else {
                helper.showToast(result.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    validateInputFields: function (component, event, helper) {
        try{
            return component.find('validateField').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }catch( ex ){
            return true;
        }
    },
})