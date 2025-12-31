import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processCSVFile from '@salesforce/apex/DairylandCSVProcessor.processCSVFile';

export default class DairylandFileUploader extends LightningElement {
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

    // To store the list of processed leads
    processedLeadIds = [];

    // Instruction message
    get instructions() {
        return 'Select the CSV File of Dairyland Insurance to import Leads.';
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

        // Call Apex method to process the file
        processCSVFile({ csvFileContent: this.fileContent })
            .then(result => {
                this.processedLeadIds = result;
                this.results.success = true;
                this.results.recordCount = result.length;
                this.results.message = `${result.length} leads were successfully processed.`;
                this.showToast('Success', this.results.message, 'success');

                // Fire event to notify successful upload
                this.dispatchEvent(new CustomEvent('uploadcomplete', {
                    detail: {
                        success: true,
                        leadIds: result
                    }
                }));
            })
            .catch(error => {
                console.error('Error processing file:', error);
                this.results.success = false;
                this.results.message = 'Error processing the file: ' + (error.body ? error.body.message : error.message);
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
        this.processedLeadIds = [];
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