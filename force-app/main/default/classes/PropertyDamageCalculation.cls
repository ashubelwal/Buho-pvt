public without sharing class PropertyDamageCalculation {
                    public static Map<String, Object> calculatePropertyDamage(String coverageInput, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords) {
                        Map<String, Object> response = new Map<String, Object>();
                        
                        try {
                            if (String.isNotBlank(coverageInput)) {
                                // Parse the JSON string into a List
                                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(coverageInput);
                                
                                Map<String, String> propertyDamageData = new Map<String, String>();
                                
                                Map<String, Object> tempMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(vendorData.get('Physical_Damage_Fields__c')));
                                
                                // Create a Map<String, List<String>> to store the final data
                                Map<String, List<Object>> mapData = new Map<String, List<Object>>();
                                
                                // Iterate over the Map<String, Object> and cast each value to List<String>
                                for (String key : tempMap.keySet()) {
                                    // Ensure that the value is a List of Objects and cast it to List<String>
                                    mapData.put(key, (List<Object>) tempMap.get(key));
                                }
                                
                                for(String key : mapData.keySet()){
                                    for(Integer i=0;i<leadDetails.size();i++){
                                        Map<String, Object> leadDetailsData = (Map<String, Object>) leadDetails[i];
                                        if((Boolean) leadDetailsData.keySet().contains(key)){
                                            List<Object> getFields = (List<Object>) mapData.get(key);
                                            Map<String, Object> keyData = (Map<String, Object>) leadDetailsData.get(key); // Cast to Map
                                            
                                            for(Object field : getFields){
                                                System.debug('Lead details data'+leadDetailsData);
                                                System.debug('Serialized Data'+JSON.serialize(keyData));
                                                propertyDamageData.put((String) field, String.valueOf(keyData.get((String) field)));
                                            }
                                        }else{
                                            /*response.put('Message', 'No data found for calculation');
                                            response.put('Status', 'Error');
                                            return response;*/
                                        }
                                    }
                                }
                                system.debug('propertyDamageData@@###'+ propertyDamageData);
                                propertyDamageData = calculateVehicleAge(propertyDamageData);
                                propertyDamageData = calculateDatesInBetween(propertyDamageData);
                                System.debug('Property Damage Data'+propertyDamageData);
                                if(propertyDamageData.get('Coverage__c') != 'Liability'){
                                    Decimal val = evaluateFormula(propertyDamageData , vendorName, (Vendor__c)vendorData, termMetadataRecords);
                                    System.debug('KeySet'+propertyDamageData);
                                    response.put('Status','Success');
                                    response.put('Vendor', vendorName);
                                    response.put('PropertyDamage', val);
                                    response.put('IsIncluded', true);
                                    System.debug('Response'+response);
                                }else{
                                    response.put('Status','Success');
                                    response.put('Vendor', vendorName);
                                    response.put('PropertyDamage',0.00);
                                    response.put('IsIncluded', false);
                                    System.debug('Response'+response);
                                }
                            }
                            
                            return response;
                            
                        } catch (Exception e) {
                            // Log the exception and return an error response
                            
                            response.put('Message', 'An error occurred: ' + e.getMessage()+' at line number'+e.getLineNumber());
                            response.put('Status', 'Error');
                            response.put('Vendor', vendorName);
                            response.put('PropertyDamage', 0.00);
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
                            // CustomErrorExceptionHandlerException.LogException(e);
                            
                            // Handle error by adding an error message to the map
                            mapData.put('Message', 'Invalid Year__c value: ' + mapData.get('Year__c'));
                            mapData.put('Status', 'Error');
                        }
                        return mapData;
                    }
                    
                    public static Decimal evaluateFormula(Map<String, String> fieldValues, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords ) {
                        try{
                            String formula;
                            String str = 'Property_Damage';
                            
                            // Fetch formula from Vendor__c object
                            Vendor__c vendor = vendorData;
                            
                            // Check for the age restrictions in the formula
                            Boolean isAgeIncludedInPropertyDamage = vendor.Is_Age_Included_In_Property_Damage__c != null ? vendor.Is_Age_Included_In_Property_Damage__c : false;
                            if(isAgeIncludedInPropertyDamage){
                                Integer vehicleAge = vendor.Property_Damage_Vehicle_Age_Restriction__c != null ? Integer.valueOf(vendor.Property_Damage_Vehicle_Age_Restriction__c) : 0;
                                if(vehicleAge < Integer.valueOf((String)fieldValues.get('VehicleAge'))){
                                    return 0;
                                }
                            }
                            
                            // Ensure the picklist or multi-select picklist is properly split into a list
                            List<String> availableTermsList = vendor.Property_Term_Available__c != null ? vendor.Property_Term_Available__c.split(';') : new List<String>();
                            // **Retrieve Field List Dynamically from Custom Metadata**
                            List<Term_Mapping__mdt> metadataRecords = termMetadataRecords;
                            List<String> fieldList = new List<String>();
                           
                            for (Term_Mapping__mdt meta : metadataRecords) {
                                if(meta.Term__c == fieldValues.get('Term__c')){
                                    if (availableTermsList.contains(meta.Value__c)) {
                                        str = str + '_' + meta.Value__c;
                                        fieldList.add(meta.Value__c);
                                    } else {
                                        str = str + '_' + 'Term_Daily__c' ;  // This else case is redundant; it's the same as the if case
                                        fieldList.add('Term_Daily__c');
                                        
                                    }
                                    break;
                                }
                            }
                            
                            System.debug('Get String'+str);
                            
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
        }catch(Exception e){
            // Log the exception and return an error response
            CustomErrorExceptionHandlerException.LogException(e);
            return 0; // Default to 0 if an error occurs
        }
    }
    
    private static Decimal executeDynamicQuery(String fieldList, String objectName, String whereClause , String vendorName) {
        try {
            // Construct the dynamic SOQL query
            String query = 'SELECT ' + fieldList + ' FROM ' + objectName + ' WHERE ' + whereClause +'AND Data_type__c = \'Physical Damage\''+' AND Vendor__c = \'' + vendorName + '\' LIMIT 1';
            System.debug('SOQL Query: ' + query);
            
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
    // Calculate the days in between
    private static Map<String, String> calculateDatesInBetween(Map<String, String> mapData){
        try{
            Date startDate = Date.valueOf(mapData.get('Start_Date_for_Coverage__c'));
            Date endDate = Date.valueOf(mapData.get('End_Date_for_Coverage__c'));
            Integer daysBetween = startDate.daysBetween(endDate);
            mapData.put('Days_between_Start_and_End_Date',String.valueOf(daysBetween));
        }catch(Exception e){
            // Log the exception and return an error response
            CustomErrorExceptionHandlerException.LogException(e);
            return mapData;
        }
        return mapData;
    }
    // Evaluating the expression to calculate the values
    public static Decimal evaluateExpression(String expression) {
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