public class PolicyAutoRenewGetTransaction implements Database.batchable<Sobject> ,Database.Stateful, Database.AllowsCallouts {
    
    public Map<String,object> policyIdsVsTransaction = new Map<String, object>();
    public Map<Id, Quote__c> policyIdVsQuote = new Map<Id, Quote__c>();
    public Set<String> policyIdsSet = new Set<String>();
    public Map<String,AuthorizeNetClient.CreateTransactionRequest> policyVsRequest = new Map<String,AuthorizeNetClient.CreateTransactionRequest>();
    public Map<String,AuthorizeNetClient.CreateTransactionResponse> policyVsResponse = new Map<String,AuthorizeNetClient.CreateTransactionResponse>();
    public Map<Id,Object> failedTransacation = new Map<Id,Object>();
    
    public PolicyAutoRenewGetTransaction(Map<Id, Quote__c> quotes) {
        this.policyIdVsQuote = quotes;
        this.policyIdsSet = new Set<String>(); 
        this.policyIdsVsTransaction = new Map<String, object>();
        this.policyVsRequest = new Map<String,AuthorizeNetClient.CreateTransactionRequest>();
        this.policyVsResponse = new Map<String,AuthorizeNetClient.CreateTransactionResponse>();
        this.failedTransacation = new Map<Id,Object>();
    } 
    
    public Database.queryLocator start(Database.batchableContext BC){ 
        System.debug('Start Policy Renew Batch');
        Set<String> policyIdsQuery = new Set<String>();
        for(String policyIds : policyIdVsQuote.keyset()){
            System.debug('policyIds---'+policyIds);
            policyIdsQuery.add(policyIds);
        }
        System.debug('policyIdsQuery---'+policyIdsQuery);
        String query = 'SELECT id, Term__c, Term_days__c, Auto_renew__c, End_Date__c, Start_Date__c, Quote_c__c, Policy_Type_picklist__c,Contact__c,Auto_renew_card__c,Renew_Payment_Profile_Id__c,Auto_Renew_Confirmed__c,Updated_Quote_Json__c  from Policy__c WHERE ID IN: policyIdsQuery LIMIT 50000';
        System.debug('query'+query); 
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Policy__c> policyList){
        System.debug('getTransaction QueueableContext--');
         System.debug('policyList --'+policyList.size());
        Map<string, object> getTransaction = new Map<string, object>();
        Map<String,object> transactionDetails = new Map<String, object>();
        Map<String, Object> getTransactionDetails = new Map<String,Object>();
        
        if(policyList.size() > 0){
            for(Policy__c policy :policyList){
                
                List<String> quoteIdsList = new List<String>();
                String profileId = policy.Renew_Payment_Profile_Id__c;
                String contactId = policy.Contact__c;
                Quote__c quoteRecord = policyIdVsQuote.get(policy.Id);
                
                string policyId = policy.Id;
                string newQuoteID = quoteRecord.Id;
                quoteIdsList.add(quoteRecord.Id);
                
                if(quoteIdsList.size() > 0 && profileId != null){
                    transactionDetails.put('ip', '173.249.144.83');  // enter Current Ip...
                    transactionDetails.put('quoteIds' ,quoteIdsList);
                    transactionDetails.put('paymentProfileId',profileId);
                }
                
                System.debug('Details'+JSON.serialize(transactionDetails));
                getTransaction = PolicyAutoRenewCardHandler.createPaymentProfileTransaction(JSON.serialize(transactionDetails), contactId);
                System.debug('getTransaction--------'+getTransaction);
                policyIdsVsTransaction.put(policy.Id, getTransaction.get('status'));
                
                Object detailsObject = getTransaction.get('transcationDetails');
                Map<String, Object> details = (Map<String, Object>)detailsObject;
                if(getTransaction.get('status') == 'success'){
                    AuthorizeNetClient.CreateTransactionRequest request = (AuthorizeNetClient.CreateTransactionRequest)details.get('policyVsRequest');
                    AuthorizeNetClient.CreateTransactionResponse response = (AuthorizeNetClient.CreateTransactionResponse)details.get('policyVsResponse');
                    policyVsRequest.put(policy.Id,request);
                    policyVsResponse.put(policy.Id,response);
                }else{
                    failedTransacation.put(policy.Id, getTransaction.get('status'));
                    policyIdVsQuote.remove(policy.Id);
                    policyIdsVsTransaction.remove(policy.Id);
                }
                
            }
        }
    }
    
    public void finish (Database.BatchableContext Bc){
        System.debug('Finish PolicyAutoRenewGetTransaction---');
        System.debug('policyIdVsQuote--'+policyIdVsQuote);
        System.debug('policyIdsVsTransaction--'+policyIdsVsTransaction);
        
        if(policyVsRequest.size() > 0 && policyVsResponse.size() > 0){
            PolicyAutoRenewCardHandler.saveTransactionRecord(policyIdVsQuote, policyVsRequest, policyVsResponse, policyIdsVsTransaction);
        }
        
        System.debug('failedTransacation---'+failedTransacation);
        if(failedTransacation.size() > 0){
            PolicyAutoRenewCreateCase.createCase(failedTransacation);
        }
        
    }
    
}