import { LightningElement, api, track } from 'lwc';

export default class Buho_input extends LightningElement {
    @api label = '';
    @api type = 'input'; // input, combobox, checkbox, radio, textarea
    @api name = '';
    @api set value(val) {
        this.inputValue =
            val === undefined || val === null || val === 'undefined'
                ? ''
                : val;
    };

    get value() {
        return this.inputValue;
    };
    @api placeholder = '';
    @api inputType = 'text'; // text, password, time, date, email, etc.
    @api options = []; // for combobox
    @api icon = ''; // bootstrap icon class (e.g., 'bi-clock')
    @api disabled = false;
    @api checked = false; // for checkbox/radio
    @api inputClass = 'form-control'; // default class for input
    @api dropdownClass = 'coverage-dropdown'; // default class for combobox
    @api containerClass = ''; // custom class for wrapper container
    @api labelClass = ''; // custom class for label
    @api labelTitleClass = 'checkbox-title'; // custom class for label title
    @api hint;
    @api maxLength; // maximum length for input
    @api pattern; // regex pattern for validation
    @api messageWhenPatternMismatch = ''; // error message when pattern doesn't match
    @api textareaStyle = ''; // custom style for textarea (e.g., "height: 180px;")
    @api required = false; // whether the field is required
    @api tooltipText = ''; // tooltip text to display on hover of info icon

    @track _isDropdownOpen = false;
    @track _searchTerm = '';
    _isTyping = false;

    @track inputValue;

    showPatternError = false;

    get computedContainerClass() {
        return `${this.containerClass}`;
    } 
    
    get computedLabelClass() {
        return `${this.labelClass}`;
    }

    get computedLabelTitleClass() {
        return `${this.labelTitleClass}`;
    }

    get computedInputClass() {
        return `default_input ${this.inputClass}`;
    }

    get computedDropdownClass() {
        return `default_dropdown ${this.dropdownClass}`;
    }

    get isInput() {
        return this.type === 'input';
    }

    get isCombobox() {
        return this.type === 'combobox';
    }

    get isSearchableCombobox() {
        return this.type === 'searchable_combobox';
    }

    get isCheckbox() {
        return this.type === 'checkbox';
    }

    get isRadio() {
        return this.type === 'radio';
    }

    get isTextarea() {
        return this.type === 'textarea';
    }

    get hasIcon() {
        return this.icon && this.isInput;
    }

    get hasTooltip() {
        return this.tooltipText && this.tooltipText.trim() !== '';
    }

    get computedInputClass() {
        return this.inputClass;
    }

    get computedDropdownClass() {
        return this.dropdownClass;
    }

    get comboboxOptions() {
        const mappedOptions = this.options?.map(option => {
            if (typeof option === 'string') {
                return {
                    label: option,
                    value: option,
                    isSelected: option === this.inputValue
                };
            }
            return {
                label: option.label || option.value,
                value: option.value,
                isSelected: option.value === this.inputValue
            };
        }) || [];

        // Add blank option at the beginning if no value is pre-selected
        // This forces users to actively select an option
        const hasValue = this.inputValue !== null && this.inputValue !== undefined && this.inputValue !== '';
        if (!hasValue && mappedOptions.length > 0) {
            return [
                { label: '-- Select --', value: '', isSelected: true },
                ...mappedOptions
            ];
        }

        return mappedOptions;
    }

    get searchInputValue() {
        if (this._isDropdownOpen) {
            return this._searchTerm;
        }
        // When closed, show the label of the selected value
        const selectedOpt = this.comboboxOptions.find(opt => opt.value === this.inputValue);
        return selectedOpt ? selectedOpt.label : '';
    }

    get filteredOptions() {
        let options = this.comboboxOptions;
        
        if (this._searchTerm && this._isDropdownOpen && this._isTyping) {
            const lowerSearch = this._searchTerm.toLowerCase();
            options = options.filter(opt => 
                opt.label && opt.label.toLowerCase().includes(lowerSearch)
            );
        }
        
        return options.map(opt => ({
            ...opt,
            listItemClass: `dropdown-list-item ${opt.isSelected ? 'selected' : ''}`
        }));
    }

    get noOptionsFound() {
        return this.filteredOptions.length === 0;
    }

    openDropdown() {
        this._isDropdownOpen = true;
        this._isTyping = false;
        const selectedOpt = this.comboboxOptions.find(opt => opt.value === this.inputValue);
        this._searchTerm = selectedOpt && selectedOpt.value !== '' ? selectedOpt.label : '';
    }

    handleBlur() {
        // Delay closing to allow mousedown on option to fire first
        setTimeout(() => {
            this._isDropdownOpen = false;
        }, 200);
    }

    handleNativeBlur() {
        this.dispatchEvent(new CustomEvent('blur'));
    }

    handleSearch(event) {
        this._searchTerm = event.target.value;
        this._isTyping = true;
        this._isDropdownOpen = true;
    }

    handleSelectOption(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.inputValue = selectedValue;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                name: this.name,
                value: selectedValue,
                type: this.type
            }
        }));
        this._isDropdownOpen = false;
    }

    handleInvalid(event) {
        if (this.pattern && this.messageWhenPatternMismatch) {
            const input = event.target;
            if (!input.validity.valid && input.validity.patternMismatch) {
                this.showPatternError = true;
            } else {
                this.showPatternError = false;
            }
        }
    }

    handleInputChange(event) {
        event.stopPropagation();
        const value = event.target.value;
        this.inputValue = value;
        
        // Validate pattern if provided
        if (this.pattern && this.messageWhenPatternMismatch) {
            const regex = new RegExp(this.pattern);
            // Only show error if there's a value and it doesn't match
            if (value && value.trim() !== '' && !regex.test(value)) {
                this.showPatternError = true;
            } else {
                this.showPatternError = false;
            }
        }
        
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                name: this.name,
                value: value,
                type: this.type
            }
        }));
    }

    handleComboboxChange(event) {
        event.stopPropagation();
        const value = event.target.value;
        this.inputValue = value;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                name: this.name,
                value: value,
                type: this.type
            }
        }));
        
    }

    renderedCallback() {
        if (this.isCombobox) {
            const selectEl = this.template.querySelector('select');
            if (selectEl && selectEl.value !== this.inputValue) {
                selectEl.value = this.inputValue || '';
            }
        }
    }

    handleCheckboxChange(event) {
        event.stopPropagation();
        const checked = event.target.checked;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                name: this.name,
                checked: checked,
                value: checked,
                type: this.type
            }
        }));
    }

    handleKeyUp(event) {
        event.stopPropagation();
        this.dispatchEvent(new CustomEvent('keyup', {
            detail: {
                name: this.name,
                value: event.target.value,
                key: event.key,
                type: this.type
            }
        }));
    }

    handleInput(event) {
        event.stopPropagation();
        const value = event.target.value;
        
        // Validate pattern on input if provided
        if (this.pattern && this.messageWhenPatternMismatch) {
            const regex = new RegExp(this.pattern);
            // Only show error if there's a value and it doesn't match
            if (value && value.trim() !== '' && !regex.test(value)) {
                this.showPatternError = true;
            } else {
                this.showPatternError = false;
            }
        }
        const inputevent = new CustomEvent('input', {
            detail: {
                name: this.name,
                value: value,
                type: this.type,
                hasError: this.showPatternError
            }
        })
        this.dispatchEvent(inputevent);
        this.inputValue = value;
    }

    /**
     * @api reportValidity()
     * Validates the input field and reports validity
     * Returns true if valid, false otherwise
     */
    @api
    reportValidity() {
        let inputElement;
        if(this.showPatternError == true) {
            return false;
        }
        
        // Get the appropriate input element based on type
        if (this.isInput || this.isTextarea) {
            inputElement = this.template.querySelector('input, textarea');
        } else if (this.isCombobox) {
            inputElement = this.template.querySelector('select');
        } else if (this.isSearchableCombobox) {
            inputElement = this.template.querySelector('.searchable-input-wrapper input');
        } else if (this.isCheckbox || this.isRadio) {
            inputElement = this.template.querySelector('input[type="checkbox"], input[type="radio"]');
        }

        if (inputElement) {
            // Check native HTML5 validation
            let isValid = inputElement.reportValidity();
            console.log(inputElement,'html 5 validation@@@',isValid);
            
            if (this.isSearchableCombobox && this.required) {
                if (!this.inputValue) {
                    inputElement.setCustomValidity('Please select an option.');
                    inputElement.reportValidity();
                    return false;
                } else {
                    inputElement.setCustomValidity('');
                    isValid = true;
                }
            }
            // Additional pattern validation for custom error messages
            if (this.pattern && this.messageWhenPatternMismatch) {
                const regex = new RegExp(this.pattern);
                const value = inputElement.value;
                if (value && value.trim() !== '' && !regex.test(value)) {
                    this.showPatternError = true;
                    inputElement.setCustomValidity(this.messageWhenPatternMismatch);
                    inputElement.reportValidity();
                    return false;
                } else {
                    this.showPatternError = false;
                    inputElement.setCustomValidity('');
                }
            }
            
            return isValid;
        }
        
        return true;
    }

    /**
     * @api checkValidity()
     * Checks the validity of the input without showing error messages
     * Returns true if valid, false otherwise
     */
    @api
    checkValidity() {
        let inputElement;
        
        // Get the appropriate input element based on type
        if (this.isInput || this.isTextarea) {
            inputElement = this.template.querySelector('input, textarea');
        } else if (this.isCombobox) {
            inputElement = this.template.querySelector('select');
        } else if (this.isSearchableCombobox) {
            inputElement = this.template.querySelector('.searchable-input-wrapper input');
        } else if (this.isCheckbox || this.isRadio) {
            inputElement = this.template.querySelector('input[type="checkbox"], input[type="radio"]');
        }
        console.log('@@@checking validity',inputElement);
        if (inputElement) {
            // Check native HTML5 validation
            let isValid = inputElement.checkValidity();
            console.log(inputElement,'html2 5 validation@@@',isValid);
            
            if (this.isSearchableCombobox && this.required) {
                if (!this.inputValue) {
                    return false;
                } else {
                    isValid = true;
                }
            }
            // Additional pattern validation
            if (this.pattern) {
                const regex = new RegExp(this.pattern);
                const value = inputElement.value;
                if (value && value.trim() !== '' && !regex.test(value)) {
                    return false;
                }
            }
            
            return isValid;
        }
        
        return true;
    }

    /**
     * @api setCustomValidity(message)
     * Sets a custom validation message
     * @param {string} message - The custom error message to display
     */
    @api
    setCustomValidity(message) {
        let inputElement;
        
        // Get the appropriate input element based on type
        if (this.isInput || this.isTextarea) {
            inputElement = this.template.querySelector('input, textarea');
        } else if (this.isCombobox) {
            inputElement = this.template.querySelector('select');
        } else if (this.isSearchableCombobox) {
            inputElement = this.template.querySelector('.searchable-input-wrapper input');
        } else if (this.isCheckbox || this.isRadio) {
            inputElement = this.template.querySelector('input[type="checkbox"], input[type="radio"]');
        }

        if (inputElement) {
            inputElement.setCustomValidity(message || '');
        }
    }

    /**
     * @api validity
     * Returns the ValidityState object for the input
     */
    @api
    get validity() {
        let inputElement;
        
        // Get the appropriate input element based on type
        if (this.isInput || this.isTextarea) {
            inputElement = this.template.querySelector('input, textarea');
        } else if (this.isCombobox) {
            inputElement = this.template.querySelector('select');
        } else if (this.isSearchableCombobox) {
            inputElement = this.template.querySelector('.searchable-input-wrapper input');
        } else if (this.isCheckbox || this.isRadio) {
            inputElement = this.template.querySelector('input[type="checkbox"], input[type="radio"]');
        }

        if (inputElement) {
            return inputElement.validity;
        }
        
        return { valid: true };
    }
}