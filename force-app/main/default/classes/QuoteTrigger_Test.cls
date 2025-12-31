@isTest
public class QuoteTrigger_Test {
    @isTest
    public static void validateQuoteTrigger(){
        //Create custom setting record for mapping Quote field to Lead field
        QuoteToLeadMapping__c objQuoteToLeadMapping1 = new QuoteToLeadMapping__c();
        objQuoteToLeadMapping1.Name = 'Quote Value';
        objQuoteToLeadMapping1.Lead_API__c='Quote_Value__c';
        objQuoteToLeadMapping1.Quote_API__c='Quote_Value__c';
        insert objQuoteToLeadMapping1;
        
        //Create Lead record
        Lead objLead = new Lead();
        objLead.LastName = 'Test Name';
        objLead.Company = 'Test Company';
        insert objLead;
        
        Test.startTest();
        //Create Quote record
        Quote__c objQuote = new Quote__c();
        objQuote.Lead__c = objLead.Id;
        objQuote.Quote_Value__c = 1122;
        objQuote.Vehicle_Value__c = 6699;
        objQuote.Vehicle_Type__c = 'Mototrcycle';
        insert objQuote;
        
        //Update Quote record fields
        objQuote.Quote_Value__c = 1122;
        objQuote.Vehicle_Value__c = 6699;
        objQuote.Vehicle_Type__c = 'Mototrcycle';
        update objQuote;
        
        //Create Quote record
        Quote__c objQuote2 = new Quote__c();
        objQuote2.Lead__c = objLead.Id;
        objQuote2.Quote_Value__c = 1122;
        objQuote2.Vehicle_Value__c = 6699;
        objQuote2.Vehicle_Type__c = 'Mototrcycle';
        insert objQuote2;
        
        delete objQuote;
        undelete objQuote;
        
        delete objQuote2;
        undelete objQuote2;
        Test.stopTest();
    }

}