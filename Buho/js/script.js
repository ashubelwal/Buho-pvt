// Carousel functionality
let currentSlide = 0;
const slides = document.querySelectorAll('.carousel-slide');
const totalSlides = slides.length;
const currentSlideEl = document.getElementById('currentSlide');
const totalSlidesEl = document.getElementById('totalSlides');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');

// Update total slides counter
totalSlidesEl.textContent = totalSlides;

function showSlide(index) {
    // Remove active class from all slides
    slides.forEach(slide => {
        slide.classList.remove('active');
    });

    // Wrap around if necessary
    if (index >= totalSlides) {
        currentSlide = 0;
    } else if (index < 0) {
        currentSlide = totalSlides - 1;
    } else {
        currentSlide = index;
    }

    // Add active class to current slide
    slides[currentSlide].classList.add('active');
    
    // Update counter
    currentSlideEl.textContent = currentSlide + 1;
}

// Next button click
nextBtn.addEventListener('click', () => {
    showSlide(currentSlide + 1);
});

// Previous button click
prevBtn.addEventListener('click', () => {
    showSlide(currentSlide - 1);
});

// Auto-advance carousel every 5 seconds
let autoAdvance = setInterval(() => {
    showSlide(currentSlide + 1);
}, 5000);

// Stop auto-advance when user interacts with carousel
[prevBtn, nextBtn].forEach(btn => {
    btn.addEventListener('click', () => {
        clearInterval(autoAdvance);
        // Restart auto-advance after 10 seconds
        autoAdvance = setInterval(() => {
            showSlide(currentSlide + 1);
        }, 5000);
    });
});

// Form submission handling
const loginForm = document.getElementById('loginForm');

loginForm.addEventListener('submit', (e) => {
    e.preventDefault();
    
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const submitBtn = loginForm.querySelector('.btn-signin');
    
    // Add loading state
    submitBtn.classList.add('loading');
    submitBtn.textContent = 'Signing in...';
    
    // Simulate API call
    setTimeout(() => {
        console.log('Login attempt:', { email, password });
        
        // Remove loading state
        submitBtn.classList.remove('loading');
        submitBtn.textContent = 'Sign in';
        
        // Here you would typically make an API call to your Salesforce backend
        // Example:
        // fetch('/api/login', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify({ email, password })
        // })
        // .then(response => response.json())
        // .then(data => {
        //     if (data.success) {
        //         window.location.href = '/dashboard';
        //     } else {
        //         alert('Invalid credentials');
        //     }
        // });
        
        alert('Login functionality ready! Connect to your Salesforce backend.');
    }, 1500);
});

// Social login handlers
document.querySelector('.btn-google').addEventListener('click', () => {
    console.log('Google Sign In clicked');
    // Implement Google OAuth here
    alert('Google Sign In - Connect to your OAuth provider');
});

document.querySelector('.btn-twitter').addEventListener('click', () => {
    console.log('Twitter Sign In clicked');
    // Implement Twitter OAuth here
    alert('Twitter Sign In - Connect to your OAuth provider');
});

// Keyboard navigation for carousel
document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowLeft') {
        showSlide(currentSlide - 1);
    } else if (e.key === 'ArrowRight') {
        showSlide(currentSlide + 1);
    }
});

// Touch/swipe support for mobile
let touchStartX = 0;
let touchEndX = 0;

const carouselContainer = document.querySelector('.carousel-container');

carouselContainer.addEventListener('touchstart', (e) => {
    touchStartX = e.changedTouches[0].screenX;
});

carouselContainer.addEventListener('touchend', (e) => {
    touchEndX = e.changedTouches[0].screenX;
    handleSwipe();
});

function handleSwipe() {
    const swipeThreshold = 50;
    const diff = touchStartX - touchEndX;
    
    if (Math.abs(diff) > swipeThreshold) {
        if (diff > 0) {
            // Swipe left - next slide
            showSlide(currentSlide + 1);
        } else {
            // Swipe right - previous slide
            showSlide(currentSlide - 1);
        }
    }
}

// Input validation and UX enhancements
const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');

// Email validation
emailInput.addEventListener('blur', () => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (emailInput.value && !emailRegex.test(emailInput.value)) {
        emailInput.style.borderColor = '#EF4444';
    } else {
        emailInput.style.borderColor = '';
    }
});

// Clear error on focus
[emailInput, passwordInput].forEach(input => {
    input.addEventListener('focus', () => {
        input.style.borderColor = '';
    });
});

