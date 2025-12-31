@isTest
public class PolicyHandlerBatchTest {
    
    @isTest
    public static void createCommunityUser(){
        /* Query Community User Profile */
        Id profileId = [Select Id From Profile Where Name ='Customer Community Plus Login User'].Id;
        Account acc = createAccount('Test Account');
        insert acc;
        Contact con = createContact('test','Contact','test@gmail.com',acc.Id);
        insert con;
        User u = createCommunityUser(con.Id,profileId,'Amit','Singh');
        insert u;
        System.runAs(u){
            Database.executeBatch(new PolicyHandlerBatch());    
        }
    }
    public static User createUser(String roleId, String profId, String firstName, String lastName){
        User tempUser = prepareUser(roleId, profId, firstName, lastName);
        return tempUser;
    }
    
    public static User prepareUser(String roleId, String profId, String firstName, String lastName) {  
        
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = firstName,  
            LastName = lastName,  
            isActive  = true,
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profId
        );    
        if( String.isBlank(roleId) == false ){
            tempUser.UserRoleId = roleId;
        }
        return tempUser;  
    }
    public static User createCommunityUser(String contactId, String profId, String firstName, String lastName) {
        User tempUser = prepareUser('', profId, firstName, lastName);
        tempUser.ContactId = contactId;
        return tempUser;
    }
    public static Account createAccount(String Name){
        Account portalAccount = new Account(name = Name );
        return portalAccount;
    }
    public static Contact createContact(String firstName, String lastName, String email, String accountId){
        Contact portalContact = new contact(
            FirstName = firstName, 
            LastName = lastName, 
            Email = email, 
            AccountId = accountId
        );
        return portalContact;
    }
}