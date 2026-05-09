import { LightningElement, track, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

// ── GraphQL query ─────────────────────────────────────────────────────────────
const QUOTES_QUERY = gql`
    query GetAgentQuotes {
        uiapi {
            query {
                Quote__c(
                    orderBy: { CreatedDate: { order: DESC } }
                    first: 200
                ) {
                    edges {
                        node {
                            Id
                            Name { value }
                            CreatedDate { value displayValue }
                            LastModifiedDate { value displayValue }
                            Account__r { Name { value } }
                            Vehicle_Make__c { value }
                            Vehicle_Model__c { value }
                            Vehicle_Type__c { value }
                            Term_Days__c { value }
                            Vehicle_Value__c { value }
                            Vehicle_Year__c { value }
                            Quote_Status__c { value }
                            Territory__c { value }
                            Term__c { value }
                            Quote_Value__c { value }
                        }
                    }
                }
            }
        }
    }
`;

export default class AgentQuotes extends LightningElement {

    // ── Wire ──────────────────────────────────────────────────────────────────
    @wire(graphql, { query: QUOTES_QUERY })
    wiredResult({ data, errors }) {
        if (data) {
            this.quotes = data.uiapi.query.Quote__c.edges.map(({ node: n }) => ({
                Id: n.Id,
                quoteNumber: n.Name?.value ?? '—',
                createdDate: n.CreatedDate?.displayValue ?? '—',
                lastModified: n.LastModifiedDate?.displayValue ?? '—',
                account: n.Account__r?.Name?.value ?? '—',
                vehicleMake: n.Vehicle_Make__c?.value ?? '—',
                vehicleModel: n.Vehicle_Model__c?.value ?? '—',
                vehicleType: n.Vehicle_Type__c?.value ?? '—',
                termDays: n.Term_Days__c?.value ?? '—',
                vehicleValue: n.Vehicle_Value__c?.value != null
                    ? '$' + Number(n.Vehicle_Value__c.value).toLocaleString() : '—',
                vehicleYear: n.Vehicle_Year__c?.value ?? '—',
                territory: n.Territory__c?.value ?? '—',
                term: n.Term__c?.value ?? '—',
                premium: n.Quote_Value__c?.value != null
                    ? '$' + Number(n.Quote_Value__c.value).toLocaleString() : '—',
                statusClass: this._statusClass(n.Quote_Status__c?.value),
                statusLabel: n.Quote_Status__c?.value ?? 'Draft',
            }));
            this.isLoading = false;
            this.hasError = false;
            this.currentPage = 1;
        }
        if (errors) {
            console.error('AgentQuotes GraphQL error', errors);
            this.errorMessage = errors.map(e => e.message).join('; ');
            this.hasError = true;
            this.isLoading = false;
        }
    }

    // ── State ─────────────────────────────────────────────────────────────────
    @track quotes = [];
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track searchValue = '';

    // Pagination
    @track currentPage = 1;
    @track pageSize = 10;

    // Modal state
    @track showDetailsModal = false;
    @track showEditModal = false;
    @track selectedQuote = {};

    // ── Helpers ───────────────────────────────────────────────────────────────
    _statusClass(status) {
        if (!status || status === 'Draft') return 'status-badge inactive';
        return 'status-badge active';
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    get filteredQuotes() {
        if (!this.searchValue) return this.quotes;
        const kw = this.searchValue.toLowerCase();
        return this.quotes.filter(q =>
            (q.quoteNumber && q.quoteNumber.toLowerCase().includes(kw)) ||
            (q.account && q.account.toLowerCase().includes(kw)) ||
            (q.vehicleMake && q.vehicleMake.toLowerCase().includes(kw)) ||
            (q.vehicleModel && q.vehicleModel.toLowerCase().includes(kw))
        );
    }

    get paginatedQuotes() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.filteredQuotes.slice(start, end);
    }

    get totalPages() { return Math.ceil(this.filteredQuotes.length / this.pageSize) || 1; }
    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }
    get pageInfo() { return `Page ${this.currentPage} of ${this.totalPages}`; }

    get hasQuotes() { return this.filteredQuotes.length > 0; }
    get totalQuotes() { return this.quotes.length; }
    get totalSold() { return this.quotes.filter(q => q.statusLabel === 'Policy Created').length; }

    // ── Actions ───────────────────────────────────────────────────────────────
    handleSearch(event) {
        this.searchValue = event.target.value;
        this.currentPage = 1;
    }

    prevPage() {
        if (this.currentPage > 1) this.currentPage--;
    }

    nextPage() {
        if (this.currentPage < this.totalPages) this.currentPage++;
    }

    // ── Modals ────────────────────────────────────────────────────────────────
    openDetailsModal(event) {
        event.stopPropagation();
        const id = event.currentTarget.dataset.id;
        this.selectedQuote = this.quotes.find(q => q.Id === id) || {};
        this.showDetailsModal = true;
    }

    closeDetailsModal() { this.showDetailsModal = false; }

    openEditModal(event) {
        event.stopPropagation();
        const id = event.currentTarget.dataset.id;
        this.selectedQuote = this.quotes.find(q => q.Id === id) || {};
        this.showEditModal = true;
    }

    closeEditModal() { this.showEditModal = false; }

    stopPropagation(event) { event.stopPropagation(); }
}
