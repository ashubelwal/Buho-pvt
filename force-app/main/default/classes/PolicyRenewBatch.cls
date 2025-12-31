public class PolicyRenewBatch implements Database.batchable<Sobject> ,Database.Stateful , Database.AllowsCallouts{
    
    Map<String,object> policyIdsVsTransaction = new Map<String, object>();
    public Map<Id, Quote__c> policyIdVsQuote = new Map<Id, Quote__c>();
    public Set<String> policyIdsSet = new Set<String>();
    //public Map<Id,Object> failedTransacation = new Map<Id,Object>();

    public PolicyRenewBatch(Map<Id, Quote__c> quotes, Map<String,object> policyIdsVsTransaction) {
        this.policyIdVsQuote = quotes;
        this.policyIdsSet = new Set<String>(); 
        //this.failedTransacation = new Map<Id,Object>();
        this.policyIdsVsTransaction = policyIdsVsTransaction;
    } 
    
    public Database.queryLocator start(Database.batchableContext BC){ 
        System.debug('Start Policy Renew Batch');
        Set<String> policyIdsQuery = new Set<String>();
        for(String policyIds : policyIdVsQuote.keyset()){
            System.debug('policyIds'+policyIds);
            policyIdsQuery.add(policyIds);
        }
        System.debug('policyIdsQuery'+policyIdsQuery);
        String query = 'SELECT id, Term__c, Term_days__c, Auto_renew__c, End_Date__c, Start_Date__c, Quote_c__c, Policy_Type_picklist__c,Contact__c,Auto_renew_card__c,Renew_Payment_Profile_Id__c,Auto_Renew_Confirmed__c,Updated_Quote_Json__c  from Policy__c WHERE ID IN: policyIdsQuery LIMIT 50000';
        System.debug('query'+query); 
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Policy__c> policyList){
        System.debug('Policy List - '+ policyList);
        
        Set<Id> policyIdSet = new Set<Id>(); 
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Watercraft__c> querywatercraft = new Map<Id,Watercraft__c>();
        Map<Id,List<Towed_Unit__c>> queryTowedUnit = new Map<Id,List<Towed_Unit__c>>();
        Map<String,object> transactionDetails = new Map<String, object>();
        Map<String,String> towedDetails = new Map<String, String>();
        Map<String, String> getNewWaterCraftPolicy = new Map<String, String>();
        Map<String, String> getNewPolicy = new Map<String, String>();
        Map<Id, String> policyVehicleMap = new Map<Id, String>();
        Map<Id, Id> policyVsnewQuote = new Map<Id, Id>();
        Map<Id, List<Map<String, Object>>> policyDriverMap = new Map<Id, List<Map<String, Object>>>();
        
        
        if(policyList.size() > 0){
            for(Policy__c policy :policyList){
                policyIdSet.add(policy.id);
                contactIdSet.add(policy.Contact__c);
            }
        }
        
        System.debug('policyIdSet'+policyIdSet);
        System.debug('contactIdSet'+contactIdSet);
        
        List<Quote_Driver__c > quoteDriverList = [SELECT Id, Name, Contact__c, Driver__c, Policy__c,Driver__r.OwnerId, Driver__r.Name, Driver__r.First_Name__c, Driver__r.Last_Name__c, Driver__r.Dob__c, Driver__r.license_number__c,
                                                   Driver__r.License_Country__c, Driver__r.License_state__c, Driver__r.Age_Range__c, Driver__r.Deleted_Driver__c,
                                                   Driver__r.User_Email__c, Driver__r.Account_Driver__c, Driver__r.Address__c, Driver__r.City__c, Driver__r.Contact__c, Driver__r.Country__c,
                                                   Driver__r.Driver_Type__c, Driver__r.Phone__c, Driver__r.Postal_Code__c, Driver__r.State_Province__c, Driver__r.LN_With_Country__c,
                                                   Driver__r.Primary_insured__c FROM Quote_Driver__c WHERE  Policy__c IN: policyIdSet];
        
        List<Quote_Vehicle__c > quoteVehicleList = [SELECT Id, Name, Contact__c, Vehicle__c, Policy__c,Vehicle__r.OwnerId,Vehicle__r.Name, Vehicle__r.RecordTypeId, Vehicle__r.Rental__c, Vehicle__r.Vin__c, Vehicle__r.Make__c, Vehicle__r.Model__c, Vehicle__r.Registered_Plate__c,
                                                       Vehicle__r.Registered_Country__c, Vehicle__r.Registered_State__c, Vehicle__r.Account_Vehicle__c, Vehicle__r.Year__c, Vehicle__r.Deleted_vehicle__c, Vehicle__r.Contact__c, 
                                                       Vehicle__r.Is_Lienholder__c, Vehicle__r.Is_the_vehicle_registered_to_a_business__c, Vehicle__r.Is_the_vehicle_used_for_business_purpose__c, 
                                                       Vehicle__r.Salvage_Vehicle__c, Vehicle__r.Value__c, Vehicle__r.Vehicle_Type__c, Vehicle__r.Is_there_a_driver_under_21__c, Vehicle__r.Is_Account_Company_Named__c, 
                                                       Vehicle__r.Is_vehicle_owned_by_a_company_or_rented__c, Vehicle__r.Business_Address__c FROM Quote_Vehicle__c WHERE  Policy__c IN: policyIdSet];
        System.debug('quoteDriverList--'+quoteDriverList);
        if(quoteVehicleList.size() > 0){
            for (Quote_Vehicle__c quoteVehicle : quoteVehicleList) {
                Id policyId = quoteVehicle.Policy__c;
                if (!policyVehicleMap.containsKey(policyId)) {
                    Map<String, Object> vehicleFieldsMap = new Map<String, Object>();
                    List<String> policyVehicleList = new List<String>();
                    system.debug('Account_Vehicle__c'+quoteVehicle.Vehicle__r.Account_Vehicle__c);
                    system.debug('Contact__c'+quoteVehicle.Vehicle__r.Contact__c);
                    
                    vehicleFieldsMap.put('Owner Id', quoteVehicle.Vehicle__r.OwnerId != null ? quoteVehicle.Vehicle__r.OwnerId : '' );
                    vehicleFieldsMap.put('Name', quoteVehicle.Vehicle__r.Name != null ? quoteVehicle.Vehicle__r.Name : '');
                    //vehicleFieldsMap.put('RecordTypeId', quoteVehicle.Vehicle__r.RecordTypeId != null ? quoteVehicle.Vehicle__r.RecordTypeId : '');
                    vehicleFieldsMap.put('Vin__c', quoteVehicle.Vehicle__r.Vin__c != null ? quoteVehicle.Vehicle__r.Vin__c : '');
                    vehicleFieldsMap.put('Make__c', quoteVehicle.Vehicle__r.Make__c != null ? quoteVehicle.Vehicle__r.Make__c : '');
                    vehicleFieldsMap.put('Model__c', quoteVehicle.Vehicle__r.Model__c != null ? quoteVehicle.Vehicle__r.Model__c : '');
                    vehicleFieldsMap.put('Registered_Plate__c', quoteVehicle.Vehicle__r.Registered_Plate__c != null ? quoteVehicle.Vehicle__r.Registered_Plate__c : '');
                    vehicleFieldsMap.put('Registered_Country__c', quoteVehicle.Vehicle__r.Registered_Country__c != null ? quoteVehicle.Vehicle__r.Registered_Country__c : '');
                    vehicleFieldsMap.put('Registered_State__c', quoteVehicle.Vehicle__r.Registered_State__c != null ? quoteVehicle.Vehicle__r.Registered_State__c : '');
                    vehicleFieldsMap.put('Account_Vehicle__c', String.valueOf(quoteVehicle.Vehicle__r.Account_Vehicle__c) != null ? String.valueOf(quoteVehicle.Vehicle__r.Account_Vehicle__c) : '');
                    vehicleFieldsMap.put('Year__c', quoteVehicle.Vehicle__r.Year__c != null ? quoteVehicle.Vehicle__r.Year__c : '');
                    vehicleFieldsMap.put('Deleted_vehicle__c', quoteVehicle.Vehicle__r.Deleted_vehicle__c);
                    vehicleFieldsMap.put('Contact__c', String.valueOf(quoteVehicle.Vehicle__r.Contact__c) != null ? String.valueOf(quoteVehicle.Vehicle__r.Contact__c) : '');
                    vehicleFieldsMap.put('Is_Lienholder__c', quoteVehicle.Vehicle__r.Is_Lienholder__c);
                    vehicleFieldsMap.put('Is_the_vehicle_registered_to_a_business__c', quoteVehicle.Vehicle__r.Is_the_vehicle_registered_to_a_business__c);
                    vehicleFieldsMap.put('Is_the_vehicle_used_for_business_purpose__c', quoteVehicle.Vehicle__r.Is_the_vehicle_used_for_business_purpose__c);
                    vehicleFieldsMap.put('Salvage_Vehicle__c', quoteVehicle.Vehicle__r.Salvage_Vehicle__c );
                    vehicleFieldsMap.put('Value__c', quoteVehicle.Vehicle__r.Value__c != null ? String.valueOf(quoteVehicle.Vehicle__r.Value__c) : '');
                    vehicleFieldsMap.put('Vehicle_Type__c', quoteVehicle.Vehicle__r.Vehicle_Type__c != null ? quoteVehicle.Vehicle__r.Vehicle_Type__c : '');
                    vehicleFieldsMap.put('Is_there_a_driver_under_21__c', quoteVehicle.Vehicle__r.Is_there_a_driver_under_21__c);
                    vehicleFieldsMap.put('Is_Account_Company_Named__c', quoteVehicle.Vehicle__r.Is_Account_Company_Named__c);
                    vehicleFieldsMap.put('Is_vehicle_owned_by_a_company_or_rented__c', quoteVehicle.Vehicle__r.Is_vehicle_owned_by_a_company_or_rented__c);
                    //vehicleFieldsMap.put('Business_Address__c', quoteVehicle.Vehicle__r.Business_Address__c != null ? quoteVehicle.Vehicle__r.Business_Address__c : '');
                    
                    String jsonVehicleFields = JSON.serialize(vehicleFieldsMap);
                    policyVehicleList.add(jsonVehicleFields);
                    policyVehicleMap.put(policyId, jsonVehicleFields);
                }
            }
        }
        
        if(quoteDriverList.size() > 0){
            for (Quote_Driver__c quoteDriver : quoteDriverList) {
                Id policyId = quoteDriver.Policy__c;
                if (!policyDriverMap.containsKey(policyId)) {
                    Map<String, Object> DriverFieldsMap = new Map<String, Object>();
                    List<Map<String, Object>> policyDriverList = new List<Map<String, Object>>();
                    
                    system.debug('Account_Driver__c'+quoteDriver.Driver__r.Account_Driver__c);
                    system.debug('Contact__c'+quoteDriver.Driver__r.Contact__c);
                    
                    DriverFieldsMap.put('Owner Id', quoteDriver.Driver__r.OwnerId != null ? quoteDriver.Driver__r.OwnerId : '');
                    DriverFieldsMap.put('Name', quoteDriver.Driver__r.Name != null ? quoteDriver.Driver__r.Name : '');
                    DriverFieldsMap.put('First_Name__c', quoteDriver.Driver__r.First_Name__c != null ? quoteDriver.Driver__r.First_Name__c : '');
                    DriverFieldsMap.put('Last_Name__c', quoteDriver.Driver__r.Last_Name__c != null ? quoteDriver.Driver__r.Last_Name__c : '');
                    DriverFieldsMap.put('Dob__c', quoteDriver.Driver__r.Dob__c != null ? String.valueOf(quoteDriver.Driver__r.Dob__c) : '');
                    DriverFieldsMap.put('license_number__c', quoteDriver.Driver__r.license_number__c != null ? quoteDriver.Driver__r.license_number__c : '');
                    DriverFieldsMap.put('License_Country__c', quoteDriver.Driver__r.License_Country__c != null ? quoteDriver.Driver__r.License_Country__c : '');
                    DriverFieldsMap.put('License_state__c', quoteDriver.Driver__r.License_state__c != null ? quoteDriver.Driver__r.License_state__c : '');
                    DriverFieldsMap.put('Age_Range__c', quoteDriver.Driver__r.Age_Range__c != null ? String.valueOf(quoteDriver.Driver__r.Age_Range__c) : '');
                    DriverFieldsMap.put('Deleted_Driver__c', quoteDriver.Driver__r.Deleted_Driver__c);
                    DriverFieldsMap.put('User_Email__c', quoteDriver.Driver__r.User_Email__c != null ? quoteDriver.Driver__r.User_Email__c : '');
                    DriverFieldsMap.put('Account_Driver__c', String.valueOf(quoteDriver.Driver__r.Account_Driver__c) != '' ? String.valueOf(quoteDriver.Driver__r.Account_Driver__c) : '');
                    DriverFieldsMap.put('Address__c', quoteDriver.Driver__r.Address__c != null ? quoteDriver.Driver__r.Address__c : '');
                    DriverFieldsMap.put('City__c', quoteDriver.Driver__r.City__c != null ? quoteDriver.Driver__r.City__c : '');
                    DriverFieldsMap.put('Contact__c', String.valueOf(quoteDriver.Driver__r.Contact__c) != null ? String.valueOf(quoteDriver.Driver__r.Contact__c) : '');
                    DriverFieldsMap.put('Country__c', quoteDriver.Driver__r.Country__c != null ? quoteDriver.Driver__r.Country__c : '');
                    DriverFieldsMap.put('Driver_Type__c', quoteDriver.Driver__r.Driver_Type__c != null ? quoteDriver.Driver__r.Driver_Type__c : '');
                    DriverFieldsMap.put('Phone__c', quoteDriver.Driver__r.Phone__c != null ? quoteDriver.Driver__r.Phone__c : '');
                    DriverFieldsMap.put('Postal_Code__c', quoteDriver.Driver__r.Postal_Code__c != null ? quoteDriver.Driver__r.Postal_Code__c : '');
                    DriverFieldsMap.put('State_Province__c', quoteDriver.Driver__r.State_Province__c != null ? quoteDriver.Driver__r.State_Province__c : '');
                    DriverFieldsMap.put('LN_With_Country__c', quoteDriver.Driver__r.LN_With_Country__c != null ? quoteDriver.Driver__r.LN_With_Country__c : '');
                    DriverFieldsMap.put('Primary_insured__c', quoteDriver.Driver__r.Primary_insured__c);
                    
                    String jsonDriverFields = JSON.serialize(DriverFieldsMap);
                    policyDriverList.add(DriverFieldsMap);
                    policyDriverMap.put(policyId, policyDriverList);
                }
            }
        }
        
        List<Watercraft__c> watercraftList = [SELECT Id,OwnerId, Name, Account__c, Any_Boat_Operator_Under_22__c, Contact__c, Engine_Type__c, 
                                       Is_the_Maximum_Speed_more_than_50_mph__c, Is_the_owner_living_in_Mexico__c, Make__c, Model__c, 
                                       Type_of_Vessel__c, VIN_Number__c, Value__c, Year__c, Vessel_Length__c,Captain_s_Day__c, Captain_s_Month__c, 
                                       Captain_s_Year__c from Watercraft__c  where Contact__c IN: contactIdSet];
        
        
        List<Quote_Towed_Unit__c> towedunitList = [SELECT Policy__c,Towed_Unit__r.Id,Towed_Unit__r.OwnerId, Towed_Unit__r.Name,Towed_Unit__r.Account__c, 
                                             Towed_Unit__r.Contact__c, Towed_Unit__r.Make__c, Towed_Unit__r.Model__c, Towed_Unit__r.Plate__c, Towed_Unit__r.Towed_Unit_Type__c, 
                                         Towed_Unit__r.Towed_Unit_Value__c, Towed_Unit__r.VIN_Number__c, Towed_Unit__r.Year__c, Towed_Unit__r.Days_in_Tow__c from Quote_Towed_Unit__c 
                                             where Policy__c IN: policyIdSet ];
        
        System.debug('policyVehicleMap'+policyVehicleMap);
        System.debug('towedunitList'+towedunitList);
        System.debug('policyDriverMap'+policyDriverMap);
        
        if(watercraftList.size() > 0){
            for (Watercraft__c watercraft : watercraftList) {
            	querywatercraft.put(watercraft.Contact__c, watercraft);
        	}
        }
        
        if(towedunitList.size() > 0){
            for (Quote_Towed_Unit__c towed : towedunitList) {
                List<Towed_Unit__c> towedList;
                
                if (queryTowedUnit.containsKey(towed.Policy__c)) {
                    towedList = queryTowedUnit.get(towed.Policy__c);
                } else {
                    towedList = new List<Towed_Unit__c>();
                }
                
                towedList.add(towed.Towed_Unit__r);
                queryTowedUnit.put(towed.Policy__c, towedList);
            }

        }

        System.debug('querywatercraft'+querywatercraft);
        System.debug('queryTowedUnit'+queryTowedUnit);    
        
        if(policyList.size() > 0){
            for(Policy__c policy :policyList){
                List<String> quoteIdsList = new List<String>();
                String profileId = policy.Renew_Payment_Profile_Id__c;
                String contactId = policy.Contact__c;
                String policyId = policy.Id;
               	Quote__c quoteRecord = policyIdVsQuote.get(policy.Id);
                string newQuoteID = quoteRecord.Id;

                if(policyIdsVsTransaction.get(policy.Id) == 'success'){
                    if(policy.Policy_Type_picklist__c == 'Watercraft'){
                        System.debug('Watercraft'+JSON.serialize(querywatercraft.get(policy.Contact__c)));
                        System.debug('Watercraft DRIVER'+JSON.serialize(policyDriverMap.get(policy.Id)));
                        
                        getNewWaterCraftPolicy = PaymentFormController.createNewWatercraftEditPolicy(JSON.serialize(querywatercraft.get(policy.Contact__c)), JSON.serialize(policyDriverMap.get(policy.Id)), newQuoteID, policyId, True);
                    	System.debug('getNewWaterCraftPolicy--'+getNewWaterCraftPolicy);
                        if(getNewWaterCraftPolicy.get('status') == 'success'){
                            policyIdsSet.add(getNewWaterCraftPolicy.get('data'));
                            Policy__c updatePolicy = new Policy__c();
                        	updatePolicy.Id = getNewWaterCraftPolicy.get('data');
                            updatePolicy.Auto_renew__c = true;
                            updatePolicy.Auto_renew_card__c = policy.Auto_renew_card__c;
                            updatePolicy.Renew_Payment_Profile_Id__c = profileId;
                            update updatePolicy;
                            System.debug('updatePolicy--'+updatePolicy);
                        }
                        
                    }else{
                        System.debug('Vehcile--'+policyVehicleMap.get(policy.Id));
                        System.debug('Driver--'+JSON.serialize(policyDriverMap.get(policy.Id)));
                        System.debug('Towed Unit'+JSON.serialize(queryTowedUnit.get(policy.Id)));
                        String towedUnits = queryTowedUnit.containsKey(policy.Id) ? JSON.serialize(queryTowedUnit.get(policy.Id)) : '';
                        if(towedUnits == '' || towedUnits == null){
                            List<Towed_Unit__c> emptyList = new List<Towed_Unit__c>();
                            towedUnits = JSON.serialize(emptyList);
                        }
                        System.debug('towedUnits---'+towedUnits);
                        getNewPolicy = PaymentFormController.createNewEditPolicy(policyVehicleMap.get(policy.Id), JSON.serialize(policyDriverMap.get(policy.Id)), towedUnits, newQuoteID, policyId, True);
                        System.debug('getNewPolicy--'+getNewPolicy);
                        
                        if(getNewPolicy.get('status') == 'success'){
                            policyIdsSet.add(getNewPolicy.get('data')); 
                            Policy__c updatePolicy = new Policy__c();
                        	updatePolicy.Id = getNewPolicy.get('data');
                            updatePolicy.Auto_renew__c = true;
                            updatePolicy.Auto_renew_card__c = policy.Auto_renew_card__c;
                            updatePolicy.Renew_Payment_Profile_Id__c = profileId;
                            update updatePolicy;
                            System.debug('updatePolicy--'+updatePolicy);
                        }
                    }
                    
                }else{
                    // Handle Decline Transaction here.......
                    //failedTransacation.put(policy.Id, policyIdsVsTransaction.get(policy.Id));
                }
                
        	}
        }
        
    }
    
    public void finish (Database.BatchableContext Bc){
        System.debug('Finish Policy Renew Batch');
        System.debug('policyIdsSet--'+policyIdsSet);
        if(policyIdsSet.size() > 0){
            PolicyAutoRenewalEmailHandler emailHandler = new PolicyAutoRenewalEmailHandler(policyIdsSet, true);
            Id jobID = System.enqueueJob(emailHandler);
            System.debug('Queueable jobID'+jobID);
        }
        //System.debug('failedTransacation---'+failedTransacation);
        //if(failedTransacation.size() > 0){
            //PolicyAutoRenewCreateCase.createCase(failedTransacation);
        //}
    }

}