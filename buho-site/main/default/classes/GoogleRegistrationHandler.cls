global class GoogleRegistrationHandler implements Auth.RegistrationHandler {

    global User createUser(Id portalId, Auth.UserData data) {
        System.debug('@@@'+data);
        
        if (String.isBlank(data.email)) {
            if (data.provider == 'Apple') {
                throw new Auth.AuthProviderPluginException(
                    'Apple did not share your email address. To resolve this, go to Settings > [Your Name] > Sign-In & Security > Sign in with Apple on your Apple device, select Buho, tap "Stop using Apple ID", and try logging in again while choosing to share your email.'
                );
            } else {
                throw new Auth.AuthProviderPluginException(
                    'Email address is required but was not provided by the authentication provider.'
                );
            }
        }

        List<User> users = [
            SELECT Id, IsActive
            FROM User
            WHERE Username = :data.email
            AND IsActive = true
            AND ContactId != null
            AND Profile.Name = 'Buho Customer Community Plus Login User'
            LIMIT 1
        ];

        if (!users.isEmpty()) {
            return users[0];
        }

        throw new Auth.AuthProviderPluginException(
            'No Buho user exists with email: ' + data.email
        );
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        // No updates required
    }
}