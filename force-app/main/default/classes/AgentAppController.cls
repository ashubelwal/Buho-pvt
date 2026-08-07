public with sharing class AgentAppController {
    public class AgentAppControllerException extends Exception {
    }

    @AuraEnabled
    public static List<LeadWrapper> getDataByObj(String leadName, String userId) {
        List<User> userDetail = [
            SELECT Name, ContactId, User_Type__c
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];
        System.debug('leadName:::' + leadName);
        System.debug('userId:::' + userId);
        System.debug('userDetail:::' + userDetail);
        List<LeadWrapper> leadWrap = new List<LeadWrapper>();
        List<Lead> leadData = new List<Lead>();

        if (userDetail[0].User_Type__c == 'External') {
            if (leadName != null && leadName != '' && leadName != 'undefined') {
                leadData = [
                    SELECT
                        Id,
                        Name,
                        Company,
                        Status,
                        CreatedDate,
                        Email,
                        Agent__r.Name,
                        Agency__r.Name
                    FROM Lead
                    WHERE
                        Agency__c = :userDetail[0].contactId
                        AND (Name LIKE :('%' + leadName + '%')
                        OR Agent__r.Name LIKE :('%' + leadName + '%')
                        OR Agency__r.Name LIKE :('%' + leadName + '%'))
                        AND IsConverted = FALSE
                    ORDER BY CreatedDate DESC
                    LIMIT 50000
                ];
            } else {
                leadData = [
                    SELECT
                        Id,
                        Name,
                        Company,
                        Status,
                        CreatedDate,
                        Email,
                        Agent__r.Name,
                        Agency__r.Name
                    FROM Lead
                    WHERE Agency__c = :userDetail[0].contactId AND IsConverted = FALSE
                    ORDER BY CreatedDate DESC
                    LIMIT 50000
                ];
            }
            System.debug('INSIDE EXTERNAL:::' + leadData);
            for (Lead ldata : leadData) {
                LeadWrapper ld = new LeadWrapper();
                ld.Id = ldata.Id;
                ld.Name = ldata.Name;
                ld.Company = ldata.Company;
                ld.Status = ldata.Status;
                ld.CreatedDate = ldata.CreatedDate;
                ld.Email = ldata.Email;
                ld.Agent = ldata.Agent__r.Name;
                ld.Agency = ldata.Agency__r.Name;
                leadWrap.add(ld);
            }
        }

        if (userDetail[0].User_Type__c == 'Agency' || userDetail[0].User_Type__c == 'Internal') {
            if (leadName != null && leadName != '' && leadName != 'undefined') {
                leadData = [
                    SELECT
                        Id,
                        Name,
                        Company,
                        Status,
                        CreatedDate,
                        Email,
                        Agent__r.Name,
                        Agency__r.Name
                    FROM Lead
                    WHERE
                        Agency__c = :userDetail[0].contactId
                        AND (Name LIKE :('%' + leadName + '%')
                        OR Agent__r.Name LIKE :('%' + leadName + '%')
                        OR Agency__r.Name LIKE :('%' + leadName + '%'))
                        AND IsConverted = FALSE
                    ORDER BY CreatedDate DESC
                    LIMIT 50000
                ];
            } else {
                leadData = [
                    SELECT
                        Id,
                        Name,
                        Company,
                        Status,
                        CreatedDate,
                        Email,
                        Agent__r.Name,
                        Agency__r.Name
                    FROM Lead
                    WHERE Agency__c = :userDetail[0].contactId AND IsConverted = FALSE
                    ORDER BY CreatedDate DESC
                    LIMIT 50000
                ];
            }
            System.debug('INSIDE AGENCY:::' + leadData);
            for (Lead ldata : leadData) {
                LeadWrapper ld = new LeadWrapper();
                ld.Id = ldata.Id;
                ld.Name = ldata.Name;
                ld.Company = ldata.Company;
                ld.Status = ldata.Status;
                ld.CreatedDate = ldata.CreatedDate;
                ld.Email = ldata.Email;
                ld.Agent = ldata.Agent__r.Name;
                ld.Agency = ldata.Agency__r.Name;
                leadWrap.add(ld);
            }
        }

        System.debug('leadWrap:::' + leadWrap);
        return leadWrap;
    }

    @AuraEnabled
    public static String saveLeadDetails(
        String leadJson,
        String quoteJSON,
        String vehicleJSON,
        String towedlistJSON
    ) {
        try {
            // Business logic runs in AgentAppBaseService (without sharing) so that
            // portal users can upsert Lead records regardless of OWD settings.
            return AgentAppBaseService.saveLeadDetails(
                leadJson,
                quoteJSON,
                vehicleJSON,
                towedlistJSON
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String purchaseSaveDetails(String quotes, String leadId, Boolean PolicyFromLead) {
        try {
            return AgentAppBaseService.purchaseSaveDetails(quotes, leadId, PolicyFromLead);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean saveInfoBeforePayment(
        String leadId,
        String quotedata,
        String vehicleData,
        String termsAndAlerts,
        String driverDetails,
        String termOptions,
        String towedDetails
    ) {
        try {
            return AgentAppBaseService.saveInfoBeforePayment(
                leadId,
                quotedata,
                vehicleData,
                termsAndAlerts,
                driverDetails,
                termOptions,
                towedDetails
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' line number -' + e.getLineNumber());
        }
    }

    @AuraEnabled
    public static Boolean saveLeadDestinationInfoBeforePayment(
        String leadId,
        String termsAndAlerts
    ) {
        try {
            return AgentAppBaseService.saveLeadDestinationInfoBeforePayment(leadId, termsAndAlerts);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' line number -' + e.getLineNumber());
        }
    }

    @AuraEnabled
    public static String updateContactDestinationDetails(String contactId, String termsAlert) {
        if (contactId != null) {
            try {
                Contact con = new Contact();
                con.Id = contactId;
                con.Terms_Alert__c = termsAlert;
                update con;
                return 'success';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return 'Error';
        }
    }

    @AuraEnabled
    public static Map<String, Object> paymentThroughCard(
        String transactionDetails,
        String paymentDetails,
        String email
    ) {
        try {
            return PaymentFormController.createTransaction(
                paymentDetails,
                transactionDetails,
                email
            );
        } catch (AuraHandledException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createPolicy(
        String leadId,
        Boolean needPortalAccess,
        Boolean isCardPayment
    ) {
        return AgentAppBaseService.createPolicy(leadId, needPortalAccess, isCardPayment);
    }

    @AuraEnabled
    public static String createPolicyFromContact(
        String contactId,
        Boolean needPortalAccess,
        Boolean isCardPayment
    ) {
        return AgentAppBaseService.createPolicyFromContact(
            contactId,
            needPortalAccess,
            isCardPayment
        );
    }

    @AuraEnabled
    public static Map<String, Object> updatePolicyDetails(
        String quoteData,
        String DriverData,
        String vehicleData,
        String towedUnitData
    ) {
        return AgentAppBaseService.updatePolicyDetails(
            quoteData,
            DriverData,
            vehicleData,
            towedUnitData
        );
    }

    @AuraEnabled
    public static Map<String, String> createNewEditPolicy(
        String vehicleData,
        String DriverData,
        String towedUnitData,
        String quoteId,
        String oldPolicyId,
        Boolean isRenewal
    ) {
        return AgentAppBaseService.createNewEditPolicy(
            vehicleData,
            DriverData,
            towedUnitData,
            quoteId,
            oldPolicyId,
            isRenewal
        );
    }

    @AuraEnabled(cacheable=true)
    public static String getExternalIp() {
        return Auth.SessionManagement.getCurrentSession().get('SourceIp');
    }

    // Search details from Lead, Quote, Contact and Policy
    @AuraEnabled
    public static String searchDetails(String searchKey, String agencyId) {
        Map<String, String> allSearchData = new Map<String, String>();
        try {
            String searchKeyWord = '%' + searchKey + '%';
            List<Lead> leadData = new List<Lead>();
            List<Quote__c> quoteData = new List<Quote__c>();
            List<Policy__c> policyData = new List<Policy__c>();
            List<Contact> contactData = new List<Contact>();
            List<Contact> contactAgencyData = new List<Contact>();
            System.debug('searchKey::' + searchKey);
            System.debug('agencyId::' + agencyId);

            if (agencyId != null && agencyId != '') {
                System.debug('INSIDE IFFF::');
                leadData = [
                    SELECT Id, Name, Phone, Email, IsConverted
                    FROM Lead
                    WHERE
                        (Name LIKE :searchKeyWord
                        OR Email LIKE :searchKeyWord)
                        AND IsConverted = FALSE
                        AND (Agency__c = :agencyId
                        OR Agent__c = :agencyId)
                ];

                quoteData = [
                    SELECT
                        Id,
                        Name,
                        Vehicle_Type__c,
                        Vehicle_Year__c,
                        Vehicle_Make__c,
                        Vehicle_Model__c,
                        Vehicle_Value__c,
                        Coverage__c,
                        Term__c,
                        Term_Days__c,
                        Quote_Value__c,
                        Account__c,
                        Lead__c,
                        Annual_Term__c,
                        Any_Boat_Operator_Under_22__c,
                        Broker_Policy_Fee__c,
                        Contact__c,
                        Date_of_Birth__c,
                        Driver_Age__c,
                        End_Date_for_Coverage__c,
                        End_Time__c,
                        I_V_A_Mex_Tax__c,
                        Is_the_Maximum_Speed_more_than_50_mph__c,
                        Is_the_owner_living_in_Mexico__c,
                        Is_there_a_driver_over_75__c,
                        Is_there_a_driver_under_21__c,
                        Is_this_a_Rental_Vehicle__c,
                        Liability_Coverage__c,
                        Liability__c,
                        Medical_Coverage__c,
                        Medical__c,
                        Net_Premium__c,
                        Policy_Type__c,
                        Policy_Type_picklist__c,
                        Policy__c,
                        Property_Damage_Liability__c,
                        Quote_Status__c,
                        Salvage_Vehicle__c,
                        Start_Date_for_Coverage__c,
                        Start_Time__c,
                        Territory_Coverage__c,
                        Territory__c,
                        Time_Zone__c,
                        Towed_Unit__c,
                        Trailering__c,
                        Type_of_Vessel__c,
                        Underwriter__c,
                        Vehicle_Age__c,
                        Vehicle_Make_WS__c,
                        Vehicle_Year_WS__c,
                        Vehicle_used_for_Business_Purposes__c,
                        Vessel_Length__c,
                        Vehicle_Sub_type__c,
                        Renew_Quote__c,
                        Surcharge__c,
                        Third_Party_Bodily_Injury__c,
                        Vehicle_Deductible_Collision__c,
                        Vehicle_Deductible_Comprehensive__c,
                        Vehicle__c,
                        Policy_Fee__c,
                        Lead_Id__c,
                        Physical_Damage__c,
                        Total_Theft_Payment__c,
                        Liability_Payment__c,
                        Medical_Payment__c,
                        Platinum_Endorsment__c,
                        QuotePdfJson__c
                    FROM Quote__c
                    WHERE
                        (Name LIKE :searchKeyWord
                        OR Lead__r.Email LIKE :searchKeyWord
                        OR Id = :searchKey)
                        AND Term_Days__c != NULL
                        AND (Contact__r.Agency__c = :agencyId
                        OR Contact__r.Agent__c = :agencyId)
                ];

                contactData = [
                    SELECT Id, Name, Phone, Email, (SELECT Id, Username FROM Users)
                    FROM Contact
                    WHERE
                        (Name LIKE :searchKeyWord
                        OR Email LIKE :searchKeyWord
                        OR Phone LIKE :searchKeyWord)
                        AND (Agency__c = :agencyId
                        OR Agent__c = :agencyId)
                ];

                policyData = [
                    SELECT
                        Id,
                        Name,
                        Contact_Email__c,
                        Policy_Type_picklist__c,
                        Status_picklist__c,
                        Term_days__c,
                        Term__c,
                        Contact__c,
                        Quote_c__c,
                        Start_Date__c,
                        Start_Time__c,
                        End_Date__c,
                        Issued_At__c,
                        Contact__r.Email
                    FROM Policy__c
                    WHERE
                        (Name LIKE :searchKeyWord
                        OR Contact_Email__c LIKE :searchKeyWord
                        OR Contact__r.Name LIKE :searchKeyWord
                        OR Contact__r.Email LIKE :searchKeyWord)
                        AND Status_picklist__c != 'Updated'
                        AND (Contact__r.Agency__c = :agencyId
                        OR Contact__r.Agent__c = :agencyId)
                ];

                contactAgencyData = [
                    SELECT Id, Name, Phone, Email
                    FROM Contact
                    WHERE
                        Email = :searchKeyWord
                        AND Agency__c != :agencyId
                        AND Agent__c != :agencyId
                ];
            } else {
                System.debug('INSDIE ELSEE::');
                leadData = [
                    SELECT Id, Name, Phone, Email, IsConverted
                    FROM Lead
                    WHERE
                        (Name LIKE :searchKeyWord
                        OR Email LIKE :searchKeyWord)
                        AND IsConverted = FALSE
                ];

                quoteData = [
                    SELECT
                        Id,
                        Name,
                        Vehicle_Type__c,
                        Vehicle_Year__c,
                        Vehicle_Make__c,
                        Vehicle_Model__c,
                        Vehicle_Value__c,
                        Coverage__c,
                        Term__c,
                        Term_Days__c,
                        Quote_Value__c,
                        Account__c,
                        Lead__c,
                        Annual_Term__c,
                        Any_Boat_Operator_Under_22__c,
                        Broker_Policy_Fee__c,
                        Contact__c,
                        Date_of_Birth__c,
                        Driver_Age__c,
                        End_Date_for_Coverage__c,
                        End_Time__c,
                        I_V_A_Mex_Tax__c,
                        Is_the_Maximum_Speed_more_than_50_mph__c,
                        Is_the_owner_living_in_Mexico__c,
                        Is_there_a_driver_over_75__c,
                        Is_there_a_driver_under_21__c,
                        Is_this_a_Rental_Vehicle__c,
                        Liability_Coverage__c,
                        Liability__c,
                        Medical_Coverage__c,
                        Medical__c,
                        Net_Premium__c,
                        Policy_Type__c,
                        Policy_Type_picklist__c,
                        Policy__c,
                        Property_Damage_Liability__c,
                        Quote_Status__c,
                        Salvage_Vehicle__c,
                        Start_Date_for_Coverage__c,
                        Start_Time__c,
                        Territory_Coverage__c,
                        Territory__c,
                        Time_Zone__c,
                        Towed_Unit__c,
                        Trailering__c,
                        Type_of_Vessel__c,
                        Underwriter__c,
                        Vehicle_Age__c,
                        Vehicle_Make_WS__c,
                        Vehicle_Year_WS__c,
                        Vehicle_used_for_Business_Purposes__c,
                        Vessel_Length__c,
                        Vehicle_Sub_type__c,
                        Renew_Quote__c,
                        Surcharge__c,
                        Third_Party_Bodily_Injury__c,
                        Vehicle_Deductible_Collision__c,
                        Vehicle_Deductible_Comprehensive__c,
                        Vehicle__c,
                        Policy_Fee__c,
                        Lead_Id__c,
                        Physical_Damage__c,
                        Total_Theft_Payment__c,
                        Liability_Payment__c,
                        Medical_Payment__c,
                        Platinum_Endorsment__c,
                        QuotePdfJson__c
                    FROM Quote__c
                    WHERE
                        (Name LIKE :searchKeyWord
                        OR Lead__r.Email LIKE :searchKeyWord
                        OR Id = :searchKey)
                        AND Term_Days__c != NULL
                ];

                contactData = [
                    SELECT Id, Name, Phone, Email, (SELECT Id, Username FROM Users)
                    FROM Contact
                    WHERE
                        Name LIKE :searchKeyWord
                        OR Email LIKE :searchKeyWord
                        OR Phone LIKE :searchKeyWord
                ];

                policyData = [
                    SELECT
                        Id,
                        Name,
                        Contact_Email__c,
                        Policy_Type_picklist__c,
                        Status_picklist__c,
                        Term_days__c,
                        Term__c,
                        Contact__c,
                        Quote_c__c,
                        Start_Date__c,
                        Start_Time__c,
                        End_Date__c,
                        Issued_At__c,
                        Contact__r.Email
                    FROM Policy__c
                    WHERE
                        (Name LIKE :searchKeyWord
                        OR Contact_Email__c LIKE :searchKeyWord
                        OR Contact__r.Name LIKE :searchKeyWord
                        OR Contact__r.Email LIKE :searchKeyWord)
                        AND Status_picklist__c != 'Updated'
                ];
            }

            System.debug('contactAgencyData::' + contactAgencyData);
            allSearchData.put('Lead', JSON.serialize(leadData));
            allSearchData.put('Quote', JSON.serialize(quoteData));
            allSearchData.put('Contact', JSON.serialize(contactData));
            allSearchData.put('Policy', JSON.serialize(policyData));
            allSearchData.put('contactAgencyData', JSON.serialize(contactAgencyData));

            return JSON.serialize(allSearchData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String fetchExistingLead(String email, String leadId) {
        String existData = '';
        String query =
            'SELECT Id, ConvertedContactId, LastName, FirstName, Name, Company, Street, City, State, PostalCode, Country, Address, Phone, Email, City__c, Full_Name__c,' +
            'Vehicle_Type__c, Vehicle_Value__c, Term__c, Policy_Type__c, Start_Date_for_Coverage__c,' +
            'Coverage__c, Territory_Options__c, Liability_Coverage__c, Medical_Coverage__c, Vehicle_will_be_used_for_business_purpos__c,' +
            'End_Date_for_Coverage__c, State__c, Model__c, Make__c, Year_A__c, Year__c, Zip_Code__c, Quote_Term__c,' +
            'Quote_Value__c, Quote_Vehicle_Make__c, Quote_Vehicle_Model__c, Quote_Vehicle_Type__c, Quote_Vehicle_Value__c, Quote_Vehicle_Year__c,' +
            'Date_of_Birth__c, Vehicle_details__c, Term_days__c, Is_towing__c, Days_in_tow__c, Towing__c,' +
            'Underwriter_picklist__c, Review_vehicle__c, Company_details__c, Lienholder_info__c, Country__c, Driver_details__c, Terms_Alert__c,' +
            'Vehicle_sub_type__c, Term_options__c, Quote_Details__c, Watercraft_Detail__c, Liability__c, Agency__c, Agent__c,' +
            '(SELECT Id, OwnerId, Name, Vehicle_Type__c, Vehicle_Year__c, Vehicle_Make__c, Vehicle_Model__c,' +
            'Vehicle_Value__c, Coverage__c, Term__c, Term_Days__c, Quote_Value__c, Account__c, Lead__c, Annual_Term__c, Any_Boat_Operator_Under_22__c, Broker_Policy_Fee__c, Contact__c, Date_of_Birth__c, Driver_Age__c,' +
            'End_Date_for_Coverage__c, End_Time__c, I_V_A_Mex_Tax__c, Is_the_Maximum_Speed_more_than_50_mph__c, Is_the_owner_living_in_Mexico__c, Is_there_a_driver_over_75__c, Is_there_a_driver_under_21__c,' +
            'Is_this_a_Rental_Vehicle__c, Liability_Coverage__c, Liability__c, Medical_Coverage__c, Medical__c, Net_Premium__c, Policy_Type__c, Policy_Type_picklist__c, Policy__c, Property_Damage_Liability__c,' +
            'Quote_Status__c, Salvage_Vehicle__c, Start_Date_for_Coverage__c, Start_Time__c, Territory_Coverage__c, Territory__c, Time_Zone__c, Towed_Unit__c, Trailering__c, Type_of_Vessel__c, Underwriter__c,' +
            'Vehicle_Age__c, Vehicle_Make_WS__c, Vehicle_Year_WS__c, Vehicle_used_for_Business_Purposes__c, Vessel_Length__c, Vehicle_Sub_type__c, Renew_Quote__c, Surcharge__c, Third_Party_Bodily_Injury__c,' +
            'Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Vehicle__c, Policy_Fee__c, Lead_Id__c, Physical_Damage__c, Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c,' +
            'Platinum_Endorsment__c, QuotePdfJson__c, Old_Net_Premium__c, Agent_Fee__c FROM Quotes__r) FROM Lead';

        try {
            if (!String.isBlank(email)) {
                query += ' WHERE Email = :email LIMIT 1';
            }
            if (!String.isBlank(leadId)) {
                query += ' WHERE Id = :leadId LIMIT 1';
            }
            Lead[] results = Database.query(query);
            if (!results.isEmpty()) {
                existData = JSON.serialize(results[0]);
                System.debug('existData@@###' + existData);
            }
            return existData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Get contact details by ID
    @AuraEnabled
    public static String fetchContactDetails(String contactId) {
        if (contactId != null) {
            try {
                Contact[] contactDetails = [
                    SELECT
                        Id,
                        Name,
                        LastName,
                        FirstName,
                        Phone,
                        Email,
                        CreatedDate,
                        LastModifiedDate,
                        Country__c,
                        City__c,
                        State__c,
                        Street__c,
                        Term_options__c,
                        Driver_details__c,
                        Terms_Alert__c,
                        Towing__c,
                        Watercraft_Detail__c,
                        Vehicle_details__c,
                        Quote_Details__c,
                        Agent_Fee__c,
                        Old_Net_Premium__c,
                        (
                            SELECT
                                Id,
                                Name,
                                Contact_Email__c,
                                Policy_type_picklist__c,
                                Status_picklist__c,
                                Term_days__c,
                                Term__c,
                                Start_Date__c,
                                Start_Time__c,
                                Issued_At__c,
                                Agent_Brokerage_Fee__c
                            FROM Policies__r
                            WHERE Status_picklist__c != 'Updated'
                        ),
                        (
                            SELECT
                                Id,
                                Name,
                                Contact__c,
                                Lead__c,
                                Policy_Type_picklist__c,
                                Term_Days__c,
                                Start_Date_for_Coverage__c,
                                End_Date_for_Coverage__c
                            FROM Quotes__r
                        ),
                        (
                            SELECT
                                Name,
                                Id,
                                license_number__c,
                                License_Country__c,
                                License_state__c,
                                City__c
                            FROM Drivers__r
                        ),
                        (
                            SELECT Name, Id, Vin__c, Make__c, Model__c, Lienholder_name__c
                            FROM Vehicle__r
                        )
                    FROM Contact
                    WHERE Id = :contactId
                ];

                if (contactDetails.size() < 1) {
                    Contact con = new Contact();
                    Lead leadData = [
                        SELECT LastName, FirstName, Phone, Email
                        FROM Lead
                        WHERE ConvertedContactId = :contactId
                    ];
                    con.FirstName = leadData.FirstName;
                    con.LastName = leadData.LastName;
                    con.Phone = leadData.Phone;
                    con.Email = leadData.Email;
                    contactDetails.add(con);
                }
                return JSON.serialize(contactDetails);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return 'Error';
        }
    }

    @AuraEnabled
    public static String updateContactRecord(Contact contactRecord) {
        try {
            System.debug('@@@@' + contactRecord);
            update contactRecord;
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Update contact details by ID
    // legacy method need to be removed after testing
    @AuraEnabled
    public static String updateContactDetails(
        Boolean Istowing,
        String contactId,
        String termOptions,
        String driverDetails,
        String termsAlert,
        String towedlistJSON,
        String WatercraftDetails,
        String vehicledetails,
        String quoteDetails
    ) {
        if (contactId != null) {
            try {
                Contact con = new Contact();
                con.Id = contactId;
                con.Is_towing__c = Istowing;
                con.Quote_Details__c = quoteDetails;
                con.Term_options__c = termOptions;
                con.Driver_details__c = driverDetails;
                con.Terms_Alert__c = termsAlert;
                con.Watercraft_Detail__c = WatercraftDetails;
                con.Vehicle_Details__c = vehicledetails;
                con.Towing__c = towedlistJSON;
                update con;
                return 'success';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return 'Error';
        }
    }

    @AuraEnabled
    public static String mapAffiliateOnContact(String contactId, String affiliateId) {
        if (String.isNotBlank(contactId) && String.isNotBlank(affiliateId)) {
            try {
                Contact con = new Contact(Id = contactId, Affiliate__c = affiliateId);
                update con;
                return 'success';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return 'Error';
    }

    @AuraEnabled
    public static User portalAccessForUser(String username) {
        List<User> userList = [SELECT Id, Name, IsActive FROM User WHERE Email = :username LIMIT 1];
        if (userList != null && !userList.isEmpty()) {
            return userList[0];
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String insertContactsFeature(String contactDetails) {
        try {
            String resultId = '';
            List<Contact> contactList = new List<Contact>();
            Contact contact = (Contact) JSON.deserialize(contactDetails, Contact.class);
            contact.Source__c = 'DMV Service';
            if (contact.Email != null) {
                contactList = [SELECT Id, Name FROM Contact WHERE Email = :contact.Email LIMIT 1];
            }
            if (contactList.size() > 0) {
                return 'False';
            }
            insert contact;
            resultId = contact.Id;
            return resultId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createUserForContact(String contactId) {
        try {
            System.debug('contactId' + contactId);
            if (contactId != null) {
                Id AccountId;
                Contact con = [
                    SELECT Id, Name, Email, FirstName, LastName, Phone
                    FROM Contact
                    WHERE Id = :contactId
                    LIMIT 1
                ];
                List<Account> acc = [
                    SELECT Id, Name, Email__c
                    FROM Account
                    WHERE Email__c = :con.Email
                    LIMIT 1
                ];
                System.debug('con' + con);
                System.debug('acc' + acc);
                if (acc.size() < 1) {
                    Account dupAc = new Account();
                    dupAc.Name = con.Name;
                    dupAc.Email__c = con.Email;
                    Database.insert(dupAc);
                    con.AccountId = dupAc.Id;
                    Database.update(con);
                    AccountId = dupAc.Id;
                } else {
                    AccountId = acc[0].Id;
                }
                Profile portalProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = 'Mex Insurance Customer Community Plus Login User'
                    LIMIT 1
                ];
                System.debug('portalProfile' + portalProfile);
                String userFName = con.FirstName.substring(0, 1);
                String userLName = con.LastName.length() >= 3
                    ? con.LastName.substring(0, 3)
                    : con.LastName;
                User newUser = new User(
                    Username = con.Email,
                    Email = con.Email,
                    LastName = con.LastName,
                    FirstName = con.FirstName != null ? con.FirstName : '',
                    Phone = con.Phone != null ? con.Phone : '',
                    Alias = (con.FirstName != null &&
                        con.LastName != null)
                        ? userFName + ' ' + userLName
                        : (con.FirstName == null && con.LastName != null) ? userLName : '',
                    ContactId = con.Id,
                    ProfileId = portalProfile.Id,
                    EmailEncodingKey = 'UTF-8',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
                );
                Database.insert(newUser);
            }
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage() + ' at line no :' + e.getLineNumber());
            return 'Error : ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static String updateContactEmail(String email, String contactId) {
        try {
            List<Contact> existContact = [
                SELECT Id, Name
                FROM Contact
                WHERE Email = :email
                LIMIT 50000
            ];
            if (existContact.size() < 1) {
                Contact con = new Contact();
                con.Id = contactId;
                con.Email = email;
                update con;
                return 'Success';
            } else {
                return 'Error This email already exist in another contact';
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage() + ' at line no :' + e.getLineNumber());
            return 'Error : ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static String getDriverData(String contactId) {
        try {
            if (contactId != null) {
                List<Driver__c> driverList = [
                    SELECT
                        Id,
                        Name,
                        First_Name__c,
                        Last_Name__c,
                        license_number__c,
                        License_Country__c,
                        License_state__c,
                        Dob__c,
                        Driver_Type__c,
                        Country__c,
                        Postal_Code__c,
                        State_Province__c,
                        City__c,
                        Address__c,
                        Phone__c
                    FROM Driver__c
                    WHERE Contact__c = :contactId
                ];
                if (driverList.size() > 0) {
                    return JSON.serialize(driverList);
                }
            }
            return null;
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage() + ' at line number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getVehicleData(String vehicleId) {
        try {
            List<Vehicle__c> vehicles = new List<Vehicle__c>();
            if (vehicleId != null) {
                vehicles = [
                    SELECT
                        Id,
                        Name,
                        Vin__c,
                        Is_vehicle_owned_by_a_company_or_rented__c,
                        Make__c,
                        Model__c,
                        Year__c,
                        Value__c,
                        Vehicle_Type__c,
                        Salvage_Vehicle__c,
                        Registered_Country__c,
                        Registered_Plate__c,
                        Registered_State__c,
                        Vehicle_Owner_Driver_License_State__c,
                        Is_there_a_driver_under_21__c,
                        Is_the_vehicle_used_for_business_purpose__c,
                        Is_the_vehicle_registered_to_a_business__c
                    FROM Vehicle__c
                    WHERE Contact__c = :vehicleId
                ];
            }
            return JSON.serialize(vehicles);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> createCloneQuote(String quote) {
        return AgentAppBaseService.createCloneQuote(quote);
    }

    @AuraEnabled
    public static void updateQuoteTime(String quoteDataUpdate, String quoteId) {
        try {
            System.debug('updateQuoteTime----quoteDataUpdate' + quoteDataUpdate);
            if (!String.isEmpty(quoteDataUpdate)) {
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(
                    quoteDataUpdate
                );
                String startTime = (String) jsonMap.get('Start_Time__c') + 'Z';
                String endTime = (String) jsonMap.get('End_Time__c') + 'Z';
                jsonMap.put('Start_Time__c', startTime);
                jsonMap.put('End_Time__c', endTime);
                System.debug('jsonMap:---->' + jsonMap);
                Quote__c quoteRecord = (Quote__c) JSON.deserialize(
                    JSON.serialize(jsonMap),
                    Quote__c.class
                );
                quoteRecord.Id = quoteId;
                System.debug('updateQuoteTime----quoteRecord' + quoteRecord);
                update quoteRecord;
            }
        } catch (Exception e) {
            System.debug('Error :' + e.getMessage() + 'at line number : ' + e.getLineNumber());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Contact getLoggedInContactData(String UserId) {
        User currentUser = [SELECT ContactId, Email FROM User WHERE Id = :UserId LIMIT 1];
        if (currentUser.ContactId != null) {
            return [
                SELECT Id, FirstName, LastName, Email, Agent__c, Agency__c
                FROM Contact
                WHERE Id = :currentUser.ContactId
                LIMIT 1
            ];
        } else {
            return [
                SELECT Id, FirstName, LastName, Email, Agent__c, Agency__c
                FROM Contact
                WHERE Id = :currentUser.Email
                LIMIT 1
            ];
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getUserInfo() {
        try {
            List<User> userList = [
                SELECT Id, User_Type__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            if (userList != null && !userList.isEmpty()) {
                return JSON.serialize(userList[0]);
            }
            return 'User List is Empty';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getVendorInfo() {
        try {
            List<User> userList = [
                SELECT Id, ContactId, Email, User_Type__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            if (userList != null && userList[0].ContactId != null) {
                List<Contact> agentContact = [
                    SELECT Id, Agency__c, Vendors__c
                    FROM Contact
                    WHERE Id = :userList[0].ContactId
                ];
                if (agentContact.size() > 0 && agentContact[0].Agency__c != null) {
                    List<Contact> contactList = [
                        SELECT Id, Vendors__c
                        FROM Contact
                        WHERE Id = :agentContact[0].Agency__c
                    ];
                    if (contactList != null) {
                        if (contactList[0].Vendors__c != null) {
                            return JSON.serialize(contactList[0].Vendors__c);
                        }
                        return 'true';
                    }
                    return 'true';
                }
                if (agentContact.size() > 0 && agentContact[0].Agency__c == null) {
                    if (agentContact[0].Vendors__c != null) {
                        return JSON.serialize(agentContact[0].Vendors__c);
                    }
                    return 'true';
                }
                return 'true';
            }
            return 'true';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String returnAccessToken() {
        Salesforce_Api__mdt metadataRecord = [
            SELECT
                DeveloperName,
                Consumer_Key__c,
                Consumer_Secret__c,
                Label,
                Password__c,
                Token__c,
                URL__c,
                Username__c
            FROM Salesforce_Api__mdt
            WHERE DeveloperName = :'Fetch_data_from_salesforce'
            LIMIT 1
        ];

        String accessToken = '';
        String url = metadataRecord.URL__c;
        String username = metadataRecord.Username__c;
        String password =
            String.valueOf(metadataRecord.Password__c) + String.valueOf(metadataRecord.Token__c);
        String clientId = metadataRecord.Consumer_Key__c;
        String clientSecret = metadataRecord.Consumer_Secret__c;

        String requestBody =
            'grant_type=password' +
            '&client_id=' +
            EncodingUtil.urlEncode(clientId, 'UTF-8') +
            '&client_secret=' +
            EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
            '&username=' +
            EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' +
            EncodingUtil.urlEncode(password, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(requestBody);

        HttpResponse response = new Http().send(req);
        System.debug('response::::' + response);

        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
                response.getBody()
            );
            accessToken = (String) responseMap.get('access_token');
            System.debug('Access Token: ' + accessToken);
            return accessToken;
        } else {
            System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            return 'Error for token: ' + response.getStatus();
        }
    }

    @AuraEnabled
    public static Salesforce_Api__mdt getCustomMetadataForApi(String developerName) {
        return [
            SELECT
                DeveloperName,
                Consumer_Key__c,
                Consumer_Secret__c,
                Label,
                Password__c,
                Token__c,
                URL__c,
                Username__c,
                Endpoint_Url__c
            FROM Salesforce_Api__mdt
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPolicyDataforPieChart(
        String policyTerm,
        String userId
    ) {
        if (String.isBlank(userId)) {
            throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
        }
        List<String> policyTypes = new List<String>{
            'Automobile',
            'RV',
            'Motorcycle/Street Legal ATV'
        };
        User userRecord = [SELECT Id, Profile.Name, ContactId FROM User WHERE Id = :userId LIMIT 1];
        System.debug('userRecord:::' + userRecord);
        String filterField = userRecord.Profile.Name == 'Agency Community Plus Login User'
            ? 'Agency__c'
            : 'Agent__c';
        String contactId = userRecord.ContactId;
        String query;

        if (String.isBlank(policyTerm)) {
            query =
                'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount ' +
                'FROM Policy__c ' +
                'WHERE ' +
                filterField +
                ' = :contactId AND Policy_Type_picklist__c IN: policyTypes ' +
                'GROUP BY Policy_Type_picklist__c, renewed_check__c';
        } else {
            query =
                'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount ' +
                'FROM Policy__c ' +
                'WHERE ' +
                filterField +
                ' = :contactId AND Policy_Type_picklist__c IN: policyTypes AND CreatedDate = ' +
                policyTerm +
                ' GROUP BY Policy_Type_picklist__c, renewed_check__c';
        }
        System.debug('query:::' + query);

        List<AggregateResult> aggregateResults = Database.query(query);
        List<Map<String, Object>> policyData = new List<Map<String, Object>>();
        for (AggregateResult result : aggregateResults) {
            policyData.add(
                new Map<String, Object>{
                    'Policy_Type_picklist__c' => result.get('Policy_Type_picklist__c'),
                    'renewed_check__c' => result.get('renewed_check__c'),
                    'totalCount' => (Integer) result.get('totalCount')
                }
            );
        }
        System.debug('policyData:::' + policyData);
        return policyData;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPolicyDataforBarChart(
        String policyTerm,
        String userId
    ) {
        if (String.isBlank(userId)) {
            throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
        }
        List<String> policyTypes = new List<String>{
            'Automobile',
            'RV',
            'Motorcycle/Street Legal ATV'
        };
        User userRecord = [SELECT Id, Profile.Name, ContactId FROM User WHERE Id = :userId LIMIT 1];
        Contact contactData = new Contact();
        String contactId = userRecord.ContactId;
        String query;

        if (contactId != null) {
            contactData = [
                SELECT
                    Id,
                    Name,
                    Commission_Mex_Auto_Renew__c,
                    Commission_Mex_Auto_New__c,
                    Commission_Mex_Moto_New__c,
                    Commission_Mex_Moto_Renew__c,
                    Commission_Mex_RV_New__c,
                    Commission_Mex_RV_Renew__c
                FROM Contact
                WHERE Id = :contactId
            ];
        }

        if (String.isBlank(policyTerm)) {
            query =
                'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount, SUM(Total_Transaction_Amount__c) totalAmount ' +
                'FROM Policy__c ' +
                'WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN: policyTypes ' +
                'GROUP BY Policy_Type_picklist__c, renewed_check__c';
        } else {
            query =
                'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount, SUM(Total_Transaction_Amount__c) totalAmount ' +
                'FROM Policy__c ' +
                'WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN: policyTypes AND CreatedDate = ' +
                policyTerm +
                ' GROUP BY Policy_Type_picklist__c, renewed_check__c';
        }
        System.debug('query:::' + query);

        List<AggregateResult> aggregateResults = Database.query(query);
        List<Map<String, Object>> policyData = new List<Map<String, Object>>();

        Map<String, Map<Boolean, String>> policyTypeMappings = new Map<String, Map<Boolean, String>>{
            'Automobile' => new Map<Boolean, String>{
                false => 'Commission_Mex_Auto_New__c',
                true => 'Commission_Mex_Auto_Renew__c'
            },
            'Motorcycle/Street Legal ATV' => new Map<Boolean, String>{
                false => 'Commission_Mex_Moto_New__c',
                true => 'Commission_Mex_Moto_Renew__c'
            },
            'RV' => new Map<Boolean, String>{
                false => 'Commission_Mex_RV_New__c',
                true => 'Commission_Mex_RV_Renew__c'
            }
        };

        for (AggregateResult result : aggregateResults) {
            String policyType = (String) result.get('Policy_Type_picklist__c');
            Boolean isRenewed = (Boolean) result.get('renewed_check__c');
            Decimal totalAmountValue = (Decimal) result.get('totalAmount');

            if (policyTypeMappings.containsKey(policyType)) {
                String commissionField = policyTypeMappings.get(policyType).get(isRenewed);
                if (!String.isBlank(commissionField) && contactData.get(commissionField) != null) {
                    Decimal commissionValue = (Decimal) contactData.get(commissionField);
                    Double calculatedValue = (totalAmountValue / 100) * commissionValue;
                    System.debug('commissionValue::' + commissionValue);
                    System.debug('totalAmountValue:::' + totalAmountValue);
                    System.debug('calculatedValue:::' + calculatedValue);
                    policyData.add(
                        new Map<String, Object>{
                            'Policy_Type_picklist__c' => policyType +
                            (isRenewed ? ' Renew' : ' New'),
                            'totalCount' => calculatedValue
                        }
                    );
                }
            }
        }

        System.debug('policyData:::' + policyData);
        return policyData;
    }

    /*
    @AuraEnabled
    public static String searchUserDetails(String searchKey) {
        try {
            System.debug('searchKey: -- :' + searchKey);
            List<User> userDetail = new List<User>();
            if (searchKey != null) {
                userDetail = [SELECT Id, AccountId, Address, Agent_Account_Id__c, User_Type__c, Alias, BadgeText,
                                     BannerPhotoUrl, CallCenterId, City, ContactID, Country, IsPortalEnabled, IsActive
                              FROM User
                              WHERE Id = :searchKey
                              LIMIT 1];
                System.debug('userDetail: --:' + userDetail);
            }
            return JSON.serialize(userDetail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    */

    public class LeadWrapper {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Email;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String Company;
        @AuraEnabled
        public Datetime CreatedDate;
        @AuraEnabled
        public String Agent;
        @AuraEnabled
        public String Agency;
    }
}
