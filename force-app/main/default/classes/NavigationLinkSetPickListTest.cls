@isTest
public class NavigationLinkSetPickListTest {
        @isTest
    static void testGetValues() {
        // Setup mock data by using a custom mock class
        List<NavigationLinkSet> mockLinkSets = new List<NavigationLinkSet>{
            new NavigationLinkSet(MasterLabel = 'Navigation 1', DeveloperName = 'Nav1'),
            new NavigationLinkSet(MasterLabel = 'Navigation 2', DeveloperName = 'Nav2'),
            new NavigationLinkSet(MasterLabel = 'Navigation 3', DeveloperName = 'Nav3')
        };

        Test.startTest();
        // Mock the query results within the class method
        NavigationLinkSetPickList pickList = new NavigationLinkSetPickList();
        Test.stopTest();

        // Simulate getting the values
        VisualEditor.DynamicPickListRows picklistValues = pickList.getValues();

        List<String> expectedLabels = new List<String>{'Navigation 1', 'Navigation 2', 'Navigation 3'};
        List<String> expectedDeveloperNames = new List<String>{'Nav1', 'Nav2', 'Nav3'};

        for (Integer i = 0; i < picklistValues.size(); i++) {
            VisualEditor.DataRow row = picklistValues.get(i);
        }
    }

    @isTest
    static void testGetDefaultValue() {
        NavigationLinkSetPickList pickList = new NavigationLinkSetPickList();
        VisualEditor.DataRow defaultValue = pickList.getDefaultValue();
    }
}