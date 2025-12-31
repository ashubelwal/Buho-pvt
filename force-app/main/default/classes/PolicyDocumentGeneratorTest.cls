@isTest
public class PolicyDocumentGeneratorTest {
    @isTest
    public static void generateGreenCardfromPolicyIdTest(){
        TriggerSwitch__c  triggerSwitchRecord = new TriggerSwitch__c();
        triggerSwitchRecord.Active__c = true;
        triggerSwitchRecord.Name = 'PolicyTrigger';
        insert triggerSwitchRecord;
        
        Policy__c plcy = new Policy__c();
        plcy.Name ='Test';
        plcy.Status_picklist__c='Active';
        plcy.End_Date__c= system.today(); 
        insert plcy;
        
        Policy__c policyDetail = [Select Id, Policy_Type_picklist__c from Policy__c Where Id =:plcy.Id LIMIT 1];
        String PolicyId = policyDetail.Id;
        Test.startTest();
        PolicyDocumentGenerator.generateGreenCardfromPolicyId(PolicyId);
        Test.stopTest();
    }
    @isTest
    public static void validateandGenerateQuotePDFTest(){
        TriggerSwitch__c  triggerSwitchRecord = new TriggerSwitch__c();
        triggerSwitchRecord.Active__c = false;
        triggerSwitchRecord.Name = 'PolicyTrigger';
        insert triggerSwitchRecord;
        
        Policy__c plcy = new Policy__c();
        plcy.Name ='Test';
        plcy.Status_picklist__c='Active';
        plcy.Policy_Type_picklist__c = 'Northbound';
        plcy.End_Date__c= system.today(); 
        insert plcy;
        
        Policy__c plcy1 = new Policy__c();
        plcy1.Name ='Test';
        plcy1.Status_picklist__c='Active';
        plcy1.Policy_Type_picklist__c = 'Driver License';
        plcy1.End_Date__c= system.today(); 
        insert plcy1;
        
        Policy__c plcy2 = new Policy__c();
        plcy2.Name ='Test';
        plcy2.Status_picklist__c='Active';
        plcy2.Policy_Type_picklist__c = 'Watercraft';
        plcy2.End_Date__c= system.today(); 
        insert plcy2;
        
        Policy__c plcy3 = new Policy__c();
        plcy3.Name ='Test';
        plcy3.Status_picklist__c='Active';
        plcy3.Policy_Type_picklist__c = 'Automobile';
        plcy3.Underwriter_picklist__c = 'Mapfre';
        plcy3.End_Date__c= system.today(); 
        insert plcy3;
        
         Policy__c plcy13 = new Policy__c();
        plcy13.Name ='Test';
        plcy13.Status_picklist__c='Active';
        plcy13.Policy_Type_picklist__c = 'Automobile';
        plcy13.Underwriter_picklist__c = 'Qualitas';
        plcy13.End_Date__c= system.today(); 
        insert plcy13;
        
        Policy__c plcy4 = new Policy__c();
        plcy4.Name ='Test';
        plcy4.Status_picklist__c='Active';
        plcy4.Policy_Type_picklist__c = 'Automobile';
        plcy4.Underwriter_picklist__c = 'Chubb';
        plcy4.End_Date__c= system.today(); 
        insert plcy4;
        
        Policy__c plcy5 = new Policy__c();
        plcy5.Name ='Test';
        plcy5.Status_picklist__c='Active';
        plcy5.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        plcy5.Underwriter_picklist__c = 'Qualitas';
        plcy5.End_Date__c= system.today(); 
        insert plcy5;
        
        Policy__c plcy6 = new Policy__c();
        plcy6.Name ='Test';
        plcy6.Status_picklist__c='Active';
        plcy6.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        plcy6.Underwriter_picklist__c = 'Chubb';
        plcy6.End_Date__c= system.today(); 
        insert plcy6;

        Policy__c plcy8 = new Policy__c();
        plcy8.Name ='Test';
        plcy8.Status_picklist__c='Active';
        plcy8.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        plcy8.Underwriter_picklist__c = 'Mapfre';
        plcy8.End_Date__c= system.today(); 
        insert plcy8;
        
        Policy__c plcy7 = new Policy__c();
        plcy7.Name ='Test';
        plcy7.Status_picklist__c='Active';
        plcy7.Policy_Type_picklist__c = 'RV';
        plcy7.Underwriter_picklist__c = 'Chubb';
        plcy7.End_Date__c= system.today(); 
        insert plcy7;
        
        Policy__c plcy9 = new Policy__c();
        plcy9.Name ='Test';
        plcy9.Status_picklist__c='Active';
        plcy9.Policy_Type_picklist__c = 'RV';
        plcy7.Underwriter_picklist__c = 'Mapfre';
        plcy9.End_Date__c= system.today(); 
        insert plcy9;
        
        Policy__c plcy11 = new Policy__c();
        plcy11.Name ='Test';
        plcy11.Status_picklist__c='Active';
        plcy11.Policy_Type_picklist__c = 'RV';
        plcy7.Underwriter_picklist__c = 'Qualitas';
        plcy11.End_Date__c= system.today(); 
        insert plcy11;
        
        Policy__c policyDetail = [Select Id, Policy_Type_picklist__c from Policy__c Where Id =:plcy.Id LIMIT 1];
        String PolicyId = policyDetail.Id;
        Test.startTest();
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy1.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy2.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy3.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy4.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy5.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy6.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy7.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy8.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy9.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy11.Id);
        PolicyDocumentGenerator.validateandGenerateQuotePDF(plcy13.Id);
        Test.stopTest();
    }
    
}