public without sharing class AgentAppController {
    
    @AuraEnabled
    public static List<LeadWrapper> getDataByObj(String leadName,String userId) {
        List<User> userDetail = [SELECT Name, ContactId, User_Type__c FROM User Where Id = :userId LIMIT 1];
        System.debug('leadName:::'+leadName);
        System.debug('userId:::'+userId);
        System.debug('userDetail:::'+userDetail);
        List<LeadWrapper> leadWrap = new List<LeadWrapper>();
        List<lead> leadData = new List<Lead>();
        
        if(userDetail[0].User_Type__c == 'External') {
            
            if(leadName != null && leadName != '' && leadName != 'undefined'){
                leadData = [Select Id, Name, Company, Status, CreatedDate, Email, Agent__r.Name, Agency__r.Name from Lead WHERE Agency__c = :userDetail[0].contactId AND (Name LIKE :('%' +leadName + '%') OR Agent__r.Name LIKE :('%' +leadName + '%') OR Agency__r.Name LIKE :('%' +leadName + '%')) AND IsConverted = FALSE ORDER BY createddate DESC LIMIT 50000];
            }else{
                leadData = [Select Id, Name, Company, Status, CreatedDate, Email, Agent__r.Name, Agency__r.Name from Lead WHERE Agency__c = :userDetail[0].contactId AND IsConverted = FALSE ORDER BY createddate DESC LIMIT 50000];
            }
            System.debug('INSIDE EXTERNAL:::'+leadData);
            for(Lead ldata : leadData) {
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
        
        if(userDetail[0].User_Type__c == 'Agency' || userDetail[0].User_Type__c == 'Internal') {
            if(leadName != null && leadName != '' && leadName != 'undefined'){
                leadData = [Select Id, Name, Company, Status, CreatedDate, Email, Agent__r.Name, Agency__r.Name from Lead WHERE Agency__c = :userDetail[0].contactId AND (Name LIKE :('%' +leadName + '%') OR Agent__r.Name LIKE :('%' +leadName + '%') OR Agency__r.Name LIKE :('%' +leadName + '%')) AND IsConverted = FALSE ORDER BY createddate DESC LIMIT 50000];
            }else{
                leadData = [Select Id, Name, Company, Status, CreatedDate, Email, Agent__r.Name, Agency__r.Name from Lead WHERE Agency__c = :userDetail[0].contactId AND IsConverted = FALSE ORDER BY createddate DESC LIMIT 50000];
            }
            System.debug('INSIDE AGENCY:::'+leadData);
            for(Lead ldata : leadData) {
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
        System.debug('leadWrap:::'+leadWrap);
        return leadWrap;
    }
    
    @AuraEnabled
    public static string saveLeadDetails(String leadJson, String quoteJSON, String vehicleJSON, String towedlistJSON){
        try {
            if(String.isNotBlank(leadJson)){
                
                Id loggedInUserId = UserInfo.getUserId();
                String agentId ='';
                Contact agentContact = new Contact();
                List<Contact> customerContact = new List<Contact>();
                User getUserInfo = new User();
                
                if(loggedInUserId != null){
                    getUserInfo = [Select Id,User_Type__c,Email FROM User WHERE Id =: loggedInUserId LIMIT 1];
                    
                    if(getUserInfo.User_Type__c == 'Customer' || getUserInfo.User_Type__c == null){agentId = [Select id from contact where email =: getUserInfo.email  Limit 1].Id;
                    }else if(loggedInUserId != null){
                        List<User> userdata =  [Select id,ContactId  from user WHERE Id =: loggedInUserId LIMIT 1];
                        if(userdata[0].ContactId != null){ agentId = [Select id,ContactId  from user WHERE Id =: loggedInUserId LIMIT 1].ContactId; }
                    }
                }
                
                if(agentId != null){
                    List<Contact> contactData = [Select id,name, Agency__c from Contact WHERE Id =: agentId LIMIT 1];
                    if( contactData.size() > 0){  agentContact = contactData[0];}
                }
                
                Lead getLeadData = new Lead();
                getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
                getLeadData.Company = getLeadData.FirstName + ' '+ getLeadData.LastName;
                getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
                getLeadData.Quote_Details__c = quoteJSON;
                if(getLeadData.Policy_Type__c == 'Watercraft'){
                    getLeadData.Watercraft_Detail__c = vehicleJSON;
                }else{
                    getLeadData.Vehicle_Details__c = vehicleJSON;
                }
                
                if(agentContact.Agency__c != null){
                    getLeadData.Agency__c = agentContact.Agency__c;
                }else{
                    getLeadData.Agency__c = agentContact.Id;
                }
                getLeadData.Agent__c = agentContact.Id;
                
                getLeadData.Towing__c = towedlistJSON;
                System.debug('Lead Before Saving'+getLeadData);
                upsert getLeadData;
                System.debug('Lead AFTER Saving'+getLeadData);
                return JSON.serialize(getLeadData);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    
    @AuraEnabled
    public static string purchaseSaveDetails(String quotes, String leadId, boolean PolicyFromLead){
        try {
            System.debug('quotes---> '+quotes);
            Quote__c quoteRecord = new Quote__c();
            
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quotes);
            String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
            String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
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
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
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
    
    @AuraEnabled
    public static Boolean saveLeadDestinationInfoBeforePayment(String leadId,String termsAndAlerts){
        try {
            if(String.isNotBlank(leadId)){
                Lead quoteLead = new Lead();
                quoteLead.Id = leadId;
                if(String.isNotBlank(termsAndAlerts)){
                    quoteLead.Terms_Alert__c = termsAndAlerts;
                }
                update quoteLead;
                return true;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' line number -'+e.getlineNumber());
        }
        return false;
    }
    
    @AuraEnabled
    public static String updateContactDestinationDetails(String contactId,String termsAlert) {
        if(contactId != null) {
            try{
                Contact con = new Contact();
                con.Id = contactId;
                con.Terms_Alert__c = termsAlert;
                update con;
                
                return 'success';
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return 'Error';
        }
    }
    
    
    @AuraEnabled
    public static map<string, object> paymentThroughCard(String transactionDetails, String paymentDetails, String email){
        try {
            return PaymentFormController.createTransaction(paymentDetails,transactionDetails,email);
        }catch (AuraHandledException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
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
    
    @AuraEnabled
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
    
    @AuraEnabled
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
                vehicleRecord = (Vehicle__c) JSON.deserialize(vehicleData, Vehicle__c.class);
                
                if (vehicleRecord != null) {
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
    
    @AuraEnabled
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
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
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
    
    @AuraEnabled(cacheable=true)
    public static String getExternalIp() {
        return Auth.SessionManagement.getCurrentSession().get('SourceIp');
    }
    
    // Search details From Lead, Quote, Contact and Policy
    @AuraEnabled
    public static String searchDetails(String searchKey, String agencyId) {
        Map<String, String> allSearchData = new Map<String, String>();
        try{
            
            String searchKeyWord= '%'+searchKey+'%';
            List<Lead> leadData = new List<Lead>();
            List<Quote__c> quoteData = new List<Quote__c>();
            List<Policy__c> policyData = new List<Policy__c>();
            List<Contact> contactData = new List<Contact>();
            List<Contact> contactAgencyData = new List<Contact>();
            System.debug('searchKey::'+searchKey);
            System.debug('agencyId::'+agencyId);
            
            if(agencyId != null && agencyId != ''){
                System.debug('INSIDE IFFF::');
                leadData = [SELECT Id, Name, Phone, Email, IsConverted FROM Lead WHERE (Name LIKE :searchKeyWord OR Email LIKE :searchKeyWord) AND IsConverted = false AND (Agency__c =: agencyId OR Agent__c =: agencyId)];
                quoteData = [Select Id, Name, Vehicle_Type__c, Vehicle_Year__c, Vehicle_Make__c, Vehicle_Model__c, Vehicle_Value__c, Coverage__c, Term__c, Term_Days__c, Quote_Value__c, Account__c, Lead__c, Annual_Term__c, Any_Boat_Operator_Under_22__c, Broker_Policy_Fee__c, Contact__c, Date_of_Birth__c, Driver_Age__c, End_Date_for_Coverage__c, End_Time__c, I_V_A_Mex_Tax__c, Is_the_Maximum_Speed_more_than_50_mph__c, Is_the_owner_living_in_Mexico__c, Is_there_a_driver_over_75__c, Is_there_a_driver_under_21__c, Is_this_a_Rental_Vehicle__c, Liability_Coverage__c, Liability__c, Medical_Coverage__c, Medical__c, Net_Premium__c, Policy_Type__c, Policy_Type_picklist__c, Policy__c, Property_Damage_Liability__c, Quote_Status__c, Salvage_Vehicle__c, Start_Date_for_Coverage__c, Start_Time__c, Territory_Coverage__c, Territory__c, Time_Zone__c, Towed_Unit__c, Trailering__c, Type_of_Vessel__c, Underwriter__c, Vehicle_Age__c, Vehicle_Make_WS__c, Vehicle_Year_WS__c, Vehicle_used_for_Business_Purposes__c, Vessel_Length__c, Vehicle_Sub_type__c, Renew_Quote__c, Surcharge__c, Third_Party_Bodily_Injury__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Vehicle__c, Policy_Fee__c, Lead_Id__c, Physical_Damage__c, Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Platinum_Endorsment__c, QuotePdfJson__c FROM Quote__c WHERE (Name LIKE :searchKeyWord OR Lead__r.Email LIKE :searchKeyWord OR Id = :searchKey) AND Term_Days__c != NULL AND (Contact__r.Agency__c =: agencyId OR Contact__r.Agent__c =: agencyId)];
                contactData = [SELECT Id, Name, Phone, Email,(SELECT Id, Username FROM Users ) FROM Contact WHERE (Name LIKE :searchKeyWord OR Email LIKE :searchKeyWord OR Phone LIKE :searchKeyWord)  AND (Agency__c =: agencyId OR Agent__c =: agencyId)];
                policyData = [SELECT Id, Name, Contact_Email__c, Policy_Type_picklist__c , Status_picklist__c, Term_days__c, Term__c, Contact__c, Quote_c__c, Start_Date__c, Start_Time__c,End_Date__c , Issued_At__c, Contact__r.Email FROM Policy__c WHERE (Name LIKE :searchKeyWord OR Contact_Email__c LIKE :searchKeyWord OR Contact__r.Name LIKE :searchKeyWord OR Contact__r.Email LIKE :searchKeyWord) AND  Status_picklist__c != 'Updated' AND (Contact__r.Agency__c =: agencyId OR Contact__r.Agent__c =: agencyId)];
                contactAgencyData = [SELECT Id, Name, Phone, Email FROM Contact WHERE Email =:searchKeyWord  AND Agency__c !=: agencyId AND Agent__c !=: agencyId];
               
            }else{
                System.debug('INSDIE ELSEE::');
                leadData = [SELECT Id, Name, Phone, Email, IsConverted FROM Lead WHERE (Name LIKE :searchKeyWord OR Email LIKE :searchKeyWord) AND IsConverted = false];
                quoteData = [Select Id, Name, Vehicle_Type__c, Vehicle_Year__c, Vehicle_Make__c, Vehicle_Model__c, Vehicle_Value__c, Coverage__c, Term__c, Term_Days__c, Quote_Value__c, Account__c, Lead__c, Annual_Term__c, Any_Boat_Operator_Under_22__c, Broker_Policy_Fee__c, Contact__c, Date_of_Birth__c, Driver_Age__c, End_Date_for_Coverage__c, End_Time__c, I_V_A_Mex_Tax__c, Is_the_Maximum_Speed_more_than_50_mph__c, Is_the_owner_living_in_Mexico__c, Is_there_a_driver_over_75__c, Is_there_a_driver_under_21__c, Is_this_a_Rental_Vehicle__c, Liability_Coverage__c, Liability__c, Medical_Coverage__c, Medical__c, Net_Premium__c, Policy_Type__c, Policy_Type_picklist__c, Policy__c, Property_Damage_Liability__c, Quote_Status__c, Salvage_Vehicle__c, Start_Date_for_Coverage__c, Start_Time__c, Territory_Coverage__c, Territory__c, Time_Zone__c, Towed_Unit__c, Trailering__c, Type_of_Vessel__c, Underwriter__c, Vehicle_Age__c, Vehicle_Make_WS__c, Vehicle_Year_WS__c, Vehicle_used_for_Business_Purposes__c, Vessel_Length__c, Vehicle_Sub_type__c, Renew_Quote__c, Surcharge__c, Third_Party_Bodily_Injury__c, Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Vehicle__c, Policy_Fee__c, Lead_Id__c, Physical_Damage__c, Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, Platinum_Endorsment__c, QuotePdfJson__c FROM Quote__c WHERE (Name LIKE :searchKeyWord OR Lead__r.Email LIKE :searchKeyWord OR Id = :searchKey) AND Term_Days__c != NULL];
                contactData = [SELECT Id, Name, Phone, Email,(SELECT Id, Username FROM Users ) FROM Contact WHERE Name LIKE :searchKeyWord OR Email LIKE :searchKeyWord OR Phone LIKE :searchKeyWord];
                policyData = [SELECT Id, Name, Contact_Email__c, Policy_Type_picklist__c , Status_picklist__c, Term_days__c, Term__c, Contact__c, Quote_c__c, Start_Date__c, Start_Time__c,End_Date__c , Issued_At__c, Contact__r.Email FROM Policy__c WHERE (Name LIKE :searchKeyWord OR Contact_Email__c LIKE :searchKeyWord OR Contact__r.Name LIKE :searchKeyWord OR Contact__r.Email LIKE :searchKeyWord) AND  Status_picklist__c != 'Updated'];
                
            }
            System.debug('contactAgencyData::'+contactAgencyData);
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
        String query = 'Select Id,ConvertedContactId, LastName, FirstName, Name, Company, Street, City, State, PostalCode, Country, Address, Phone, Email, City__c, Full_Name__c,'+
            'Vehicle_Type__c, Vehicle_Value__c, Term__c, Policy_Type__c, Start_Date_for_Coverage__c,'+
            'Coverage__c, Territory_Options__c, Liability_Coverage__c, Medical_Coverage__c, Vehicle_will_be_used_for_business_purpos__c,'+
            'End_Date_for_Coverage__c, State__c, Model__c, Make__c, Year_A__c, Year__c, Zip_Code__c, Quote_Term__c,'+
            'Quote_Value__c, Quote_Vehicle_Make__c, Quote_Vehicle_Model__c, Quote_Vehicle_Type__c, Quote_Vehicle_Value__c, Quote_Vehicle_Year__c,'+
            'Date_of_Birth__c, Vehicle_details__c, Term_days__c, Is_towing__c, Days_in_tow__c, Towing__c,'+
            'Underwriter_picklist__c, Review_vehicle__c, Company_details__c, Lienholder_info__c, Country__c, Driver_details__c, Terms_Alert__c,'+
            'Vehicle_sub_type__c, Term_options__c, Quote_Details__c, Watercraft_Detail__c, Liability__c, (SELECT Id, OwnerId, Name, Vehicle_Type__c, Vehicle_Year__c, Vehicle_Make__c, Vehicle_Model__c,'+
            'Vehicle_Value__c, Coverage__c, Term__c, Term_Days__c, Quote_Value__c, Account__c, Lead__c, Annual_Term__c, Any_Boat_Operator_Under_22__c, Broker_Policy_Fee__c, Contact__c, Date_of_Birth__c, Driver_Age__c,'+
            'End_Date_for_Coverage__c, End_Time__c, I_V_A_Mex_Tax__c, Is_the_Maximum_Speed_more_than_50_mph__c, Is_the_owner_living_in_Mexico__c, Is_there_a_driver_over_75__c, Is_there_a_driver_under_21__c, '+
            'Is_this_a_Rental_Vehicle__c, Liability_Coverage__c, Liability__c, Medical_Coverage__c, Medical__c, Net_Premium__c, Policy_Type__c, Policy_Type_picklist__c, Policy__c, Property_Damage_Liability__c, '+
            'Quote_Status__c, Salvage_Vehicle__c, Start_Date_for_Coverage__c, Start_Time__c, Territory_Coverage__c, Territory__c, Time_Zone__c, Towed_Unit__c, Trailering__c, Type_of_Vessel__c, Underwriter__c, '+
            'Vehicle_Age__c, Vehicle_Make_WS__c, Vehicle_Year_WS__c, Vehicle_used_for_Business_Purposes__c, Vessel_Length__c, Vehicle_Sub_type__c, Renew_Quote__c, Surcharge__c, Third_Party_Bodily_Injury__c, '+
            'Vehicle_Deductible_Collision__c, Vehicle_Deductible_Comprehensive__c, Vehicle__c, Policy_Fee__c, Lead_Id__c, Physical_Damage__c, Total_Theft_Payment__c, Liability_Payment__c, Medical_Payment__c, '+
            'Platinum_Endorsment__c, QuotePdfJson__c,Old_Net_Premium__c,Agent_Fee__c FROM Quotes__r) FROM Lead';
        
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
            }
            
            return existData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Get contact details by ID
    @AuraEnabled
    public static String fetchContactDetails(String contactId) {
        if(contactId != null) {
            try{
                Contact[] contactDetails = [SELECT Id, Name, LastName, FirstName, Phone, Email, CreatedDate, LastModifiedDate, Country__c, City__c, State__c, Street__c, Term_options__c, Driver_details__c, Terms_Alert__c, Towing__c, Watercraft_Detail__c, Vehicle_details__c, Quote_Details__c,Agent_Fee__c,Old_Net_Premium__c,                                            
                                            (SELECT Id, Name, Contact_Email__c, Policy_type_picklist__c , Status_picklist__c, Term_days__c, Term__c, Start_Date__c, Start_Time__c, Issued_At__c, Agent_Brokerage_Fee__c FROM Policies__r WHERE Status_picklist__c != 'Updated'),
                                            (SELECT Id, Name, Contact__c, Lead__c, Policy_Type_picklist__c, Term_Days__c, Start_Date_for_Coverage__c, End_Date_for_Coverage__c FROM Quotes__r),
                                            (SELECT Name, Id, license_number__c, License_Country__c, License_state__c, City__c FROM Drivers__r),
                                            (SELECT Name, Id, Vin__c, Make__c, Model__c, Lienholder_name__c FROM Vehicle__r)
                                            FROM Contact WHERE Id = :contactId];
                
                if(contactDetails.size() < 1){
                    Contact con = new contact();
                    Lead leadData = [SELECT LastName, FirstName, Phone, Email FROM Lead WHERE ConvertedContactId =: contactId];
                    con.firstName = leadData.FirstName;
                    con.LastName = leadData.LastName;
                    con.Phone = leadData.Phone;
                    con.Email = leadData.Email;
                    contactDetails.add(con);
                }
                return JSON.serialize(contactDetails);
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return 'Error';
        }
    }
    
    // Update contact details by ID
    @AuraEnabled
    public static String updateContactDetails(Boolean Istowing, String contactId, String termOptions, String driverDetails, String termsAlert, String towedlistJSON, String WatercraftDetails, String vehicledetails, String quoteDetails) {
        if(contactId != null) {
            try{
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
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            return 'Error';
        }
    }
    
    @AuraEnabled
    public static User portalAccessForUser(string username) {
        List<User> userList = [SELECT Id, Name, IsActive FROM User WHERE Email = :username LIMIT 1];
        
        if (userList != null && !userList.isEmpty()) {
            return userList[0];
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String insertContactsFeature (String contactDetails){
        try{
            String reusltId = '';
            List<Contact> contactList = new List<Contact>();
            Contact contact = new Contact();
            contact = (contact)JSON.deserialize(contactDetails, contact.class);
            contact.Source__c = 'DMV Service';
            
            if(contact.Email != null){
                contactList = [SELECT Id, Name FROM Contact WHERE email =: contact.Email LIMIT 1];
            }
            
            if(contactList.size() > 0){
                return 'False';
            }
            
            insert contact;
            reusltId = contact.Id;
            return reusltId;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createUserForContact(String contactId){
        try{
            System.debug('contactId'+contactId);
            if(contactId != null){
                Id AccountId;
                Contact con = [SELECT Id,name, email,FirstName,LastName,Phone FROM Contact WHERE Id =: contactId LIMIT 1];
                List<Account> acc = [SELECT Id, Name, Email__c FROM Account WHere Email__c =: con.Email LIMIT 1];
                System.debug('con'+con);
                System.debug('acc'+acc);
                if(acc.size() < 1) {
                    Account dupAc = new Account();
                    dupAc.Name = con.Name;
                    dupAc.Email__c = con.Email;
                    Database.insert(dupAc);
                    con.AccountId = dupAc.Id;
                    Database.update(con);
                    AccountId = dupAc.Id;
                }else{
                    AccountId = acc[0].Id;
                }
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];
                System.debug('portalProfile'+portalProfile);
                String userFName = con.FirstName.substring(0,1);
                String userLName = con.LastName.length() >=3 ? con.LastName.substring(0, 3):con.LastName;
                User newUser = new User(
                    Username = con.Email,
                Email = con.Email,
                LastName = con.LastName,
                FirstName = con.FirstName != null ? con.FirstName : '',
                Phone = con.Phone != null ? con.Phone : '',
                Alias = (con.FirstName != null && con.LastName != null) ? userFName + ' ' + userLName : (con.FirstName == null && con.LastName != null) ? userLName : '',
                contactId = con.Id,
                profileId = portalProfile.Id,
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
                    );
                Database.insert(newUser);
                
            }
            return 'Success';
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage() + ' at line no :' +e.getLineNumber());
            return 'Error : ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string updateContactEmail(String email, String contactId){
        try{
            List<Contact> existContact = [SELECT Id,Name FROM Contact WHERE Email =: email LIMIT 50000];
            if(existContact.size() < 1){
                Contact con = new Contact();
                con.Id = contactId;
                con.Email = email;
                
                update con;
                return 'Success';
            }else{
                return 'Error This email already exist in another contact';
            }
            
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage() + ' at line no :' +e.getLineNumber());
            return 'Error : ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string getDriverData(String contactId){
        try{
            if(ContactId != null){
                List<Driver__c> driverList = [Select Id,Name,First_Name__c, Last_Name__c,license_number__c,License_Country__c,License_state__c,Dob__c, Driver_Type__c , Country__c, Postal_Code__c, 
                                              State_Province__c,City__c, Address__c, Phone__c from Driver__c where Contact__c =: contactId ];
                
                if(driverList.size() > 0){
                    return JSON.serialize(driverList);
                }
            }
            return null;
        }catch(Exception e){
            System.debug('Error : '+e.getMessage() + ' at line number : ' + e.getlinenumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getVehicleData(String vehicleId){
        try {
            List<Vehicle__c> vehicles = new List<Vehicle__c>();
            if(vehicleId != null){
                vehicles = [Select Id, Name, Vin__c, Is_vehicle_owned_by_a_company_or_rented__c,Make__c, Model__c, Year__c, Value__c, Vehicle_Type__c, Salvage_Vehicle__c, Registered_Country__c,Registered_Plate__c, Registered_State__c, Vehicle_Owner_Driver_License_State__c, Is_there_a_driver_under_21__c,
                        Is_the_vehicle_used_for_business_purpose__c, Is_the_vehicle_registered_to_a_business__c from Vehicle__c Where Contact__c  =:vehicleId];
            }
            return JSON.serialize(vehicles);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
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
                
                if (quoteData.isSuccess()) {
                    responseMap.put('status', 'success');
                    responseMap.put('data', quoteData.getId());
                    
                } else {
                    List<Database.Error> err = new List<Database.Error>(quoteData.getErrors());
                    responseMap.put('status', 'success');
                    responseMap.put('message', err[0].getMessage());
                }
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'quote: ' + quote;
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static void updateQuoteTime(String quoteDataUpdate, String quoteId){
        try{
            System.debug(' updateQuoteTime----quoteDataUpdate'+quoteDataUpdate);
            if (!String.isEmpty(quoteDataUpdate)) {
                
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(quoteDataUpdate);
                String startTime = (String)jsonMap.get('Start_Time__c') + 'Z';
                String endTime = (String)jsonMap.get('End_Time__c') + 'Z';
                jsonMap.put('Start_Time__c', startTime);
                jsonMap.put('End_Time__c', endTime);
                system.debug('jsonMap:---->'+jsonMap);
                
                Quote__c quoteRecord = (Quote__c) JSON.deserialize(JSON.serialize(jsonMap), Quote__c.class);
                quoteRecord.Id = quoteId;
                System.debug('updateQuoteTime ----quoteRecord'+quoteRecord);
                update quoteRecord;
            }
        }catch(Exception e){
            System.debug('Error :'+e.getMessage() + 'at line number : '+e.getLineNumber());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact getLoggedInContactData(String UserId) {
        // Get the User record
        User currentUser = [SELECT ContactId,email FROM User WHERE Id = :UserId LIMIT 1];
        
        // Retrieve the Contact fields if ContactId is available
        if (currentUser.ContactId != null) {
            return [SELECT Id, FirstName, LastName, Email, Agent__c,Agency__c FROM Contact WHERE Id = :currentUser.ContactId LIMIT 1];
        }else{
             return [SELECT Id, FirstName, LastName, Email, Agent__c,Agency__c FROM Contact WHERE Id = :currentUser.email LIMIT 1];
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static string getUserInfo(){
        try {
            List <User> userList = [SELECT Id,User_Type__c FROM User Where Id =: UserInfo.getUserId()];
            if (userList != null && !userList.isEmpty()) {
                return JSON.serialize(userList[0]);
            }
            return 'User List is Empty';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getVendorInfo(){
        try {
            
            List <User> userList = [SELECT Id, ContactId, Email, User_Type__c FROM User Where Id =: UserInfo.getUserId()];
            if(userList != null && userList[0].ContactId != null){
                List<Contact> agentContact = [SELECT Id, Agency__c, Vendors__c FROM Contact WHERE Id =: userList[0].contactId];
                if(agentContact.size() > 0 && agentContact[0].Agency__c != null){
                    List<Contact> contactList = [SELECT Id, Vendors__c FROM Contact WHERE Id =: agentContact[0].Agency__c];
                    
                    if(contactList != null){
                        if(contactList[0].Vendors__c != null){
                            return JSON.serialize(contactList[0].Vendors__c);
                        }
                        return 'true';
                    }
                    
                    return 'true';
                }
                if(agentContact.size() > 0 && agentContact[0].Agency__c == null){
                    if(agentContact[0].Vendors__c != null){
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
        Salesforce_Api__mdt metadataRecord = [SELECT DeveloperName, Consumer_Key__c, Consumer_Secret__c, Label, Password__c, Token__c, URL__c, Username__c FROM Salesforce_Api__mdt WHERE DeveloperName = :'Fetch_data_from_salesforce' LIMIT 1];

        String accessToken = '';
        String url = metadataRecord.URL__c;
        String username = metadataRecord.Username__c;
        String password = String.valueOf(metadataRecord.Password__c) + String.valueOf(metadataRecord.Token__c);
        String clientId = metadataRecord.Consumer_Key__c;
        String clientSecret = metadataRecord.Consumer_Secret__c;
        
        String requestBody = 'grant_type=password' +
            '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse response = http.send(req);

        System.debug('response::::' + response);

        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            accessToken = (String) responseMap.get('access_token');
            System.debug('Access Token: ' + accessToken);
            return accessToken;
        } else {
            System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            return 'Error for token: ' + response.getStatus();
        }
    }
    
    @AuraEnabled
    public static Salesforce_Api__mdt getCustomMetadataForApi(String developerName){
        Salesforce_Api__mdt metadataRecord = [SELECT DeveloperName, Consumer_Key__c, Consumer_Secret__c, Label, Password__c, Token__c, URL__c, Username__c,Endpoint_Url__c FROM Salesforce_Api__mdt WHERE DeveloperName = :developerName LIMIT 1];
        return metadataRecord;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPolicyDataforPieChart(String policyTerm,String userId) {
        if (String.isBlank(userId)) {
            throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
        }
        List<String> policyTypes = new List<String>{'Automobile', 'RV', 'Motorcycle/Street Legal ATV'};
        User userRecord = [SELECT Id, Profile.Name,contactId FROM User WHERE Id = :userId LIMIT 1];
        System.debug('userRecord:::'+userRecord);
        String filterField = userRecord.Profile.Name == 'Agency Community Plus Login User' ? 'Agency__c' : 'Agent__c';
        String contactId = userRecord.contactId;
        String query ='';
        
        if (String.isBlank(policyTerm)) {
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount ' +
                'FROM Policy__c ' +
                'WHERE ' + filterField + ' = :contactId AND Policy_Type_picklist__c IN: policyTypes ' +
                'GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }else{
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount ' +
                'FROM Policy__c ' +
                'WHERE ' + filterField + ' = :contactId AND Policy_Type_picklist__c IN: policyTypes AND CreatedDate = ' + policyTerm + 
                ' GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }
        
        
        
        List<AggregateResult> aggregateResults = Database.query(query);
        List<Map<String, Object>> policyData = new List<Map<String, Object>>();
        
        for (AggregateResult result : aggregateResults) {
            policyData.add(new Map<String, Object>{
                'Policy_Type_picklist__c' => result.get('Policy_Type_picklist__c'),
                    'renewed_check__c' => result.get('renewed_check__c'),
                    'totalCount' => (Integer) result.get('totalCount')
                    });
        }
        System.debug('policyData:::'+policyData);
        return policyData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPolicyDataforBarChart(String policyTerm, String userId) {
        if (String.isBlank(userId)) {
            throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
        }
        List<String> policyTypes = new List<String>{'Automobile', 'RV', 'Motorcycle/Street Legal ATV'};
        User userRecord = [SELECT Id, Profile.Name,contactId FROM User WHERE Id = :userId LIMIT 1];
        Contact contactData = new Contact();
        String contactId = userRecord.contactId;
        String query ='';
        
        if(contactId != null){
            contactData = [SELECT id,name,Commission_Mex_Auto_Renew__c, Commission_Mex_Auto_New__c, Commission_Mex_Moto_New__c, Commission_Mex_Moto_Renew__c, Commission_Mex_RV_New__c, Commission_Mex_RV_Renew__c FROM contact WHERE id =:contactId];
        }
        if (String.isBlank(policyTerm)) {
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount,SUM(Total_Transaction_Amount__c) totalAmount FROM Policy__c WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN: policyTypes GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }else{
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount,SUM(Total_Transaction_Amount__c) totalAmount FROM Policy__c WHERE Agency__c = :contactId  AND Policy_Type_picklist__c IN: policyTypes AND CreatedDate = ' + policyTerm + 
                ' GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }
        
        List<AggregateResult> aggregateResults = Database.query(query);
        List<Map<String, Object>> policyData = new List<Map<String, Object>>();
        
        Map<String, Map<Boolean, String>> policyTypeMappings = new Map<String, Map<Boolean, String>>{
            'Automobile' => new Map<Boolean, String>{
                false => 'Commission_Mex_Auto_New__c',
                    true  => 'Commission_Mex_Auto_Renew__c'
                    },
                        'Motorcycle/Street Legal ATV' => new Map<Boolean, String>{
                            false => 'Commission_Mex_Moto_New__c',
                                true  => 'Commission_Mex_Moto_Renew__c'
                                },
                                    'RV' => new Map<Boolean, String>{
                                        false => 'Commission_Mex_RV_New__c',
                                            true  => 'Commission_Mex_RV_Renew__c'
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
                        System.debug('commissionValue::'+commissionValue);
                        System.debug('totalAmountValue:::'+totalAmountValue); 
                        System.debug('calculatedValue:::'+calculatedValue);
                        policyData.add(new Map<String, Object>{
                            'Policy_Type_picklist__c' => policyType + (isRenewed ? ' Renew' : ' New'),
                                'totalCount' => calculatedValue
                                });
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
            System.debug('searchKey: -- :'+searchKey);
            List<User> userDetail = new List<User>();
            if(searchKey != null){
                userDetail = [Select id,AccountId, Address, Agent_Account_Id__c, User_Type__c,Alias, BadgeText, BannerPhotoUrl, CallCenterId, City, ContactID,Country, IsPortalEnabled, IsActive FROM User WHERE Id =:searchKey LIMIT 1];
                System.debug('userDetail: --:'+userDetail);
                
            }
            return JSON.serialize(userDetail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     */
    
    public class LeadWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String Email;
        @AuraEnabled public String Id;
        @AuraEnabled public String Status;
        @AuraEnabled public String Company;
        @AuraEnabled public Datetime CreatedDate;
        @AuraEnabled public String Agent;
        @AuraEnabled public String Agency;
    }
    
    public class TermAndConditionWrapper {
        Public Boolean Terms_of_Purchase_Confirmed_Tempc {get;set;}
        Public Boolean Terms_of_Cancellation_Confirmed_Tempc{get;set;}
        Public String What_is_your_trip_destination_in_US_Tempc{get;set;}
        Public String What_is_the_purpose_of_trip_Tempc{get;set;}
        Public Boolean Newsletter_Tempc{get;set;}
    }
    
}