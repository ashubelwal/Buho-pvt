public with sharing class PaymentFormController {

    @AuraEnabled
    public static void createProfileSubscription(String transactionDetails) {
        //TODO: change units to days, trial occurrences to 0, start day to end day minus 7 in case if start date should be end date - 7 days
        try {
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
                JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
            TransactionService.createProfileSubscription(paymentTransaction, 12, 'months', 0, 9999, 0.0);
        } catch (AuthorizeNetClient.DuplicateSubscriptionException ex) {
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new AuraHandledException('An error occurred during subscription process');
        }
    }

    @AuraEnabled
    public static void createSubscription(String newCreditCard, String transactionDetails) {
        try {
            ContactService.CreditCard creditCard = (ContactService.CreditCard) JSON.deserialize(newCreditCard, ContactService.CreditCard.class);
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
                JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
            TransactionService.createSubscription(creditCard, paymentTransaction, 12, 'months', 0, 9999, 0.0);} catch (AuthorizeNetClient.DuplicateSubscriptionException ex) {CustomErrorExceptionHandlerException.LogException(ex);throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new AuraHandledException('An error occurred during subscription process');
        }
    }

    @AuraEnabled
    public static map<string, object> createPaymentProfileTransaction(String transactionDetails) {
        map<string, object> responseMap = new map<string, object>();
        try {
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
            JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
            TransactionService.createPaymentProfileTransaction(paymentTransaction);
            responseMap.put('status', 'success');} catch (AuthorizeNetClient.DuplicateTransactionException ex) {responseMap.put('status', 'error');responseMap.put('status', ex.getMessage());CustomErrorExceptionHandlerException.LogException(ex);throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            //throw new AuraHandledException('An error occurred during payment process');
            System.debug('--ex----'+ex);
            String exceptionStr = '';
            CustomErrorExceptionHandlerException.LogException(ex);
            if( ex.getMessage().contains(':')){exceptionStr = ex.getMessage().substringAfter(':');
            }
            responseMap.put('status', 'error');
            responseMap.put('status', ex.getMessage());
            if( exceptionStr != ''){throw new AuraHandledException(exceptionStr);
            }else{
                throw new AuraHandledException(ex.getMessage());
            }
        }
        system.debug('--responseMap---'+ responseMap);
        return responseMap;
    }

    @AuraEnabled
    public static map<string, object> createAdditionalPaymentProfileTransactionForCards(String transactionDetails, Decimal amount, String policyId) {
        map<string, object> responseMap = new map<string, object>();
        try {
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
                JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
                TransactionService.createPaymentProfileCardTransaction(paymentTransaction, amount, policyId);
                responseMap.put('status', 'success');} catch (AuthorizeNetClient.DuplicateTransactionException ex) {CustomErrorExceptionHandlerException.LogException(ex);responseMap.put('status', 'error');responseMap.put('status', ex.getMessage());throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            //throw new AuraHandledException('An error occurred during payment process');
            System.debug('--ex----'+ex);
            CustomErrorExceptionHandlerException.LogException(ex);
            String exceptionStr = '';
            if( ex.getMessage().contains(':')){exceptionStr = ex.getMessage().substringAfter(':');
            }
            responseMap.put('status', 'error');
            responseMap.put('status', ex.getMessage());
            if( exceptionStr != ''){throw new AuraHandledException(exceptionStr);
            }else{
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static map<string, object> createAdditionalPaymentProfileTransaction(String transactionDetails, Decimal amount, String policyId) {
        map<string, object> responseMap = new map<string, object>();
        try {
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
                JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
                TransactionService.createAdditionalPaymentProfileTransaction(paymentTransaction, amount, policyId);
                responseMap.put('status', 'success');} catch (AuthorizeNetClient.DuplicateTransactionException ex) {CustomErrorExceptionHandlerException.LogException(ex);responseMap.put('status', 'error');responseMap.put('status', ex.getMessage());throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            //throw new AuraHandledException('An error occurred during payment process');
            System.debug('--ex----'+ex);
            CustomErrorExceptionHandlerException.LogException(ex);
            String exceptionStr = '';
            if( ex.getMessage().contains(':')){exceptionStr = ex.getMessage().substringAfter(':');
            }
            responseMap.put('status', 'error');
            responseMap.put('status', ex.getMessage());
            if( exceptionStr != ''){throw new AuraHandledException(exceptionStr);
            }else{
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return responseMap;
    }

    @AuraEnabled
    public static map<string, object> createTransaction(String newCreditCard, String transactionDetails, String email) {
        map<string, object> responseMap = new map<string, object>();
        try {
            System.debug('newCreditCard~~~ : ' + newCreditCard);
            System.debug('transactionDetails~~~ : ' + transactionDetails);
            ContactService.CreditCard creditCard = (ContactService.CreditCard) JSON.deserialize(newCreditCard, ContactService.CreditCard.class);
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
            JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
            System.debug('creditCard~~~ : ' + creditCard);
            System.debug('paymentTransaction~~~ : ' + paymentTransaction);
            TransactionService.createPaymentTransaction(creditCard, paymentTransaction, email);
            responseMap.put('status', 'success');} catch (AuthorizeNetClient.DuplicateTransactionException ex) {CustomErrorExceptionHandlerException.LogException(ex);responseMap.put('status', 'error');responseMap.put('message', ex.getMessage() + ' at line '+ ex.getLineNumber());throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            System.debug('--ex----'+ex+'-line--'+ex.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(ex);
            String exceptionStr = '';
            if( ex.getMessage().contains(':')){exceptionStr = ex.getMessage().substringAfter(':');
            }
            responseMap.put('status', 'error');
            responseMap.put('message', exceptionStr + ' at line '+ ex.getLineNumber());
            if( exceptionStr != ''){throw new AuraHandledException(exceptionStr);
            }else{
                System.debug('In error in else part ' + responseMap + '. Message : ' + ex.getMessage());
                throw new StringException(ex.getMessage());
            }
            
        }
        return responseMap;
    }

    @AuraEnabled
    public static map<string, object> createTransactionWithPredefinedAmount(String newCreditCard, String transactionDetails, Decimal amount, String policyId, String email) {
        map<string, object> responseMap = new map<string, object>();
        try {
            System.debug('newCreditCard~~~ : ' + newCreditCard);
            System.debug('transactionDetails~~~ : ' + transactionDetails);
            ContactService.CreditCard creditCard = (ContactService.CreditCard) JSON.deserialize(newCreditCard, ContactService.CreditCard.class);
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
                JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
            System.debug('creditCard~~~ : ' + creditCard);
            System.debug('paymentTransaction~~~ : ' + paymentTransaction);
            system.debug('Decimalvalue'+amount);
            system.debug('policyId'+policyId);
            TransactionService.createPaymentTransactionWithPredefinedAmount(creditCard, paymentTransaction, amount, policyId, email);
             responseMap.put('status', 'success');} catch (AuthorizeNetClient.DuplicateTransactionException ex) {CustomErrorExceptionHandlerException.LogException(ex);responseMap.put('status', 'error');responseMap.put('message', ex.getMessage() + ' at line '+ ex.getLineNumber());throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            //throw new AuraHandledException('An error occurred during payment process');
            System.debug('--ex----'+ex+'-line--'+ex.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(ex);
            String exceptionStr = '';
            if( ex.getMessage().contains(':')){
                exceptionStr = ex.getMessage().substringAfter(':');
            }
            responseMap.put('status', 'error');
            responseMap.put('message', exceptionStr + ' at line '+ ex.getLineNumber());
            if( exceptionStr != ''){
                throw new AuraHandledException(exceptionStr);
            }else{
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return responseMap;
    }
    

    @AuraEnabled
    public static map<string, object> refundTransaction(String newCreditCard, String transactionDetails, Decimal refundAmount, String policyId, String refundObjtext) {
        map<string, object> responseMap = new map<string, object>();
        try {            
            ContactService.CreditCard creditCard = (ContactService.CreditCard) JSON.deserialize(newCreditCard, ContactService.CreditCard.class);
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
                JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
            TransactionService.refundPaymentTransaction(creditCard, paymentTransaction, refundAmount, policyId,refundObjtext);
            responseMap.put('status', 'success');} catch (AuthorizeNetClient.DuplicateTransactionException ex) {CustomErrorExceptionHandlerException.LogException(ex);responseMap.put('status', 'error');responseMap.put('message', ex.getMessage() + ' at line '+ ex.getLineNumber());throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            //throw new AuraHandledException('An error occurred during payment process');
            System.debug('--ex----'+ex+'-line--'+ex.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(ex);
            String exceptionStr = '';
            if( ex.getMessage().contains(':')){
                exceptionStr = ex.getMessage().substringAfter(':');
            }
            responseMap.put('status', 'error');
            responseMap.put('message', exceptionStr + ' at line '+ ex.getLineNumber());
            if( exceptionStr != ''){
                throw new AuraHandledException(exceptionStr);
            }else{
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return responseMap;
    }

    @AuraEnabled
    public static map<string, object> refundTransactionUsingSavedCard(String transactionDetails, Decimal refundAmount, String policyId) {
        map<string, object> responseMap = new map<string, object>();
        try {
            System.debug('transactionDetails');
            System.debug(transactionDetails);
            TransactionService.PaymentTransaction paymentTransaction = (TransactionService.PaymentTransaction)
                JSON.deserialize(transactionDetails, TransactionService.PaymentTransaction.class);
            TransactionService.refundPaymentTransactionFromCard(paymentTransaction, refundAmount, policyId);
            responseMap.put('status', 'success');} catch (AuthorizeNetClient.DuplicateTransactionException ex) {CustomErrorExceptionHandlerException.LogException(ex);responseMap.put('status', 'error');responseMap.put('message', ex.getMessage() + ' at line '+ ex.getLineNumber());throw new AuraHandledException(ex.getMessage());
        } catch (Exception ex) {
            //throw new AuraHandledException('An error occurred during payment process');
            //System.debug('--ex----'+ex+'-line--'+ex.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(ex);
            String exceptionStr = '';
            if( ex.getMessage().contains(':')){
                exceptionStr = ex.getMessage().substringAfter(':');
            }
            responseMap.put('status', 'error');
            responseMap.put('message', exceptionStr + ' at line '+ ex.getLineNumber());
            if( exceptionStr != ''){
                throw new AuraHandledException(exceptionStr);
               // System.debug(exceptionStr);
            }else{
                throw new AuraHandledException(ex.getMessage());
               //System.debug(ex.getMessage());
            }
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static String createPaymentProfile(String newCreditCard, List<String> quoteIds) {
        String paymentProfileId;
        
            ContactService.CreditCard creditCard = (ContactService.CreditCard) JSON.deserialize(newCreditCard, ContactService.CreditCard.class);
            paymentProfileId = ContactService.createProfile(creditCard, quoteIds);
        
        return paymentProfileId;
    }

    @AuraEnabled
    public static String getPaymentInfo(List<String> quoteIds) {
        ContactService.PaymentInfo paymentInfo;
        try {
            paymentInfo = ContactService.getPaymentInfo(quoteIds);
            system.debug('paymentInfo : '+ paymentInfo);
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new AuraHandledException('An error occurred during retrieving credit card information');
        }
        return JSON.serialize(paymentInfo);
    }

    @AuraEnabled
    public static String getAddress( String policyId ) {
        ContactService.CreditCard creditCard;
        try {
            list<Quote_Vehicle__c> qVehicles = new list<Quote_Vehicle__c>();
            qVehicles = [select Id, Policy__c, Vehicle__c, Vehicle__r.Vehicle_Owner_Address__c, Vehicle__r.Vehicle_Owner_City__c,
                        Vehicle__r.Vehicle_Owner_State__c, Vehicle__r.Vehicle_Owner_Country__c,
                        Vehicle__r.Vehicle_Owner_Postal_Code__c from Quote_Vehicle__c 
                        where Policy__c=: policyId and Vehicle__r.Vehicle_Owner_Name__c != null ];
            if( qVehicles != null && !qVehicles.isEmpty() ){
                creditCard = new ContactService.CreditCard();
                creditCard.address1 = qVehicles[0].Vehicle__r.Vehicle_Owner_Address__c;
                creditCard.zip = qVehicles[0].Vehicle__r.Vehicle_Owner_Postal_Code__c;
                creditCard.country = qVehicles[0].Vehicle__r.Vehicle_Owner_Country__c;
                creditCard.state = qVehicles[0].Vehicle__r.Vehicle_Owner_State__c;
                creditCard.city = qVehicles[0].Vehicle__r.Vehicle_Owner_City__c;
            }

            if( creditCard == null ){
                list<Quote_Driver__c> qDrivers = new list<Quote_Driver__c>();
                qDrivers = [select Id, Policy__c, Driver__c from Quote_Driver__c where Policy__c=: policyId  ];
                set<String> driverIds = new set<String>();
                for(Quote_Driver__c qdr : qDrivers){
                    driverIds.add(qdr.Driver__c);
                }
                for(Driver__c dr : [select Id, City__c, Country__c, State_Province__c, Postal_Code__c, Address__c from Driver__c where Id In: driverIds and Primary_insured__c = true limit 1 ]){
                    creditCard = new ContactService.CreditCard();
                    creditCard.address1 = dr.Address__c;
                    creditCard.zip = dr.Postal_Code__c;
                    creditCard.country = dr.Country__c;
                    creditCard.state = dr.State_Province__c;
                    creditCard.city = dr.City__c;
                }
            }

            if( creditCard == null ){
                creditCard = ContactService.getAddress();
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new AuraHandledException('An error occurred during retrieving address information');
        }
        return JSON.serialize(creditCard);
    }

    @AuraEnabled
    public static String getDriverAddress( List<String> quoteIds ) {
        //list<Driver__c> drivers =  new list<Driver__c>();
        list<Contact> conDetails = new List<Contact>();
        try {
            System.debug('-quoteIds--'+quoteIds);
            if( quoteIds != null && !quoteIds.isEmpty() ){
                //drivers =  QuickQuotationCtrl.getDriver( quoteIds[0] );
                conDetails = QuickQuotationCtrl.getContact(quoteIds[0]);
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.LogException(ex);
            throw new AuraHandledException('An error occurred during retrieving address information');
        }
        return JSON.serialize(conDetails);
    }
    
     public static Map<String, String> createNewEditPolicy(String vehicleData, String DriverData, String towedUnitData, String quoteId, String oldPolicyId, Boolean isRenewal) {
        Map<String, String> responseMap = new Map<String, String>();

        try {
            if (String.isNotBlank(quoteId)) {
                SYstem.debug('inside QuoteId' + quoteId);
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c 
                                        FROM Quote__c WHERE Id = :quoteId];
                
                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                System.debug('policyTransaction--> '+policyTransaction);
                 System.debug('oldPolicy--> '+oldPolicyId);
                if (!policyTransaction.isEmpty()) {
                    // Get Old Policy Record
                    Policy__c oldPolicy;
                    if (String.isNotBlank(oldPolicyId)) {
                        oldPolicy = [SELECT Id, Name, Quote_c__c, Affiliate_Account__c,Contact_Email__c, What_is_the_purpose_of_trip__c, RecordTypeId, 
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId];
                        System.debug('oldPolicy--> '+oldPolicy);
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Vehicle__c vehicleRecord;
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                        upsert vehicleRecord;
                    } else {
                        // return error -> Vehicle record missing
                    }
                    
                    // Upsert the Driver Record
                    List<Driver__c> driverList;
                    if (!String.isEmpty(DriverData)) {
                        driverList = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);
                        
                        for (Driver__c eachDriver : driverList) {
                            eachDriver.Contact__c = quoteRecord.Contact__c;
                        }

                        upsert driverList;
                    } else {
                        // return error -> Driver record missing
                    }
                    System.debug('towedUnitData'+towedUnitData);
                    // Upsert the Towed Unit Record
                    List<Towed_Unit__c> towedUnitList =new List<Towed_Unit__c>();
                    if (!String.isEmpty(towedUnitData)) {
                        System.debug('towedUnitData'+towedUnitData);
                        towedUnitList = (List<Towed_Unit__c>) JSON.deserialize(towedUnitData, List<Towed_Unit__c>.class);
                        System.debug('towedUnitList'+towedUnitList);
                        upsert towedUnitList;
                    }
                    System.debug('towedUnitList'+towedUnitList);
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    // Create edit Policy Clone
                    Policy__c newPolicy = new Policy__c();
                    newPolicy.Broker_Policy_Fee__c = quoteRecord.Broker_Policy_Fee__c;
                    newPolicy.I_V_A_Mex_Tax__c = quoteRecord.I_V_A_Mex_Tax__c;
                    newPolicy.Net_Premium__c = quoteRecord.Net_Premium__c;
                    newPolicy.Policy_Type_picklist__c = quoteRecord.Policy_Type_picklist__c;
                    newPolicy.Quote_c__c = quoteRecord.Id;
                    newPolicy.Package__c = quoteRecord.Coverage__c;
                    newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
                    newPolicy.Surcharge__c = quoteRecord.Surcharge__c;
                    newPolicy.Vehicle_deductible_collision__c = quoteRecord.Vehicle_Deductible_Collision__c;
                    newPolicy.Vehicle_deductible_comprehensive__c = quoteRecord.Vehicle_Deductible_Comprehensive__c;
                    newPolicy.Vehicle_Policy__c = vehicleRecord.Id;
                    newPolicy.Contact__c = quoteRecord.Contact__c;
                    newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
                    newPolicy.Account_Policy__c = quoteRecord.Account__c;
                    newPolicy.Status_picklist__c = 'Active';
                    newPolicy.Source__c = 'New Lead Flow';
                    newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                    newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                    newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                    newPolicy.Term__c = quoteRecord.Term__c;
                    
                    if (quoteRecord.Term__c != null && (quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual' )) {
                        newPolicy.Term_days__c = 365;
                    } else {
                        newPolicy.Term_days__c = quoteRecord.Term_Days__c;
                    }
                    
                    if (quoteRecord.Start_Date_for_Coverage__c != null) {
                        newPolicy.Start_Date__c = quoteRecord.Start_Date_for_Coverage__c;
                    }
                    if (quoteRecord.Start_Time__c != null) {
                        newPolicy.Start_Time__c = quoteRecord.Start_Time__c;
                    }
                    if (quoteRecord.End_Date_for_Coverage__c != null) {
                        newPolicy.End_Date__c = quoteRecord.End_Date_for_Coverage__c;
                    }
                    if (quoteRecord.End_Time__c != null) {
                        newPolicy.End_Time__c = quoteRecord.End_Time__c;
                    }

                    newPolicy.Underwriter_picklist__c = quoteRecord.Underwriter__c;
                    newPolicy.Vehicle_type__c = quoteRecord.Vehicle_Type__c;
                    newPolicy.Insured_value__c = quoteRecord.Vehicle_Value__c;
                    if (oldPolicy != null && !isRenewal) {
                        String oldPolicyName = oldPolicy.Name;
                        
                        newPolicy.Affiliate_Account__c = oldPolicy.Affiliate_Account__c;
                        String cloneOldPolicyName = oldPolicyName.substringAfterLast('-');
                        
                        if (cloneOldPolicyName != null && cloneOldPolicyName.length() > 2) {
                            oldPolicyName += '-2';
                        } else {
                            Integer num = Integer.valueOf(cloneOldPolicyName) + 1;
                            oldPolicyName = oldPolicyName.substringBeforeLast('-') + '-' + num;
                        }
                        newPolicy.Name = oldPolicyName;
                        // newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
                    } else {
                        
                        newPolicy.renewed_check__c = true;
                        newPolicy.renewed_from_id__c = oldPolicy.Id;
                        newPolicy.Name = Mex_NewLeadProcess.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                        system.debug('New Policy-->'+newPolicy);
                    }

                    newPolicy.What_is_the_purpose_of_trip__c = oldPolicy.What_is_the_purpose_of_trip__c != null ? oldPolicy.What_is_the_purpose_of_trip__c : '';
                    newPolicy.What_is_your_trip_destination_in_US__c = oldPolicy.What_is_your_trip_destination_in_US__c != null ? oldPolicy.What_is_your_trip_destination_in_US__c : '';
                    newPolicy.Terms_of_Purchase_Confirmed__c = oldPolicy.Terms_of_Purchase_Confirmed__c != null ? oldPolicy.Terms_of_Purchase_Confirmed__c : false;
                    newPolicy.Terms_of_Cancellation_Confirmed__c = oldPolicy.Terms_of_Cancellation_Confirmed__c != null ? oldPolicy.Terms_of_Cancellation_Confirmed__c : false;
                    if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }

                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;
                    
                    insert newPolicy;
                    
                    // Update the Old Policy Record...
                    if (oldPolicy != null && !isRenewal) {
                        oldPolicy.Status_picklist__c  = 'Updated';
                        oldPolicy.Policy__c = newPolicy.Id;
                        update oldPolicy;
                    }
                    
                    // update the New Quote Record
                    if (quoteRecord != null) {
                        quoteRecord.Quote_Status__c = 'Policy Created';
                        update quoteRecord;
                    }
                    
                    // Create New Quote Vehicle Record
                    Quote_Vehicle__c newQuoteVehicle = new Quote_Vehicle__c();
                    newQuoteVehicle.Account__c = quoteRecord.Account__c;
                    newQuoteVehicle.Contact__c = quoteRecord.Contact__c;
                    newQuoteVehicle.Quote_c__c = quoteRecord.Id;
                    newQuoteVehicle.Policy__c = newPolicy.Id;
                    newQuoteVehicle.Vehicle__c = vehicleRecord.Id;
                    insert newQuoteVehicle;
                    
                    // Create New Quote Driver Record
                    List<Quote_Driver__c> newQuoteDriverList = new List<Quote_Driver__c>();
                    if (!driverList.isEmpty() && driverList.size() > 0) {
                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
                        }
                    }
                    
                    // Create New Quote Towed Unit Record
                    List<Quote_Towed_Unit__c> newQuoteTowedUnitList = new List<Quote_Towed_Unit__c>();
                    if (towedUnitList.size() > 0 && !towedUnitList.isEmpty() ) {
                        for (Towed_Unit__c each : towedUnitList) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            newQuoteTowed.Account__c = quoteRecord.Account__c;
                            newQuoteTowed.Contact__c = quoteRecord.Contact__c;
                            newQuoteTowed.Quote_c__c = quoteRecord.Id;
                            newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
                            newQuoteTowed.Towed_Unit__c = each.Id;
                            newQuoteTowed.Policy__c = newPolicy.id;
                            newQuoteTowedUnitList.add(newQuoteTowed);
                        }
                        
                        if (!newQuoteTowedUnitList.isEmpty()) {
                            insert newQuoteTowedUnitList;
                        }
                    }
                    
                    // Update New Transaction Record
                    policyTransaction[0].Policy_Transaction__c = newPolicy.Id;
                    policyTransaction[0].Account_Transaction__c = quoteRecord.Account__c;
                    update policyTransaction;
                    
                    // Update the Old Policy Transaction Record
                    List<Transaction__c> oldPolicyTransactionList = [SELECT Id, Policy_Transaction__c, Quote_c__c FROM Transaction__c Where Policy_Transaction__c = :oldPolicy.Id LIMIT 500];
                    
                    if (!oldPolicyTransactionList.isEmpty() && isRenewal == false) {
                        List<Transaction__c> oldPolicyTransList = new List<Transaction__c>();
                        for (Transaction__c eachTrans : oldPolicyTransactionList) {
                            eachTrans.Policy_Transaction__c = newPolicy.Id;
                            eachTrans.Quote_c__c = quoteRecord.Id;
                            eachTrans.Account_Transaction__c = quoteRecord.Account__c;
                            oldPolicyTransList.add(eachTrans);
                            System.debug('oldPolicyTransList-->'+oldPolicyTransList);
                        }
                        
                        if (!oldPolicyTransList.isEmpty()) {
                            update oldPolicyTransList;
                        }
                    }else{
                        System.debug('isRenewal-->'+isRenewal);
                        
                    }
                    System.debug('Test Email');
                    // send email to the user along with attachment...
                    Set<String> policyIds = new Set<String>();
                    if (!String.isBlank(newPolicy.Id)) {
                        System.debug('Test Email222');
                        policyIds.add(newPolicy.Id);
                    }
                    System.debug('Test Email3333');
                    if (policyIds != null && !policyIds.isEmpty()) {
                        Boolean add_attachment = true;
                       // Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
                    }

                    responseMap.put('status', 'success');
                    responseMap.put('data', String.valueOf(newPolicy.Id));
                } else {
                    // return error -> Transaction missing;
                }
                    } else {
                        // return error -> quoteId missing
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'Quote Id is missing, can\'t edit the policy.');
                        return responseMap;
                    }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'vehicleData: ' + vehicleData + '\nDriverData: ' + DriverData + '\ntowedUnitData: ' + towedUnitData + '\nquoteId: ' + quoteId + '\noldPolicyId: ' + oldPolicyId + '\nisRenewal: ' + isRenewal;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            System.debug('Create new edit policy error '+ ex.getMessage() + 'at - ' + ex.getLineNumber());
            responseMap.put('message', ex.getMessage() + 'at - ' + ex.getLineNumber());
        }
        
        return responseMap;
    }
    
    public static Map<String, String> createNewWatercraftEditPolicy(String watercraftData, String DriverData, String quoteId, String oldPolicyId, Boolean isRenewal) {
        Map<String, String> responseMap = new Map<String, String>();
        try {
            if (!String.isEmpty(quoteId)) {
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c 
                                        FROM Quote__c WHERE Id = :quoteId];
                
                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                
                if (!policyTransaction.isEmpty()) {
                    // Get Old Policy Record
                    Policy__c oldPolicy;
                    if (!String.isEmpty(oldPolicyId)) {
                        oldPolicy = [SELECT Id, Name, Quote_c__c, Affiliate_Account__c,Contact_Email__c, What_is_the_purpose_of_trip__c, RecordTypeId, 
                                     What_is_your_trip_destination_in_US__c, Terms_of_Purchase_Confirmed__c, Terms_of_Cancellation_Confirmed__c 
                                     FROM Policy__c 
                                     WHERE Id = :oldPolicyId];
                    } else {
                        // return error -> old policy record missing, can't edit/renew a policy
                    }
                    
                    // Update Vehicle Record
                    Watercraft__c watercraftRecord;
                    if (!String.isEmpty(watercraftData)) {
                        watercraftRecord = (Watercraft__c) JSON.deserialize(watercraftData, Watercraft__c.class);
                        upsert watercraftRecord;
                    } else {
                        // return error -> Vehicle record missing
                    }
                    
                    // Upsert the Driver Record
                    List<Driver__c> driverList;
                    if (!String.isEmpty(DriverData)) {
                        driverList = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);
                        
                        for (Driver__c eachDriver : driverList) {
                            eachDriver.Contact__c = quoteRecord.Contact__c;
                        }

                        upsert driverList;
                    } else {
                        // return error -> Driver record missing
                    }
                    
                   Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    // Create edit Policy Clone
                    Policy__c newPolicy = new Policy__c();
                    newPolicy.Broker_Policy_Fee__c = quoteRecord.Broker_Policy_Fee__c;
                    newPolicy.I_V_A_Mex_Tax__c = quoteRecord.I_V_A_Mex_Tax__c;
                    newPolicy.Net_Premium__c = quoteRecord.Net_Premium__c;
                    newPolicy.Policy_Type_picklist__c = quoteRecord.Policy_Type_picklist__c;
                    newPolicy.Quote_c__c = quoteRecord.Id;
                    newPolicy.Package__c = quoteRecord.Coverage__c;
                    newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
                    newPolicy.Surcharge__c = quoteRecord.Surcharge__c;
                    newPolicy.Vehicle_deductible_collision__c = quoteRecord.Vehicle_Deductible_Collision__c;
                    newPolicy.Vehicle_deductible_comprehensive__c = quoteRecord.Vehicle_Deductible_Comprehensive__c;
                    newPolicy.Watercraft__c = watercraftRecord.Id;
                    newPolicy.Contact__c = quoteRecord.Contact__c;
                    newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
                    newPolicy.Account_Policy__c = quoteRecord.Account__c;
                    newPolicy.Status_picklist__c = 'Active';
                    newPolicy.Source__c = 'New Lead Flow';
                    newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                    newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                    newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                    newPolicy.Term__c = quoteRecord.Term__c;
                    
                    if (quoteRecord.Term__c != null && (quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual')) {
                        newPolicy.Term_days__c = 365;
                    } else {
                        newPolicy.Term_days__c = quoteRecord.Term_Days__c;
                    }
                    
                    if (quoteRecord.Start_Date_for_Coverage__c != null) {
                        newPolicy.Start_Date__c = quoteRecord.Start_Date_for_Coverage__c;
                    }
                    if (quoteRecord.Start_Time__c != null) {
                        newPolicy.Start_Time__c = quoteRecord.Start_Time__c;
                    }
                    if (quoteRecord.End_Date_for_Coverage__c != null) {
                        newPolicy.End_Date__c = quoteRecord.End_Date_for_Coverage__c;
                    }
                    if (quoteRecord.End_Time__c != null) {
                        newPolicy.End_Time__c = quoteRecord.End_Time__c;
                    }


                    newPolicy.Underwriter_picklist__c = quoteRecord.Underwriter__c;
                    newPolicy.Vehicle_type__c = quoteRecord.Vehicle_Type__c;
                    newPolicy.Insured_value__c = quoteRecord.Vehicle_Value__c;
                    if (oldPolicy != null && !isRenewal) {
                        String oldPolicyName = oldPolicy.Name;
                        
                        newPolicy.Affiliate_Account__c = oldPolicy.Affiliate_Account__c;
                        String cloneOldPolicyName = oldPolicyName.substringAfterLast('-');
                        
                        if (cloneOldPolicyName != null && cloneOldPolicyName.length() > 2) {
                            oldPolicyName += '-2';
                        } else {
                            Integer num = Integer.valueOf(cloneOldPolicyName) + 1;
                            oldPolicyName = oldPolicyName.substringBeforeLast('-') + '-' + num;
                        }
                        newPolicy.Name = oldPolicyName;
                        // newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
                    } else {
                        newPolicy.renewed_check__c = true;
                        newPolicy.renewed_from_id__c = oldPolicy.Id;
                        newPolicy.Name = Mex_NewLeadProcess.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                    }

                    newPolicy.What_is_the_purpose_of_trip__c = oldPolicy.What_is_the_purpose_of_trip__c != null ? oldPolicy.What_is_the_purpose_of_trip__c : '';
                    newPolicy.What_is_your_trip_destination_in_US__c = oldPolicy.What_is_your_trip_destination_in_US__c != null ? oldPolicy.What_is_your_trip_destination_in_US__c : '';
                    newPolicy.Terms_of_Purchase_Confirmed__c = oldPolicy.Terms_of_Purchase_Confirmed__c != null ? oldPolicy.Terms_of_Purchase_Confirmed__c : false;
                    newPolicy.Terms_of_Cancellation_Confirmed__c = oldPolicy.Terms_of_Cancellation_Confirmed__c != null ? oldPolicy.Terms_of_Cancellation_Confirmed__c : false;
                    if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }
                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;
                    
                    insert newPolicy;
                    
                    // Update the Old Policy Record...
                    if (oldPolicy != null && !isRenewal) {
                        oldPolicy.Status_picklist__c  = 'Updated';
                        oldPolicy.Policy__c = newPolicy.Id;
                        update oldPolicy;
                    }
                    
                    // update the New Quote Record
                    if (quoteRecord != null) {
                        quoteRecord.Quote_Status__c = 'Policy Created';
                        update quoteRecord;
                    }
                    
                    Quote_Watercraft__c newQuoteWatercraft = new Quote_Watercraft__c();
                    newQuoteWatercraft.Account__c = quoteRecord.Account__c;
                    newQuoteWatercraft.Contact__c = quoteRecord.Contact__c;
                    newQuoteWatercraft.Watercraft__c = watercraftRecord.Id;
                    newQuoteWatercraft.Quote_c__c = quoteRecord.Id;
                    newQuoteWatercraft.Policy__c = newPolicy.Id;
                    insert newQuoteWatercraft;

                    // Create New Quote Driver Record
                    List<Quote_Driver__c> newQuoteDriverList = new List<Quote_Driver__c>();
                    if (!driverList.isEmpty()) {
                        for (Driver__c each : driverList) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = quoteRecord.Account__c;
                            newQuoteDriver.Contact__c = quoteRecord.Contact__c;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Driver__c = each.Id;
                            newQuoteDriver.Watercraft__c = watercraftRecord.Id;
                            newQuoteDriver.Policy__c = newPolicy.Id;
                            newQuoteDriverList.add(newQuoteDriver);
                        }
                        
                        if (!newQuoteDriverList.isEmpty()) {
                            insert newQuoteDriverList;
                        }
                    }

                    // Update New Transaction Record
                    policyTransaction[0].Policy_Transaction__c = newPolicy.Id;
                    policyTransaction[0].Account_Transaction__c = quoteRecord.Account__c;
                    update policyTransaction;
                    
                    // Update the Old Policy Transaction Record
                    List<Transaction__c> oldPolicyTransactionList = [SELECT Id, Policy_Transaction__c, Quote_c__c FROM Transaction__c Where Policy_Transaction__c = :oldPolicy.Id LIMIT 500];
                    
                    if (!oldPolicyTransactionList.isEmpty() && !isRenewal) {
                        List<Transaction__c> oldPolicyTransList = new List<Transaction__c>();
                        for (Transaction__c eachTrans : oldPolicyTransactionList) {
                            eachTrans.Policy_Transaction__c = newPolicy.Id;
                            eachTrans.Quote_c__c = quoteRecord.Id;
                            eachTrans.Account_Transaction__c = quoteRecord.Account__c;
                            oldPolicyTransList.add(eachTrans);
                        }
                        
                        if (!oldPolicyTransList.isEmpty()) {
                            update oldPolicyTransList;
                        }
                    }
                    
                    // send email to the user along with attachment...
                    Set<String> policyIds = new Set<String>();
                    if (!String.isBlank(newPolicy.Id)) {
                        policyIds.add(newPolicy.Id);
                    }

                    responseMap.put('status', 'success');
                    responseMap.put('data', String.valueOf(newPolicy.Id));
                } else {
                    // return error -> Transaction missing;
                }
                    
                    } else {
                        // return error -> quoteId missing
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'Quote Id is missing, can\'t edit the policy.');
                        return responseMap;
                    }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'watercraftData: '+ watercraftData +'\nDriverData: ' + DriverData + '\nquoteId: ' + quoteId + '\noldPolicyId: ' + oldPolicyId + 'isRenewal: ' + isRenewal;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            System.debug('Create new watercraft edit policy:' + ex.getMessage());
            responseMap.put('message', ex.getMessage());
        }
        
        return responseMap;
    }
    
    public static void sendAutoRenewEmail(set<String> policyIds, Boolean add_attachment){
        String endPoint = '/services/apexrest/sendEmailService/*'; 
        map<String,object> ldObjectMap = new map<String,Object>();
        ldObjectMap.put('policyIdset', policyIds);
        ldObjectMap.put('add_attachment', add_attachment);
        system.debug('ldObjectMap-->'+ldObjectMap);
        String body = JSON.serialize(ldObjectMap);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Salesforce'+endPoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        
        System.debug('--endpoint--'+request.getEndpoint());
        
        if( body != null && body != ''){
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
        }
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('--response--'+response);
        System.debug('--response--'+response.getBody());
                        
    }
}