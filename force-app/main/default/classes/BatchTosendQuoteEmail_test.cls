@isTest
public class BatchTosendQuoteEmail_test {
    public static  testMethod void BatchTosendQuoteEmail(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'Northbound';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }    
        public static  testMethod void BatchTosendQuoteEmail2(){
         TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
            
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
            
        List<Policy__c> policies = new List<Policy__c>();
        set<String> policyIdset = new set<String>();
        for(Integer i =0 ;i<=2; i++){
            Policy__c policyrecord = new policy__c();
            policyrecord.name='policy'+i; 
            policyrecord.Policy_Type_picklist__c = 'Northbound'; 
            policyrecord.Term__c ='semi';
            policyrecord.Account_Policy__c = acObj.Id;
            policyrecord.Contact__c = conObj.Id;           
               
            policies.add(policyrecord);
        }
        insert policies;
            for(Policy__c policyid :policies){
                policyIdset.add(policyid.Id);
            }
        test.startTest();
            Database.executeBatch(new BatchTosendQuoteEmail(policyIdset));
        test.stopTest();
    }
    
    
    public static  testMethod void BatchTosendQuoteEmail3(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'Driver License';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
       public static  testMethod void BatchTosendQuoteEmail4(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'Watercraft';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
       public static  testMethod void BatchTosendQuoteEmail5(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
       public static  testMethod void BatchTosendQuoteEmail6(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Underwriter_picklist__c = 'Mapfre';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
       public static  testMethod void BatchTosendQuoteEmail7(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Underwriter_picklist__c = 'Qualitas';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
       public static  testMethod void BatchTosendQuoteEmail8(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'RV';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
    public static  testMethod void BatchTosendQuoteEmail9(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'RV';
        policyrecord.Underwriter_picklist__c = 'Mapfre';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
    public static  testMethod void BatchTosendQuoteEmail10(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'RV';
        policyrecord.Underwriter_picklist__c = 'Qualitas';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
    public static  testMethod void BatchTosendQuoteEmail11(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        acObj.Affiliate_Number__c = '1234';
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
       
        set<String> policyIdset = new set<String>();
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy data'; 
        policyrecord.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyrecord.Underwriter_picklist__c = 'Mapfre';
        policyrecord.Term__c ='semi';
        policyrecord.Account_Policy__c = acObj.Id;
        policyrecord.Contact__c = conObj.Id;
        insert policyrecord;
        
        policyIdset.add(policyrecord.Id);
        
        test.startTest();
        //BatchTosendQuoteEmail batchemail = new BatchTosendQuoteEmail(policyIdset, True);
         Database.executeBatch(new BatchTosendQuoteEmail(policyIdset,true));
        test.stopTest();
        
        // batchemail.BatchTosendQuoteEmail();
    }  
}