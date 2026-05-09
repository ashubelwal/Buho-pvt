public without sharing class Mex_NewLeadProcess {
    /*@AuraEnabled(cacheable=true)
    public static List<caseTypeOptions__c> getCaseTypeCustomSettings(){
        List<caseTypeOptions__c> caseTypeOptions = caseTypeOptions__c.getall().values();
       return caseTypeOptions;
    }*/

    // For fetching values of policies for google tracking services
    @AuraEnabled
    public static String fetchPolicyDetails(String policyId){
        List<Policy__c> policies = [Select Id, Name,Contact__c,Contact__r.Email, Contact__r.Phone, Total_Premium_Amount__c,Underwriter_picklist__c, Term__c, Vehicle_type__c, Territory_picklist__c, Policy_Type_picklist__c, Net_Premium__c, I_V_A_Mex_Tax__c from Policy__c Where Id =:policyId LIMIT 1 ];
        List<Transaction__c> transactions = [Select Id, Policy_Transaction__c  from Transaction__c Where Policy_Transaction__c =:policyId LIMIT 1];
        Datalayer layer = new Datalayer();
        if(policies.size() > 0){
            layer.policyId = policyId;
            layer.term = String.isNotBlank( policies.get(0).Term__c ) ? policies.get(0).Term__c : '';
            layer.underWriter = String.isNotBlank( policies.get(0).Underwriter_picklist__c ) ? policies.get(0).Underwriter_picklist__c : '';
            layer.territory = String.isNotBlank( policies.get(0).Territory_picklist__c ) ? policies.get(0).Territory_picklist__c : '';
            layer.ivaTax = String.isNotBlank( String.valueOf( policies.get(0).I_V_A_Mex_Tax__c )) ? policies.get(0).I_V_A_Mex_Tax__c : 0;
            layer.vehicleType = String.isNotBlank( policies.get(0).Vehicle_type__c ) ? policies.get(0).Vehicle_type__c : '';
            layer.policyType = String.isNotBlank( policies.get(0).Policy_Type_picklist__c ) ? policies.get(0).Policy_Type_picklist__c : '';
            layer.netPremium = String.isNotBlank( String.valueOf( policies.get(0).Net_Premium__c )) ? policies.get(0).Net_Premium__c : 0;
            layer.contactEmail = String.isNotBlank( policies.get(0).Contact__c ) ? policies.get(0).Contact__r.Email : '';
            layer.contactPhone = String.isNotBlank( policies.get(0).Contact__c ) ? policies.get(0).Contact__r.Phone : '';
            layer.policyAmount = String.isNotBlank( String.valueOf(policies.get(0).Total_Premium_Amount__c) ) ? policies.get(0).Total_Premium_Amount__c : 0;
            
        }
        if(transactions.size() > 0){
            layer.transactionId = transactions.get(0).Id;
        }
        return JSON.serialize(layer);
    }
    public class Datalayer{
        public String transactionId;
        public String policyId;
        public String contactEmail;
        public String contactPhone;
        public Double policyAmount;
        public Double ivaTax;
        public Double netPremium;
        public String policyType;
        public String vehicleType;
        public String territory;
        public String underWriter;
        public String term;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTimeZone() {
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            Datetime dt = System.now();
            String dtPST = dt.format('yyyy-MM-dd HH:mm:ss', 'PST');
            String dPST = dt.format('yyyy-MM-dd', 'PST');

            Time myTimess = dt.time();
            string timePst = dt.format('HH:mm:ss', 'PST');
            string HHPst = dt.format('HH', 'PST');
            Time myTime = dt.time();
            Integer myHour = Integer.valueOf(HHPst);
            Integer myMin = dt.minute();

            Integer nextNearestMin = (Integer) (Math.ceil((Double)myMin/15) * 15);
            if(nextNearestMin == 60){
                myHour = myHour + 1;
                nextNearestMin = 0;
            }
            if(myHour == 24){
                dt = dt + 1;
                dtPST = dt.format('yyyy-MM-dd HH:mm:ss', 'PST');
            }

            string tempMin = String.valueOf(nextNearestMin);
            string temHour = String.valueOf(myHour);
            if(nextNearestMin < 10){
                tempMin = '0'+tempMin;
            }
            if(myHour < 10){
                temHour = '0'+temHour;
            }
            if(temHour == '24'){
                temHour = '00';
            }
            string nextMin =  temHour + ':' + tempMin + ':00.000Z';
            
            responseMap.put('status', 'success');
            responseMap.put('timePst', timePst);
            responseMap.put('timestamp', dt.getTime());
            responseMap.put('dtPST', dtPST);
            responseMap.put('dPST', dPST);
            responseMap.put('myTime', myTime);
            responseMap.put('myHour', myHour);
            responseMap.put('myMin', myMin);
            responseMap.put('nextMin', nextMin);
        }catch (Exception e) {
            responseMap.put('status', 'error');
            responseMap.put('message', e.getMessage());
            CustomErrorExceptionHandlerException.LogException(e);
        }
        return responseMap;
    }

    
    @AuraEnabled
    public static Map<String, object> checkalreadyExistUserAction(String leadDataItem) {
        Map<String, object> returnMap = new map<String,object>();
        list<Lead> leadData = new list<Lead>();
        try{
            Lead getLeadData = new Lead();
            getLeadData = (Lead)JSON.deserialize(leadDataItem, lead.class);
			System.debug('getLeadData---'+getLeadData);
            
            list<User> userList = new list<User>();
            map<string, object> insertedNewLead = new map<string, object>();
            userList = [select Id, UserName, Email, Isactive from User where Email =: getLeadData.Email limit 1];
            returnMap.put('isExistUser', false);
            
			System.debug('userList---'+userList);
            
            if(userList != null && !userList.isEmpty()) {
                returnMap.put('isExistUser', true);
                returnMap.put('userData', userList[0]);
            } else {
                System.debug('ELSE-----');
                string query = getQueryWithAllFields(Lead.getSObjectType().getDescribe().getName());
                query += ' WHERE';
                if (getLeadData.Id != null && !String.isEmpty(getLeadData.Id)) {
                    query += ' Id=\'' + getLeadData.Id + '\'';
                } else if (getLeadData.Email != null && !String.isEmpty(getLeadData.Email)) {
                    query += ' Email=\'' + getLeadData.Email + '\'';
                }
                leadData = Database.query(query);
				System.debug('leadData---leadData'+leadData);
                
                if(!leadData.isEmpty()){
                    if (getLeadData.FirstName != null && getLeadData.LastName != null) {
                        System.debug('Update Lead MEthod');
                        leadData[0].FirstName = getLeadData.FirstName;
                        leadData[0].LastName = getLeadData.LastName;
                        leadData[0].Phone = getLeadData.Phone;
                        update leadData;
                        System.debug('leadData---'+leadData);
                    }
					System.debug('leadData---'+leadData);
                    
                    string quoteQuery = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
                    quoteQuery += ' WHERE Lead__c=\'' + leadData[0].Id + '\'';
                    list<Quote__c> QuoteData = Database.query(quoteQuery);
					System.debug('QuoteData---'+QuoteData);
                    returnMap.put('LeadInfo', leadData[0]);
                    if(!QuoteData.isEmpty()){
                        returnMap.put('QuoteInfo', QuoteData[0]);
                    }
                }
            }

            if(userList.isEmpty() && leadData.isEmpty()){
                System.debug('getLeadData--- EMPTY'+getLeadData);
                getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
                insertedNewLead = InsertLeadData(JSON.serialize(getLeadData));
                returnMap.put('LeadInfo', insertedNewLead.get('LeadInfo'));
            }

            returnMap.put('status', 'Success');
        }catch(Exception ex){
            returnMap.put('status', 'Error');
            returnMap.put('message ', ex.getMessage());
            CustomErrorExceptionHandlerException.data = 'From parameter: '+leadDataItem+'\n leadData on query: '+JSON.serialize(leadData);
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        return returnMap;
    }

    @AuraEnabled
    public static Map<String, Object> getQuoteDataToContinueQuote(String quoteId) {
        Map<String, object> respMap = new Map<String, Object>();
        List<Quote_Vehicle__c> qvRec = new List<Quote_Vehicle__c>();
        List<Quote_Driver__c> qdRec = new List<Quote_Driver__c>();
        List<Quote_Towed_Unit__c> qtRec = new List<Quote_Towed_Unit__c>();
        List<Quote_Watercraft__c> qwRec = new List<Quote_Watercraft__c>();
        try {
            if (String.isEmpty(quoteId)) {
                respMap.put('status', 'error');
                respMap.put('message', 'Invalid access');
                return respMap;
            }

            String userType = UserInfo.getUserType();
            if (userType != null && (!userType.equalsIgnoreCase('Guest') || Test.isRunningTest())) {
                List<User> loginUserList = new List<User>();
                loginUserList = getloginUser();
                if (loginUserList != null && !loginUserList.isEmpty()) {
                    respMap.put('userRecord', loginUserList[0]);
                }

                List<Quote__c> quoteRecord = new List<Quote__c>();
                List<Vehicle__c> vehicleRecord = new List<Vehicle__c>();
                List<Driver__c> driverRecord = new List<Driver__c>();
                List<Towed_Unit__c> towRecord = new List<Towed_Unit__c>();
                List<Watercraft__c> watercraftRecord = new List<Watercraft__c>();
                string query = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
                query += ' WHERE ID =\'' + quoteId + '\'';
                
                quoteRecord = Database.query(query);
                
                if (!quoteRecord.isEmpty()) {
                    respMap.put('status', 'success');
                    respMap.put('quoteRecord', quoteRecord[0]);

                    qvRec = [Select Vehicle__c from Quote_Vehicle__c where Quote_c__c =:quoteId];
                    qdRec = [Select Driver__c from Quote_Driver__c where Quote_c__c =: quoteId];
                    qtRec = [Select Id, Towed_Unit__c from Quote_Towed_Unit__c where Quote_c__c =: quoteId];
                    qwRec = [SELECT Id, Watercraft__c From Quote_Watercraft__c Where Quote_c__c =: quoteId];
                    if (!qvRec.isEmpty()) {
                        set<String> vehIds = new set<String>();
                        for(Quote_Vehicle__c qvl : qvRec) {
                            vehIds.add( qvl.Vehicle__c );
                        }
                        String vehQuery = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
                        vehQuery += ' where Id IN: vehIds';
                        vehicleRecord = Database.query(vehQuery);
                        if (!vehicleRecord.isEmpty()) {
                            respMap.put('vehicleRecord', vehicleRecord);
                        }
                    }

                    if (!qdRec.isEmpty()) {
                        set<String> drIds = new set<String>();
                        for(Quote_Driver__c qdr : qdRec){
                            drIds.add( qdr.Driver__c );
                        }
                        
                        String drQuery = getQueryWithAllFields(Driver__c.getSObjectType().getDescribe().getName());
                        drQuery += ' where Id IN: drIds';
                        driverRecord = Database.query(drQuery);
                        
                        if (!driverRecord.isEmpty()) {
                            respMap.put('driverRecord', driverRecord);
                        }
                    }
                    
                    if (!qtRec.isEmpty()) {
                        set<String> towIds = new set<String>();
                        for(Quote_Towed_Unit__c qtu : qtRec){
                            towIds.add( qtu.Towed_Unit__c );
                        }
                        String towQuery = getQueryWithAllFields(Towed_Unit__c.getSObjectType().getDescribe().getName());
                        towQuery += ' Where Id IN: towIds';
                        towRecord = Database.query(towQuery);
                        if (!towRecord.isEmpty()) {
                            respMap.put('towRecord', towRecord);
                        }
                    }

                    if (!qwRec.isEmpty()) {
                        set<String> waterIds = new Set<String>();
                        for (Quote_Watercraft__c qwtr : qwRec) {
                            waterIds.add(qwtr.Watercraft__c);
                        }
                        String waterQuery = getQueryWithAllFields(Watercraft__c.getSObjectType().getDescribe().getName());
                        waterQuery += ' Where Id IN: waterIds';
                        watercraftRecord = Database.query(waterQuery);
                        
                        if (!watercraftRecord.isEmpty()) {
                            respMap.put('watercraftRecord', watercraftRecord);
                        }
                    }
                }
            } else {
                respMap.put('status', 'error');
                respMap.put('message', 'Invalid access');
                return respMap;                
            } } catch (Exception ex) { respMap.put('status', 'error'); respMap.put('message', ex.getMessage()); CustomErrorExceptionHandlerException.data = '\nqvRec: ' + JSON.serialize(qvRec) + '\nqdRec' + JSON.serialize(qdRec) + '\nqtRec' + JSON.serialize(qtRec) + '\nqwRec: ' + JSON.serialize(qwRec); CustomErrorExceptionHandlerException.LogException(ex); }
        return respMap;
    }

    @AuraEnabled
    public static List<User> getloginUser() {
        return [
            SELECT Id, Email, FirstName, LastName, Phone, ContactId, Contact.Email, Contact.Birthdate, Contact.Date_of_Birth__c, Contact.AccountId,
            Contact.MailingState, Contact.MailingCity, Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCountry
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }
        
    @AuraEnabled
    public static String getDateForQuoteScreen(String someId, String userType) {
        Map<String, object> data = new Map<String, Object>();
        if (userType == 'newLead') {
            List<Lead> leadList = new List<Lead>();
            leadList = [SELECT Id, FirstName, LastName, Email, Phone,Is_towing__c, Quote_Details__c, Territory_Options__c, Term_options__c, Vehicle_details__c,Watercraft_Detail__c, Terms_Alert__c, Towing__c, Liability__c From Lead Where Id = :someId Limit 1];
            
            if (!leadList.isEmpty()) {
                data.put('status', 'success');
                data.put('data', leadList[0]);
            } else {
                data.put('status', 'error');
                data.put('message', 'No data found. Kindly retry generating new quote.');
            }
        }
        
        return JSON.serialize(data);
    }

    @AuraEnabled
    public static List<Vehicle__c> getCurrentUserVehicles( String policyType ) {
        set<String> vehicletypeFilters;
        try {
            list<User> users = new list<User>();
            users = [select Id, contactId from User where Id=: UserInfo.getUserId() limit 1];
            
            if( policyType != null && policyType.equalsIgnoreCase('Automobile')){
                vehicletypeFilters = new set<String>{'Automobile/Sedan', 'Pickup Truck w or w/o Camper Shell', 'SUV', 'Van','Car/Truck/Auto'};
                    }else if( policyType != null && policyType.equalsIgnoreCase('Motorcycle/Street Legal ATV') ){
                        vehicletypeFilters = new set<String>{'Motorcycle', 'Street Legal ATV'};
                            }else if( policyType != null && policyType.equalsIgnoreCase('RV') ){
                                vehicletypeFilters = new set<String>{'Motor Home / RV'};
                                    }
            
            if( users != null && !users.isEmpty() && users[0].contactId != null ){
                list<Vehicle__c>  quoteVechiles = [select Id from Vehicle__c where Contact__c =: users[0].contactId or createdbyId =: UserInfo.getUserId() ];
                set<String> vechileIds = new set<String>();
                if( quoteVechiles != null && !quoteVechiles.isEmpty() ){
                    for(Vehicle__c qvl : quoteVechiles){
                        vechileIds.add( qvl.Id );
                    }
                }
                String query = getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
                query += ' where ( Id IN: vechileIds or createdbyId=\''+UserInfo.getUserId()+'\' )'; 
                if( vehicletypeFilters != null && !vehicletypeFilters.isEmpty()){
                    query += ' And Vehicle_Type__c IN: vehicletypeFilters';
                }
                if( policyType != null && policyType.equalsIgnoreCase('Northbound')){
                    query += ' And Registered_Country__c = \'Mexico\'';
                }else {
                    query += ' And Registered_Country__c != \'Mexico\'';
                }
                return Database.query(query);
            }
        } catch(Exception ex) { CustomErrorExceptionHandlerException.data = JSON.serialize(vehicletypeFilters); CustomErrorExceptionHandlerException.LogException(ex); }
        return null;
    }
    
    @AuraEnabled
    public static map<string, object> InsertLeadData(string leadData){
        map<string, object> returnMap = new map<string, object>();
        try{
            System.debug('leadData----->'+leadData);
            Lead getLeadData = new Lead();
            getLeadData = (Lead) JSON.deserialize(leadData, lead.class);
            if(getLeadData.Policy_Type__c != null){
                getLeadData.Company = getLeadData.Policy_Type__c + ' New Insurance';
                getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
                getLeadData.Liability__c = getLeadData.Liability__c;
            }
            System.debug('getLeadData----->'+getLeadData);
            upsert getLeadData;
            System.debug('getLeadData----->'+getLeadData);
            returnMap.put('LeadInfo', getLeadData);
            returnMap.put('status', 'Success');
        }catch(exception ex){
            returnMap.put('status', 'Error');
            returnMap.put('message ', ex.getMessage());
            CustomErrorExceptionHandlerException.data = leadData;
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        return returnMap;
    }
    
    @AuraEnabled
    public static map<string, object> insertNewQuotes(String quotes, String leadId){
        map<string, object> responseMap = new map<string, object>();
        try{
            Quote__c quoteRecord = new Quote__c();
            quoteRecord = (Quote__c)JSON.deserialize(quotes, Quote__c.class);
            quoteRecord.Lead__c = leadId;
            quoteRecord.Policy_Type_picklist__c = quoteRecord.Policy_Type_picklist__c == 'Automobile/Sedan' ? 'Automobile' : quoteRecord.Policy_Type_picklist__c;

            if (quoteRecord.Medical__c != null && quoteRecord.Medical__c != '') {
                quoteRecord.Medical__c = quoteRecord.Medical__c.contains('$') ? quoteRecord.Medical__c.replace('$', '') : quoteRecord.Medical__c ;
            }
            System.debug('Quote Record BEFORE UPSERT ::'+JSON.serializePretty(quoteRecord));
            upsert quoteRecord;
            
            List<Lead> leadRecords = [SELECT Id, Insurance_Type__c, Vehicle_Details__c,Watercraft_Detail__c,  Quote_Details__c FROM Lead Where Id = :leadId LIMIT 1];
            if (!leadRecords.isEmpty()) {
                Map<String, Object> vehicleDetailsMap;
                Lead leadRecord = leadRecords.get(0);
                
                if(leadRecord.Insurance_Type__c == 'Watercraft'){
                    vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Watercraft_Detail__c);
                }else{
                    vehicleDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(leadRecord.Vehicle_Details__c);
                }
                
                
                vehicleDetailsMap.put('Coverage__c', quoteRecord.Coverage__c);
                leadRecord.Vehicle_details__c = JSON.serialize(vehicleDetailsMap);
                leadRecord.Quote_Details__c = JSON.serialize(quoteRecord);
                update leadRecord;
            }
            
            responseMap.put('status', 'success');
            responseMap.put('data', quoteRecord);
        }catch( Exception ex){
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
            CustomErrorExceptionHandlerException.data = quotes;
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        return responseMap;    
    }

    @AuraEnabled
    public static Map<String, Object> sendEmailQuoteDetails(String quoteId){
        system.debug('In the sendEmailQuoteDetails Method:: ' +quoteId );
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Quote__c> quoteDetail;
        try {
            quoteDetail = [SELECT Id, Name, Policy_Type_picklist__c, 
                                Lead__c, Contact__c, Lead__r.Email,
                                Lead__r.Name, Contact__r.Email, Underwriter__c, 
                                Lead__r.Agency__r.Policy_Email_From_Address__c,
                                Contact__r.Agency__r.Policy_Email_From_Address__c
                           FROM Quote__c 
                           WHERE Id =: quoteId 
                           LIMIT 1];
            //OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'charles@mexinsurance.com'];
            String wideOrgEmail='';
            if(quoteDetail[0].Contact__c != null && quoteDetail[0].Contact__r.Agency__r.Policy_Email_From_Address__c  != null) {
                wideOrgEmail  = quoteDetail[0].Contact__r.Agency__r.Policy_Email_From_Address__c;
            } else if(quoteDetail[0].Lead__c != null && quoteDetail[0].Lead__r.Agency__r.Policy_Email_From_Address__c  != null) {
                wideOrgEmail  = quoteDetail[0].Lead__r.Agency__r.Policy_Email_From_Address__c;
            } else {
                wideOrgEmail = System.Label.RemainderEmail;
            }
            OrgWideEmailAddress[] senderEmail = [select Id from OrgWideEmailAddress where Address =: wideOrgEmail]; 

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            PageReference pdfpage = Page.selectedQuoteNewRate;
            pdfPage.getParameters().put('Id',quoteId);
            pdfpage.setRedirect(true);
            
            // Take the PDF content
            Blob pdfBlob = pdfPage.getContent();
            if (!Test.isRunningTest()) {
                pdfBlob = pdfPage.getContent();
            }

            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

            string fileName = 'Mexinsurance-'+quoteDetail[0].Underwriter__c+'-Quote.pdf';
            efa.setFileName(fileName);
            if (!Test.isRunningTest()) {
                efa.setBody(pdfBlob);
                efa.setContentType('text/plain');
            } else {
                
                efa.setBody(Blob.valueOf('Unit Test Attachment Body'));
            }

            List<String> toAddresses = new List<String>();      
            
            if(quoteDetail[0].contact__r.Email != null){
                 toAddresses.add(quoteDetail[0].contact__r.Email);
            }else{
                 toAddresses.add(quoteDetail[0].Lead__r.Email);
            }

            // Sets the paramaters of the email

            string subject = 'Your MexInsurance® Quote';
            email.setSubject( subject );
            email.setOrgWideEmailAddressId(senderEmail.get(0).Id);
            email.setToAddresses(toAddresses);
            email.setHtmlBody( 'Here\'s attachment of Quick Quote Details.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
            responseMap.put('status', 'success');
        }catch( Exception ex){
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
            CustomErrorExceptionHandlerException.data = JSON.serialize(quoteDetail);
            CustomErrorExceptionHandlerException.LogException(ex);
        }
        system.debug('This is the map status' + responseMap.get('status'));
        return responseMap; 
    }
    
    public static String getQueryWithAllFields(String objectName) {
        return 'SELECT ' + String.join(getAllFields(objectName), ', ') + ' FROM ' + objectName;
    }
    
    private static Set<String> removeFields = new Set<String>{
        'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastvieweddate',
            'lastreferenceddate'
            };
                
                private static List<String> getAllFields(String objectName) {
                    SObjectType objectType = describeObject(objectName);
                    Map<String, Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
                    
                    List<String> fieldsSet = new List<String>();
                    for (String s : mfields.keySet()) {
                        if ((mfields.get(s).getDescribe().isAccessible() && !removeFields.contains(String.valueOf(s).toLowerCase())) || Test.isRunningTest()) {
                            fieldsSet.add(s);
                        }
                    }
                    
                    if (fieldsSet != null && !fieldsSet.contains('id')) {
                        fieldsSet.add('id');
                    }
                    return fieldsSet;
                }
    
    @AuraEnabled
    public static map<string, object> fetchDataFromLead(String LeadId, String screenName){
        map<string, object> responseMap = new map<string, object>();
        try{
            List<Lead> fetchLeadData = new List<Lead>(); 
            
            string query = 'SELECT '+ screenName + ' ,Insurance_Type__c FROM Lead WHERE Id=\'' + LeadId + '\'';
            fetchLeadData = Database.query(query);
            responseMap.put('status', 'success');
            responseMap.put('data', fetchLeadData); }catch(Exception ex){ responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()+ ' at line : '+ex.getLineNumber()); CustomErrorExceptionHandlerException.data = 'screenName>>'+ screenName+'\n leadId>>'+LeadId; CustomErrorExceptionHandlerException.LogException(ex); }
        return responseMap;
    }

    @AuraEnabled
    public static String createWaterCraftPolicy(String leadId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Lead leadObj = [SELECT Id, Name, LastName, Is_towing__c, Email, FirstName, Phone, IsConverted, ConvertedContactId, ConvertedAccountId, Source__c, Quote_Details__c, 
                            Vehicle_details__c,Watercraft_Detail__c, Company_details__c, Lienholder_info__c, Driver_details__c, Towing__c, Terms_Alert__c,Agency__c, Agency__r.Agency_Community_Profile__c
                            FROM Lead 
                            WHERE Id = :leadId 
                            LIMIT 1];
            
            String userCommunityProfileName = (leadObj.Agency__c != null && !String.isBlank(leadObj.Agency__r.Agency_Community_Profile__c))
                    ? leadObj.Agency__r.Agency_Community_Profile__c
                    : 'Mex Insurance Customer Community Plus Login User';
        
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = :userCommunityProfileName LIMIT 1];
                    
            
            if (leadObj != null && !leadObj.IsConverted){
                List<Account> existingAccountlist = [Select Id from Account Where Email__c = :leadObj.Email];
                List<Contact> existingContacts = [Select Id from Contact Where Email = :leadObj.Email];



                Database.LeadConvert leadConvertInst = new Database.LeadConvert();
                
                leadConvertInst.setLeadId(leadId);
                System.debug('existingAccountlist->  1  '+existingAccountlist);
                if(existingAccountlist.size() > 0){
                    leadConvertInst.setAccountId(existingAccountlist.get(0).Id);
                }
                if(existingContacts.size() > 0){
                    if(existingAccountlist.size() < 1){
                        Account dupAc = new Account();
                        dupAc.Name = existingContacts.get(0).Name;
                        dupAc.Email__c = existingContacts.get(0).Email;
                        Database.upsert(dupAc);
                        existingContacts.get(0).AccountId = dupAc.Id;
                        Database.update(existingContacts);

                        leadConvertInst.setAccountId(dupAc.Id);
                    }
                    leadConvertInst.setContactId(existingContacts.get(0).Id);
                }
                
                leadConvertInst.setDoNotCreateOpportunity(true);
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
               
                Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
                System.debug('leadConvertRslt->  1  '+leadConvertRslt);
                
                if (leadConvertRslt.isSuccess() && leadConvertRslt.getContactId() != null){
                    
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
                    
                    Database.insert(newUser);
                    String userId = newuser.Id;
                    
                    Quote__c quoteRecord = new Quote__c();
                    WatercraftRecordWrapper watercraftRecord = new WatercraftRecordWrapper();
                    TermAndConditionWrapper termConditionRecord = new TermAndConditionWrapper();
                    
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    if (leadObj.Quote_Details__c != null && !String.isBlank(leadObj.Quote_Details__c)) {
                        quoteRecord = (Quote__c)JSON.deserialize(leadObj.Quote_Details__c, Quote__c.class);
                    }
                    
                    if (leadObj.Watercraft_Detail__c != null && !String.isBlank(leadObj.Watercraft_Detail__c)) {
                        watercraftRecord = (WatercraftRecordWrapper)JSON.deserialize(leadObj.Watercraft_Detail__c.replaceAll('__c', '_Tempc'), WatercraftRecordWrapper.class);
                    }
                    if (leadObj.Terms_Alert__c != null && !String.isBlank(leadObj.Terms_Alert__c)) {
                        termConditionRecord = (TermAndConditionWrapper)JSON.deserialize(leadObj.Terms_Alert__c.replaceAll('__c', '_Tempc'), TermAndConditionWrapper.class);
                    }

                    if (userId != null) {
                        String isUpdated = updateQuoteContact(quoteRecord.Id, leadConvertRslt.getAccountId(), leadConvertRslt.getContactId());
                        
                        if(isUpdated == 'ok') {
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

                            // update the Account Object...
                            Account accObj = new Account();
                            accObj.Name = (!String.isBlank(leadObj.FirstName) ? leadObj.FirstName + ' ' : driverOwner[0].First_Name__c) + (!String.isBlank(leadObj.LastName) ? leadobj.LastName : driverOwner[0].Last_Name__c);
                            accObj.Id = leadConvertRslt.getAccountId();
                            accObj.Email__c = !String.isBlank(leadObj.Email) ? leadobj.Email : driverOwner[0].Email__c;
                            accObj.Phone = !String.isBlank(leadObj.Phone) ? leadObj.Phone : driverOwner[0].Phone__c;
                            accObj.Phone__c = !String.isBlank(leadObj.Phone) ? leadObj.Phone : driverOwner[0].Phone__c;
                            accObj.Source__c = 'New Lead Flow';
                            accObj.Type = 'Customer';
                            update accObj;
                            
                            // update the Contact Object...
                            Contact conObj = new Contact();
                            conObj.FirstName = !String.isBlank(leadObj.FirstName) ? leadObj.FirstName : driverOwner[0].First_Name__c;
                            conObj.LastName = !String.isBlank(leadObj.LastName) ? leadobj.LastName : driverOwner[0].Last_Name__c;
                            conObj.Email = !String.isBlank(leadObj.Email) ? leadobj.Email : driverOwner[0].Email__c;
                            conObj.Id = leadConvertRslt.getContactId();
                            conObj.Phone = !String.isBlank(leadObj.Phone) ? leadObj.Phone: driverOwner[0].Phone__c;
                            conObj.MobilePhone = !String.isBlank(leadObj.Phone) ? leadObj.Phone : driverOwner[0].Phone__c;
                            conObj.Source__c = 'New Lead Flow';
                            conObj.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                            conObj.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                            conObj.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
                            update conObj;
                            
                            // update the Quote__c Object...
                            quoteRecord.Quote_Status__c = 'Policy Created';
                            update quoteRecord;
                            
                            // Check if transaction exist then create policy and Update the transaction record...
                            List<Transaction__c> policyTransaction = [SELECT Id FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                            
                            if (!policyTransaction.isEmpty()){
                                // insert the Vehicle__c Object...
                                Watercraft__c newWaterCraft = new Watercraft__c();
                                newWaterCraft.VIN_Number__c = watercraftRecord.Vin_Number_Tempc;
                                newWaterCraft.Year__c = watercraftRecord.Year_Tempc;
                                newWaterCraft.Make__c = watercraftRecord.Make_Tempc;
                                newWaterCraft.Model__c = watercraftRecord.Model_Tempc;
                                newWaterCraft.Type_of_Vessel__c = watercraftRecord.Type_of_Vessel_Tempc;
                                newWaterCraft.Vessel_Length__c = watercraftRecord.Vessel_Length_Tempc;
                                newWaterCraft.Beam__c = watercraftRecord.Beam_Tempc;
                                newWaterCraft.Flag__c = watercraftRecord.Flag_Tempc;
                                newWaterCraft.Engine_Type__c = watercraftRecord.Engine_Type_Tempc;
                                newWaterCraft.Value__c = Decimal.valueOf(watercraftRecord.Value_Tempc);
                                newWaterCraft.Account__c = leadConvertRslt.getAccountId();
                                newWaterCraft.Contact__c = leadConvertRslt.getContactId();
                                insert newWaterCraft;
                                
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
                                newPolicy.Vehicle_deductible_collision__c = quoteRecord.Vehicle_Deductible_Collision__c;
                                newPolicy.Vehicle_deductible_comprehensive__c = quoteRecord.Vehicle_Deductible_Comprehensive__c;
                                newPolicy.Watercraft__c = newWaterCraft.Id;
                                newPolicy.Contact__c = leadConvertRslt.getContactId();
                                newPolicy.Policy_Parent_Account__c = leadConvertRslt.getAccountId();
                                newPolicy.Account_Policy__c = leadConvertRslt.getAccountId();
                                newPolicy.Status_picklist__c = 'Active';
                                newPolicy.Source__c = 'New Lead Flow';
                                newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                                newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                                newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                                newPolicy.Third_Party_Bodily_Injury__c = quoteRecord.Third_Party_Bodily_Injury__c;
                                newPolicy.Property_Damage_Liability__c = quoteRecord.Property_Damage_Liability__c;
                                newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
                                newPolicy.Term__c = quoteRecord.Term__c;
                                
                                if (quoteRecord.Term__c != null && quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual' ) {
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
                                newPolicy.Terms_of_Purchase_Confirmed__c = termConditionRecord.Terms_of_Purchase_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Purchase_Confirmed_Tempc : false;
                                newPolicy.Terms_of_Cancellation_Confirmed__c = termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc : false;
                                newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                                newPolicy.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                                newPolicy.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
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
                                // } 
                                else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'RV' && policyDeveloperNameVsId.containsKey('RV')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('RV');
                                } else if (quoteRecord.Policy_Type_picklist__c != null && quoteRecord.Policy_Type_picklist__c == 'Watercraft' && policyDeveloperNameVsId.containsKey('Watercraft')) {
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Watercraft');
                                }else{
                                    newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
                                }
                                insert newPolicy;
                                
                                
                                // insert the Quote_Vehicle__C Object...
                                Quote_Watercraft__c newQuoteWatercraft = new Quote_Watercraft__c();
                                newQuoteWatercraft.Account__c = leadConvertRslt.getAccountId();
                                newQuoteWatercraft.Contact__c = leadConvertRslt.getContactId();
                                newQuoteWatercraft.Watercraft__c = newWaterCraft.Id;
                                newQuoteWatercraft.Quote_c__c = quoteRecord.Id;
                                newQuoteWatercraft.Policy__c = newPolicy.Id;
                                insert newQuoteWatercraft;
                                
                                // insert the Quote_Driver__c Object...
                                List<Quote_Driver__c> quoteDriverList = new List<Quote_Driver__c>();
                                if (!driverRecordList.isEmpty()) {
                                    for (Driver__c each : driverRecordList) {
                                        Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                                        newQuoteDriver.Account_Driver__c = accObj.Id;
                                        newQuoteDriver.Contact__c = conObj.Id;
                                        newQuoteDriver.Quote_c__c = quoteRecord.Id;
                                        newQuoteDriver.Driver__c = each.Id;
                                        newQuoteDriver.Watercraft__c = newWaterCraft.Id;
                                        newQuoteDriver.Policy__c = newPolicy.Id;
                                        quoteDriverList.add(newQuoteDriver);
                                    }
                                    
                                    if (!quoteDriverList.isEmpty()) {
                                        insert quoteDriverList;
                                    }
                                } else {
                                    // return error -> Driver record missing
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
                                
                                if (policyIds != null && !policyIds.isEmpty()) {
                                    Boolean add_attachment = true;
                                    Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
                                }
                                
                                responseMap.put('status', 'success');
                                responseMap.put('data', String.valueOf(newPolicy.Name));
                                responseMap.put('email', String.valueOf(newPolicy.Contact_Email__c));
                                responseMap.put('PolicyId', String.valueOf(newPolicy.Id));
                                
                            }else {
                                // Error occured while updating the quote data...
                            }
                        }
                    }
                }
            }else{
                responseMap.put('status', 'error');
                responseMap.put('message', 'Account already exist kindly retry creating policy after Logging-In!');
            } }catch (Exception ex) { responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); CustomErrorExceptionHandlerException.LogException(ex); }
        return JSON.serialize(responseMap);
    }

    @AuraEnabled
    public static String createPolicy(String leadId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Lead leadObj = [SELECT Id, Name, LastName, Is_towing__c, Email, FirstName, Phone, IsConverted, ConvertedContactId, ConvertedAccountId, Source__c, Quote_Details__c, 
                            Vehicle_details__c, Company_details__c, Lienholder_info__c, Driver_details__c, Towing__c, Terms_Alert__c,Agency__c, Agency__r.Agency_Community_Profile__c
                            FROM Lead 
                            WHERE Id = :leadId 
                            LIMIT 1];
            System.debug('Lead Data' + JSON.serialize(leadObj));
            
            String userCommunityProfileName = (leadObj.Agency__c != null && !String.isBlank(leadObj.Agency__r.Agency_Community_Profile__c))
                    ? leadObj.Agency__r.Agency_Community_Profile__c
                    : 'Mex Insurance Customer Community Plus Login User';

            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = :userCommunityProfileName LIMIT 1];
            
            if (leadObj != null && !leadObj.IsConverted) {

                List<Account> existingAccountlist = [SELECT Id from Account WHERE Email__c = :leadObj.Email];
                List<Contact> existingContacts = [SELECT Id, FirstName,LastName, Name, Email FROM Contact WHERE Email = :leadObj.Email];
                System.debug('Contact exisitng Data' + JSON.serialize(existingContacts));
                System.debug('existingAccountlist' + JSON.serialize(existingAccountlist));
                Database.LeadConvert leadConvertInst = new Database.LeadConvert();
                leadConvertInst.setLeadId(leadId);
                System.debug('existingAccountlist->  2  '+existingAccountlist);
                
                if(existingAccountlist.size() > 0){
                    leadConvertInst.setAccountId(existingAccountlist.get(0).Id);
                }
                if(existingContacts.size() > 0){
                    if(existingAccountlist.size() < 1){
                        Account dupAc = new Account();
                        dupAc.Name = existingContacts.get(0).Name;
                        dupAc.Email__c = existingContacts.get(0).Email;
                        Database.upsert(dupAc);
                        existingContacts.get(0).AccountId = dupAc.Id;
                        Database.update(existingContacts);
                        
                        leadConvertInst.setAccountId(dupAc.Id);
                    }
                    System.debug('Account email'+existingAccountlist);
                    leadConvertInst.setContactId(existingContacts.get(0).Id);
                    System.debug('Exisitng contact@@@@@'+existingContacts);
                }
                leadConvertInst.setDoNotCreateOpportunity(true);
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                leadConvertInst.setConvertedStatus(convertStatus.MasterLabel);
                
                Database.LeadConvertResult leadConvertRslt = Database.convertLead(leadConvertInst);
                System.debug('leadConvertRslt->  2  '+leadConvertRslt);

                if (leadConvertRslt.isSuccess() && leadConvertRslt.getContactId() != null) {
                    
          
            
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
                    System.debug('user before insert'+newUser);
                    Database.insert(newUser);
                    String userId = newuser.Id;
                    System.debug('Lead Data' + JSON.serialize(leadObj));
                    Quote__c quoteRecord = new Quote__c();
                    VehicleRecordWrapper vehicleRecord = new VehicleRecordWrapper();
                    CompanyDetailsWrapper companyRecord = new CompanyDetailsWrapper();
                    LienholderWrapper lienholderRecord = new LienholderWrapper();
                    TermAndConditionWrapper termConditionRecord = new TermAndConditionWrapper();
                    
                    Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
                    for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
                        policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
                    }
                    
                    if (leadObj.Quote_Details__c != null && !String.isBlank(leadObj.Quote_Details__c)) {
                        quoteRecord = (Quote__c)JSON.deserialize(leadObj.Quote_Details__c, Quote__c.class);
                    }
                    if (leadObj.Vehicle_details__c != null && !String.isBlank(leadObj.Vehicle_details__c)) {
                        vehicleRecord = (VehicleRecordWrapper)JSON.deserialize(leadObj.Vehicle_details__c.replaceAll('__c', '_Tempc'), VehicleRecordWrapper.class);
                    }
                    if (leadObj.Company_details__c != null && !String.isBlank(leadObj.Company_details__c) && vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc) {
                        companyRecord = (CompanyDetailsWrapper)JSON.deserialize(leadObj.Company_details__c.replaceAll('__c', '_Tempc'), CompanyDetailsWrapper.class);
                    }
                    
                    if (leadObj.Lienholder_info__c != null && !String.isBlank(leadObj.Lienholder_info__c) && vehicleRecord.Is_Lienholder_Tempc) {
                        lienholderRecord = (LienholderWrapper)JSON.deserialize(leadObj.Lienholder_info__c.replaceAll('__c', '_Tempc'), LienholderWrapper.class);
                    }
                    
                    if (leadObj.Terms_Alert__c != null && !String.isBlank(leadObj.Terms_Alert__c)) {
                        termConditionRecord = (TermAndConditionWrapper)JSON.deserialize(leadObj.Terms_Alert__c.replaceAll('__c', '_Tempc'), TermAndConditionWrapper.class);
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
                                if (eachRec.Driver_Type__c == 'Owner' || eachRec.Driver_Type__c == 'Owner & Driver' || eachRec.Driver_Type__c == 'true') {
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
                            Account accObj = new Account();
                            
                            if (vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc == true && vehicleRecord.Is_Account_Company_Named_Tempc == true) {
                                accObj.Name = !String.isBlank(companyRecord.Company_Name_Tempc) ? companyRecord.Company_Name_Tempc : '';
                                accObj.Id = leadConvertRslt.getAccountId();
                                accObj.Is_Account_Company_Named__c = true;
                                accObj.Email__c = leadobj.Email;
                                accObj.Phone =!String.isBlank(companyRecord.Company_Phone_Tempc) ? companyRecord.Company_Phone_Tempc : '';
                                accObj.Phone__c =!String.isBlank(companyRecord.Company_Phone_Tempc) ? companyRecord.Company_Phone_Tempc : '';
                                accObj.Street__c = companyRecord.Company_Address_Tempc;
                                accobj.City__c = companyRecord.Company_City_Tempc;
                                accobj.State__c = companyRecord.Company_State_Tempc;
                                accObj.Country__c = companyRecord.Company_Country_Tempc;
                                accObj.Postal_Code__c = companyRecord.Company_Zip_Tempc;
                            } else if (vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc == true && vehicleRecord.Is_Account_Company_Named_Tempc != true) {
                                System.debug('Inside second If');
                                //accObj.Name = leadObj.FirstName + ' ' + leadObj.LastName;
                                accObj.Name = !String.isBlank(companyRecord.Company_Name_Tempc) ? companyRecord.Company_Name_Tempc : '';
                                accObj.Id = leadConvertRslt.getAccountId();
                                accObj.Is_Account_Company_Named__c = false;
                                accObj.Email__c = leadobj.Email;
                                accObj.Phone = leadObj.Phone;
                                accObj.Phone__c = leadObj.Phone;
                                accObj.Street__c = vehicleRecord.BusinessAddress_Tempc.Address_Tempc;
                                accObj.Street_2__c = vehicleRecord.BusinessAddress_Tempc.Address_Line_2_Tempc;
                                accobj.City__c = vehicleRecord.BusinessAddress_Tempc.City_Tempc;
                                accobj.State__c = vehicleRecord.BusinessAddress_Tempc.State_Province_Tempc;
                                accObj.Country__c = vehicleRecord.BusinessAddress_Tempc.Country_Tempc;
                                accObj.Postal_Code__c = vehicleRecord.BusinessAddress_Tempc.Postal_Code_Tempc;
                            } else {
                                System.debug('Inside third If');
                                accObj.Name = driverOwner[0].First_Name__c + ' ' + driverOwner[0].Last_Name__c;
                                accObj.Id = leadConvertRslt.getAccountId();
                                accObj.Email__c = leadobj.Email != null ? leadobj.Email : '' ;
                                accObj.Phone =leadObj.Phone != null ? leadObj.Phone : '';
                                accObj.Phone__c = leadObj.Phone;
                                accObj.Street__c = driverOwner[0].Address__c;
                                accObj.Street_2__c = driverOwner[0].Address_Line_2__c;
                                accobj.City__c = driverOwner[0].City__c;
                                accobj.State__c = driverOwner[0].State_Province__c;
                                accObj.Country__c = driverOwner[0].Country__c;
                                accObj.Postal_Code__c = driverOwner[0].Postal_Code__c;
                            }
                            System.debug('Updated account'+accObj);
                            if(String.isNotBlank(leadObj.Source__c) && leadObj.Source__c != 'Portal'){
                                accObj.Source__c =leadObj.Source__c;
                            }else{
                                accObj.Source__c = 'New Lead Flow';
                            }
                            
                            accObj.Type = 'Customer';
                            update accObj;
                         
                            // update the Contact Object...
                            Contact conObj = new Contact();
                            if (vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc == true && vehicleRecord.Is_Account_Company_Named_Tempc == true) {
                                conObj.LastName = !String.isBlank(companyRecord.Company_Name_Tempc) ? companyRecord.Company_Name_Tempc : '';
                                conObj.FirstName = '';
                            } else if (vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc == true && vehicleRecord.Is_Account_Company_Named_Tempc != true) {
                                conObj.FirstName = leadObj.FirstName;
                                conObj.LastName = leadObj.LastName;
                            } else if (!vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc == true && vehicleRecord.Is_Account_Company_Named_Tempc != true) {
                                conObj.FirstName = driverOwner[0].First_Name__c;
                                conObj.LastName = driverOwner[0].Last_Name__c;
                                conObj.Date_of_Birth__c = driverOwner[0].Dob__c;
                            }
                            conObj.Email = accObj.Email__c;
                            conObj.Id = leadConvertRslt.getContactId();
                            conObj.Phone = !String.isBlank(accObj.Phone) ? accObj.Phone : '';
                            conObj.MobilePhone = !String.isBlank(accObj.Phone) ? accObj.Phone : '';
                            
                            if(String.isNotBlank(leadObj.Source__c) && leadObj.Source__c != 'Portal'){
                                conObj.Source__c =leadObj.Source__c;
                            }else{
                                conObj.Source__c = 'New Lead Flow';
                            }
                            
                            conObj.Street__c = !String.isBlank(accObj.Street__c) ? accObj.Street__c : '';
                            conObj.Street_2__c = !String.isBlank(accObj.Street_2__c) ? accObj.Street_2__c : '';
                            conObj.City__c = !String.isBlank(accObj.City__c) ? accObj.City__c : '';
                            conObj.State__c = !String.isBlank(accObj.State__c) ? accObj.State__c : '';
                            conObj.Country__c = !String.isBlank(accObj.Country__c) ? accObj.Country__c : '';
                            conObj.Postal_Code__c = !String.isBlank(accObj.Postal_Code__c) ? accObj.Postal_Code__c : '';
                            conObj.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                            conObj.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                            conObj.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
                            update conObj;
                            System.debug('Updated Contact object'+conObj);
                            System.debug('Lead data again'+leadObj);
                            // update the Quote__c Object...
                            quoteRecord.Quote_Status__c = 'Policy Created';
                            update quoteRecord;
                            
                            // Check if transaction exist then create policy and Update the transaction record...
                            List<Transaction__c> policyTransaction = [SELECT Id, Amount__c FROM Transaction__c Where Quote_c__c = :quoteRecord.Id];
                            
                            if (!policyTransaction.isEmpty()) {
                                // insert the Vehicle__c Object...
                                Vehicle__c newVehicle = new Vehicle__c();
                                newVehicle.Name = vehicleRecord.Model_Tempc + ' ' + vehicleRecord.Make_Tempc + ' ' + vehicleRecord.Year_Tempc;
                                newVehicle.Vin__c = vehicleRecord.Vin_Tempc;
                                newVehicle.Vehicle_Type__c = vehicleRecord.Vehicle_sub_type_Tempc;
                                newVehicle.Year__c = vehicleRecord.Year_Tempc;
                                newVehicle.Make__c = vehicleRecord.Make_Tempc;
                                newVehicle.Model__c = vehicleRecord.Model_Tempc;
                                newVehicle.Value__c = Decimal.valueOf(vehicleRecord.Value_Tempc);
                                newVehicle.Account_Vehicle__c = leadConvertRslt.getAccountId();
                                newVehicle.Contact__c = leadConvertRslt.getContactId();
                                newVehicle.Registered_Plate__c = vehicleRecord.Registered_Plate_Tempc;
                                newVehicle.Registered_State__c = vehicleRecord.Registered_State_Tempc;
                                newVehicle.Registered_Country__c = vehicleRecord.Registered_Country_Tempc;
                                newVehicle.Rental__c = vehicleRecord.Is_this_a_Rental_Vehicle_Tempc ? 'Yes' : 'No';
                                newVehicle.Salvage_Vehicle__c = vehicleRecord.Salvage_Vehicle_Tempc;
                                newVehicle.Is_the_vehicle_used_for_business_purpose__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc;
                                newVehicle.Is_the_vehicle_registered_to_a_business__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc;
                                newVehicle.Company_Name__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Company_Name_Tempc : '';
                                newVehicle.Company_Phone__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Company_Phone_Tempc : '';
                                newVehicle.Company_Address__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Company_Address_Tempc : '';
                                newVehicle.Tax_ID__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Tax_ID_Tempc : '';
                                newVehicle.Company_City__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Company_City_Tempc : '';
                                newVehicle.Company_State__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Company_State_Tempc : '';
                                newVehicle.Company_Zip__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Company_Zip_Tempc : '';
                                newVehicle.Company_Country__c = vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc && companyRecord != null ? companyRecord.Company_Country_Tempc : '';
                                newVehicle.Is_Lienholder__c = vehicleRecord.Is_Lienholder_Tempc;
                                newVehicle.Lienholder_name__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_name_Tempc : '';
                                newVehicle.Lienholder_Phone__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_Phone_Tempc : '';
                                newVehicle.Lienholder_Fax__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_Fax_Tempc : '';
                                newVehicle.Lienholder_Street__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_Street_Tempc : '';
                                newVehicle.Lienholder_Street_2__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_Street_2_Tempc : '';
                                newVehicle.Lienholder_City__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_City_Tempc : '';
                                newVehicle.Lienholder_State__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_State_Tempc : '';
                                newVehicle.Lienholder_Postal_Code__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_Postal_Code_Tempc : '';
                                newVehicle.Lienholder_Country__c = vehicleRecord.Is_Lienholder_Tempc && lienholderRecord != null ? lienholderRecord.Lienholder_Country_Tempc : '';
                                
                                if (vehicleRecord.Is_the_vehicle_registered_to_a_business_Tempc != true && vehicleRecord.Is_Account_Company_Named_Tempc != true) {
                                    newVehicle.Vehicle_Owner_Name__c = driverOwner[0].First_Name__c + ' ' + driverOwner[0].Last_Name__c;
                                    newVehicle.Vehicle_Owner_Phone__c = driverOwner[0].Phone__c;
                                    newVehicle.Vehicle_Owner_Address__c = driverOwner[0].Address__c;
                                    newVehicle.Vehicle_Owner_Driver_License__c = driverOwner[0].license_number__c;
                                    newVehicle.Vehicle_Owner_Driver_License_State__c = driverOwner[0].License_state__c;
                                    newVehicle.Vehicle_Owner_City__c = driverOwner[0].City__c;
                                    newVehicle.Vehicle_Owner_State__c = driverOwner[0].State_Province__c;
                                    newvehicle.Vehicle_Owner_Postal_Code__c = driverOwner[0].Postal_Code__c;
                                    newVehicle.Vehicle_Owner_Country__c = driverOwner[0].Country__c;
                                }
                                insert newVehicle;
                                
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
                                newPolicy.Vehicle_Policy__c = newVehicle.Id;
                                newPolicy.Contact__c = leadConvertRslt.getContactId();
                                newPolicy.Policy_Parent_Account__c = leadConvertRslt.getAccountId();
                                newPolicy.Account_Policy__c = leadConvertRslt.getAccountId();
                                newPolicy.Status_picklist__c = 'Active';
                                if(String.isNotBlank(leadObj.Source__c) && leadObj.Source__c != 'Portal'){
                                    newPolicy.Source__c =leadObj.Source__c;
                                }else{
                                    newPolicy.Source__c = 'New Lead Flow';
                                }
                               
                                newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
                                newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
                                newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
                                newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
                                newPolicy.Term__c = quoteRecord.Term__c;
                                
                                if (quoteRecord.Term__c != null && quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual') {
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
                                if(quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual' ){
                                    newPolicy.Start_Time__c = newPolicy.Start_Time__c.addHours(-8);
                                    newPolicy.End_Time__c = newPolicy.End_Time__c.addHours(-8);
                                }
                                
                                newPolicy.Underwriter_picklist__c = quoteRecord.Underwriter__c;
                                newPolicy.Vehicle_type__c = quoteRecord.Vehicle_Type__c;
                                newPolicy.Insured_value__c = quoteRecord.Vehicle_Value__c;
                                newPolicy.Name = generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                                newPolicy.What_is_the_purpose_of_trip__c = termConditionRecord.What_is_the_purpose_of_trip_Tempc != null ? termConditionRecord.What_is_the_purpose_of_trip_Tempc : '';
                                newPolicy.What_is_your_trip_destination_in_US__c = termConditionRecord.What_is_your_trip_destination_in_US_Tempc != null ? termConditionRecord.What_is_your_trip_destination_in_US_Tempc : '';
                                newPolicy.Terms_of_Purchase_Confirmed__c = termConditionRecord.Terms_of_Purchase_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Purchase_Confirmed_Tempc : false;
                                newPolicy.Terms_of_Cancellation_Confirmed__c = termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc != null ? termConditionRecord.Terms_of_Cancellation_Confirmed_Tempc : false;
                                newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null && termConditionRecord.Newsletter_Tempc == 'Yes' ? true:false;
                                newPolicy.Announcements__c = termConditionRecord.Announcements_Tempc != null && termConditionRecord.Announcements_Tempc == 'Yes' ? true:false;
                                newPolicy.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null && termConditionRecord.Travel_Alerts_Tempc == 'Yes' ? true:false;
                                //newPolicy.Newsletter__c = termConditionRecord.Newsletter_Tempc != null ? termConditionRecord.Newsletter_Tempc : 'No';
                                //newPolicy.Announcements__c = termConditionRecord.Announcements_Tempc != null ? termConditionRecord.Announcements_Tempc : 'No';
                               //newPolicy.Travel_Alerts__c = termConditionRecord.Travel_Alerts_Tempc != null ? termConditionRecord.Travel_Alerts_Tempc : 'No';
                                newPolicy.Contact_Email__c = conObj.Email;
                                // Commented Code
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
                                //     newPolicy.Yellow_Card__c = String.isNotEmpty(termConditionRecord.Yellow_Card_Tempc) ? termConditionRecord.Yellow_Card_Tempc : 'No';
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
                                insert newPolicy;

                                //Update Quote With new Policy
                                quoteRecord.Policy__c = newPolicy.Id;
                                update quoteRecord;

                                //Update Vehicle With New Policy Lookup
                                newVehicle.Policy__c = newPolicy.Id;
                                update newVehicle;
                                
                                // insert the Quote_Vehicle__C Object...
                                Quote_Vehicle__C newQuoteVehicle = new Quote_vehicle__c();
                                newQuoteVehicle.Account__c = leadConvertRslt.getAccountId();
                                newQuoteVehicle.Contact__c = leadConvertRslt.getContactId();
                                newQuoteVehicle.Vehicle__c = newVehicle.Id;
                                newQuoteVehicle.Quote_c__c = quoteRecord.Id;
                                newQuoteVehicle.Policy__c = newPolicy.Id;
                                insert newQuoteVehicle;
                                
                                // insert the Quote_Driver__c Object...
                                List<Quote_Driver__c> quoteDriverList = new List<Quote_Driver__c>();
                                if (!driverRecordList.isEmpty()) {
                                    List<Driver__c> updateDriverList = new List<Driver__c>();
                                    for (Driver__c each : driverRecordList) {
                                        Quote_Driver__c newQuoteDriver = new Quote_Driver__c();
                                        newQuoteDriver.Account_Driver__c = accObj.Id;
                                        newQuoteDriver.Contact__c = conObj.Id;
                                        newQuoteDriver.Quote_c__c = quoteRecord.Id;
                                        newQuoteDriver.Driver__c = each.Id;
                                        newQuoteDriver.Vehicle_Driver__c = newVehicle.Id;
                                        newQuoteDriver.Policy__c = newPolicy.Id;
                                        quoteDriverList.add(newQuoteDriver);
                                        each.Policy__c = newPolicy.Id;
                                        updateDriverList.add(each);
                                    }
                                    
                                    if (!quoteDriverList.isEmpty()) {
                                        insert quoteDriverList;
                                    }
                                    if(!updateDriverList.isEmpty()){
                                        update updateDriverList;
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
                                        
                                        quoteTowedList.add(newQuoteTowed);
                                    }
                                    
                                    if (!quoteTowedList.isEmpty()) {
                                        insert quoteTowedList;
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
                                System.debug('caalling  policy callouts');
                                System.debug('caalling  policy callouts '+policyIds);
                                if (policyIds != null && !policyIds.isEmpty()) {
                                    Boolean add_attachment = true;
                                    Mex_Insurance_Calloututility.sendEmail(policyIds, add_attachment);
                                }
                                
                                responseMap.put('status', 'success');
                                responseMap.put('data', String.valueOf(newPolicy.Name));
                                responseMap.put('email', String.valueOf(newPolicy.Contact_Email__c));
                                responseMap.put('PolicyId', String.valueOf(newPolicy.Id));
                                responseMap.put('transactionId', String.valueOf(policyTransaction[0].Id));
                                responseMap.put('amount', String.valueOf(policyTransaction[0].Amount__c));
                            }
                            System.debug('Data at end'+conObj);
                            System.debug('DAta at end'+accObj);
                            System.debug('Data at end'+leadObj);
                        } else {
                            // Error occured while updating the quote data...
                        }
                    }
                }
            } else {
                responseMap.put('status', 'error');
                responseMap.put('message', 'Account already exist kindly retry creating policy after Logging-In!');
            } } catch (Exception ex) { responseMap.put('status', 'error'); responseMap.put('message', ex.getMessage()); 
            System.debug('Error-> '+ex.getMessage() + ' at line: '+ex.getLineNumber());
            CustomErrorExceptionHandlerException.LogException(ex); }
        return JSON.serialize(responseMap);
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
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
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
    
    @AuraEnabled
    public static Attachment generatePDF(string UserDetailId,  string userName){
        try {
            PageReference pdfpage = Page.renderAsPDF;
            pdfPage.getParameters().put('id',UserDetailId);
            Blob pdfBlob = pdfPage.getContent();
            Attachment a = new Attachment(parentId = UserDetailId, name=userName + '.pdf', body = pdfBlob);
            insert a;
            
            return a;
        }
        catch(Exception e) {
            CustomErrorExceptionHandlerException.data = 'UserDetailId: '+UserDetailId+'\nuserName: '+userName;
            CustomErrorExceptionHandlerException.LogException(e);
            return null;
        }
    }

    @AuraEnabled
    public static String preViewslectedQuote() {
        return '/apex/selectedQuoteRate';
    }

    @AuraEnabled
    public static Attachment generateSelectedQuotePDF(string UserDetailId,  string userName){
        try {
            PageReference pdfpage = Page.selectedQuoteRate;
            pdfPage.getParameters().put('id',UserDetailId);
            Blob pdfBlob = pdfPage.getContent();
            Attachment a = new Attachment(parentId = UserDetailId, name=userName + '.pdf', body = pdfBlob);
            insert a;
            return a;
        }
        catch(Exception e) {
            CustomErrorExceptionHandlerException.data = 'UserDetailId: '+UserDetailId+'\nuserName: '+userName;
            CustomErrorExceptionHandlerException.LogException(e);
            return null;
        }
    }
    
    private static SObjectType describeObject(String objectName) {
        return Schema.getGlobalDescribe().get(objectName);
    }
    
    
    @AuraEnabled
    public static List<object> getYears(){
        return VehicalAPIController.getYears();
    }
    
    @AuraEnabled
    public static List<object> getMakes(string year){
        return VehicalAPIController.getMakes(year);
    }
    
    @AuraEnabled
    public static List<object> getModels(string year, string make){
        return VehicalAPIController.getModels(year, make);
    }
    
    Public class VehicleRecordWrapper {
        Public String Year_Tempc{get;set;}
        Public String Make_Tempc{get;set;}
        Public String Model_Tempc{get;set;}
        Public String Value_Tempc{get;set;}
        Public String Vin_Tempc{get;set;}
        Public String Vehicle_Type_Tempc{get;set;}
        Public String Vehicle_sub_type_Tempc{get;set;}
        Public String Registered_State_Tempc{get;set;}
        Public String Registered_Country_Tempc{get;set;}
        Public String Registered_Plate_Tempc{get;set;}
        public BusinessAddress BusinessAddress_Tempc{get;set;}
        Public Boolean Is_Lienholder_Tempc{get;set;}
        Public Boolean Salvage_Vehicle_Tempc{get;set;}
        Public Boolean Is_there_a_driver_under_21_Tempc{get;set;}
        Public Boolean Is_this_a_Rental_Vehicle_Tempc{get;set;}
        Public Boolean Is_the_vehicle_registered_to_a_business_Tempc{get;set;}
        Public Boolean Is_the_vehicle_used_for_business_purpose_Tempc{get;set;}
        Public Boolean Is_used_user_or_company_Info_Tempc{get;set;}
        Public Boolean Is_Account_Company_Named_Tempc{get;set;}
    }
    
    public class  WatercraftRecordWrapper{
        
        public String Value_Tempc{get;set;}
        public String Make_Tempc{get;set;}
        Public String Model_Tempc{get;set;}
        public String Is_the_Maximum_Speed_more_than_50_mph_Tempc{get;set;}
        public String Year_Tempc{get;set;}
        public String Any_Boat_Operator_Under_22_Tempc{get;set;}
        public String Vessel_Length_Tempc{get;set;}
        public String Is_the_owner_living_in_Mexico_Tempc{get;set;}
        public String Type_of_Vessel_Tempc{get;set;}
        public String VIN_Number_Tempc{get;set;}
        public String Vessel_for_Hire{get;set;}
        public String Beam_Tempc{get;set;}
        public String Older_Vessel{get;set;}
        public String Flag_Tempc{get;set;}
        public String Racing{get;set;}
        public String Engine_Type_Tempc{get;set;}
        public String Commercial_Vessel{get;set;}
    }
    public class BusinessAddress{
        public String Address_Tempc{get;set;}
        public String Country_Tempc{get;set;}
        public String Postal_Code_Tempc{get;set;}
        public String City_Tempc{get;set;}
        public String State_Province_Tempc{get;set;}
        public String Address_Line_2_Tempc{get;set;}
    }
    Public class CompanyDetailsWrapper {
        Public String Company_Name_Tempc{get;set;}
        Public String Company_Phone_Tempc{get;set;}
        Public String Tax_ID_Tempc{get;set;}
        Public String Company_Country_Tempc{get;set;}
        Public String Company_State_Tempc{get;set;}
        Public String Company_City_Tempc{get;set;}
        Public String Company_Address_Tempc{get;set;}
        Public String Company_Zip_Tempc{get;set;}
    }
    
    Public class LienholderWrapper {
        Public String Lienholder_name_Tempc{get;set;}
        Public String Lienholder_Phone_Tempc{get;set;}
        Public String Lienholder_Street_Tempc{get;set;}
        Public String Lienholder_Street_2_Tempc{get;set;}
        Public String Lienholder_City_Tempc{get;set;}
        Public String Lienholder_Country_Tempc{get;set;}
        Public String Lienholder_State_Tempc{get;set;}
        Public String Lienholder_Postal_Code_Tempc{get;set;}
        Public String Lienholder_Fax_Tempc{get;set;}
    }
    
    Public class TermAndConditionWrapper {
        Public Boolean Terms_of_Purchase_Confirmed_Tempc{get;set;}
        Public Boolean Terms_of_Cancellation_Confirmed_Tempc{get;set;}
        Public String What_is_your_trip_destination_in_US_Tempc{get;set;}
        Public String What_is_the_purpose_of_trip_Tempc{get;set;}
        Public String Yellow_Card_Tempc{get;set;}
        Public String Newsletter_Tempc{get;set;}
        Public String Announcements_Tempc{get;set;}
        Public String Travel_Alerts_Tempc{get;set;}
    }
}