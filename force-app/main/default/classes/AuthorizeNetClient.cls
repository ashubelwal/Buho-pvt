public with sharing class AuthorizeNetClient {

    private static final Boolean isSandbox;

    static {
        isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static CustomerProfileResponse sendCreateCustomerProfileRequest(CreateCustomerProfileRequest customerProfileRequest) {
        HttpRequest request = buildRequest();
         customerProfileRequest.validationMode = isSandbox ? 'testMode' : 'liveMode';
         // customerProfileRequest.validationMode =  'liveMode';
        customerProfileRequest.merchantAuthentication = buildAuthenticationObject();
        request.setBody(buildCreateCustomerProfileRequestBody(customerProfileRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
        CustomerProfileResponse customerProfileResponse = (CustomerProfileResponse) JSON.deserialize(removeBom(response.getBody()), CustomerProfileResponse.class);
        validateResponse(customerProfileResponse.messages);
        return customerProfileResponse;
    }
    
    public static void testMethodForCallClass(){
         buildAuthenticationObject();
    }

    public static CustomerPaymentProfileResponse sendCreatePaymentProfileRequest(CreateCustomerPaymentProfileRequest customerPaymentProfileRequest) {
        HttpRequest request = buildRequest();
        customerPaymentProfileRequest.validationMode = isSandbox ? 'testMode' : 'liveMode';
        customerPaymentProfileRequest.merchantAuthentication = buildAuthenticationObject();
        request.setBody(buildCreateCustomerPaymentProfileRequestBody(customerPaymentProfileRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
        CustomerPaymentProfileResponse customerPaymentProfileResponse = (CustomerPaymentProfileResponse) JSON.deserialize(removeBom(response.getBody()), CustomerPaymentProfileResponse.class);
        validateResponse(customerPaymentProfileResponse.messages);
        return customerPaymentProfileResponse;
    }

    public static GetProfileResponse sendGetCustomerProfileRequest(String profileId) {
        HttpRequest request = buildRequest();
        GetCustomerProfileRequest customerProfileRequest = new GetCustomerProfileRequest();
        customerProfileRequest.merchantAuthentication = buildAuthenticationObject();
        customerProfileRequest.customerProfileId = profileId;
        customerProfileRequest.includeIssuerInfo = false;
        request.setBody(buildGetCustomerProfileBody(customerProfileRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
        GetProfileResponse getProfileResponse = (GetProfileResponse) JSON.deserialize(removeBom(response.getBody()), GetProfileResponse.class);
        validateResponse(getProfileResponse.messages);
        return getProfileResponse;
    }

    public static CreateTransactionResponse sendChargeCustomerProfileRequest(CreateTransactionRequest transactionRequest) {
        HttpRequest request = buildRequest();
        transactionRequest.merchantAuthentication = buildAuthenticationObject();
        transactionRequest.refId = String.valueOf(Crypto.getRandomLong());
        transactionRequest.transactionRequest.transactionType = 'authCaptureTransaction';
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false;
        transactionRequest.transactionRequest.authorizationIndicatorType.authorizationIndicator = 'final';//probably change to the user input needed
        request.setBody(buildChargeCustomerProfileRequest(transactionRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
        CreateTransactionResponse createTransactionResponse = (CreateTransactionResponse) JSON.deserialize(removeBom(response.getBody()), CreateTransactionResponse.class);
        validateTransactionResponse(createTransactionResponse);
        return createTransactionResponse;
    }

    public static CreateTransactionResponse sendChargeTransactionRequest(CreateTransactionRequest transactionRequest, String email) {
        HttpRequest request;
        if (String.isNotBlank(email)) {
            request = buildRequest(email);
        } else {
            request = buildRequest();
        }
        
        transactionRequest.merchantAuthentication = buildAuthenticationObject();
        transactionRequest.refId = String.valueOf(Crypto.getRandomLong());
        transactionRequest.transactionRequest.transactionType = 'authCaptureTransaction';
        transactionRequest.transactionRequest.processingOptions.isSubsequentAuth = false;
        transactionRequest.transactionRequest.authorizationIndicatorType.authorizationIndicator = 'final';//probably change to the user input needed
        request.setBody(buildChargeCreditCardRequest(transactionRequest));
        System.debug ('reqBody : ' + request.getBody());
        Http httph = new Http();
        HttpResponse response = httph.send(request);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
       
        CreateTransactionResponse createTransactionResponse = (CreateTransactionResponse) JSON.deserialize(removeBom(response.getBody()), CreateTransactionResponse.class);
        validateTransactionResponse(createTransactionResponse);
        return createTransactionResponse;
    }

    public static CreateTransactionResponse sendRefundTransactionRequest(CreateTransactionRequest transactionRequest) {
        HttpRequest request = buildRequest();
        transactionRequest.merchantAuthentication = buildAuthenticationObject();
        transactionRequest.refId = String.valueOf(Crypto.getRandomLong());
        transactionRequest.transactionRequest.transactionType = 'refundTransaction';
        request.setBody(buildRefundTransactionRequest(transactionRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response~~~ : ' + response);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
        CreateTransactionResponse createTransactionResponse = (CreateTransactionResponse) JSON.deserialize(removeBom(response.getBody()), CreateTransactionResponse.class);
        validateTransactionResponse(createTransactionResponse);
        return createTransactionResponse;
    }

    public static CreateTransactionResponse sendRefundTransactionRequestForCards(CreateTransactionRequest transactionRequest) {
        HttpRequest request = buildRequest();
        transactionRequest.merchantAuthentication = buildAuthenticationObject();
        transactionRequest.refId = String.valueOf(Crypto.getRandomLong());
        transactionRequest.transactionRequest.transactionType = 'refundTransaction';
        System.debug(buildRefundTransactionRequestForSavedCard(transactionRequest));
        request.setBody(buildRefundTransactionRequestForSavedCard(transactionRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response~~~ : ' + response);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
        CreateTransactionResponse createTransactionResponse = (CreateTransactionResponse) JSON.deserialize(removeBom(response.getBody()), CreateTransactionResponse.class);
        validateTransactionResponse(createTransactionResponse);
        return createTransactionResponse;
    }

    public static CreateSubscriptionResponse sendProfileSubscriptionRequest(ARBCreateSubscriptionRequest subscriptionRequest) {
        HttpRequest request = buildRequest();
        subscriptionRequest.merchantAuthentication = buildAuthenticationObject();
        subscriptionRequest.refId = String.valueOf(Crypto.getRandomLong());
        request.setBody(buildProfileSubscriptionRequest(subscriptionRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        CreateSubscriptionResponse createSubscriptionResponse = (CreateSubscriptionResponse) JSON.deserialize(removeBom(response.getBody()), CreateSubscriptionResponse.class);
        validateResponse(createSubscriptionResponse.messages);
        return createSubscriptionResponse;
    }

    public static CreateSubscriptionResponse sendSubscriptionRequest(ARBCreateSubscriptionRequest subscriptionRequest) {
        HttpRequest request = buildRequest();
        subscriptionRequest.merchantAuthentication = buildAuthenticationObject();
        subscriptionRequest.refId = String.valueOf(Crypto.getRandomLong());
        request.setBody(buildSubscriptionRequest(subscriptionRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('-response--'+response);
        System.debug('-body--'+response.getBody());
        CreateSubscriptionResponse createSubscriptionResponse = (CreateSubscriptionResponse) JSON.deserialize(removeBom(response.getBody()), CreateSubscriptionResponse.class);
        validateResponse(createSubscriptionResponse.messages);
        return createSubscriptionResponse;
    }

    public static GetSubscriptionResponse sendGetSubscriptionRequest(GetSubscriptionRequest getSubscriptionRequest) {
        HttpRequest request = buildRequest();
        if (Test.isRunningTest()) {
            request.setHeader('Callout-Type', AuthorizeNetMockGenerator.Callout.GET_SUBSCRIPTION_OK.name());
        }
        getSubscriptionRequest.ARBGetSubscriptionRequest.merchantAuthentication = buildAuthenticationObject();
        getSubscriptionRequest.ARBGetSubscriptionRequest.refId = String.valueOf(Crypto.getRandomLong());
        request.setBody(buildGetSubscriptionRequest(getSubscriptionRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response.getBody() : ' + response.getBody());
        GetSubscriptionResponse getSubscriptionResponse = (GetSubscriptionResponse) JSON.deserialize(removeBom(response.getBody()), GetSubscriptionResponse.class);
        System.debug('getSubscriptionResponse : ' + getSubscriptionResponse);
        validateResponse(getSubscriptionResponse.messages);
        return getSubscriptionResponse;
    }

    public static TransactionDetailsResponse sendGetTransactionDetailsRequest(TransactionDetailsRequest transactionDetailsRequest) {
        Map<String,String> keywordsToChange = new Map<String,String>();
        keywordsToChange.put('transaction', 'transactionDetails');

        HttpRequest request = buildRequest();
        if (Test.isRunningTest()) {
            request.setHeader('Callout-Type', AuthorizeNetMockGenerator.Callout.GET_TRANSACTION_DETAILS_OK.name());
        }
        transactionDetailsRequest.getTransactionDetailsRequest.merchantAuthentication = buildAuthenticationObject();
        request.setBody(buildGetTransactionDetailsRequest(transactionDetailsRequest));
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response.getBody() : ' + response.getBody());
        TransactionDetailsResponse transactionDetailsResponse = (TransactionDetailsResponse) JSON.deserialize(replaceKeywords(removeBom(response.getBody()), keywordsToChange), TransactionDetailsResponse.class);
        System.debug('transactionDetailsResponse : ' + transactionDetailsResponse);
        validateResponse(transactionDetailsResponse.messages);
        return transactionDetailsResponse;
    }

    private static void validateResponse(Message message) {
        System.debug(message);
        if (message.resultCode == 'Error') {
            saveLog(message);
            message.message = message.message == null ? new List<MessageItem>() : message.message;
            for (MessageItem messageItem : message.message) {
                if (messageItem.code == 'E00012') {
                    throw new DuplicateSubscriptionException('A duplicate of the subscription was already submitted');
                }
            }
            throwDefaultException(message);
        }
    }
    
    private static void validateTransactionResponse(CreateTransactionResponse response) {
        
        System.debug(response.messages);
        system.debug('transactionResponse -->'+ response.transactionResponse.errors);
        if(response.transactionResponse.errors != null){
            saveAuthTransactionLog(response.transactionResponse);
            system.debug('This transaction has been declined.');
            if (response.transactionResponse.errors[0].errorText != null) {
                throw new DeclinedTransactionException(response.transactionResponse.errors[0].errorText);
            } else {
                throw new DeclinedTransactionException('This transaction has been declined.');
            }
        }
        

        if (response.messages.resultCode == 'Error') {
            saveAuthTransactionLog(response.transactionResponse);
            if( response.transactionResponse != null ){
                response.transactionResponse.errors = response.transactionResponse.errors == null ? new List<Error>() : response.transactionResponse.errors;
                for (Error error : response.transactionResponse.errors) {
                    if (error.errorCode == '11') {
                        throw new DuplicateTransactionException('A duplicate of the transaction was already submitted');
                    }
                }
            }
            throwDefaultException(response.messages);
        }
    }
    
    private static void saveAuthTransactionLog(TransactionResponse res) {
        try {
            EventBus.publish(new Authorize_Net_Log_Event__e(
                Type__c = res.responseCode,
                Contact__c = ContactService.contactId,
                Full_Message__c = JSON.serialize(res)
            ));
        } catch (Exception ex) {
            System.debug('Save log exception ' + ex.getMessage());
            EventBus.publish(new Authorize_Net_Log_Event__e(
                Contact__c = ContactService.contactId,
                Full_Message__c = JSON.serialize(res)
            ));
            CustomErrorExceptionHandlerException.LogException(ex);
        }
    }

    private static void saveLog(Message message) {
        try {
            String description = '';
            if (message.message != null & !message.message.isEmpty() && message.message[0].text != null) {
                description = message.message[0].text.abbreviate(255);
            }
            EventBus.publish(new Authorize_Net_Log_Event__e(
                Type__c = message.resultCode,
                Contact__c = ContactService.contactId,
                Description__c = description,
                Full_Message__c = JSON.serialize(message)
            ));
        } catch (Exception ex) {
            System.debug('Save log exception ' + ex.getMessage());
            CustomErrorExceptionHandlerException.LogException(ex);
        }
    }

    private static void throwDefaultException(Message message) {
        String description = 'An integration error occurred';
        if (message.message != null && !message.message.isEmpty()) {
            description = message.message[0].text;
        }
        throw new AuthorizeNetException(description);
    }

    private static HttpRequest buildRequest() {
        HttpRequest request = new HttpRequest();
        system.debug('CA log request 1 '+ request);
        request.setEndpoint('callout:authorize_net');
        request.setMethod('POST');
        system.debug('CA log request 2 '+ request);
        return request;
    }
    
    private static HttpRequest buildRequest(String email) {
        HttpRequest request = new HttpRequest();
        if (String.isNotBlank(email) && email == 'tech@mexinsurance.com') {
            request.setEndpoint('callout:authorize_net');
            request.setMethod('POST');
        } else {
            system.debug('CA log request 1 '+ request);
            request.setEndpoint('callout:authorize_net');
            request.setMethod('POST');
            system.debug('CA log request 2 '+ request);
        }
        return request;
    }

    private static MerchantAuthentication buildAuthenticationObject() {
        MerchantAuthentication merchantAuthentication = new MerchantAuthentication();
        merchantAuthentication.name = '{!$Credential.Username}';
        // merchantAuthentication.name = '82G9WqsJq';
        merchantAuthentication.transactionKey = '{!$Credential.Password}';
         //merchantAuthentication.transactionKey = '99y4JBgAL8893Jkp';
        system.debug('merchantAuthentication : '+ merchantAuthentication);
        system.debug('Credential.Username : '+ '{!$Credential.Username}');
        system.debug('Credential.Password : '+ '{!$Credential.Password}');
        return merchantAuthentication;
    }

    //The API supports JSON with ordered fields only, standard serialization method doesn't guarantee the order
    private static String buildCreateCustomerProfileRequestBody(CreateCustomerProfileRequest customerProfileRequest) {
        String requestBody = '{' +
            '  "createCustomerProfileRequest": {' +
            '    "merchantAuthentication": {' +
            '      "name": "' + customerProfileRequest.merchantAuthentication.name + '",' +
            '      "transactionKey": "' + + customerProfileRequest.merchantAuthentication.transactionKey + '"' +
            '    },' +
            '    "profile": {' +
            '      "merchantCustomerId": "' + customerProfileRequest.profile.merchantCustomerId + '",' +
            '      "description": "' + customerProfileRequest.profile.description + '",' +
            '      "email": "' + customerProfileRequest.profile.email + '",' +
                    + buildPaymentProfilesString(customerProfileRequest.profile.paymentProfiles) +
            '      },' +
            '    "validationMode": "' + customerProfileRequest.validationMode + '"' +
            '  }' +
            '}';
        return requestBody;
    }

    private static String buildCreateCustomerPaymentProfileRequestBody(CreateCustomerPaymentProfileRequest customerPaymentProfileRequest) {
        String requestBody = '{' +
            '  "createCustomerPaymentProfileRequest": {' +
            '    "merchantAuthentication": {' +
            '      "name": "' + customerPaymentProfileRequest.merchantAuthentication.name + '",' +
            '      "transactionKey": "' + + customerPaymentProfileRequest.merchantAuthentication.transactionKey + '"' +
            '    },' +
            '    "customerProfileId": "' + customerPaymentProfileRequest.customerProfileId + '",' +
            + buildPaymentProfilesString(new List<PaymentProfile>{customerPaymentProfileRequest.paymentProfile}).replaceAll('"paymentProfiles": ', '"paymentProfile": ') +
            '    "validationMode": "' + customerPaymentProfileRequest.validationMode + '"' +
            '  }' +
            '}';
        return requestBody;
    }

    private static String buildPaymentProfilesString(List<PaymentProfile> paymentProfiles){
        String serializedPaymentProfiles = '';
        for (PaymentProfile paymentProfile : paymentProfiles) {
            serializedPaymentProfiles += '"paymentProfiles": {' +
                '  "customerType": "' + paymentProfile.customerType + '",' +
                '  "billTo": {' +
                '    "firstName": "' + paymentProfile.billTo.firstName + '",' +
                '    "lastName": "' + paymentProfile.billTo.lastName + '",' +
                '    "address": "' + paymentProfile.billTo.address + '",' +
                '    "city": "' + paymentProfile.billTo.city + '",' +
                '    "state": "' + paymentProfile.billTo.state + '",' +
                '    "zip": "' + paymentProfile.billTo.zip + '",' +
                '    "country": "' + paymentProfile.billTo.country + '"' +
                '  },' +
                '  "payment": {' +
                '    "creditCard": {' +
                '      "cardNumber": "' + paymentProfile.payment.creditCard.cardNumber + '",' +
                '      "expirationDate": "' + paymentProfile.payment.creditCard.expirationDate + '",' +
                '      "cardCode": "' + paymentProfile.payment.creditCard.cardCode + '"' +
                '    }' +
                '  },' +
                '},';
        }
        return serializedPaymentProfiles;
    }

    private static String buildGetCustomerProfileBody(GetCustomerProfileRequest customerProfileRequest) {
        return '{' +
            '    "getCustomerProfileRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + customerProfileRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + customerProfileRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "customerProfileId": "' + customerProfileRequest.customerProfileId + '",' +
            '        "includeIssuerInfo": "' + customerProfileRequest.includeIssuerInfo + '"' +
            '    }' +
            '}';
    }

    private static String buildChargeCreditCardRequest(CreateTransactionRequest transactionRequest) {
        return '{' +
            '    "createTransactionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + transactionRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + transactionRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + transactionRequest.refId + '",' +
            '        "transactionRequest": {' +
            '            "transactionType": "' + transactionRequest.transactionRequest.transactionType + '",' +
            '            "amount": "' + transactionRequest.transactionRequest.amount + '",' +
            '            "payment": {' +
            '                "creditCard": {' +
            '                   "cardNumber": "' + transactionRequest.transactionRequest.payment.creditCard.cardNumber + '",' +
            '                   "expirationDate": "' + transactionRequest.transactionRequest.payment.creditCard.expirationDate + '",' +
            '                   "cardCode": "' + transactionRequest.transactionRequest.payment.creditCard.cardCode + '"' +
            '                }' +
            '             },' +
            '            "lineItems": {' +
                         buildLineItems(transactionRequest.transactionRequest.lineItems) +
            '            },' +
            '            "billTo": {' +
            '                "firstName": "' + transactionRequest.transactionRequest.billTo.firstName + '",' +
            '                "lastName": "' + transactionRequest.transactionRequest.billTo.lastName + '",' +
            '                "address": "' + transactionRequest.transactionRequest.billTo.address + '",' +
            '                "city": "' + transactionRequest.transactionRequest.billTo.city + '",' +
            '                "state": "' + transactionRequest.transactionRequest.billTo.state + '",' +
            '                "zip": "' + transactionRequest.transactionRequest.billTo.zip + '",' +
            '                "country": "' + transactionRequest.transactionRequest.billTo.country + '"' +
            '            },' +
            '            "customerIP": "' + transactionRequest.transactionRequest.customerIP + '",' +
            '            "transactionSettings": {' +
            '               "setting": {'+
            '                   "settingName": "duplicateWindow",'+
            '                   "settingValue": "5"'+
            '                }'+
            '             },'+
            '            "processingOptions": {' +
            '                "isSubsequentAuth": "' + transactionRequest.transactionRequest.processingOptions.isSubsequentAuth + '"' +
            '            },' +
                         buildSubsequentAuthInformation(transactionRequest) +
            '            "authorizationIndicatorType": {' +
            '               "authorizationIndicator": "' + transactionRequest.transactionRequest.authorizationIndicatorType.authorizationIndicator + '"' +
            '            }' +
            '        }' +
            '    }' +
            '}';
    }
    /*
    private static String buildRefundTransactionRequest(CreateTransactionRequest transactionRequest) {
        return '{' +
            '    "createTransactionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + transactionRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + transactionRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + transactionRequest.refId + '",' +
            '        "transactionRequest": {' +
            '            "transactionType": "' + transactionRequest.transactionRequest.transactionType + '",' +
            '            "amount": "' + transactionRequest.transactionRequest.amount + '",' +
            '            "payment": {' +
            '                "creditCard": {' +
            '                   "cardNumber": "' + transactionRequest.transactionRequest.payment.creditCard.cardNumber + '",' +
            '                   "expirationDate": "' + transactionRequest.transactionRequest.payment.creditCard.expirationDate + '"' +
            '                }' +
            '             },' +
            '            "refTransId": "' + transactionRequest.transactionRequest.refTransId + '"' +
            '        }' +
            '    }' +
            '}';
    }
    */
    
    private static String buildRefundTransactionRequest(CreateTransactionRequest transactionRequest) {
        return '{' +
            '    "createTransactionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + transactionRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + transactionRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + transactionRequest.refId + '",' +
            '        "transactionRequest": {' +
            '            "transactionType": "' + transactionRequest.transactionRequest.transactionType + '",' +
            '            "amount": "' + transactionRequest.transactionRequest.amount + '",' +
            '            "payment": {' +
            '                "creditCard": {' +
            '                   "cardNumber": "' + transactionRequest.transactionRequest.payment.creditCard.cardNumber + '",' +
            '                   "expirationDate": "' + transactionRequest.transactionRequest.payment.creditCard.expirationDate + '"' +
            '                }' +
            '             },' +
            '            "refTransId": "' + transactionRequest.transactionRequest.refTransId + '"' +
            '        }' +
            '    }' +
            '}';
    }

    private static String buildRefundTransactionRequestForSavedCard(CreateTransactionRequest transactionRequest) {
        return '{' +
            '    "createTransactionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + transactionRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + transactionRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + transactionRequest.refId + '",' +
            '        "transactionRequest": {' +
            '            "transactionType": "' + transactionRequest.transactionRequest.transactionType + '",' +
            '            "amount": "' + transactionRequest.transactionRequest.amount + '",' +
            '            "profile": {' +
            '                "customerProfileId": "' + transactionRequest.transactionRequest.profile.customerProfileId + '",' +
            '                "paymentProfile": { ' +
            '                    "paymentProfileId": "' + transactionRequest.transactionRequest.profile.paymentProfile.paymentProfileId + '" ' +
            '                }' +
            '            },' +
            '            "refTransId": "' + transactionRequest.transactionRequest.refTransId + '"' +
            '        }' +
            '    }' +
            '}';
    }
    
    private static String buildChargeCustomerProfileRequest(CreateTransactionRequest transactionRequest) {
        return '{' +
            '    "createTransactionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + transactionRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + transactionRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + transactionRequest.refId + '",' +
            '        "transactionRequest": {' +
            '            "transactionType": "' + transactionRequest.transactionRequest.transactionType + '",' +
            '            "amount": "' + transactionRequest.transactionRequest.amount + '",' +
            '            "profile": {' +
            '                "customerProfileId": "' + transactionRequest.transactionRequest.profile.customerProfileId + '",' +
            '                "paymentProfile": { ' +
            '                    "paymentProfileId": "' + transactionRequest.transactionRequest.profile.paymentProfile.paymentProfileId + '" ' +
            '                }' +
            '            },' +
            '            "lineItems": {' +
                            + buildLineItems(transactionRequest.transactionRequest.lineItems) +
            '            },' +
            '            "customerIP": "' + transactionRequest.transactionRequest.customerIP + '",' +
            '            "processingOptions": {' +
            '                "isSubsequentAuth": "' + transactionRequest.transactionRequest.processingOptions.isSubsequentAuth + '"' +
            '            },' +
                         buildSubsequentAuthInformation(transactionRequest) +
            '            "authorizationIndicatorType": {' +
            '               "authorizationIndicator": "' + transactionRequest.transactionRequest.authorizationIndicatorType.authorizationIndicator + '"' +
            '            }' +
            '        }' +
            '    }' +
            '}';
    }

    private static String buildSubsequentAuthInformation(CreateTransactionRequest transactionRequest) {
        return transactionRequest.transactionRequest.processingOptions.isSubsequentAuth ? '"subsequentAuthInformation": {' +
            '    "originalNetworkTransId": "' + transactionRequest.transactionRequest.subsequentAuthInformation.originalNetworkTransId + '",' +
            '    "originalAuthAmount": "' + transactionRequest.transactionRequest.subsequentAuthInformation.originalAuthAmount + '",' +
            '    "reason": "' + transactionRequest.transactionRequest.subsequentAuthInformation.reason + '"' +
            '    ' +
            '},' : '';
    }

    private static String buildLineItems(List<TransactionLineItem> lineItems) {
        String serializedLineItems = '';
        String lineId;
        String lineName;
        String lineDescription;

        for (TransactionLineItem lineItem : lineItems) {
            lineId = lineItem.itemId;
            if (lineId.length() > 31) {
                lineId = lineId.substring(0, 31);
            }
            lineName = lineItem.name;
            if (lineName.length() > 31) {
                lineName = lineName.substring(0, 31);
            }
            lineDescription = lineItem.description;
            if (lineDescription.length() > 255) {
                lineDescription = lineDescription.substring(0, 255);
            }

            System.debug('lineName : ' + lineName);
            System.debug('lineDescription : ' + lineDescription);

            serializedLineItems += '"lineItem": {' +
                '    "itemId": "' + lineId + '",' +
                '    "name": "' + lineName + '",' +
                '    "description": "' + lineDescription + '",' +
                '    "quantity": "' + lineItem.quantity + '",' +
                '    "unitPrice": "' + lineItem.unitPrice + '"' +
                '},';
        }
        return serializedLineItems;
    }
    
    /*private static String buildOrderItems(List<TransactionOrderItem> lineItems) {
        String serializedLineItems = '';
        String lineId;
        String lineDescription;
        
        //for (TransactionLineItem lineItem : lineItems) {
            lineId = lineItems[0].invoiceNumber;
            if (lineId.length() > 31) {
                lineId = lineId.substring(0, 31);
            }
            lineDescription = lineItems[0].description;
            if (lineDescription.length() > 255) {
                lineDescription = lineDescription.substring(0, 255);
            }

            serializedLineItems = '{' +
                '    "invoiceNumber": "' + lineId + '",' +
                '    "description": "' + lineDescription + '"' +
                '}';
        //}
        return serializedLineItems;
    }*/
    
    private static String buildProfileSubscriptionRequest(ARBCreateSubscriptionRequest subscription) {
        return '{' +
            '    "ARBCreateSubscriptionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + subscription.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + subscription.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + subscription.refId + '",' +
            '        "subscription": {' +
            '            "name": "' + subscription.subscription.name + '",' +
            '            "paymentSchedule": {' +
            '                "interval": {' +
            '                    "length": "'+ subscription.subscription.paymentSchedule.interval.length +'",' +
            '                    "unit": "' + subscription.subscription.paymentSchedule.interval.unit + '"' +
            '                },' +
            '                "startDate": "' + subscription.subscription.paymentSchedule.startDate +'",' +
            '                "totalOccurrences": "' + subscription.subscription.paymentSchedule.totalOccurrences + '",' +
            '                "trialOccurrences": "' + subscription.subscription.paymentSchedule.trialOccurrences + '"' +
            '            },' +
            '            "amount": "' + subscription.subscription.amount + '",' +
            '            "trialAmount": "' + subscription.subscription.trialAmount + '",' +
            '            "profile": {' +
            '                "customerProfileId": "' + subscription.subscription.profile.customerProfileId + '",' +
            '                "customerPaymentProfileId": "' + subscription.subscription.profile.customerPaymentProfileId + '"' +
            '            }' +
            '        }' +
            '    }' +
            '}';
    }

    private static String buildSubscriptionRequest(ARBCreateSubscriptionRequest subscription) {
        return '{' +
            '    "ARBCreateSubscriptionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + subscription.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + subscription.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + subscription.refId + '",' +
            '        "subscription": {' +
            '            "name": "Sample subscription",' +
            '            "paymentSchedule": {' +
            '                "interval": {' +
            '                    "length": "'+ subscription.subscription.paymentSchedule.interval.length +'",' +
            '                    "unit": "' + subscription.subscription.paymentSchedule.interval.unit + '"' +
            '                },' +
            '                "startDate": "' + subscription.subscription.paymentSchedule.startDate +'",' +
            '                "totalOccurrences": "' + subscription.subscription.paymentSchedule.totalOccurrences + '",' +
            '                "trialOccurrences": "' + subscription.subscription.paymentSchedule.trialOccurrences + '"' +
            '            },' +
            '            "amount": "' + subscription.subscription.amount + '",' +
            '            "trialAmount": "' + subscription.subscription.trialAmount + '",' +
            '            "payment": {' +
            '                "creditCard": {' +
            '                   "cardNumber": "' + subscription.subscription.payment.creditCard.cardNumber + '",' +
            '                   "expirationDate": "' + subscription.subscription.payment.creditCard.expirationDate + '",' +
            '                   "cardCode": "' + subscription.subscription.payment.creditCard.cardCode + '"' +
            '                }' +
            '             },' +
            '            "billTo": {' +
            '                "firstName": "' + subscription.subscription.billTo.firstName + '",' +
            '                "lastName": "' + subscription.subscription.billTo.lastName + '",' +
            '                "address": "' + subscription.subscription.billTo.address + '",' +
            '                "city": "' + subscription.subscription.billTo.city + '",' +
            '                "state": "' + subscription.subscription.billTo.state + '",' +
            '                "zip": "' + subscription.subscription.billTo.zip + '",' +
            '                "country": "' + subscription.subscription.billTo.country + '"' +
            '            },' +
            '        }' +
            '    }' +
            '}';
    }

    private static String buildGetSubscriptionRequest(GetSubscriptionRequest getSubscriptionRequest) {
        return '{' +
            '    "ARBGetSubscriptionRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + getSubscriptionRequest.ARBGetSubscriptionRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + getSubscriptionRequest.ARBGetSubscriptionRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "refId": "' + getSubscriptionRequest.ARBGetSubscriptionRequest.refId + '",' +
            '        "subscriptionId": "' + getSubscriptionRequest.ARBGetSubscriptionRequest.subscriptionId + '",' +
            '        "includeTransactions": "' + getSubscriptionRequest.ARBGetSubscriptionRequest.includeTransactions + '"' +
            '    }' +
            '}';
    }

    private static String buildGetTransactionDetailsRequest(TransactionDetailsRequest transactionDetailsRequest) {
        return '{' +
            '    "getTransactionDetailsRequest": {' +
            '        "merchantAuthentication": {' +
            '            "name": "' + transactionDetailsRequest.getTransactionDetailsRequest.merchantAuthentication.name + '",' +
            '            "transactionKey": "' + transactionDetailsRequest.getTransactionDetailsRequest.merchantAuthentication.transactionKey + '"' +
            '        },' +
            '        "transId": "' + transactionDetailsRequest.getTransactionDetailsRequest.transId + '"' +
            '    }' +
            '}';
    }

    private static String removeBom(String value) {
        return value.replaceAll('\\uFEFF', '');
    }

    public static String replaceKeywords(String jsonString, Map<String, String> keywordsToReplace) {
        for (String keyword : keywordsToReplace.keySet()) {
            jsonString = jsonString.replace(keyword, keywordsToReplace.get(keyword));
        }

        return jsonString;
    }
    
    public class CreateCustomerProfileRequest {
        public MerchantAuthentication merchantAuthentication;
        public Profile profile;
        public String validationMode;

        public CreateCustomerProfileRequest() {
            merchantAuthentication = new MerchantAuthentication();
            profile = new Profile();
        }
    }

    public class CreateCustomerPaymentProfileRequest {
        public MerchantAuthentication merchantAuthentication;
        public String customerProfileId;
        public PaymentProfile paymentProfile;
        public String validationMode;

        public CreateCustomerPaymentProfileRequest() {
            merchantAuthentication = new MerchantAuthentication();
            paymentProfile = new PaymentProfile();
        }
    }

    public class GetCustomerProfileRequest {
        public MerchantAuthentication merchantAuthentication;
        public String customerProfileId;
        public Boolean includeIssuerInfo;

        public GetCustomerProfileRequest() {
            merchantAuthentication = new MerchantAuthentication();
        }
    }

    public class GetPaymentProfileRequest {
        public MerchantAuthentication merchantAuthentication;
        public String customerProfileId;
        public String customerPaymentProfileId;
        public Boolean includeIssuerInfo;

        public GetPaymentProfileRequest() {
            merchantAuthentication = new MerchantAuthentication();
        }
    }

    public class CreateTransactionRequest {
        public MerchantAuthentication merchantAuthentication;
        public String refId;
        public TransactionRequest transactionRequest;

        public CreateTransactionRequest() {
            merchantAuthentication = new MerchantAuthentication();
            transactionRequest = new TransactionRequest();
        }
    }

    public class MerchantAuthentication {
        public String name;
        public String transactionKey;
    }

    public class Profile {
        public String merchantCustomerId;
        public String description;
        public String email;
        public List<PaymentProfile> paymentProfiles;

        public Profile() {
            paymentProfiles = new List<PaymentProfile>();
        }
    }

    public class PaymentProfile {
        public String customerType;
        public Payment payment;
        public BillTo billTo;

        public PaymentProfile() {
            payment = new Payment();
            billTo = new BillTo();
        }
    }

    public class BillTo {
        public String firstName;
        public String lastName;
        public String address;
        public String city;
        public String state;
        public String country;
        public String zip;
    }

    public class Payment {
        public CreditCard creditCard;

        public Payment() {
            creditCard = new CreditCard();
        }
    }

    public class CreditCard {
        public String cardNumber;
        public String expirationDate;
        public String cardCode;
        public String cardType;

        public void setExpirationDate(String year, String month) {
            if (month.length() == 1) {
                month = '0' + month;
            }
            this.expirationDate = year + '-' + month;
        }
    }

    public class TransactionRequest {
        public String transactionType;
        public Decimal amount;
        public Payment payment;
        public TransactionProfile profile;
        public List<TransactionLineItem> lineItems;
        public BillTo billTo;
        public ProcessingOptions processingOptions;
        public SubsequentAuthInformation subsequentAuthInformation;
        public AuthorizationIndicatorType authorizationIndicatorType;
        public String customerIP;
        public String refTransId;

        public TransactionRequest() {
            payment = new Payment();
            profile = new TransactionProfile();
            lineItems = new List<TransactionLineItem>();
            billTo = new BillTo();
            processingOptions = new ProcessingOptions();
            subsequentAuthInformation = new SubsequentAuthInformation();
            authorizationIndicatorType = new AuthorizationIndicatorType();
        }
    }

    public class TransactionProfile {
        public String customerProfileId;
        public TransactionPaymentProfile paymentProfile;

        public TransactionProfile() {
            paymentProfile = new TransactionPaymentProfile();
        }
    }

    public class TransactionPaymentProfile {
        public String paymentProfileId;
    }

    public class TransactionLineItem {
        public String itemId;
        public String name;
        public String description;
        public Integer quantity;
        public Decimal unitPrice;
    }

    public class ProcessingOptions {
        public Boolean isSubsequentAuth;
    }

    public class SubsequentAuthInformation {
        public String originalNetworkTransId;
        public Decimal originalAuthAmount;
        public String reason;
    }

    public class AuthorizationIndicatorType {
        public String authorizationIndicator;
    }

    public class CreateTransactionResponse {
        public Message messages;
        public TransactionResponse transactionResponse;
        public String refId;

        public CreateTransactionResponse() {
            messages = new Message();
            transactionResponse = new TransactionResponse();
        }
    }

    public class TransactionResponse {
        public String responseCode;
        public String authCode;
        public String avsResultCode;
        public String cvvResultCode;
        public String cavvResultCode;
        public String transId;
        public String refTransID;
        public String transHash;
        public String testRequest;
        public String accountNumber;
        public String accountType;
        public List<Error> errors;
        public List<MessageItem> message;
        public String transHashSha2;
        public ProfileResponseItem profile;
        public String SupplementalDataQualificationIndicator;
        public String networkTransId;

        public TransactionResponse() {
            message = new List<MessageItem>();
            profile = new ProfileResponseItem();
            errors = new List<Error>();
        }
    }

    public class Error {
        public String errorCode;
        public String errorText;
    }

    public class ProfileResponseItem {
        public String customerProfileId;
        public String customerPaymentProfileId;
    }

    public class Message {
        public String resultCode;
        public List<MessageItem> message;

        public Message() {
            message = new List<MessageItem>();
        }
    }

    public class MessageItem {
        public String code;
        public String text;
        public String description;
    }

    public class CustomerProfileResponse {
        public String customerProfileId;
        public List<String> customerPaymentProfileIdList;
        public Message messages;

        public CustomerProfileResponse() {
            customerPaymentProfileIdList = new List<String>();
            messages = new Message();
        }
    }

    public class CustomerPaymentProfileResponse {
        public String customerProfileId;
        public String customerPaymentProfileId;
        public String validationDirectResponse;
        public Message messages;

        public CustomerPaymentProfileResponse() {
            messages = new Message();
        }
    }

    public class ARBCreateSubscriptionRequest {
        public MerchantAuthentication merchantAuthentication;
        public String refId;
        public Subscription subscription;

        public ARBCreateSubscriptionRequest() {
            subscription = new Subscription();
            merchantAuthentication = new MerchantAuthentication();
        }
    }

    public class TransactionDetailsRequest {
        public GetTransactionDetailsRequest getTransactionDetailsRequest;

        public TransactionDetailsRequest() {
            this.getTransactionDetailsRequest = new GetTransactionDetailsRequest();
        }
    }
    
    public class GetTransactionDetailsRequest {
        public MerchantAuthentication merchantAuthentication;
        public String transId;

        public GetTransactionDetailsRequest() {
            this.merchantAuthentication = new MerchantAuthentication();
        }
    }

    public class GetSubscriptionRequest {    
        public ARBGetSubscriptionRequest ARBGetSubscriptionRequest;

        public GetSubscriptionRequest() {
            this.ARBGetSubscriptionRequest = new ARBGetSubscriptionRequest();
        }
    }
    
    public class ARBGetSubscriptionRequest {
        public MerchantAuthentication merchantAuthentication;
        public String refId;
        public String subscriptionId;
        public Boolean includeTransactions;

        public ARBGetSubscriptionRequest() {
            this.merchantAuthentication = new MerchantAuthentication();
        }
    }

    public class Subscription {
        public String name;
        public PaymentSchedule paymentSchedule;
        public Decimal amount;
        public Decimal trialAmount;
        public SubscriptionProfile profile;
        public BillTo billTo;
        public Payment payment;

        public Subscription() {
            paymentSchedule = new PaymentSchedule();
            profile = new SubscriptionProfile();
            billTo = new BillTo();
            payment = new Payment();
        }
    }

    public class PaymentSchedule {
        public Interval interval;
        public String startDate;
        public String totalOccurrences;
        public String trialOccurrences;

        public PaymentSchedule() {
            interval = new Interval();
        }
    }

    public class Interval {
        public String length;
        public String unit;
    }

    public class SubscriptionProfile {
        public String customerProfileId;
        public String customerPaymentProfileId;
    }

    public class CreateSubscriptionResponse {
        public String subscriptionId;
        public SubscriptionProfile profile;
        public String refId;
        public Message messages;

        public CreateSubscriptionResponse() {
            profile = new SubscriptionProfile();
            messages = new Message();
        }
    }

    public class TransactionDetailsResponse {
        public Message messages;
        public TransactionDetails transactionDetails;

        public TransactionDetailsResponse() {
            this.messages = new Message();
            this.transactionDetails = new TransactionDetails();
        }
    }

    public class TransactionDetails {
        public String customerIP;
        public String transId;
        public Payment payment;

        public TransactionDetails() {
            this.payment = new Payment();
        }
    }

    public class GetSubscriptionResponse {
        public String refId;
        public Message messages;
        public ARBGetSubscription subscription;

        public GetSubscriptionResponse() {
            this.messages = new Message();
            this.subscription = new ARBGetSubscription();
        }
    }

    public class ARBGetSubscription {
        public List<ArbTransaction> arbTransactions;

        public ARBGetSubscription() {
            this.arbTransactions = new List<ArbTransaction>();
        }
    }

    public class ArbTransaction {
        public String transId;
        public String response;
        public String submitTimeUTC;
        public String payNum;
        public String attemptNum;
    }

    public class GetProfileResponse {
        public GetCustomerProfileResponse profile;
        public Message messages;
        public List<String> subscriptionIds;

        public GetProfileResponse() {
            messages = new Message();
            subscriptionIds = new List<String>();
            profile = new GetCustomerProfileResponse();
        }
    }

    public class GetCustomerProfileResponse {
        public List<PaymentProfileResponse> paymentProfiles;

        public GetCustomerProfileResponse() {
            paymentProfiles = new List<PaymentProfileResponse>();
        }
    }

    public class PaymentProfileResponse {
        public String customerPaymentProfileId;
        public Payment payment;
        public String customerType;
        public BillTo billTo;

        public PaymentProfileResponse() {
            payment = new Payment();
            billTo = new BillTo();
        }
    }

    public class AuthorizeNetException extends Exception {}

    public class DuplicateSubscriptionException extends Exception {}

    public class DuplicateTransactionException extends Exception {}
    
    public class DeclinedTransactionException extends Exception {}
}