@IsTest
public with sharing class AuthorizeNetMockGenerator implements HttpCalloutMock {

    public AuthorizeNetMockGenerator() {}

    public AuthorizeNetMockGenerator(Callout calloutType) {
        this.calloutType = calloutType;
    }

    public enum Callout {
        CREATE_PROFILE_OK,
        CREATE_PAYMENT_PROFILE_OK,
        GET_CUSTOMER_PROFILE,
        CREATE_PROFILE_TRANSACTION_OK,
        CREATE_TRANSACTION_OK,
        CREATE_PROFILE_SUBSCRIPTION_OK,
        CREATE_SUBSCRIPTION_OK,
        GET_EMPTY_SUBSCRIPTION_OK,
        GET_SUBSCRIPTION_OK,
        GET_TRANSACTION_DETAILS_OK
    }

    public Callout calloutType {get; set;}

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (calloutType == Callout.CREATE_PROFILE_OK) {
            res.setBody('' +
                '{' +
                '    "customerProfileId": "190178",' +
                '    "customerPaymentProfileIdList": [' +
                '        "157497"' +
                '    ],' +
                '    "customerShippingAddressIdList": [],' +
                '    "validationDirectResponseList": [' +
                '        "1,1,1,(TESTMODE) This transaction has been approved.,000000,P,0,none,Test transaction for ValidateCustomerPaymentProfile.,1.00,CC,auth_only,Merchant_Customer_ID,,,,,,,,,,,customer-profile-email@her.com,,,,,,,,,0.00,0.00,0.00,FALSE,none,207BCBBF78E85CF174C87AE286B472D2,,,,,,,,,,,,,XXXX1111,Visa,,,,,,,,,,,,,,,,"' +
                '    ],' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
            res.setStatusCode(200);
        } else if (calloutType == Callout.CREATE_PAYMENT_PROFILE_OK) {
            res.setBody('{' +
                '  "customerProfileId": "11111",' +
                '  "customerPaymentProfileId": "20000",' +
                '  "validationDirectResponse": "1,1,1,This transaction has been approved.,000000,Y,2000000000,none,Test transaction for ' +
                'ValidateCustomerPaymentProfile.,0.00,CC,auth_only,custId123,' +
                'John,Doe,,123 Main St.,Bellevue,WA,98004,USA,000-000-0000,,email@example.com,,,,,,,,,0.00,0.00,0.00,FALSE,none,' +
                'D18EB6B211FE0BBF556B271FDA6F92EE,P,2,,,,,,,,,,,XXXX1111,Visa,,,,,,,,,,,,,,,,,",' +
                '  "messages": {' +
                '    "resultCode": "Ok",' +
                '    "message": [' +
                '      {' +
                '        "code": "I00001",' +
                '        "text": "Successful."' +
                '      }' +
                '    ]' +
                '  }' +
                '}');
        } else if (calloutType == Callout.GET_CUSTOMER_PROFILE) {
            res.setBody('{' +
                '    "profile": {' +
                '        "paymentProfiles": [' +
                '            {' +
                '                "defaultPaymentProfile": true,' +
                '                "customerPaymentProfileId": "22222",' +
                '                "payment": {' +
                '                    "creditCard": {' +
                '                        "cardNumber": "XXXX1111",' +
                '                        "expirationDate": "XXXX",' +
                '                        "cardType": "Visa",' +
                '                        "issuerNumber": "411111",' +
                '                        "isPaymentToken": true' +
                '                    }' +
                '                },' +
                '                "customerType": "individual",' +
                '                "billTo": {' +
                '                    "firstName": "John",' +
                '                    "lastName": "Smith"' +
                '                }' +
                '            }' +
                '        ],' +
                '        "customerProfileId": "11111",' +
                '        "merchantCustomerId": "CUST001",' +
                '        "description": "Profile created by Subscription: 3078153",' +
                '        "email": "joe@mail.com"' +
                '    },' +
                '    "subscriptionIds": [' +
                '        "3078153",' +
                '        "3078154"' +
                '    ],' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        } else if (calloutType == Callout.CREATE_PROFILE_TRANSACTION_OK) {
            res.setBody('{' +
                '    "transactionResponse": {' +
                '        "responseCode": "1",' +
                '        "authCode": "4JYKA2",' +
                '        "avsResultCode": "Y",' +
                '        "cvvResultCode": "P",' +
                '        "cavvResultCode": "2",' +
                '        "transId": "2157786076",' +
                '        "refTransID": "",' +
                '        "transHash": "",' +
                '        "testRequest": "0",' +
                '        "accountNumber": "XXXX2222",' +
                '        "accountType": "Visa",' +
                '        "messages": [' +
                '            {' +
                '                "code": "1",' +
                '                "description": "This transaction has been approved."' +
                '            }' +
                '        ],' +
                '        "transHashSha2": "",' +
                '        "profile": {' +
                '            "customerProfileId": "11111",' +
                '            "customerPaymentProfileId": "22222"' +
                '        },' +
                '        "SupplementalDataQualificationIndicator": 0,' +
                '        "networkTransId": "6PUPU4XXWSO7CCQL0YJNYY7"' +
                '    },' +
                '    "refId": "123456",' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        } else if (calloutType == Callout.CREATE_TRANSACTION_OK) {
            res.setBody('{' +
                '    "transactionResponse": {' +
                '        "responseCode": "1",' +
                '        "authCode": "HW617E",' +
                '        "avsResultCode": "Y",' +
                '        "cvvResultCode": "",' +
                '        "cavvResultCode": "",' +
                '        "transId": "2157047189",' +
                '        "refTransID": "",' +
                '        "transHash": "E7CEB0A9F1BECA32A02493E1B31D5955",' +
                '        "testRequest": "0",' +
                '        "accountNumber": "XXXX1111",' +
                '        "accountType": "Visa",' +
                '        "messages": [' +
                '            {' +
                '                "code": "1",' +
                '                "description": "This transaction has been approved."' +
                '            }' +
                '        ],' +
                '        "transHashSha2": "D0C4FFF5648511A5862B917CFD9BB78ABF8A6E1D90C119CBBC4C0B454F4FF40DED15B204E042F36ECA5FB15D02588E4E4A7B85B94E7279599CE6020462CB7DEE",' +
                '        "SupplementalDataQualificationIndicator": 0,' +
                '	"networkTransId": "123456789NNNH"' +
                '    },' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        } else if (calloutType == Callout.CREATE_PROFILE_SUBSCRIPTION_OK) {
            res.setBody('{' +
                '  "subscriptionId": "158383",' +
                '	"profile": {' +
                '		"customerProfileId": "11111",' +
                '		"customerPaymentProfileId": "22222",' +
                '		"customerAddressId": "37726371"' +
                '	},' +
                '    "refId": "123456",' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        } else if (calloutType == Callout.CREATE_SUBSCRIPTION_OK) {
            res.setBody('{' +
                '    "subscriptionId": "158383",' +
                '    "profile": {' +
                '        "customerProfileId": "11111",' +
                '        "customerPaymentProfileId": "22222",' +
                '		"customerAddressId": "189691"' +
                '    },' +
                '    "refId": "123456",' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        } else if (calloutType == Callout.GET_EMPTY_SUBSCRIPTION_OK) {
            res.setBody('{' +
                '    "subscription": {' +
                '        "name": "Sample subscription",' +
                '        "paymentSchedule": {' +
                '            "interval": {' +
                '                "length": "12",' +
                '                "unit": "months"' +
                '            },' +
                '            "startDate": "2017-09-09",' +
                '            "totalOccurrences": "9999",' +
                '            "trialOccurrences": "1"' +
                '        },' +
                '        "amount": "10.29",' +
                '        "trialAmount": "1.00",' +
                '        "status": "active"' +
                '    },' +
                '    "refId": "123456",' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        } else if (calloutType == Callout.GET_SUBSCRIPTION_OK) {
            res.setBody('{' +
                '    "subscription": {' +
                '        "name": "Sample subscription",' +
                '        "paymentSchedule": {' +
                '            "interval": {' +
                '                "length": "12",' +
                '                "unit": "months"' +
                '            },' +
                '            "startDate": "2017-09-09",' +
                '            "totalOccurrences": "9999",' +
                '            "trialOccurrences": "1"' +
                '        },' +
                '        "amount": "10.29",' +
                '        "trialAmount": "1.00",' +
                '        "status": "active",' +
                '        "arbTransactions": [' +
                '            {' +
                '                "transId": "11111111111",' +
                '                "response": "This transaction has been approved.",' +
                '                "submitTimeUTC": "' + Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '",' +
                '                "payNum": "1",' +
                '                "attemptNum": "1"' +
                '            }' +
                '        ]' +
                '    },' +
                '    "refId": "123456",' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        } else if (calloutType == Callout.GET_TRANSACTION_DETAILS_OK) {
            res.setBody('{' +
                '    "transaction": {' +
                '        "customerIP": "0.0.0.0",' +
                '        "transId": "11111111111",' +
                '        "payment": {' +
                '            "creditCard": {' +
                '                "cardNumber": "XXXX1111",' +
                '                "expirationDate": "XXXX",' +
                '                "cardType": "Visa"' +
                '            }' +
                '        }' +
                '    },' +
                '    "messages": {' +
                '        "resultCode": "Ok",' +
                '        "message": [' +
                '            {' +
                '                "code": "I00001",' +
                '                "text": "Successful."' +
                '            }' +
                '        ]' +
                '    }' +
                '}');
        }
        
        return res;
    }
}