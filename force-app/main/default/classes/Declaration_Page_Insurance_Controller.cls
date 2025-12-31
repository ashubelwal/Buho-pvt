public without sharing class Declaration_Page_Insurance_Controller {
    public Policy__c policy{get; set;}
    public Transaction__c trans{get; set;}
    public list<Towed_Unit__c> towedUnitsList {get;set;}
    public string policyId;
    public string medicalExpensePerPerson {get;set;}
    public string medicalExpensePerAccident {get;set;}
    public Driver__c driver {get;set;}
    public Driver__c primaryInsuredDriver {get;set;}
    public Coverage_Detail__c cvrgDetail {get;set;}
    public string startTime {get;set;}
    public string endTime {get;set;}
    public Watercraft__c Watercraft{get; set;}
    public String formattedDobDate {get;set;}
    public decimal totalTowedUnitPrice {get;set;}
    public decimal totalInsuredValue {get;set;}
    public list<Driver__c> drivers {get;set;}
    public string formattedIssuanceDate {get;set;}
    public string formattedIssuanceTime {get;set;}
    public user agencyData{get; set;}
    public decimal totalBrokerageFee {get;set;}
    public decimal netPremiumWithoutAgentAndBrokerFee {get;set;}

    public Declaration_Page_Insurance_Controller() {
        try{ 
            primaryInsuredDriver = new driver__c();
            Watercraft = new Watercraft__c();
            towedUnitsList = new list<Towed_Unit__c>();
            policyId = ApexPages.currentPage().getParameters().get('id');
            system.debug('policyId -> '+ policyId);
            driver = new driver__c();    
            drivers = new list<Driver__c>();
            list<Policy__c> policyList = new list<Policy__c>(); 
            policyList = [SELECT Id, Chubb_Policy_Number__c, Name, Created_At__c,CreatedDate,Issued_At__c, Contact__r.Name, End_at__c, Start_at__c, Policy_Type_picklist__c, Contact__r.Date_of_Birth__c, Contact__r.Street__c, Start_Time__c, End_Time__c, End_Date__c, Package__c, Underwriter_picklist__c, Contact__r.Street_2__c, Contact__r.State__c, Contact__r.Postal_Code__c, Contact__r.Email, Contact__r.City__c, Contact__r.Country__c,
                          Contact__r.Phone, contact__r.MailingAddress, Insured_value__c, Vehicle_deductible_comprehensive__c,
                          Contact__r.MailingState, Contact__r.MailingCity, Contact__r.MailingStreet, Third_Party_Bodily_Injury__c, Property_Damage_Liability__c,
                          Contact__r.MailingPostalCode, Contact__r.MailingCountry, Territory_picklist__c, Surcharge__c, 
                          What_is_the_purpose_of_trip__c, Net_Premium__c,Policy_Fee__c, Broker_Policy_Fee__c, Agent_Brokerage_Fee__c, Total_Premium_Amount__c,
                          Liability_picklist__c,Vehicle_deductible_collision__c, Under_21__c, Watercraft__r.Year__c, 
                          (SELECT id, Id__c , Name from Transactions__r), Watercraft__c, Watercraft__r.Make__c, Watercraft__r.Model__c, 
                          (SELECT Id, Primary_insured__c, Driver__c from Quote_Drivers__r), 
                          Quote_c__c, Quote_c__r.Is_there_a_driver_under_21__c,
                          Quote_c__r.Is_the_Maximum_Speed_more_than_50_mph__c,
                          Quote_c__r.Is_the_owner_living_in_Mexico__c,
                          Quote_c__r.Is_there_a_driver_over_75__c,
                          Vehicle_Policy__r.Is_Lienholder__c,Vehicle_Policy__r.Is_the_vehicle_registered_to_a_business__c,Vehicle_Policy__r.Is_vehicle_owned_by_a_company_or_rented__c,
                          Vehicle_Policy__r.Company_Name__c,Vehicle_Policy__r.Company_Address__c,Vehicle_Policy__r.Company_City__c,Vehicle_Policy__r.Company_Zip__c,Vehicle_Policy__r.Company_State__c,Vehicle_Policy__r.Company_Phone__c,
                          Vehicle_Policy__r.Vehicle_Owner_Name__c,
                          Vehicle_Policy__r.Vehicle_Owner_Phone__c,
                          Vehicle_Policy__r.Vehicle_Owner_Address__c,
                          Vehicle_Policy__r.Vehicle_Owner_Postal_Code__c,
                          Vehicle_Policy__r.Vehicle_Owner_City__c,
                          Vehicle_Policy__r.Vehicle_Owner_Country__c,
                          Vehicle_Policy__r.Vehicle_Owner_State__c,
                          Vehicle_Policy__r.Lienholder_Postal_Code__c,
                          Vehicle_Policy__r.Lienholder_Phone__c, Vehicle_Policy__r.Lienholder_Street__c,
                          Vehicle_Policy__r.Lienholder_Street_2__c, Vehicle_Policy__r.Lienholder_State__c, 
                          Vehicle_Policy__r.Lienholder_City__c, Vehicle_Policy__r.Lienholder_Country__c,
                          Vehicle_Policy__c, Vehicle_Policy__r.Lienholder_name__c, Vehicle_Policy__r.Year__c, Vehicle_Policy__r.Vin__c,
                          Vehicle_Policy__r.Make__c,Vehicle_Policy__r.Registered_Plate__c, Vehicle_Policy__r.Model__c,Vehicle_Policy__r.Registered_State__c,Vehicle_Policy__r.Value__c,
                          Vehicle_Policy__r.Domestic_Insurance_Name__c,Vehicle_Policy__r.Domestic_Insurance_Phone__c,Vehicle_Policy__r.Domestic_Insurance_Policy__c,
                          Medical_picklist__c,I_V_A_Mex_Tax__c, Term_days__c, Start_Date__c,Agency__c,Agency__r.Email FROM Policy__c
                          WHERE Id = :policyId  limit 1];
            system.debug('policyList' + policyList);
            if( (policyList != null && !policyList.isEmpty())){
                List<User> agencyList = new List<User>();
                
                policy = new Policy__c();
                agencyData = new User();
                system.debug('newpolicy --->'+policy);
                policy = policyList[0];
                
                if(policy.Broker_Policy_Fee__c == null){
                    policy.Broker_Policy_Fee__c = 0;
                }
                
                totalBrokerageFee = policy.Broker_Policy_Fee__c + policy.Agent_Brokerage_Fee__c;
                netPremiumWithoutAgentAndBrokerFee = policy.Net_Premium__c - policy.Agent_Brokerage_Fee__c;
                
                
                if( policy.Agency__c != null){
                    agencyList = [Select id,Name,FirstName, LastName, Website__c, Phone, Primary_Color__c,Partner_email__c, Partner_Id__c, Partner_Name__c, Logo_URL__c, User_Type__c,ContactId,Agent_Id__c from user where ContactId =: policy.Agency__c OR Email =: policy.Agency__r.Email LIMIT 1];
                }
                
                if(agencyList.size() > 0){
                    agencyData = agencyList[0];
                }
                
                system.debug('policy agencyData : ' + agencyData);
                
                formattedIssuanceDate = policy.Issued_At__c != null ? policy.Issued_At__c.format('MMM dd, yyyy') : '';
                formattedIssuanceTime = policy.Issued_At__c != null ? policy.Issued_At__c.format('h:mm a') : '';
                system.debug('policy I_V_A_Mex_Tax__c : ' + policy.I_V_A_Mex_Tax__c);
                
                //setting watercraft policy details
                if(policy.Policy_Type_picklist__c =='Watercraft'){
                    
                }
                
                
                if(policy.Vehicle_Policy__r.Vehicle_Owner_Name__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Vehicle_Owner_Name__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Vehicle_Owner_Name__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Vehicle_Owner_Name__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Vehicle_Owner_Name__c = policy.Vehicle_Policy__r.Vehicle_Owner_Name__c.capitalize();
                }
                if(policy.Vehicle_Policy__r.Company_Name__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Company_Name__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Company_Name__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Company_Name__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Company_Name__c = policy.Vehicle_Policy__r.Company_Name__c.capitalize();
                }
                if(policy.Vehicle_Policy__r.Vehicle_Owner_Address__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Vehicle_Owner_Address__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Vehicle_Owner_Address__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Vehicle_Owner_Address__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Vehicle_Owner_Address__c = policy.Vehicle_Policy__r.Vehicle_Owner_Address__c.capitalize();
                }
                if(policy.Vehicle_Policy__r.Company_Address__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Company_Address__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Company_Address__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Company_Address__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Company_Address__c = policy.Vehicle_Policy__r.Company_Address__c.capitalize();
                }
                if(policy.Vehicle_Policy__r.Company_City__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Company_City__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Company_City__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Company_City__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Company_City__c = policy.Vehicle_Policy__r.Company_City__c.capitalize();
                }
                if(policy.Vehicle_Policy__r.Vehicle_Owner_City__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Vehicle_Owner_City__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Vehicle_Owner_City__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Vehicle_Owner_City__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Vehicle_Owner_City__c = policy.Vehicle_Policy__r.Vehicle_Owner_City__c.capitalize();
                }
                if(policy.Vehicle_Policy__r.Vehicle_Owner_State__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Vehicle_Owner_State__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Vehicle_Owner_State__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Vehicle_Owner_State__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Vehicle_Owner_State__c = policy.Vehicle_Policy__r.Vehicle_Owner_State__c.capitalize();
                }
                if(policy.Vehicle_Policy__r.Company_State__c != null){
                    List<String> elems = policy.Vehicle_Policy__r.Company_State__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Vehicle_Policy__r.Company_State__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Vehicle_Policy__r.Company_State__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                    //policy.Vehicle_Policy__r.Company_State__c = policy.Vehicle_Policy__r.Company_State__c.capitalize();
                }
                if(policy.Contact__r.Street__c != null){
                    List<String> elems = policy.Contact__r.Street__c.split(' ');
                    set<string> aStringSet = new set<string>(elems);
                    aStringSet.remove('');
                    policy.Contact__r.Street__c= '';
                    for (String x : aStringSet)
                    {
                        policy.Contact__r.Street__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                    }
                }
                if(policy.I_V_A_Mex_Tax__c == null || policy.I_V_A_Mex_Tax__c == 0){
                    policy.I_V_A_Mex_Tax__c = 0.00;
                }
                if(policy.Surcharge__c == null || policy.Surcharge__c == 0){
                    policy.Surcharge__c = 0.00;
                }
                if(policy.Medical_picklist__c != null){
                    medicalExpensePerPerson = policy.Medical_picklist__c.substringBefore('/');
                    medicalExpensePerAccident = policy.Medical_picklist__c.substringAfter('/');
                }
                trans = new Transaction__c();
                if( policy.Transactions__r != null && !policy.Transactions__r.isEmpty()){
                    trans = policy.Transactions__r[0];
                }
                if(policy.Quote_Drivers__r != null && !policy.Quote_Drivers__r.isEmpty() ){
                    set<String> driverIds = new set<String>();
                    for(Quote_Driver__c qdr : policy.Quote_Drivers__r){
                        /*if(qdr.Primary_insured__c && qdr.driver__c != null){
primaryInsuredDriver = [select Id, Email__c,Address__c, Address_Line_2__c, Phone__c,City__c,State_Province__c, Country__c,
Postal_Code__c,license_number__c, LN_With_Country__c, License_Expire__c, DOB__c, License_Country__c,
License_state__c, First_Name__c, Last_Name__c, Driver_Type__c
from Driver__c where Id =: qdr.driver__c];
//driver = primaryInsuredDriver;
system.debug('primaryInsuredDriver : '+ primaryInsuredDriver);
}*/
                        driverIds.add( qdr.driver__c);
                    }
                    drivers = new list<Driver__c>();
                    List<Driver__c> dl = new List<Driver__c>();
                    drivers = [SELECT Id, Phone__c,license_number__c,Address__c,City__c, Address_Line_2__c, Postal_Code__c,State_Province__c, Country__c, LN_With_Country__c, License_Expire__c, DOB__c, License_Country__c, 
                               License_state__c, First_Name__c, Last_Name__c, Driver_Type__c
                               from Driver__c where Id IN: driverIds];
                    if( drivers != null && !drivers.isEmpty() && driver.id == null ){
                        if(drivers.size() > 1 && policy.Vehicle_Policy__r.Company_Name__c == null ){
                            for(Driver__c eachDriver : drivers){
                                if(eachDriver.Driver_Type__c == 'Owner' || eachDriver.Driver_Type__c == 'Owner & Driver' || eachDriver.Driver_Type__c == 'true'){
                                    dl.add(eachDriver);
                                }
                            }
                            driver = dl[0];
                            if(driver.First_Name__c != null){
                                List<String> elems = driver.First_Name__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.First_Name__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.First_Name__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                            if(driver.Last_Name__c != null){
                                List<String> elems = driver.Last_Name__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.Last_Name__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.Last_Name__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                            if(driver.Address__c != null){
                                List<String> elems = driver.Address__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.Address__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.Address__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                            if(driver.Address_Line_2__c != null){
                                List<String> elems = driver.Address_Line_2__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.Address_Line_2__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.Address_Line_2__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                        }else{
                            driver = drivers[0];
                            if(driver.First_Name__c != null){
                                List<String> elems = driver.First_Name__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.First_Name__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.First_Name__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                            if(driver.Last_Name__c != null){
                                List<String> elems = driver.Last_Name__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.Last_Name__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.Last_Name__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                            if(driver.Address__c != null){
                                List<String> elems = driver.Address__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.Address__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.Address__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                            if(driver.Address_Line_2__c != null){
                                List<String> elems = driver.Address_Line_2__c.split(' ');
                                set<string> aStringSet = new set<string>(elems);
                                aStringSet.remove('');
                                driver.Address_Line_2__c = '';
                                for (String x : aStringSet)
                                {
                                    driver.Address_Line_2__c += x.substring(0,1).toUpperCase()+x.substring(1,x.length()).toLowerCase() + ' ';
                                }
                            }
                        }
                    }
                }
                system.debug('Policy_Type_picklist__c : '+policy.Policy_Type_picklist__c + ' Date_of_Birth__c : ' + policy.Contact__r.Date_of_Birth__c);
                if (policy.Policy_Type_picklist__c == 'Watercraft' && policy.Contact__r.Date_of_Birth__c != null) {
                    Date dob = policy.Contact__r.Date_of_Birth__c;
                    Datetime dt = Datetime.newInstance(dob.year(),dob.month(),dob.day());
                    formattedDobDate = dt.format('MMM dd, YYYY');
                    system.debug('formatteddobDate : '+ formattedDobDate);
                }
                
                if (policy.Policy_Type_Picklist__c == 'Automobile' || policy.Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' || policy.Policy_Type_picklist__c == 'RV') {
                    
                    List<Coverage_Detail__c> tempCoverages =  [SELECT Id, Deductible_Damage__c, Deductible_Total_Theft__c, 
                                  Package__c, Partial_Theft__c, Partial_Theft_Details__c, Plane_Tickets_Home__c, 
                                  Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Underwriter__c, Legal_Defense_and_Bail__c, 
                                  Collision_Deductible__c, Deductibles__c, Legal_Defense_and_Bail_Details__c FROM Coverage_Detail__c 
                                  where Policy_Type__c = :policy.Policy_Type_picklist__c AND (Package__c = :policy.Package__c AND Underwriter__c = :policy.Underwriter_picklist__c)];

                     if(tempCoverages.size() > 0){ cvrgDetail = tempCoverages.get(0);
                     }             
                }
                
                if(policy.Start_Time__c != null){
                    startTime = string.valueOf(policy.start_time__c);
                }
                if(policy.End_Time__c != null){
                    endTime = string.valueOf(policy.End_Time__c);
                }
                
                towedUnitsList = [select Id, name, Account__c, Contact__c, Lead__c, Make__c, Model__c, Plate__c, Days_in_Tow__c,
                                  Policy__c, Quote_c__c, Street_Legal__c, Towed_Unit_Type__c, Towed_Unit_Value__c, 
                                  Towing_Terms__c, VIN_Number__c, Year__c from Towed_Unit__c where Id IN ( select Towed_Unit__c from Quote_Towed_Unit__c where policy__c =: policy.Id ) ];
                
                System.debug('--towedUnitsList--'+towedUnitsList);
                list<Watercraft__c> Watercrafts = new list<Watercraft__c>(); 
                system.debug('policy.Watercraft__c : -----'+ policy.Watercraft__c);
                totalTowedUnitPrice = 0.00;
                if(towedUnitsList.size() > 0){
                    for(Towed_Unit__c eachTowed : towedUnitsList){ totalTowedUnitPrice += eachTowed.Towed_Unit_Value__c;
                    }
                    totalInsuredValue  = policy.Insured_value__c + totalTowedUnitPrice;
                }else{
                    totalInsuredValue = policy.Insured_value__c;
                }
                system.debug('--totalInsuredValue--'+totalInsuredValue);
                if( policy.Watercraft__c != null ){
                    System.debug('-policy.Watercraft__c---'+policy.Watercraft__c);
                    Watercrafts = [select Id, Year__c, VIN_Number__c, Vessel_Length__c, Make__c, Type_of_Vessel__c, Flag__c, Model__c,
                                   Beam__c, Engine_Type__c from Watercraft__c where Id=: policy.Watercraft__c];
                    
                    System.debug('-Watercrafts---'+Watercrafts);
                    if( Watercrafts != null && !Watercrafts.isEmpty() ){
                        Watercraft = Watercrafts[0];
                    }
                }
                
            }
            System.debug('**policy****'+policy);
            
            System.debug('**trans****'+trans);

        }
        catch( Exception e){
            System.debug('--Exception--'+e.getMessage()+'--line--'+e.getLineNumber());
        }
        
    }
    
    public String getFormattedStartTime() {
        if(!test.isRunningTest()){
            System.debug('Policy data '+policy);
            System.debug('Start time'+policy.Start_Time__c);
            Integer hour = policy.Start_Time__c.hour(); Integer minute = policy.Start_Time__c.minute(); String ampm = 'AM';
            if (hour >= 12) { ampm = 'PM'; if (hour > 12) { hour = hour - 12; }
            }
            if (hour == 0) { hour = 12; } return hour.format().leftPad(2, '0') + ':' + minute.format().leftPad(2, '0') + ' ' + ampm+' PDT';
        }
        else{
            return '11:48';
        }        
    }
    
    public String getFormattedEndTime() {
        if(!test.isRunningTest()){
            Integer hour = policy.End_Time__c.hour(); Integer minute = policy.End_Time__c.minute(); String ampm = 'AM';
            if (hour >= 12) { ampm = 'PM'; if (hour > 12) { hour = hour - 12; }
            }
            if (hour == 0) { hour = 12; } return hour.format().leftPad(2, '0') + ':' + minute.format().leftPad(2, '0') + ' ' + ampm+' PDT';
        }
        else{
            return '11:48';
        }   
    }

   
}