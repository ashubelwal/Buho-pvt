@isTest
private class AgentLoginControllerTest {

    // ─── login() tests ────────────────────────────────────────────────────────

    @isTest
    static void testBlankUsername() {
        Test.startTest();
        String result = AgentLoginController.login('', 'password123', '/agency/');
        Test.stopTest();
        System.assertEquals('Please enter your email address.', result, 'Should return validation error for blank username.');
    }

    @isTest
    static void testBlankPassword() {
        Test.startTest();
        String result = AgentLoginController.login('test@example.com', '', '/agency/');
        Test.stopTest();
        System.assertEquals('Please enter your password.', result, 'Should return validation error for blank password.');
    }

    @isTest
    static void testInvalidLogin() {
        Test.startTest();
        // Site.login returns null in test context → controller returns the error string
        String result = AgentLoginController.login('test@example.com', 'wrongpassword', '/agency/');
        Test.stopTest();
        System.assertEquals('Invalid username or password. Please try again.', result);
    }

    // ─── forgotPassword() tests ───────────────────────────────────────────────

    @isTest
    static void testForgotPassword_blankEmail() {
        Test.startTest();
        String result = AgentLoginController.forgotPassword('');
        Test.stopTest();
        System.assertEquals('Please enter your email address.', result);
    }

    @isTest
    static void testForgotPassword_invalidEmail() {
        Test.startTest();
        String result = AgentLoginController.forgotPassword('not-an-email');
        Test.stopTest();
        System.assertEquals('Please enter a valid email address.', result);
    }

    @isTest
    static void testForgotPassword_validEmail_noUser() {
        // No active user with this email exists → controller skips Site.forgotPassword
        // but still returns the neutral security message
        Test.startTest();
        String result = AgentLoginController.forgotPassword('nobody@example.com');
        Test.stopTest();
        System.assertEquals(
            'If an account exists with this email, you will receive password reset instructions.',
            result
        );
    }
}
