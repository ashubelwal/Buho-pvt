// import { LightningElement, wire, track } from 'lwc';
// import getAnnualRenewalReportPartial from '@salesforce/apex/AnnualRenewalReportController.getAnnualRenewalReportPartial';

// export default class AnnualRenewalReport extends LightningElement {
//     @track data = [];
//     @track error;

//     @wire(getAnnualRenewalReportPartial)
//     wiredReport({ error, data }) {
//         if (data) {
//             this.error = undefined;
//             this.data = data.map(row => {
//                 const pct = row.targetRenewal > 0 ? (row.renewed / row.targetRenewal) * 100 : 0;
//                 const pctLimited = pct > 100 ? 100 : pct;
//                 return {
//                     ...row,
//                     monthName: this.monthName(row.month),
//                     renewedPct: pctLimited,
//                     renewedPctFormatted: pctLimited.toFixed(2) + '%'
//                 };
//             });
//         } else if (error) {
//             this.error = error.body ? error.body.message : error;
//             this.data = [];
//         }
//     }

//     monthName(monthNum) {
//         const months = ['January', 'February', 'March', 'April', 'May', 'June', 
//                         'July', 'August', 'September', 'October', 'November', 'December'];
//         return months[monthNum - 1] || 'Unknown';
//     }
// }

import { LightningElement, wire, track } from 'lwc';
import getAnnualRenewalReportPartial from '@salesforce/apex/AnnualRenewalReportController.getAnnualRenewalReportPartial';

export default class AnnualRenewalReport extends LightningElement {
    @track data = [];
    @track error;

    @wire(getAnnualRenewalReportPartial)
    wiredReport({ error, data }) {
        if (data) {
            this.error = undefined;
            this.data = data.map(row => {
                const renewedPct = row.targetRenewal > 0 ? (row.renewed / row.targetRenewal) * 100 : 0;
                const ineligiblePct = row.targetRenewal > 0 ? (row.ineligible / row.targetRenewal) * 100 : 0;
                const pendingPct = row.targetRenewal > 0 ? (row.pending / row.targetRenewal) * 100 : 0;
                const lostPct = row.targetRenewal > 0 ? (row.lost / row.targetRenewal) * 100 : 0;

                const renewedPctLimited = renewedPct > 100 ? 100 : renewedPct;
                const ineligiblePctLimited = ineligiblePct > 100 ? 100 : ineligiblePct;
                const pendingPctLimited = pendingPct > 100 ? 100 : pendingPct;
                const lostPctLimited = lostPct > 100 ? 100 : lostPct;

                return {
                    ...row,
                    displayMonthName: (row.month === null || row.month === undefined) ? 'Total' : this.monthName(row.month),
                    renewedPctFormatted: renewedPctLimited.toFixed(2) + '%',
                    ineligiblePctFormatted: ineligiblePctLimited.toFixed(2) + '%',
                    pendingPctFormatted: pendingPctLimited.toFixed(2) + '%',
                    lostPctFormatted: lostPctLimited.toFixed(2) + '%',
                    rowKey: row.month === null ? 'total' : row.month,
                    rowClass: row.month === null ? 'total-row' : ''
                };
            });
        } else if (error) {
            this.error = error.body ? error.body.message : error;
            this.data = [];
        }
    }

    monthName(monthNum) {
        const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                        'July', 'August', 'September', 'October', 'November', 'December'];
        if (!monthNum || monthNum < 1 || monthNum > 12) {
            return 'Total';
        }
        return months[monthNum - 1];
    }

}