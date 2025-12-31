global class TimeRecordReminder implements Schedulable
{
/*public List<Account> usr = new List<Account>();
public List<Account> accdaily = new List<Account>();

//public List<String> usr_email = new List<String>();
public Map<id,string> Map_usr = new Map<id,string>();
public Map<id,string> Map_usr_daily = new Map<id,string>();
public List<Policy__c> policy = new List<Policy__c>();
public Set<id>  accid = new Set<id>(); 
public List<Contact> con_list = new List<Contact>();
public List<Contact> con_list_for_daily = new List<Contact>();

public Map<id,List<Policy__c>> mapdailypolicy = new Map<id,List<Policy__c>>();*/
global void execute(SchedulableContext ctx)
{
        // TODO: your code here
       
      /*  usr=new List<Account>();
        policy= new List<Policy__c>();
        usr.clear();
        policy=[select id,Account_Policy__c , Term__c ,Loyal_Client_Survey_Check__c From Policy__c Where Term__c = 'annual' OR Term__c ='semi'];
        System.debug('my policy filtered '+policy);
        
    for(Policy__c pl : policy){
     
        pl.Loyal_Client_Survey_Check__c = true;
        accid.add(pl.Account_Policy__c);
        System.debug('my set account '+accid);      
                             }
        usr=[select id,Email__c from Account where id IN: accid];
    
        con_list=[Select id,accountid,Email from Contact where accountid IN : accid];    
        Map_usr=new Map<id,string>();
    
     for(Contact c : con_list)
        {
            system.debug('_____________id______'+c.id+'___________Email______________'+c.Email);
           
            if(c.Email !=null)
                Map_usr.put(c.id,c.Email);
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
    for(Policy__c pl : policy_daily){
     
        pl.Loyal_Client_Survey_Check__c = true;      
                             }
    Map_usr_daily=new Map<id,string>(); 
     for(Contact c : con_list_for_daily)
        {
            system.debug('_____________id______'+c.id+'___________Email______________'+c.Email);
           
            if(c.Email !=null)
                Map_usr_daily.put(c.id,c.Email);     
        } 
//=====================================for daily term ends===============================
//Send email to contacts email 
//send email to user with term annual and semi
      if(Map_usr.size()>0)
          Map_usr.putAll(Map_usr_daily);
          sendmail(Map_usr);
      system.debug('_____________id______'+Map_usr.keySet());
      system.debug('_________value______'+Map_usr.values());
    updatePolicy up = new updatePolicy();
    Database.executeBatch(up);   */
}
 
    
 
}