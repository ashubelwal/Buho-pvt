/**
 * @description Service class that executes in WITHOUT SHARING context.
 *   Intended for operations that must bypass record-level sharing rules
 *   (e.g. portal users upserting Lead records they would otherwise not
 *   have access to due to OWD settings).
 *
 *   This class is NOT called directly by LWC. All @AuraEnabled entry points
 *   remain on AgentAppController, which delegates to this service so that
 *   existing LWC imports (e.g. @salesforce/apex/AgentAppController.saveLeadDetails)
 *   require no changes.
 */
public without sharing class AgentAppBaseService {

    /**
     * @description Core logic for saving / upserting a Lead with associated
     *   quote, vehicle, and towing details. Runs without sharing so that
     *   portal (community) users can upsert Lead records regardless of OWD.
     *
     * @param leadJson        Serialised Lead sObject JSON
     * @param quoteJSON       Quote details JSON string
     * @param vehicleJSON     Vehicle details JSON string
     * @param towedlistJSON   Towing details JSON string
     * @return String         Serialised Lead after upsert, or null
     * @throws AgentAppController.AgentAppControllerException on DML failure
     */
    public static String saveLeadDetails(
        String leadJson,
        String quoteJSON,
        String vehicleJSON,
        String towedlistJSON
    ) {
        if (String.isBlank(leadJson)) {
            return null;
        }

        Id loggedInUserId = UserInfo.getUserId();
        String agentId = '';
        Contact agentContact = new Contact();

        if (loggedInUserId != null) {
            User getUserInfo = [
                SELECT Id, User_Type__c, Email, ContactId
                FROM User
                WHERE Id = :loggedInUserId
                LIMIT 1
            ];
            if(getUserInfo.ContactId != null) {
                agentId = getUserInfo.ContactId;
            } else if (getUserInfo.User_Type__c == 'Customer' || getUserInfo.User_Type__c == null) {
                List<Contact> lstCon = [SELECT Id FROM Contact WHERE Email = :getUserInfo.Email LIMIT 1];
                if (!lstCon.isEmpty()) agentId = lstCon[0].Id;
            } /*else {
                List<User> userdata = [SELECT Id, ContactId FROM User WHERE Id = :loggedInUserId LIMIT 1];
                if (!userdata.isEmpty() && userdata[0].ContactId != null) {
                    agentId = userdata[0].ContactId;
                }
            }*/
        }

        if (String.isNotBlank(agentId)) {
            List<Contact> contactData = [ SELECT Id, Name, Agency__c, RecordType.Name FROM Contact WHERE Id = :agentId LIMIT 1];
            if (!contactData.isEmpty()) agentContact = contactData[0];
        }

        Lead getLeadData = (Lead) JSON.deserialize(leadJson, Lead.class);
        getLeadData.Company          = getLeadData.FirstName + ' ' + getLeadData.LastName;
        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
        getLeadData.Quote_Details__c  = quoteJSON;

        if (getLeadData.Policy_Type__c == 'Watercraft') {
            getLeadData.Watercraft_Detail__c = vehicleJSON;
        } else {
            getLeadData.Vehicle_Details__c = vehicleJSON;
        }

        if (String.isBlank(getLeadData.Agency__c)) {
            getLeadData.Agency__c = (agentContact.RecordType.Name == 'Agency RT' || agentContact.Agency__c == null) ? agentContact.Id : agentContact.Agency__c;
        }

        if (String.isBlank(getLeadData.Agent__c)) {
            getLeadData.Agent__c = agentContact.Id;
        }

        getLeadData.Towing__c = towedlistJSON;

        System.debug('Lead Before Saving: ' + getLeadData);
        upsert getLeadData;
        System.debug('Lead AFTER Saving: ' + getLeadData);
        return JSON.serialize(getLeadData);
    }

    public static string createPolicy(String leadId, Boolean needPortalAccess, Boolean isCardPayment) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            System.debug('Lead Id'  + leadId);
            Lead leadObj = [SELECT Id, Name, LastName, Is_towing__c, Email,FirstName, Phone, IsConverted, ConvertedContactId, ConvertedAccountId, Source__c, Quote_Details__c, Vehicle_details__c, Company_details__c, Lienholder_info__c, Driver_details__c, Towing__c, Terms_Alert__c, Agent__c, Agency__c FROM Lead WHERE Id = :leadId LIMIT 1];
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];
            System.debug('portalProfile--->'+portalProfile);
            
            List<User> currentUsers = [Select Id,Name,Agent_Account_Id__c from User Where Id = :UserInfo.getUserId() LIMIT 1 ];
            System.debug('CurrentUser'+ currentUsers);
            List<Account> existingAccountlist = new List<Account>();
            List<Contact> existingContacts = new List<Contact>();
            
            if (leadObj != null && !leadObj.IsConverted) {
                if(needPortalAccess == false && currentUsers.size() > 0){
                    System.debug('In if block 1');
                    existingAccountlist = [Select Id from Account Where Id =:currentUsers.get(0).Agent_Account_Id__c];
                    System.debug('ExistingAccountList1:'+existingAccountList);
                }
                
                if(leadObj.Email != null){
                    System.debug('In if block 2');
                    System.debug('Null Email In lead');
                    existingContacts = [Select Id, FirstName,LastName, Name, Email from Contact Where Email = :leadObj.Email];
                    System.debug('ExistingAccountList2:'+existingContacts);
                }
                
                Database.LeadConvert leadConvertInst = new Database.LeadConvert();
                leadConvertInst.setLeadId(leadId);
                
                // if(needPortalAccess == false && existingAccountlist.size() > 0){
                    //  Vehicle__c checkVehicleOwner = new Vehicle__c();
                    //  if (leadObj.Vehicle_details__c != null && !String.isBlank(leadObj.Vehicle_details__c)) {
                        //         checkVehicleOwner = (Vehicle__c)JSON.deserialize(leadObj.Vehicle_details__c, Vehicle__c.class);
                    //     }
                    //     if(checkVehicleOwner.Is_vehicle_owned_by_a_company_or_rented__c == false){
                        //         System.debug('In if block 3');
                        //         leadConvertInst.setAccountId(existingAccountlist.get(0).Id);
                    //     }
                // }
                
                if(needPortalAccess == false && existingAccountlist.size() > 0){
                    
                    leadConvertInst.setAccountId(existingAccountlist.get(0).Id);
                }
                
                
                if(existingContacts.size() > 0){
                    if(existingAccountlist.size() < 1){
                        System.debug('In if block 4');
                        System.debug('ExistingContactSize' +existingContacts );
                        System.debug('existingAccountList' + existingAccountlist );
                        Account dupAc = new Account();
                        dupAc.Name = existingContacts.get(0).Name;
                        dupAc.Email__c = existingContacts.get(0).Email;
                        Database.upsert(dupAc);
                        System.debug('Created Account' + dupAc);
                        existingContacts.get(0).AccountId = dupAc.Id;
                        Database.update(existingContacts);
                        
                        leadConvertInst.setAccountId(dupAc.Id);
                    }
                    
                    leadConvertInst.setContactId(existingContacts.get(0).Id);
                }
                leadConvertInst.setDoNotCreateOpportunity(true);
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
                
                System.debug('ConvertStatus' + convertStatus);
                System.debug('leadConvertInst' + leadConvertInst);
                
                Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
                System.debug('leadConvertRslt->  2  '+leadConvertRslt);
                
                
                String userId;
                
                if(needPortalAccess == true){
                    
                    String userFName = leadObj.FirstName.substring(0,1);
                    String userLName = leadObj.LastName.length() >=3 ? leadObj.LastName.substring(0, 3):leadObj.LastName;
                    User newUser = new User(
                        Username = leadObj.Email,
                    Email = leadObj.Email,
                    LastName = leadObj.LastName,
                    FirstName = leadObj.FirstName != null ? leadObj.FirstName : '',
                    Phone = leadObj.Phone != null ? leadObj.Phone : '',
                    Alias = (leadObj.FirstName != null && leadObj.LastName != null) ? userFName + ' ' + userLName : (leadObj.FirstName == null && leadObj.LastName != null) ? userLName : '',
                    contactId = leadConvertRslt.getContactId(),
                    profileId = portalProfile.Id,
                    EmailEncodingKey = 'UTF-8',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
                        );
                    System.debug('newUser--->'+newUser);
                    Database.insert(newUser);
                    userId = newuser.Id;
                }else{
                    userId = currentUsers.get(0).Id;
                }
                
                
                if (leadConvertRslt.isSuccess() && leadConvertRslt.getContactId() != null)
                {
                    Quote__c quoteRecord = new Quote__c();
                    Vehicle__c vehicleRecord = new Vehicle__c();
                    
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    if (leadObj.Quote_Details__c != null && !String.isBlank(leadObj.Quote_Details__c)) {
                        quoteRecord = (Quote__c)JSON.deserialize(leadObj.Quote_Details__c, Quote__c.class);
                        
                        system.debug('quoteRecord:---->'+quoteRecord);
                    }
                    
                    if (leadObj.Vehicle_details__c != null && !String.isBlank(leadObj.Vehicle_details__c)) {
                        vehicleRecord = (Vehicle__c)JSON.deserialize(leadObj.Vehicle_details__c, Vehicle__c.class);
                    }
                    
                    TermAndConditionWrapper termConditionRecord = new TermAndConditionWrapper();
                    System.debug('Lead object term and conditions' + leadObj.Terms_Alert__c);
                    if (leadObj.Terms_Alert__c != null && !String.isBlank(leadObj.Terms_Alert__c)) {
                        System.debug('Lead object term and conditions' + leadObj.Terms_Alert__c);
                        String formattedJson = leadObj.Terms_Alert__c
                            .replaceAll('__c', '_Tempc')
                            .replaceAll('"true"', 'true')
                            .replaceAll('"false"', 'false');
                        termConditionRecord = (TermAndConditionWrapper)JSON.deserialize(formattedJson.replaceAll('__c', '_Tempc'), TermAndConditionWrapper.class);
                        System.debug('Values in wrapper class' + termConditionRecord);
                    }
                    
                    if (userId != null) {
                        String isUpdated = updateQuoteContact(quoteRecord.Id, leadConvertRslt.getAccountId(), leadConvertRslt.getContactId());
                        
                        if (isUpdated == 'ok') {
                            // insert the Driver__c Object...
                            List<Driver__c> driverOwner = new List<Driver__c>();
                            List<Driver__c> driverRecordList = (List<Driver__c>)JSON.deserialize(leadObj.Driver_details__c, List<Driver__c>.class);
                            for (Driver__c eachDriver : driverRecordList) {
                                eachDriver.Name = eachDriver.First_Name__c + ' ' + eachDriver.Last_Name__c;
                                eachDriver.Contact__c = leadConvertRslt.getContactId();
                            }
                            insert driverRecordList;
                            
                            for (Driver__c eachRec : driverRecordList) {
                                if (eachRec.Driver_Type__c == 'Owner' || eachRec.Driver_Type__c == 'Owner & Driver') {
                                    driverOwner.add(eachRec);
                                }
                            }
                            
                            // insert the Towed_Unit__c Object...
                            List<Towed_Unit__c> towedRecordList;
                            if (leadObj.Is_towing__c == true) {
                                towedRecordList = (List<Towed_Unit__c>) JSON.deserialize(leadObj.Towing__c, List<Towed_Unit__c>.class);
                                if (!towedRecordList.isEmpty()) {
                                    for (Towed_Unit__c eachTow : towedRecordList) {
                                        eachTow.Contact__c = leadConvertRslt.getContactId();
                                        eachTow.Account__c = leadConvertRslt.getAccountId();
                                    }
                                    insert towedRecordList;
                                }
                            }
                            
                            // update the Account Object...
                            
                            //  Account accObj = new Account();
                            //  accObj.Id = leadConvertRslt.getAccountId();
                            //  if (vehicleRecord.Is_vehicle_owned_by_a_company_or_rented__c == true) {
                                //      accObj.Name = !String.isBlank(vehicleRecord.Company_Name__c) ? vehicleRecord.Company_Name__c : '';
                                //      accObj.Email__c = leadobj.Email;
                                //      accObj.Phone =!String.isBlank(vehicleRecord.Company_Phone__c) ? vehicleRecord.Company_Phone__c : '';
                                //      accObj.Phone__c =!String.isBlank(vehicleRecord.Company_Phone__c) ? vehicleRecord.Company_Phone__c : '';
                                //      accobj.City__c = vehicleRecord.Company_City__c;
                                //      accobj.State__c = vehicleRecord.Company_State__c;
                                //      accObj.Country__c = vehicleRecord.Company_Country__c;
                                //      accObj.Postal_Code__c = vehicleRecord.Company_Zip__c;
                                //      if([SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' And Name = 'Company'].size()>0){
                                    //          accObj.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' And Name = 'Company' LIMIT 1].id;
                                //      }
                            //  }
                            //  if(needPortalAccess == true){
                                //      accObj.Source__c = 'Agent App';
                                //      accObj.Type = 'Customer';
                            //  }
                            //  update accObj;
                            
                            Account accObj = new Account();
                            accObj.Id = leadConvertRslt.getAccountId();
                            if (needPortalAccess == true && vehicleRecord.Is_the_vehicle_registered_to_a_business__c && vehicleRecord.Is_Account_Company_Named__c) {
                                
                            } else if ( needPortalAccess == true &&  vehicleRecord.Is_the_vehicle_registered_to_a_business__c && !vehicleRecord.Is_Account_Company_Named__c) {
                                
                            } else if(needPortalAccess == true){
                            }
                            if(needPortalAccess == true){
                                accObj.Source__c = 'Agent App';
                                accObj.Type = 'Customer';
                                update accObj;
                            }
                            // update the Contact Object...
                            Contact conObj = new Contact();
                            
                            conObj.Email = leadobj.Email;
                            conObj.Id = leadConvertRslt.getContactId();
                            conObj.Phone = !String.isBlank(leadObj.Phone) ? leadObj.Phone : '';
                            conObj.MobilePhone = !String.isBlank(accObj.Phone) ? accObj.Phone : '';
                            conObj.Source__c = 'Agent App';
                            conObj.Street__c = !String.isBlank(accObj.Street__c) ? accObj.Street__c : '';
                            conObj.Street_2__c = !String.isBlank(accObj.Street_2__c) ? accObj.Street_2__c : '';
                            conObj.City__c = !String.isBlank(accObj.City__c) ? accObj.City__c : '';
                            conObj.State__c = !String.isBlank(accObj.State__c) ? accObj.State__c : '';
                            conObj.Country__c = !String.isBlank(accObj.Country__c) ? accObj.Country__c : '';
                            conObj.Postal_Code__c = !String.isBlank(accObj.Postal_Code__c) ? accObj.Postal_Code__c : '';
                            // Add Agent and agency
                            if(leadObj.Agency__c != null && conObj.Agency__c == null){
                                conObj.Agency__c = leadObj.Agency__c;
                            }
                            if(leadObj.Agent__c != null && conObj.Agent__c == null){
                                conObj.Agent__c = leadObj.Agent__c;
                            }
                            update conObj;
                            
                            // update the Quote__c Object...
                            quoteRecord.Quote_Status__c = 'Policy Created';
                            update quoteRecord;
                            
                            // Check if transaction exist then create policy and Update the transaction record...
                            List<Transaction__c> policyTransaction;
                            if(isCardPayment){
                                policyTransaction = [SELECT Id, Amount__c FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                                policyTransaction[0].Payment_Type__c = 'Card';
                            }else{
                                policyTransaction =  new List<Transaction__c>();
                                policyTransaction.add(
                                    new Transaction__c(
                                    Amount__c = quoteRecord.Quote_Value__c,
                                Quote_c__c = quoteRecord.Id,
                                Payment_Type__c = 'Cash',
                                Tax_Iva__c = quoteRecord.I_V_A_Mex_Tax__c
                                    )
                                    );
                                insert policyTransaction;
                            }
                            
                            
                            if (!policyTransaction.isEmpty()) {
                                vehicleRecord.Contact__c =  leadConvertRslt.getContactId();
                                insert vehicleRecord;
                                System.debug('quoteRecord.I_V_A_Mex_Tax__c----->'+quoteRecord.I_V_A_Mex_Tax__c);
                                // insert the Policy__c Object...
                                Policy__c newPolicy = new Policy__c();
                                newPolicy.Broker_Policy_Fee__c = quoteRecord.Broker_Policy_Fee__c;
                                newPolicy.I_V_A_Mex_Tax__c = quoteRecord.I_V_A_Mex_Tax__c;
                                newPolicy.Net_Premium__c = quoteRecord.Net_Premium__c;
                                newPolicy.Policy_Type_picklist__c = quoteRecord.Policy_Type_picklist__c;
                                newPolicy.Quote_c__c = quoteRecord.Id;
                                newPolicy.Package__c = quoteRecord.Coverage__c;
                                newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
                                newPolicy.Surcharge__c = quoteRecord.Surcharge__c;
                                newPolicy.Vehicle_deductible_collision__c = quoteRecord.Vehicle_Deductible_Collision__c != null ? quoteRecord.Vehicle_Deductible_Collision__c : '';
                                newPolicy.Vehicle_deductible_comprehensive__c = quoteRecord.Vehicle_Deductible_Comprehensive__c != null ? quoteRecord.Vehicle_Deductible_Comprehensive__c : '';
                                newPolicy.Vehicle_Policy__c = vehicleRecord.Id;
                                newPolicy.Contact__c = leadConvertRslt.getContactId();
                                newPolicy.Policy_Parent_Account__c = leadConvertRslt.getAccountId();
                                newPolicy.Account_Policy__c = leadConvertRslt.getAccountId();
                                newPolicy.Status_picklist__c = 'Active';
                                newPolicy.Source__c = 'Agent App';
                                newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                                newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                                newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                                newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
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
                                newPolicy.Name = generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                                newPolicy.What_is_the_purpose_of_trip__c = termConditionRecord.What_is_the_purpose_of_trip_Tempc != null ? termConditionRecord.What_is_the_purpose_of_trip_Tempc : '';
                                newPolicy.What_is_your_trip_destination_in_US__c = termConditionRecord.What_is_your_trip_destination_in_US_Tempc != null ? termConditionRecord.What_is_your_trip_destination_in_US_Tempc : '';
                                newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null ? termConditionRecord.Newsletter_Tempc : false;
                                newPolicy.Terms_of_Purchase_Confirmed__c = termConditionRecord.Terms_of_Purchase_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Purchase_Confirmed_Tempc : false;
                                newPolicy.Terms_of_Cancellation_Confirmed__c = termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc : false;
                                newPolicy.Contact_Email__c = conObj.Email;
                                if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                                } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                                } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                                } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                                }
                                //  else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                                //     newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                                //     // newPolicy.Yellow_Card__c = String.isNotEmpty(termConditionRecord.Yellow_Card_Tempc) ? termConditionRecord.Yellow_Card_Tempc : 'No';
                                // } 
                                else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                                } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                                }else{
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                                }
                                if(quoteRecord.Gold__c != null){
                                   newPolicy.Gold__c = quoteRecord.Gold__c;
                                }
                                if(quoteRecord.Max__c != null){
                                    newPolicy.Max__c = quoteRecord.Max__c;
                                }
                                if(quoteRecord.Platinum__c != null){
                                    newPolicy.Platinum__c = quoteRecord.Platinum__c;
                                }
                                // Add Agent and agency
                                if(leadObj.Agency__c != null && newPolicy.Agency__c == null){
                                    newPolicy.Agency__c = leadObj.Agency__c;
                                }
                                if(leadObj.Agent__c != null && newPolicy.Agent__c == null){
                                    newPolicy.Agent__c = leadObj.Agent__c;
                                }
                                insert newPolicy;
                                System.debug('newPolicy----->'+newPolicy);

                                if(newPolicy.Id != null){
                                    quoteRecord.Policy__c = newPolicy.Id;
                                    update quoteRecord;
                                    vehicleRecord.Policy__c = newpolicy.Id;
                                    update vehicleRecord;
                                }
                                
                                Id loggedInUserId = UserInfo.getUserId();
                                if(newPolicy.Agency__c == null || newPolicy.Agent__c == null){
                                    AgencyController.updatePolicyAgentAgency(newPolicy.Id,loggedInUserId);
                                }
                                
                                // insert the Quote_Vehicle__C Object...
                                Quote_Vehicle__C newQuoteVehicle = new Quote_vehicle__c();
                                newQuoteVehicle.Account__c = leadConvertRslt.getAccountId();
                                newQuoteVehicle.Contact__c = leadConvertRslt.getContactId();
                                newQuoteVehicle.Vehicle__c = vehicleRecord.Id;
                                newQuoteVehicle.Quote_c__c = quoteRecord.Id;
                                newQuoteVehicle.Policy__c = newPolicy.Id;
                                insert newQuoteVehicle;
                                
                                // insert the Quote_Driver__c Object...
                                List<Quote_Driver__c> quoteDriverList = new List<Quote_Driver__c>();
                                if (!driverRecordList.isEmpty()) {
                                    for (Driver__c each : driverRecordList) {
                                        Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                                        newQuoteDriver.Account_Driver__c = accObj.Id;
                                        newQuoteDriver.Contact__c = conObj.Id;
                                        newQuoteDriver.Quote_c__c = quoteRecord.Id;
                                        newQuoteDriver.Driver__c = each.Id;
                                        newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                                        newQuoteDriver.Policy__c = newPolicy.Id;
                                        quoteDriverList.add(newQuoteDriver);
                                        each.Policy__c = newPolicy.id;
                                    }

                                    if (!quoteDriverList.isEmpty()) {
                                        insert quoteDriverList;
                                        update driverRecordList;
                                    }
                                } else {
                                    // return error -> Driver record missing
                                }
                                
                                // insert the Quote_Towed_Unit__c Object...
                                List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
                                if (towedRecordList != null && !towedRecordList.isEmpty()) {
                                    for (Towed_Unit__c eachTowed : towedRecordList) {
                                        Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                                        newQuoteTowed.Account__c = accObj.Id;
                                        newQuoteTowed.Contact__c = conObj.Id;
                                        newQuoteTowed.Policy__c = newPolicy.Id;
                                        newQuoteTowed.Quote_c__c = quoteRecord.Id;
                                        newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
                                        newQuoteTowed.Towed_Unit__c = eachTowed.Id;
                                        eachTowed.Policy__c = newPolicy.Id;
                                        quoteTowedList.add(newQuoteTowed);
                                    }
                                    
                                    if (!quoteTowedList.isEmpty()) {
                                        insert quoteTowedList;
                                        update towedRecordList;
                                    }
                                }
                                
                                // Update the Transaction__c object...
                                policyTransaction[0].Policy_Transaction__c = newPolicy.Id;
                                policyTransaction[0].Account_Transaction__c = accObj.Id;
                                update policyTransaction;
                                
                                // send email to the user along with attachment...
                                Set<String> policyIds = new Set<String>();
                                if (!String.isBlank(newPolicy.Id)) {
                                    policyIds.add(newPolicy.Id);
                                }
                                
                                System.debug('Reached in pdf generation' + newPolicy.Id);
                                
                                
                                if (policyIds != null && !policyIds.isEmpty()) {
                                    
                                    System.debug('Reached in mail section in lead'+ policyIds);
                                    
                                    Boolean add_attachment = true;
                                    Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
                                }
                                return newPolicy.Id;
                            }
                            
                        } else {
                            // Error occured while updating the quote data...
                        }
                    }
                }
            } else {
                return 'Error 1';
        } } catch (Exception ex) { CustomErrorExceptionHandlerException.LogException(ex); System.debug('Exception occured '+ex);}
        return 'Error 2';
    }

    public static string createPolicyFromContact(String contactId, Boolean needPortalAccess, Boolean isCardPayment) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Id AccountId= null;
            Contact contactObj = [SELECT Id, AccountId, Name, LastName, Email, FirstName, Phone, Quote_Details__c,Watercraft_Detail__c, 
                            Vehicle_details__c, Driver_details__c, Is_towing__c, Towing__c, Terms_Alert__c FROM Contact 
                            WHERE Id = :contactId 
                            LIMIT 1];
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];
            System.debug('contactObj'+contactObj);
            List<User> currentUsers = [Select Id,Agent_Account_Id__c from User Where Id = :UserInfo.getUserId() LIMIT 1 ];
            List<User> existingUsers = [Select Id,Agent_Account_Id__c from User Where Email =: contactObj.Email LIMIT 1 ];
            List<Account> existingAccountlist = new List<Account>();
            
            System.debug('existingUsers -:'+existingUsers);
            System.debug('currentUsers -: '+currentUsers);
            
            if (contactObj != null) {
                if(needPortalAccess == false && currentUsers.size() > 0 && existingUsers.size() < 1){
                    existingAccountlist = [Select Id from Account Where Id =:currentUsers.get(0).Agent_Account_Id__c];
                }else{
                    existingAccountlist = [Select Id, Email__c from Account Where Email__c =:contactObj.Email];
                    if(existingAccountlist.size() < 1){
                        if(contactObj.AccountId != null){
                            if(contactObj.AccountId != currentUsers.get(0).Agent_Account_Id__c){
                                existingAccountlist = [Select Id, Email__c from Account Where Id =:contactObj.AccountId];
                            }
                        }
                    }
                }
                
                
                List<Contact> existingContacts = [Select Id, FirstName,LastName, Name, Email from Contact Where Email = :contactObj.Email];
                
                // Database.LeadConvert leadConvertInst = new Database.LeadConvert();
                // leadConvertInst.setLeadId(leadId);
                
                //if(needPortalAccess == false && existingAccountlist.size() > 0){
                    //    leadConvertInst.setAccountId(existingAccountlist.get(0).Id);
                //}
                
                if(existingContacts.size() > 0){
                    if(existingAccountlist.size() < 1){
                        Account dupAc = new Account();
                        dupAc.Name = existingContacts.get(0).Name;
                        dupAc.Email__c = existingContacts.get(0).Email;
                        Database.upsert(dupAc);
                        existingContacts.get(0).AccountId = dupAc.Id;
                        Database.update(existingContacts);
                        AccountId = dupAc.Id;
                        
                        //leadConvertInst.setAccountId(dupAc.Id);
                    }
                    
                    //leadConvertInst.setContactId(existingContacts.get(0).Id);
                }
                //leadConvertInst.setDoNotCreateOpportunity(true);
                
                //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                //leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
                
                //Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
                //System.debug('leadConvertRslt->  2  '+leadConvertRslt);
                
                
                String userId;
                
                if(needPortalAccess == true){
                    
                    String userFName = contactObj.FirstName.substring(0,1);
                    String userLName = contactObj.LastName.length() >=3 ? contactObj.LastName.substring(0, 3):contactObj.LastName;
                    User newUser = new User(
                        Username = contactObj.Email,
                    Email = contactObj.Email,
                    LastName = contactObj.LastName,
                    FirstName = contactObj.FirstName != null ? contactObj.FirstName : '',
                    Phone = contactObj.Phone != null ? contactObj.Phone : '',
                    Alias = (contactObj.FirstName != null && contactObj.LastName != null) ? userFName + ' ' + userLName : (contactObj.FirstName == null && contactObj.LastName != null) ? userLName : '',
                    contactId = contactObj.Id,
                    profileId = portalProfile.Id,
                    EmailEncodingKey = 'UTF-8',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
                        );
                    Database.insert(newUser);
                    userId = newuser.Id;
                }else{
                    userId = currentUsers.get(0).Id;
                }
                
                
                //if (leadConvertRslt.isSuccess() && leadConvertRslt.getContactId() != null)
                //{
                    Quote__c quoteRecord = new Quote__c();
                    Vehicle__c vehicleRecord = new Vehicle__c();
                    
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    if (contactObj.Quote_Details__c != null && !String.isBlank(contactObj.Quote_Details__c)) {
                        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(contactObj.Quote_Details__c);
                        String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
                        String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
                        jsonMap.put('Start_Time__c', startTime);
                        jsonMap.put('End_Time__c', endTime);
                        system.debug('jsonMap:---->'+jsonMap);
                        quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
                        //quoteRecord = (Quote__c)JSON.deserialize(contactObj.Quote_Details__c, Quote__c.class);
                        system.debug('quoteRecord:---->'+quoteRecord);
                        
                    }
                    
                    if (contactObj.Vehicle_details__c != null && !String.isBlank(contactObj.Vehicle_details__c)) {
                        vehicleRecord = (Vehicle__c)JSON.deserialize(contactObj.Vehicle_details__c, Vehicle__c.class);
                    }
                    
                    TermAndConditionWrapper termConditionRecord = new TermAndConditionWrapper();
                    if (contactObj.Terms_Alert__c != null && !String.isBlank(contactObj.Terms_Alert__c)) {
                        System.debug('Contact object term and conditions' + contactObj.Terms_Alert__c);
                        String formattedJson = contactObj.Terms_Alert__c
                            .replaceAll('__c', '_Tempc')
                            .replaceAll('"true"', 'true')
                            .replaceAll('"false"', 'false');
                        termConditionRecord = (TermAndConditionWrapper)JSON.deserialize(formattedJson.replaceAll('__c', '_Tempc'), TermAndConditionWrapper.class);
                        System.debug('Values in wrapper class' + termConditionRecord);
                    }
                    
                    if (userId != null) {
                        String isUpdated = updateQuoteContact(quoteRecord.Id, contactObj.AccountId, contactObj.Id);
                        
                        if (isUpdated == 'ok') {
                            // insert the Driver__c Object...
                            List<Driver__c> driverOwner = new List<Driver__c>();
                            List<Driver__c> driverRecordList = (List<Driver__c>)JSON.deserialize(contactObj.Driver_details__c, List<Driver__c>.class);
                            for (Driver__c eachDriver : driverRecordList) {
                                eachDriver.Name = eachDriver.First_Name__c + ' ' + eachDriver.Last_Name__c;
                                eachDriver.Contact__c = contactObj.Id;
                            }
                            upsert driverRecordList;
                            
                            for (Driver__c eachRec : driverRecordList) {
                                if (eachRec.Driver_Type__c == 'Owner' || eachRec.Driver_Type__c == 'Owner & Driver') {
                                    driverOwner.add(eachRec);
                                }
                            }
                            
                            // insert the Towed_Unit__c Object...
                            List<Towed_Unit__c> towedRecordList;
                            if (contactObj.Is_towing__c == true) {
                                towedRecordList = (List<Towed_Unit__c>) JSON.deserialize(contactObj.Towing__c, List<Towed_Unit__c>.class);
                                if (!towedRecordList.isEmpty()) {
                                    for (Towed_Unit__c eachTow : towedRecordList) { eachTow.Contact__c = contactObj.Id;  eachTow.Account__c = contactObj.AccountId;
                                    }
                                    insert towedRecordList;
                                }
                            }
                            System.debug('Vehicle Record in quick quote--->' + vehicleRecord);
                            System.debug('Vehicle Record in quick quote--->' + vehicleRecord.Is_the_vehicle_registered_to_a_business__c);
                            System.debug('Vehicle Record in quick quote--->' + vehicleRecord.Is_Account_Company_Named__c);
                            
                            // update the Account Object...
                            Account accObj = new Account();
                            accObj.Id = contactObj.AccountId;
                            if (needPortalAccess == true && vehicleRecord.Is_the_vehicle_registered_to_a_business__c && vehicleRecord.Is_Account_Company_Named__c) {
                                // accObj.Name = !String.isBlank(companyRecord.Company_Name_Tempc) ? companyRecord.Company_Name_Tempc : '';
                                // accObj.Id = leadConvertRslt.getAccountId();
                                // accObj.Is_Account_Company_Named__c = true;
                                // accObj.Email__c = leadobj.Email;
                                // accObj.Phone =!String.isBlank(companyRecord.Company_Phone_Tempc) ? companyRecord.Company_Phone_Tempc : '';
                                // accObj.Phone__c =!String.isBlank(companyRecord.Company_Phone_Tempc) ? companyRecord.Company_Phone_Tempc : '';
                                // accObj.Street__c = companyRecord.Company_Address_Tempc;
                                // accobj.City__c = companyRecord.Company_City_Tempc;
                                // accobj.State__c = companyRecord.Company_State_Tempc;
                                // accObj.Country__c = companyRecord.Company_Country_Tempc;
                                // accObj.Postal_Code__c = companyRecord.Company_Zip_Tempc;
                            } else if ( needPortalAccess == true &&  vehicleRecord.Is_the_vehicle_registered_to_a_business__c && !vehicleRecord.Is_Account_Company_Named__c) {
                                // accObj.Name = leadObj.FirstName + ' ' + leadObj.LastName;
                                // accObj.Id = leadConvertRslt.getAccountId();
                                // accObj.Is_Account_Company_Named__c = false;
                                // accObj.Email__c = leadobj.Email;
                                // accObj.Phone = leadObj.Phone;
                                // accObj.Phone__c = leadObj.Phone;
                                // accObj.Street__c = vehicleRecord.BusinessAddress_Tempc.Address_Tempc;
                                // accObj.Street_2__c = vehicleRecord.BusinessAddress_Tempc.Address_Line_2_Tempc;
                                // accobj.City__c = vehicleRecord.BusinessAddress_Tempc.City_Tempc;
                                // accobj.State__c = vehicleRecord.BusinessAddress_Tempc.State_Province_Tempc;
                                // accObj.Country__c = vehicleRecord.BusinessAddress_Tempc.Country_Tempc;
                                // accObj.Postal_Code__c = vehicleRecord.BusinessAddress_Tempc.Postal_Code_Tempc;
                            } else if(needPortalAccess == true){
                                // accObj.Name = driverOwner[0].First_Name__c + ' ' + driverOwner[0].Last_Name__c;
                                // accObj.Id = leadConvertRslt.getAccountId();
                                // accObj.Email__c = driverOwner[0].Email__c;
                                // accObj.Phone = driverOwner[0].Phone__c;
                                // accObj.Phone__c = driverOwner[0].Phone__c;
                                // accObj.Street__c = driverOwner[0].Address__c;
                                // accObj.Street_2__c = driverOwner[0].Address_Line_2__c;
                                // accobj.City__c = driverOwner[0].City__c;
                                // accobj.State__c = driverOwner[0].State_Province__c;
                                // accObj.Country__c = driverOwner[0].Country__c;
                                // accObj.Postal_Code__c = driverOwner[0].Postal_Code__c;
                            }
                            if(needPortalAccess == true){
                                accObj.Source__c = 'Agent App';
                                accObj.Type = 'Customer';
                                update accObj;
                            }
                            
                            
                            // update the Contact Object...
                            //Contact conObj = new Contact();
                            // if (vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && vehicleRecord.Is_Account_Company_Named_Tempc) {
                                //     conObj.LastName = !String.isBlank(companyRecord.Company_Name_Tempc) ? companyRecord.Company_Name_Tempc : '';
                                //     conObj.FirstName = '';
                            // } else if (vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && !vehicleRecord.Is_Account_Company_Named_Tempc) {
                                //     conObj.FirstName = leadObj.FirstName;
                                //     conObj.LastName = leadObj.LastName;
                            // } else if (!vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && !vehicleRecord.Is_Account_Company_Named_Tempc) {
                                //     conObj.FirstName = driverOwner[0].First_Name__c;
                                //     conObj.LastName = driverOwner[0].Last_Name__c;
                                //     conObj.Date_of_Birth__c = driverOwner[0].Dob__c;
                            // }
                            //conObj.Email = leadobj.Email;
                            //conObj.Id = leadConvertRslt.getContactId();
                            //conObj.Phone = !String.isBlank(accObj.Phone) ? accObj.Phone : '';
                            //conObj.MobilePhone = !String.isBlank(accObj.Phone) ? accObj.Phone : '';
                            //conObj.Source__c = 'Agent App';
                            //conObj.Street__c = !String.isBlank(accObj.Street__c) ? accObj.Street__c : '';
                            //conObj.Street_2__c = !String.isBlank(accObj.Street_2__c) ? accObj.Street_2__c : '';
                            //conObj.City__c = !String.isBlank(accObj.City__c) ? accObj.City__c : '';
                            //conObj.State__c = !String.isBlank(accObj.State__c) ? accObj.State__c : '';
                            //conObj.Country__c = !String.isBlank(accObj.Country__c) ? accObj.Country__c : '';
                            //conObj.Postal_Code__c = !String.isBlank(accObj.Postal_Code__c) ? accObj.Postal_Code__c : '';
                            //update conObj;
                            
                            // update the Quote__c Object...
                            quoteRecord.Quote_Status__c = 'Policy Created';
                            update quoteRecord;
                            
                            Quote__c updatedQuoteRecord = [SELECT Id,Quote_Value__c,Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Net_Premium__c, Policy_Type_picklist__c, Coverage__c, Territory__c, 
                                                           Surcharge__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                                           Start_Date_for_Coverage__c, Start_Time__c, End_Date_for_Coverage__c, End_Time__c, Underwriter__c, Vehicle_Type__c, Vehicle_Value__c,Gold__c,Platinum__c,Max__c 
                                                           FROM Quote__c WHERE Id =: quoteRecord.Id LIMIT 1];
                            // Check if transaction exist then create policy and Update the transaction record...
                            List<Transaction__c> policyTransaction;
                            if(isCardPayment){
                                policyTransaction = [SELECT Id, Amount__c FROM Transaction__c Where Quote_c__c = :updatedQuoteRecord.Id];  policyTransaction[0].Payment_Type__c = 'Card';
                            }else{
                                policyTransaction =  new List<Transaction__c>();
                                policyTransaction.add(
                                    new Transaction__c(
                                    Amount__c = updatedQuoteRecord.Quote_Value__c,
                                Quote_c__c = updatedQuoteRecord.Id,
                                Payment_Type__c = 'Cash',
                                Tax_Iva__c = quoteRecord.I_V_A_Mex_Tax__c
                                    )
                                    );
                                insert policyTransaction;
                            }
                            
                            
                            if (!policyTransaction.isEmpty()) {
                                vehicleRecord.Contact__c =  contactObj.Id;
                                upsert vehicleRecord;
                                
                                // insert the Policy__c Object...
                                Policy__c newPolicy = new Policy__c();
                                newPolicy.Broker_Policy_Fee__c = updatedQuoteRecord.Broker_Policy_Fee__c;
                                newPolicy.I_V_A_Mex_Tax__c = updatedQuoteRecord.I_V_A_Mex_Tax__c;
                                newPolicy.Net_Premium__c = updatedQuoteRecord.Net_Premium__c;
                                newPolicy.Policy_Type_picklist__c = updatedQuoteRecord.Policy_Type_picklist__c;
                                newPolicy.Quote_c__c = updatedQuoteRecord.Id;
                                newPolicy.Package__c = updatedQuoteRecord.Coverage__c;
                                newPolicy.Territory_picklist__c = updatedQuoteRecord.Territory__c;
                                newPolicy.Surcharge__c = updatedQuoteRecord.Surcharge__c;
                                newPolicy.Vehicle_deductible_collision__c = updatedQuoteRecord.Vehicle_Deductible_Collision__c != null ? updatedQuoteRecord.Vehicle_Deductible_Collision__c : '';
                                newPolicy.Vehicle_deductible_comprehensive__c = updatedQuoteRecord.Vehicle_Deductible_Comprehensive__c != null ? updatedQuoteRecord.Vehicle_Deductible_Comprehensive__c : '';
                                newPolicy.Vehicle_Policy__c = vehicleRecord.Id;
                                newPolicy.Contact__c = contactObj.Id;
                                newPolicy.Policy_Parent_Account__c = AccountId != null ? AccountId : contactObj.AccountId;
                                newPolicy.Account_Policy__c = AccountId != null ? AccountId : contactObj.AccountId;
                                newPolicy.Status_picklist__c = 'Active';
                                newPolicy.Source__c = 'Agent App';
                                newPolicy.Total_Transaction_Amount__c = updatedQuoteRecord.Quote_Value__c;
                                newPolicy.Medical_picklist__c = updatedQuoteRecord.Medical__c;
                                newPolicy.Liability_picklist__c = updatedQuoteRecord.Liability__c;
                                newPolicy.Territory_picklist__c = updatedQuoteRecord.Territory__c;
                                newPolicy.Term__c = updatedQuoteRecord.Term__c;
                                
                                if (updatedQuoteRecord.Term__c != null && (updatedQuoteRecord.Term__c == 'Annual(One Year)' || updatedQuoteRecord.Term__c == 'Annual')) {
                                    newPolicy.Term_days__c = 365;
                                } else {
                                    newPolicy.Term_days__c = updatedQuoteRecord.Term_Days__c;
                                }
                                
                                if (updatedQuoteRecord.Start_Date_for_Coverage__c != null) {
                                    newPolicy.Start_Date__c = updatedQuoteRecord.Start_Date_for_Coverage__c;
                                }
                                if (updatedQuoteRecord.Start_Time__c != null) {
                                    newPolicy.Start_Time__c = updatedQuoteRecord.Start_Time__c;
                                }
                                if (updatedQuoteRecord.End_Date_for_Coverage__c != null) {
                                    newPolicy.End_Date__c = updatedQuoteRecord.End_Date_for_Coverage__c;
                                }
                                if (updatedQuoteRecord.End_Time__c != null) {
                                    newPolicy.End_Time__c = updatedQuoteRecord.End_Time__c;
                                }
                                
                                newPolicy.Underwriter_picklist__c = updatedQuoteRecord.Underwriter__c;
                                newPolicy.Vehicle_type__c = updatedQuoteRecord.Vehicle_Type__c;
                                newPolicy.Insured_value__c = updatedQuoteRecord.Vehicle_Value__c;
                                newPolicy.Name = generatePolicyName(updatedQuoteRecord.Underwriter__c, updatedQuoteRecord.Policy_Type_picklist__c, updatedQuoteRecord.Coverage__c, updatedQuoteRecord.Term__c, updatedQuoteRecord.Territory__c);
                                newPolicy.What_is_the_purpose_of_trip__c = termConditionRecord.What_is_the_purpose_of_trip_Tempc != null ? termConditionRecord.What_is_the_purpose_of_trip_Tempc : '';
                                newPolicy.What_is_your_trip_destination_in_US__c = termConditionRecord.What_is_your_trip_destination_in_US_Tempc != null ? termConditionRecord.What_is_your_trip_destination_in_US_Tempc : '';
                                newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null ? termConditionRecord.Newsletter_Tempc : false;
                                newPolicy.Terms_of_Purchase_Confirmed__c = termConditionRecord.Terms_of_Purchase_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Purchase_Confirmed_Tempc : false;
                                newPolicy.Terms_of_Cancellation_Confirmed__c = termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc : false;
                                newPolicy.Contact_Email__c = contactObj.Email;

                                if (updatedQuoteRecord.Policy_Type_picklist__c != null && updatedQuoteRecord.Policy_Type_picklist__c == 'Automobile' && policyDeveloperNameVsId.containsKey('Automobile')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                                } else if (updatedQuoteRecord.Policy_Type_picklist__c != null && updatedQuoteRecord.Policy_Type_picklist__c == 'Driver License' && policyDeveloperNameVsId.containsKey('Driver_License')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Driver_License');
                                } else if (updatedQuoteRecord.Policy_Type_picklist__c != null && updatedQuoteRecord.Policy_Type_picklist__c == 'Homeowners' && policyDeveloperNameVsId.containsKey('Homeowners')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Homeowners');
                                } else if (updatedQuoteRecord.Policy_Type_picklist__c != null && updatedQuoteRecord.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && policyDeveloperNameVsId.containsKey('Motorcycle')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Motorcycle');
                                }
                                //  else if (updatedQuoteRecord.Policy_Type_picklist__c != null && updatedQuoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                                //     newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                                //     // newPolicy.Yellow_Card__c = String.isNotEmpty(termConditionRecord.Yellow_Card_Tempc) ? termConditionRecord.Yellow_Card_Tempc : 'No';
                                // }
                                 else if (updatedQuoteRecord.Policy_Type_picklist__c != null && updatedQuoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                                } else if (updatedQuoteRecord.Policy_Type_picklist__c != null && updatedQuoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                                } else {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                                }

                                if(updatedQuoteRecord.Gold__c != null){
                                   newPolicy.Gold__c = updatedQuoteRecord.Gold__c;
                                }
                                if(updatedQuoteRecord.Max__c != null){
                                    newPolicy.Max__c = updatedQuoteRecord.Max__c;
                                }
                                if(updatedQuoteRecord.Platinum__c != null){
                                    newPolicy.Platinum__c = updatedQuoteRecord.Platinum__c;
                                }
                                insert newPolicy;

                                if(newPolicy.Id != null){
                                    updatedQuoteRecord.Policy__c = newPolicy.Id;
                                    update updatedQuoteRecord;
                                    vehicleRecord.Policy__c = newpolicy.Id;
                                    update vehicleRecord;
                                }                                
                                Id loggedInUserId = UserInfo.getUserId();
                                AgencyController.updatePolicyAgentAgency(newPolicy.Id,loggedInUserId);
                                
                                // insert the Quote_Vehicle__C Object...
                                Quote_Vehicle__C newQuoteVehicle = new Quote_vehicle__c();
                                newQuoteVehicle.Account__c = contactObj.AccountId;
                                newQuoteVehicle.Contact__c = contactObj.Id;
                                newQuoteVehicle.Vehicle__c = vehicleRecord.Id;
                                newQuoteVehicle.Quote_c__c = updatedQuoteRecord.Id;
                                newQuoteVehicle.Policy__c = newPolicy.Id;
                                insert newQuoteVehicle;
                                
                                // insert the Quote_Driver__c Object...
                                List<Quote_Driver__c> quoteDriverList = new List<Quote_Driver__c>();
                                if (!driverRecordList.isEmpty()) {
                                    for (Driver__c each : driverRecordList) {
                                        Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                                        newQuoteDriver.Account_Driver__c = accObj.Id;
                                        newQuoteDriver.Contact__c = contactObj.Id;
                                        newQuoteDriver.Quote_c__c = updatedQuoteRecord.Id;
                                        newQuoteDriver.Driver__c = each.Id;
                                        newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                                        newQuoteDriver.Policy__c = newPolicy.Id;
                                        quoteDriverList.add(newQuoteDriver);
                                        each.Policy__c = newPolicy.Id;
                                    }
                                    
                                    if (!quoteDriverList.isEmpty()) {
                                        insert quoteDriverList;
                                        update driverRecordList;
                                    }
                                } else {
                                    // return error -> Driver record missing
                                }
                                
                                // insert the Quote_Towed_Unit__c Object...
                                List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
                                if (towedRecordList != null && !towedRecordList.isEmpty()) {
                                    for (Towed_Unit__c eachTowed : towedRecordList) {
                                        Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                                        newQuoteTowed.Account__c = accObj.Id;
                                        newQuoteTowed.Contact__c = contactObj.Id;
                                        newQuoteTowed.Policy__c = newPolicy.Id;
                                        newQuoteTowed.Quote_c__c = updatedQuoteRecord.Id;
                                        newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
                                        newQuoteTowed.Towed_Unit__c = eachTowed.Id;
                                        eachTowed.Policy__c = newPolicy.Id;
                                        quoteTowedList.add(newQuoteTowed);
                                    }
                                    
                                    if (!quoteTowedList.isEmpty()) {
                                        insert quoteTowedList;
                                        update towedRecordList;
                                    }
                                }
                                
                                // Update the Transaction__c object...
                                policyTransaction[0].Policy_Transaction__c = newPolicy.Id;
                                policyTransaction[0].Account_Transaction__c = accObj.Id;
                                update policyTransaction;
                                
                                System.debug('Reached in pdf generation' + newPolicy.Id);
                                
                                // send email to the user along with attachment...
                                Set<String> policyIds = new Set<String>();
                                if (!String.isBlank(newPolicy.Id)) {
                                    policyIds.add(newPolicy.Id);
                                }
                                
                                System.debug('Inside create policy from conatact::::::::::::::'+policyIds +',PolicyIdssss');
                                
                                
                                if (policyIds != null && !policyIds.isEmpty()) {
                                    System.debug('Send mail function');
                                    Boolean add_attachment = true;
                                    Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
                                }
                                
                                return newPolicy.Id;
                            }
                            
                        //} else {
                            // Error occured while updating the quote data...
                        // }
                    }
                }
            } else {
                return 'Error 1';
        } } catch (Exception ex) { CustomErrorExceptionHandlerException.LogException(ex); }
        return 'Error 2';
    }

    private static String updateQuoteContact(String quoteId, String accountId, String contactId) {
        try {
            Quote__c quote = new Quote__c();
            quote.Id = quoteId;
            quote.Contact__c = contactId;
            quote.Account__c = accountId;
            update quote;
            
            return 'ok';
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.data = 'quoteId: '+quoteId+'\naccountId: '+accountId+'\ncontactId'+contactId;
            CustomErrorExceptionHandlerException.LogException(e);
            return 'error';
        }
    }

    public static string generatePolicyName(String underwriter, String policyType, String coverageType, String term, String territory) {
        String policyName = '';
        
        //1 Letter
        if (underWriter != null && underWriter != '') {
            policyName += underWriter.substring(0, 1).toUpperCase();
        }
        
        //2 Letter
        if (policyType != null && policyType != '') {
            policyName += policyType.substring(0, 1).toUpperCase();
        }
        
        //3 Letter
        if (coverageType != null && coverageType != '') {
            policyName += coverageType.substring(0, 1).toUpperCase();
        }
        
        //4 Letter
        if (term != null && term != '') {
            policyName += term.substring(0, 1).toUpperCase();
        }
        
        //5 Letter
        if (territory != null && territory != '') {
            policyName += territory.substring(0, 1).toUpperCase();
        }
        
        //6 - 8Letter
        policyName += '-' + String.valueOf(System.today().year()).substring(2, 4) + '-' + generateRandomString(5).toUpperCase();
        
        return policyName;
    }

    public static Map<String, String> createNewEditPolicy(String vehicleData, String DriverData, String towedUnitData, String quoteId, String oldPolicyId, Boolean isRenewal) {
        Map<String, String> responseMap = new Map<String, String>();
        
        try {
            if (String.isNotBlank(quoteId)) {
                SYstem.debug('inside QuoteId');
                // Get New Quote Record
                Quote__c quoteRecord = [SELECT Id, Name, Underwriter__c, Policy_Type_picklist__c, Net_Premium__c, Broker_Policy_Fee__c, I_V_A_Mex_Tax__c, Quote_Value__c, Surcharge__c, 
                                        Account__c, Contact__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Physical_Damage__c, 
                                        Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Coverage__c, Territory__c, Medical__c, Liability__c, Term__c, Term_Days__c, 
                                        Start_Date_for_Coverage__c, Start_Time__c, Quote_Status__c, End_Date_for_Coverage__c, End_Time__c, Vehicle_Value__c 
                                        FROM Quote__c WHERE Id = :quoteId];
                
                
                
                // Check if transaction exist then create policy and Update the transaction record...
                List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                policyTransaction[0].Payment_Type__c = 'Card';
                
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
                    system.debug('@@#vehicleData@@###+++'+vehicleData);
                    if (!String.isEmpty(vehicleData)) {
                        vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                        if (!String.isEmpty(vehicleRecord.Company_Name__c) && vehicleRecord.Is_vehicle_owned_by_a_company_or_rented__c == true) {
                            vehicleRecord.Vehicle_Owner_Name__c = '';
                            vehicleRecord.Vehicle_Owner_Phone__c = '';
                            vehicleRecord.Vehicle_Owner_Address__c = '';
                            vehicleRecord.Vehicle_Owner_Driver_License__c = '';
                            vehicleRecord.Vehicle_Owner_Driver_License_State__c = '';
                            vehicleRecord.Vehicle_Owner_City__c = '';
                            vehicleRecord.Vehicle_Owner_State__c = '';
                            vehicleRecord.Vehicle_Owner_Postal_Code__c = '';
                            vehicleRecord.Vehicle_Owner_Country__c = '';
                        }
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
                    try {
                        if (String.isNotBlank(vehicleData) && !String.isEmpty(DriverData)) {
                            List<Driver__c> allDrivers = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);

                            System.debug('All drivers@@###' + allDrivers);

                            // Filter drivers by Driver_Type__c values
                            List<Driver__c> filteredDrivers = new List<Driver__c>();
                            for (Driver__c d : allDrivers) {
                                // You can adjust this condition as needed
                                String driverType = d.Driver_Type__c.toLowerCase();
                                    if (driverType == 'true' || driverType == 'owner' || driverType == 'co-owner' || driverType == 'owner & driver') {
                                        filteredDrivers.add(d);
                                    }
                            }

                            System.debug('Filtered drivers@@###' + filteredDrivers);

                            if (!filteredDrivers.isEmpty()) {
                                Driver__c ownerDriver = filteredDrivers[0];
                                vehicleRecord.Vehicle_Owner_Name__c = ownerDriver.First_Name__c + ' ' + ownerDriver.Last_Name__c;
                                vehicleRecord.Vehicle_Owner_Phone__c = ownerDriver.Phone__c;
                                vehicleRecord.Vehicle_Owner_Address__c = ownerDriver.Address__c;
                                vehicleRecord.Vehicle_Owner_Driver_License__c = ownerDriver.license_number__c;
                                vehicleRecord.Vehicle_Owner_Driver_License_State__c = ownerDriver.License_state__c;
                                vehicleRecord.Vehicle_Owner_City__c = ownerDriver.City__c;
                                vehicleRecord.Vehicle_Owner_State__c = ownerDriver.State_Province__c;
                                vehicleRecord.Vehicle_Owner_Postal_Code__c = ownerDriver.Postal_Code__c;
                                vehicleRecord.Vehicle_Owner_Country__c = ownerDriver.Country__c;
                                vehicleRecord.Is_the_vehicle_registered_to_a_business__c = false;
                                vehicleRecord.Company_Name__c = '';
                                vehicleRecord.Company_Phone__c = '';
                                vehicleRecord.Tax_ID__c = '';
                                vehicleRecord.Company_Country__c = '';
                                vehicleRecord.Company_Address__c = '';
                                vehicleRecord.Company_Zip__c = '';
                                vehicleRecord.Company_State__c = '';
                                vehicleRecord.Company_City__c = '';
                                update vehicleRecord;
                                System.debug('vehicleRecord@@###' + vehicleRecord);

                                responseMap.put('status', 'success');
                               // responseMap.put('vehicleData', vehicleRecord);
                            } 
                        } 
                    } catch (Exception e) {
                        responseMap.put('status', 'error');
                        responseMap.put('message', e.getMessage());
                    }
                    // Upsert the Towed Unit Record
                    List<Towed_Unit__c> towedUnitList;
                    if (!String.isEmpty(towedUnitData)) {
                        towedUnitList = (List<Towed_Unit__c>) JSON.deserialize(towedUnitData, List<Towed_Unit__c>.class);
                        upsert towedUnitList;
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
                        //newPolicy.RecordTypeId = oldPolicy.RecordTypeId;
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
                    } 
                    // else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Northbound' && policyDeveloperNameVsId.containsKey('Northbound')) {
                    //     newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Northbound');
                    // }
                    else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                    } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                    }else{
                        newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                    }
                    newPolicy.Contact_Email__c = oldPolicy.Contact_Email__c;
                    
                    insert newPolicy;
                    
                    Id loggedInUserId = UserInfo.getUserId();
                    AgencyController.updatePolicyAgentAgency(newPolicy.Id,loggedInUserId);
                    
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
                    if (!towedUnitList.isEmpty() && towedUnitList.size() > 0) {
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
                    
                    // send email to the user along with attachment...
                    Set<String> policyIds = new Set<String>();
                    if (!String.isBlank(newPolicy.Id)) {
                        policyIds.add(newPolicy.Id);
                    }
                    
                    if (policyIds != null && !policyIds.isEmpty()) {
                        Boolean add_attachment = true;
                        Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
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
            responseMap.put('message', ex.getMessage());
        }
        
        return responseMap;
    }

    public static map<String, Object> updatePolicyDetails(String quoteData, String DriverData, String vehicleData, String towedUnitData){
        map<String, Object> responseMap = new map<String, Object>();
        Quote__c quoteRecord;
        Vehicle__c vehicleRecord;
        List<Driver__c> driverRecord;
        List<Towed_Unit__c> towedRecord;
        Policy__c policyRecord;
        User userRecord = [SELECT Id, Name, Email, Username, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        try{
            if (!String.isEmpty(quoteData)) {
                system.debug('quoteData: updatePolicyDetails---->'+quoteData);
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quoteData);
                String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
                String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
                // 13 sep update for renew date
                String startDateStr = (String)jsonMap.get('Start_Date_for_Coverage__c');
                String endDateStr = (String)jsonMap.get('End_Date_for_Coverage__c');
                Date startDate = Date.valueOf(startDateStr);
                Date endDate = Date.valueOf(endDateStr);
                jsonMap.put('Start_Time__c', startTime);
                jsonMap.put('End_Time__c', endTime);
                jsonMap.put('Start_Date_for_Coverage__c',startDate);
                jsonMap.put('End_Date_for_Coverage__c',endDate);
                system.debug('jsonMap:---->'+jsonMap);
                quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
                system.debug('quoteRecord--- updatePolicyDetails:---->'+quoteRecord);
                if (quoteRecord != null) {
                    update quoteRecord;
                    
                    policyRecord = [SELECT Id, Name, Quote_c__c, Start_Time__c, End_Time__c,Start_Date__c,End_Date__c From Policy__c Where Quote_c__c = :quoteRecord.Id];
                    
                    policyRecord.Start_Time__c = quoteRecord.Start_Time__c;
                    policyRecord.End_Time__c = quoteRecord.End_Time__c;
                    policyRecord.Start_Date__c = quoteRecord.Start_Date_for_Coverage__c;
                    policyRecord.End_Date__c = quoteRecord.End_Date_for_Coverage__c;
                    
                    update policyRecord;
                }
            }
            
            if (!String.isEmpty(vehicleData)) {
                system.debug('vehicleData@@####'+ vehicleData);
                vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                system.debug('vehicleRecord@@###'+vehicleRecord);
                if (vehicleRecord != null) {
                    if (!String.isEmpty(vehicleRecord.Company_Name__c) && vehicleRecord.Is_vehicle_owned_by_a_company_or_rented__c == true) {
                        vehicleRecord.Vehicle_Owner_Name__c = '';
                        vehicleRecord.Vehicle_Owner_Phone__c = '';
                        vehicleRecord.Vehicle_Owner_Address__c = '';
                        vehicleRecord.Vehicle_Owner_Driver_License__c = '';
                        vehicleRecord.Vehicle_Owner_Driver_License_State__c = '';
                        vehicleRecord.Vehicle_Owner_City__c = '';
                        vehicleRecord.Vehicle_Owner_State__c = '';
                        vehicleRecord.Vehicle_Owner_Postal_Code__c = '';
                        vehicleRecord.Vehicle_Owner_Country__c = '';
                    }
                    update vehicleRecord;
                }
            }
            
            if (!String.isEmpty(DriverData)) {
                driverRecord = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);
                
                if (!driverRecord.isEmpty()) {
                    List<Quote_Driver__c> quoteDriverRecord = [SELECT Id, Driver__c,Quote_c__c FROM Quote_Driver__c WHERE Quote_c__c = :quoteRecord.Id];
                    for (Driver__c eachDr : driverRecord) {
                        eachDr.Contact__c = userRecord.ContactId;
                        eachDr.Account_Driver__c = userRecord.AccountId;
                        eachDr.Name = eachDr.First_Name__c + ' ' + eachDr.Last_Name__c;
                    }
                    upsert driverRecord;
                    
                    //logic for matching existing driver list and comparing to remove it
                    List<Quote_Driver__c> deleteQuoteDriverList = new List<Quote_Driver__c>();
                    if(driverRecord.size() != quoteDriverRecord.size()){
                        for(Quote_Driver__c quoteDriver : quoteDriverRecord){
                            Boolean isAvailable = false;
                            for(Driver__c eachDriver : driverRecord){
                                if(eachDriver.Id == quoteDriver.Driver__c){
                                    isAvailable = true;
                                    break;
                                }
                            }
                            if(isAvailable == false){
                                deleteQuoteDriverList.add(quoteDriver);
                            }
                            
                        }
                        if(deleteQuoteDriverList.size() > 0){
                            
                            for(Integer i = 0; i <quoteDriverRecord.size() ; i ++ ){
                                Boolean isAvailable = false;
                                for(Quote_Driver__c eachDeleteQuote : deleteQuoteDriverList){
                                    if(quoteDriverRecord.get(i).Id == eachDeleteQuote.Id ){
                                        isAvailable = true;
                                        break;
                                    }
                                }
                                if(isAvailable == true){
                                    quoteDriverRecord.remove(i);
                                }
                                
                            }
                            
                            Database.delete(deleteQuoteDriverList);
                        }
                    }
                    
                    if (quoteDriverRecord.isEmpty()) {
                        List<Quote_Driver__c> quoteDriversList = new List<Quote_Driver__c>();
                        for (Driver__c eachDriver : driverRecord) {
                            Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                            newQuoteDriver.Account_Driver__c = userRecord.AccountId;
                            newQuoteDriver.Contact__c = userRecord.ContactId;
                            newQuoteDriver.Driver__c = eachDriver.Id;
                            newQuoteDriver.Quote_c__c = quoteRecord.Id;
                            newQuoteDriver.Primary_insured__c = eachDriver.Primary_insured__c;
                            newQuoteDriver.Vehicle_Driver__c = vehicleRecord.Id;
                            newQuoteDriver.Policy__c = policyRecord.Id;
                            quoteDriversList.add(newQuoteDriver);
                        }
                        
                        if (!quoteDriversList.isEmpty()) {
                            upsert quoteDriversList;
                        }
                    } else {
                        Map<Id, Quote_Driver__c> quoteDriverMap = new Map<Id, Quote_Driver__c>();
                        List<Driver__c> newDriverToInsert = new List<Driver__c>();
                        for (Quote_Driver__c eachQuoteDriver : quoteDriverRecord) {
                            if (!quoteDriverMap.containsKey(eachQuoteDriver.Id)) {
                                quoteDriverMap.put(eachQuoteDriver.Driver__c, eachQuoteDriver);
                            }
                        }
                        
                        for (Driver__c eachDr : driverRecord) {
                            if (!quoteDriverMap.containsKey(eachDr.Id)) {
                                newDriverToInsert.add(eachDr);
                            }
                        }
                        
                        if (!newDriverToInsert.isEmpty()) {
                            List<Quote_Driver__c> quoteDriverNewList = new List<Quote_Driver__c>();
                            for (Driver__c eachNewDriver : newDriverToInsert) {
                                Quote_Driver__c newQuoteDriverData = new Quote_Driver__c();
                                newQuoteDriverData.Account_Driver__c = userRecord.AccountId;
                                newQuoteDriverData.Contact__c = userRecord.ContactId;
                                newQuoteDriverData.Quote_c__c = quoteRecord.Id;
                                newQuoteDriverData.Vehicle_Driver__c = vehicleRecord.Id;
                                newQuoteDriverData.Driver__c = eachNewDriver.Id;
                                newQuoteDriverData.Policy__c = policyRecord.Id;
                                quoteDriverNewList.add(newQuoteDriverData);
                            }
                            
                            if (!quoteDriverNewList.isEmpty()) {
                                insert quoteDriverNewList;
                            }
                        }
                    }
                }
            }
            try {
                if (String.isNotBlank(vehicleData) && !String.isEmpty(DriverData)) {
                    List<Driver__c> allDrivers = (List<Driver__c>) JSON.deserialize(DriverData, List<Driver__c>.class);

                    System.debug('All drivers@@###' + allDrivers);

                    // Filter drivers by Driver_Type__c values
                    List<Driver__c> filteredDrivers = new List<Driver__c>();
                    for (Driver__c d : allDrivers) {
                        // You can adjust this condition as needed
                        String driverType = d.Driver_Type__c.toLowerCase();
                            if (driverType == 'true' || driverType == 'owner' || driverType == 'co-owner' || driverType == 'owner & driver') {
                                filteredDrivers.add(d);
                            }
                    }

                    System.debug('Filtered drivers@@###' + filteredDrivers);

                    if (!filteredDrivers.isEmpty()) {
                        Driver__c ownerDriver = filteredDrivers[0];
                        vehicleRecord.Vehicle_Owner_Name__c = ownerDriver.First_Name__c + ' ' + ownerDriver.Last_Name__c;
                        vehicleRecord.Vehicle_Owner_Phone__c = ownerDriver.Phone__c;
                        vehicleRecord.Vehicle_Owner_Address__c = ownerDriver.Address__c;
                        vehicleRecord.Vehicle_Owner_Driver_License__c = ownerDriver.license_number__c;
                        vehicleRecord.Vehicle_Owner_Driver_License_State__c = ownerDriver.License_state__c;
                        vehicleRecord.Vehicle_Owner_City__c = ownerDriver.City__c;
                        vehicleRecord.Vehicle_Owner_State__c = ownerDriver.State_Province__c;
                        vehicleRecord.Vehicle_Owner_Postal_Code__c = ownerDriver.Postal_Code__c;
                        vehicleRecord.Vehicle_Owner_Country__c = ownerDriver.Country__c;
                        vehicleRecord.Is_the_vehicle_registered_to_a_business__c = false;
                        vehicleRecord.Company_Name__c = '';
                        vehicleRecord.Company_Phone__c = '';
                        vehicleRecord.Tax_ID__c = '';
                        vehicleRecord.Company_Country__c = '';
                        vehicleRecord.Company_Address__c = '';
                        vehicleRecord.Company_Zip__c = '';
                        vehicleRecord.Company_State__c = '';
                        vehicleRecord.Company_City__c = '';
                        update vehicleRecord;
                        System.debug('vehicleRecord@@###' + vehicleRecord);

                        responseMap.put('status', 'success');
                        responseMap.put('vehicleData', vehicleRecord);
                    } 
                } 
            } catch (Exception e) {
                responseMap.put('status', 'error');
                responseMap.put('message', e.getMessage());
            }
            
            if (!String.isEmpty(towedUnitData)) {
                
                towedRecord = (List<Towed_Unit__c>) JSON.deserialize(towedUnitData, List<Towed_Unit__c>.class);
                System.debug('towedRecord-->'+towedRecord);
                if (quoteRecord.Towed_Unit__c == 'Yes' && !towedRecord.isEmpty()) {
                    upsert towedRecord;
                    List<Quote_Vehicle__c> vehicledatanew = [SELECT Id FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteRecord.Id LIMIT 1];
                    Quote_Vehicle__c quoteVehicleRecord;
                    if(vehicledatanew.size() > 0){
                        quoteVehicleRecord = vehicledatanew[0];
                    }
                    System.debug('vehicledatanew-->'+vehicledatanew);
                    System.debug('quoteVehicleRecord-->'+quoteVehicleRecord);
                    List<Quote_Towed_Unit__c> quoteTowRecord = [SELECT Id, Towed_Unit__c FROM Quote_Towed_Unit__c WHERE Quote_c__c = :quoteRecord.Id];
                    System.debug('quoteTowRecord-->'+quoteTowRecord);
                    Map<String,String> towedIdVsQuoteTowedId = new Map<String,String>();
                    List<Quote_Towed_Unit__c> deleteQuoteTowedRecord = new List<Quote_Towed_Unit__c>();
                    Set<Id> getQuoteTowedId = new Set<Id>();
                    if (!quoteTowRecord.isEmpty()) {
                        for(Quote_Towed_Unit__c quoteTowed : quoteTowRecord){
                            towedIdVsQuoteTowedId.put(quoteTowed.Towed_Unit__c,quoteTowed.Id);
                        }
                    }
                    System.debug('towedIdVsQuoteTowedId'+towedIdVsQuoteTowedId);
                    for(Towed_Unit__c towed : towedRecord){
                        if(towedIdVsQuoteTowedId.containskey(towed.Id)){
                            getQuoteTowedId.add(towedIdVsQuoteTowedId.get(towed.Id));
                            
                        }
                    }
                    System.debug('getQuoteTowedId-->'+getQuoteTowedId);
                    if(getQuoteTowedId.size() > 0){
                        deleteQuoteTowedRecord = [SELECT Id FROM Quote_Towed_Unit__c WHERE Id NOT IN: getQuoteTowedId AND Quote_c__c = :quoteRecord.Id LIMIT 50];
                    }else{
                        deleteQuoteTowedRecord = quoteTowRecord;
                    }
                    System.debug('deleteQuoteTowedRecord-->'+deleteQuoteTowedRecord);
                    if(deleteQuoteTowedRecord.size() > 0){
                        delete deleteQuoteTowedRecord;
                    }
                    
                    if (quoteTowRecord.isEmpty()) {
                        List<Quote_Towed_Unit__c> quoteTowedList = new List<Quote_Towed_Unit__c>();
                        for (Towed_Unit__c eachTow : towedRecord) {
                            Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
                            newQuoteTowed.Account__c = userRecord.AccountId;
                            newQuoteTowed.Contact__c = userRecord.ContactId;
                            newQuoteTowed.Quote_c__c = quoteRecord.Id;
                            newQuoteTowed.Quote_Vehicle__c = quoteVehicleRecord.Id;
                            newQuoteTowed.Towed_Unit__c = eachTow.Id;
                            newQuoteTowed.Policy__c = policyRecord.Id;
                            quoteTowedList.add(newQuoteTowed);
                        }
                        
                        if (quoteTowedList != null && !quoteTowedList.isEmpty()) {
                            upsert quoteTowedList;
                        }
                    } else {
                        Map<Id, Quote_Towed_Unit__c> quoteTowedMap = new Map<Id, Quote_Towed_Unit__c>();
                        List<Towed_Unit__c> newTowedToInsert = new List<Towed_Unit__c>();
                        for (Quote_Towed_Unit__c eachQuoteTowed : quoteTowRecord) {
                            if (!quoteTowedMap.containsKey(eachQuoteTowed.Id)) {
                                quoteTowedMap.put(eachQuoteTowed.Towed_Unit__c, eachQuoteTowed);
                            }
                        }
                        
                        for (Towed_Unit__c eachTowedUnit : towedRecord) {
                            if (!quoteTowedMap.containsKey(eachTowedUnit.Id)) {
                                newTowedToInsert.add(eachTowedUnit);
                            }
                        }
                        
                        if (!newTowedToInsert.isEmpty()) {
                            List<Quote_Towed_Unit__c> quoteTowedNewList = new List<Quote_Towed_Unit__c>();
                            for (Towed_Unit__c eachNewTow : newTowedToInsert) {
                                Quote_Towed_Unit__c newQuoteTowedData = new Quote_Towed_Unit__c();
                                newQuoteTowedData.Account__c = userRecord.AccountId;
                                newQuoteTowedData.Contact__c = userRecord.ContactId;
                                newQuoteTowedData.Quote_c__c = quoteRecord.Id;
                                newQuoteTowedData.Quote_Vehicle__c = quoteVehicleRecord.Id;
                                newQuoteTowedData.Towed_Unit__c = eachNewTow.Id;
                                newQuoteTowedData.Policy__c = policyRecord.Id;
                                quoteTowedNewList.add(newQuoteTowedData);
                            }
                            
                            if (!quoteTowedNewList.isEmpty()) {
                                upsert quoteTowedNewList;
                            }
                        }
                    }
                }
            }
            
            responseMap.put('status', 'success');
        }catch(Exception ex){
            CustomErrorExceptionHandlerException.data = 'quoteData: '+quoteData+'\nDriverData: '+DriverData+'\nvehicleData: '+vehicleData+'\ntowedUnitData: '+towedUnitData;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status','error');
            responseMap.put('message', ex.getMessage());
            System.debug('Error: '+ex.getMessage() + 'at line number:' + ex.getLineNumber());
        }
        return responseMap;
    }
    
    public static string purchaseSaveDetails(String quotes, String leadId, boolean PolicyFromLead){
        
        System.debug('quotes---> '+quotes);
        Quote__c quoteRecord = new Quote__c();
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quotes);
        // String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
        // String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
        String startTime = (String) jsonMap.get('Start_Time__c');
        if (startTime != null && startTime != '') {
            startTime = startTime.trim();
            if (!startTime.endsWith('Z')) {
                startTime += 'Z';
            }
        }
        
        // Safely format End_Time__c
        String endTime = (String) jsonMap.get('End_Time__c');
        if (endTime != null && endTime != '') {
            endTime = endTime.trim();
            if (!endTime.endsWith('Z')) {
                endTime += 'Z';
            }
        }
        jsonMap.put('Start_Time__c', startTime);
        jsonMap.put('End_Time__c', endTime);
        system.debug('jsonMap:---->'+jsonMap);quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
        
        //quoteRecord = (Quote__c)JSON.deserialize(quotes, Quote__c.class);
        
        if(PolicyFromLead == true){
            quoteRecord.Lead__c = leadId;
        }else{
            quoteRecord.Contact__c = leadId;
        }
        upsert quoteRecord;
        System.debug('quoteRecord---> '+quoteRecord);
        if(PolicyFromLead == true){
            List<Lead> leadRecords = [SELECT Id, Insurance_Type__c, Vehicle_Details__c,Watercraft_Detail__c,  Quote_Details__c FROM Lead Where Id = :leadId LIMIT 1];
            if (!leadRecords.isEmpty()) {
                Map<String, Object> vehicleDetailsMap; Lead leadRecord = leadRecords.get(0);
                if(leadRecord.Insurance_Type__c == 'Watercraft'){vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Watercraft_Detail__c);
                                                                }else{vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Vehicle_Details__c);}  vehicleDetailsMap.put('Coverage__c', quoteRecord.Coverage__c);
                leadRecord.Vehicle_details__c = JSON.serialize(vehicleDetailsMap); leadRecord.Quote_Details__c = JSON.serialize(quoteRecord);
                update leadRecord;
                return JSON.serialize(leadRecord);
            }
        }else{
            List<Contact> contactRecords = [SELECT Id, Watercraft_Detail__c, Vehicle_details__c, Quote_Details__c  FROM Contact Where Id = :leadId LIMIT 1];
            if (!contactRecords.isEmpty()) {
                Map<String, Object> vehicleDetailsMap;
                Contact contactRecord = contactRecords.get(0);
                if(contactRecord.Watercraft_Detail__c != null){vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(contactRecord.Watercraft_Detail__c);
                                                              }else{ vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(contactRecord.Vehicle_details__c);
                                                                   }
                
                vehicleDetailsMap.put('Coverage__c', quoteRecord.Coverage__c);
                contactRecord.Vehicle_details__c = JSON.serialize(vehicleDetailsMap);
                contactRecord.Quote_Details__c = JSON.serialize(quoteRecord);
                update contactRecord;
                return JSON.serialize(contactRecord);
            }
        }
        return null;
    }
    

    public static Boolean saveInfoBeforePayment(String leadId, String quotedata, String vehicleData,
    		String termsAndAlerts, String driverDetails, String termOptions, String towedDetails){
        try {
            if(String.isNotBlank(quotedata)){
                Quote__c quoteDetails = new Quote__c();
                quoteDetails = (Quote__c)JSON.deserialize(quotedata, Quote__c.class);
                upsert quoteDetails;
                Lead quoteLead = new Lead();
                quoteLead.Id = leadId;
                if(String.isNotBlank(vehicleData)){ quoteLead.Vehicle_details__c = vehicleData;}
                if(String.isNotBlank(driverDetails)){quoteLead.Driver_details__c = driverDetails;}
                if(String.isNotBlank(towedDetails)){quoteLead.Towing__c = towedDetails;}
                if(String.isNotBlank(termOptions)){quoteLead.Term_options__c = termOptions;}
                if(String.isNotBlank(termsAndAlerts)){quoteLead.Terms_Alert__c = termsAndAlerts;}
                upsert quoteLead;
                return true;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' line number -'+e.getlineNumber());
        }
        return false;
    }

    public static Map<String, Object> createCloneQuote(String quote){
        Map<String, String> responseMap = new Map<String, String>();
        try {
            
            if (!String.isEmpty(quote)) {
                System.debug('createCloneQuote ----quote'+quote);
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quote);
                String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
                String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
                jsonMap.put('Start_Time__c', startTime);
                jsonMap.put('End_Time__c', endTime);
                system.debug('jsonMap:---->'+jsonMap);
                //quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
                
                Quote__c quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
                System.debug('createCloneQuote ----quoteRecord'+quoteRecord);
                Database.SaveResult quoteData = Database.insert(quoteRecord, true);
                
                if (quoteData.isSuccess()) { responseMap.put('status', 'success'); responseMap.put('data', quoteData.getId());} else {List<Database.Error> err = new List<Database.Error>(quoteData.getErrors());responseMap.put('status', 'success');responseMap.put('message', err[0].getMessage());}
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'quote: ' + quote;CustomErrorExceptionHandlerException.LogException(ex);responseMap.put('status', 'error');responseMap.put('message', ex.getMessage());
        }
        return responseMap;
    }

    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public class TermAndConditionWrapper {
        Public Boolean Terms_of_Purchase_Confirmed_Tempc {get;set;}
        Public Boolean Terms_of_Cancellation_Confirmed_Tempc{get;set;}
        Public String What_is_your_trip_destination_in_US_Tempc{get;set;}
        Public String What_is_the_purpose_of_trip_Tempc{get;set;}
        Public Boolean Newsletter_Tempc{get;set;}
    }
}