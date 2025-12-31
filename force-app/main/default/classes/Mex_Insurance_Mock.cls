@isTest
public class Mex_Insurance_Mock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = '';
        if( req.getEndpoint().containsIgnoreCase('/services/data/v50.0/query/?q')){
            body = '{ "done": true, "totalSize": 14, "records": [{ "Id": null }] }';
            res.setStatusCode(200);
        }else if( req.getEndpoint().containsIgnoreCase('/services/apexrest/sendEmailService/') ){
            body = '{ "done": true, "totalSize": 14, "records": [{ "Id": null }] }';
            res.setStatusCode(200);
        }else if( req.getEndpoint().containsIgnoreCase('/services/data/v50.0/sobjects/Lead/') ){
            body = '{ "done": true, "id": null  }';
            res.setStatusCode(201);
        }
        res.setBody(body);
        
        return res;
    }
}