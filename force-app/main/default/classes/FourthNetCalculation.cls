public without sharing class FourthNetCalculation {
    private static Map<String, Object> response = new Map<String, Object>(); // Keep as a class variable

    public static Map<String, Object> calculateNetFourth(String jsonString, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords,Map<String,String> quoteData) {
        
        try {
            if (String.isNotBlank(jsonString)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(jsonString);
                
                Map<String, String> propertyDamageData = new Map<String, String>();
                
                Map<String, Object> tempMap = (Map<String, Object>) JSON.deserializeUntyped( (String)vendorData.get('Net_Fourth_Fields__c'));
                
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
                propertyDamageData = calculateDatesInBetween(propertyDamageData);
                System.debug('Property Damage Data'+propertyDamageData);
                    Decimal val = evaluateFormula(propertyDamageData , vendorName, (Vendor__c)vendorData, termMetadataRecords,quoteData);
                    System.debug('KeySet'+propertyDamageData);
                    response.put('Status','Success');
                    response.put('Vendor', vendorName);
                    response.put('NetFourth', val);
                    response.put('Message', 'Success');
                    System.debug('Response'+response);
            }
            
            return response;
            
        } catch (Exception e) {
            // Log the exception and return an error response
            response.put('Message', 'An error occurred: ' + e.getMessage());
            response.put('Status', 'Error');
            response.put('Vendor', vendorName);
            response.put('NetFourth', 0.00);
            response.put('Message', 'Success');
            System.debug('Response'+response);
            return response;
        }
    }
    private static Map<String, String> calculateDatesInBetween(Map<String, String> mapData) {
        try {
            Date startDate = Date.valueOf(mapData.get('Start_Date_for_Coverage__c'));
            Date endDate = Date.valueOf(mapData.get('End_Date_for_Coverage__c'));
            Integer daysBetween = startDate.daysBetween(endDate);
            mapData.put('Days_between_Start_and_End_Date', String.valueOf(daysBetween));
        } catch (Exception e) {
            // // Log the exception and return an error response
            // CustomErrorExceptionHandlerException.LogException(e);
            // response.put('Message', 'An error occurred: ' + e.getMessage());
            // response.put('Status', 'Error');
            // return response;
        }
        return mapData;
}

    public static Decimal evaluateFormula(Map<String, String> fieldValues, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords,Map<String,String> quoteData) {
                        String formula;
                        String str = 'Net_Fourth';
                        
                        // **Retrieve Field List Dynamically from Custom Metadata**
                        List<Term_Mapping__mdt> metadataRecords = termMetadataRecords;
                        List<String> fieldList = new List<String>();
                        
                        for (Term_Mapping__mdt meta : metadataRecords) {
                            if (meta.Term__c == fieldValues.get('Term__c')) {
                                    str = str + '_' + meta.Value__c;
                                    fieldList.add(meta.Value__c);
                                    
                                }
                        }

                        if(fieldList.size() < 0){
                                str = str + '_' + 'Term_Daily__c'; // This else case is redundant; it's the same as the if case
                                fieldList.add('Term_Daily__c');
                        }
                        
                        // Use dynamic SOQL to query the field value                        
                        Vendor__c towedFormula = (Vendor__c) vendorData;
                        
                        if (towedFormula != null) {
                            formula = (String) towedFormula.get(str); // Get dynamic field value
                        }
                        
                        System.debug('Formula Value: ' + formula);
                        
                        // Replace field placeholders `{Field__c}` with actual values
                        Matcher fieldMatcher = Pattern.compile('\\{([^}]+)\\}').matcher(formula);
                        while (fieldMatcher.find()) {
                            String fieldName = fieldMatcher.group(1);
                            if (fieldValues.containsKey(fieldName)) {
                            formula = formula.replace('{' + fieldName + '}', fieldValues.get(fieldName));
                        }else if(quoteData.containsKey(fieldName)){
                            formula = formula.replace('{' + fieldName + '}', String.valueOf(quoteData.get(fieldName)));
                        } else {
                        formula = formula.replace('{' + fieldName + '}', '0'); // Default missing fields to 0
                    }
                }
                      
                // Handle `Query([...], Object, [Condition])` statements
                Matcher queryMatcher = Pattern.compile('Query\\(\\[(.*?)\\],\\s*(\\w+),\\s*\\[(.*?)\\]\\)').matcher(formula);
                while (queryMatcher.find()) {
                    String fieldListStr = queryMatcher.group(1);
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
        private static Decimal executeDynamicQuery(String fieldList, String objectName, String whereClause, String vendorName) {
        try {
            // Construct the dynamic SOQL query
            String query = 'SELECT ' + fieldList + ' FROM ' + objectName + ' WHERE ' + whereClause +  ' AND Vendor__c = \'' + vendorName + '\' LIMIT 1';
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
                    totalValue += Decimal.valueOf((String) queriedRecord.get(field));
                }
            }
            
            System.debug('Debug for total value' + totalValue);
            
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
        Map<String, Integer> precedence = new Map<String, Integer>{'+' => 1, '-' => 1, '*' => 2, '/' => 2};
        
        List<String> output = new List<String>();
        List<String> operators = new List<String>();
        
        for (String token : tokens) {
            if (token.isNumeric() || token.contains('.')) {
                output.add(token);
            } else if (precedence.containsKey(token)) {
                while (!operators.isEmpty() && precedence.containsKey(operators[operators.size() - 1])
                && precedence.get(token) <= precedence.get(operators[operators.size() - 1])) {
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
                
                if (token == '+')
                    stack.add(a + b);
                else if (token == '-')
                    stack.add(a - b);
                else if (token == '*')
                    stack.add(a * b);
                else if (token == '/')
                    stack.add(a / b);
            }
        }
        
        return stack[0];
    }
}