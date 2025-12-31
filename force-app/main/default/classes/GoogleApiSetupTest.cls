@isTest
public class GoogleApiSetupTest {

    @isTest
    public static void testGetAddress() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String searchString = 'San Francisco';

        Test.startTest();
        List<GoogleApiSetup.SuggestionWrapper> suggestions = GoogleApiSetup.getAddress(searchString);
        Test.stopTest();

        GoogleApiSetup.SuggestionWrapper suggestion = new GoogleApiSetup.SuggestionWrapper('Test Address', 'TestPlaceId');
       
    }

    @isTest
    public static void testGetPlaceDetails() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String placeId = 'testPlaceId';

        Test.startTest();
        String placeDetails = GoogleApiSetup.getPlaceDetails(placeId);
        Test.stopTest();

    }
}