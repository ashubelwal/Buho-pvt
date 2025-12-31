public with sharing class AgentAppChart {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPolicyDataforPieChart(String policyTerm,String userId) {
        if (String.isBlank(userId)) {
            throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
        }
        List<String> policyTypes = new List<String>{'Automobile-Van-Minivan', 'Motorhome', 'Motorcycle', 'ATV-UTV-Quads-Buggie','SUV-Crossover','Pickup'};
        User userRecord = [SELECT Id, Profile.Name,contactId FROM User WHERE Id = :userId LIMIT 1];
        System.debug('userRecord:::'+userRecord);
        String filterField = userRecord.Profile.Name == 'Agency Community Plus Login User' ? 'Agency__c' : 'Agent__c';
        String contactId = userRecord.contactId;
        String query ='';
        
        if (String.isBlank(policyTerm)) {
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount ' +
                'FROM Policy__c ' +
                'WHERE ' + filterField + ' = :contactId AND Policy_Type_picklist__c IN: policyTypes ' +
                'GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }else{
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount ' +
                'FROM Policy__c ' +
                'WHERE ' + filterField + ' = :contactId AND Policy_Type_picklist__c IN: policyTypes AND CreatedDate = ' + policyTerm + 
                ' GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }
        
        
        
        List<AggregateResult> aggregateResults = Database.query(query);
        List<Map<String, Object>> policyData = new List<Map<String, Object>>();
        
        for (AggregateResult result : aggregateResults) {
            policyData.add(new Map<String, Object>{
                'Policy_Type_picklist__c' => result.get('Policy_Type_picklist__c'),
                    'renewed_check__c' => result.get('renewed_check__c'),
                    'totalCount' => (Integer) result.get('totalCount')
                    });
        }
        System.debug('policyData:::'+policyData);
        return policyData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPolicyDataforBarChart(String policyTerm, String userId) {
        if (String.isBlank(userId)) {
            throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
        }
        List<String> policyTypes = new List<String>{'Automobile-Van-Minivan', 'Motorhome', 'Motorcycle', 'ATV-UTV-Quads-Buggie','SUV-Crossover','Pickup'};
        User userRecord = [SELECT Id, Profile.Name,contactId FROM User WHERE Id = :userId LIMIT 1];
        Contact contactData = new Contact();
        String contactId = userRecord.contactId;
        String query ='';
        
        if(contactId != null){
            contactData = [SELECT id,name,Commission_Mex_Auto_Renew__c, Commission_Mex_Auto_New__c, Commission_Mex_Moto_New__c, Commission_Mex_Moto_Renew__c, Commission_Mex_RV_New__c, Commission_Mex_RV_Renew__c FROM contact WHERE id =:contactId];
        }
        if (String.isBlank(policyTerm)) {
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount,SUM(Total_Transaction_Amount__c) totalAmount FROM Policy__c WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN: policyTypes GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }else{
            query = 'SELECT Policy_Type_picklist__c,renewed_check__c, COUNT(Id) totalCount,SUM(Total_Transaction_Amount__c) totalAmount FROM Policy__c WHERE Agency__c = :contactId  AND Policy_Type_picklist__c IN: policyTypes AND CreatedDate = ' + policyTerm + 
                ' GROUP BY Policy_Type_picklist__c,renewed_check__c';
            System.debug('query:::' + query);
        }
        
        List<AggregateResult> aggregateResults = Database.query(query);
        List<Map<String, Object>> policyData = new List<Map<String, Object>>();
        
        Map<String, Map<Boolean, String>> policyTypeMappings = new Map<String, Map<Boolean, String>>{
            'Automobile' => new Map<Boolean, String>{
                false => 'Commission_Mex_Auto_New__c',
                    true  => 'Commission_Mex_Auto_Renew__c'
                    },
                        'Motorcycle/Street Legal ATV' => new Map<Boolean, String>{
                            false => 'Commission_Mex_Moto_New__c',
                                true  => 'Commission_Mex_Moto_Renew__c'
                                },
                                    'RV' => new Map<Boolean, String>{
                                        false => 'Commission_Mex_RV_New__c',
                                            true  => 'Commission_Mex_RV_Renew__c'
                                            }
        };
            
            for (AggregateResult result : aggregateResults) {
                String policyType = (String) result.get('Policy_Type_picklist__c');
                Boolean isRenewed = (Boolean) result.get('renewed_check__c');
                Decimal totalAmountValue = (Decimal) result.get('totalAmount');
                
                if (policyTypeMappings.containsKey(policyType)) {
                    String commissionField = policyTypeMappings.get(policyType).get(isRenewed);
                    
                    if (!String.isBlank(commissionField) && contactData.get(commissionField) != null) {
                        Decimal commissionValue = (Decimal) contactData.get(commissionField);
                        Double calculatedValue = (totalAmountValue / 100) * commissionValue;
                        System.debug('commissionValue::'+commissionValue);
                        System.debug('totalAmountValue:::'+totalAmountValue); 
                        System.debug('calculatedValue:::'+calculatedValue);
                        policyData.add(new Map<String, Object>{
                            'Policy_Type_picklist__c' => policyType + (isRenewed ? ' Renew' : ' New'),
                                'totalCount' => calculatedValue
                                });
                    }
                }
            }
        
        System.debug('policyData:::' + policyData);
        return policyData;
    }

    @AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getPolicyDataforBarChartNetPremium(String policyTerm, String userId) {
    if (String.isBlank(userId)) {
        throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
    }

    List<String> policyTypes = new List<String>{'Automobile-Van-Minivan', 'Motorhome', 'Motorcycle'};
    User userRecord = [SELECT Id, Profile.Name, ContactId FROM User WHERE Id = :userId LIMIT 1];
    String contactId = userRecord.ContactId;

    String query = '';
    if (String.isBlank(policyTerm)) {
        query = 'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount, SUM(Total_Transaction_Amount__c) totalAmount, SUM(Net_Premium__c) netValue ' +
                'FROM Policy__c ' +
                'WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN :policyTypes ' +
                'GROUP BY Policy_Type_picklist__c, renewed_check__c';
    } else {
        query = 'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount, SUM(Total_Transaction_Amount__c) totalAmount, SUM(Net_Premium__c) netValue ' +
                'FROM Policy__c ' +
                'WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN :policyTypes AND CreatedDate = ' + policyTerm + ' ' +
                'GROUP BY Policy_Type_picklist__c, renewed_check__c';
    }

    List<AggregateResult> aggregateResults = Database.query(query);
    List<Map<String, Object>> policyData = new List<Map<String, Object>>();

    for (AggregateResult result : aggregateResults) {
        String policyType = (String) result.get('Policy_Type_picklist__c');
        Boolean isRenewed = (Boolean) result.get('renewed_check__c');
        Decimal totalAmountValue = (Decimal) result.get('netValue');

        // Añadir directamente sin validar comisión
        policyData.add(new Map<String, Object>{
            'Policy_Type_picklist__c' => policyType + (isRenewed ? ' Renew' : ' New'),
            'totalCount' => totalAmountValue
        });
    }

    System.debug('policyData:::' + policyData);
    return policyData;
}

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getPolicyDataforBarChartNetPremiumComission(String policyTerm, String userId) {
    if (String.isBlank(userId)) {
        throw new AuraHandledException('Agent or Agency ID cannot be null or empty.');
    }

    List<String> policyTypes = new List<String>{'Automobile-Van-Minivan', 'Motorhome', 'Motorcycle', 'ATV-UTV-Quads-Buggie','SUV-Crossover','Pickup'};
    User userRecord = [SELECT Id, Profile.Name, ContactId FROM User WHERE Id = :userId LIMIT 1];
    String contactId = userRecord.ContactId;

    String query = '';
    if (String.isBlank(policyTerm)) {
        query = 'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount, SUM(Total_Transaction_Amount__c) totalAmount, SUM(Net_Premium__c) netValue ' +
                'FROM Policy__c ' +
                'WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN :policyTypes ' +
                'GROUP BY Policy_Type_picklist__c, renewed_check__c';
    } else {
        query = 'SELECT Policy_Type_picklist__c, renewed_check__c, COUNT(Id) totalCount, SUM(Total_Transaction_Amount__c) totalAmount, SUM(Net_Premium__c) netValue ' +
                'FROM Policy__c ' +
                'WHERE Agency__c = :contactId AND Policy_Type_picklist__c IN :policyTypes AND CreatedDate = ' + policyTerm + ' ' +
                'GROUP BY Policy_Type_picklist__c, renewed_check__c';
    }

    List<AggregateResult> aggregateResults = Database.query(query);
List<Map<String, Object>> policyData = new List<Map<String, Object>>();

for (AggregateResult result : aggregateResults) {
    String policyType = (String) result.get('Policy_Type_picklist__c');
    Boolean isRenewed = (Boolean) result.get('renewed_check__c');
    Decimal totalAmountValue = (Decimal) result.get('netValue');

    // Multiplicar el valor por 0.3
    Decimal adjustedValue = totalAmountValue * 0.3;

    policyData.add(new Map<String, Object>{
        'Policy_Type_picklist__c' => policyType + (isRenewed ? ' Renew' : ' New'),
        'totalCount' => adjustedValue
    });
}

System.debug('policyData:::' + policyData);
return policyData;

}
}