/**
 * Reset Password Page JavaScript
 * Designed to be modular and reusable for LWC component conversion
 */

// =============================================================================
// Password Utility Functions (Reusable)
// =============================================================================

/**
 * Validates password strength
 * @param {string} password - The password to validate
 * @returns {Object} - { strength: string, score: number, message: string }
 */
function validatePasswordStrength(password) {
    let score = 0;
    const checks = {
        length: password.length >= 8,
        lowercase: /[a-z]/.test(password),
        uppercase: /[A-Z]/.test(password),
        numbers: /\d/.test(password),
        special: /[!@#$%^&*(),.?":{}|<>]/.test(password)
    };

    // Calculate score
    if (checks.length) score++;
    if (checks.lowercase) score++;
    if (checks.uppercase) score++;
    if (checks.numbers) score++;
    if (checks.special) score++;

    // Determine strength level
    let strength, message;
    if (score <= 1) {
        strength = 'weak';
        message = 'Weak - Add more characters';
    } else if (score === 2) {
        strength = 'fair';
        message = 'Fair - Add uppercase or special characters';
    } else if (score === 3 || score === 4) {
        strength = 'good';
        message = 'Good - Strong password';
    } else {
        strength = 'strong';
        message = 'Strong - Excellent password';
    }

    return { strength, score, message, checks };
}

/**
 * Validates if passwords match
 * @param {string} password - Original password
 * @param {string} confirmPassword - Confirmation password
 * @returns {boolean}
 */
function doPasswordsMatch(password, confirmPassword) {
    return password === confirmPassword && password.length > 0;
}

// =============================================================================
// DOM Element References
// =============================================================================

const resetPasswordForm = document.getElementById('resetPasswordForm');
const newPasswordInput = document.getElementById('newPassword');
const confirmPasswordInput = document.getElementById('confirmPassword');
const togglePasswordButtons = document.querySelectorAll('.toggle-password');
const submitButton = resetPasswordForm?.querySelector('.btn-primary');

// =============================================================================
// Password Visibility Toggle
// =============================================================================

/**
 * Toggles password visibility for input fields
 */
function initPasswordToggle() {
    togglePasswordButtons.forEach(button => {
        button.addEventListener('click', () => {
            const targetId = button.getAttribute('data-target');
            const input = document.getElementById(targetId);
            
            if (input) {
                const isPassword = input.type === 'password';
                input.type = isPassword ? 'text' : 'password';
                
                // Update icon appearance (Bootstrap Icons)
                const icon = button.querySelector('i');
                if (icon) {
                    icon.classList.toggle('bi-eye', isPassword);
                    icon.classList.toggle('bi-eye-slash', !isPassword);
                }
                
                button.classList.toggle('active', !isPassword);
                
                // Update aria-label for accessibility
                button.setAttribute('aria-label', 
                    isPassword ? 'Hide password' : 'Show password'
                );
            }
        });
    });
}

// =============================================================================
// Password Strength Indicator
// =============================================================================

/**
 * Creates and manages password strength indicator
 */
function initPasswordStrengthIndicator() {
    if (!newPasswordInput) return;

    // Create strength indicator elements
    const strengthContainer = document.createElement('div');
    strengthContainer.className = 'password-strength';
    strengthContainer.innerHTML = `
        <div class="strength-bar">
            <div class="strength-bar-fill"></div>
        </div>
        <span class="strength-text"></span>
    `;

    // Insert after the password input wrapper
    const inputWrapper = newPasswordInput.closest('.password-input-wrapper');
    inputWrapper.parentNode.insertBefore(strengthContainer, inputWrapper.nextSibling);

    const strengthBarFill = strengthContainer.querySelector('.strength-bar-fill');
    const strengthText = strengthContainer.querySelector('.strength-text');

    // Update on input
    newPasswordInput.addEventListener('input', () => {
        const password = newPasswordInput.value;
        
        if (password.length === 0) {
            strengthBarFill.className = 'strength-bar-fill';
            strengthText.textContent = '';
            return;
        }

        const result = validatePasswordStrength(password);
        strengthBarFill.className = `strength-bar-fill ${result.strength}`;
        strengthText.textContent = result.message;
    });
}

// =============================================================================
// Password Match Validation
// =============================================================================

/**
 * Creates and manages password match indicator
 */
function initPasswordMatchIndicator() {
    if (!confirmPasswordInput) return;

    // Create match indicator element
    const matchIndicator = document.createElement('div');
    matchIndicator.className = 'password-match-indicator';
    matchIndicator.style.display = 'none';

    // Insert after the confirm password input wrapper
    const inputWrapper = confirmPasswordInput.closest('.password-input-wrapper');
    inputWrapper.parentNode.insertBefore(matchIndicator, inputWrapper.nextSibling);

    // Update on input
    const updateMatchIndicator = () => {
        const password = newPasswordInput.value;
        const confirmPassword = confirmPasswordInput.value;

        if (confirmPassword.length === 0) {
            matchIndicator.style.display = 'none';
            confirmPasswordInput.classList.remove('error', 'success');
            return;
        }

        matchIndicator.style.display = 'flex';

        if (doPasswordsMatch(password, confirmPassword)) {
            matchIndicator.className = 'password-match-indicator match';
            matchIndicator.innerHTML = '✓ Passwords match';
            confirmPasswordInput.classList.remove('error');
            confirmPasswordInput.classList.add('success');
        } else {
            matchIndicator.className = 'password-match-indicator no-match';
            matchIndicator.innerHTML = '✗ Passwords do not match';
            confirmPasswordInput.classList.remove('success');
            confirmPasswordInput.classList.add('error');
        }
    };

    newPasswordInput.addEventListener('input', updateMatchIndicator);
    confirmPasswordInput.addEventListener('input', updateMatchIndicator);
}

// =============================================================================
// Form Submission
// =============================================================================

/**
 * Handles form submission
 */
function initFormSubmission() {
    if (!resetPasswordForm) return;

    resetPasswordForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const newPassword = newPasswordInput.value;
        const confirmPassword = confirmPasswordInput.value;

        // Validate passwords match
        if (!doPasswordsMatch(newPassword, confirmPassword)) {
            showError('Passwords do not match');
            confirmPasswordInput.focus();
            return;
        }

        // Validate password strength
        const strengthResult = validatePasswordStrength(newPassword);
        if (strengthResult.score < 2) {
            showError('Please choose a stronger password');
            newPasswordInput.focus();
            return;
        }

        // Show loading state
        setLoadingState(true);

        try {
            // Simulate API call - Replace with actual API call
            await simulatePasswordReset(newPassword);
            
            // Show success message
            showSuccess('Password reset successfully! Redirecting to login...');
            
            // Redirect after delay
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);

        } catch (error) {
            showError(error.message || 'Failed to reset password. Please try again.');
        } finally {
            setLoadingState(false);
        }
    });
}

/**
 * Simulates password reset API call
 * Replace this with actual Salesforce API integration
 */
function simulatePasswordReset(password) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            // Simulate successful response
            console.log('Password reset requested');
            resolve({ success: true });
            
            // To test error handling, uncomment below:
            // reject(new Error('Token expired'));
        }, 1500);
    });
}

/**
 * Sets the loading state of the submit button
 */
function setLoadingState(isLoading) {
    if (!submitButton) return;

    if (isLoading) {
        submitButton.classList.add('loading');
        submitButton.disabled = true;
        submitButton.textContent = 'Resetting Password...';
    } else {
        submitButton.classList.remove('loading');
        submitButton.disabled = false;
        submitButton.textContent = 'Reset Your Password';
    }
}

/**
 * Shows error message
 */
function showError(message) {
    // Check if error container exists, if not create one
    let errorContainer = document.querySelector('.error-message');
    
    if (!errorContainer) {
        errorContainer = document.createElement('div');
        errorContainer.className = 'error-message';
        submitButton.parentNode.insertBefore(errorContainer, submitButton);
    }

    errorContainer.textContent = message;
    errorContainer.classList.add('visible');

    // Hide after 5 seconds
    setTimeout(() => {
        errorContainer.classList.remove('visible');
    }, 5000);
}

/**
 * Shows success message
 */
function showSuccess(message) {
    // Check if success container exists, if not create one
    let successContainer = document.querySelector('.success-message');
    
    if (!successContainer) {
        successContainer = document.createElement('div');
        successContainer.className = 'success-message';
        successContainer.innerHTML = '<p></p>';
        resetPasswordForm.insertBefore(successContainer, resetPasswordForm.firstChild);
    }

    successContainer.querySelector('p').textContent = message;
    successContainer.classList.add('visible');
}

// =============================================================================
// Initialization
// =============================================================================

/**
 * Initialize all functionality when DOM is ready
 */
function init() {
    initPasswordToggle();
    initPasswordStrengthIndicator();
    initPasswordMatchIndicator();
    initFormSubmission();

    console.log('Reset Password module initialized');
}

// Run initialization when DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}

// =============================================================================
// Export for LWC (if needed)
// These functions can be imported into LWC components
// =============================================================================

// For use in LWC, these can be exported as:
// export { validatePasswordStrength, doPasswordsMatch };

