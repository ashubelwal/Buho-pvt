@isTEst
public class Mex_NorthboundYellowPdfTest {
    @isTest static void Mex_NorthboundYellowPdf(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Account accObj = new Account();
        accObj.Name= 'Test';
        insert accObj;
        
        Contact con=new Contact();
        con.LastName='Testlast';
        con.AccountId=accObj.Id;
        insert con;
        
        String end_time = '01:45:00.000Z';
        String start_time = '01:45:00.000Z';
        
        String[] strTimeSplit = end_time.split(':');
        String[] strTimeSplit2 = start_time.split(':');
        Time endtimeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                     ,Integer.valueOf(strTimeSplit[1]) //min
                                     ,0                                //sec
                                     ,0);
        Time starttimeChange = Time.newInstance( Integer.valueOf(strTimeSplit2[0]) //hour
                                     ,Integer.valueOf(strTimeSplit2[1]) //min
                                     ,0                                //sec
                                     ,0);
        
        Quote__c qouteDetails = new Quote__c();
        qouteDetails.Vehicle_Make__c = 'Audi';
        qouteDetails.Quote_Status__c = 'Policy Created';
        qouteDetails.Underwriter__c = 'Chubb';
        qouteDetails.Policy_Type_picklist__c = 'Automobile';
        qouteDetails.Net_Premium__c = 132.00;
        qouteDetails.Broker_Policy_Fee__c = 10.00;
        qouteDetails.I_V_A_Mex_Tax__c = 19.00;
        qouteDetails.Quote_Value__c = 210.00;
        qouteDetails.Surcharge__c =0;
        qouteDetails.Account__c = accObj.Id;
        qouteDetails.Contact__c =con.Id;
        qouteDetails.Vehicle_Sub_type__c = 'Automobile/Sedan';
        qouteDetails.Vehicle_Type__c = 'Car/Truck/Auto';
        qouteDetails.Vehicle_Deductible_Collision__c = '500';
        qouteDetails.Vehicle_Deductible_Comprehensive__c = '500';
        qouteDetails.Physical_Damage__c=0;
        qouteDetails.Total_Theft_Payment__c=0;
        qouteDetails.Liability_Payment__c=0;
        qouteDetails.Medical_Payment__c=0;
        qouteDetails.Coverage__c='Complete';
        qouteDetails.Territory__c='Baja/Sonora';
        qouteDetails.Medical__c='10,000/50,000';
        qouteDetails.Liability__c='100,000';
        qouteDetails.Term__c='Daily';
        qouteDetails.Term_Days__c=2;
        qouteDetails.Start_Date_for_Coverage__c=date.parse('01/01/2022');
        qouteDetails.End_Date_for_Coverage__c=date.parse('01/03/2022');
        qouteDetails.Start_Time__c=starttimeChange;
        qouteDetails.End_Time__c=endtimeChange;
        qouteDetails.Vehicle_Value__c=10000.00;
        insert qouteDetails;
        
        Policy__c policyDetail = new Policy__c();
        policyDetail.Name='CNLDN-22-XZPQH';
        policyDetail.Quote_c__c = qouteDetails.Id;
        policyDetail.Status_picklist__c = 'Active';
        policyDetail.Term__c = 'Daily';
        policyDetail.Underwriter_picklist__c='Chubb';
        Insert policyDetail;
        
        PageReference pr = page.renderAsPdf;
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('id',policyDetail.Id);
        Test.startTest();
        Mex_NorthboundYellowPdf nyp =new Mex_NorthboundYellowPdf();
        Test.stopTest();
    }
}