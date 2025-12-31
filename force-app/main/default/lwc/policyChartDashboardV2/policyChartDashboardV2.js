import { LightningElement, track, wire, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import getPolicyDataforPieChart from '@salesforce/apex/AgentAppChart.getPolicyDataforPieChart';
import getPolicyDataforBarChart from '@salesforce/apex/AgentAppChart.getPolicyDataforBarChart';
import getPolicyDataBarChartNetValue from '@salesforce/apex/AgentAppChart.getPolicyDataforBarChartNetPremium';
import getPolicyDataBarChartNetValueComission from '@salesforce/apex/AgentAppChart.getPolicyDataforBarChartNetPremiumComission';
import CHART_JS from '@salesforce/resourceUrl/ChartJs';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['User.Profile.Name'];

export default class PolicyChartDashboardV2 extends LightningElement {
    @track userId = USER_ID;
    @track chartData = [];
    @track barChartData = [];
    @track netValueBarChartData = [];
    @track netValueBarChartDataComission = [];
    @track selectedPolicyType = '';
    @track isAgency = false;
    @track isChartJsInitialized = false;
    @track isPolicyForRenew = true;
    @track isPolicyForNew = true;
    pieChartNew;
    pieChartRenew;
    barChart;
    barChartValueData;
    barChartComissionData;
    debug = false;

    policyOptions = [
        { label: 'Weekly', value: 'THIS_WEEK' },
        { label: 'Monthly', value: 'THIS_MONTH' },
        { label: 'Quarterly', value: 'THIS_QUARTER' },
        { label: 'Annual', value: 'THIS_YEAR' }
    ];

    @wire(getRecord, { recordId: '$userId', fields: FIELDS })
    userRecord({ error, data }) {
        if (data) {
            let profileName = data.fields?.Profile?.displayValue || data.field?.Profile?.value?.fields?.Name?.value;
            this.isAgency = profileName === 'Agency Community Plus Login User';
        } else if (error) {
            if(this.debug) console.error('Error fetching user profile:', error);
        }
    }

    connectedCallback() {
        this.loadInitialData();
    }

    async loadInitialData() {
        await Promise.all([this.fetchPolicyDataForChart(''), this.fetchPolicyDataForBarChart(''),
        this.fetchPolicyDataBarChartNetValue(''), this.fetchPolicyDataBarChartNetValueComission('')]);
        this.renderCharts();
    }

    renderedCallback() {
        if (this.isChartJsInitialized) return; 

        loadScript(this, CHART_JS)
            .then(() => {
                    this.isChartJsInitialized = true;
                    this.renderCharts();
                })
            .catch((error) => {
                if(this.debug) console.error('Error loading Chart.js:', error);
            });
    }

    handlePolicyChange(event) {
        this.selectedPolicyType = event.detail.value;
        this.loadPolicyData();
    }

    async loadPolicyData() {
        await Promise.all([this.fetchPolicyDataForChart(this.selectedPolicyType),
        this.fetchPolicyDataForBarChart(this.selectedPolicyType),
        this.fetchPolicyDataBarChartNetValue(this.selectedPolicyType),
        this.fetchPolicyDataBarChartNetValueComission(this.selectedPolicyType)]);
        this.renderCharts();
    }

    fetchPolicyDataForChart(policyType) {
        if (!this.userId) {
            return 'Id is missing';
        }

        return getPolicyDataforPieChart({ policyTerm: policyType, userId: this.userId })
            .then((data) => {
                this.chartData = data || [];
                if(this.debug) console.log('Pie Chart Data:::', data);
            })
            .catch((error) => {
                if(this.debug) console.error('Error fetching pie chart data:', error);
            });
    }

    fetchPolicyDataForBarChart(policyType) {
        if (!this.userId) {
            return 'Id is missing.';
        }

        return getPolicyDataforBarChart({ policyTerm: policyType, userId: this.userId })
            .then((data) => {
                if(this.debug) console.log('Bar Chart Data:::', data);
                this.barChartData = data || [];
                if(this.debug) console.log('barChartData Data:::', this.barChartData);
            })
            .catch((error) => {
                if(this.debug) console.error('Error fetching bar chart data:', error);
            });
    }

    fetchPolicyDataBarChartNetValue(policyType) {
        if (!this.userId) {
            return 'Id is missing.';
        }


        return getPolicyDataBarChartNetValue({ policyTerm: policyType, userId: this.userId })
            .then((data) => {
                if(this.debug) console.log('Bar Chart Data:::', data);
                // if(this.debug) console.log('Net Value Bar Chart Data:::', data);
                this.netValueBarChartData = data || [];
                if(this.debug) console.log('barChartData Data:::', this.netValueBarChartData);
            })
            .catch((error) => {
                if(this.debug) console.error('Error fetching net value bar chart data:', error);
            });
    }
    fetchPolicyDataBarChartNetValueComission(policyType) {
        if (!this.userId) {
            return 'Id is missing.';
        }


        return getPolicyDataBarChartNetValueComission({ policyTerm: policyType, userId: this.userId })
            .then((data) => {
                if(this.debug) console.log('Bar Chart Data:::', data);
                // if(this.debug) console.log('Net Value Bar Chart Data:::', data);
                this.netValueBarChartDataComission = data || [];
                if(this.debug) console.log('barChartData Data:::', this.netValueBarChartDataComission);
            })
            .catch((error) => {
                if(this.debug) console.error('Error fetching net value bar chart data:', error);
            });
    }

    async renderCharts() {
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
        if(this.debug) console.log('policyCountsForRenew:::', policyCountsForRenew);
        if (policyCountsForRenew != null) {

            let pieCtxRenew = this.template.querySelector('canvas[data-id="pie-chartrenew"]').getContext('2d');

            let policyRenewTypes = policyTypes.map((type) => `${type} Renew`);
            if (this.pieChartRenew) this.pieChartRenew.destroy();
            this.pieChartRenew = new Chart(pieCtxRenew, {
                type: 'pie',
                data: {
                    labels: policyRenewTypes,
                    datasets: [{
                        data: policyCountsForRenew,
                        backgroundColor: [
                            '#FF6384', // Pink-Red
                            '#36A2EB', // Blue
                            '#FFCE56', // Yellow
                            '#4BC0C0', // Teal
                            '#9966FF', // Purple
                            '#FF9F40', // Orange
                            '#2ECC71'  // Green
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Quantity of Policies by Type',
                            font: {
                                size: 16
                            }
                        }
                    }
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
                    datasets: [{
                        data: policyCountsForNew,
                        backgroundColor: [
                            '#FF6384', // Pink-Red
                            '#36A2EB', // Blue
                            '#FFCE56', // Yellow
                            '#4BC0C0', // Teal
                            '#9966FF', // Purple
                            '#FF9F40', // Orange
                            '#2ECC71'  // Green
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Quantity of Policies by Type',
                            font: {
                                size: 16
                            }
                        }
                    }
                },
            });

        } else {
            this.isPolicyForRenew = false;
        }

        // Render Bar Chart
        // if (this.isAgency) {
        //     if (!this.barChartData.length) {
        //         this.isAgency = false;
        //         return;
        //     }

        //     let barCtx = this.template.querySelector('canvas[data-id="bar-chart"]').getContext('2d');
        //     let barLabels = this.barChartData.map((item) => item.Policy_Type_picklist__c);
        //     let barData = this.barChartData.map((item) => item.totalCount);

        //     if (this.barChart) this.barChart.destroy();

        //     this.barChart = new Chart(barCtx, {
        //         type: 'bar',
        //         data: {
        //             labels: barLabels,
        //             datasets: [{ label: 'Policies Total Commission', data: barData, backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56'] }]
        //         },
        //         options: {
        //             scales: {
        //                 y: {
        //                     beginAtZero: true,
        //                 },
        //             },
        //             responsive: true,
        //             maintainAspectRatio: false,
        //         },
        //     });
        // }
        // Render Net Value Bar Chart
        if (this.isAgency) {
            if (!this.netValueBarChartData.length) {
                this.isAgency = false;
                return;
            }

            let barCtx = this.template.querySelector('canvas[data-id="bar-chart-net"]').getContext('2d');
            let barLabels = this.netValueBarChartData.map((item) => item.Policy_Type_picklist__c);
            let barData = this.netValueBarChartData.map((item) => item.totalCount);

            if (this.barChartValueData) this.barChartValueData.destroy();

            this.barChartValueData = new Chart(barCtx, {
                type: 'bar',
                data: {
                    labels: barLabels,
                    datasets: [{ label: 'Policies Total Net', data: barData, backgroundColor: [
                            '#FF6384', // Pink-Red
                            '#36A2EB', // Blue
                            '#FFCE56', // Yellow
                            '#4BC0C0', // Teal
                            '#9966FF', // Purple
                            '#FF9F40', // Orange
                            '#2ECC71'  // Green
                        ] }]
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

        // Render Net Value Bar Chart Comission
        if (this.isAgency) {
            if (!this.netValueBarChartDataComission.length) {
                this.isAgency = false;
                return;
            }

            let barCtx = this.template.querySelector('canvas[data-id="bar-chart-net-commission"]').getContext('2d');
            let barLabels = this.netValueBarChartDataComission.map((item) => item.Policy_Type_picklist__c);
            let barData = this.netValueBarChartDataComission.map((item) => item.totalCount);

            if (this.barChartComissionData) this.barChartComissionData.destroy();

            this.barChartComissionData = new Chart(barCtx, {
                type: 'bar',
                data: {
                    labels: barLabels,
                    datasets: [{ label: 'Policies Total Net Comission', data: barData, backgroundColor: [
                            '#FF6384', // Pink-Red
                            '#36A2EB', // Blue
                            '#FFCE56', // Yellow
                            '#4BC0C0', // Teal
                            '#9966FF', // Purple
                            '#FF9F40', // Orange
                            '#2ECC71'  // Green
                        ] }]
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