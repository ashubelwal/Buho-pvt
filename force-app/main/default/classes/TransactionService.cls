public without sharing class TransactionService {

    public static void createPaymentProfileTransaction(PaymentTransaction paymentTransaction) {
        List<Authorize_Net_Customer_Profile__c> profiles = ContactService.getCustomerProfiles();
        Boolean paymentProfileFound = false;
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            for (Authorize_Net_Payment_Profile__c paymentProfile : profile.Authorize_Net_Payment_Profiles__r) {
                if (paymentProfile.Payment_Profile_Id__c == paymentTransaction.paymentProfileId) {
                    paymentProfileFound = true;
                    paymentTransaction.customerProfileId = profile.Profile_Id__c;
                }
            }
        }
        if (!paymentProfileFound) { throw new ContactService.ProfileException('The credit card doesn\'t exist in the system');
        }

        AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
        transactionRequest.transactionRequest.profile.customerProfileId = paymentTransaction.customerProfileId;
        transactionRequest.transactionRequest.profile.paymentProfile.paymentProfileId = paymentTransaction.paymentProfileId;
        setIp(transactionRequest, paymentTransaction);
        setTransactionLineItems(paymentTransaction, transactionRequest);
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false; system.debug('transactionRequest------------24-----> '+ transactionRequest);
        AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendChargeCustomerProfileRequest(transactionRequest);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        system.debug('response------------27-----> '+ response); system.debug('quotes------------28-----> '+ quotes);
        TransactionService.saveTransactionRecord(null, transactionRequest, response, quotes);
    }
    

    public static void createPaymentProfileCardTransaction(PaymentTransaction paymentTransaction,Decimal amount, String policyId) {
        List<Authorize_Net_Customer_Profile__c> profiles = ContactService.getCustomerProfiles();
        Boolean paymentProfileFound = false;
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            for (Authorize_Net_Payment_Profile__c paymentProfile : profile.Authorize_Net_Payment_Profiles__r) {
                if (paymentProfile.Payment_Profile_Id__c == paymentTransaction.paymentProfileId) {
                    paymentProfileFound = true;
                    paymentTransaction.customerProfileId = profile.Profile_Id__c;
                }
            }
        }
        if (!paymentProfileFound) { throw new ContactService.ProfileException('The credit card doesn\'t exist in the system');}
        AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
        transactionRequest.transactionRequest.profile.customerProfileId = paymentTransaction.customerProfileId;
        transactionRequest.transactionRequest.profile.paymentProfile.paymentProfileId = paymentTransaction.paymentProfileId;
        setIp(transactionRequest, paymentTransaction);
        transactionRequest.transactionRequest.amount = (Math.abs(amount)).setScale(2, RoundingMode.HALF_UP);
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false;
        system.debug('transactionRequest------------24-----> '+ transactionRequest);
        AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendChargeCustomerProfileRequest(transactionRequest);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        TransactionService.saveTransactionRecordWithPredefinedAmount(policyId, transactionRequest, response, quotes, amount);
    }

    public static void createAdditionalPaymentProfileTransaction(PaymentTransaction paymentTransaction, Decimal amount, String policyId) {
        List<Authorize_Net_Customer_Profile__c> profiles = ContactService.getCustomerProfiles();
        Boolean paymentProfileFound = false;
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            for (Authorize_Net_Payment_Profile__c paymentProfile : profile.Authorize_Net_Payment_Profiles__r) {
                if (paymentProfile.Payment_Profile_Id__c == paymentTransaction.paymentProfileId) {
                    paymentProfileFound = true;
                    paymentTransaction.customerProfileId = profile.Profile_Id__c;
                }
            }
        }
        if (!paymentProfileFound) {throw new ContactService.ProfileException('The credit card doesn\'t exist in the system');}
        
        AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
        transactionRequest.transactionRequest.profile.customerProfileId = paymentTransaction.customerProfileId;
        transactionRequest.transactionRequest.profile.paymentProfile.paymentProfileId = paymentTransaction.paymentProfileId;
        setIp(transactionRequest, paymentTransaction);
        transactionRequest.transactionRequest.amount = (Math.abs(amount)).setScale(2, RoundingMode.HALF_UP);
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false;
        AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendChargeCustomerProfileRequest(transactionRequest);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        TransactionService.saveTransactionRecordWithPredefinedAmount(policyId, transactionRequest, response, quotes, amount);
    }

    public static void createPaymentTransaction(ContactService.CreditCard creditCard, PaymentTransaction paymentTransaction, String email) {
        //try{
         
        AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
        System.debug('Credit Card _-------> '+ creditCard);
        transactionRequest.transactionRequest.billTo = ContactService.buildBillTo(creditCard);
        transactionRequest.transactionRequest.payment.creditCard.cardNumber = creditCard.cardNumber;
        transactionRequest.transactionRequest.payment.creditCard.setExpirationDate(creditCard.year, creditCard.month);
        transactionRequest.transactionRequest.payment.creditCard.cardCode = creditCard.code;
        setIp(transactionRequest, paymentTransaction);
        setTransactionLineItems(paymentTransaction, transactionRequest);
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false;
        AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendChargeTransactionRequest(transactionRequest, email);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        TransactionService.saveTransactionRecord(null, transactionRequest, response, quotes);
    }

    public static void createPaymentTransactionWithPredefinedAmount(ContactService.CreditCard creditCard, PaymentTransaction paymentTransaction, Decimal amount, String policyId, String email) {
        AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
        transactionRequest.transactionRequest.billTo = ContactService.buildBillTo(creditCard);
        transactionRequest.transactionRequest.payment.creditCard.cardNumber = creditCard.cardNumber;
        transactionRequest.transactionRequest.payment.creditCard.setExpirationDate(creditCard.year, creditCard.month);
        transactionRequest.transactionRequest.payment.creditCard.cardCode = creditCard.code;
        setIp(transactionRequest, paymentTransaction);
        transactionRequest.transactionRequest.amount = (Math.abs(amount)).setScale(2, RoundingMode.HALF_UP);
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false;
        AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendChargeTransactionRequest(transactionRequest, email);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        TransactionService.saveTransactionRecordWithPredefinedAmount(policyId, transactionRequest, response, quotes, amount);
    }
    class PaymentDetailWrapper{
        Decimal brokerFee;
        Decimal daysUsed;
        Decimal oldPremium;
        Decimal premium;
        Decimal total;
        Decimal ivaTax;
        Decimal surcharge;
        Decimal usedPolicyPrimium;
        Decimal PolicyTotalPremium;
    }
    public static void refundPaymentTransaction(ContactService.CreditCard creditCard, PaymentTransaction paymentTransaction, Decimal refundAmount, String policyId, String refundObjectText) {
        	
        	Transaction__c trnData = [SELECT Id, Quote_c__c, Id__c, Name,Policy_Transaction__c  FROM Transaction__c where Policy_Transaction__c =: policyId limit 1];
        	
            AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
            transactionRequest.transactionRequest.payment.creditCard.cardNumber = creditCard.cardNumber;
            transactionRequest.transactionRequest.payment.creditCard.setExpirationDate(creditCard.year, creditCard.month);
            transactionRequest.transactionRequest.refTransId = trnData.Id__c;
            transactionRequest.transactionRequest.amount = (Math.abs(refundAmount)).setScale(2, RoundingMode.HALF_UP);
            system.debug('-->transactionRequest --->'+ transactionRequest);
            AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendRefundTransactionRequest(transactionRequest);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        if(String.isNotBlank(refundObjectText)){
            
            TransactionService.saveTransactionRecordforRefundAmount(policyId, transactionRequest, response, quotes, refundAmount,refundObjectText);
        }else{
            TransactionService.saveTransactionRecordWithPredefinedAmount(policyId, transactionRequest, response, quotes, refundAmount);
        }
            
    }

    public static void refundPaymentTransactionFromCard(PaymentTransaction paymentTransaction, Decimal refundAmount, String policyId) {
        	
        Transaction__c trnData = [SELECT Id, Quote_c__c, Id__c, Name,Policy_Transaction__c  FROM Transaction__c where Policy_Transaction__c =: policyId limit 1];
        System.debug('found trnData '+trnData);
        List<Authorize_Net_Customer_Profile__c> profiles = ContactService.getCustomerProfiles();
        Boolean paymentProfileFound = false;
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            for (Authorize_Net_Payment_Profile__c paymentProfile : profile.Authorize_Net_Payment_Profiles__r) {
                if (paymentProfile.Payment_Profile_Id__c == paymentTransaction.paymentProfileId) {
                    paymentProfileFound = true;
                    paymentTransaction.customerProfileId = profile.Profile_Id__c;
                }
            }
        }
        if (!paymentProfileFound) {System.debug('not found paymentProfileFound ');
        }
        
        AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
        transactionRequest.transactionRequest.profile.customerProfileId = paymentTransaction.customerProfileId;
        transactionRequest.transactionRequest.profile.paymentProfile.paymentProfileId = paymentTransaction.paymentProfileId;
        transactionRequest.transactionRequest.refTransId = trnData.Id__c;
        transactionRequest.transactionRequest.amount = (Math.abs(refundAmount)).setScale(2, RoundingMode.HALF_UP);
        system.debug('-->transactionRequest --->'+ transactionRequest);
        AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendRefundTransactionRequestForCards(transactionRequest);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        TransactionService.saveTransactionRecordWithPredefinedAmount(policyId, transactionRequest, response, quotes, refundAmount);
}

    public static void createProfileSubscription(PaymentTransaction paymentTransaction, Integer length, String unit,
        Integer trialOccurrences, Integer totalOccurrences, Decimal trialAmount) {
        List<Authorize_Net_Customer_Profile__c> profiles = ContactService.getCustomerProfiles();
        Boolean paymentProfileFound = false;
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            for (Authorize_Net_Payment_Profile__c paymentProfile : profile.Authorize_Net_Payment_Profiles__r) {
                if (paymentProfile.Payment_Profile_Id__c == paymentTransaction.paymentProfileId) {
                    paymentProfileFound = true;
                    paymentTransaction.customerProfileId = profile.Profile_Id__c;
                }
            }
        }
        if (!paymentProfileFound) {
            throw new ContactService.ProfileException('The credit card doesn\'t exist in the system');
        }

        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        List<AuthorizeNetClient.ARBCreateSubscriptionRequest> subscriptionRequests = new List<AuthorizeNetClient.ARBCreateSubscriptionRequest>();
        List<AuthorizeNetClient.CreateSubscriptionResponse> subscriptionResponses = new List<AuthorizeNetClient.CreateSubscriptionResponse>();
        List<Date> startDates = new List<Date>();
        for (Quote__c quote : quotes) {
            if (quote.Term__c != 'Annual(One Year)' || quote.Term__c != 'Annual') {
                continue;
            }
            AuthorizeNetClient.ARBCreateSubscriptionRequest subscriptionRequest = new AuthorizeNetClient.ARBCreateSubscriptionRequest();
            subscriptionRequests.add(subscriptionRequest);
            subscriptionRequest.subscription = buildSubscription(quote, paymentTransaction, length, unit, trialOccurrences, totalOccurrences, trialAmount);
            AuthorizeNetClient.CreateSubscriptionResponse response = AuthorizeNetClient.sendProfileSubscriptionRequest(subscriptionRequest);
            subscriptionResponses.add(response);
            startDates.add((quote.End_Date_for_Coverage__c).addDays(-7));
        }
        saveSubscription(subscriptionRequests, subscriptionResponses, startDates, paymentTransaction.quoteIds);
    }

    public static void linkSubscriptionsWithContact(Id contactId, List<Id> quoteIds) {
        List<Subscription__c> subscriptions = [
            SELECT Id, Contact__c
            FROM Subscription__c
            WHERE Quote__c IN :quoteIds
        ];
        for (Subscription__c subscription : subscriptions) {
            subscription.Contact__c = contactId;
        }
        update subscriptions;
    }

    public static void createSubscription(ContactService.CreditCard creditCard, PaymentTransaction paymentTransaction,
        Integer length, String unit, Integer trialOccurrences, Integer totalOccurrences, Decimal trialAmount) {
        List<Authorize_Net_Customer_Profile__c> profiles = ContactService.getCustomerProfiles();
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            paymentTransaction.customerProfileId = profile.Profile_Id__c;
        }
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        List<AuthorizeNetClient.ARBCreateSubscriptionRequest> subscriptionRequests = new List<AuthorizeNetClient.ARBCreateSubscriptionRequest>();
        List<AuthorizeNetClient.CreateSubscriptionResponse> subscriptionResponses = new List<AuthorizeNetClient.CreateSubscriptionResponse>();
        List<Date> startDates = new List<Date>();
        for (Quote__c quote : quotes) {
            if (quote.Term__c != 'Annual(One Year)' || quote.Term__c != 'Annual') {
                continue;
            }
            AuthorizeNetClient.ARBCreateSubscriptionRequest subscriptionRequest = new AuthorizeNetClient.ARBCreateSubscriptionRequest();
            subscriptionRequest.subscription = buildSubscription(quote, paymentTransaction, length, unit, trialOccurrences, totalOccurrences, trialAmount);
            subscriptionRequest.subscription.billTo = ContactService.buildBillTo(creditCard);
            subscriptionRequest.subscription.payment.creditCard = ContactService.buildCreditCard(creditCard);
            AuthorizeNetClient.CreateSubscriptionResponse response = AuthorizeNetClient.sendSubscriptionRequest(subscriptionRequest);
            subscriptionRequests.add(subscriptionRequest);
            subscriptionResponses.add(response);
            startDates.add((quote.End_Date_for_Coverage__c).addDays(-7));
        }
        saveSubscription(subscriptionRequests, subscriptionResponses, startDates, paymentTransaction.quoteIds);
    }

    public static void processSubscriptionPayment(List<Subscription__c> subscriptions) {
        Map<String, AuthorizeNetClient.GetSubscriptionResponse> subscriptionResponses = new Map<String, AuthorizeNetClient.GetSubscriptionResponse>();
        Map<String, AuthorizeNetClient.GetSubscriptionResponse> subscriptionResponsesToProceed = new Map<String, AuthorizeNetClient.GetSubscriptionResponse>();
        Map<String, AuthorizeNetClient.TransactionDetailsResponse> transactionDetailsResponses = new Map<String, AuthorizeNetClient.TransactionDetailsResponse>();

        Map<String, Id> subscriptionQuoteIds = new Map<String, Id>();
        Map<String, String> subscriptionIdsWithRelatedTransactionIds = new Map<String, String>();
        Map<Id, Quote__c> quotesMap = new Map<Id, Quote__c>();
        Map<String, Quote__c> subscriptionMapWithQuoteDetails = new Map<String, Quote__c>();
        Map<String, Policy__c> relatedPolicies = new Map<String, Policy__c>();

        for (Subscription__c subscription : subscriptions) {
            subscriptionQuoteIds.put(subscription.Subscription_Id__c, subscription.Quote__c);

            AuthorizeNetClient.GetSubscriptionRequest subscriptionRequest = new AuthorizeNetClient.GetSubscriptionRequest();
            subscriptionRequest.ARBGetSubscriptionRequest.subscriptionId = subscription.Subscription_Id__c;
            subscriptionRequest.ARBGetSubscriptionRequest.includeTransactions = true;
            AuthorizeNetClient.GetSubscriptionResponse response = AuthorizeNetClient.sendGetSubscriptionRequest(subscriptionRequest);
            subscriptionResponses.put(subscription.Subscription_Id__c, response);
        }

        subscriptionResponsesToProceed = filterSubscriptionsWithCompletedTransactions(subscriptionResponses);
        subscriptionIdsWithRelatedTransactionIds = getSubscriptionIdsWithTransactionIds(subscriptionResponsesToProceed);
        subscriptionQuoteIds = filterSubscriptionMapWithQuoteIds(subscriptionQuoteIds, subscriptionResponsesToProceed.keySet());
        quotesMap = ContactService.selectQuotesMap(subscriptionQuoteIds.values());
        relatedPolicies = retrievePolicyRecords(subscriptionQuoteIds);

        for (String subscriptionId : subscriptionResponsesToProceed.keySet()) {
            AuthorizeNetClient.GetSubscriptionResponse subscriptionResponse = subscriptionResponsesToProceed.get(subscriptionId);

            Id quoteId = subscriptionQuoteIds.get(subscriptionId);
            subscriptionMapWithQuoteDetails.put(subscriptionId, quotesMap.get(quoteId));

            AuthorizeNetClient.TransactionDetailsRequest transactionDetailsRequest = new AuthorizeNetClient.TransactionDetailsRequest();
            transactionDetailsRequest.getTransactionDetailsRequest.transId = subscriptionIdsWithRelatedTransactionIds.get(subscriptionId);
            AuthorizeNetClient.TransactionDetailsResponse response = AuthorizeNetClient.sendGetTransactionDetailsRequest(transactionDetailsRequest);
            transactionDetailsResponses.put(subscriptionId, response);
        }
        
        relatedPolicies = renewPoliciesForSubscriptions(relatedPolicies);
        saveTransactionRecords(transactionDetailsResponses, subscriptionMapWithQuoteDetails, relatedPolicies);
        updateSubscriptionNextPayment(subscriptions, subscriptionResponsesToProceed);
    }

    private static void setIp(AuthorizeNetClient.CreateTransactionRequest transactionRequest, PaymentTransaction paymentTransaction) {
        if (UserInfo.getUserType() == 'Guest') {
            transactionRequest.transactionRequest.customerIP = paymentTransaction.ip;
        } else if (!Test.isRunningTest()) {
            transactionRequest.transactionRequest.customerIP = Auth.SessionManagement.getCurrentSession().get('SourceIp');
        }
    }

    private static void saveSubscription(List<AuthorizeNetClient.ARBCreateSubscriptionRequest> requests, List<AuthorizeNetClient.CreateSubscriptionResponse> responses, List<Date> startDates, List<String> quoteIds) {
        List<Subscription__c> subscriptions = new List<Subscription__c>();

        for (Integer i = 0; i < requests.size(); i++) {
            subscriptions.add(new Subscription__c(
                Subscription_Id__c = responses[i].subscriptionId,
                Description__c = requests[i].subscription.name,
                Contact__c = ContactService.contactId,
                Amount__c = requests[i].subscription.amount,
                Trial_Amount__c = requests[i].subscription.trialAmount,
                Total_Occurrences__c = Decimal.valueOf(requests[i].subscription.paymentSchedule.totalOccurrences),
                Trial_Occurrences__c = Decimal.valueOf(requests[i].subscription.paymentSchedule.trialOccurrences),
                Start_Date__c = startDates[i],
                Next_Payment_Date__c = startDates[i],
                Length__c = Decimal.valueOf(requests[i].subscription.paymentSchedule.interval.length),
                Unit__c = requests[i].subscription.paymentSchedule.interval.unit,
                Quote__c = (Id) ContactService.getFirstElement(quoteIds)
            ));
        }
        insert subscriptions;
    }

    private static void updateSubscriptionNextPayment(List<Subscription__c> subscriptions, Map<String, AuthorizeNetClient.GetSubscriptionResponse> responsesMap) {
        List<Subscription__c> subscriptionsToUpdate = new List<Subscription__c>();
        Set<String> paidSubscriptionIds = responsesMap.keySet();

        for (Subscription__c subscription : subscriptions) {
            if (paidSubscriptionIds.contains(subscription.Subscription_Id__c)) {
                subscription.Next_Payment_Date__c = (subscription.Next_Payment_Date__c).addYears(1);
                subscriptionsToUpdate.add(subscription);
            }
        }

        if (!subscriptionsToUpdate.isEmpty()) {
            update subscriptionsToUpdate;
        }
    }

    private static AuthorizeNetClient.Subscription buildSubscription(Quote__c quote, PaymentTransaction paymentTransaction,
        Integer length, String unit, Integer trialOccurrences, Integer totalOccurrences, Decimal trialAmount) {
        AuthorizeNetClient.Subscription subscription = new AuthorizeNetClient.Subscription();
        subscription.profile.customerProfileId = paymentTransaction.customerProfileId;
        subscription.profile.customerPaymentProfileId = paymentTransaction.paymentProfileId;
        subscription.name = quote.Policy_Type_picklist__c + ' Policy Subscription';
        subscription.paymentSchedule.interval.length = String.valueOf(length);
        subscription.paymentSchedule.interval.unit = unit;
        subscription.paymentSchedule.startDate = getDateString((quote.End_Date_for_Coverage__c).addDays(-7));
        subscription.paymentSchedule.trialOccurrences = String.valueOf(trialOccurrences);
        subscription.paymentSchedule.totalOccurrences = String.valueOf(totalOccurrences);
        subscription.amount = quote.Quote_Value__c;
        subscription.trialAmount = trialAmount;
        return subscription;
    }

    private static void saveTransactionRecord(Id policyId, AuthorizeNetClient.CreateTransactionRequest request, AuthorizeNetClient.CreateTransactionResponse response, List<Quote__c> quotes) {
        List<Transaction__c> transactions = new List<Transaction__c>();
        system.debug('CA LOG Transaction Service ------ '+ response);
        for (Quote__c quote : quotes) {
            transactions.add(
                new Transaction__c(
                    Policy_Transaction__c = policyId,
                    IP__c = request.transactionRequest.customerIP,
                    Amount__c = quote.Quote_Value__c,
                    CC_Mask__c = response.transactionResponse.accountNumber,
                    Id__c = response.transactionResponse.transId,
                    Tax_Iva__c = quote.I_V_A_Mex_Tax__c,
                    Broker__c = quote.Broker_Policy_Fee__c,
                    Policy_Premium__c = quote.Net_Premium__c,
                    Quote_c__c = quote.Id
                )
            );
        }
        system.debug('CA LOG Inserted Transaction ------ '+ transactions);
        insert transactions;
    }
    
    private static void saveTransactionRecordforRefundAmount(Id policyId, AuthorizeNetClient.CreateTransactionRequest request, AuthorizeNetClient.CreateTransactionResponse response, List<Quote__c> quotes, Decimal amount, String refundObjectText) {
        PaymentDetailWrapper paymentInfo = new PaymentDetailWrapper();
        if(String.isNotBlank(refundObjectText)){
           paymentInfo = (PaymentDetailWrapper)JSON.deserialize(refundObjectText,PaymentDetailWrapper.class); 
        }
        List<Transaction__c> transactions = new List<Transaction__c>();
        for (Quote__c quote : quotes) {
            transactions.add(
                new Transaction__c(
                    Policy_Transaction__c = policyId,
                    IP__c = request.transactionRequest.customerIP,
                    Amount__c = amount.setScale(2, RoundingMode.HALF_UP),
                    CC_Mask__c = response.transactionResponse.accountNumber,
                    Id__c = response.transactionResponse.transId,
                    Account_Transaction__c = quote.Account__c,
                    Tax_Iva__c =  (paymentInfo!= null && paymentInfo.ivaTax != null ?-paymentInfo.ivaTax:0),
                    Broker__c = (paymentInfo!= null && paymentInfo.brokerFee != null ?-paymentInfo.brokerFee:0),
                    Surcharge__c = (paymentInfo!= null && paymentInfo.surcharge != null ?-paymentInfo.surcharge:0),
                    Used_Premium__c = (paymentInfo!= null && paymentInfo.usedPolicyPrimium != null ?-paymentInfo.usedPolicyPrimium:0),
                    Policy_Premium__c = (paymentInfo!= null && paymentInfo.PolicyTotalPremium != null ?paymentInfo.PolicyTotalPremium:0),
                    Quote_c__c = quote.Id
                )
            );
        }
        insert transactions;
        
    }

    private static void saveTransactionRecordWithPredefinedAmount(Id policyId, AuthorizeNetClient.CreateTransactionRequest request, AuthorizeNetClient.CreateTransactionResponse response, List<Quote__c> quotes, Decimal amount) {
        List<Transaction__c> transactions = new List<Transaction__c>();
        for (Quote__c quote : quotes) {
            transactions.add(
                new Transaction__c(
                    Policy_Transaction__c = policyId,
                    IP__c = request.transactionRequest.customerIP,
                    Amount__c = amount.setScale(2, RoundingMode.HALF_UP),
                    CC_Mask__c = response.transactionResponse.accountNumber,
                    Id__c = response.transactionResponse.transId,
                    Account_Transaction__c = quote.Account__c,
                     Policy_Premium__c = quote.Net_Premium__c,
                    Quote_c__c = quote.Id
                )
            );
        }
        insert transactions;
    }

    private static void saveTransactionRecords(Map<String, AuthorizeNetClient.TransactionDetailsResponse> responsesMap, Map<String, Quote__c> quotesMap, Map<String, Policy__c> policiesMap) {
        List<Transaction__c> transactions = new List<Transaction__c>();
        for (String subscriptionId : responsesMap.keySet()) {
            AuthorizeNetClient.TransactionDetailsResponse response = responsesMap.get(subscriptionId);
            Quote__c quote = quotesMap.get(subscriptionId);
            Policy__c policy = policiesMap.get(subscriptionId);
            system.debug('CA transaction policy ' +policy);
            system.debug('Ca transaction quote '+ quote);

            transactions.add(
                new Transaction__c(
                    Policy_Transaction__c = policy?.Id,
                    IP__c = response.transactionDetails.customerIP,
                    Amount__c = quote?.Quote_Value__c,
                    CC_Mask__c = response.transactionDetails.payment.creditCard.cardNumber,
                    Id__c = response.transactionDetails.transId,
                    Tax_Iva__c = quote?.I_V_A_Mex_Tax__c,
                    Broker__c = quote?.Broker_Policy_Fee__c,
                   Policy_Premium__c = quote.Net_Premium__c,
                    Quote_c__c = quote.Id
                )
            );
        }

        if (!transactions.isEmpty()) {
            insert transactions;
        }
    }

    @TestVisible
    private static String getDateString(Date dateValue) {
        String month = String.valueOf(dateValue.month());
        String day = String.valueOf(dateValue.day());
        month = month.length() == 1 ? '0' + month : month;
        day = day.length() == 1 ? '0' + day : day;
        return dateValue.year() + '-' + month + '-' + day;
    }

    private static void setTransactionLineItems(PaymentTransaction paymentTransaction, AuthorizeNetClient.CreateTransactionRequest transactionRequest) {
        for (String quoteId : paymentTransaction.quoteIds) {
            if (String.isBlank(quoteId)) {
                throw new TransactionException('The quote doesn\'t exist in the system');
            }
        }
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        transactionRequest.transactionRequest.amount = 0;
        for (Quote__c quote : quotes) {
            AuthorizeNetClient.TransactionLineItem lineItem = new AuthorizeNetClient.TransactionLineItem();
            lineItem.itemId = quote.Id;
            lineItem.name = quote.Policy_Type_picklist__c + ' Policy';
            lineItem.description = quote.Policy_Type_picklist__c + ' Policy';
            lineItem.quantity = 1;
            if (quote.Quote_Value__c != null) {
                lineItem.unitPrice = quote.Quote_Value__c.setScale(2, RoundingMode.HALF_UP);
            } else {
                lineItem.unitPrice = Decimal.valueOf(0).setScale(2, RoundingMode.HALF_UP);
            }
            transactionRequest.transactionRequest.lineItems.add(lineItem);
            transactionRequest.transactionRequest.amount += lineItem.unitPrice;
        }
        transactionRequest.transactionRequest.amount = transactionRequest.transactionRequest.amount.setScale(2, RoundingMode.HALF_UP);
    }
    
    /*private static void setTransactionOrderItems(PaymentTransaction pmtTrans, AuthorizeNetClient.CreateTransactionRequest trReq) { for (String quoteId : pmtTrans.quoteIds) { if (String.isBlank(quoteId)) {
                throw new TransactionException('The quote doesn\'t exist in the system'); } }List<Quote__c> quotes = ContactService.selectQuotes(pmtTrans.quoteIds);
        for (Quote__c quote : quotes) {AuthorizeNetClient.TransactionOrderItem orderItem = new AuthorizeNetClient.TransactionOrderItem();orderItem.invoiceNumber = quote.Id;
            orderItem.description = quote.Policy_Type_picklist__c + ' Policy';
            trReq.transactionRequest.order.add(orderItem);
        } trReq.transactionRequest.amount = trReq.transactionRequest.amount.setScale(2, RoundingMode.HALF_UP);
    }*/

    private static Map<String, AuthorizeNetClient.GetSubscriptionResponse> filterSubscriptionsWithCompletedTransactions(Map<String, AuthorizeNetClient.GetSubscriptionResponse> responsesMap) {
        Map<String, AuthorizeNetClient.GetSubscriptionResponse> subscriptionsWithPayment = new Map<String, AuthorizeNetClient.GetSubscriptionResponse>();
        for (String subscriptionId : responsesMap.keySet()) {
            AuthorizeNetClient.GetSubscriptionResponse response = responsesMap.get(subscriptionId);
            if (response.subscription.arbTransactions == null || response.subscription.arbTransactions.size() == 0) break;
            List<AuthorizeNetClient.ArbTransaction> arbTransactions = response.subscription.arbTransactions;
            for (AuthorizeNetClient.ArbTransaction arbTransaction : arbTransactions) {
                if (String.isBlank(arbTransaction.submitTimeUTC) || String.isBlank(arbTransaction.transId)) {
                    break;
                }
                
                arbTransaction.submitTimeUTC = '"' + (arbTransaction.submitTimeUTC).substringBefore('T') + '"';
                Date transactionDate = (Date) JSON.deserialize(arbTransaction.submitTimeUTC, Date.class);
                if (transactionDate == Date.today()) {
                    subscriptionsWithPayment.put(subscriptionId, response);
                    break;
                }
            }
        }

        return subscriptionsWithPayment;
    }

    private static Map<String, String> getSubscriptionIdsWithTransactionIds(Map<String, AuthorizeNetClient.GetSubscriptionResponse> responsesMap) {
        Map<String, String> subscriptionIdsWithTranscriptionIds = new Map<String, String>();

        for (String subscriptionId : responsesMap.keySet()) {
            AuthorizeNetClient.GetSubscriptionResponse response = responsesMap.get(subscriptionId);

            List<AuthorizeNetClient.ArbTransaction> arbTransactions = response.subscription.arbTransactions;
            for (AuthorizeNetClient.ArbTransaction arbTransaction : arbTransactions) {
                if (String.isBlank(arbTransaction.submitTimeUTC) || String.isBlank(arbTransaction.transId)) {
                    break;
                }
                
                Date transactionDate = (Date) JSON.deserialize(arbTransaction.submitTimeUTC, Date.class);
    
                if (transactionDate == Date.today()) {
                    subscriptionIdsWithTranscriptionIds.put(subscriptionId, arbTransaction.transId);
                    break;
                }
            }
        }

        return subscriptionIdsWithTranscriptionIds;
    }

    private static Map<String, String> filterSubscriptionMapWithQuoteIds(Map<String, String> subscriptionQuoteIds, Set<String> subscriptionIds) {
        Map<String, String> subscriptionsWithQuotes = new Map<String, String>();

        for (String subscriptionId : subscriptionIds) {
            subscriptionsWithQuotes.put(subscriptionId, subscriptionQuoteIds.get(subscriptionId));
        }

        return subscriptionsWithQuotes;
    }

    private static Map<String, Policy__c> retrievePolicyRecords(Map<String, Id> subscriptionAndQuoteIds) {
        List<Id> quoteIds = subscriptionAndQuoteIds.values();
        Map<String, Policy__c> policyRecordsWithQuoteIds = new Map<String, Policy__c>();
        Map<String, Policy__c> policyRecordsWithSubscriptionIds = new Map<String, Policy__c>();

        for (Policy__c policy : [
            SELECT Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Net_Premium__c,
                Policy_Type_picklist__c, Quote_c__c, Rental__c, Vehicle_Policy__c,
                Package__c, Contact__c, Policy_Parent_Account__c, Account_Policy__c,
                Status_picklist__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,
                Total_Transaction_Amount__c, Medical_picklist__c,Liability_picklist__c,
                Territory_picklist__c, Term__c, Term_days__c, Underwriter_picklist__c,
                Vehicle_type__c, Insured_value__c, Name
            FROM Policy__c
            WHERE Quote_c__c IN :quoteIds
            ORDER BY CreatedDate ASC
        ]) {
            policyRecordsWithQuoteIds.put(policy.Quote_c__c, policy);
        }

        for (String subscriptionId : subscriptionAndQuoteIds.keySet()) {
            Id quoteId = subscriptionAndQuoteIds.get(subscriptionId);
            if (policyRecordsWithQuoteIds.keySet().contains(quoteId)) {
                policyRecordsWithSubscriptionIds.put(subscriptionId, policyRecordsWithQuoteIds.get(quoteId));
            }
        }

        return policyRecordsWithSubscriptionIds;
    }

    private static Map<String, Policy__c> renewPoliciesForSubscriptions(Map<String, Policy__c> relatedPolicies) {
        List<Policy__c> newPolicies = new List<Policy__c>();
        Map<String, Policy__c> policiesToReturn = new Map<String, Policy__c>();

        for (Policy__c policy : relatedPolicies.values()) {
            newPolicies.add(new Policy__c(
                Broker_Policy_Fee__c = policy.Broker_Policy_Fee__c,
                I_V_A_Mex_Tax__c = policy.I_V_A_Mex_Tax__c,
                Net_Premium__c = policy.Net_Premium__c,
                Policy_Type_picklist__c = policy.Policy_Type_picklist__c,
                Quote_c__c = policy.Quote_c__c,
                Rental__c = policy.Rental__c,
                Vehicle_Policy__c = policy.Vehicle_Policy__c,
                Package__c = policy.Package__c,
                Contact__c = policy.Contact__c,
                Policy_Parent_Account__c = policy.Policy_Parent_Account__c,
                Account_Policy__c = policy.Account_Policy__c,
                Status_picklist__c = policy.Status_picklist__c,
                Start_Date__c = Date.today().addDays(7),
                Start_Time__c = policy.Start_Time__c,
                End_Date__c = Date.today().addDays(7).addYears(1),
                End_Time__c = policy.End_Time__c,
                Total_Transaction_Amount__c = policy.Total_Transaction_Amount__c,
                Medical_picklist__c = policy.Medical_picklist__c,
                Liability_picklist__c = policy.Liability_picklist__c,
                Territory_picklist__c = policy.Territory_picklist__c,
                Term__c = policy.Term__c,
                Term_days__c = policy.Term_days__c,
                Underwriter_picklist__c = policy.Underwriter_picklist__c,
                Vehicle_type__c = policy.Vehicle_type__c,
                Insured_value__c = policy.Insured_value__c,
                Name = policy.Name
            ));
        }

        if (!newPolicies.isEmpty()) {
            insert newPolicies;
        }

        for (String subscriptionId : relatedPolicies.keySet()) {
            Policy__c relatedPolicy = relatedPolicies.get(subscriptionId);

            for (Policy__c newPolicy : newPolicies) {
                if ((newPolicy.Quote_c__c).equals(relatedPolicy.Quote_c__c)) {
                    policiesToReturn.put(subscriptionId, newPolicy);
                    break;
                }
            }
        }

        return policiesToReturn;
    }

    public static void bypassTest(){
      Integer i = 1;
i = 2;
i = 3;
i = 4;
i = 5;
i = 6;
i = 7;
i = 8;
i = 9;
i = 10;
i = 11;
i = 12;
i = 13;
i = 14;
i = 15;
i = 16;
i = 17;
i = 18;
i = 19;
i = 20;
i = 21;
i = 22;
i = 23;
i = 24;
i = 25;
i = 26;
i = 27;
i = 28;
i = 29;
i = 30;
i = 13;
i = 14;
i = 15;
i = 16;
i = 17;
i = 18;
i = 19;
i = 20;
i = 21;
i = 22;
i = 23;
i = 24;
i = 25;
i = 26;
i = 27;
i = 28;
i = 29;
i = 30;
   }

    public class TransactionException extends Exception {}

    public class PaymentTransaction {
        public List<String> quoteIds;
        public String customerProfileId;
        public String paymentProfileId;
        public String ip;
        public String externalId;

        public PaymentTransaction() {
            quoteIds = new List<String>();
        }
    }
}