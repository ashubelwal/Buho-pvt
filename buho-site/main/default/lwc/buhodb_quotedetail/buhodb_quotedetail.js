import { LightningElement, api, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getQuoteById from '@salesforce/apex/BuhoDashboardController.getQuoteById';

export default class Buhodb_quotedetail extends LightningElement {
    @api quoteId;

    @track quoteDetail;
    @track isLoading = true;
    @track error;
    @track showInfoSection = true;
    @track showCoverageSection = true;

    // ── Wire: Single quote detail ──
    @wire(getQuoteById, { quoteId: '$quoteId' })
    wiredQuoteDetail({ error, data }) {
        if (data) {
            this.quoteDetail = data;
            this.isLoading = false;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.quoteDetail = undefined;
            this.isLoading = false;
            console.error('Error fetching quote detail:', error);
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
        if (!this.quoteDetail) return {};
        const q = this.quoteDetail;
        return {
            quoteNumber: q.Name || '',
            netPremium: this._formatCurrency(q.Net_Premium__c),
            underwriter: q.Underwriter__c || '',
            brokerPolicyFee: this._formatCurrency(q.Broker_Policy_Fee__c),
            policyType: q.Policy_Type__c || '',
            ivaMexTax: this._formatCurrency(q.I_V_A_Mex_Tax__c),
            driverAge: q.Driver_Age__c != null ? String(q.Driver_Age__c) : '',
            vehicleAge: q.Vehicle_Age__c != null ? String(q.Vehicle_Age__c) : '',
            quoteValue: this._formatCurrency(q.Quote_Value__c),
            endTime: q.End_Time__c || '',
            physicalDamage: this._formatCurrency(q.Physical_Damage__c),
            dateOfBirth: this._formatDate(q.Date_of_Birth__c),
            totalTheftPayment: this._formatCurrency(q.Total_Theft_Payment__c),
            typeOfVessel: q.Type_of_Vessel__c || '',
            medicalPayment: this._formatCurrency(q.Medical_Payment__c),
            maxSpeedOver50: q.Is_the_Maximum_Speed_more_than_50_mph__c || '',
            liabilityPayment: this._formatCurrency(q.Liability_Payment__c),
            ownerLivingInMexico: q.Is_the_owner_living_in_Mexico__c || '',
            platinumEndorsement: this._formatCurrency(q.Platinum_Endorsment__c),
            boatOperatorUnder22: q.Any_Boat_Operator_Under_22__c || '',
            vesselLength: q.Vessel_Length__c || '',
            thirdPartyBodilyInjury: q.Third_Party_Bodily_Injury__c || '',
            propertyDamageLiability: q.Property_Damage_Liability__c || '',
            vehicleSubType: q.Vehicle_Sub_type__c || '',
            surcharge: this._formatCurrency(q.Surcharge__c),
            vehicleDeductibleCollision: q.Vehicle_Deductible_Collision__c || '',
            vehicleDeductibleComprehensive: q.Vehicle_Deductible_Comprehensive__c || '',
            renewQuote: q.Renew_Quote__c || '',
            leadId: q.Lead_Id__c || '',
            gold: q.Gold__c || false,
            max: q.Max__c || false,
            platinum: q.Platinum__c || false,
            // Coverage details
            coverage: q.Coverage__c || '',
            startDateCoverage: this._formatDate(q.Start_Date_for_Coverage__c),
            endDateCoverage: this._formatDate(q.End_Date_for_Coverage__c),
            medical: q.Medical__c || '',
            liability: q.Liability__c || '',
            startTime: q.Start_Time__c || '',
            territory: q.Territory__c || '',
            timeZone: q.Time_Zone__c || '',
            trailering: q.Trailering__c || false,
            termDays: q.Term_Days__c != null ? String(q.Term_Days__c) : ''
        };
    }

    // ── Checkbox visual classes ──
    get goldCheckClass() {
        return this.quoteDetail && this.quoteDetail.Gold__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    get maxCheckClass() {
        return this.quoteDetail && this.quoteDetail.Max__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    get platinumCheckClass() {
        return this.quoteDetail && this.quoteDetail.Platinum__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    get traileringCheckClass() {
        return this.quoteDetail && this.quoteDetail.Trailering__c
            ? 'pd-checkbox pd-checkbox-checked'
            : 'pd-checkbox pd-checkbox-unchecked';
    }

    // ── Section toggle chevron classes ──
    get infoChevronClass() {
        return this.showInfoSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    get coverageChevronClass() {
        return this.showCoverageSection ? 'pd-chevron pd-chevron-open' : 'pd-chevron';
    }

    // ── Event handlers ──
    handleBackToList() {
        this.dispatchEvent(
            new CustomEvent('backtoquotes', {
                bubbles: true,
                composed: true
            })
        );
    }

    toggleInfo() {
        this.showInfoSection = !this.showInfoSection;
    }

    toggleCoverage() {
        this.showCoverageSection = !this.showCoverageSection;
    }

    // ── Private helpers ──
    _formatDate(dateValue) {
        if (!dateValue) return '';
        const d = new Date(dateValue + 'T00:00:00');
        const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
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
