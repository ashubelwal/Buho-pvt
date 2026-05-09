/**
 * @description Controller for BÚHO Login Component
 * Handles authentication for Experience Site
 * @author BÚHO Insurance
 * @date 2025
 */
public without sharing class BuhoLoginController {

    /**
     * @description Authenticates user and returns redirect URL
     * @param username The user's email/username
     * @param password The user's password
     * @param startUrl The URL to redirect to after successful login
     * @return String The redirect URL on success, error message on failure
     */
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try {
            // Validate inputs
            if (String.isBlank(username)) {
                return 'Please enter your email address.';
            }
            
            if (String.isBlank(password)) {
                return 'Please enter your password.';
            }

            // Activate user
            List<User> userRecords = new List<User>([
                    SELECT Id, IsActive 
                    FROM User 
                    WHERE UserName =: username LIMIT 1]);
                    
            if(!userRecords.isEmpty() && !userRecords[0].IsActive) {
                userRecords[0].IsActive = true;
                update userRecords;
            }
            
            // Attempt login
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
            
            if (pageRef != null) {
                return pageRef.getUrl();
            } else {
                return 'Invalid username or password. Please try again.';
            }
        } catch (Exception e) {
            System.debug('Login error: ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    /**
     * @description Initiates password reset process
     * @param email The user's email address
     * @return String Success or error message
     */
    @AuraEnabled
    public static String forgotPassword(String email) {
        try {
            if (String.isBlank(email)) {
                return 'Please enter your email address.';
            }
            
            // Validate email format
            if (!isValidEmail(email)) {
                return 'Please enter a valid email address.';
            }
            
            // Check if user exists
            List<User> users = [
                SELECT Id, Email, Username 
                FROM User 
                WHERE Email = :email 
                AND IsActive = true 
                LIMIT 1
            ];
            
            if (users.isEmpty()) {
                // Don't reveal if email exists for security
                return 'If an account exists with this email, you will receive password reset instructions.';
            }
            
            // Send password reset email
            Site.forgotPassword(users[0].Username);
            
            return 'If an account exists with this email, you will receive password reset instructions.';
        } catch (Exception e) {
            System.debug('Forgot password error: ' + e.getMessage());
            return 'An error occurred. Please try again.';
        }
    }
    
    /**
     * @description Validates if the provided string is a valid email
     * @param email The email string to validate
     * @return Boolean True if valid email format
     */
    private static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(email);
        return emailMatcher.matches();
    }
    
    /**
     * @description Gets the current site's base URL
     * @return String The site base URL
     */
    @AuraEnabled(cacheable=true)
    public static String getSiteBaseUrl() {
        return Site.getBaseUrl();
    }
    
    /**
     * @description Checks if user is already authenticated
     * @return Boolean True if user is logged in
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isUserAuthenticated() {
        return UserInfo.getUserType() != 'Guest';
    }
    
    /**
     * @description Gets the community/site name
     * @return String The site name
     */
    @AuraEnabled(cacheable=true)
    public static String getSiteName() {
        return Site.getName();
    }
    
    /**
     * @description Change password using verification code
     * @param username - User's username/email
     * @param password - New password
     * @param verifyPassword - Confirm new password
     * @return Map with success status and message
     */
    @AuraEnabled
    public static Map<String, Object> changePassword(String username, String password, String verifyPassword) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            // Validate inputs
            if (String.isBlank(username) || String.isBlank(password) || String.isBlank(verifyPassword)) {
                response.put('success', false);
                response.put('message', 'All fields are required.');
                return response;
            }
            
            // Validate password match
            if (password != verifyPassword) {
                response.put('success', false);
                response.put('message', 'Passwords do not match.');
                return response;
            }
            
            // Use Site.changePassword method
            PageReference pageRef = Site.changePassword(password, verifyPassword, null);
            
            if (pageRef != null) {
                response.put('success', true);
                response.put('message', 'Password changed successfully.');
                response.put('redirectUrl', pageRef.getUrl());
            } else {
                response.put('success', false);
                response.put('message', 'Unable to change password. Please verify your information.');
            }
            
        } catch (Exception e) {
            response.put('success', false);
            response.put('message', 'An error occurred: ' + e.getMessage());
            System.debug('Change Password Error: ' + e.getMessage());
        }
        
        return response;
    }

    /**
     * Returns details of the currently running Salesforce Site / Experience Cloud context.
     *
     * This method is intended to be used in Site, Community, or Guest User execution.
     * When executed outside of a Site context (e.g., internal Salesforce UI),
     * most values in the returned map will be null.
     *
     * Returned Map Keys:
     *  - siteName   : Developer name of the Site (Site.getName())
     *  - siteId     : Id of the Site (Site.getSiteId())
     *  - siteType   : Type of Site (SITE or COMMUNITY)
     *  - pathPrefix : URL path prefix for the Site (Site.getPathPrefix())
     *  - baseUrl    : Base URL of the Site (Site.getBaseUrl())
     *
     * @return Map<String, String> containing site-related details for the current context
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCurrentSiteDetails() {
        Map<String, String> siteDetails = new Map<String, String>();

        siteDetails.put('siteName', Site.getName());
        siteDetails.put('siteId', (Site.getSiteId() != null) ? String.valueOf(Site.getSiteId()) : null);
        siteDetails.put('siteType', (Site.getSiteType() != null) ? String.valueOf(Site.getSiteType()) : null);
        siteDetails.put('pathPrefix', Site.getPathPrefix());
        siteDetails.put('baseUrl', Site.getBaseSecureUrl() );
        return siteDetails;
    }

    @AuraEnabled
    public static void updateLeadStep(Id leadId, Integer step) {
        if(leadId != null) {
            update new Lead(Id = leadId, Current_Step__c = step);
        }
    }

    @AuraEnabled
    public static void updateAgency(){
        Id buhoAgencyId = Label.Buho_AgencyId;
        User currentUser = [SELECT  Id, ContactId, Contact.Agency__c  FROM User WHERE Id =: UserInfo.getUserId()];
        if(currentUser.Contact.Agency__c != buhoAgencyId ) {
            update new Contact(Id = currentUser.ContactId, Agency__c = buhoAgencyId);
        }
    }

    @AuraEnabled
    public static void activateUser(Id userId) {
        update new User(Id = userId, IsActive = true);
    }

}