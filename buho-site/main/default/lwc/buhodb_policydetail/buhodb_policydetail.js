import { LightningElement, api, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getPolicyById from '@salesforce/apex/BuhoDashboardController.getPolicyById';

const STORAGE_KEY = 'buhoPolicyDetailId';

export default class Buhodb_policydetail extends LightningElement {
    @api policyId;

    @track policyDetail;
    @track isLoadingDetail = true;
    @track error;
    @track showInformationSection = true;
    @track showCoverageSection = true;
    @track showFeesSection = true;
    @track showTripSection = true;

    // ── Wire: Single policy detail ──
    @wire(getPolicyById, { policyId: '$policyId' })
    wiredPolicyDetail({ error, data }) {
        if (data) {
            this.policyDetail = data;
            this.isLoadingDetail = false;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.policyDetail = undefined;
            this.isLoadingDetail = false;
            console.error('Error fetching policy detail:', error);
        }
    }

    // ──────────────────────────────────────
    //  Icon URLs
    // ──────────────────────────────────────

    get chevronDownIconUrl() {
        return `${buhoAssets}/images/chevron-down.svg`;
    }

    get chevronLeftIconUrl() {
        return `${buhoAssets}/images/chevron-left.svg`;
    }

    get carIconUrl() {
        return `${buhoAssets}/images/caricon.svg`;
    }

    // ──────────────────────────────────────
    //  Policy Detail getters
    // ──────────────────────────────────────

    get formattedPolicy() {
        if (!this.policyDetail) return {};
        const p = this.policyDetail;
        return {
            policyNumber: p.Reference_number__c || p.Name || '',
            status: p.Status_picklist__c || '',
            policyType: p.Policy_Type_picklist__c || '',
            vehicleType: p.Vehicle_type__c || '',
            underwriter: p.Underwriter_picklist__c || '',
            startDate: this._formatDate(p.Start_Date__c),
            startTime: this._formatTime(p.Start_Time__c),
            package: p.Package__c || '',
            endDate: this._formatDate(p.End_Date__c),
            endTime: this._formatTime(p.End_Time__c),
            quoteName: p.Quote_c__r ? p.Quote_c__r.Name : '',
            termDays: p.Term_days__c != null ? String(p.Term_days__c) : '',
            term: p.Term__c || '',
            newPolicyName: p.Policy__r ? p.Policy__r.Name : '',
            fullyEarned: p.Fully_Earned__c || false,
            issuedAt: this._formatDateTime(p.Issued_At__c),
            agentName: p.Agent_Name__c || '',
            agencyName: p.Agency_Name__c || '',
            source: p.Source__c || '',
            whyTerminate: p.Why_Terminate_Policy__c || '',
            gold: p.Gold__c || false,
            max: p.Max__c || false,
            platinum: p.Platinum__c || false,
            // Coverage
            medical: p.Medical__c || '',
            statedValue: this._formatCurrency(p.Insured_value__c),
            liability: p.Liability__c || '',
            territory: p.Territory_picklist__c || '',
            // Fees
            netPremium: this._formatCurrency(p.Net_Premium__c),
            physicalDamage: this._formatCurrency(p.Physical_Damage__c),
            brokerPolicyFee: this._formatCurrency(p.Broker_Policy_Fee__c),
            totalTheftPayment: this._formatCurrency(p.Total_Theft_Payment__c),
            ivaMexTax: this._formatCurrency(p.I_V_A_Mex_Tax__c),
            liabilityPayment: this._formatCurrency(p.Liability_Payment__c),
            surcharge: this._formatCurrency(p.Surcharge__c),
            medicalPayment: this._formatCurrency(p.Medical_Payment__c),
            totalPremiumAmount: this._formatCurrency(p.Total_Premium_Amount__c),
            platinumEndorsement: this._formatCurrency(p.Platinum_Endorsement_Payment__c),
            // Trip
            tripDestination: p.What_is_your_trip_destination_in_US__c || '',
            tripPurpose: p.What_is_the_purpose_of_trip__c || ''
        };
    }

    get policyDateRange() {
        if (!this.policyDetail) return '';
        const start = this._formatDate(this.policyDetail.Start_Date__c);
        const end = this._formatDate(this.policyDetail.End_Date__c);
        return [start, end].filter(Boolean).join(' — ');
    }

    get policyDetailStatus() {
        return this.policyDetail ? (this.policyDetail.Status_picklist__c || '') : '';
    }

    get policyDetailVehicleLabel() {
        if (!this.policyDetail) return '';
        const parts = [
            this.policyDetail.Vehicle_Year__c,
            this.policyDetail.Vehicle_Make__c,
            this.policyDetail.Vehicle_Model__c
        ].filter(Boolean);
        return parts.length > 0 ? parts.join(' ') : (this.policyDetail.Vehicle_type__c || '');
    }

    // ── Status badge class ──
    get policyStatusBadgeClass() {
        const status = this.policyDetailStatus;
        let modifier = 'pd-badge-default';
        if (status === 'Active') modifier = 'pd-badge-active';
        else if (status === 'Expired' || status === 'Terminated') modifier = 'pd-badge-expired';
        else if (status === 'Updated') modifier = 'pd-badge-updated';
        return `pd-status-badge ${modifier}`;
    }

    get policyStatusFieldClass() {
        const status = this.policyDetailStatus;
        let modifier = '';
        if (status === 'Active') modifier = 'pd-status-active';
        else if (status === 'Expired' || status === 'Terminated') modifier = 'pd-status-expired';
        return `pd-field-value ${modifier}`;
    }

    // ── Checkbox visual classes ──
    get fullyEarnedCheckClass() {
        return this.policyDetail && this.policyDetail.Fully_Earned__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    get goldCheckClass() {
        return this.policyDetail && this.policyDetail.Gold__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    get maxCheckClass() {
        return this.policyDetail && this.policyDetail.Max__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    get platinumCheckClass() {
        return this.policyDetail && this.policyDetail.Platinum__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    // ── Section toggle chevron classes ──
    get infoChevronClass() {
        return this.showInformationSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    get coverageChevronClass() {
        return this.showCoverageSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    get feesChevronClass() {
        return this.showFeesSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    get tripChevronClass() {
        return this.showTripSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    // ──────────────────────────────────────
    //  Event handlers
    // ──────────────────────────────────────

    handleBackToList() {
        // Clear stored policy
        localStorage.removeItem(STORAGE_KEY);

        // Notify parent (buhodb_mypolicy) to switch back to list view.
        // buhodb_mypolicy listens via onback={handleBackToList} and then
        // dispatches 'hashupdate' to the container to update the URL hash.
        this.dispatchEvent(
            new CustomEvent('back', {
                bubbles: true,
                composed: true
            })
        );
    }

    toggleInformation() {
        this.showInformationSection = !this.showInformationSection;
    }

    toggleCoverage() {
        this.showCoverageSection = !this.showCoverageSection;
    }

    toggleFees() {
        this.showFeesSection = !this.showFeesSection;
    }

    toggleTrip() {
        this.showTripSection = !this.showTripSection;
    }

    // ──────────────────────────────────────
    //  Private helpers
    // ──────────────────────────────────────

    _formatDate(dateValue) {
        if (!dateValue) return '';
        const d = new Date(dateValue + 'T00:00:00');
        const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
        return d.toLocaleDateString('en-US', options);
    }

    _formatTime(timeValue) {
        if (timeValue === undefined || timeValue === null) return '';
        const totalMs = Number(timeValue);
        const hours = Math.floor(totalMs / 3600000);
        const minutes = Math.floor((totalMs % 3600000) / 60000);
        const seconds = Math.floor(((totalMs % 3600000) % 60000) / 1000);
        const period = hours >= 12 ? 'PM' : 'AM';
        const displayHours = hours % 12 || 12;
        const displayMinutes = String(minutes).padStart(2, '0');
        const displaySeconds = String(seconds).padStart(2, '0');
        return `${displayHours}:${displayMinutes}:${displaySeconds} ${period}`;
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
