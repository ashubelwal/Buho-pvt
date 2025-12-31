@isTest
public class DeclarationPageInsuranceControllerTest {
    
 public static testMethod void Declaration_Page_Insurance_Controller(){ 
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        Watercraft__c watercraftrecord = new Watercraft__c();
        watercraftrecord.year__c = '2010';
        insert watercraftrecord;
        List <Driver__c> drive = new List <Driver__c>();
        for(integer i=0; i<2; i++){
            Driver__c drivers = new Driver__c ();
            if(i==0){
                drivers.Driver_Type__c = 'Owner';
            }else{
                drivers.Driver_Type__c = 'Driver';
            }            
            drivers.First_Name__c = 'test'+ i;
            drivers.Last_Name__c = 'test last'+ i;
            drivers.Address_Line_2__c = 'address line'+ i;
            drivers.Address__c = 'address line2'+ i;
            drive.add(drivers);
        }
        insert drive;
        /*Driver__c onlyDriver = new Driver__c();
        onlyDriver.Driver_Type__c = 'Driver';
        onlyDriver.First_Name__c = 'test Driver';
        onlyDriver.Last_Name__c = 'test Driver last';
        onlyDriver.Address_Line_2__c = 'Driver address line';
        onlyDriver.Address__c = 'Driver address line2';        
        insert onlyDriver;*/
        Account acc = new Account();
        acc.Name = 'testAccount';
        
        insert acc;
        
        Vehicle__c vehiclePolicy = new Vehicle__c();
        vehiclePolicy.Vehicle_Owner_Name__c = 'Test Owner';
        vehiclePolicy.Company_Name__c = 'Test company';
        vehiclePolicy.Vehicle_Owner_Address__c = 'Test address';
        vehiclePolicy.Company_Address__c = 'Test address';
        vehiclePolicy.Company_City__c = 'Test city';
        vehiclePolicy.Vehicle_Owner_City__c = 'Test city';
         vehiclePolicy.Vehicle_Owner_State__c = 'Test state';
         vehiclePolicy.Company_State__c = 'Test state';
        insert vehiclePolicy;
        
        Contact policyContact = new Contact();
        policyContact.FirstName = 'Test';
        policyContact.LastName = ' contact';
        policyContact.Street__c = 'Contact street';
        insert policyContact;
        
        Policy__c policyrecord=new policy__c();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        Time expected = Time.newInstance(4, 2, 3, 4);
        policyrecord.name='policy';
        policyrecord.Account_Policy__c = acc.Id;
        policyrecord.Policy_Type_picklist__c = 'Northbound';
        policyrecord.Start_Time__c =  myTime;
        policyrecord.End_Time__c =  expected;
        policyrecord.Watercraft__c = watercraftrecord.Id;
        policyRecord.Medical_picklist__c = '2,000/10,000';
        policyrecord.Vehicle_Policy__c = vehiclePolicy.Id;
        policyrecord.Contact__c = policyContact.Id;
        insert policyrecord;
        Quote__c quotes = new Quote__c ();
        date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
        insert quotes;
        
        
        List <Quote_Driver__c> quotedrive = new List <Quote_Driver__c>();
        for(integer i= 0; i<drive.size(); i++){
            Quote_Driver__c quotedriver = new Quote_Driver__c();
            quotedriver.Driver__c = drive[i].Id;
            quotedriver.Quote_c__c = quotes.id;
            quotedriver.Policy__c = policyrecord.id ;
            quotedrive.add(quotedriver);  
        }
        insert quotedrive;
        test.startTest();
        PageReference pgRef = Page.Southbound_PolicyDec_Chubb; 
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', policyrecord.Id);
        // System.currentPageReference().getParameters().put('params', 'CRLAL-22-DXQL4');
        Declaration_Page_Insurance_Controller controller = new Declaration_Page_Insurance_Controller() ; 
        test.stopTest();   
    }
    public static testMethod void getFormattedStartTime_Method(){
        test.startTest();
        PageReference pgRef = Page.Declaration_Page_Insurance; 
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', '00B1C000008UeA61');
        Declaration_Page_Insurance_Controller decl = new Declaration_Page_Insurance_Controller();
        decl.getFormattedStartTime();
        test.stopTest();  
    }
    public static testMethod void getFormattedEndTime_Method(){
        test.startTest();      
        Declaration_Page_Insurance_Controller decl = new Declaration_Page_Insurance_Controller();
        decl.getFormattedEndTime();
        test.stopTest();  
    }
    }