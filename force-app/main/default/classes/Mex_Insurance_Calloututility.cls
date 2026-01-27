public class Mex_Insurance_Calloututility {
    public Mex_Insurance_Calloututility() {

    }

    @future(callout=true)
    public static void sendEmail(set<String> policyIdset, Boolean add_attachment ){
        String endPoint = '/services/apexrest/sendEmailService/*'; 
        map<String,object> ldObjectMap = new map<String,Object>();
        ldObjectMap.put('policyIdset', policyIdset);
        ldObjectMap.put('add_attachment', add_attachment);
        system.debug('ldObjectMap-->'+ldObjectMap);
        
        HttpResponse response = make_request(endPoint, 'POST', JSON.serialize(ldObjectMap) );
        system.debug('sendEmail  response--->'+ response);
        system.debug('sendEmail  response--->'+ response.getBody());
    }

    public static String getLeadId( map<String,object> ldObjectMap ){
        String LeadId = null;
        String whereClose = ' Email=\''+String.valueOf(ldObjectMap.get('Email'))+'\'';
        String query = getLeadQuery( whereClose );
        String endPoint = '/services/data/v50.0/query/?q='+EncodingUtil.urlEncode(query, 'UTF-8');
        HttpResponse response = make_request(endPoint, 'GET', null );
        if(response != null && response.getStatusCode() == 200 && response.getBody() != null  ){
            map<String,object> leadResponseMap = new map<String,object>();
            leadResponseMap = (map<String,object>)JSON.deserializeUntyped(response.getBody());
            if( leadResponseMap != null && leadResponseMap.containsKey('records')){
                list<object> records = (list<object>)leadResponseMap.get('records');
                for(object ldObj : records){
                    map<String,object> leadMap = new map<String,object>();
                    leadMap = (map<String,object>)ldObj;
                    LeadId = String.valueOf(leadMap.get('Id'));
                }
            }
        }

        return LeadId;

    }

    /*public static String updateAccount_Record( String accountId, map<String,object> ldObjectMap ){
        String recordId = null;
        String endPoint = '/services/data/v50.0/sobjects/Account/'+accountId;
        HttpResponse response = make_request(endPoint, 'PATCH', JSON.serialize(ldObjectMap) );
        if(response != null && response.getStatusCode() == 201 && response.getBody() != null  ){
            map<String,object> ResponseMap = new map<String,object>();
            ResponseMap = (map<String,object>)JSON.deserializeUntyped(response.getBody());
            if( ResponseMap != null && ResponseMap.containsKey('id')){
                recordId = String.valueOf(ResponseMap.get('id'));
            } 
        }else if( response != null && response.getStatusCode() == 204 ){
            return accountId;
        }
        return recordId;
    }

    public static String createAccount_Record( map<String,object> ldObjectMap ){
        String recordId = null;
        String endPoint = '/services/data/v50.0/sobjects/Account/';
        HttpResponse response = make_request(endPoint, 'POST', JSON.serialize(ldObjectMap) );
        if(response != null && response.getStatusCode() == 201 && response.getBody() != null  ){
            map<String,object> ResponseMap = new map<String,object>();
            ResponseMap = (map<String,object>)JSON.deserializeUntyped(response.getBody());
            if( ResponseMap != null && ResponseMap.containsKey('id')){
                recordId = String.valueOf(ResponseMap.get('id'));
            }
        }
        return recordId;
    }

    public static String createUser_Record( map<String,object> ldObjectMap ){
        String recordId = null;
        String endPoint = '/services/data/v50.0/sobjects/User/';
        HttpResponse response = make_request(endPoint, 'POST', JSON.serialize(ldObjectMap) );
        if(response != null && response.getStatusCode() == 201 && response.getBody() != null  ){
            map<String,object> ResponseMap = new map<String,object>();
            ResponseMap = (map<String,object>)JSON.deserializeUntyped(response.getBody());
            if( ResponseMap != null && ResponseMap.containsKey('id')){
                recordId = String.valueOf(ResponseMap.get('id'));
            }
        }
        return recordId;
    }*/

    public static String createLead_Record( map<String,object> ldObjectMap ){
        String LeadId = null;
        String endPoint = '/services/data/v50.0/sobjects/Lead/';
        HttpResponse response = make_request(endPoint, 'POST', JSON.serialize(ldObjectMap) );
        if(response != null && response.getStatusCode() == 201 && response.getBody() != null  ){
            map<String,object> leadResponseMap = new map<String,object>();
            leadResponseMap = (map<String,object>)JSON.deserializeUntyped(response.getBody());
            if( leadResponseMap != null && leadResponseMap.containsKey('id')){
                LeadId = String.valueOf(leadResponseMap.get('id'));
            }
        }
        return LeadId;
    }
    
    private static HttpResponse make_request(String endPoint, String Method, String body){
        
        HttpRequest request = new HttpRequest();
        if( Method.equalsIgnoreCase('PATCH')){
            endPoint += '?_HttpMethod=PATCH';
            Method = 'POST';
        }
        request.setEndpoint('callout:Salesforce'+endPoint);
        request.setMethod(Method);
        request.setTimeout(120000);

        System.debug('--endpoint--'+request.getEndpoint());

        if( body != null && body != ''){
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
        }

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('--response--'+response);
        System.debug('--response--'+response.getBody());

        return response;
    }

    private static String getLeadQuery(String whereClose){
        String leadQuery = 'select Id, Name, convertedContactId, convertedAccountId from Lead';
        if( whereClose != null ){
            leadQuery += ' where '+whereClose;
        }
        return leadQuery;
    }
}