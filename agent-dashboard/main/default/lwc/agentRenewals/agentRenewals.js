import { LightningElement, track, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

const RENEWALS_QUERY = gql`
    query GetRenewals($todayDate: Date, $endDateLimit: Date) {
        uiapi {
            query {
                Policy__c(
                    where: { 
                        and: [
                            { End_Date__c: { lte: { value: $endDateLimit } } }
                            { End_Date__c: { gte: { value: $todayDate } } }
                        ]
                    }
                    orderBy: { End_Date__c: { order: ASC } }
                    first: 200
                ) {
                    edges {
                        node {
                            Id
                            Name { value }
                            Contact__r { 
                                Name { value }
                                Email { value }
                                Phone { value }
                            }
                            Vehicle_Make__c { value }
                            Vehicle_Model__c { value }
                            Vehicle_Year__c { value }
                            End_Date__c { value displayValue }
                            Net_Premium__c { value }
                            Total_Transaction_Amount__c { value }
                            Territory_picklist__c { value }
                        }
                    }
                }
            }
        }
    }
`;

export default class AgentRenewals extends LightningElement {
    @track renewals = [];
    @track isLoadingRenewals = true;

    todayDateStr = new Date().toISOString().split('T')[0];
    endDateLimitStr = (() => {
        const d = new Date();
        d.setDate(d.getDate() + 30);
        return d.toISOString().split('T')[0];
    })();

    get renewalsVariables() {
        return {
            todayDate: this.todayDateStr,
            endDateLimit: this.endDateLimitStr
        };
    }

    @wire(graphql, {
        query: RENEWALS_QUERY,
        variables: '$renewalsVariables'
    })
    wiredRenewals({ data, errors }) {
        if (data) {
            const today = new Date();
            this.renewals = data.uiapi.query.Policy__c.edges.map(({ node: n }) => {
                const endDateStr = n.End_Date__c?.value;
                let diffDays = 0;
                if (endDateStr) {
                    const end = new Date(endDateStr);
                    const diffTime = end - today;
                    diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                    if (diffDays < 0) diffDays = 0;
                }

                let badgeClass = 'badge-days safe';
                if (diffDays <= 7) badgeClass = 'badge-days critical';
                else if (diffDays <= 10) badgeClass = 'badge-days high';
                else if (diffDays <= 15) badgeClass = 'badge-days medium';
                else if (diffDays <= 20) badgeClass = 'badge-days low';

                return {
                    Id: n.Id,
                    policyNumber: n.Name?.value ?? '—',
                    client: n.Contact__r?.Name?.value ?? '—',
                    clientEmail: n.Contact__r?.Email?.value ?? '—',
                    clientPhone: n.Contact__r?.Phone?.value ?? '—',
                    vehicle: [n.Vehicle_Year__c?.value, n.Vehicle_Make__c?.value, n.Vehicle_Model__c?.value].filter(Boolean).join(' ') || '—',
                    vehicleYear: n.Vehicle_Year__c?.value ?? '—',
                    vehicleMake: n.Vehicle_Make__c?.value ?? '—',
                    vehicleModel: n.Vehicle_Model__c?.value ?? '—',
                    expiryDate: n.End_Date__c?.displayValue ?? n.End_Date__c?.value ?? '—',
                    endDateRaw: n.End_Date__c?.value,
                    daysUntil: diffDays,
                    badgeClass: badgeClass,
                    premium: n.Total_Transaction_Amount__c?.value != null ? '$' + Number(n.Total_Transaction_Amount__c.value).toLocaleString() : '—',
                    territory: n.Territory_picklist__c?.value ?? '—'
                };
            });
            this.isLoadingRenewals = false;
        }
        if (errors) {
            console.error('AgentRenewals GraphQL error', errors);
            this.isLoadingRenewals = false;
        }
    }

    get hasRenewals() {
        return this.renewals && this.renewals.length > 0;
    }

    get totalDueThisMonth() {
        return this.renewals.length;
    }

    get criticalCount() {
        return this.renewals.filter(r => r.daysUntil <= 7).length;
    }

    @track showDetailsModal = false;
    @track showEditModal = false;
    @track selectedRenewal = null;

    openDetailsModal(event) {
        event.stopPropagation();
        const id = event.currentTarget.dataset.id;
        this.selectedRenewal = this.renewals.find(r => r.Id === id) || null;
        this.showDetailsModal = true;
    }

    closeDetailsModal() {
        this.showDetailsModal = false;
    }

    openEditModal(event) {
        event.stopPropagation();
        const id = event.currentTarget.dataset.id;
        this.selectedRenewal = this.renewals.find(r => r.Id === id) || null;
        this.showEditModal = true;
    }

    closeEditModal() {
        this.showEditModal = false;
    }

    navigateToPolicyRenew(event) {
        event.stopPropagation();
        const policyId = event.currentTarget.dataset.id || this.selectedRenewal?.Id;
        if (!policyId) return;

        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                page: 'policyEditRenew',
                params: {
                    c__policyId: policyId,
                    c__actionmode: 'renew'
                }
            },
            bubbles: true,
            composed: true
        }));
    }

    stopPropagation(event) {
        event.stopPropagation();
    }
}
