public without sharing class Mex_QualitasRV {
    
    public static decimal calculatePhysicalDamageDaily(decimal physical_damages_daily, integer days){
        physical_damages_daily = physical_damages_daily != null ? physical_damages_daily : 0 ;
        decimal result= (physical_damages_daily*days);
        // system.debug('Physical Damage'+ result);
        return result;
    }
    
    public static decimal calculatePhysicalDamageSemiAnnual(decimal physical_damages_semi_annual)
    {
        decimal result= (physical_damages_semi_annual);
        //system.debug('Physical Damage Semi Annual'+ result);
        return result;
    } 
    
    public static decimal calculatePhysicalDamageAnnual(decimal physical_damages_annual)
    {
        decimal result= (physical_damages_annual);
        //system.debug('Physical Damage Semi Annual'+ result);
        return result;
    }
    
    public static decimal calculateDamageDeductible( decimal vehicle_actual_cash_value) {
        // vehicle_actual_cash_value = vehicle_actual_cash_value != null ? vehicle_actual_cash_value : 0;
        // decimal result= vehicle_actual_cash_value*0.05;
        // if(result>1000)
        // {
        //     return result;
        // }
        // else
        // {
        //     return 500;
        // }
        return 1000;
    }
    
    public static decimal calculateTotalTheftDaily(decimal total_theft_daily, integer days){
        total_theft_daily = total_theft_daily != null ? total_theft_daily : 0 ;
        decimal result= (total_theft_daily * days);
        //system.debug('Total Theft'+ result);
        return result;
    }
    
    public static decimal calculateTotalTheftSemiAnnual(decimal total_theft_semi_annual) {
        decimal result= (total_theft_semi_annual);
        //system.debug('Total Theft Semi Annual'+ result);
        return result;
    }      
    
    public static decimal calculateTotalTheftAnnual(decimal total_theft_annual){
        decimal result= (total_theft_annual);
        //system.debug('Total Theft Annual'+ result);
        return result;
    }   
    
    public static decimal calculateTheftDeductibles(decimal vehicle_actual_cash_value){
        // vehicle_actual_cash_value = vehicle_actual_cash_value != null ? vehicle_actual_cash_value : 0;
        // decimal result= vehicle_actual_cash_value*0.02;
        // if(result>1000)
        // {
        //     return result;
        // }
        // else
        // {
        //     return 1000;    
        // }
        return 1000;
    }    
    public static decimal calculateLiabilityDaily(decimal third_party_liability_daily, integer days){
        third_party_liability_daily = third_party_liability_daily != null ? third_party_liability_daily : 0 ;
        decimal result= (third_party_liability_daily*days);
        //system.debug('Liability'+ result);
        return result;
    }
    
    public static decimal calculateLiabilitySemiAnnual(decimal third_party_liability_semi_annual){
        decimal result= (third_party_liability_semi_annual);
        //system.debug('Liability Semi Annual'+ result);
        return result;
    }  
    
    public static decimal calculateLiabilityAnnual(decimal third_party_liability_annual){
        decimal result= (third_party_liability_annual);
        //system.debug('Liability Annual'+ result);
        return result;
    }  
    
    public static decimal calculateMedicalDaily( decimal medical_Expenses_daily, integer days){
        
        medical_Expenses_daily = medical_Expenses_daily != null ? medical_Expenses_daily : 0 ;
        
        decimal result= (medical_Expenses_daily*days) ;
        //system.debug('Medical'+ result );
        return result;
    }
    
    public static decimal calculateMedicalSemiAnnual( decimal medical_Expenses_semi_annual){
        
        decimal result= (medical_Expenses_semi_annual) ;
        //system.debug('Medical Semi Annual'+ result );
        return result;
    }
    
    public static decimal calculateMedicalAnnual( decimal medical_Expenses_annual){
        
        decimal result= (medical_Expenses_annual) ;
        // system.debug('Medical Annual'+ result );
        return result;
    } 
    
    public static decimal calculateLegalandRoadsideDaily(decimal legal_and_roadside_daily, integer days){
        legal_and_Roadside_daily = legal_and_Roadside_daily != null ? legal_and_Roadside_daily : 0 ;
        
        decimal result= (legal_and_Roadside_daily*days) ;
        // system.debug('Legal and Roadside'+ result );
        return result;
    }
    
    public static decimal calculateLegalandRoadsideSemiAnnual(decimal legal_and_roadside_semi_annual){
        decimal result= (legal_and_roadside_semi_annual) ;
        //system.debug('Legal and Roadside Semi Annual'+ result );	
        return result;
    } 
    
    public static decimal calculateLegalandRoadsideAnnual(decimal legal_and_roadside_annual) {
        decimal result= (legal_and_roadside_annual) ;
        //system.debug('Legal and Roadside Annual'+ result );
        return result;
    }
    
    public static decimal calculateCompleteCoveragePremium(decimal physical_damage, decimal total_theft, 
                                                           decimal liability, decimal Medical, decimal legal_and_roadside){
                                                               physical_damage = physical_damage != null ? physical_damage : 0 ;
                                                               total_theft = total_theft != null ? total_theft : 0 ;
                                                               liability = liability != null ? liability : 0 ;
                                                               Medical = Medical != null ? Medical : 0 ;
                                                               legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0 ;
                                                               
                                                               decimal result= (physical_damage + total_theft + liability + Medical + legal_and_roadside);
                                                               return result;
                                                           }
    
    public static decimal calculateLiabilityOnlyPremium(decimal liability, decimal Medical, decimal legal_and_roadside)	 {
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0 ;
        Medical = Medical != null ? Medical : 0 ;
        liability = liability != null ? liability : 0 ;
        
        decimal result= (liability + Medical + legal_and_roadside) ;
        //system.debug('Liability Only Premium'+ result);
        return result;   
    }     
    
    public static decimal calculateIVACompleteCoverage(decimal complete_coverage_premium){
        decimal result= (complete_coverage_premium*0.16) ;
        //system.debug('IVA Complete Coverage'+ result);
        return result;   
    }     
    
    public static decimal calculateIVALiabilityOnly(decimal liability_only_premium)	{
        decimal result= (liability_only_premium*0.16) ;
        return result;   
    }     
    
    public static decimal calculateTotalCompleteCoverageDaily(decimal complete_coverage_premium_daily, decimal IVA_complete_coverage){
        complete_coverage_premium_daily = complete_coverage_premium_daily != null ? complete_coverage_premium_daily : 0 ;
        IVA_complete_coverage = IVA_complete_coverage != null ? IVA_complete_coverage : 0 ;
        
        decimal result = (complete_coverage_premium_daily + IVA_complete_coverage + 10);
        //system.debug('Total Complete Coverage Daily'+ result);
        return result;
    }    
    
    public static decimal calculateTotalCompleteCoverageSemiAnnual(decimal complete_coverage_premium_Semi_Annual, decimal IVA_complete_coverage){

        complete_coverage_premium_Semi_Annual = complete_coverage_premium_Semi_Annual != null ? complete_coverage_premium_Semi_Annual : 0 ;
        IVA_complete_coverage = IVA_complete_coverage != null ? IVA_complete_coverage : 0 ;
        
        decimal result = (complete_coverage_premium_Semi_Annual + IVA_complete_coverage + 15);
        //system.debug('Total Complete Coverage Semi Annual'+ result);
        return result;
    } 
    
    public static decimal calculateTotalCompleteCoverageAnnual(decimal complete_coverage_premium_Annual, decimal IVA_complete_coverage){
        complete_coverage_premium_Annual = complete_coverage_premium_Annual != null ? complete_coverage_premium_Annual : 0 ;
        IVA_complete_coverage = IVA_complete_coverage != null ? IVA_complete_coverage : 0 ;
        
        decimal result = (complete_coverage_premium_Annual + IVA_complete_coverage + 25);
        //system.debug('Total Complete Coverage Annual'+ result);
        return result;
    }
    
    public static decimal calculateCompleteCoverageLimited(decimal total_complete_coverage, decimal discount){
        total_complete_coverage = total_complete_coverage != null ? total_complete_coverage : 0 ;
        total_complete_coverage = total_complete_coverage != null ? total_complete_coverage : 0 ;
        discount = discount != null ? discount : 0 ;
        
        decimal result = (total_complete_coverage-((total_complete_coverage*discount)));
        //system.debug('Complete Coverage Limited'+ result);
        return result;
    }
    
    public static decimal calculateTotalPremiumLiabilityOnly(decimal liability_only_premium, decimal IVA_liability_only, integer broker_fee)	
    {
        liability_only_premium = liability_only_premium != null ? liability_only_premium : 0 ;
        IVA_liability_only = IVA_liability_only != null ? IVA_liability_only : 0 ;
        broker_fee = broker_fee != null ? broker_fee : 0 ;
        
        decimal result = (liability_only_premium+IVA_liability_only+broker_fee);
        return result;
    }		
    
    public static decimal calculateTotalPremiumLimitedTerritoryOnly(decimal liability_only_premium, decimal IVA_liability_only, integer broker_fee, decimal discount)	
    {
        liability_only_premium = liability_only_premium != null ? liability_only_premium : 0 ;
        IVA_liability_only = IVA_liability_only != null ? IVA_liability_only : 0 ;
        broker_fee = broker_fee != null ? broker_fee : 0 ;
        
        decimal result = (liability_only_premium+IVA_liability_only+broker_fee)- ((liability_only_premium+IVA_liability_only+broker_fee) * discount);
        return result;
    }	
    
    public static decimal calculateLiabilityOnlyLimitedTerritory(decimal total_premium_liability_only, decimal discount){
        total_premium_liability_only = total_premium_liability_only != null ? total_premium_liability_only : 0 ;
        total_premium_liability_only = total_premium_liability_only != null ? total_premium_liability_only : 0 ;
        discount = discount != null ? discount : 0;
        decimal result = (total_premium_liability_only-(total_premium_liability_only*discount));
        return result;  
    }	
    public static decimal calculateAgeSurchargeLiabilityOnly(decimal liability, decimal Medical, decimal legal_and_roadside)     {
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0 ;
        Medical = Medical != null ? Medical : 0 ;
        liability = liability != null ? liability : 0 ;
        
        decimal result= (liability + Medical + legal_and_roadside)*0.2 ;
        //system.debug('Liability Only Premium'+ result);
        return result;   
    }
    public static decimal calculateAgeSurcharge(decimal physical_damage, decimal total_theft, 
                                                           decimal liability, decimal Medical, decimal legal_and_roadside){
        physical_damage = physical_damage != null ? physical_damage : 0 ;
        total_theft = total_theft != null ? total_theft : 0 ;
        liability = liability != null ? liability : 0 ;
        Medical = Medical != null ? Medical : 0 ;
        legal_and_roadside = legal_and_roadside != null ? legal_and_roadside : 0 ;
        
        decimal result= (physical_damage + total_theft + liability + Medical + legal_and_roadside)*0.2 ;
        //system.debug('Complete Coverage Premium'+ result);
        return result;
    }

    public Static Mex_QualitasAutomobile.QuotesQualitasWrapper calculate(string coverageTerritory, string vehicleType, Decimal VehicleActualCashValue, Integer Days, Decimal LiabilityLimit, String MedicalPayments, list<Towed_Unit__c> towedUnits, decimal driverAge, boolean Vehicle_used_for_Business_Purposes, boolean Is_this_a_Rental_Vehicle)
    {
        
        Rate_Table__c rates = new Rate_Table__c();
        list<Rate_Table__c> Rate_Tables = new list<Rate_Table__c>();
        Rate_Tables = [Select Daily_Rate__c, Semi_Annual_Rate__c, Annual_Rate__c, Daily_Rate_Total_Theft__c, Semi_Annual_Total_Theft__c, Annual_Total_Theft__c  
                       from Rate_Table__c where Underwriter__c = 'Qualitas' and type__c =: vehicleType and High_Value__c >=: VehicleActualCashValue 
                       and Low_Value__c <=: VehicleActualCashValue limit 1];
         
        if( Rate_Tables != null && !Rate_Tables.isEmpty()){
            rates = Rate_Tables[0];
        }
        decimal towedUnitValue = 0;
        decimal towedUnitDays = 0;
        for(Towed_Unit__c tw : towedUnits){
            
            if(tw.Towed_Unit_Value__c != null){
                towedUnitValue += tw.Towed_Unit_Value__c;
            }
        }
        Qualitas_Liability_CSL__mdt liability = new Qualitas_Liability_CSL__mdt();
        list<Qualitas_Liability_CSL__mdt> Qualitas_Liability_CSLs = new list<Qualitas_Liability_CSL__mdt>();
        Qualitas_Liability_CSLs = [Select Daily__c, Semi_Annual__c, Annual__c	From Qualitas_Liability_CSL__mdt 
                                   where Limit_Selection__c =: LiabilityLimit limit 1];   
        if( Qualitas_Liability_CSLs != null && !Qualitas_Liability_CSLs.isEmpty()){
            liability = Qualitas_Liability_CSLs[0];
        } 
        
        Medical_Expense_Qualitas__mdt payments = new Medical_Expense_Qualitas__mdt();
        list<Medical_Expense_Qualitas__mdt> Medical_Expense_Qualitas = new list<Medical_Expense_Qualitas__mdt>();
        Medical_Expense_Qualitas = [Select Daily__c,Semi_Annual__c, Annual__c From Medical_Expense_Qualitas__mdt 
                                    where Limit_Selection__c =: MedicalPayments]; 
        if( Medical_Expense_Qualitas != null && !Medical_Expense_Qualitas.isEmpty()){
            payments = Medical_Expense_Qualitas[0];
        }
        
        Roadside_Assistance_Qualitas__mdt RAQualitas = [Select Daily__c, Semi_Annual__c, Annual__c From Roadside_Assistance_Qualitas__mdt]; 
        Surcharges_and_Discounts_of_Qualitas__mdt  Surcharges = [Select Discount__c From Surcharges_and_Discounts_of_Qualitas__mdt];
        if(coverageTerritory == 'Baja/Sonora' || coverageTerritory == 'Baja Sonora'){
            Surcharges.Discount__c = 0.30;
        }
        
        Mex_QualitasAutomobile.QuotesQualitasWrapper wrapInstance = new Mex_QualitasAutomobile.QuotesQualitasWrapper();
        
        Decimal PhysicalDamage3 = calculatePhysicalDamageAnnual(rates.Annual_Rate__c);
        Decimal PhysicalDamage1 = 0;
        Decimal PhysicalDamage2 = calculatePhysicalDamageSemiAnnual(rates.Semi_Annual_Rate__c);
        Decimal tempPhysicalDamage1 = calculatePhysicalDamageDaily(rates.Daily_Rate__c, Days);

        if(tempPhysicalDamage1>PhysicalDamage2){
            PhysicalDamage1 = PhysicalDamage2;
        }else{
            PhysicalDamage1 = tempPhysicalDamage1;
        }

            
        wrapInstance.PhysicalDamage = new Mex_QualitasAutomobile.PhysicalDamage();
        wrapInstance.PhysicalDamage.Daily = (PhysicalDamage1);
        wrapInstance.PhysicalDamage.Semi_annual = (PhysicalDamage2);
        wrapInstance.PhysicalDamage.Annual = (PhysicalDamage3);

        //physical damage
        
        if(PhysicalDamage1 != null && PhysicalDamage1 != 0){
            wrapInstance.showQualitas = true;
        }else{
            wrapInstance.showQualitas = false;
        }

        Decimal DamageDeductible1 = calculateDamageDeductible(VehicleActualCashValue+towedUnitValue);
        Decimal DamageDeductible2 = calculateDamageDeductible(VehicleActualCashValue+towedUnitValue);
        Decimal DamageDeductible3 = calculateDamageDeductible(VehicleActualCashValue+towedUnitValue);
        wrapInstance.DamageDeductible = new Mex_QualitasAutomobile.DamageDeductible(); 
        wrapInstance.DamageDeductible.Daily = (DamageDeductible1);
        wrapInstance.DamageDeductible.Semi_annual = (DamageDeductible2);
        wrapInstance.DamageDeductible.Annual = (DamageDeductible3); 
        
        //damage deductible

        

        Decimal towedUnitsPhysicalDamage = 0;
        Decimal towedUnitsPhysicalDamage180 = 0;
        Decimal towedUnitsPhysicalDamage365 = 0;
        Decimal towedUnitsTotalTheft = 0;
        Decimal towedUnitsTotalTheft180 = 0;
        Decimal towedUnitsTotalTheft365 = 0;
        //---- towed units calculation
        if(towedUnits != null && !towedUnits.isEmpty()){
            map<decimal, Rate_Table__c> Rate_TablesTowedUnit = new map<decimal, Rate_Table__c>();
            for(Rate_Table__c rt : [Select Daily_Rate__c, Semi_Annual_Rate__c, Annual_Rate__c, Daily_Rate_Total_Theft__c, Semi_Annual_Total_Theft__c, Annual_Total_Theft__c, High_Value__c  from Rate_Table__c where Underwriter__c = 'Qualitas' AND type__c =: vehicleType]){
                if(rt.High_Value__c != null){
                    Rate_TablesTowedUnit.put(rt.High_Value__c , rt);
                }
                
            }
            
            Decimal TowedUnitPhysicalDamage1 = 0;
            Decimal TowedUnitPhysicalDamage2 = 0;
            Decimal TowedUnitPhysicalDamage3 = 0;

            Decimal TowedUnittotalTheft1 = 0;
            Decimal TowedUnittotalTheft2 = 0;
            Decimal TowedUnittotalTheft3 = 0;

            towedUnitDays = towedUnits[0].Days_in_Tow__c;
            towedUnitValue = (towedUnitValue.setScale(2)/1000).round(RoundingMode.CEILING)* 1000;

            //NEw code

            if(integer.valueOf(towedUnitDays) > 20){
                TowedUnitPhysicalDamage3 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Annual_Rate__c, 
                                                                            1);//calculatePhysicalDamageAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Annual_Rate__c , tu.Days_in_Tow__c);
            }else{
                TowedUnitPhysicalDamage3 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate__c, 
                                                                        integer.valueOf(towedUnitDays));//calculatePhysicalDamageAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Annual_Rate__c , tu.Days_in_Tow__c);    
            }
            if(integer.valueOf(towedUnitDays) > 20){
                TowedUnitPhysicalDamage2 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Semi_Annual_Rate__c, 1);//calculatePhysicalDamageAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Annual_Rate__c , tu.Days_in_Tow__c);
            }else{
                TowedUnitPhysicalDamage2 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate__c, integer.valueOf(towedUnitDays));//calculatePhysicalDamageAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Annual_Rate__c , tu.Days_in_Tow__c);    
            }

            Decimal tempTowedUnitDaily = calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate__c, integer.valueOf(towedUnitDays));
            if(tempTowedUnitDaily > TowedUnitPhysicalDamage2){
                TowedUnitPhysicalDamage1 = TowedUnitPhysicalDamage2;
            }else{
                TowedUnitPhysicalDamage1 = tempTowedUnitDaily;
            }


            if(integer.valueOf(towedUnitDays) > 20){
                TowedUnitTotalTheft3 += calculateTotalTheftDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Annual_Total_Theft__c, 1);  
               }else{
                TowedUnitTotalTheft3 += calculateTotalTheftDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate_Total_Theft__c, integer.valueOf(towedUnitDays));
               }
               if(integer.valueOf(towedUnitDays) > 20){
                TowedUnitTotalTheft2 += calculateTotalTheftDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Semi_Annual_Total_Theft__c, 1);  
               }else{
                TowedUnitTotalTheft2 += calculateTotalTheftDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate_Total_Theft__c, integer.valueOf(towedUnitDays));
               }
               
               Decimal tempTowedTheftDaily = calculateTotalTheftDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate_Total_Theft__c, integer.valueOf(towedUnitDays));
               if(tempTowedTheftDaily > TowedUnitTotalTheft2){
                TowedUnitTotalTheft1 = TowedUnitTotalTheft2;
               }else{
                TowedUnitTotalTheft1 = tempTowedTheftDaily;
               }

            //New code

            // TowedUnitPhysicalDamage1 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate__c, integer.valueOf(towedUnitDays));
            // TowedUnitPhysicalDamage2 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate__c, integer.valueOf(towedUnitDays));
            // TowedUnitPhysicalDamage3 += calculatePhysicalDamageDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate__c, integer.valueOf(towedUnitDays));
            
            // TowedUnitTotalTheft1 += calculateTotalTheftDaily(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Daily_Rate_Total_Theft__c, integer.valueOf(towedUnitDays));
            
            towedUnitsPhysicalDamage = (TowedUnitPhysicalDamage1);
            towedUnitsPhysicalDamage180 = (TowedUnitPhysicalDamage2);
            towedUnitsPhysicalDamage365 = (TowedUnitPhysicalDamage3);

            wrapInstance.TowedUnitPhysicalDamage = new Mex_QualitasAutomobile.TowedUnitPhysicalDamage();
            wrapInstance.TowedUnitPhysicalDamage.Daily = (TowedUnitPhysicalDamage1);
            wrapInstance.TowedUnitPhysicalDamage.Semi_annual = (TowedUnitPhysicalDamage2);
            wrapInstance.TowedUnitPhysicalDamage.Annual = (TowedUnitPhysicalDamage3);

            towedUnitsTotalTheft = (TowedUnitTotalTheft1);
            towedUnitsTotalTheft180 = (TowedUnitTotalTheft2);
            towedUnitsTotalTheft365 = (TowedUnitTotalTheft3);

            wrapInstance.TowedUnitTotalTheft = new Mex_QualitasAutomobile.TowedUnitTotalTheft();
            wrapInstance.TowedUnittotalTheft.Daily = (TowedUnitTotalTheft1);
            wrapInstance.TowedUnittotalTheft.Semi_annual = (TowedUnitTotalTheft2);
            wrapInstance.TowedUnittotalTheft.Annual = (TowedUnitTotalTheft3);
        
        }

        wrapInstance.totalValue = VehicleActualCashValue + towedUnitValue;

        Decimal TotalTheft3 = calculateTotalTheftAnnual(rates.Annual_Total_Theft__c);
        Decimal TotalTheft1 = 0;
        Decimal TotalTheft2 = calculateTotalTheftSemiAnnual(rates.Semi_Annual_Total_Theft__c);
        Decimal tempTotalTheft1 = calculateTotalTheftDaily(rates.Daily_Rate_Total_Theft__c, Days);
        if(tempTotalTheft1 > TotalTheft2){
            TotalTheft1 = TotalTheft2;
        }else{
            TotalTheft1 = tempTotalTheft1;
        }
        
        wrapInstance.TotalTheft = new Mex_QualitasAutomobile.TotalTheft(); 
        wrapInstance.TotalTheft.Daily = (TotalTheft1);
        wrapInstance.TotalTheft.Semi_annual = (TotalTheft2);
        wrapInstance.TotalTheft.Annual = (TotalTheft3);
        
        Decimal TheftDeductible1 = calculateTheftDeductibles(VehicleActualCashValue);
        Decimal TheftDeductible2 = calculateTheftDeductibles(VehicleActualCashValue);
        Decimal TheftDeductible3 = calculateTheftDeductibles(VehicleActualCashValue);
        wrapInstance.TheftDeductible = new Mex_QualitasAutomobile.TheftDeductible(); 
        wrapInstance.TheftDeductible.Daily = (TheftDeductible1);
        wrapInstance.TheftDeductible.Semi_Annual = (TheftDeductible2);
        wrapInstance.TheftDeductible.Annual = (TheftDeductible3);


        Decimal Liability3 = calculateLiabilityAnnual(liability.Annual__c);
        Decimal Liability1 = 0;
        Decimal Liability2 = calculateLiabilitySemiAnnual(liability.Semi_Annual__c);
        Decimal tempLiability1 = calculateLiabilityDaily(liability.Daily__c, days);
        if(tempLiability1 > Liability2){
            Liability1 = Liability2;
        }else{
            Liability1 = tempLiability1;
        }
        
        
        
        wrapInstance.Liability = new Mex_QualitasAutomobile.Liability(); 
        wrapInstance.Liability.Daily = (Liability1);
        wrapInstance.Liability.Semi_annual = (Liability2);
        wrapInstance.Liability.Annual = (Liability3);
        
        Decimal Medical3 = calculateMedicalAnnual(payments.Annual__c);
        Decimal Medical1 = 0;
        Decimal Medical2 = calculateMedicalSemiAnnual(payments.Semi_Annual__c);

        Decimal tempMedical1 = calculateMedicalDaily(payments.Daily__c, Days);
        if(tempMedical1 > Medical2){
            Medical1 = Medical2;
        }else {
            Medical1 = tempMedical1;
        }
        


        if(Medical1 == null){
            Medical1 = 0;
        }
        if(Medical2 == null){
            Medical2 = 0;
        }
        if(Medical3 == null){
            Medical3 = 0;
        }

        wrapInstance.Medical = new Mex_QualitasAutomobile.Medical(); 
        wrapInstance.Medical.Daily = (Medical1);
        wrapInstance.Medical.Semi_Annual = (Medical2);
        wrapInstance.Medical.Annual = (Medical3);

        if(PhysicalDamage1 == null)PhysicalDamage1 = 0;
        if(PhysicalDamage2 == null)PhysicalDamage2 = 0;
        if(TotalTheft1 == null)TotalTheft1 = 0;
        if(TotalTheft2 == null)TotalTheft2 = 0;
        if(PhysicalDamage3 == null)PhysicalDamage3 = 0;
        if(TotalTheft3 == null)TotalTheft3 = 0;
        if(towedUnitsTotalTheft == null)towedUnitsTotalTheft = 0;
        if(towedUnitsPhysicalDamage == null)towedUnitsPhysicalDamage = 0;
        
        
        Decimal LegalandRoadside1 = calculateLegalandRoadsideDaily(RAQualitas.Daily__c, Days);
        Decimal LegalandRoadside2 = calculateLegalandRoadsideSemiAnnual(RAQualitas.Semi_Annual__c);
        Decimal LegalandRoadside3 = calculateLegalandRoadsideAnnual(RAQualitas.Annual__c);
        wrapInstance.LegalandRoadside = new Mex_QualitasAutomobile.LegalandRoadside();
        wrapInstance.LegalandRoadside.Daily = (LegalandRoadside1);
        wrapInstance.LegalandRoadside.Semi_Annual = (LegalandRoadside2);
        wrapInstance.LegalandRoadside.Annual = (LegalandRoadside3);
        
        //--- calculating age surcharge here complete coverage
        Decimal ageSurcharge1 = (driverAge <= 20 ? calculateAgeSurcharge(PhysicalDamage1+towedUnitsPhysicalDamage, TotalTheft1+towedUnitsTotalTheft, Liability1, Medical1, LegalandRoadside1 ) : 0 );
        Decimal ageSurcharge2 = (driverAge <= 20 ? calculateAgeSurcharge(PhysicalDamage2+towedUnitsPhysicalDamage180, TotalTheft2+towedUnitsTotalTheft180, Liability2, Medical2, LegalandRoadside2) : 0);
        Decimal ageSurcharge3 = (driverAge <= 20 ? calculateAgeSurcharge(PhysicalDamage3+towedUnitsPhysicalDamage365, TotalTheft3+towedUnitsTotalTheft365, Liability3, Medical3, LegalandRoadside3) : 0);
        wrapInstance.ageSurcharge = new Mex_QualitasAutomobile.ageSurcharge(); 
        wrapInstance.ageSurcharge.Daily = (ageSurcharge1);
        wrapInstance.ageSurcharge.Semi_Annual = (ageSurcharge2);
        wrapInstance.ageSurcharge.Annual = (ageSurcharge3);
        
        
        //-- calculating business surcharge here complete coverage
        Decimal businessSurcharge1 = (Vehicle_used_for_Business_Purposes == true ? calculateAgeSurcharge(PhysicalDamage1+towedUnitsPhysicalDamage, TotalTheft1+towedUnitsTotalTheft, Liability1, Medical1, LegalandRoadside1 ) : 0);
        Decimal businessSurcharge2 = (Vehicle_used_for_Business_Purposes == true ? calculateAgeSurcharge(PhysicalDamage2+towedUnitsPhysicalDamage180, TotalTheft2+towedUnitsTotalTheft180, Liability2, Medical2, LegalandRoadside2) : 0);
        Decimal businessSurcharge3 = (Vehicle_used_for_Business_Purposes == true ? calculateAgeSurcharge(PhysicalDamage3+towedUnitsPhysicalDamage365, TotalTheft3+towedUnitsTotalTheft365, Liability3, Medical3, LegalandRoadside3) : 0);

       
        businessSurcharge1 += ( Is_this_a_Rental_Vehicle == true ? calculateAgeSurcharge(PhysicalDamage1+towedUnitsPhysicalDamage, TotalTheft1+towedUnitsTotalTheft, Liability1, Medical1, LegalandRoadside1 ) : 0);
        businessSurcharge2 += ( Is_this_a_Rental_Vehicle == true ? calculateAgeSurcharge(PhysicalDamage2+towedUnitsPhysicalDamage180, TotalTheft2+towedUnitsTotalTheft180, Liability2, Medical2, LegalandRoadside2) : 0);
        businessSurcharge3 += (Is_this_a_Rental_Vehicle == true ? calculateAgeSurcharge(PhysicalDamage3+towedUnitsPhysicalDamage365, TotalTheft3+towedUnitsTotalTheft365, Liability3, Medical3, LegalandRoadside3) : 0);

        wrapInstance.businessSurcharge = new Mex_QualitasAutomobile.businessSurcharge(); 
        wrapInstance.businessSurcharge.Daily = (businessSurcharge1);
        wrapInstance.businessSurcharge.Semi_Annual = (businessSurcharge2);
        wrapInstance.businessSurcharge.Annual = (businessSurcharge3);

        Decimal CompleteCoveragePremium1 = calculateCompleteCoveragePremium(PhysicalDamage1+towedUnitsPhysicalDamage+ageSurcharge1+businessSurcharge1, TotalTheft1+towedUnitsTotalTheft, Liability1, Medical1, LegalandRoadside1 );
        Decimal CompleteCoveragePremium2 = calculateCompleteCoveragePremium(PhysicalDamage2+towedUnitsPhysicalDamage180+ageSurcharge2+businessSurcharge2, TotalTheft2+towedUnitsTotalTheft180, Liability2, Medical2, LegalandRoadside2);
        Decimal CompleteCoveragePremium3 = calculateCompleteCoveragePremium(PhysicalDamage3+towedUnitsPhysicalDamage365+ageSurcharge3+businessSurcharge3, TotalTheft3+towedUnitsTotalTheft365, Liability3, Medical3, LegalandRoadside3);
        wrapInstance.CompleteCoveragePremium = new Mex_QualitasAutomobile.CompleteCoveragePremium(); 
        wrapInstance.CompleteCoveragePremium.Daily = (CompleteCoveragePremium1);
        wrapInstance.CompleteCoveragePremium.Semi_Annual = (CompleteCoveragePremium2);
        wrapInstance.CompleteCoveragePremium.Annual = (CompleteCoveragePremium3);
       
        Decimal ageSurchargeLiabilityOnly1 = (driverAge <= 20 ? calculateAgeSurchargeLiabilityOnly(Liability1, Medical1, LegalandRoadside1 ) : 0);
        Decimal ageSurchargeLiabilityOnly2 = (driverAge <= 20 ? calculateAgeSurchargeLiabilityOnly(Liability2, Medical2, LegalandRoadside2) : 0);
        Decimal ageSurchargeLiabilityOnly3 = (driverAge <= 20 ? calculateAgeSurchargeLiabilityOnly(Liability3, Medical3, LegalandRoadside3) : 0);
        
        
        //-- calculating business surcharge here liability only
        Decimal businessSurchargeLiabilityOnly1 = (Vehicle_used_for_Business_Purposes == true ? calculateAgeSurchargeLiabilityOnly(Liability1, Medical1, LegalandRoadside1 ) : 0);
        Decimal businessSurchargeLiabilityOnly2 = (Vehicle_used_for_Business_Purposes == true ? calculateAgeSurchargeLiabilityOnly(Liability2, Medical2, LegalandRoadside2) : 0);
        Decimal businessSurchargeLiabilityOnly3 = (Vehicle_used_for_Business_Purposes == true ? calculateAgeSurchargeLiabilityOnly(Liability3, Medical3, LegalandRoadside3) : 0);

        businessSurchargeLiabilityOnly1 += ( Is_this_a_Rental_Vehicle == true ? calculateAgeSurchargeLiabilityOnly(Liability1, Medical1, LegalandRoadside1 ) : 0);
        businessSurchargeLiabilityOnly2 += ( Is_this_a_Rental_Vehicle == true ? calculateAgeSurchargeLiabilityOnly(Liability2, Medical2, LegalandRoadside2) : 0);
        businessSurchargeLiabilityOnly3 += ( Is_this_a_Rental_Vehicle == true ? calculateAgeSurchargeLiabilityOnly(Liability3, Medical3, LegalandRoadside3) : 0);
        

        Decimal LiabilityOnlyPremium1 = calculateLiabilityOnlyPremium(Liability1+businessSurchargeLiabilityOnly1+ageSurchargeLiabilityOnly1, Medical1, LegalandRoadside1);
        Decimal LiabilityOnlyPremium2 = calculateLiabilityOnlyPremium(Liability2+ageSurchargeLiabilityOnly2+businessSurchargeLiabilityOnly2, Medical2, LegalandRoadside2);
        Decimal LiabilityOnlyPremium3 = calculateLiabilityOnlyPremium(Liability3+ageSurchargeLiabilityOnly3+businessSurchargeLiabilityOnly3, Medical3, LegalandRoadside3);
        wrapInstance.LiabilityOnlyPremium = new Mex_QualitasAutomobile.LiabilityOnlyPremium(); 
        wrapInstance.LiabilityOnlyPremium.Daily = (LiabilityOnlyPremium1);
        wrapInstance.LiabilityOnlyPremium.Semi_Annual = (LiabilityOnlyPremium2);
        wrapInstance.LiabilityOnlyPremium.Annual = (LiabilityOnlyPremium3);
        
        
        Decimal IVACompleteCoverage1 = calculateIVACompleteCoverage(CompleteCoveragePremium1);
        Decimal IVACompleteCoverage2 = calculateIVACompleteCoverage(CompleteCoveragePremium2);
        Decimal IVACompleteCoverage3 = calculateIVACompleteCoverage(CompleteCoveragePremium3);
        wrapInstance.IVACompleteCoverage = new Mex_QualitasAutomobile.IVACompleteCoverage(); 
        wrapInstance.IVACompleteCoverage.Daily = (IVACompleteCoverage1);
        wrapInstance.IVACompleteCoverage.Semi_Annual = (IVACompleteCoverage2);
        wrapInstance.IVACompleteCoverage.Annual = (IVACompleteCoverage3);
        
        
        Decimal IVALiabilityOnly1 = calculateIVALiabilityOnly(LiabilityOnlyPremium1);
        Decimal IVALiabilityOnly2 = calculateIVALiabilityOnly(LiabilityOnlyPremium2);
        Decimal IVALiabilityOnly3 = calculateIVALiabilityOnly(LiabilityOnlyPremium3);
        wrapInstance.IVALiabilityOnly = new Mex_QualitasAutomobile.IVALiabilityOnly(); 
        wrapInstance.IVALiabilityOnly.Daily = (IVALiabilityOnly1);
        wrapInstance.IVALiabilityOnly.Semi_Annual = (IVALiabilityOnly2);
        wrapInstance.IVALiabilityOnly.Annual = (IVALiabilityOnly3);
        
        wrapInstance.brokerFee = new Mex_QualitasAutomobile.brokerFee();
        wrapInstance.brokerFee.Daily = (10);
        wrapInstance.brokerFee.Semi_Annual = (15);
        wrapInstance.brokerFee.Annual = (25);
        
        
        Decimal TotalCompleteCoverage1 = calculateTotalCompleteCoverageDaily(CompleteCoveragePremium1,IVACompleteCoverage1);
        Decimal TotalCompleteCoverage2 = calculateTotalCompleteCoverageSemiAnnual(CompleteCoveragePremium2,IVACompleteCoverage2);
        Decimal TotalCompleteCoverage3 = calculateTotalCompleteCoverageAnnual(CompleteCoveragePremium3,IVACompleteCoverage3);

        wrapInstance.TotalCompleteCoverage = new Mex_QualitasAutomobile.TotalCompleteCoverage(); 
        wrapInstance.TotalCompleteCoverage.Daily = (TotalCompleteCoverage1);
        wrapInstance.TotalCompleteCoverage.Semi_Annual = (TotalCompleteCoverage2);
        wrapInstance.TotalCompleteCoverage.Annual = (TotalCompleteCoverage3);
        

        decimal completeCoverageLimitedPremium1 = calculateCompleteCoverageLimited(CompleteCoveragePremium1, Surcharges.Discount__c);
        decimal completeCoverageLimitedPremium2 = calculateCompleteCoverageLimited(CompleteCoveragePremium2, Surcharges.Discount__c);
        decimal completeCoverageLimitedPremium3 = calculateCompleteCoverageLimited(CompleteCoveragePremium3, Surcharges.Discount__c);

        Decimal IVALimitedCoverage1 = calculateIVACompleteCoverage(CompleteCoveragePremium1);
        Decimal IVALimitedCoverage2 = calculateIVACompleteCoverage(CompleteCoveragePremium2);
        Decimal IVALimitedCoverage3 = calculateIVACompleteCoverage(CompleteCoveragePremium3);

        Decimal CompleteCoverageLimited1 = calculateTotalPremiumLimitedTerritoryOnly(CompleteCoveragePremium1 , IVALimitedCoverage1,10, Surcharges.Discount__c);//calculateCompleteCoverageLimited(CompleteCoveragePremium1, Surcharges.Discount__c);
        Decimal CompleteCoverageLimited2 = calculateTotalPremiumLimitedTerritoryOnly(CompleteCoveragePremium2 , IVALimitedCoverage2,15, Surcharges.Discount__c);//calculateCompleteCoverageLimited(CompleteCoveragePremium2, Surcharges.Discount__c);
        Decimal CompleteCoverageLimited3 = calculateTotalPremiumLimitedTerritoryOnly(CompleteCoveragePremium3 , IVALimitedCoverage3, 25, Surcharges.Discount__c);//calculateCompleteCoverageLimited(CompleteCoveragePremium3, Surcharges.Discount__c);
        
        CompleteCoverageLimited1 = (CompleteCoveragePremium1  - (CompleteCoveragePremium1 * Surcharges.Discount__c )) + IVALimitedCoverage1 + 10;
        CompleteCoverageLimited2 = (CompleteCoveragePremium2  - (CompleteCoveragePremium2 * Surcharges.Discount__c )) + IVALimitedCoverage2 + 15;
        CompleteCoverageLimited3 = (CompleteCoveragePremium3  - (CompleteCoveragePremium3 * Surcharges.Discount__c )) + IVALimitedCoverage3 + 25;


        wrapInstance.CompleteCoverageLimited = new Mex_QualitasAutomobile.CompleteCoverageLimited(); 
        wrapInstance.CompleteCoverageLimited.Daily = (CompleteCoverageLimited1);
        wrapInstance.CompleteCoverageLimited.Semi_Annual = (CompleteCoverageLimited2);
        wrapInstance.CompleteCoverageLimited.Annual = (CompleteCoverageLimited3);
         
        Decimal TotalPremiumLiabilityOnly1 = calculateTotalPremiumLiabilityOnly(LiabilityOnlyPremium1, IVALiabilityOnly1, 10);
        Decimal TotalPremiumLiabilityOnly2 = calculateTotalPremiumLiabilityOnly(LiabilityOnlyPremium2, IVALiabilityOnly2, 15 );
        Decimal TotalPremiumLiabilityOnly3 = calculateTotalPremiumLiabilityOnly(LiabilityOnlyPremium3, IVALiabilityOnly3, 25 );
        wrapInstance.TotalPremiumLiabilityOnly = new Mex_QualitasAutomobile.TotalPremiumLiabilityOnly(); 
        wrapInstance.TotalPremiumLiabilityOnly.Daily = (TotalPremiumLiabilityOnly1);
        wrapInstance.TotalPremiumLiabilityOnly.Semi_Annual = (TotalPremiumLiabilityOnly2);
        wrapInstance.TotalPremiumLiabilityOnly.Annual = (TotalPremiumLiabilityOnly3);
        
        Decimal LiabilityOnlyLimitedTerritory1 = calculateTotalPremiumLimitedTerritoryOnly(LiabilityOnlyPremium1, 
        calculateIVALiabilityOnly(LiabilityOnlyPremium1), 10 , Surcharges.Discount__c);
        Decimal LiabilityOnlyLimitedTerritory2 = calculateTotalPremiumLimitedTerritoryOnly(LiabilityOnlyPremium2, 
        calculateIVALiabilityOnly(LiabilityOnlyPremium2) , 15, Surcharges.Discount__c );
        Decimal LiabilityOnlyLimitedTerritory3 = calculateTotalPremiumLimitedTerritoryOnly(LiabilityOnlyPremium3, 
        calculateIVALiabilityOnly(LiabilityOnlyPremium3) , 25, Surcharges.Discount__c );

        LiabilityOnlyLimitedTerritory1 = (LiabilityOnlyPremium1  - (LiabilityOnlyPremium1 * Surcharges.Discount__c )) + calculateIVALiabilityOnly(LiabilityOnlyPremium1) + 10;
        LiabilityOnlyLimitedTerritory2 = (LiabilityOnlyPremium2  - (LiabilityOnlyPremium2 * Surcharges.Discount__c )) + calculateIVALiabilityOnly(LiabilityOnlyPremium2) + 15;
        LiabilityOnlyLimitedTerritory3 = (LiabilityOnlyPremium3  - (LiabilityOnlyPremium3 * Surcharges.Discount__c )) + calculateIVALiabilityOnly(LiabilityOnlyPremium3) + 25;

        wrapInstance.LiabilityOnlyLimitedTerritory = new Mex_QualitasAutomobile.LiabilityOnlyLimitedTerritory(); 
        wrapInstance.LiabilityOnlyLimitedTerritory.Daily = (LiabilityOnlyLimitedTerritory1);
        wrapInstance.LiabilityOnlyLimitedTerritory.Semi_Annual = (LiabilityOnlyLimitedTerritory2);
        wrapInstance.LiabilityOnlyLimitedTerritory.Annual = (LiabilityOnlyLimitedTerritory3);
        
        return wrapInstance;
    }
    
    
    
    public class QuotesQualitasWrapper
    {
        public PhysicalDamage PhysicalDamage;
        public DamageDeductible DamageDeductible;
        public TotalTheft TotalTheft;
        public TheftDeductible TheftDeductible;
        public Liability Liability;
        public Medical Medical;
        public LegalandRoadside LegalandRoadside;
        public CompleteCoveragePremium CompleteCoveragePremium;
        public LiabilityOnlyPremium LiabilityOnlyPremium;
        public IVACompleteCoverage IVACompleteCoverage;	  
        public IVALiabilityOnly IVALiabilityOnly;	
        public brokerFee brokerFee;
        public TotalCompleteCoverage TotalCompleteCoverage;
        public CompleteCoverageLimited CompleteCoverageLimited;
        public TotalPremiumLiabilityOnly TotalPremiumLiabilityOnly;
        public LiabilityOnlyLimitedTerritory LiabilityOnlyLimitedTerritory;

        public TowedUnitPhysicalDamage TowedUnitPhysicalDamage;
        public TowedUnitTotalTheft TowedUnitTotalTheft;
        public ageSurcharge ageSurcharge;
        public businessSurcharge businessSurcharge;
        public boolean showQualitas;
    }       
    
    public class PhysicalDamage{
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
    public class DamageDeductible{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class TotalTheft {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class TheftDeductible {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class Liability {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class Medical {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class LegalandRoadside {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class CompleteCoveragePremium {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class LiabilityOnlyPremium {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class ageSurcharge{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class businessSurcharge{
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class IVACompleteCoverage  {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class IVALiabilityOnly  {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class brokerFee  {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class TotalCompleteCoverage  {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    public class CompleteCoverageLimited  {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class TotalPremiumLiabilityOnly {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
    
    public class LiabilityOnlyLimitedTerritory {
        public Decimal Daily;
        public Decimal Semi_annual;
        public Decimal Annual;
    }
}