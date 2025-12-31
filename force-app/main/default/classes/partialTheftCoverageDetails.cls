/**
* @File Name : partialTheftCoverageDetails.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 4, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 4, 2025 |   | Initial Version
**/

public class partialTheftCoverageDetails {
	public static String evaluateFormula(String formula, Map<String, Object> dataMap) {
        try {
            return parseIfElseFormula(formula.trim(), dataMap);
        } catch (Exception e) {
            System.debug('Error in formula evaluation: ' + e.getMessage());
            return null;
        }
    }
    
    private static String parseIfElseFormula(String formula, Map<String, Object> dataMap) {
        formula = formula.trim();
        
        Integer index = 0;
        while (index < formula.length()) {
            Boolean isIfBlock = false;
            Boolean isElseIfBlock = false;
            Boolean isElseBlock = false;
            
            String lowerFormula = formula.substring(index).toLowerCase();
            
            if (lowerFormula.startsWith('if')) {
                isIfBlock = true;
                index += 2;
            } else if (lowerFormula.startsWith('else if')) {
                isElseIfBlock = true;
                index += 7;
            } else if (lowerFormula.startsWith('else')) {
                isElseBlock = true;
                index += 4;
            } else {
                break;
            }
            
            // Skip whitespace
            while (index < formula.length() && formula.substring(index, index + 1) == ' ') index++;
            
            String condition = null;
            if (isIfBlock || isElseIfBlock) {
                if (index >= formula.length() || formula.substring(index, index + 1) != '(') {
                    return null;
                }
                Integer condStart = index + 1;
                Integer condEnd = findMatchingParen(formula, index);
                condition = formula.substring(condStart, condEnd).trim();
                index = condEnd + 1;
                while (index < formula.length() && formula.substring(index, index + 1) == ' ') index++;
            }
            
            if (index >= formula.length() || formula.substring(index, index + 1) != '{') {
                return null;
            }
            Integer blockStart = index + 1;
            Integer blockEnd = findMatchingBrace(formula, index);
            String blockValue = formula.substring(blockStart, blockEnd).trim();
            index = blockEnd + 1;
            while (index < formula.length() && formula.substring(index, index + 1) == ' ') index++;
            
            if (isIfBlock || isElseIfBlock) {
                if (evaluateCondition(condition, dataMap)) {
                    return blockValue.contains('+') ? evaluateBlockValue(blockValue, dataMap) : stripQuotes(blockValue);
                }
            } else if (isElseBlock) {
                // NEW: Check if blockValue starts with IF (case-insensitive), call parseIfElseFormula recursively
                if (blockValue.trim().toLowerCase().startsWith('if')) {
                    return parseIfElseFormula(blockValue, dataMap);
                } else {
                    return blockValue.contains('+') ? evaluateBlockValue(blockValue, dataMap) : stripQuotes(blockValue);
                }
            }
            
        }
        
        // No condition matched and no ELSE found
        return '';
    }
    
    private static Integer findMatchingParen(String str, Integer openIndex) {
        Integer count = 0;
        for (Integer i = openIndex; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            if (ch == '(') count++;
            else if (ch == ')') {
                count--;
                if (count == 0) return i;
            }
        }
        return count;
    }
    
    private static Integer findMatchingBrace(String str, Integer openIndex) {
        Integer count = 0;
        Boolean inQuotes = false;
        for (Integer i = openIndex; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            if (ch == '"') inQuotes = !inQuotes;
            if (!inQuotes) {
                if (ch == '{') count++;
                else if (ch == '}') {
                    count--;
                    if (count == 0) return i;
                }
            }
        }
        return count;
    }
    
    private static Boolean evaluateCondition(String condition, Map<String, Object> dataMap) {
        condition = condition.trim();
        
        // Operators to check (longest first)
        List<String> ops = new List<String>{'>=', '<=', '==', '!=', '>', '<'};
            
            for (String op : ops) {
                Integer opIndex = condition.indexOf(op);
                if (opIndex > 0) {
                    String left = condition.substring(0, opIndex).trim();
                    String right = condition.substring(opIndex + op.length()).trim();
                    right = stripQuotes(right);
                    
                    Object leftVal = dataMap.get(left);
                    if (leftVal == null) return false;
                    
                    String leftStr = String.valueOf(leftVal);
                    
                    // Special case for UpdatedVehicleValue - always treat as Decimal for comparisons
                    if (left.equalsIgnoreCase('UpdatedVehicleValue')) {
                        try {
                            Decimal leftNum = Decimal.valueOf(leftStr);
                            Decimal rightNum = Decimal.valueOf(right);
                            if (op == '==') return leftNum == rightNum;
                            else if (op == '!=') return leftNum != rightNum;
                            else if (op == '>') return leftNum > rightNum;
                            else if (op == '<') return leftNum < rightNum;
                            else if (op == '>=') return leftNum >= rightNum;
                            else if (op == '<=') return leftNum <= rightNum;
                        } catch (Exception e) {
                            return false; // If parsing fails, treat condition as false
                        }
                    }
                    
                    
                    // Try numeric comparison if both are numbers
                    Decimal leftNum = null;
                    Decimal rightNum = null;
                    Boolean numericComparison = false;
                    try {
                        leftNum = Decimal.valueOf(leftStr);
                        rightNum = Decimal.valueOf(right);
                        numericComparison = true;
                    } catch (Exception e) {
                        numericComparison = false;
                    }
                    
                    if (op == '==') {
                        if (numericComparison) return leftNum == rightNum;
                        else return leftStr == right;
                    } else if (op == '!=') {
                        if (numericComparison) return leftNum != rightNum;
                        else return leftStr != right;
                    } else if (numericComparison) {
                        if (op == '>') return leftNum > rightNum;
                        else if (op == '<') return leftNum < rightNum;
                        else if (op == '>=') return leftNum >= rightNum;
                        else if (op == '<=') return leftNum <= rightNum;
                    } else {
                        // For string comparisons '>' or '<', use lex order
                        if (op == '>') return leftStr.compareTo(right) > 0;
                        else if (op == '<') return leftStr.compareTo(right) < 0;
                        else if (op == '>=') return leftStr.compareTo(right) >= 0;
                        else if (op == '<=') return leftStr.compareTo(right) <= 0;
                    }
                }
            }
        
        // If no operator matched or unknown condition
        return false;
    }
    
    private static String stripQuotes(String input) {
        input = input.trim();
        if (input.startsWith('"') && input.endsWith('"') && input.length() >= 2) {
            return input.substring(1, input.length() - 1);
        }
        return input;
    }
    
    private static String evaluateBlockValue(String block, Map<String, Object> dataMap) {
        // Split by '+' while handling quotes
        List<String> parts = new List<String>();
        String current = '';
        Boolean inQuotes = false;
        
        for (Integer i = 0; i < block.length(); i++) {
            String ch = block.substring(i, i + 1);
            if (ch == '"') inQuotes = !inQuotes;
            
            if (ch == '+' && !inQuotes) {
                parts.add(current.trim());
                current = '';
            } else {
                current += ch;
            }
        }
        if (!String.isBlank(current)) parts.add(current.trim());
        
        String result = '';
        for (String part : parts) {
            part = part.trim();
            if (part.startsWith('"') && part.endsWith('"')) {
                result += part.substring(1, part.length() - 1); // Strip quotes
            } else {
                Object val = dataMap.get(part);
                result += (val != null ? String.valueOf(val) : '');
            }
        }
        return result;
    }
}