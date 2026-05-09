import { LightningElement, track, wire, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import getPolicyDataforPieChart from '@salesforce/apex/AgentAppController.getPolicyDataforPieChart';
import getPolicyDataforBarChart from '@salesforce/apex/AgentAppController.getPolicyDataforBarChart';
import CHART_JS from '@salesforce/resourceUrl/ChartJs';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['User.Profile.Name'];

export default class PolicyChartDashboard extends LightningElement {
    @track userId = USER_ID;
    @track chartData = [];
    @track barChartData = [];
    @track selectedPolicyType = '';
    @track isAgency = false;
    @track isChartJsInitialized = false;
    @track isPolicyForRenew = true;
    @track isPolicyForNew = true;
    pieChartNew;
    pieChartRenew;
    barChart;

    policyOptions = [
        { label: 'Weekly', value: 'THIS_WEEK' },
        { label: 'Monthly', value: 'THIS_MONTH' },
        { label: 'Quarterly', value: 'THIS_QUARTER' },
        { label: 'Annual', value: 'THIS_YEAR' }
    ];

    @wire(getRecord, { recordId: '$userId', fields: FIELDS })
    userRecord({ error, data }) {
        if (data) {
            let profileName = data.fields.Profile.displayValue || data.fields.Profile.value.fields.Name.value;
            this.isAgency = profileName === 'Agency Community Plus Login User';
        } else if (error) {
            console.error('Error fetching user profile:', error);
        }
    }

    connectedCallback() {
        this.loadInitialData();
    }

    async loadInitialData() {
        await Promise.all([this.fetchPolicyDataForChart(''), this.fetchPolicyDataForBarChart('')]);
        console.log('Initial Data Loaded');
        this.renderCharts();
    }

    renderedCallback() {
        if (!this.isChartJsInitialized) {
            loadScript(this, CHART_JS)
                .then(() => {
                    this.isChartJsInitialized = true;
                    this.renderCharts();
                })
                .catch((error) => {
                    console.error('Error loading Chart.js:', error);
                });
        }
    }

    handlePolicyChange(event) {
        this.selectedPolicyType = event.detail.value;
        this.loadPolicyData();
    }

    async loadPolicyData() {
        await Promise.all([this.fetchPolicyDataForChart(this.selectedPolicyType), this.fetchPolicyDataForBarChart(this.selectedPolicyType)]);
        this.renderCharts();
    }

    fetchPolicyDataForChart(policyType) {
        return getPolicyDataforPieChart({ policyTerm: policyType, userId: this.userId })
            .then((data) => {
                this.chartData = data || [];
                console.log('Pie Chart Data:::', data);
            })
            .catch((error) => {
                console.error('Error fetching pie chart data:', error);
            });
    }

    fetchPolicyDataForBarChart(policyType) {
        return getPolicyDataforBarChart({ policyTerm: policyType, userId: this.userId })
            .then((data) => {
                console.log('Bar Chart Data:::', data);
                this.barChartData = data || [];
                console.log('barChartData Data:::', this.barChartData);
            })
            .catch((error) => {
                console.error('Error fetching bar chart data:', error);
            });
    }

    async renderCharts() {
        console.log('renderCharts');
        if (!this.isChartJsInitialized || !this.chartData.length) {
            return;
        }

        let policyTypes = [...new Set(this.chartData.map((policy) => policy.Policy_Type_picklist__c))];

        let policyCountsForRenew = await Promise.all(
            policyTypes.map(async (type) => {
                const policy = this.chartData.find((policy) =>
                    policy.Policy_Type_picklist__c === type && policy.renewed_check__c
                );
                return policy ? policy.totalCount : null;
            })
        ).then((result) => result.every(count => count === null) ? null : result);


        let policyCountsForNew = await Promise.all(
            policyTypes.map(async (type) => {
                const policy = this.chartData.find((policy) => policy.Policy_Type_picklist__c === type && !policy.renewed_check__c);
                return policy ? policy.totalCount : 0;
            })
        ).then((result) => result.every(count => count === null) ? null : result);

        // Render Pie Charts
        console.log('policyCountsForRenew:::', policyCountsForRenew);
        if (policyCountsForRenew != null) {

            let pieCtxRenew = this.template.querySelector('canvas[data-id="pie-chartrenew"]').getContext('2d');

            let policyRenewTypes = policyTypes.map((type) => `${type} Renew`);
            if (this.pieChartRenew) this.pieChartRenew.destroy();
            this.pieChartRenew = new Chart(pieCtxRenew, {
                type: 'pie',
                data: {
                    labels: policyRenewTypes,
                    datasets: [{ data: policyCountsForRenew, backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56'] }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                },
            });
        } else {
            this.isPolicyForRenew = false;
        }

        if (policyCountsForNew != null) {
            let pieCtxNew = this.template.querySelector('canvas[data-id="pie-chart"]').getContext('2d');
            if (this.pieChartNew) this.pieChartNew.destroy();

            this.pieChartNew = new Chart(pieCtxNew, {
                type: 'pie',
                data: {
                    labels: policyTypes,
                    datasets: [{ data: policyCountsForNew, backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56'] }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                },
            });
        } else {
            this.isPolicyForRenew = false;
        }

        // Render Bar Chart
        if (this.isAgency) {
            if (!this.barChartData.length) {
                this.isAgency = false;
                return;
            }

            let barCtx = this.template.querySelector('canvas[data-id="bar-chart"]').getContext('2d');
            let barLabels = this.barChartData.map((item) => item.Policy_Type_picklist__c);
            let barData = this.barChartData.map((item) => item.totalCount);

            if (this.barChart) this.barChart.destroy();

            this.barChart = new Chart(barCtx, {
                type: 'bar',
                data: {
                    labels: barLabels,
                    datasets: [{ label: 'Policies Commission', data: barData, backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56'] }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true,
                        },
                    },
                    responsive: true,
                    maintainAspectRatio: false,
                },
            });
        }
    }
}