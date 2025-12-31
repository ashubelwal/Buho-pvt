public without sharing class Mex_MapfreMotorcycle {
    
    public static decimal calculatePhysicalDamage(decimal physical_damages_rate, integer days, decimal discount){   
        physical_damages_rate = physical_damages_rate != null ? physical_damages_rate : 0 ;
        discount = discount != null? discount : 0 ;

        decimal result= ((physical_damages_rate*days)-((physical_damages_rate*days)*discount*0.01));
        //system.debug('Physical Damage '+ result );
        return result;
    }

    public static decimal calculateMaxCoverageAddOns(decimal subtotal, integer days, decimal dailyrate){   
        subtotal = subtotal != null ? subtotal : 0 ;
        dailyrate = dailyrate != null? dailyrate : 0 ;
        days = days != null ? days : 0;

        decimal result= ((dailyrate*days)-((dailyrate*days)*subtotal*0.01));
        //system.debug('Physical Damage '+ result );
        return result;
    }
    
    public static decimal calculateDeductiblesPhysicalDamage( decimal vehicle_value){
            vehicle_value = vehicle_value != null ? vehicle_value : 0 ;
            decimal result= vehicle_value*0.02;
            if(result>500){
                return result;
            }else{
                return 500;
        } 
    }
    
    public static decimal calculateTotalTheft(decimal total_theft_rate, integer days, decimal discount){
        total_theft_rate = total_theft_rate != null ? total_theft_rate : 0 ;
        discount = discount != null? discount: 0;

        decimal result= ((total_theft_rate*days)-((total_theft_rate*days)*discount*0.01)) ;
        //system.debug('Total Theft '+ result );
        return result; 
    }
    
    public static decimal calculateDeductiblesTotalTheft(decimal vehicle_value){   
        vehicle_value = vehicle_value != null ? vehicle_value : 0 ;
        decimal result= vehicle_value*0.05;
        if(result>500){
            return result;
        }else{
            return 1000;    
        } 
    }
    
    public static decimal calculateLiability(decimal insured_sum_daily_rate, integer days, decimal discount){
        insured_sum_daily_rate = insured_sum_daily_rate != null ? insured_sum_daily_rate : 0;
        discount = discount != null ? discount : 0 ;

        decimal result= ((insured_sum_daily_rate*days)-((insured_sum_daily_rate*days)*discount*0.01));
        //system.debug('Liability '+ result );
        return result;
    }

    /*public static decimal calculateMedicalPayments( decimal per_person_daily_rate, integer days, decimal discount){
        per_person_daily_rate = per_person_daily_rate != null ? per_person_daily_rate : 0;
        discount = discount != null ? discount: 0 ;

        decimal result= ((per_person_daily_rate*days)-((per_person_daily_rate*days)*discount*0.01)) ;
        //system.debug('Medical payment'+ result );
        return result;
    }*/
    
    public static decimal calculateLegalAssist(integer days, decimal discount, decimal legalAssistRate){  
        discount = discount != null ? discount : 0 ;
        legalAssistRate = legalAssistRate != null ? legalAssistRate : 0;

        decimal result= ((days*legalAssistRate)-((days*legalAssistRate)*discount*0.01));
        //system.debug('Legal Assist'+ result );                 
        return result;  
    }
    
        public static decimal calculateTravelAssistance(integer days, decimal discount, decimal travelAssistrate){
        discount = discount != null ? discount : 0 ;
        travelAssistrate = travelAssistrate != null ? travelAssistrate : 0;
        decimal result= ((days*travelAssistrate)-((days*travelAssistrate)*discount*0.01));
        //system.debug('Travel Assistance'+ result );                 
        return result; 
        }
    
    public static decimal calculateLiabilityOnlyTotal(integer brokerfee, decimal liability, decimal travelassistance, decimal medicalFee, decimal legalFee ){
        brokerfee = brokerfee != null ? brokerfee : 0 ;
        liability = liability != null ? liability : 0 ;
        travelassistance = travelassistance != null ? travelassistance : 0 ;
        medicalFee = medicalFee != null ? medicalFee : 0;
        legalFee = legalFee != null ? legalFee : 0;

        decimal result= (liability+travelassistance+medicalFee+legalFee);
        //system.debug('Liability Only Total'+ result );
        return result+calculateIVA(result)+brokerfee;
    }
    
        public static decimal calculatelimitedcoveragetotal(decimal totaltheft, decimal liability, decimal legalassist, decimal travelassistance, integer brokerfee){
                                                                
        totaltheft = totaltheft != null ? totaltheft : 0 ;
        liability = liability != null ? liability : 0 ;
        legalassist = legalassist != null ? legalassist : 0 ;
        travelassistance = travelassistance != null ? travelassistance : 0 ;
        brokerfee = brokerfee != null ? brokerfee : 0 ;

        decimal result= (totaltheft+liability+legalassist+travelassistance+brokerfee);
        //system.debug('Limited coverage total'+ result );
        return result; 
        }
    
    public static decimal calculatefullcoveragetotal (decimal totaltheft, decimal liability, decimal legalassist, decimal travelassistance, decimal physicaldamage, integer brokerfee, decimal medicalFee){
        totaltheft = totaltheft != null ? totaltheft : 0 ;
        liability = liability != null ? liability : 0 ;
        legalassist = legalassist != null ? legalassist : 0 ;
        travelassistance = travelassistance != null ? travelassistance : 0 ;
        brokerfee = brokerfee != null ? brokerfee : 0 ;
        physicaldamage = physicaldamage != null ? physicaldamage : 0 ;
        medicalFee = medicalFee != null ? medicalFee : 0;
        
        system.debug('totaltheft : '+ totaltheft + ' liability : '+ liability+' legalassist : '+ legalassist + ' travelassistance : '+travelassistance);
        system.debug('brokerfee : '+ brokerfee + ' physicaldamage : '+ physicaldamage);
        
        decimal result= (totaltheft+liability+legalassist+travelassistance+physicaldamage+medicalFee);
        //system.debug('full coverage total '+ result );
        return result+calculateIVA(result)+brokerfee;
    }
    
    public static decimal calculateIVA(decimal val) {
        decimal res = 0.16 * val;
        return res;
    }

    public static decimal calculateMaxcoveragetotal (decimal fullCoverageTotal, decimal partialTheft, decimal planeTickets, decimal rentalCar){
        fullCoverageTotal = fullCoverageTotal != null ? fullCoverageTotal : 0 ;
        partialTheft = partialTheft != null ? partialTheft : 0 ;
        planeTickets = planeTickets != null ? planeTickets : 0 ;
        rentalCar = rentalCar != null ? rentalCar : 0 ;
        
        decimal result= (fullCoverageTotal+partialTheft+planeTickets+rentalCar);
        //system.debug('full coverage total '+ result );
        return result;
    }
    
    public Static Mex_MapfreAutomobile.Quoteswrapper calculate(string mainvehicleType,Decimal VehicalValue, Integer Days,Decimal LiabilityLimit, String MedicalPayments, string vehicleType, list<Towed_Unit__c> towedUnits){
        try{ Rate_Table__c rates = new Rate_Table__c();

        list<Rate_Table__c> Rate_Tables = new list<Rate_Table__c>();
        Rate_Tables = [Select Risk_1_Physical_Damages__c,Risk_2_Total_Theft__c from Rate_Table__c 
            where Underwriter__c = 'Mapfre' and type__c =: mainvehicleType and High_Value__c >=: VehicalValue and Low_Value__c <=: VehicalValue limit 1];
        if( Rate_Tables.Size() != 0 && !Rate_Tables.isEmpty()){
            rates = Rate_Tables[0];
        }
        decimal towedUnitValue = 0;
        decimal towedUnitDays = 0;
        for(Towed_Unit__c tw : towedUnits){
            if(tw.Towed_Unit_Value__c != null){
                towedUnitValue += tw.Towed_Unit_Value__c;
            }
        }

        Discount__c discount = new Discount__c();
        discount = [Select Daily_Discount__c from Discount__c where No_of_Days__c =: Days limit 1];
        Discount__c discount90 = new Discount__c();
        discount90 = [Select Daily_Discount__c from Discount__c where No_of_Days__c = 90 limit 1];
        Discount__c discount180 = new Discount__c();
        discount180 = [Select Daily_Discount__c from Discount__c where No_of_Days__c = 180 limit 1];
        Discount__c discount365 = new Discount__c();
        discount365 = [Select Daily_Discount__c from Discount__c where No_of_Days__c = 365 limit 1];

        Liability_CSL__mdt liability = new Liability_CSL__mdt();
        list<Liability_CSL__mdt> Liability_CSLs = new list<Liability_CSL__mdt>();
        Liability_CSLs = [Select Daily_rate__c From Liability_CSL__mdt where Insured_sum__c =: LiabilityLimit];
        if( Liability_CSLs != null && !Liability_CSLs.isEmpty()){
            liability = Liability_CSLs[0];
        }

        Medical_Expense__mdt payments = new Medical_Expense__mdt();
        list<Medical_Expense__mdt> Medical_Expenses = new list<Medical_Expense__mdt>();
        Medical_Expenses = [Select Daily_rate__c From Medical_Expense__mdt where Per_person_Per_accident__c =: MedicalPayments];
        if( Medical_Expenses != null && !Medical_Expenses.isempty()){
            payments = Medical_Expenses[0];
        }

        Mex_MapfreAutomobile.Quoteswrapper wrapInstance = new Mex_MapfreAutomobile.Quoteswrapper();
        
        wrapInstance.totalvalue = VehicalValue + towedUnitValue;
        
        Decimal physicalDamages1 = calculatePhysicalDamage(rates.Risk_1_Physical_Damages__c, Days, discount.Daily_Discount__c);
        Decimal physicalDamages90 = calculatePhysicalDamage(rates.Risk_1_Physical_Damages__c, 90, discount90.Daily_Discount__c);
        Decimal physicalDamages180 = calculatePhysicalDamage(rates.Risk_1_Physical_Damages__c, 180, discount180.Daily_Discount__c);
        Decimal physicalDamages365 = calculatePhysicalDamage(rates.Risk_1_Physical_Damages__c, 365, discount365.Daily_Discount__c);
        wrapInstance.physicalDamages = new Mex_MapfreAutomobile.physicalDamages();
        wrapInstance.physicalDamages.Daily = (physicalDamages1);
        wrapInstance.physicalDamages.Days90 = (physicalDamages90);
        wrapInstance.physicalDamages.Days180 = (physicalDamages180);
        wrapInstance.physicalDamages.Annual = (physicalDamages365);
        
        if(physicalDamages1 != null && physicalDamages1 != 0){
            wrapInstance.showMapfre = true;
        }else{
            wrapInstance.showMapfre = false;
        }

        wrapInstance.deductiblesPhysicalDamages = new Mex_MapfreAutomobile.deductiblesPhysicalDamages();
        wrapInstance.deductiblesPhysicalDamages.Daily = (calculateDeductiblesPhysicalDamage(VehicalValue));
        wrapInstance.deductiblesPhysicalDamages.Days90 = (calculateDeductiblesPhysicalDamage(VehicalValue));
        wrapInstance.deductiblesPhysicalDamages.Days180 = (calculateDeductiblesPhysicalDamage(VehicalValue));
        wrapInstance.deductiblesPhysicalDamages.Annual = (calculateDeductiblesPhysicalDamage(VehicalValue));
        
        Decimal towedUnitsPhysicalDamage = 0;
        Decimal towedUnitsTotalTheft = 0;
        //---- towed units calculation
        if(towedUnits != null && !towedUnits.isEmpty()){
            map<decimal, Rate_Table__c> Rate_TablesTowedUnit = new map<decimal, Rate_Table__c>();
            for(Rate_Table__c rt : [Select Risk_1_Physical_Damages__c,Risk_2_Total_Theft__c, High_Value__c  from Rate_Table__c where Underwriter__c = 'Mapfre']){
                if(rt.High_Value__c != null){
                    Rate_TablesTowedUnit.put(rt.High_Value__c , rt);
                }
                
            }
            
            Decimal TowedUnitPhysicalDamage1 = 0;
            Decimal TowedUnitPhysicalDamage2 = 0;
            Decimal TowedUnitPhysicalDamage3 = 0;

            Decimal TowedUnittotalTheft1 = 0;
            towedUnitDays = towedUnits[0].Days_in_Tow__c;
            towedUnitValue = (towedUnitValue.setScale(2)/1000).round(RoundingMode.CEILING)* 1000;
            List<Discount__c> towedUnitDiscount = [Select Daily_Discount__c from Discount__c where No_of_Days__c =:towedUnitDays limit 1];
            
            TowedUnitPhysicalDamage1 += calculatePhysicalDamage(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_1_Physical_Damages__c, integer.valueOf(towedUnitDays), towedUnitDiscount[0].Daily_Discount__c);
            TowedUnitPhysicalDamage2 += calculatePhysicalDamage(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_1_Physical_Damages__c, integer.valueOf(towedUnitDays), towedUnitDiscount[0].Daily_Discount__c);//calculatePhysicalDamageSemiAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Semi_Annual_Rate__c , tu.Days_in_Tow__c);
            TowedUnitPhysicalDamage3 += calculatePhysicalDamage(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_1_Physical_Damages__c, integer.valueOf(towedUnitDays), towedUnitDiscount[0].Daily_Discount__c);//calculatePhysicalDamageAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Annual_Rate__c , tu.Days_in_Tow__c);
            
            TowedUnitTotalTheft1 += calculateTotalTheft(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_2_Total_Theft__c, integer.valueOf(towedUnitDays), towedUnitDiscount[0].Daily_Discount__c);
            
            /*for(Towed_Unit__c tu : towedUnits){
                towedUnitValue = ((tu.Towed_Unit_Value__c.setScale(2))/1000).round(RoundingMode.CEILING)*1000;
                if(towedUnitValue != null && tu.Days_in_Tow__c != null && Rate_TablesTowedUnit.containsKey(towedUnitValue.setScale(2))){
                    Discount__c towedUnitDiscount = new Discount__c();
                    towedUnitDiscount = [Select Daily_Discount__c from Discount__c where No_of_Days__c =: tu.Days_in_Tow__c  limit 1];
                    
                    TowedUnitPhysicalDamage1 += calculatePhysicalDamage(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_1_Physical_Damages__c, integer.valueOf(tu.Days_in_Tow__c), towedUnitDiscount.Daily_Discount__c);
                    TowedUnitPhysicalDamage2 += calculatePhysicalDamage(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_1_Physical_Damages__c, integer.valueOf(tu.Days_in_Tow__c), towedUnitDiscount.Daily_Discount__c);//calculatePhysicalDamageSemiAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Semi_Annual_Rate__c , tu.Days_in_Tow__c);
                    TowedUnitPhysicalDamage3 += calculatePhysicalDamage(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_1_Physical_Damages__c, integer.valueOf(tu.Days_in_Tow__c), towedUnitDiscount.Daily_Discount__c);//calculatePhysicalDamageAnnual(Rate_TablesTowedUnit.get(tu.Towed_Unit_Value__c).Annual_Rate__c , tu.Days_in_Tow__c);
                    
                    TowedUnitTotalTheft1 += calculateTotalTheft(Rate_TablesTowedUnit.get(towedUnitValue.setScale(2)).Risk_2_Total_Theft__c, integer.valueOf(tu.Days_in_Tow__c), towedUnitDiscount.Daily_Discount__c);
                }
            }*/
            towedUnitsPhysicalDamage = (TowedUnitPhysicalDamage1);

            wrapInstance.TowedUnitPhysicalDamage = new Mex_MapfreAutomobile.TowedUnitPhysicalDamage();
            wrapInstance.TowedUnitPhysicalDamage.Daily = (TowedUnitPhysicalDamage1);
            wrapInstance.TowedUnitPhysicalDamage.Semi_annual = (TowedUnitPhysicalDamage2);
            wrapInstance.TowedUnitPhysicalDamage.Annual = (TowedUnitPhysicalDamage3);

            towedUnitsTotalTheft = (TowedUnitTotalTheft1);
            wrapInstance.TowedUnitTotalTheft = new Mex_MapfreAutomobile.TowedUnitTotalTheft();
            wrapInstance.TowedUnittotalTheft.Daily = (TowedUnitTotalTheft1);
            
        
        }

        Decimal totalTheft1 = calculateTotalTheft(rates.Risk_2_Total_Theft__c, Days, discount.Daily_Discount__c);
        Decimal totalTheft90 = calculateTotalTheft(rates.Risk_2_Total_Theft__c, 90, discount90.Daily_Discount__c);
        Decimal totalTheft180 = calculateTotalTheft(rates.Risk_2_Total_Theft__c, 180, discount180.Daily_Discount__c);
        Decimal totalTheft365 = calculateTotalTheft(rates.Risk_2_Total_Theft__c, 365, discount365.Daily_Discount__c);
        wrapInstance.totalTheft = new Mex_MapfreAutomobile.totalTheft();
        wrapInstance.totalTheft.Daily = (totalTheft1);
        wrapInstance.totalTheft.Days90 = (totalTheft90);
        wrapInstance.totalTheft.Days180 = (totalTheft180);
        wrapInstance.totalTheft.Annual = (totalTheft365);

        wrapInstance.deductiblesTotalTheft = new Mex_MapfreAutomobile.deductiblesTotalTheft();
        wrapInstance.deductiblesTotalTheft.Daily = (calculateDeductiblesTotalTheft(VehicalValue));
        wrapInstance.deductiblesTotalTheft.Days90 = (calculateDeductiblesTotalTheft(VehicalValue));
        wrapInstance.deductiblesTotalTheft.Days180 = (calculateDeductiblesTotalTheft(VehicalValue));
        wrapInstance.deductiblesTotalTheft.Annual = (calculateDeductiblesTotalTheft(VehicalValue));
        
        wrapInstance.liability = new Mex_MapfreAutomobile.liability();
        Decimal liability1 = calculateLiability(liability.Daily_rate__c, Days, discount.Daily_Discount__c);
        Decimal liability90 = calculateLiability(liability.Daily_rate__c, 90, discount90.Daily_Discount__c);
        Decimal liability180 = calculateLiability(liability.Daily_rate__c, 180, discount180.Daily_Discount__c);
        Decimal liability365 = calculateLiability(liability.Daily_rate__c, 365, discount365.Daily_Discount__c);
        
        wrapInstance.liability.Daily = (liability1);
        wrapInstance.liability.Days90 = (liability90);
        wrapInstance.liability.Days180 = (liability180);
        wrapInstance.liability.Annual = (liability365);

        Decimal Medical1 = 0;
        Decimal Medical90 = 0;
        Decimal Medical180 = 0;
        Decimal Medical365 = 0;

        /*if(vehicleType != null && vehicleType != 'Motorcycle'){
            Medical1 = (calculateMedicalPayments(payments.Daily_rate__c, Days, discount.Daily_Discount__c));
            Medical90 = (calculateMedicalPayments(payments.Daily_rate__c, 90, discount90.Daily_Discount__c));
            Medical180 = (calculateMedicalPayments(payments.Daily_rate__c, 180, discount180.Daily_Discount__c));
            Medical365 = (calculateMedicalPayments(payments.Daily_rate__c, 365, discount365.Daily_Discount__c));
        }*/

        wrapInstance.medicalPayments = new Mex_MapfreAutomobile.medicalPayments();
        wrapInstance.medicalPayments.Daily = Medical1;
        wrapInstance.medicalPayments.Days90 = Medical90;
        wrapInstance.medicalPayments.Days180 = Medical180;
        wrapInstance.medicalPayments.Annual = Medical365;
        
        Legal_Assist__mdt legalAssistMDT = new Legal_Assist__mdt();
        legalAssistMDT = [select Daily_rate__c from Legal_Assist__mdt where Underwriter__c = 'Mapfre' limit 1 ];


        Decimal legalAssist1 = calculateLegalAssist(Days, discount.Daily_Discount__c, legalAssistMDT.Daily_rate__c);
        Decimal legalAssist90 = calculateLegalAssist(90, discount90.Daily_Discount__c, legalAssistMDT.Daily_rate__c);
        Decimal legalAssist180 = calculateLegalAssist(180, discount180.Daily_Discount__c, legalAssistMDT.Daily_rate__c);
        Decimal legalAssist365 = calculateLegalAssist(365, discount365.Daily_Discount__c, legalAssistMDT.Daily_rate__c);
        
        wrapInstance.legalAssist = new Mex_MapfreAutomobile.legalAssist();
        wrapInstance.legalAssist.Daily = (legalAssist1);
        wrapInstance.legalAssist.Days90 = (legalAssist90);
        wrapInstance.legalAssist.Days180 = (legalAssist180);
        wrapInstance.legalAssist.Annual = (legalAssist365);

        Travel_Assistance__mdt travelAssistMDT = new Travel_Assistance__mdt();
        travelAssistMDT = [select Daily_rate__c from Travel_Assistance__mdt where Underwriter__c = 'Mapfre' limit 1 ];

        Decimal travelAssistance1 = calculateTravelAssistance(Days, discount.Daily_Discount__c, travelAssistMDT.Daily_rate__c);
        Decimal travelAssistance90 = calculateTravelAssistance(90, discount90.Daily_Discount__c, travelAssistMDT.Daily_rate__c);
        Decimal travelAssistance180 = calculateTravelAssistance(180, discount180.Daily_Discount__c, travelAssistMDT.Daily_rate__c);
        Decimal travelAssistance365 = calculateTravelAssistance(365, discount365.Daily_Discount__c, travelAssistMDT.Daily_rate__c);
        
        
        wrapInstance.travelAssistance = new Mex_MapfreAutomobile.travelAssistance();
        wrapInstance.travelAssistance.Daily = (travelAssistance1);
        wrapInstance.travelAssistance.Days90 = (travelAssistance90);
        wrapInstance.travelAssistance.Days180 = (travelAssistance180);
        wrapInstance.travelAssistance.Annual = (travelAssistance365);
        
            wrapInstance.brokerFee = new Mex_MapfreAutomobile.brokerFee();
            wrapInstance.brokerFee.Daily = (10);
            wrapInstance.brokerFee.Days90 = (15);
            wrapInstance.brokerFee.Days180 = (20);
            wrapInstance.brokerFee.Annual = (30);
            
            Decimal liabilityOnlyTotal1 = calculateLiabilityOnlyTotal(10, liability1, travelAssistance1, wrapInstance.medicalPayments.Daily, legalAssist1);
            Decimal liabilityOnlyTotal90 = calculateLiabilityOnlyTotal(15, liability90, travelAssistance90, wrapInstance.medicalPayments.Days90, legalAssist90);
            Decimal liabilityOnlyTotal180 = calculateLiabilityOnlyTotal(20, liability180, travelAssistance180, wrapInstance.medicalPayments.Days180, legalAssist180);
            Decimal liabilityOnlyTotal365 = calculateLiabilityOnlyTotal(30, liability365, travelAssistance365, wrapInstance.medicalPayments.Annual, legalAssist365);
            wrapInstance.liabilityOnlyTotal = new Mex_MapfreAutomobile.liabilityOnlyTotal();
            wrapInstance.liabilityOnlyTotal.Daily = (liabilityOnlyTotal1);
            wrapInstance.liabilityOnlyTotal.Days90 = (liabilityOnlyTotal90);
            wrapInstance.liabilityOnlyTotal.Days180 = (liabilityOnlyTotal180);
            wrapInstance.liabilityOnlyTotal.Annual = (liabilityOnlyTotal365);
            
            Decimal liabilityTheftTotal1 = calculateLiabilityOnlyTotal(10, liability1 + totalTheft1, travelAssistance1, wrapInstance.medicalPayments.Daily, legalAssist1);
            Decimal liabilityTheftTotal90 = calculateLiabilityOnlyTotal(15, liability90 + totalTheft90, travelAssistance90, wrapInstance.medicalPayments.Days90, legalAssist90);
            Decimal liabilityTheftTotal180 = calculateLiabilityOnlyTotal(20, liability180 + totalTheft180, travelAssistance180, wrapInstance.medicalPayments.Days180, legalAssist180);
            Decimal liabilityTheftTotal365 = calculateLiabilityOnlyTotal(30, liability365 + totalTheft365, travelAssistance365, wrapInstance.medicalPayments.Annual, legalAssist365);
            
            wrapInstance.liabilityTheftTotal = new Mex_MapfreAutomobile.liabilityTheftTotal();
            wrapInstance.liabilityTheftTotal.Daily = (liabilityTheftTotal1);
            wrapInstance.liabilityTheftTotal.Days90 = (liabilityTheftTotal90);
            wrapInstance.liabilityTheftTotal.Days180 = (liabilityTheftTotal180);
            wrapInstance.liabilityTheftTotal.Annual = (liabilityTheftTotal365);
            
            Decimal IVALiabilityOnlyTotal1 = calculateIVA(liability1 + travelAssistance1 + wrapInstance.medicalPayments.Daily + legalAssist1);
            Decimal IVALiabilityOnlyTotal90 = calculateIVA(liability90 + travelAssistance90 + wrapInstance.medicalPayments.Days90 + legalAssist90);
            Decimal IVAliabilityOnlyTotal180 = calculateIVA(liability180 + travelAssistance180 + wrapInstance.medicalPayments.Days180+ legalAssist180);
            Decimal IVAliabilityOnlyTotal365 = calculateIVA(liability365 + travelAssistance365 + wrapInstance.medicalPayments.Annual + legalAssist365);
            
            wrapInstance.IVAliabilityOnlyTotal = new Mex_MapfreAutomobile.IVAliabilityOnlyTotal();
            wrapInstance.IVAliabilityOnlyTotal.Daily = IVALiabilityOnlyTotal1;
            wrapInstance.IVAliabilityOnlyTotal.Days90 = IVALiabilityOnlyTotal90;
            wrapInstance.IVAliabilityOnlyTotal.Days180 = IVAliabilityOnlyTotal180;
            wrapInstance.IVAliabilityOnlyTotal.Annual = IVAliabilityOnlyTotal365;
            
            Decimal IVALiabilityTheftTotal1 = calculateIVA(liability1 + travelAssistance1 + totalTheft1 + wrapInstance.medicalPayments.Daily + legalAssist1);
            Decimal IVALiabilityTheftTotal90 = calculateIVA(liability90 + travelAssistance90 + totalTheft90 + wrapInstance.medicalPayments.Days90 + legalAssist90);
            Decimal IVALiabilityTheftTotal180 = calculateIVA(liability180 + travelAssistance90 + totalTheft180 + wrapInstance.medicalPayments.Days180 + legalAssist180);
            Decimal IVALiabilityTheftTotal365 = calculateIVA(liability365 + travelAssistance365 + totalTheft365 + wrapInstance.medicalPayments.Annual + legalAssist365);
            
            wrapInstance.IVALiabilityTheft = new Mex_MapfreAutomobile.IVALiabilityTheft();
            wrapInstance.IVALiabilityTheft.Daily = IVALiabilityTheftTotal1;
            wrapInstance.IVALiabilityTheft.Days90 = IVALiabilityTheftTotal90;
            wrapInstance.IVALiabilityTheft.Days180 = IVALiabilityTheftTotal180;
            wrapInstance.IVALiabilityTheft.Annual = IVALiabilityTheftTotal365;
            
            Decimal limitedCoverageTotal1 = calculatelimitedcoveragetotal(totalTheft1, liability1, legalAssist1, travelAssistance1 , 10);
            Decimal limitedCoverageTotal90 = calculatelimitedcoveragetotal(totalTheft90, liability90, legalAssist90, travelAssistance90, 15);
            Decimal limitedCoverageTotal180 = calculatelimitedcoveragetotal(totalTheft180, liability180, legalAssist180, travelAssistance180 , 20);
            Decimal limitedCoverageTotal365 = calculatelimitedcoveragetotal(totalTheft365, liability365, legalAssist365, travelAssistance365, 30);
            wrapInstance.limitedCoverageTotal = new Mex_MapfreAutomobile.limitedCoverageTotal();
            wrapInstance.limitedCoverageTotal.Daily = (limitedCoverageTotal1);
            wrapInstance.limitedCoverageTotal.Days90 = (limitedCoverageTotal90);
            wrapInstance.limitedCoverageTotal.Days180 = (limitedCoverageTotal180);
            wrapInstance.limitedCoverageTotal.Annual = (limitedCoverageTotal365);
        
            system.debug('physicalDamages180 : '+ physicalDamages180 + ' towedUnitsPhysicalDamage: '+ towedUnitsPhysicalDamage + ' totalTheft180 : '+ totalTheft180 + ' towedUnitsTotalTheft : '+ towedUnitsTotalTheft);
        
        system.debug('liability180 : '+ liability180 + ' legalAssist180: '+ legalAssist180 + ' travelAssistance180 : '+ travelAssistance180 + ' wrapInstance.medicalPayments.Days180 : '+wrapInstance.medicalPayments.Days180);
            
        Decimal fullCoverageTotal1 = calculatefullcoveragetotal(physicalDamages1+towedUnitsPhysicalDamage, totalTheft1+towedUnitsPhysicalDamage, liability1, legalAssist1, travelAssistance1, 10, wrapInstance.medicalPayments.Daily);
        Decimal fullCoverageTotal90 = calculatefullcoveragetotal(physicalDamages90+towedUnitsPhysicalDamage, totalTheft90+towedUnitsPhysicalDamage, liability90, legalAssist90, travelAssistance90, 15, wrapInstance.medicalPayments.Days90);
        Decimal fullCoverageTotal180 = calculatefullcoveragetotal(physicalDamages180+towedUnitsPhysicalDamage, totalTheft180+towedUnitsPhysicalDamage, liability180, legalAssist180, travelAssistance180, 20, wrapInstance.medicalPayments.Days180);
        Decimal fullCoverageTotal365 = calculatefullcoveragetotal(physicalDamages365+towedUnitsPhysicalDamage, totalTheft365+towedUnitsPhysicalDamage, liability365, legalAssist365, travelAssistance365, 30, wrapInstance.medicalPayments.Annual);
        wrapInstance.fullCoverageTotal = new Mex_MapfreAutomobile.fullCoverageTotal();
        wrapInstance.fullCoverageTotal.Daily = (fullCoverageTotal1);
        wrapInstance.fullCoverageTotal.Days90 = (fullCoverageTotal90);
        wrapInstance.fullCoverageTotal.Days180 = (fullCoverageTotal180);
        wrapInstance.fullCoverageTotal.Annual = (fullCoverageTotal365);
            
        Decimal IVAfullCoverageTotal1 = calculateIVA(physicalDamages1+towedUnitsPhysicalDamage+ totalTheft1+towedUnitsPhysicalDamage + liability1 + legalAssist1 + travelAssistance1 + wrapInstance.medicalPayments.Daily);
        Decimal IVAfullCoverageTotal90 = calculateIVA(physicalDamages90+towedUnitsPhysicalDamage + totalTheft90+towedUnitsPhysicalDamage + liability90 + legalAssist90 + travelAssistance90 + wrapInstance.medicalPayments.Days90);
        Decimal IVAfullCoverageTotal180 = calculateIVA(physicalDamages180+towedUnitsPhysicalDamage + totalTheft180+towedUnitsPhysicalDamage + liability180 + legalAssist180 + travelAssistance180 + wrapInstance.medicalPayments.Days180);
        Decimal IVAfullCoverageTotal365 = calculateIVA(physicalDamages365+towedUnitsPhysicalDamage + totalTheft365+towedUnitsPhysicalDamage + liability365 + legalAssist365 + travelAssistance365 + wrapInstance.medicalPayments.Annual);
		wrapInstance.IVAFullCoverage = new Mex_MapfreAutomobile.IVAFullCoverage();
        wrapInstance.IVAFullCoverage.Daily = IVAfullCoverageTotal1;
        wrapInstance.IVAFullCoverage.Days90 = IVAfullCoverageTotal90;
        wrapInstance.IVAFullCoverage.Days180 = IVAfullCoverageTotal180;
        wrapInstance.IVAFullCoverage.Annual = IVAfullCoverageTotal365;

        //calculateMaxCoverageAddOns
        //---- calculating max coverage for mapfre

        Partial_Theft__mdt partialTheftMDT = new Partial_Theft__mdt();
        partialTheftMDT = [select Daily_rate__c, Limit__c, Underwriter__c from Partial_Theft__mdt where Underwriter__c ='Mapfre' limit 1];

        Decimal partialTheftAddOnValue1 = calculateMaxCoverageAddOns(discount.Daily_Discount__c, days, partialTheftMDT.Daily_rate__c);
        Decimal partialTheftAddOnValue90 = calculateMaxCoverageAddOns(discount90.Daily_Discount__c, 90, partialTheftMDT.Daily_rate__c);
        Decimal partialTheftAddOnValue180 = calculateMaxCoverageAddOns(discount180.Daily_Discount__c, 180, partialTheftMDT.Daily_rate__c);
        Decimal partialTheftAddOnValue365 = calculateMaxCoverageAddOns(discount365.Daily_Discount__c, 365, partialTheftMDT.Daily_rate__c);

        list<Plane_Ticket__mdt> planeTicketMDT = new list<Plane_Ticket__mdt>();
        planeTicketMDT = [select Daily_rate__c, Vehicle_type__c, Underwriter__c from Plane_Ticket__mdt where Underwriter__c ='Mapfre' and Vehicle_Type__c =:vehicleType limit 1];

        Decimal planeTicketAddOnValue1 = 0;
        Decimal planeTicketAddOnValue90 = 0;
        Decimal planeTicketAddOnValue180 = 0;
        Decimal planeTicketAddOnValue365 = 0;

        if(!planeTicketMDT.isEmpty()){
            planeTicketAddOnValue1 = calculateMaxCoverageAddOns(discount.Daily_Discount__c, days, planeTicketMDT[0].Daily_rate__c);
            planeTicketAddOnValue90 = calculateMaxCoverageAddOns(discount90.Daily_Discount__c, 90, planeTicketMDT[0].Daily_rate__c);
            planeTicketAddOnValue180 = calculateMaxCoverageAddOns(discount180.Daily_Discount__c, 180, planeTicketMDT[0].Daily_rate__c);
            planeTicketAddOnValue365 = calculateMaxCoverageAddOns(discount365.Daily_Discount__c, 365, planeTicketMDT[0].Daily_rate__c);
            
        }
        
        list<Rental_Car__mdt> rentalCarMDT = new list<Rental_Car__mdt>();
        rentalCarMDT = [select Daily_rate__c, Vehicle_type__c, Underwriter__c from Rental_Car__mdt where Underwriter__c ='Mapfre' and Vehicle_Type__c =:vehicleType limit 1];

        Decimal rentalCarMDTAddOnValue1 = 0;
        Decimal rentalCarMDTAddOnValue90 = 0;
        Decimal rentalCarMDTAddOnValue180 = 0;
        Decimal rentalCarMDTAddOnValue365 = 0;

        if(!rentalCarMDT.isEmpty()){
            rentalCarMDTAddOnValue1 = calculateMaxCoverageAddOns(discount.Daily_Discount__c, days, rentalCarMDT[0].Daily_rate__c);
            rentalCarMDTAddOnValue90 = calculateMaxCoverageAddOns(discount90.Daily_Discount__c, 90, rentalCarMDT[0].Daily_rate__c);
            rentalCarMDTAddOnValue180 = calculateMaxCoverageAddOns(discount180.Daily_Discount__c, 180, rentalCarMDT[0].Daily_rate__c);
            rentalCarMDTAddOnValue365 = calculateMaxCoverageAddOns(discount365.Daily_Discount__c, 365, rentalCarMDT[0].Daily_rate__c);
            
        }
        
        system.debug('@@@@ partialTheftAddOnValue1'+partialTheftAddOnValue1);
        system.debug('@@@@ partialTheftAddOnValue1'+partialTheftAddOnValue90);
        system.debug('@@@@ partialTheftAddOnValue1'+partialTheftAddOnValue180);
        system.debug('@@@@ partialTheftAddOnValue365'+partialTheftAddOnValue365);

        system.debug('@@@@ planeTicketAddOnValue1'+planeTicketAddOnValue1);
        system.debug('@@@@ planeTicketAddOnValue90'+planeTicketAddOnValue90);
        system.debug('@@@@ planeTicketAddOnValue180'+planeTicketAddOnValue180);
        system.debug('@@@@ planeTicketAddOnValue365'+planeTicketAddOnValue365);

        system.debug('@@@@ rentalCarMDTAddOnValue1'+rentalCarMDTAddOnValue1);
        system.debug('@@@@ rentalCarMDTAddOnValue90'+rentalCarMDTAddOnValue90);
        system.debug('@@@@ rentalCarMDTAddOnValue180'+rentalCarMDTAddOnValue180);
        system.debug('@@@@ rentalCarMDTAddOnValue365'+rentalCarMDTAddOnValue365);
        
        
        Decimal maxCoverageTotal1 = calculateMaxcoveragetotal(fullCoverageTotal1, partialTheftAddOnValue1, planeTicketAddOnValue1, rentalCarMDTAddOnValue1);
        Decimal maxCoverageTotal90 = calculateMaxcoveragetotal(fullCoverageTotal90, partialTheftAddOnValue90, planeTicketAddOnValue90, rentalCarMDTAddOnValue90);
        Decimal maxCoverageTotal180 = calculateMaxcoveragetotal(fullCoverageTotal180, partialTheftAddOnValue180, planeTicketAddOnValue180, rentalCarMDTAddOnValue180);
        Decimal maxCoverageTotal365 = calculateMaxcoveragetotal(fullCoverageTotal365, partialTheftAddOnValue365, planeTicketAddOnValue365, rentalCarMDTAddOnValue365);
        wrapInstance.MaxCoverageTotal = new Mex_MapfreAutomobile.MaxCoverageTotal();
        wrapInstance.MaxCoverageTotal.Daily = (maxCoverageTotal1);
        wrapInstance.MaxCoverageTotal.Days90 = (maxCoverageTotal90);
        wrapInstance.MaxCoverageTotal.Days180 = (maxCoverageTotal180);
        wrapInstance.MaxCoverageTotal.Annual = (maxCoverageTotal365);
        
        return wrapInstance;
       }catch(Exception ex){
            system.debug('Exception:::'+ ex.getMessage()+'at'+ex.getLineNumber());
            return null;
            
        }
    }

    public class Quoteswrapper
    {
        public physicalDamages physicalDamages;
        public deductiblesPhysicalDamages deductiblesPhysicalDamages;
        public totalTheft totalTheft;
        public deductiblesTotalTheft deductiblesTotalTheft;
        public liability liability;
        public medicalPayments medicalPayments;
        public legalAssist legalAssist;
        public travelAssistance travelAssistance;  
        public brokerFee brokerFee;
        public liabilityOnlyTotal liabilityOnlyTotal;
        public IVAliabilityOnlyTotal IVAliabilityOnlyTotal;
        public IVALiabilityTheft IVALiabilityTheft;
        public limitedCoverageTotal limitedCoverageTotal;
        public fullCoverageTotal fullCoverageTotal;
        public IVAFullCoverage IVAFullCoverage;
        public MaxCoverageTotal MaxCoverageTotal;
        public TowedUnitPhysicalDamage TowedUnitPhysicalDamage;
        public TowedUnitTotalTheft TowedUnitTotalTheft;
        public decimal totalvalue;
        public boolean showMapfre;
    } 
    
    public class physicalDamages{
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    
    public class deductiblesPhysicalDamages{
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
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
    public class totalTheft {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    
    public class deductiblesTotalTheft {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class liability {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class medicalPayments {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class legalAssist {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class travelAssistance {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class brokerFee {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class liabilityOnlyTotal {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }

    public class MaxCoverageTotal {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }

    public class limitedCoverageTotal 	{
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class fullCoverageTotal {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class IVAFullCoverage {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    public class IVAliabilityOnlyTotal {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
    
    public class IVALiabilityTheft {
        public Decimal Daily;
        public Decimal Days90;
        public Decimal Days180;
        public Decimal Annual;
    }
}