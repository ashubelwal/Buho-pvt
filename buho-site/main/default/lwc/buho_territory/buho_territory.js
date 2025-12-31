import { LightningElement, track, api } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import image from '@salesforce/resourceUrl/mexJs';
import mexImage from '@salesforce/resourceUrl/mexinsurance_assets';
import saveTerritoryDetails from '@salesforce/apex/TerritoryOptionFlow.saveTerritoryDetails';

export default class Buho_territory extends LightningElement {
    @api payload;
    @track parentPayloadData;
    isDebug = true;
    __componentLoaded = false;

    @track inputValues = {};
    
    @track options = [
        { label: 'Baja/Sonora', value: 'Baja/Sonora', selected: true, imageUrl: `${buhoAssets}/images/baja_sonora.png` },
        { label: 'Baja/Sonora Baja, Sonora, Chihuahua, Coahuila, Nuevo Leon, Tamaulipas', value: 'Limited', selected: false, imageUrl: `${buhoAssets}/images/extended_territory.png` },
        { label: 'Entire Mexico', value: 'Full', selected: false, imageUrl: `${buhoAssets}/images/entire_mexico.png` }
    ];

    @track booleanvar = {
        isError: false,
    };
    
    @track userType;

    // Territory options with computed classes for UI
    get territories() {
        return this.options.map(option => ({
            ...option,
            className: option.selected ? 'territory-card selected' : 'territory-card'
        }));
    }

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

    // Handle territory selection (card click)
    handleTerritorySelect(event) {
        const territory = event.currentTarget.dataset.territory;
        
        // Update selected option in options array
        this.options = this.options.map(option => ({
            ...option,
            selected: option.value === territory
        }));

        // Update inputValues
        this.inputValues['region'] = territory;
        
        this.booleanvar.isError = false;
        
        if (this.isDebug) console.log('BTR Territory selected:', territory);
        if (this.isDebug) console.log('BTR Input values:', this.inputValues);
    }

    // Handle input change (for radio buttons if used directly)
    async handleInputChange(event) {
        try {
            const { value } = event.target;

            // Update selected option in options array
            this.options = this.options.map(option => ({
                ...option,
                selected: option.value === value
            }));

            // Update inputValues
            this.inputValues['region'] = value;
            
            if (this.isDebug) console.log('BTR Selected region:', this.inputValues);

            this.booleanvar.isError = false;
        } catch (err) {
            if (this.isDebug) console.log('BTR Error in handleInputChange:', err.message);
        }
    }

    // Validation method (returns true if valid, false if invalid)
    @api validate() {
        // Check if a territory is selected
        const selectedOption = this.options.find(option => option.selected);
        
        if (!selectedOption || !this.inputValues.region) {
            this.booleanvar.isError = true;
            this.dispatchEvent(new CustomEvent('toastevent', {
                detail: { variant: 'error', title: 'Validation Error', message: 'Please select a territory.' },
                bubbles: true,
                composed: true
            }));
            if (this.isDebug) console.error('BTR Territory: No territory selected.');
            return false;
        }

        this.booleanvar.isError = false;
        if (this.isDebug) console.log('BTR Territory: Validation passed:', this.inputValues);
        return true;
    }

    // Get data method - called by parent
    @api async getData() {
        let temp = { ['territory']: this.inputValues }
        let updatedPayload = [...this.payload];

        const existingIndex = this.payload.findIndex(item =>
            Object.keys(item)[0] === "territory"
        );
        
        if (existingIndex !== -1) {
            // Update the existing item at the found index
            updatedPayload[existingIndex] = temp;
        } else {
            // Add the new territory object
            updatedPayload.push(temp);
        }

        // Reassign the updated array back to payload
        this.payload = updatedPayload;
        
        // Call apex method to save TerritoryOption data in lead obj
        if (this.isDebug) console.log('BTR saveTerritoryDetails data:', JSON.stringify(this.payload));
        
        if (!this.currentUserType) {
            try {
                const result = await saveTerritoryDetails({ strLeadDetails: JSON.stringify(this.payload) });
                if (this.isDebug) console.log('BTR Response from save territory data:', result);
            } catch (err) {
                if (this.isDebug) console.log('BTR Error while saving the TerritoryOption:', JSON.stringify(err));
                this.dispatchEvent(new CustomEvent('toastevent', {
                    detail: { variant: 'error', title: 'Error', message: 'Error saving territory details' },
                    bubbles: true,
                    composed: true
                }));
            }
        }

        if (this.isDebug) console.log('BTR Territory - getData - Final Data:', JSON.stringify(this.inputValues));
        return this.inputValues;
    }

    // Handle continue button
    handleContinue() {
        if (!this.validate()) {
            return;
        }
        
        this.dispatchEvent(new CustomEvent('changescreen', {
            detail: { direction: 'next' },
            bubbles: true,
            composed: true
        }));
    }

    // Lifecycle: component connected
    connectedCallback() {
        if (this.isDebug) console.log('BTR Connected, payload:', JSON.stringify(this.payload));
        
        // Initialize inputValues with default selection
        const defaultSelected = this.options.find(option => option.selected);
        if (defaultSelected) {
            this.inputValues['region'] = defaultSelected.value;
        }
    }

    // Lifecycle: component rendered
    renderedCallback() {
        // Populate from payload if available
        if (this.payload && this.payload.length > 0 && !this.__componentLoaded) {
            this.__componentLoaded = true;
            const territoryData = this.payload.find(item => item.territory);
            if (territoryData && territoryData.territory.region) {
                const selectedValue = territoryData.territory.region;
                
                // Update options array to reflect the saved selection
                this.options = this.options.map(option => ({
                    ...option,
                    selected: option.value === selectedValue
                }));
                
                // Update inputValues
                this.inputValues['region'] = selectedValue;
                
                if (this.isDebug) console.log('BTR Populated territory from payload:', selectedValue);
            }
        }
    }
}
