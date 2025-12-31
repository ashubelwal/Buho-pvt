@isTest
private class Mex_Insurance_Calloututility_Test {
    public static testMethod void postiveTesting(){
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
            Mex_Insurance_Calloututility.sendEmail( new set<String>{'test'}, true);

            map<String,object> leadObjMap = new map<String,object>();
            leadObjMap.put('Email', 'test');
            Mex_Insurance_Calloututility.getLeadId( leadObjMap );

            Mex_Insurance_Calloututility.createLead_Record( leadObjMap );

        Test.stopTest();
    }

    public static testMethod void postiveSendEmailServiceTesting(){

        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        Account ac=new account();
        ac.name='testaccount';
        ac.annualrevenue=2000;
        insert ac;

        contact c=new contact();
        c.lastname='con';
        c.accountid=ac.id;
        c.email='abc@gmail.com';
        insert c;

        Quote__c quote = new quote__c();
        quote.Start_Date_for_Coverage__c=date.today();
        quote.End_Date_for_Coverage__c=date.today()+5;
        quote.Driver_Age__c = 80;
        quote.Underwriter__c ='Chubb';
        quote.Coverage__c='Complete';
        quote.Medical__c='2,000/10,000';
        quote.Liability__c='100,000'; 
        insert quote;
        
        vehicle__c vehicle = new vehicle__c();
        vehicle.Quote_c__c=quote.id;
        vehicle.Company_Name__c ='s';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';     
        insert vehicle; 

        Policy__c policyrecord=new policy__c();
        policyrecord.name='policy';
        policyrecord.contact__c= c.id;
        policyrecord.Vehicle_Policy__c= vehicle.id;
        policyrecord.Policy_Type_picklist__c = 'Northbound';
        insert policyrecord;

        Test.startTest();
            map<String,object> leadObjMap = new map<String,object>();
            leadObjMap.put('policyIdset', new list<object>{ policyrecord.Id });
            leadObjMap.put('add_attachment', true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse(); 
            req.requestBody = Blob.valueOf(JSON.serialize(leadObjMap));           
            req.requestURI = '/services/apexrest/sendEmailService/*';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;

            sendEmailService.sendEmail();

            ApexPages.currentPage().getParameters().put('id', policyrecord.id);
            Declaration_Page_Insurance_Controller declar = new Declaration_Page_Insurance_Controller();
            
        Test.stopTest();
    }
}