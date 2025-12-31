@isTest
public class DriverLicenseTermOptionsControllerTest {
    @testsetup static void dataSupte(){
             
    }
 @isTest
    static void testMethodOne(){
        DriverLicenseTermOptionsController Drvl = new DriverLicenseTermOptionsController(); 
        DriverLicenseTermOptionsController.getPicklistValues('Driver__c','Driver_Type__c');
        DriverLicenseTermOptionsController.getDependentPicklistValues('Quote__c','Time_Zone__c');
    }
    @isTest
    static void testMethodTwo(){
         Quote__c quote1 = new Quote__c(
            Policy_Type_picklist__c = 'Driver License',
            Quote_Value__c = 130.50,
            Start_Date_for_Coverage__c = Date.today(),
            End_Date_for_Coverage__c = Date.today().addYears(1),
            I_V_A_Mex_Tax__c = 13.50,
            Broker_Policy_Fee__c = 50
            
        );
         insert quote1;
          DriverLicenseTermOptionsController.handleQuoteAction(quote1);
        
         Quote__c quote2 = new Quote__c(
            Policy_Type_picklist__c = 'Driver License',
            Quote_Value__c = 130.50,
            Start_Date_for_Coverage__c = Date.today(),
            End_Date_for_Coverage__c = Date.today().addDays(18),
            I_V_A_Mex_Tax__c = 13.50,
            Broker_Policy_Fee__c = 50
           
        );
         insert quote2;
          DriverLicenseTermOptionsController.handleQuoteAction(quote2);
        
         Quote__c quote3 = new Quote__c(
            Policy_Type_picklist__c = 'Driver License',
            Quote_Value__c = 130.50,
            Start_Date_for_Coverage__c = Date.today(),
            End_Date_for_Coverage__c = Date.today().addDays(60),
            I_V_A_Mex_Tax__c = 13.50,
            Broker_Policy_Fee__c = 50
            
        );
         insert quote3;
          DriverLicenseTermOptionsController.handleQuoteAction(quote3);
         Quote__c quote4 = new Quote__c(
            Policy_Type_picklist__c = 'Driver License',
            Quote_Value__c = 130.50,
            Start_Date_for_Coverage__c = Date.today(),
            End_Date_for_Coverage__c = Date.today().addDays(120),
            I_V_A_Mex_Tax__c = 13.50,
            Broker_Policy_Fee__c = 50
            
        );
         insert quote4;
          DriverLicenseTermOptionsController.handleQuoteAction(quote4);
    }
}