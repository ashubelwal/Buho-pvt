import { LightningElement, api, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getUserPolicies from '@salesforce/apex/BuhoDashboardController.getUserPolicies';

const STORAGE_KEY = 'buhoPolicyDetailId';

export default class Buhodb_mypolicy extends LightningElement {
    @track selectedFilter = 'All Policies';
    @track selectedFilterValue = 'all';
    @track isDropdownOpen = false;
    @track currentSubView = 'list'; // 'list', 'detail', 'addPolicy', 'editPolicy', 'renewPolicy', or 'terminatePolicy'
    @track allPolicies = [];
    @track error;

    // Detail view state
    @track selectedPolicyId;

    /** Receive sub-view from parent container (driven by URL hash) */
    @api
    get subView() {
        return this.currentSubView;
    }
    set subView(value) {
        if (value) {
            // Track pending loading-off for edit/renew/terminate (loader is shown by the button component)
            if (value === 'editPolicy' || value === 'renewPolicy' || value === 'terminatePolicy') {
                this._pendingLoadingOff = true;
            }
            this.currentSubView = value;
            if (value === 'detail') {
                this._restorePolicyFromStorage();
            }
        }
    }

    renderedCallback() {
        // Once the child component for edit/renew/terminate is rendered, hide the global loader
        if (this._pendingLoadingOff && (this.isEditPolicyView || this.isRenewPolicyView || this.isTerminatePolicyView)) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this._dispatchLoading(false);
            }, 0);
        }
    }

    /**
     * Dispatch global loading status event (caught by buhodb_container).
     * Any child component can reuse this pattern.
     */
    _dispatchLoading(isLoading) {
        this._pendingLoadingOff = isLoading;
        this.dispatchEvent(
            new CustomEvent('loadingstatus', {
                detail: { isLoading },
                bubbles: true,
                composed: true
            })
        );
    }

    // ── Wire: All policies (list view) ──
    @wire(getUserPolicies)
    wiredPolicies({ error, data }) {
        if (data) {
            this.allPolicies = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.allPolicies = [];
            console.error('Error fetching policies:', error);
        }
    }

    // ──────────────────────────────────────
    //  Icon URLs
    // ──────────────────────────────────────

    get chevronDownIconUrl() {
        return `${buhoAssets}/images/chevron-down.svg`;
    }

    get filterIconUrl() {
        return `${buhoAssets}/images/filter-lines.svg`;
    }

    get plusIconUrl() {
        return `${buhoAssets}/images/plus-icon.svg`;
    }

    get chevronLeftIconUrl() {
        return `${buhoAssets}/images/chevron-left.svg`;
    }

    // ──────────────────────────────────────
    //  View state helpers
    // ──────────────────────────────────────

    get isListView() {
        return this.currentSubView === 'list';
    }

    get isDetailView() {
        return this.currentSubView === 'detail';
    }

    get isAddPolicyView() {
        return this.currentSubView === 'addPolicy';
    }

    get isEditPolicyView() {
        return this.currentSubView === 'editPolicy';
    }

    get isRenewPolicyView() {
        return this.currentSubView === 'renewPolicy';
    }

    get isTerminatePolicyView() {
        return this.currentSubView === 'terminatePolicy';
    }

    get showBackToPolicy() {
        return this.isEditPolicyView || this.isRenewPolicyView || this.isTerminatePolicyView;
    }

    // ──────────────────────────────────────
    //  Filter dropdown
    // ──────────────────────────────────────

    get filterOptions() {
        return [
            { label: 'All Policies', value: 'all' },
            { label: 'Active Policies', value: 'active' },
            { label: 'Expired Policies', value: 'expired' },
            { label: 'Pending Renewal', value: 'pending' }
        ];
    }

    // ── Filtered & mapped policies for list view ──
    get policies() {
        let filtered;

        switch (this.selectedFilterValue) {
            case 'active':
                filtered = this.allPolicies.filter(
                    (p) => p.Status_picklist__c === 'Active'
                );
                break;
            case 'expired':
                filtered = this.allPolicies.filter(
                    (p) => p.Status_picklist__c === 'Expired'
                );
                break;
            case 'pending':
                filtered = this.allPolicies.filter((p) => {
                    if (p.Status_picklist__c !== 'Active' || !p.End_Date__c) {
                        return false;
                    }
                    const endDate = new Date(p.End_Date__c);
                    const today = new Date();
                    const diffDays = Math.ceil(
                        (endDate - today) / (1000 * 60 * 60 * 24)
                    );
                    return diffDays >= 0 && diffDays <= 30;
                });
                break;
            default:
                filtered = this.allPolicies;
        }

        return filtered.map((p) => ({
            id: p.Id,
            vehicleName: this._buildVehicleName(p),
            policyNumber: p.Reference_number__c || p.Name,
            activeUntil: this._formatDate(p.End_Date__c),
            coverage: p.Package__c || '',
            premium: this._formatCurrency(p.Total_Premium_Amount__c),
            paymentType: p.Term__c || ''
        }));
    }

    get noPolicies() {
        return !this.policies || this.policies.length === 0;
    }

    // ──────────────────────────────────────
    //  Event handlers — List view
    // ──────────────────────────────────────

    handleDropdownToggle() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }

    handleFilterSelect(event) {
        const value = event.currentTarget.dataset.value;
        const selected = this.filterOptions.find(
            (opt) => opt.value === value
        );
        if (selected) {
            this.selectedFilter = selected.label;
            this.selectedFilterValue = selected.value;
        }
        this.isDropdownOpen = false;
    }

    handleFilterClick() {
        console.log('Filter clicked');
    }

    handleAddPolicy() {
        this.currentSubView = 'addPolicy';
        this.dispatchEvent(
            new CustomEvent('hashupdate', {
                detail: { hash: 'newpolicy' },
                bubbles: true,
                composed: true
            })
        );
    }

    handleViewDetails(event) {
        const { policyId } = event.detail;
        if (!policyId) return;

        // Store in localStorage so we can restore on page reload
        localStorage.setItem(STORAGE_KEY, policyId);

        // Set the selected policy and switch to detail view
        this.selectedPolicyId = policyId;
        this.currentSubView = 'detail';

        // Tell parent container to update URL hash
        this.dispatchEvent(
            new CustomEvent('hashupdate', {
                detail: { hash: 'policydetail' },
                bubbles: true,
                composed: true
            })
        );
    }

    handleDownloadDocuments(event) {
        const { policyId } = event.detail;
        console.log('Download documents for policy:', policyId);
    }

    handleRenew(event) {
        const { policyId } = event.detail;
        console.log('Renew policy:', policyId);
    }

    // ──────────────────────────────────────
    //  Event handlers — Detail view
    // ──────────────────────────────────────

    handleBackToList() {
        // Clear stored policy
        localStorage.removeItem(STORAGE_KEY);
        this.selectedPolicyId = undefined;
        this.currentSubView = 'list';

        // Update hash back to policies list
        this.dispatchEvent(
            new CustomEvent('hashupdate', {
                detail: { hash: 'policies' },
                bubbles: true,
                composed: true
            })
        );
    }

    handleBackToDetail() {
        // Restore policy detail from storage and navigate back
        this._restorePolicyFromStorage();
        this.currentSubView = 'detail';

        this.dispatchEvent(
            new CustomEvent('hashupdate', {
                detail: { hash: 'policydetail' },
                bubbles: true,
                composed: true
            })
        );
    }

    // ──────────────────────────────────────
    //  Private helpers
    // ──────────────────────────────────────

    _restorePolicyFromStorage() {
        const storedId = localStorage.getItem(STORAGE_KEY);
        if (storedId) {
            this.selectedPolicyId = storedId;
        } else {
            // No stored ID, fall back to list
            this.currentSubView = 'list';
            this.dispatchEvent(
                new CustomEvent('hashupdate', {
                    detail: { hash: 'policies' },
                    bubbles: true,
                    composed: true
                })
            );
        }
    }

    _buildVehicleName(policy) {
        const parts = [
            policy.Vehicle_Year__c,
            policy.Vehicle_Make__c,
            policy.Vehicle_Model__c
        ].filter(Boolean);
        return parts.length > 0
            ? parts.join(' ')
            : policy.Vehicle_type__c || '';
    }

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
