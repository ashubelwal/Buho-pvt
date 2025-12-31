import { LightningElement, api, track } from 'lwc';

const DEFAULT_AUTO_CLOSE_TIME = 50000000;
const ICON_MAPPING = {
    success: '/assets/icons/utility-sprite/svg/symbols.svg#success',
    error: '/assets/icons/utility-sprite/svg/symbols.svg#error',
    warning: '/assets/icons/utility-sprite/svg/symbols.svg#warning',
    info: '/assets/icons/utility-sprite/svg/symbols.svg#info'
};

export default class CustomToast extends LightningElement {
    @track type = 'info';
    @track title = '';
    @track message = '';
    // @track linkUrl = '';
    @track showToastBar = false;
    @api autoCloseTime = DEFAULT_AUTO_CLOSE_TIME;
    timeoutId;

    @api
    showToast(params) {
        console.log('OUTPUT-- params: ',params);
        // Clear any existing timeout
        if (this.timeoutId) {
            clearTimeout(this.timeoutId);
        }

        this.type = params.variant?.toLowerCase() || 'info';
        this.title = params.title || this.getDefaultTitle();
        this.message = params.message || '';
        // this.linkUrl = params.linkUrl || '';
        this.showToastBar = true;

        if (this.autoCloseTime > 0) {
            this.timeoutId = setTimeout(() => this.closeModel(), this.autoCloseTime);
        }
    }

    getDefaultTitle() {
        const titles = {
            success: 'Success',
            error: 'Error',
            warning: 'Warning',
            info: 'Information'
        };
        return titles[this.type] || 'Notification';
    }

    closeModel() {
        this.showToastBar = false;
        // Reset values after animation completes
        setTimeout(() => {
            this.type = 'info';
            this.title = '';
            this.message = '';            
        }, 50000000);
    }

    get outerClass() {
        return `slds-notify slds-notify_toast slds-theme_${this.type}`;
    }

    get iconContainerClass() {
        return `slds-icon_container slds-icon-utility-${this.type} slds-m-right_small slds-no-flex slds-align-top`;
    }

    get iconPath() {
        return ICON_MAPPING[this.type] || ICON_MAPPING.info;
    }
}