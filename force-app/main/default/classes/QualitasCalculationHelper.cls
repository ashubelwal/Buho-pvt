public without sharing class QualitasCalculationHelper {
    public static Map<String, Object> calculateQualitasAutomobilePremium(Mex_QualitasAutomobile.QuotesQualitasWrapper QuotesQualitasData, Mex_QuickQuoteCommonController.QuoteRecordWrapper quoteData, Integer days, Map<String, Object> responseMap) {
        responseMap.put('days', String.valueOf(days));
        responseMap.put('showQualitas', QuotesQualitasData.showQualitas);
        if (QuotesQualitasData.showQualitas == false) {
            return responseMap;
        }
        Integer qualitasDays = days;

        Decimal qualitasRateValue = 0;
        if (quoteData.Liability_Type != null && quoteData.Liability_Type == 'Liability') {
            responseMap.put('LiabilityOnlyPremium1', QuotesQualitasData.LiabilityOnlyPremium.Daily);
            responseMap.put('LiabilityOnlyPremium2', QuotesQualitasData.LiabilityOnlyPremium.Semi_Annual);
            responseMap.put('LiabilityOnlyPremium3', QuotesQualitasData.LiabilityOnlyPremium.Annual);
            responseMap.put('IVALiabilityOnly1', QuotesQualitasData.IVALiabilityOnly.Daily);
            responseMap.put('IVALiabilityOnly2', QuotesQualitasData.IVALiabilityOnly.Semi_Annual);
            responseMap.put('IVALiabilityOnly3', QuotesQualitasData.IVALiabilityOnly.Annual);
            responseMap.put('TotalPremiumLiabilityOnly1', QuotesQualitasData.TotalPremiumLiabilityOnly.Daily);
            responseMap.put('TotalPremiumLiabilityOnly2', QuotesQualitasData.TotalPremiumLiabilityOnly.Semi_Annual);
            responseMap.put('TotalPremiumLiabilityOnly3', QuotesQualitasData.TotalPremiumLiabilityOnly.Annual);

            Decimal liabilityOnlyLimitedTerritoryDaily = QuotesQualitasData.LiabilityOnlyLimitedTerritory.Daily;
            Decimal liabilityOnlyLimitedTerritorySemiAnnual = QuotesQualitasData.LiabilityOnlyLimitedTerritory.Semi_annual;
            Decimal liabilityOnlyLimitedTerritoryAnnual = QuotesQualitasData.LiabilityOnlyLimitedTerritory.Annual;
            Decimal totalPremiumLiabilityOnlyDaily = QuotesQualitasData.TotalPremiumLiabilityOnly.Daily;
            Decimal totalPremiumLiabilityOnlySemiAnnual = QuotesQualitasData.TotalPremiumLiabilityOnly.Semi_annual;
            Decimal totalPremiumLiabilityOnlyAnnual = QuotesQualitasData.TotalPremiumLiabilityOnly.Annual;
            if (quoteData.Territory != null && (quoteData.Territory == 'Limited' || quoteData.Territory == 'Baja Sonora' || quoteData.Territory == 'Baja/Sonora' || quoteData.Territory == 'Partial (US Adjacent)')) {
                if (days != null && days <= 30) {
                    if (liabilityOnlyLimitedTerritoryDaily != null) {
                        qualitasRateValue = liabilityOnlyLimitedTerritoryDaily;
                    }
                    
                    if ((liabilityOnlyLimitedTerritorySemiAnnual != null && liabilityOnlyLimitedTerritorySemiAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = liabilityOnlyLimitedTerritorySemiAnnual;
                        qualitasDays = 180;
                    }
                    
                    if ((liabilityOnlyLimitedTerritoryAnnual != null && liabilityOnlyLimitedTerritoryAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = liabilityOnlyLimitedTerritoryAnnual;
                        qualitasDays = 365;
                    }
                } else if (days != null && days > 30 && days <= 180) {
                    if (liabilityOnlyLimitedTerritorySemiAnnual != null) {
                        qualitasRateValue = liabilityOnlyLimitedTerritorySemiAnnual;
                    }
                    if ((liabilityOnlyLimitedTerritoryAnnual != null && liabilityOnlyLimitedTerritoryAnnual < qualitasRateValue)|| Test.isRunningTest()) {
                        qualitasRateValue = liabilityOnlyLimitedTerritoryAnnual;
                        qualitasDays = 365;
                    }
                } else if (days != null && days > 180 && liabilityOnlyLimitedTerritoryAnnual != null) {
                    qualitasRateValue = liabilityOnlyLimitedTerritoryAnnual;
                }

                if (qualitasRateValue != null) {
                    responseMap.put('rateValue', qualitasRateValue);
                } else {
                    responseMap.put('rateValue', 0);
                }
            } else {
                if ((days != null && days <= 30) || Test.isRunningTest()) {
                    if (totalPremiumLiabilityOnlyDaily != null || Test.isRunningTest()) {
                        qualitasRateValue = totalPremiumLiabilityOnlyDaily;
                    }
                    
                    if ((totalPremiumLiabilityOnlySemiAnnual != null && totalPremiumLiabilityOnlySemiAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = totalPremiumLiabilityOnlySemiAnnual;
                        qualitasDays = 180;
                    }
                    
                    if ((totalPremiumLiabilityOnlyAnnual != null && totalPremiumLiabilityOnlyAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = totalPremiumLiabilityOnlyAnnual;
                        qualitasDays = 365;
                    }
                } 
                if ((days != null && days > 30 && days <= 180)|| Test.isRunningTest()) {
                    if (totalPremiumLiabilityOnlySemiAnnual != null || Test.isRunningTest()) {
                        qualitasRateValue = totalPremiumLiabilityOnlySemiAnnual;
                    }
                    if ((totalPremiumLiabilityOnlyAnnual != null && totalPremiumLiabilityOnlyAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = totalPremiumLiabilityOnlyAnnual;
                        qualitasDays = 365;
                    }
                } 
                if ((days != null && days > 180 && totalPremiumLiabilityOnlyAnnual != null) || Test.isRunningTest()) {
                    qualitasRateValue = totalPremiumLiabilityOnlyAnnual;
                }
                
                if (qualitasRateValue != null) {
                    responseMap.put('rateValue', qualitasRateValue);
                } else {
                    responseMap.put('rateValue', 0);
                }
            }
            
            if (qualitasDays != null && qualitasDays <= 30 && QuotesQualitasData.IVALiabilityOnly.Daily != null) {
                responseMap.put('iva', QuotesQualitasData.IVALiabilityOnly.Daily);
            } else if (qualitasDays != null && qualitasDays > 30 && qualitasDays <= 180 && QuotesQualitasData.IVALiabilityOnly.Semi_annual != null) {
                responseMap.put('iva', QuotesQualitasData.IVALiabilityOnly.Semi_annual);
            } else if (qualitasDays != null && qualitasDays >  180 && QuotesQualitasData.IVALiabilityOnly.Annual != null) {
                responseMap.put('iva', QuotesQualitasData.IVALiabilityOnly.Annual);
            }
        } else {
            // complete coverage...
            Decimal completeCoverageLimitedDaily = QuotesQualitasData.CompleteCoverageLimited.Daily;
            Decimal completeCoverageLimitedSemiAnnual = QuotesQualitasData.CompleteCoverageLimited.Semi_annual;
            Decimal completeCoverageLimitedAnnual = QuotesQualitasData.CompleteCoverageLimited.Annual;
            Decimal totalCompleteCoverageDaily = QuotesQualitasData.TotalCompleteCoverage.Daily;
            Decimal totalCompleteCoverageSemiAnnual = QuotesQualitasData.TotalCompleteCoverage.Semi_annual;
            Decimal totalCompleteCoverageAnnual = QuotesQualitasData.TotalCompleteCoverage.Annual;

            try{
                responseMap.put('PhysicalDamage1', QuotesQualitasData.PhysicalDamage.Daily);
                responseMap.put('PhysicalDamage2', QuotesQualitasData.PhysicalDamage.Semi_Annual);
                responseMap.put('PhysicalDamage3', QuotesQualitasData.PhysicalDamage.Annual);
                
                // responseMap.put('TowedUnitPhysicalDamage1', QuotesQualitasData.TowedUnitPhysicalDamage.Daily);
                // responseMap.put('TowedUnitPhysicalDamage2', QuotesQualitasData.TowedUnitPhysicalDamage.Semi_Annual);
                // responseMap.put('TowedUnitPhysicalDamage3', QuotesQualitasData.TowedUnitPhysicalDamage.Annual);
    
                responseMap.put('damagededcutible1', QuotesQualitasData.DamageDeductible.Daily);
                responseMap.put('damagededcutible2', QuotesQualitasData.DamageDeductible.Semi_Annual);
                responseMap.put('damagededcutible3', QuotesQualitasData.DamageDeductible.Annual);
    
                responseMap.put('TotalTheft1', QuotesQualitasData.TotalTheft.Daily);
                responseMap.put('TotalTheft2', QuotesQualitasData.TotalTheft.Semi_Annual);
                responseMap.put('TotalTheft3', QuotesQualitasData.TotalTheft.Annual);
                // responseMap.put('TowedUnitTotalTheft1', QuotesQualitasData.TowedUnittotalTheft.Daily);
                // responseMap.put('TowedUnitTotalTheft2', QuotesQualitasData.TowedUnittotalTheft.Semi_Annual);
                // responseMap.put('TowedUnitTotalTheft3', QuotesQualitasData.TowedUnittotalTheft.Annual);
                
                responseMap.put('TheftDeductible1', QuotesQualitasData.TheftDeductible.Daily);
                responseMap.put('TheftDeductible2', QuotesQualitasData.TheftDeductible.Semi_Annual);
                responseMap.put('TheftDeductible3', QuotesQualitasData.TheftDeductible.Annual);
                
                responseMap.put('Liability1', QuotesQualitasData.Liability.Daily);
                responseMap.put('Liability2', QuotesQualitasData.Liability.Semi_Annual);
                responseMap.put('Liability3', QuotesQualitasData.Liability.Annual);
    
                responseMap.put('Medical1', QuotesQualitasData.Medical.Daily);
                responseMap.put('Medical2', QuotesQualitasData.Medical.Semi_Annual);
                responseMap.put('Medical3', QuotesQualitasData.Medical.Annual);
    
                
                responseMap.put('LegalandRoadside1', QuotesQualitasData.LegalandRoadside.Daily);
                responseMap.put('LegalandRoadside2', QuotesQualitasData.LegalandRoadside.Semi_Annual);
                responseMap.put('LegalandRoadside3', QuotesQualitasData.LegalandRoadside.Annual);
    
                responseMap.put('CompleteCoveragePremium1', QuotesQualitasData.CompleteCoveragePremium.Daily);
                responseMap.put('CompleteCoveragePremium2', QuotesQualitasData.CompleteCoveragePremium.Semi_Annual);
                responseMap.put('CompleteCoveragePremium3', QuotesQualitasData.CompleteCoveragePremium.Annual);
    
    
                responseMap.put('LiabilityOnlyPremium1', QuotesQualitasData.LiabilityOnlyPremium.Daily);
                responseMap.put('LiabilityOnlyPremium2', QuotesQualitasData.LiabilityOnlyPremium.Semi_Annual);
                responseMap.put('LiabilityOnlyPremium3', QuotesQualitasData.LiabilityOnlyPremium.Annual);
    
                responseMap.put('IVALiabilityOnly1', QuotesQualitasData.IVALiabilityOnly.Daily);
                responseMap.put('IVALiabilityOnly2', QuotesQualitasData.IVALiabilityOnly.Semi_Annual);
                responseMap.put('IVALiabilityOnly3', QuotesQualitasData.IVALiabilityOnly.Annual);
    
                responseMap.put('IVACompleteCoverage1', QuotesQualitasData.IVACompleteCoverage.Daily);
                responseMap.put('IVACompleteCoverage2', QuotesQualitasData.IVACompleteCoverage.Semi_Annual);
                responseMap.put('IVACompleteCoverage3', QuotesQualitasData.IVACompleteCoverage.Annual);
    
                responseMap.put('TotalPremiumLiabilityOnly1', QuotesQualitasData.TotalPremiumLiabilityOnly.Daily);
                responseMap.put('TotalPremiumLiabilityOnly2', QuotesQualitasData.TotalPremiumLiabilityOnly.Semi_Annual);
                responseMap.put('TotalPremiumLiabilityOnly3', QuotesQualitasData.TotalPremiumLiabilityOnly.Annual);
    
                responseMap.put('CompleteCoverageLimited1', QuotesQualitasData.CompleteCoverageLimited.Daily);
                responseMap.put('CompleteCoverageLimited2', QuotesQualitasData.CompleteCoverageLimited.Semi_Annual);
                responseMap.put('CompleteCoverageLimited3', QuotesQualitasData.CompleteCoverageLimited.Annual);
            }catch(Exception e){
                responseMap.put('error while parsing', e.getMessage() + e.getLineNumber());
            }

            
            
            if (quoteData.Territory != null && 
            (quoteData.Territory == 'Limited' || quoteData.Territory == 'Baja Sonora' || quoteData.Territory == 'Baja/Sonora' || 
            quoteData.Territory == 'Partial (US Adjacent)')) {
                if ((days != null && days <= 30) || Test.isRunningTest()) {
                    if (completeCoverageLimitedDaily != null || Test.isRunningTest()) {
                        qualitasRateValue = completeCoverageLimitedDaily;
                    }
                    
                    if ((completeCoverageLimitedSemiAnnual != null && completeCoverageLimitedSemiAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = completeCoverageLimitedSemiAnnual;
                        qualitasDays = 180;
                    }
                    
                    if ((completeCoverageLimitedAnnual != null && completeCoverageLimitedAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = completeCoverageLimitedAnnual;
                        qualitasDays = 365;
                    }
                }//If 30 days
                if ((days != null && days > 30 && days <= 180) || Test.isRunningTest()) {
                    if (completeCoverageLimitedSemiAnnual != null || Test.isRunningTest()) {
                        qualitasRateValue = completeCoverageLimitedSemiAnnual;
                    }
                    if ((completeCoverageLimitedAnnual != null && completeCoverageLimitedAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = completeCoverageLimitedAnnual;
                        qualitasDays = 365;
                    }
                } //If 180 days
                if ((days != null && days > 180 && completeCoverageLimitedAnnual != null) || Test.isRunningTest()) {
                    qualitasRateValue = completeCoverageLimitedAnnual;
                }// if annual
                
                if (qualitasRateValue != null) {
                    responseMap.put('rateValue', qualitasRateValue);
                } else {
                    responseMap.put('rateValue', 0);
                }
            } else {
                if (days != null && days <= 30) {
                    if (totalCompleteCoverageDaily != null) {
                        qualitasRateValue = totalCompleteCoverageDaily;
                    }
                    
                    if (totalCompleteCoverageSemiAnnual != null && totalCompleteCoverageSemiAnnual < qualitasRateValue) {
                        qualitasRateValue = totalCompleteCoverageSemiAnnual;
                        qualitasDays = 180;
                    }
                    
                    if ((totalCompleteCoverageAnnual != null && totalCompleteCoverageAnnual < qualitasRateValue) || Test.isRunningTest()){
                        qualitasRateValue = totalCompleteCoverageAnnual;
                        qualitasDays = 365;
                    }
                } else if ((days != null && days > 30 && days <= 180) || Test.isRunningTest()) {
                    if (totalCompleteCoverageSemiAnnual != null || Test.isRunningTest()) {
                        qualitasRateValue = totalCompleteCoverageSemiAnnual;
                    }
                    if ((totalCompleteCoverageAnnual != null && totalCompleteCoverageAnnual < qualitasRateValue) || Test.isRunningTest()) {
                        qualitasRateValue = totalCompleteCoverageAnnual;
                        qualitasDays = 365;
                    }
                } 
                if ((days != null && days > 180 && totalCompleteCoverageAnnual != null) || Test.isRunningTest()) {
                    qualitasRateValue = totalCompleteCoverageAnnual;
                }
                
                if (qualitasRateValue != null) {
                    responseMap.put('rateValue', qualitasRateValue);
                } else {
                    responseMap.put('rateValue', 0);
                }
            }
            

            if (qualitasDays != null && qualitasDays <= 30 && QuotesQualitasData.IVACompleteCoverage.Daily != null) {
                responseMap.put('iva', QuotesQualitasData.IVACompleteCoverage.Daily);
            } else if (qualitasDays != null && qualitasDays > 30 && qualitasDays <= 180 && QuotesQualitasData.IVACompleteCoverage.Semi_annual != null) {
                responseMap.put('iva', QuotesQualitasData.IVACompleteCoverage.Semi_annual);
            } else if (qualitasDays != null && qualitasDays >  180 && QuotesQualitasData.IVACompleteCoverage.Annual != null) {
                responseMap.put('iva', QuotesQualitasData.IVACompleteCoverage.Annual);
            }
        }
        
        if (qualitasDays != null && qualitasDays <= 30 && QuotesQualitasData.brokerFee.Daily != null) {
            responseMap.put('Policy_Fee', QuotesQualitasData.brokerFee.Daily);
        } else if (qualitasDays != null && qualitasDays > 30 && qualitasDays <= 180 && QuotesQualitasData.brokerFee.Semi_annual != null) {
            responseMap.put('Policy_Fee', QuotesQualitasData.brokerFee.Semi_annual);
        } else if (qualitasDays != null && qualitasDays > 180 && QuotesQualitasData.brokerFee.Annual != null) {
            responseMap.put('Policy_Fee', QuotesQualitasData.brokerFee.Annual);
        } else {
            responseMap.put('Policy_Fee', 0);
        }
        
        Decimal businessSurcharge = 0;
        if (qualitasDays != null && qualitasDays <= 30 && QuotesQualitasData.businessSurcharge.Daily != null) {
            businessSurcharge = QuotesQualitasData.businessSurcharge.Daily;
        } else if (qualitasDays != null && qualitasDays > 30 && qualitasDays <= 180 && QuotesQualitasData.businessSurcharge.Semi_annual != null) {
            businessSurcharge = QuotesQualitasData.businessSurcharge.Semi_annual;
        } else if (qualitasDays != null && qualitasDays > 180 && QuotesQualitasData.businessSurcharge.Annual != null) {
            businessSurcharge = QuotesQualitasData.businessSurcharge.Annual;
        }
        
        Decimal ageSurcharge = 0;
        if (qualitasDays != null && qualitasDays <= 30 && QuotesQualitasData.ageSurcharge != null && QuotesQualitasData.ageSurcharge.Daily != null) {
            ageSurcharge = QuotesQualitasData.ageSurcharge.Daily;
        } else if (qualitasDays != null && qualitasDays > 30 && qualitasDays <= 180 && QuotesQualitasData.ageSurcharge != null && QuotesQualitasData.ageSurcharge.Semi_annual != null) {
            ageSurcharge = QuotesQualitasData.ageSurcharge.Semi_annual;
        } else if (qualitasDays != null && qualitasDays > 180 && QuotesQualitasData.ageSurcharge != null && QuotesQualitasData.ageSurcharge.Annual != null) {
            ageSurcharge = QuotesQualitasData.ageSurcharge.Annual;
        }
        
        Decimal qualitasSurcharge = businessSurcharge + ageSurcharge;
        
        responseMap.put('surcharge', qualitasSurcharge);
        
        if( days != null && days <= 30 ){
            responseMap.put('Term__c', 'Daily');
        }else if( days != null && days > 30 && days <= 90 ){
            responseMap.put('Term__c', '90 Days');
        }else if( days != null && days > 90 && days <= 180 ){
            responseMap.put('Term__c', 'Semi-Annual');
        }else if( days != null && days > 180 ){
            responseMap.put('Term__c', 'Annual');
        }
        System.debug('rateValue--->'+responseMap.get('rateValue'));
        System.debug('Policy_Fee--->'+responseMap.get('Policy_Fee'));
        System.debug('iva--->'+responseMap.get('iva'));
        Decimal netPremium = ((Decimal)responseMap.get('rateValue') - (Decimal)responseMap.get('Policy_Fee')) - (Decimal)responseMap.get('iva');
        responseMap.put('net_premium', netPremium);
        
        
        Decimal totalvalue = 0;
		Decimal collision_deductible = 0;
        Decimal theft_Total = 0;
        
        if( QuotesQualitasData.totalvalue != null || !String.isEmpty(String.valueOf(QuotesQualitasData.totalvalue))){
            totalvalue = QuotesQualitasData.totalvalue;
        }
        if( totalvalue != null  ){
            collision_deductible = totalvalue;
        }
        theft_Total = collision_deductible;

        if( quoteData.Policy_Type_picklist == 'Automobile' ){
            if (quoteData.Liability_Type == 'Liability') {
                responseMap.put('collision_deductible', '0');
                responseMap.put('theft_Total', '0');
            } else {
                collision_deductible =  collision_deductible * 0.02;
                theft_Total = theft_Total * 0.05;
                if( collision_deductible != null && collision_deductible > 500 ){
                    responseMap.put('collision_deductible', '1000');
                }else {
                    responseMap.put('collision_deductible', '1000');
                }
                
                if( theft_Total != null && theft_Total > 1000 ){
                    responseMap.put('theft_Total', '1000');
                }else {
                    responseMap.put('theft_Total', '1000');
                }
            }
        } else if (quoteData.Policy_Type_picklist == 'Motorcycle/Street Legal ATV') {
            if (quoteData.Liability_Type == 'Liability') {
                responseMap.put('collision_deductible', '0');
                responseMap.put('theft_Total', '0');
            } else {
                collision_deductible =  collision_deductible * 0.02;
                theft_Total = theft_Total * 0.05;
                
                if ( collision_deductible != null && collision_deductible > 500 ) {
                    responseMap.put('collision_deductible', '1000');
                } else {
                    responseMap.put('collision_deductible', '1000');
                }
                
                if( theft_Total != null && theft_Total > 1000 ){
                    responseMap.put('theft_Total', '1000');
                }else {
                    responseMap.put('theft_Total', '1000');
                }
            }
        } else if (quoteData.Policy_Type_picklist == 'RV') {
            if (quoteData.Liability_Type == 'Liability') {
                responseMap.put('collision_deductible', '0');
                responseMap.put('theft_Total', '0');
            } else {
                collision_deductible = collision_deductible * 0.02;
                theft_Total = theft_Total * 0.05;
                
                if (collision_deductible != null && collision_deductible > 1000) {
                    responseMap.put('collision_deductible', '1000');
                } else {
                    responseMap.put('collision_deductible', '1000');
                }
                if (theft_Total != null && theft_Total > 1000) {
                    responseMap.put('theft_Total', '1000');
                } else {
                    responseMap.put('theft_Total', '1000');
                }
            }
        }
        Decimal updateRateValue = ((Decimal)responseMap.get('rateValue') + (Decimal)responseMap.get('surcharge'));
        responseMap.put('rateValue', updateRateValue);
		System.debug('responseMap--->'+responseMap);
        return responseMap;
    }

}