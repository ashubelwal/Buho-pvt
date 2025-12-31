/**
* @File Name : LiabilityCoverageDetails.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 3, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 3, 2025 |   | Initial Version
**/

public class LiabilityCoverageDetails {

    public static String evaluateFormula(String formula, Map<String, Object> dataMap) {
        System.debug('Fromula evalutor'+formula);
        formula = formula.trim();

        if (formula.startsWithIgnoreCase('IF')) {
            return evaluateIfBlock(formula, dataMap);
        } else if (formula.toLowerCase().startsWith('return')) {
            return extractReturnValue(formula);
        } else {
            return formula;
        }
    }

private static String evaluateIfBlock(String formula, Map<String, Object> dataMap) {
    Integer index = 0;

    while (index < formula.length()) {
        formula = formula.trim();
        
        // Find the next IF or ELSE IF
        if (formula.substring(index).startsWithIgnoreCase('IF') || 
            formula.substring(index).startsWithIgnoreCase('ELSE IF')) {

            // Find start and end of condition
            Integer condStart = formula.indexOf('(', index);
            Integer condEnd = formula.indexOf(')', condStart);
            if (condStart == -1 || condEnd == -1) break;
            String condition = formula.substring(condStart + 1, condEnd).trim();

            // Evaluate the condition
            Boolean conditionResult = evaluateCondition(condition, dataMap);
            System.debug('Boolean condition'+ conditionResult);
            // Get the block content
            Integer blockStart = formula.indexOf('{', condEnd);
            Integer blockEnd = findMatchingBrace(formula, blockStart);
            if (blockStart == -1 || blockEnd == -1) break;
            String block = formula.substring(blockStart + 1, blockEnd).trim();

            if (conditionResult) {
                return evaluateFormula(block, dataMap);
            } else {
                // Move index to after current block
                index = blockEnd + 1;
                continue;
            }

        } else if (formula.substring(index).startsWithIgnoreCase('ELSE')) {
            Integer blockStart = formula.indexOf('{', index);
            Integer blockEnd = findMatchingBrace(formula, blockStart);
            if (blockStart == -1 || blockEnd == -1) break;
            String elseBlock = formula.substring(blockStart + 1, blockEnd).trim();
            return evaluateFormula(elseBlock, dataMap);
        } else {
            break;
        }
    }

    return '';
}



    public static Boolean evaluateCondition(String condition, Map<String, Object> dataMap) {
        condition = condition.trim();

        List<String> operators = new List<String>{'>=', '<=', '==', '!=', '>', '<'};
        for (String op : operators) {
            if (condition.contains(op)) {
                List<String> parts = condition.split(Pattern.quote(op));
                System.debug('Parts'+parts);
                if (parts.size() == 2) {
                    String field = parts[0].trim();
                    String valueStr = parts[1].trim();
                    
                    Object fieldValue = dataMap.get(field);
                    System.debug('Fieldvalue' + fieldValue);
                    System.debug ('Value str'+valuestr);
                    System.debug('Op'+op);
                    if (fieldValue == null) return false;
                    
                    if (fieldValue instanceof Boolean) {
                        Boolean val = valueStr.toLowerCase() == 'true';
                        return op == '==' ? ((Boolean)fieldValue == val) :
                               op == '!=' ? ((Boolean)fieldValue != val) : false;
                    } else if (fieldValue instanceof Integer) {
                        Integer val = Integer.valueOf(valueStr);
                        Integer actual = (Integer)fieldValue;
                        return op == '==' ? (actual == val) :
                               op == '!=' ? (actual != val) :
                               op == '>'  ? (actual > val) :
                               op == '<'  ? (actual < val) :
                               op == '>=' ? (actual >= val) :
                               op == '<=' ? (actual <= val) : false;
                    } else if (fieldValue instanceof String) {
                        String actual = (String)fieldValue;
                        valueStr = valueStr.replaceAll('^\"|\"$', ''); // remove quotes
                        return op == '==' ? (actual == valueStr) :
                               op == '!=' ? (actual != valueStr) : false;
                    }
                }
            }
        }
        return false;
    }

    public static String extractReturnValue(String code) {
        Integer start = code.indexOf('"');
        Integer endl = code.lastIndexOf('"');
        if (start != -1 && endl != -1 && endl > start) {
            return code.substring(start + 1, endl);
        }
        return '';
    }

    public static Integer findMatchingBrace(String str, Integer openIndex) {
        Integer count = 1;
        for (Integer i = openIndex + 1; i < str.length(); i++) {
            if (str.substring(i, i + 1) == '{') count++;
            if (str.substring(i, i + 1) == '}') count--;
            if (count == 0) return i;
        }
        return -1;
    }


	public static String evaluateSimpleFormula(String formula, Map<String, Object> dataMap) {
        // Trim and clean up
        formula = formula.trim();

        // Regular expression to find variable names like Liability__c, Days__c etc.
        Pattern varPattern = Pattern.compile('\\b[A-Za-z_][A-Za-z0-9_]*\\b');
        Matcher m = varPattern.matcher(formula);

        // Replace all variable names with values from dataMap
        while (m.find()) {
            String variable = m.group();
            if (dataMap.containsKey(variable)) {
                Object value = dataMap.get(variable);
                // Use replaceAll with word boundary to prevent partial replacement
                formula = formula.replaceAll('\\b' + Pattern.quote(variable) + '\\b', String.valueOf(value));
            }
        }

        // Remove any extra '+' and spaces from concatenation if needed
        return evaluateStringConcatenation(formula);
    }

    // Basic concatenation handler (e.g., "Covered with " + 100000 -> Covered with 100000)
    public static String evaluateStringConcatenation(String input) {
        List<String> parts = input.split('\\+');
        String result = '';
        for (String part : parts) {
            part = part.trim();
            if (part.startsWith('"') && part.endsWith('"')) {
                part = part.substring(1, part.length() - 1);
            }
            result += part;
        }
        return result;
    }

}