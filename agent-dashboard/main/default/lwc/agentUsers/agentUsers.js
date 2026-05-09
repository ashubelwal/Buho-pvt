import { LightningElement, track, wire, api } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import createAgencyUser from '@salesforce/apex/AgencyPortalController.createAgencyUser';

// ── GraphQL query – all Agent RT contacts under this agency ──
const USERS_QUERY = gql`
    query GetAllUsers($contactId: ID) {
        uiapi {
            query {
                User(
                    where: { 
                        and: [
                            { IsActive: { eq: true } },
                            { Contact: { Agency__c: { eq: $contactId } } },
                            { Contact: { RecordType: { Name: { eq: "Agent RT" } } } }
                        ]
                    }
                    orderBy: { CreatedDate: { order: DESC } }
                    first: 2000
                ) {
                    edges {
                        node {
                            Id
                            Contact {
                                Name { value }
                                Email { value }
                                Phone { value }
                            }
                            CreatedDate { value displayValue }
                            IsActive { value }
                        }
                    }
                }
            }
        }
    }
`;

export default class AgentUsers extends LightningElement {

    // ── @api ─────────────────────────────────────────────────────────────────
    @api contactId; // passed from agentContainer – the logged-in user's Contact Id

    // ── State ────────────────────────────────────────────────────────────────
    @track usersList = [];
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track searchValue = '';

    // Pagination
    @track currentPage = 1;
    pageSize = 10;

    // View-details modal
    @track showUserModal = false;
    @track selectedUser = {};

    // Create-user modal
    @track showCreateModal = false;
    @track isSaving = false;
    
    // New user form state
    @track newUser = {
        FirstName: '',
        LastName: '',
        Email: ''
    };

    get graphqlVariables() {
        return {
            contactId: this.contactId
        };
    }

    // ── GraphQL ──────────────────────────────────────────────────────────────

    @wire(graphql, {
        query: USERS_QUERY,
        variables: '$graphqlVariables'
    })
    wiredUsers({ data, errors }) {
        if (data) {
            console.log('@@@data',data);
            this.usersList = data.uiapi.query.User.edges.map(({ node: n }) => {
                return {
                    Id: n.Id,
                    Name: n.Contact?.Name?.value ?? '—',
                    Phone: n.Contact?.Phone?.value ?? '—',
                    Email: n.Contact?.Email?.value ?? '—',
                    CreatedDate: n.CreatedDate?.displayValue ?? n.CreatedDate?.value ?? '—',
                    IsActive: n.IsActive?.value ?? false    
                };
            });
            this.isLoading = false;
            this.hasError = false;
        }
        if (errors) {
            console.error('AgentUsers GraphQL error', errors);
            this.errorMessage = errors[0]?.message || 'Failed to load users.';
            this.hasError = true;
            this.isLoading = false;
        }
    }

    // ── Computed getters ─────────────────────────────────────────────────────
    get filteredUsers() {
        if (!this.searchValue) return this.usersList;
        const kw = this.searchValue.toLowerCase();
        return this.usersList.filter(c =>
            (c.Name && c.Name.toLowerCase().includes(kw)) ||
            (c.Email && c.Email.toLowerCase().includes(kw)) ||
            (c.Phone && c.Phone.toLowerCase().includes(kw))
        );
    }

    get paginatedUsers() {
        const start = (this.currentPage - 1) * this.pageSize;
        return this.filteredUsers.slice(start, start + this.pageSize);
    }

    get totalPages() { return Math.ceil(this.filteredUsers.length / this.pageSize) || 1; }
    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }
    get pageInfo() { return `Page ${this.currentPage} of ${this.totalPages}`; }
    get hasUsers() { return this.filteredUsers.length > 0; }
    get totalUsers() { return this.usersList.length; }
    get filteredCount() { return this.paginatedUsers.length; }

    // ── Actions ──────────────────────────────────────────────────────────────
    handleSearch(event) {
        this.searchValue = event.target.value;
        this.currentPage = 1;
    }

    prevPage() { if (this.currentPage > 1) this.currentPage--; }
    nextPage() { if (this.currentPage < this.totalPages) this.currentPage++; }

    // ── View-details modal ───────────────────────────────────────────────────
    openUserModal(event) {
        event.stopPropagation();
        const id = event.currentTarget.dataset.id;
        this.selectedUser = this.usersList.find(c => c.Id === id) || {};
        this.showUserModal = true;
    }
    closeUserModal() { this.showUserModal = false; }

    // ── Create-user modal ──────────────────────────────────────────────────
    openCreateModal() { 
        this.newUser = { FirstName: '', LastName: '', Email: '' };
        this.showCreateModal = true; 
    }
    closeCreateModal() { this.showCreateModal = false; }
    
    handleInputChange(event) {
        const field = event.target.dataset.field;
        this.newUser[field] = event.target.value;
    }

    async handleSaveUser() {
        if (!this.newUser.LastName || !this.newUser.Email) {
            const toast = this.template.querySelector('c-agent-toast');
            if (toast) {
                toast.showToast({
                    title: 'Error',
                    message: 'Last Name and Email are required.',
                    variant: 'error'
                });
            }
            return;
        }
        
        this.isSaving = true;
        try {
            console.log('@@@@this.newUser',this.newUser);
            const result = await createAgencyUser({
                firstName: this.newUser.FirstName,
                lastName: this.newUser.LastName,
                email: this.newUser.Email,
                agencyContactId: this.contactId
            });
            
            if (result === 'Success') {
                const toast = this.template.querySelector('c-agent-toast');
                if (toast) {
                    toast.showToast({
                        title: 'Success',
                        message: 'User created successfully and welcome email sent.',
                        variant: 'success'
                    });
                }
                this.closeCreateModal();
                this.refreshList();
            } else {
                const toast = this.template.querySelector('c-agent-toast');
                if (toast) {
                    toast.showToast({
                        title: 'Error',
                        message: result,
                        variant: 'error'
                    });
                }
            }
        } catch (error) {
            const toast = this.template.querySelector('c-agent-toast');
            if (toast) {
                toast.showToast({
                    title: 'Error',
                    message: error.body?.message || error.message,
                    variant: 'error'
                });
            }
        } finally {
            this.isSaving = false;
        }
    }

    refreshList() {
        this.isLoading = true;
        const current = this.contactId;
        this.contactId = null;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        Promise.resolve().then(() => { this.contactId = current; });
    }

    stopPropagation(event) { event.stopPropagation(); }
}
