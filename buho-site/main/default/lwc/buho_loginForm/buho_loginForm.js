import { LightningElement, api, track } from 'lwc';

export default class Buho_loginForm extends LightningElement {
    // Public API properties - configurable by parent
    @api username = '';
    @api password = '';
    @api errorMessage = '';
    @api isLoading = false;
    @api showForgotPassword;
    @api usernameLabel = 'Email';
    @api passwordLabel = 'Password';
    @api usernamePlaceholder = 'Enter your email';
    @api passwordPlaceholder = 'Enter your password';
    @api submitButtonLabel = 'Sign in';
    @api loadingButtonLabel = 'Signing in...';
    @api forgotPasswordText = 'Forget Password ?';

    // Handle username input
    handleUsernameChange(event) {
        const value = event.target.value;
        this.dispatchEvent(new CustomEvent('usernamechange', {
            detail: { value },
            bubbles: true,
            composed: true
        }));
    }

    // Handle password input
    handlePasswordChange(event) {
        const value = event.target.value;
        this.dispatchEvent(new CustomEvent('passwordchange', {
            detail: { value },
            bubbles: true,
            composed: true
        }));
    }

    // Handle submit button click
    handleSubmit() {
        this.dispatchEvent(new CustomEvent('submit', {
            bubbles: true,
            composed: true
        }));
    }

    // Handle Enter key press
    handleKeyUp(event) {
        if (event.key === 'Enter' && !this.isLoading) {
            this.handleSubmit();
        }
    }

    // Handle forgot password click
    handleForgotPassword() {
        this.dispatchEvent(new CustomEvent('forgotpassword', {
            bubbles: true,
            composed: true
        }));
    }
}

