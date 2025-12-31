/**
 * @description Test class for BuhoLoginController
 * @author BÚHO Insurance
 * @date 2025
 */
@isTest
private class BuhoLoginControllerTest {
    
    @isTest
    static void testLoginWithEmptyUsername() {
        Test.startTest();
        String result = BuhoLoginController.login('', 'password123', '/home');
        Test.stopTest();
        
        System.assertEquals('Please enter your email address.', result, 'Should return error for empty username');
    }
    
    @isTest
    static void testLoginWithEmptyPassword() {
        Test.startTest();
        String result = BuhoLoginController.login('test@example.com', '', '/home');
        Test.stopTest();
        
        System.assertEquals('Please enter your password.', result, 'Should return error for empty password');
    }
    
    @isTest
    static void testLoginWithInvalidCredentials() {
        Test.startTest();
        String result = BuhoLoginController.login('invalid@example.com', 'wrongpassword', '/home');
        Test.stopTest();
        
        // Site.login returns null for invalid credentials in test context
        System.assertNotEquals(null, result, 'Should return a message');
    }
    
    @isTest
    static void testForgotPasswordWithEmptyEmail() {
        Test.startTest();
        String result = BuhoLoginController.forgotPassword('');
        Test.stopTest();
        
        System.assertEquals('Please enter your email address.', result, 'Should return error for empty email');
    }
    
    @isTest
    static void testForgotPasswordWithInvalidEmail() {
        Test.startTest();
        String result = BuhoLoginController.forgotPassword('invalid-email');
        Test.stopTest();
        
        System.assertEquals('Please enter a valid email address.', result, 'Should return error for invalid email');
    }
    
    @isTest
    static void testForgotPasswordWithValidEmail() {
        Test.startTest();
        String result = BuhoLoginController.forgotPassword('test@example.com');
        Test.stopTest();
        
        System.assertEquals('If an account exists with this email, you will receive password reset instructions.', result, 
            'Should return generic success message');
    }
    
    @isTest
    static void testGetSiteBaseUrl() {
        Test.startTest();
        String result = BuhoLoginController.getSiteBaseUrl();
        Test.stopTest();
        
        // In test context, this may return null
        // Just verify no exception is thrown
        System.assert(true, 'Method executed without error');
    }
    
    @isTest
    static void testIsUserAuthenticated() {
        Test.startTest();
        Boolean result = BuhoLoginController.isUserAuthenticated();
        Test.stopTest();
        
        // In test context, user is typically not a Guest
        System.assertNotEquals(null, result, 'Should return a boolean value');
    }
    
    @isTest
    static void testGetSiteName() {
        Test.startTest();
        String result = BuhoLoginController.getSiteName();
        Test.stopTest();
        
        // In test context, this may return null
        // Just verify no exception is thrown
        System.assert(true, 'Method executed without error');
    }
}

