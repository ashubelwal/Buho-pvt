@RestResource(urlMapping='/sendEmailService/*')
global class sendEmailService {
    @HttpPost
    global static void sendEmail() {
        RestRequest request = RestContext.request;
        String body = request.requestBody.toString();
        if( body != null && body != ''){
            map<String,object> sendEmailMap = new map<String,object>();
            sendEmailMap = (map<String,object>)JSON.deserializeUntyped(body);
            list<object> policyIdset = new list<object>();
            policyIdset = (list<object>)sendEmailMap.get('policyIdset');

            set<String> temppolicyIdset = new set<String>();
            for(object pid : policyIdset ){
                temppolicyIdset.add( String.valueOf(pid));
            }
            Boolean add_attachment = Boolean.valueOf(sendEmailMap.get('add_attachment'));
            Database.executeBatch( new BatchTosendQuoteEmail(temppolicyIdset, add_attachment), 1);
        }
        
    }
}