import { LightningElement, api } from 'lwc';

export default class Buho_input extends LightningElement {
    @api label = '';
    @api type = 'input'; // input, combobox, checkbox, radio
    @api name = '';
    @api value = '';
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

    get isCheckbox() {
        return this.type === 'checkbox';
    }

    get isRadio() {
        return this.type === 'radio';
    }

    get hasIcon() {
        return this.icon && this.isInput;
    }

    get computedInputClass() {
        return this.inputClass;
    }

    get computedDropdownClass() {
        return this.dropdownClass;
    }

    get comboboxOptions() {
        return this.options.map(option => {
            if (typeof option === 'string') {
                return {
                    label: option,
                    value: option,
                    isSelected: option === this.value
                };
            }
            return {
                label: option.label || option.value,
                value: option.value,
                isSelected: option.value === this.value
            };
        });
    }

    handleInputChange(event) {
        const value = event.target.value;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                name: this.name,
                value: value
            }
        }));
    }

    handleComboboxChange(event) {
        const value = event.target.value;
        console.log('value on change',value)
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                name: this.name,
                value: value
            }
        }));
    }

    handleCheckboxChange(event) {
        const checked = event.target.checked;
        console.log('input checked'+checked);
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                name: this.name,
                checked: checked,
                value: checked
            }
        }));
    }

    handleKeyUp(event) {
        this.dispatchEvent(new CustomEvent('keyup', {
            detail: {
                name: this.name,
                value: event.target.value,
                key: event.key
            }
        }));
    }

    handleInput(event) {
        this.dispatchEvent(new CustomEvent('input', {
            detail: {
                name: this.name,
                value: event.target.value
            }
        }));
    }
}