@IsTest
public class AuthorizeNetMultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
    
    public AuthorizeNetMultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getHeader('Callout-Type'));
        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new MultiRequestMockException('HTTP callout not supported for test methods');
        }
    }
    
    public void addRequestMock(String calloutType, HttpCalloutMock mock) {
        requests.put(calloutType, mock);
    }

    public class MultiRequestMockException extends Exception {}
}