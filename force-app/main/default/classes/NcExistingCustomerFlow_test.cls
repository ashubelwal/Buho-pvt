@isTest
public class NcExistingCustomerFlow_test {
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
        
        Profile profileid = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; 
        
        
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
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
        Quote__c quote = new Quote__c();
        quote.Start_Date_for_Coverage__c= system.today();
        quote.End_Date_for_Coverage__c= system.today()+5;
        quote.Start_Time__c = Time.newInstance(10, 00, 00, 00);
        quote.End_Time__c = Time.newInstance(10, 00, 00, 00);
        quote.Driver_Age__c = 80;
        quote.Lead__c = ldObj.Id;
        quote.contact__c = conObj.Id;
        quote.Account__c = acObj.Id;
        quote.Underwriter__c ='Chubb';
        quote.Coverage__c='Complete';
        quote.Territory__c='  Full';
        quote.Term__c='Daily';
        quote.Policy_Type_picklist__c='Northbound';
        quote.Vehicle_Type__c = 'Automobile';
        quote.Medical__c='2,000/10,000';
        quote.Liability__c='100,000'; 
        quote.Date_of_Birth__c = date.newinstance(1950,10,12);
        quote.Towed_Unit__c = 'Yes';
        
        String quoteRecord = JSON.serialize(quote);
        quote.Towed_Unit__c = 'Yes';
        insert quote;
        
        List<driver__c> updatedrivers = new List<driver__c>();
        List<driver__c> drivers = new List<driver__c>();
        driver__c driver =new driver__c();
        driver.lead__c = ldObj.id;
        driver.Contact__c =  conObj.Id;
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
        drivers.add(driver);
        String driversRecord = JSON.serialize(drivers);
        insert driver;
        updatedrivers.add(driver);
        
        
        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = ldObj.Id;
        insert vehicle;
        String vehicleReacord = JSON.serialize(vehicle); 
        
       
        
        
        //
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
        
        String watercraftRecord = JSON.serialize(watercraft);    
        insert watercraft;
        
       
        
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quote.Id;
        insert towunit;
        towedUnitsData.add(towunit);
        String towedUnitRecord = JSON.serialize(towedUnitsData); 
        
        
        Map<Object, Object> termAgreements = new Map<Object, Object>();
        termAgreements.put('Terms_of_Purchase_Confirmed__c', true);
        termAgreements.put('Terms_of_Cancellation_Confirmed__c', true);
        
        String termAgreement = JSON.serialize(termAgreements);
        
         
        
        
        
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quote.id;
        insert trans;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        NcExistingCustomerFlow.checkCommunityUserAndFetchDetails();
        NcExistingCustomerFlow.saveQuoteRecordData(quoteRecord, vehicleReacord, towedUnitRecord);
        NcExistingCustomerFlow.saveQuoteRecordData(quoteRecord, '', towedUnitRecord);
        Mex_existingCustomerFlowController.saveWatercraftQuoteRecordData( quoteRecord, watercraftRecord);
        Mex_existingCustomerFlowController.saveWatercraftQuoteRecordData( quoteRecord, '');
        Mex_existingCustomerFlowController.createWatercraftPolicyForExistingCustomer(quote.Id, watercraft.Id, termAgreement);
        Mex_existingCustomerFlowController.createPolicyForExistingCustomer(quote.Id, vehicle.Id, termAgreement);
        
        String updatequoteRecord = JSON.serialize(quote);
        String updatewatercraftRecord = JSON.serialize(watercraft); 
        
        
        Mex_existingCustomerFlowController.updateWatercraftQuoteRecordData(updatequoteRecord, updatewatercraftRecord, driversRecord);
        
        
        
        String updatedriversRecord = JSON.serialize(updatedrivers);
        //Mex_existingCustomerFlowController.updateWatercraftQuoteRecordData(updatequoteRecord, updatequoteRecord, updatedriversRecord);
        
        String updatevehicleReacord = JSON.serialize(vehicle);
        
        NcExistingCustomerFlow.updateQuoteRecordData(updatequoteRecord, updatevehicleReacord, towedUnitRecord, updatedriversRecord);
        
       
        
        
        test.stopTest();
    }

    public static testMethod void postivetesting2(){
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
        
        
        Profile profileid = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; 
        
        
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
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
        Quote__c quote = new Quote__c();
        quote.Start_Date_for_Coverage__c= system.today();
        quote.End_Date_for_Coverage__c= system.today()+5;
        quote.Start_Time__c = Time.newInstance(10, 00, 00, 00);
        quote.End_Time__c = Time.newInstance(10, 00, 00, 00);
        quote.Driver_Age__c = 80;
        quote.Lead__c = ldObj.Id;
        quote.contact__c = conObj.Id;
        quote.Account__c = acObj.Id;
        quote.Underwriter__c ='Chubb';
        quote.Coverage__c='Complete';
        quote.Territory__c='  Full';
        quote.Term__c='Daily';
        quote.Policy_Type_picklist__c='Northbound';
        quote.Vehicle_Type__c = 'Automobile';
        quote.Medical__c='2,000/10,000';
        quote.Liability__c='100,000'; 
        quote.Date_of_Birth__c = date.newinstance(1950,10,12);
        quote.Towed_Unit__c = 'Yes';
        insert quote;
        String updatequoteRecord = JSON.serialize(quote);
        
        List<driver__c> updatedrivers = new List<driver__c>();
        List<driver__c> drivers = new List<driver__c>();
        driver__c driver =new driver__c();
        driver.lead__c = ldObj.id;
        driver.Contact__c =  conObj.Id;
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
        drivers.add(driver);
        String driversRecord = JSON.serialize(drivers);
        
        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = ldObj.Id;
       
        insert vehicle;
         String vehicleReacord = JSON.serialize(vehicle); 
        
       
        
        
        //
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
        
           
        insert watercraft;
        String watercraftRecord = JSON.serialize(watercraft); 
       
        
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quote.Id;
        insert towunit;
        towedUnitsData.add(towunit);
        String towedUnitRecord = JSON.serialize(towedUnitsData); 
        
        
       
        
        
        
        Map<Object, Object> termAgreements = new Map<Object, Object>();
        termAgreements.put('Terms_of_Purchase_Confirmed__c', true);
        termAgreements.put('Terms_of_Cancellation_Confirmed__c', true);
        
        String termAgreement = JSON.serialize(termAgreements);
        
         
        
        
        
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quote.id;
        insert trans;
        
        
         Quote_Driver__c quoteDriver = new Quote_Driver__c();
        quoteDriver.Quote_c__c = quote.Id;
        quoteDriver.Account_Driver__c = acObj.id;
        quoteDriver.Contact__c = conObj.Id;
        quoteDriver.Driver__c = driver.Id;
        quoteDriver.Vehicle_Driver__c = vehicle.Id;
        insert quoteDriver;
        
         Quote_Vehicle__c newQuoteVehicle = new Quote_Vehicle__c();
        newQuoteVehicle.Account__c = acObj.Id;
        newQuoteVehicle.Contact__c = conObj.Id;
        newQuoteVehicle.Quote_c__c = quote.Id;
        newQuoteVehicle.Vehicle__c = vehicle.Id;
        
        insert newQuoteVehicle;

        System.debug('QUote Vehicle Data'+newQuoteVehicle);
         Quote_Watercraft__c newQuotewatercraft = new Quote_Watercraft__c();
        newQuotewatercraft.Account__c = acObj.Id;
        newQuotewatercraft.Contact__c = conObj.Id;
        newQuotewatercraft.Quote_c__c = quote.Id;
        newQuotewatercraft.Watercraft__c = watercraft.Id;
        insert newQuotewatercraft;
        
        
        String updatewatercraftRecord = JSON.serialize(watercraft);
        
         Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
        newQuoteTowed.Account__c = acObj.Id;
        newQuoteTowed.Contact__c = conObj.Id;
        newQuoteTowed.Quote_c__c = quote.Id;
        newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
        newQuoteTowed.Towed_Unit__c = towunit.Id;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        NcExistingCustomerFlow.updateQuoteRecordData(updatequoteRecord, vehicleReacord, towedUnitRecord, driversRecord);
        Mex_existingCustomerFlowController.createPolicyForExistingCustomer(quote.Id, vehicle.Id, termAgreement);
        Test.stopTest();
        
    }
    public static testMethod void postivetesting3(){
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
        
        
        Profile profileid = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; 
        
        
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
        
        Account acObj=new account();
        acObj.name='testaccount';
        acObj.annualrevenue=2000;
        insert acObj;
        
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
        Quote__c quote = new Quote__c();
        quote.Start_Date_for_Coverage__c= system.today();
        quote.End_Date_for_Coverage__c= system.today()+5;
        quote.Driver_Age__c = 80;
        quote.Lead__c = ldObj.Id;
        quote.contact__c = conObj.Id;
        quote.Account__c = acObj.Id;
        quote.Underwriter__c ='Chubb';
        quote.Coverage__c='Complete';
        quote.Territory__c='  Full';
        quote.Term__c='Daily';
        quote.Policy_Type_picklist__c='Northbound';
        quote.Vehicle_Type__c = 'Automobile';
        quote.Medical__c='2,000/10,000';
        quote.Liability__c='100,000'; 
        quote.Date_of_Birth__c = date.newinstance(1950,10,12);
        quote.Towed_Unit__c = 'Yes';
        insert quote;
        String updatequoteRecord = JSON.serialize(quote);

        Quote__c quote2 = new Quote__c();
        quote.Start_Date_for_Coverage__c= system.today();
        quote.End_Date_for_Coverage__c= system.today()+5;
        quote.Driver_Age__c = 80;
        quote.Lead__c = ldObj.Id;
        quote.contact__c = conObj.Id;
        quote.Account__c = acObj.Id;
        quote.Underwriter__c ='Chubb';
        quote.Coverage__c='Complete';
        quote.Territory__c='  Full';
        quote.Term__c='Daily';
        quote.Policy_Type_picklist__c='Northbound';
        quote.Vehicle_Type__c = 'Automobile';
        quote.Medical__c='2,000/10,000';
        quote.Liability__c='100,000'; 
        quote.Date_of_Birth__c = date.newinstance(1950,10,12);
        quote.Towed_Unit__c = 'Yes';
        insert quote2;
        
        List<driver__c> updatedrivers = new List<driver__c>();
        List<driver__c> drivers = new List<driver__c>();
        driver__c driver =new driver__c();
        driver.lead__c = ldObj.id;
        driver.Contact__c =  conObj.Id;
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
        drivers.add(driver);
        String driversRecord = JSON.serialize(drivers);
        
        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        vehicle.Lead__c = ldObj.Id;
       
        insert vehicle;
         String vehicleReacord = JSON.serialize(vehicle); 
        
       
        
        
        //
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
        
           
        insert watercraft;
        String watercraftRecord = JSON.serialize(watercraft); 
       
        
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quote.Id;
        insert towunit;
        towedUnitsData.add(towunit);
        String towedUnitRecord = JSON.serialize(towedUnitsData); 
        
        
       
        
        
        
        Map<Object, Object> termAgreements = new Map<Object, Object>();
        termAgreements.put('Terms_of_Purchase_Confirmed__c', true);
        termAgreements.put('Terms_of_Cancellation_Confirmed__c', true);
        
        String termAgreement = JSON.serialize(termAgreements);
        
         
        
        
        
        Transaction__c trans = new Transaction__c();
        trans.Quote_c__c = quote.id;
        insert trans;
        
        
         Quote_Driver__c quoteDriver = new Quote_Driver__c();
        quoteDriver.Quote_c__c = quote2.Id;
        quoteDriver.Account_Driver__c = acObj.id;
        quoteDriver.Contact__c = conObj.Id;
        quoteDriver.Driver__c = driver.Id;
        quoteDriver.Vehicle_Driver__c = vehicle.Id;
        insert quoteDriver;
        
         Quote_Vehicle__c newQuoteVehicle = new Quote_Vehicle__c();
        newQuoteVehicle.Account__c = acObj.Id;
        newQuoteVehicle.Contact__c = conObj.Id;
        newQuoteVehicle.Quote_c__c = quote.Id;
        newQuoteVehicle.Vehicle__c = vehicle.Id;
        
        insert newQuoteVehicle;

        System.debug('QUote Vehicle Data'+newQuoteVehicle);
         Quote_Watercraft__c newQuotewatercraft = new Quote_Watercraft__c();
        newQuotewatercraft.Account__c = acObj.Id;
        newQuotewatercraft.Contact__c = conObj.Id;
        newQuotewatercraft.Quote_c__c = quote.Id;
        newQuotewatercraft.Watercraft__c = watercraft.Id;
        insert newQuotewatercraft;
        
        
        String updatewatercraftRecord = JSON.serialize(watercraft);
        
         Quote_Towed_Unit__c newQuoteTowed = new Quote_Towed_Unit__c();
        newQuoteTowed.Account__c = acObj.Id;
        newQuoteTowed.Contact__c = conObj.Id;
        newQuoteTowed.Quote_c__c = quote2.Id;
        newQuoteTowed.Quote_Vehicle__c = newQuoteVehicle.Id;
        newQuoteTowed.Towed_Unit__c = towunit.Id;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        String companyRecord ='{"Company_Name__c":"ankittcomp","Company_Phone__c":"(454) 645-656","Tax_ID__c":"23344","Company_Country__c":"United States","Company_Address__c":"4701 Great America Way","Company_Zip__c":"95054","Company_State__c":"California","Company_City__c":"Santa Clara"}';
        String vehicleRecord ='{"Id":"a0GVD0000071zrr2AA","label":"Audi A4 2024 - 32432543","value":"a0GVD0000071zrr2AA","Coverage__c":"Complete","Electric_Hybrid__c":false,"Liability__c":"300,000","Medical__c":"10,000/50,000","Year__c":"2024","Vehicle_sub_type__c":"Automobile-Van-Minivan","Make":"Audi","Model":"A4","Value__c":"3456","Vin__c":"32432543","Registered_Country__c":"United States","Registered_State__c":"Arizona","licensePlate":"TEST","Is_the_vehicle_registered_to_a_business__c":true}';
        String driversJson ='[{"Id":"a0LVD000007PZcr2AG","label":"shivam ten - 2009-11-10 - 98654KJJJ","value":"a0LVD000007PZcr2AG","First_Name__c":"shivam","Last_Name__c":"ten","License_Country__c":"United States","License_state__c":"Alabama","license_number__c":"98654KJJJ","Dob__c":"2009-11-10","Driver_Type__c":true,"Country__c":"United States","Country_Text__c":"United States","State_Province__c":"California","Postal_Code__c":"95054","City__c":"Santa Clara","Address__c":"4701 Great America Pkwy","diff":1762767973446},{"Id":"a0LVD000007PZcs2AG","label":"Testing Chauhan - 2001-11-10 - 98654K","value":"a0LVD000007PZcs2AG","First_Name__c":"Testing","Last_Name__c":"Chauhan","License_Country__c":"United States","License_state__c":"Arizona","license_number__c":"98654K","Dob__c":"2001-11-10","Driver_Type__c":false,"Country__c":"","Country_Text__c":"","State_Province__c":"","Postal_Code__c":"","City__c":"","Address__c":"","diff":1762767973446}]';
        Test.startTest();
        NcExistingCustomerFlow.updateVehicleRecordData(vehicleRecord,companyRecord);
        NcExistingCustomerFlow.updateVehicleWithOwnerDriver(vehicleRecord, driversJson);
        NcExistingCustomerFlow.updateQuoteRecordData(updatequoteRecord, vehicleReacord, towedUnitRecord, driversRecord);
        Mex_existingCustomerFlowController.createPolicyForExistingCustomer(quote.Id, vehicle.Id, termAgreement);
        Test.stopTest();
        
    }  
}