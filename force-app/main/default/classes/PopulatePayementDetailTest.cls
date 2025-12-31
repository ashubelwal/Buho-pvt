@isTest
public class PopulatePayementDetailTest {
	@isTest
    static void postiovemethod(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 1.2087;
        ratesTable.Risk_2_Total_Theft__c = 0.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 10000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 67;
        ratesTable.Semi_Annual_Total_Theft__c = 45;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 35;
        insert ratesTable;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+28;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
        quoteRecord.Vehicle_Value__c = 20000;
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '300,000';
        policyrecord.Medical_picklist__c = '5,000/25,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Liability';
        policyrecord.Term_days__c = 28;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        
        Test.startTest();
        PopulatePaymentDetail.calculateAndPopulateData();
        
        
        policyrecord.Term_days__c = 180;
        
        update policyrecord;
       // quoteRecord.End_Date_for_Coverage__c= system.today()+180;
       // update quoteRecord;
        PopulatePaymentDetail.calculateAndPopulateData();
        
        policyrecord.Term_days__c = 365;
        
        update policyrecord;
        
        quoteRecord.End_Date_for_Coverage__c= system.today()+365;
        update quoteRecord;
        PopulatePaymentDetail.calculateAndPopulateData();
       
        
        Test.stopTest(); 
        
    }
    
     @isTest
    static void postiovemethod11(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 1.2087;
        ratesTable.Risk_2_Total_Theft__c = 0.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 10000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 67;
        ratesTable.Semi_Annual_Total_Theft__c = 45;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 35;
        insert ratesTable;
        Test.startTest();
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+180;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
        quoteRecord.Vehicle_Value__c = 20000;
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '300,000';
        policyrecord.Medical_picklist__c = '5,000/25,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Liability';
        policyrecord.Term_days__c = 180;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        
        
        PopulatePaymentDetail.calculateAndPopulateData();
        
        quoteRecord.Is_there_a_driver_under_21__c = 'No';
        update quoteRecord;
        
        PopulatePaymentDetail.calculateAndPopulateData();        
        Test.stopTest();
    }
    
  @isTest
    static void postiovemethod12(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 00;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 85.2087;
        ratesTable.Risk_2_Total_Theft__c = 15.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 200000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 167;
        ratesTable.Semi_Annual_Total_Theft__c = 545;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 35;
        insert ratesTable;
       Test.startTest(); 
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+365;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
        quoteRecord.Vehicle_Value__c = 20000;
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '300,000';
        policyrecord.Medical_picklist__c = '5,000/25,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Liability';
        policyrecord.Term_days__c = 365;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        
        
        PopulatePaymentDetail.calculateAndPopulateData();
        
        quoteRecord.Is_there_a_driver_under_21__c = 'No';
        update quoteRecord;
        
        PopulatePaymentDetail.calculateAndPopulateData();        
        Test.stopTest();
    } 
    @isTest
    static void postiovemethod0(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 1.2087;
        ratesTable.Risk_2_Total_Theft__c = 0.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 10000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 67;
        ratesTable.Semi_Annual_Total_Theft__c = 45;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 35;
        insert ratesTable;
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+28;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
        quoteRecord.Vehicle_Value__c = 20000;
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '300,000';
        policyrecord.Medical_picklist__c = '5,000/25,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Liability';
        policyrecord.Term_days__c = 28;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        
        Test.startTest();
        PopulatePaymentDetail.calculateAndPopulateData();
       
        
        Test.stopTest(); 
        
    }
    
     @isTest
    static void postiovemethod111(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 1.2087;
        ratesTable.Risk_2_Total_Theft__c = 0.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 10000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 67;
        ratesTable.Semi_Annual_Total_Theft__c = 45;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 35;
        insert ratesTable;
        Test.startTest();
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+180;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'No';
        quoteRecord.Vehicle_Value__c = 20000;
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '300,000';
        policyrecord.Medical_picklist__c = '5,000/25,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Liability';
        policyrecord.Term_days__c = 180;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        
        
        PopulatePaymentDetail.calculateAndPopulateData();
        
        
        PopulatePaymentDetail.calculateAndPopulateData();        
        Test.stopTest();
    }
    
  @isTest
    static void postiovemethod121(){
          TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 00;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 85.2087;
        ratesTable.Risk_2_Total_Theft__c = 15.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 200000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 167;
        ratesTable.Semi_Annual_Total_Theft__c = 545;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 35;
        insert ratesTable;
       Test.startTest(); 
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+365;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'No';
        quoteRecord.Vehicle_Value__c = 20000;
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '300,000';
        policyrecord.Medical_picklist__c = '5,000/25,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Liability';
        policyrecord.Term_days__c = 365;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        
        
        PopulatePaymentDetail.calculateAndPopulateData();
        
        
        PopulatePaymentDetail.calculateAndPopulateData();        
        Test.stopTest();
    } 
    
    
    @isTest
    static void postiovemethod20(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 16;
        ratesTable.Risk_2_Total_Theft__c = 25;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 10000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 125;
        ratesTable.Semi_Annual_Total_Theft__c = 105;
        ratesTable.Annual_Rate__c = 2;
        ratesTable.Annual_Total_Theft__c = 5;
        insert ratesTable;
        
         
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+28;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'RAutomobileV';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
        quoteRecord.Vehicle_Value__c = 20000; 
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '500,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Complete';
        policyrecord.Term_days__c = 28;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        Test.startTest();
        PopulatePaymentDetail.calculateAndPopulateData();
        
        
        Test.stopTest();
        
    }
    
    
    @isTest
    static void postiovemethod2(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 1.2087;
        ratesTable.Risk_2_Total_Theft__c = 0.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 10000;
        ratesTable.Low_Value__c = 10000;
        ratesTable.Semi_Annual_Rate__c = 67;
        ratesTable.Semi_Annual_Total_Theft__c = 95;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 105;
        insert ratesTable;
        
         
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+365;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
        quoteRecord.Vehicle_Value__c = 200000; 
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '500,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Complete';
        policyrecord.Term_days__c = 365;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        Test.startTest();
        PopulatePaymentDetail.calculateAndPopulateData();
        
        
        Test.stopTest();
        
    }
    
    @isTest
    static void postiovemethod21(){
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = false;
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
        insert acObj;
        contact conObj =new contact();
        conObj.lastname='con';
        conObj.accountid=acObj.id;
        conObj.email='abc@gmail.com';
        insert conObj;
        
        
        Rate_Table__c ratesTable = new Rate_Table__c();
        ratesTable.Risk_1_Physical_Damages__c = 1.2087;
        ratesTable.Risk_2_Total_Theft__c = 0.5610;
        ratesTable.Underwriter__c = 'Chubb';
        ratesTable.type__c = 'Automobile';
        ratesTable.High_Value__c = 10000;
        ratesTable.Low_Value__c = 800000;
        ratesTable.Semi_Annual_Rate__c = 67;
        ratesTable.Semi_Annual_Total_Theft__c = 95;
        ratesTable.Annual_Rate__c = 89;
        ratesTable.Annual_Total_Theft__c = 105;
        insert ratesTable;
        
         
         List<Discount__c> discountList = new List<Discount__c>();
            for(Integer i=0 ; i < 4; i++){
                Discount__c discountObj = new Discount__c();
                if(i == 0){
                  discountObj.No_of_Days__c = 28;  
                }else if(i == 1){
                   discountObj.No_of_Days__c = 90; 
                }else if(i == 2){
                    discountObj.No_of_Days__c = 180; 
                }else{
                    discountObj.No_of_Days__c = 365; 
                }
                
                discountObj.Daily_Discount__c  = 0;
                discountList.add(discountObj);
            }
            
            insert discountList;
        
        
        
        Quote__c quoteRecord = new Quote__c();
        quoteRecord.Start_Date_for_Coverage__c= system.today();
        quoteRecord.End_Date_for_Coverage__c= system.today()+180;
        quoteRecord.Driver_Age__c = 80;
        quoteRecord.Lead__c = ldObj.Id;
        quoteRecord.contact__c = conObj.Id;
        quoteRecord.Account__c = acObj.Id;
        quoteRecord.Underwriter__c ='Chubb';
        quoteRecord.Coverage__c='Complete';
        quoteRecord.Territory__c='  Full';
        quoteRecord.Term__c='Daily';
        quoteRecord.Policy_Type_picklist__c='Automobile';
        quoteRecord.Vehicle_Type__c = 'Automobile';
        quoteRecord.Medical__c='20,000/100,000';
        quoteRecord.Liability__c='300,000'; 
        quoteRecord.Medical_Payment__c = 0;
        quoteRecord.Date_of_Birth__c = date.newinstance(1950,10,12);
        quoteRecord.Is_there_a_driver_under_21__c = 'Yes';
        quoteRecord.Vehicle_Value__c = 600000; 
        insert quoteRecord;
        
        Policy__c policyrecord = new policy__c();
        policyrecord.name='policy';
        policyrecord.Quote_c__c = quoteRecord.Id;
        policyrecord.contact__c = conObj.id;
        policyrecord.Policy_Type_picklist__c = 'Automobile';
        policyrecord.Liability_picklist__c = '500,000';
        policyrecord.Medical_picklist__c = '10,000/50,000';
        policyrecord.Underwriter_picklist__c = 'Chubb';
        policyrecord.Package__c = 'Complete';
        policyrecord.Term_days__c = 180;
        
        insert policyrecord;
        
        Towed_Unit__c towed= new Towed_Unit__c();
        towed.Street_Legal__c='No';
        towed.Quote_c__c = quoteRecord.Id;
        towed.Account__c = acObj.Id;
        towed.Days_in_Tow__c = 180;
        towed.Policy__c =policyrecord.Id;
        
        insert towed;
        
        
        Quote_Towed_Unit__c quoteTowedUnit = new Quote_Towed_Unit__c();
        quoteTowedUnit.Towed_Unit__c = towed.Id;
        quoteTowedUnit.Quote_c__c = quoteRecord.Id;
        
        insert quoteTowedUnit;
        
        Test.startTest();
        PopulatePaymentDetail.calculateAndPopulateData();
        
        Test.stopTest();
        
    }
}