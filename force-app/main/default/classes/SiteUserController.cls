public without sharing class SiteUserController {
    Public static Boolean stopUserTrigger = true;

    @AuraEnabled
    public static String activateUser (String email) {

            SiteUserController.stopUserTrigger = false;
            if (email.length() == 0) {
                throw new UserErrorException('Please provide an email address');
            }
            
            List<User> getUser = [SELECT Id, Name, username,Email, IsActive from User Where Email =: email  limit 1];
            system.debug('User ---> '+ getUser);
            if (getUser.size() > 0) {
                if (getUser[0].IsActive == false) {
                    getUser[0].IsActive = true;
                    
                    Database.DMLOptions dlo = new Database.DMLOptions();
                    dlo.EmailHeader.triggerUserEmail= false;
                    Database.saveresult[] sr = Database.update(getUser, dlo);
                    //update getUser;

                    System.resetPassword(getUser[0].Id, true);
                    return 'Account activated. Kindly check your email!';
                } else {
                    throw new UserErrorException('Your account is already active!');
                }
            } else {
                throw new UserErrorException('No User exist with that email');
            }
               
    }
    
    public class UserErrorException extends Exception {}
}