import { LightningElement, api, track } from 'lwc';
export default class CustomCombobox extends LightningElement {
    @api options = []; // Options passed from parent or hardcoded
    @track filteredOptions = []; // Filtered options for display
    @track showDropdown = false; // To toggle the dropdown
    @api searchValue = ''; // Tracks the current search value
    @track isValid = true; // Tracks input validity for required validation
    @api inputLabel;
    @api inputrequired;
    @api inputdisabled;
    @api name;
    @api value;

    get showAddNewOption() {
        return this.searchValue && this.filteredOptions.length === 0;
    }

    get inputClass() {
        return `search-input slds-input ${this.isValid ? '' : 'invalid'}`;
    }

    connectedCallback() {
        // Initialize filtered options with all available options
        this.filteredOptions = [...this.options];
        // this.searchValue = this.value || '';

        // Add a listener for clicks outside the combobox
        document.addEventListener('click', this.handleDocumentClick.bind(this));        
    }


    disconnectedCallback() {
        // Remove the listener when the component is destroyed
        document.removeEventListener('click', this.handleDocumentClick.bind(this));
    }

    handleDocumentClick(event) {
        const comboboxContainer = this.template.querySelector('.combobox-container');
        // Check if the click is outside the combobox container
        if (comboboxContainer && !comboboxContainer.contains(event.target)) {
            this.showDropdown = false;
        }
        
    }

    handleInputClick(event) { 
        // Stop propagation to avoid triggering handleDocumentClick
        event.stopPropagation();
        
        // Show the dropdown with all options
        this.filteredOptions = [...this.options];
        this.showDropdown = true;
    }

    handleInputChange(event) {        
        const searchKey = event.target.value.toLowerCase();
        this.searchValue = searchKey;

        // Filter options based on the search key
        this.filteredOptions = this.options.filter(option =>
            option.label.toLowerCase().includes(searchKey)
        );

        // Ensure the dropdown is visible
        this.showDropdown = true;

        // Mark input as valid if the user starts typing
        this.isValid = true;

        // Pass value to parent cmp
        const { name, value } = event.target;
        this.dispatchEvent(new CustomEvent('type', { detail: {name, value}}));
    }

    handleOptionClick(event) { 
        const selectedValue = event.target.dataset.value;
        this.searchValue = selectedValue;
        this.showDropdown = false;

        // Fire a custom event for parent component communication
        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                value: selectedValue,   // Selected value
                name: this.inputLabel,  // Input Label   
                inputName: this.name    // Input Name
            }
        }));        
    }

    handleAddNewValue() {        
        if (this.searchValue?.trim()) {
            const newOption = { label: this.searchValue, value: this.searchValue };

            // Add the new value to options and update filteredOptions
            this.options = [...this.options, newOption];
            this.filteredOptions = [...this.options];
            this.showDropdown = false;

            // Fire a custom event for parent component communication
            this.dispatchEvent(new CustomEvent('addnew', { 
                detail: {
                value: this.searchValue,   // Selected value
                label: this.inputLabel,  // Input Label   
                name: this.name    // Input Name
              }
            }));
        }
    }

    // validateInput() {
    //     // Mark the input as invalid if it's empty
    //     this.isValid = this.searchValue.trim() !== '';
    //     return this.isValid;
    // }

    validateInput() {        
        // Check if input is required and empty
        if (this.inputrequired && !this.searchValue?.trim()) {
            this.isValid = false;            
        } else { 
            this.isValid = true;
        }
        return this.isValid;
    }

    @api
    reportValidity() {
        this.validateInput();
        return this.isValid;
    }

    @api handleReset() {
       // Reset the input field and filtered options        
        this.searchValue = '';
        this.filteredOptions = [...this.options];
        this.isValid = true;
       
        this.dispatchEvent(new CustomEvent('reset',{detail: this.inputLabel}));
    }
}