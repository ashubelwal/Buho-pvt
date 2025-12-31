@isTest
public class SiteUserController_test {
    @isTest
    public static void postivetesting(){
        
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj; 
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            
            Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        List<user> userList = new List<user>();
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'Test123@gmail.com', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         IsActive = false,
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         UserRoleId = obj.Id); 
        userList.add(uu);
        insert userList;
        SiteUserController.activateUser('Test123@gmail.com');
        //SiteUserController.activateUser('Test1234@gmail.com');
    }
    
    public static void negativetesting(){
        SiteUserController.activateUser('');
        
        
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj; 
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            
            Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        List<user> userList = new List<user>();
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'Test123@gmail.com', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         IsActive = true,
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         UserRoleId = obj.Id); 
         userList.add(uu);
        
        insert userList;
        SiteUserController.activateUser('Test123@gmail.com');
        SiteUserController.activateUser('Test1234@gmail.com');
    }
    
    
}