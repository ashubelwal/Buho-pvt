public without sharing class RoadsideTravelCalculation {        
    private static Map<String, Object> response = new Map<String, Object>(); // Keep as a class variable

    public static Map<String, Object> calculateRoadsideTravel(String jsonString, String vendorName, Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords) {
        
        try {
            if (String.isNotBlank(jsonString)) {
                // Parse the JSON string into a List
                List<Object> leadDetails = (List<Object>) JSON.deserializeUntyped(jsonString);
                
                Map<String, String> propertyDamageData = new Map<String, String>();
                
                Map<String, Object> tempMap = (Map<String, Object>) JSON.deserializeUntyped( (String)vendorData.get('RoadsideTravel_Fields__c'));
                
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
                    Decimal val = evaluateRoadsideTravelFormula(propertyDamageData , vendorName,jsonString,(Vendor__c)vendorData, termMetadataRecords);
                    System.debug('KeySet'+propertyDamageData);
                    response.put('Status','Success');
                    response.put('Vendor', vendorName);
                    response.put('RoadsideTravel', val);
                    response.put('Days_between_Start_and_End_Date', propertyDamageData.get('Days_between_Start_and_End_Date'));
                    response.put('Message', 'Success');
                    System.debug('Response'+response);
            }
            
            return response;
            
        } catch (Exception e) {
            // Log the exception and return an error response
            response.put('Message', 'An error occurred: ' + e.getMessage());
            response.put('Status', 'Error');
            response.put('Vendor', vendorName);
            response.put('RoadsideTravel', 0.00);
            response.put('Message', 'Exception');
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

    public static Decimal evaluateRoadsideTravelFormula(Map<String, String> fieldValues, String vendorName, String jsonData,Vendor__c vendorData, List<Term_Mapping__mdt> termMetadataRecords) {
        // List of base fields we need to process
        List<String> strList = new List<String>{'RoadsideTravel', 'LegalCalculation', 'PlaneTicketsCalculation', 'PartialTheftCalculation', 'RentalCarCalculation'};
        Map<String, Decimal> evaluatedResults = new Map<String, Decimal>();
    
        // **Retrieve Field List Dynamically from Custom Metadata**
        List<Term_Mapping__mdt> metadataRecords = termMetadataRecords;
    
        // Map to store field mappings
        Map<String, String> fieldMappings = new Map<String, String>();
    
        for (String str : strList) {
            String dynamicField = str;
    
            // Get the correct API name for the field
            List<String> fieldList = new List<String>();
            for (Term_Mapping__mdt meta : metadataRecords) {
                if (meta.Term__c == fieldValues.get('Term__c')) {
                    dynamicField = dynamicField + '_' + meta.Value__c;
                    fieldList.add(meta.Value__c);
                }
            }
    
            // Default value if no specific mapping is found
            if (fieldList.isEmpty()) {
                dynamicField = dynamicField + '_Term_Daily__c';
                fieldList.add('Term_Daily__c');
            }
    
            fieldMappings.put(str, dynamicField);
        }
    
        // **Dynamically Query Vendor Object for Multiple Fields**
        List<String> selectedFields = new List<String>();
        for (String key : fieldMappings.keySet()) {
            selectedFields.add(fieldMappings.get(key));
        }
    
        Vendor__c vendorRecord = (Vendor__c) vendorData;
    
        // **Retrieve Roadside Rates Calculation Data**
        Map<String, Object> roadsideCalculationData = RoadsideRatesCalculation.calculateRoadsideRates(jsonData, vendorName, (Vendor__c)vendorData, termMetadataRecords);

        response.put('Legal', roadsideCalculationData.get('Legal'));
        response.put('Roadside', roadsideCalculationData.get('Roadside'));
        response.put('TravelAssist', roadsideCalculationData.get('TravelAssist'));
        response.put('AirplaneTickets', roadsideCalculationData.get('AirplaneTickets'));
        response.put('PartialTheft', roadsideCalculationData.get('PartialTheft'));
        response.put('RentalCar', roadsideCalculationData.get('RentalCar'));

        Map<String, String> calculationMapping = new Map<String, String>{
    'RentalCarCalculation'     => 'RentalCar',
    'PartialTheftCalculation'  => 'PartialTheft',
    'PlaneTicketsCalculation'  => 'AirplaneTickets',
    'LegalCalculation'  => 'Legal',
    'RoadsideTravel'  => 'Roadside'
};

    
        // **Process Each Field Formula**
        for (String key : fieldMappings.keySet()) {
            String fieldName = fieldMappings.get(key);
            if (vendorRecord != null) {
                String formula = (String) vendorRecord.get(fieldName);
                System.debug('Original Formula for ' + key + ': ' + formula);

                if(formula != null){
    
                // Replace `{Field}` placeholders with values from roadsideCalculationData and fieldValues
                formula = replacePlaceholders(formula, fieldValues, roadsideCalculationData);
    
                // **Handle Query Statements in the Formula**
                formula = processQueryStatements(formula, fieldValues, vendorName);
    
                System.debug('Evaluated Formula for ' + key + ': ' + formula);
    
                // **Evaluate the final mathematical expression**
                Decimal result = evaluateExpression(formula);
                evaluatedResults.put(key, result);
                if(calculationMapping.containsKey(key)){
                    response.put(calculationMapping.get(key),result);
                }
              }
            }
        }
    
        System.debug('Final Evaluated Results: ' + evaluatedResults);
    
        // Returning the first computed value, modify as per requirement
        return evaluatedResults.isEmpty() ? 0 : evaluatedResults.get('RoadsideTravel');
    }
    
    /**
     * Replaces placeholders in the formula with actual values from maps.
     */
    private static String replacePlaceholders(String formula, Map<String, String> fieldValues, Map<String, Object> roadsideCalculationData) {
        Matcher fieldMatcher = Pattern.compile('\\{([^}]+)\\}').matcher(formula);
        while (fieldMatcher.find()) {
            String fieldName = fieldMatcher.group(1);
            if (roadsideCalculationData.containsKey(fieldName)) {
                formula = formula.replace('{' + fieldName + '}', String.valueOf(roadsideCalculationData.get(fieldName)));
            } else if (fieldValues.containsKey(fieldName)) {
                formula = formula.replace('{' + fieldName + '}', fieldValues.get(fieldName));
            } else {
                formula = formula.replace('{' + fieldName + '}', '0'); // Default missing fields to 0
            }
        }
        return formula;
    }
    
    /**
     * Processes and executes Query statements found inside the formula.
     */
    private static String processQueryStatements(String formula, Map<String, String> fieldValues, String vendorName) {
        Matcher queryMatcher = Pattern.compile('Query\\(\\[(.*?)\\],\\s*(\\w+),\\s*\\[(.*?)\\]\\)').matcher(formula);
        while (queryMatcher.find()) {
            String fieldListStr = queryMatcher.group(1);
            String objectName = queryMatcher.group(2);
            String whereClause = queryMatcher.group(3);
    
            // **Replace field placeholders inside WHERE clause**
            whereClause = replacePlaceholders(whereClause, fieldValues, new Map<String, Object>());
    
            System.debug('Executing Query: SELECT ' + fieldListStr + ' FROM ' + objectName + ' WHERE ' + whereClause);
    
            // Execute query and replace in formula
            Decimal queryResult = executeDynamicQuery(fieldListStr, objectName, whereClause, vendorName);
            formula = formula.replace(queryMatcher.group(0), String.valueOf(queryResult));
        }
        return formula;
    }
    
    /**
     * Executes the dynamic SOQL query and returns the result.
     */
    private static Decimal executeDynamicQuery(String fieldListStr, String objectName, String whereClause, String vendorName) {
        String query = 'SELECT ' + fieldListStr + ' FROM ' + objectName + ' WHERE ' + whereClause + ' LIMIT 1';
        List<SObject> results = Database.query(query);
        if (!results.isEmpty()) {
            SObject record = results[0];
            Object value = record.get(fieldListStr.split(',')[0].trim()); // Take first field if multiple
            return value != null ? Decimal.valueOf(String.valueOf(value)) : 0;
        }
        return 0;
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