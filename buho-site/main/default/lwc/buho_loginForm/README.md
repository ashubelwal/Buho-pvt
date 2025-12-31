# Buho Login Form Component

A reusable LWC component for displaying login forms across the Buho Insurance application.

## Description

This component provides a standardized login interface with username/email, password fields, submit button, and optional forgot password link. It's designed to be used by multiple parent components to maintain consistency and reduce code duplication.

## Features

- ✅ Username/Email input field
- ✅ Password input field  
- ✅ Submit button with loading state
- ✅ Optional "Forgot Password" link
- ✅ Error message display
- ✅ Enter key support for form submission
- ✅ Fully customizable labels and placeholders
- ✅ Disabled state during loading
- ✅ Uses global Buho stylesheet for consistent styling

## API Properties

### Input Properties (from parent)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `username` | String | `''` | Current username/email value |
| `password` | String | `''` | Current password value |
| `errorMessage` | String | `''` | Error message to display |
| `isLoading` | Boolean | `false` | Loading state for submit button |
| `showForgotPassword` | Boolean | `true` | Show/hide forgot password link |
| `usernameLabel` | String | `'Email'` | Label for username field |
| `passwordLabel` | String | `'Password'` | Label for password field |
| `usernamePlaceholder` | String | `'Enter your email'` | Placeholder for username field |
| `passwordPlaceholder` | String | `'Enter your password'` | Placeholder for password field |
| `submitButtonLabel` | String | `'Sign in'` | Label for submit button |
| `loadingButtonLabel` | String | `'Signing in...'` | Label for button during loading |
| `forgotPasswordText` | String | `'Forget Password ?'` | Text for forgot password link |

### Events (to parent)

| Event | Detail | Description |
|-------|--------|-------------|
| `usernamechange` | `{ value: String }` | Fired when username changes |
| `passwordchange` | `{ value: String }` | Fired when password changes |
| `submit` | `none` | Fired when form is submitted |
| `forgotpassword` | `none` | Fired when forgot password link clicked |

## Usage Examples

### Example 1: Simple Login Form

```html
<c-buho_login-form
    username={email}
    password={password}
    error-message={errorMessage}
    is-loading={isLoading}
    onusernamechange={handleUsernameChange}
    onpasswordchange={handlePasswordChange}
    onsubmit={handleLogin}
    onforgotpassword={handleForgotPassword}>
</c-buho_login-form>
```

```javascript
handleUsernameChange(event) {
    this.email = event.detail.value;
}

handlePasswordChange(event) {
    this.password = event.detail.value;
}

handleLogin() {
    // Your login logic here
}

handleForgotPassword() {
    // Navigate to forgot password page
}
```

### Example 2: Modal Login Form (No Forgot Password)

```html
<c-buho_login-form
    username={loginUsername}
    password={loginPassword}
    error-message={loginError}
    is-loading={isLoggingIn}
    show-forgot-password={hideForgotPassword}
    submit-button-label="Login to Your Account"
    loading-button-label="Logging in..."
    onusernamechange={handleLoginUsernameChange}
    onpasswordchange={handleLoginPasswordChange}
    onsubmit={handleModalLogin}>
</c-buho_login-form>
```

### Example 3: Custom Labels

```html
<c-buho_login-form
    username={userEmail}
    password={userPass}
    username-label="Usuario"
    password-label="Contraseña"
    username-placeholder="Ingrese su correo"
    password-placeholder="Ingrese su contraseña"
    submit-button-label="Iniciar sesión"
    loading-button-label="Iniciando sesión..."
    forgot-password-text="¿Olvidó su contraseña?"
    onusernamechange={handleUsernameChange}
    onpasswordchange={handlePasswordChange}
    onsubmit={handleLogin}
    onforgotpassword={handleForgotPassword}>
</c-buho_login-form>
```

## Parent Components Using This Component

1. **buho_login** - Main login page component
2. **buho_userDetails** - Active user modal login

## Styling

All styles are consolidated in the global stylesheet:
`buhoAssets/css/buhoStyles.css`

The component uses the following CSS classes:
- `.modal-login-form` - Container
- `.modal-form-group` - Field groups
- `.modal-input` - Input fields
- `.modal-error-message` - Error display
- `.modal-actions-large` - Button container
- `.btn-dark` - Submit button
- `.forgot-link` - Forgot password link

## Notes

- The component automatically handles Enter key press to submit the form
- Loading state disables all inputs and shows loading text on button
- Error messages are displayed above the username field
- All styling is inherited from the global stylesheet for consistency

