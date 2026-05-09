@IsTest
private class ShowObjectFieldsCtrlTest {
    @IsTest
    static void testShowObjectFieldsControllerCoverage() {
        PageReference p = Page.ShowObjectFields;
        Test.setCurrentPage(p);
        ApexPages.currentPage().getParameters().put('objectName', 'Account');

        Test.startTest();
        ShowObjectFieldsCtrl ctrl = new ShowObjectFieldsCtrl();
        ctrl.objectName = 'Contact';
        ctrl.loadFields();
        List<String> accountFields = ShowObjectFields.getAllFields('Account');
        Test.stopTest();

        System.assertNotEquals(null, ctrl.fields, 'Controller fields list should not be null.');
        System.assert(ctrl.fields.size() > 0, 'Controller should return at least one field for Contact.');
        System.assert(accountFields.size() > 0, 'Utility class should return fields for Account.');
    }
}
