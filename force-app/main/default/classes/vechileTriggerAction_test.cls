@isTest
public class vechileTriggerAction_test {
    public static testMethod void vechileTriggerAction(){
        try{
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        Watercraft__c watercraftrecord = new Watercraft__c();
        watercraftrecord.year__c = '2010';
        insert watercraftrecord;
        
        Policy__c policyrecord=new policy__c();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        Time expected = Time.newInstance(4, 2, 3, 4);
        policyrecord.name = 'testPolicy';
        policyrecord.Status_picklist__c = 'Active';
        insert policyrecord;
        
        
        Vehicle__c vechile = new Vehicle__c();
        vechile.Vehicle_Type__c = 'SUV';
        vechile.Rental__c = 'No';
        vechile.Value__c  = 10000;
        vechile.Policy__c = policyrecord.Id;
        insert vechile;
        
        
        Quote__c quotes = new Quote__c ();
        date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
        quotes.Annual_Term__c = 'Annual';
        quotes.Policy__c =  policyrecord.Id;
        insert quotes;
        
        Quote_Vehicle__c quotevechile  = new Quote_Vehicle__c();
        quotevechile.Quote_c__c = quotes.Id;
        quotevechile.Vehicle__c = vechile.Id;
        quotevechile.Policy__c = policyrecord.Id;
        insert quotevechile;  
        system.debug(quotevechile);
        
        vechile.Value__c  = 12000;
        update vechile;
        
        
    }
        Catch(Exception ee){
            Boolean expectedExceptionThrown =  ee.getMessage().contains('Modifying this value will change the premium of policy testPolicy.  To make this change you will need to edit the Policy ') ? true : false;
			//System.AssertEquals(expectedExceptionThrown, true);
        }
    }
}