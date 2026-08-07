# Buho Mobile App - Capacitor Wrapper Documentation

This document describes the structure, implementation, and instructions for running the Capacitor-based mobile application that wraps the Salesforce Experience Cloud site `https://u.gobuho.com` for iOS and Android.

---

## 1. Overview & Architecture

To wrap the Salesforce Experience Cloud site into a native iOS and Android application with minimal overhead, we initialized a **Capacitor** application. 

### Implementation Approaches

There are two primary approaches to loading the external site:

#### Option A: Fullscreen Iframe (Current Implementation)
We serve a local static `www/index.html` file on the mobile device which renders a fullscreen iframe pointing to `https://u.gobuho.com`. 
- **Pros:** Fast load times for local assets, custom local splash screen, ability to inject custom offline handling.
- **Cons:** Salesforce Experience Cloud sites typically have Clickjacking Protection enabled, which adds `X-Frame-Options: SAMEORIGIN` or CSP `frame-ancestors 'self'`. This might cause the browser/webview to block rendering within the iframe.

*Note: If you run into issues where the portal fails to load inside the iframe, you must configure the Salesforce Session Security settings to allow framing for the app's local origin (e.g., `capacitor://localhost` or `http://localhost`).*

#### Option B: Direct Webview Loading (Alternative / Recommended Backup)
If Salesforce clickjacking protections cannot be disabled or bypassed via framing, you can configure Capacitor to load the Salesforce Experience site directly as the main frame in the webview.
- **Pros:** Completely bypasses clickjacking protection and iframe frame-ancestors restrictions because the site is loaded directly as the top-level document inside the native webview.
- **Cons:** Doesn't serve local web pages first, so loading relies entirely on remote connection.

To enable **Option B**, modify your `capacitor.config.json` file as follows:
```json
{
  "appId": "com.gobuho.app",
  "appName": "Buho Mobile",
  "webDir": "www",
  "server": {
    "url": "https://u.gobuho.com",
    "androidScheme": "https"
  }
}
```

---

## 2. Files Created

1. **[package.json](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/mobile_app/package.json)**
   - Manages the Node project environment.
   - Installs the required Capacitor CLI and Core packages (`@capacitor/core` and `@capacitor/cli`).

2. **[capacitor.config.json](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/mobile_app/capacitor.config.json)**
   - Defines basic app configurations:
     - `appId`: The native bundle identifier (`com.gobuho.app`).
     - `appName`: The display name of the application (`Buho Mobile`).
     - `webDir`: The directory containing local assets to bundle (`www`).

3. **[www/index.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/mobile_app/www/index.html)**
   - Displays a premium loading screen with custom animations.
   - Features a viewport optimized for modern notched phones (`viewport-fit=cover`).
   - Uses safe-area-inset CSS variables to avoid system UI overlaps.
   - Embeds a fullscreen iframe pointing to the Buho experience site.

4. **[claude.md](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/mobile_app/claude.md)**
   - This documentation file.

---

## 3. How to Run and Build the App

To run and build this application on your local machine, execute the following commands in your terminal from the `mobile_app` folder:

### Step 1: Install Node Dependencies
Installs `@capacitor/core` and `@capacitor/cli`:
```bash
npm install
```

### Step 2: Install Platform Dependencies
Installs the iOS and Android platforms support packages:
```bash
npm install @capacitor/ios @capacitor/android
```

### Step 3: Add Native Projects
Generates the native Xcode and Android Studio projects:
```bash
npx cap add ios
npx cap add android
```

### Step 4: Sync Web Assets to Native Platforms
Whenever you make changes to files in the `www` folder, copy those updates into the native projects:
```bash
npx cap sync
```

### Step 5: Open Native IDEs to Run/Archive
Capacitor acts as a bridge. Use these helper commands to open the native projects in Xcode or Android Studio:

- **For iOS (macOS only):**
  ```bash
  npx cap open ios
  ```
  *This opens Xcode. Select an emulator or connected device and press the Play button to run.*

- **For Android:**
  ```bash
  npx cap open android
  ```
  *This opens Android Studio. Select an emulator or connected device and run the project.*

---

## 4. Advanced Configurations & Features

### iOS Safe Area (Notch Layout Fix)
To prevent content from bleeding under the iPhone status bar and notch area when loading the external site directly (`server.url`), we modified the iOS native views:
1. Created a custom subclass `ViewController` at the bottom of **[AppDelegate.swift](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/mobile_app/ios/App/App/AppDelegate.swift)**: Subclasses `CAPBridgeViewController` and dynamically updates the scroll view's `contentInset` inside `viewSafeAreaInsetsDidChange()` to match the device safe area offsets. This offsets the remote page content down below the notch and status bar while keeping the full-screen background aesthetics intact, avoiding constraints conflicts and feedback recursion loops.
2. Updated **[Main.storyboard](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/mobile_app/ios/App/App/Base.lproj/Main.storyboard)**: Replaced the default view controller class (`CAPBridgeViewController`) with our custom `ViewController` implementation.

### Native PDF Downloading & Viewing
To bypass webview PDF limitations (especially on Android), we implemented a JavaScript-to-Native bridge flow:

1. **LWC Integration ([buho_quotePage.js](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_quotePage/buho_quotePage.js))**:
   - Detects if running inside Capacitor (`window.Capacitor`).
   - If direct (Option B), calls the `@capacitor/filesystem` and `@capacitor-community/file-opener` plugins to fetch and launch the native viewer directly.
   - If inside an iframe (Option A), uses `window.parent.postMessage` to send a `downloadPdf` request to the parent container.
   
2. **Capacitor Container Listener ([www/index.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/mobile_app/www/index.html))**:
   - Listens to incoming `downloadPdf` postMessage events from the iframe.
   - Invokes the local Capacitor plugins to download the PDF binary to the device cache and triggers the native Android/iOS file opener prompt.

### Splash Screen & App Icon Generation
To display a professional splash screen at startup and avoid a blank white load screen, we use the Capacitor `@capacitor/splash-screen` plugin combined with the automated asset generation tool:

1. **Configurations (`capacitor.config.json`)**:
   We added configurations under the `"plugins"` section to keep the splash screen visible for `3000ms` (3 seconds) while the remote website loads in the background:
   ```json
   "plugins": {
     "SplashScreen": {
       "launchShowDuration": 3000,
       "launchAutoHide": true,
       "backgroundColor": "#ffffff",
       "showSpinner": false
     }
   }
   ```
2. **Generating Native Icon & Splash assets**:
   We placed high-resolution source files in `assets/icon.png` (1024x1024 px) and `assets/splash.png` (2732x2732 px).
   Run the following commands in the `mobile_app` folder to automatically resize and inject the icons and splash images into the iOS Xcode project and Android Gradle folders:
   ```bash
   npm install
   npm install @capacitor/assets --save-dev
   npx capacitor-assets generate
   ```


