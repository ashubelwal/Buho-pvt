import { LightningElement, track, wire, api } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

// ── GraphQL query – all contacts the logged-in user has access to ──
const CLIENTS_QUERY = gql`
    query GetAllClients {
        uiapi {
            query {
                Contact(
                    orderBy: { CreatedDate: { order: DESC } }
                    first: 2000
                ) {
                    edges {
                        node {
                            Id
                            Name { value }
                            Phone { value }
                            Email { value }
                            MailingStreet { value }
                            MailingCity { value }
                            MailingState { value }
                            MailingPostalCode { value }
                            MailingCountry { value }
                            CreatedDate { value displayValue }
                        }
                    }
                }
            }
        }
    }
`;

export default class AgentClients extends LightningElement {

    // ── @api ─────────────────────────────────────────────────────────────────
    @api contactId; // passed from agentContainer – the logged-in user's Contact Id

    // ── State ────────────────────────────────────────────────────────────────
    @track clients = [];
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track searchValue = '';

    // Pagination
    @track currentPage = 1;
    pageSize = 10;

    // View-details modal
    @track showClientModal = false;
    @track selectedClient = {};

    // Create-client modal
    @track showCreateModal = false;

    // ── GraphQL ──────────────────────────────────────────────────────────────

    @wire(graphql, {
        query: CLIENTS_QUERY
    })
    wiredClients({ data, errors }) {
        console.log('@@@@client data', data);
        if (data) {
            this.clients = data.uiapi.query.Contact.edges.map(({ node: n }) => {
                const addrParts = [
                    n.MailingStreet?.value,
                    n.MailingCity?.value,
                    n.MailingState?.value,
                    n.MailingPostalCode?.value,
                    n.MailingCountry?.value
                ].filter(Boolean);
                return {
                    Id: n.Id,
                    Name: n.Name?.value ?? '—',
                    Phone: n.Phone?.value ?? '—',
                    Email: n.Email?.value ?? '—',
                    Address: addrParts.length ? addrParts.join(', ') : '—',
                    CreatedDate: n.CreatedDate?.displayValue ?? n.CreatedDate?.value ?? '—'
                };
            });
            this.isLoading = false;
            this.hasError = false;
        }
        if (errors) {
            console.error('AgentClients GraphQL error', errors);
            this.errorMessage = errors[0]?.message || 'Failed to load clients.';
            this.hasError = true;
            this.isLoading = false;
        }
    }

    // ── Computed getters ─────────────────────────────────────────────────────
    get filteredClients() {
        if (!this.searchValue) return this.clients;
        const kw = this.searchValue.toLowerCase();
        return this.clients.filter(c =>
            (c.Name && c.Name.toLowerCase().includes(kw)) ||
            (c.Email && c.Email.toLowerCase().includes(kw)) ||
            (c.Phone && c.Phone.toLowerCase().includes(kw))
        );
    }

    get paginatedClients() {
        console.log('@@@this.filteredClients', this.filteredClients);
        const start = (this.currentPage - 1) * this.pageSize;
        return this.filteredClients.slice(start, start + this.pageSize);
    }

    get totalPages() { return Math.ceil(this.filteredClients.length / this.pageSize) || 1; }
    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }
    get pageInfo() { return `Page ${this.currentPage} of ${this.totalPages}`; }
    get hasClients() { return this.filteredClients.length > 0; }
    get totalClients() { return this.clients.length; }
    get filteredCount() { return this.paginatedClients.length; }

    // ── Actions ──────────────────────────────────────────────────────────────
    handleSearch(event) {
        this.searchValue = event.target.value;
        this.currentPage = 1;
    }

    prevPage() { if (this.currentPage > 1) this.currentPage--; }
    nextPage() { if (this.currentPage < this.totalPages) this.currentPage++; }

    // ── View-details modal ───────────────────────────────────────────────────
    openClientModal(event) {
        event.stopPropagation();
        const id = event.currentTarget.dataset.id;
        this.selectedClient = this.clients.find(c => c.Id === id) || {};
        this.showClientModal = true;
    }
    closeClientModal() { this.showClientModal = false; }

    // ── Create-client modal ──────────────────────────────────────────────────
    openCreateModal() { this.showCreateModal = true; }
    closeCreateModal() { this.showCreateModal = false; }

    handleClientCreated() {
        // child fired 'clientcreated' – close modal & refresh wire
        this.showCreateModal = false;
        this.isLoading = true;
        // Nudge the wire adapter to re-fetch by toggling a reactive variable
        const current = this.contactId;
        this.contactId = null;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        Promise.resolve().then(() => { this.contactId = current; });
    }

    stopPropagation(event) { event.stopPropagation(); }
}
