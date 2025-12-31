public without sharing class PolicyAutoRenewCardHandler {
    
    public static map<string, object> createPaymentProfileTransaction(String transactionDetails , String contactId) {
        map<string, object> responseMap = new map<string, object>();
        try {
            Map<String, Object> getResult = getCardProfileIds(transactionDetails,contactId);
            responseMap.put('transcationDetails',getResult);
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
            if( exceptionStr != ''){//throw new AuraHandledException(exceptionStr);
                responseMap.put('status', 'error');
            responseMap.put('status', exceptionStr);
            }else{
                //throw new AuraHandledException(ex.getMessage());
                responseMap.put('status', 'error');
            responseMap.put('status', ex.getMessage());
            }
        }
        system.debug('--responseMap---'+ responseMap);
        return responseMap;
    }
    
    public static Map<String, Object> getCardProfileIds(String paymentTransactionJSON,  String contactId){
        
       List<Authorize_Net_Customer_Profile__c> profilesLists = [SELECT Id, Profile_Id__c,(SELECT Id, Payment_Profile_Id__c FROM Authorize_Net_Payment_Profiles__r) 
                                                             FROM Authorize_Net_Customer_Profile__c WHERE Contact__c = :contactId];
        
        System.debug('profilesLists ->'+profilesLists);
        PaymentTransaction paymentTransaction = (PaymentTransaction)JSON.deserialize(paymentTransactionJSON, PaymentTransaction.class);
        System.debug('paymentTransaction ->'+paymentTransaction);
        List<Authorize_Net_Customer_Profile__c> profiles = profilesLists;
        Boolean paymentProfileFound = false;
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            for (Authorize_Net_Payment_Profile__c paymentProfile : profile.Authorize_Net_Payment_Profiles__r) {
                System.debug('paymentProfile.Payment_Profile_Id__c ->'+paymentProfile.Payment_Profile_Id__c);
                System.debug('paymentTransaction.paymentProfileId ->'+paymentTransaction.paymentProfileId);
                if (paymentProfile.Payment_Profile_Id__c == paymentTransaction.paymentProfileId) {
                    paymentProfileFound = true;
                    paymentTransaction.customerProfileId = profile.Profile_Id__c;
                }
            }
        }
        if (!paymentProfileFound) {
            throw new ContactService.ProfileException('The credit card doesn\'t exist in the system');
        }

        AuthorizeNetClient.CreateTransactionRequest transactionRequest = new AuthorizeNetClient.CreateTransactionRequest();
        transactionRequest.transactionRequest.profile.customerProfileId = paymentTransaction.customerProfileId;
        transactionRequest.transactionRequest.profile.paymentProfile.paymentProfileId = paymentTransaction.paymentProfileId;
        setIp(transactionRequest, paymentTransaction);
        setTransactionLineItems(paymentTransaction, transactionRequest);
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false;
        system.debug('transactionRequest------------24-----> '+ transactionRequest);
        AuthorizeNetClient.CreateTransactionResponse response = AuthorizeNetClient.sendChargeCustomerProfileRequest(transactionRequest);
        system.debug('response------------27-----> '+ response);
        List<Quote__c> quotes = ContactService.selectQuotes(paymentTransaction.quoteIds);
        
        system.debug('quotes------------28-----> '+ quotes);
        //saveTransactionRecord(null, transactionRequest, response, quotes);
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('policyVsRequest', transactionRequest);
        result.put('policyVsResponse', response);
        
        return result;
        
    }
    
      public static void saveTransactionRecord(Map<Id, Quote__c> policyIdVsQuote, Map<String,AuthorizeNetClient.CreateTransactionRequest> CreateTransactionRequest, Map<String,AuthorizeNetClient.CreateTransactionResponse> CreateTransactionResponse, Map<String,object> policyIdsVsTransaction) {
        List<Transaction__c> transactions = new List<Transaction__c>();
        system.debug('CA LOG Transaction Service ------ '+ CreateTransactionResponse);
          
          for (Id policy : policyIdVsQuote.keyset()) {
              Quote__c quoteRecord = policyIdVsQuote.get(policy);
              string newQuoteID = quoteRecord.Id;
              
              AuthorizeNetClient.CreateTransactionRequest request = (AuthorizeNetClient.CreateTransactionRequest)CreateTransactionRequest.get(policy);
              AuthorizeNetClient.CreateTransactionResponse response = (AuthorizeNetClient.CreateTransactionResponse)CreateTransactionResponse.get(policy);
              
              transactions.add(
                new Transaction__c(
                    Policy_Transaction__c = policy,
                    IP__c = request.transactionRequest.customerIP,
                    Amount__c = quoteRecord.Quote_Value__c,
                    CC_Mask__c = response.transactionResponse.accountNumber,
                    Id__c = response.transactionResponse.transId,
                    Tax_Iva__c = quoteRecord.I_V_A_Mex_Tax__c,
                    Broker__c = quoteRecord.Broker_Policy_Fee__c,
                    Policy_Premium__c = quoteRecord.Net_Premium__c,
                    Quote_c__c = newQuoteID
                )
            );
        }
        system.debug('CA LOG Inserted Transaction ------ '+ transactions);
          if(transactions.size() > 0){
              Database.insert(transactions,false);
          }
          
          if(policyIdVsQuote.size() > 0){
            Database.executeBatch(new PolicyRenewBatch(policyIdVsQuote,policyIdsVsTransaction), 4);
        }
        
    }
    
    private static void setIp(AuthorizeNetClient.CreateTransactionRequest transactionRequest, PaymentTransaction paymentTransaction) {
       transactionRequest.transactionRequest.customerIP = paymentTransaction.ip;
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
    
    public class TransactionException extends Exception {}
    
    
}