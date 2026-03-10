import { LightningElement, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getUserQuotes from '@salesforce/apex/BuhoDashboardController.getUserQuotes';

export default class Buhodb_myquotes extends LightningElement {
    @track currentSubView = 'list'; // 'list', 'detail'
    @track selectedQuoteId;
    @track allQuotes = [];
    @track error;

    // Wire quotes from Apex
    @wire(getUserQuotes)
    wiredQuotes({ error, data }) {
        if (data) {
            this.allQuotes = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.allQuotes = [];
            console.error('Error fetching quotes:', error);
        }
    }

    // Asset URLs
    get quoteIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }

    // ── View state helpers ──
    get isListView() {
        return this.currentSubView === 'list';
    }

    // ── Stats ──
    get totalQuotesFormatted() {
        return String(this.allQuotes.length).padStart(2, '0');
    }

    // ── Mapped quote data for cards ──
    get quotes() {
        return this.allQuotes.map((q) => ({
            id: q.Id,
            quoteNumber: q.Name || '',
            quoteStatus: q.Quote_Status__c || '',
            quoteValue: this._formatCurrency(q.Quote_Value__c),
            policyType: q.Policy_Type__c || '',
            coverage: q.Coverage__c || '',
            termDays: q.Term_Days__c != null ? String(q.Term_Days__c) : '',
            netPremium: this._formatCurrency(q.Net_Premium__c),
            vehicleInfo: this._buildVehicleInfo(q),
            territory: q.Territory__c || ''
        }));
    }

    // ── Navigation handlers ──
    handleViewQuote(event) {
        const { quoteId } = event.detail;
        this.selectedQuoteId = quoteId;
        this.currentSubView = 'detail';
    }

    handleBackToList() {
        this.currentSubView = 'list';
        this.selectedQuoteId = null;
    }

    // ── Private helpers ──
    _buildVehicleInfo(q) {
        const parts = [q.Vehicle_Year__c, q.Vehicle_Make__c, q.Vehicle_Model__c].filter(Boolean);
        return parts.length > 0 ? parts.join(' ') : '';
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
