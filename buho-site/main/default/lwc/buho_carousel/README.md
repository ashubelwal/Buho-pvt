# BÚHO Carousel Component

A reusable carousel component for displaying rotating slides with images and text.

## Features

- Auto-advance slides (configurable interval)
- Manual navigation (prev/next buttons)
- Smooth fade animations
- Responsive design
- Touch/swipe support (inherited from CSS)
- Accessible controls
- Configurable slides via data binding

## Usage

### 1. Import the Component

```html
<c-buho_carousel
    slides-data={carouselSlides}
    auto-advance-interval="5000"
    disable-auto-advance={disableAutoAdvance}>
</c-buho_carousel>
```

### 2. Define Slides Data in JavaScript

```javascript
import { LightningElement } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class MyComponent extends LightningElement {
    
    get ladyImage() {
        return `${buhoAssets}/images/lady-image.png`;
    }

    get carouselSlides() {
        return [
            {
                image: this.ladyImage,
                text: 'Smart protection for your Mexican adventures',
                alt: 'Smart protection'
            },
            {
                image: this.ladyImage,
                text: 'Comprehensive coverage for every journey',
                alt: 'Comprehensive coverage'
            },
            {
                image: this.ladyImage,
                text: 'Fast and easy claims process',
                alt: 'Easy claims'
            },
            {
                image: this.ladyImage,
                text: '24/7 customer support',
                alt: '24/7 Support'
            },
            {
                image: this.ladyImage,
                text: 'Best rates for your peace of mind',
                alt: 'Best rates'
            }
        ];
    }

    // Optional: only if you want to disable auto-advance
    get disableAutoAdvance() {
        return false; // Set to true to disable auto-advance
    }
}
```

## Properties

### `slides-data` (Required)
**Type:** Array  
**Description:** Array of slide objects, each containing:
- `image` (string): URL to the slide image
- `text` (string): Text to display on the slide
- `alt` (string): Alt text for accessibility

### `auto-advance-interval` (Optional)
**Type:** Number  
**Default:** 5000  
**Description:** Time in milliseconds between auto-advancing slides

### `disable-auto-advance` (Optional)
**Type:** Boolean  
**Default:** undefined (auto-advance is enabled by default)  
**Description:** Set to `true` to disable automatic slide advancement. If not provided or `false`, auto-advance is enabled.

**Note:** Public properties (@api) in LWC should not be initialized with default values. By default, auto-advance is enabled unless you explicitly set `disable-auto-advance={true}` or bind it to a truthy value.

## Public Methods

The carousel exposes these public methods for programmatic control:

### `goToSlide(index)`
Navigate to a specific slide by index (0-based)

```javascript
this.template.querySelector('c-buho_carousel').goToSlide(2);
```

### `pause()`
Pause auto-advance

```javascript
this.template.querySelector('c-buho_carousel').pause();
```

### `resume()`
Resume auto-advance

```javascript
this.template.querySelector('c-buho_carousel').resume();
```

## Events

### `slidechange`
Fired when the slide changes (either manually or automatically)

**Event Detail:**
```javascript
{
    currentSlide: number,  // 0-based index of current slide
    totalSlides: number    // Total number of slides
}
```

**Usage:**
```html
<c-buho_carousel
    slides-data={carouselSlides}
    onslidechange={handleSlideChange}>
</c-buho_carousel>
```

```javascript
handleSlideChange(event) {
    const { currentSlide, totalSlides } = event.detail;
    console.log(`Slide ${currentSlide + 1} of ${totalSlides}`);
}
```

## Example: Using in Login Component

```html
<!-- buho_login.html -->
<template>
    <div class="login-container">
        <!-- Left Section - Login Form -->
        <div class="login-section">
            <!-- Your login form here -->
        </div>

        <!-- Right Section - Carousel -->
        <div class="carousel-section">
            <c-buho_carousel
                slides-data={loginCarouselSlides}
                auto-advance-interval="5000">
            </c-buho_carousel>
        </div>
    </div>
</template>
```

```javascript
// buho_login.js
import { LightningElement } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';

export default class Buho_login extends LightningElement {
    
    get ladyImage() {
        return `${buhoAssets}/images/lady-image.png`;
    }

    get loginCarouselSlides() {
        return [
            {
                image: this.ladyImage,
                text: 'Smart protection for your Mexican adventures',
                alt: 'Smart protection'
            },
            // ... more slides
        ];
    }

    // Optional: Omit this getter to enable auto-advance by default
    // Or set to true to disable auto-advance
    // get disableAutoAdvance() {
    //     return false;
    // }
}
```

## Styling

The carousel uses global styles from `buhoStyles.css`. Component-specific styles are minimal and focus on layout. The carousel inherits the following CSS classes:

- `.carousel-container` - Main container
- `.carousel-slide` - Individual slides
- `.carousel-slide.active` - Active slide
- `.carousel-controls` - Controls container
- `.carousel-btn` - Navigation buttons
- `.carousel-counter` - Slide counter

## Best Practices

### Default Behavior
By default, the carousel auto-advances every 5 seconds. You don't need to pass any properties to enable this:

```html
<c-buho_carousel slides-data={carouselSlides}></c-buho_carousel>
```

### Disabling Auto-Advance
Only pass `disable-auto-advance` if you want to disable the default behavior:

```html
<c-buho_carousel 
    slides-data={carouselSlides}
    disable-auto-advance={true}>
</c-buho_carousel>
```

### Custom Interval
Change the auto-advance interval (default is 5000ms):

```html
<c-buho_carousel 
    slides-data={carouselSlides}
    auto-advance-interval="3000">
</c-buho_carousel>
```

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- IE11 not supported (uses modern JavaScript features)

## Dependencies

- Lightning Web Components
- Bootstrap Icons (for chevron icons)
- buhoAssets static resource

## LWC Best Practices Note

⚠️ **Important:** Public properties (`@api`) in LWC should not be initialized with default values. This component follows that best practice by:
- Using `disableAutoAdvance` (undefined by default) instead of `enableAutoAdvance = true`
- Calculating `enableAutoAdvance` internally as `!(this.disableAutoAdvance === true)`
- This ensures auto-advance is enabled by default without initializing a public property

