public with sharing class ShowObjectFieldsCtrl {
    public String objectName { get; set; }
    public List<String> fields { get; set; }

    public ShowObjectFieldsCtrl() {
        objectName = ApexPages.currentPage().getParameters().get('objectName');
        loadFields();
    }

    public void loadFields() {
        fields = ShowObjectFields.getAllFields(objectName);
        if (String.isNotBlank(objectName) && (fields == null || fields.isEmpty())) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No fields found or invalid object name.'));
        }
    }
}
