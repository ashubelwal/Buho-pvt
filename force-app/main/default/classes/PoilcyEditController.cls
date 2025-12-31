public without sharing class PoilcyEditController {
    
    @AuraEnabled
    public static String getTimeZone() {
        return QuickQuotationCtrl.getTimeZone();
    }
    
    @AuraEnabled
    public static Policy__c fetchPolicyInfo( String policyId ) {
        list<Policy__c> policys = new list<Policy__c>();
        policys = [select Id, Quote_c__c, Start_Date__c, End_Date__c, Status_picklist__c, Net_Premium__c, I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Surcharge__c, Liability_picklist__c, Medical_picklist__c, Policy_Type_picklist__c, Name, Total_Transaction_Amount__c  from Policy__c where Id =:policyId ];
        if( policys != null && !policys.isEmpty()){
            return policys[0];
        } return null;
    }
    @AuraEnabled
    public static String preViewPdfAction( String policyId ) {
        list<Policy__c> policys = new list<Policy__c>();
        policys = [select Id, Underwriter_picklist__c, Policy_Type_picklist__c, Name  from Policy__c where Id =:policyId ];
        if( policys != null && !policys.isEmpty()){
            String policyType = policys[0].Policy_Type_picklist__c;
            String underWriter = policys[0].Underwriter_picklist__c;
            system.debug('policy Type -----> '+ policyType);
            
            if (policyType == 'Northbound') {return '/apex/Declaration_Page_Insurance_2?Id='+policyId;} else if ( policyType == 'Driver License') { return '/apex/policy_declaration_driver_license?Id='+policyId;
            }else if ( policyType == 'Watercraft') {return '/apex/watercraft_policy_declaration_Page?Id='+policyId;
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Chubb' ){
                return '/apex/Southbound_PolicyDec_Chubb?Id='+policyId;
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Mapfre' ){
                return '/apex/Southbound_PolicyDeclarationPage_Mapfre?Id='+policyId;
            }else if( policyType == 'Automobile' && underWriter != null && underWriter == 'Qualitas' ){
                return '/apex/Southbound_PolicyDecPage_Qualitas?Id='+policyId;
            }/*else if( policyType == 'RV' && underWriter != null && underWriter == 'Chubb' ){
                return '/apex/Southbound_Chubb_RV?Id='+policyId;
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Mapfre' ){
                return '/apex/Southbound_Mapfre_RV?Id='+policyId;
            }else if( policyType == 'RV' && underWriter != null && underWriter == 'Qualitas' ){
                return '/apex/Southbound_Qualitas_RV?Id='+policyId;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Qualitas' ){
                return '/apex/Southbound_Qualitas_Motorcycle?Id='+policyId;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Mapfre' ){
                return '/apex/Southbound_Mapfre_Motorcycle?Id='+policyId;
            }else if( policyType == 'Motorcycle/Street Legal ATV' && underWriter != null && underWriter == 'Chubb' ){
                return '/apex/Southbound_ChubbMotorcycle?Id='+policyId;
            }*/
        }
        return null;
    }
    
    @AuraEnabled
    public static map<String, Object> fetchEditPolicyAction( String policyId ) {
        System.debug('--policyId---'+policyId);
        System.debug('--Id.valueOf(policyId).getSobjectType()---'+Id.valueOf(policyId).getSobjectType());
        System.debug('--Policy__c.SobjectType---'+Policy__c.SobjectType);
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            list<Policy__c> policys = new list<Policy__c>();
            if( policyId != null && Id.valueOf(policyId).getSobjectType() == Policy__c.SobjectType){
                policys = [select Id, Quote_c__c, Start_Date__c, Net_Premium__c, I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Surcharge__c, Liability_picklist__c,watercraft__c, 
                           Third_Party_Bodily_Injury__c, Medical_picklist__c, Property_Damage_Liability__c, Policy_Type_picklist__c, Name, Total_Transaction_Amount__c, 
                           Vehicle_deductible_collision__c, Vehicle_deductible_comprehensive__c from Policy__c where Id =:policyId ];
            }
            String quoteId = null;
            System.debug('CA log '+ Quote__c.SobjectType);
            System.debug('CA log '+ Id.valueOf(policyId).getSobjectType());
            if( policyId != null && Id.valueOf(policyId).getSobjectType() == Quote__c.SobjectType){
                quoteId = policyId;
            }
            if( policys != null && !policys.isEmpty() ){
                quoteId = policys[0].Quote_c__c;
            }
            
            if( quoteId != null && quoteId != ''){
                Quote__c quoteRecord = QuickQuotationCtrl.getQuoteWithAllFields(quoteId);
                if (quoteRecord != null) {
                    responseMap.put('quoteRecord', quoteRecord);
                }
                
                List<Towed_Unit__c> towed_UnitList = new List<Towed_Unit__c>();
                towed_UnitList = QuickQuotationCtrl.getTowedUnit(quoteId);
                if (towed_UnitList != null && !towed_UnitList.isEmpty()) {
                    responseMap.put('towedunitRecords', towed_UnitList);
                }
                
                List<Quote_Vehicle__c> quoteVehicleList = new List<Quote_Vehicle__c>();
                quoteVehicleList = [SELECT Id, Vehicle__c FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteId];
                
                List<Vehicle__c> vehicleList = new List<Vehicle__c>();
                if( quoteVehicleList != null && !quoteVehicleList.isEmpty() && quoteVehicleList[0].Vehicle__c != null ){
                    String query = QuickQuotationCtrl.getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
                    query += ' where Id=\'' + quoteVehicleList[0].Vehicle__c + '\'';
                    vehicleList = Database.query(query);
                }
                
                if (vehicleList != null && !vehicleList.isEmpty()) {
                    responseMap.put('vehicleRecords', vehicleList);
                }
                
                List<Driver__c> driverList = new List<Driver__c>();
                driverList = QuickQuotationCtrl.getDriver(quoteId);
                if (driverList != null && !driverList.isEmpty()) {
                    responseMap.put('driverRecords', driverList);
                }
                
                List<Transaction__c> transactionList = new List<Transaction__c>();
                transactionList = QuickQuotationCtrl.retrieveTransactionDetailsByQuoteId(quoteId);
                if (transactionList != null && !transactionList.isEmpty()) {
                    responseMap.put('transactionRecords', transactionList);
                }
                
                List<Watercraft__c> watercraftList = new List<Watercraft__c>();
                watercraftList = QuickQuotationCtrl.retrieveWatercraftDetailsByQuoteId(policyId);
                if (watercraftList != null && !watercraftList.isEmpty()) {
                    responseMap.put('watercraftRecords', watercraftList);
                }
                
                if( policys != null && !policys.isEmpty()){ responseMap.put('policyType', policys[0].Policy_Type_picklist__c); responseMap.put('policyName', policys[0].Name); responseMap.put('policyRecord', policys[0]);
                }
                responseMap.put('success', true);
            }
            
        } catch (Exception e) {
            System.debug('--exception---' + e.getMessage()+'---line--'+e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static map<String, Object> fetchRenewPolicyAction( String renewQuoteId ) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            list<Policy__c> policys = new list<Policy__c>();
            if( renewQuoteId != null && Id.valueOf(renewQuoteId).getSobjectType() == Quote__c.SobjectType){
                policys = [select Id, Quote_c__c, Start_Date__c, Net_Premium__c, I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Surcharge__c, Liability_picklist__c,watercraft__c,Third_Party_Bodily_Injury__c, Medical_picklist__c, Property_Damage_Liability__c, Policy_Type_picklist__c, Name, Total_Transaction_Amount__c, Vehicle_deductible_collision__c, Vehicle_deductible_comprehensive__c from Policy__c where Quote_c__c =:renewQuoteId ];
            }
            String quoteId = null;
            
            if( policys != null && !policys.isEmpty() ){ quoteId = policys[0].Quote_c__c; responseMap.put('policyExist', true);
            }else {
                quoteId = renewQuoteId;
                responseMap.put('policyExist', false);
            }
            
            if( quoteId != null && quoteId != ''){
                Quote__c quoteRecord = QuickQuotationCtrl.getQuoteWithAllFields(quoteId);
                if (quoteRecord != null) {
                    responseMap.put('quoteRecord', quoteRecord);
                }
                
                List<Towed_Unit__c> towed_UnitList = new List<Towed_Unit__c>();
                towed_UnitList = QuickQuotationCtrl.getTowedUnit(quoteId);
                if (towed_UnitList != null && !towed_UnitList.isEmpty()) {
                    responseMap.put('towedunitRecords', towed_UnitList);
                }
                
                List<Quote_Vehicle__c> quoteVehicleList = new List<Quote_Vehicle__c>();
                quoteVehicleList = [SELECT Id, Vehicle__c FROM Quote_Vehicle__c WHERE Quote_c__c = :quoteId];
                
                List<Vehicle__c> vehicleList = new List<Vehicle__c>();
                if( quoteVehicleList != null && !quoteVehicleList.isEmpty() && quoteVehicleList[0].Vehicle__c != null ){
                    String query = QuickQuotationCtrl.getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
                    query += ' where Id=\'' + quoteVehicleList[0].Vehicle__c + '\'';
                    vehicleList = Database.query(query);
                }
                
                if (vehicleList != null && !vehicleList.isEmpty()) {
                    responseMap.put('vehicleRecords', vehicleList);
                }
                
                List<Driver__c> driverList = new List<Driver__c>();
                driverList = QuickQuotationCtrl.getDriver(quoteId);
                if (driverList != null && !driverList.isEmpty()) {
                    responseMap.put('driverRecords', driverList);
                }
                
                List<Transaction__c> transactionList = new List<Transaction__c>();
                transactionList = QuickQuotationCtrl.retrieveTransactionDetailsByQuoteId(quoteId);
                if (transactionList != null && !transactionList.isEmpty()) {
                    responseMap.put('transactionRecords', transactionList);
                }
                
                List<Watercraft__c> watercraftList = new List<Watercraft__c>();
                watercraftList = QuickQuotationCtrl.retrieveWatercraftDetailsByQuoteId(quoteId);
                if (watercraftList != null && !watercraftList.isEmpty()) {
                    responseMap.put('watercraftRecords', watercraftList);
                }
                
                if( policys != null && !policys.isEmpty()){
                    responseMap.put('policyType', policys[0].Policy_Type_picklist__c);
                    responseMap.put('policyName', policys[0].Name);
                    responseMap.put('policyRecord', policys[0]);
                }
                
                
                responseMap.put('success', true);
            }
            
        } catch (Exception e) {
            System.debug('--exception---' + e.getMessage()+'---line--'+e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getDependentMap(SObject objDetail, String contrfieldApiName, String depfieldApiName) {
        return QuickQuotationCtrl.getDependentMap(objDetail, contrfieldApiName, depfieldApiName);
    }
    
    @AuraEnabled
    public static Map<String, Object> createRenewQuoteAction(Quote__c quoteRecord, String oldQuoteId) {
        Map<String, Object> returnResonse = new map<String,object>();
        System.debug('CA log quote Record -----' + quoteRecord);
        System.debug('CA log quote Record ID -----' + quoteRecord.Id);
        System.debug('CA log old Quote Id -----' + oldQuoteId);
        if( quoteRecord.Id == oldQuoteId ){
            quoteRecord.Id = null;
        }
        if(( quoteRecord.Id != null && quoteRecord.Id != oldQuoteId)){
            System.debug('Inside IF BLock');
            return QuickQuotationCtrl.handleQuocteAction( quoteRecord );
        }else{
            System.debug('Inside Else Block');
            Map<String, Object> responseMap = fetchEditPolicyAction( oldQuoteId );
            list<Driver__c> driverRecords;
            Vehicle__c vehicleObject;
            Towed_Unit__c towedObject;
            list<Towed_Unit__c> transporates;
            List<Watercraft__c> watercraftList;
            
            if( responseMap != null && !responseMap.isEmpty() ){
                if( responseMap.containsKey('driverRecords')) {
                    driverRecords = ( list<Driver__c> )responseMap.get('driverRecords');
                }
                if( responseMap.containsKey('vehicleRecords')) {
                    list<Vehicle__c> vehicleRecords = new list<Vehicle__c>();
                    vehicleRecords = ( list<Vehicle__c> )responseMap.get('vehicleRecords');
                    if( vehicleRecords != null && !vehicleRecords.isEmpty()){
                        vehicleObject = vehicleRecords[0];
                    }
                }
                
                if( responseMap.containsKey('towedunitRecords')) {
                    transporates = ( list<Towed_Unit__c> )responseMap.get('towedunitRecords');
                    if( transporates != null && !transporates.isEmpty() && !(quoteRecord.Policy_Type_picklist__c == 'Automobile' || quoteRecord.Policy_Type_picklist__c == 'RV')){
                        towedObject = transporates[0];
                        transporates = new list<Towed_Unit__c>();
                    }
                }
                if( responseMap.containsKey('watercraftRecords')) {
                    watercraftList = ( list<Watercraft__c> )responseMap.get('watercraftRecords');
                }
            }
            returnResonse =  createClonePolicy( quoteRecord, driverRecords, vehicleObject, towedObject, transporates, quoteRecord.Policy_Type_picklist__c, oldQuoteId );
            list<Quote__c> oldQuotes = new list<Quote__c>();
            oldQuotes = [select Id, Renew_Quote__c from Quote__c where Id =: oldQuoteId and Renew_Quote__c = null limit 1];
            if( oldQuotes != null && !oldQuotes.isEmpty() && returnResonse.containsKey('quoteRecordId')
               && returnResonse.get('quoteRecordId') != null ){
                   oldQuotes[0].Renew_Quote__c = String.valueOf(returnResonse.get('quoteRecordId'));
                   try{
                       update oldQuotes;
                   }catch(Exception ex){
                       System.debug('Error ----- '+ ex.getMessage() + ' at line ----- ' + ex.getLineNumber());
                   }
               }
        }
        return returnResonse;
    }
    
    @AuraEnabled
    public static Map<String, Object> handleQuocteAction(Quote__c quoteRecord) {
        return QuickQuotationCtrl.handleQuocteAction( quoteRecord );
    }
    
    @AuraEnabled
    public static Map<String, Object> createWatercraftClonePolicy(Quote__c quoteRecord, list<Driver__c> driverRecords,
                                                                  Watercraft__c watercraftObject, String policyType, String oldQuoteId) {
                                                                      
                                                                      //QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
                                                                      Map<String, Object> returnResponseMap = new map<String,object>();
                                                                      try {
                                                                          Integer daysBetween = 0;
                                                                          if( quoteRecord.Start_Date_for_Coverage__c != null && quoteRecord.End_Date_for_Coverage__c != null ){
                                                                              daysBetween = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c );
                                                                          }
                                                                          quoteRecord.Term_Days__c = daysBetween;
                                                                          system.debug('Ca log quoteRecord.Term_Days__c : '+ quoteRecord.Term_Days__c);
                                                                          if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c <= 30) {
                                                                              quoteRecord.Term__c = 'Daily';
                                                                          } else {
                                                                              quoteRecord.Term__c = 'Annual';
                                                                          }
                                                                          if( quoteRecord.id == null ){
                                                                              quoteRecord.Quote_Status__c = 'Draft';
                                                                              insert quoteRecord;
                                                                          }else{
                                                                              update quoteRecord;
                                                                          }
                                                                          
                                                                          list<Transaction__c> TransactionsList = new list<Transaction__c>();
                                                                          for (Transaction__c trans : [SELECT Id, Policy_Transaction__c, Quote_c__c, Account_Transaction__c FROM Transaction__c WHERE Quote_c__c =: oldQuoteId]) {
                                                                              TransactionsList.add(trans);
                                                                              system.debug('CA log trans : ' + trans);
                                                                          }
                                                                          
                                                                          if( quoteRecord.Id != null ) {
                                                                              String watercraftId = null;
                                                                              if( watercraftObject != null ){
                                                                                  map<String, Object> responseMap = WatercraftFlowController.createWatercraftAction(watercraftObject, quoteRecord,'');
                                                                              }
                                                                              
                                                                              List<Quote_Watercraft__c> quotevehicleList = new List<Quote_Watercraft__c>();
                                                                              quotevehicleList = [SELECT Id, Watercraft__c, Quote_c__c, Account__c, Contact__c FROM Quote_Watercraft__c WHERE Quote_c__c =: quoteRecord.Id];
                                                                              Map<String, Quote_Watercraft__c> quoteVehicleMap = new Map<String, Quote_Watercraft__c>();
                                                                              for (Quote_Watercraft__c vehicle : quotevehicleList) {
                                                                                  quoteVehicleMap.put(vehicle.Quote_c__c, vehicle);
                                                                                  watercraftId = vehicle.Watercraft__c;
                                                                              }
                                                                              
                                                                              if( driverRecords != null && !driverRecords.isEmpty()){
                                                                                  for(Driver__c driverRecord : driverRecords){
                                                                                      map<String, Object> responseMap = WatercraftFlowController.createDriverAction(driverRecord, quoteRecord.Id, false, watercraftId, false);
                                                                                      if( responseMap != null && responseMap.containsKey('savedDriverRecord')){
                                                                                          Driver__c savedDriverRecord = (Driver__c)responseMap.get('savedDriverRecord');
                                                                                          if( savedDriverRecord != null && savedDriverRecord.Id != null ){
                                                                                              driverRecord.Id = savedDriverRecord.Id;
                                                                                          }
                                                                                      }
                                                                                  }
                                                                              }
                                                                              returnResponseMap.put('success', true);
                                                                              returnResponseMap.put('quoteRecord', quoteRecord);
                                                                              returnResponseMap.put('quoteRecordId', quoteRecord.Id);
                                                                              returnResponseMap.put('driverRecords', driverRecords);
                                                                              returnResponseMap.put('watercraftObject', watercraftObject);
                                                                          }
                                                                      } catch (Exception ex) {
                                                                          System.debug('--Exception---'+ex.getMessage()+'--line--'+ex.getLineNumber());
                                                                          //throw new AuraHandledException(e.getMessage());
                                                                      }
                                                                      return returnResponseMap;
                                                                  }
    
    @AuraEnabled
    public static Map<String, Object> createClonePolicy(Quote__c quoteRecord, list<Driver__c> driverRecords,
                                                        Vehicle__c vehicleObject, Towed_Unit__c towedObject, list<Towed_Unit__c> transporates, String policyType, String oldQuoteId){
                                                            
                                                            QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
                                                            Map<String, Object> returnResponseMap = new map<String,object>();
                                                            try {
                                                                Integer daysBetween = 0;
                                                                if( quoteRecord.Start_Date_for_Coverage__c != null && quoteRecord.End_Date_for_Coverage__c != null ){
                                                                    daysBetween = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c );
                                                                }
                                                                quoteRecord.Term_Days__c = daysBetween;
                                                                system.debug('Ca log quoteRecord.Term_Days__c : '+ quoteRecord.Term_Days__c);
                                                                if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c <= 30) {
                                                                    quoteRecord.Term__c = 'Daily';
                                                                } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 30 && quoteRecord.Term_Days__c <= 90) {
                                                                    quoteRecord.Term__c = '90 Day';
                                                                } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 90 && quoteRecord.Term_Days__c <= 180) {
                                                                    quoteRecord.Term__c = 'Semi-Annual';
                                                                } else if (quoteRecord.Term_Days__c != null && quoteRecord.Term_Days__c > 180) {
                                                                    quoteRecord.Term__c = 'Annual';
                                                                }
                                                                if( quoteRecord.id == null ){
                                                                    quoteRecord.Quote_Status__c = 'Draft';
                                                                    insert quoteRecord;
                                                                }else{
                                                                    update quoteRecord;
                                                                }
                                                                
                                                                system.debug('Ca log auoteId : '+ oldQuoteId);
                                                                list<Transaction__c> TransactionsList = new list<Transaction__c>();
                                                                for (Transaction__c trans : [SELECT Id, Policy_Transaction__c, Quote_c__c, Account_Transaction__c FROM Transaction__c WHERE Quote_c__c =: oldQuoteId]) {
                                                                    TransactionsList.add(trans);
                                                                    system.debug('CA log trans : ' + trans);
                                                                }
                                                                
                                                                
                                                                if( quoteRecord.Id != null ){
                                                                    String vehicleId = null;
                                                                    if( vehicleObject != null ){
                                                                        map<String, Object> responseMap = QuickQuotationCtrl.createVehicleNorthAction(vehicleObject, quoteRecord.Id );
                                                                    }
                                                                    
                                                                    List<Quote_Vehicle__c> quotevehicleList = new List<Quote_Vehicle__c>();
                                                                    quotevehicleList = [SELECT Id, Vehicle__c, Vehicle__r.Rental__c, Quote_c__c, Account__c, Contact__c FROM Quote_Vehicle__c WHERE Quote_c__c =: quoteRecord.Id];
                                                                    Map<String, Quote_Vehicle__c> quoteVehicleMap = new Map<String, Quote_Vehicle__c>();
                                                                    for (Quote_Vehicle__c vehicle : quotevehicleList) {
                                                                        quoteVehicleMap.put(vehicle.Quote_c__c, vehicle);
                                                                        vehicleId = vehicle.Vehicle__c;
                                                                    }
                                                                    
                                                                    set<String> twoUintIds = new set<String>();
                                                                    if( towedObject != null && towedObject.Make__c != null && towedObject.Model__c != null){
                                                                        map<String, Object> responseMap = QuickQuotationCtrl.createTowedUnit(towedObject, quoteRecord.Id, vehicleId );
                                                                        system.debug('responseMap-->'+ responseMap);
                                                                        if( responseMap != null && responseMap.containsKey('success') && responseMap.containsKey('towedUnitId')){
                                                                            towedObject.Id = String.valueOf(responseMap.get('towedUnitId'));
                                                                            twoUintIds.add(towedObject.Id);
                                                                        }
                                                                    }
                                                                    if( transporates != null && !transporates.isEmpty()){
                                                                        for(Towed_Unit__c tow : transporates){
                                                                            map<String, Object> responseMap = QuickQuotationCtrl.createTowedUnit(tow, quoteRecord.Id, vehicleId );
                                                                            if( responseMap != null && responseMap.containsKey('success') && responseMap.containsKey('towedUnitId')){
                                                                                tow.Id = String.valueOf(responseMap.get('towedUnitId'));
                                                                                twoUintIds.add(tow.Id);
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    if( driverRecords != null && !driverRecords.isEmpty()){
                                                                        for(Driver__c driverRecord : driverRecords){
                                                                            map<String, Object> responseMap = QuickQuotationCtrl.createDriverAction(driverRecord, quoteRecord.Id, false, null, false);
                                                                            if( responseMap != null && responseMap.containsKey('savedDriverRecord')){
                                                                                Driver__c savedDriverRecord = (Driver__c)responseMap.get('savedDriverRecord');
                                                                                if( savedDriverRecord != null && savedDriverRecord.Id != null ){
                                                                                    driverRecord.Id = savedDriverRecord.Id;
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    returnResponseMap.put('success', true);
                                                                    returnResponseMap.put('towedObject', towedObject);
                                                                    returnResponseMap.put('transporates', transporates);
                                                                    returnResponseMap.put('quoteRecord', quoteRecord);
                                                                    returnResponseMap.put('quoteRecordId', quoteRecord.Id);
                                                                    returnResponseMap.put('driverRecords', driverRecords);
                                                                    returnResponseMap.put('vehicleObject', vehicleObject);
                                        
                                                                }
                                                            } catch (Exception ex) {
                                                                System.debug('--Exception---'+ex.getMessage()+'--line--'+ex.getLineNumber());
                                                                //throw new AuraHandledException(e.getMessage());
                                                                
                                                            }
                                                            return returnResponseMap;
                                                        }
    
    
    @AuraEnabled
    public static map<String,object>  createPolicy(Quote__c quoteRecord, String oldQuoteId, Boolean IsRenew){
        
        System.debug('--oldQuoteId--'+oldQuoteId);
        System.debug('Quote Record ----->> '+ quoteRecord);
        map<String,object> returnResponseMap = new map<String,object>();
        
        list<Transaction__c> TransactionsList = new list<Transaction__c>();
        for (Transaction__c trans : [SELECT Id, Policy_Transaction__c, Quote_c__c, Account_Transaction__c FROM Transaction__c WHERE Quote_c__c =: oldQuoteId]) {
            TransactionsList.add(trans);
        }
        
        List<Quote_Vehicle__c> quotevehicleList = new List<Quote_Vehicle__c>();
        quotevehicleList = [SELECT Id, Vehicle__c, Vehicle__r.Rental__c, Quote_c__c, Account__c, Contact__c FROM Quote_Vehicle__c WHERE Quote_c__c =: quoteRecord.Id];
        Map<String, Quote_Vehicle__c> quoteVehicleMap = new Map<String, Quote_Vehicle__c>();
        for (Quote_Vehicle__c vehicle : quotevehicleList) {
            quoteVehicleMap.put(vehicle.Quote_c__c, vehicle);
        }
        
        map<String, list<Quote_Towed_Unit__c>> quoteIdVsTowedMap = new map<String, list<Quote_Towed_Unit__c>>();
        for(Quote_Towed_Unit__c qTu : [ select Id, Quote_c__c, policy__c from Quote_Towed_Unit__c where Quote_c__c =: quoteRecord.Id ]){
            if( !quoteIdVsTowedMap.containskey( qTu.Quote_c__c ) ){
                quoteIdVsTowedMap.put(  qTu.Quote_c__c, new list<Quote_Towed_Unit__c>{qTu} );
            }else{
                quoteIdVsTowedMap.get( qTu.Quote_c__c ).add( qTu );
            }
        }
        System.debug('--quoteIdVsTowedMap--'+quoteIdVsTowedMap);
        
        map<String, list<Quote_Driver__c>> quoteIdVsDriverMap = new map<String, list<Quote_Driver__c>>();
        for(Quote_Driver__c qTu : [ select Id, Quote_c__c, policy__c from Quote_Driver__c where Quote_c__c =: quoteRecord.Id  ]){
            if( !quoteIdVsDriverMap.containskey( qTu.Quote_c__c ) ){
                quoteIdVsDriverMap.put(  qTu.Quote_c__c, new list<Quote_Driver__c>{qTu} );
            }else{
                quoteIdVsDriverMap.get( qTu.Quote_c__c ).add( qTu );
            }
        }
        
        map<String, list<Quote_Watercraft__c>> quoteIdVsWatercraftMap = new map<String, list<Quote_Watercraft__c>>();
        for(Quote_Watercraft__c qTu : [ select Id, Quote_c__c, policy__c from Quote_Watercraft__c where Quote_c__c =: quoteRecord.Id  ]){
            if( !quoteIdVsWatercraftMap.containskey( qTu.Quote_c__c ) ){
                quoteIdVsWatercraftMap.put(  qTu.Quote_c__c, new list<Quote_Watercraft__c>{qTu} );
            }else{
                quoteIdVsWatercraftMap.get( qTu.Quote_c__c ).add( qTu );
            }
        }
        
        Map<String, String> policyDeveloperNameVsId = new Map<String, String>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Policy__c']) {
            policyDeveloperNameVsId.put(rt.DeveloperName, rt.Id);
        }
        
        list<Policy__c> oldpolicys = new list<Policy__c>();
        oldpolicys = [select Id, Quote_c__c, Net_Premium__c, Status_picklist__c, Affiliate_Account__c, Watercraft__c, I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Liability_picklist__c, Medical_picklist__c, Policy_Type_picklist__c, Name from Policy__c where Quote_c__c =:oldQuoteId ];
        
        
        Policy__c newPolicy = new Policy__c();
        newPolicy.Broker_Policy_Fee__c = quoteRecord.Broker_Policy_Fee__c;
        newPolicy.I_V_A_Mex_Tax__c = quoteRecord.I_V_A_Mex_Tax__c;
        newPolicy.Net_Premium__c = quoteRecord.Net_Premium__c;
        newPolicy.Total_Transaction_Amount__c = quoteRecord.Quote_Value__c;
        newPolicy.Policy_Type_picklist__c = quoteRecord.Policy_Type_picklist__c;
        newPolicy.Quote_c__c = quoteRecord.Id;
        newPolicy.Package__c = quoteRecord.Coverage__c;
        newPolicy.Surcharge__c = quoteRecord.Surcharge__c;
        newPolicy.Vehicle_deductible_collision__c = quoteRecord.Vehicle_Deductible_Collision__c;
        newPolicy.Vehicle_deductible_comprehensive__c = quoteRecord.Vehicle_Deductible_Comprehensive__c;
        
        newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
        if (newPolicy.Policy_Type_picklist__c != null) {
            newPolicy.RecordTypeId = policyDeveloperNameVsId.get('Automobile');
        }
        if (quoteVehicleMap != null && quoteVehicleMap.containsKey(quoteRecord.Id)) {
            newPolicy.Rental__c = quoteVehicleMap.get(quoteRecord.Id).Vehicle__r.Rental__c;
            newPolicy.Vehicle_Policy__c = quoteVehicleMap.get(quoteRecord.Id).Vehicle__c;
        }
        
        /*if (quoteIDVsPackageMap != null && quoteIDVsPackageMap.containsKey(qtObj.Id)) {
newPolicy.Package__c = quoteIDVsPackageMap.get(qtObj.Id);
}*/
        
        newPolicy.Contact__c = quoteRecord.Contact__c;
        newPolicy.Policy_Parent_Account__c = quoteRecord.Account__c;
        newPolicy.Account_Policy__c = quoteRecord.Account__c;
        
        newPolicy.Status_picklist__c = 'Active';
        Date myDate = Date.newInstance(2011, 11, 18);
        
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
        
        if (oldpolicys[0].Policy_Type_picklist__c == 'Watercraft') {
            newPolicy.Watercraft__c = oldpolicys[0].Watercraft__c;
        }
        
        newPolicy.Medical_picklist__c = quoteRecord.Medical__c;
        newPolicy.Liability_picklist__c = quoteRecord.Liability__c;
        newPolicy.Territory_picklist__c = quoteRecord.Territory__c;
        newPolicy.Term__c = quoteRecord.Term__c;
        
        if (quoteRecord.Term__c != null && (quoteRecord.Term__c == 'Annual(One Year)' || quoteRecord.Term__c == 'Annual')) {
            newPolicy.Term_days__c = 365;
        } else {
            newPolicy.Term_days__c = quoteRecord.Term_Days__c;
        }
        
        newPolicy.Underwriter_picklist__c = quoteRecord.Underwriter__c;
        newPolicy.Vehicle_type__c = quoteRecord.Vehicle_Type__c;
        newPolicy.Insured_value__c = quoteRecord.Vehicle_Value__c;
        
        if ( oldpolicys != null && !oldpolicys.isEmpty()) {
            if (IsRenew) {
                newPolicy.Name = QuickQuotationCtrl.generatePolicyName(quoteRecord.Underwriter__c, quoteRecord.Policy_Type_picklist__c, quoteRecord.Coverage__c, quoteRecord.Term__c, quoteRecord.Territory__c);
                newPolicy.renewed_check__c = true;
                newPolicy.renewed_from_id__c = String.valueOf(oldpolicys[0].Id);
            } else {
                newPolicy.Affiliate_Account__c = oldpolicys[0].Affiliate_Account__c;
                //newPolicy.Policy__c = oldpolicys[0].Id;
                String oldName = oldpolicys[0].Name;
                try{
                    if( oldName != null ){
                        String clonePoilcyTimes = oldName.substringAfterLast('-');
                        if( clonePoilcyTimes != null && clonePoilcyTimes.length() > 2 ){
                            oldName += '-2';
                        }else{
                            Integer cloneNumber = Integer.valueOf(clonePoilcyTimes) + 1;
                            oldName = oldName.substringBeforeLast('-') + '-'+cloneNumber;
                        }
                    }
                }catch(Exception ex){
                    system.debug('Error ----> ' + ex.getMessage() + ' on Line ----> ' + ex.getLineNumber());
                }
                newPolicy.Name = oldName;
            }
            insert newPolicy;
        }
        
        try{
            if ( oldpolicys != null && !oldpolicys.isEmpty()) {
                if(newPolicy != null && newPolicy.Id != null){
                    oldpolicys[0].Policy__c = newPolicy.Id;
                    // oldpolicys[0].Status_picklist__c = 'Updated';
                    if (!IsRenew) {
                        oldpolicys[0].Status_picklist__c = 'Updated';
                    }
                }
                
                update oldpolicys;
            }
        }catch(exception ex ){
            system.debug('Error ----> ' + ex.getMessage() + ' on Line ----> ' + ex.getLineNumber());
        }
        
        try{
            
            if( newPolicy.Id != null ){
                quoteRecord.Quote_Status__c = 'Policy Created';
                update quoteRecord;
                
                if (quoteVehicleMap != null && quoteVehicleMap.containsKey(quoteRecord.Id)) {
                    quoteVehicleMap.get(quoteRecord.Id).Policy__c = newPolicy.Id;
                    
                    update quoteVehicleMap.values();
                }
                
                if( quoteIdVsDriverMap != null && quoteIdVsDriverMap.containskey(quoteRecord.Id) ){
                    list<Quote_Driver__c> driverlistTemp = new list<Quote_Driver__c>();
                    for(Quote_Driver__c qtv : quoteIdVsDriverMap.get(quoteRecord.Id)) {
                        qtv.Policy__c = newPolicy.Id;
                        driverlistTemp.add(qtv);
                    }
                    
                    if( driverlistTemp != null && !driverlistTemp.isEmpty() ){
                        update driverlistTemp;
                    }
                }
                System.debug('--quoteRecord.Id--'+quoteRecord.Id);
                if( quoteIdVsTowedMap != null && quoteIdVsTowedMap.containskey(quoteRecord.Id) ){
                    list<Quote_Towed_Unit__c> transporatesTemp = new list<Quote_Towed_Unit__c>();
                    for(Quote_Towed_Unit__c qtv : quoteIdVsTowedMap.get( quoteRecord.Id )) {
                        qtv.Policy__c = newPolicy.Id;
                        transporatesTemp.add(qtv);
                    }
                    System.debug('--transporatesTemp.Id--'+transporatesTemp);
                    if( transporatesTemp != null && !transporatesTemp.isEmpty() ){
                        update transporatesTemp;
                    }
                }
                
                if( quoteIdVsWatercraftMap != null && quoteIdVsWatercraftMap.containskey(quoteRecord.Id) ){
                    list<Quote_Watercraft__c> QuoteWaterCraftTemp = new list<Quote_Watercraft__c>();
                    for(Quote_Watercraft__c qtv : quoteIdVsWatercraftMap.get( quoteRecord.Id )) {
                        qtv.Policy__c = newPolicy.Id;
                        QuoteWaterCraftTemp.add(qtv);
                    }
                    System.debug('--QuoteWaterCraftTemp.Id--'+QuoteWaterCraftTemp);
                    if( QuoteWaterCraftTemp != null && !QuoteWaterCraftTemp.isEmpty() ){
                        update QuoteWaterCraftTemp;
                    }
                }
            }
            
            if( TransactionsList != null && !TransactionsList.isEmpty() && !IsRenew){
                for(Transaction__c tran : transactionsList){
                    tran.Quote_c__c = quoteRecord.Id;
                    tran.Policy_Transaction__c = newPolicy.Id;
                }
                
                try{
                    update transactionsList;
                }catch(Exception ex ){
                    
                }
            }
            
            returnResponseMap.put('success', true);
            returnResponseMap.put('policyNewId', newPolicy.Id);
            if (newPolicy.Id != null) {
                Boolean add_attachment = true;
                Mex_Insurance_Calloututility.sendEmail(new set<String>{newPolicy.Id}, true);
                Mex_Insurance_Calloututility.sendEmail(new set<String>{newPolicy.Id}, false);
            }
        }catch (Exception ex) {
            System.debug('--Exception---'+ex.getMessage()+'--line--'+ex.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
        
        return returnResponseMap;
    }
    
    @AuraEnabled
    public static String  calculateNewRate(Quote__c quoteRecord){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            system.debug('@@ calculateNewRate '+quoteRecord);
            
            Integer days = 0;
            days = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
            //days = integer.valueOf(quoteRecord.Term_Days__c);
            decimal liabilityLimit = decimal.valueOf(string.valueOf(quoteRecord.Liability__c).replace(',',''));
            String medicalLimit = quoteRecord.Medical__c;
            if(medicalLimit != null){
                medicalLimit = ('$'+medicalLimit.substringBefore('/') + '/'+'$'+medicalLimit.substringAfter('/'));
            }
            list<Towed_Unit__c> towedUnits = new list<Towed_Unit__c>();
            towedUnits = [SELECT id, ownerid,Days_in_Tow__c, name, lastactivitydate, policy__c, towed_unit_type__c, towed_unit_value__c, towing_terms__c, street_legal__c, vin_number__c, year__c, make__c, model__c, quote_c__c, plate__c, contact__c, account__c, lead__c FROM Towed_Unit__c where id IN (select Towed_Unit__c from Quote_Towed_Unit__c where Quote_c__c =:quoteRecord.Id) ];
            string Underwriter = quoteRecord.Underwriter__c;
            
            if (quoteRecord.Policy_Type_picklist__c == 'Watercraft') {
                String watercraftRate = JSON.serialize(WatercraftCalculation.calculate(quoteRecord));
                system.debug('@@ watercraftRate '+watercraftRate);
                return watercraftRate;
            } 
            responseMap.put('success', true);
            responseMap.put('days', days);
            system.debug('@@ responseMap '+responseMap);
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        system.debug('@@ responseMap == '+responseMap);
        return JSON.serialize(responseMap);
    }
    @AuraEnabled
    public static map<String, Object> refundCalculation( String policyId ) {
        system.debug('policyId>>>>>'+policyId);
        list<Policy__c> policies = new list<Policy__c>();
        Map<String, Object> responseMap = new Map<String, Object>();

        policies = [select Id, Agent_Brokerage_Fee__c, Territory_picklist__c, Term__c, Term_days__c, Start_Date__c, End_Date__c,Start_time__c, End_time__c, Vehicle_type__c, Package__c, Quote_c__c, Underwriter_picklist__c, Net_Premium__c, I_V_A_Mex_Tax__c, Broker_Policy_Fee__c, Surcharge__c, Liability_picklist__c, Medical_picklist__c, Policy_Type_picklist__c, Name, Total_Transaction_Amount__c  from Policy__c where Id =:policyId ];

        if(policies[0].Policy_Type_picklist__c == 'Northbound' && policies[0].Policy_Type_picklist__c == 'Watercraft') {
            responseMap.put('success', false);
            responseMap.put('error', true);
            responseMap.put('Data', 'Not available currently.');
            return responseMap;
        }

        if( policies != null && !policies.isEmpty() ){
            Integer daysUsed;

            Quote__c quoteRecord = new Quote__c();
            String quoteId = policies[0].Quote_c__c;
            system.debug('quoteId-->'+ quoteId);
            if( quoteId != null && quoteId != ''){
                quoteRecord = QuickQuotationCtrl.getQuoteWithAllFields(quoteId);
            }
            string Underwriter = quoteRecord.Underwriter__c;
            system.debug('@@ policies[0].Start_Date__c'+policies[0].Start_Date__c+' daysbetween '+date.today().daysbetween(policies[0].Start_Date__c));
            if(policies[0].Start_Date__c != null && policies[0].Start_Date__c <= date.today()){
                daysUsed = policies[0].Start_Date__c.daysbetween(date.today()) + 1;
            }

            List<Map<String, Object>> policydata = PolicyFormatter.transformPolicyData(policyId);
            Map<String, Object> retrievedTermOption = (Map<String, Object>) policydata[3].get('termOption');
            String agentBrokerageFee = String.valueOf(policies[0].Agent_Brokerage_Fee__c);
            String brokerPolicyFee = String.valueOf(policies[0].Broker_Policy_Fee__c);

            if (daysUsed != null && daysUsed <= 30) {
                retrievedTermOption.put('Term__c', 'Daily');
            } else if (daysUsed != null && daysUsed > 30 && daysUsed <= 180) {
                retrievedTermOption.put('Term__c', 'Semi-Annual');
            } else if (daysUsed != null && daysUsed > 180) {
                retrievedTermOption.put('Term__c', 'Annual');
            }

            retrievedTermOption.put('End_Date_for_Coverage__c', Date.today());
            System.debug('policydata::::'+policydata);
            if(Test.isRunningTest()){
                 CalculateCoverage.isFeatureEnabled = true;
            }
            Map<String,Map<String,String>> rates = calculatecoverage.CalculateTotalCoverage(JSON.serialize(policydata));
            System.debug('Data :::: ' + rates.get(Underwriter));
            if(daysUsed != null && daysUsed > 0 && policies[0].term__c != 'Daily'){
                // Rates return convert to wrapper
                rates.get(Underwriter).put('DaysUsed', String.valueOf(daysUsed));
                rates.get(Underwriter).put('AgentBrokerageFee', agentBrokerageFee);
                rates.get(Underwriter).put('BrokerPolicyFee', brokerPolicyFee);
                rates.get(Underwriter).put('PolicyNotStartedYet', (daysUsed == 0 ? String.valueOf(true) : String.valueOf(false)));
                responseMap.put('success', true);
                responseMap.put('Data', rates.get(Underwriter));
            } else {
                // zero days consumed and trying to terminate...
                if (policies[0].term__c != null && policies[0].term__c == 'Daily' && policies[0].Start_Date__c != null && policies[0].Start_Date__c == Date.today()) {
                    Date policydate = policies[0].Start_Date__c;
                    Time strtTime = policies[0].Start_Time__c;
                    DateTime policyDateTime = DateTime.newInstance(policydate, strtTime);
                    Long timeAvailable = (DateTime.now().getTime()) - (policyDateTime.getTime()) ;

                    if(timeAvailable <= 1800000){
                        rates.get(Underwriter).put('DaysUsed', '0');
                        rates.get(Underwriter).put('AgentBrokerageFee', agentBrokerageFee);
                        rates.get(Underwriter).put('BrokerPolicyFee', brokerPolicyFee);
                        rates.get(Underwriter).put('PolicyNotStartedYet', String.valueOf(true));
                        //responseMap.put('message', 'This policy has not yet started, so there is no premium charged. The cancellation fee is equal to the broker fee paid.');
                        responseMap.put('success', true);
                        responseMap.put('Data', rates.get(Underwriter));
                    } else{
                        rates.get(Underwriter).put('DaysUsed', String.valueOf(daysUsed));
                        rates.get(Underwriter).put('AgentBrokerageFee', agentBrokerageFee);
                    	rates.get(Underwriter).put('BrokerPolicyFee', brokerPolicyFee);
                        rates.get(Underwriter).put('PolicyNotStartedYet', String.valueOf(false));
                        responseMap.put('success', false);
                        responseMap.put('Data', rates.get(Underwriter));
                        responseMap.put('error', 'This policy cannot be canceled. Daily Policies are considered Fully Earned as soon as they start. Contact support for further assistance.');
                    }
                } else if (policies[0].term__c != null && policies[0].term__c == 'Daily' && policies[0].Start_Date__c != null && policies[0].Start_Date__c > Date.today()) {
                    rates.get(Underwriter).put('DaysUsed', '0');
                    rates.get(Underwriter).put('AgentBrokerageFee', agentBrokerageFee);
                    rates.get(Underwriter).put('BrokerPolicyFee', brokerPolicyFee);
                    rates.get(Underwriter).put('PolicyNotStartedYet', String.valueOf(true));
                    //responseMap.put('message', 'This policy has not yet started, so there is no premium charged. The cancellation fee is equal to the broker fee paid.');
                    responseMap.put('success', true);
                    responseMap.put('Data', rates.get(Underwriter));
                } else if (policies[0].term__c != null && policies[0].term__c != 'Daily' && policies[0].Start_Date__c != null && policies[0].Start_Date__c > Date.today()) {
                    rates.get(Underwriter).put('DaysUsed', '0');
                    rates.get(Underwriter).put('AgentBrokerageFee', agentBrokerageFee);
                    rates.get(Underwriter).put('BrokerPolicyFee', brokerPolicyFee);
                    rates.get(Underwriter).put('PolicyNotStartedYet', String.valueOf(true));
                    responseMap.put('success', true);
                    responseMap.put('Data', rates.get(Underwriter));
                }
            }
        }

        return responseMap;
    }
    @AuraEnabled
    public static Map<String, string> terminatedPolicy( String policyId, String whyTerminate) {
        Map<String, String> responseMap = new Map<String, String>();
        list<Policy__c> policys = new list<Policy__c>();
        policys = [select Id, Status_picklist__c, Start_Date__c, End_Date__c, End_Time__c,Term_days__c  from Policy__c where Id =:policyId ];
        if( policys != null && !policys.isEmpty() && policys[0].Status_picklist__c != 'Terminated'){
            try{
                policys[0].Status_picklist__c = 'Terminated';
                policys[0].Why_Terminate_Policy__c = whyTerminate;
                policys[0].End_Date__c = System.today();
                if( policys[0].Start_Date__c != null ){
                    policys[0].Term_days__c = policys[0].Start_Date__c.daysBetween( System.today() );
                }
                if(  policys[0].Term_days__c != null &&  policys[0].Term_days__c < 0){
                    policys[0].Term_days__c = 0;
                }
                policys[0].End_Time__c = Time.newInstance(System.now().hour(), System.now().minute(), 0, 0);
                update policys;
                
                responseMap.put('status', 'success');
            }catch(Exception ex){
                responseMap.put('status', 'error');
                responseMap.put('message', ex.getMessage());
            }
            
        }
        else{
            responseMap.put('status', 'error');
            responseMap.put('message', 'Policy Already Terminated');
        }
        
        return responseMap;
    }
    
    
    public class refundWrapper{
        @AuraEnabled
        public decimal premium;
        @AuraEnabled
        public decimal oldPremium;
        @AuraEnabled
        public decimal surcharge;
        @AuraEnabled
        public decimal ivaTax;
        @AuraEnabled
        public decimal brokerFee;
        @AuraEnabled
        public decimal total;
        @AuraEnabled
        public integer daysUsed;
        @AuraEnabled
        public date endDate;
        @AuraEnabled
        public string message;
        @AuraEnabled
        public boolean policyNotStartedYet;
        @AuraEnabled
        public String policyType;
    }
}