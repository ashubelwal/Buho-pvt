({
    initialize: function(component, event) {
        console.log('--newCreditCard---');
        component.set('v.newCreditCard', {});
        if (!component.get('v.transactionDetails')) {
            component.set('v.transactionDetails', {});
        }
        /*var editPolicy = component.get("v.editPolicy");
        var isRefund = component.get("v.isRefund");
        if( editPolicy != undefined && editPolicy == true){
            if( isRefund != undefined && isRefund == true){
            }
        }*/
        this.populateQuoteIds(component, event);
        this.getPaymentInfo(component, event);

        
        var countryOption = [];
        countryOption = [
            { "value" : "United States", "label" : "United States" },	
            { "value" : "Canada", "label" : "Canada" },
            { "value" : "Other", "label" : "Other" }	
        ];
        countryOption.push({ "value" : "Mexico", "label" : "Mexico" });
        component.set("v.countryOption", countryOption);

        this.updatePickListValue( component, event );
        this.calculateDateOptions( component, event );
    },

    calculateDateOptions : function( component, event ){
        var currentDate = new Date();
        
        let currentYear = currentDate.getFullYear();

        let startFrom = currentYear;
        var years = [];
        for( startFrom ; startFrom < (currentYear + 20); startFrom++) {
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
                'value': mon
            });
        }
        component.set("v.months",months);
    },


    updatePickListValue : function( component, event ){
        try{
            var policyType = component.get("v.policyType");
            var newCreditCard = component.get('v.newCreditCard');
    
            if( policyType && policyType.toLowerCase() == 'northbound' && newCreditCard != undefined && newCreditCard.country && newCreditCard.country.toUpperCase() == 'MEXICO'){ 
                component.set("v.disableCountry", true);
                this.setCountryAndStates(component, 'MEXICO' );
            }
    
            if( newCreditCard != undefined && newCreditCard.country != undefined ){ 
                if( newCreditCard.country.toUpperCase() == 'MEXICO' ){
                    component.set("v.showStatePick", true);
                    this.setCountryAndStates(component, 'MEXICO' );
                }else if( newCreditCard.country.toUpperCase() == 'UNITED STATES' ){
                    component.set("v.showStatePick", true);
                    this.setCountryAndStates(component, 'UNITED STATES' );
                }else if( newCreditCard.country.toUpperCase() == 'CANADA' ){
                    component.set("v.showStatePick", true);
                    this.setCountryAndStates(component, 'CANADA' );
                }
                component.set("v.policyCountry",newCreditCard.country);
            }
        }catch( ex ){
            console.log('---ex--',ex)
        }
    },

    populateQuoteIds: function(component, event) {
        
        let quoteIds = component.get('v.quoteIds');
        if (!Array.isArray(quoteIds) || !quoteIds.length) {
            quoteIds = [];
        }

        const quoteId = component.get('v.quoteId');
        console.log("CA log Quote ID -----> ", quoteId);
        if (quoteId && quoteId !== '' && !quoteIds.includes(quoteId)) {
            quoteIds.push(quoteId);
        }
        component.set('v.quoteIds', quoteIds);

        this.getDriverAddress( component, event );
    },

    getDriverAddress : function(component, event) {
        const that = this;

        const action = component.get('c.getDriverAddress');
        action.setParams({quoteIds: component.get('v.quoteIds')});
        action.setCallback(this, function (response) {
         if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('--result all contacts--',result);
                if( result && result != null ){
                    result = JSON.parse(result);
                    if( result && result.length > 0 ){
                        result = result[0];
                        console.log('--result--',result);
                        let newCreditCard = component.get('v.newCreditCard');
                        /*newCreditCard.address1 = result.Address__c;
                        newCreditCard.zip = result.Postal_Code__c;
                        newCreditCard.country = result.Country__c;
                        newCreditCard.state = result.State_Province__c;
                        newCreditCard.city = result.City__c;
                        newCreditCard.name = (result.First_Name__c != undefined ? result.First_Name__c+' ': '') + (result.Last_Name__c != undefined ? result.Last_Name__c : '')
                        component.set('v.newCreditCard', newCreditCard);*/
                        
                        let communityUsers = component.get("v.communityUser");
                        
                        let ownerDriver = [];
                        let Driver = component.get("v.drivers");
                        console.log("driver all "+ JSON.stringify(Driver));
                       	console.log("length of driver--"+ Driver.length);
                        for(let i=0; i<Driver.length; i++){
                            console.log("inside for loop");
                            console.log("driver---"+JSON.stringify(Driver[i], null, 4));
                            if(Driver[i].Driver_Type__c == 'Owner' || Driver[i].Driver_Type__c == 'Owner & Driver'){
                                ownerDriver.push(Driver[i]);
                            }
                        }
                         console.log(" communityUser -- " + JSON.stringify(ownerDriver, null, 4));
                         console.log(" communityUser -- " + JSON.stringify(communityUsers, null, 4));
                        if(!communityUsers){
                            newCreditCard.address1 = ownerDriver[0].Address__c;
                            newCreditCard.address2 = ownerDriver[0].Address_Line_2__c;
                            newCreditCard.zip = ownerDriver[0].Postal_Code__c;
                            newCreditCard.country = ownerDriver[0].Country__c;
                            newCreditCard.state = ownerDriver[0].State_Province__c;
                            newCreditCard.city = ownerDriver[0].City__c;
                            newCreditCard.name = (ownerDriver[0].First_Name__c != undefined ? ownerDriver[0].First_Name__c+' ' : '') + (ownerDriver[0].Last_Name__c != undefined ? ownerDriver[0].Last_Name__c : '');
                            newCreditCard.email = result.Email;
                            newCreditCard.quoteId = component.get('v.quoteIds')[0];
                            newCreditCard.description = component.get('v.policyType') + ' Policy';
                            component.set('v.newCreditCard', newCreditCard);
                        }else{
                            newCreditCard.address1 = result.Street__c == undefined ? ownerDriver[0].Address__c : result.Street__c;
                            newCreditCard.address2 = result.Street_2__c == undefined ? ownerDriver[0].Address_Line_2__c :  result.Street_2__c;
                            newCreditCard.zip = result.Postal_Code__c == undefined ? ownerDriver[0].Postal_Code__c : ownerDriver[0].Postal_Code__c;
                            newCreditCard.country = result.Country__c  == undefined ? ownerDriver[0].Country__c : result.Country__c;
                            newCreditCard.state = result.State__c == undefined ? ownerDriver[0].State_Province__c : result.State__c;
                            newCreditCard.city = result.City__c == undefined ? ownerDriver[0].City__c : result.City__c;
                            newCreditCard.name = (result.FirstName != undefined ? result.FirstName+' ' : '') + (result.LastName != undefined ? result.LastName : '');
                            newCreditCard.email = result.Email;
                            newCreditCard.quoteId = component.get('v.quoteIds')[0];
                            newCreditCard.description = component.get('v.policyType') + ' Policy';
                            component.set('v.newCreditCard', newCreditCard);  
                        }
                        
                        
                        console.log("CA log  newCreditCard : "+ JSON.stringify(component.get('v.newCreditCard'), null, 4));

                        
                        
                        that.updatePickListValue( component, event );
                    }
                }
            } else {
                that.showError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    makePayment: function(component, event) {
        const addCardMode = component.get('v.addCardMode');
        const refundAmount = component.get('v.refundAmount');
        console.log("CA log addCardMode : "+ addCardMode);
         console.log("CA log refundAmount : "+ refundAmount);
        if( addCardMode == true ){
            var newCreditCard = component.get("v.newCreditCard");
            console.log('CA log newCreditCard : '+ JSON.stringify(newCreditCard, null, 4));
            var currentDate = new Date();
            let currentYear = currentDate.getFullYear();
            let currentMonth = (currentDate.getMonth() + 1);
            if( newCreditCard != undefined && currentYear == parseInt(newCreditCard.year) && currentMonth > parseInt(newCreditCard.month) ){
                this.showToast('Please enter a valid expiration date.', 'error');
                return;
            }
        }
        if (addCardMode && !this.checkValidity(component, event)) {
            return;
        }
        
        if (!component.get("v.communityUser")) {
            let quoteRecord = component.get("v.quoteRecord");
            let selectedProduct = {};
            selectedProduct.item_name = quoteRecord.Policy_Type_picklist__c.toLowerCase() == "northbound" ? "Northbound" : quoteRecord.Policy_Type_picklist__c.toLowerCase() == "watercraft" ? "Watercraft" : "Automobile";
            selectedProduct.item_id = quoteRecord.Policy_Type_picklist__c == "Automobile" ? "0121C00000102F1QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "Motorcycle/Street Legal ATV" ? "0121C00000102F4QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "RV" ? "0121C00000102F6QAI-" + quoteRecord.Underwriter__c : quoteRecord.Policy_Type_picklist__c == "Northbound" ? "0121C00000102F5QAI-" + quoteRecord.Underwriter__c : "0121C00000102F7QAI-" + quoteRecord.Underwriter__c;
            selectedProduct.price = quoteRecord.Quote_Value__c;
            selectedProduct.item_brand = "MexInsurance";
            selectedProduct.item_category = quoteRecord.Vehicle_Type__c;
            selectedProduct.item_category2 = quoteRecord.Term__c;
            selectedProduct.item_category3 = quoteRecord.Policy_Type_picklist__c != "Watercraft" ? quoteRecord.Territory_Coverage__c : "";
            selectedProduct.item_category4 = quoteRecord.Underwriter__c;
            selectedProduct.item_variant = quoteRecord.Coverage__c;
            selectedProduct.item_list_name = quoteRecord.Policy_Type_picklist__c == "Northbound" ? "Northbound Quote Page" : quoteRecord.Policy_Type_picklist__c == "Watercraft" ? "Watercraft Quote Page" : quoteRecord.Policy_Type_picklist__c + " Quote Page";
            selectedProduct.quantity = 1;
            selectedProduct.index = quoteRecord.Policy_Type_picklist__c.toLowerCase() == "northbound" || quoteRecord.Policy_Type_picklist__c.toLowerCase() == "watercraft" ? 1 : quoteRecord.Policy_Type_picklist__c.toLowerCase() != "northbound" && quoteRecord.Policy_Type_picklist__c.toLowerCase() != "watercraft" && quoteRecord.Underwriter__c.toLowerCase() == "qualitas" ? 1 : quoteRecord.Policy_Type_picklist__c.toLowerCase() != "northbound" && quoteRecord.Policy_Type_picklist__c.toLowerCase() != "watercraft" && quoteRecord.Underwriter__c.toLowerCase() == "chubb" ? 2 : 3;
            
            console.log("Selected Product Payment page -->", JSON.stringify(selectedProduct, null, 4));
            window.dataLayer.push({ ecommerce: undefined });
            window.dataLayer.push({
                event: "add_shipping_info",
                ecommerce: {
                    items: [selectedProduct]
                }
            });
            
            window.dataLayer.push({
                event: "add_payment_info",
                ecommerce: {
                    items: [selectedProduct]
                }
            });
        }
        
        const selectedCardId = component.get('v.selectedCardId');
        console.log("CA LOG SelectedCard ID ", selectedCardId);
        if (refundAmount != null && parseFloat(refundAmount) < 0) {
            this.refundTransaction(component, event);
            return;
        } else if (refundAmount != null && parseFloat(refundAmount) > 0) {
            console.log("Inside createAdditionalTransaction Block");
            if (!addCardMode && selectedCardId != '') {
                this.createAdditionalPaymentProfileTransaction(component, selectedCardId);
                return;
            } else {
                this.createAdditionalTransaction(component, event);
            	return;
            }
        } else if (!addCardMode && selectedCardId !== ''){
            console.log("Inside createPaymentProfileTransaction Block");
            this.createPaymentProfileTransaction(component, selectedCardId);
        } else if (component.get('v.newCreditCard').saveNewCard === true) {
            console.log("Inside createPaymentProfile Block");
            this.createPaymentProfile(component, event);
        } else if (addCardMode) {
            console.log("Inside createTransaction Block");
            this.createTransaction(component, event);
        }
    },

    checkValidity: function(component, event) {
        const inputFields = component.find('fieldWithValidation');
        let validity = true;
        for (let i = 0; i < inputFields.length; i++) {
            if (!inputFields[i].checkValidity()) {
                validity = false;
            }
            inputFields[i].reportValidity();
        }
        return validity;
    },

    showCardForm: function(component, event) {
        component.set('v.populateAddress', false);
        component.set('v.addCardMode', true);
        let paymentInfo = component.get('v.paymentInfo');
        for (let i = 0; i < paymentInfo.creditCards.length; i++) {
            paymentInfo.creditCards[i].selected = false;
        }
        component.set('v.paymentInfo', paymentInfo);
        component.set('v.selectedCardId', '');
    },

    selectNewCard: function(component, event) {
        component.set('v.addCardMode', false);
        component.set('v.newCreditCard', {});
        const selectedIndex = parseInt(event.currentTarget.dataset.id);
        let paymentInfo = component.get('v.paymentInfo');

        for (let i = 0; i < paymentInfo.creditCards.length; i++) {
            if (i !== selectedIndex) {
                paymentInfo.creditCards[i].selected = false;
            } else {
                component.set('v.newCreditCard', paymentInfo.creditCards[i]);
                paymentInfo.creditCards[i].selected = true;
                component.set('v.selectedCardId', paymentInfo.creditCards[i].cardId);
            }
        }
        component.set('v.paymentInfo', paymentInfo);
        console.log("CA log paymentInfo selctedCard : "+ JSON.stringify(component.get('v.paymentInfo'), null, 4));
    },

    getPaymentInfo: function(component, event) {
        const that = this;
        const action = component.get('c.getPaymentInfo');
        action.setParams({quoteIds: component.get('v.quoteIds')});
        action.setCallback(this, function (response) {
         
            if (response.getState() === 'SUCCESS') {
                const paymentInfo = JSON.parse(response.getReturnValue());
                console.log("CA Log payment info card "+JSON.stringify(paymentInfo, null, 4));
                if (paymentInfo.creditCards && paymentInfo.creditCards.length > 0) {
                    component.set('v.addCardMode', false);
                } else {
                    component.set('v.addCardMode', true);
                }
                component.set('v.paymentInfo', paymentInfo);
                that.getIpAddress(component, event);
            } else {
                that.showError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    

    getIpAddress: function(component, event) {
        const urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf('/s/'));
        let xmlHttp = new XMLHttpRequest();
        xmlHttp.open( "GET", baseURL + '/apex/IPAddress', false );
        xmlHttp.send( null );
        const ip = JSON.parse(xmlHttp.responseText);
        component.set('v.paymentInfo.ip', ip.ip);
    },

    createPaymentProfile: function(component, event) {
        const that = this;
        const ip = component.get('v.paymentInfo.ip');
        let transactionDetails = component.get('v.transactionDetails');
        transactionDetails.ip = ip;
        const action = component.get('c.createPaymentProfile');
        console.log("CA log createPayment Profile ", JSON.stringify(component.get('v.newCreditCard'), null, 4));
        console.log("CA log ", JSON.stringify(component.get('v.quoteIds'), null, 4));
        
        action.setParams({newCreditCard: JSON.stringify(component.get('v.newCreditCard')), quoteIds: component.get('v.quoteIds')});
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                if (transactionDetails.subscribe) {
                    //the timeout is needed because of known issue of the payment system
                    component.set('v.showSpinner', true);
                    window.setTimeout(
                        $A.getCallback(function() {
                            that.createPaymentProfileTransaction(component, response.getReturnValue());
                            component.set('v.showSpinner', false);
                        }), 10000
                    );
                } else {
                    that.createPaymentProfileTransaction(component, response.getReturnValue());
                }
            } else {
                that.showError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    createPaymentProfileTransaction: function(component, paymentProfileId) {
        console.log("CA log paymentProfileId : "+ paymentProfileId);
        const that = this;
        const ip = component.get('v.paymentInfo.ip');
        const action = component.get('c.createPaymentProfileTransaction');
        let transactionDetails = component.get('v.transactionDetails');
        transactionDetails.ip = ip;
        transactionDetails.quoteIds = component.get('v.quoteIds');
        transactionDetails.paymentProfileId = paymentProfileId;
        
        console.log("CA log transaction in 298 lie  :"+ JSON.stringify(transactionDetails, null, 4));
        action.setParams({transactionDetails: JSON.stringify(transactionDetails)});
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                if (transactionDetails.subscribe) {
                    that.createProfileSubscription(component, paymentProfileId);
                } else {
                    const successfulEvent = component.getEvent('paymentIsSuccessful');
                    successfulEvent.fire();
                    that.showToast('Payment successful');
                }
            } else {
                that.showError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    createTransaction: function(component, event) {
        try{
            const that = this;
            const action = component.get('c.createTransaction');
            const ip = component.get('v.paymentInfo.ip');
            let transactionDetails = component.get('v.transactionDetails');
            transactionDetails.ip = ip;
            transactionDetails.quoteIds = component.get('v.quoteIds');
            console.log("CA Log quote Ids ", JSON.stringify(component.get('v.quoteIds'), null, 4));
            console.log("CA log transactionDetails : "+JSON.stringify(transactionDetails, null, 4));
            action.setParams({
                newCreditCard: JSON.stringify(component.get('v.newCreditCard')),
                transactionDetails: JSON.stringify(transactionDetails)
            });
            action.setCallback(this, function (response) {
                
                console.log("this is payment form response--->"+JSON.stringify(response.getState(), null, 4));
                
                console.log("this is response from apex >>> "+ JSON.stringify(response.getReturnValue(), null, 4));
                   console.log(response.getState());
                 console.log(transactionDetails.subscribe);
                
                if (response.getState() === 'SUCCESS') {
                         
                    if (transactionDetails.subscribe) {
                        that.createSubscription(component);
                    } else {
                        const successfulEvent = component.getEvent('paymentIsSuccessful');
                        successfulEvent.fire();
                        that.showToast('Payment successful');
                    }
                } else {
                    that.showError(response.getError());
                    $A.enqueueAction(component.get("v.onBackClick"));
                    
                    //  component.set("v.screenName", 'confirmScreen');
                }
            });
            $A.enqueueAction(action);
        }catch(error){
            console.log("error---->"+error);
        }
        
        
    },
    
    createAdditionalPaymentProfileTransaction : function (component, paymentProfileId) {
        const that = this;
        const ip = component.get('v.paymentInfo.ip');
        const action = component.get('c.createAdditionalPaymentProfileTransaction');
        let transactionDetails = component.get('v.transactionDetails');
        transactionDetails.ip = ip;
        transactionDetails.quoteIds = component.get('v.quoteIds');
        transactionDetails.paymentProfileId = paymentProfileId;
        
        console.log("CA log transaction in 358 line  :"+ JSON.stringify(transactionDetails, null, 4));
        action.setParams({
            transactionDetails: JSON.stringify(transactionDetails),
            amount: component.get('v.refundAmount'),
            policyId: component.get('v.policyId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                if (transactionDetails.subscribe) {
                    that.createSubscription(component);
                } else {
                    const successfulEvent = component.getEvent('paymentIsSuccessful');
                    successfulEvent.fire();
                    that.showToast('Payment successful');
                }
            } else {
                that.showError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    createAdditionalTransaction: function(component, event) {
        const that = this;
        console.log("CA log that : "+ JSON.stringify(that));
        const action = component.get('c.createTransactionWithPredefinedAmount');
        const ip = component.get('v.paymentInfo.ip');

        let transactionDetails = component.get('v.transactionDetails');
        transactionDetails.ip = ip;
        transactionDetails.quoteIds = component.get('v.quoteIds');
	
        console.log("CA log newCreditCard : "+ JSON.stringify(component.get('v.newCreditCard'), null, 4));
        console.log("CA log policyId paymentform : "+ component.get('v.policyId'));
        console.log("CA log transactionDetail : "+ JSON.stringify(transactionDetails, null, 4));
        console.log("CA log refundamount : "+ component.get('v.refundAmount'));
        
        action.setParams({
            newCreditCard: JSON.stringify(component.get('v.newCreditCard')),
            transactionDetails: JSON.stringify(transactionDetails),
            amount: component.get('v.refundAmount'),
            policyId: component.get('v.policyId')
        });

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                if (transactionDetails.subscribe) {
                    that.createSubscription(component);
                } else {
                    const successfulEvent = component.getEvent('paymentIsSuccessful');
                    successfulEvent.fire();
                    that.showToast('Payment successful');
                }
            } else {
                that.showError(response.getError());
            }
        });

        $A.enqueueAction(action);
    }, 

    refundTransaction: function(component, event) {
        const that = this;
        const action = component.get('c.refundTransaction');
        const ip = component.get('v.paymentInfo.ip');

        let transactionDetails = component.get('v.transactionDetails');
        console.log("---transactionDetails-->"+JSON.stringify(transactionDetails, null, 4));
        
        transactionDetails.quoteIds = component.get('v.quoteIds');

        action.setParams({
            newCreditCard: JSON.stringify(component.get('v.newCreditCard')),
            transactionDetails: JSON.stringify(transactionDetails),
            refundAmount: component.get('v.refundAmount'),
            policyId: component.get('v.policyId')
        });

        action.setCallback(this, function (response) {
            console.log("CA payment refund response ----- ", JSON.stringify(response.getState(), null, 4));
            if (response.getState() === 'SUCCESS') {
                if (transactionDetails.subscribe) {
                    that.createSubscription(component);
                } else {
                    const successfulEvent = component.getEvent('paymentIsSuccessful');
                    successfulEvent.fire();
                    that.showToast('Refund successfully completed');
                }
            } else {
                that.showError(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },

    createProfileSubscription: function(component, paymentProfileId) {
        const that = this;
        const action = component.get('c.createProfileSubscription');
        const ip = component.get('v.paymentInfo.ip');
        let transactionDetails = component.get('v.transactionDetails');
        transactionDetails.ip = ip;
        transactionDetails.quoteIds = component.get('v.quoteIds');
        transactionDetails.paymentProfileId = paymentProfileId;
        action.setParams({transactionDetails: JSON.stringify(transactionDetails)});
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                const successfulEvent = component.getEvent('paymentIsSuccessful');
                successfulEvent.fire();
                that.showToast('Payment successful');
            } else {
                that.showError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    createSubscription: function(component) {
        const that = this;
        const ip = component.get('v.paymentInfo.ip');
        const action = component.get('c.createSubscription');
        let transactionDetails = component.get('v.transactionDetails');
        transactionDetails.quoteIds = component.get('v.quoteIds');
        transactionDetails.ip = ip;
        action.setParams({
            newCreditCard: JSON.stringify(component.get('v.newCreditCard')),
            transactionDetails: JSON.stringify(transactionDetails)
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                const successfulEvent = component.getEvent('paymentIsSuccessful');
                successfulEvent.fire();
                that.showToast('Payment successful');
            } else {
                that.showError(responssetAddresse.getError());
            }
        });
        $A.enqueueAction(action);
    },

    setAddress: function(component, event) {
        const populateAddress = component.get('v.populateAddress');
        if (!populateAddress) {
            return;
        }
        const that = this;
        const action = component.get('c.getAddress');
        action.setParams({
            policyId: component.get("v.policyId") 
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                const addressInfo = JSON.parse(response.getReturnValue());
                console.log('--addressInfo---',JSON.stringify(addressInfo));
                let newCreditCard = component.get('v.newCreditCard');
                newCreditCard.address1 = addressInfo.address1;
                newCreditCard.zip = addressInfo.zip;
                newCreditCard.country = addressInfo.country;
                newCreditCard.state = addressInfo.state;
                newCreditCard.city = addressInfo.city;
                component.set('v.newCreditCard', newCreditCard);

                that.updatePickListValue( component, event );
            } else {
                that.showError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    showError: function(errorList) {
        if (errorList.length > 0 && errorList[0].message) {
            this.showToast(errorList[0].message, 'error');
        }
    },

    showToast: function(message, type) {
        let mode = 'dismissible';
        if (type === 'error') {
            //mode = 'sticky';
        }
        this.showToastWithParams(message, type, mode);
    },

    showToastWithParams: function(message, type, mode) {
        $A.get('e.force:showToast').setParams({
            mode: mode,
            type: type,
            message: message
        }).fire();
    },

    setCountryAndStates : function( component, country ){
        var canadaOptions = [	
            { "value" : "Alberta", "label" : "Alberta" },	
            { "value" : "British Columbia", "label" : "British Columbia" },
            { "value" : "Manitoba", "label" : "Manitoba" },	
            { "value" : "New Brunswick", "label" : "New Brunswick" },
            { "value" : "Newfoundland", "label" : "Newfoundland" },	
            { "value" : "Northwest Territories", "label" : "Northwest Territories" },
            { "value" : "Nova Scotia", "label" : "Nova Scotia" },	
            { "value" : "Nunavut", "label" : "Nunavut" },
            { "value" : "Ontario", "label" : "Ontario" },	
            { "value" : "Prince Edward Island", "label" : "Prince Edward Island" },
            { "value" : "Quebec", "label" : "Quebec" },	
            { "value" : "Saskatchewan", "label" : "Saskatchewan" },
            { "value" : "Yukon", "label" : "Yukon" },
        ];

        var mexicoOptions = [	
            { "value" : "Aguascalientes", "label" : "Aguascalientes" },	
            { "value" : "Baja California", "label" : "Baja California" },
            { "value" : "Baja California Sur", "label" : "Baja California Sur" },
            { "value" : "Campeche", "label" : "Campeche" },
            { "value" : "Chihuahua", "label" : "Chihuahua" },
            { "value" : "Chiapas", "label" : "Chiapas" },
            { "value" : "Coahuila", "label" : "Coahuila" },
            { "value" : "Colima", "label" : "Colima" },
            { "value" : "Distrito Federal", "label" : "Distrito Federal" },
            { "value" : "Durango", "label" : "Durango" },
            { "value" : "Guerrero", "label" : "Guerrero" },
            { "value" : "Guanajuato", "label" : "Guanajuato" },
            { "value" : "Hidalgo", "label" : "Hidalgo" },
            { "value" : "Jalisco", "label" : "Jalisco" },
            { "value" : "México", "label" : "México" },
            { "value" : "Michoacán", "label" : "Michoacán" },
            { "value" : "Morelos", "label" : "Morelos" },
            { "value" : "Nayarit", "label" : "Nayarit" },
            { "value" : "Nuevo León", "label" : "Nuevo León" },
            { "value" : "Oaxaca", "label" : "Oaxaca" },
            { "value" : "Puebla", "label" : "Puebla" },
            { "value" : "Querétaro", "label" : "Querétaro" },
            { "value" : "Quintana Roo", "label" : "Quintana Roo" },
            { "value" : "Sinaloa", "label" : "Sinaloa" },
            { "value" : "San Luís Potosí", "label" : "San Luís Potosí" },
            { "value" : "Sonora", "label" : "Sonora" },
            { "value" : "Tabasco", "label" : "Tabasco" },
            { "value" : "Tamaulipas", "label" : "Tamaulipas" },
            { "value" : "Tlaxcala", "label" : "Tlaxcala" },
            { "value" : "Veracruz", "label" : "Veracruz" },
            { "value" : "Yucatán", "label" : "Yucatán" },
            { "value" : "Zacatecas", "label" : "Zacatecas" }   
        ];

        var usOptions = [	
            { "value" : "Alabama", "label" : "Alabama" },	
            { "value" : "Alaska", "label" : "Alaska" },
            { "value" : "Arizona", "label" : "Arizona" },	
            { "value" : "Arkansas", "label" : "Arkansas" },
            { "value" : "California", "label" : "California" },	
            { "value" : "Colorado", "label" : "Colorado" },
            { "value" : "Connecticut", "label" : "Connecticut" },	
            { "value" : "Delaware", "label" : "Delaware" },
            { "value" : "Florida", "label" : "Florida" },	
            { "value" : "Georgia", "label" : "Georgia" },
            { "value" : "Hawaii", "label" : "Hawaii" },	
            { "value" : "Idaho", "label" : "Idaho" },
            { "value" : "Illinois", "label" : "Illinois" },
            { "value" : "Indiana", "label" : "Indiana" },
            { "value" : "Iowa", "label" : "Iowa" },	
            { "value" : "Kansas", "label" : "Kansas" },
            { "value" : "Kentucky", "label" : "Kentucky" },	
            { "value" : "Louisiana", "label" : "Louisiana" },
            { "value" : "Maine", "label" : "Maine" },	
            { "value" : "Maryland", "label" : "Maryland" },
            { "value" : "Massachusetts", "label" : "Massachusetts" },	
            { "value" : "Michigan", "label" : "Michigan" },
            { "value" : "Minnesota", "label" : "Minnesota" },	
            { "value" : "Mississippi", "label" : "Mississippi" },
            { "value" : "Missouri", "label" : "Missouri" },	
            { "value" : "Montana", "label" : "Montana" },
            { "value" : "Nebraska", "label" : "Nebraska" },
            { "value" : "Nevada", "label" : "Nevada" },	
            { "value" : "New Hampshire", "label" : "New Hampshire" },
            { "value" : "New Jersey", "label" : "New Jersey" },	
            { "value" : "New Mexico", "label" : "New Mexico" },
            { "value" : "New York", "label" : "New York" },	
            { "value" : "North Carolina", "label" : "North Carolina" },
            { "value" : "North Dakota", "label" : "North Dakota" },	
            { "value" : "Ohio", "label" : "Ohio" },
            { "value" : "Oklahoma", "label" : "Oklahoma" },	
            { "value" : "Oregon", "label" : "Oregon" },
            { "value" : "Pennsylvania", "label" : "Pennsylvania" },
            { "value" : "Rhode Island", "label" : "Rhode Island" },
            { "value" : "South Carolina", "label" : "South Carolina" },
            { "value" : "South Dakota", "label" : "South Dakota" },	
            { "value" : "Tennessee", "label" : "Tennessee" },
            { "value" : "Texas", "label" : "Texas" },	
            { "value" : "Utah", "label" : "Utah" },
            { "value" : "Vermont", "label" : "Vermont" },	
            { "value" : "Virginia", "label" : "Virginia" },
            { "value" : "Washington", "label" : "Washington" },	
            { "value" : "West Virginia", "label" : "West Virginia" },
            { "value" : "Wisconsin", "label" : "Wisconsin" },	
            { "value" : "Wyoming", "label" : "Wyoming" }
        ];

        if( country && country.toUpperCase() == 'MEXICO'){
            component.set("v.stateOptions", mexicoOptions);
        }else if( country && country.toUpperCase() == 'CANADA'){
            component.set("v.stateOptions", canadaOptions);
        }else if( country && country.toUpperCase() == 'UNITED STATES'){
            component.set("v.stateOptions", usOptions);
        }
        
    },
});