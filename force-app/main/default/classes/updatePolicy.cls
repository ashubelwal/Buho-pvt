global class updatePolicy implements Database.Batchable<sObject>

{

global List<Policy__c> policy = new List<Policy__c>();
global List<Policy__c> policyupdate = new List<Policy__c>();
   global updatePolicy(){
         List<Account> usr = new List<Account>();
 List<Account> accdaily = new List<Account>();
 Map<id,string> Map_usr_daily = new Map<id,string>();
 Set<id>  accid = new Set<id>(); 
 Set<id>  PolicyId = new Set<id>();
 
 List<Contact> con_list_for_daily = new List<Contact>();

 usr=new List<Account>();
        policy= new List<Policy__c>();
        usr.clear();
        policy=[select id,Account_Policy__c , Term__c ,Loyal_Client_Survey_Check__c From Policy__c Where Term__c = 'annual' OR Term__c ='semi'];
        System.debug('my policy filtered '+policy);
        
   for(Policy__c pl : policy){     
     
       PolicyId.add(pl.id);
             }

    //=====================================for daily term ====================================
    List<AggregateResult> results = [Select Count(Id),Account_Policy__c,Term__c  From Policy__c  WHERE  Term__c = 'daily' GROUP BY Account_Policy__c,Term__c];
     Set<ID> Daily_account = new Set<id>();
    for (AggregateResult ar : results)  {
    id myacc = (id)ar.get('Account_Policy__c');
    Integer numApps = (Integer) ar.get('expr0');
    if(numApps >= 2){
        Daily_account.add(myacc);     
    }
       }
    System.debug('settt: ' +Daily_account);
    con_list_for_daily= [Select id,accountid,Email from Contact where accountid IN : Daily_account]; 
    List<Policy__c> policy_daily=[select id,Account_Policy__c , Term__c ,Loyal_Client_Survey_Check__c From Policy__c where Account_Policy__c IN: Daily_account];
    //checkbox update
  
    policy.addAll(policy_daily);
    for(Policy__c pl : policy_daily){
      // pl.Loyal_Client_Survey_Check__c = true;
         PolicyId.add(pl.id);
                             }
     
 policyupdate =[Select id,Account_Policy__c , Term__c ,Loyal_Client_Survey_Check__c From Policy__c Where id In :PolicyId];
    for(Policy__c pol : policyupdate ){
        pol.Loyal_Client_Survey_Check__c = true;
    }
      System.debug('list: ' +policyupdate);
        
    }
global List<Policy__c> start(Database.BatchableContext BC){
    

  return policyupdate;

}

 

global void execute(Database.BatchableContext BC,List<Policy__c> scope)
{
  // update scope;
      update scope;   
}

 

global void finish(Database.BatchableContext BC)
{}
}