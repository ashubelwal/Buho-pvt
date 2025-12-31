@isTest
public class WatercraftCalculationTest {
    @isTest
    public static void testMethodOne(){
        try{
            Quote__c quote = new Quote__c();
            
            quote.Vehicle_Type__c = 'Watercraft';
            quote.Vehicle_Year__c = '2010';
            quote.Vehicle_Make__c= 'Make';
            quote.Vehicle_Model__c= 'Model';
            quote.Vehicle_Value__c= 5000;
            quote.Coverage__c= 'Liability';
            quote.Term__c= 'Daily';
            quote.Term_Days__c= 365;
            quote.Quote_Value__c= 167.25;
            quote.Start_Date_for_Coverage__c= date.newInstance(2022, 01, 11);
            quote.End_Date_for_Coverage__c= date.newInstance(2022, 02, 09);
            quote.Underwriter__c= 'Chubb';
            quote.Policy_Type_picklist__c= 'Watercraft';
            quote.Liability__c= '200,000';
            quote.Driver_Age__c= 24;
            quote.Vehicle_Age__c= 22;
            quote.Trailering__c = false;
            quote.Net_Premium__c= 152.25;
            quote.Broker_Policy_Fee__c = 15;
            quote.I_V_A_Mex_Tax__c= 0;
            quote.Date_of_Birth__c=  date.newInstance(2000, 02, 09);
            quote.Is_this_a_Rental_Vehicle__c= false;
            quote.Vehicle_used_for_Business_Purposes__c = false;
            quote.Type_of_Vessel__c = 'Powerboat';
            quote.Is_the_Maximum_Speed_more_than_50_mph__c= 'No';
            quote.Is_the_owner_living_in_Mexico__c = 'No';
            quote.Any_Boat_Operator_Under_22__c = 'No';
            quote.Vessel_Length__c = 'Less than 27\' long';
            quote.Third_Party_Bodily_Injury__c = '$50,000 / $100,000';
            quote.Property_Damage_Liability__c = '$100,000';
            quote.Vehicle_Sub_type__c = 'Watercraft';
            quote.Surcharge__c = 0;
            quote.Is_the_Maximum_Speed_more_than_50_mph__c = 'Yes';
            quote.Any_Boat_Operator_Under_22__c = 'Yes';
            quote.Is_the_owner_living_in_Mexico__c = 'Yes';
            
            insert quote;
            
            
            
            
            Rate_Table__c  rateTable = new Rate_Table__c();
            rateTable.Total_Premium__c = 50;
            rateTable.Net_Premium__c = 40;
            rateTable.Broker_Policy_Fee__c = 20;
            rateTable.Package__c = 'Liability';
            rateTable.Type__c = 'Watercraft';
            rateTable.Days__c= 25;
            rateTable.Trailering_Surcharge__c = 50;
            rateTable.Term__c = 'Annual';
            rateTable.IVA_Mex_Tax__c = 0;
            rateTable.Underwriter__c = 'Chubb';
            rateTable.Age_of_Vehicle_Surcharge_25_years_old__c = 50;
            rateTable.Age_of_Vehicle_Surcharge__c = 50;
            rateTable.Age_of_Operator_Surcharge__c = 50;
            rateTable.Type_of_Vessel__c = 'Powerboat';
            rateTable.Vessel_Length__c = 'Less than 27\' long';
            rateTable.Third_Party_Bodily_Injury__c = '$50,000 / $100,000';
            rateTable.Property_Damage_Liability__c = '$100,000';
            
            insert rateTable;
            
            WatercraftCalculation.calculate(quote);
        }catch(Exception ex){
            system.debug('Message : '+ ex.getMessage() + ' At line number : '+ ex.getLineNumber());
        }
    }
}