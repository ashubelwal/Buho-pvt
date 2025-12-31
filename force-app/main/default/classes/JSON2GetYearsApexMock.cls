global class JSON2GetYearsApexMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
         HttpResponse res = new HttpResponse();
         res.setBody('?({ "Years": {"min_year":"1941", "max_year":"2022"} });');
         return res;
    }
}