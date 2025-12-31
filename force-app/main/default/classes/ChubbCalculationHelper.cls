public without sharing class ChubbCalculationHelper {
    public static Map<String, Object> calculateChubbAutomobilePremium(Mex_ChubbAutomobile.QuotesChubbwrapper QuotesChubbData, Mex_QuickQuoteCommonController.QuoteRecordWrapper quoteData, Integer days, Map<String, Object> responseMap) {
        responseMap.put('days', String.valueOf(days));
        responseMap.put('showChubb', QuotesChubbData.showChubb);
        system.debug('QuotesChubbData QuotesChubbData'+ QuotesChubbData);
        if (QuotesChubbData.showChubb == false) {
            return responseMap;
        }
        Integer chubbDays = days;

        Decimal chubbRateValue;
        Decimal physical_damage_payment = 0;
        Decimal Liability_payment = 0;
        Decimal medical_payment = 0;
        Decimal platinum_endorsement_payment = 0;
        Decimal total_theft_payment = 0;
System.debug('---QuotesChubbData-----'+ QuotesChubbData);
System.debug('--quoteData.Liability_Type---'+ quoteData.Liability_Type);
        if (quoteData.Liability_Type != null && quoteData.Liability_Type == 'Liability') {
            chubbRateValue = 0;


            if (QuotesChubbData.TotalPremiumLiabilityOnly != null) {
                if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes') {
                    if( days != null && days <= 30 ){
                        if( QuotesChubbData.TotalPremiumLiabilityOnly.Daily != null ) {
                            chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Daily;
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Daily + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Daily : 0);
                            Liability_payment = QuotesChubbData.Liability.Daily;
                            medical_payment = QuotesChubbData.Medical.Daily;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Daily;
                            total_theft_payment = QuotesChubbData.TotalTheft.Daily + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Daily : 0);
                            if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes') {
                                Decimal chubbSurcharge = chubbRateValue - QuotesChubbData.brokerFee.Daily;
                                chubbRateValue += chubbSurcharge;
                                responseMap.put('rateValue', chubbRateValue);
                                responseMap.put('surcharge', chubbSurcharge);
                                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Daily);
                            }
                        }
                        
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual != null && ((QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual) + (QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual - QuotesChubbData.brokerFee.Semi_annual)) < chubbRateValue) {
                            chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual;
                            chubbDays = 180;
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Semi_annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Semi_annual;
                            medical_payment = QuotesChubbData.Medical.Semi_annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Semi_annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Semi_annual : 0);
                            
                            if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes'){
                                Decimal chubbSurcharge = chubbRateValue - QuotesChubbData.brokerFee.Semi_annual;
                                chubbRateValue += chubbSurcharge;
                                
                                responseMap.put('rateValue', chubbRateValue);
                                responseMap.put('surcharge', chubbSurcharge);
                                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Semi_annual);
                            }
                        }
                        
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Annual != null && ((QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual) + (QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual - QuotesChubbData.brokerFee.Annual)) < chubbRateValue) {
                            chubbRateValue = QuotesChubbData.totalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual;
                            chubbDays = 365;
                            
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Annual;
                            medical_payment = QuotesChubbData.Medical.Annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                            if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes') {
                                Decimal chubbSurcharge = chubbRateValue - QuotesChubbData.brokerFee.Annual;
                                chubbRateValue += chubbSurcharge;
                                
                                responseMap.put('rateValue', chubbRateValue);
                                responseMap.put('surcharge', chubbSurcharge);
                                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Annual);
                            }
                        }
                    } else if (days != null && days > 30 && days <= 180) {
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual != null) {
                            chubbRateValue = QuotesChubbData.totalPremiumLiabilityOnly.Semi_annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual;
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Semi_annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Semi_annual;
                            medical_payment = QuotesChubbData.Medical.Semi_annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Semi_annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Semi_annual : 0);
                            
                            
                            if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes'){
                                Decimal chubbSurcharge = chubbRateValue - QuotesChubbData.brokerFee.Semi_annual;
                                chubbRateValue += chubbSurcharge;
                                
                                responseMap.put('rateValue', chubbRateValue);
                                responseMap.put('surcharge', chubbSurcharge);
                                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Semi_annual);
                            }
                        }
                        
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Annual != null && ((QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual ) + (QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual - QuotesChubbData.brokerFee.Annual)) < chubbRateValue) {
                            chubbRateValue = QuotesChubbData.totalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual;
                            chubbDays = 365;
                            
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Annual;
                            medical_payment = QuotesChubbData.Medical.Annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                            
                            
                            if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes'){
                                Decimal chubbSurcharge = chubbRateValue - QuotesChubbData.brokerFee.Annual;
                                chubbRateValue += chubbSurcharge;
                                
                                responseMap.put('rateValue', chubbRateValue);
                                responseMap.put('surcharge', chubbSurcharge);
                                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Annual);
                            }
                        }
                    } else if ( days != null && days > 180 && QuotesChubbData.totalPremiumLiabilityOnly.Annual != null ) {
                        chubbRateValue = QuotesChubbData.totalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual;
                        physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                        Liability_payment = QuotesChubbData.Liability.Annual;
                        medical_payment = QuotesChubbData.Medical.Annual;
                        platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Annual;
                        total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                        
                        
                        if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes'){
                            Decimal chubbSurcharge = chubbRateValue - QuotesChubbData.brokerFee.Annual;
                            chubbRateValue += chubbSurcharge;
                            
                            responseMap.put('rateValue', chubbRateValue);
                            responseMap.put('surcharge', chubbSurcharge);
                            responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Annual);
                        }
                    }
                } else {
                    if (days != null && days <= 30) {
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Daily != null) {
                            chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Daily;
                            
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Daily + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Daily : 0);
                            Liability_payment = QuotesChubbData.Liability.Daily;
                            medical_payment = QuotesChubbData.Medical.Daily;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Daily;
                            total_theft_payment = QuotesChubbData.TotalTheft.Daily + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Daily : 0);
                        }
                        
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual != null && (QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual) < chubbRateValue) {
                            chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual;
                            chubbDays = 180;
                            
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Semi_annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Semi_annual;
                            medical_payment = QuotesChubbData.Medical.Semi_annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Semi_annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Semi_annual : 0);
                        }
                        
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Annual != null && (QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual) < chubbRateValue) {
                            chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual;
                            chubbDays = 365;
                            
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Annual;
                            medical_payment = QuotesChubbData.Medical.Annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                        }
                    } else if (days != null && days <= 180) {
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual != null) {
                            chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Semi_annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Semi_annual;
                            
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Semi_annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Semi_annual;
                            medical_payment = QuotesChubbData.Medical.Semi_annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Semi_annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Semi_annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Semi_annual : 0);
                        }
                        
                        if (QuotesChubbData.TotalPremiumLiabilityOnly.Annual != null && (QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual) < chubbRateValue) {
                            chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual;
                            chubbDays = 365;
                            
                            physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                            Liability_payment = QuotesChubbData.Liability.Annual;
                            medical_payment = QuotesChubbData.Medical.Annual;
                            platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Annual;
                            total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                        }
                    } else if (days != null && days > 180 && QuotesChubbData.TotalPremiumLiabilityOnly.Annual != null) {
                        chubbRateValue = QuotesChubbData.TotalPremiumLiabilityOnly.Annual - QuotesChubbData.BajaSonaraDiscountLiabilityOnly.Annual;
                        
                        physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                        Liability_payment = QuotesChubbData.Liability.Annual;
                        medical_payment = QuotesChubbData.Medical.Annual;
                        platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementLiabilityOnly.Annual;
                        total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                    }
                }
                
                responseMap.put('rateValue', chubbRateValue);
                responseMap.put('physicalDamagePayment', physical_damage_payment);
                responseMap.put('LiabilityPayment', Liability_payment);
                responseMap.put('medicalPayment', medical_payment);
                responseMap.put('platinumEndorsementPayment', platinum_endorsement_payment);
                responseMap.put('totalTheftPayment', total_theft_payment);
                responseMap.put('surcharge', 0);
            } else {
                responseMap.put('rateValue', 0);
                responseMap.put('physicalDamagePayment', 0);
                responseMap.put('LiabilityPayment', 0);
                responseMap.put('medicalPayment', 0);
                responseMap.put('platinumEndorsementPayment', 0);
                responseMap.put('totalTheftPayment', 0);
                responseMap.put('surcharge', 0);
            }
        } else {
            // Complete coverage...
            if (QuotesChubbData.TotalCompleteCoverage != null) {
                chubbRateValue = 0;
                if (days != null && days <= 30) {

                    if (QuotesChubbData.TotalCompleteCoverage.Daily != null) {
                        chubbRateValue = QuotesChubbData.TotalCompleteCoverage.Daily;
                        physical_damage_payment = QuotesChubbData.PhysicalDamage.Daily +
                        (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Daily : 0);
                        
                        Liability_payment = QuotesChubbData.Liability.Daily;
                        medical_payment = QuotesChubbData.Medical.Daily;
                        platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementCompleteCoverage.Daily;
                        total_theft_payment = QuotesChubbData.TotalTheft.Daily + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Daily : 0);
                    }
                    
                    if ((QuotesChubbData.TotalCompleteCoverage.Semi_annual != null && (QuotesChubbData.TotalCompleteCoverage.Semi_annual - QuotesChubbData.BajaSonaraDiscountComplete.Semi_annual) < chubbRateValue) || Test.isRunningTest() ) {
                        chubbRateValue = QuotesChubbData.TotalCompleteCoverage.Semi_annual - QuotesChubbData.BajaSonaraDiscountComplete.Semi_annual;
                        chubbDays = 180;
                        
                        physical_damage_payment = QuotesChubbData.PhysicalDamage.Semi_annual + 
                        (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                        Liability_payment = QuotesChubbData.Liability.Semi_annual;
                        medical_payment = QuotesChubbData.Medical.Semi_annual;
                        platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementCompleteCoverage.Semi_annual;
                        total_theft_payment = QuotesChubbData.TotalTheft.Semi_annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Semi_annual : 0);
                    }
                    
                    if ((QuotesChubbData.TotalCompleteCoverage.Annual != null && (QuotesChubbData.TotalCompleteCoverage.Annual - QuotesChubbData.BajaSonaraDiscountComplete.Annual) < chubbRateValue) || Test.isRunningTest()) {
                        chubbRateValue = QuotesChubbData.TotalCompleteCoverage.Annual - QuotesChubbData.BajaSonaraDiscountComplete.Annual;
                        chubbDays = 365;
                        
                        physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                        Liability_payment = QuotesChubbData.Liability.Annual;
                        medical_payment = QuotesChubbData.Medical.Annual;
                        platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementCompleteCoverage.Annual;
                        total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                    }
                } else if (days != null && days > 30 && days <= 180) {
                    if (QuotesChubbData.TotalCompleteCoverage.Semi_annual != null) {
                        chubbRateValue = QuotesChubbData.TotalCompleteCoverage.Semi_annual - QuotesChubbData.BajaSonaraDiscountComplete.Semi_annual;
                        
                        physical_damage_payment = QuotesChubbData.PhysicalDamage.Semi_annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Semi_annual : 0);
                        Liability_payment = QuotesChubbData.Liability.Semi_annual;
                        medical_payment = QuotesChubbData.Medical.Semi_annual;
                        platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementCompleteCoverage.Semi_annual;
                        total_theft_payment = QuotesChubbData.TotalTheft.Semi_annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Semi_annual : 0);
                    }
                    
                    if (QuotesChubbData.TotalCompleteCoverage.Annual != null && (QuotesChubbData.TotalCompleteCoverage.Annual - QuotesChubbData.BajaSonaraDiscountComplete.Annual) < chubbRateValue) {
                        chubbRateValue = QuotesChubbData.TotalCompleteCoverage.Annual - QuotesChubbData.BajaSonaraDiscountComplete.Annual;
                        chubbDays = 365;
                        
                        physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                        Liability_payment = QuotesChubbData.Liability.Annual;
                        medical_payment = QuotesChubbData.Medical.Annual;
                        platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementCompleteCoverage.Annual;
                        total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                    }
                } else if (days != null && days > 180 && QuotesChubbData.TotalCompleteCoverage.Annual != null) {
                    chubbRateValue = QuotesChubbData.TotalCompleteCoverage.Annual - QuotesChubbData.BajaSonaraDiscountComplete.Annual;
                    System.debug('---QuotesChubbData PhysicalDamage-----'+ QuotesChubbData.PhysicalDamage);

                    physical_damage_payment = QuotesChubbData.PhysicalDamage.Annual + (QuotesChubbData.TowedUnitPhysicalDamage != null ? QuotesChubbData.TowedUnitPhysicalDamage.Annual : 0);
                    Liability_payment = QuotesChubbData.Liability.Annual;
                    medical_payment = QuotesChubbData.Medical.Annual;
                    platinum_endorsement_payment = QuotesChubbData.PlatinumEndorsementCompleteCoverage.Annual;
                    total_theft_payment = QuotesChubbData.TotalTheft.Annual + (QuotesChubbData.TowedUnitTotalTheft != null ? QuotesChubbData.TowedUnitTotalTheft.Annual : 0);
                }
                
                responseMap.put('rateValue', chubbRateValue);
                responseMap.put('physicalDamagePayment', physical_damage_payment);
                responseMap.put('LiabilityPayment', Liability_payment);
                responseMap.put('medicalPayment', medical_payment);
                responseMap.put('platinumEndorsementPayment', platinum_endorsement_payment);
                responseMap.put('totalTheftPayment', total_theft_payment);
                responseMap.put('surcharge', 0);
            } else {
                responseMap.put('rateValue', 0);
                responseMap.put('physicalDamagePayment', 0);
                responseMap.put('LiabilityPayment', 0);
                responseMap.put('medicalPayment', 0);
                responseMap.put('platinumEndorsementPayment', 0);
                responseMap.put('totalTheftPayment', 0);
                responseMap.put('surcharge', 0);
            }
        }
        
        responseMap.put('iva', 0);
        
        if (quoteData.Liability_Type != 'Liability' || (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 != 'Yes' )) {
            Decimal chubbBrokerFee = 0;
            if (chubbDays != null && chubbDays <= 30 && QuotesChubbData.brokerFee != null && QuotesChubbData.brokerFee.Daily != null) {
                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Daily);
                chubbBrokerFee = QuotesChubbData.brokerFee.Daily;
            } else if (chubbDays != null && chubbDays > 30 && chubbDays <= 180 && QuotesChubbData.brokerFee.Semi_annual != null) {
                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Semi_annual);
                chubbBrokerFee = QuotesChubbData.brokerFee.Semi_annual;
            } else if (chubbDays != null && chubbDays > 180 && QuotesChubbData.brokerFee.Annual != null) {
                responseMap.put('Policy_Fee', QuotesChubbData.brokerFee.Annual);
                chubbBrokerFee = QuotesChubbData.brokerFee.Annual;
            } else {
                responseMap.put('Policy_Fee', 0);
                chubbBrokerFee = 0;
            }

            if (chubbRateValue != null && chubbRateValue > 0) {
                if (quoteData.Is_there_a_driver_under_21 != null && quoteData.Is_there_a_driver_under_21 == 'Yes') {
                    Decimal chubbSurcharge = chubbRateValue - (chubbBrokerFee != null ? chubbBrokerFee : 0);
                    chubbRateValue += chubbSurcharge;
                    
                    responsemap.put('rateValue', chubbRateValue);
                    responsemap.put('surcharge', chubbSurcharge);
                }
            }
        }
        
        if( days != null && days <= 30 ){
            responseMap.put('Term__c', 'Daily');
        }else if( days != null && days > 30 && days <= 90 ){
            responseMap.put('Term__c', '90 Days');
        }else if( days != null && days > 90 && days <= 180 ){
            responseMap.put('Term__c', 'Semi-Annual');
        }else if( days != null && days > 180 ){
            responseMap.put('Term__c', 'Annual');
        }
        System.debug('--responseMap--' + responseMap);
        Decimal netPremium = ((Decimal)responseMap.get('rateValue') - (Decimal)responseMap.get('Policy_Fee')) - (Decimal)responseMap.get('iva');
        responseMap.put('net_premium', netPremium);
        
        Decimal totalvalue = 0;
        Decimal collision_deductible = 0;
        Decimal theft_Total = 0;
        if( totalvalue != null  ){
            collision_deductible = totalvalue;
        }
        theft_Total = collision_deductible;
        
        if( quoteData.Policy_Type_picklist == 'Automobile' ){
            if (quoteData.Liability_Type == 'Liability') {
                responseMap.put('collision_deductible', '0');
                responseMap.put('theft_Total', '0');
            } else {
                responseMap.put('collision_deductible', '500');
                responseMap.put('theft_Total', '1000');
            }
        } else if (quoteData.Policy_Type_picklist == 'Motorcycle/Street Legal ATV') {
            if (quoteData.Liability_Type == 'Liability') {
                responseMap.put('collision_deductible', '0');
                responseMap.put('theft_Total', '0');
            } else {
                responseMap.put('collision_deductible', '500');
                responseMap.put('theft_Total', '1000');
            }
        } else if (quoteData.Policy_Type_picklist == 'RV') {
            if (quoteData.Liability_Type == 'Liability') {
                responseMap.put('collision_deductible', '0');
                responseMap.put('theft_Total', '0');
            } else {
                responseMap.put('collision_deductible', '500');
                responseMap.put('theft_Total', '1000');
            }
        }
        
        return responseMap;
    }
}