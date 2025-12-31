public class Mex_LogACaseHandler {
    
    @AuraEnabled(cacheable=true)
    public static boolean checkCommunityUserAndFetchDetails() {
        String userType = UserInfo.getUserType();
        return !userType.equalsIgnoreCase('Guest');        
    }
        @AuraEnabled(cacheable=true)
        public static List<caseTypeOptions__c> getCaseTypeCustomSettings(){
            List<caseTypeOptions__c> caseTypeOptions = caseTypeOptions__c.getall().values();
            
            return caseTypeOptions;
        } 
        @AuraEnabled
        public static map<string, string> createLogACaseMethod(string caseType, string caseDiscription, string userEmail){
            map<string, string> responseMap = new map<string, string>();
            try{
                if(caseType != Null ){
                    user userObj = [SELECT Id, Name, Email, ContactId FROM User where id =: userinfo.getuserid()];
                    case caseObj = new case();
                    caseObj.Reason = caseType;
                    caseObj.Description = caseDiscription;
                    caseObj.Status = 'New';
                    caseObj.ContactId = userObj.ContactId;
                    caseObj.SuppliedEmail = userEmail;
                    insert caseObj;
                    //   JSON
                    responseMap.put('status', 'success');
                    responseMap.put('errorObjId', caseObj.Id);
                }
                return responseMap;            
            }
            catch(Exception ex){
                responseMap.put('status', 'error');
                responseMap.put('message', ex.getMessage());
                return responseMap;
            }
        }
        
        @AuraEnabled(cacheable=true)
        public static List<Case> fetchAllCaseRealtedContact(){
            user userObj = [SELECT Id, Name, Email, ContactId FROM User where id =: userinfo.getuserid()];
            List<Case> getAllRealtedcase = [SELECT Id, CaseNumber, ContactId, Type, Status, Comments,Reason, Description  FROM Case where ContactId =: userObj.ContactId];
            return getAllRealtedcase;
        }
        
    }