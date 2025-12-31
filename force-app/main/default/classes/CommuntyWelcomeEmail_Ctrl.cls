public class CommuntyWelcomeEmail_Ctrl {
	public Id contactIdPassedCtrl{get; set;}
    //public User useObj{get;set;}
	
    public void CommuntyWelcomeEmail_Ctrl(){
		
	}
    
    public User getUserObj(){
        List<User> usersFromContact = [SELECT Name, UserName, Profile.Name FROM User WHERE ContactId = :contactIdPassedCtrl LIMIT 1];

		if(usersFromContact != null && !usersFromContact.isEmpty()){
            return usersFromContact[0];
		}
        return null;
    }
}