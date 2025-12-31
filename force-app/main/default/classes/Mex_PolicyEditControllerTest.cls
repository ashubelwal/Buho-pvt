@isTest
public class Mex_PolicyEditControllerTest {
    @isTest Static void policyEditControllerTest(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Vehicle__c vehiceDetails=new Vehicle__c();
        vehiceDetails.Make__c = 'Audi';
        insert vehiceDetails;            
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
        qouteDetails.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
        qouteDetails.Vehicle_Type__c = 'Automobile-Van-Minivan';
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
        qouteDetails.Towed_Unit__c = 'Yes';
        insert qouteDetails;
        
        Quote__c qouteDetails2 = new Quote__c();
        qouteDetails2.Vehicle_Make__c = 'BMW';
        qouteDetails2.Quote_Status__c = 'Policy Created';
        qouteDetails2.Underwriter__c = 'Chubb';
        qouteDetails2.Policy_Type_picklist__c = 'Automobile';
        qouteDetails2.Net_Premium__c = 132.00;
        qouteDetails2.Broker_Policy_Fee__c = 10.00;
        qouteDetails2.I_V_A_Mex_Tax__c = 19.00;
        qouteDetails2.Quote_Value__c = 210.00;
        qouteDetails2.Surcharge__c =0;
        qouteDetails2.Account__c = accObj.Id;
        qouteDetails2.Contact__c =con.Id;
        qouteDetails2.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
        qouteDetails2.Vehicle_Type__c = 'Automobile-Van-Minivan';
        qouteDetails2.Vehicle_Deductible_Collision__c = '500';
        qouteDetails2.Vehicle_Deductible_Comprehensive__c = '500';
        qouteDetails2.Physical_Damage__c=0;
        qouteDetails2.Total_Theft_Payment__c=0;
        qouteDetails2.Liability_Payment__c=0;
        qouteDetails2.Medical_Payment__c=0;
        qouteDetails2.Coverage__c='Complete';
        qouteDetails2.Territory__c='Baja/Sonora';
        qouteDetails2.Medical__c='10,000/50,000';
        qouteDetails2.Liability__c='100,000';
        qouteDetails2.Term__c='Daily';
        qouteDetails2.Term_Days__c=2;
        qouteDetails2.Start_Date_for_Coverage__c=date.parse('01/01/2022');
        qouteDetails2.End_Date_for_Coverage__c=date.parse('01/03/2022');
        qouteDetails2.Start_Time__c=starttimeChange;
        qouteDetails2.End_Time__c=endtimeChange;
        qouteDetails2.Vehicle_Value__c=10000.00;
        qouteDetails2.Towed_Unit__c = 'Yes';
        qouteDetails2.Renew_Quote__c = qouteDetails.Id;
        insert qouteDetails2;
        
        Watercraft__c watercraftdetails = new Watercraft__c();
        watercraftdetails.Make__c = 'Audi';
        insert watercraftdetails;
        
        List<driver__c> updatedrivers = new List<driver__c>();
        Driver__c driverDetails = new Driver__c();
        driverDetails.Name = 'd s';
        driverDetails.First_Name__c='d';
        driverDetails.Last_Name__c='s';
        driverDetails.email__c='s@gmail.com';
        driverDetails.Driver_Type__c='Owner';
        driverDetails.Phone__c='123';
        driverDetails.Address__c ='address';
        driverDetails.Address_Line_2__c = 'address';
        driverDetails.City__c = 'city';
        driverDetails.Country__c = 'country';
        driverDetails.default__c = 'Yes';
        insert driverDetails;
        updatedrivers.add(driverDetails);

        List<driver__c> updatedrivers2 = new List<driver__c>();
        Driver__c driverDetails1 = new Driver__c();
        driverDetails1.Name = 'd s12';
        driverDetails1.First_Name__c='d';
        driverDetails1.Last_Name__c='s12';
        driverDetails1.email__c='s12@gmail.com';
        driverDetails1.Driver_Type__c='Owner';
        driverDetails1.Phone__c='123';
        driverDetails1.Address__c ='address';
        driverDetails1.Address_Line_2__c = 'address';
        driverDetails1.City__c = 'city';
        driverDetails1.Country__c = 'country';
        driverDetails1.default__c = 'Yes';
        insert driverDetails1;
        updatedrivers2.add(driverDetails1);
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunitsDetails =new Towed_Unit__c();
        towunitsDetails.Make__c = 'Audi';
        insert towunitsDetails;
        towedUnitsData.add(towunitsDetails);
        
        List<Towed_Unit__c> towedUnitsData2 = new List<Towed_Unit__c>();
        Towed_Unit__c towunitsDetails2 =new Towed_Unit__c();
        towunitsDetails2.Make__c = 'BMW';
        insert towunitsDetails2;
        towedUnitsData2.add(towunitsDetails2);
        
        Policy__c policyDetail = new Policy__c();
        policyDetail.Name='CNLDN-22-XYRGH';
        policyDetail.Vehicle_Policy__c=vehiceDetails.Id;
        policyDetail.Watercraft__c = watercraftdetails.Id;
        policyDetail.Quote_c__c = qouteDetails.Id;
        policyDetail.Status_picklist__c = 'Active';
        policyDetail.Term__c = 'Daily';
        policyDetail.Underwriter_picklist__c='Chubb';
        Insert policyDetail;
        
        Quote_Driver__c qoutedriverDetails = new Quote_Driver__c();
        qoutedriverDetails.Policy__c = policyDetail.Id;
        qoutedriverDetails.Driver__c = driverDetails.Id;
        qoutedriverDetails.Quote_c__c = qouteDetails.Id;
        insert qoutedriverDetails;
        
        Quote_Towed_Unit__c quoteTowedUnitDetails = new Quote_Towed_Unit__c();
        quoteTowedUnitDetails.Policy__c = policyDetail.Id;
        quoteTowedUnitDetails.Towed_Unit__c= towunitsDetails.Id;
        quoteTowedUnitDetails.Quote_c__c = qouteDetails.Id;
        insert quoteTowedUnitDetails;
        
        Transaction__c transactionDetails = new Transaction__c();
        transactionDetails.Policy_Transaction__c = policyDetail.Id;
        transactionDetails.Quote_c__c = qouteDetails.Id;
        transactionDetails.Amount__c = 350.00;
        insert transactionDetails;
        
        
        
        String dr='[{"mailto:first_name__c":"testnamefirst","last_name__c":"testlastname","email__c":"kr.1235gfgfdgf@gmail.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"addressline1","Address_Line_2__c":"addressline2","License_Country__c":"Canada","Country__c":"Canada","City__c":"testcity","Postal_Code__c":"00810","License_state__c":"British Columbia","State_Province__c":"British Columbia","license_number__c":"FGHGFHFVCCVD","Dob__c":"1934-03-03"}]';
        
        String td='[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"}]';
        
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        Mex_PolicyEditController.getEditPolicyDetail(policyDetail.Id);
        Mex_PolicyEditController.getEditPolicyDetail('00B15000070M8NhEAK');
        
        Mex_PolicyEditController.getDataRealtedScreen(policyDetail.Id,'reviewVehicle');
        Mex_PolicyEditController.getDataRealtedScreen(policyDetail.Id,'driverScreen');
        Mex_PolicyEditController.getDataRealtedScreen(policyDetail.Id,'towedDetail');
        Mex_PolicyEditController.getDataRealtedScreen('00B15000070M8NhEAK','reviewVehicle');
        
        Mex_PolicyEditController.updatePolicyDetails(JSON.serialize(qouteDetails),JSON.serialize(updatedrivers),JSON.serialize(vehiceDetails),JSON.serialize(towedUnitsData));
        Mex_PolicyEditController.fetchRenewQuoteData(qouteDetails.Id);
        Mex_PolicyEditController.fetchRenewQuoteData('');
        Mex_PolicyEditController.createNewRenewQuote(JSON.serialize(qouteDetails2), qouteDetails.Id);
        Mex_PolicyEditController.updatePolicyDetails(JSON.serialize(qouteDetails2),JSON.serialize(updatedrivers2),JSON.serialize(vehiceDetails),JSON.serialize(towedUnitsData));
        Mex_PolicyEditController.createNewWatercraftEditPolicy(JSON.serialize(watercraftdetails),dr,qouteDetails.Id,policyDetail.Id,false);
        Mex_PolicyEditController.createNewEditPolicy(JSON.serialize(vehiceDetails),dr,td,qouteDetails.Id,policyDetail.Id,false);
        Mex_PolicyEditController.updateQuoteData(JSON.serialize(qouteDetails));
        Mex_PolicyEditController.updateQuoteData('');
        Mex_PolicyEditController.createCloneQuote(JSON.serialize(qouteDetails));
        Mex_PolicyEditController.getDriver(qouteDetails.Id);
        Mex_PolicyEditController.getTowedUnit(qouteDetails.Id);
        Test.stopTest();
    }
    @isTest Static void policyEditControllerTwwest(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Vehicle__c vehiceDetails=new Vehicle__c();
        vehiceDetails.Make__c = 'Audi';
        insert vehiceDetails;            
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
        qouteDetails.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
        qouteDetails.Vehicle_Type__c = 'Automobile-Van-Minivan';
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
        qouteDetails.Towed_Unit__c = 'Yes';
        insert qouteDetails;
        
        Quote__c qouteDetails2 = new Quote__c();
        qouteDetails2.Vehicle_Make__c = 'BMW';
        qouteDetails2.Quote_Status__c = 'Policy Created';
        qouteDetails2.Underwriter__c = 'Chubb';
        qouteDetails2.Policy_Type_picklist__c = 'Automobile';
        qouteDetails2.Net_Premium__c = 132.00;
        qouteDetails2.Broker_Policy_Fee__c = 10.00;
        qouteDetails2.I_V_A_Mex_Tax__c = 19.00;
        qouteDetails2.Quote_Value__c = 210.00;
        qouteDetails2.Surcharge__c =0;
        qouteDetails2.Account__c = accObj.Id;
        qouteDetails2.Contact__c =con.Id;
        qouteDetails2.Vehicle_Sub_type__c = 'Automobile-Van-Minivan';
        qouteDetails2.Vehicle_Type__c = 'Automobile-Van-Minivan';
        qouteDetails2.Vehicle_Deductible_Collision__c = '500';
        qouteDetails2.Vehicle_Deductible_Comprehensive__c = '500';
        qouteDetails2.Physical_Damage__c=0;
        qouteDetails2.Total_Theft_Payment__c=0;
        qouteDetails2.Liability_Payment__c=0;
        qouteDetails2.Medical_Payment__c=0;
        qouteDetails2.Coverage__c='Complete';
        qouteDetails2.Territory__c='Baja/Sonora';
        qouteDetails2.Medical__c='10,000/50,000';
        qouteDetails2.Liability__c='100,000';
        qouteDetails2.Term__c='Daily';
        qouteDetails2.Term_Days__c=2;
        qouteDetails2.Start_Date_for_Coverage__c=date.parse('01/01/2022');
        qouteDetails2.End_Date_for_Coverage__c=date.parse('01/03/2022');
        qouteDetails2.Start_Time__c=starttimeChange;
        qouteDetails2.End_Time__c=endtimeChange;
        qouteDetails2.Vehicle_Value__c=10000.00;
        qouteDetails2.Towed_Unit__c = 'Yes';
        qouteDetails2.Renew_Quote__c = qouteDetails.Id;
        insert qouteDetails2;
        
        Watercraft__c watercraftdetails = new Watercraft__c();
        watercraftdetails.Make__c = 'Audi';
        insert watercraftdetails;
        
        List<driver__c> updatedrivers = new List<driver__c>();
        Driver__c driverDetails = new Driver__c();
        driverDetails.Name = 'd s';
        driverDetails.First_Name__c='d';
        driverDetails.Last_Name__c='s';
        driverDetails.email__c='s@gmail.com';
        driverDetails.Driver_Type__c='Owner';
        driverDetails.Phone__c='123';
        driverDetails.Address__c ='address';
        driverDetails.Address_Line_2__c = 'address';
        driverDetails.City__c = 'city';
        driverDetails.Country__c = 'country';
        driverDetails.default__c = 'Yes';
        insert driverDetails;
        updatedrivers.add(driverDetails);

        List<driver__c> updatedrivers2 = new List<driver__c>();
        Driver__c driverDetails1 = new Driver__c();
        driverDetails1.Name = 'd s12';
        driverDetails1.First_Name__c='d';
        driverDetails1.Last_Name__c='s12';
        driverDetails1.email__c='s12@gmail.com';
        driverDetails1.Driver_Type__c='Owner';
        driverDetails1.Phone__c='123';
        driverDetails1.Address__c ='address';
        driverDetails1.Address_Line_2__c = 'address';
        driverDetails1.City__c = 'city';
        driverDetails1.Country__c = 'country';
        driverDetails1.default__c = 'Yes';
        insert driverDetails1;
        
            updatedrivers2.add(driverDetails);
        updatedrivers2.add(driverDetails1);
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunitsDetails =new Towed_Unit__c();
        towunitsDetails.Make__c = 'Audi';
        insert towunitsDetails;
        towedUnitsData.add(towunitsDetails);
        
        List<Towed_Unit__c> towedUnitsData2 = new List<Towed_Unit__c>();
        Towed_Unit__c towunitsDetails2 =new Towed_Unit__c();
        towunitsDetails2.Make__c = 'BMW';
        insert towunitsDetails2;
        towedUnitsData2.add(towunitsDetails2);
        
        Policy__c policyDetail = new Policy__c();
        policyDetail.Name='CNLDN-22-XYRGH';
        policyDetail.Vehicle_Policy__c=vehiceDetails.Id;
        policyDetail.Watercraft__c = watercraftdetails.Id;
        policyDetail.Quote_c__c = qouteDetails.Id;
        policyDetail.Status_picklist__c = 'Active';
        policyDetail.Term__c = 'Daily';
        policyDetail.Underwriter_picklist__c='Chubb';
        Insert policyDetail;
        
        Quote_Driver__c qoutedriverDetails = new Quote_Driver__c();
        qoutedriverDetails.Policy__c = policyDetail.Id;
        qoutedriverDetails.Driver__c = driverDetails.Id;
        qoutedriverDetails.Quote_c__c = qouteDetails.Id;
        insert qoutedriverDetails;
        Quote_Driver__c qoutedriverDetailss = new Quote_Driver__c();
        qoutedriverDetailss.Policy__c = policyDetail.Id;
        qoutedriverDetailss.Driver__c = driverDetails1.Id;
        qoutedriverDetailss.Quote_c__c = qouteDetails.Id;
        insert qoutedriverDetailss;
        
        Quote_Towed_Unit__c quoteTowedUnitDetails = new Quote_Towed_Unit__c();
        quoteTowedUnitDetails.Policy__c = policyDetail.Id;
        quoteTowedUnitDetails.Towed_Unit__c= towunitsDetails.Id;
        quoteTowedUnitDetails.Quote_c__c = qouteDetails.Id;
        insert quoteTowedUnitDetails;
        
        Transaction__c transactionDetails = new Transaction__c();
        transactionDetails.Policy_Transaction__c = policyDetail.Id;
        transactionDetails.Quote_c__c = qouteDetails.Id;
        transactionDetails.Amount__c = 350.00;
        insert transactionDetails;
        
        
        
        String dr='[{"mailto:first_name__c":"testnamefirst","last_name__c":"testlastname","email__c":"kr.1235gfgfdgf@gmail.com","Phone__c":"(098) 765-4321","Driver_Type__c":"Owner","Address__c":"addressline1","Address_Line_2__c":"addressline2","License_Country__c":"Canada","Country__c":"Canada","City__c":"testcity","Postal_Code__c":"00810","License_state__c":"British Columbia","State_Province__c":"British Columbia","license_number__c":"FGHGFHFVCCVD","Dob__c":"1934-03-03"}]';
        
        String td='[{"Year__c":"2010","Make__c":"testmakeEdit","Model__c":"testModeltowed","VIN_Number__c":"VINTOWED12319","Towed_Unit_Value__c":"10000","Plate__c":"RDX123LICNUM11TH","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"},{"Year__c":"2007","Make__c":"MAKE","Towed_Unit_Value__c":"10000","VIN_Number__c":"VINTOWED123AHUJAA","Model__c":"testModeljjjj","Plate__c":"J8787","Days_in_Tow__c":"21","Towed_Unit_Type__c":"Motorcycle","Street_Legal__c":"no"}]';
        
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        Mex_PolicyEditController.getEditPolicyDetail(policyDetail.Id);
        Mex_PolicyEditController.getEditPolicyDetail('00B15000070M8NhEAK');
        
        Mex_PolicyEditController.getDataRealtedScreen(policyDetail.Id,'reviewVehicle');
        Mex_PolicyEditController.getDataRealtedScreen(policyDetail.Id,'driverScreen');
        Mex_PolicyEditController.getDataRealtedScreen(policyDetail.Id,'towedDetail');
        Mex_PolicyEditController.getDataRealtedScreen('00B15000070M8NhEAK','reviewVehicle');
        
        Mex_PolicyEditController.updatePolicyDetails(JSON.serialize(qouteDetails),JSON.serialize(updatedrivers),JSON.serialize(vehiceDetails),JSON.serialize(towedUnitsData));
        Mex_PolicyEditController.fetchRenewQuoteData(qouteDetails.Id);
        Mex_PolicyEditController.fetchRenewQuoteData('');
        Mex_PolicyEditController.createNewRenewQuote(JSON.serialize(qouteDetails2), qouteDetails.Id);
        Mex_PolicyEditController.updatePolicyDetails(JSON.serialize(qouteDetails2),JSON.serialize(updatedrivers2),JSON.serialize(vehiceDetails),JSON.serialize(towedUnitsData));
        Mex_PolicyEditController.createNewWatercraftEditPolicy(JSON.serialize(watercraftdetails),dr,qouteDetails.Id,policyDetail.Id,false);
        Mex_PolicyEditController.createNewEditPolicy(JSON.serialize(vehiceDetails),dr,td,qouteDetails.Id,policyDetail.Id,false);
        Mex_PolicyEditController.updateQuoteData(JSON.serialize(qouteDetails));
        Mex_PolicyEditController.updateQuoteData('');
        Mex_PolicyEditController.createCloneQuote(JSON.serialize(qouteDetails));
        Mex_PolicyEditController.getDriver(qouteDetails.Id);
        Mex_PolicyEditController.getTowedUnit(qouteDetails.Id);
        Test.stopTest();
    }
    
    @isTest Static void previewPDFTest(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Policy__c policyDetail1 = new Policy__c();
        policyDetail1.Name='Test';
        policyDetail1.Policy_Type_picklist__c = 'Automobile';
        policyDetail1.Status_picklist__c = 'Active';
        policyDetail1.Term__c = 'Daily';
        policyDetail1.Underwriter_picklist__c='Chubb';
        Insert policyDetail1;
        
        Policy__c policyDetail2 = new Policy__c();
        policyDetail2.Name='Test';
        policyDetail2.Policy_Type_picklist__c = 'Automobile';
        policyDetail2.Status_picklist__c = 'Active';
        policyDetail2.Term__c = 'Daily';
        policyDetail2.Underwriter_picklist__c='Qualitas';
        Insert policyDetail2;
        
        Policy__c policyDetail3 = new Policy__c();
        policyDetail3.Name='Test';
        policyDetail3.Policy_Type_picklist__c = 'Automobile';
        policyDetail3.Status_picklist__c = 'Active';
        policyDetail3.Term__c = 'Daily';
        policyDetail3.Underwriter_picklist__c='Mapfre';
        Insert policyDetail3;
        
        Policy__c policyDetail4 = new Policy__c();
        policyDetail4.Name='Test';
        policyDetail4.Policy_Type_picklist__c = 'Northbound';
        policyDetail4.Status_picklist__c = 'Active';
        policyDetail4.Term__c = 'Daily';
        policyDetail4.Underwriter_picklist__c='Chubb';
        Insert policyDetail4;
        
        Policy__c policyDetail5 = new Policy__c();
        policyDetail5.Name='Test';
        policyDetail5.Policy_Type_picklist__c = 'Watercraft';
        policyDetail5.Status_picklist__c = 'Active';
        policyDetail5.Term__c = 'Daily';
        policyDetail5.Underwriter_picklist__c='Chubb';
        Insert policyDetail5;
        
        Policy__c policyDetail7 = new Policy__c();
        policyDetail7.Name='Test';
        policyDetail7.Policy_Type_picklist__c = 'RV';
        policyDetail7.Status_picklist__c = 'Active';
        policyDetail7.Term__c = 'Daily';
        policyDetail7.Underwriter_picklist__c='Chubb';
        Insert policyDetail7;
        
        Policy__c policyDetail6 = new Policy__c();
        policyDetail6.Name='Test';
        policyDetail6.Policy_Type_picklist__c = 'RV';
        policyDetail6.Status_picklist__c = 'Active';
        policyDetail6.Term__c = 'Daily';
        policyDetail6.Underwriter_picklist__c='Qualitas';
        Insert policyDetail6;
        
        Policy__c policyDetail8 = new Policy__c();
        policyDetail8.Name='Test';
        policyDetail8.Policy_Type_picklist__c = 'RV';
        policyDetail8.Status_picklist__c = 'Active';
        policyDetail8.Term__c = 'Daily';
        policyDetail8.Underwriter_picklist__c='Mapfre';
        Insert policyDetail8;
        
        Policy__c policyDetail9 = new Policy__c();
        policyDetail9.Name='Test';
        policyDetail9.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyDetail9.Status_picklist__c = 'Active';
        policyDetail9.Term__c = 'Daily';
        policyDetail9.Underwriter_picklist__c='Chubb';
        Insert policyDetail9;
        
        Policy__c policyDetail10 = new Policy__c();
        policyDetail10.Name='Test';
        policyDetail10.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyDetail10.Status_picklist__c = 'Active';
        policyDetail10.Term__c = 'Daily';
        policyDetail10.Underwriter_picklist__c='Mapfre';
        Insert policyDetail10;
        
        Policy__c policyDetail11 = new Policy__c();
        policyDetail11.Name='Test';
        policyDetail11.Policy_Type_picklist__c = 'Motorcycle/Street Legal ATV';
        policyDetail11.Status_picklist__c = 'Active';
        policyDetail11.Term__c = 'Daily';
        policyDetail11.Underwriter_picklist__c='Qualitas';
        Insert policyDetail11;
        
        Test.startTest();
        Mex_PolicyEditController.preViewPdfAction(policyDetail1.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail2.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail3.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail4.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail5.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail6.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail7.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail8.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail9.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail10.Id);
        Mex_PolicyEditController.preViewPdfAction(policyDetail11.Id);
        Mex_PolicyEditController.preViewPdfAction('00B15000070M8NhEAK');
        Test.stopTest();
    }
}