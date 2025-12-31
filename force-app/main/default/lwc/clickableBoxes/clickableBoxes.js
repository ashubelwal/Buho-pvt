import { LightningElement } from 'lwc';

export default class GridColumn extends LightningElement {
    items = [
        { id: 1, name: 'GENERAL', url: '/supportcenter/s/generaltopics' },
        { id: 2, name: 'WEBSITE', url: '/supportcenter/s/websiteknowledges' },
        { id: 3, name: 'COVERAGE AND CLAIMS', url: '/supportcenter/s/coverageandclaimsknowledges' }
    ];
}