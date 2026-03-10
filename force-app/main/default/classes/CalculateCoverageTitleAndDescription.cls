public class CalculateCoverageTitleAndDescription {
    private static List<CoverageFormula__mdt> cachedVendors = new List<CoverageFormula__mdt>();
    private static List<Term_Mapping__mdt> termMetadataRecords = [SELECT Term__c,Value__c FROM Term_Mapping__mdt];
    private static List<String> vendors = new List<String>();
    
    static {
        
        // Query the custom metadata type
        List<Vendor_List__mdt> vendorMetadataList = [SELECT MasterLabel FROM Vendor_List__mdt];
        
        // Loop through the results and store labels in the list
        for (Vendor_List__mdt vendor : vendorMetadataList) {
            vendors.add(vendor.MasterLabel);
        }
        
        
        
        if (!vendors.isEmpty()) {
            // 1. Dynamically retrieve all Vendor__c fields
            Map<String, Schema.SObjectField> fields = Schema.SObjectType.Vendor__c.fields.getMap();
            List<String> fieldNames = new List<String>(fields.keySet());
            
            // 2. Build query with dynamic fields and vendor filter
            String query = 'SELECT Order__c,Vendor__c,Title_Formula__c,Description_Formula__c,Coverage_Name__c,Label,QualifiedApiName,Coverage_Image_URL__c FROM CoverageFormula__mdt  WHERE Vendor__c IN :vendors ORDER BY Order__c ASC'; // Use WHERE instead of LIMIT
            
            // 3. Execute query and cache results
            cachedVendors = Database.query(query);
        }
    }
    
    
    @AuraEnabled
    public static Map<String,Map<String,Map<String,String>>> getDescriptionAndTitle(String jsonString){
        Map<String,Map<String,Map<String,String>>> responseMap = new Map<String,Map<String,Map<String,String>>>();
        try{
            Map<String,String> dataMap = getDataMap(jsonString);
            System.debug('Data Map'+JSON.serialize(dataMap));
            for(String vendor: vendors){ 
                System.debug('vendor'+JSON.serialize(vendor));
                Map<String,Map<String,String>> coverageMap = new Map<String,Map<String,String>>();
                for(CoverageFormula__mdt vendorData : cachedVendors){
                    Map<String,String> granchildNestedMap =  new Map<String,String>();
                    if(vendorData.Vendor__c == vendor){
                        if(!dataMap.containsKey('Gold__c')){
                            dataMap.put('Gold__c','false');
                        }
                        if(!dataMap.containsKey('Max__c')){
                            dataMap.put('Max__c','false');
                        }
                        dataMap.put('Platinum__c','true');
                        if(vendorData.Coverage_Name__c == 'Liability (Damage You Cause)'){
                            if(dataMap.containsKey('Liability__c')) {
                                String liabilityValue = String.valueOf(dataMap.get('Liability__c'));
                                dataMap.put('Liability__c', liabilityValue.replace(',',''));
                            }
                            String description = LiabilityCoverageDetails.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = LiabilityCoverageDetails.evaluateSimpleFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Liability (Damage You Cause)',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Medical for Occupants of Your Vehicle'){
                            if(dataMap.containsKey('Medical__c')) {
                                String medicalValue = String.valueOf(dataMap.get('Medical__c'));
                                dataMap.put('Medical__c', medicalValue.replace(',',''));
                            }
                            string title = MedicalCoverageEvaluator.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            if(title != 'n/a'){
                                String description = MedicalCoverageEvaluator.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Medical for Occupants of Your Vehicle',granchildNestedMap);
                            }else{
                                String description = 'No Medical on Motorcycle or ATV/UTV/Dune Buggie Class Policies';
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Medical for Occupants of Your Vehicle',granchildNestedMap);
                                
                            }
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Vehicle Theft'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.05;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = vehicleTheftCoverageDetails.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = vehicleTheftCoverageDetails.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c)); 
                            coverageMap.put('Vehicle Theft',granchildNestedMap);
                            continue;
                        }            
                        if(vendorData.Coverage_Name__c == 'Partial Theft'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            String description = partialTheftCoverageDetails.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = partialTheftCoverageDetails.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Partial Theft',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Theft of Towed Unit(s) While Attached'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            if(Boolean.valueOf(dataMap.get('isTowing')) == true) {
                                String towedValue = dataMap.get('Total_Towed_Unit_Value__c');
                                String vehicleValue = datamap.get('Value__c');
                                Integer value = Integer.valueOf(vehicleValue) + Integer.valueOf(towedValue);
                                Decimal UpdatedTowedValue = value * 0.05;
                                dataMap.put('UpdatedTowedValue',String.valueOf(UpdatedTowedValue));
                                String description = towedTheftCoverageDetails.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                                string title = towedTheftCoverageDetails.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Theft of Towed Unit(s) While Attached',granchildNestedMap);
                            } else if(Boolean.valueOf(dataMap.get('isTowing')) == false && dataMap.get('Coverage__c') != 'Liability'){
                                String description = 'No Towed Units Listed';
                                string title = 'Not Covered';
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Theft of Towed Unit(s) While Attached',granchildNestedMap);
                            }else{
                                String description = 'Not Applicable on Liability Only Policies';
                                string title = 'Not Covered';
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Theft of Towed Unit(s) While Attached',granchildNestedMap);
                            }
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Damage to Vehicle'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.02;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = damageVehicleCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = damageVehicleCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Damage to Vehicle',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Damage to Towed Unit while Attached'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            if(Boolean.valueOf(dataMap.get('isTowing')) == true) {
                                String towedValue = dataMap.get('Total_Towed_Unit_Value__c');
                                String vehicleValue = datamap.get('Value__c');
                                Integer value = Integer.valueOf(vehicleValue) + Integer.valueOf(towedValue);
                                Decimal UpdatedTowedValue = value * 0.02;
                                dataMap.put('UpdatedTowedValue',String.valueOf(UpdatedTowedValue));
                                System.debug('IIIII'+UpdatedTowedValue);
                                String description = damageTowedVehicleCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                                string title = damageTowedVehicleCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Damage to Towed Unit while Attached',granchildNestedMap);
                            } else if(Boolean.valueOf(dataMap.get('isTowing')) == false && dataMap.get('Coverage__c') != 'Liability'){
                                String description = 'No Towed Units Listed';
                                string title = 'Not Covered';
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Damage to Towed Unit while Attached',granchildNestedMap);
                            }else{
                                String description = 'Not Applicable on Liability Only Policies';
                                string title = 'Not Covered';
                                granchildNestedMap.put('Title',title);
                                granchildNestedMap.put('Description',description);
                                granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                                granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                                coverageMap.put('Damage to Towed Unit while Attached',granchildNestedMap);
                            }
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Uninsured or Underinsured Damage to Vehicle'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            
                            String description = underinsuredVehicleCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = underinsuredVehicleCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Uninsured or Underinsured Damage to Vehicle',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Eligible to Repair in the U.S.'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            
                            String description = repairinUsCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = repairinUsCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Eligible to Repair in the U.S.',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Gap Coverage'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            String description = gapCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = gapCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Gap Coverage',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Vandalism Coverage'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.02;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = vandalismCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = vandalismCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Vandalism Coverage',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Glass Coverage'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            Integer Days = calculateCoverageDays(dataMap);
                            dataMap.put('Days',String.valueOf(Days));
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.02;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = glassCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = glassCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Glass Coverage',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Roadside Assistance'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            Integer Days = getVehicleAge(dataMap);
                            dataMap.put('VehicleAge',String.valueOf(Days));
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.02;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = roadsideAssistanceCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = roadsideAssistanceCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Roadside Assistance',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Rental Car Benefit'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            String description = glassCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = glassCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Rental Car Benefit',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Towing Benefit'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            Integer Days = getVehicleAge(dataMap);
                            dataMap.put('VehicleAge',String.valueOf(Days));
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.02;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = towingBenefitCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = towingBenefitCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Towing Benefit',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Trip Interruption'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            Integer Days = getVehicleAge(dataMap);
                            dataMap.put('VehicleAge',String.valueOf(Days));
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.02;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = towingBenefitCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = towingBenefitCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Trip Interruption',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Air Ambulance'){
                            if(!dataMap.containsKey('Gold__c')){
                                dataMap.put('Gold__c','false');
                            }
                            if(!dataMap.containsKey('Max__c')){
                                dataMap.put('Max__c','false');
                            }
                            if(!dataMap.containsKey('Platinum__c ')){
                                dataMap.put('Platinum__c ','false');
                            }
                            Integer Days = getVehicleAge(dataMap);
                            dataMap.put('VehicleAge',String.valueOf(Days));
                            String vehicleValue = dataMap.get('Value__c');
                            Integer value = Integer.valueOf(vehicleValue);
                            Decimal updatedVehicleValue = value * 0.02;
                            dataMap.put('UpdatedVehicleValue',String.valueOf(updatedVehicleValue));
                            String description = towingBenefitCoverage.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = towingBenefitCoverage.evaluateFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Air Ambulance',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Bail Bond Limit'){
                            if(dataMap.containsKey('Liability__c')) {
                                String liabilityValue = String.valueOf(dataMap.get('Liability__c'));
                                dataMap.put('Liability__c', liabilityValue.replace(',',''));
                            }
                            String description = LiabilityCoverageDetails.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = LiabilityCoverageDetails.evaluateSimpleFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Bail Bond Limit',granchildNestedMap);
                            continue;
                        }
                        if(vendorData.Coverage_Name__c == 'Legal Assistance Coverage'){
                            if(dataMap.containsKey('Liability__c')) {
                                String liabilityValue = String.valueOf(dataMap.get('Liability__c'));
                                dataMap.put('Liability__c', liabilityValue.replace(',',''));
                            }
                            String description = LiabilityCoverageDetails.evaluateFormula(vendorData.Description_Formula__c,dataMap);
                            string title = LiabilityCoverageDetails.evaluateSimpleFormula(vendorData.Title_Formula__c,dataMap);
                            granchildNestedMap.put('Title',title);
                            granchildNestedMap.put('Description',description);
                            granchildNestedMap.put('Image',vendorData.Coverage_Image_URL__c);
                            granchildNestedMap.put('Order',String.valueOf(vendorData.Order__c));
                            coverageMap.put('Legal Assistance Coverage',granchildNestedMap);
                            continue;
                        }
                    }
                }
                responseMap.put(vendor,coverageMap);
            }
            
            System.debug('Data Map'+JSON.serialize(dataMap));
            System.debug('Response Map'+JSON.serialize(responseMap));
            return responseMap;
        }catch(Exception e){
            System.debug('Exception at:'+e.getLineNumber()+e.getMessage());
            throw new AuraHandledException('Error' + e.getLineNumber()+e.getMessage());
        }
    }
    
    public static Map<String, String> getDataMap(String jsonString) {
        Map<String, String> resultMap = new Map<String, String>();
        Map<String, Decimal> tracker = new Map<String, Decimal>{ 'Total' => 0 };
            
            try {
                List<Object> dataList = (List<Object>)JSON.deserializeUntyped(jsonString);
                
                for (Object item : dataList) {
                    if (item instanceof Map<String, Object>) {
                        Map<String, Object> itemMap = (Map<String, Object>)item;
                        
                        for (String key : itemMap.keySet()) {
                            if(key.equalsIgnoreCase('userDetails') || key.equalsIgnoreCase('vehicleDetails') || key.equalsIgnoreCase('territory') ||key.equalsIgnoreCase('termOption')){
                                Object value = itemMap.get(key);
                                
                                if (key == 'vehicleList' || key == 'towunitsList') continue;
                                
                                if (value instanceof Map<String, Object>) {
                                    flattenMap('', (Map<String, Object>)value, resultMap, tracker);
                                } else if (value instanceof List<Object>) {
                                    processList('', (List<Object>)value, resultMap, tracker);
                                } else {
                                    resultMap.put(key, String.valueOf(value));
                                }
                            }                               
                        }
                    }
                }
                if(!resultMap.containsKey('Total_Towed_Unit_Value__c')){
                    resultMap.put('Total_Towed_Unit_Value__c', String.valueOf(tracker.get('Total')));
                }
            } catch (Exception e) {
                System.debug('Error processing JSON: ' + e.getMessage());
            }
        
        return resultMap;
    }
    
    
    private static void flattenMap(String prefix, Map<String, Object> sourceMap, Map<String, String> resultMap, Map<String, Decimal> tracker) {
        for (String key : sourceMap.keySet()) {
            Object value = sourceMap.get(key);
            
            if (value instanceof Map<String, Object>) {
                flattenMap('', (Map<String, Object>)value, resultMap, tracker);
            } else if (value instanceof List<Object>) {
                if (!key.contains('vehicleList') && !key.contains('towunitsList')) {
                    processList('', (List<Object>)value, resultMap, tracker);
                }
            } else {
                resultMap.put(key, String.valueOf(value));
            }
        }
    }
    
    
    private static void processList(String prefix, List<Object> itemList, Map<String, String> resultMap, Map<String, Decimal> tracker) {
        for (Integer i = 0; i < itemList.size(); i++) {
            Object item = itemList[i];
            
            if (item instanceof Map<String, Object>) {
                Map<String, Object> itemMap = (Map<String, Object>)item;
                
                if (itemMap.containsKey('Towed_Unit_Value__c')) {
                    try {
                        Decimal val = Decimal.valueOf(String.valueOf(itemMap.get('Towed_Unit_Value__c')));
                        tracker.put('Total', tracker.get('Total') + val);
                    } catch (Exception e) {
                        System.debug('Invalid Towed_Unit_Value__c: ' + itemMap.get('Towed_Unit_Value__c'));
                    }
                }
                
                flattenMap('', itemMap, resultMap, tracker);
            } else if (item instanceof List<Object>) {
                processList('', (List<Object>)item, resultMap, tracker);
            } else {
                resultMap.put(prefix + i, String.valueOf(item));
            }
        }
    }
    
    public static Integer calculateCoverageDays(Map<String, Object> dataMap) {
        try {
            String startDateStr = (String) dataMap.get('Start_Date_for_Coverage__c');
            String endDateStr = (String) dataMap.get('End_Date_for_Coverage__c');
            
            if (String.isNotBlank(startDateStr) && String.isNotBlank(endDateStr)) {
                Date startDate = Date.valueOf(startDateStr);
                Date endDate = Date.valueOf(endDateStr);
                
                Integer daysBetween = startDate.daysBetween(endDate) + 1; // Include both days
                return daysBetween;
            }
        } catch (Exception e) {
            System.debug('Error calculating coverage days: ' + e.getMessage());
        }
        
        return 0;
    }
    
    public static Integer getVehicleAge(Map<String, Object> dataMap) {
        try {
            String yearStr = (String) dataMap.get('Year__c');
            if (String.isNotBlank(yearStr)) {
                Integer vehicleYear = Integer.valueOf(yearStr);
                Integer currentYear = Date.today().year();
                
                return currentYear - vehicleYear;
            }
        } catch (Exception e) {
            System.debug('Error calculating vehicle age: ' + e.getMessage());
        }
        
        return null;
    }
    
}