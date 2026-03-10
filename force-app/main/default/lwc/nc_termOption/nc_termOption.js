import { LightningElement, track, api } from 'lwc';
import getTermDaysMetadata from '@salesforce/apex/TermOptionFlow.getTermDaysMetadata';
import saveLeadPolicyTerms from '@salesforce/apex/TermOptionFlow.saveLeadPolicyTerms';
import getCalculatedTermEndTime from '@salesforce/apex/TermOptionFlow.getCalculatedTermEndTime';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nc_termOption extends LightningElement {
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
    @track selectedTerm = '';
    @track userType;

    @track systemTime;
    @track displayPstTime;
    @track timeOptions = [];

    @track flags = {
        isRendered: false,
        'disableDateRange': false,
        'isLoaded': false, 'isDateLoaded': false, 'isFutureDate': false
    }

    @track inputValues = {
        "Gold__c": false,
        'Start_Time__c': '00:00:00.000Z'
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

    // GFetches term options from the Apex method and updates the termOptions array.
    async getTermOptions() {
        try {
            const result = await getTermDaysMetadata();
            if (result.Status === 'Success') {
                this.termOptions = result.Data;
                if (this.DEBUG_MODE) console.log('Term is retrieved:', this.termOptions);
            } else {
                console.error('Error fetching term days metadata:', result.Message);
            }
        } catch (error) {
            console.error('Error:', error);
        }
    }

    // Handles the event from the child component and updates relevant values.
    handleChildSelectEvent(event) {
        if (!event?.detail) return;

        const { StartDate, EndDate, DateRange } = event.detail;
        this.startDate = StartDate;
        this.endDate = EndDate;
        this.dateRange = DateRange;

        this.inputValues = { ...this.inputValues, StartDate, EndDate, DateRange };
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
     * Parse date string as local date to avoid timezone issues
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
     * Calculate start time based on whether date is today or future
     * For today: start time = system time + 30 mins
     * For future: start time = 00:01
     */
    calculatePolicyTimes(selectedDate) {
        if (!selectedDate || !this.defaultDate || !this.displayPstTime) {
            return {
                startTime: '00:01',
                isFutureDate: false
            };
        }

        const start = this.parseDateAsLocal(selectedDate);
        const today = this.parseDateAsLocal(this.defaultDate);
        
        // Reset time parts for comparison
        start.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);

        if (start > today) {
            // Future date: use default time
            console.log('NC_TO Future date selected:', start);
            return {
                startTime: '00:01',
                isFutureDate: true
            };
        } else {
            // Today's date: calculate based on system time
            console.log('NC_TO Today date selected, system time:', this.displayPstTime);
            
            // Add 30 minutes to system time for start time
            const startTimeResult = this.addMinutesToTime(this.displayPstTime, 30);
            const startTime = startTimeResult.time;
            
            console.log('NC_TO Calculated start time:', {
                systemTime: this.displayPstTime,
                startTime: startTime
            });
            
            return {
                startTime: startTime,
                isFutureDate: false
            };
        }
    }

    /**
    * Resets the start time based on whether the date is today or future
    */
    resetStartTimeIfFuture() {
        if (!this.startDate || !this.defaultDate) return null;

        const timeCalculation = this.calculatePolicyTimes(this.startDate);
        
        this.flags.isFutureDate = timeCalculation.isFutureDate;
        this.inputValues['Start_Time__c'] = timeCalculation.startTime;
        
        console.log('NC_TO resetStartTimeIfFuture - Final values:', {
            startDate: this.startDate,
            endDate: this.endDate,
            startTime: this.inputValues.Start_Time__c,
            isFutureDate: this.flags.isFutureDate
        });

        this.validateTimeRange(this.inputValues.Start_Time__c, this.displayPstTime)
    }

    validateTimeRange(timeValue, displayPstTime) {
        if (!timeValue || !displayPstTime) return true;

        const timeInput = this.template.querySelector('[data-id="start-time"]');        
        if(this.flags.isFutureDate ) {
            if(timeInput) {
                timeInput.classList.remove('slds-has-error'); // Remove error styling if valid
                timeInput.setCustomValidity('');
                timeInput.reportValidity();
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
                timeInput.classList.add('slds-has-error');
                timeInput.setCustomValidity(`Time cannot be earlier than ${displayPstTime}`);
                timeInput.reportValidity();
            }
            return false;
        } else {
            if (timeInput) {                
                timeInput.classList.remove('slds-has-error'); // Remove error styling if valid
                timeInput.setCustomValidity('');
                timeInput.reportValidity();
            }
            return true;
        }
    }


    /**
    * Handles input changes and updates the corresponding values.
    */
    async handleInputChange(event) {
        try {
            const { name, value, checked } = event.target;
            this.inputValues[name] = value || checked;

            if(name === 'Start_Date_for_Coverage__c') {
                console.log('OUTPUT : date changed ');
            }

            if (name === 'Term__c') {
                //if (this.DEBUG_MODE) console.log('OUTPUT12 : ', value);
                this.flags.isDateLoaded = false;
            }

            if (name === 'Start_Time__c') {                
                this.validateTimeRange(value, this.displayPstTime);
            }

            //if (this.DEBUG_MODE) console.log('Name : ', name + ' Value: ', value + ' Checked: ', checked);

            if (this.inputValues.Term__c != ' ') {
                // this.flags.disableDateRange = (name === 'Term__c' && value == '') ? true : false;
                this.selectedTerm = name === 'Term__c' ? value : this.selectedTerm;
            }

            this.flags.isDateLoaded = true;

            if (this.DEBUG_MODE) console.log('on change : ', JSON.stringify(this.inputValues));
        } catch (err) {
            if (this.DEBUG_MODE) console.log('OUTPUT : ', err.message);
        }
    }

    /**
    * Validates the input fields and returns true if valid, false otherwise.
    */
    @api validate() {
        const inputs = this.template.querySelectorAll('lightning-input, c-nc_datepicker, lightning-checkbox-group, lightning-radio-group, lightning-combobox, input[type="radio"]');
        const values = {};
        let allValid = true;

        // Check if start date equals end date
        if (this.startDate === this.endDate) {
            this.errorMessage = 'Start date and end date cannot be the same. Please select a valid date range.';
            return false; // Prevent proceeding
        } else {
            this.errorMessage = ''; // Clear the error message if validation passes
        }

        inputs.forEach(input => {
            const { required, value, name, type } = input;

            // Handle validation for required fields
            if (required && !input.checkValidity()) {
                input.classList.add('slds-has-error'); // Add error styling
                input.reportValidity(); // Show validation message
                allValid = false;
            } else {
                input.classList.remove('slds-has-error'); // Remove error styling if valid
                let inputValue; // Capture values based on type
                if (type === 'checkbox') {
                    inputValue = input.checked; // Checkbox value
                } else if (type === 'radio') {
                    inputValue = input.value; // Selected radio value
                } else if (type === 'combobox') {
                    inputValue = input.value; // Selected combobox value
                } else {
                    inputValue = value; // For text, email, etc.
                }
                values[name] = inputValue; // Add to value
            }

            if (name === 'Start_time__c') {
                this.validateTimeRange(value, this.displayPstTime);
            }
        });

        if (allValid) {
            this.inputValues = values; // Update with valid values
            if (this.DEBUG_MODE) console.log('Term Option : Captured values:', JSON.stringify(this.inputValues));
        } else {
            if (this.DEBUG_MODE) console.log('Error getting: ');
            if (this.DEBUG_MODE) console.error('Term Option : Some required fields are invalid. Please fix the errors and try again.');
            return false;
        }

        return true; // Valid if fields are filled
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
                
                this.startDate = timeData.dPST;
                this.defaultDate = timeData.dPST;
                
                // Calculate start time based on policy time logic (system time + 30 mins)
                const timeCalculation = this.calculatePolicyTimes(this.startDate);
                this.inputValues['Start_Time__c'] = timeCalculation.startTime;
                this.flags.isFutureDate = timeCalculation.isFutureDate;
                
                console.log('NC_TO getSystemTime - Initialized with:', {
                    systemTime: this.displayPstTime,
                    startTime: this.inputValues['Start_Time__c'],
                    isFutureDate: this.flags.isFutureDate
                });
            } else {
                console.log('OUTPUT : Getting error while calling getTimeZone');
            }
        } catch (ex) {
            console.log('error occur in get system time : ' + ex.message);
        }
    }

    /* Executes on component initialization. */
    async connectedCallback() {
        try{
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
            if (this.DEBUG_MODE) console.log('term option - OUTPUT : ', JSON.stringify(this.payload));
            
            await this.getTermOptions();
            
            // const result = await getTimeZone();
            // this.generateTimeSlots(result.nextMin, '23:45:00', 15);

            // const timeData = await getTimeZone();
            await this.getSystemTime();
            this.resetStartTimeIfFuture();


            this.flags.isLoaded = true;
            this.flags.isDateLoaded = true;
            this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
            // if (this.DEBUG_MODE) console.log('timeDat a : ', timeData);
        } catch(err) {
            console.log('Error : connectedcallback', err.message);
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
            if (!this.currentUserType) {
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
            } else {
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
            }
        } catch (error) {
            if (this.DEBUG_MODE) console.log('Error in saving the term data', error);
            throw error;
        }
    }

    /**
    * Executes after the component renders.
    */
    renderedCallback() {
        // Populate input fields when the component loads or updates 

        if (this.payload && this.payload.length > 0) {
            const termOptionData = this.payload.find((item) => item.termOption);
            if (termOptionData && !this.flags.isRendered) {
                this.termOption = termOptionData.termOption;
                this.populateInputFields();
            }
        }
    }

    /**
    * Populates input fields with existing values.
    */
    populateInputFields() {        
        // Get all input elements and set their values        
        try {
            const inputs = this.template.querySelectorAll( 'lightning-input, lightning-checkbox-group, lightning-radio-group, lightning-combobox, input[type="radio"]' );
            console.log('OUTPUT : inputs ', inputs);
            inputs.forEach((input) => {
                const fieldName = input.name;
                const fieldValue = this.termOption[fieldName];
                if (this.DEBUG_MODE) console.log('In the populate: ', fieldName + " | " + fieldValue + " | " + input.localName);

                if (fieldValue !== undefined) {
                    if (input.type === 'checkbox') {
                        input.checked = fieldValue; 
                    } else if (input.type === 'radio') {
                        this.template.querySelector(`input[name="${fieldName}"][value="${fieldValue}"]`)?.setAttribute('checked', true); 
                    } else if (input.localName === 'lightning-checkbox-group' || input.localName === 'lightning-radio-group') {
                        input.value = Array.isArray(fieldValue) ? fieldValue : fieldValue;
                        // if (this.DEBUG_MODE) console.log('123: ', JSON.stringify(input.value));                        
                    } else {                        
                        if(fieldName === 'Start_Time__c') {
                            this.inputValues['Start_Time__c'] = fieldValue;
                        } else {
                            input.value = fieldValue; 
                        }
                    }

                    if(fieldName === 'Term__c') {
                        // this.inputValues['Start_Time__c']
                        this.selectedTerm = fieldValue;
                    }
                }

                this.flags.isRendered = true;
            });
        } catch (err) {
            if (this.DEBUG_MODE) console.log('Error in populateInputFields : ', err.message);
        }
    }
}