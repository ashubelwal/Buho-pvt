import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FLATPICKR_RESOURCES from '@salesforce/resourceUrl/flatpickr';
import getTermAndDaysMetadata from '@salesforce/apex/TermOptionFlow.getTermAndDaysMetadata';

export default class Nc_datepicker extends LightningElement {
    @api inputdisabled;
    @api defaultdate;
    DEBUG_MODE = true;
    _termSelected; // Private variable for termSelected
    startDate = ''; // Start date value
    endDate = ''; // End date value
    dateRange = ''; // Concatenated date range for display
    flatpickrInstance; // Reference to the Flatpickr instance
    filteredTerms = []; // Array of filtered terms

    // Lifecycle hook that runs when the component is inserted into the DOM
    async connectedCallback() {
        await this.getTermandDays()

         // Load the Flatpickr library dynamically
        Promise.all([
            loadScript(this, FLATPICKR_RESOURCES + '/flatpickr.js'),
            loadStyle(this, FLATPICKR_RESOURCES + '/flatpickr.min.css')
        ])
            .then(() => {
                this.initializeFlatpickr(); // Initialize after loading
                this.updateFlatpickr();
            })
            .catch(error => {
                console.error('Error loading Flatpickr:', error);
            });

        this.getDatesByDateOffset({ Term: 'Daily', Day: '1' }); // Set default date range for 'Daily' term
    }

      // Setter for termSelected with logic to update the date picker
    @api
    set termSelected(value) {
        this._termSelected = value;
        this.clearDate();
        this.updateFlatpickr(); // Update Flatpickr when the term changes
    }

    // Getter for termSelected
    get termSelected() {
        return this._termSelected;
    }

    // Initialize Flatpickr instance with custom options
    initializeFlatpickr() {
        const inputElement = this.template.querySelector('lightning-input');

        if (inputElement) {
            this.flatpickrInstance = flatpickr(inputElement, this.getFlatpickrOptions());
        }
    }

    // Update the Flatpickr instance with new options
    async updateFlatpickr() {
        if (this.flatpickrInstance) {
            await this.flatpickrInstance.destroy();
        }
        this.initializeFlatpickr();
    }


    // Get start and end dates based on term offset
    getDatesByDateOffset(termSetting) {
        let start = new Date(this.defaultdate);
        let end = new Date(start);

        end.setDate(start.getDate() + parseInt(termSetting.Day, 10));

        this.dateRange = `${start.toISOString().split('T')[0]} to ${end.toISOString().split('T')[0]}`;
        if (this.DEBUG_MODE) console.log('getDatesByDateOffset: dateRange : ', this.dateRange);
        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                StartDate: start.toISOString().split('T')[0],
                EndDate: end.toISOString().split('T')[0],
                DateRange: this.dateRange
            }
        }));
    }

    // Configure Flatpickr options based on term selection
    getFlatpickrOptions() {
        const options = { 
            altFormat: "F j, Y",
            dateFormat: "Y-m-d",
            minDate: 'today',
        };
        const termSetting = this.filteredTerms.find(setting => setting.Term === this.termSelected)
        //if(this.DEBUG_MODE) console.log('getFlatpickrOptions : Term filtered: ', JSON.stringify(this.filteredTerms) + ' || Term setting: ', JSON.stringify(termSetting) + ' || Term selected: ', JSON.stringify(this.termSelected));

        if (this.DEBUG_MODE) console.log('termSetting : ', termSetting);

        if (!termSetting || ['Daily', 'Semi-Annual', 'Annual','Term_90__c','Term_30__c'].includes(termSetting.Term)) {
            this.getDatesByDateOffset(termSetting || { Term: 'Daily', Day: '1' });
        }

        if (termSetting) {
            const daysOffset = parseInt(termSetting.Day, 10);
            options.mode = 'single'; // Allow selecting only start date
            options.onChange = (selectedDates) => {
                this.handleSingleDateChange(selectedDates, daysOffset);
            };
        } else {
            options.mode = 'range'; // Allow selecting start and end dates            
            options.onChange = (selectedDates) => {
                if (selectedDates.length === 2) {
                    this.handleRangeDateChange(selectedDates);
                }
            };
        }
        
        return options;

        // if (termSetting) {
        //     const daysOffset = parseInt(termSetting.Day, 10);
        //     options.mode = 'single'; // Allow selecting only start date
        //     options.onChange = (selectedDates) => {
        //         const selectedDate = new Date(selectedDates[0]);
        //         const localDate = new Date(
        //             selectedDate.getTime() - selectedDate.getTimezoneOffset() * 60000
        //         );

        //         this.startDate = localDate.toISOString().split('T')[0];
        //         const endDate = new Date(selectedDates[0]);
        //         const localendDate = new Date(
        //             endDate.getTime() - endDate.getTimezoneOffset() * 60000
        //         );
        //         localendDate.setDate(localendDate.getDate() + daysOffset);
        //         this.endDate = localendDate.toISOString().split('T')[0];
        //         this.dateRange = `${this.startDate} to ${this.endDate}`;

        //         this.dispatchEvent(new CustomEvent('select', {
        //             detail: {
        //                 StartDate: this.startDate,   // Selected value
        //                 EndDate: this.endDate,
        //                 DateRange: this.dateRange// Input label
        //             }
        //         }));
        //     };
        // } else {
        //     options.mode = 'range'; // Allow selecting start and end dates            
        //     options.onChange = (selectedDates) => {
        //         if (selectedDates.length === 2) {
        //             const selectedDate = new Date(selectedDates[0]);
        //             const localDate = new Date(
        //                 selectedDate.getTime() - selectedDate.getTimezoneOffset() * 60000
        //             );
        //             this.startDate = localDate.toISOString().split('T')[0];
        //             const selectedendDate = new Date(selectedDates[1]);
        //             const localendDate = new Date(
        //                 selectedendDate.getTime() - selectedendDate.getTimezoneOffset() * 60000
        //             );

        //             this.endDate = localendDate.toISOString().split('T')[0];
        //             this.dateRange = `${this.startDate} to ${this.endDate}`;

        //             this.dispatchEvent(new CustomEvent('select', {
        //                 detail: {
        //                     StartDate: this.startDate,
        //                     EndDate: this.endDate,
        //                     DateRange: this.dateRange
        //                 }
        //             }));
        //         }
        //     };
        // }
        // return options;
    }

    // Handle single date selection
    handleSingleDateChange(selectedDates, daysOffset) {
        const selectedDate = this.getLocalDate(new Date(selectedDates[0]));
        this.startDate = this.formatDate(selectedDate);
        
        const endDate = new Date(selectedDate);
        endDate.setDate(endDate.getDate() + daysOffset);
        this.endDate = this.formatDate(endDate);
        
        this.updateDateRangeAndDispatch();
    }

    // Handle date range selection
    handleRangeDateChange(selectedDates) {
        const start = this.getLocalDate(new Date(selectedDates[0]));
        const end = this.getLocalDate(new Date(selectedDates[1]));
        
        this.startDate = this.formatDate(start);
        this.endDate = this.formatDate(end);
        this.updateDateRangeAndDispatch();
    }

    // Helper method to format date as YYYY-MM-DD
    formatDate(date) {
        return date.toISOString().split('T')[0];
    }

    // Helper method to adjust for timezone
    getLocalDate(date) {
        return new Date(date.getTime() - date.getTimezoneOffset() * 60000);
    }

    // Helper method to check for special terms
    isSpecialTerm(term) {
        return ['Daily', 'Semi-Annual', 'Annual'].includes(term);
    }

    // Helper method to update date range and dispatch event
    updateDateRangeAndDispatch() {
        this.dateRange = `${this.startDate} to ${this.endDate}`;
        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                StartDate: this.startDate,
                EndDate: this.endDate,
                DateRange: this.dateRange
            }
        }));
        
        if (this.DEBUG_MODE) console.log('Date range updated:', this.dateRange);
    }

    // Fetch term and days metadata from Apex
    async getTermandDays() {
        try {
            const result = await getTermAndDaysMetadata();
            if (result.Status === 'Success') {
                this.filteredTerms = result.Data;
                console.log('Filtered terms 232',this.filteredTerms);
            } else {
                console.error('Error fetching term days metadata:', result.Message);
            }
        } catch (error) {
            console.error('Unexpected error fetching term days metadata:', error);
        }
    }

      // Clear start date, end date, and date range
    clearDate() {
        this.startDate = ''; // Clear the start date
        this.endDate = ''; // Clear the end date
        this.dateRange = ''; // Clear the date range
    }
}