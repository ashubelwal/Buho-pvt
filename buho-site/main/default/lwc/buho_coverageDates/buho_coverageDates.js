import { LightningElement, track, api } from 'lwc';

export default class Buho_coverageDates extends LightningElement {
    @api payload;
    
    @track inputValues = {
        Term__c: 'daily',
        Start_Date__c: '',
        End_Date__c: '',
        Start_Time__c: '',
        End_Time__c: '',
        dateRange: ''
    };

    isDebug = true;

    // Get minimum date (today)
    get minDate() {
        return new Date().toISOString().split('T')[0];
    }

    // Show time selection for daily term
    get showTimeSelection() {
        return this.inputValues.Term__c === 'daily';
    }

    // Button classes based on selected term
    get dailyBtnClass() {
        return this.inputValues.Term__c === 'daily' ? 'term-btn active' : 'term-btn';
    }

    get semiAnnualBtnClass() {
        return this.inputValues.Term__c === 'semi-annual' ? 'term-btn active' : 'term-btn';
    }

    get annualBtnClass() {
        return this.inputValues.Term__c === 'annual' ? 'term-btn active' : 'term-btn';
    }

    // Handle term type change
    handleTermChange(event) {
        const term = event.target.dataset.term;
        this.inputValues = { ...this.inputValues, Term__c: term };
        
        // Update end date based on term
        if (this.inputValues.Start_Date__c) {
            this.updateEndDate(this.inputValues.Start_Date__c, term);
        }
        
        if (this.isDebug) console.log('BCD Term changed:', term);
    }

    // Handle start date change
    handleStartDateChange(event) {
        const startDate = event.target.value;
        this.inputValues = { ...this.inputValues, Start_Date__c: startDate };
        
        // Auto-calculate end date based on term
        this.updateEndDate(startDate, this.inputValues.Term__c);
        
        if (this.isDebug) console.log('BCD Start date changed:', startDate);
    }

    // Update end date based on start date and term
    updateEndDate(startDateStr, term) {
        if (!startDateStr) return;

        const startDate = new Date(startDateStr);
        let endDate = new Date(startDate);

        switch (term) {
            case 'daily':
                endDate.setDate(endDate.getDate() + 1);
                break;
            case 'semi-annual':
                endDate.setMonth(endDate.getMonth() + 6);
                break;
            case 'annual':
                endDate.setFullYear(endDate.getFullYear() + 1);
                break;
            default:
                endDate.setDate(endDate.getDate() + 1);
        }

        const endDateStr = endDate.toISOString().split('T')[0];
        this.inputValues = { ...this.inputValues, End_Date__c: endDateStr };

        // Update the end date input
        const endDateInput = this.template.querySelector('#endDate');
        if (endDateInput) {
            endDateInput.value = endDateStr;
        }

        // Update date range display
        this.inputValues.dateRange = `${this.formatDate(startDateStr)} - ${this.formatDate(endDateStr)}`;
        
        if (this.isDebug) console.log('BCD End date updated:', endDateStr);
    }

    // Format date for display
    formatDate(dateStr) {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    }

    // Handle input changes
    handleInputChange(event) {
        const { name, value } = event.target;
        this.inputValues = { ...this.inputValues, [name]: value };
        if (this.isDebug) console.log('BCD Input changed:', name, value);
    }

    // Handle continue button
    handleContinue() {
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    // Show toast message
    showToast(variant, title, message) {
        this.dispatchEvent(new CustomEvent('toastevent', {
            detail: { variant, title, message },
            bubbles: true,
            composed: true
        }));
    }

    // Validation method - called by parent
    @api validate() {
        let allValid = true;

        const startDate = this.inputValues.Start_Date__c;
        const endDate = this.inputValues.End_Date__c;

        // Check required fields
        if (!startDate || !endDate) {
            this.showToast('error', 'Validation Error', 'Please select start and end dates.');
            allValid = false;
        }

        // Validate date logic
        if (startDate && endDate) {
            const start = new Date(startDate);
            const end = new Date(endDate);
            if (end <= start) {
                this.showToast('error', 'Validation Error', 'End date must be after start date.');
                allValid = false;
            }
        }

        // Mark invalid fields
        const startInput = this.template.querySelector('#startDate');
        const endInput = this.template.querySelector('#endDate');
        
        if (!startDate && startInput) {
            startInput.classList.add('is-invalid');
        } else if (startInput) {
            startInput.classList.remove('is-invalid');
        }

        if (!endDate && endInput) {
            endInput.classList.add('is-invalid');
        } else if (endInput) {
            endInput.classList.remove('is-invalid');
        }

        if (this.isDebug) console.log('BCD Validation result:', allValid, this.inputValues);
        return allValid;
    }

    // Get data method - called by parent
    @api async getData() {
        // Update date range
        if (this.inputValues.Start_Date__c && this.inputValues.End_Date__c) {
            this.inputValues.dateRange = `${this.formatDate(this.inputValues.Start_Date__c)} - ${this.formatDate(this.inputValues.End_Date__c)}`;
        }
        
        if (this.isDebug) console.log('BCD getData:', JSON.stringify(this.inputValues));
        return this.inputValues;
    }

    // Lifecycle: component connected
    connectedCallback() {
        if (this.isDebug) console.log('BCD Connected, payload:', JSON.stringify(this.payload));
        
        // Set default start date to today
        if (!this.inputValues.Start_Date__c) {
            this.inputValues.Start_Date__c = this.minDate;
            this.updateEndDate(this.minDate, this.inputValues.Term__c);
        }
    }

    // Lifecycle: component rendered
    renderedCallback() {
        // Populate fields from payload if available
        if (this.payload && this.payload.length > 0) {
            const termData = this.payload.find(item => item.termOption || item.coverageDates);
            if (termData) {
                const data = termData.termOption || termData.coverageDates;
                this.inputValues = { ...this.inputValues, ...data };
            }
        }
    }
}

