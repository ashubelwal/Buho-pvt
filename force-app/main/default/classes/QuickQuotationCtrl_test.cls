@isTest
public class QuickQuotationCtrl_test {

    public static testMethod void postivetesting(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 

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

        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Northbound';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='2,000/10,000';
        quoteRecord.Liability__c='100,000'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        String leadString = '{ "Email": "testNewUser@gmail.com"}';

        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = ldObj.Id;

        driver__c driver =new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c='d';
        driver.Last_Name__c='s';
        driver.email__c='s@gmail.com';
        driver.Driver_Type__c='Owner';
        driver.Phone__c='123';
        driver.Address__c ='address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';
        driver.Contact__c = conObj.Id;

        insert driver;

        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        test.startTest();
          QuickQuotationCtrl.getPicklistValues('Quote__c', 'Policy_Type_picklist__c');
          QuickQuotationCtrl.generatePolicyName('Test', 'Test', 'Test', 'Test', 'Test');
          map<String,object> quoteMap = QuickQuotationCtrl.handleVehicleQuoteAction(quoteRecord, leadString);
          QuickQuotationCtrl.handleVehicleQuoteAction(null, null);
          QuickQuotationCtrl.getCoverageDetail(quoteRecord);
         

          String quoteId = String.valueOf(quoteMap.get('quoteId'));
          String leadId = String.valueOf(quoteMap.get('leadId'));
          quoteRecord.Id = quoteId;
          QuickQuotationCtrl.createTowedUnit( new Towed_Unit__c(), quoteId,vehicle.Id);
        QuickQuotationCtrl.createTowedUnit( null, null,null);

          Policy__c policyrecord=new policy__c();
          policyrecord.name='policy';
          policyrecord.Quote_c__c = quoteRecord.Id;
          policyrecord.contact__c= conObj.id;
          policyrecord.Vehicle_Policy__c= vehicle.id;
          policyrecord.Policy_Type_picklist__c = 'Northbound';
        policyRecord.Yellow_Card__c ='Yes';
          insert policyrecord;

          Legal_Term__c legal = new Legal_Term__c();
          legal.Policy_Type__c = 'Automobile';
          legal.Underwriter__c = 'Chubb';
          insert legal;

        	 Quote_Vehicle__c quotVeh = new Quote_Vehicle__c();
        quotVeh.Vehicle__c = vehicle.Id;
        quotVeh.Quote_c__c = quoteRecord.Id;
        quotVeh.Policy__c = policyrecord.Id;
        
        insert quotVeh;
        
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quoteRecord.Id;
         insert towunit;
        
        Quote_Towed_Unit__c quoteTowed = new Quote_Towed_Unit__c();
        quoteTowed.Quote_Vehicle__c = quotVeh.Id;
        quoteTowed.Quote_c__c = quoteRecord.Id;
        quoteTowed.Policy__c = policyrecord.Id;
        quoteTowed.Towed_Unit__c = towunit.Id;
        
        insert quoteTowed;
        
        Quote_Driver__c quoteDriver = new Quote_Driver__c();
        quoteDriver.Driver__c = driver.Id;
        quoteDriver.Account_Driver__c = acObj.Id;
        quoteDriver.Contact__c = conObj.Id;
        quoteDriver.Policy__c = policyrecord.Id;
        quoteDriver.Quote_c__c = quoteRecord.Id;
        quoteDriver.Vehicle_Driver__c = vehicle.Id;
        insert quoteDriver;
        
     
        
      QuickQuotationCtrl.getDriver(quoteRecord.Id);
        QuickQuotationCtrl.getTowedUnit(quoteRecord.Id);
 		QuickQuotationCtrl.getVehicle(quoteRecord.Id);
        
          QuickQuotationCtrl.handleQuocteAction(quoteRecord);
          quoteRecord.End_Date_for_Coverage__c= system.today()+35;

          QuickQuotationCtrl.handleQuocteAction(quoteRecord);
          quoteRecord.End_Date_for_Coverage__c= system.today()+95;

          QuickQuotationCtrl.handleQuocteAction(quoteRecord);
          quoteRecord.End_Date_for_Coverage__c= system.today()+185;

          QuickQuotationCtrl.handleQuocteAction(quoteRecord);

          QuickQuotationCtrl.createVehicleNorthAction( vehicle, quoteRecord.Id);
          QuickQuotationCtrl.updateVehicleAction( vehicle );
          map<String,object> driverMap = QuickQuotationCtrl.createDriverAction( driver, quoteId, true, null, true );
          System.debug('---driverMap--'+driverMap);

        QuickQuotationCtrl.sendEmailDocumentAction( JSON.serialize( new set<String>{'test'}));
        QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id,  'test@gmail.com', 'Northbound', 'Chubb');
        QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Driver License', 'Chubb');
        QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Watercraft', 'Chubb');
        QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Automobile', 'Chubb');
        QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Automobile', 'Mapfre');
        QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Automobile', 'Qualitas');
        QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'RV', 'Qualitas');
        
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id,  'test@gmail.com', 'Northbound', 'Chubb', 'CDLA-22-1LRT0_Yellow_Card');
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Driver License', 'Chubb', 'CDLA-22-1LRT0_Yellow_Card');
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Watercraft', 'Chubb', 'CDLA-22-1LRT0_Yellow_Card');
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id, 'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Automobile', 'Chubb', 'CDLA-22-1LRT0_Yellow_Card');
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Automobile', 'Mapfre', 'CDLA-22-1LRT0_Yellow_Card');
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Automobile', 'Qualitas', 'CDLA-22-1LRT0_Yellow_Card');
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'RV', 'Qualitas', 'CDLA-22-1LRT0_Yellow_Card');
        
        QuickQuotationCtrl.getquickQuoteDataSouthBound(quoteRecord, '', '', '', '', '', '', '' );
        QuickQuotationCtrl.createOrUpdateHomeOwner(leadString);
        QuickQuotationCtrl.retrieveLegalTermDetails('Automobile', 'Chubb');
        QuickQuotationCtrl.retrieveAffiliateAccount('1234'); 
        QuickQuotationCtrl.getTimeZone();
        QuickQuotationCtrl.getContact(quoteRecord.Id);
        QuickQuotationCtrl.updateLeadRecord(ldObj.Id, 'TestLead', 'TestLname', 'ssharma'+String.valueOf(System.today())+'@gmail.com', '0987654321', quoteRecord.id, 'Automobile');

          QuickQuotationCtrl.updatePolicyAction( conObj, policyrecord, JSON.serialize(new list<String>{ldObj.Id}), JSON.serialize( new list<String>{quoteId}) );
        test.stopTest();
    }


    
    public static testMethod void postiveDriverLicenseQuotetesting(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;

        Profile profileid = [SELECT Id FROM Profile WHERE userType = 'Guest' LIMIT 1];  
        /*id pid ;
        for(Profile k:profileId)
        {
          pid = k.id;  
        } */

        User myuser = new user();
        myuser.LastName = 'Test Code';
        myuser.Email = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.Alias = 'Tcode';
        myuser.Username = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.CommunityNickname = 'test12';
        myuser.LocaleSidKey = 'en_US';
        myuser.TimeZoneSidKey = 'GMT';
        myuser.ProfileID = profileid.Id;
        myuser.LanguageLocaleKey = 'en_US';
        myuser.EmailEncodingKey = 'UTF-8';
        
        //insert myuser;

        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 

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
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Northbound';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='2,000/10,000';
        quoteRecord.Liability__c='100,000'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        String leadString = '{ "Email": "testNewUser@gmail.com"}';

        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = ldObj.Id;
        
        insert vehicle; 
        Policy__c policyrecord=new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c= conObj.id;
        policyrecord.Vehicle_Policy__c= vehicle.id;
        policyrecord.Policy_Type_picklist__c = 'Northbound';
        policyRecord.Yellow_Card__c = 'No';
        insert policyrecord;
        
        driver__c driver =new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c='d';
        driver.Last_Name__c='s';
        driver.email__c='s@gmail.com';
        driver.Driver_Type__c='Owner';
        driver.Phone__c='123';
        driver.Address__c ='address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes';

        insert driver;
       
             QuickQuotationCtrl.getPicklistValues('Quote__c', 'Policy_Type_picklist__c');
            //QuickQuotationCtrl.generatePolicyName('Test', 'Test', 'Test', 'Test', 'Test');
            QuickQuotationCtrl.driverLicenseQuote(leadString, quoteRecord);
         QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'RV', 'Chubb');
            QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'RV', 'Mapfre');
            QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Motorcycle/Street Legal ATV', 'Qualitas');
            QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Motorcycle/Street Legal ATV', 'Chubb');
            QuickQuotationCtrl.sendQuoteEmail( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Motorcycle/Street Legal ATV', 'Mapfre');
        
        QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'RV', 'Chubb', 'CDLA-22-1LRT0_Yellow_Card');
            QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'RV', 'Mapfre', 'CDLA-22-1LRT0_Yellow_Card');
            QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Motorcycle/Street Legal ATV', 'Qualitas', 'CDLA-22-1LRT0_Yellow_Card');
            QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Motorcycle/Street Legal ATV', 'Chubb', 'CDLA-22-1LRT0_Yellow_Card');
            QuickQuotationCtrl.sendQuoteEmailWithYellowCard( policyrecord.Id,'CDLA-22-1LRT0', conObj.Id, 'test@gmail.com', 'Motorcycle/Street Legal ATV', 'Mapfre', 'CDLA-22-1LRT0_Yellow_Card');
      /*  Test.startTest();
        system.runAs(myuser){
          Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            QuickQuotationCtrl.getPicklistValues('Quote__c', 'Policy_Type_picklist__c');
            //QuickQuotationCtrl.generatePolicyName('Test', 'Test', 'Test', 'Test', 'Test');
            QuickQuotationCtrl.driverLicenseQuote(leadString, quoteRecord);
        }
        Test.stopTest(); */
    }

    public static testMethod void postivetestingGuestUser(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Profile profileid = [SELECT Id FROM Profile WHERE userType = 'Guest' LIMIT 1];  
        /*id pid ;
        for(Profile k:profileId)
        {
          pid = k.id;  
        }*/
          
        
        User myuser = new user();
        myuser.LastName = 'Test Code';
        myuser.Email = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.Alias = 'Tcode';
        myuser.Username = 'test'+String.valueOf(System.today())+'@test.com';
        myuser.CommunityNickname = 'test12';
        myuser.LocaleSidKey = 'en_US';
        myuser.TimeZoneSidKey = 'GMT';
        myuser.ProfileID =profileid.Id;
        myuser.LanguageLocaleKey = 'en_US';
        myuser.EmailEncodingKey = 'UTF-8';
        insert myuser;


        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 

        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.lead__c = ldObj.Id;
        quoteRecord.End_Date_for_Coverage__c= system.today()+5;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Northbound';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='2,000/10,000';
        quoteRecord.Liability__c='100,000'; 
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);

        insert quoteRecord;
        
        Rate_Table__c rate = new Rate_Table__c();
        rate.Total_Premium__c = 100;
        rate.Net_Premium__c = 100;
        rate.Broker_Policy_Fee__c = 100;
        rate.Package__c ='Liability';
        rate.Type__c = 'Automobile';
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
        rate.Direction__c =quoteRecord.Policy_Type_picklist__c;
        insert rate; 

        String leadString = '{ "Email": "testNewUser@gmail.com"}';

        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = ldObj.Id;
		
        insert vehicle;
        driver__c driver =new driver__c();
        driver.lead__c = ldObj.id;
        driver.First_Name__c='d';
        driver.Last_Name__c='s';
        driver.email__c='s@gmail.com';
        driver.Driver_Type__c='Owner';
        driver.Phone__c='123';
        driver.Address__c ='address';
        driver.Address_Line_2__c = 'address';
        driver.City__c = 'city';
        driver.Country__c = 'country';
        driver.default__c = 'Yes'; 
          
        insert driver;
        
        Authorize_Net_Customer_Profile__c auth=new Authorize_Net_Customer_Profile__c();
        auth.Quote__c=quoteRecord.id;
        insert auth;
          
        Subscription__c subs = new Subscription__c();
        subs.quote__c=quoteRecord.id;
        insert subs;

        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c= quoteRecord.id;
        insert trans;

        test.startTest();
        system.runAs(myuser){
          Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '100,000');
            quoteRecord.End_Date_for_Coverage__c= system.today()+35;
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '70000');

            quoteRecord.End_Date_for_Coverage__c= system.today()+95;
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '100000');

            quoteRecord.End_Date_for_Coverage__c= system.today()+185;
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '150000');
              quoteRecord.End_Date_for_Coverage__c= system.today()+186;
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '300000');
            quoteRecord.End_Date_for_Coverage__c= system.today()+188;
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '200000');
            quoteRecord.End_Date_for_Coverage__c= system.today()+189;
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '50000');
              quoteRecord.End_Date_for_Coverage__c= system.today()+187;
            QuickQuotationCtrl.getDataFromDataTable( quoteRecord, '500000');
            QuickQuotationCtrl.getDataFromDataTable( null, null);

            map<String,object> quoteMap = QuickQuotationCtrl.handleVehicleQuoteAction(quoteRecord, leadString);
            

            String quoteId = String.valueOf(quoteMap.get('quoteId'));
            String leadId = String.valueOf(quoteMap.get('leadId'));
            QuickQuotationCtrl.createTowedUnit( new Towed_Unit__c(), quoteId,vehicle.Id);

            QuickQuotationCtrl.createVehicleNorthAction( vehicle, quoteId);
            QuickQuotationCtrl.updateVehicleAction( vehicle );
            map<String,object> driverMap = QuickQuotationCtrl.createDriverAction( driver, quoteId, true, '',true);
            System.debug('---driverMap--'+driverMap);

            QuickQuotationCtrl.updateDriverAction( driver );
            QuickQuotationCtrl.getDriver(quoteId);

            

            QuickQuotationCtrl.getQuoteDetails( JSON.serialize(new list<String>{quoteId}));
            QuickQuotationCtrl.initialize( 'Northbound', quoteRecord.Id);

            QuickQuotationCtrl.saveQuoteAction(ldObj.Id, 'TestFirstname', 'TestLastName', driver.email__c,driver.Phone__c, quoteId);
            QuickQuotationCtrl.saveQuoteAction(ldObj.Id, 'TestFirstname', 'TestLastName',driver.email__c,driver.Phone__c, quoteId);
            QuickQuotationCtrl.getRelatedDrivers(quoteRecord.Id);
            QuickQuotationCtrl.getCoverageDetailForSouthbound(quoteRecord);
            String rateRecordListmyuser = '[{"quoteId":"'+quoteRecord.Id+'","leadId":"'+ldObj.Id+'"}]';
            Account testAcc = new Account();
            
            map<String,object> transactionMap =  QuickQuotationCtrl.createTransactionAction(rateRecordListmyuser, JSON.serialize(testAcc)); 
            System.debug('---transactionMap--'+transactionMap);
            
            Schema.SObjectType st = Schema.getGlobalDescribe().get('Quote__c'); // obtain sObject description from the schema
            sObject tempobj = st.newSObject();
            
            QuickQuotationCtrl.getDependentMap(tempobj, 'Policy_Type_picklist__c', 'Time_Zone__c' ); 
            QuickQuotationCtrl.getLeadRecord(' Id != null ');
            QuickQuotationCtrl.checkRateTableExist(2000.00, 'Motorcycle/Street Legal ATV');
           
        }
        test.stopTest();
  }


  public static testMethod void negativeTesting(){
      Test.startTest();
        Driver__c driver = new Driver__c();
       driver.First_Name__c = 'TestFirstname';
       insert driver;
      
       
          QuickQuotationCtrl.saveQuoteAction(driver.Id,  driver.First_Name__c, 'TestLastName', 'sfc@gmail.com','123', 'QN-35421');
          QuickQuotationCtrl.updateVehicleAction(null);
          QuickQuotationCtrl.updateDriverAction(null);
          QuickQuotationCtrl.createVehicleNorthAction(null, null);
          QuickQuotationCtrl.updateQuoteContact(null, null, null );
          QuickQuotationCtrl.updateTowedunitContact(null, null, null );
      Test.stopTest();
  }
     public static testMethod List<Vehicle__c> getVehicle (){
        Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
        list<Quote_Vehicle__c> quoteVechiles = new list<Quote_Vehicle__c>();
         Quote_Vehicle__c quotevechile = new Quote_Vehicle__c (); 
         quoteVechiles = [select Vehicle__c from Quote_Vehicle__c where Quote_c__c =:quotes.Id ];
        if( quoteVechiles != null && !quoteVechiles.isEmpty() ){
            set<String> vechileIds = new set<String>();
            for(Quote_Vehicle__c qvl : quoteVechiles){
                vechileIds.add( qvl.Vehicle__c );
            }
            String query = QuickQuotationCtrl.getQueryWithAllFields(Vehicle__c.getSObjectType().getDescribe().getName());
            query += ' where Id IN: vechileIds';
            return Database.query(query);
    }
            return null;    
} 
    public static testMethod void deleteDriverAction() {
          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
        
        Driver__c driver = new  Driver__c ();
        driver.First_Name__c = 'TestFirstname';
        insert driver;
       Test.startTest();
        QuickQuotationCtrl.deleteDriverAction(driver,quotes.Id);
        QuickQuotationCtrl.deleteDriverAction(null,null);
        Test.stopTest();
            
                  
    }
    public static testMethod void getCurrentUserDrivers(){
         list<Profile>profileid = [SELECT Id FROM Profile WHERE usertype = 'Guest' LIMIT 1];  
        id pid ;
        for(Profile k:profileId)
        {
          pid = k.id;  
        }
         Test.startTest();
        QuickQuotationCtrl.getCurrentUserDrivers();
        Test.stopTest();
    }
    public static testMethod void getCurrentUserTransporate(){
         Test.startTest();
        QuickQuotationCtrl.getCurrentUserTransporate();
        Test.stopTest();
    }
    public static  testMethod void getCurrentUserVehicles(){
        Test.startTest();
        QuickQuotationCtrl.getCurrentUserVehicles('Driver License');
        Test.stopTest();
    }
    public static testMethod void retrieveWatercraftDetailsByQuoteId(){
                Test.startTest();
          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
        Quote_Watercraft__c quotewatercraft = new Quote_Watercraft__c();
        quotewatercraft.Quote_c__c = quotes.Id;
         insert quotewatercraft;
         QuickQuotationCtrl.retrieveWatercraftDetailsByQuoteId(quotes.Id);
          Test.stopTest();
        
    }
    public static testMethod void getStateCode(){
         Test.startTest();
          QuickQuotationCtrl.getStateCode('AB');
         Test.stopTest();
    }
    public static testMethod void getCountryCode(){
        Test.startTest();
          QuickQuotationCtrl.getCountryCode('united states');
         Test.stopTest();
    }
    public static testMethod void checkalreadyExistUserAction(){
         Test.startTest();
         QuickQuotationCtrl.checkalreadyExistUserAction('test@gmail.com');
          Test.stopTest();
        
    }
    public static testMethod void retrieveTransactionDetailsByQuoteId(){
         Test.startTest();
          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
        QuickQuotationCtrl.retrieveTransactionDetailsByQuoteId(quotes.Id);
        Test.stopTest();
    } 
    public static testMethod void  getQuoteRecord(){  
        Test.startTest();
          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
        QuickQuotationCtrl.getQuoteRecord(quotes.Id);
        Test.stopTest();    
    }
    public static testMethod void createNewDriver(){
        Test.startTest();
        QuickQuotationCtrl.vechileTriggerAction = false; // stop trigger
        
        Map<String, Object> responseMap = new Map<String, Object>();
         lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldObj.status='New';  
        insert ldObj; 
          driver__c driverRecord =new driver__c();
        driverRecord.lead__c = ldObj.id;
        driverRecord.First_Name__c='d';
        driverRecord.Last_Name__c='s';
        driverRecord.email__c='s@gmail.com';
        driverRecord.Driver_Type__c='Owner';
        driverRecord.Phone__c='123';
        driverRecord.Address__c ='address';
        driverRecord.Address_Line_2__c = 'address';
        driverRecord.City__c = 'city';
        driverRecord.Country__c = 'country';
        driverRecord.default__c = 'Yes'; 
        insert driverRecord;
        try{
            
            list<User> userList = new list<User>();
            userList = [select Id, contactId, Contact.accountId from User where Id='0052i000004cBweAAE' and contactId != null ];
             QuickQuotationCtrl.createNewDriver(driverRecord);
            QuickQuotationCtrl.createNewDriver(null);
        }
        
        catch (exception ex) {
            
        }
        Test.stopTest();      
    }
    public static testMethod void getBoatPicklistValues(){
        
         Test.startTest();
         QuickQuotationCtrl.getBoatPicklistValues('Quote__c', 'Policy_Type_picklist__c');
          Test.stopTest();
    }
    public static testMethod void getBoatDependentMap(){
         Test.startTest();
        Schema.SObjectType st = Schema.getGlobalDescribe().get('Quote__c'); // obtain sObject description from the schema
            sObject tempobj = st.newSObject();
         QuickQuotationCtrl.getBoatDependentMap(tempobj,'Policy_Type_picklist__c', 'Time_Zone__c');
          Test.stopTest();
        
    }
    public static testMethod void handleDeleteTowedUnitAction(){
           Test.startTest();
          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
         QuickQuotationCtrl.handleDeleteTowedUnitAction(quotes);
        QuickQuotationCtrl.handleDeleteTowedUnitAction(null);
          Test.stopTest();
    } 
    public static testMethod void handleQuoteForTowUnitAction(){
          Test.startTest();
          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quotes.Id;
         insert towunit;
        QuickQuotationCtrl.handleQuoteForTowUnitAction(JSON.serialize(towunit),quotes);
        QuickQuotationCtrl.handleQuoteForTowUnitAction(null,null);
         Test.stopTest();
    }
    public static testMethod void deleteTowedUnitAction(){

          Quote__c quotes = new Quote__c ();
         date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
         insert quotes;
          Towed_Unit__c towunit = new Towed_Unit__c();
         towunit.Quote_c__c = quotes.Id;
         insert towunit;
        Test.startTest();
         QuickQuotationCtrl.deleteTowedUnitAction(towunit.Id,quotes.Id);
        QuickQuotationCtrl.deleteTowedUnitAction(null,null);
         Test.stopTest();
    }
    
/*    public static testMethod void emailTemplateAction(){
     
        EmailTemplate fld = [SELECT Id, Subject,Description, HtmlValue,Name, Body, folderId FROM EmailTemplate WHERE Name = 'UserLicense SendEmail'];
        
        EmailTemplate e = new EmailTemplate (developerName = 'UserLicense_SendEmail',Folderid = fld.folderId , TemplateType= 'Text', Name = 'UserLicense SendEmail'); // plus any other fields that you want to set
        insert e;
        
        QuickQuotationCtrl.checkUserLicenceSendMail();
    } */
}