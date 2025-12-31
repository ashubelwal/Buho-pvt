# BÚHO Forgot Password Component

## Overview
The Forgot Password component allows users to request password reset instructions via email. This component uses Salesforce's built-in `Site.forgotPassword()` method for secure password reset functionality.

## Architecture

### Flow
1. User clicks "Forget Password?" on the login page
2. User is redirected to the Forgot Password page
3. User enters their email address
4. System calls `Site.forgotPassword()` method via Apex
5. Salesforce sends password reset email with a secure token
6. User clicks the link in the email
7. User is redirected to the Reset Password page
8. User enters new password and confirms
9. System calls `Site.changePassword()` method via Apex
10. Password is updated and user is redirected to login

## Components Created

### LWC Components (Salesforce)

#### 1. `buho_forgotPassword`
**Location:** `/buho-site/main/default/lwc/buho_forgotPassword/`

**Files:**
- `buho_forgotPassword.html` - Template with email input form
- `buho_forgotPassword.js` - Controller with email validation and Apex calls
- `buho_forgotPassword.js-meta.xml` - Metadata configuration
- `buho_forgotPassword.css` - Component-specific styles

**Key Features:**
- Email validation
- Calls `BuhoLoginController.forgotPassword()` Apex method
- Success state with confirmation message
- "Try Another Email" functionality
- Back to Login navigation
- Loading states and error handling

#### 2. `buho_resetPassword` (Updated)
**Location:** `/buho-site/main/default/lwc/buho_resetPassword/`

**Key Changes:**
- Fixed LWC template syntax (removed inline ternary operators)
- Added getter methods for password input types
- Uses `Site.changePassword()` method via Apex
- Password strength indicator
- Password match validation

### HTML Pages (Standalone Buho folder)

#### 1. `forgot-password.html`
**Location:** `/Buho/forgot-password.html`

Features same UI as LWC component for testing/preview.

#### 2. `forgot-password.js`
**Location:** `/Buho/js/forgot-password.js`

JavaScript logic for standalone HTML version.

### Apex Controller

#### `BuhoLoginController.cls`
**Location:** `/buho-site/main/default/classes/BuhoLoginController.cls`

**Methods:**

```apex
@AuraEnabled
public static String forgotPassword(String email)
```
- Looks up user by email
- Calls `Site.forgotPassword(username)` to send reset email
- Returns success message (doesn't reveal if email exists for security)

```apex
@AuraEnabled
public static String changePassword(String username, String newPassword, String verifyNewPassword)
```
- Validates input parameters
- Calls `Site.changePassword(username, newPassword, verifyNewPassword)`
- Returns success or error message

## Salesforce Site Methods Used

### `Site.forgotPassword(username)`
- Sends password reset email to the user
- Email contains a secure token link
- Token expires after configured time (default 24 hours)
- No custom fields or tokens needed

### `Site.changePassword(username, newPassword, verifyNewPassword)`
- Changes user password securely
- Validates new password meets org requirements
- Verifies password confirmation matches
- No custom verification logic needed

## CSS Styles

### Global Styles Added
**Location:** 
- `/buho-site/main/default/staticresources/buhoAssets/css/buhoStyles.css`
- `/Buho/css/styles.css`

**New Classes:**
- `.input-with-icon` - Input wrapper with icon positioning
- `.input-icon` - Icon positioning inside input
- `.success-state` - Success confirmation UI
- `.success-icon` - Large checkmark icon
- `.btn-secondary` - Secondary button style
- `.help-text` - Help text styling
- `.spinner-border` - Loading spinner animation

## Navigation Flow

### Login Page Links
```html
<a href="forgot-password.html">Forget Password ?</a>
<!-- LWC: navigates to 'Forgot_Password' named page -->
```

### Forgot Password Page Links
```html
<a href="index.html">Back to Login</a>
<!-- LWC: navigates to 'Login' named page -->
```

### Email Reset Link (Sent by Salesforce)
```
https://your-site.force.com/reset-password?token=SECURE_TOKEN
<!-- Automatically handled by Salesforce -->
```

## Security Features

1. **No Email Disclosure**: Doesn't reveal whether an email exists in the system
2. **Secure Tokens**: Uses Salesforce-generated secure tokens
3. **Token Expiration**: Tokens expire after configured time
4. **Password Validation**: Enforces org password policies
5. **Server-Side Validation**: All validation done server-side via Apex

## Testing

### Standalone HTML
1. Open `file:///path/to/Buho/forgot-password.html` in browser
2. Test UI and form validation
3. Note: API calls are simulated in standalone version

### Salesforce Experience Site
1. Deploy components to Salesforce org
2. Add `buho_forgotPassword` component to a page in Experience Builder
3. Set page name to "Forgot_Password" for navigation to work
4. Configure Site email settings for password reset emails
5. Test full flow with actual user accounts

## Configuration Required

### Salesforce Site Setup
1. **Enable Password Reset Emails**
   - Setup → Administration → Email Administration
   - Configure "Password Reset Email Template"

2. **Configure Site Settings**
   - Setup → Digital Experiences → Settings
   - Enable "Allow Password Reset"
   - Set token expiration time

3. **Create Named Pages**
   - Create "Forgot_Password" page with `buho_forgotPassword` component
   - Create "Reset_Password" page with `buho_resetPassword` component
   - Create "Login" page with `buho_login` component

4. **Email Deliverability**
   - Ensure Site domain is whitelisted
   - Configure SPF/DKIM records
   - Test email delivery

## Files Modified

1. `/buho-site/main/default/lwc/buho_login/buho_login.js`
   - Already had `handleForgotPassword()` navigation method

2. `/buho-site/main/default/lwc/buho_resetPassword/buho_resetPassword.js`
   - Added getter methods for password input types
   - Fixed LWC template syntax

3. `/buho-site/main/default/lwc/buho_resetPassword/buho_resetPassword.html`
   - Replaced inline ternary operators with getter properties

4. `/buho-site/main/default/classes/BuhoLoginController.cls`
   - Uses `Site.forgotPassword()` and `Site.changePassword()`

5. `/Buho/index.html`
   - Updated forgot password link to point to `forgot-password.html`

6. `/buho-site/main/default/staticresources/buhoAssets/css/buhoStyles.css`
   - Added forgot password specific styles

7. `/Buho/css/styles.css`
   - Added forgot password specific styles

## Deployment Steps

```bash
# Deploy to Salesforce
sfdx force:source:deploy -p buho-site/main/default/lwc/buho_forgotPassword -u your-org-alias
sfdx force:source:deploy -p buho-site/main/default/lwc/buho_resetPassword -u your-org-alias
sfdx force:source:deploy -p buho-site/main/default/classes/BuhoLoginController.cls -u your-org-alias

# Or deploy entire buho-site folder
sfdx force:source:deploy -p buho-site -u your-org-alias
```

## Future Enhancements

1. **Email Customization**: Customize password reset email template
2. **Multi-Language Support**: Add translations for different languages
3. **Enhanced Security**: Add CAPTCHA for bot prevention
4. **Analytics**: Track password reset requests and success rates
5. **User Notifications**: Send confirmation after password change

