@isTest
public with sharing class NavigationMenuItemsControllerTest {
    @isTest
    public static void  getNavigationMenuItemsTest() {
        Id mockNetworkId = Test.getStandardPricebookId();
        String mockLinkSetId = '0lTxx0000004CcbEAE';  // Use a valid 18-character Id format

        // Mock data for NavigationMenuItem
        List<NavigationMenuItem> mockMenuItems = new List<NavigationMenuItem>();
        
        NavigationMenuItem testItem1 = new NavigationMenuItem();
        testItem1.Label = 'Item 1';
        testItem1.Target = '/item1';
        testItem1.Type = 'Internal';
        testItem1.Status = 'Live';
        testItem1.NavigationLinkSetId = mockLinkSetId;
        testItem1.Position = 1;
        mockMenuItems.add(testItem1);
        
        NavigationMenuItem testItem2 = new NavigationMenuItem();
        testItem2.Label = 'Item 2';
        testItem2.Target = '/item2';
        testItem2.Type = 'Internal';
        testItem2.Status = 'Live';
        testItem2.NavigationLinkSetId = mockLinkSetId;
        testItem2.Position = 2;
        mockMenuItems.add(testItem2);
        
        NavigationMenuItem testItem3 = new NavigationMenuItem();
        testItem3.Label = 'Item 3';
        testItem3.Target = '/item3';
        testItem3.Type = 'Internal';
        testItem3.Status = 'Draft';
        testItem3.NavigationLinkSetId = mockLinkSetId;
        testItem3.Position = 3;
        mockMenuItems.add(testItem3);

        Test.startTest();

        // Use a mocked method to bypass SOQL execution in actual logic if needed
        List<NavigationMenuItem> liveItems = NavigationMenuItemsController.getNavigationMenuItems('TestMenu', 'Live');
        List<NavigationMenuItem> draftItems = NavigationMenuItemsController.getNavigationMenuItems('TestMenu', 'Draft');

        Test.stopTest();
    }
}