import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// Static Resources - All assets in one ZIP
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

// Apex Controller
import login from '@salesforce/apex/BuhoLoginController.login';

// Community Base Path
import basePath from '@salesforce/community/basePath';

export default class Buho_login extends NavigationMixin(LightningElement) {
    // Public properties (configurable in Experience Builder)
    @api showCarousel = false;
    @api showSocialLogin = false;
    @api forgotPasswordUrl = '/ForgotPassword';
    @api signUpUrl = '/SelfRegister';
    @api startUrl = '/community';

    // Private tracked properties
    @track email = '';
    @track password = '';
    @track errorMessage = '';
    @track successMessage = '';
    @track isLoading = false;
    @track currentSlide = 0;

    // Carousel slides data
    @track slides = [
        {
            id: 1,
            title: 'Smart protection for your Mexican adventures',
            imageUrl: '',
            cssClass: 'buho-carousel-slide active'
        },
        {
            id: 2,
            title: 'Comprehensive coverage for every journey',
            imageUrl: '',
            cssClass: 'buho-carousel-slide'
        },
        {
            id: 3,
            title: 'Fast and easy claims process',
            imageUrl: '',
            cssClass: 'buho-carousel-slide'
        },
        {
            id: 4,
            title: '24/7 customer support',
            imageUrl: '',
            cssClass: 'buho-carousel-slide'
        },
        {
            id: 5,
            title: 'Best rates for your peace of mind',
            imageUrl: '',
            cssClass: 'buho-carousel-slide'
        }
    ];

    stylesLoaded = false;
    autoAdvanceInterval;

    // Getters for asset URLs (from buhoAssets ZIP)
    get logoUrl() {
        return `${buhoAssets}/images/Logo.svg`;
    }

    get googleIconUrl() {
        return `${buhoAssets}/images/google-icon.svg`;
    }

    get twitterIconUrl() {
        return `${buhoAssets}/images/twitter-icon.svg`;
    }

    get carouselImageUrl() {
        return `${buhoAssets}/images/lady-image.png`;
    }

    get stylesUrl() {
        return `${buhoAssets}/css/buhoStyles.css`;
    }

    get currentSlideNumber() {
        return this.currentSlide + 1;
    }

    get totalSlides() {
        return this.slides.length;
    }

    // Boolean getter for template attribute
    get showForgotPasswordLink() {
        return true;
    }

    // Lifecycle hooks
    connectedCallback() {
        // Initialize carousel image URLs
        this.slides = this.slides.map(slide => ({
            ...slide,
            imageUrl: this.carouselImageUrl
        }));

        // Start auto-advance
        this.startAutoAdvance();
    }

    disconnectedCallback() {
        // Clear auto-advance interval
        if (this.autoAdvanceInterval) {
            clearInterval(this.autoAdvanceInterval);
        }
    }

    // Event Handlers
    handleUsernameChange(event) {
        this.email = event.detail.value;
        this.clearMessages();
    }

    handlePasswordChange(event) {
        this.password = event.detail.value;
        this.clearMessages();
    }

    handleLogin() {
        console.log('handleLogin');
        // Validate inputs
        if (!this.validateInputs()) {
            return;
        }

        this.isLoading = true;
        this.clearMessages();

        // Call Apex controller
        login({ username: this.email, password: this.password, startUrl: this.startUrl })
            .then(result => {
                console.log('@@@result',JSON.stringify(result));
                if (result && result.startsWith('http')) {
                    // Successful login - redirect
                    window.location.href = result;
                } else {
                    this.errorMessage = result || 'Login failed. Please try again.';
                }
            })
            .catch(error => {
                console.error('Login error:', error);
                this.errorMessage = this.getErrorMessage(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleForgotPassword() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Forgot_Password'
            }
        });
    }

    handleSignUp() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'selfRegister'
            }
        });
    }

    handleGoogleLogin() {
        // Navigate to Google OAuth endpoint
        // This should be configured in Salesforce Auth Providers
        const googleAuthUrl = `${basePath}/services/auth/sso/Google`;
        window.location.href = googleAuthUrl;
    }

    handleTwitterLogin() {
        // Navigate to Twitter OAuth endpoint
        const twitterAuthUrl = `${basePath}/services/auth/sso/Twitter`;
        window.location.href = twitterAuthUrl;
    }

    // Carousel methods
    handlePrevSlide() {
        this.goToSlide(this.currentSlide - 1);
        this.resetAutoAdvance();
    }

    handleNextSlide() {
        this.goToSlide(this.currentSlide + 1);
        this.resetAutoAdvance();
    }

    goToSlide(index) {
        // Wrap around
        if (index < 0) {
            index = this.slides.length - 1;
        } else if (index >= this.slides.length) {
            index = 0;
        }

        this.currentSlide = index;
        this.updateSlideClasses();
    }

    updateSlideClasses() {
        this.slides = this.slides.map((slide, index) => ({
            ...slide,
            cssClass: index === this.currentSlide 
                ? 'buho-carousel-slide active' 
                : 'buho-carousel-slide'
        }));
    }

    startAutoAdvance() {
        this.autoAdvanceInterval = setInterval(() => {
            this.goToSlide(this.currentSlide + 1);
        }, 5000);
    }

    resetAutoAdvance() {
        clearInterval(this.autoAdvanceInterval);
        this.startAutoAdvance();
    }

    // Utility methods
    validateInputs() {
        if (!this.email) {
            this.errorMessage = 'Please enter your email address.';
            return false;
        }

        if (!this.isValidEmail(this.email)) {
            this.errorMessage = 'Please enter a valid email address.';
            return false;
        }

        if (!this.password) {
            this.errorMessage = 'Please enter your password.';
            return false;
        }

        return true;
    }

    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    clearMessages() {
        this.errorMessage = '';
        this.successMessage = '';
    }

    getErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        }
        if (error.message) {
            return error.message;
        }
        return 'An unexpected error occurred. Please try again.';
    }
}

