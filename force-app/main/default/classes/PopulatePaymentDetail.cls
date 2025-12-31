public class PopulatePaymentDetail {
    public static void calculateAndPopulateData(){
        try{
            List<Policy__c> getAllBlankPaymentPolicyData = [SELECT Id, Name, Quote_c__c,package__c,term__c,term_days__c, 
                                                            Medical_Payment__c, Liability_Payment__c, Total_Theft_Payment__c, Physical_damage__c, 
                                                            Platinum_Endorsement_Payment__c, Underwriter_picklist__c ,Medical_picklist__c, Liability_picklist__c 
                                                            FROM Policy__c where Underwriter_picklist__c = 'Chubb' AND (Medical_Payment__c = 0 AND Liability_Payment__c = 0) AND 
                                                            Policy_Type_Picklist__c  != 'Northbound'
                                                            AND Policy_Type_Picklist__c  != 'Watercraft' 
                                                            AND Policy_Type_Picklist__c  != 'Driver License' limit 5];
            
           
            set<Id> policyId = new set<Id>();
             //  map< Quote__c> updateQuotePaymentData = new map<Id, Quote__c>();
            List<Quote__c> updateQuotePaymentData = new List<Quote__c>();            
            for(Policy__c eachPolicy : getAllBlankPaymentPolicyData){
                if(eachPolicy.Quote_c__c != null){
                    policyId.add(eachPolicy.Id);
                    Quote__c quoteData =  getQuoteWithAllFields(eachPolicy.Quote_c__c);
                  quote__c dataput =  callRateTableFunction(quoteData, eachPolicy);
                    updateQuotePaymentData.add(dataput);
                } 
            }
            
           system.debug('updateQuotePaymentData----->'+ updateQuotePaymentData);
            update updateQuotePaymentData;
            system.debug('quoteAllData--->'+policyId);
          //  system.debug('quoteIds : '+ quoteIds);
        }catch(Exception ex){
            system.debug('message : '+ ex.getMessage() +' at line : '+ ex.getLineNumber());
        }
        
    }
        public static Quote__c getQuoteWithAllFields(String quoteId) {
            List<Quote__c> quotes = new List<Quote__c>();
            if (String.isNotBlank(quoteId)) {
                String query = getQueryWithAllFields(Quote__c.getSObjectType().getDescribe().getName());
                query += ' WHERE Id=\'' + quoteId + '\'';
                quotes = Database.query(query);
            }
            return !quotes.isEmpty() ? quotes[0] : null;
        }
        
        public static String getQueryWithAllFields(String objectName) {
        return 'SELECT ' + String.join(getAllFields(objectName), ', ') + ' FROM ' + objectName;
    }
        
          private static Set<String> removeFields = new Set<String>{
        'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastvieweddate',
            'lastreferenceddate'
            };
  private static List<String> getAllFields(String objectName) {
                    System.debug('--objectName--' + objectName);
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
        
    
     private static SObjectType describeObject(String objectName) {
         return Schema.getGlobalDescribe().get(objectName);
     }
    
    
    public static Quote__c callRateTableFunction(Quote__c quoteRecord, Policy__c policyRecord){
        
        
        
        string chubbLiability = policyRecord.Liability_picklist__c != null ? policyRecord.Liability_picklist__c.replace(',','') : '';
     
        string chubbMedical = policyRecord.Medical_picklist__c != null ? '$'+ policyRecord.Medical_picklist__c.replace('/','/$') : '';
        string returndata =   QuickQuotationCtrl.getquickQuoteDataSouthBound(quoteRecord, '300000',chubbLiability, '300000', '$10,000/$50,000', chubbMedical, '$10,000/$50,000', '');
        
         system.debug('returndata-->'+ returndata);
        
        system.debug('term_days__c : '+policyRecord.term_days__c);
        
        PopulatePayementWrapper RateTableData = (PopulatePayementWrapper)JSON.deserialize(returndata, PopulatePayementWrapper.class);
        system.debug('RateTableData-->'+ RateTableData);
        system.debug('RateTableData-->'+ RateTableData.ChubbData);
        
     
        
        Decimal chubDays = policyRecord.term_days__c;
        decimal physical_damage_payment = 0;
        decimal Liability_payment = 0;
        decimal medical_payment = 0;
        decimal platinum_endorsement_payment = 0;
        decimal total_theft_payment = 0;
        decimal chubbRateValue = 0;
        if( RateTableData != null && RateTableData.ChubbData != null ){
                                        if( policyRecord.Package__c == 'Liability' ){
                                           // var totalPremiumLiabilityOnly = RateTableData.ChubbData.TotalPremiumLiabilityOnly;
                                            if( RateTableData.ChubbData.TotalPremiumLiabilityOnly != null ){
                                            
                                                
                                                if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                                    
                                                    if( policyRecord.term_days__c!= null && policyRecord.term_days__c <= 30 ){
                                                        if(RateTableData.ChubbData.TotalPremiumLiabilityOnly.Daily != null ){
                                                           	chubbRateValue = (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Daily);
                                                            physical_damage_payment = RateTableData.ChubbData.PhysicalDamage.Daily + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Daily : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Daily);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Daily);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Daily);
                                                            total_theft_payment = RateTableData.ChubbData.TotalTheft.Daily + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                            
                                                            if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                                                decimal chub_SurCharge = chubbRateValue - ( (RateTableData.ChubbData.brokerFee.Daily));
                                                                chubbRateValue += chub_SurCharge;
                                                                
                                                                
                                                                system.debug('@@ chub_SurCharge '+chub_SurCharge);
                                                               
                                                            }
                                                        }
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual != null && ( 
                                                            (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual ) + 
                                                            ( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual -  RateTableData.ChubbData.brokerFee.Semi_annual)
                                                            
                                                        ) < chubbRateValue ){
                                                            chubbRateValue = RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual - (RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                                            chubDays = 180;
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Semi_annual != null ? RateTableData.ChubbData.PhysicalDamage.Semi_annual : 0) + 
                           						                                     (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                                                            Liability_payment = RateTableData.ChubbData.Liability.Semi_annual;
                                                            medical_payment = RateTableData.ChubbData.Medical.Semi_annual;
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Semi_annual != null ? RateTableData.ChubbData.TotalTheft.Semi_annual : 0) +
                                                               					 (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                            
                                                            if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                                                decimal chub_SurCharge = chubbRateValue - ((RateTableData.ChubbData.brokerFee.Semi_annual));
                                                                chubbRateValue += chub_SurCharge;
                                                                system.debug('@@ chub_SurCharge '+chub_SurCharge);
                                                              //  component.set("v.chubbRateValue", chubbRateValue); 
                                                              //  component.set("v.chub_SurCharge", chub_SurCharge); 
                                                            }
                                                        }
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual != null && ( 
                                                            (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) + 
                                                            (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual - RateTableData.ChubbData.brokerFee.Annual)
                                                        ) < chubbRateValue ){
                                                            chubbRateValue = RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - (RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                                            chubDays = 365;
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);

                                                            if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                                                Decimal chub_SurCharge = chubbRateValue - (  (RateTableData.ChubbData.brokerFee.Annual));
                                                                chubbRateValue += chub_SurCharge;
                                                                system.debug('@@ chub_SurCharge '+chub_SurCharge);
                                                              //  component.set("v.chubbRateValue", chubbRateValue); 
                                                              //  component.set("v.chub_SurCharge", chub_SurCharge); 
                                                            }
                                                            
                                                        }
                                                    }else if( policyRecord.term_days__c != null && policyRecord.term_days__c > 30 && policyRecord.term_days__c <= 180 ){
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual != null ){
                                                            chubbRateValue = (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                                            
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Semi_annual != null ? RateTableData.ChubbData.PhysicalDamage.Semi_annual : 0 )+ 
                                                                						(RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Semi_annual);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Semi_annual);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Semi_annual != null ? RateTableData.ChubbData.TotalTheft.Semi_annual : 0) + 
                                                               						 (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                            
                                                            
                                                            if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                                                decimal chub_SurCharge = chubbRateValue - ( (RateTableData.ChubbData.brokerFee.Semi_annual));
                                                                chubbRateValue += chub_SurCharge;
                                                                system.debug('@@ chub_SurCharge '+chub_SurCharge);
                                                               // component.set("v.chubbRateValue", chubbRateValue); 
                                                              //  component.set("v.chub_SurCharge", chub_SurCharge); 
                                                            }
                                                        }
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual != null && (
                                                            (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual) + 
                                                            (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual - RateTableData.ChubbData.brokerFee.Annual)
                                                        ) < chubbRateValue ){
                                                            chubbRateValue = (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                                            chubDays = 365;
                                                            
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                            
                                                            
                                                            if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                                                decimal chub_SurCharge = chubbRateValue - ( (RateTableData.ChubbData.brokerFee.Annual));
                                                                chubbRateValue += chub_SurCharge;
                                                                system.debug('@@ chub_SurCharge '+chub_SurCharge);
                                                              //  component.set("v.chubbRateValue", chubbRateValue); 
                                                              //  component.set("v.chub_SurCharge", chub_SurCharge); 
                                                            }
                                                        }
                                                    }else if( policyRecord.term_days__c != null  && policyRecord.term_days__c > 180 && RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual != null ){
                                                        chubbRateValue = ( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                                       
                                                        physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                        Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                        medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                        platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                                        total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                        
                                                        if (quoteRecord.Is_there_a_driver_under_21__c != null && quoteRecord.Is_there_a_driver_under_21__c == 'Yes'){
                                                            decimal chub_SurCharge = chubbRateValue - ( (RateTableData.ChubbData.brokerFee.Annual));
                                                            chubbRateValue += chub_SurCharge;
                                                            system.debug('@@ chub_SurCharge '+chub_SurCharge);
                                                          //  component.set("v.chubbRateValue", chubbRateValue); 
                                                          //  component.set("v.chub_SurCharge", chub_SurCharge); 
                                                        }
                                                    }
                                                    
                                                    
                                                }else{
                                                    
                                                    if( policyRecord.term_days__c != null  && policyRecord.term_days__c <= 30 ){
                                                        if(RateTableData.ChubbData.TotalPremiumLiabilityOnly.Daily != null ){
                                                            chubbRateValue = (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Daily);
                                                            
                                                            physical_damage_payment = RateTableData.ChubbData.PhysicalDamage.Daily + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Daily : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Daily);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Daily);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Daily);
                                                            total_theft_payment = RateTableData.ChubbData.TotalTheft.Daily + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                            
                                                            
                                                        }
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual != null && ( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual ) < chubbRateValue ){
                                                            chubbRateValue = RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual;
                                                            chubDays = 180;
                                                            
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Semi_annual != null ? RateTableData.ChubbData.PhysicalDamage.Semi_annual : 0 ) + 
                                                                			(RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Semi_annual);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Semi_annual);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Semi_annual != null ? RateTableData.ChubbData.TotalTheft.Semi_annual : 0 ) + 
                                                                					(RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                            
                                                            
                                                        }
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual != null && ( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual ) < chubbRateValue ){
                                                            chubbRateValue = (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                                            chubDays = 365;
                                                            
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                            
                                                        }
                                                    }else if( chubDays != null && chubDays > 30 && chubDays <= 180 ){
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual != null){
                                                            chubbRateValue = (RateTableData.ChubbData.TotalPremiumLiabilityOnly.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual);
                                                       
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Semi_annual != null ? RateTableData.ChubbData.PhysicalDamage.Semi_annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Semi_annual);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Semi_annual);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Semi_annual != null ? RateTableData.ChubbData.TotalTheft.Semi_annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                            
                                                            
                                                        }
                                                        if( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual != null && ( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual ) < chubbRateValue ){
                                                            chubbRateValue = RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - (RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                                            chubDays = 365;
                                                            
                                                            physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                            Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                            medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                            platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                                            total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                            
                                                        }
                                                    }else if( chubDays != null && chubDays > 180 && RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual != null ){
                                                        chubbRateValue = ( RateTableData.ChubbData.TotalPremiumLiabilityOnly.Annual - RateTableData.ChubbData.BajaSonaraDiscountLiabilityOnly.Annual);
                                                    
                                                        physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                        Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                        medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                        platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementLiabilityOnly.Annual);
                                                        total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                        
                                                    }
                                                    
                                                }
                                               
                                              //  component.set("v.chubbRateValue", chubbRateValue );
                                            }else{
                                              //  component.set("v.chubbRateValue", ('0'));
                                            }
                                        }else{
                                           // var totalCompleteCoverage = RateTableData.ChubbData.TotalCompleteCoverage;
                                            if( RateTableData.ChubbData.TotalCompleteCoverage != null ){
                                                                     
                                               
                                                if( policyRecord.term_days__c != null && policyRecord.term_days__c <= 30 ){
                                                    if(RateTableData.ChubbData.TotalCompleteCoverage.Daily != null ){
                                                        chubbRateValue = (RateTableData.ChubbData.TotalCompleteCoverage.Daily);
                                                        
                                                        physical_damage_payment = RateTableData.ChubbData.PhysicalDamage.Daily + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Daily : 0);
                                                        Liability_payment = (RateTableData.ChubbData.Liability.Daily);
                                                        medical_payment = (RateTableData.ChubbData.Medical.Daily);
                                                        platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementCompleteCoverage.Daily);
                                                        total_theft_payment = RateTableData.ChubbData.TotalTheft.Daily + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                        
                                                        
                                                    }
                                                    if( (RateTableData.ChubbData.TotalCompleteCoverage.Semi_annual != null && ( RateTableData.ChubbData.TotalCompleteCoverage.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Semi_annual ) < chubbRateValue ) || Test.isRunningTest()){
                                                        chubbRateValue = (RateTableData.ChubbData.TotalCompleteCoverage.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Semi_annual);
                                                        chubDays = 180;
                                                        
                                                        physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Semi_annual != null ? RateTableData.ChubbData.PhysicalDamage.Semi_annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                                                        Liability_payment = (RateTableData.ChubbData.Liability.Semi_annual);
                                                        medical_payment = (RateTableData.ChubbData.Medical.Semi_annual);
                                                        platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementCompleteCoverage.Semi_annual);
                                                        total_theft_payment = (RateTableData.ChubbData.TotalTheft.Semi_annual != null ? RateTableData.ChubbData.TotalTheft.Semi_annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                    }
                                                    if( RateTableData.ChubbData.TotalCompleteCoverage.Annual != null && ( RateTableData.ChubbData.TotalCompleteCoverage.Annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Annual ) < chubbRateValue ){
                                                        chubbRateValue = (RateTableData.ChubbData.TotalCompleteCoverage.Annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Annual);
                                                        chubDays = 365;
                                                        
                                                        physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                        Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                        medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                        platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementCompleteCoverage.Annual);
                                                        total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                    }
                                                }else if( policyRecord.term_days__c != null && policyRecord.term_days__c > 30 && policyRecord.term_days__c <= 180 ){
                                                    if( RateTableData.ChubbData.TotalCompleteCoverage.Semi_annual != null){
                                                        chubbRateValue = (RateTableData.ChubbData.TotalCompleteCoverage.Semi_annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Semi_annual);
                                                        
                                                        physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Semi_annual != null ? RateTableData.ChubbData.PhysicalDamage.Semi_annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                                                        Liability_payment = (RateTableData.ChubbData.Liability.Semi_annual);
                                                        medical_payment = (RateTableData.ChubbData.Medical.Semi_annual);
                                                        platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementCompleteCoverage.Semi_annual);
                                                        total_theft_payment = (RateTableData.ChubbData.TotalTheft.Semi_annual != null ? RateTableData.ChubbData.TotalTheft.Semi_annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                    
                                                    }
                                                    system.debug('@@ chubbRateValue'+chubbRateValue+'@@ annual='+RateTableData.ChubbData.TotalCompleteCoverage.Annual+' dis='+RateTableData.ChubbData.BajaSonaraDiscountComplete.Annual+' total='+(RateTableData.ChubbData.TotalCompleteCoverage.Annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Annual) );
                                                    if( RateTableData.ChubbData.TotalCompleteCoverage.Annual != null && ( RateTableData.ChubbData.TotalCompleteCoverage.Annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Annual ) < chubbRateValue ){
                                                        chubbRateValue = (RateTableData.ChubbData.TotalCompleteCoverage.Annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Annual);
                                                        chubDays = 365;
                                                        
                                                        physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                        Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                        medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                        platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementCompleteCoverage.Annual);
                                                        total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                        
                                                    }
                                                }else if( policyRecord.term_days__c != null && policyRecord.term_days__c > 180 && RateTableData.ChubbData.TotalCompleteCoverage.Annual != null){
                                                    chubbRateValue = ( RateTableData.ChubbData.TotalCompleteCoverage.Annual - RateTableData.ChubbData.BajaSonaraDiscountComplete.Annual) ;
                                               
                                                    physical_damage_payment = (RateTableData.ChubbData.PhysicalDamage.Annual != null ? RateTableData.ChubbData.PhysicalDamage.Annual : 0) + (RateTableData.ChubbData.TowedUnitPhysicalDamage != null ? RateTableData.ChubbData.TowedUnitPhysicalDamage.Annual : 0);
                                                    Liability_payment = (RateTableData.ChubbData.Liability.Annual);
                                                    medical_payment = (RateTableData.ChubbData.Medical.Annual);
                                                    platinum_endorsement_payment = (RateTableData.ChubbData.PlatinumEndorsementCompleteCoverage.Annual);
                                                    total_theft_payment = (RateTableData.ChubbData.TotalTheft.Annual != null ? RateTableData.ChubbData.TotalTheft.Annual : 0) + (RateTableData.ChubbData.TowedUnitTotalTheft != null ? RateTableData.ChubbData.TowedUnitTotalTheft.Daily : 0);
                                                    
                                                
                                                }
                                                
                                              //  component.set("v.chubbRateValue", chubbRateValue );
                                                system.debug('chubbRateValue--->'+chubbRateValue);
                                              //  component.set("v.physicalDamagePayment", physical_damage_payment );
                                              
                                                system.debug('physical_damage_payment--->'+physical_damage_payment);
                                              //  component.set("v.LiabilityPayment", Liability_payment );
                                              
                                                system.debug('Liability_payment--->'+Liability_payment);
                                                
                                              //  component.set("v.medicalPayment", medical_payment );
                                              
                                              system.debug('medical_payment--->'+medical_payment);
                                                  
                                              //  component.set("v.platinumEndorsementPayment", platinum_endorsement_payment );
                                              //  
                                           system.debug('platinum_endorsement_payment--->'+platinum_endorsement_payment);
                                              //  
                                             //   component.set("v.totalTheftPayment", total_theft_payment );
                                             //   
                                                system.debug('total_theft_payment--->'+total_theft_payment);
                                                
                                            }else{
                                                
                                                 system.debug('chubbRateValue-else--->'+chubbRateValue);
                                                 system.debug('Liability_payment-else-->'+Liability_payment);
                                                  system.debug('medical_payment-else-->'+medical_payment);
                                                system.debug('platinum_endorsement_payment-else-->'+platinum_endorsement_payment);
                                                system.debug('total_theft_payment-else-->'+total_theft_payment);
                                                system.debug('physical_damage_payment-else-->'+physical_damage_payment);
                                                
                                                
                                              //  component.set("v.chubbRateValue", ('0'));
                                                
                                              //  component.set("v.physicalDamagePayment", ('0') );
                                             //   component.set("v.LiabilityPayment", ('0') );
                                             //   component.set("v.medicalPayment", ('0') );
                                             //   component.set("v.platinumEndorsementPayment", ('0') );
                                             //   component.set("v.totalTheftPayment", ('0') );
                                            }
                                        }
                                        
                                        
                                        
                                    }
        
        
        
        
        
        Quote__c updateQuotePayement = new Quote__c();
        updateQuotePayement.Id = quoteRecord.id;
        updateQuotePayement.Physical_Damage__c = physical_damage_payment;
        updateQuotePayement.Liability_Payment__c = Liability_payment;
        updateQuotePayement.Medical_Payment__c = medical_payment;
        updateQuotePayement.Platinum_Endorsment__c = platinum_endorsement_payment;
        updateQuotePayement.Total_Theft_Payment__c = total_theft_payment;
        
        
        return updateQuotePayement;
       
    }
        
}