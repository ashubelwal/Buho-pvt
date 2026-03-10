public without sharing class TowedTotalTheftCalculation {
    public static Map<String, Object> calculateTowedTotalTheftCalculation(String jsonString, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords) {
        Map<String, Object> response = new Map<String, Object>();
        try{
            // Query the text field from Custom Settings
            String textFieldValue = (String)vendorData.get('Towed_Property_Damage_Fields__c');
            
            // Deserialize the text field JSON mapping
            Map<String, Object> fieldMapping = (Map<String, Object>) JSON.deserializeUntyped(textFieldValue);
            System.debug('Field Mapping: ' + fieldMapping);
            
            // Deserialize the input JSON data
            List<Object> dataList = (List<Object>) JSON.deserializeUntyped(jsonString);
            System.debug('DataList: ' + dataList);
            
            // Initialize the result map
            Map<String, String> dynamicData = new Map<String, String>();
            
            // Iterate over the mapping JSON keys (e.g., "vehicleDetails", "termOption")
            for (String parentKey : fieldMapping.keySet()) {
                System.debug('Parent key: ' + parentKey);
                
                // Loop through the JSON data list to find matching keys
                for (Object obj : dataList) {
                    Map<String, Object> dataMap = (Map<String, Object>) obj;
                    System.debug('DataMap: ' + dataMap);
                    
                    if (dataMap.containsKey(parentKey)) {
                        // Get the nested data (e.g., vehicleDetails, termOption)
                        Map<String, Object> nestedData = (Map<String, Object>) dataMap.get(parentKey);
                        Object mappingValue = fieldMapping.get(parentKey);
                        System.debug('Mapping Values: ' + mappingValue);
                        
                        if (mappingValue instanceof Map<String, Object>) {
                            // Handling nested structures (e.g., vehicleDetails, towunits)
                            Map<String, Object> childMapping = (Map<String, Object>) mappingValue;
                            
                            for (String childKey : childMapping.keySet()) {
                                if (nestedData.containsKey(childKey)) {
                                    Object extractedData = nestedData.get(childKey);
                                    
                                    if (extractedData instanceof String || extractedData instanceof Boolean || extractedData instanceof Integer) {
                                        // Store simple field values (e.g., isTowing)
                                        dynamicData.put(childKey, String.valueOf(extractedData));
                                    } else if (extractedData instanceof Map<String, Object>) {
                                        // Handling nested structures (e.g., towunits)
                                        Map<String, Object> childData = (Map<String, Object>) extractedData;
                                        List<Object> fieldsToExtract = (List<Object>) childMapping.get(childKey);
                                        
                                        Integer totalValue = 0;
                                        String towDays = '';
                                        
                                        for (String key : childData.keySet()) {
                                            Map<String, Object> towUnit = (Map<String, Object>) childData.get(key);
                                            
                                            for (Object fieldName : fieldsToExtract) {
                                                String fieldStr = (String) fieldName;
                                                
                                                if (fieldStr == 'Towed_Unit_Value__c') {
                                                    totalValue += Integer.valueOf(String.valueOf(towUnit.get(fieldStr)));
                                                } else if (fieldStr == 'Days_in_Tow__c') {
                                                    towDays = String.valueOf(towUnit.get(fieldStr));
                                                }
                                            }
                                        }
                                        
                                        dynamicData.put('Towed_Unit_Value__c', String.valueOf(totalValue));
                                        dynamicData.put('Days_in_Tow__c', towDays);
                                    }else if (extractedData instanceof List<Object>) {
                                        // Handle List case using existing variable names
                                        List<Object> childData = (List<Object>) extractedData;
                                        List<Object> fieldsToExtract = (List<Object>) childMapping.get(childKey);
                                        Integer totalValue = 0;
                                        String towDays = '';
                                        
                                        for (Object item : childData) {
                                            if (item instanceof Map<String, Object>) {
                                                Map<String, Object> towUnit = (Map<String, Object>) item;
                                                
                                                for (Object fieldName : fieldsToExtract) {
                                                    String fieldStr = (String) fieldName;
                                                    System.debug('Fields string'+fieldStr);
                                                    if (fieldStr == 'Towed_Unit_Value__c' && towUnit.containsKey(fieldStr)) {
                                                        totalValue += Integer.valueOf(String.valueOf(towUnit.get(fieldStr)));
                                                    } else if (fieldStr == 'Days_in_Tow__c' && towUnit.containsKey(fieldStr)) {
                                                        towDays = String.valueOf(towUnit.get(fieldStr));
                                                    }
                                                }
                                            }
                                        }
                                        
                                        dynamicData.put('Towed_Unit_Value__c', String.valueOf(totalValue));
                                        dynamicData.put('Days_in_Tow__c', towDays);
                                    }
                                }
                            }
                        } else if (mappingValue instanceof List<Object>) {
                            // Handle non-nested structures like termOption
                            List<Object> fieldList = (List<Object>) mappingValue;
                            System.debug('FieldList: ' + fieldList);
                            System.debug('Nested Data: ' + nestedData);
                            
                            for (Object fieldItem : fieldList) {
                                if (nestedData.containsKey((String) fieldItem)) {
                                    dynamicData.put((String) fieldItem, String.valueOf(nestedData.get((String) fieldItem)));
                                }
                            }
                        }
                    }
                }
            }
            
            // Perform additional calculations if needed
            dynamicData = calculateDatesInBetween(dynamicData);
            dynamicdata = calculateVehicleAge(dynamicData);
            // Evaluate formula if isTowing is true
            if (dynamicData.containsKey('isTowing') && Boolean.valueOf(dynamicData.get('isTowing')) && dynamicData.get('Coverage__c') != 'Liability' ) {
                System.debug('Towed Data: ' + dynamicData);
                Decimal val = evaluateFormula(dynamicData, vendorName, (Vendor__c)vendorData, termMetadataRecords);
                response.put('Status', 'Success');
                response.put('Vendor', vendorName);
                response.put('TowedTotalTheft', val);
                response.put('IsIncluded', true);
                System.debug('Response: ' + response);
            } else {
                response.put('Status', 'Success');
                response.put('Vendor', vendorName);
                response.put('TowedTotalTheft', 0.00);
                response.put('IsIncluded',false);
                System.debug('Response: ' + response);
            }
            
            return response;
        } catch (Exception e) {
            // Log the exception and return an error response
            response.put('Message', 'An error occurred: ' + e.getMessage() + ' at line'+ e.getLineNumber());
            response.put('Status', 'Error');
            response.put('Vendor', vendorName);
            response.put('TowedTotalTheft', 0.00);
            return response;
        }
    }
    
    // Calculate vehicle age
    private static Map<String, String> calculateVehicleAge(Map<String, String> mapData) {
        try {
            // Get the current year
            Integer currentYear = Date.today().year();
            
            // Convert vehicleYear from the map
            Integer vehicleYear = Integer.valueOf(mapData.get('Year__c'));
            
            // Calculate vehicle age difference
            Integer vehicleAge = currentYear - vehicleYear;
            
            // Store the calculated age difference in the map
            mapData.put('VehicleAge', String.valueOf(vehicleAge));
        } catch (Exception e) {
            // Log the exception (uncomment if you have a logging mechanism)
            CustomErrorExceptionHandlerException.LogException(e);
            
            // Handle error by adding an error message to the map
            mapData.put('Message', 'Invalid Year__c value: ' + mapData.get('Year__c'));
            mapData.put('Status', 'Error');
        }
        return mapData;
    }
    
    
    // Calculate the days in between
    private static Map<String, String> calculateDatesInBetween(Map<String, String> mapData) {
        try {
            Date startDate = Date.valueOf(mapData.get('Start_Date_for_Coverage__c'));
            Date endDate = Date.valueOf(mapData.get('End_Date_for_Coverage__c'));
            Integer daysBetween = startDate.daysBetween(endDate);
            mapData.put('Days_between_Start_and_End_Date', String.valueOf(daysBetween));
        } catch (Exception e) {
            // // Log the exception and return an error response
            CustomErrorExceptionHandlerException.LogException(e);
            mapData.put('Message', 'An error occurred: ' + e.getMessage());
            mapData.put('Status', 'Error');
            return mapData;
        }
        return mapData;
    }
    
    
    public static Decimal evaluateFormula(Map<String, String> fieldValues, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords) {
        String formula;
        String str = 'Towed_Total_Theft';
        
        // Fetch formula from Vendor__c object
        Vendor__c vendor = (Vendor__c)vendorData;
        
        // Check for the age restrictions in the formula
        Boolean isAgeIncludedInPropertyDamage = vendor.Is_Age_Included_In_Towed_Property_Damage__c != null ? vendor.Is_Age_Included_In_Towed_Property_Damage__c : false;
        if(isAgeIncludedInPropertyDamage){
            Integer vehicleAge = vendor.Property_Damage_Vehicle_Age_Restriction__c != null ? Integer.valueOf(vendor.Property_Damage_Vehicle_Age_Restriction__c) : 0;
            if(vehicleAge < Integer.valueOf((String)fieldValues.get('VehicleAge'))){
                return 0;
            }
        }
        
        // Ensure the picklist or multi-select picklist is properly split into a list
        List<String> availableTermsList = vendor.Towed_Term_Available__c != null ? vendor.Towed_Term_Available__c.split(';') : new List<String>();
        // **Retrieve Field List Dynamically from Custom Metadata**
        List<Term_Mapping__mdt> metadataRecords = termMetadataRecords;
        List<String> fieldList = new List<String>();
        
        // for (Term_Mapping__mdt meta : metadataRecords) {
        //     if(meta.Term__c == fieldValues.get('Term__c')){
        //         if (availableTermsList.contains(meta.Value__c)) {
        //             str = str + '_' + meta.Value__c;
        //             fieldList.add(meta.Value__c);
                    
        //         } else {
        //             str = str + '_' + 'Term_Daily__c' ;  // This else case is redundant; it's the same as the if case
        //             fieldList.add('Term_Daily__c');
                    
        //         }
        //     }
        // }

        Integer daysInTow = Integer.valueOf(String.valueOf(fieldValues.get('Days_in_Tow__c')));

        // if (daysInTow < 180) {
        //         System.debug('Towed for less than 180 days');
        //         if (availableTermsList.contains('Term_Daily__c')) {
        //             str += '_Term_Daily__c';
        //             fieldList.add('Term_Daily__c');
        //         } else {
        //             str += '_Term_Daily__c';
        //             fieldList.add('Term_Daily__c'); // fallback to Term_Daily__c
        //         }

        //     } else if (daysInTow < 365) {
        //         System.debug('Towed for between 180 and 364 days');
        //         if (availableTermsList.contains('Term_180__c')) {
        //             str += '_Term_180__c';
        //             fieldList.add('Term_180__c');
        //         } else {
        //             str += '_Term_Daily__c';
        //             fieldList.add('Term_Daily__c'); // fallback
        //         }

        //     } else {
        //         System.debug('Towed for 365 days or more');
        //         if (availableTermsList.contains('Term_365__c')) {
        //             str += '_Term_365__c';
        //             fieldList.add('Term_365__c');
        //         } else {
        //             str += '_Term_Daily__c';
        //             fieldList.add('Term_Daily__c'); // fallback
        //         }
        //     }

        if(daysInTow < 30){
                if (availableTermsList.contains('Term_Daily__c')) {
                    str += '_Term_Daily__c';
                    fieldList.add('Term_Daily__c');
                } else {
                    str += '_Term_Daily__c';
                    fieldList.add('Term_Daily__c'); // fallback to Term_Daily__c
                }
            }else if(daysInTow < 90){
                if (availableTermsList.contains('Term_30__c')) {
                    str += '_Term_30__c';
                    fieldList.add('Term_30__c');
                } else {
                    str += '_Term_Daily__c';
                    fieldList.add('Term_Daily__c'); // fallback to Term_Daily__c
                }
            }else if(daysInTow < 180){
                if (availableTermsList.contains('Term_90__c')) {
                    str += '_Term_90__c';
                    fieldList.add('Term_90__c');
                } else {
                    str += '_Term_Daily__c';
                    fieldList.add('Term_Daily__c'); // fallback to Term_Daily__c
                }
            }else if(daysInTow < 365){
                if (availableTermsList.contains('Term_180__c')) {
                    str += '_Term_180__c';
                    fieldList.add('Term_180__c');
                } else {
                    str += '_Term_Daily__c';
                    fieldList.add('Term_Daily__c'); // fallback to Term_Daily__c
                }
            }else if(daysInTow == 365){
                if (availableTermsList.contains('Term_365__c')) {
                    str += '_Term_365__c';
                    fieldList.add('Term_365__c');
                } else {
                    str += '_Term_Daily__c';
                    fieldList.add('Term_Daily__c'); // fallback to Term_Daily__c
                }
            }
            else{

                str += '_Term_Daily__c';
                fieldList.add('Term_Daily__c'); // fallback to Term_Daily__c

            }
        
        // Use dynamic SOQL to query the field value
        Vendor__c towedFormula = (Vendor__c) vendorData;
        
        if (towedFormula != null) {
            formula = (String) towedFormula.get(str);  // Get dynamic field value
        }
        
        System.debug('Formula Value: ' + formula);
        
        // Replace field placeholders `{Field__c}` with actual values
        Matcher fieldMatcher = Pattern.compile('\\{([^}]+)\\}').matcher(formula);
        while (fieldMatcher.find()) {
            String fieldName = fieldMatcher.group(1);
            if (fieldValues.containsKey(fieldName)) {
                formula = formula.replace('{' + fieldName + '}', fieldValues.get(fieldName));
            } else {
                formula = formula.replace('{' + fieldName + '}', '0'); // Default missing fields to 0
            }
        }
        
        
        
        // If no fields found, default to '*' (not recommended but ensures no failure)
        String fieldListStr = fieldList.isEmpty() ? 'Id' : String.join(fieldList, ', ');
        
        // Handle `Query([...], Object, [Condition])` statements
        Matcher queryMatcher = Pattern.compile('Query\\(\\[(.*?)\\],\\s*(\\w+),\\s*\\[(.*?)\\]\\)').matcher(formula);
        while (queryMatcher.find()) {
            //String fieldList = queryMatcher.group(1);
            String objectName = queryMatcher.group(2);
            String whereClause = queryMatcher.group(3);
            
            // **NEW: Replace field placeholders inside WHERE clause**
            Matcher whereFieldMatcher = Pattern.compile('\\{([^}]+)\\}').matcher(whereClause);
            while (whereFieldMatcher.find()) {
                String whereFieldName = whereFieldMatcher.group(1);
                if (fieldValues.containsKey(whereFieldName)) {
                    whereClause = whereClause.replace('{' + whereFieldName + '}', fieldValues.get(whereFieldName));
                } else {
                    whereClause = whereClause.replace('{' + whereFieldName + '}', '0'); // Default missing WHERE values to 0
                }
            }
            
            System.debug('Executing Query: SELECT ' + fieldListStr + ' FROM ' + objectName + ' WHERE ' + whereClause);
            
            // Execute query and replace in formula
            Decimal queryResult = executeDynamicQuery(fieldListStr, objectName, whereClause, vendorName);
            formula = formula.replace(queryMatcher.group(0), String.valueOf(queryResult));
        }
        
        System.debug('Final Evaluated Expression: ' + formula);
        
        // Evaluate the final mathematical expression
        return evaluateExpression(formula);
    }
    
    private static Decimal executeDynamicQuery(String fieldList, String objectName, String whereClause , String vendorName) {
        try {
            // Construct the dynamic SOQL query
            // Construct the dynamic SOQL query
            String query = 'SELECT ' + fieldList + ' FROM ' + objectName + ' WHERE ' + whereClause + 'AND Data_type__c = \'Total Theft\''
                + ' AND Vendor__c = \'' + vendorName + '\' LIMIT 1';            System.debug('SOQL Query: ' + query);
            
            // Execute the query
            SObject queriedRecord = Database.query(query);
            
            System.debug('Query Result: ' + queriedRecord);
            
            // Extract and sum field values
            Decimal totalValue = 0;
            List<String> fields = fieldList.split(',');
            for (String field : fields) {
                field = field.trim();
                if (queriedRecord.get(field) != null) {
                    totalValue += Decimal.valueOf((String)queriedRecord.get(field));
                }
            }
            
            System.debug('Debug for total value'+totalValue);
            
            return totalValue;
        } catch (Exception e) {
            System.debug('Error executing dynamic query: ' + e.getMessage());
            return 0; // Default to 0 if no records found or error occurs
        }
    }
    
    // Evaluating the expression to calculate the values
    private static Decimal evaluateExpression(String expression) {
        try {
            // Remove spaces
            expression = expression.replace(' ', '');
            
            // Convert infix to postfix (Reverse Polish Notation)
            List<String> postfix = infixToPostfix(tokenizeExpression(expression));
            
            // Evaluate the postfix expression
            return evaluatePostfix(postfix);
        } catch (Exception e) {
            throw new IllegalArgumentException('Invalid formula expression: ' + expression);
        }
    }
    // Tokenizes the expression
private static List<String> tokenizeExpression(String expression) {
    List<String> tokens = new List<String>();
    String currentNumber = '';
    Boolean expectUnary = true; // Expect unary minus at beginning or after operator/parenthesis

    for (Integer i = 0; i < expression.length(); i++) {
        String ch = expression.substring(i, i + 1);

        if (ch == '-' && expectUnary) {
            currentNumber += ch; // Start of a negative number
        } else if (ch.isNumeric() || ch == '.') {
            currentNumber += ch;
            expectUnary = false;
        } else {
            if (currentNumber != '') {
                tokens.add(currentNumber);
                currentNumber = '';
            }
            if (ch.trim() != '') {
                tokens.add(ch);
                expectUnary = (ch == '(' || ch == '+' || ch == '-' || ch == '*' || ch == '/');
            }
        }
    }

    if (currentNumber != '') {
        tokens.add(currentNumber);
    }

    return tokens;
}

    // Converts infix to postfix (Reverse Polish Notation)
    private static List<String> infixToPostfix(List<String> tokens) {
        Map<String, Integer> precedence = new Map<String, Integer>{
            '+' => 1, '-' => 1, '*' => 2, '/' => 2
                };
                    
                    List<String> output = new List<String>();
        List<String> operators = new List<String>();
        
        for (String token : tokens) {
            if (token.isNumeric() || token.contains('.')) {
                output.add(token);
            } else if (precedence.containsKey(token)) {
                while (!operators.isEmpty() && precedence.containsKey(operators[operators.size() - 1]) &&
                       precedence.get(token) <= precedence.get(operators[operators.size() - 1])) {
                           output.add(operators.remove(operators.size() - 1));
                       }
                operators.add(token);
            } else if (token == '(') {
                operators.add(token);
            } else if (token == ')') {
                while (!operators.isEmpty() && operators[operators.size() - 1] != '(') {
                    output.add(operators.remove(operators.size() - 1));
                }
                operators.remove(operators.size() - 1);
            }
        }
        
        while (!operators.isEmpty()) {
            output.add(operators.remove(operators.size() - 1));
        }
        
        return output;
    }
    // Evaluates the postfix expression
    private static Decimal evaluatePostfix(List<String> tokens) {
        List<Decimal> stack = new List<Decimal>();
        
        for (String token : tokens) {
            if (token.isNumeric() || token.contains('.')) {
                stack.add(Decimal.valueOf(token));
            } else {
                Decimal b = stack.remove(stack.size() - 1);
                Decimal a = stack.remove(stack.size() - 1);
                
                if (token == '+') stack.add(a + b);
                else if (token == '-') stack.add(a - b);
                else if (token == '*') stack.add(a * b);
                else if (token == '/') stack.add(a / b);
            }
        }
        
        return stack[0];
    }
}