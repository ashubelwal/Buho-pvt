public without sharing class WatercraftCalculation {
  /* =========================================================
       LWC ENTRY POINT — called from nc_quotePage.js via:
       import calculateWaterCraftRate from '@salesforce/apex/WatercraftCalculation.calculateWaterCraftRate';
       ========================================================= */
  @AuraEnabled
  public static String calculateWaterCraftRate(String jsonString) {
    try {
      System.debug('WatercraftCalculation.calculateWaterCraftRate JSON INPUT ==> ' + jsonString);

      Quote__c quoteObj = parseJsonToQuote(jsonString);
      WatercraftCalculationWrapper result = calculate(quoteObj);

      return JSON.serialize(result);
    } catch (exception ex) {
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /* =========================================================
       JSON PARSING — converts LWC payload array to Quote__c
       ========================================================= */
  private static Quote__c parseJsonToQuote(String jsonBody) {
    List<Object> jsonList = (List<Object>) JSON.deserializeUntyped(jsonBody);

    TermOptionWrapper termOption;
    Map<String, Object> watercraftDetails;

    System.debug('WatercraftCalculation.parseJsonToQuote jsonList => ' + jsonList);

    for (Object obj : jsonList) {
      Map<String, Object> section = (Map<String, Object>) obj;

      if (section.containsKey('termOption')) {
        Map<String, Object> termMap = (Map<String, Object>) section.get('termOption');
        termOption = new TermOptionWrapper();
        termOption.term = (String) termMap.get('Term__c');
        termOption.startDate = (String) termMap.get('Start_Date_for_Coverage__c');
        termOption.endDate = (String) termMap.get('End_Date_for_Coverage__c');
        termOption.startTime = (String) termMap.get('Start_Time__c');
      }

      if (section.containsKey('watercraftDetails')) {
        watercraftDetails = (Map<String, Object>) section.get('watercraftDetails');
      }
    }

    if (termOption == null) {
      throw new AuraHandledException('Term Option missing in JSON payload');
    }

    Quote__c quoteObj = new Quote__c();

    /* ===== TERM DATA ===== */
    quoteObj.Term__c = termOption.term;
    quoteObj.Start_Date_for_Coverage__c = Date.valueOf(termOption.startDate);
    quoteObj.End_Date_for_Coverage__c = Date.valueOf(termOption.endDate);

    /* ===== WATERCRAFT DATA ===== */
    System.debug(
      'WatercraftCalculation.parseJsonToQuote watercraftDetails => ' + watercraftDetails
    );
    if (watercraftDetails != null) {
      quoteObj.Type_of_Vessel__c = (String) watercraftDetails.get('Type_of_Vessel__c');
      quoteObj.Vessel_Length__c = (String) watercraftDetails.get('Vessel_Length__c');
      quoteObj.Is_the_Maximum_Speed_more_than_50_mph__c = (String) watercraftDetails.get(
        'Is_the_Maximum_Speed_more_than_50_mph__c'
      );
      quoteObj.Any_Boat_Operator_Under_22__c = (String) watercraftDetails.get(
        'Any_Boat_Operator_Under_22__c'
      );
      quoteObj.Is_the_owner_living_in_Mexico__c = (String) watercraftDetails.get(
        'Is_the_owner_living_in_Mexico__c'
      );

      // Dynamically map Liability__c to Third_Party_Bodily_Injury__c and Property_Damage_Liability__c
      String liability = (String) watercraftDetails.get('Liability__c');
      if (liability == '400,000') {
          quoteObj.Third_Party_Bodily_Injury__c = '$100,000 / $300,000';
          quoteObj.Property_Damage_Liability__c = '$100,000';
      } else if (liability == '750,000') {
          quoteObj.Third_Party_Bodily_Injury__c = '$250,000 / $500,000';
          quoteObj.Property_Damage_Liability__c = '$250,000';
      } else {
          quoteObj.Third_Party_Bodily_Injury__c = '$50,000 / $100,000';
          quoteObj.Property_Damage_Liability__c = '$100,000';
      }
      quoteObj.Policy_Type_picklist__c = 'Watercraft';
      quoteObj.Underwriter__c = 'Chubb';
    }

    return quoteObj;
  }

  /* =========================================================
       RATE CALCULATION
       Used by both LWC (via calculateWaterCraftRate) and legacy
       Aura components (called directly with a Quote__c object).
       ========================================================= */
  public static WatercraftCalculationWrapper calculate(Quote__c quoteObject) {
    List<Rate_Table__c> rateTables = getDataFromDataTable(quoteObject);

    WatercraftCalculationWrapper calculationWrapper = new WatercraftCalculationWrapper();
    Integer differenceInDays = quoteObject.Start_Date_for_Coverage__c.daysBetween(
      quoteObject.End_Date_for_Coverage__c
    );
    calculationWrapper.days = differenceInDays;

    // Null-safe guard: if no matching Rate Table rows found, return empty wrapper
    if (rateTables == null || rateTables.isEmpty()) {
      System.debug(
        'WatercraftCalculation.calculate: No Rate Table rows found. Returning empty wrapper.'
      );
      return calculationWrapper;
    }

    for (Rate_Table__c rateTable : rateTables) {
      Decimal Net_Premium = (rateTable.Net_Premium__c != null ? rateTable.Net_Premium__c : 0);
      Decimal Broker_Policy_Fee = (rateTable.Broker_Policy_Fee__c != null
        ? rateTable.Broker_Policy_Fee__c
        : 0);
      Decimal IVA_Mex_Tax = (rateTable.IVA_Mex_Tax__c != null ? rateTable.IVA_Mex_Tax__c : 0);

      String Term = (rateTable.Term__c != null ? rateTable.Term__c : null);

      Decimal Liability_Limit_Selection = Net_Premium;

      if (Term == 'Daily') {
        Liability_Limit_Selection = Liability_Limit_Selection * differenceInDays;
      }

      Decimal Surcharge = 0;
      Decimal Total_Premium = Liability_Limit_Selection;

      if (quoteObject.Is_the_Maximum_Speed_more_than_50_mph__c == 'Yes') {
        Surcharge += (Liability_Limit_Selection * 0.5);
      }
      if (quoteObject.Any_Boat_Operator_Under_22__c == 'Yes') {
        Surcharge += (Liability_Limit_Selection * 2);
      }
      if (quoteObject.Is_the_owner_living_in_Mexico__c == 'Yes') {
        Surcharge += (Liability_Limit_Selection * 0.5);
      }

      Total_Premium = Total_Premium + Broker_Policy_Fee + IVA_Mex_Tax + Surcharge;

      if (
        calculationWrapper.Data.RateResult.TotalPremium == null ||
        Total_Premium < calculationWrapper.Data.RateResult.TotalPremium
      ) {
        calculationWrapper.Data.QuoteResult.Quote_Value__c = Net_Premium;
        calculationWrapper.Data.QuoteResult.Net_Premium__c = Net_Premium;
        calculationWrapper.Data.QuoteResult.I_V_A_Mex_Tax__c = IVA_Mex_Tax;
        calculationWrapper.Data.QuoteResult.Broker_Policy_Fee__c = Broker_Policy_Fee;

        if (Term == 'Annual' && quoteObject.Term__c == 'Daily') {
          Date startDate = quoteObject.Start_Date_for_Coverage__c;
          Date endDate = startDate.addYears(1);

          calculationWrapper.Data.QuoteResult.Start_Date_for_Coverage__c = startDate;
          calculationWrapper.Data.QuoteResult.End_Date_for_Coverage__c = endDate;
          calculationWrapper.Data.QuoteResult.Term__c = 'Annual(One Year)';
          calculationWrapper.Data.QuoteResult.Term_Days__c = 365;
        }

        calculationWrapper.Data.RateResult.NetPremium = Net_Premium;
        calculationWrapper.Data.RateResult.IVAMexTax = IVA_Mex_Tax;
        calculationWrapper.Data.RateResult.Surcharge = Surcharge;
        calculationWrapper.Data.RateResult.BrokerPolicyFee = Broker_Policy_Fee;
        calculationWrapper.Data.RateResult.LiabilityLimitSelection = Liability_Limit_Selection;
        calculationWrapper.Data.RateResult.TotalPremium = Total_Premium;
        calculationWrapper.Data.RateResult.RateValue = Total_Premium;
        calculationWrapper.Data.RateResult.Term = Term;
        calculationWrapper.Data.RateResult.Underwriter = rateTable.Underwriter__c;
      }
    }

    return calculationWrapper;
  }

  /* =========================================================
       RATE TABLE QUERY
       ========================================================= */
  private static List<Rate_Table__c> getDataFromDataTable(Quote__c quoteObject) {
    try {
      List<Rate_Table__c> rateTables = new List<Rate_Table__c>();

      String rateQuery = 'select id, Total_Premium__c, Net_Premium__c, Broker_Policy_Fee__c, Package__c, Type__c, Days__c, Trailering_Surcharge__c, Term__c,';
      rateQuery += ' IVA_Mex_Tax__c, Underwriter__c, Age_of_Vehicle_Surcharge_25_years_old__c, Age_of_Vehicle_Surcharge__c, Age_of_Operator_Surcharge__c ';
      rateQuery += ' from Rate_Table__c ';
      rateQuery += ' where Type_of_Vessel__c = \'' + quoteObject.Type_of_Vessel__c + '\'';
      rateQuery +=
        ' and Vessel_Length__c = \'' +
        String.escapeSingleQuotes(quoteObject.Vessel_Length__c) +
        '\'';
      rateQuery +=
        ' and Third_Party_Bodily_Injury__c = \'' +
        quoteObject.Third_Party_Bodily_Injury__c +
        '\' and Property_Damage_Liability__c = \'' +
        quoteObject.Property_Damage_Liability__c +
        '\'';
      rateQuery +=
        ' and Underwriter__c = \'' +
        quoteObject.Underwriter__c +
        '\' and Type__c = \'' +
        quoteObject.Policy_Type_picklist__c +
        '\'';

      System.debug('WatercraftCalculation.getDataFromDataTable rateQuery => ' + rateQuery);
      rateTables = Database.query(rateQuery);

      System.debug('WatercraftCalculation.getDataFromDataTable rateTables => ' + rateTables);
      if (rateTables != null && !rateTables.isEmpty()) {
        return rateTables;
      }
      return null;
    } catch (Exception e) {
      System.debug('WatercraftCalculation.getDataFromDataTable Exception => ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /* =========================================================
       WRAPPERS
       All fields are 'public' so JSON.serialize() includes them
       in the response sent back to the LWC.
       ========================================================= */
  public class TermOptionWrapper {
    public String term;
    public String startDate;
    public String endDate;
    public String startTime;
  }

  public class WatercraftCalculationWrapper {
    public WatercraftData Data;
    public Integer days;

    public WatercraftCalculationWrapper() {
      Data = new WatercraftData();
    }
  }

  public class WatercraftData {
    public Quote__c QuoteResult;
    public RateResult RateResult;

    public WatercraftData() {
      QuoteResult = new Quote__c();
      RateResult = new RateResult();
    }
  }

  public class RateResult {
    public Decimal NetPremium;
    public Decimal BrokerPolicyFee;
    public Decimal IVAMexTax;
    public Decimal LiabilityLimitSelection;
    public Decimal Surcharge;
    public Decimal TotalPremium;
    public Decimal RateValue;
    public String Term;
    public String Underwriter;
  }
}
