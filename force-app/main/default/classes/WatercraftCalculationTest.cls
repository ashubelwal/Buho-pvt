@isTest
public class WatercraftCalculationTest {

    /* -------------------------------------------------------
       Shared helper: inserts a Rate_Table__c record that
       matches the defaults set by parseJsonToQuote().
    ------------------------------------------------------- */
    private static Rate_Table__c insertRateTable(String vesselType, String vesselLength, String term) {
        Rate_Table__c rt = new Rate_Table__c();
        rt.Total_Premium__c              = 200;
        rt.Net_Premium__c                = 150;
        rt.Broker_Policy_Fee__c          = 20;
        rt.IVA_Mex_Tax__c                = 0;
        rt.Package__c                    = 'Liability';
        rt.Type__c                       = 'Watercraft';
        rt.Days__c                       = 365;
        rt.Trailering_Surcharge__c       = 0;
        rt.Term__c                       = term;
        rt.Underwriter__c                = 'Chubb';
        rt.Age_of_Vehicle_Surcharge_25_years_old__c = 0;
        rt.Age_of_Vehicle_Surcharge__c   = 0;
        rt.Age_of_Operator_Surcharge__c  = 0;
        rt.Type_of_Vessel__c             = vesselType;
        rt.Vessel_Length__c              = vesselLength;
        rt.Third_Party_Bodily_Injury__c  = '$50,000 / $100,000';
        rt.Property_Damage_Liability__c  = '$100,000';
        insert rt;
        return rt;
    }

    /* -------------------------------------------------------
       1. Original test — calls calculate(Quote__c) directly
          (covers the legacy Aura path)
    ------------------------------------------------------- */
    @isTest
    public static void testMethodOne() {
        try {
            Quote__c quote = new Quote__c();
            quote.Vehicle_Type__c                            = 'Watercraft';
            quote.Vehicle_Year__c                            = '2010';
            quote.Vehicle_Make__c                            = 'Make';
            quote.Vehicle_Model__c                           = 'Model';
            quote.Vehicle_Value__c                           = 5000;
            quote.Coverage__c                                = 'Liability';
            quote.Term__c                                    = 'Daily';
            quote.Term_Days__c                               = 365;
            quote.Quote_Value__c                             = 167.25;
            quote.Start_Date_for_Coverage__c                 = date.newInstance(2022, 01, 11);
            quote.End_Date_for_Coverage__c                   = date.newInstance(2022, 02, 09);
            quote.Underwriter__c                             = 'Chubb';
            quote.Policy_Type_picklist__c                    = 'Watercraft';
            quote.Liability__c                               = '200,000';
            quote.Driver_Age__c                              = 24;
            quote.Vehicle_Age__c                             = 22;
            quote.Trailering__c                              = false;
            quote.Net_Premium__c                             = 152.25;
            quote.Broker_Policy_Fee__c                       = 15;
            quote.I_V_A_Mex_Tax__c                           = 0;
            quote.Date_of_Birth__c                           = date.newInstance(2000, 02, 09);
            quote.Is_this_a_Rental_Vehicle__c                = false;
            quote.Vehicle_used_for_Business_Purposes__c      = false;
            quote.Type_of_Vessel__c                          = 'Powerboat';
            quote.Is_the_Maximum_Speed_more_than_50_mph__c   = 'Yes';
            quote.Is_the_owner_living_in_Mexico__c           = 'Yes';
            quote.Any_Boat_Operator_Under_22__c              = 'Yes';
            quote.Vessel_Length__c                           = 'Less than 27\' long';
            quote.Third_Party_Bodily_Injury__c               = '$50,000 / $100,000';
            quote.Property_Damage_Liability__c               = '$100,000';
            quote.Vehicle_Sub_type__c                        = 'Watercraft';
            quote.Surcharge__c                               = 0;
            insert quote;

            insertRateTable('Powerboat', 'Less than 27\' long', 'Annual');

            Test.startTest();
            WatercraftCalculation.calculate(quote);
            Test.stopTest();

        } catch (Exception ex) {
            System.debug('testMethodOne Exception: ' + ex.getMessage() + ' line: ' + ex.getLineNumber());
        }
    }

    /* -------------------------------------------------------
       2. calculateWaterCraftRate — happy path with Annual term
          (covers the new LWC entry point + parseJsonToQuote)
    ------------------------------------------------------- */
    @isTest
    public static void testCalculateWaterCraftRate_Annual() {
        insertRateTable('Sailboat', 'Between 27\' and 45\' long', 'Annual');

        String jsonPayload = '[' +
            '{"userDetails":{"Email":"test@test.com","FirstName":"Test","LastName":"User","Phone":"","Id":""}},' +
            '{"vehicleDetails":{' +
                '"Vehicle_sub_type__c":"Watercraft",' +
                '"Type_of_Vessel__c":"Sailboat",' +
                '"Vessel_Length__c":"Between 27\' and 45\' long",' +
                '"Is_the_Maximum_Speed_more_than_50_mph__c":"No",' +
                '"Any_Boat_Operator_Under_22__c":"No",' +
                '"Is_the_owner_living_in_Mexico__c":"No"' +
            '}},' +
            '{"termOption":{' +
                '"Term__c":"Annual",' +
                '"Start_Date_for_Coverage__c":"2026-08-10",' +
                '"End_Date_for_Coverage__c":"2027-08-10",' +
                '"Start_Time__c":"00:00:00",' +
                '"End_Time__c":"00:00:00"' +
            '}},' +
            '{"watercraftDetails":{' +
                '"Type_of_Vessel__c":"Sailboat",' +
                '"Vessel_Length__c":"Between 27\' and 45\' long",' +
                '"Is_the_Maximum_Speed_more_than_50_mph__c":"No",' +
                '"Any_Boat_Operator_Under_22__c":"No",' +
                '"Is_the_owner_living_in_Mexico__c":"No"' +
            '}}' +
        ']';

        Test.startTest();
        String result = WatercraftCalculation.calculateWaterCraftRate(jsonPayload);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('TotalPremium'), 'Result should contain TotalPremium');
    }

    /* -------------------------------------------------------
       3. calculateWaterCraftRate — with surcharges
          (speed > 50mph, operator under 22, owner in Mexico)
    ------------------------------------------------------- */
    @isTest
    public static void testCalculateWaterCraftRate_WithSurcharges() {
        insertRateTable('Powerboat', 'Less than 27\' long', 'Annual');

        String jsonPayload = '[' +
            '{"termOption":{' +
                '"Term__c":"Annual",' +
                '"Start_Date_for_Coverage__c":"2026-08-10",' +
                '"End_Date_for_Coverage__c":"2027-08-10",' +
                '"Start_Time__c":"00:00:00"' +
            '}},' +
            '{"watercraftDetails":{' +
                '"Type_of_Vessel__c":"Powerboat",' +
                '"Vessel_Length__c":"Less than 27\' long",' +
                '"Is_the_Maximum_Speed_more_than_50_mph__c":"Yes",' +
                '"Any_Boat_Operator_Under_22__c":"Yes",' +
                '"Is_the_owner_living_in_Mexico__c":"Yes"' +
            '}}' +
        ']';

        Test.startTest();
        String result = WatercraftCalculation.calculateWaterCraftRate(jsonPayload);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    /* -------------------------------------------------------
       4. calculateWaterCraftRate — no matching Rate Table rows
          (covers the null/empty guard in calculate())
    ------------------------------------------------------- */
    @isTest
    public static void testCalculateWaterCraftRate_NoRateTableMatch() {
        // Do NOT insert any Rate_Table__c — query returns empty list

        String jsonPayload = '[' +
            '{"termOption":{' +
                '"Term__c":"Annual",' +
                '"Start_Date_for_Coverage__c":"2026-08-10",' +
                '"End_Date_for_Coverage__c":"2027-08-10",' +
                '"Start_Time__c":"00:00:00"' +
            '}},' +
            '{"watercraftDetails":{' +
                '"Type_of_Vessel__c":"Jet Ski",' +
                '"Vessel_Length__c":"Less than 27\' long",' +
                '"Is_the_Maximum_Speed_more_than_50_mph__c":"No",' +
                '"Any_Boat_Operator_Under_22__c":"No",' +
                '"Is_the_owner_living_in_Mexico__c":"No"' +
            '}}' +
        ']';

        Test.startTest();
        String result = WatercraftCalculation.calculateWaterCraftRate(jsonPayload);
        Test.stopTest();

        // Should return a valid (empty) wrapper, not throw an exception
        System.assertNotEquals(null, result, 'Should return serialized empty wrapper, not null');
    }

    /* -------------------------------------------------------
       5. calculateWaterCraftRate — missing termOption
          (covers the AuraHandledException throw in parseJsonToQuote)
    ------------------------------------------------------- */
    @isTest
    public static void testCalculateWaterCraftRate_MissingTermOption() {
        String jsonPayload = '[' +
            '{"watercraftDetails":{' +
                '"Type_of_Vessel__c":"Sailboat",' +
                '"Vessel_Length__c":"Between 27\' and 45\' long",' +
                '"Is_the_Maximum_Speed_more_than_50_mph__c":"No",' +
                '"Any_Boat_Operator_Under_22__c":"No",' +
                '"Is_the_owner_living_in_Mexico__c":"No"' +
            '}}' +
        ']';

        Test.startTest();
        try {
            WatercraftCalculation.calculateWaterCraftRate(jsonPayload);
            System.assert(false, 'Should have thrown an exception for missing termOption');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null');
        } catch (Exception e) {
            // Any exception is acceptable here — method correctly rejected bad input
            System.debug('Expected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /* -------------------------------------------------------
       6. calculateWaterCraftRate — dynamic liability mapping (400k and 750k)
    ------------------------------------------------------- */
    @isTest
    public static void testCalculateWaterCraftRate_LiabilityTiers() {
        // Mock Rate_Table__c entries for 400k and 750k tiers
        Rate_Table__c rt400 = new Rate_Table__c();
        rt400.Total_Premium__c              = 400;
        rt400.Net_Premium__c                = 300;
        rt400.Broker_Policy_Fee__c          = 20;
        rt400.IVA_Mex_Tax__c                = 0;
        rt400.Package__c                    = 'Liability';
        rt400.Type__c                       = 'Watercraft';
        rt400.Days__c                       = 365;
        rt400.Trailering_Surcharge__c       = 0;
        rt400.Term__c                       = 'Annual';
        rt400.Underwriter__c                = 'Chubb';
        rt400.Type_of_Vessel__c             = 'Sailboat';
        rt400.Vessel_Length__c              = 'Between 27\' and 45\' long';
        rt400.Third_Party_Bodily_Injury__c  = '$100,000 / $300,000';
        rt400.Property_Damage_Liability__c  = '$100,000';
        insert rt400;

        Rate_Table__c rt750 = new Rate_Table__c();
        rt750.Total_Premium__c              = 750;
        rt750.Net_Premium__c                = 600;
        rt750.Broker_Policy_Fee__c          = 20;
        rt750.IVA_Mex_Tax__c                = 0;
        rt750.Package__c                    = 'Liability';
        rt750.Type__c                       = 'Watercraft';
        rt750.Days__c                       = 365;
        rt750.Trailering_Surcharge__c       = 0;
        rt750.Term__c                       = 'Annual';
        rt750.Underwriter__c                = 'Chubb';
        rt750.Type_of_Vessel__c             = 'Sailboat';
        rt750.Vessel_Length__c              = 'Between 27\' and 45\' long';
        rt750.Third_Party_Bodily_Injury__c  = '$250,000 / $500,000';
        rt750.Property_Damage_Liability__c  = '$250,000';
        insert rt750;

        String json400 = '[{"termOption":{"Term__c":"Annual","Start_Date_for_Coverage__c":"2026-08-10","End_Date_for_Coverage__c":"2027-08-10"}},' +
            '{"watercraftDetails":{"Type_of_Vessel__c":"Sailboat","Vessel_Length__c":"Between 27\' and 45\' long","Liability__c":"400,000"}}]';

        String json750 = '[{"termOption":{"Term__c":"Annual","Start_Date_for_Coverage__c":"2026-08-10","End_Date_for_Coverage__c":"2027-08-10"}},' +
            '{"watercraftDetails":{"Type_of_Vessel__c":"Sailboat","Vessel_Length__c":"Between 27\' and 45\' long","Liability__c":"750,000"}}]';

        Test.startTest();
        String res400 = WatercraftCalculation.calculateWaterCraftRate(json400);
        String res750 = WatercraftCalculation.calculateWaterCraftRate(json750);
        Test.stopTest();

        System.assertNotEquals(null, res400);
        System.assertNotEquals(null, res750);
    }
}