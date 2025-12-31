public without sharing class CalculateCoverage {
    private static Map<String, Vendor__c> cachedVendors = new Map<String, Vendor__c>();
    private static List<Term_Mapping__mdt> termMetadataRecords = [SELECT Term__c,Value__c FROM Term_Mapping__mdt];
    private static List<String> vendors = new List<String>();
    
    public static Boolean isFeatureEnabled = false;  
    
    @AuraEnabled
    public static Map<String,Map<String,String>> calculateTotalCoverage(String jsonString){
        Map<String,Map<String,String>> responseDataMap =  new Map<String,Map<String,String>>();
        try{
            if(isFeatureEnabled){
                return generateMockCoverage();
            }
            System.debug('Cached Vendors'+ cachedVendors);
            jsonString = processVehicleValue(jsonString);
            System.debug('Updated JSON String'+jsonstring);
            //String jsonString = '[{"userDetails":{"Email":"atul.rai@cloudanalogy.com","FirstName":"Adarsh","LastName":"Kumar","countryCode":"+1","Phone":"07979830325"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"Rental__c":true,"Electric_Hybrid__c":true,"is_there_a_driver_under_21__c":false,"salvage_vehicle__c":false,"Coverage__c":false,"isTowing":true,"Liability__c":100000,"Medical__c":"2000/10000","towunits":{"0":{"type":"Type 1","Towed_Unit_Value__c":1000,"Days_in_Tow__c":"180"},"1":{"type":"Type 2","Towed_Unit_Value__c":"2000","Days_in_Tow__c":"180"}},"Vehicle_sub_type__c":"Pick Up","Year__c":"2023","Make":"Aston Martin","Model":"Wrangler","Value__c":"15000"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-02-07","End_Date_for_Coverage__c":"2026-02-07","dateRange":"2025-02-07 to 2026-02-07","Start_Time__c":"1:00 AM","Gold__c":true}},{"territory":{"Territory__c":"Limited"}}]';
            for(String vendor : vendors){
                Map<String,String> recievedData = new Map<String,String>();
                if(cachedVendors.containsKey(vendor)){
                    recievedData.put('PropertyDamage',String.valueOf(PropertyDamageCalculation.calculatePropertyDamage(jsonString,vendor,cachedVendors.get(vendor), termMetadataRecords).get('PropertyDamage')));
                    recievedData.put('TowedPropertyDamage',String.valueOf(TowedPropertyDamageCalculation.calculateTowedPropertyDamage(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords).get('TowedPropertyDamage')));
                    recievedData.put('TotalTheft',String.valueOf(TotalTheftCalculation.calculateTotalTheft(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords).get('TotalTheft')));
                    recievedData.put('TowedTotalTheft',String.valueOf(TowedTotalTheftCalculation.calculateTowedTotalTheftCalculation(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords).get('TowedTotalTheft')));
                    recievedData.put('Liability',String.valueOf(LiabilityCalculation.calculateLiability(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords).get('Liability')));
                    recievedData.put('Medical',String.valueOf(MedicalCalculation.calculateMedical(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords).get('Medical')));
                    Map<String,Object> roadsideCalculationData = RoadsideTravelCalculation.calculateRoadsideTravel(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords);
                    recievedData.put('Legal', String.valueOf(roadsideCalculationData.get('Legal')));
                    recievedData.put('Roadside', String.valueOf(roadsideCalculationData.get('Roadside')));
                    recievedData.put('TravelAssist', String.valueOf(roadsideCalculationData.get('TravelAssist')));
                    recievedData.put('AirplaneTickets', String.valueOf(roadsideCalculationData.get('AirplaneTickets')));
                    recievedData.put('PartialTheft', String.valueOf(roadsideCalculationData.get('PartialTheft')));
                    recievedData.put('RentalCar', String.valueOf(roadsideCalculationData.get('RentalCar')));
                    recievedData.put('RoadsideTravel', String.valueOf(roadsideCalculationData.get('RoadsideTravel')));
                    Map<String,Object> vehicleSurchargeCalculationData = CalculateSurchargeVehicleType.CalculateSurchargeVehicleType(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData);
                    recievedData.put('SurchargeVehicleTypes',String.valueOf(vehicleSurchargeCalculationData.get('SurchargeVehicleTypes')));
                    recievedData.put('LiabilityWithTerritoryDiscount',String.valueOf(vehicleSurchargeCalculationData.get('LiabilityWithTerritoryDiscount')));
                    recievedData.put('MedicalWithTerritoryDiscount',String.valueOf(vehicleSurchargeCalculationData.get('MedicalWithTerritoryDiscount')));
                    recievedData.put('Platinum',String.valueOf(PlatinumCalculation.calculatePlatinum(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('Platinum')));
                    recievedData.put('NetFirst',String.valueOf(FirstNetCalculation.calculateTotal(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('NetFirst')));
                    recievedData.put('Max',String.valueOf(MaxCalculation.calculateMax(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('Max')));
                    recievedData.put('Gold',String.valueOf(GoldCalculation.calculateGold(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('Gold')));
                    recievedData.put('NetSecond',String.valueOf(SecondNetCalculation.calculateTotal(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('NetSecond')));
                    //recievedData.put('SurchargeVehicleTypes',String.valueOf(CalculateSurchargeVehicleType.CalculateSurchargeVehicleType(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('SurchargeVehicleTypes')));
                    recievedData.put('SurchargeRental',String.valueOf(SurchargeRentalCalculation.calculateSurchargeRental(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('SurchargeRental')));
                    recievedData.put('SurchargeHighRisk',String.valueOf(SurchargeHighRiskCalculation.calculateSurchargeHighRisk(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('SurchargeHighRisk')));
                    recievedData.put('SurchargeAge',String.valueOf(SurchargeAgeCalculation.calculateSurchargeAge(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('SurchargeAge')));
                    recievedData.put('SurchargeElectricHybrid',String.valueOf(SurchargeElectricHybridCalculation.calculateSurchargeElectricHybrid(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('SurchargeElectricHybrid')));
                    recievedData.put('SurchargeBusiness',String.valueOf(SurchargeBusinessCalculation.calculateSurchargeBusiness(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('SurchargeBusiness')));
                    recievedData.put('TotalSurcharges',String.valueOf(TotalSurchargesCalculation.calculateTotalSurcharges(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('TotalSurcharges')));
                    recievedData.put('NetThird',String.valueOf(ThirdNetCalculation.calculateNetThird(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('NetThird')));
                    recievedData.put('TerritoryDiscount',String.valueOf(TerritoryDiscountCalculation.calculateTerritoryDiscount(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('TerritoryDiscount')));
                    recievedData.put('OtherDiscount',String.valueOf(OtherDiscountCalculation.calculateOtherDiscount(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('OtherDiscount')));
                    recievedData.put('NetFourth',String.valueOf(FourthNetCalculation.calculateNetFourth(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('NetFourth')));
                    recievedData.put('IVA',String.valueOf(IVACalculation.calculateIVA(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('IVA')));
                    recievedData.put('BrokerFee',String.valueOf(BrokerFeeCalculation.calculateBrokerFee(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('BrokerFee')));
                    recievedData.put('AgentFee',String.valueOf(AgentFeeCalculation.calculateAgentFee(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('AgentFee')));
                    recievedData.put('Total',String.valueOf(TotalCalculation.calculateTotal(jsonString,vendor,cachedVendors.get(vendor),termMetadataRecords,recievedData).get('Total')));
                    recievedData.put('Is_Gold__c',String.valueOf(cachedVendors.get(vendor).get('Is_Gold__c')));
                    recievedData.put('Is_Max__c',String.valueOf(cachedVendors.get(vendor).get('Is_Max__c')));
                    recievedData.put('Is_Platinum__c',String.valueOf(cachedVendors.get(vendor).get('Is_Platinum__c'))); 
                    recievedData.put('TermAndConditionENG',String.valueOf(cachedVendors.get(vendor).get('Term_And_Condition_URL_ENG__c'))); 
                    recievedData.put('TermAndConditionSPN',String.valueOf(cachedVendors.get(vendor).get('Term_And_Condition_URL_SPAINISH__c'))); 
                    responseDataMap.put(vendor,recievedData);
                }
            }
            
            
            System.debug('Repsonse data'+JSON.serialize(responseDataMap));
        } catch(Exception e){
            CustomErrorExceptionHandlerException.LogException(e);
            System.debug('Exception at:'+e.getLineNumber()+e.getMessage());
            throw new AuraHandledException('Error' + e.getLineNumber()+e.getMessage());
        }
        return responseDataMap;
    }


public static String processVehicleValue(String jsonData) {
        try {
            // Parse the JSON string into an Object
            List<Object> parsedData = (List<Object>) JSON.deserializeUntyped(jsonData);

            for (Object item : parsedData) {
                Map<String, Object> dataMap = (Map<String, Object>) item;

                if (dataMap.containsKey('vehicleDetails')) {
                    Map<String, Object> vehicleDetails = (Map<String, Object>) dataMap.get('vehicleDetails');

                    if (vehicleDetails.containsKey('Value__c')) {
                        Object rawValue = vehicleDetails.get('Value__c');
                        Decimal value;

                        // Convert to Decimal safely
                        if (rawValue instanceof String) {
                            value = Decimal.valueOf((String) rawValue);
                        } else if (rawValue instanceof Integer) {
                            value = Decimal.valueOf((Integer) rawValue);
                        } else if (rawValue instanceof Decimal) {
                            value = (Decimal) rawValue;
                        } else {
                            continue; // skip unknown types
                        }

                        // Apply transformation rules
                        if (value < 0) {
                            value = value.abs();
                        }

                        value = Math.floor(value); // remove decimals

                        if (value > 0 && value < 1000) {
                            value = 0;
                        } else if (value >= 1000 && value < 2000) {
                            value = 1000;
                        } else {
                            // Round down to nearest 1000 (e.g., 3100 → 3000)
                            Integer rounded = (Integer)(value / 1000);
                            value = rounded * 1000;
                        }

                        vehicleDetails.put('Value__c', String.valueOf(value));
                    }
                }
            }

            // Serialize the modified object back to JSON string
            return JSON.serialize(parsedData);
        } catch (Exception e) {
            System.debug('Error while processing vehicle value: ' + e.getMessage());
            return null;
        }
    }
    
    
    static {
        
        // Query the custom metadata type
        List<Vendor_List__mdt> vendorMetadataList = [SELECT MasterLabel FROM Vendor_List__mdt];
        
        // Loop through the results and store labels in the list
        for (Vendor_List__mdt vendor : vendorMetadataList) {
            vendors.add(vendor.MasterLabel);
        }
        
        // Debug the output
        System.debug('Vendor Labels: ' + vendors);
        
        if (!vendors.isEmpty()) {
            // 1. Dynamically retrieve all Vendor__c fields
            Map<String, Schema.SObjectField> fields = Schema.SObjectType.Vendor__c.fields.getMap();
            List<String> fieldNames = new List<String>(fields.keySet());
            
            // 2. Build query with dynamic fields and vendor filter
            String query = 'SELECT ' + String.join(fieldNames, ', ') +
                ' FROM Vendor__c WHERE Name IN :vendors'; // Use WHERE instead of LIMIT
            
            // 3. Execute query and cache results
            for (Vendor__c vendor : Database.query(query)) {
                cachedVendors.put(vendor.Name, vendor);
            }
        }
        System.debug('Cached Vendors'+ cachedVendors);
    }
    
    // Get all cached vendors
    public static Map<String, Vendor__c> getVendors() {
        return cachedVendors;
    }
    
    // Get a vendor by name
    public static Vendor__c getVendor(String vendorName) {
        return cachedVendors.get(vendorName);
    }

    @AuraEnabled
    public static Map<String, Map<String, String>> generateMockCoverage() {
        Map<String, Map<String, String>> responseDataMap = new Map<String, Map<String, String>>();

        // Fixed vendors
        List<String> vendors = new List<String>{'Chubb', 'Qualitas', 'Mapfre'};

        for (String vendor : vendors) {
            Map<String, String> recievedData = new Map<String, String>();

            // Integer values (all as string to match real method)
            recievedData.put('PropertyDamage', '1000');
            recievedData.put('TowedPropertyDamage', '200');
            recievedData.put('TotalTheft', '500');
            recievedData.put('TowedTotalTheft', '100');
            recievedData.put('Liability', '10000');
            recievedData.put('Medical', '2000');
            recievedData.put('Legal', '800');
            recievedData.put('Roadside', '400');
            recievedData.put('TravelAssist', '600');
            recievedData.put('AirplaneTickets', '1200');
            recievedData.put('PartialTheft', '300');
            recievedData.put('RentalCar', '700');
            recievedData.put('RoadsideTravel', '900');
            recievedData.put('SurchargeVehicleTypes', '250');
            recievedData.put('LiabilityWithTerritoryDiscount', '9500');
            recievedData.put('MedicalWithTerritoryDiscount', '1800');
            recievedData.put('Platinum', '15000');
            recievedData.put('NetFirst', '16000');
            recievedData.put('Max', '20000');
            recievedData.put('Gold', '12000');
            recievedData.put('NetSecond', '17000');
            recievedData.put('SurchargeRental', '100');
            recievedData.put('SurchargeHighRisk', '150');
            recievedData.put('SurchargeAge', '200');
            recievedData.put('SurchargeElectricHybrid', '300');
            recievedData.put('SurchargeBusiness', '400');
            recievedData.put('TotalSurcharges', '1150');
            recievedData.put('NetThird', '17500');
            recievedData.put('TerritoryDiscount', '500');
            recievedData.put('OtherDiscount', '250');
            recievedData.put('NetFourth', '18000');
            recievedData.put('IVA', '1600');
            recievedData.put('BrokerFee', '200');
            recievedData.put('AgentFee', '300');
            recievedData.put('Total', '21000');

            // Boolean values
            recievedData.put('Is_Gold__c', 'true');
            recievedData.put('Is_Max__c', 'false');
            recievedData.put('Is_Platinum__c', 'true');

            // URL values
            recievedData.put('TermAndConditionENG', 'https://example.com/eng-terms');
            recievedData.put('TermAndConditionSPN', 'https://example.com/spn-terms');

            responseDataMap.put(vendor, recievedData);
        }

        return responseDataMap;
    }
    
}