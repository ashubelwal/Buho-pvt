import { LightningElement, api, track } from 'lwc';

export default class Agent_toast extends LightningElement {
    @track isVisible = false;
    @track variant = 'info'; // success, error, warning, info
    @track title = '';
    @track message = '';
    
    autoCloseTime = 5000; // 5 seconds default

    get toastClass() {
        return `agent-toast agent-toast-${this.variant}`;
    }

    get isSuccess() {
        return this.variant === 'success';
    }

    get isError() {
        return this.variant === 'error';
    }

    get isWarning() {
        return this.variant === 'warning';
    }

    get isInfo() {
        return this.variant === 'info';
    }

    @api
    showToast(config) {
        this.variant = config.variant || 'info';
        this.title = config.title || '';
        this.message = config.message || '';
        this.isVisible = true;

        // Auto close after specified time
        const closeTime = config.duration || this.autoCloseTime;
        if (closeTime > 0) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.handleClose();
            }, closeTime);
        }
    }

    @api
    handleClose() {
        this.isVisible = false;
    }
}
