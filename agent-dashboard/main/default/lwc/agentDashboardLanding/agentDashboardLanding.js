import { LightningElement, track, wire, api } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import getDashboardStats from '@salesforce/apex/AgencyPortalController.getDashboardStats';

const RECENT_QUOTES_QUERY = gql`
    query GetRecentQuotes {
        uiapi {
            query {
                Quote__c(
                    orderBy: { CreatedDate: { order: DESC } }
                    first: 10
                ) {
                    edges {
                        node {
                            Id
                            Name { value }
                            CreatedDate { value displayValue }
                            Account__r { Name { value } }
                            Vehicle_Make__c { value }
                            Vehicle_Model__c { value }
                            Vehicle_Year__c { value }
                            Quote_Value__c { value }
                        }
                    }
                }
            }
        }
    }
`;

const RENEWALS_QUERY = gql`
    query GetRenewals($todayDate: Date, $endDateLimit: Date) {
        uiapi {
            query {
                Policy__c(
                    where: { 
                        and: [
                            { End_Date__c: { lte: { value: $endDateLimit } } },
                            { End_Date__c: { gte: { value: $todayDate } } }
                        ]
                    }
                    orderBy: { End_Date__c: { order: ASC } }
                    first: 10
                ) {
                    edges {
                        node {
                            Id
                            Name { value }
                            Contact__r { Id Name { value } }
                            Vehicle_Make__c { value }
                            Vehicle_Model__c { value }
                            Vehicle_Year__c { value }
                            End_Date__c { value displayValue }
                            Net_Premium__c { value }
                            Total_Transaction_Amount__c { value }
                        }
                    }
                }
            }
        }
    }
`;


export default class AgentDashboardLanding extends LightningElement {
    @api contactId;
    /** Agency Id resolved by the parent (agentContainer).
     *  Agency RT users  → their own contactId.
     *  Sub-agent users  → their Contact.Agency__c value.
     */
    @api agency;

    @track recentQuotes = [];
    @track isLoadingQuotes = true;

    @track renewals = [];
    @track isLoadingRenewals = true;

    todayDateStr = new Date().toISOString().split('T')[0];
    endDateLimitStr = (() => {
        const d = new Date();
        d.setDate(d.getDate() + 30);
        return d.toISOString().split('T')[0];
    })();

    get quotesVariables() {
        return {};
    }

    @track stats = {
        activePolicies: 0,
        policiesTrend: '',
        policiesClass: 'stat-card-change',
        policiesIcon: '',
        expiringSoon: 0,
        totalClients: 0,
        clientsTrend: '',
        clientsClass: 'stat-card-change',
        clientsIcon: '',
        monthlyRevenue: '$0',
        revenueTrend: '',
        revenueClass: 'stat-card-change',
        revenueIcon: ''
    };

    @wire(getDashboardStats)
    wiredStats({ data, errors }) {
        if (data) {
            const formatTrend = (nowVal, prevVal) => {
                if (prevVal === 0) return nowVal > 0 ? { val: '100', pos: true } : { val: '0', pos: true };
                const pct = ((nowVal - prevVal) / prevVal) * 100;
                return { val: Math.abs(pct).toFixed(1), pos: pct >= 0 };
            };

            const thisMonthPolicies = data.thisMonthPolicies || 0;
            const lastMonthPolicies = data.lastMonthPolicies || 0;
            const thisMonthRevenue  = data.thisMonthRevenue  || 0;
            const lastMonthRevenue  = data.lastMonthRevenue  || 0;
            const thisMonthClients  = data.thisMonthClients  || 0;
            const lastMonthClients  = data.lastMonthClients  || 0;

            const pTrend = formatTrend(thisMonthPolicies, lastMonthPolicies);
            const cTrend = formatTrend(thisMonthClients,  lastMonthClients);
            const rTrend = formatTrend(thisMonthRevenue,  lastMonthRevenue);

            this.stats = {
                activePolicies: (data.totalPolicies || 0).toLocaleString(),
                policiesTrend:  pTrend.pos ? `+${pTrend.val}% Vs last month` : `-${pTrend.val}% Vs last month`,
                policiesClass:  pTrend.pos ? 'stat-card-change positive' : 'stat-card-change negative',
                policiesIcon:   pTrend.pos ? 'bi bi-arrow-up-short' : 'bi bi-arrow-down-short',

                expiringSoon:   (data.expiringSoon || 0).toLocaleString(),

                totalClients:   (data.totalClients || 0).toLocaleString(),
                clientsTrend:   cTrend.pos ? `+${cTrend.val}% Vs last month` : `-${cTrend.val}% Vs last month`,
                clientsClass:   cTrend.pos ? 'stat-card-change positive' : 'stat-card-change negative',
                clientsIcon:    cTrend.pos ? 'bi bi-arrow-up-short' : 'bi bi-arrow-down-short',

                monthlyRevenue: '$' + Number(thisMonthRevenue).toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 0 }),
                revenueTrend:   rTrend.pos ? `+${rTrend.val}% Vs last month` : `-${rTrend.val}% Vs last month`,
                revenueClass:   rTrend.pos ? 'stat-card-change positive' : 'stat-card-change negative',
                revenueIcon:    rTrend.pos ? 'bi bi-arrow-up-short' : 'bi bi-arrow-down-short'
            };
        }
        if (errors) {
            console.error('AgentDashboardLanding Stats error', errors);
        }
    }

    @wire(graphql, {
        query: RECENT_QUOTES_QUERY,
        variables: '$quotesVariables'
    })
    wiredResult({ data, errors }) {
        if (data) {
            this.recentQuotes = data.uiapi.query.Quote__c.edges.map(({ node: n }) => ({
                Id: n.Id,
                quoteNumber: n.Name?.value ?? '—',
                account: n.Account__r?.Name?.value ?? '—',
                vehicle: [n.Vehicle_Year__c?.value, n.Vehicle_Make__c?.value, n.Vehicle_Model__c?.value].filter(Boolean).join(' ') || '—',
                premium: n.Quote_Value__c?.value != null ? '$' + Number(n.Quote_Value__c.value).toLocaleString() : '—',
                createdDate: n.CreatedDate?.displayValue ?? '—'
            }));
            this.isLoadingQuotes = false;
        }
        if (errors) {
            console.error('AgentDashboardLanding GraphQL error', errors);
            this.isLoadingQuotes = false;
        }
    }

    get hasQuotes() {
        return this.recentQuotes && this.recentQuotes.length > 0;
    }

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

                let badgeClass = 'badge-days ok';
                if (diffDays <= 10) badgeClass = 'badge-days urgent';
                else if (diffDays <= 20) badgeClass = 'badge-days warning';

                return {
                    Id: n.Id,
                    policyNumber: n.Name?.value ?? '—',
                    client: n.Contact__r?.Name?.value ?? '—',
                    contactId: n.Contact__r?.Id ?? null,
                    vehicle: [n.Vehicle_Year__c?.value, n.Vehicle_Make__c?.value, n.Vehicle_Model__c?.value].filter(Boolean).join(' ') || '—',
                    expiryDate: n.End_Date__c?.displayValue ?? n.End_Date__c?.value ?? '—',
                    daysUntil: `${diffDays} Days`,
                    badgeClass: badgeClass,
                    premium: n.Total_Transaction_Amount__c?.value != null ? '$' + Number(n.Total_Transaction_Amount__c.value).toLocaleString() : '—'
                };
            });
            this.isLoadingRenewals = false;
        }
        if (errors) {
            console.error('AgentDashboardLanding Renewals GraphQL error', errors);
            this.isLoadingRenewals = false;
        }
    }

    get hasRenewals() {
        return this.renewals && this.renewals.length > 0;
    }

    handleNewQuoteClick() {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { page: 'newQuote' }
        }));
    }

    handleLookUpPolicyClick() {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { page: 'lookUpPolicy' }
        }));
    }

    // ── Renewals table action handlers ───────────────────────────────────────

    handleRenewClick(event) {
        const policyId = event.target.dataset.id;
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                page: 'policyEditRenew',
                params: {
                    c__policyId: policyId,
                    c__actionmode: 'renew'
                }
            }
        }));
    }

    handleContactClick(event) {
        const contactId = event.target.dataset.id;
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                page: 'contactDetails',
                params: {
                    c__obj: 'contact',
                    c__action: 'VIEW',
                    c__id: contactId
                }
            }
        }));
    }

    // ── Add Client modal ──────────────────────────────────────────────────────
    @track showAddClientModal = false;

    openAddClientModal() { this.showAddClientModal = true; }
    closeAddClientModal() { this.showAddClientModal = false; }

    handleClientCreated() {
        this.showAddClientModal = false;
        // Quotes/renewals wire will refresh on next tick automatically
    }

    handleGenerateReport() {
        const chartCmp = this.template.querySelector('[data-id="chart-report"]');
        if (chartCmp) {
            chartCmp.downloadCSV();
        }
    }
}
