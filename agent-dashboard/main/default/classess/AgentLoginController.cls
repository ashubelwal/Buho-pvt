public without sharing class AgentLoginController {
  /**
   * @description Authenticates user and returns redirect URL for Agent Portal
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

      // Attempt login. Defaulting to '/' if no startUrl provided
      String redirectUrl = '/agency/';
      ApexPages.PageReference pageRef = Site.login(username, password, redirectUrl);
      if (pageRef != null) {
        System.debug('@@@@' + pageRef.getUrl());
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
   * @description Initiates the password reset process for Agent Portal users
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

      // Check if an active user exists with this email
      List<User> users = [
        SELECT Id, Email, Username
        FROM User
        WHERE Email = :email
        AND IsActive = true
        LIMIT 1
      ];

      // For security, always return the same message regardless of whether the email exists
      if (!users.isEmpty()) {
        Site.forgotPassword(users[0].Username);
      }

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
}