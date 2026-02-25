import { LightningElement, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getUserTransactions from '@salesforce/apex/BuhoDashboardController.getUserTransactions';

export default class Buhodb_mytransactions extends LightningElement {
    @track allTransactions = [];
    @track error;

    // Wire transactions from Apex
    @wire(getUserTransactions)
    wiredTransactions({ error, data }) {
        if (data) {
            this.allTransactions = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.allTransactions = [];
            console.error('Error fetching transactions:', error);
        }
    }

    // Asset URLs
    get transactionIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }

    // ── Stats ──
    get totalTransactionsFormatted() {
        return String(this.allTransactions.length).padStart(2, '0');
    }

    get totalAmountFormatted() {
        const total = this.allTransactions.reduce((sum, t) => {
            return sum + (t.Amount__c || 0);
        }, 0);
        return this._formatCurrency(total);
    }

    // ── Mapped transaction data for cards ──
    get transactions() {
        return this.allTransactions.map((t) => ({
            id: t.Id,
            transactionName: t.Name__c || t.Name || '',
            transactionType: t.type__c || '',
            amount: this._formatCurrency(t.Amount__c),
            premiumAmount: this._formatCurrency(t.Premium_Amount__c),
            taxIva: this._formatCurrency(t.Tax_Iva__c),
            paymentType: t.Payment_Type__c || '',
            mode: t.Mode__c || '',
            policyRef: t.Policy_Transaction__r
                ? (t.Policy_Transaction__r.Reference_number__c || t.Policy_Transaction__r.Name)
                : '',
            ccMask: t.CC_Mask__c || '',
            gatewaySource: t.gateway_source__c || '',
            termDays: t.Term_Days__c != null ? String(t.Term_Days__c) : '',
            createdAt: this._formatDateTime(t.Created_At__c),
            description: t.Description__c || ''
        }));
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
