@isTest
public class WatercraftFlowControllerTest {
    @IsTest
    static void negativeTesting(){
        Test.startTest();
            WatercraftFlowController.saveQuoteAction(null, null, null, null ,null, null);
            WatercraftFlowController.updateWatercraftAction(null, null);
            WatercraftFlowController.updateDriverAction(null);
            WatercraftFlowController.createWatercraftAction(null, null, null);
            WatercraftFlowController.createDriverAction(null, null, null, null,null);
            WatercraftFlowController.updateQuoteContactAndAccount(null, null, null);
            WatercraftFlowController.saveQuoteActionByAdmin(null,null,null,null,null, null);
        Test.stopTest();
    }

    
    @IsTest
    static void positiveTesting() {
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
        insert customset;

        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        ldObj.Phone = '0987654321';
        insert ldObj; 
        String leadString = '{ "Email": "testNewUser@gmail.com"}';

        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;

        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;

        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today();
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Watercraft';
        quoteRecord.Vehicle_Type__c = 'Watercraft';
        quoteRecord.Liability__c = '200,000'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);

        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Beam__c = 'beam';
        watercraft.Engine_Type__c = 'engine';
        watercraft.Flag__c = 'flag';
        watercraft.Make__c = 'make';
        watercraft.Model__c = 'model';
        watercraft.Type_of_Vessel__c = 'Sailboat';
        watercraft.VIN_Number__c = '1325';
        watercraft.Value__c = 1000;
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Year__c = '2000';
        watercraft.Lead__c = ldObj.Id;

        driver__c driver = new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c = 'd';
        driver.Last_Name__c = 's';
        driver.email__c = 's@gmail.com';
        driver.Driver_Type__c = 'Owner';
        driver.Phone__c = '123';
        driver.Address__c = 'address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';

        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
            WatercraftFlowController.getPicklistValues('Quote__c', 'Policy_Type_picklist__c');
            WatercraftFlowController.generatePolicyName('Test', 'Test', 'Test', 'Test', 'Test');
            map<String,object> quoteMap = WatercraftFlowController.handleVehicleQuoteAction(quoteRecord, leadString);
            WatercraftFlowController.getCoverageDetail(quoteRecord);

            quoteRecord = (Quote__c) quoteMap.get('quote');
            String leadId = String.valueOf(quoteMap.get('leadId'));

            Policy__c policyrecord = new policy__c();
            policyrecord.name='policy';
            policyrecord.Quote_c__c = quoteRecord.Id;
            policyrecord.contact__c = conObj.id;
            policyrecord.Policy_Type_picklist__c = 'Watercraft';
            insert policyrecord;

            WatercraftFlowController.handleQuoteAction(quoteRecord, false);
            quoteRecord.End_Date_for_Coverage__c= date.today()+35;

            WatercraftFlowController.handleQuoteAction(quoteRecord, false);
            quoteRecord.End_Date_for_Coverage__c= date.today()+95;

            WatercraftFlowController.handleQuoteAction(quoteRecord, false);
            quoteRecord.End_Date_for_Coverage__c= date.today()+185;

            WatercraftFlowController.handleQuoteAction(quoteRecord, false);

            map<String,object> responseMap = WatercraftFlowController.createWatercraftAction(watercraft, quoteRecord, leadId);
            String watercraftId = String.valueOf(responseMap.get('watercraftId'));
            watercraft.Id = watercraftId;
            WatercraftFlowController.updateWatercraftAction( watercraft, quoteRecord );
            
          //  Map<String,object> driverMap = WatercraftFlowController.createDriverAction( driver, quoteRecord.Id, true, watercraftId );

            WatercraftFlowController.updatePolicyAction( conObj, policyrecord, JSON.serialize(new list<String>{ldObj.Id}), JSON.serialize( new list<String>{quoteRecord.Id}) );
        Test.stopTest();
    }

    @IsTest
    static void postiveTestingGuestUser(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        list<Profile>profiles = [SELECT Id FROM Profile WHERE usertype = 'Guest' LIMIT 1];  
        Id pid ;
        for(Profile k:profiles)
        {
            pid = k.id;  
        }
        
        User myuser = new user();
        myuser.LastName = 'Test Code';
        myuser.Email = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.Alias = 'Tcode';
        myuser.Username = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.CommunityNickname = 'test12';
        myuser.LocaleSidKey = 'en_US';
        myuser.TimeZoneSidKey = 'GMT';
        myuser.ProfileID =pid;
        myuser.LanguageLocaleKey = 'en_US';
        myuser.EmailEncodingKey = 'UTF-8';
        insert myuser;

        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        String leadString = '{ "Email": "testNewUser@gmail.com"}';

        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today();
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Watercraft';
        quoteRecord.Vehicle_Type__c = 'Watercraft';
        quoteRecord.Liability__c = '750,000';
        quoteRecord.Third_Party_Bodily_Injury__c = '$250,000 / $500,000';
        quoteRecord.Property_Damage_Liability__c = '$250,000';
        quoteRecord.Type_of_Vessel__c = 'Powerboat/Yacht'; 
        quoteRecord.Vessel_Length__c = 'Between 27\' and 45\' long'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        
        Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Watercraft';
        rate.Type_of_Vessel__c = 'Powerboat/Yacht';
        rate.Vessel_Length__c = 'Between 27\' and 45\' long';
        rate.Third_Party_Bodily_Injury__c = '$250,000 / $500,000';
        rate.Property_Damage_Liability__c = '$250,000';
        rate.Days__c = 10;
        rate.Trailering_Surcharge__c = 35;
        rate.IVA_Mex_Tax__c = 100;
        rate.Underwriter__c = quoteRecord.Underwriter__c;
        rate.Age_of_Vehicle_Surcharge_25_years_old__c = 10;
        rate.Age_of_Vehicle_Surcharge__c = 25; 
        rate.Age_of_Operator_Surcharge__c = 20;
        rate.Risk_3_Third_Party_Liability_Insured_Sum__c = '100,000';
        rate.Days__c = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
        rate.Term__c = 'Daily';//have to take care of this and quoteObject.Policy_Type_picklist__c == 'Driver License'
        rate.Underwriter__c = quoteRecord.Underwriter__c;
        insert rate; 

        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Beam__c = 'beam';
        watercraft.Engine_Type__c = 'engine';
        watercraft.Flag__c = 'flag';
        watercraft.Make__c = 'make';
        watercraft.Model__c = 'model';
        watercraft.Type_of_Vessel__c = 'Sailboat';
        watercraft.VIN_Number__c = '1325';
        watercraft.Value__c = 1000;
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Year__c = '2000';
        watercraft.Lead__c = ldObj.Id;

        driver__c driver = new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c = 'd';
        driver.Last_Name__c = 's';
        driver.email__c = 's@gmail.com';
        driver.Driver_Type__c = 'Owner';
        driver.Phone__c = '123';
        driver.Address__c = 'address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';
        WatercraftFlowController.updateRelatedContact(driver);
        Account affAccount = new Account();
        affAccount.Name = 'testaccount';
        affAccount.Affiliate_Number__c = '123456';
        insert affAccount;

        Legal_Term__c legalTerm = new Legal_Term__c();
        legalTerm.Policy_Type__c = 'Watercraft';
        legalTerm.Underwriter__c = 'Chubb';
        insert legalTerm;
        
        Authorize_Net_Customer_Profile__c auth=new Authorize_Net_Customer_Profile__c();
        auth.Quote__c=quoteRecord.id;
        insert auth;
        
        Subscription__c subs = new Subscription__c();
        subs.quote__c=quoteRecord.id;
        insert subs;

        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c= quoteRecord.id;
        insert trans;

        System.runAs(myuser){
            Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            Test.startTest();
                WatercraftFlowController.getDataFromDataTable(quoteRecord, false);
                quoteRecord.End_Date_for_Coverage__c= date.today()+35;
                WatercraftFlowController.getDataFromDataTable( quoteRecord, false);

                quoteRecord.End_Date_for_Coverage__c= date.today()+95;
                WatercraftFlowController.getDataFromDataTable( quoteRecord, false);

                quoteRecord.End_Date_for_Coverage__c= date.today()+365;
                WatercraftFlowController.getDataFromDataTable( quoteRecord, true);

                Map<String,object> quoteMap = WatercraftFlowController.handleVehicleQuoteAction(quoteRecord, leadString);
    
                quoteRecord = (Quote__c) quoteMap.get('quote');
                String leadId = String.valueOf(quoteMap.get('leadId'));

                Map<String,object> responseMap = WatercraftFlowController.createWatercraftAction(watercraft, quoteRecord, leadId);
                String watercraftId = String.valueOf(responseMap.get('watercraftId'));
                watercraft.Id = watercraftId;
                WatercraftFlowController.updateWatercraftAction( watercraft, quoteRecord );

                Map<String,object> driverMap = WatercraftFlowController.createDriverAction( driver, quoteRecord.Id, true, watercraftId,true );
                WatercraftFlowController.updateDriverAction( driver );
                
                //WatercraftFlowController.initializeFlow('a0H2i00000TUU2oEAH');
                WatercraftFlowController.initializeFlow(quoteRecord.Id);
                WatercraftFlowController.getRelatedDrivers( quoteRecord.Id );
                WatercraftFlowController.getCurrentUserWaterCraft();
                WatercraftFlowController.checkalreadyExistUserAction('test@gmail.com');
                WatercraftFlowController.saveQuoteActionByAdmin(ldObj.Id,'testFirst','testLast','test@gmail.com',quoteRecord.Id, '0987654321');
                WatercraftFlowController.saveQuoteAction(ldObj.Id, 'TestFirstname', 'TestLastName','test@gmail.com',quoteRecord.Id, '0987654321');
                // WatercraftFlowController.saveQuoteAction(ldObj.Id, 'TestFirstname', 'TestLastName', quoteRecord.Id);

                Schema.SObjectType st = Schema.getGlobalDescribe().get('Quote__c'); // obtain sObject description from the schema
                sObject tempobj = st.newSObject();
                WatercraftFlowController.getDependentMap(tempobj, 'Policy_Type_picklist__c', 'Time_Zone__c' ); 

                String rateRecordListmyuser = '[{"quoteId":"'+quoteRecord.Id+'","leadId":"'+ldObj.Id+'"}]';
                Account testAcc = new Account();

                Map<String,object> transactionMap =  WatercraftFlowController.createTransactionAction(rateRecordListmyuser, JSON.serialize(testAcc), watercraft); 

                Account acc = WatercraftFlowController.retrieveAffiliateAccount('123456');
                Legal_Term__c term = WatercraftFlowController.retrieveLegalTermDetails(quoteRecord.Policy_Type_picklist__c, quoteRecord.Underwriter__c);
            Test.stopTest();
        }
       
    }
 public static testMethod void handleQuoteForTowUnitActionTest(){
          Test.startTest();
          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quotes.Id;
         insert towunit;
        WatercraftFlowController.handleQuoteForTowUnitAction(JSON.serialize(towunit),quotes);
         Test.stopTest();
    }
    /*@IsTest
    static void postiveTestingCommunityUser(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Mex Insurance Customer Community Plus Login User' LIMIT 1];

        Account accObj = new account();
        accObj.name = 'testaccount';
        insert accObj;

        contact conObj = new contact();
        conObj.lastname = 'con';
        conObj.accountid = accObj.id;
        conObj.email = 'abc@gmail.com';
        insert conObj;
        
        User myuser = new User(
            Alias='Jesse', Email='jesse.creech@ncino.com',
            EmailEncodingKey='UTF-8', LastName='Creech',                    
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles', ContactId = conObj.Id,
            Username='jesse.creech@ncino.com', ProfileId = portalProfile.Id
        );
        insert myuser;

        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
        String leadString = '{ "Email": "testNewUser@gmail.com"}';

        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c = date.today();
        quoteRecord.End_Date_for_Coverage__c = date.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c = 'Liability';
        quoteRecord.Term__c=  'Daily';
        quoteRecord.Policy_Type_picklist__c = 'Watercraft';
        quoteRecord.Vehicle_Type__c = 'Watercraft';
        quoteRecord.Liability__c = '750,000';
        quoteRecord.Third_Party_Bodily_Injury__c = '$250,000 / $500,000';
        quoteRecord.Property_Damage_Liability__c = '$250,000';
        quoteRecord.Type_of_Vessel__c = 'Powerboat/Yacht'; 
        quoteRecord.Vessel_Length__c = 'Between 27\' and 45\' long'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        
        Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Watercraft';
        rate.Type_of_Vessel__c = 'Powerboat/Yacht';
        rate.Vessel_Length__c = 'Between 27\' and 45\' long';
        rate.Third_Party_Bodily_Injury__c = '$250,000 / $500,000';
        rate.Property_Damage_Liability__c = '$250,000';
        rate.Days__c = 10;
        rate.Trailering_Surcharge__c = 35;
        rate.IVA_Mex_Tax__c = 100;
        rate.Underwriter__c = quoteRecord.Underwriter__c;
        rate.Age_of_Vehicle_Surcharge_25_years_old__c = 10;
        rate.Age_of_Vehicle_Surcharge__c = 25; 
        rate.Age_of_Operator_Surcharge__c = 20;
        rate.Risk_3_Third_Party_Liability_Insured_Sum__c = '100,000';
        rate.Days__c = quoteRecord.Start_Date_for_Coverage__c.daysBetween(quoteRecord.End_Date_for_Coverage__c);
        rate.Term__c = 'Daily';//have to take care of this and quoteObject.Policy_Type_picklist__c == 'Driver License'
        rate.Underwriter__c = quoteRecord.Underwriter__c;
        insert rate; 

        Watercraft__c watercraft = new Watercraft__c();
        watercraft.Beam__c = 'beam';
        watercraft.Engine_Type__c = 'engine';
        watercraft.Flag__c = 'flag';
        watercraft.Make__c = 'make';
        watercraft.Model__c = 'model';
        watercraft.Type_of_Vessel__c = 'Sailboat';
        watercraft.VIN_Number__c = '1325';
        watercraft.Value__c = 1000;
        watercraft.Vessel_Length__c = 'Less than 27\' long';
        watercraft.Year__c = '2000';
        watercraft.Lead__c = ldObj.Id;

        driver__c driver = new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c = 'd';
        driver.Last_Name__c = 's';
        driver.email__c = 's@gmail.com';
        driver.Driver_Type__c = 'Owner';
        driver.Phone__c = '123';
        driver.Address__c = 'address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';

        Account affAccount = new Account();
        affAccount.Name = 'testaccount';
        affAccount.Affiliate_Number__c = '123456';
        insert affAccount;

        Legal_Term__c legalTerm = new Legal_Term__c();
        legalTerm.Policy_Type__c = 'Watercraft';
        legalTerm.Underwriter__c = 'Chubb';
        insert legalTerm;
        
        Authorize_Net_Customer_Profile__c auth=new Authorize_Net_Customer_Profile__c();
        auth.Quote__c=quoteRecord.id;
        insert auth;
        
        Subscription__c subs = new Subscription__c();
        subs.quote__c=quoteRecord.id;
        insert subs;

        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c= quoteRecord.id;
        insert trans;

        System.runAs(myuser){
            Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            Test.startTest();
                WatercraftFlowController.getDataFromDataTable(quoteRecord, false);
                quoteRecord.End_Date_for_Coverage__c= date.today()+35;
                WatercraftFlowController.getDataFromDataTable( quoteRecord, false);

                quoteRecord.End_Date_for_Coverage__c= date.today()+95;
                WatercraftFlowController.getDataFromDataTable( quoteRecord, false);

                quoteRecord.End_Date_for_Coverage__c= date.today()+365;
                WatercraftFlowController.getDataFromDataTable( quoteRecord, true);

                Map<String,object> quoteMap = WatercraftFlowController.handleVehicleQuoteAction(quoteRecord, leadString);
    
                quoteRecord = (Quote__c) quoteMap.get('quote');
                String leadId = String.valueOf(quoteMap.get('leadId'));

                Map<String,object> responseMap = WatercraftFlowController.createWatercraftAction(watercraft, quoteRecord, leadId);
                String watercraftId = String.valueOf(responseMap.get('watercraftId'));
                watercraft.Id = watercraftId;
                WatercraftFlowController.updateWatercraftAction( watercraft, quoteRecord );

               // Map<String,object> driverMap = WatercraftFlowController.createDriverAction( driver, quoteRecord.Id, true, watercraftId );
                WatercraftFlowController.updateDriverAction( driver );
                
               // WatercraftFlowController.initializeFlow();

                WatercraftFlowController.getRelatedDrivers( quoteRecord.Id );

              //  WatercraftFlowController.saveQuoteAction(ldObj.Id, 'TestFirstname', 'TestLastName', quoteRecord.Id);
               // WatercraftFlowController.saveQuoteAction(ldObj.Id, 'TestFirstname', 'TestLastName', quoteRecord.Id);

                Schema.SObjectType st = Schema.getGlobalDescribe().get('Quote__c'); // obtain sObject description from the schema
                sObject tempobj = st.newSObject();
                WatercraftFlowController.getDependentMap(tempobj, 'Policy_Type_picklist__c', 'Time_Zone__c' ); 

                String rateRecordListmyuser = '[{"quoteId":"'+quoteRecord.Id+'","leadId":"'+ldObj.Id+'"}]';
                Account testAcc = new Account();

                Map<String,object> transactionMap =  WatercraftFlowController.createTransactionAction(rateRecordListmyuser, JSON.serialize(testAcc), watercraft); 

                Account acc = WatercraftFlowController.retrieveAffiliateAccount('123456');
                Legal_Term__c term = WatercraftFlowController.retrieveLegalTermDetails(quoteRecord.Policy_Type_picklist__c, quoteRecord.Underwriter__c);
            Test.stopTest();
        }
    }*/
}