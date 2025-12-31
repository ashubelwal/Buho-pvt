/**
 * Forgot Password functionality
 * Handles password reset email request
 */

document.addEventListener('DOMContentLoaded', function() {
    initForgotPassword();
});

function initForgotPassword() {
    const form = document.getElementById('forgotPasswordForm');
    const emailInput = document.getElementById('email');
    const submitBtn = document.getElementById('submitBtn');
    const tryAgainBtn = document.getElementById('tryAgainBtn');
    const successState = document.getElementById('successState');

    // Handle form submission
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const email = emailInput.value.trim();
        
        // Clear previous messages
        hideMessage('error');
        hideMessage('success');
        
        // Validate email
        if (!validateEmail(email)) {
            showMessage('error', 'Please enter a valid email address.');
            return;
        }
        
        // Show loading state
        setLoadingState(submitBtn, true);
        
        // Simulate API call (replace with actual API call)
        try {
            // In production, this would call your backend API
            // For now, simulate a successful response
            await simulatePasswordResetRequest(email);
            
            // Show success state
            showSuccessState(email);
            
        } catch (error) {
            showMessage('error', error.message || 'An error occurred. Please try again.');
            setLoadingState(submitBtn, false);
        }
    });

    // Handle "Try Another Email" button
    tryAgainBtn.addEventListener('click', function() {
        resetForm();
    });

    // Email input validation on blur
    emailInput.addEventListener('blur', function() {
        const email = emailInput.value.trim();
        if (email && !validateEmail(email)) {
            showMessage('error', 'Please enter a valid email address.');
            emailInput.classList.add('error');
        } else {
            emailInput.classList.remove('error');
            hideMessage('error');
        }
    });

    // Clear error on input
    emailInput.addEventListener('input', function() {
        emailInput.classList.remove('error');
        hideMessage('error');
    });
}

// Validate email format
function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// Show error or success message
function showMessage(type, message) {
    const messageDiv = document.getElementById(`${type}Message`);
    const messageText = document.getElementById(`${type}Text`);
    
    if (messageDiv && messageText) {
        messageText.textContent = message;
        messageDiv.style.display = 'flex';
    }
}

// Hide error or success message
function hideMessage(type) {
    const messageDiv = document.getElementById(`${type}Message`);
    if (messageDiv) {
        messageDiv.style.display = 'none';
    }
}

// Set loading state for button
function setLoadingState(button, isLoading) {
    if (isLoading) {
        button.disabled = true;
        button.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Sending...';
    } else {
        button.disabled = false;
        button.innerHTML = 'Send Reset Instructions';
    }
}

// Show success state
function showSuccessState(email) {
    const form = document.getElementById('forgotPasswordForm');
    const successState = document.getElementById('successState');
    const sentEmail = document.getElementById('sentEmail');
    
    // Hide form and show success state
    form.style.display = 'none';
    successState.style.display = 'block';
    sentEmail.textContent = email;
    
    // Show success message
    showMessage('success', 'Password reset instructions sent successfully!');
}

// Reset form to initial state
function resetForm() {
    const form = document.getElementById('forgotPasswordForm');
    const successState = document.getElementById('successState');
    const emailInput = document.getElementById('email');
    const submitBtn = document.getElementById('submitBtn');
    
    // Show form and hide success state
    form.style.display = 'block';
    successState.style.display = 'none';
    
    // Reset form fields
    emailInput.value = '';
    emailInput.classList.remove('error');
    
    // Hide all messages
    hideMessage('error');
    hideMessage('success');
    
    // Reset button state
    setLoadingState(submitBtn, false);
}

// Simulate password reset request (replace with actual API call)
async function simulatePasswordResetRequest(email) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            // Simulate successful response
            // In production, replace this with actual API call:
            // const response = await fetch('/api/forgot-password', {
            //     method: 'POST',
            //     headers: { 'Content-Type': 'application/json' },
            //     body: JSON.stringify({ email })
            // });
            
            console.log('Password reset requested for:', email);
            resolve({ success: true });
            
            // Simulate error (uncomment to test error handling):
            // reject(new Error('Failed to send reset email. Please try again.'));
        }, 1500);
    });
}

