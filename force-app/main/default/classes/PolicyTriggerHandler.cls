/*
* Class Name : PolicyTriggerHandler
* Description : Manages all the updates on the policy and its related records on various events respectively.
* Created Date :
* Created By :
* Version : 1.1
* Modification Log :
* Name				Date			Version				Description
* Abhishek Sahay	6/9/2022		1.1					Validate and update the Chubb policy number.
*/
public  class PolicyTriggerHandler  
{
    
    /* public void OnAfterInsert(list<Policy__c> triggerNew, map<id,Policy__c> triggerOldMap)
{

}       
public void OnAfterUpdate(list<Policy__c> triggerNew, map<id,Policy__c> triggerOldMap,list<Policy__c> triggerOld)
{

}
*/
    public void OnBeforeInsert(list<Policy__c> triggerNew)
    {
        updatecontactid(triggerNew);
        updateChubbPolicyNumber(triggerNew);
        
        updatecontactname(triggerNew);
        
    }
    
    /* public void OnBeforeUpdate(list<Policy__c> triggerNew, map<id,Policy__c> triggerOldMap)
{

}
public void OnBeforeDelete(list<Policy__c> triggerOld, map<id,Policy__c> triggerOldMap)
{

}
public void OnAfterDelete(list<Policy__c> triggerOld, map<id,Policy__c> triggerOldMap)
{

}
public void OnAfterUnDelete(list<Policy__c> triggerNew)
{

}
*/ 
    
    public void updateChubbPolicyNumber(list<Policy__c> triggerNew ){
        try{
            
            list<Policy__c> latestPolicyRangeNB = new list<Policy__c>();
            list<Policy__c> latestPolicyRangeSB = new list<Policy__c>();
            list<Policy__c> latestPolicyRangeWC = new list<Policy__c>();
            
            // latestPolicyRangeNB = [SELECT id, Policy_Range_Number__c, Chubb_Policy_Number__c FROM Policy__c WHERE Underwriter_picklist__c ='Chubb' AND Chubb_Policy_Number__c != null 
            //                        AND Policy_Type_picklist__c ='Northbound' ORDER BY CreatedDate DESC LIMIT 1];
            // latestPolicyRangeSB = [SELECT id, Policy_Range_Number__c,Chubb_Policy_Number__c FROM Policy__c WHERE Underwriter_picklist__c ='Chubb' AND Chubb_Policy_Number__c != null 
            //                        AND Policy_Type_picklist__c !='Northbound' ORDER BY CreatedDate DESC LIMIT 1];
            
            // Integer northBoundRange = 247001;
            // Integer southBoundRange = 339001;

            // Modified for new range numbers of Northbound, southbound and watercraft policies.
            latestPolicyRangeNB = [SELECT id, Policy_Range_Number__c, Chubb_Policy_Number__c FROM Policy__c WHERE Underwriter_picklist__c ='Chubb' AND Chubb_Policy_Number__c != null 
                                   AND Policy_Type_picklist__c ='Northbound' ORDER BY CreatedDate DESC LIMIT 1];
            latestPolicyRangeSB = [SELECT id, Policy_Range_Number__c,Chubb_Policy_Number__c FROM Policy__c WHERE Underwriter_picklist__c ='Chubb' AND Chubb_Policy_Number__c != null 
                                   AND Policy_Type_picklist__c !='Northbound' AND Policy_Type_picklist__c !='Watercraft' ORDER BY CreatedDate DESC LIMIT 1];
            latestPolicyRangeWC = [SELECT id, Policy_Range_Number__c,Chubb_Policy_Number__c FROM Policy__c WHERE Underwriter_picklist__c ='Chubb' AND Chubb_Policy_Number__c != null 
                                  AND Policy_Type_picklist__c ='Watercraft' ORDER BY CreatedDate DESC LIMIT 1];
            Integer northBoundRange = 188001;
            Integer southBoundRange = 225001;
            Integer watercraftRange = 234500;
            
            if(!latestPolicyRangeNB.isEmpty()){
                northBoundRange = Integer.valueOf(latestPolicyRangeNB[0].Policy_Range_Number__c)+1;
            }            
            if(!latestPolicyRangeSB.isEmpty()){
                southBoundRange = Integer.valueOf(latestPolicyRangeSB[0].Policy_Range_Number__c)+1;
            }
            if(!latestPolicyRangeWC.isEmpty()){
                watercraftRange = Integer.valueOf(latestPolicyRangeWC[0].Policy_Range_Number__c)+1;
            }
            
            for(Policy__c policy: triggerNew){
                if(policy.Chubb_Policy_Number__c == null && policy.Underwriter_picklist__c != null && policy.Underwriter_picklist__c == 'Chubb'){
                    DateTime policyCreatedDate = policy.CreatedDate == null ? Date.today() : policy.CreatedDate;
                    String startYear = String.valueOf(( policyCreatedDate.year() - 2020 + 40 ));
                    
                    // if((policy.Policy_Type_picklist__c != null && policy.Policy_Type_picklist__c == 'Northbound') || test.isRunningTest()){
                    //     System.debug('northBoundRange > '+northBoundRange);
                    //     policy.Chubb_Policy_Number__c = 'RR '+ startYear+ northBoundRange;
                    //     northBoundRange = northBoundRange + 1;
                    //     System.debug('northBoundRange > '+northBoundRange);
                    //     System.debug('policy > '+policy.Chubb_Policy_Number__c);
                    // }
                    // else{
                    //     policy.Chubb_Policy_Number__c = 'NZ '+ startYear+ southBoundRange;
                    //     southBoundRange = southBoundRange + 1;
                    // } 
                    if((policy.Policy_Type_picklist__c != null && policy.Policy_Type_picklist__c == 'Northbound') ){
                        policy.Chubb_Policy_Number__c = 'RR '+ startYear+ northBoundRange;
                        northBoundRange = northBoundRange + 1;
                    }else if((policy.Policy_Type_picklist__c != null && policy.Policy_Type_picklist__c !='Northbound' && policy.Policy_Type_picklist__c !='Watercraft')){
                        policy.Chubb_Policy_Number__c = 'NZ '+ startYear+ southBoundRange;
                        southBoundRange = southBoundRange + 1;
                    }else if((policy.Policy_Type_picklist__c != null && policy.Policy_Type_picklist__c == 'Watercraft')){
                        policy.Chubb_Policy_Number__c = 'NZ '+ startYear+ watercraftRange;
                        watercraftRange = watercraftRange + 1;
                    }
                }
            }
        }
        catch(exception e){
            system.debug('message : '+ e.getMessage() + ' cause :'+ e.getCause() + ' Line number : '+e.getLineNumber());
        }
    }
    
    public void updatecontactid(list<Policy__c> triggerNew ){
        set<string> Accountset = new set<string>();
        map<string,string> ConatctMap = new map<string,string>();
        try{
            for(Policy__c policy: triggerNew  )
            {    
                if( policy.Contact__c == null ){
                    
                    Accountset.add(policy.Account_Policy__c);
                }
            }
            
            list<contact> contactlist = [select id,Accountid from contact where accountid IN: Accountset];
            
            for(contact cnt: contactlist )
            {
                ConatctMap.put(cnt.accountid,cnt.id);
            }
            
            for(Policy__c policy: triggerNew  )
            {
                if( policy.Contact__c == null ){
                    policy.Contact__c = ConatctMap.get(policy.Account_Policy__c);
                }
            }
        }
        catch(exception e) 
        {
            system.debug('message : '+ e.getMessage() + ' cause :'+ e.getCause() + ' Line number : '+e.getLineNumber());
        }
    }

    public static void updatecontactname(List<Policy__c> triggerNew){
        set<String> ContactId = new set<String>();
        set<String> AccountsId = new set<String>();

        try{
            for(Policy__c policy: triggerNew  ){
                if( policy.Contact__c != null && policy.Account_Policy__c != null){
                    ContactId.add(policy.Contact__c);
                    AccountsId.add(policy.Account_Policy__c);
                }
            }

            List<Driver__c> getDrivers = [SELECT Id, Name, First_Name__c, Last_Name__c, Policy__c, Phone__c, Account_Driver__c, Email__c, Address__c, Address_Line_2__c, City__c, 
                                          Country__c, Postal_Code__c, State_Province__c,  Contact__c, Dob__c FROM Driver__c 
                                          WHERE Contact__c IN: ContactId And (Driver_Type__c = 'Owner & Driver' OR Driver_Type__c = 'Owner') LIMIT 1];

            Contact contactGets =  [SELECT Id, Name, LastName, FirstName, Email, AccountId FROM Contact Where Id IN: ContactId LIMIT 1];

            Account AccDetail =  [SELECT Name, Email__c, Id FROM Account WHERE Id IN: AccountsId];

            if(AccDetail.Email__c != null && (AccDetail.Email__c == getDrivers[0].Email__c)) {
                AccDetail.Phone__c = getDrivers[0].Phone__c;
                AccDetail.Source__c = 'Portal';
                AccDetail.Street__c = getDrivers[0].Address__c;
                AccDetail.Street_2__c = getDrivers[0].Address_Line_2__c;
                AccDetail.City__c = getDrivers[0].City__c;
                AccDetail.Country__c = getDrivers[0].Country__c;
                AccDetail.Postal_Code__c = getDrivers[0].Postal_Code__c;
                AccDetail.State__c = getDrivers[0].State_Province__c;

                update AccDetail;
            }

           if(contactGets.Email != null && (contactGets.Email == getDrivers[0].Email__c)) {
                contactGets.Date_of_Birth__c = getDrivers[0].Dob__c;
                contactGets.MobilePhone = getDrivers[0].Phone__c;
                contactGets.Street__c = getDrivers[0].Address__c;
                contactGets.Street_2__c = getDrivers[0].Address_Line_2__c;
                contactGets.City__c = getDrivers[0].City__c;
                contactGets.Country__c = getDrivers[0].Country__c;
                contactGets.Postal_Code__c = getDrivers[0].Postal_Code__c;
                contactGets.State__c = getDrivers[0].State_Province__c;

                Update contactGets;
            }

            /*if(contactGets !=  null){
                User userDetail = [SELECT Id, Name From user where Email =:contactGets.Email];
                if(userDetail.Name.contains('New Lead') || userDetail.Name.contains('Insurance')){
                    userDetail.FirstName = getDrivers[0].First_Name__c;
                    userDetail.LastName = getDrivers[0].Last_Name__c;
                    userDetail.Alias = getDrivers[0].First_Name__c.charAt(0) + getDrivers[0].Last_Name__c.substring(0,5);
                    
                    update userDetail;
                }
            }*/
        } catch(exception ex){
            system.debug('message : '+ ex.getMessage() + ' line Number : '+ ex.getLineNumber());
        }
    }
}