public without sharing class Mex_QuickQuoteCommonController {
    @AuraEnabled
    public static String getWatercraftQuote(String requestBody, Boolean annualTerm) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (requestBody == null || String.isEmpty(requestBody)) {
                responseMap.put('statusCode', '400');
                responseMap.put('message', 'Request body can\'t be empty');
                return JSON.serialize(responseMap);
            }
            
            QuoteRecordWrapper quoteObject = (QuoteRecordWrapper) JSON.deserialize(requestBody.replaceAll('__c', '_Tempc'), QuoteRecordWrapper.class);
            List<Rate_Table__c> rateTables = new List<Rate_Table__c>();
            String term = null;
            if (annualTerm) {
                term = 'Annual';
            } else {
                term = 'Daily';
            }
            
            Integer days = 0;
            if (quoteObject != null && quoteObject.Start_Date_for_Coverage != null && quoteObject.End_Date_for_Coverage != null) {
                Date startDate = Date.valueOf(quoteObject.Start_Date_for_Coverage);
                Date endDate = Date.valueOf(quoteObject.End_Date_for_Coverage);
                days = startDate.daysBetween(endDate);
            }

            String rateQuery = 'select id, Total_Premium__c, Net_Premium__c, Broker_Policy_Fee__c, Package__c, Type__c, Days__c, Trailering_Surcharge__c, Term__c,';
            rateQuery += ' IVA_Mex_Tax__c, Underwriter__c, Age_of_Vehicle_Surcharge_25_years_old__c, Age_of_Vehicle_Surcharge__c, Age_of_Operator_Surcharge__c ';
            rateQuery += ' from Rate_Table__c ';
            rateQuery += ' where Type_of_Vessel__c = \'' + quoteObject.Type_of_Vessel_Tempc + '\'';
            rateQuery += ' and Vessel_Length__c = \'' + String.escapeSingleQuotes(quoteObject.Vessel_Length_Tempc) + '\'';
            rateQuery += ' and Third_Party_Bodily_Injury__c = \'' + quoteObject.Third_Party_Bodily_Injury_Tempc + '\' and Property_Damage_Liability__c = \'' + quoteObject.Property_Damage_Liability_Tempc + '\'';
            rateQuery += ' and Underwriter__c = \'' + 'Chubb' + '\' and Type__c = \'' + quoteObject.Policy_Type_picklist + '\'';
            if(quoteObject.Towed_Unit_Tempc == 'Yes'){
                rateQuery += ' ORDER BY Term__c Desc';
            }else{
                rateQuery += ' ORDER BY Term__c ASC';
            }
            
            rateTables = Database.query(rateQuery);

            if (rateTables != null && !rateTables.isEmpty()) {

                Decimal annualQuoteRate = 0.00;
                Decimal dailyQuoteRate = 0.00;
                
                Decimal finalTotalPremium = 0.00;
                Map<String, Object> rateRecord = new Map<String, Object>();
                
                for(Rate_Table__c each: rateTables){
                    
                    Decimal Net_Premium = each.Net_Premium__c;
                    Decimal Broker_Policy_Fee = (each.Broker_Policy_Fee__c != null ? each.Broker_Policy_Fee__c : 0);
                    Decimal IVA_Mex_Tax = (each.IVA_Mex_Tax__c != null ? each.IVA_Mex_Tax__c : 0);
                    
                    if(each.term__c == 'Daily'){
                        Net_Premium = Net_Premium * days;
                    }
                    Decimal surcharge = 0.00;
                    if (quoteObject.Is_the_Maximum_Speed_more_than_50_mph_Tempc == 'Yes') {
                        surcharge += (Net_Premium * 0.5);
                    }
                    if (quoteObject.Any_Boat_Operator_Under_22_Tempc == 'Yes') {
                        surcharge += (Net_Premium * 2);
                    }
                    if (quoteObject.Is_the_owner_living_in_Mexico_Tempc == 'Yes') {
                        surcharge += (Net_Premium * 0.5);
                    }
                    
                    Decimal totalPremium = Net_Premium + surcharge + Broker_Policy_Fee + IVA_Mex_Tax;

                    if(finalTotalPremium == 0.00 || totalPremium < finalTotalPremium){
                        finalTotalPremium = totalPremium;

                        rateRecord.put('Underwriter__c', each.Underwriter__c);
                        rateRecord.put('Quote_Value__c', totalPremium);
                        rateRecord.put('Net_Premium__c', Net_Premium);
                        rateRecord.put('Surcharge__c', surcharge);
                        rateRecord.put('I_V_A_Mex_Tax__c', IVA_Mex_Tax);
                        rateRecord.put('Broker_Policy_Fee__c', Broker_Policy_Fee);
                        rateRecord.put('Term__c', each.Term__c);
                        if(each.Term__c == 'Annual'){
                            rateRecord.put('Day__c', 365);   
                        }else{
                            rateRecord.put('Day__c', days);
                        }
                    }
                }

                responseMap.put('statusCode', '200');
                responseMap.put('rateTables', rateTables);
                responseMap.put('rateRecord', rateRecord);
                return JSON.serialize(responseMap);
            }
            return null;
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getNorthboundQuote (String requestBody, String liability) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            if (requestBody == null || String.isEmpty(requestBody)) {
                responseMap.put('statusCode', '400');
                responseMap.put('message', 'Request body can\'t be empty');
                return JSON.serialize(responseMap);
            }
            QuoteRecordWrapper quoteData = (QuoteRecordWrapper) JSON.deserialize(requestBody.replaceAll('__c', '_Tempc'), QuoteRecordWrapper.class);
            List<Rate_Table__c> rateTables = new List<Rate_Table__c>();
            Integer days = 0;
            if (quoteData != null && quoteData.Start_Date_for_Coverage != null && quoteData.End_Date_for_Coverage != null) {
                Date startDate = Date.valueOf(quoteData.Start_Date_for_Coverage);
                Date endDate = Date.valueOf(quoteData.End_Date_for_Coverage);
                days = startDate.daysBetween(endDate);
            }
            
            if(liability != null && liability == '50000'){
                liability = '50,000';
            }else if(liability != null && liability == '70000'){
                liability = '70,000';
            }else if(liability != null && liability == '100000'){
                liability = '100,000';
            }else if(liability != null && liability == '150000'){
                liability = '150,000';
            }else if(liability != null && liability == '200000'){
                liability = '200,000';
            }else if(liability != null && liability == '300000'){
                liability = '300,000';
            }else if(liability != null && liability == '500000'){
                liability = '500,000';
            }
            
            String term = null;
            if (days != null && days <= 30) {
                term = 'Daily';
            } else if (days != null && days > 30 && days <= 90) {
                term = '90 Days';
            } else if (days != null && days > 90 && days <= 180) {
                term = 'Semi-Annual';
            } else if (days != null && days > 180) {
                term = 'Annual';
            }
            
            String rateQuery = 'select id, Total_Premium__c, Net_Premium__c, Broker_Policy_Fee__c, Package__c, Type__c, Days__c, Trailering_Surcharge__c, Term__c,';
            rateQuery += ' IVA_Mex_Tax__c, Underwriter__c, Age_of_Vehicle_Surcharge_25_years_old__c, Age_of_Vehicle_Surcharge__c, Age_of_Operator_Surcharge__c ';
            rateQuery += ' from Rate_Table__c ';
            if (quoteData.Policy_Type_picklist == 'Automobile' || quoteData.Policy_Type_picklist == 'Northbound') { //
                rateQuery += ' where Risk_3_Third_Party_Liability_Insured_Sum__c = \'' + liability + '\'';
                if (days != null && days <= 30) {
                    rateQuery += ' and Days__c = ' + days;
                } else if (days != null && days > 30) {
                    rateQuery += ' and Term__c = \'' + term + '\'';
                }
                String queryParam1= (quoteData.Policy_Type_picklist == 'Automobile')?'Northbound':quoteData.Policy_Type_picklist;
                
                rateQuery += ' and Underwriter__c = \'Chubb\' and Direction__c = \''+queryParam1+'\'';
            }
            rateTables = Database.query(rateQuery);
            System.debug('test--->   '+rateTables);
            
            responseMap.put('days', String.valueOf(days));
            responseMap.put('status', 'success');
            if (!rateTables.isEmpty()) {
                Rate_Table__c rt = rateTables[0];
                Decimal Net_Premium = rt.Net_Premium__c != null ? rt.Net_Premium__c : 0;
                Decimal Broker_Policy_Fee = rt.Broker_Policy_Fee__c != null ? rt.Broker_Policy_Fee__c : 0;
                Decimal IVA_Mex_Tax = rt.IVA_Mex_Tax__c != null ? rt.IVA_Mex_Tax__c : 0;
                responseMap.put('Policy_Fee', String.valueOf(Broker_Policy_Fee));
                responseMap.put('iva', String.valueOf(IVA_Mex_Tax));
                Decimal Vehicle_Age_20 = rt.Age_of_Vehicle_Surcharge__c != null ? rt.Age_of_Vehicle_Surcharge__c : 0;
                Decimal Vehicle_Age_25 = rt.Age_of_Vehicle_Surcharge_25_years_old__c != null ? rt.Age_of_Vehicle_Surcharge_25_years_old__c : 0;
                Decimal operator_Charge = rt.Age_of_Operator_Surcharge__c != null ? rt.Age_of_Operator_Surcharge__c : 0;
                Decimal towing_Charge = rt.Trailering_Surcharge__c != null ? rt.Trailering_Surcharge__c : 0;
                Decimal surcharge = 0;
                Decimal Total_Premium = Net_Premium;
                if (String.isNotEmpty(quoteData.vehicle_Age)) {
                    if (Integer.valueOf(quoteData.vehicle_Age) > 30 && Integer.valueOf(quoteData.vehicle_Age) <= 35) {
                        surcharge += Net_Premium * (Vehicle_Age_20 / 100);
                    } else if (Integer.valueOf(quoteData.vehicle_Age) > 35) {
                        surcharge += Net_Premium * (Vehicle_Age_25 / 100);
                    }
                }
                
                if (quoteData.Policy_Type_picklist == 'Automobile' || quoteData.Policy_Type_picklist == 'Northbound') {//
                    if (String.isNotEmpty(quoteData.driver_Age)) {
                        if( Integer.valueOf(quoteData.driver_Age) >= 16 && Integer.valueOf(quoteData.driver_Age) <= 18 ){
                            surcharge += Net_Premium;
                        }else if( Integer.valueOf(quoteData.driver_Age) >= 19 && Integer.valueOf(quoteData.driver_Age) <= 21 ){
                            surcharge += (Net_Premium * 0.5);
                        }else if( Integer.valueOf(quoteData.driver_Age) >= 75 && Integer.valueOf(quoteData.driver_Age) <= 79 ){
                            surcharge += (Net_Premium * 0.5);
                        }else if( Integer.valueOf(quoteData.driver_Age) >= 80 && Integer.valueOf(quoteData.driver_Age) <= 84 ){
                            surcharge += Net_Premium;
                        }
                    }
                    
                    if (quoteData.Is_Towing != null && quoteData.Is_Towing == 'Yes') {
                        surcharge += (Net_Premium * (towing_Charge / 100));
                    }
                }

                Total_Premium = Total_Premium + Broker_Policy_Fee + IVA_Mex_Tax + surcharge;
                responseMap.put('rateValue', String.valueOf(Total_Premium));
                Decimal tempNetPremium = (Total_Premium - (Broker_Policy_Fee + surcharge));
                responseMap.put('net_premium', String.valueOf(tempNetPremium));
                responseMap.put('surcharge', surcharge);
            }
        } catch (Exception ex) {
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
            return 'Exception: '+ex.getMessage() + ' at line: '+ex.getLineNumber();
        }
        return JSON.serialize(responseMap);
    }
    
    @AuraEnabled
    public static List<Coverage_Detail__c> getNorthboundCoverage() {
        List<Coverage_Detail__c> Coverage_Details = new List<Coverage_Detail__c>();
        try {
            String query = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c,';
            query += 'IsDeleted, Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query += 'Roadside_Details__c, SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, ';
            query += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c, Total_Theft_Deductible__c';
            query += ' FROM Coverage_Detail__c where Underwriter__c = \'Chubb\' and Policy_Type__c =  \'Northbound\' limit 1';
            
            Coverage_Details = Database.query(query);
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
        }
        return Coverage_Details;
    }
    
    @AuraEnabled
    public static String getQuote(String requestBody, String qualitasLiability, String chubbLiability, String mapfreLiability, String qualitasMedical, String chubbMedical, String mapfreMedical) {
        Map<String, Object> responseMap = new Map<String, String>();
        Map<String, Object> qualitasMap = new Map<String, Object>();
        Map<String, Object> mapfreMap = new Map<String, Object>();
        Map<String, Object> chubbMap = new Map<String, Object>();
        Mex_MapfreAutomobile.Quoteswrapper QuotesMapfreData;
        Mex_ChubbAutomobile.QuotesChubbwrapper QuotesChubbData;
        Mex_QualitasAutomobile.QuotesQualitasWrapper QuotesQualitasData;
        
        try {
            if (requestBody == null || String.isEmpty(requestBody)) {
                responseMap.put('statusCode', '400');
                responseMap.put('message', 'Request body can\'t be empty');
                return JSON.serialize(responseMap);
            }
            
            QuoteRecordWrapper quoteData = (QuoteRecordWrapper) JSON.deserialize(requestBody.replaceAll('__c', '_Tempc'), QuoteRecordWrapper.class);
            
            Map<String, Object> isValid = validateRequestBody(responseMap, quoteData);
            if (isValid.get('statusCode') == '400') {
                return JSON.serialize(isValid);
            } else {
                Integer days = 0 ;
                if (quoteData != null && quoteData.Start_Date_for_Coverage != null && quoteData.End_Date_for_Coverage != null) {
                    days = Date.valueOf(quoteData.Start_Date_for_Coverage).daysBetween(Date.valueOf(quoteData.End_Date_for_Coverage));
                }
                list<Towed_Unit__c> towedUnits = new list<Towed_Unit__c>();

                if (quoteData.Is_Towing == 'Yes') {
                    for (TowedUnitWrapper each : quoteData.towedUnits) {
                        Towed_Unit__c towedUnitRecord = new Towed_Unit__c();
                        towedUnitRecord.Days_in_Tow__c = each.Days_in_Tow_Tempc;
                        towedUnitRecord.Towed_Unit_Type__c = each.Towed_Unit_Type_Tempc;
                        towedUnitRecord.Towed_Unit_Value__c = each.Towed_Unit_Value_Tempc;
                        towedUnitRecord.Towing_Terms__c = each.Towing_Terms_Tempc;
                        // towedUnitRecord.Street_Legal__c = each.Street_Legal_Tempc;
                        towedUnits.add(towedUnitRecord);
                    }
                }
                
                decimal tempDriverAge = 21;
                Boolean isUsedForBusiness = quoteData.Vehicle_used_for_Business_Purposes == 'Yes' ? true : false;
                Boolean isRental = quoteData.Is_Rental_Vehicle == 'Yes' ? true : false;
                if(quoteData != null && quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes'){
                    tempDriverAge = 19;
                }
                
                if(quoteData.Vehicle_Type != null && quoteData.Vehicle_Type == 'Car/Truck/Auto' && quoteData.Policy_Type_picklist == 'Automobile' && (quoteData.Vehicle_Sub_Type == 'Automobile/Sedan' || quoteData.Vehicle_Sub_Type == 'Pickup Truck w or w/o Camper Shell' || quoteData.Vehicle_Sub_Type == 'SUV' || quoteData.Vehicle_Sub_Type == 'Van')) {
                    QuotesMapfreData = Mex_MapfreAutomobile.calculate('Automobile', Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(mapfreLiability), mapfreMedical, quoteData.Vehicle_Sub_Type, towedUnits);
                    QuotesChubbData = Mex_ChubbAutomobile.calculate(Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(chubbLiability), chubbMedical, quoteData.Territory, quoteData.Vehicle_Sub_Type, towedUnits);
                    QuotesQualitasData = Mex_QualitasAutomobile.calculate(quoteData.Territory,'Automobile', Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(qualitasLiability), qualitasMedical, towedUnits, tempDriverAge, isUsedForBusiness, isRental);

                    Map<String, Object> res = MapfreAutomobileCalculationHelper.calculateMapfreAutomobilePremium(QuotesMapfreData, quoteData, days, mapfreMap);
                    Map<String, Object> res1 = ChubbCalculationHelper.calculateChubbAutomobilePremium(QuotesChubbData, quoteData, days, chubbMap);
                    Map<String, Object> res2 = QualitasCalculationHelper.calculateQualitasAutomobilePremium(QuotesQualitasData, quoteData, days, qualitasMap);
                    
                    if (res.get('rateValue') == null && res1.get('rateValue') == null && res2.get('rateValue') == null) {
                        responseMap.clear();
                        res.clear();
                        CalloutException exp = new CalloutException();
                        exp.setMessage('Something went wrong! Kindly try again or contact to the admin.');
                        CustomErrorExceptionHandlerException.data = 'Rate value are null';
                        throw exp;
                    }
                    Map<String, Map<String, Object>> quoteObject = new Map<String, Map<String, Object>>();
                    if (res.get('showMapfre') != null) {
                        quoteObject.put('mapfreQuote', res);
                    }
                    
                    if (res1.get('showChubb') != null) {
                        quoteObject.put('chubbQuote', res1);
                    }
                    
                    if (res2.get('showQualitas') != null) {
                        quoteObject.put('qualitasQuote', res2);
                    }
                    
                    return JSON.serialize(quoteObject);
                } else if (quoteData.Vehicle_Type != null && quoteData.Vehicle_Type == 'Motorcycle/Street Legal ATV' && (quoteData.Vehicle_Sub_Type == 'Motorcycle' || quoteData.Vehicle_Sub_Type == 'Street Legal ATV')) {
                    QuotesMapfreData = Mex_MapfreMotorcycle.calculate('Motorcycle', Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(mapfreLiability), mapfreMedical, quoteData.Vehicle_Sub_Type, towedUnits);
                    QuotesChubbData = Mex_ChubbMotorcycle.calculate(Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(chubbLiability), chubbMedical, quoteData.Territory, quoteData.Vehicle_Sub_Type, towedUnits);
                    QuotesQualitasData = Mex_QualitasMotorcycle.calculate(quoteData.Territory, 'Motorcycle', Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(qualitasLiability), qualitasMedical, towedUnits, tempDriverAge, isUsedForBusiness, isRental);
                    
                    Map<String, Object> res = MapfreAutomobileCalculationHelper.calculateMapfreAutomobilePremium(QuotesMapfreData, quoteData, days, mapfreMap);
                    Map<String, Object> res1 = ChubbCalculationHelper.calculateChubbAutomobilePremium(QuotesChubbData, quoteData, days, chubbMap);
                    Map<String, Object> res2 = QualitasCalculationHelper.calculateQualitasAutomobilePremium(QuotesQualitasData, quoteData, days, qualitasMap);
                    
                    if (res.get('rateValue') == null && res1.get('rateValue') == null && res2.get('rateValue') == null) {
                        responseMap.clear();
                        res.clear();
                        CalloutException exp = new CalloutException();
                        exp.setMessage('Something went wrong! Kindly try again or contact to the admin.');
                        throw exp;
                    }
                    Map<String, Map<String, Object>> quoteObject = new Map<String, Map<String, Object>>();
                    if (res.get('showMapfre') != null) {
                        quoteObject.put('mapfreQuote', res);
                    }
                    
                    if (res1.get('showChubb') != null) {
                        quoteObject.put('chubbQuote', res1);
                    }
                    
                    if (res2.get('showQualitas') != null) {
                        quoteObject.put('qualitasQuote', res2);
                    }
                    return JSON.serialize(quoteObject);
                } else if (quoteData.Vehicle_Type != null && quoteData.Vehicle_Type == 'RV' && quoteData.Policy_Type_picklist == 'RV' && quoteData.Vehicle_Sub_Type == 'Motor Home / RV') {
                    QuotesMapfreData = Mex_MapfreRV.calculate('RV', Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(mapfreLiability), mapfreMedical, quoteData.Vehicle_Sub_Type, towedUnits);
                    QuotesChubbData = Mex_ChubbRV.calculate(Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(chubbLiability), chubbMedical, quoteData.Territory, 'RV', towedUnits);
                    QuotesQualitasData = Mex_QualitasRV.calculate(quoteData.Territory, 'RV', Decimal.valueOf(quoteData.Vehicle_Value), days, Decimal.valueOf(qualitasLiability), qualitasMedical, towedUnits, tempDriverAge, isUsedForBusiness, isRental);
                    
                    Map<String, Object> res = MapfreAutomobileCalculationHelper.calculateMapfreAutomobilePremium(QuotesMapfreData, quoteData, days, mapfreMap);
                    Map<String, Object> res1 = ChubbCalculationHelper.calculateChubbAutomobilePremium(QuotesChubbData, quoteData, days, chubbMap);
                    Map<String, Object> res2 = QualitasCalculationHelper.calculateQualitasAutomobilePremium(QuotesQualitasData, quoteData, days, qualitasMap);
                    
                    if (res.get('rateValue') == null && res1.get('rateValue') == null && res2.get('rateValue') == null) {
                        responseMap.clear();
                        res.clear();
                        CalloutException exp = new CalloutException();
                        exp.setMessage('Something went wrong! Kindly try again or contact to the admin.');
                        throw exp;
                    }

                    Map<String, Map<String, Object>> quoteObject = new Map<String, Map<String, Object>>();
                    if (res.get('showMapfre') != null) {
                        quoteObject.put('mapfreQuote', res);
                    }

                    if (res1.get('showChubb') != null) {
                        quoteObject.put('chubbQuote', res1);
                    }

                    if (res2.get('showQualitas') != null) {
                        quoteObject.put('qualitasQuote', res2);
                    }
                    return JSON.serialize(quoteObject);
                } else {
                    responseMap.clear();
                    responseMap.put('statusCode', '400');
                    responseMap.put('message', 'There\'s something not correct with the data send. Kindly, check and try again.');
                }
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.LogException(ex);
            responseMap.put('statusCode', '500');
            responseMap.put('error', ex.getMessage());
        }
        return JSON.serialize(responseMap);
    }

 @AuraEnabled
    public static map<string, list<Coverage_Detail__c>> getCoverageDetailForSouthbound(string pickList) {
        List<Coverage_Detail__c> Coverage_Details = new List<Coverage_Detail__c>();
        map<string, list<Coverage_Detail__c>> coverageDetailsMap = new map<string, list<Coverage_Detail__c>>();
        try {
            String query = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c, Package__c, ';
            query += 'IsDeleted, Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query += 'Roadside_Details__c, SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, ';
            query += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c, Total_Theft_Deductible__c';
            query += ' FROM Coverage_Detail__c where Policy_Type__c =  \'' + pickList + '\' ORDER BY SystemModstamp DESC';
            
            Coverage_Details = Database.query(query);

            for(Coverage_Detail__c c : Coverage_Details){
                if( c.Underwriter__c != null && !coverageDetailsMap.containskey( c.Underwriter__c ) ){
                    coverageDetailsMap.put( c.Underwriter__c, new list<Coverage_Detail__c>{c} );
                }else if( c.Underwriter__c != null ) {
                    coverageDetailsMap.get(c.Underwriter__c).add(c);
                }
            }
            
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
        }
        return coverageDetailsMap;
    }
    @AuraEnabled
    public static map<string, list<Coverage_Detail__c>> getExactCoverageDetailForSouthbound(string pickList,String packageType) {
        List<Coverage_Detail__c> Coverage_Details = new List<Coverage_Detail__c>();
         List<Coverage_Detail__c> SecondCoverage_Details = new List<Coverage_Detail__c>();
        map<string, list<Coverage_Detail__c>> coverageDetailsMap = new map<string, list<Coverage_Detail__c>>();
        try {
            String query = '';
            String query2 = '';
            if(packageType == 'Max'){
            query = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c, Package__c, ';
            query += 'IsDeleted, Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query += 'Roadside_Details__c, SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, ';
            query += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c, Total_Theft_Deductible__c';
            query += ' FROM Coverage_Detail__c where Policy_Type__c =  \'' + pickList + '\' AND Package__c = \'Complete\' AND Underwriter__c != \'Mapfre\' ORDER BY SystemModstamp DESC';
                
                
                query2 = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c, Package__c, ';
            query2 += 'IsDeleted, Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query2 += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query2 += 'Roadside_Details__c, SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query2 += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query2 += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, ';
            query2 += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c, Total_Theft_Deductible__c';
            query2 += ' FROM Coverage_Detail__c where Policy_Type__c =  \'' + pickList + '\' AND Package__c = \'Max\' AND Underwriter__c = \'Mapfre\' ORDER BY SystemModstamp DESC';
            
                Coverage_Details =  Database.query(query);
            SecondCoverage_Details = Database.query(query2);
            Coverage_Details.addAll(SecondCoverage_Details);
            }else{
            query = 'SELECT Id, Bail_Bond_Limit__c, Name, Deductible_Damage__c, Deductible_Total_Theft__c, Package__c, ';
            query += 'IsDeleted, Glass_Breakage__c, Glass_Breakage_Details__c, Legal_Assistance__c, Legal_Details__c, Partial_Theft__c, Partial_Theft_Details__c,';
            query += 'Plane_Tickets_Home__c, Policy_Type__c, Rental_Car__c, Rental_Car_Details__c, Roadside_Assistance__c,';
            query += 'Roadside_Details__c, SystemModstamp, Territory_Discount__c, Towing__c, Underwriter__c, Uninsured_Motorist_Deductible_Waiver__c,';
            query += 'Vandalism__c, Vandalism_Details__c, Vehicles_Older_than_20_Years__c, Legal_Defense_and_Bail__c, ';
            query += 'Collision_Deductible__c, Bonus_Coverage__c, Labor_Rates__c, Deductibles__c, ';
            query += 'Towing_Details__c, Legal_Defense_and_Bail_Details__c, Total_Theft_Deductible__c';
            query += ' FROM Coverage_Detail__c where Policy_Type__c =  \'' + pickList + '\' AND Package__c = :packageType ORDER BY SystemModstamp DESC';
            	Coverage_Details =  Database.query(query);
            }
            
            
            

            for(Coverage_Detail__c c : Coverage_Details){
                if( c.Underwriter__c != null && !coverageDetailsMap.containskey( c.Underwriter__c ) ){
                    coverageDetailsMap.put( c.Underwriter__c, new list<Coverage_Detail__c>{c} );
                }else if( c.Underwriter__c != null ) {
                    coverageDetailsMap.get(c.Underwriter__c).add(c);
                }
            }
            
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
        }
        return coverageDetailsMap;
    }

    public static Map<String, Object> validateRequestBody(Map<String, Object> responseMap, QuoteRecordWrapper quoteData) {
        if (quoteData.Policy_Type_picklist == null || String.isEmpty(quoteData.Policy_Type_picklist)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Policy_Type_picklist');
            return responseMap;
        }
        
        if (quoteData.Policy_Type_picklist != 'Automobile' && quoteData.Policy_Type_picklist != 'Motorcycle/Street Legal ATV' && quoteData.Policy_Type_picklist != 'RV') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Policy_Type_picklist field. Supported Value is Automobile, Motorcycle/Street Legal ATV, RV.');
            return responseMap;
        }
        
        if (quoteData.Vehicle_Type == null || String.isEmpty(quoteData.Vehicle_Type)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Vehicle_Type');
            return responseMap;
        }
        
        if (quoteData.Vehicle_Type != 'Car/Truck/Auto' && quoteData.Vehicle_Type != 'Motorcycle/Street Legal ATV' && quoteData.Vehicle_Type != 'RV') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Vehicle_Type field. Supported Value is Car/Truck/Auto, Motorcycle/Street Legal ATV, RV.');
            return responseMap;
        }
        
        if (quoteData.Vehicle_Sub_Type == null || String.isEmpty(quoteData.Vehicle_Sub_Type)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Vehicle_Sub_Type');
            return responseMap;
        }
        
        if (quoteData.Vehicle_Sub_Type != 'Automobile/Sedan' && quoteData.Vehicle_Sub_Type != 'Pickup Truck w or w/o Camper Shell' && quoteData.Vehicle_Sub_Type != 'SUV' && quoteData.Vehicle_Sub_Type != 'Van' && quoteData.Vehicle_Sub_Type != 'Automobile' && quoteData.Vehicle_Sub_Type != 'Motorcycle' && quoteData.Vehicle_Sub_Type != 'Motor Home / RV' && quoteData.Vehicle_Sub_Type != 'Street Legal ATV' && quoteData.Vehicle_Sub_Type != 'Watercraft') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Vehicle_Sub_Type field. Supported Values are Automobile/Sedan, Automobile, Pickup Truck w or w/o Camper Shell, SUV, Van, Motorcycle, Motor Home / RV, Watercraft, Street Legal ATV.');
            return responseMap;
        }
        
        if (quoteData.Territory != 'Full' && quoteData.Territory != 'Limited' && quoteData.Territory != 'Baja/Sonora') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Territory field. Supported Values are Full, Limited, Baja/Sonora.');
            return responseMap;
        }
        
        if (quoteData.Is_there_a_driver_under_21 == null || String.isEmpty(quoteData.Is_there_a_driver_under_21)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Is_there_a_driver_under_21');
            return responseMap;
        }
        
        if (quoteData.Vehicle_Value == null || String.isEmpty(quoteData.Vehicle_Value)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Vehicle_Value');
            return responseMap;
        }
        
        if (quoteData.Start_Date_for_Coverage == null || String.isEmpty(quoteData.Start_Date_for_Coverage)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Start_Date_for_Coverage');
            return responseMap;
        }
        
        if (quoteData.End_Date_for_Coverage == null || String.isEmpty(quoteData.End_Date_for_Coverage)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: End_Date_for_Coverage');
            return responseMap;
        }
        
        if (quoteData.Liability == null || String.isEmpty(quoteData.Liability)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Liability');
            return responseMap;
        }
        
        if (quoteData.Liability != '50000' && quoteData.Liability != '400000' && quoteData.Liability != '70000' && quoteData.Liability != '100000' && quoteData.Liability != '150000' && quoteData.Liability != '200000' && quoteData.Liability != '300000' && quoteData.Liability != '500000' && quoteData.Liability != '1000000') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Liability field. Supported values are: 50000, 70000, 100000, 150000, 200000, 300000, 500000, 1000000.');
            return responseMap;
        }
        
        if (quoteData.Liability_Type == null || String.isEmpty(quoteData.Liability_Type)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Liability_Type');
            return responseMap;
        }
        
        if (quoteData.Liability_Type != 'Liability' && quoteData.Liability_Type != 'Complete' && quoteData.Liability_Type != 'LiabilityTheft' && quoteData.Liability_Type != 'Max' && quoteData.Liability_Type != 'Full') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Liability_Type field. Supported values are: Liability, LiabilityTheft, Complete, Max, Full.');
            return responseMap;
        }
        
        if (quoteData.Medical == null || String.isEmpty(quoteData.Medical)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Medical');
            return responseMap;
        }
        
        if (quoteData.Medical != '$2,000/$10,000' && quoteData.Medical != '$3,000/$15,000' && quoteData.Medical != '$4,000/$20,000' && quoteData.Medical != '$5,000/$25,000' && quoteData.Medical != '$10,000/$50,000' && quoteData.Medical != '$15,000/$75,000' && quoteData.Medical != '$20,000/$100,000') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Medical field. Supported values are: $2,000/$10,000, $3,000/$15,000, $4,000/$20,000, $5,000/$25,000, $10,000/$50,000, $15,000/$75,000, $20,000/$100,000.');
            return responseMap;
        }
        
        if (quoteData.Is_Towing == null || String.isEmpty(quoteData.Is_Towing)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Required field missing: Is_Towing');
            return responseMap;
        }
        
        if (quoteData.Is_Towing != 'Yes' && quoteData.Is_Towing != 'No') {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Wrong value provided for the Is_Towing field. Supported value is: Yes or No.');
            return responseMap;
        }
        
        if (quoteData.Is_Towing == 'Yes' && (quoteData.towedUnits == null || quoteData.towedUnits.size() == 0)) {
            responseMap.put('statusCode', '400');
            responseMap.put('message', 'Missing required array towedUnits.');
            return responseMap;
        }
        
        if (quoteData.Is_Towing == 'Yes' && quoteData.towedUnits.size() > 0) {
            map<string, boolean> isValidArr = new map<string, boolean>();
            for (TowedUnitWrapper eachTow : quoteData.towedUnits) {
                if (eachTow.Days_in_Tow_Tempc == null) {
                    isValidArr.put('Days_in_Tow', false);
                }
                
                if (eachTow.Towed_Unit_Type_Tempc == null || String.isEmpty(eachTow.Towed_Unit_Type_Tempc)) {
                    isValidArr.put('Towed_Unit_Type', false);
                }
                
                if (eachTow.Towed_Unit_Type_Tempc != 'Motorcycle' && eachTow.Towed_Unit_Type_Tempc != 'ATV-UTV' && eachTow.Towed_Unit_Type_Tempc != 'Boat' && eachTow.Towed_Unit_Type_Tempc != 'Camper' 
                && eachTow.Towed_Unit_Type_Tempc != 'Utility/Misc Trailer' && eachTow.Towed_Unit_Type_Tempc != 'Towed Automobile') {
                    isValidArr.put('Wrong value provided for the Towed_Unit_Type field. Supported values are: Motorcycle, ATV-UTV, Boat, Camper, Utility/Misc Trailer, Towed Automobile.', false);
                }
                
                if (eachTow.Towed_Unit_Value_Tempc == null) {
                    isValidArr.put('Towed_Unit_Value', false);
                }
            }
            
            if (isValidArr.size() > 0 && isValidArr.values().contains(false)) {
                responseMap.put('statusCode', '400');
                responseMap.put('message', 'Required field missing: ' + String.valueOf(isValidArr.keySet()));
                return responseMap;
            }
        }
        return responseMap;
    }

    @AuraEnabled
    public static String sendEmailDocumentAction(String policyIds) {
        try {
            if (policyIds != null && policyIds != '') {
                Set<String> policyIdList = new Set<String>();
                policyIdList = (Set<String>) JSON.deserialize(policyIds, Set<String>.class);
                Boolean add_attachment = true;
                Mex_Insurance_Calloututility.sendEmail(policyIdList, add_attachment);
            }
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Quote__c getQuoteRecord(String quoteId) {
        try {
            Quote__c quote = [
                SELECT Id, Driver_Age__c, Underwriter__c, Policy_Type_picklist__c, Coverage__c, Territory__c,Broker_Policy_Fee__c,
                I_V_A_Mex_Tax__c, Net_Premium__c, Term__c, Term_Days__c, Vehicle_Type__c, Start_Date_for_Coverage__c, End_Date_for_Coverage__c,
                End_Time__c, Start_Time__c, Quote_Value__c, Medical__c, Liability__c, Vehicle_Value__c
                FROM Quote__c
                WHERE Id = :quoteId
                LIMIT 1
            ];

            return quote;
        } catch (Exception e) {
            CustomErrorExceptionHandlerException.LogException(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Legal_Term__c retrieveLegalTermDetails(String policyType, String underwriter){
        Legal_Term__c legalTerm = [
            SELECT Id, Terms_of_Purchase_and_Use__c, Terms_of_Cancellation__c, Daily_Policy_Cancellation__c, Semi_Annual_and_Annual_Policy_Cancellati__c
            FROM Legal_Term__c
            WHERE Policy_Type__c = :policyType
            AND Underwriter__c = :underwriter
            LIMIT 1
        ];

        return legalTerm;
    }
    
    public class QuoteRecordWrapper {
        public String Policy_Type_picklist{get;set;}
        public String Vehicle_Type{get;set;}
        public String Vehicle_Sub_Type{get;set;}
        public String Territory{get;set;}
        public String Is_there_a_driver_under_21{get;set;}
        public String Salvage_Vehicle{get;set;}
        public String Vehicle_used_for_Business_Purposes{get;set;}
        public String Is_Rental_Vehicle{get;set;}
        public String Vehicle_Value{get;set;}
        public String Start_Date_for_Coverage{get;set;}
        public String End_Date_for_Coverage{get;set;}
        public String Is_Towing{get;set;}
        public String Liability{get;set;}
        public String Medical{get;set;}
        public String Liability_Type{get;set;}
        public String vehicle_Age{get;set;}
        public String driver_Age{get;set;}
        public List<TowedUnitWrapper> towedUnits{get;set;}


        public string Type_of_Vessel_Tempc{get;set;}
        public string Towed_Unit_Tempc{get;set;}
        public string Property_Damage_Liability_Tempc{get;set;}
        public string Policy_Type_picklist_Tempc{get;set;}
        public string Third_Party_Bodily_Injury_Tempc{get;set;}
        public string Vessel_Length_Tempc{get;set;}
        public string Is_the_Maximum_Speed_more_than_50_mph_Tempc{get;set;}
        public string Any_Boat_Operator_Under_22_Tempc{get;set;}
        public string Is_the_owner_living_in_Mexico_Tempc{get;set;}

    }
    
    public class TowedUnitWrapper {
        public Integer Days_in_Tow_Tempc{get;set;}
        public String Towed_Unit_Type_Tempc{get;set;}
        public Decimal Towed_Unit_Value_Tempc{get;set;}
        public String Towing_Terms_Tempc{get;set;}
        // public String Street_Legal_Tempc{get;set;}
    }
}