import { LightningElement, track, api } from 'lwc';
import getTermDaysMetadata from '@salesforce/apex/TermOptionFlow.getTermDaysMetadata';
import saveLeadPolicyTerms from '@salesforce/apex/TermOptionFlow.saveLeadPolicyTerms';
import getCalculatedTermEndTime from '@salesforce/apex/TermOptionFlow.getCalculatedTermEndTime';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import BUHO_ASSETS from '@salesforce/resourceUrl/buhoAssets';

export default class Buho_termOption extends LightningElement {
    @api payload;
    @track errorMessage = ''; // Property to store the error message
    @track DEBUG_MODE = true;
    termOption = {};
    @track startDate = '';
    @track endDate = '';
    @track defaultDate;
    @track startTime = '00:00:00.000Z';
    @track endTime = '23:59:00.000Z';
    @track dateRange = '';
    @track selectedTerm = 'Annual'; // Default to Annual
    @track userType;
    termType = 'Annual'; // Non-tracked property for internal use

    @track systemTime;
    @track displayPstTime;
    @track timeOptions = [];

    @track flags = {
        isRendered: false,
        'disableDateRange': false,
        'isLoaded': false, 
        'isDateLoaded': false, 
        'isFutureDate': false,
        'flatpickrInitialized': false
    }
    
    flatpickrInstance = null; // Store flatpickr instance for start date
    endDateFlatpickrInstance = null; // Store flatpickr instance for end date
    
    // Hardcoded term to days mapping (no days attribute in metadata)
    termDaysMap = {
        'Daily': 1,
        'Semi-Annual': 180, // 6 months
        'Annual': 365 // 1 year
    };

    @track inputValues = {
        "Gold__c": false,
        'Start_Time__c': '00:01', // Default start time (12:01 AM)
        'End_Time__c': '00:01'    // Default end time (start time + 24 hours = same clock time)
    };
    //selectedTimeSlot = ''; // Holds the selected time slot
    termType = 'Daily';

    // Options for term type
    termOptions = [];

    get currentUserType() {
        const existingIndex = this.payload.findIndex(item =>
            Object.keys(item)[0] === "UserType"
        );
        if (existingIndex != -1) {
            this.userType = "Customer";
            return true;
        }
        return false;
    }

    // Show time selection for all term types
    get showTimeSelection() {
        return true; // Always show time selection
    }

    // Check if current term is Daily
    get isDailyTerm() {
        return this.selectedTerm === 'Daily';
    }

    // End date should be disabled for Annual/Semi-Annual, enabled for Daily
    get isEndDateDisabled() {
        return !this.isDailyTerm;
    }

    // Format dates for display (MM/DD/YYYY)
    get formattedStartDate() {
        return this.formatDateForDisplay(this.startDate);
    }

    get formattedEndDate() {
        return this.formatDateForDisplay(this.endDate);
    }

    formatDateForDisplay(dateString) {
        if (!dateString) return '';
        try {
            const date = this.parseDateAsLocal(dateString);
            
            if (!date || isNaN(date.getTime())) {
                console.error('BTO Invalid date:', dateString);
                return '';
            }
            
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const year = date.getFullYear();
            return `${month}/${day}/${year}`;
        } catch (error) {
            console.error('BTO Error formatting date:', error, dateString);
            return '';
        }
    }

    // Format 24h time (HH:mm) to 12h time (hh:mm AM/PM)
    formatTimeForDisplay(timeString) {
        if (!timeString) return '';
        const [hourStr, minuteStr] = timeString.split(':');
        let hour = parseInt(hourStr, 10);
        const minute = minuteStr || '00';
        const ampm = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12 || 12;
        return `${hour}:${minute} ${ampm}`;
    }

    // Coverage summary text shown above the Continue button
    get coverageSummaryText() {
        const sDate = this.formattedStartDate;
        const eDate = this.formattedEndDate;
        const sTime = this.formatTimeForDisplay(this.inputValues.Start_Time__c);
        const eTime = this.formatTimeForDisplay(this.inputValues.End_Time__c);
        if (sDate && eDate && sTime && eTime) {
            return `Your coverage starts at ${sDate} ${sTime} and ends at ${eDate} ${eTime}`;
        }
        return '';
    }

    // Get term options with computed classes
    get termOptionsWithClass() {
        return this.termOptions.map(option => ({
            ...option,
            className: this.selectedTerm === option.value ? 'term-btn active' : 'term-btn'
        }));
    }

    // Handle term button click
    handleTermClick(event) {
        event?.preventDefault?.();
        const selectedTerm = event.target.dataset.term;
        if (selectedTerm) {
            const previousTerm = this.selectedTerm;
            this.termType = selectedTerm;
            this.selectedTerm = selectedTerm;
            this.inputValues.Term__c = selectedTerm;
            
            if (this.DEBUG_MODE) console.log('BTO Term selected:', selectedTerm, 'Previous:', previousTerm);
            
            // If a start date is already selected, handle end date based on term type
            if (this.startDate) {
                const startDate = this.parseDateAsLocal(this.startDate);
                
                // Calculate times based on whether date is today or future
                // Pass the newly selected term explicitly
                const timeCalculation = this.calculatePolicyTimes(this.startDate, selectedTerm);
                this.inputValues.Start_Time__c = timeCalculation.startTime;
                this.inputValues.End_Time__c = timeCalculation.endTime;
                this.flags.isFutureDate = timeCalculation.isFutureDate;
                
                if (selectedTerm === 'Daily') {
                    // For Daily: end date = start date + offset (minimum 1 day, end date must be > start date)
                    const endDateOffset = timeCalculation.endDateOffset || 1;
                    const endDate = new Date(startDate);
                    endDate.setDate(endDate.getDate() + endDateOffset);
                    this.endDate = this.formatDateForApi(endDate);
                } else {
                    // For Annual/Semi-Annual, auto-calculate end date based on term duration
                    const daysOffset = this.termDaysMap[selectedTerm] || 365;
                    const endDate = new Date(startDate);
                    endDate.setDate(endDate.getDate() + daysOffset);
                    this.endDate = this.formatDateForApi(endDate);
                }
                
                // Update date range display
                this.dateRange = `${this.formatDateForDisplay(this.startDate)} to ${this.formatDateForDisplay(this.endDate)}`;
                
                // Update input values
                this.inputValues = {
                    ...this.inputValues,
                    Start_Date_for_Coverage__c: this.startDate,
                    End_Date_for_Coverage__c: this.endDate,
                    StartDate: this.startDate,
                    EndDate: this.endDate,
                    DateRange: this.dateRange
                };
                
                if (this.DEBUG_MODE) console.log('BTO Recalculated dates for new term:', {
                    term: selectedTerm,
                    startDate: this.startDate,
                    endDate: this.endDate,
                    startTime: this.inputValues.Start_Time__c,
                    endTime: this.inputValues.End_Time__c,
                    isFutureDate: timeCalculation.isFutureDate
                });
            }
            
            // Update Flatpickr with new term settings
            this.updateFlatpickr();
        }
    }

    // Handle continue button click
    handleContinue() {
        if (!this.validate()) {
            return;
        }
        // Dispatch event to parent to move to next step
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    /**
     * Handle time input click to show time picker
     * This allows the time picker to open when clicking anywhere on the input, not just the icon
     */
    handleTimeInputClick(event) {
        try {
            const inputElement = event.target;
            // Check if showPicker method is available (modern browsers)
            if (inputElement && typeof inputElement.showPicker === 'function') {
                inputElement.showPicker();
            }
        } catch (error) {
            // Silently fail if showPicker is not supported
            // The user can still use the input normally
            if (this.DEBUG_MODE) console.log('BTO showPicker not supported:', error);
        }
    }

    // Fetches term options from the Apex method and updates the termOptions array.
    async getTermOptions() {
        try {
            const result = await getTermDaysMetadata();
            if (result.Status === 'Success') {
                this.termOptions = result.Data;
                if (this.DEBUG_MODE) console.log('BTO Term options retrieved:', this.termOptions);
                if (this.DEBUG_MODE) console.log('BTO Term days map (hardcoded):', this.termDaysMap);
            } else {
                console.error('BTO Error fetching term days metadata:', result.Message);
            }
        } catch (error) {
            console.error('BTO Error:', error);
        }
    }

    // Handles the event from the child component and updates relevant values.
    handleChildSelectEvent(event) {
        if (!event?.detail) return;

        const { StartDate, EndDate, DateRange } = event.detail;
        this.startDate = StartDate;
        this.endDate = EndDate;
        this.dateRange = DateRange;

        this.inputValues = { 
            ...this.inputValues, 
            StartDate, 
            EndDate, 
            DateRange,
            Start_Date_for_Coverage__c: StartDate,
            End_Date_for_Coverage__c: EndDate
        };

        if (this.DEBUG_MODE) console.log('BTO Received child event:', JSON.stringify(this.inputValues));



        // handle if not today
        this.resetStartTimeIfFuture();

    }

    /**
     * Add minutes to a time string (HH:mm format)
     * Returns {time: "HH:mm", crossesMidnight: boolean}
     */
    addMinutesToTime(timeString, minutesToAdd) {
        const [hours, minutes] = timeString.split(':').map(Number);
        let totalMinutes = hours * 60 + minutes + minutesToAdd;
        let dayOffset = 0;
        
        // Handle overflow past midnight
        while (totalMinutes >= 24 * 60) {
            totalMinutes -= 24 * 60;
            dayOffset++;
        }
        
        const newHours = Math.floor(totalMinutes / 60);
        const newMinutes = totalMinutes % 60;
        
        return {
            time: `${String(newHours).padStart(2, '0')}:${String(newMinutes).padStart(2, '0')}`,
            crossesMidnight: dayOffset > 0,
            daysToAdd: dayOffset
        };
    }

    /**
     * Calculate start and end times based on whether date is today or future
     * RULE: End time = Start time (start time + 24 hours = same clock time) for ALL policy types
     * For today: start time = system time + 30 mins
     * For future dates: start time = 00:01
     * @param {string} selectedDate - The selected date
     * @param {string} termType - The term type (Daily, Annual, Semi-Annual)
     */
    calculatePolicyTimes(selectedDate, termType = null) {
        // Use component's term type if not provided
        const currentTermType = termType || this.selectedTerm;
        
        if (!selectedDate || !this.defaultDate || !this.displayPstTime) {
            return {
                startTime: '00:01',
                endTime: '00:01', // Same as start time (+24 hours)
                isFutureDate: false,
                endDateOffset: 1
            };
        }

        const start = this.parseDateAsLocal(selectedDate);
        const today = this.parseDateAsLocal(this.defaultDate);
        
        // Reset time parts for comparison
        start.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);

        if (start > today) {
            // Future date: start at 00:01, end = same as start (+24h)
            console.log('BTO Future date selected:', start);
            return {
                startTime: '00:01',
                endTime: '00:01', // Same clock time = +24 hours
                isFutureDate: true,
                endDateOffset: 1
            };
        } else {
            // Today's date: start = system time + 30 mins, end = same as start (+24h)
            console.log('BTO Today date selected, system time:', this.displayPstTime, 'Term:', currentTermType);
            
            // Add 30 minutes to system time for start time
            const startTimeResult = this.addMinutesToTime(this.displayPstTime, 30);
            const startTime = startTimeResult.time;
            
            // End time = start time (same clock time = +24 hours) for ALL policy types
            const endTime = startTime;
            const endDateOffset = 1; // Always next day since end time = start time + 24h
            
            console.log('BTO Calculated times:', {
                systemTime: this.displayPstTime,
                termType: currentTermType,
                startTime: startTime,
                endTime: endTime,
                endDateOffset: endDateOffset
            });
            
            return {
                startTime: startTime,
                endTime: endTime,
                isFutureDate: false,
                endDateOffset: endDateOffset
            };
        }
    }

    /**
    * Resets the start time based on whether the date is today or future
    * Also adjusts end date if the 24-hour period crosses midnight
    */
    resetStartTimeIfFuture() {
        if (!this.startDate || !this.defaultDate) return null;

        const timeCalculation = this.calculatePolicyTimes(this.startDate);
        
        this.flags.isFutureDate = timeCalculation.isFutureDate;
        this.inputValues['Start_Time__c'] = timeCalculation.startTime;
        this.inputValues['End_Time__c'] = timeCalculation.endTime;
        
        // For Daily term, ensure end date is always > start date
        if (this.isDailyTerm) {
            const endDateOffset = timeCalculation.endDateOffset || 1;
            const startDateObj = this.parseDateAsLocal(this.startDate);
            const newEndDate = new Date(startDateObj);
            newEndDate.setDate(newEndDate.getDate() + endDateOffset);
            this.endDate = this.formatDateForApi(newEndDate);
            
            // Update input values
            this.inputValues.End_Date_for_Coverage__c = this.endDate;
            this.inputValues.EndDate = this.endDate;
            
            // Update date range
            this.dateRange = `${this.formatDateForDisplay(this.startDate)} to ${this.formatDateForDisplay(this.endDate)}`;
            this.inputValues.DateRange = this.dateRange;
            
            console.log('BTO End date set for Daily term:', this.endDate);
        }
        
        console.log('BTO resetStartTimeIfFuture - Final values:', {
            startDate: this.startDate,
            endDate: this.endDate,
            startTime: this.inputValues.Start_Time__c,
            endTime: this.inputValues.End_Time__c,
            isFutureDate: this.flags.isFutureDate
        });

        this.validateTimeRange(this.inputValues.Start_Time__c, this.displayPstTime)
    }


    validateTimeRange(timeValue, displayPstTime) {
        if (!timeValue || !displayPstTime) return true;

        const timeInput = this.template.querySelector('input[name="Start_Time__c"]');
        if (this.flags.isFutureDate) {
            if (timeInput) {
                timeInput.setCustomValidity('');
            }
            return true;
        }

        console.log('OUTPUT : flag is false, so that we are here', this.inputValues.Start_Time__c);

        // Extract HH and MM from both values
        const [t1Hour, t1Min] = timeValue.split(':').map(Number); // handles "HH:mm" or "HH:mm:ss"
        const [t2Hour, t2Min] = displayPstTime.split(':').map(Number);

        // Convert to minutes
        const totalMinutes1 = t1Hour * 60 + t1Min;
        const totalMinutes2 = t2Hour * 60 + t2Min;


        if (totalMinutes1 < totalMinutes2) {
            console.warn(`❌ Time too early: ${timeValue} < ${displayPstTime}`);
            if (timeInput) {
                timeInput.setCustomValidity(`Time cannot be earlier than ${displayPstTime}`);
                timeInput.reportValidity();
            }
            return false;
        } else {
            if (timeInput) {
                timeInput.setCustomValidity('');
            }
            return true;
        }
    }

    /**
     * Validates that end date+time combination is not before start date+time combination
     */
    validateStartEndTime(startTime, endTime) {
        if (!startTime || !endTime || !this.startDate || !this.endDate) return true;

        const endTimeInput = this.template.querySelector('input[name="End_Time__c"]');
        
        try {
            // Parse dates
            const startDateObj = this.parseDateAsLocal(this.startDate);
            const endDateObj = this.parseDateAsLocal(this.endDate);
            
            // Parse times and create full datetime objects
            const [startHour, startMin] = startTime.split(':').map(Number);
            const [endHour, endMin] = endTime.split(':').map(Number);
            
            // Create datetime objects combining date and time
            const startDateTime = new Date(startDateObj);
            startDateTime.setHours(startHour, startMin, 0, 0);
            
            const endDateTime = new Date(endDateObj);
            endDateTime.setHours(endHour, endMin, 0, 0);
            
            // Compare full datetime values
            if (endDateTime <= startDateTime) {
                const errorMsg = this.startDate === this.endDate 
                    ? `End time (${endTime}) cannot be earlier than or equal to start time (${startTime}) on the same day`
                    : `End date and time cannot be before or equal to start date and time`;
                    
                console.warn(`❌ ${errorMsg}`);
                if (endTimeInput) {
                    endTimeInput.setCustomValidity(errorMsg);
                    endTimeInput.reportValidity();
                }
                return false;
            }

            // Clear any previous errors
            if (endTimeInput) {
                endTimeInput.setCustomValidity('');
            }
            return true;
        } catch (error) {
            console.error('BTO Error in validateStartEndTime:', error);
            return true; // Don't block if validation fails
        }
    }


    /**
    * Handles input changes and updates the corresponding values.
    */
    async handleInputChange(event) {
        try {
            const { name, value, checked } = event.target;
            this.inputValues[name] = value || checked;

            // Handle Date Change
            if (name === 'Start_Date_for_Coverage__c') {
                if (this.DEBUG_MODE) console.log('BTO Date changed:', value);
                // Date is already updated by Flatpickr's handleDateChange
            }

            // Handle Term Change
            if (name === 'Term__c') {
                if (this.DEBUG_MODE) console.log('BTO Term changed:', value);
                this.selectedTerm = value;
                this.termType = value;
                
                // Recalculate end date if start date exists
                if (this.startDate) {
                    const startDate = this.parseDateAsLocal(this.startDate);
                    
                    // Calculate times based on whether date is today or future
                    // Pass the newly selected term explicitly
                    const timeCalculation = this.calculatePolicyTimes(this.startDate, value);
                    this.inputValues.Start_Time__c = timeCalculation.startTime;
                    this.inputValues.End_Time__c = timeCalculation.endTime;
                    this.flags.isFutureDate = timeCalculation.isFutureDate;
                    
                    if (value === 'Daily') {
                        // For Daily: end date = start date + offset (minimum 1 day, end date must be > start date)
                        const endDateOffset = timeCalculation.endDateOffset || 1;
                        const endDate = new Date(startDate);
                        endDate.setDate(endDate.getDate() + endDateOffset);
                        this.endDate = this.formatDateForApi(endDate);
                    } else {
                        // For Annual/Semi-Annual, auto-calculate end date
                        const daysOffset = this.termDaysMap[value] || 365;
                        const endDate = new Date(startDate);
                        endDate.setDate(endDate.getDate() + daysOffset);
                        this.endDate = this.formatDateForApi(endDate);
                    }
                    
                    // Update date range display
                    this.dateRange = `${this.formatDateForDisplay(this.startDate)} to ${this.formatDateForDisplay(this.endDate)}`;
                    
                    // Update input values
                    this.inputValues.Start_Date_for_Coverage__c = this.startDate;
                    this.inputValues.End_Date_for_Coverage__c = this.endDate;
                    this.inputValues.StartDate = this.startDate;
                    this.inputValues.EndDate = this.endDate;
                    this.inputValues.DateRange = this.dateRange;
                    
                    if (this.DEBUG_MODE) console.log('BTO Recalculated dates for term change:', {
                        term: value,
                        startDate: this.startDate,
                        endDate: this.endDate,
                        startTime: this.inputValues.Start_Time__c,
                        endTime: this.inputValues.End_Time__c,
                        isFutureDate: timeCalculation.isFutureDate
                    });
                }
            }

            // Handle Start Time Change — end time always = start time (+24 hours = same clock time)
            if (name === 'Start_Time__c') {
                // Auto-set end time to match start time (start + 24h = same clock time)
                this.inputValues['End_Time__c'] = value;
                
                // Update the end time input field in the UI
                const endTimeInput = this.template.querySelector('input[name="End_Time__c"]');
                if (endTimeInput) {
                    endTimeInput.value = value;
                }
                
                if (this.DEBUG_MODE) console.log('BTO Start time changed, end time auto-set:', {
                    startTime: value,
                    endTime: value
                });
            }

            if (this.DEBUG_MODE) console.log('BTO Input change:', { name, value, inputValues: this.inputValues });
        } catch (err) {
            console.error('BTO Error in handleInputChange:', err.message);
        }
    }

    /**
     * Validates policy time restrictions for today's date
     * For ALL terms (today): start time >= PST + 30 min
     * For Daily only (today): end time <= start + 24 hours
     */
    validatePolicyTimeRestrictions() {
        // Only validate if start date is today
        if (!this.startDate || !this.defaultDate) {
            return true;
        }

        const startDateObj = this.parseDateAsLocal(this.startDate);
        const todayObj = this.parseDateAsLocal(this.defaultDate);
        startDateObj.setHours(0, 0, 0, 0);
        todayObj.setHours(0, 0, 0, 0);

        // Only validate for today's date (not future dates)
        if (startDateObj > todayObj) {
            return true;
        }

        // Validate start time for ALL term types (Daily, Annual, Semi-Annual)
        // Start time must be at least PST + 30 minutes when start date is today
        if (this.inputValues.Start_Time__c && this.displayPstTime) {
            const minimumStartTime = this.addMinutesToTime(this.displayPstTime, 30).time;
            const [minHour, minMin] = minimumStartTime.split(':').map(Number);
            const [startHour, startMin] = this.inputValues.Start_Time__c.split(':').map(Number);
            
            const minTotalMinutes = minHour * 60 + minMin;
            const startTotalMinutes = startHour * 60 + startMin;

            if (startTotalMinutes < minTotalMinutes) {
                this.errorMessage = `For today's date, start time must be at least ${minimumStartTime} (current system time + 30 minutes). Please select a valid start time.`;
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Validation Error', message: this.errorMessage },
                    bubbles: true,
                    composed: true
                }));
                return false;
            }
        }

        // Validate end time ONLY for Daily policies
        // End time must not exceed start time + 24 hours
        if (this.selectedTerm === 'Daily' && this.inputValues.Start_Time__c && this.inputValues.End_Time__c) {
            const startDateObj = this.parseDateAsLocal(this.startDate);
            const endDateObj = this.parseDateAsLocal(this.endDate);
            const todayObj = this.parseDateAsLocal(this.defaultDate);
            
            // Reset time parts for date comparison
            startDateObj.setHours(0, 0, 0, 0);
            endDateObj.setHours(0, 0, 0, 0);
            todayObj.setHours(0, 0, 0, 0);
            // Calculate day difference between start and end date
            const dayDifference = Math.round((endDateObj.getTime() - startDateObj.getTime()) / (1000 * 60 * 60 * 24));
            const maxEndTime = this.addMinutesToTime(this.inputValues.Start_Time__c, 24 * 60);
            const [maxHour, maxMin] = maxEndTime.time.split(':').map(Number);
            const [endHour, endMin] = this.inputValues.End_Time__c.split(':').map(Number);
            
            const maxTotalMinutes = maxHour * 60 + maxMin;
            const endTotalMinutes = endHour * 60 + endMin;

            // If end time crosses midnight, we need to add 24 hours to compare
            let adjustedEndMinutes = endTotalMinutes;
            if (maxEndTime.daysToAdd > 0) {
                // End time should cross midnight
                if ( dayDifference === 1 && endTotalMinutes > (this.inputValues.Start_Time__c.split(':').map(Number)[0] * 60 + this.inputValues.Start_Time__c.split(':').map(Number)[1])) {
                    // End time is on same day as start but shouldn't be
                    this.errorMessage = `For Daily policies starting today, end time cannot exceed start time + 24 hours. Maximum allowed end time is ${maxEndTime.time} (next day).`;
                    this.dispatchEvent(new CustomEvent('toastevent', {
                        detail: { variant: 'error', title: 'Validation Error', message: this.errorMessage },
                        bubbles: true,
                        composed: true
                    }));
                    return false;
                }
            } else {
                // End time should be on same day
                if (endTotalMinutes > maxTotalMinutes && dayDifference === 1) {
                    this.errorMessage = `For Daily policies starting today, end time cannot exceed start time + 24 hours. Maximum allowed end time is ${maxEndTime.time}.`;
                    this.dispatchEvent(new CustomEvent('toastevent', {
                        detail: { variant: 'error', title: 'Validation Error', message: this.errorMessage },
                        bubbles: true,
                        composed: true
                    }));
                    return false;
                }
            }
        }

        return true;
    }

    /**
    * Validates the input fields and returns true if valid, false otherwise.
    */
    @api validate() {
        let allValid = true;

        // Validate that start date is selected
        if (!this.startDate || !this.endDate) {
            this.errorMessage = 'Please select start and end dates.';
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Validation Error', message: this.errorMessage },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Validate end date is not before start date
        const startDateObj = this.parseDateAsLocal(this.startDate);
        const endDateObj = this.parseDateAsLocal(this.endDate);
        if (endDateObj < startDateObj) {
            this.errorMessage = 'End date cannot be before start date.';
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Validation Error', message: this.errorMessage },
                bubbles: true,
                composed: true
            }));
            return false;
        }

        // Validate policy time restrictions
        // For all terms (today): start time >= PST + 30 min
        // For Daily only (today): end time <= start + 24 hours
        if (!this.validatePolicyTimeRestrictions()) {
            return false;
        }

        // Validate time for Daily term
        if (this.termType === 'Daily' && this.inputValues.Start_Time__c) {
            //const timeValid = this.validateTimeRange(this.inputValues.Start_Time__c, this.displayPstTime);
            const timeValid = this.validateStartEndTime(this.inputValues.Start_Time__c, this.inputValues.End_Time__c);
            if (!timeValid) {
                allValid = false;
            }
        }

        // Validate start time vs end time
        if (this.inputValues.Start_Time__c && this.inputValues.End_Time__c) {
            const timeValid = this.validateStartEndTime(this.inputValues.Start_Time__c, this.inputValues.End_Time__c);
            if (!timeValid) {
                allValid = false;
            }
        }

        // Validate required inputs
        const inputs = this.template.querySelectorAll('input[required], c-nc_datepicker');
        inputs.forEach(input => {
            if (input.checkValidity && !input.checkValidity()) {
                if (input.reportValidity) {
                    input.reportValidity();
                }
                allValid = false;
            }
        });

        if (allValid) {
            this.errorMessage = '';
            if (this.DEBUG_MODE) console.log('BTO Validation passed. Values:', JSON.stringify(this.inputValues));
        } else {
            if (this.DEBUG_MODE) console.error('BTO Validation failed.');
        }

        return allValid;
    }

    /**
    * Retrieves data and inserts term options.
    */
    @api async getData() {
        await this.insertTermOptions()
            .then((result) => {
                if (this.DEBUG_MODE) console.log('Term data saved successfully', JSON.stringify(result));
            })
            .catch((error) => {
                if (this.DEBUG_MODE) console.log('Error in saving the term data', JSON.stringify(error));
            });
        return this.inputValues;
    }

    /**
    * Adds data to input values.
    */
    async addData() {
        if (this.DEBUG_MODE) console.log('Input values', this.inputValues);
        this.inputValues = {
            ...this.inputValues,
            Start_Date_for_Coverage__c: this.startDate,
            End_Date_for_Coverage__c: this.endDate,
        }
    }

    /**
    * Checks data before processing.
    */
    async checkData() {
        return true;
    }

    getSystemTime = async () => {
        try {
            const timeData = await getTimeZone();

            if (timeData.status == 'success') {
                this.systemTime = timeData;

                this.displayPstTime = timeData.timePst;
                // Set default times: start = 00:01, end = same as start (start + 24h)
                this.inputValues['Start_Time__c'] = '00:01';
                this.inputValues['End_Time__c'] = '00:01';

                this.startDate = timeData.dPST;
                this.defaultDate = timeData.dPST;
             
            } else {
                console.error('BTO Error calling getTimeZone:', timeData);
            }
        } catch (ex) {
            console.error('BTO Error in getSystemTime:', ex.message);
        }
    }

    /**
     * Executes on component initialization.
     * 
     * TWO FLOWS:
     * 1. FIRST TIME VISIT (no termOption in payload):
     *    - startDate = today (from getSystemTime)
     *    - term = Annual
     *    - endDate = startDate + 365 days
     * 
     * 2. RETURNING VISIT (termOption exists in payload):
     *    - Restore all values from payload (startDate, endDate, term, etc.)
     */
    async connectedCallback() {
        try {
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { 
                detail: false,
                bubbles: true,
                composed: true
            }));
            if (this.DEBUG_MODE) console.log('BTO Connected. Payload:', JSON.stringify(this.payload));

            await this.getTermOptions();

            // Get system time which sets this.startDate to today's date and this.defaultDate
            await this.getSystemTime();
            
            let hasExistingData = false;
            
            // Check if payload has existing termOption data (user returning to this step)
            if (this.payload && this.payload.length > 0) {
                const termOptionData = this.payload.find((item) => item.termOption);
                if (termOptionData && termOptionData.termOption) {
                    // FLOW 2: User is returning to this step, restore their previous selections
                    this.termOption = termOptionData.termOption;
                    this.selectedTerm = this.termOption.Term__c;
                    this.termType = this.selectedTerm;
                    this.startDate = this.termOption.Start_Date_for_Coverage__c;
                    this.endDate = this.termOption.End_Date_for_Coverage__c;
                    this.dateRange = this.termOption.DateRange;
                    
                    hasExistingData = true;
                    
                    if (this.DEBUG_MODE) console.log('BTO FLOW 2: Restored from payload:', {
                        term: this.selectedTerm,
                        startDate: this.startDate,
                        endDate: this.endDate
                    });
                }
            }
            
            // FLOW 1: First time visit - set defaults
            if (!hasExistingData) {
                // Set default term to Annual
                this.selectedTerm = 'Annual';
                this.termType = 'Annual';
                
                // startDate is already set by getSystemTime() as timeData.dPST (today's date)
                // Now calculate endDate as startDate + 365 days
                const today = this.parseDateAsLocal(this.startDate);
                
                if (this.DEBUG_MODE) console.log('BTO FLOW 1: Setting defaults. Parsed startDate:', {
                    startDateString: this.startDate,
                    parsedDate: today,
                    dateIsValid: !isNaN(today.getTime())
                });
                
                // Calculate end date: today + 365 days (Annual)
                const daysOffset = this.termDaysMap[this.selectedTerm]; // 365
                const endDate = new Date(today);
                endDate.setDate(endDate.getDate() + daysOffset);
                this.endDate = this.formatDateForApi(endDate);
                
                // Update date range display
                this.dateRange = `${this.formatDateForDisplay(this.startDate)} to ${this.formatDateForDisplay(this.endDate)}`;
                
                if (this.DEBUG_MODE) console.log('BTO FLOW 1: Calculated defaults:', {
                    term: this.selectedTerm,
                    startDate: this.startDate,
                    endDate: this.endDate,
                    daysOffset: daysOffset
                });
            }
            
            // Update input values with current data (for both flows)
            this.inputValues.Start_Date_for_Coverage__c = this.startDate;
            this.inputValues.End_Date_for_Coverage__c = this.endDate;
            this.inputValues.StartDate = this.startDate;
            this.inputValues.EndDate = this.endDate;
            this.inputValues.DateRange = this.dateRange;
            this.inputValues.Term__c = this.selectedTerm;
            
            this.resetStartTimeIfFuture();

            this.flags.isLoaded = true;
            this.flags.isDateLoaded = true;
            
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { 
                detail: true,
                bubbles: true,
                composed: true
            }));
        } catch (err) {
            console.error('BTO Error in connectedCallback:', err.message);
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { 
                detail: true,
                bubbles: true,
                composed: true
            }));
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Error', message: 'Error initializing date selection' },
                bubbles: true,
                composed: true
            }));
        }
    }

    pad(num) {
        return num.toString().padStart(2, '0');
    }

    generateTimeSlots(startStr, endStr, intervalMin) {
        try {
            const [startHour, startMin] = startStr.split(':').map(Number);
            const [endHour, endMin] = endStr.split(':').map(Number);

            let hour = startHour;
            let minute = Math.ceil(startMin / intervalMin) * intervalMin;

            const options = [];

            while (hour < endHour || (hour === endHour && minute <= endMin)) {
                const hh = this.pad(hour);
                const mm = this.pad(minute);
                const label = `${hh}:${mm}`;
                const value = `${hh}:${mm}`;
                options.push({ label, value });

                minute += intervalMin;
                if (minute >= 60) {
                    minute = minute % 60;
                    hour += 1;
                }
            }

            // this.inputValues['Start_Time__c'] = ;
            this.timeOptions = options;
        } catch (err) {
            console.log('OUTPUT : message', err.message);
        }
    }


    /* Inserts term options by saving the data to Salesforce. */
    async insertTermOptions() {
        try {
            // Add necessary data into the object
            await this.addData();
            const temp = {
                ['termOption']: this.inputValues
            };

            let updatedPayload = [...this.payload];

            const existingIndex = this.payload.findIndex(item =>
                Object.keys(item)[0] === "termOption"
            );
            if (existingIndex !== -1) {
                // Update the existing item at the found index
                updatedPayload[existingIndex] = temp;
            } else {
                // Add the new vehicleDetails object
                updatedPayload.push(temp);
            }

            // Reassign the updated array back to payload
            this.payload = updatedPayload;

            if (this.DEBUG_MODE) console.log('Payload data before saving the term', this.payload);

            // Add validation if needed
            await this.checkData();

            // Save data in the backend
            //if (!this.currentUserType) {
                const result = await saveLeadPolicyTerms({ strLeadDetails: JSON.stringify(this.payload) });

                if (result.Status === 'Success') {
                    const savedTermOptions = JSON.parse(result.Data.Term_options__c);
                    if (savedTermOptions && savedTermOptions.length > 0) {
                        this.inputValues = {
                            ...this.inputValues,
                            End_Time__c: savedTermOptions[0].End_Time__c
                        };
                        if (this.DEBUG_MODE) console.log('Updated inputValues with end time from saved result:', this.inputValues);
                    }

                    return result;
                } else if (result.Status === 'Error') {
                    throw new Error(result.Message);
                }
                // need to discuss this logic with charls
            /*} else {
                // Explicitly fetch calculated End Time from Apex if no save
                const termObj = this.payload.find(p => p.termOption)?.termOption;
                if (termObj) {
                    const endTime = await getCalculatedTermEndTime({ strTermDetailsJson: JSON.stringify(termObj) });
                    this.inputValues = {
                        ...this.inputValues,
                        End_Time__c: endTime
                    };
                    if (this.DEBUG_MODE) console.log('Explicitly fetched End Time from Apex:', endTime);
                    return this.inputValues;
                }
            }*/
        } catch (error) {
            if (this.DEBUG_MODE) console.log('Error in saving the term data', error);
            throw error;
        }
    }

    /**
    * Initialize Flatpickr on the start date and end date inputs
    */
    initializeFlatpickr() {
        if (this.flags.flatpickrInitialized) return;
        
        const startDateInput = this.template.querySelector('.startDate');
        const endDateInput = this.template.querySelector('.endDate');
        console.log('flatpickr===>',window.flatpickr);
        if (!startDateInput || !endDateInput || typeof window.flatpickr === 'undefined') {
            if (this.DEBUG_MODE) console.log('BTO Flatpickr not ready yet');
            return;
        }

        try {
            // Parse dates as JavaScript Date objects
            const startDateObj = this.startDate ? this.parseDateAsLocal(this.startDate) : null;
            const endDateObj = this.endDate ? this.parseDateAsLocal(this.endDate) : null;
            const minDateObj = this.defaultDate ? this.parseDateAsLocal(this.defaultDate) : 'today';
            
            if (this.DEBUG_MODE) console.log('BTO Initializing Flatpickr with:', {
                startDateString: this.startDate,
                endDateString: this.endDate,
                startDateObj: startDateObj,
                endDateObj: endDateObj,
                minDateObj: minDateObj,
                term: this.selectedTerm,
                isDailyTerm: this.isDailyTerm
            });
            
            // Initialize Start Date Picker
            this.flatpickrInstance = window.flatpickr(startDateInput, {
                dateFormat: 'm/d/Y',
                minDate: minDateObj,
                defaultDate: startDateObj,
                disable: this.flags.disableDateRange ? [() => true] : [],
                onChange: (selectedDates, dateStr, instance) => {
                    this.handleStartDateChange(selectedDates[0]);
                }
            });

            // Initialize End Date Picker (for Daily term only)
            if (this.isDailyTerm) {
                // End date must be strictly after start date (dates <= start date are disabled)
                const minEndDate = startDateObj ? new Date(startDateObj) : new Date(minDateObj);
                minEndDate.setDate(minEndDate.getDate() + 1);

                this.endDateFlatpickrInstance = window.flatpickr(endDateInput, {
                    dateFormat: 'm/d/Y',
                    minDate: minEndDate,
                    defaultDate: endDateObj,
                    onChange: (selectedDates, dateStr, instance) => {
                        this.handleEndDateChange(selectedDates[0]);
                    }
                });
            } else {
                // For Annual/Semi-Annual, destroy end date picker if it exists
                if (this.endDateFlatpickrInstance) {
                    this.endDateFlatpickrInstance.destroy();
                    this.endDateFlatpickrInstance = null;
                }
            }

            this.flags.flatpickrInitialized = true;
            
            if (this.DEBUG_MODE) console.log('BTO Flatpickr initialized successfully');
        } catch (error) {
            console.error('BTO Error initializing Flatpickr:', error);
        }
    }

    /**
    * Handle start date change from Flatpickr
    */
    handleStartDateChange(selectedDate) {
        if (!selectedDate) return;

        // Format start date
        const startDate = new Date(selectedDate);
        this.startDate = this.formatDateForApi(startDate);

        // Calculate times based on whether date is today or future and term type
        const timeCalculation = this.calculatePolicyTimes(this.startDate);
        this.inputValues.Start_Time__c = timeCalculation.startTime;
        this.inputValues.End_Time__c = timeCalculation.endTime;
        this.flags.isFutureDate = timeCalculation.isFutureDate;

        // Calculate end date based on term type
        if (this.isDailyTerm) {
            // For Daily: end date = start date + offset (minimum 1 day, end date must be > start date)
            const endDateOffset = timeCalculation.endDateOffset || 1;
            const endDate = new Date(startDate);
            endDate.setDate(endDate.getDate() + endDateOffset);
            this.endDate = this.formatDateForApi(endDate);

            // Update end date picker: dates <= start date are disabled
            if (this.endDateFlatpickrInstance) {
                const minEndDate = new Date(startDate);
                minEndDate.setDate(minEndDate.getDate() + 1);
                this.endDateFlatpickrInstance.set('minDate', minEndDate);
                this.endDateFlatpickrInstance.setDate(this.parseDateAsLocal(this.endDate));
            }
        } else {
            // For Annual/Semi-Annual, auto-calculate end date based on term duration
            const daysOffset = this.termDaysMap[this.selectedTerm] || 365;
            const endDate = new Date(startDate);
            endDate.setDate(endDate.getDate() + daysOffset);
            this.endDate = this.formatDateForApi(endDate);
        }

        // Format for display and update input values
        this.dateRange = `${this.formatDateForDisplay(this.startDate)} to ${this.formatDateForDisplay(this.endDate)}`;

        this.inputValues = {
            ...this.inputValues,
            Start_Date_for_Coverage__c: this.startDate,
            End_Date_for_Coverage__c: this.endDate,
            StartDate: this.startDate,
            EndDate: this.endDate,
            DateRange: this.dateRange
        };

        if (this.DEBUG_MODE) console.log('BTO Start date changed:', {
            startDate: this.startDate,
            endDate: this.endDate,
            startTime: this.inputValues.Start_Time__c,
            endTime: this.inputValues.End_Time__c,
            dateRange: this.dateRange,
            isFutureDate: timeCalculation.isFutureDate
        });

        // Validate time range
        this.validateTimeRange(this.inputValues.Start_Time__c, this.displayPstTime);

        // Trigger input change event
        this.handleInputChange({
            target: {
                name: 'Start_Date_for_Coverage__c',
                value: this.startDate
            }
        });
    }

    /**
    * Handle end date change from Flatpickr (Daily term only)
    */
    handleEndDateChange(selectedDate) {
        if (!selectedDate) return;

        // Format end date
        const endDate = new Date(selectedDate);
        this.endDate = this.formatDateForApi(endDate);

        // End time remains as auto-calculated (always disabled/greyed out)
        // End time = start time + 24 hours (same clock time as start time)

        // Update date range display
        this.dateRange = `${this.formatDateForDisplay(this.startDate)} to ${this.formatDateForDisplay(this.endDate)}`;

        // Update input values
        this.inputValues = {
            ...this.inputValues,
            End_Date_for_Coverage__c: this.endDate,
            EndDate: this.endDate,
            DateRange: this.dateRange
        };

        if (this.DEBUG_MODE) console.log('BTO End date changed:', {
            startDate: this.startDate,
            endDate: this.endDate,
            startTime: this.inputValues.Start_Time__c,
            endTime: this.inputValues.End_Time__c,
            dateRange: this.dateRange
        });
    }

    /**
     * Sets the end date to the next day after the given date and end time to 00:01.
     * Also updates the UI end time input and Flatpickr instance.
     * @param {Date} baseDate - The date to add 1 day to
     */
    setEndDateToNextDay(baseDate) {
        const nextDay = new Date(baseDate);
        nextDay.setDate(nextDay.getDate() + 1);
        this.endDate = this.formatDateForApi(nextDay);
        
        // End time = start time (start + 24h = same clock time)
        const endTimeValue = this.inputValues.Start_Time__c || '00:01';
        this.inputValues.End_Time__c = endTimeValue;

        const endTimeInput = this.template.querySelector('input[name="End_Time__c"]');
        if (endTimeInput) {
            endTimeInput.value = endTimeValue;
        }

        if (this.endDateFlatpickrInstance) {
            this.endDateFlatpickrInstance.setDate(nextDay);
        }

        if (this.DEBUG_MODE) console.log('BTO End date set to next day, end time matches start time:', this.endDate, endTimeValue);
    }

    /**
    * Parse date string as local date to avoid timezone issues
    * @param {string} dateString - Date in YYYY-MM-DD format
    * @returns {Date} - JavaScript Date object
    */
    parseDateAsLocal(dateString) {
        if (!dateString) return null;
        if (typeof dateString === 'string' && dateString.includes('-')) {
            const [year, month, day] = dateString.split('-').map(num => parseInt(num, 10));
            return new Date(year, month - 1, day); // month is 0-indexed
        }
        return new Date(dateString);
    }

    /**
    * Format date for API (YYYY-MM-DD)
    */
    formatDateForApi(date) {
        if (!date) return '';
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    /**
    * Destroy and recreate Flatpickr with new settings
    */
    updateFlatpickr() {
        if (this.flatpickrInstance) {
            this.flatpickrInstance.destroy();
            this.flatpickrInstance = null;
        }
        
        if (this.endDateFlatpickrInstance) {
            this.endDateFlatpickrInstance.destroy();
            this.endDateFlatpickrInstance = null;
        }
        
        this.flags.flatpickrInitialized = false;
        
        // Reinitialize after a short delay
        setTimeout(() => {
            this.initializeFlatpickr();
        }, 100);
    }

    /**
    * Executes after the component renders.
    */
    renderedCallback() {
        // Initialize Flatpickr if not already done
        if (this.flags.isDateLoaded && !this.flags.flatpickrInitialized) {
            Promise.all([
                loadScript(this, BUHO_ASSETS + '/js/flatpickr.js')
            ])
            .then(() => {
                console.log('script loaded initializing js');
                this.initializeFlatpickr();
            })
            .catch(error => {
                console.error('Flatpickr failed to load', error);
            });
            
        }

        // Populate input fields from termOption data (if returning to step)
        if (this.termOption && Object.keys(this.termOption).length > 0 && !this.flags.isRendered) {
            this.populateInputFields();
            this.flags.isRendered = true;
        }
        
    }

    /**
    * Populates input fields with existing values from termOption.
    * This is called when user navigates back to this step.
    */
    populateInputFields() {
        try {
            // Get all input elements (both native HTML and Lightning Web Components)
            const inputs = this.template.querySelectorAll(
                'lightning-input, lightning-checkbox-group, lightning-radio-group, lightning-combobox, ' +
                'input[type="text"], input[type="time"], input[type="radio"], input[type="checkbox"]'
            );
            
            if (this.DEBUG_MODE) console.log('BTO populateInputFields - Found inputs:', inputs.length);
            
            inputs.forEach((input) => {
                const fieldName = input.name;
                const fieldValue = this.termOption[fieldName];
                
                if (fieldValue !== undefined) {
                    if (input.type === 'checkbox') {
                        input.checked = fieldValue;
                    } else if (input.type === 'radio') {
                        this.template.querySelector(`input[name="${fieldName}"][value="${fieldValue}"]`)?.setAttribute('checked', true);
                    } else if (input.localName === 'lightning-checkbox-group' || input.localName === 'lightning-radio-group') {
                        input.value = Array.isArray(fieldValue) ? fieldValue : fieldValue;
                    } else if (input.type === 'text' || input.type === 'time') {
                        // Handle native HTML inputs (dates, times)
                        if (fieldName === 'Start_Date_for_Coverage__c') {
                            // Date is already set in connectedCallback, Flatpickr will handle display
                            input.value = this.formatDateForDisplay(fieldValue);
                        } else if (fieldName === 'End_Date_for_Coverage__c') {
                            input.value = this.formatDateForDisplay(fieldValue);
                        } else if (fieldName === 'Start_Time__c' || fieldName === 'End_Time__c') {
                            this.inputValues[fieldName] = fieldValue;
                            input.value = fieldValue;
                        } else {
                            input.value = fieldValue;
                        }
                    } else {
                        // Default: set value for other input types
                        if (fieldName === 'Start_Time__c') {
                            this.inputValues['Start_Time__c'] = fieldValue;
                        } else {
                            input.value = fieldValue;
                        }
                    }

                    // Update selectedTerm if Term__c is being populated
                    if (fieldName === 'Term__c') {
                        this.selectedTerm = fieldValue;
                        this.termType = fieldValue;
                    }
                    
                    if (this.DEBUG_MODE) console.log('BTO Populated field:', fieldName, '=', fieldValue);
                }
            });
        } catch (err) {
            console.error('BTO Error in populateInputFields:', err.message);
        }
    }
}