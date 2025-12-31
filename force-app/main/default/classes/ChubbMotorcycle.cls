public without sharing class ChubbMotorcycle {
    public static decimal calculatePhysicalDamageDaily(decimal physical_damages_daily, integer days){
        physical_damages_daily = physical_damages_daily != null ? physical_damages_daily : 0 ;
        decimal result= (physical_damages_daily*days);
        //system.debug('Physical Damage'+ result);
        return result;
    }
    
    public static decimal calculatePhysicalDamageSemiAnnual(decimal physical_damages_semi_annual){
        return physical_damages_semi_annual;
    } 
    
    public static decimal calculatePhysicalDamageAnnual(decimal physical_damages_annual){
        return physical_damages_annual;
    }  
    
    
    public static decimal calculateTotalTheftDaily(decimal total_theft_daily, integer days){   
        total_theft_daily = total_theft_daily != null ? total_theft_daily : 0 ;
        decimal result= (total_theft_daily*days);
        //system.debug('Total Theft'+ result);
        return result;
    }
    
    public static decimal calculateTotalTheftSemiAnnual(decimal total_theft_semi_annual){
        decimal result= (total_theft_semi_annual);
        //system.debug('Total Theft Semi Annual'+ result);
        return result;
    }  
    
    public static decimal calculateTotalTheftAnnual(decimal total_theft_annual)
    {
        decimal result= (total_theft_annual);
        //system.debug('Total Theft Annual'+ result);
        return result;
    }   
    
    public static decimal calculateLiabilityDaily(decimal third_party_liability_daily, integer days)
    {
        third_party_liability_daily = third_party_liability_daily != null ? third_party_liability_daily : 0 ;
        decimal result= (third_party_liability_daily*days);
        //system.debug('Liability'+ result);
        return result;
    }
    
    public static decimal calculateLiabilitySemiAnnual(decimal third_party_liability_semi_annual)
    {
        decimal result= (third_party_liability_semi_annual);
        //system.debug('Liability Semi Annual'+ result);
        return result;
    }  
    
    public static decimal calculateLiabilityAnnual(decimal third_party_liability_annual)
    {
        decimal result= (third_party_liability_annual);
        //system.debug('Liability Annual'+ result);
        return result;
    } 
    
    public static decimal calculateMedicalDaily( decimal medical_Expenses_daily, integer days)
    {
        medical_Expenses_daily = medical_Expenses_daily != null ? medical_Expenses_daily : 0 ;
        decimal result= (medical_Expenses_daily*days) ;
        //system.debug('Medical'+ result );
        return result;
    }
    
    public static decimal calculateMedicalSemiAnnual( decimal medical_Expenses_semi_annual)
    {
        
        decimal result= (medical_Expenses_semi_annual) ;
        //system.debug('Medical Semi Annual'+ result );
        return result;
    }
    
    public static decimal calculateMedicalAnnual( decimal medical_Expenses_annual)
    {
        
        decimal result= (medical_Expenses_annual) ;
        //system.debug('Medical Annual'+ result );
        return result;
    } 
    
    public static decimal calculateLegalandRoadsideDaily(decimal legal_and_roadside_daily, integer days){
        legal_and_Roadside_daily = legal_and_Roadside_daily != null ? legal_and_Roadside_daily : 0 ;
        decimal result= (legal_and_Roadside_daily*days) ;
        //system.debug('Legal and Roadside'+ result );
        return result;
    }
    
    public static decimal calculateLegalandRoadsideSemiAnnual(decimal legal_and_roadside_semi_annual)
    {
        decimal result= (legal_and_roadside_semi_annual) ;
        //system.debug('Legal and Roadside Semi Annual'+ result );
        return result;
    } 
    
    public static decimal calculateLegalandRoadsideAnnual(decimal legal_and_roadside_annual)
    {
        decimal result= (legal_and_roadside_annual) ;
        //system.debug('Legal and Roadside Annual'+ result );
        return result;
    } 
    
    public static decimal calculateCompleteCoveragePremiumDaily(decimal physical_damage_daily, decimal total_theft_daily, decimal liability_daily, decimal Medical_daily, decimal legal_and_roadside_daily){    
        physical_damage_daily = physical_damage_daily != null ? physical_damage_daily : 0;
        total_theft_daily = total_theft_daily != null ? total_theft_daily : 0;
        liability_daily = liability_daily != null ? liability_daily : 0;
        Medical_daily = Medical_daily != null ? Medical_daily : 0;
        legal_and_roadside_daily = legal_and_roadside_daily != null ? legal_and_roadside_daily : 0;
        
        //-- remove leagal and roadside from here
        //--  13 feb 2021
        decimal result= (physical_damage_daily + total_theft_daily + liability_daily + Medical_daily +legal_and_roadside_daily ) ;//+ legal_and_roadside_daily
        // system.debug('Complete Coverage Premium Daily'+ result);
        return result;
    }
    
    public static decimal calculateCompleteCoveragePremiumSemiAnnual(decimal physical_damage_SemiAnnual, decimal total_theft_SemiAnnual, decimal liability_SemiAnnual, decimal Medical_SemiAnnual, decimal legal_and_roadside_SemiAnnual)   {
        physical_damage_SemiAnnual = physical_damage_SemiAnnual != null ? physical_damage_SemiAnnual : 0;
        total_theft_SemiAnnual = total_theft_SemiAnnual != null ? total_theft_SemiAnnual : 0;
        liability_SemiAnnual = liability_SemiAnnual != null ? liability_SemiAnnual : 0;
        Medical_SemiAnnual = Medical_SemiAnnual != null ? Medical_SemiAnnual : 0;
        legal_and_roadside_SemiAnnual = legal_and_roadside_SemiAnnual != null ? legal_and_roadside_SemiAnnual : 0;
        
        decimal result= (physical_damage_SemiAnnual + total_theft_SemiAnnual + liability_SemiAnnual + Medical_SemiAnnual ) ;//+ legal_and_roadside_SemiAnnual
        // system.debug('Complete Coverage Premium Semi Annual'+ result);
        return result;
    }
    
    public static decimal calculateCompleteCoveragePremiumAnnual(decimal physical_damage_Annual, decimal total_theft_Annual, decimal liability_Annual, decimal Medical_Annual, decimal legal_and_roadside_Annual)   
    {
        physical_damage_Annual = physical_damage_Annual != null ? physical_damage_Annual : 0;
        total_theft_Annual = total_theft_Annual != null ? total_theft_Annual : 0;
        liability_Annual = liability_Annual != null ? liability_Annual : 0;
        Medical_Annual = Medical_Annual != null ? Medical_Annual : 0;
        legal_and_roadside_Annual = legal_and_roadside_Annual != null ? legal_and_roadside_Annual : 0;
        
        decimal result= (physical_damage_Annual + total_theft_Annual + liability_Annual + Medical_Annual + legal_and_roadside_Annual ) ;// + legal_and_roadside_Annual
        // system.debug('Complete Coverage Premium Annual'+ result);
        return result;
    }  

    public static decimal calculateBajaSonaraDiscount(decimal subtotal, decimal discountrate){
        if (discountrate != null && subtotal != null){
            return (subtotal * discountrate)/100;
        }
        else
            return 0;

    }

    
    public static decimal calculateLiabilityOnlyPremium(decimal liability, decimal Medical, decimal legal_and_roadside){
        liability = liability != null ? liability : 0;
        Medical = Medical != null ? Medical : 0;
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0;
        
        //decimal result= (liability + Medical + legal_and_roadside) ;
        //--- changed because of differences in rate table sheet
        //--- legal and roadside will be added after platinumEndorsementForLiabilityOnly is calculated
        
        decimal result= (liability + Medical + legal_and_roadside) ;
        
        
        // system.debug('Liability Only Premium'+ result);
        return result;   
    }  
    
    public static decimal calculatePlatinumEndorsementLiabilityOnlyDaily(decimal liability_only_premium_daily, decimal daily_rate){
        liability_only_premium_daily = liability_only_premium_daily != null ? liability_only_premium_daily : 0 ;
        daily_rate = daily_rate != null ? daily_rate : 0 ;
        decimal result= (liability_only_premium_daily*daily_rate);
        // system.debug('Platinum Endorsement Liability Only'+ result);
        return result;
    }
    
    public static decimal calculatePlatinumEndorsementLiabilityOnlySemiAnnual(decimal liability_only_premium_semi_annual, decimal Six_months_rate){
        liability_only_premium_semi_annual = liability_only_premium_semi_annual != null ? liability_only_premium_semi_annual : 0;
        Six_months_rate = Six_months_rate != null ? Six_months_rate : 0 ;
        
        decimal result= (liability_only_premium_semi_annual*Six_months_rate);
        // system.debug('Platinum Endorsement Liability Only Semi Annual'+ result);
        return result;
    }  
    
    public static decimal calculatePlatinumEndorsementLiabilityOnlyAnnual(decimal liability_only_premium_annual, decimal Annual_rate){
        liability_only_premium_annual = liability_only_premium_annual != null ? liability_only_premium_annual : 0;
        Annual_rate = Annual_rate != null ? Annual_rate : 0 ;
        
        decimal result= (liability_only_premium_annual*Annual_rate);
        // system.debug('Platinum Endorsement Liability Only Annual'+ result);
        return result;
    }  
    
    public static decimal calculatePlatinumEndorsementCompleteCoveragedaily( decimal complete_coverage_premium_daily, decimal daily_rate) {
        complete_coverage_premium_daily = complete_coverage_premium_daily != null ? complete_coverage_premium_daily : 0;
        daily_rate = daily_rate != null ? daily_rate : 0 ;
        decimal result= (complete_coverage_premium_daily*daily_rate);
        // system.debug('Platinum Endorsement Complete Coverage Daily'+ result);
        return result;
    }
    
    public static decimal calculatePlatinumEndorsementCompleteCoverageSemiAnnual( decimal complete_coverage_premium_semi_annual, decimal semi_annual_rate) {
        complete_coverage_premium_semi_annual = complete_coverage_premium_semi_annual != null ? complete_coverage_premium_semi_annual : 0;
        semi_annual_rate = semi_annual_rate != null ? semi_annual_rate : 0 ;
        decimal result= (complete_coverage_premium_semi_annual*semi_annual_rate);
        // system.debug('Platinum Endorsement Complete Coverage Semi Annual'+ result);
        return result;
    }  
    
    public static decimal calculatePlatinumEndorsementCompleteCoverageAnnual( decimal complete_coverage_premium_annual, decimal annual_rate) {
        complete_coverage_premium_annual = complete_coverage_premium_annual != null ? complete_coverage_premium_annual : 0;
        annual_rate = annual_rate != null ? annual_rate : 0 ;
        decimal result= (complete_coverage_premium_annual*annual_rate);
        // system.debug('Platinum Endorsement Complete Coverage Annual'+ result);
        return result;
    }   
    
    
    
    public static decimal calculateTotalPremiumLiabilityOnlyDaily(decimal liability_only_premium_daily, decimal platinum_endorsement_liability_only_daily, decimal legal_and_roadside){
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0;
        liability_only_premium_daily = liability_only_premium_daily != null ? liability_only_premium_daily : 0 ;
        platinum_endorsement_liability_only_daily = platinum_endorsement_liability_only_daily != null ? platinum_endorsement_liability_only_daily : 0 ;
        decimal result = (liability_only_premium_daily + platinum_endorsement_liability_only_daily+ 10+ legal_and_roadside);
        // system.debug('Total Premium Liability Only Daily'+ result);
        return result;
    }                                                       
    
    public static decimal calculateTotalPremiumLiabilityOnlySemiAnnual(decimal liability_only_premium_semi_annual, decimal platinum_endorsement_liability_only_daily_semi_annual, decimal legal_and_roadside){
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0;
        liability_only_premium_semi_annual = liability_only_premium_semi_annual != null ? liability_only_premium_semi_annual : 0 ;
        platinum_endorsement_liability_only_daily_semi_annual = platinum_endorsement_liability_only_daily_semi_annual != null ? platinum_endorsement_liability_only_daily_semi_annual : 0;
        decimal result = (liability_only_premium_semi_annual + platinum_endorsement_liability_only_daily_semi_annual+ 15 + legal_and_roadside);
        // system.debug('Total Premium Liability Only Semi Annual'+ result);
        return result;
    }   
    
    public static decimal calculateTotalPremiumLiabilityOnlyAnnual(decimal liability_only_premium_annual, decimal platinum_endorsement_liability_only_daily_annual, decimal legal_and_roadside){
        system.debug('liability_only_premium_annual : -> '+ liability_only_premium_annual + ' platinum_endorsement_liability_only_daily_annual-> '+platinum_endorsement_liability_only_daily_annual+ ' legal_and_roadside'+ legal_and_roadside);
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0;
        liability_only_premium_annual = liability_only_premium_annual != null ? liability_only_premium_annual : 0 ;
        platinum_endorsement_liability_only_daily_annual = platinum_endorsement_liability_only_daily_annual != null  ? platinum_endorsement_liability_only_daily_annual : 0;
        
        
        decimal result = (liability_only_premium_annual + platinum_endorsement_liability_only_daily_annual+ 25 + legal_and_roadside);
        // system.debug('Total Premium Liability Only Annual'+ result);
        return result;
    }   
    
    public static decimal calculateTotalCompleteCoverageDaily(decimal complete_coverage_premium_daily, decimal platinum_endorsement_complete_coverage_daily, decimal legal_and_roadside){
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0;
        complete_coverage_premium_daily = complete_coverage_premium_daily != null ? complete_coverage_premium_daily : 0 ;
        platinum_endorsement_complete_coverage_daily = platinum_endorsement_complete_coverage_daily != null ? platinum_endorsement_complete_coverage_daily : 0;
        
        decimal result = (complete_coverage_premium_daily + platinum_endorsement_complete_coverage_daily + 10+ legal_and_roadside);
        // system.debug('Total Complete Coverage Daily'+ result);
        return result;
    }
    
    public static decimal calculateTotalCompleteCoverageSemiAnnual(decimal complete_coverage_premium_semi_annual, decimal platinum_endorsement_complete_coverage_semi_annual, decimal legal_and_roadside){
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0;
        complete_coverage_premium_semi_annual = complete_coverage_premium_semi_annual != null ? complete_coverage_premium_semi_annual : 0 ;
        platinum_endorsement_complete_coverage_semi_annual = platinum_endorsement_complete_coverage_semi_annual != null ? platinum_endorsement_complete_coverage_semi_annual : 0;
        
        decimal result = (complete_coverage_premium_semi_annual + platinum_endorsement_complete_coverage_semi_annual + 15+ legal_and_roadside);
        //system.debug('Total Complete Coverage Semi Annual'+ result);
        return result;
    }   
    
    public static decimal calculateTotalCompleteCoverageAnnual(decimal complete_coverage_premium_annual, decimal platinum_endorsement_complete_coverage_annual, decimal legal_and_roadside)
    {
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0;
        complete_coverage_premium_annual = complete_coverage_premium_annual != null ? complete_coverage_premium_annual : 0 ;
        platinum_endorsement_complete_coverage_annual = platinum_endorsement_complete_coverage_annual != null ? platinum_endorsement_complete_coverage_annual : 0;
        
        decimal result = (complete_coverage_premium_annual + platinum_endorsement_complete_coverage_annual + 25 + legal_and_roadside);
        // system.debug('Total Complete Coverage Annual'+ result);
        return result;
    }  
    
    public Static QuotesChubbwrapper calculate(Decimal VehicleActualCashValue, Integer Days, Decimal LiabilityLimit, String MedicalPayments, string coverageTerritory, string vehicleType, list<Towed_Unit__c> towedUnits)
       { 
        try{
        map<string, string> vehicleTypeVsRateType = new map<string, string>();
        vehicleTypeVsRateType.put('Automobile','Automobile');
        vehicleTypeVsRateType.put('Motorcycle','Motorcycle');
        vehicleTypeVsRateType.put('Motor Home / RV','RV');
        vehicleTypeVsRateType.put('Street Legal ATV','Street Legal ATV');
        vehicleTypeVsRateType.put('Watercraft','Watercraft');
        
        if(vehicleTypeVsRateType.containsKey(vehicleType)){
            vehicleType = vehicleTypeVsRateType.get(vehicleType);
        } 

        Rate_Table__c rates = new Rate_Table__c();
        list<Rate_Table__c> Rate_Tables = new list<Rate_Table__c>();
        system.debug('@@ vehicleType'+vehicleType);
        Rate_Tables = [Select Daily_Rate__c, Semi_Annual_Rate__c, Annual_Rate__c, Daily_Rate_Total_Theft__c, Semi_Annual_Total_Theft__c, Annual_Total_Theft__c  from Rate_Table__c where Underwriter__c = 'Chubb' and type__c =: vehicleType and High_Value__c >=: VehicleActualCashValue and Low_Value__c <=: VehicleActualCashValue limit 1];
        if( Rate_Tables != null && !Rate_Tables.isEmpty() ){
            rates = Rate_Tables[0];
        }
        


        Chubb_Liability_CSL__mdt liability = new Chubb_Liability_CSL__mdt();
        list<Chubb_Liability_CSL__mdt> Liability_CSLs = new list<Chubb_Liability_CSL__mdt>();
        Liability_CSLs = [Select Daily_rate__c, Semi_annual_rate__c, Annual_rate__c 
                          From Chubb_Liability_CSL__mdt where Limit_Selection__c =: LiabilityLimit limit 1];
        if( Liability_CSLs != null && !Liability_CSLs.isEmpty() ){
            liability = Liability_CSLs[0];
        }
        
        Medical_Expense_Chubb__mdt payments = new Medical_Expense_Chubb__mdt();
        list<Medical_Expense_Chubb__mdt> Medical_Expense_Chubbs = new list<Medical_Expense_Chubb__mdt>();
        Medical_Expense_Chubbs = [Select Daily__c,Semi_Annual__c, Annual__c 
                                  From Medical_Expense_Chubb__mdt where Limit_Selection__c =: MedicalPayments];
        if( Medical_Expense_Chubbs != null && !Medical_Expense_Chubbs.isEmpty()){
            payments = Medical_Expense_Chubbs[0];
        }
        
        Legal_Roadside_Assistance__mdt LRAssistance = [Select Daily__c,Semi_Annual__c, Annual__c From Legal_Roadside_Assistance__mdt];
        
        Surcharges__mdt  Surcharges = [Select Daily_rate__c,Six_months_rate__c, Annual_rate__c From Surcharges__mdt];
        
        QuotesChubbwrapper wrapInstance = new QuotesChubbwrapper();
        
        Decimal PhysicalDamage1 = calculatePhysicalDamageDaily(rates.Daily_Rate__c, Days);
        Decimal PhysicalDamage2 = calculatePhysicalDamageSemiAnnual(rates.Semi_Annual_Rate__c);
        Decimal PhysicalDamage3 = calculatePhysicalDamageAnnual(rates.Annual_Rate__c);
        wrapInstance.PhysicalDamage = new PhysicalDamage();
        wrapInstance.PhysicalDamage.Daily = (PhysicalDamage1);
        wrapInstance.PhysicalDamage.Semi_annual = (PhysicalDamage2);
        wrapInstance.PhysicalDamage.Annual = (PhysicalDamage3);
        
        if(PhysicalDamage1 != null && PhysicalDamage1 != 0){
            wrapInstance.showChubb = true;
        }else{
            wrapInstance.showChubb = false;
        }

        Integer DamageDeductible1 = 500;
        Integer DamageDeductible90 = 500;
        Integer DamageDeductible365 = 500;
        wrapInstance.DamageDeductible = new DamageDeductible();
        wrapInstance.DamageDeductible.Daily = (DamageDeductible1);
        wrapInstance.DamageDeductible.Semi_annual = (DamageDeductible90);
        wrapInstance.DamageDeductible.Annual = (DamageDeductible365);
        
        Decimal towedUnitsPhysicalDamage = 0;
        Decimal towedUnitsTotalTheft = 0;
        //---- towed units calculation
        if(towedUnits != null && !towedUnits.isEmpty()){
            map<decimal, Rate_Table__c> Rate_TablesTowedUnit = new map<decimal, Rate_Table__c>();
            for(Rate_Table__c rt : [Select Daily_Rate__c, Semi_Annual_Rate__c, Annual_Rate__c, Daily_Rate_Total_Theft__c, Semi_Annual_Total_Theft__c, Annual_Total_Theft__c, High_Value__c  from Rate_Table__c where Underwriter__c = 'Chubb' and type__c =:vehicleType]){
                if(rt.High_Value__c != null){
                    Rate_TablesTowedUnit.put(rt.High_Value__c , rt);
                }
                
            }
            
            Decimal TowedUnitPhysicalDamage1 = 0;
            Decimal TowedUnitPhysicalDamage2 = 0;
            Decimal TowedUnitPhysicalDamage3 = 0;

            Decimal TowedUnittotalTheft1 = 0;
            
            for(Towed_Unit__c tu : towedUnits){
                if(tu.Towed_Unit_Value__c != null && tu.Days_in_Tow__c != null && Rate_TablesTowedUnit.containsKey(tu.Towed_Unit_Value__c)){

                    TowedUnitPhysicalDamage1 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Daily_Rate__c, integer.valueOf(tu.Days_in_Tow__c));
                    TowedUnitPhysicalDamage2 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Daily_Rate__c, integer.valueOf(tu.Days_in_Tow__c));//calculatePhysicalDamageSemiAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Semi_Annual_Rate__c , tu.Days_in_Tow__c);
                    TowedUnitPhysicalDamage3 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Daily_Rate__c, integer.valueOf(tu.Days_in_Tow__c));//calculatePhysicalDamageAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Annual_Rate__c , tu.Days_in_Tow__c);
                    
                    TowedUnitTotalTheft1 += calculateTotalTheftDaily(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Daily_Rate_Total_Theft__c, integer.valueOf(tu.Days_in_Tow__c));
                }
            }
            towedUnitsPhysicalDamage = (TowedUnitPhysicalDamage1);

            wrapInstance.TowedUnitPhysicalDamage = new TowedUnitPhysicalDamage();
            wrapInstance.TowedUnitPhysicalDamage.Daily = ( null != TowedUnitPhysicalDamage1 ? TowedUnitPhysicalDamage1 : 0);
            wrapInstance.TowedUnitPhysicalDamage.Semi_annual = ( null != TowedUnitPhysicalDamage2 ? TowedUnitPhysicalDamage2 : 0);
            wrapInstance.TowedUnitPhysicalDamage.Annual = ( null != TowedUnitPhysicalDamage3 ? TowedUnitPhysicalDamage3 : 0);

            towedUnitsTotalTheft = (TowedUnitTotalTheft1);
            wrapInstance.TowedUnitTotalTheft = new TowedUnitTotalTheft();
            wrapInstance.TowedUnittotalTheft.Daily = ( null != TowedUnitTotalTheft1 ? TowedUnitTotalTheft1 : 0);
            
        
        }
        
        Decimal totalTheft1 = calculateTotalTheftDaily(rates.Daily_Rate_Total_Theft__c, Days);
        Decimal totalTheft90 = calculateTotalTheftSemiAnnual(rates.Semi_Annual_Total_Theft__c);
        Decimal totalTheft365 = calculateTotalTheftAnnual(rates.Annual_Total_Theft__c);
        wrapInstance.TotalTheft = new TotalTheft();
        wrapInstance.totalTheft.Daily = (totalTheft1);
        wrapInstance.totalTheft.Semi_annual = (totalTheft90);
        wrapInstance.totalTheft.Annual = (totalTheft365);    
        
        Decimal Liability1 = calculateLiabilityDaily(liability.Daily_rate__c, Days);
        Decimal Liability90 = calculateLiabilitySemiAnnual(liability.Semi_annual_rate__c);
        Decimal Liability365 = calculateLiabilityAnnual(liability.Annual_rate__c);
        wrapInstance.Liability = new Liability();
        wrapInstance.Liability.Daily = (Liability1);
        wrapInstance.Liability.Semi_Annual = (Liability90);
        wrapInstance.Liability.Annual = (Liability365);
        
        Decimal Medical1 = 0;
        Decimal Medical90 = 0;
        Decimal Medical365 = 0;

        if(vehicleType != null && vehicleType == 'Motorcycle'){
            Medical1 = calculateMedicalDaily(payments.Daily__c, Days);
            Medical90 = calculateMedicalSemiAnnual(payments.Semi_Annual__c);
            Medical365 = calculateMedicalAnnual(payments.Annual__c);
        }
        if(Medical1 == null){
            Medical1 = 0;
        }
        if(Medical90 == null){
            Medical90 = 0;
        }
        if(Medical365 == null){
            Medical365 = 0;
        }
        
        wrapInstance.Medical = new Medical();
        wrapInstance.Medical.Daily = (Medical1);
        wrapInstance.Medical.Semi_Annual = (Medical90);
        wrapInstance.Medical.Annual = (Medical365);
        

        //---- Baja sonara discounts
        BajaSonara_Discount__mdt bajaSonaraDiscountComplete180 = new BajaSonara_Discount__mdt();
        BajaSonara_Discount__mdt bajaSonaraDiscountComplete360 = new BajaSonara_Discount__mdt();

        if(coverageTerritory != null && coverageTerritory == 'Baja Sonora'){
            //if(Days != null && days > 90 && days <=182){
                bajaSonaraDiscountComplete180 = [select Discount__c, Time_Frame__c, Underwriter__c, Coverage_Detail__c
                        From BajaSonara_Discount__mdt
                        where Time_Frame__c = '180' AND Coverage_Detail__c='complete'
                        AND Underwriter__c ='Chubb'];
            //}
            //else if(Days != null && days > 182){
                bajaSonaraDiscountComplete360 = [select Discount__c, Time_Frame__c, Underwriter__c, Coverage_Detail__c
                        From BajaSonara_Discount__mdt
                        where Time_Frame__c = '365' AND Coverage_Detail__c='complete'
                        AND Underwriter__c ='Chubb'];
            //}

        }
        BajaSonara_Discount__mdt bajaSonaraDiscountLiabilityOnly180 = new BajaSonara_Discount__mdt();
        BajaSonara_Discount__mdt bajaSonaraDiscountLiabilityOnly360 = new BajaSonara_Discount__mdt();

        if(coverageTerritory != null && coverageTerritory == 'Baja Sonora'){
            //if(Days != null && days > 90 && days <=182){
                bajaSonaraDiscountLiabilityOnly180 = [select Discount__c, Time_Frame__c, Underwriter__c, Coverage_Detail__c
                        From BajaSonara_Discount__mdt
                        where Time_Frame__c = '180' AND Coverage_Detail__c='liability'
                        AND Underwriter__c ='Chubb'];
            //}
            //else if(Days != null && days > 182){
                bajaSonaraDiscountLiabilityOnly360 = [select Discount__c, Time_Frame__c, Underwriter__c, Coverage_Detail__c
                        From BajaSonara_Discount__mdt
                        where Time_Frame__c = '365' AND Coverage_Detail__c='liability'
                        AND Underwriter__c ='Chubb'];
            //}

        }


        // calculate baja sonara discount here
        //Decimal BajaSonaraDiscount1 = calculateBajaSonaraDiscount(Liability1, Days);
        decimal bajasonaraRateComplete180 = (null != bajaSonaraDiscountComplete180 ? bajaSonaraDiscountComplete180.Discount__c : 0);
        decimal bajasonaraRateComplete365 = (null != bajaSonaraDiscountComplete360 ? bajaSonaraDiscountComplete360.Discount__c : 0);
        
        decimal bajasonaraRateLiabilityOnly180 = (null != bajaSonaraDiscountLiabilityOnly180 ? bajaSonaraDiscountLiabilityOnly180.Discount__c : 0);
        decimal bajasonaraRateLiabilityOnly365 = (null != bajaSonaraDiscountLiabilityOnly360 ? bajaSonaraDiscountLiabilityOnly360.Discount__c : 0);
        
        
            
            if(Medical90 == null) Medical90 = 0;
            if(Medical365 == null) Medical365 = 0;
            if(Liability90 == null) Liability90 = 0;
            if(Liability365 == null) Liability365 = 0;
            if(PhysicalDamage2 == null) PhysicalDamage2 = 0;
            if(totalTheft90 == null) totalTheft90 = 0;
            if(PhysicalDamage3 == null) PhysicalDamage3 = 0;
            if(totalTheft365 == null) totalTheft365 = 0;
            if(bajasonaraRateComplete180 == null) bajasonaraRateComplete180 = 0;
            if(bajasonaraRateComplete365 == null) bajasonaraRateComplete365 = 0;
            if(bajasonaraRateLiabilityOnly180 == null) bajasonaraRateLiabilityOnly180 = 0;
            if(bajasonaraRateLiabilityOnly365 == null) bajasonaraRateLiabilityOnly365 = 0;

        Decimal BajaSonaraDiscount180 = 0;
        Decimal BajaSonaraDiscount365 = 0;
        Decimal BajaSonaraDiscountl180 = 0;
        Decimal BajaSonaraDiscountl365 = 0;
        system.debug(Liability365 + ' ' + Medical365 + ' ' + PhysicalDamage3 + ' ' + totalTheft365 + ' ' + bajasonaraRateComplete365);
        system.debug('@@@ Liability90'+Liability90 + ' Medical90='+Medical90+' PhysicalDamage2='+PhysicalDamage2+' totalTheft90='+totalTheft90+' bajasonaraRateComplete180='+bajasonaraRateComplete180);
        //if(vehicleType != null && vehicleType != 'Motorcycle'){
            BajaSonaraDiscount180 = calculateBajaSonaraDiscount(Liability90 + Medical90 + PhysicalDamage2 + totalTheft90, bajasonaraRateComplete180);
            BajaSonaraDiscount365 = calculateBajaSonaraDiscount(Liability365 + Medical365 + PhysicalDamage3 + totalTheft365, bajasonaraRateComplete365);
            BajaSonaraDiscountl180 = calculateBajaSonaraDiscount(Liability90 + Medical90, bajasonaraRateLiabilityOnly180);
            BajaSonaraDiscountl365 = calculateBajaSonaraDiscount(Liability365 + Medical365, bajasonaraRateLiabilityOnly365);
        
        //}    
       
        wrapInstance.BajaSonaraDiscountComplete = new BajaSonaraDiscountComplete();
        wrapInstance.BajaSonaraDiscountComplete.Daily = 0;
        wrapInstance.BajaSonaraDiscountComplete.Semi_Annual = (BajaSonaraDiscount180);
        wrapInstance.BajaSonaraDiscountComplete.Annual = (BajaSonaraDiscount365);

        wrapInstance.BajaSonaraDiscountLiabilityOnly = new BajaSonaraDiscountLiabilityOnly();
        wrapInstance.BajaSonaraDiscountLiabilityOnly.Daily = 0;
        wrapInstance.BajaSonaraDiscountLiabilityOnly.Semi_Annual = BajaSonaraDiscountl180;
        wrapInstance.BajaSonaraDiscountLiabilityOnly.Annual = BajaSonaraDiscountl365;

        Decimal LegalandRoadside1 = calculateLegalandRoadsideDaily(LRAssistance.Daily__c, Days);
        Decimal LegalandRoadside90 = calculateLegalandRoadsideSemiAnnual(LRAssistance.Semi_Annual__c);
        Decimal LegalandRoadside365 = calculateLegalandRoadsideAnnual(LRAssistance.Annual__c);
        wrapInstance.LegalandRoadside = new LegalandRoadside();
        wrapInstance.LegalandRoadside.Daily = (LegalandRoadside1);
        wrapInstance.LegalandRoadside.Semi_Annual = (LegalandRoadside90);
        wrapInstance.LegalandRoadside.Annual = (LegalandRoadside365);
        
        system.debug('@@@@ PhysicalDamage1 '+PhysicalDamage1  +' towedUnitsPhysicalDamage= '+towedUnitsPhysicalDamage+' totalTheft1='+totalTheft1);
        system.debug('@@@@ towedUnitsTotalTheft '+towedUnitsTotalTheft  +' Liability1= '+Liability1+' Medical1='+Medical1);

        system.debug('@@@@ PhysicalDamage2 '+PhysicalDamage2  +' towedUnitsPhysicalDamage= '+towedUnitsPhysicalDamage+' totalTheft90='+totalTheft90);
        system.debug('@@@@ towedUnitsTotalTheft '+towedUnitsTotalTheft  +' Liability1= '+Liability1+' Medical1='+Medical1);
        // added by vikas to remove null;
        PhysicalDamage1 = PhysicalDamage1 != null ? PhysicalDamage1 : 0;
        towedUnitsPhysicalDamage = towedUnitsPhysicalDamage != null ? towedUnitsPhysicalDamage : 0;
        totalTheft1 = totalTheft1 != null ? totalTheft1 : 0;
        towedUnitsTotalTheft = towedUnitsTotalTheft != null ? towedUnitsTotalTheft : 0;
        Liability1 = Liability1 != null ? Liability1 : 0;
        Medical1 = Medical1 != null ? Medical1 : 0;

        PhysicalDamage2 = PhysicalDamage2 != null ? PhysicalDamage2 : 0;
        totalTheft90 = totalTheft90 != null ? totalTheft90 : 0;
        Liability90 = Liability90 != null ? Liability90 : 0;
        Medical90 = Medical90 != null ? Medical90 : 0;

        PhysicalDamage3 = PhysicalDamage3 != null ? PhysicalDamage3 : 0;
        totalTheft365 = totalTheft365 != null ? totalTheft365 : 0;
        Liability365 = Liability365 != null ? Liability365 : 0;
        Medical365 = Medical365 != null ? Medical365 : 0;

        Decimal CompleteCoveragePremium1 = calculateCompleteCoveragePremiumDaily(PhysicalDamage1+towedUnitsPhysicalDamage, totalTheft1+towedUnitsTotalTheft, Liability1, Medical1, 0);//LegalandRoadside1
        Decimal CompleteCoveragePremium90 = calculateCompleteCoveragePremiumSemiAnnual(PhysicalDamage2+towedUnitsPhysicalDamage, totalTheft90+towedUnitsTotalTheft, Liability90, Medical90, 0);//LegalandRoadside90
        Decimal CompleteCoveragePremium365 = calculateCompleteCoveragePremiumAnnual(PhysicalDamage3+towedUnitsPhysicalDamage, totalTheft365+towedUnitsTotalTheft, Liability365, Medical365, 0);//LegalandRoadside365
        wrapInstance.CompleteCoveragePremium = new CompleteCoveragePremium();
        wrapInstance.CompleteCoveragePremium.Daily = (CompleteCoveragePremium1); 
        wrapInstance.CompleteCoveragePremium.Semi_Annual = (CompleteCoveragePremium90); 
        wrapInstance.CompleteCoveragePremium.Annual = (CompleteCoveragePremium365); 
        
        system.debug('@@@@ CompleteCoveragePremium1 '+CompleteCoveragePremium1  +' semi= '+CompleteCoveragePremium90+' annual='+CompleteCoveragePremium365);
        /*wrapInstance.CompleteCoveragePremium = new List<Decimal>();
wrapInstance.CompleteCoveragePremium.add(PhysicalDamage1 + totalTheft1 + Liability1 + Medical1 + LegalandRoadside1);
wrapInstance.CompleteCoveragePremium.add(PhysicalDamage2 + totalTheft90 + Liability90 + Medical90 + LegalandRoadside90);
wrapInstance.CompleteCoveragePremium.add(PhysicalDamage1 + totalTheft365 + Liability365 + Medical365 + LegalandRoadside365);*/
        
        Decimal LiabilityOnlyPremium1 = calculateLiabilityOnlyPremium(Liability1, Medical1, 0);//LegalandRoadside1 
        Decimal LiabilityOnlyPremium90 = calculateLiabilityOnlyPremium(Liability90, Medical90, 0);//LegalandRoadside90
        Decimal LiabilityOnlyPremium365 = calculateLiabilityOnlyPremium(Liability365, Medical365, 0); //LegalandRoadside365
        wrapInstance.LiabilityOnlyPremium = new LiabilityOnlyPremium();
        wrapInstance.LiabilityOnlyPremium.Daily = (LiabilityOnlyPremium1);
        wrapInstance.LiabilityOnlyPremium.Semi_Annual = (LiabilityOnlyPremium90);
        wrapInstance.LiabilityOnlyPremium.Annual = (LiabilityOnlyPremium365);
        
        /*  wrapInstance.LiabilityOnlyPremium = new List<Decimal>();
wrapInstance.LiabilityOnlyPremium.add(Liability1 + Medical1 + LegalandRoadside1);
wrapInstance.LiabilityOnlyPremium.add(Liability90 + Medical90 + LegalandRoadside90);
wrapInstance.LiabilityOnlyPremium.add(Liability365 + Medical365 + LegalandRoadside365); */
        
        Decimal PlatinumEndorsementLiabilityOnly1 = calculatePlatinumEndorsementLiabilityOnlyDaily(LiabilityOnlyPremium1, Surcharges.Daily_rate__c);
        Decimal PlatinumEndorsementLiabilityOnly90 = calculatePlatinumEndorsementLiabilityOnlySemiAnnual(LiabilityOnlyPremium90 - BajaSonaraDiscountl180, Surcharges.Six_months_rate__c);
        Decimal PlatinumEndorsementLiabilityOnly365 = calculatePlatinumEndorsementLiabilityOnlyAnnual(LiabilityOnlyPremium365 - BajaSonaraDiscountl365, Surcharges.Annual_rate__c);
        wrapInstance.PlatinumEndorsementLiabilityOnly = new PlatinumEndorsementLiabilityOnly();
        wrapInstance.PlatinumEndorsementLiabilityOnly.Daily = (PlatinumEndorsementLiabilityOnly1);
        wrapInstance.PlatinumEndorsementLiabilityOnly.Semi_Annual = (PlatinumEndorsementLiabilityOnly90);
        wrapInstance.PlatinumEndorsementLiabilityOnly.Annual = (PlatinumEndorsementLiabilityOnly365);
        
        
        Decimal PlatinumEndorsementCompleteCoverage1 = calculatePlatinumEndorsementCompleteCoveragedaily(CompleteCoveragePremium1, Surcharges.Daily_rate__c);
        Decimal PlatinumEndorsementCompleteCoverage90 = calculatePlatinumEndorsementCompleteCoverageSemiAnnual(CompleteCoveragePremium90 - BajaSonaraDiscount180, Surcharges.Six_months_rate__c);
        Decimal PlatinumEndorsementCompleteCoverage365 = calculatePlatinumEndorsementCompleteCoverageAnnual(CompleteCoveragePremium365 - BajaSonaraDiscount365, Surcharges.Annual_rate__c);
        wrapInstance.PlatinumEndorsementCompleteCoverage = new PlatinumEndorsementCompleteCoverage();
        wrapInstance.PlatinumEndorsementCompleteCoverage.Daily = (PlatinumEndorsementCompleteCoverage1);
        wrapInstance.PlatinumEndorsementCompleteCoverage.Semi_Annual = (PlatinumEndorsementCompleteCoverage90);
        wrapInstance.PlatinumEndorsementCompleteCoverage.Annual = (PlatinumEndorsementCompleteCoverage365);    
        
        system.debug('@@@@ PlatinumEndorsementCompleteCoverage1 '+PlatinumEndorsementCompleteCoverage1  +' semi= '+PlatinumEndorsementCompleteCoverage90+' annual='+PlatinumEndorsementCompleteCoverage365);

        Integer brokerFee1 = 10;
        Integer brokerFee90 = 15;
        Integer brokerFee365 = 25;
        wrapInstance.brokerFee = new brokerFee();
        wrapInstance.brokerFee.Daily = (brokerFee1);
        wrapInstance.brokerFee.Semi_Annual = (brokerFee90);
        wrapInstance.brokerFee.Annual = (brokerFee365);
        
        
        
        Decimal TotalPremiumLiabilityOnly1 = calculateTotalPremiumLiabilityOnlyDaily(LiabilityOnlyPremium1, PlatinumEndorsementLiabilityOnly1, 0);
        Decimal TotalPremiumLiabilityOnly90 = calculateTotalPremiumLiabilityOnlySemiAnnual(LiabilityOnlyPremium90, PlatinumEndorsementLiabilityOnly90, 0); 
        Decimal TotalPremiumLiabilityOnly365 = calculateTotalPremiumLiabilityOnlyAnnual(LiabilityOnlyPremium365, PlatinumEndorsementLiabilityOnly365, 0);
        wrapInstance.TotalPremiumLiabilityOnly = new TotalPremiumLiabilityOnly();
        wrapInstance.TotalPremiumLiabilityOnly.Daily = (TotalPremiumLiabilityOnly1);
        wrapInstance.TotalPremiumLiabilityOnly.Semi_Annual = (TotalPremiumLiabilityOnly90);
        wrapInstance.TotalPremiumLiabilityOnly.Annual = (TotalPremiumLiabilityOnly365); 
        
        
        Decimal TotalCompleteCoverage1 = calculateTotalCompleteCoverageDaily(CompleteCoveragePremium1, PlatinumEndorsementCompleteCoverage1, 0);
        Decimal TotalCompleteCoverage90 = calculateTotalCompleteCoverageSemiAnnual(CompleteCoveragePremium90, PlatinumEndorsementCompleteCoverage90, 0); 
        Decimal TotalCompleteCoverage365 = calculateTotalCompleteCoverageAnnual(CompleteCoveragePremium365, PlatinumEndorsementCompleteCoverage365, 0);
        wrapInstance.TotalCompleteCoverage = new TotalCompleteCoverage();
        wrapInstance.TotalCompleteCoverage.Daily = (TotalCompleteCoverage1);
        wrapInstance.TotalCompleteCoverage.Semi_Annual = (TotalCompleteCoverage90);
        wrapInstance.TotalCompleteCoverage.Annual = (TotalCompleteCoverage365);
        
        return wrapInstance;
        
    } catch( Exception ex){
         system.debug('Exception:::::'+ex.getMessage()+'at'+ ex.getLineNumber());
         return null;
            
    }  
    }
    public class QuotesChubbwrapper
    {
        public PhysicalDamage PhysicalDamage;
        public DamageDeductible DamageDeductible;
        public TotalTheft TotalTheft;
        public Liability Liability;
        public Medical Medical;
        public LegalandRoadside LegalandRoadside;
        public BajaSonaraDiscountComplete BajaSonaraDiscountComplete;
        public BajaSonaraDiscountLiabilityOnly BajaSonaraDiscountLiabilityOnly;
        public CompleteCoveragePremium CompleteCoveragePremium;
        public LiabilityOnlyPremium LiabilityOnlyPremium;
        public PlatinumEndorsementLiabilityOnly PlatinumEndorsementLiabilityOnly;  
        public PlatinumEndorsementCompleteCoverage PlatinumEndorsementCompleteCoverage;
        public brokerFee brokerFee;
        public TotalPremiumLiabilityOnly TotalPremiumLiabilityOnly;
        public TotalCompleteCoverage TotalCompleteCoverage;
        public TowedUnitPhysicalDamage TowedUnitPhysicalDamage;
        public TowedUnitTotalTheft TowedUnitTotalTheft;
        public boolean showChubb;
    }   
    public class PhysicalDamage{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class DamageDeductible{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    Public class TotalTheft{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    Public class Liability{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    Public class BajaSonaraDiscountComplete{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }

    Public class BajaSonaraDiscountLiabilityOnly{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }

    Public class Medical{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    } 
    
    Public class LegalandRoadside{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    Public class CompleteCoveragePremium{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    Public class LiabilityOnlyPremium{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class TowedUnitTotalTheft{
        public Decimal Daily;
    }
	public class TowedUnitPhysicalDamage{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    Public class PlatinumEndorsementLiabilityOnly{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    Public class PlatinumEndorsementCompleteCoverage{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    Public class brokerFee{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    Public class TotalPremiumLiabilityOnly{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    Public class TotalCompleteCoverage{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }   
    
}