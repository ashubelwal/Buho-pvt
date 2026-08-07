import { LightningElement, track, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

const ACTIVE_POLICIES_QUERY = gql`
    query GetActivePolicies {
        uiapi {
            query {
                Policy__c(
                    where: { Status_picklist__c: { eq: "Active" } }
                    orderBy: { CreatedDate: { order: DESC } }
                    first: 500
                ) {
                    edges {
                        node {
                            Id
                            Name { value }
                            Contact__r { 
                                Name { value }
                            }
                            Vehicle_Make__c { value }
                            Vehicle_Model__c { value }
                            Vehicle_Year__c { value }
                            Start_Date__c { value displayValue }
                            End_Date__c { value displayValue }
                            Status_picklist__c { value }
                            Total_Transaction_Amount__c { value }
                        }
                    }
                }
            }
        }
    }
`;

export default class AgentEndorsement extends LightningElement {
    @track policies = [];
    @track isLoading = true;
    @track searchQuery = '';

    @wire(graphql, {
        query: ACTIVE_POLICIES_QUERY
    })
    wiredPolicies({ data, errors }) {
        if (data) {
            this.policies = data.uiapi.query.Policy__c.edges.map(({ node: n }) => {
                return {
                    Id: n.Id,
                    policyNumber: n.Name?.value ?? '—',
                    client: n.Contact__r?.Name?.value ?? '—',
                    vehicle: [n.Vehicle_Year__c?.value, n.Vehicle_Make__c?.value, n.Vehicle_Model__c?.value].filter(Boolean).join(' ') || '—',
                    status: n.Status_picklist__c?.value ?? '—',
                    startDate: n.Start_Date__c?.displayValue ?? n.Start_Date__c?.value ?? '—',
                    endDate: n.End_Date__c?.displayValue ?? n.End_Date__c?.value ?? '—',
                    premium: n.Total_Transaction_Amount__c?.value != null ? '$' + Number(n.Total_Transaction_Amount__c.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '—'
                };
            });
            this.isLoading = false;
        }
        if (errors) {
            console.error('AgentEndorsement GraphQL error', errors);
            this.isLoading = false;
        }
    }

    get filteredPolicies() {
        if (!this.searchQuery) return this.policies;
        const lowerQ = this.searchQuery.toLowerCase();
        return this.policies.filter(p => 
            p.policyNumber.toLowerCase().includes(lowerQ) ||
            p.client.toLowerCase().includes(lowerQ) ||
            p.vehicle.toLowerCase().includes(lowerQ)
        );
    }

    get hasPolicies() {
        return this.filteredPolicies && this.filteredPolicies.length > 0;
    }

    handleSearch(event) {
        this.searchQuery = event.target.value;
    }

    navigateToPolicyEdit(event) {
        event.stopPropagation();
        const policyId = event.currentTarget.dataset.id;
        if (!policyId) return;

        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                page: 'policyEditRenew',
                params: {
                    c__policyId: policyId,
                    c__actionmode: 'edit'
                }
            },
            bubbles: true,
            composed: true
        }));
    }
}
