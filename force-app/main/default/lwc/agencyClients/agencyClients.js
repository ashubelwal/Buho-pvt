import { LightningElement, track, api } from 'lwc';
import USER_ID from "@salesforce/user/Id";
import getDataByObj from '@salesforce/apex/AgentAppController.getDataByObj';
export default class AgencyClients extends LightningElement {
    customTableData = [];
    userId = USER_ID;
    @api cmpSource;
    @track boolean = { isTableData: false };
    actionLeadbuttons = [{ label: 'Resume', name: 'Resume' }];
    searchValue = '';

    columns = [
        { label: 'Company', fieldName: 'Company' },
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Agency', fieldName: 'Agency' },
        { label: 'Agent', fieldName: 'Agent' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { type: 'action', typeAttributes: { rowActions: this.actionLeadbuttons } }
    ];


    searchKeyword(event) {
        this.searchValue = event.target.value;
        console.log('SEARCH HANDLE ::: : ', this.searchValue);
        if (this.searchValue !== '') {
            console.log('SEARCH HANDLE IF : ');
            getDataByObj({ leadName: this.searchValue, userId: this.userId }).then(result => {
                this.customTableData = result;
                console.log('SEARCH HANDLE result ::: ', result);
            });
            console.log('SEARCH HANDLE IF DATA: ', this.customTableData);
        } else {
            console.log('SEARCH HANDLE ELSE : ');
            this.connectedCallback();
        }
    }

    connectedCallback() {
        console.log('USER_ID sdf', this.userId);
        getDataByObj({ leadName: '', userId: this.userId })
            .then(result => {
                console.log(result);
                this.boolean.isTableData = true;
                this.customTableData = result;
            })
            .catch(err => {
                console.log(err);

            })
    }

    handleLeadRowAction(event) {
        const actionName = event.detail.action.name;
        let row = event.detail.row.Id;
        console.log('currentUrl', window.location.origin);
        console.log('event ', event);
        console.log('Lead Row ', row);

        if (actionName == 'Resume') {
            let currentUrl = window.location.origin;
            if (this.cmpSource == 'comm') {
                location.replace(`${currentUrl}/agency/quick-quote?c__contactId=${row}&c__actionmode=resumeLead`);
            } else {
                location.replace(`${currentUrl}/lightning/n/Quick_Quote?c__contactId=${row}&c__actionmode=resumeLead`);
            }
        }

    }

}