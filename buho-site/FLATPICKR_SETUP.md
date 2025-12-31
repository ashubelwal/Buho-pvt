# Flatpickr Setup for Date Picker - UPDATED

## Root Cause Identified ✅

The date picker wasn't working because we were using LWC components (`c-nc_datepicker` and `lightning-input`) instead of native HTML `<input>` elements that Flatpickr can attach to.

## Important: Term Days Mapping

**NOTE:** The Apex method `getTermDaysMetadata()` returns term options with ONLY `label` and `value` fields (e.g., "Daily", "Semi-Annual", "Annual"). There is **NO `days` attribute** in the metadata.

Therefore, the term-to-days mapping is **hardcoded** in the JavaScript:

```javascript
termDaysMap = {
    'Daily': 1,
    'Semi-Annual': 180, // 6 months
    'Annual': 365 // 1 year
};
```

This mapping is used to calculate end dates when:
1. User selects a start date
2. User changes the term type
3. Component initializes with default values

## Solution Implemented ✅

### **Changes Made:**

1. **Replaced LWC Components with Native HTML Inputs**
   - Removed `c-nc_datepicker` component
   - Replaced with native `<input type="text">` with class `flatpickr-input`
   - Removed `lightning-input` for time fields
   - Replaced with native `<input type="time">`

2. **Added Flatpickr Initialization in JavaScript**
   - Added `initializeFlatpickr()` method to attach Flatpickr to start date input
   - Added `handleDateChange()` method to calculate end dates based on term type
   - Added `updateFlatpickr()` method to reinitialize when term changes
   - Added `termDaysMap` to store days offset for each term type

3. **Automatic Date Calculation**
   - When user selects start date, end date is automatically calculated
   - Calculation based on term type:
     - **Daily**: +1 day
     - **Semi-Annual**: +180 days (approximately)
     - **Annual**: +365 days
   - End date is automatically populated and readonly

## HTML Structure

```html
<!-- Start Date Input (Flatpickr attaches here) -->
<input 
    type="text" 
    id="startDate"
    name="Start_Date_for_Coverage__c"
    class="form-control flatpickr-input" 
    placeholder="MM/DD/YYYY"
    data-input
    onchange={handleInputChange}
    disabled={flags.disableDateRange}
    readonly
    required>

<!-- End Date Input (Readonly, auto-calculated) -->
<input 
    type="text" 
    id="endDate"
    name="End_Date_for_Coverage__c"
    class="form-control" 
    placeholder="MM/DD/YYYY"
    value={formattedEndDate}
    disabled={flags.disableDateRange}
    readonly
    required>
```

### Important Attributes:
- **`onchange={handleInputChange}`** - Triggers parent payload update
- **`disabled={flags.disableDateRange}`** - Respects component-level disable flags
- **`readonly`** - Prevents manual typing (calendar selection only)
- **`data-input`** - Flatpickr attribute for input binding

## JavaScript Implementation

### Key Methods Added:

1. **`initializeFlatpickr()`**
   - Attaches Flatpickr to the `#startDate` input
   - Sets minimum date to today (or system date)
   - Configures date format as `m/d/Y` (MM/DD/YYYY)
   - Respects `flags.disableDateRange` to disable date selection when needed
   - Sets up `onChange` callback to trigger `handleDateChange`

2. **`handleDateChange(selectedDate, daysOffset)`**
   - Calculates end date based on selected start date
   - Updates `startDate`, `endDate`, and `dateRange` properties
   - Updates `inputValues` object with both new format (`Start_Date_for_Coverage__c`) and legacy format (`StartDate`)
   - Triggers `handleInputChange` to update parent payload
   - Calls `resetStartTimeIfFuture()` to validate time selection

3. **`updateFlatpickr()`**
   - Destroys existing Flatpickr instance
   - Reinitializes with new settings (e.g., when term changes)

4. **`formatDateForApi(date)`**
   - Formats date as `YYYY-MM-DD` for API

5. **`formatDateForDisplay(dateString)`**
   - Formats date as `MM/DD/YYYY` for display

## Required Global Scripts

Your Salesforce Community Head Markup should include:

```html
<!-- Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<!-- Flatpickr (Both CSS and JS required) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

<!-- BÚHO Styles -->
<link rel="stylesheet" href="https://mexinsurance--partialcpy--c.sandbox.vf.force.com/resource/[TIMESTAMP]/buhoAssets/css/buhoStyles.css">
```

## How It Works

1. **Component Loads:**
   - `connectedCallback()` fetches term options and builds `termDaysMap`
   - Sets `flags.isDateLoaded = true`

2. **Flatpickr Initializes:**
   - `renderedCallback()` detects date picker is loaded
   - Calls `initializeFlatpickr()` to attach Flatpickr to `#startDate` input
   - Flatpickr respects `flags.disableDateRange` if set

3. **User Selects Date:**
   - User clicks on start date input (if not disabled)
   - Flatpickr calendar popup appears
   - User selects a date
   - Flatpickr's `onChange` callback triggers `handleDateChange()`

4. **Date Change Event Flow:**
   - `handleDateChange()` is called with selected date and days offset
   - Start date is formatted and stored
   - End date is calculated: `startDate + termDaysOffset`
   - `inputValues` object is updated with both formats:
     - New format: `Start_Date_for_Coverage__c`, `End_Date_for_Coverage__c`
     - Legacy format: `StartDate`, `EndDate`, `DateRange`
   - `handleInputChange()` is called to update parent payload
   - `resetStartTimeIfFuture()` validates time selection
   - Both dates are displayed

5. **Term Type Changes:**
   - User clicks different term button (Daily/Semi-Annual/Annual)
   - `handleTermClick()` is triggered
   - **Updates term type:** Sets both `selectedTerm` and `termType` properties
   - **Time selection visibility:** 
     - If switching TO Daily: Shows time selection inputs, sets default times (00:00 - 23:59)
     - If switching FROM Daily: Hides time selection inputs, resets to full-day times
   - **Date recalculation:** If a start date was already selected:
     - Gets new `daysOffset` from `termDaysMap` based on selected term
     - Recalculates end date: `startDate + daysOffset`
     - Updates `dateRange` display
     - Updates all date fields in `inputValues`
   - **Flatpickr update:** 
     - `updateFlatpickr()` destroys and recreates Flatpickr instance
     - New instance uses updated term's days offset
     - Calendar reopens with new date calculation logic

## Verification Steps

### 1. Initial Load Testing

1. **Open Experience Site** and navigate to Step 3 (Term Option)
2. **Open Browser Console** (F12)
3. **Check for logs:**
   - "BTO Flatpickr initialized successfully"
   - "BTO Default dates set: {startDate, endDate, term: 'Annual', daysOffset: 365}"
   - No errors about `flatpickr is undefined`

4. **Test Initial State (Annual Selected by Default):**
   - ✅ Annual button should have "active" class
   - ✅ Time selection inputs should be **hidden** (not visible)
   - ✅ Start date field shows **today's date** (e.g., "12/17/2024")
   - ✅ End date field shows **1 year from today** (e.g., "12/17/2025")
   - ✅ Console shows default dates set for Annual term

### 2. Date Picker Testing

5. **Click Start Date field:**
   - Calendar popup should appear
   - Can select any date from today onwards
   - Current date should be highlighted

6. **Select a different date:**
   - Start date field updates to selected date
   - End date automatically recalculates (selected date + 365 days for Annual)
   - Console shows: "BTO Date changed: {startDate, endDate, dateRange}"

### 3. Term Type Change Testing

7. **Test Term Type Changes:**
   
   **A. Switch to Semi-Annual:**
   - Click "Semi-Annual" button
   - ✅ Active class moves to Semi-Annual button
   - ✅ Time selection inputs remain **hidden**
   - ✅ End date recalculates: start date + 180 days (~6 months ahead)
   - ✅ Console shows: "BTO Term selected: Semi-Annual" and "BTO Recalculated dates for new term"
   - ✅ Example: If start is 12/17/2024, end becomes ~06/15/2025
   
   **B. Switch to Daily:**
   - Click "Daily" button
   - ✅ Active class moves to Daily button
   - ✅ Time selection inputs **appear** (Start Time and End Time visible)
   - ✅ End date recalculates: start date + 1 day
   - ✅ Times default to 00:00 - 23:59
   - ✅ Console shows: "BTO Set default times for Daily term"
   - ✅ Example: If start is 12/17/2024, end becomes 12/18/2024
   
   **C. Switch back to Annual:**
   - Click "Annual" button
   - ✅ Active class moves back to Annual button
   - ✅ Time selection inputs **disappear**
   - ✅ End date recalculates: start date + 365 days
   - ✅ Console shows updated dates
   - ✅ Example: If start is 12/17/2024, end becomes 12/17/2025

### 4. Date Selection After Term Change

8. **Test Date Selection After Term Change:**
   - Change term type first (e.g., click Semi-Annual)
   - Then click start date and select a new date
   - ✅ Verify end date calculates with correct offset (180 days for Semi-Annual)
   - ✅ Console logs show correct daysOffset value

### 5. Expected Console Logs

When everything works correctly:
```
BTO Term options retrieved: [{label: "Daily", value: "Daily"}, ...]
BTO Term days map (hardcoded): {Daily: 1, Semi-Annual: 180, Annual: 365}
BTO Default dates set: {startDate: "2024-12-17", endDate: "2025-12-17", term: "Annual", daysOffset: 365}
BTO Flatpickr initialized successfully: {disabled: false, daysOffset: 365, term: "Annual", defaultDate: "2024-12-17"}
// On term change:
BTO Term selected: Semi-Annual, Previous: Annual
BTO Recalculated dates for new term: {term: "Semi-Annual", daysOffset: 180, startDate: "2024-12-17", endDate: "2025-06-15"}
```

## Troubleshooting

### "flatpickr is not defined"
- **Cause:** Flatpickr JavaScript not loaded in Community Head Markup
- **Solution:** Add `<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>` to head markup

### Calendar doesn't appear
- **Cause:** Flatpickr CSS not loaded or input has wrong class
- **Solution:** Verify CSS is loaded and input has class `flatpickr-input`

### End date not calculating
- **Cause:** Term days mapping not built correctly
- **Solution:** Check console for "BTO Term days map:" and verify data

### Date format issues
- **Cause:** Format mismatch between display and API
- **Solution:** Uses `m/d/Y` for display, converts to `YYYY-MM-DD` for API

## Benefits of This Approach

✅ **Native HTML inputs** - Flatpickr works directly without LWC wrapper complications
✅ **Better performance** - No extra LWC component overhead
✅ **Automatic calculations** - End date updates instantly
✅ **Bootstrap styled** - Consistent with rest of the UI
✅ **Responsive** - Works on mobile and desktop
✅ **Accessibility** - Native inputs with proper ARIA labels

## Technical Notes

- Flatpickr instance is stored in `this.flatpickrInstance`
- Instance is destroyed and recreated when term changes
- Uses `renderedCallback()` to ensure DOM is ready before initialization
- Checks `typeof flatpickr !== 'undefined'` before initialization
- Date calculations handle timezone properly using native Date object

## Default Behavior

**On Page Load:**
- **Default Term:** Annual (pre-selected)
- **Default Start Date:** Today's date
- **Default End Date:** Today + 1 year (365 days)
- **Time Selection:** Hidden (only shows for Daily term)

## Term Type Behavior

### Annual Term (DEFAULT)
- **Time Selection:** Visible (user can select specific start/end times)
- **Default Times:** System time (Start), End Time = Start Time + 24 hours
- **Days Offset:** +365 days (1 year)
- **Use Case:** Long-term coverage (1 year)
- **Best Value:** Offers maximum discount on premium

### Semi-Annual Term
- **Time Selection:** Visible (user can select specific start/end times)
- **Default Times:** System time (Start), End Time = Start Time + 24 hours
- **Days Offset:** +180 days (6 months)
- **Use Case:** Medium-term coverage (6 months)
- **Good Value:** Offers discount on premium

### Daily Term
- **Time Selection:** Visible (shows Start Time and End Time inputs)
- **Default Times:** 00:00 (Start Time), End Time = Start Time + 24 hours
- **Days Offset:** +1 day
- **Use Case:** Short-term coverage (1 day)
- **Higher Cost:** No multi-day discount applies

### Dynamic Updates When Term Changes

When user switches between term types:

1. **Time Selection:**
   - Time selection inputs are ALWAYS visible for all term types
   - User-selected times are preserved when switching between terms
   - User can adjust start time and end time auto-calculates (+24 hours)

2. **Date Recalculation:**
   - When term changes, end date automatically recalculates based on new offset
   - Start date remains the same
   - Examples:
     - Daily: Start date + 1 day
     - Semi-Annual: Start date + 180 days
     - Annual: Start date + 365 days

3. **Time Behavior:**
   - Start time can be changed by user
   - End time is automatically set to start time + 24 hours (same time next day)
   - Clicking anywhere on the time input opens the time picker (not just the clock icon)

## Related Files

- `buho_termOption.html` - Template with native inputs
- `buho_termOption.js` - JavaScript with Flatpickr initialization
- `buhoStyles.css` - Styling for inputs and calendar
- `TermOptionFlow.cls` - Apex class for fetching term metadata
