global class JSON2GetModelApexMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
         HttpResponse res = new HttpResponse();
         res.setBody('{"Count":7,"Message":"Results returned successfully","SearchCriteria":"Make:ACURA &#124; ModelYear:2021","data":[{"name":"model"},{"name":"model"}],"Results":[{"Make_ID":475,"Make_Name":"ACURA","Model_ID":5168,"Model_Name":"NSX"},{"Make_ID":475,"Make_Name":"ACURA","Model_ID":2147,"Model_Name":"MDX"},{"Make_ID":475,"Make_Name":"ACURA","Model_ID":1871,"Model_Name":"RDX"},{"Make_ID":475,"Make_Name":"ACURA","Model_ID":29419,"Model_Name":"TLX TYPE S "},{"Make_ID":475,"Make_Name":"ACURA","Model_ID":2150,"Model_Name":"ILX"},{"Make_ID":475,"Make_Name":"ACURA","Model_ID":5354,"Model_Name":"TLX"},{"Make_ID":475,"Make_Name":"ACURA","Model_ID":2149,"Model_Name":"RLX"}]}');
         return res;
    }
}