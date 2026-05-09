import { LightningElement, track, wire } from 'lwc';
import buhoAssets from '@salesforce/resourceUrl/buhoAssets';
import getUserPolicies from '@salesforce/apex/BuhoDashboardController.getUserPolicies';
import getUserVehicles from '@salesforce/apex/BuhoDashboardController.getUserVehicles';
import getUserName from '@salesforce/apex/BuhoDashboardController.getUserName';

const STORAGE_KEY = 'buhoPolicyDetailId';

export default class Buhodb_dashboardlanding extends LightningElement {
    @track userName = '';
    @track allPolicies = [];
    @track allVehicles = [];
    @track error;

    // Carousel tracking
    @track currentPolicyIndex = 0;
    @track currentVehicleIndex = 0;

    // Wire user name
    @wire(getUserName)
    wiredUserName({ error, data }) {
        if (data) {
            this.userName = data;
        } else if (error) {
            console.error('Error fetching user name:', error);
            this.userName = '';
        }
    }

    // Wire policies from Apex
    @wire(getUserPolicies)
    wiredPolicies({ error, data }) {
        if (data) {
            this.allPolicies = data;
            this.error = undefined;
            this.currentPolicyIndex = 0;
        } else if (error) {
            this.error = error;
            this.allPolicies = [];
            console.error('Error fetching policies:', error);
        }
    }

    // Wire vehicles from Apex
    @wire(getUserVehicles)
    wiredVehicles({ error, data }) {
        if (data) {
            this.allVehicles = data;
            this.currentVehicleIndex = 0;
        } else if (error) {
            this.allVehicles = [];
            console.error('Error fetching vehicles:', error);
        }
    }

    // ── Computed: active policies only ──
    get activePolicyList() {
        return this.allPolicies.filter(
            (p) => p.Status_picklist__c === 'Active'
        );
    }

    // ── Stats ──
    get activePolicies() {
        const count = this.activePolicyList.length;
        return count < 10 ? '0' + count : String(count);
    }

    get daysRemaining() {
        const today = new Date();
        let minDays = null;

        this.activePolicyList.forEach((p) => {
            if (p.End_Date__c) {
                const endDate = new Date(p.End_Date__c);
                const diff = Math.ceil(
                    (endDate - today) / (1000 * 60 * 60 * 24)
                );
                if (diff > 0 && (minDays === null || diff < minDays)) {
                    minDays = diff;
                }
            }
        });

        return minDays !== null ? String(minDays) : '0';
    }

    // ── Asset URLs ──
    get clockIconUrl() {
        return `${buhoAssets}/images/clockicon.svg`;
    }

    get carIconUrl() {
        return `${buhoAssets}/images/caricon.svg`;
    }

    get policyIconUrl() {
        return `${buhoAssets}/images/mypoliciesicon.svg`;
    }

    get plusIconUrl() {
        return `${buhoAssets}/images/plus-icon.svg`;
    }

    // ── Policy carousel data ──
    get mappedPolicies() {
        return this.activePolicyList.map((p) => ({
            id: p.Id,
            vehicleType: this._buildPolicyVehicleName(p),
            policyNumber: p.Reference_number__c || p.Name,
            activeUntil: this._formatDate(p.End_Date__c),
            coverage: p.Package__c || '',
            premium: this._formatCurrency(p.Total_Premium_Amount__c),
            paymentType: p.Term__c || ''
        }));
    }

    get policyData() {
        const policies = this.mappedPolicies;
        if (policies.length === 0) {
            return {};
        }
        return policies[this.currentPolicyIndex] || {};
    }

    get totalPolicies() {
        return this.mappedPolicies.length;
    }

    get policyCounter() {
        if (this.totalPolicies === 0) return '0 / 0';
        return `${this.currentPolicyIndex + 1} / ${this.totalPolicies}`;
    }

    get isFirstPolicy() {
        return this.currentPolicyIndex === 0;
    }

    get isLastPolicy() {
        return (
            this.totalPolicies === 0 ||
            this.currentPolicyIndex === this.totalPolicies - 1
        );
    }

    // ── Vehicle carousel data (from Vehicle__c records) ──
    get mappedVehicles() {
        return this.allVehicles.map((v) => ({
            id: v.Id,
            name: this._buildVehicleName(v),
            vin: v.Vin__c || '',
            plate: this._buildPlate(v),
            value: this._formatCurrency(v.Value__c),
            surcharge: this._formatCurrency(
                v.Policy__r ? v.Policy__r.Surcharge__c : null
            ),
            primaryDriver: v.Vehicle_Owner_Name__c || '',
            added: this._formatDateTime(v.Created_At__c)
        }));
    }

    get vehicleData() {
        const vehicles = this.mappedVehicles;
        if (vehicles.length === 0) {
            return {};
        }
        return vehicles[this.currentVehicleIndex] || {};
    }

    get totalVehicles() {
        return this.mappedVehicles.length;
    }

    get vehicleCounter() {
        if (this.totalVehicles === 0) return '0 / 0';
        return `${this.currentVehicleIndex + 1} / ${this.totalVehicles}`;
    }

    get isFirstVehicle() {
        return this.currentVehicleIndex === 0;
    }

    get isLastVehicle() {
        return (
            this.totalVehicles === 0 ||
            this.currentVehicleIndex === this.totalVehicles - 1
        );
    }

    // ── Recent documents (static for now) ──
    get recentDocuments() {
        return [
            {
                id: '1',
                name: 'Insurance Certificate',
                policyNumber: 'MEX-2345-2024',
                type: 'PDF',
                action: 'Downloaded',
                date: 'March 15, 2024',
                size: '2.3MB'
            },
            {
                id: '2',
                name: 'Policy Terms & Conditions',
                policyNumber: 'MEX-2345-2024',
                type: 'PDF',
                action: 'Viewed',
                date: 'March 15, 2024',
                size: '5.7MB'
            },
            {
                id: '3',
                name: 'Payment Confirmation #PYM-887632',
                amount: '$612.50',
                date: 'March 15, 2024',
                card: 'Visa •••4231'
            },
            {
                id: '4',
                name: 'Mexico Fishing License Add-on',
                purchased: 'March 15, 2024',
                validUntil: 'March 14, 2025'
            }
        ];
    }

    // ── Helpful resources (static for now) ──
    get helpfulResources() {
        return [
            {
                id: '1',
                title: 'Border Crossing Checklist',
                description:
                    "Make sure you're prepared before you cross the border",
                action: 'Read the guide'
            },
            {
                id: '2',
                title: 'Fishing Permit',
                description:
                    'Get your fishing permit for your next trip to Mexico',
                action: 'Learn more'
            },
            {
                id: '3',
                title: 'What to Bring (and What NOT to Bring)',
                description: '',
                action: 'Check the full guide'
            },
            {
                id: '4',
                title: 'FMM Permit',
                description: 'Required for most travelers entering Mexico',
                action: 'Get your permit'
            }
        ];
    }

    // ── Event handlers ──
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

    handleDownloadDocuments() {
        console.log('Download documents');
    }

    handleRenew() {
        console.log('Renew policy');
    }

    handleAddPolicy() {
        this.dispatchEvent(
            new CustomEvent('hashupdate', {
                detail: { hash: 'newpolicy' },
                bubbles: true,
                composed: true
            })
        );
    }

    handleEditVehicle(event) {
        const vehicleId = event.currentTarget.dataset.id;
        console.log('Edit vehicle:', vehicleId);
    }

    // Policy carousel navigation
    handlePreviousPolicy() {
        if (this.currentPolicyIndex > 0) {
            this.currentPolicyIndex--;
        }
    }

    handleNextPolicy() {
        if (this.currentPolicyIndex < this.totalPolicies - 1) {
            this.currentPolicyIndex++;
        }
    }

    // Vehicle carousel navigation
    handlePreviousVehicle() {
        if (this.currentVehicleIndex > 0) {
            this.currentVehicleIndex--;
        }
    }

    handleNextVehicle() {
        if (this.currentVehicleIndex < this.totalVehicles - 1) {
            this.currentVehicleIndex++;
        }
    }

    // ── Private helpers ──
    _buildPolicyVehicleName(policy) {
        const parts = [
            policy.Vehicle_Year__c,
            policy.Vehicle_Make__c,
            policy.Vehicle_Model__c
        ].filter(Boolean);
        return parts.length > 0
            ? parts.join(' ')
            : policy.Vehicle_type__c || '';
    }

    _buildVehicleName(v) {
        const parts = [v.Year__c, v.Make__c, v.Model__c].filter(Boolean);
        return parts.length > 0
            ? parts.join(' ')
            : v.Vehicle_Type__c || '';
    }

    _buildPlate(v) {
        if (!v.Registered_Plate__c) return '';
        const state = v.Registered_State__c
            ? ` (${v.Registered_State__c})`
            : '';
        return `${v.Registered_Plate__c}${state}`;
    }

    _formatDate(dateValue) {
        if (!dateValue) return '';
        const d = new Date(dateValue + 'T00:00:00');
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return d.toLocaleDateString('en-US', options);
    }

    _formatDateTime(dateValue) {
        if (!dateValue) return '';
        const d = new Date(dateValue);
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
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
