public class PolicyAutoRenewQuoteGenerateBatch implements Database.batchable<Sobject>,Database.Stateful , Database.AllowsCallouts{
    
    public Map<Id, Quote__c> policyIdVsQuote = new Map<Id, Quote__c>();
    public Set<Id> policyIdSet = new Set<Id>();
    public PolicyAutoRenewQuoteGenerateBatch(Set<Id> policyIdSet) {
        policyIdVsQuote = new Map<Id, Quote__c>();
        this.policyIdSet = policyIdSet;
    }
    
    public Database.queryLocator start(Database.batchableContext BC){ 
        System.debug('Start Policy Renew Batch');
        date todaysDate = date.today();
        String query = 'SELECT id, Term__c, Term_days__c, Auto_renew__c, End_Date__c, Start_Date__c, Quote_c__c, Policy_Type_picklist__c,Contact__c,Auto_renew_card__c,Renew_Payment_Profile_Id__c,Auto_Renew_Confirmed__c,Updated_Quote_Json__c  from Policy__c WHERE Id IN: policyIdSet LIMIT 50000';

        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Policy__c> policyList){
        System.debug('Policy List - '+ policyList);
        
        Set<Id> quoteIdSet = new Set<Id>();
        Map<Id,Quote__c> queryQuote = new Map<Id,Quote__c>();
        
        if(policyList.size() > 0){
            for(Policy__c policy :policyList){
                quoteIdSet.add(policy.Quote_c__c);
            }
        }
        
        if(quoteIdSet.size() > 0){
            List<Quote__c> quoteList = [SELECT Account__c, Broker_Policy_Fee__c, Contact__c, Coverage__c, End_Date_for_Coverage__c, End_Time__c, 
                                        I_V_A_Mex_Tax__c, Is_there_a_driver_under_21__c, Is_this_a_Rental_Vehicle__c, Liability_Payment__c, Liability__c, 
                                        Medical__c, Medical_Payment__c, Net_Premium__c, OwnerId, Physical_Damage__c, Platinum_Endorsment__c, Policy_Type_picklist__c, 
                                        Quote_Status__c, Quote_Value__c, Salvage_Vehicle__c, Start_Date_for_Coverage__c, Start_Time__c, Surcharge__c, Term_Days__c, 
                                        Term__c, Territory__c, Total_Theft_Payment__c, Towed_Unit__c, Trailering__c, Underwriter__c, Vehicle_Deductible_Collision__c, 
                                        Vehicle_Deductible_Comprehensive__c, Vehicle_Make__c, Vehicle_Model__c, Vehicle_Sub_type__c, Vehicle_Type__c, Vehicle_Value__c, 
                                        Vehicle_Year__c, Vehicle_used_for_Business_Purposes__c FROM Quote__c where id IN: quoteIdSet];
            
            if(quoteList.size() > 0){
                for (Quote__c quote : quoteList) {
                    queryQuote.put(quote.Id, quote);
                }
            }
        }
        
        if(policyList.size() > 0){
            for (Policy__c policy : policyList) {
                String oldquoteId = policy.Quote_c__c;
                Map<String, Object> quoteDetails = new Map<String, Object>();
                if(policy.Updated_Quote_Json__c != null){
                    quoteDetails = (Map<String, Object>)JSON.deserializeUntyped(policy.Updated_Quote_Json__c);
                }
                
                Quote__c quoteRecord = queryQuote.get(oldquoteId).clone();
                quoteRecord.Id = null;
                
                if (quoteDetails.containsKey('Vehicle_Value__c')) {
                    Object vehicleValue = quoteDetails.get('Vehicle_Value__c');
                    
                    if (vehicleValue instanceof Decimal) {
                        quoteRecord.Vehicle_Value__c = (Decimal)vehicleValue;
                    } else if (vehicleValue instanceof String) {
                        quoteRecord.Vehicle_Value__c = Decimal.valueOf((String)vehicleValue);
                    }
                }
                
                //if(quoteDetails.containskey('Vehicle_Value__c')){
                //    quoteRecord.Vehicle_Value__c = Decimal.valueOf(quoteDetails.get('Vehicle_Value__c'));
                //}
                
                if(quoteDetails.containskey('Liability__c')){
                    quoteRecord.Liability__c = String.valueOf(quoteDetails.get('Liability__c'));
                }
                
                if(quoteDetails.containskey('Medical__c')){
                    quoteRecord.Medical__c = String.valueOf(quoteDetails.get('Medical__c'));
                }
                
                insert quoteRecord;
                policyIdVsQuote.put(policy.Id, quoteRecord);
            }
        }
        System.debug('policyIdVsQuote-->'+policyIdVsQuote);
        //List<Quote__c> newQuoteRecords = new List<Quote__c>(policyIdVsQuote.values());
        
    }
    
    public void finish(Database.BatchableContext Bc) {
        System.debug('Finish Policy Renew Batch ->');
        System.debug('policyIdVsQuote-->'+policyIdVsQuote);
        if (policyIdVsQuote.size() > 0) {
            Database.executeBatch(new PolicyAutoRenewGetTransaction(policyIdVsQuote),4);
        } else {
            System.debug('Error: The Quote size is Zero');
        }
    }
    
}