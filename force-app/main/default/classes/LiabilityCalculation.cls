public without sharing class LiabilityCalculation {
        public static Map<String, Object> calculateLiability(String jsonString, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords) {
            Map<String, Object> response = new Map<String, Object>();
            
            try {
                if (String.isNotBlank(jsonString)) {
                    // Parse the JSON string into a List
                    List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(jsonString);
                    
                    Map<String, String> propertyDamageData = new Map<String, String>();
                    
                    Map<String, Object> tempMap = (Map<String, Object>) JSON.deserializeUntyped( (String)vendorData.get('Liability_Fields__c'));
                    
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
                    Decimal val = evaluateFormula(propertyDamageData ,vendorName, (Vendor__c)vendorData, termMetadataRecords);
                    System.debug('KeySet'+propertyDamageData);
                    response.put('Status','Success');
                    response.put('Vendor', vendorName);
                    response.put('Liability', val);
                    System.debug('Response'+response);
                }
                
                return response;
                
            } catch (Exception e) {
                // Log the exception and return an error response
                response.put('Message', 'An error occurred: ' + e.getMessage()+' at line number'+e.getLineNumber());
                response.put('Status', 'Error');
                response.put('Vendor', vendorName);
                response.put('Liability', 0.00);
                return response;
            }
        }
        
        
        // Calculate the days in between
        private static Map<String, String> calculateDatesInBetween(Map<String, String> mapData){
            try{
                Date startDate = Date.valueOf(mapData.get('Start_Date_for_Coverage__c'));
                Date endDate = Date.valueOf(mapData.get('End_Date_for_Coverage__c'));
                Integer daysBetween = startDate == endDate ? 1 : startDate.daysBetween(endDate);
                mapData.put('Days_between_Start_and_End_Date',String.valueOf(daysBetween));
            }catch(Exception e){
                // // Log the exception and return an error response
                // CustomErrorExceptionHandlerException.LogException(e);
                // response.put('Message', 'An error occurred: ' + e.getMessage());
                // response.put('Status', 'Error');
                // return response;
            }
            return mapData;
        }
        
        
        public static Decimal evaluateFormula(Map<String, String> fieldValues, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords) {
            String formula = '';
            String str = 'Liability';
            
            // Fetch formula from Vendor__c object
            Vendor__c vendor = vendorData;
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
            
            System.debug('Get String'+str);
            // Use dynamic SOQL to query the field value
            try {
                Vendor__c towedFormula = (Vendor__c) vendorData;
                if (towedFormula != null) {
                    formula = (String) towedFormula.get(str);
                }
            } catch (Exception e) {
                System.debug('Error fetching formula: ' + e.getMessage());
                return 0;
            }
            
            System.debug('Formula Value: ' + formula);
            
            // Replace field placeholders `{Field__c}` with actual values
            formula = replaceFieldValues(formula, fieldValues);
            
            // Handle `Query([...], Object, [Condition])` statements
            formula = processQueryStatements(formula, fieldValues, vendorName, fieldList);
            
            System.debug('Final Evaluated Expression: ' + formula);
            
            // Evaluate the final mathematical expression
            return evaluateExpression(formula);
        }
        
        private static String replaceFieldValues(String formula, Map<String, String> fieldValues) {
            Matcher fieldMatcher = Pattern.compile('\\{([^}]+)\\}').matcher(formula);
            while (fieldMatcher.find()) {
                String fieldName = fieldMatcher.group(1);
                String replacementValue = fieldValues.containsKey(fieldName) ? fieldValues.get(fieldName) : '0';
            formula = formula.replace('{' + fieldName + '}', replacementValue);
        }
        return formula;
    }
    
    private static String processQueryStatements(String formula, Map<String, String> fieldValues, String vendorName, List<String> fieldList) {
        Matcher queryMatcher = Pattern.compile('Query\\(\\[(.*?)\\],\\s*(\\w+),\\s*\\[(.*?)\\]\\)').matcher(formula);
        while (queryMatcher.find()) {
            String objectName = queryMatcher.group(2);
            String whereClause = queryMatcher.group(3);
            
            whereClause = replaceFieldValues(whereClause, fieldValues);
            
            String fieldListStr = fieldList.isEmpty() ? 'Id' : String.join(fieldList, ', ');
            System.debug('Executing Query: SELECT ' + fieldListStr + ' FROM ' + objectName + ' WHERE ' + whereClause);
            
            Decimal queryResult = executeDynamicQuery(fieldListStr, objectName, whereClause, vendorName);
            formula = formula.replace(queryMatcher.group(0), String.valueOf(queryResult));
        }
        return formula;
    }
    
    
    private static Decimal executeDynamicQuery(String fieldList, String objectName, String whereClause , String vendorName) {
        try {
            // Construct the dynamic SOQL query
            String query = 'SELECT ' + fieldList + ' FROM ' + objectName + ' WHERE ' + whereClause +' AND Object_Name__c = \'Liability\' '+' AND Data_type__c = null'+' AND Vendor__c = \'' + vendorName + '\' LIMIT 1';
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