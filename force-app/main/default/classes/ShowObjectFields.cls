public without sharing class ShowObjectFields {
    private static Set<String> removeFields = new Set<String>{
        'isdeleted', 'createddate', 'createdbyid',
        'lastmodifieddate', 'lastmodifiedbyid',
        'systemmodstamp', 'lastvieweddate',
        'lastreferenceddate'
    };

    public static List<String> getAllFields(String objectName) {
        SObjectType objectType = describeObject(objectName);
        if (objectType == null) {
            return new List<String>();
        }

        Map<String, Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();

        List<String> fieldsSet = new List<String>();
        for (String s : mfields.keySet()) {
            if (mfields.get(s).getDescribe().isAccessible()) {
                fieldsSet.add(s);
            }
        }

        if (fieldsSet != null && !fieldsSet.contains('Id') && !fieldsSet.contains('id')) {
            fieldsSet.add('Id');
        }

        fieldsSet.sort();
        return fieldsSet;
    }

    private static SObjectType describeObject(String objectName) {
        if (String.isBlank(objectName)) {
            return null;
        }
        return Schema.getGlobalDescribe().get(objectName.trim());
    }
}
