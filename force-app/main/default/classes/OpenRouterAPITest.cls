@isTest
private class OpenRouterAPITest {

@isTest
    static void testGetChatResponse() {
        // Mock data
        String userMessage = 'Help';
        String knowledgeContext = 'Knowledge context mock';

        // Set up HTTP mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method to be tested
        String response = OpenRouterAPI.getChatResponse(userMessage);

        // Assert the response
        System.assertNotEquals(null, response, 'Response should not be null');
    }
}