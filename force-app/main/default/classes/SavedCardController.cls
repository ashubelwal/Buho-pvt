/**
 * @description       : This class is used to get, add and remove new card to authorize.net
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-30-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SavedCardController {
    private static List<Authorize_Net_Customer_Profile__c> getCustomerProfileId() {
        List<Authorize_Net_Customer_Profile__c> getProfileIds = new List<Authorize_Net_Customer_Profile__c>();
        getProfileIds = [SELECT Id, Profile_Id__c FROM Authorize_Net_Customer_Profile__c WHERE Contact__c = :ContactService.contactId];
        return getProfileIds;
    }
    
    @AuraEnabled
    public static Map<String, Map<Id,String>> getCardDetialsByContact() {
        List<Policy__c> getPolicy = new List<Policy__c>();
        getPolicy = [SELECT Id, Name,Auto_renew__c, Auto_renew_card__c, Renew_Payment_Profile_Id__c FROM policy__c WHERE Contact__c = :ContactService.contactId AND Status_picklist__c = 'Active'];
        System.debug('getPolicy---'+getPolicy);
        Map<String, Map<Id,String>> paymentProfileIdVsPolicyNames = new Map<String, Map<Id,String>>();
		
        if(getPolicy.size() > 0){
            for (Policy__c policy : getPolicy) {
                if (policy.Auto_renew__c == true && policy.Renew_Payment_Profile_Id__c != null) {
                    String paymentProfileId = policy.Renew_Payment_Profile_Id__c;
                    String policyName = policy.Name;
                    
                    if (!paymentProfileIdVsPolicyNames.containsKey(paymentProfileId)) {
                        paymentProfileIdVsPolicyNames.put(paymentProfileId, new Map<Id,String>{policy.Id =>policyName});
                    } else {
                        paymentProfileIdVsPolicyNames.get(paymentProfileId).put(policy.Id, policyName);
                    }
                }
            }
        }
        

        System.debug('paymentProfileIdVsPolicyNames--'+paymentProfileIdVsPolicyNames);
        return paymentProfileIdVsPolicyNames;
    }
    
    private static String makeCallout(String body) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:authorize_dot_net');
            request.setMethod('POST');
            request.setBody(body);
            Http http = new Http();
            HttpResponse response = http.send(request);
            return response.getBody();
        } catch(Exception e) {
            System.debug('Exception>>'+e.getMessage()+ ' at line>>'+e.getLineNumber());
            throw e;
        }
    }
    @AuraEnabled
    public static String getCardDetailsByProfileId() {
        try {
            List<Authorize_Net_Customer_Profile__c> getProfileIds = getCustomerProfileId();
            AuthorizeNetClient.GetProfileResponse getProfiledetails = new AuthorizeNetClient.GetProfileResponse();
            CardDetailsWrapper cardDetail = new CardDetailsWrapper();
            List<AuthorizeNetClient.PaymentProfileResponse> allcardsList= new List<AuthorizeNetClient.PaymentProfileResponse>();
            List<AuthorizeNetClient.PaymentProfileResponse> expiredcardsList= new List<AuthorizeNetClient.PaymentProfileResponse>();
            if(!getProfileIds.isEmpty()) {
                Authorize_Net_Customer_Profile__c getCustomerProfuleId = getProfileIds.get(0);
                getProfiledetails = AuthorizeNetClient.sendGetCustomerProfileRequest(getCustomerProfuleId.Profile_Id__c);
                getProfiledetails.profile.paymentProfiles = getProfiledetails.profile.paymentProfiles == null ? new List<AuthorizeNetClient.PaymentProfileResponse>() : getProfiledetails.profile.paymentProfiles;
                Map<String, Authorize_Net_Payment_Profile__c> paymentProfileVsDateMap = new Map<String, Authorize_Net_Payment_Profile__c>();
                for(Authorize_Net_Payment_Profile__c paymentProfiles : [SELECT Id, Card_Expiration_Date__c, Payment_Profile_Id__c FROM Authorize_Net_Payment_Profile__c WHERE Authorize_Net_Customer_Profile__c =: getProfileIds.get(0).Id]) {
                    paymentProfileVsDateMap.put(paymentProfiles.Payment_Profile_Id__c, paymentProfiles);
                }
                for(AuthorizeNetClient.PaymentProfileResponse profileResp : getProfiledetails.profile.paymentProfiles) {
                    Authorize_Net_Payment_Profile__c paymentProfile = paymentProfileVsDateMap.get(profileResp.customerPaymentProfileId);
                    if(paymentProfile != null && paymentProfile.Card_Expiration_Date__c != null) {
                        List<String> yearAndMonth = new List<String>();
                        yearAndMonth = paymentProfile.Card_Expiration_Date__c.split('-');
                        Integer year = Integer.valueOf(yearAndMonth[0]);
                        Integer month = Integer.valueOf(yearAndMonth[1]);
                        if(year > Date.today().year()) {
                            allcardsList.add(profileResp);
                        }
                        else if(Date.today().year() == year) {
                            if(month >= Date.today().month()) {
                                allcardsList.add(profileResp);
                            }
                            else {
                                expiredcardsList.add(profileResp);
                            }
                        }
                        else {
                            expiredcardsList.add(profileResp);
                        }
                    }
                    else {
                        allcardsList.add(profileResp);
                    }
                }
            }
            cardDetail.allCards = allcardsList;
            cardDetail.expiredCards = expiredcardsList;
            return '{"messages": {"resultCode": "Ok", "message":'+JSON.serialize(cardDetail)+'}}';
        } catch(Exception e) {
            system.debug('exception:::'+e.getMessage()+' line'+e.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(e);
            return '{"messages": {"resultCode": "Error", "message":"'+e.getMessage()+'"}}';
        }
    }
    @AuraEnabled
    public static String getCardDetailsByMonth(String month){
        try {
            List<Authorize_Net_Customer_Profile__c> getProfiles = getCustomerProfileId();
            if(!getProfiles.isEmpty() && String.isNotBlank(month) && String.isNotEmpty(month)) {
                AuthorizeNetClient.MerchantAuthentication authenticationObj = new AuthorizeNetClient.MerchantAuthentication();
                authenticationObj = buildAuthenticationObject();
                String reqBody = buildCustomerPaymentProfileListBody(authenticationObj, month);
                String respBody = makeCallout(reqBody).remove('﻿');
                return respBody;
            }
            return '{"Status": "Failed", "Message": "Customer Payment Profile Not Found"}';
        } catch (Exception e) {
            System.debug('Exception>>'+e.getMessage()+ ' at line>>'+e.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String addNewCardTOCustomerProfile(String newCreditCard) {
        try {
            ContactService.CreditCard creditCard = (ContactService.CreditCard) JSON.deserialize(newCreditCard, ContactService.CreditCard.class);
            String profileId = ContactService.createProfile(creditCard, new List<String>());
            if(Test.isRunningTest()) {
                profileId = '22222';
            }
            if(String.isNotBlank(profileId) && String.isNotEmpty(profileId)) {
                List<Authorize_Net_Customer_Profile__c> getProfileIds = getCustomerProfileId();
                List<Authorize_Net_Payment_Profile__c> getPaymentProfile = [SELECT Id FROM Authorize_Net_Payment_Profile__c WHERE Payment_Profile_Id__c =:profileId AND Authorize_Net_Customer_Profile__c =:getProfileIds.get(0).Id];
                if(!getPaymentProfile.isEmpty()) {
                    Authorize_Net_Payment_Profile__c updateCardDate = new Authorize_Net_Payment_Profile__c();
                    updateCardDate.Id = getPaymentProfile.get(0).Id;
                    updateCardDate.Card_Expiration_Date__c = creditCard.year+'-'+creditCard.month;
                    update updateCardDate;
                }
                return '{"Status": "Ok", "Message": "New Card is added."}';
            }
            else {
                return '{"Status": "Error", "Message": "Customer Payment Profile Not Found"}';
            }
        } catch(Exception e) {
            System.debug('Exception>>'+e.getMessage()+ ' at line>>'+e.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(e);
            return '{"Status": "Error", "Message": "'+e.getMessage()+'"}';
        }
    }
    @AuraEnabled
    public static String updateCardToCustomerProfile(String paymentProfileId, String cardDetails) {
        try {
            Map<String, Object> creditCard = (Map<String, Object>) JSON.deserializeUntyped(cardDetails);
            List<Authorize_Net_Customer_Profile__c> getProfileIds = getCustomerProfileId();
            if(!getProfileIds.isEmpty() && String.isNotBlank(paymentProfileId) && String.isNotEmpty(paymentProfileId)) {
                AuthorizeNetClient.MerchantAuthentication authReq = buildAuthenticationObject();
                String respBody = makeCallout(buildUpdateCustomerpaymentProfileRequestBody(authReq, creditCard, paymentProfileId, (String) getProfileIds.get(0).Profile_Id__c));
                if(respBody.contains('"resultCode":"Ok"') && String.valueOf(creditCard.get('year')) != 'XXXX') {
                    List<Authorize_Net_Payment_Profile__c> paymProflst = [SELECT Id FROM Authorize_Net_Payment_Profile__c WHERE Payment_Profile_Id__c =:paymentProfileId];
                    if(paymProflst.size() > 0) {
                        Authorize_Net_Payment_Profile__c paymentProfObj = new Authorize_Net_Payment_Profile__c();
                        paymentProfObj.Id = paymProflst[0].Id;
                        paymentProfObj.Card_Expiration_Date__c = String.valueOf(creditCard.get('year')) + '-' +String.valueOf(creditCard.get('month'));
                        update paymentProfObj;
                    }
                }
                List<String> respList = respBody.split('"messages"');
                return '{"messages"'+respList[1];
            }
            return '{"messages": { "resultCode": "Error", "message": [{ "code": "400", "text": "We are unable to update card details." } ] }';
        } catch(Exception e) {
            system.debug('exception:::'+e.getMessage()+'line:::'+e.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(e);
            return '{"messages": { "resultCode": "Error", "message": [{ "code": "400", "text": "Something went wrong." } ] }';
        }
    }
    @AuraEnabled
    public static string removeCardFromCustomerprofile(String paymentProfileId){
        try {
            List<Authorize_Net_Customer_Profile__c> getProfileIds = getCustomerProfileId();
            if(!getProfileIds.isEmpty() && String.isNotBlank(paymentProfileId) && String.isNotEmpty(paymentProfileId)) {
                CustomerPaymentProfileRequest requestBody = new CustomerPaymentProfileRequest();
                requestBody.merchantAuthentication = buildAuthenticationObject();
                requestBody.customerPaymentProfileId = paymentProfileId;
                requestBody.customerProfileId = getProfileIds.get(0).Profile_Id__c;
                String responseBody = makeCallout(buildDeleteCustomerPaymentProfile(requestBody));
                removePaymentProfile(getProfileIds.get(0).Id, paymentProfileId);
                List<String> respBodyLst = responseBody.split('"messages"');
                return '{"messages"'+respBodyLst[1];
            }
            return '{"messages": { "resultCode": "Error", "message": [{ "code": "400", "text": "We are unable to remove card." } ] }';
        } catch (Exception e) {
            System.debug('Exception>>'+e.getMessage()+ ' at line>>'+e.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(e);
            return '{"messages": { "resultCode": "Error", "message": [{ "code": "400", "text": "Something went wrong." } ] }';
        }
    }
    
    private static void removePaymentProfile(Id customerProfileId, String paymentProfId) {
        try {
            List<Authorize_Net_Payment_Profile__c> paymentProfileList = new List<Authorize_Net_Payment_Profile__c>();
            paymentProfileList = [SELECT Id FROM Authorize_Net_Payment_Profile__c WHERE Authorize_Net_Customer_Profile__c =:customerProfileId AND Payment_Profile_Id__c =:paymentProfId];
            if(!paymentProfileList.isEmpty()) {
                delete paymentProfileList;
            }
        } catch(Exception e) {
            System.debug('Exception>>'+e.getMessage()+ ' at line>>'+e.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(e);
            throw e;
        }
    }
    private static AuthorizeNetClient.MerchantAuthentication buildAuthenticationObject() {
        AuthorizeNetClient.MerchantAuthentication merchantAuthentication = new AuthorizeNetClient.MerchantAuthentication();
        merchantAuthentication.name = '{!$Credential.Username}';
        // merchantAuthentication.name = '82G9WqsJq';
        merchantAuthentication.transactionKey = '{!$Credential.Password}';
         //merchantAuthentication.transactionKey = '99y4JBgAL8893Jkp';
        return merchantAuthentication;
    }
    private static string buildDeleteCustomerPaymentProfile(CustomerPaymentProfileRequest paymentprofileBody) {
        return '{'+
        '           "deleteCustomerPaymentProfileRequest": {'+
        '               "merchantAuthentication": {'+
        '                   "name": "'+paymentprofileBody.merchantAuthentication.name+'",'+
        '                   "transactionKey": "'+paymentprofileBody.merchantAuthentication.transactionKey+'"'+
        '               },'+
        '               "customerProfileId": "'+paymentprofileBody.customerProfileId+'",'+
        '               "customerPaymentProfileId": "'+paymentprofileBody.customerPaymentProfileId+'"'+
        '           }'+
        '       }';
    }
    private static String buildUpdateCustomerpaymentProfileRequestBody(AuthorizeNetClient.MerchantAuthentication authBody, Map<String, Object> creditCard, String paymentProfId, String profid) {
        String fullName = String.valueOf(creditCard.get('name'));
        List<String> name = fullName.split(' ');
        String firstName = name[0];
        String lastName = name.size() > 1 ? name[1] : '';
        String cardExpDate = String.valueOf(creditCard.get('year')) == 'XXXX' ? String.valueOf(creditCard.get('year')) : String.valueOf(creditCard.get('year')) + '-' +String.valueOf(creditCard.get('month'));
        String validationMode = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox == true ? 'testMode' : 'liveMode';
        return '{'+
                    '"updateCustomerPaymentProfileRequest": {'+
                        '"merchantAuthentication": {'+
                            '"name": "'+authBody.name+'",'+
                            '"transactionKey": "'+authBody.transactionKey+'"'+
                        '},'+
                        '"customerProfileId": "'+profid+'",'+
                        '"paymentProfile": {'+
                            '"billTo": {'+
                            '"firstName": "'+firstName+'",'+
                            '"lastName": "'+lastName+'",'+
                            '"address": "'+String.valueOf(creditCard.get('address1'))+'",'+
                            '"city": "'+String.valueOf(creditCard.get('city'))+'",'+
                            '"state": "'+String.valueOf(creditCard.get('state'))+'",'+
                            '"zip": "'+String.valueOf(creditCard.get('zip'))+'",'+
                            '"country": "'+String.valueOf(creditCard.get('country'))+'"'+
                            /*'"phoneNumber": "'+paymentProfileRequest.paymentProfile.billTo.+'"'*/
                            '},'+
                            '"payment": {'+
                                '"creditCard": {'+
                                    '"cardNumber": "'+String.valueOf(creditCard.get('cardNumber'))+'",'+
                                    '"expirationDate": "'+cardExpDate+'"'+
                                '}'+
                            '},'+
                            '"defaultPaymentProfile": false,'+
            				'"customerPaymentProfileId": "'+paymentProfId+'"'+
                        '},'+
                        '"validationMode": "'+ validationMode +'"'+
                    '}'+
                '}';
    }
    private static String buildCustomerPaymentProfileListBody(AuthorizeNetClient.MerchantAuthentication authdata, String month) {
        return '{'+
                    '"getCustomerPaymentProfileListRequest": {'+
                        '"merchantAuthentication": {'+
                            '"name": "'+authdata.name+'",'+
                            '"transactionKey": "'+authdata.transactionKey+'"'+
                        '},'+
                        '"searchType": "cardsExpiringInMonth",'+
                        '"month": "'+Date.today().year() +'-'+month+'",'+
                        '"sorting": {'+
                            '"orderBy": "id",'+
                            '"orderDescending": "false"'+
                        '},'+
                        '"paging": {'+
                                '"limit": "1000",'+
                                '"offset": "1"'+
                        '}'+
                    '}'+
                '}';
    }
    public class CustomerPaymentProfileRequest {
        public AuthorizeNetClient.MerchantAuthentication merchantAuthentication;
        public String customerProfileId;
        public String customerPaymentProfileId;
        public CustomerPaymentProfileRequest() {
            merchantAuthentication = new AuthorizeNetClient.MerchantAuthentication();
        }
    }
    public class CardDetailsWrapper {
        public List<AuthorizeNetClient.PaymentProfileResponse> allCards;
        public List<AuthorizeNetClient.PaymentProfileResponse> expiredCards;
    }
}