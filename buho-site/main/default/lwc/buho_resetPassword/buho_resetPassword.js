import { LightningElement, track, api } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import changePassword from '@salesforce/apex/BuhoLoginController.changePassword';

export default class Buho_resetPassword extends LightningElement {
    @api username; // Username from URL parameter (optional)
    
    @track newPassword = '';
    @track confirmPassword = '';
    @track showNewPassword = false;
    @track showConfirmPassword = false;
    @track errorMessage = '';
    @track showSuccess = false;
    @track isLoading = false;
    @track passwordStrength = 0;

    // Logo URL
    get logoUrl() {
        return `${buhoAssets}/images/Logo.svg`;
    }

    // Password input types
    get newPasswordType() {
        return this.showNewPassword ? 'text' : 'password';
    }

    get confirmPasswordType() {
        return this.showConfirmPassword ? 'text' : 'password';
    }

    // Password visibility toggle icons
    get newPasswordIconClass() {
        return this.showNewPassword ? 'bi bi-eye-slash' : 'bi bi-eye';
    }

    get confirmPasswordIconClass() {
        return this.showConfirmPassword ? 'bi bi-eye-slash' : 'bi bi-eye';
    }

    // Password strength classes
    get strengthBarClass() {
        const baseClass = 'strength-bar-fill';
        const strengthClasses = ['weak', 'fair', 'good', 'strong'];
        return `${baseClass} ${strengthClasses[this.passwordStrength - 1] || ''}`;
    }

    get strengthText() {
        const texts = ['', 'Weak password', 'Fair password', 'Good password', 'Strong password'];
        return texts[this.passwordStrength] || '';
    }

    // Input field classes
    get newPasswordClass() {
        if (!this.newPassword) return '';
        return this.passwordStrength >= 3 ? 'success' : '';
    }

    get confirmPasswordClass() {
        if (!this.confirmPassword) return '';
        return this.passwordsMatch ? 'success' : 'error';
    }

    // Password match indicator
    get passwordsMatch() {
        return this.newPassword && this.confirmPassword && this.newPassword === this.confirmPassword;
    }

    get showMatchIndicator() {
        return this.confirmPassword.length > 0;
    }

    get matchIndicatorClass() {
        return `password-match-indicator ${this.passwordsMatch ? 'match' : 'no-match'}`;
    }

    get matchIndicatorIcon() {
        return this.passwordsMatch ? 'bi bi-check-circle' : 'bi bi-x-circle';
    }

    get matchIndicatorText() {
        return this.passwordsMatch ? 'Passwords match' : 'Passwords do not match';
    }

    // Lifecycle hook
    connectedCallback() {
        // Get username from URL if provided
        const urlParams = new URLSearchParams(window.location.search);
        this.username = urlParams.get('username') || urlParams.get('email');
    }

    // Handle password input
    handlePasswordChange(event) {
        this.newPassword = event.target.value;
        this.calculatePasswordStrength();
        this.errorMessage = '';
    }

    // Handle confirm password input
    handleConfirmPasswordChange(event) {
        this.confirmPassword = event.target.value;
        this.errorMessage = '';
    }

    // Toggle password visibility
    toggleNewPassword() {
        this.showNewPassword = !this.showNewPassword;
    }

    toggleConfirmPassword() {
        this.showConfirmPassword = !this.showConfirmPassword;
    }

    // Calculate password strength
    calculatePasswordStrength() {
        const password = this.newPassword;
        let strength = 0;

        if (password.length >= 8) strength++;
        if (password.length >= 12) strength++;
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
        if (/[0-9]/.test(password)) strength++;
        if (/[^a-zA-Z0-9]/.test(password)) strength++;

        // Normalize to 1-4 scale
        this.passwordStrength = Math.min(Math.floor(strength / 1.25), 4);
    }

    // Validate passwords
    validatePasswords() {
        if (!this.newPassword) {
            this.errorMessage = 'Please enter a new password.';
            return false;
        }

        if (this.newPassword.length < 8) {
            this.errorMessage = 'Password must be at least 8 characters long.';
            return false;
        }

        if (this.passwordStrength < 2) {
            this.errorMessage = 'Please choose a stronger password. Include uppercase, lowercase, numbers, and special characters.';
            return false;
        }

        if (!this.confirmPassword) {
            this.errorMessage = 'Please confirm your password.';
            return false;
        }

        if (this.newPassword !== this.confirmPassword) {
            this.errorMessage = 'Passwords do not match.';
            return false;
        }

        return true;
    }

    // Handle form submission
    async handleSubmit(event) {
        event.preventDefault();
        
        if (!this.validatePasswords()) {
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            // Use Site.changePassword method via Apex
            const result = await changePassword({
                username: this.username,
                password: this.newPassword,
                verifyPassword: this.confirmPassword
            });

            if (result.success) {
                this.showSuccess = true;
                
                // Redirect to login after 2 seconds
                setTimeout(() => {
                    const redirectUrl = result.redirectUrl || '/login?reset=success';
                    window.location.href = redirectUrl;
                }, 2000);
            } else {
                this.errorMessage = result.message || 'Failed to reset password. Please try again or request a new reset link.';
            }
        } catch (error) {
            console.error('Reset password error:', error);
            this.errorMessage = error.body?.message || 'An error occurred. Please try again or contact support.';
        } finally {
            this.isLoading = false;
        }
    }
}

