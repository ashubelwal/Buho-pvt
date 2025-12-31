/**
 * Shared Utility Functions for BÚHO Insurance
 * Designed to be reusable as static resources in Salesforce LWC
 */

// =============================================================================
// Validation Utilities
// =============================================================================

const BuhoValidation = {
    /**
     * Validates email format
     * @param {string} email 
     * @returns {boolean}
     */
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },

    /**
     * Validates password strength
     * @param {string} password 
     * @returns {Object}
     */
    validatePasswordStrength(password) {
        let score = 0;
        const checks = {
            length: password.length >= 8,
            lowercase: /[a-z]/.test(password),
            uppercase: /[A-Z]/.test(password),
            numbers: /\d/.test(password),
            special: /[!@#$%^&*(),.?":{}|<>]/.test(password)
        };

        if (checks.length) score++;
        if (checks.lowercase) score++;
        if (checks.uppercase) score++;
        if (checks.numbers) score++;
        if (checks.special) score++;

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
    },

    /**
     * Validates if two passwords match
     * @param {string} password 
     * @param {string} confirmPassword 
     * @returns {boolean}
     */
    doPasswordsMatch(password, confirmPassword) {
        return password === confirmPassword && password.length > 0;
    },

    /**
     * Validates phone number format (Mexican format)
     * @param {string} phone 
     * @returns {boolean}
     */
    isValidPhoneNumber(phone) {
        const phoneRegex = /^(\+52)?[\s.-]?\d{2,3}[\s.-]?\d{3,4}[\s.-]?\d{4}$/;
        return phoneRegex.test(phone.replace(/\s/g, ''));
    }
};

// =============================================================================
// UI Utilities
// =============================================================================

const BuhoUI = {
    /**
     * Shows a loading state on a button
     * @param {HTMLElement} button 
     * @param {string} loadingText 
     */
    setButtonLoading(button, loadingText = 'Loading...') {
        if (!button) return;
        button.dataset.originalText = button.textContent;
        button.classList.add('loading');
        button.disabled = true;
        button.textContent = loadingText;
    },

    /**
     * Removes loading state from a button
     * @param {HTMLElement} button 
     */
    removeButtonLoading(button) {
        if (!button) return;
        button.classList.remove('loading');
        button.disabled = false;
        button.textContent = button.dataset.originalText || 'Submit';
    },

    /**
     * Shows an error message
     * @param {HTMLElement} container 
     * @param {string} message 
     * @param {number} duration - Duration in ms (0 for permanent)
     */
    showError(container, message, duration = 5000) {
        let errorEl = container.querySelector('.error-message');
        
        if (!errorEl) {
            errorEl = document.createElement('div');
            errorEl.className = 'error-message';
            container.appendChild(errorEl);
        }

        errorEl.textContent = message;
        errorEl.classList.add('visible');

        if (duration > 0) {
            setTimeout(() => {
                errorEl.classList.remove('visible');
            }, duration);
        }
    },

    /**
     * Shows a success message
     * @param {HTMLElement} container 
     * @param {string} message 
     * @param {number} duration - Duration in ms (0 for permanent)
     */
    showSuccess(container, message, duration = 5000) {
        let successEl = container.querySelector('.success-message');
        
        if (!successEl) {
            successEl = document.createElement('div');
            successEl.className = 'success-message';
            successEl.innerHTML = '<p></p>';
            container.insertBefore(successEl, container.firstChild);
        }

        successEl.querySelector('p').textContent = message;
        successEl.classList.add('visible');

        if (duration > 0) {
            setTimeout(() => {
                successEl.classList.remove('visible');
            }, duration);
        }
    },

    /**
     * Toggles password visibility
     * @param {HTMLInputElement} input 
     * @returns {boolean} - New visibility state (true = visible)
     */
    togglePasswordVisibility(input) {
        if (!input) return false;
        const isPassword = input.type === 'password';
        input.type = isPassword ? 'text' : 'password';
        return !isPassword;
    },

    /**
     * Adds input validation styling
     * @param {HTMLInputElement} input 
     * @param {boolean} isValid 
     */
    setInputValidationState(input, isValid) {
        if (!input) return;
        input.classList.remove('error', 'success');
        input.classList.add(isValid ? 'success' : 'error');
    },

    /**
     * Clears input validation styling
     * @param {HTMLInputElement} input 
     */
    clearInputValidationState(input) {
        if (!input) return;
        input.classList.remove('error', 'success');
    }
};

// =============================================================================
// Form Utilities
// =============================================================================

const BuhoForm = {
    /**
     * Serializes form data to object
     * @param {HTMLFormElement} form 
     * @returns {Object}
     */
    serialize(form) {
        const formData = new FormData(form);
        const data = {};
        formData.forEach((value, key) => {
            data[key] = value;
        });
        return data;
    },

    /**
     * Clears all inputs in a form
     * @param {HTMLFormElement} form 
     */
    clear(form) {
        if (!form) return;
        form.reset();
        form.querySelectorAll('input').forEach(input => {
            BuhoUI.clearInputValidationState(input);
        });
    },

    /**
     * Disables all inputs in a form
     * @param {HTMLFormElement} form 
     * @param {boolean} disabled 
     */
    setDisabled(form, disabled) {
        if (!form) return;
        form.querySelectorAll('input, button, select, textarea').forEach(el => {
            el.disabled = disabled;
        });
    }
};

// =============================================================================
// Storage Utilities
// =============================================================================

const BuhoStorage = {
    /**
     * Safely sets item in localStorage
     * @param {string} key 
     * @param {*} value 
     */
    set(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
        } catch (e) {
            console.warn('Failed to save to localStorage:', e);
        }
    },

    /**
     * Safely gets item from localStorage
     * @param {string} key 
     * @param {*} defaultValue 
     * @returns {*}
     */
    get(key, defaultValue = null) {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : defaultValue;
        } catch (e) {
            console.warn('Failed to read from localStorage:', e);
            return defaultValue;
        }
    },

    /**
     * Removes item from localStorage
     * @param {string} key 
     */
    remove(key) {
        try {
            localStorage.removeItem(key);
        } catch (e) {
            console.warn('Failed to remove from localStorage:', e);
        }
    }
};

// =============================================================================
// Navigation Utilities
// =============================================================================

const BuhoNav = {
    /**
     * Gets URL parameters
     * @returns {Object}
     */
    getUrlParams() {
        const params = {};
        const searchParams = new URLSearchParams(window.location.search);
        searchParams.forEach((value, key) => {
            params[key] = value;
        });
        return params;
    },

    /**
     * Gets a specific URL parameter
     * @param {string} name 
     * @returns {string|null}
     */
    getUrlParam(name) {
        return new URLSearchParams(window.location.search).get(name);
    },

    /**
     * Redirects to a URL after a delay
     * @param {string} url 
     * @param {number} delay - Delay in ms
     */
    redirectAfter(url, delay = 0) {
        setTimeout(() => {
            window.location.href = url;
        }, delay);
    }
};

// =============================================================================
// Export utilities (for use in other scripts)
// =============================================================================

// Make utilities available globally
window.BuhoValidation = BuhoValidation;
window.BuhoUI = BuhoUI;
window.BuhoForm = BuhoForm;
window.BuhoStorage = BuhoStorage;
window.BuhoNav = BuhoNav;

// For ES6 module usage (LWC compatible)
// export { BuhoValidation, BuhoUI, BuhoForm, BuhoStorage, BuhoNav };

