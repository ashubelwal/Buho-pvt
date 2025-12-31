// // contactImporter.js
// import { LightningElement, track } from 'lwc';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { NavigationMixin } from 'lightning/navigation';
// import processCSVFile from '@salesforce/apex/ContactCSVProcessor.processCSVFile';

// export default class ContactImporter extends NavigationMixin(LightningElement) {
//     @track csvData;
//     @track headers = [];
//     @track previewRows = [];
//     @track resultIds = [];
//     @track isProcessing = false;
//     @track showResults = false;
//     @track hasError = false;
//     @track errorMessage = '';
//     @track resultCount = 0;
    
//     _fileContent;

//     get isProcessButtonDisabled() {
//         return !this.csvData;
//     }

//     handleFileChange(event) {
//         this.hasError = false;
//         this.showResults = false;
        
//         const file = event.target.files[0];
//         if (!file) return;
        
//         if (file.type !== 'text/csv' && !file.name.endsWith('.csv')) {
//             this.showError('Please select a valid CSV file.');
//             return;
//         }

//         // Read the CSV file
//         const reader = new FileReader();
//         reader.onload = () => {
//             try {
//                 this._fileContent = reader.result;
//                 this.csvData = reader.result;
//                 this.parseCSVPreview();
//             } catch (error) {
//                 this.showError('Error reading the file: ' + error.message);
//             }
//         };
//         reader.onerror = () => {
//             this.showError('Error reading the file.');
//         };
//         reader.readAsText(file);
//     }

//     parseCSVPreview() {
//         try {
//             const lines = this.csvData.split('\n');
//             if (lines.length === 0) {
//                 this.showError('The CSV file is empty.');
//                 return;
//             }

//             // Parse headers
//             this.headers = this.parseCSVLine(lines[0]);
            
//             // Parse a preview of the data (up to 5 rows)
//             this.previewRows = [];
//             const previewLimit = Math.min(lines.length - 1, 5);
//             for (let i = 1; i <= previewLimit; i++) {
//                 if (lines[i].trim()) {
//                     this.previewRows.push(this.parseCSVLine(lines[i]));
//                 }
//             }
//         } catch (error) {
//             this.showError('Error parsing CSV: ' + error.message);
//         }
//     }

//     parseCSVLine(line) {
//         const result = [];
//         let inQuotes = false;
//         let currentValue = '';

//         for (let i = 0; i < line.length; i++) {
//             const currentChar = line[i];

//             if (currentChar === '"') {
//                 inQuotes = !inQuotes;
//             } else if (currentChar === ',' && !inQuotes) {
//                 result.push(currentValue);
//                 currentValue = '';
//             } else {
//                 currentValue += currentChar;
//             }
//         }

//         result.push(currentValue); // Add the last value
//         return result;
//     }

//     handleProcessCSV() {
//         if (!this.csvData) {
//             this.showError('Please select a CSV file first.');
//             return;
//         }

//         this.isProcessing = true;
//         this.hasError = false;
//         this.showResults = false;

//         processCSVFile({ csvFileContent: this.csvData })
//             .then(result => {
//                 this.resultIds = result;
//                 this.resultCount = result.length;
//                 this.showResults = true;
//                 this.dispatchToast('Success', `Successfully processed ${result.length} contact records.`, 'success');
//             })
//             .catch(error => {
//                 this.showError(this.reduceErrors(error));
//             })
//             .finally(() => {
//                 this.isProcessing = false;
//             });
//     }

//     handleViewContacts() {
//         this[NavigationMixin.Navigate]({
//             type: 'standard__objectPage',
//             attributes: {
//                 objectApiName: 'Contact',
//                 actionName: 'list'
//             },
//             state: {
//                 filterName: 'Recent'
//             }
//         });
//     }

//     showError(message) {
//         this.hasError = true;
//         this.errorMessage = message;
//         this.dispatchToast('Error', message, 'error');
//     }

//     dispatchToast(title, message, variant) {
//         this.dispatchEvent(
//             new ShowToastEvent({
//                 title: title,
//                 message: message,
//                 variant: variant
//             })
//         );
//     }

//     // Helper method to extract error messages
//     reduceErrors(error) {
//         if (typeof error === 'string') {
//             return error;
//         }
        
//         // UI API read errors
//         if (Array.isArray(error.body) && error.body.length > 0) {
//             return error.body.map(e => e.message).join(', ');
//         }
        
//         // UI API DML, Apex and network errors
//         else if (error.body && typeof error.body.message === 'string') {
//             return error.body.message;
//         }
        
//         // JS errors
//         else if (typeof error.message === 'string') {
//             return error.message;
//         }
        
//         // Unknown error shape
//         return 'Unknown error';
//     }
// }

import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import processCSVFile from '@salesforce/apex/ContactCSVProcessor.processCSVFile';

export default class ContactImporter extends NavigationMixin(LightningElement) {
    @api recordId;
    @track fileName = '';
    @track showSpinner = false;
    @track isFileUploaded = false;
    @track fileContent;
    @track uploadDisabled = true;
    @track results = {
        success: false,
        message: '',
        recordCount: 0
    };

    // To store the list of processed contacts
    processedContactIds = [];

    // Instruction message
    get instructions() {
        return 'Select a CSV File to import Contact records. The file should contain the required columns: Last Name, First Name, Policy Number, Phone, and Email.';
    }

    // Handler for file change
    handleFileChange(event) {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            this.fileName = file.name;

            // Validate that it is a CSV file
            if (!this.fileName.endsWith('.csv')) {
                this.showToast('Error', 'Please select a valid CSV file', 'error');
                this.uploadDisabled = true;
                return;
            }

            // Read the file content
            const reader = new FileReader();
            reader.onload = () => {
                this.fileContent = reader.result;
                this.isFileUploaded = true;
                this.uploadDisabled = false;
                
                // Optional: Display a success message that the file is ready for processing
                this.showToast('File Ready', 'CSV file is ready for processing', 'info');
            };
            reader.onerror = (error) => {
                this.showToast('Error', 'Error reading the file: ' + error.message, 'error');
            };
            reader.readAsText(file);
        }
    }

    // Handler for the import button click
    handleImportClick() {
        if (!this.fileContent) {
            this.showToast('Error', 'Please select a file first', 'error');
            return;
        }

        this.showSpinner = true;
        this.results.success = false; // Reset results

        // Call Apex method to process the file
        processCSVFile({ csvFileContent: this.fileContent })
            .then(result => {
                this.processedContactIds = result;
                this.results.success = true;
                this.results.recordCount = result.length;
                this.results.message = `${result.length} contacts were successfully processed.`;
                this.showToast('Success', this.results.message, 'success');

                // Fire event to notify successful upload
                this.dispatchEvent(new CustomEvent('uploadcomplete', {
                    detail: {
                        success: true,
                        contactIds: result
                    }
                }));
            })
            .catch(error => {
                console.error('Error processing file:', error);
                this.results.success = false;
                this.results.message = this.extractErrorMessage(error);
                this.showToast('Error', this.results.message, 'error');

                // Fire error event
                this.dispatchEvent(new CustomEvent('uploadcomplete', {
                    detail: {
                        success: false,
                        error: this.results.message
                    }
                }));
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    // Helper to extract error messages from various error formats
    extractErrorMessage(error) {
        if (typeof error === 'string') {
            return error;
        }
        // UI API read errors
        else if (Array.isArray(error.body) && error.body.length > 0) {
            return error.body.map(e => e.message).join(', ');
        }
        // UI API DML, Apex and network errors
        else if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
        }
        // JS errors
        else if (typeof error.message === 'string') {
            return error.message;
        }
        // Unknown error shape
        return 'An unexpected error occurred';
    }

    // Handler to reset and start over
    handleResetClick() {
        this.fileName = '';
        this.fileContent = null;
        this.isFileUploaded = false;
        this.uploadDisabled = true;
        this.results = {
            success: false,
            message: '',
            recordCount: 0
        };
        this.processedContactIds = [];
    }

    // Method to show notifications
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}