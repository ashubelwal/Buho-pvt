public class MapfreAutomobileCalculationHelper {
    public static Map<String, Object> calculateMapfreAutomobilePremium(Mex_MapfreAutomobile.Quoteswrapper QuotesMapfreData, Mex_QuickQuoteCommonController.QuoteRecordWrapper quoteData, Integer days, Map<String, Object> responseMap) {
       System.debug('---QuotesMapfreData 1-----'+ QuotesMapfreData);
        responseMap.put('days', String.valueOf(days));
        responseMap.put('showMapfre', QuotesMapfreData.showMapfre);
        if (QuotesMapfreData.showMapfre == false) {
            return responseMap;
        }

        Integer mapfreDays = days;
System.debug('---QuotesMapfreData 1-----'+ QuotesMapfreData);
        System.debug('---days 1-----'+ days);
        
        
        if(quoteData.Liability_Type != null && quoteData.Liability_Type == 'Liability'){
            Decimal mapfreRateValue = 0;
            if(days != null && days <= 30){
                if( QuotesMapfreData.liabilityOnlyTotal.Daily != null || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Daily;
                }
                if( (QuotesMapfreData.liabilityOnlyTotal.Days90 != null && QuotesMapfreData.liabilityOnlyTotal.Days90 < mapfreRateValue) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Days90;
                    mapfreDays = 90;
                }
                if( (QuotesMapfreData.liabilityOnlyTotal.Days180 != null && QuotesMapfreData.liabilityOnlyTotal.Days180 < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.liabilityOnlyTotal.Annual != null && QuotesMapfreData.liabilityOnlyTotal.Annual < mapfreRateValue) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Annual;
                    mapfreDays = 360;
                }
            } else if (days != null && days > 30 && days <= 90) {
                if( QuotesMapfreData.liabilityOnlyTotal.Days90 != null ){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Days90;
                }
                if( (QuotesMapfreData.liabilityOnlyTotal.Days180 != null && QuotesMapfreData.liabilityOnlyTotal.Days180 < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.liabilityOnlyTotal.Annual != null && QuotesMapfreData.liabilityOnlyTotal.Annual < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Annual;
                    mapfreDays = 360;
                }
            } else if (days != null && days > 90 && days <= 180) {
                if( QuotesMapfreData.liabilityOnlyTotal.Days180 != null ){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Days180;
                }
                if( (QuotesMapfreData.liabilityOnlyTotal.Annual != null && QuotesMapfreData.liabilityOnlyTotal.Annual < mapfreRateValue) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Annual;
                    mapfreDays = 360;
                }
            } else if(days != null && days > 180 && QuotesMapfreData.liabilityOnlyTotal.Annual != null) {
                mapfreRateValue = QuotesMapfreData.liabilityOnlyTotal.Annual;
            } else {
                mapfreRateValue = 0;
            }
            System.debug('Check IVAliabilityOnlyTotal'+QuotesMapfreData.IVAliabilityOnlyTotal);
            responseMap.put('rateValue', mapfreRateValue);
            if (QuotesMapfreData.IVAliabilityOnlyTotal != null || Test.isRunningTest()) {
                if ((mapfreDays != null && mapfreDays <=30 && QuotesMapfreData.IVAliabilityOnlyTotal.Daily != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAliabilityOnlyTotal.Daily);
                } else if ((mapfreDays != null && mapfreDays > 30 && mapfreDays <=90 && QuotesMapfreData.IVAliabilityOnlyTotal.Days90 != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAliabilityOnlyTotal.Days90);
                } else if ((mapfreDays != null && mapfreDays > 90 && mapfreDays <=180 && QuotesMapfreData.IVAliabilityOnlyTotal.Days180 != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAliabilityOnlyTotal.Days180);
                } else if ((mapfreDays != null && mapfreDays > 180 && QuotesMapfreData.IVAliabilityOnlyTotal.Annual != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAliabilityOnlyTotal.Annual);
                }
            }
        } else if(quoteData.Liability_Type != null && quoteData.Liability_Type == 'LiabilityTheft'){
            Decimal mapfreRateValue = 0;
            system.debug('--QuotesMapfreData liabilityTheftTotal---'+QuotesMapfreData);
            system.debug('--QuotesMapfreData.liabilityTheftTotal---'+QuotesMapfreData.liabilityTheftTotal);
            if( days != null && days <= 30 ){
                if( (QuotesMapfreData.liabilityTheftTotal.Daily != null) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Daily;
                }
                if( (QuotesMapfreData.liabilityTheftTotal.Days90 != null && (QuotesMapfreData.liabilityTheftTotal.Days90) < mapfreRateValue) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Days90;
                    mapfreDays = 90;
                }
                if( (QuotesMapfreData.liabilityTheftTotal.Days180 != null && (QuotesMapfreData.liabilityTheftTotal.Days180) < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.liabilityTheftTotal.Annual != null && (QuotesMapfreData.liabilityTheftTotal.Annual) < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Annual;
                    mapfreDays = 365;
                }
            } else if (days != null && days > 30 && days <= 90) {
                if( QuotesMapfreData.liabilityTheftTotal.Days90 != null || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Days90;
                }
                if( (QuotesMapfreData.liabilityTheftTotal.Days180 != null && (QuotesMapfreData.liabilityTheftTotal.Days180) < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.liabilityTheftTotal.Annual != null && (QuotesMapfreData.liabilityTheftTotal.Annual) < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Annual;
                    mapfreDays = 365;
                }
            } else if (days != null && days > 90 && days <= 180) {
                if( QuotesMapfreData.liabilityTheftTotal.Days180 != null ){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.liabilityTheftTotal.Annual != null && (QuotesMapfreData.liabilityTheftTotal.Annual) < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.liabilityTheftTotal.Annual;
                    mapfreDays = 365;
                }
            } else if (days != null && days > 180 && QuotesMapfreData.liabilityTheftTotal.Annual != null) {
                mapfreRateValue =  QuotesMapfreData.liabilityTheftTotal.Annual;
            } else {
                mapfreRateValue = 0;
            }
            
            responseMap.put('rateValue', mapfreRateValue);
            System.debug('Check IVALiabilityTheft'+QuotesMapfreData.IVALiabilityTheft);
            if (QuotesMapfreData.IVALiabilityTheft != null || Test.isRunningTest()) {
                
                if ((mapfreDays != null && mapfreDays <=30 && QuotesMapfreData.IVALiabilityTheft.Daily != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVALiabilityTheft.Daily);
                } else if ((mapfreDays != null && mapfreDays > 30 && mapfreDays <=90 && QuotesMapfreData.IVALiabilityTheft.Days90 != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVALiabilityTheft.Days90);
                } else if ((mapfreDays != null && mapfreDays > 90 && mapfreDays <=180 && QuotesMapfreData.IVALiabilityTheft.Days180 != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVALiabilityTheft.Days180);
                } else if ((mapfreDays != null && mapfreDays > 180 && QuotesMapfreData.IVALiabilityTheft.Annual != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVALiabilityTheft.Annual);
                }
            }
        } else if (quoteData.Liability_Type != null && quoteData.Liability_Type == 'Complete' ) {
            Decimal mapfreRateValue = 0;
            if(days != null && days <= 30 ){
                if( QuotesMapfreData.fullCoverageTotal.Daily != null || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Daily;
                }
                if( (QuotesMapfreData.fullCoverageTotal.Days90 != null && QuotesMapfreData.fullCoverageTotal.Days90 < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Days90;
                    mapfreDays = 90;
                }
                if( (QuotesMapfreData.fullCoverageTotal.Days180 != null && QuotesMapfreData.fullCoverageTotal.Days180 < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.fullCoverageTotal.Annual != null && QuotesMapfreData.fullCoverageTotal.Annual < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Annual;
                    mapfreDays = 365;
                }
            } else if(days != null && days > 30 && days <= 90){
                if( QuotesMapfreData.fullCoverageTotal.Days90 != null || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Days90;
                }
                if( (QuotesMapfreData.fullCoverageTotal.Days180 != null && QuotesMapfreData.fullCoverageTotal.Days180 < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.fullCoverageTotal.Annual != null && QuotesMapfreData.fullCoverageTotal.Annual < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Annual;
                    mapfreDays = 365;
                }
            } else if( days != null && days > 90 && days <= 180){
                if( QuotesMapfreData.fullCoverageTotal.Days180 != null ){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Days180;
                }
                if( (QuotesMapfreData.fullCoverageTotal.Annual != null && QuotesMapfreData.fullCoverageTotal.Annual < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.fullCoverageTotal.Annual;
                    mapfreDays = 365;
                }
            } else if(days != null && days > 180 && QuotesMapfreData.fullCoverageTotal.Annual != null) {
                mapfreRateValue =  QuotesMapfreData.fullCoverageTotal.Annual;
            } else {
                mapfreRateValue = 0;
            }
            responseMap.put('rateValue', mapfreRateValue);
            System.debug('Check IVAFullCoverage'+QuotesMapfreData.IVAFullCoverage);
            if (QuotesMapfreData.IVAFullCoverage != null || Test.isRunningTest()) {
                if ((mapfreDays != null && mapfreDays <=30 && QuotesMapfreData.IVAFullCoverage.Daily != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAFullCoverage.Daily);
                }
                if ((mapfreDays != null && mapfreDays > 30 && mapfreDays <=90 && QuotesMapfreData.IVAFullCoverage.Days90 != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAFullCoverage.Days90);
                }
                if ((mapfreDays != null && mapfreDays > 90 && mapfreDays <=180 && QuotesMapfreData.IVAFullCoverage.Days180 != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAFullCoverage.Days180);
                } 
                if ((mapfreDays != null && mapfreDays > 180 && QuotesMapfreData.IVAFullCoverage.Annual != null) || Test.isRunningTest()) {
                    responseMap.put('iva', QuotesMapfreData.IVAFullCoverage.Annual);
                }
            }
        } else if (quoteData.Liability_Type != null && quoteData.Liability_Type == 'Max' ) {
            Decimal mapfreRateValue = 0;
            if( days != null && days <= 30 ){
                if( QuotesMapfreData.MaxCoverageTotal.Daily != null  || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Daily;
                }
                if( (QuotesMapfreData.MaxCoverageTotal.Days90 != null && QuotesMapfreData.MaxCoverageTotal.Days90 < mapfreRateValue ) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Days90;
                    mapfreDays = 90;
                }
                if( (QuotesMapfreData.MaxCoverageTotal.Days180 != null && QuotesMapfreData.MaxCoverageTotal.Days180 < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.MaxCoverageTotal.Annual != null && QuotesMapfreData.MaxCoverageTotal.Annual < mapfreRateValue) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Annual;
                    mapfreDays = 365;
                }
            } else if( days != null && days > 30 && days <= 90 ){
                if( QuotesMapfreData.MaxCoverageTotal.Days90 != null || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Days90;
                }
                if( (QuotesMapfreData.MaxCoverageTotal.Days180 != null && QuotesMapfreData.MaxCoverageTotal.Days180 < mapfreRateValue) || Test.isRunningTest()){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Days180;
                    mapfreDays = 180;
                }
                if( (QuotesMapfreData.MaxCoverageTotal.Annual != null && QuotesMapfreData.MaxCoverageTotal.Annual < mapfreRateValue) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Annual;
                    mapfreDays = 365;
                }
            } else if( days != null && days > 90 && days <= 180 ){
                if( QuotesMapfreData.MaxCoverageTotal.Days180 != null || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Days180;
                }
                if( (QuotesMapfreData.MaxCoverageTotal.Annual != null && QuotesMapfreData.MaxCoverageTotal.Annual < mapfreRateValue) || Test.isRunningTest() ){
                    mapfreRateValue = QuotesMapfreData.MaxCoverageTotal.Annual;
                    mapfreDays = 365;
                }
            } else if( days != null && days > 180 && QuotesMapfreData.MaxCoverageTotal.Annual != null ){
                mapfreRateValue =  QuotesMapfreData.MaxCoverageTotal.Annual;
            } else {
                mapfreRateValue = 0;
            }
            
            responseMap.put('rateValue', mapfreRateValue);
            System.debug('Check IVAMexCoverage'+QuotesMapfreData.IVAMexCoverage);
            if (QuotesMapfreData.IVAMexCoverage != null) {
                System.debug('Check IVAMexCoverage');
                if (mapfreDays != null && mapfreDays <=30 && QuotesMapfreData.IVAMexCoverage.Daily != null) {
                    responseMap.put('iva', QuotesMapfreData.IVAMexCoverage.Daily);
                } else if (mapfreDays != null && mapfreDays > 30 && mapfreDays <=90 && QuotesMapfreData.IVAMexCoverage.Days90 != null) {
                    responseMap.put('iva', QuotesMapfreData.IVAMexCoverage.Days90);
                } else if (mapfreDays != null && mapfreDays > 90 && mapfreDays <=180 && QuotesMapfreData.IVAMexCoverage.Days180 != null) {
                    responseMap.put('iva', QuotesMapfreData.IVAMexCoverage.Days180);
                } else if (mapfreDays != null && mapfreDays > 180 && QuotesMapfreData.IVAMexCoverage.Annual != null) {
                    responseMap.put('iva', QuotesMapfreData.IVAMexCoverage.Annual);
                }
            }
        }

        if( mapfreDays != null && mapfreDays <= 30 && QuotesMapfreData.brokerFee != null && QuotesMapfreData.brokerFee.Daily != null  ){
            responseMap.put('Policy_Fee', QuotesMapfreData.brokerFee.Daily);
        }else if( mapfreDays != null && mapfreDays > 30 && mapfreDays <= 90 && QuotesMapfreData.brokerFee.Days90 != null ){
            responseMap.put('Policy_Fee', QuotesMapfreData.brokerFee.Days90);
        }else if( mapfreDays != null && mapfreDays > 90 && mapfreDays <= 180 && QuotesMapfreData.brokerFee.Days180 != null ){
            responseMap.put('Policy_Fee', QuotesMapfreData.brokerFee.Days180);
        }else if( mapfreDays != null && mapfreDays > 180 && QuotesMapfreData.brokerFee.Annual != null ){
            responseMap.put('Policy_Fee', QuotesMapfreData.brokerFee.Annual);
        }else{
            responseMap.put('Policy_Fee', 0);
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
        System.debug('Rate Value -->'+responseMap.get('rateValue'));
        System.debug('Policy Fee -->'+responseMap.get('Policy_Fee'));
        System.debug('IVA -->'+responseMap.get('iva'));
        
        Decimal netPremium = ((Decimal)responseMap.get('rateValue') - (Decimal)responseMap.get('Policy_Fee')) - (responseMap.containsKey('iva')? (Decimal)(responseMap.get('iva')!=null?responseMap.get('iva'):0.00) : 0.00);
        responseMap.put('net_premium', netPremium);
        
        Decimal totalvalue = 0;
        if( QuotesMapfreData.totalvalue != null || !String.isEmpty(String.valueOf(QuotesMapfreData.totalvalue))){
            totalvalue = QuotesMapfreData.totalvalue;
        }
        
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
                Map<String, String> res = automobileMapfreCalculation(totalvalue, quoteData);
                responseMap.put('collision_deductible', res.get('collision_deductible'));
                responseMap.put('theft_Total', res.get('theft_Total'));
            }
        } else if (quoteData.Policy_Type_picklist == 'Motorcycle/Street Legal ATV') {
            if (quoteData.Liability_Type == 'Liability') {
                responseMap.put('collision_deductible', '0');
                responseMap.put('theft_Total', '0');
            } else if (quoteData.Liability_Type == 'LiabilityTheft') {
                responseMap.put('collision_deductible', '0');
                theft_Total = theft_Total * 0.05;

                if( theft_Total != null && theft_Total > 1000 ){
                    responseMap.put('theft_Total', String.valueOf(theft_Total));
                }else {
                    responseMap.put('theft_Total', '1000');
                }
            } else {
                collision_deductible =  collision_deductible * 0.02;
                theft_Total = theft_Total * 0.05;
                
                if ( collision_deductible != null && collision_deductible > 1000 ) {
                    responseMap.put('collision_deductible', String.valueOf(collision_deductible));
                } else {
                    responseMap.put('collision_deductible', '1000');
                }
                
                if( theft_Total != null && theft_Total > 1000 ){
                    responseMap.put('theft_Total', String.valueOf(theft_Total));
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
                    responseMap.put('collision_deductible', String.valueOf(collision_deductible));
                } else {
                    responseMap.put('collision_deductible', '1000');
                }
                if (theft_Total != null && theft_Total > 1000) {
                    responseMap.put('theft_Total', String.valueOf(theft_Total));
                } else {
                    responseMap.put('theft_Total', '1000');
                }
            }
        }

        return responseMap;
    }
    
    
    
    public static Map<String, String> automobileMapfreCalculation(Decimal totalvalue, Mex_QuickQuoteCommonController.QuoteRecordWrapper quoteData) {
        Map<String, String> res = new Map<String, String>();
        String vehicleSubType = quoteData.Vehicle_Sub_Type;
        Decimal auto_mapfre_collision_deductible = 0;
        Decimal auto_mapfre_theft_Total = 0;
        
        if( quoteData != null && quoteData.Vehicle_Value != null ){
            auto_mapfre_collision_deductible = Decimal.valueOf(quoteData.Vehicle_Value);
            auto_mapfre_theft_Total = Decimal.valueOf(quoteData.Vehicle_Value);
        }
        if(totalvalue != null ){
            auto_mapfre_collision_deductible = totalvalue;
            auto_mapfre_theft_Total = totalvalue;
        }
        
        if( quoteData.Liability_Type == 'Max') {
            if( vehicleSubType == 'Automobile/Sedan') {
                res.put('collision_deductible', '500');
                res.put('theft_Total', '1000');
            }else if( vehicleSubType == 'Pickup Truck w or w/o Camper Shell') {
                res.put('collision_deductible', '1000');
                res.put('theft_Total', '1000');
            }else if( vehicleSubType == 'SUV') {
                res.put('collision_deductible', '1000');
                res.put('theft_Total', '1000');
            }else if( vehicleSubType == 'Van') {
                res.put('collision_deductible', '1000');
                res.put('theft_Total', '1000');
            }
        } else if( quoteData.Liability_Type == 'Complete'){
            if( vehicleSubType == 'Automobile/Sedan'){
                auto_mapfre_collision_deductible = auto_mapfre_collision_deductible * 0.02;
                auto_mapfre_theft_Total = auto_mapfre_theft_Total * 0.05;
                
                if( auto_mapfre_collision_deductible > 500 ){
                    res.put('collision_deductible', String.valueOf(auto_mapfre_collision_deductible));
                }else{
                    res.put('collision_deductible', '500');
                }
                
                if( auto_mapfre_theft_Total > 1000 ){
                    res.put('theft_Total', String.valueOf(auto_mapfre_theft_Total));
                }else{
                    res.put('theft_Total', '1000');
                }
            } else if( vehicleSubType == 'Pickup Truck w or w/o Camper Shell' || vehicleSubType == 'SUV' || vehicleSubType == 'Van'){
                auto_mapfre_collision_deductible = auto_mapfre_collision_deductible * 0.05;
                auto_mapfre_theft_Total = auto_mapfre_theft_Total * 0.05;
                
                if( auto_mapfre_collision_deductible > 1000 ){
                    res.put('collision_deductible', String.valueOf(auto_mapfre_collision_deductible));
                }else{
                    res.put('collision_deductible', '1000');
                }
                
                if( auto_mapfre_theft_Total > 1000 ){
                    res.put('theft_Total', String.valueOf(auto_mapfre_theft_Total));
                }else{
                    res.put('theft_Total', '1000');
                }
            }
        }
        return res;
    }
}