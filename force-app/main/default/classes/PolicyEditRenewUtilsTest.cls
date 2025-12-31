@isTest
public class PolicyEditRenewUtilsTest {
    
    @isTest
    static void fetchPolicyDetails_testCase1(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name='PolicyTrigger';
        customset.Active__c=FALSE;
        insert customset;
        
        Quote__c quote = new Quote__c();
        quote.Start_Date_for_Coverage__c= system.today();
        quote.End_Date_for_Coverage__c= system.today()+5;
        quote.Driver_Age__c = 80;
        
        quote.Underwriter__c ='Chubb';
        quote.Coverage__c='Complete';
        quote.Territory__c='  Full';
        quote.Term__c='Daily';
        quote.Policy_Type_picklist__c='Northbound';
        quote.Vehicle_Type__c = 'Automobile';
        quote.Medical__c='2,000/10,000';
        quote.Liability__c='100,000'; 
        quote.Date_of_Birth__c = date.newinstance(1950,10,12);
        quote.Towed_Unit__c = 'true';
        quote.Start_Time__c = Time.newInstance(1, 0, 0, 0);
        quote.End_Time__c = Time.newInstance(1, 0, 0, 0);
        
        String quoteRecord = JSON.serialize(quote);
        quote.Towed_Unit__c = 'Yes';
        insert quote;
        List<driver__c> drivers = new List<driver__c>();
        driver__c driver =new driver__c();
        driver.Quote_c__c = quote.Id;
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
        insert drivers;
        
        Quote_Driver__c qtd = new Quote_Driver__c();
        qtd.Driver__c = driver.Id;
        qtd.Quote_c__c = quote.Id;
        insert qtd;
        
        vehicle__c vehicle = new vehicle__c();
        vehicle.Company_Name__c ='northbund';
        vehicle.Company_Address__c='abc';
        vehicle.type__c='car';
        vehicle.model__c='suv';
        vehicle.make__c='ford';
        vehicle.year__c='2020';
        insert vehicle;
        
        
        Legal_Term__c legalterm = new Legal_Term__c();
        legalterm.Terms_of_Purchase_and_Use__c = 'No';
        legalterm.Underwriter__c = 'Chubb';
        legalterm.Policy_Type__c = 'Watercraft';        
        insert legalterm;
        
        List<Towed_Unit__c> towedUnitsData = new List<Towed_Unit__c>();
        Towed_Unit__c towunit = new Towed_Unit__c();
        towunit.Quote_c__c = quote.Id;
        //insert towunit;
        towedUnitsData.add(towunit);
        insert towedUnitsData;
        Quote_Towed_Unit__c towedQUotes = new Quote_Towed_Unit__c();
        towedQUotes.Towed_Unit__c = towunit.Id;
        towedQUotes.Quote_c__c = quote.Id;
        insert towedQUotes;
        
        
        Policy__c policy = new Policy__c();
        policy.Quote_c__c = quote.Id;
        insert policy;
        Test.setMock(HttpCalloutMock.class, new Mex_Insurance_Mock());
        Test.startTest();
        PolicyEditRenewUtils.fetchPolicyDetails(policy.Id);
        PolicyEditRenewUtils.fetchPolicyQuoteDetails(quote.Id);
        PolicyEditRenewUtils.fetchPolicyVehicleDetails(vehicle.Id);
        PolicyEditRenewUtils.fetchPolicyDriverDetails(quote.Id);
        PolicyEditRenewUtils.fetchPolicyTowedDetails(quote.Id);
        PolicyEditRenewUtils.fetchUpdatedDate(Date.today(),'Semi-Annual(Half a Year)');
        PolicyEditRenewUtils.fetchUpdatedDate(Date.today(),'Annual');
        PolicyEditRenewUtils.fetchDateRelatedInfo();
        PolicyEditRenewUtils.createNewEditPolicyFromCash(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,false);
        PolicyEditRenewUtils.createNewEditPolicyFromCash(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,true);
        PolicyEditRenewUtils.createNewEditPolicyFromCashWithAmount(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,false,230);
        PolicyEditRenewUtils.createNewEditPolicyFromCashWithAmount(JSON.serialize(vehicle),JSON.serialize(drivers),JSON.serialize(towedUnitsData),quote.Id,policy.Id,true,230);
        Test.stopTest();
    }
}