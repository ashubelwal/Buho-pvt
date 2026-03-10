import { LightningElement, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getUserDrivers from '@salesforce/apex/BuhoDashboardController.getUserDrivers';
import getUserPolicies from '@salesforce/apex/BuhoDashboardController.getUserPolicies';

export default class Buhodb_mydrivers extends LightningElement {
    @track currentSubView = 'list'; // 'list', 'detail'
    @track selectedDriverId;
    @track allDrivers = [];
    @track allPolicies = [];
    @track error;

    // Wire drivers from Apex
    @wire(getUserDrivers)
    wiredDrivers({ error, data }) {
        if (data) {
            this.allDrivers = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.allDrivers = [];
            console.error('Error fetching drivers:', error);
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
    get driverIconUrl() {
        return `${buhoAssets}/images/drivericon.svg`;
    }

    get policyIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }

    // ── View state helpers ──
    get isListView() {
        return this.currentSubView === 'list';
    }

    // ── Stats ──
    get totalDriversFormatted() {
        return String(this.allDrivers.length).padStart(2, '0');
    }

    get activePoliciesFormatted() {
        const count = this.allPolicies.filter(
            (p) => p.Status_picklist__c === 'Active'
        ).length;
        return String(count).padStart(2, '0');
    }

    // ── Mapped driver data for cards ──
    get drivers() {
        return this.allDrivers.map((d) => ({
            id: d.Id,
            driverName: this._buildDriverName(d),
            licenseNumber: d.license_number__c || '',
            licenseState: d.License_state__c || '',
            dob: this._formatDate(d.Dob__c),
            driverType: d.Driver_Type__c || '',
            email: d.Email__c || '',
            phone: d.Phone__c || '',
            city: d.City__c || '',
            licenseExpire: this._formatDate(d.License_Expire__c),
            isPrimary: d.Primary_insured__c || false
        }));
    }

    // ── Navigation handlers ──
    handleViewDriver(event) {
        const { driverId } = event.detail;
        this.selectedDriverId = driverId;
        this.currentSubView = 'detail';
    }

    handleBackToList() {
        this.currentSubView = 'list';
        this.selectedDriverId = null;
    }

    // ── Private helpers ──
    _buildDriverName(d) {
        const parts = [d.First_Name__c, d.Last_Name__c].filter(Boolean);
        return parts.length > 0 ? parts.join(' ') : d.Name || '';
    }

    _formatDate(dateValue) {
        if (!dateValue) return '';
        const d = new Date(dateValue + 'T00:00:00');
        const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
        return d.toLocaleDateString('en-US', options);
    }
}
