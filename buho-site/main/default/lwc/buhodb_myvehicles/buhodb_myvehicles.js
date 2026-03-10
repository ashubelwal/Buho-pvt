import { LightningElement, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getUserVehicles from '@salesforce/apex/BuhoDashboardController.getUserVehicles';
import getUserPolicies from '@salesforce/apex/BuhoDashboardController.getUserPolicies';

export default class Buhodb_myvehicles extends LightningElement {
    @track currentSubView = 'list'; // 'list', 'view', 'add'
    @track selectedVehicleId;
    @track allVehicles = [];
    @track allPolicies = [];
    @track error;

    // Wire vehicles from Apex
    @wire(getUserVehicles)
    wiredVehicles({ error, data }) {
        if (data) {
            this.allVehicles = data;
            console.log('@@@this.allVehicles'+this.allVehicles);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.allVehicles = [];
            console.error('Error fetching vehicles:', error);
        }
    }

    // Wire policies for active-policy count
    @wire(getUserPolicies)
    wiredPolicies({ error, data }) {
        if (data) {
            this.allPolicies = data;
        } else if (error) {
            this.allPolicies = [];
        }
    }

    // Asset URLs
    get carIconUrl() {
        return `${buhoAssets}/images/caricon.svg`;
    }

    get policyIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }

    get plusIconUrl() {
        return `${buhoAssets}/images/plus-icon.svg`;
    }

    // ── View state helpers ──
    get isListView() {
        return this.currentSubView === 'list';
    }

    get formMode() {
        return this.currentSubView === 'add' ? 'add' : 'view';
    }

    // ── Stats ──
    get totalVehiclesFormatted() {
        return String(this.allVehicles.length).padStart(2, '0');
    }

    get activePoliciesFormatted() {
        const count = this.allPolicies.filter(
            (p) => p.Status_picklist__c === 'Active'
        ).length;
        return String(count).padStart(2, '0');
    }

    // ── Mapped vehicle data for cards ──
    get vehicles() {
        return this.allVehicles.map((v) => ({
            id: v.Id,
            vehicleName: this._buildVehicleName(v),
            vin: v.Vin__c || '',
            plate: this._buildPlate(v),
            value: this._formatCurrency(v.Value__c),
            surcharge: this._formatCurrency(
                v.Policy__r ? v.Policy__r.Surcharge__c : null
            ),
            surchargeType: this._buildSurchargeType(v),
            primaryDriver: v.Vehicle_Owner_Name__c || '',
            added: this._formatDate(v.Created_At__c),
            usageStats: '',
            premium: this._buildPremium(v)
        }));
    }

    // ── Navigation handlers ──
    handleAddNewVehicle() {
        this.currentSubView = 'add';
        this.selectedVehicleId = null;
    }

    handleEditVehicle(event) {
        const { vehicleId } = event.detail;
        this.selectedVehicleId = vehicleId;
        this.currentSubView = 'view';
    }

    handleUpdateValue(event) {
        const { vehicleId } = event.detail;
        console.log('Update value for vehicle:', vehicleId);
    }

    handleBackToList() {
        this.currentSubView = 'list';
        this.selectedVehicleId = null;
    }

    handleVehicleAdded() {
        this.currentSubView = 'list';
    }

    // ── Private helpers ──
    _buildVehicleName(v) {
        const parts = [v.Year__c, v.Make__c, v.Model__c].filter(Boolean);
        return parts.length > 0
            ? parts.join(' ')
            : v.Vehicle_Type__c || '';
    }

    _buildPlate(v) {
        if (!v.Registered_Plate__c) return '';
        const state = v.Registered_State__c
            ? ` (${v.Registered_State__c})`
            : '';
        return `${v.Registered_Plate__c}${state}`;
    }

    _buildSurchargeType(v) {
        const surcharge = v.Policy__r ? v.Policy__r.Surcharge__c : null;
        if (surcharge === undefined || surcharge === null) return '';
        const type = v.Vehicle_Type__c || '';
        return `${this._formatCurrency(surcharge)} (${type})`;
    }

    _buildPremium(v) {
        if (!v.Policy__r || v.Policy__r.Total_Premium_Amount__c == null)
            return '';
        const amount = this._formatCurrency(
            v.Policy__r.Total_Premium_Amount__c
        );
        const term = v.Policy__r.Term__c ? ` (${v.Policy__r.Term__c})` : '';
        return `${amount}${term}`;
    }

    _formatDate(dateValue) {
        if (!dateValue) return '';
        const d = new Date(dateValue);
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return d.toLocaleDateString('en-US', options);
    }

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
