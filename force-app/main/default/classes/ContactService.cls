public without sharing class ContactService {

    @TestVisible
    public static Id contactId {
        get {
            if (contactId == null) {
                User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                contactId = currentUser.ContactId;
            }
            return contactId;
        }

        private set;
    }

    public static String createProfile(CreditCard creditCard, List<String> quoteIds) {
        if (UserInfo.getUserType() == 'Guest') {
            return createProfileForGuest(creditCard, quoteIds);
        } else {
            return createProfileForRegistredUser(creditCard, quoteIds);
        }
    }

    public static void linkCustomerProfileWithContact(Id contactId, List<Id> quoteIds) {
        List<Authorize_Net_Customer_Profile__c> customerProfiles = [
            SELECT Id, Contact__c
            FROM Authorize_Net_Customer_Profile__c
            WHERE Quote__c IN :quoteIds
        ];
        for (Authorize_Net_Customer_Profile__c customerProfile : customerProfiles) {
            customerProfile.Contact__c = contactId;
        }
        update customerProfiles;
    }

    public static CreditCard getAddress() {
        CreditCard creditCard = new CreditCard();
        if (contactId != null) {
            List<Contact> contacts = selectContacts(new Set<Id> {contactId});
            populateCreditCardAddress(creditCard, contacts.isEmpty() ? new Contact() : contacts.get(0));
        }
        return creditCard;
    }

    private static List<Contact> selectContacts(Set<Id> contactIds) {
        return [
            SELECT Id, MailingCity, MailingState, MailingStreet, MailingPostalCode, MailingCountry
            FROM Contact
            WHERE Id IN :contactIds
        ];
    }

    private static void populateCreditCardAddress(CreditCard creditCard, Contact contact) {
        creditCard.address1 = contact.MailingStreet;
        creditCard.zip = contact.MailingPostalCode;
        creditCard.country = contact.MailingCountry;
        creditCard.state = contact.MailingState;
        creditCard.city = contact.MailingCity;
    }
    @TestVisible
    private static String createProfileForGuest(CreditCard creditCard, List<String> quoteIds) {
        String paymentProfileId;
        List<Authorize_Net_Customer_Profile__c> profiles = getCustomerProfilesByQuote((Id) getFirstElement(quoteIds));
        if (profiles.isEmpty()) {
            AuthorizeNetClient.CustomerProfileResponse customerProfileResponse = createCustomerProfile(creditCard, quoteIds);
            if (customerProfileResponse.customerPaymentProfileIdList != null && !customerProfileResponse.customerPaymentProfileIdList.isEmpty()) {
                paymentProfileId = customerProfileResponse.customerPaymentProfileIdList.get(0);
                saveCustomerProfile(customerProfileResponse, contactId, quoteIds);
            } else {
                throw new ProfileException('An error occurred during profile creation');
            }
        } else {
            AuthorizeNetClient.CustomerPaymentProfileResponse response = createPaymentProfile(creditCard, profiles.get(0).Profile_Id__c);
            paymentProfileId = response.customerPaymentProfileId;
            savePaymentProfile(response, profiles.get(0).Id);
        }
        return paymentProfileId;
    }

    private static String createProfileForRegistredUser(CreditCard creditCard, List<String> quoteIds) {
        String paymentProfileId;
        if (contactId != null) {
            List<Authorize_Net_Customer_Profile__c> profiles = getCustomerProfiles();
            if (profiles.isEmpty()) {
                AuthorizeNetClient.CustomerProfileResponse customerProfileResponse = createCustomerProfile(creditCard, quoteIds);
                if (customerProfileResponse.customerPaymentProfileIdList != null && !customerProfileResponse.customerPaymentProfileIdList.isEmpty()) {
                    paymentProfileId = customerProfileResponse.customerPaymentProfileIdList.get(0);
                    saveCustomerProfile(customerProfileResponse, contactId, quoteIds);
                } else {
                    throw new ProfileException('An error occurred during profile creation');
                }
            } else {
                AuthorizeNetClient.CustomerPaymentProfileResponse response = createPaymentProfile(creditCard, profiles.get(0).Profile_Id__c);
                paymentProfileId = response.customerPaymentProfileId;
                savePaymentProfile(response, profiles.get(0).Id);
            }
        } else {
            throw new ProfileException('An error occurred during profile creation');
        }
        return paymentProfileId;
    }

    public static PaymentInfo getPaymentInfo(List<String> quoteIds) {
        //Prevent guest user get access to the profile information
        if(contactId == null){
            contactId = [SELECT Id,Contact__c from Quote__c WHERE Id IN: quoteIds LIMIT 1].Contact__c;
        }
        System.debug('contactId()--'+contactId);
        List<Authorize_Net_Customer_Profile__c> profiles = UserInfo.getUserType() == 'Guest' ? new List<Authorize_Net_Customer_Profile__c> () : getCustomerProfiles();
        system.debug('CA LOG profiles ------ ' + profiles);
        PaymentInfo paymentInfo = new PaymentInfo();
        List<Quote__c> quotes = selectQuotes(quoteIds);
        for (Quote__c quote : quotes) {
            if (quote.Term__c == 'Annual(One Year)' || quote.Term__c == 'Annual') {
                paymentInfo.isSubscriptionAvailable = true;
            }
        }
        paymentInfo.isGuest = UserInfo.getUserType() == 'Guest';
        if (profiles.isEmpty()) {
            return paymentInfo;
        }
        Authorize_Net_Customer_Profile__c profile = profiles.get(0);
        Set<String> paymentProfileIds = getPaymentProfileIds(profiles);
        system.debug('CA--profile -----: '+ profile);
        system.debug('CA LOG paymentProfileIds ----- '+ paymentProfileIds);
        AuthorizeNetClient.GetProfileResponse profileResponse = AuthorizeNetClient.sendGetCustomerProfileRequest(profile.Profile_Id__c);
        system.debug('Ca log profileResponse ----- '+ profileResponse);
        profileResponse.profile.paymentProfiles = profileResponse.profile.paymentProfiles == null ? new List<AuthorizeNetClient.PaymentProfileResponse>() : profileResponse.profile.paymentProfiles;
        system.debug('Ca log profileResponse 2 ----- '+ profileResponse);
        for (AuthorizeNetClient.PaymentProfileResponse paymentProfile : profileResponse.profile.paymentProfiles) {
            if (paymentProfileIds.contains(paymentProfile.customerPaymentProfileId)) {
                system.debug('Inside If Statement');
                paymentInfo.creditCards.add(buildCreditCard(paymentProfile));
            }
        }
        system.debug('paymentInfo ::: '+paymentInfo);
        return paymentInfo;
    }

    public static List<Quote__c> selectQuotes(List<String> quoteIds) {
        if (quoteIds == null || quoteIds.isEmpty()) {
            return null;
        }
        List<Quote__c> quotes = [
            SELECT Id, Account__c, Contact__c, Policy_Type_picklist__c, Quote_Value__c, Start_Date_for_Coverage__c, End_Date_for_Coverage__c, I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Term__c, Net_Premium__c
            FROM Quote__c WHERE Id IN :quoteIds
        ];
        return quotes;
    }

    public static Map<Id, Quote__c> selectQuotesMap(List<String> quoteIds) {
        if (quoteIds == null || quoteIds.isEmpty()) {
            return null;
        }
        Map<Id, Quote__c> quotesMap = new Map<Id, Quote__c> ([
            SELECT Id, Policy_Type_picklist__c, Quote_Value__c, Start_Date_for_Coverage__c, End_Date_for_Coverage__c, I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Term__c, Net_Premium__c
            FROM Quote__c WHERE Id IN :quoteIds
        ]);
        return quotesMap;
    }


    public static List<Authorize_Net_Customer_Profile__c> getCustomerProfilesByQuote(Id quoteId) {
        List<Authorize_Net_Customer_Profile__c> profiles = [
            SELECT Id, Profile_Id__c,
            (SELECT Id, Payment_Profile_Id__c FROM Authorize_Net_Payment_Profiles__r)
            FROM Authorize_Net_Customer_Profile__c
            WHERE Quote__c = :quoteId
        ];
        return profiles;
    }


    public static List<Authorize_Net_Customer_Profile__c> getCustomerProfiles() {
        System.debug('contactId---'+contactId);
        List<Authorize_Net_Customer_Profile__c> profiles = [
            SELECT Id, Profile_Id__c,
            (SELECT Id, Payment_Profile_Id__c FROM Authorize_Net_Payment_Profiles__r)
            FROM Authorize_Net_Customer_Profile__c
            WHERE Contact__c = :contactId
        ];
        return profiles;
    }

    public static AuthorizeNetClient.CreditCard buildCreditCard(CreditCard creditCardDto) {
        AuthorizeNetClient.CreditCard creditCard = new AuthorizeNetClient.CreditCard();
        creditCard.cardNumber = creditCardDto.cardNumber;
        creditCard.setExpirationDate(creditCardDto.year, creditCardDto.month);
        creditCard.cardCode = creditCardDto.code;
        return creditCard;
    }

    public static AuthorizeNetClient.BillTo buildBillTo(ContactService.CreditCard creditCard) {
        AuthorizeNetClient.BillTo billTo = new AuthorizeNetClient.BillTo();
        billTo.address = creditCard.getAddress();
        billTo.firstName = creditCard.getFirsName();
        billTo.lastName = creditCard.getLastName();
        billTo.city = creditCard.city;
        billTo.state = creditCard.state;
        billTo.country = creditCard.country;
        billTo.zip = creditCard.zip;
        return billTo;
    }

    private static void savePaymentProfile(AuthorizeNetClient.CustomerPaymentProfileResponse response, Id customerProfileId) {
        insert new Authorize_Net_Payment_Profile__c(
            Authorize_Net_Customer_Profile__c = customerProfileId,
            Payment_Profile_Id__c = response.customerPaymentProfileId
        );
    }

    private static AuthorizeNetClient.CustomerProfileResponse createCustomerProfile(CreditCard creditCard, List<String> quoteIds) {
        AuthorizeNetClient.CreateCustomerProfileRequest customerProfileRequest = new AuthorizeNetClient.CreateCustomerProfileRequest();
        if (UserInfo.getUserType() == 'Guest') {
            customerProfileRequest.profile.merchantCustomerId = (String) getFirstElement(quoteIds);
            customerProfileRequest.profile.description = creditCard.name;
            customerProfileRequest.profile.email = '';
        } else {
            customerProfileRequest.profile.description = UserInfo.getName();
            customerProfileRequest.profile.email = UserInfo.getUserEmail();
        }
        AuthorizeNetClient.PaymentProfile paymentProfile = new AuthorizeNetClient.PaymentProfile();
        paymentProfile.billTo = buildBillTo(creditCard);
        paymentProfile.payment.creditCard = buildCreditCard(creditCard);
        paymentProfile.customerType = 'individual';
        customerProfileRequest.profile.paymentProfiles.add(paymentProfile);
        AuthorizeNetClient.CustomerProfileResponse response = AuthorizeNetClient.sendCreateCustomerProfileRequest(customerProfileRequest);
        return response;
    }

    private static AuthorizeNetClient.CustomerPaymentProfileResponse createPaymentProfile(CreditCard creditCard, String customerProfileId) {
        AuthorizeNetClient.CreateCustomerPaymentProfileRequest customerPaymentProfileRequest = new AuthorizeNetClient.CreateCustomerPaymentProfileRequest();
        customerPaymentProfileRequest.customerProfileId = customerProfileId;
        AuthorizeNetClient.PaymentProfile paymentProfile = new AuthorizeNetClient.PaymentProfile();
        paymentProfile.billTo = buildBillTo(creditCard);
        paymentProfile.payment.creditCard = buildCreditCard(creditCard);
        paymentProfile.customerType = 'individual';
        customerPaymentProfileRequest.paymentProfile = paymentProfile;
        AuthorizeNetClient.CustomerPaymentProfileResponse response = AuthorizeNetClient.sendCreatePaymentProfileRequest(customerPaymentProfileRequest);
        return response;
    }

    public static Object getFirstElement(List<Object> values) {
        return values.isEmpty() ? null : values.get(0);
    }

    private static void saveCustomerProfile(AuthorizeNetClient.CustomerProfileResponse response, Id contactId, List<String> quoteIds) {
        Authorize_Net_Customer_Profile__c customerProfile = new Authorize_Net_Customer_Profile__c(
            Profile_Id__c = response.customerProfileId,
            Contact__c = contactId,
            Quote__c = (Id) getFirstElement(quoteIds)
        );
        insert customerProfile;
        List<Authorize_Net_Payment_Profile__c> paymentProfiles = new List<Authorize_Net_Payment_Profile__c>();
        for (String paymentProfileId : response.customerPaymentProfileIdList) {
            paymentProfiles.add(new Authorize_Net_Payment_Profile__c(
                Authorize_Net_Customer_Profile__c = customerProfile.Id,
                Payment_Profile_Id__c = paymentProfileId
            ));
        }
        insert paymentProfiles;
    }

    private static CreditCard buildCreditCard(AuthorizeNetClient.PaymentProfileResponse paymentProfile) {
        system.debug('PAyment Profile CA LOG ---- '+ paymentProfile);
        CreditCard creditCard = new CreditCard();
        creditCard.cardId = paymentProfile.customerPaymentProfileId;
        if (paymentProfile.billTo != null) {
            creditCard.name = paymentProfile.billTo.firstName + ' ' + paymentProfile.billTo.lastName;
            creditCard.address1 = paymentProfile.billTo.address;
            creditCard.city = paymentProfile.billTo.city;
            creditCard.state = paymentProfile.billTo.state;
            creditCard.zip = paymentProfile.billTo.zip;
            creditCard.country = paymentProfile.billTo.country;
        }
        if (paymentProfile.payment != null && paymentProfile.payment.creditCard != null) {
            creditCard.cardNumber = paymentProfile.payment.creditCard.cardNumber;
            creditCard.cardType = paymentProfile.payment.creditCard.cardType;
        }
        return creditCard;
    }

    private static Set<String> getPaymentProfileIds(List<Authorize_Net_Customer_Profile__c> profiles) {
        Set<String> paymentProfileIds = new Set<String>();
        for (Authorize_Net_Customer_Profile__c profile : profiles) {
            for (Authorize_Net_Payment_Profile__c paymentProfile : profile.Authorize_Net_Payment_Profiles__r) {
                paymentProfileIds.add(paymentProfile.Payment_Profile_Id__c);
            }
        }
        return paymentProfileIds;
    }

    public class PaymentInfo {
        public Boolean isSubscriptionAvailable;
        public List<CreditCard> creditCards;
        public String ip;
        public Boolean isGuest;

        public PaymentInfo() {
            creditCards = new List<CreditCard>();
            isSubscriptionAvailable = false;
        }
    }

    public class CreditCard {
        public String cardId;
        public String cardType;
        public String name;
        public String address1;
        public String address2;
        public String city;
        public String state;
        public String zip;
        public String email;
        public String country;
        public String cardNumber;
        public String month;
        public String year;
        public String code;
        public String quoteId;
        public String description;

        public String getAddress() {
            String address = '';
            address += String.isNotBlank(address1) ? address1 : '';
            address += String.isNotBlank(address2) ? ' ' + address2 : '';
            return address;
        }

        public String getFirsName() {
            return getNameComponents().get(0);
        }

        public String getLastName() {
            return getNameComponents().get(1);
        }

        private List<String> getNameComponents() {
            name = String.isNotBlank(name) ? name : '';
            List<String> names = new List<String>();
            names = name.split(' ');
            names.addAll(new List<String>{'', ''});
            return names;
        }
    }

    public class ProfileException extends Exception {}
}