import { LightningElement, api, track } from 'lwc';

export default class Buho_carousel extends LightningElement {
    @api slidesData = []; // Array of slide objects: { image, text, alt }
    @api autoAdvanceInterval = 5000; // Auto-advance interval in milliseconds
    @api disableAutoAdvance; // Enable/disable auto-advance
    
    
    @track currentSlideIndex = 0;
    carouselInterval;
    enableAutoAdvance = !(this.disableAutoAdvance === true);

    // Computed property for current slide display (1-based)
    get currentSlideDisplay() {
        return this.currentSlideIndex + 1;
    }

    // Computed property for total slides
    get totalSlides() {
        return this.slidesData ? this.slidesData.length : 0;
    }

    // Transform slides data to include active class and unique id
    get slides() {
        if (!this.slidesData || this.slidesData.length === 0) {
            return [];
        }

        return this.slidesData.map((slide, index) => ({
            id: `slide-${index}`,
            image: slide.image,
            text: slide.text,
            alt: slide.alt || slide.text,
            slideClass: index === this.currentSlideIndex ? 'carousel-slide active' : 'carousel-slide'
        }));
    }

    // Lifecycle: component rendered
    renderedCallback() {
        if (this.enableAutoAdvance && !this.carouselInterval && this.totalSlides > 1) {
            this.startAutoAdvance();
        }
    }

    // Lifecycle: component disconnected
    disconnectedCallback() {
        this.stopAutoAdvance();
    }

    // Start auto-advance
    startAutoAdvance() {
        this.stopAutoAdvance(); // Clear any existing interval
        this.carouselInterval = setInterval(() => {
            this.showSlide(this.currentSlideIndex + 1);
        }, this.autoAdvanceInterval);
    }

    // Stop auto-advance
    stopAutoAdvance() {
        if (this.carouselInterval) {
            clearInterval(this.carouselInterval);
            this.carouselInterval = null;
        }
    }

    // Show specific slide
    showSlide(index) {
        const totalSlides = this.totalSlides;
        
        // Wrap around if necessary
        if (index >= totalSlides) {
            this.currentSlideIndex = 0;
        } else if (index < 0) {
            this.currentSlideIndex = totalSlides - 1;
        } else {
            this.currentSlideIndex = index;
        }

        // Dispatch event to notify parent of slide change
        this.dispatchEvent(new CustomEvent('slidechange', {
            detail: { 
                currentSlide: this.currentSlideIndex,
                totalSlides: totalSlides
            }
        }));
    }

    // Handle next button click
    handleNext(event) {
        event.preventDefault();
        event.stopPropagation();
        
        this.showSlide(this.currentSlideIndex + 1);
        
        // Restart auto-advance after manual interaction
        if (this.enableAutoAdvance) {
            this.startAutoAdvance();
        }
    }

    // Handle previous button click
    handlePrev(event) {
        event.preventDefault();
        event.stopPropagation();
        
        this.showSlide(this.currentSlideIndex - 1);
        
        // Restart auto-advance after manual interaction
        if (this.enableAutoAdvance) {
            this.startAutoAdvance();
        }
    }

    // Public method to navigate to specific slide
    @api
    goToSlide(index) {
        this.showSlide(index);
    }

    // Public method to pause carousel
    @api
    pause() {
        this.stopAutoAdvance();
    }

    // Public method to resume carousel
    @api
    resume() {
        if (this.enableAutoAdvance) {
            this.startAutoAdvance();
        }
    }
}

