import { LightningElement, api, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getDriverById from '@salesforce/apex/BuhoDashboardController.getDriverById';

export default class Buhodb_driverdetail extends LightningElement {
    @api driverId;

    @track driverDetail;
    @track isLoading = true;
    @track error;
    @track showPersonalSection = true;
    @track showAddressSection = true;
    @track showLicenseSection = true;
    @track showRelatedSection = true;

    // ── Wire: Single driver detail ──
    @wire(getDriverById, { driverId: '$driverId' })
    wiredDriverDetail({ error, data }) {
        if (data) {
            this.driverDetail = data;
            this.isLoading = false;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.driverDetail = undefined;
            this.isLoading = false;
            console.error('Error fetching driver detail:', error);
        }
    }

    // ── Icon URLs ──
    get chevronDownIconUrl() {
        return `${buhoAssets}/images/chevron-down.svg`;
    }

    get chevronLeftIconUrl() {
        return `${buhoAssets}/images/chevron-left.svg`;
    }

    // ── Formatted data ──
    get formatted() {
        if (!this.driverDetail) return {};
        const d = this.driverDetail;
        return {
            firstName: d.First_Name__c || '',
            lastName: d.Last_Name__c || '',
            dob: this._formatDate(d.Dob__c),
            ageRange: d.Age_Range__c || '',
            driverType: d.Driver_Type__c || '',
            email: d.Email__c || '',
            phone: d.Phone__c || '',
            primaryInsured: d.Primary_insured__c || false,
            isDefault: d.default__c || false,
            address: d.Address__c || '',
            addressLine2: d.Address_Line_2__c || '',
            city: d.City__c || '',
            stateProvince: d.State_Province__c || '',
            country: d.Country__c || '',
            postalCode: d.Postal_Code__c || '',
            licenseNumber: d.license_number__c || '',
            licenseState: d.License_state__c || '',
            licenseCountry: d.License_Country__c || '',
            licenseExpire: this._formatDate(d.License_Expire__c),
            policyName: d.Policy__r ? (d.Policy__r.Reference_number__c || d.Policy__r.Name) : '',
            vehicleName: d.Vehicle_Driver__r ? d.Vehicle_Driver__r.Name : '',
            createdAt: this._formatDateTime(d.created_at__c)
        };
    }

    // ── Checkbox visual classes ──
    get primaryInsuredCheckClass() {
        return this.driverDetail && this.driverDetail.Primary_insured__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    get defaultCheckClass() {
        return this.driverDetail && this.driverDetail.default__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    // ── Section toggle chevron classes ──
    get personalChevronClass() {
        return this.showPersonalSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    get addressChevronClass() {
        return this.showAddressSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    get licenseChevronClass() {
        return this.showLicenseSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    get relatedChevronClass() {
        return this.showRelatedSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    // ── Event handlers ──
    handleBackToList() {
        this.dispatchEvent(
            new CustomEvent('backtodrivers', {
                bubbles: true,
                composed: true
            })
        );
    }

    togglePersonal() {
        this.showPersonalSection = !this.showPersonalSection;
    }

    toggleAddress() {
        this.showAddressSection = !this.showAddressSection;
    }

    toggleLicense() {
        this.showLicenseSection = !this.showLicenseSection;
    }

    toggleRelated() {
        this.showRelatedSection = !this.showRelatedSection;
    }

    // ── Private helpers ──
    _formatDate(dateValue) {
        if (!dateValue) return '';
        const d = new Date(dateValue + 'T00:00:00');
        const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
        return d.toLocaleDateString('en-US', options);
    }

    _formatDateTime(dateTimeValue) {
        if (!dateTimeValue) return '';
        const dt = new Date(dateTimeValue);
        const dateOpts = { year: 'numeric', month: '2-digit', day: '2-digit' };
        const timeOpts = { hour: 'numeric', minute: '2-digit', hour12: true };
        return (
            dt.toLocaleDateString('en-US', dateOpts) +
            ', ' +
            dt.toLocaleTimeString('en-US', timeOpts)
        );
    }
}
