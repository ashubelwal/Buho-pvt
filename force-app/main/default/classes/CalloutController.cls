public class CalloutController {
// Unique label corresponding to the continuation
    public String requestLabel;
    // Result of callout
    public String result {get;set;}
    
    public Object startRequest() {
        //this part up here is common to both the callout 
        //and continuations approaches
        String sessionId = UserInfo.getSessionId();
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionID);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        
        //this doesn't actually work because we don't have a real web service to call
        //but you get the idea.
        req.setEndpoint('test_endpoint');
        
        req.setMethod('GET');
        
        //Here's how it works with a callout
        Http h = new Http();
        HttpResponse res = h.send(req);
        result = res.getBody();
        return null;
        //and that is all. This works fine until the service is too slow and lots of people use it.
        
    }
    
   
}