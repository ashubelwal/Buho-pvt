public without sharing class Mex_ValidateFormData {
    
    @AuraEnabled
    public static Map<String, object> validateFormData(String objData, String objName) {
        
        Map<String, object> resp = new Map<String, object>();
        try {
            if (objData != null && !String.isEmpty(objData) && objName != null && !String.isEmpty(objName)) {
                NewLeadWrapper leadWrapper = (NewLeadWrapper) JSON.deserialize(objData.replaceAll('__c', '_Tempc'), NewLeadWrapper.class);
                
                if (objName == 'vehicleDetails') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid);
                        return resp;
                    }
                }
                
                if (objName == 'termOptions') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);

                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'towDetails') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'territoryCoverage') {
                    if (String.isEmpty(leadWrapper.Territory_options_Tempc)) {
                        resp.put('status', 'error');
                        resp.put('message', 'territoryCoverage is missing.');
                        return resp;
                    }
                }
                
                if (objName == 'quoteDetails') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'reviewVehicle') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'companyInfo') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'lienholderDetails') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'driverDetails') {

                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'termsAndAgreement') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                if (objName == 'paymentDetails') {
                    Map<String, String> isValid = validateFields(leadWrapper, objName);
                    
                    if (isValid.get('valid') != 'true') {
                        resp.put('status', 'error');
                        resp.put('message', isValid.get('message'));
                        return resp;
                    }
                }
                
                resp.put('status', 'success');
                resp.put('message', '');
            } else {
                resp.put('status', 'error');
                resp.put('message', 'Kindly provide the required fields.');
            }
        } catch (Exception ex) {
            CustomErrorExceptionHandlerException.data = 'data: '+objData+'\nObject Name: '+objName;
            CustomErrorExceptionHandlerException.LogException(ex);
            resp.put('status', 'error');
            resp.put('message', ex.getMessage());
        }
        return resp;
    }
    
    private static Map<String, String> validateFields(NewLeadWrapper leadWrapper, String screenName) {
        Map<String, String> isValid = new Map<String, String>();
        isValid.put('valid', 'true');
        isValid.put('message', '');
        if (screenName == 'vehicleDetails') {
             map<string, boolean> isValidArr = new map<string, boolean>();
            if (leadWrapper.Vehicle_details_Tempc.Vehicle_Type_Tempc == null || String.isEmpty(leadWrapper.Vehicle_details_Tempc.Vehicle_Type_Tempc)) {
                 isValidArr.put('Vehicle_Type__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Year_Tempc == null || String.isEmpty(leadWrapper.Vehicle_details_Tempc.Year_Tempc)) {
                 isValidArr.put('Year__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Make_Tempc == null || String.isEmpty(leadWrapper.Vehicle_details_Tempc.Make_Tempc)) {
                 isValidArr.put('Make__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Model_Tempc == null || String.isEmpty(leadWrapper.Vehicle_details_Tempc.Model_Tempc)) {
                 isValidArr.put('Model__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Value_Tempc == null || String.isEmpty(leadWrapper.Vehicle_details_Tempc.Value_Tempc)) {
                 isValidArr.put('Value__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Is_there_a_driver_under_21_Tempc == null && leadWrapper.Policy_Type_Tempc != 'Motorcycle/Street Legal ATV' && leadWrapper.Policy_Type_Tempc != 'Northbound') {
                 isValidArr.put('Is_there_a_driver_under_21__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Salvage_Vehicle_Tempc == null) {
                 isValidArr.put('Salvage_Vehicle__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Is_the_vehicle_used_for_business_purpose_Tempc == null) {
                 isValidArr.put('Is_the_vehicle_used_for_business_purpose__c', false);
            }
            
            if (leadWrapper.Vehicle_details_Tempc.Is_this_a_Rental_Vehicle_Tempc == null) {
                 isValidArr.put('Is_this_a_Rental_Vehicle__c', false);
            }
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message vehicleDetail', 'Missing fields : '+ isValidArr.keySet());
            }
        }
        
        if (screenName == 'termOptions') {
            map<string, boolean> isValidArr = new map<string, boolean>();
            if (leadWrapper.Term_options_Tempc.Start_Date_for_Coverage_Tempc == null || String.isEmpty(leadWrapper.Term_options_Tempc.Start_Date_for_Coverage_Tempc)) {
                isValidArr.put('Start_Date_for_Coverage__c', false);
            }
            
            if (leadWrapper.Term_options_Tempc.End_Date_for_Coverage_Tempc == null || String.isEmpty(leadWrapper.Term_options_Tempc.End_Date_for_Coverage_Tempc)) {
                isValidArr.put('Start_Date_for_Coverage__c', false);
            }
            
            if (leadWrapper.Term_options_Tempc.Start_Time_Tempc == null || String.isEmpty(leadWrapper.Term_options_Tempc.Start_Time_Tempc)) {
                isValidArr.put('Start_Time__c', false);
            }
            
            if (leadWrapper.Term_options_Tempc.Start_Time_Tempc == null || String.isEmpty(leadWrapper.Term_options_Tempc.End_Time_Tempc)) {
                isValidArr.put('Start_Time__c', false);
            }
            
            if (leadWrapper.Term_options_Tempc.term_Tempc == null || String.isEmpty(leadWrapper.Term_options_Tempc.term_Tempc)) {
                isValidArr.put('term__c', false);
            }
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message termOptions', 'Missing fields : '+ isValidArr.keySet());
            }
        }
        
        if (screenName == 'towDetails') {
            map<string, boolean> isValidArr = new map<string, boolean>();
            for (TowDetailsWrapper each: leadWrapper.Towing_Tempc) {
                if (each.Year_Tempc != null && String.isEmpty(each.Year_Tempc)) {
                    isValidArr.put('Year__c', false);
                }
                
                if (each.Make_Tempc != null && String.isEmpty(each.Make_Tempc)) {
                    isValidArr.put('Make__c', false);
                }
                
                if (each.Model_Tempc != null && String.isEmpty(each.Model_Tempc)) {
                    isValidArr.put('Model__c', false);
                }
                
                if (each.VIN_Number_Tempc != null && String.isEmpty(each.VIN_Number_Tempc)) {
                    isValidArr.put('VIN_Number__c', false);
                }
                
                if (each.Plate_Tempc != null && String.isEmpty(each.Plate_Tempc)) {
                    isValidArr.put('Plate__c', false);
                }
                
                if (each.Towed_Unit_Value_Tempc != null && String.isEmpty(each.Towed_Unit_Value_Tempc)) {
                    isValidArr.put('Towed_Unit_Value__c', false);
                }
                
                if (each.Days_in_Tow_Tempc != null && String.isEmpty(each.Days_in_Tow_Tempc)) {
                    isValidArr.put('Days_in_Tow__c', false);
                }
                
                if (each.Towed_Unit_Type_Tempc != null && String.isEmpty(each.Towed_Unit_Type_Tempc)) {
                    isValidArr.put('Towed_Unit_Type__c', false);
                }
            }
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message towDetails', 'Missing fields : '+ isValidArr.keySet());
            }
        }
        
        if (screenName == 'quoteDetails') {
            map<string, boolean> isValidArr = new map<string, boolean>();
            if (leadWrapper.Quote_Details_Tempc.Start_Date_for_Coverage_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.Start_Date_for_Coverage_Tempc)) {
                isValidArr.put('Start_Date_for_Coverage__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.End_Date_for_Coverage_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.End_Date_for_Coverage_Tempc)) {
                isValidArr.put('End_Date_for_Coverage__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.Start_Time_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.Start_Time_Tempc)) {
                isValidArr.put('Start_Time__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.End_Time_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.End_Time_Tempc)) {
                isValidArr.put('End_Time__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.termDays_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.termDays_Tempc)) {
                isValidArr.put('termDays__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.vehicleValue_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.vehicleValue_Tempc)) {
                isValidArr.put('Year__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.liability_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.liability_Tempc)) {
                isValidArr.put('vehicleValue__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.medical_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.medical_Tempc)) {
                isValidArr.put('medical__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.coverageType_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.coverageType_Tempc)) {
                isValidArr.put('coverageType__c', false);
            }
            
            if (leadWrapper.Quote_Details_Tempc.underwriter_Tempc == null || String.isEmpty(leadWrapper.Quote_Details_Tempc.underwriter_Tempc)) {
                isValidArr.put('underwriter__c', false);
            }
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message quick quote', 'Missing fields : '+ isValidArr.keySet());
            }
        }
        
        if (screenName == 'reviewVehicle') {
            map<string, boolean> isValidArr = new map<string, boolean>();
            if (leadWrapper.Review_vehicle_Tempc.Year_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Year_Tempc)) {
                isValidArr.put('Year__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Make_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Make_Tempc)) {
                isValidArr.put('Make__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Model_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Model_Tempc)) {
                isValidArr.put('Model__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Value_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Value_Tempc)) {
                isValidArr.put('Value__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Vin_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Vin_Tempc)) {
                isValidArr.put('Vin__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Registered_Country_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Registered_Country_Tempc)) {
                isValidArr.put('Registered_Country__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Registered_State_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Registered_State_Tempc)) {
                isValidArr.put('Registered_State__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Registered_Plate_Tempc == null || String.isEmpty(leadWrapper.Review_vehicle_Tempc.Registered_Plate_Tempc)) {
                isValidArr.put('CRegistered_Plate__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Is_the_vehicle_registered_to_a_business_Tempc == null) {
                isValidArr.put('Is_the_vehicle_registered_to_a_business__c', false);
            }
            
            if (leadWrapper.Review_vehicle_Tempc.Is_Lienholder_Tempc == null) {
                isValidArr.put('Is_Lienholder__c', false);
            }
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message review vehicle', 'Missing fields : '+ isValidArr.keySet());
            }
        }
        
        if (screenName == 'companyInfo') {
                map<string, boolean> isValidArr = new map<string, boolean>();

            if (leadWrapper.Company_details_Tempc.Company_Name_Tempc == null || String.isEmpty(leadWrapper.Company_details_Tempc.Company_Name_Tempc)) {
                isValidArr.put('Company_Name__c', false);
            }
            
            if (leadWrapper.Company_details_Tempc.Company_Phone_Tempc == null || String.isEmpty(leadWrapper.Company_details_Tempc.Company_Phone_Tempc)) {
                isValidArr.put('Company_Phone__c', false);
            }
            
            if (leadWrapper.Company_details_Tempc.Tax_ID_Tempc == null || String.isEmpty(leadWrapper.Company_details_Tempc.Tax_ID_Tempc)) {
                isValidArr.put('Tax_ID__c', false);
            }
            
            if (leadWrapper.Company_details_Tempc.Company_Zip_Tempc == null || String.isEmpty(leadWrapper.Company_details_Tempc.Company_Zip_Tempc)) {
                isValidArr.put('Company_Zip__c', false);
            }
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message Company', 'Missing fields : '+ isValidArr.keySet());
            }
        }
        
        if (screenName == 'lienholderDetails') {
            map<string, boolean> isValidArr = new map<string, boolean>();
            if (leadWrapper.Lienholder_info_Tempc.Lienholder_name_Tempc == null || String.isEmpty(leadWrapper.Lienholder_info_Tempc.Lienholder_name_Tempc)) {
                isValidArr.put('Lienholder_name__c', false);
            }

        if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message Lienholder', 'Missing fields : '+ isValidArr.keySet());
            }

        }
        
        if (screenName == 'driverDetails') {
           
            map<string, boolean> isValidArr = new map<string, boolean>();
            for (DriverDetailsWrapper each: leadWrapper.Driver_details_Tempc) {
                if (each.First_Name_Tempc == null || String.isEmpty(each.First_Name_Tempc)) {
                    isValidArr.put('First_Name__c', false);
                }
                
                if (each.Last_Name_Tempc == null || String.isEmpty(each.Last_Name_Tempc)) {
                    isValidArr.put('Last_Name__c',false);
                    
                }
                
                // if ((each.Email_Tempc == null || String.isEmpty(each.Email_Tempc)) && (each.Driver_Type_Tempc != 'Driver' && each.Driver_Type_Tempc != 'Co-Owner')) {
                //     isValidArr.put('Email__c',false);
                    
                // }
                
                if (each.Driver_Type_Tempc == null || String.isEmpty(each.Driver_Type_Tempc)) {
                   isValidArr.put('Driver_Type__c', false);
                }

                if ((each.Address_Tempc == null || String.isEmpty(each.Address_Tempc)) && (each.Driver_Type_Tempc != 'Driver' && each.Driver_Type_Tempc != 'Co-Owner')) {
                   isValidArr.put('Address__c', false);
                }
                
                if ((each.City_Tempc == null || String.isEmpty(each.City_Tempc)) && (each.Driver_Type_Tempc != 'Driver' && each.Driver_Type_Tempc != 'Co-Owner')) {
                   isValidArr.put('City__c', false);
                    
                }
                
                if ((each.Country_Tempc == null || String.isEmpty(each.Country_Tempc)) && (each.Driver_Type_Tempc != 'Driver' && each.Driver_Type_Tempc != 'Co-Owner')) {
                   isValidArr.put('Country__c',false);
                   
                }
                
                if ((each.State_Province_Tempc == null || String.isEmpty(each.State_Province_Tempc)) && (each.Driver_Type_Tempc != 'Driver' && each.Driver_Type_Tempc != 'Co-Owner')) {
                   isValidArr.put('State_Province__c', false);
                
                }
                
                if ((each.Postal_Code_Tempc == null || String.isEmpty(each.Postal_Code_Tempc)) && (each.Driver_Type_Tempc != 'Driver' && each.Driver_Type_Tempc != 'Co-Owner')) {
                   isValidArr.put('Postal_Code__c', false);
                  
                }
                
                if (each.License_number_Tempc == null || String.isEmpty(each.License_number_Tempc)) {
                   isValidArr.put('License_number__c', false);
                  
                }
                
                if (each.License_Country_Tempc == null || String.isEmpty(each.License_Country_Tempc)) {
                   isValidArr.put('License_Country__c', false);
                   
                }
                
                if (each.License_State_Tempc == null || String.isEmpty(each.License_State_Tempc)) {
                   isValidArr.put('License_State__c', false);
                   
                }
            }
            
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message driver', 'Missing fields : '+ isValidArr.keySet());
            }
        }
        
        if (screenName == 'termsAndAgreement') {
            map<string, boolean> isValidArr = new map<string, boolean>();
            if (leadWrapper.Terms_Alert_Tempc.Terms_of_Cancellation_Confirmed_Tempc == null) {
                isValidArr.put('Terms_of_Cancellation_Confirmed__c', false);
            }
            
            if (leadWrapper.Terms_Alert_Tempc.Terms_of_Purchase_Confirmed_Tempc == null) {
               isValidArr.put('Terms_of_Purchase_Confirmed__c', false);
            }
            if (!isValidArr.isEmpty() && isValidArr.values().contains(false)) {
                isValid.put('valid', 'false');
                isValid.put('message termsAndAgreement', 'Missing fields : '+ isValidArr.keySet());
            }
        }

        return isValid;
    }

    @AuraEnabled
    public static List<Object> getPicklistValues(String objectApiName, String fieldApiName) {
        try {
            List<Object> options = new List<Object>();
            Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
            Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
            Map<String, Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    
            for (Schema.PicklistEntry f : ple) {
                Map<String, String> optionMap = new Map<String, String>();
                optionMap.put('value', f.getValue());
                optionMap.put('label', f.getLabel());
                options.add(optionMap);
            }
            return options;
        }
        catch(Exception e) {
            CustomErrorExceptionHandlerException.data = 'objectApiName: '+objectApiName+'\nfieldApiName: '+fieldApiName;
            CustomErrorExceptionHandlerException.LogException(e);
            return null;
        }
    }


    @AuraEnabled
    public static Map<String, Map<String, String>> getDependentMapWithTranslations(string objectApiName, String contrfieldApiName, String depfieldApiName) {
        try {
            String controllingField = contrfieldApiName.toLowerCase();
            String dependentField = depfieldApiName.toLowerCase();
            
            Map<String, Map<String, String>> objResults = new Map<String, Map<String, String>>();        
            Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
            Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
            Map<String, Schema.SObjectField> objFieldMap = obj_describe_result.fields.getMap() ;
    
            if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
                return objResults;
            }
    
            Schema.SObjectField theField = objFieldMap.get(dependentField);
            Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
            
            List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
           
            List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
            List<String> controllingValues = new List<String>();
            
            for (Schema.PicklistEntry ple : contrEntries) {
                String value = ple.getValue();
                objResults.put(value, new Map<String, String>());
                controllingValues.add(value);
            }
            
            for (PicklistEntryWrapper plew : depEntries) {
                String label = plew.label;
                String value = plew.value;
                String validForBits = base64ToBits(plew.validFor);
                for (Integer i = 0; i < validForBits.length(); i++) {
                    String bit = validForBits.mid(i, 1);
                    if (bit == '1') {
                        objResults.get(controllingValues.get(i)).put(value, label);
                    }
                }
            }
    
            return objResults;
        }
        catch(Exception e) {
            CustomErrorExceptionHandlerException.data = 'objectApiName: '+objectApiName+'\ncontrfieldApiName: '+contrfieldApiName+'\ndepfieldApiName: '+depfieldApiName;
            CustomErrorExceptionHandlerException.LogException(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getDependentMap(string objectApiName, String contrfieldApiName, String depfieldApiName) {
        try {
            String controllingField = contrfieldApiName.toLowerCase();
            String dependentField = depfieldApiName.toLowerCase();
            
            Map<String, List<String>> objResults = new Map<String, List<String>>();
            Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
            Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
            Map<String, Schema.SObjectField> objFieldMap = obj_describe_result.fields.getMap() ;
    
            if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
                return objResults;
            }
            
            Schema.SObjectField theField = objFieldMap.get(dependentField);
            Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
            
            List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
           
            List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
            List<String> controllingValues = new List<String>();
            
            for (Schema.PicklistEntry ple : contrEntries) {
                String label = ple.getLabel();
                objResults.put(label, new List<String>());
                controllingValues.add(label);
            }
            
            for (PicklistEntryWrapper plew : depEntries) {
                String label = plew.label;
                String validForBits = base64ToBits(plew.validFor);
                for (Integer i = 0; i < validForBits.length(); i++) {
                    String bit = validForBits.mid(i, 1);
                    if (bit == '1') {
                        objResults.get(controllingValues.get(i)).add(label);
                    }
                }
            }
    
            return objResults;
        }
        catch(Exception e) {
            CustomErrorExceptionHandlerException.data = 'objectApiName: '+objectApiName+'\ncontrfieldApiName: '+contrfieldApiName+'\ndepfieldApiName: '+depfieldApiName;
            CustomErrorExceptionHandlerException.LogException(e);
            return null;
        }
    }
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper {
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper() {
        }
    }
    
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    
    
    
    public class NewLeadWrapper {
        Public String Id{get;set;}
        Public String firstName{get;set;}
        Public String lastName{get;set;}
        Public String email{get;set;}
        Public String phone{get;set;}
        public String Policy_Type_Tempc{get;set;}
        Public VehicleDetailsWrapper Vehicle_details_Tempc{get;set;}
        Public TermOptionsWrapper Term_options_Tempc{get;set;}
        Public Boolean Is_Towing_Tempc{get;set;}
        Public List<TowDetailsWrapper> Towing_Tempc{get;set;}
        Public String Territory_options_Tempc{get;set;}
        Public QuoteWrapper Quote_Details_Tempc{get;set;}
        Public ReviewVehicleWrapper Review_vehicle_Tempc{get;set;}
        Public CompanyInfoWrapper Company_details_Tempc{get;set;}
        Public LienHolderWrapper Lienholder_info_Tempc{get;set;}
        Public List<DriverDetailsWrapper> Driver_details_Tempc{get;set;}
        Public TermsAndAgreementWrapper Terms_Alert_Tempc{get;set;}
        Public PaymentWrapper Payment_Details_Tempc{get;set;}
    }
    
    public class VehicleDetailsWrapper {
        public String Vehicle_Type_Tempc{get;set;}
        public String vehicle_sub_type_Tempc{get;set;}
        public String Year_Tempc{get;set;}
        public String Make_Tempc{get;set;}
        public String Model_Tempc{get;set;}
        public String Value_Tempc{get;set;}
        public Boolean Is_there_a_driver_under_21_Tempc{get;set;}
        public Boolean Salvage_Vehicle_Tempc{get;set;}
        public Boolean Is_the_vehicle_used_for_business_purpose_Tempc{get;set;}
        public Boolean Is_this_a_Rental_Vehicle_Tempc{get;set;}
    }
    
    Public class TermOptionsWrapper {
        public String Start_Date_for_Coverage_Tempc{get;set;}
        public String Start_Time_Tempc{get;set;}
        public String End_Date_for_Coverage_Tempc{get;set;}
        public String End_Time_Tempc{get;set;}
        public String term_Tempc{get;set;}
    }
    
    Public class TowDetailsWrapper {
        public String Year_Tempc{get;set;}
        public String Make_Tempc{get;set;}
        public String Model_Tempc{get;set;}
        public String VIN_Number_Tempc{get;set;}
        public String Plate_Tempc{get;set;}
        public String Towed_Unit_Value_Tempc{get;set;}
        public String Days_in_Tow_Tempc{get;set;}
        public String Towed_Unit_Type_Tempc{get;set;}
        public String Street_Legal_Tempc{get;set;}
    }
    
    Public class QuoteWrapper {
        public String Start_Date_for_Coverage_Tempc{get;set;}
        public String End_Date_for_Coverage_Tempc{get;set;}
        public String Start_Time_Tempc{get;set;}
        public String End_Time_Tempc{get;set;}
        public String termDays_Tempc{get;set;}
        public String vehicleValue_Tempc{get;set;}
        public String liability_Tempc{get;set;}
        public String medical_Tempc{get;set;}
        public String coverageType_Tempc{get;set;}
        public String underwriter_Tempc{get;set;}
    }
    
    Public class ReviewVehicleWrapper {
        public String Year_Tempc{get;set;}
        public String Make_Tempc{get;set;}
        public String Model_Tempc{get;set;}
        public String Value_Tempc{get;set;}
        public String Vin_Tempc{get;set;}
        public String Registered_Country_Tempc{get;set;}
        public String Registered_State_Tempc{get;set;}
        public String Registered_Plate_Tempc{get;set;}
        public Boolean Is_the_vehicle_registered_to_a_business_Tempc{get;set;}
        public Boolean Is_Lienholder_Tempc{get;set;}
    }
    
    Public class CompanyInfoWrapper {
        public String Company_Name_Tempc{get;set;}
        public String Company_Phone_Tempc{get;set;}
        public String Tax_ID_Tempc{get;set;}
        public String Company_Country_Tempc{get;set;}
        public String Company_State_Tempc{get;set;}
        public String Company_City_Tempc{get;set;}
        public String Company_Address_Tempc{get;set;}
        public String Company_Zip_Tempc{get;set;}
    }
    
    Public class LienHolderWrapper {
        public String Lienholder_name_Tempc{get;set;}
        public String Lienholder_Phone_Tempc{get;set;}
        public String Lienholder_Fax_Tempc{get;set;}
        public String Lienholder_Street_Tempc{get;set;}
        public String Lienholder_Street_2_Tempc{get;set;}
        public String Lienholder_Country_Tempc{get;set;}
        public String Lienholder_State_Tempc{get;set;}
        public String Lienholder_City_Tempc{get;set;}
        public String Lienholder_Postal_Code_Tempc{get;set;}
    }
    
    Public class DriverDetailsWrapper {
        public String First_Name_tempc{get;set;}
        public String Last_Name_Tempc{get;set;}
        public String Email_Tempc{get;set;}
        public String Phone_Tempc{get;set;}
        public String Dob_Tempc{get;set;}
        public String Driver_Type_Tempc{get;set;}
        public String Primary_insured_Tempc{get;set;}
        public String Address_Tempc{get;set;}
        public String Address_Line_2_Tempc{get;set;}
        public String City_Tempc{get;set;}
        public String Country_Tempc{get;set;}
        public String State_Province_Tempc{get;set;}
        public String Postal_Code_Tempc{get;set;}
        public String License_Country_Tempc{get;set;}
        public String License_State_Tempc{get;set;}
        public String License_number_Tempc{get;set;}
    }
    
    Public class TermsAndAgreementWrapper {
        public String What_is_your_trip_destination_in_US_Tempc{get;set;}
        public String What_is_the_purpose_of_trip_Tempc{get;set;}
        public String How_did_you_hear_about_us_Tempc{get;set;}
        public String Newsletter_Tempc{get;set;}
        public String Announcements_Tempc{get;set;}
        public String Travel_Alerts_Tempc{get;set;}
        public Boolean Terms_of_Cancellation_Confirmed_Tempc{get;set;}
        public Boolean Terms_of_Purchase_Confirmed_Tempc{get;set;}
        Public String Yellow_Card_Tempc{get;set;}
    }
    
    Public class PaymentWrapper {
        public String Street{get;set;}
        public String Street_2{get;set;}
        public String Country{get;set;}
        public String State{get;set;}
        public String City{get;set;}
        public String Postal_Code{get;set;}
        public String cardName{get;set;}
        public String CC_Mask{get;set;}
        public String expMonth{get;set;}
        public String expYear{get;set;}
        public String securityCode{get;set;}
        public Boolean saveCard{get;set;}
    }
}