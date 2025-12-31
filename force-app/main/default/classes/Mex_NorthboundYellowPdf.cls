public class Mex_NorthboundYellowPdf {

    public Policy__c policy{get;set;}
    public string policyId{get;set;}
    public List<Vehicle__c> vehicle{get;set;}
    public Mex_NorthboundYellowPdf(){
        policyId = ApexPages.currentPage().getParameters().get('Id');

        policy = [Select Id, Name, Vehicle_Make__c, Vehicle_Model__c, Vehicle_Year__c, Policy_Type_picklist__c, Account_Policy__r.Name, 
                   Account_Policy__r.Street__c, Account_Policy__r.City__c, Account_Policy__r.State__c, Start_Date__c, End_Date__c, Vehicle_Policy__r.Vehicle_Owner_Name__c, Vehicle_Policy__r.Vehicle_Owner_Address__c, Vehicle_Policy__r.Vehicle_Owner_City__c, 
                  Vehicle_Policy__r.Vehicle_Owner_State__c, Vehicle_Policy__r.Vin__c From policy__c where Id =: policyId limit 1];
    }
}