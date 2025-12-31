# BÚHO Insurance Brokerage - Authentication Pages

A modern, responsive authentication system for BÚHO Insurance Brokerage, designed for Salesforce Community integration and LWC component conversion.

## Pages

### Login Page (`index.html`)
- Email/Password login form
- Social login (Google & Twitter)
- Interactive carousel with 5 slides
- Forgot password link

### Reset Password Page (`reset-password.html`)
- Create new password form
- Confirm password validation
- Password strength indicator
- Back to login link

## Features

- ✅ Pixel-perfect replication of Figma designs
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ Interactive carousel with 5 slides
- ✅ Social login buttons (Google & Twitter)
- ✅ Form validation with real-time feedback
- ✅ Password strength indicator
- ✅ Smooth animations and transitions
- ✅ Touch/swipe support for mobile
- ✅ Keyboard navigation
- ✅ Auto-advancing carousel
- ✅ Reusable CSS components (LWC-ready)
- ✅ Modular JavaScript utilities

## Brand Assets

### Colors
- **Primary Blue**: `#13203D`
- **Accent Pink**: `#E53C7B`
- **Light Blue**: `#89DBEF`

### Typography
- **Font Family**: Poppins (fallback: system fonts)
- **Logo**: Bold/Black weight
- **Headings**: Bold weight (700)
- **Body**: Regular weight (400-500)

## File Structure

```
Buho/
├── index.html                      # Login page
├── reset-password.html             # Reset password page
├── README.md                       # Documentation
├── css/
│   ├── styles.css                  # Base/login page styles
│   ├── reset-password.css          # Reset password page styles
│   └── shared.css                  # Shared components (LWC-ready)
├── js/
│   ├── script.js                   # Login page functionality
│   ├── reset-password.js           # Reset password functionality
│   └── utils.js                    # Shared utilities (LWC-ready)
└── assets/
    ├── lady image.png              # Hero image for carousel
    ├── Logo.svg                    # BÚHO logo (icon + text combined)
    ├── google-icon.svg             # Google login icon
    ├── twitter-icon.svg            # Twitter login icon
    ├── arrow-left.svg              # Left navigation arrow
    └── arrow-right.svg             # Right navigation arrow
```

## LWC Component Conversion Guide

### CSS as Static Resources

The CSS files are designed with CSS custom properties (variables) and BEM-like naming conventions for easy conversion:

#### Design Tokens (`shared.css`)
```css
/* Import these variables in your LWC component */
--buho-primary-blue: #13203D;
--buho-accent-pink: #E53C7B;
--buho-spacing-md: 16px;
--buho-radius-md: 8px;
```

#### Reusable CSS Classes
- `.buho-btn-primary` - Primary action buttons
- `.buho-btn-secondary` - Secondary action buttons
- `.buho-btn-social` - Social login buttons
- `.buho-input` - Input fields
- `.buho-form-group` - Form field containers
- `.buho-card` - Card containers
- `.buho-link` - Styled links

### JavaScript Utilities (`utils.js`)

The utilities are namespaced and can be imported as static resources:

```javascript
// Available globally or can be exported for ES6 modules
BuhoValidation.isValidEmail(email);
BuhoValidation.validatePasswordStrength(password);
BuhoValidation.doPasswordsMatch(password, confirmPassword);
BuhoUI.setButtonLoading(button, 'Loading...');
BuhoUI.showError(container, 'Error message');
BuhoForm.serialize(form);
BuhoNav.getUrlParams();
```

### Converting to LWC

1. **Create Static Resources**
   ```
   BuhoSharedStyles   → css/shared.css
   BuhoLoginStyles    → css/styles.css
   BuhoResetStyles    → css/reset-password.css
   BuhoUtils          → js/utils.js
   ```

2. **Import in LWC Component**
   ```javascript
   import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
   import BUHO_SHARED_STYLES from '@salesforce/resourceUrl/BuhoSharedStyles';
   import BUHO_UTILS from '@salesforce/resourceUrl/BuhoUtils';
   
   renderedCallback() {
       loadStyle(this, BUHO_SHARED_STYLES);
       loadScript(this, BUHO_UTILS);
   }
   ```

3. **Use CSS Classes in Template**
   ```html
   <template>
       <div class="buho-card buho-card--gradient">
           <form class="buho-form">
               <div class="buho-form-group">
                   <label>Email</label>
                   <input type="email" class="buho-input">
               </div>
               <button class="buho-btn-primary">Submit</button>
           </form>
       </div>
   </template>
   ```

## Usage

### Standalone
Simply open `index.html` in a web browser.

### Salesforce Community Integration

1. **Upload Static Resources**
   
   **CSS Files:**
   - `css/shared.css` → `BuhoSharedStyles`
   - `css/styles.css` → `BuhoLoginStyles`
   - `css/reset-password.css` → `BuhoResetStyles`
   
   **JavaScript Files:**
   - `js/utils.js` → `BuhoUtils`
   - `js/script.js` → `BuhoLoginScript`
   - `js/reset-password.js` → `BuhoResetScript`
   
   **Assets:**
   - `assets/lady image.png` → `BuhoLadyImage`
   - `assets/Logo.svg` → `BuhoLogo`
   - `assets/google-icon.svg` → `BuhoGoogleIcon`
   - `assets/twitter-icon.svg` → `BuhoTwitterIcon`
   - `assets/arrow-left.svg` → `BuhoArrowLeft`
   - `assets/arrow-right.svg` → `BuhoArrowRight`

2. **Create Custom Pages**
   
   **Login Page:**
   - In Salesforce Community Builder, create a new login page
   - Add an HTML component
   - Copy the content from `index.html` (body section)
   
   **Reset Password Page:**
   - Create a new page for password reset
   - Copy the content from `reset-password.html` (body section)
   
   Update resource URLs:
   ```html
   <link rel="stylesheet" href="{!$Resource.BuhoSharedStyles}">
   <link rel="stylesheet" href="{!$Resource.BuhoLoginStyles}">
   <script src="{!$Resource.BuhoUtils}"></script>
   <script src="{!$Resource.BuhoLoginScript}"></script>
   <img src="{!$Resource.BuhoLogo}" alt="...">
   ```

3. **Connect Authentication**
   - Update the form submission handler in `script.js`
   - Integrate with Salesforce Community authentication APIs
   - Configure OAuth for social login buttons
   - Connect reset password form to Salesforce password reset API

## Customization

### Changing Colors
Edit the CSS variables in `css/styles.css`:
```css
:root {
    --primary-blue: #13203D;
    --accent-pink: #E53C7B;
    --light-blue: #89DBEF;
}
```

### Adding More Carousel Slides
Add more `.carousel-slide` divs in `index.html`:
```html
<div class="carousel-slide">
    <div class="carousel-image">
        <img src="your-image.png" alt="Description">
    </div>
    <div class="carousel-content">
        <h3>Your heading text</h3>
    </div>
</div>
```

### Customizing Auto-advance Timing
In `js/script.js`, change the interval (in milliseconds):
```javascript
let autoAdvance = setInterval(() => {
    showSlide(currentSlide + 1);
}, 5000); // 5000ms = 5 seconds
```

## Browser Support

- ✅ Chrome (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Edge (latest)
- ✅ Mobile browsers (iOS Safari, Chrome Mobile)

## Features for Salesforce Community

- Clean, maintainable code
- No external dependencies (except fonts)
- Easy integration with Salesforce authentication
- Responsive design for all devices
- Accessibility-friendly markup
- SEO-optimized structure

## Integration Checklist

- [ ] Upload static resources to Salesforce
- [ ] Update image/CSS/JS URLs to Static Resource URLs
- [ ] Connect form submission to Salesforce login API
- [ ] Configure Google OAuth provider in Salesforce
- [ ] Configure Twitter OAuth provider in Salesforce
- [ ] Test on mobile devices
- [ ] Test social login functionality
- [ ] Set up "Forgot Password" flow
- [ ] Create "Sign Up" page and link it
- [ ] Test in Salesforce Community preview

## Support

For questions or issues, please contact your development team.

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Design**: Based on Figma mockup

