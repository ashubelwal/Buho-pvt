import { LightningElement, api, track } from 'lwc';

export default class Buho_accordion extends LightningElement {
    @api coverageList = [];
    @track expandedItems = {};

    toggleItem(event) {
        const key = event.currentTarget.dataset.key;
        this.expandedItems = {
            ...this.expandedItems,
            [key]: !this.expandedItems[key]
        };
    }

    isExpanded(key) {
        return this.expandedItems[key] || false;
    }

    get processedCoverageList() {
        return this.coverageList.map(item => ({
            ...item,
            isExpanded: this.isExpanded(item.key),
            expandIconClass: this.isExpanded(item.key) ? 'expand-icon expanded' : 'expand-icon'
        }));
    }
}

