import { LightningElement, api, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getVehicleById from '@salesforce/apex/BuhoDashboardController.getVehicleById';
import saveVehicle from '@salesforce/apex/BuhoDashboardController.saveVehicle';
import removeVehicle from '@salesforce/apex/BuhoDashboardController.removeVehicle';

export default class Buhodb_vehicleeditform extends LightningElement {
    // 'view' = Vehicle Detail view, 'add' = Add New Vehicle form
    @api mode = 'view';
    @api vehicleId;

    @track useVinEntry = true;
    @track selectedFeatures = [];
    @track vehicleRecord;
    @track error;
    @track isSaving = false;

    // ── Form field trackers (add mode) ──
    @track formVin = '';
    @track formYear = '';
    @track formMake = '';
    @track formModel = '';
    @track formValue = '';
    @track formVehicleType = '';
    @track formPlate = '';
    @track formState = '';

    // Wire vehicle data for view mode
    @wire(getVehicleById, { vehicleId: '$vehicleId' })
    wiredVehicle({ error, data }) {
        if (data) {
            this.vehicleRecord = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.vehicleRecord = null;
            console.error('Error fetching vehicle:', error);
        }
    }

    // Icon URLs
    get chevronLeftIconUrl() {
        return `${buhoAssets}/images/chevron-left.svg`;
    }

    get chevronDownIconUrl() {
        return `${buhoAssets}/images/chevron-down.svg`;
    }

    get plusIconUrl() {
        return `${buhoAssets}/images/plus-icon.svg`;
    }

    get personIconUrl() {
        return `${buhoAssets}/images/person-icon.svg`;
    }

    // ── Mode helpers ──
    get isViewMode() {
        return this.mode === 'view';
    }

    get isAddMode() {
        return this.mode === 'add';
    }

    get pageTitle() {
        return this.isAddMode ? 'Add New Vehicle' : 'Vehicle Detail';
    }

    get pageSubtitle() {
        if (this.isAddMode) {
            return 'Add New Vehicle to Your Policy';
        }
        return `${this.vehicle.yearMakeModel} - Detailed View`;
    }

    get addButtonLabel() {
        return this.isAddMode ? 'Save Vehicle' : 'Add New Vehicle';
    }

    // ── View mode: vehicle data from Apex ──
    get vehicle() {
        const v = this.vehicleRecord;
        if (!v) {
            return {
                vin: '',
                yearMakeModel: '',
                currentValue: '',
                licensePlate: '',
                vehicleType: '',
                policy: '',
                coverageLevel: '',
                deductible: '',
                specialFeatures: '',
                batteryCoverage: '',
                completeEquipment: '',
                claimsHistory: '',
                lastTrip: '',
                nextService: '',
                avgTripDuration: '',
                primaryDriver: '',
                secondaryDriver: ''
            };
        }

        const yearMakeModel = [v.Year__c, v.Make__c, v.Model__c]
            .filter(Boolean)
            .join(' ');
        const plate = v.Registered_Plate__c
            ? `${v.Registered_Plate__c}${v.Registered_State__c ? ' - ' + v.Registered_State__c : ''}`
            : '';
        const policyRef = v.Policy__r
            ? `${v.Policy__r.Reference_number__c || v.Policy__r.Name} (${v.Policy__r.Status_picklist__c || ''})`
            : '';
        const coverageLevel = v.Policy__r
            ? v.Policy__r.Package__c || ''
            : '';
        const deductible = v.Policy__r
            ? v.Policy__r.Vehicle_deductible_collision__c || ''
            : '';

        return {
            vin: v.Vin__c || '',
            yearMakeModel: yearMakeModel,
            currentValue: this._formatCurrency(v.Value__c),
            licensePlate: plate,
            vehicleType: v.Vehicle_Type__c || v.Type__c || '',
            policy: policyRef,
            coverageLevel: coverageLevel,
            deductible: deductible,
            specialFeatures: '',
            batteryCoverage: '',
            completeEquipment: '',
            claimsHistory: '',
            lastTrip: '',
            nextService: '',
            avgTripDuration: '',
            primaryDriver: v.Vehicle_Owner_Name__c || '',
            secondaryDriver: ''
        };
    }

    // ── Add mode: form data for display ──
    get formData() {
        const yearMakeModel = [this.formYear, this.formMake, this.formModel]
            .filter(Boolean)
            .join(' ');
        return {
            vin: this.formVin,
            yearMakeModel: yearMakeModel || '',
            currentValue: this.formValue
                ? this._formatCurrency(Number(this.formValue))
                : '',
            licensePlate: this.formPlate
                ? `${this.formPlate}${this.formState ? ' - ' + this.formState : ''}`
                : '',
            vehicleType: this.formVehicleType || '',
            vehicleColor: '',
            addedToPolicy: '',
            primaryUse: '',
            annualMileage: ''
        };
    }

    // ── Vehicle Type picklist options ──
    get vehicleTypeOptions() {
        return [
            { label: 'Automobile/Sedan', value: 'Automobile/Sedan' },
            {
                label: 'Pickup Truck w or w/o Camper Shell',
                value: 'Pickup Truck w or w/o Camper Shell'
            },
            { label: 'SUV', value: 'SUV' },
            { label: 'Van', value: 'Van' },
            { label: 'Motorcycle', value: 'Motorcycle' },
            { label: 'Street Legal ATV', value: 'Street Legal ATV' },
            { label: 'Motor Home / RV', value: 'Motor Home / RV' },
            { label: 'ATV', value: 'ATV' },
            { label: 'Boat', value: 'Boat' },
            { label: 'SUV-Crossover', value: 'SUV-Crossover' },
            { label: 'Motorhome', value: 'Motorhome' },
            { label: 'Pick Up', value: 'Pick Up' }
        ];
    }

    // ── VIN / Manual entry selection ──
    get vinOptionClass() {
        return this.useVinEntry
            ? 'vform-radio-indicator checked'
            : 'vform-radio-indicator';
    }

    get manualOptionClass() {
        return !this.useVinEntry
            ? 'vform-radio-indicator checked'
            : 'vform-radio-indicator';
    }

    handleSelectVinEntry() {
        this.useVinEntry = true;
    }

    handleSelectManualEntry() {
        this.useVinEntry = false;
    }

    // ── Form input handlers ──
    handleVinChange(event) {
        this.formVin = event.target.value;
    }

    handleYearChange(event) {
        this.formYear = event.target.value;
    }

    handleMakeChange(event) {
        this.formMake = event.target.value;
    }

    handleModelChange(event) {
        this.formModel = event.target.value;
    }

    handleValueChange(event) {
        this.formValue = event.target.value;
    }

    handleVehicleTypeChange(event) {
        this.formVehicleType = event.target.value;
    }

    handlePlateChange(event) {
        this.formPlate = event.target.value;
    }

    handleStateChange(event) {
        this.formState = event.target.value;
    }

    // ── Special Features checkboxes ──
    get specialFeatureOptions() {
        const features = [
            { id: 'electric', label: 'Electric/Hybrid Vehicle (+$45)' },
            { id: 'over10', label: 'Over 10 years old (+$35)' },
            { id: 'commercial', label: 'Commercial modifications' },
            { id: 'highperf', label: 'High-performance model' },
            { id: 'custom', label: 'Custom paint/body work' }
        ];
        return features.map((f) => ({
            ...f,
            checkboxClass: this.selectedFeatures.includes(f.id)
                ? 'vform-checkbox-indicator checked'
                : 'vform-checkbox-indicator'
        }));
    }

    handleFeatureToggle(event) {
        const featureId = event.currentTarget.dataset.id;
        if (this.selectedFeatures.includes(featureId)) {
            this.selectedFeatures = this.selectedFeatures.filter(
                (f) => f !== featureId
            );
        } else {
            this.selectedFeatures = [...this.selectedFeatures, featureId];
        }
    }

    // ── Action handlers ──
    handleBack() {
        this.dispatchEvent(
            new CustomEvent('back', {
                bubbles: true,
                composed: true
            })
        );
    }

    handleRemoveToggle() {
        if (!this.vehicleId) return;

        removeVehicle({ vehicleId: this.vehicleId })
            .then(() => {
                this.dispatchEvent(
                    new CustomEvent('back', {
                        bubbles: true,
                        composed: true
                    })
                );
            })
            .catch((err) => {
                console.error('Error removing vehicle:', err);
            });
    }

    handleCancel() {
        this._resetForm();
        this.dispatchEvent(
            new CustomEvent('back', {
                bubbles: true,
                composed: true
            })
        );
    }

    handleAddNewVehicle() {
        if (this.isAddMode) {
            this._handleSave();
        } else {
            // Navigate to add form
            this.dispatchEvent(
                new CustomEvent('addnew', {
                    bubbles: true,
                    composed: true
                })
            );
        }
    }

    // ── Save vehicle via Apex ──
    _handleSave() {
        // Basic validation
        if (!this.formVin && !this.formMake) {
            console.error('Please provide at least a VIN or Make.');
            return;
        }

        this.isSaving = true;

        // Build the full Vehicle__c sObject for Apex
        const vehicleRecord = {
            sobjectType: 'Vehicle__c',
            Vin__c: this.formVin || null,
            Year__c: this.formYear || null,
            Make__c: this.formMake || null,
            Model__c: this.formModel || null,
            Value__c: this.formValue ? Number(this.formValue) : null,
            Vehicle_Type__c: this.formVehicleType || null,
            Registered_Plate__c: this.formPlate || null,
            Registered_State__c: this.formState || null
        };

        saveVehicle({ vehicle: vehicleRecord })
            .then((newId) => {
                this.isSaving = false;
                this._resetForm();
                this.dispatchEvent(
                    new CustomEvent('addvehicle', {
                        detail: { vehicleId: newId },
                        bubbles: true,
                        composed: true
                    })
                );
            })
            .catch((err) => {
                this.isSaving = false;
                console.error('Error saving vehicle:', err);
            });
    }

    _resetForm() {
        this.formVin = '';
        this.formYear = '';
        this.formMake = '';
        this.formModel = '';
        this.formValue = '';
        this.formVehicleType = '';
        this.formPlate = '';
        this.formState = '';
        this.selectedFeatures = [];
    }

    // ── Private helpers ──
    _formatCurrency(value) {
        if (value === undefined || value === null) return '';
        return (
            '$' +
            Number(value).toLocaleString('en-US', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            })
        );
    }
}
