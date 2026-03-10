import { LightningElement } from 'lwc';

export default class GobuhoLanding extends LightningElement {
    get currentYear() {
        return new Date().getFullYear();
    }

    // URL EXTERNAL
    get logoUrl() {
        return 'https://gobuho.com/wp-content/uploads/2025/11/Owl.webp';
    }

    // import logo from '@salesforce/resourceUrl/BuhoLogo';
    // get logoUrl() {
    //     return logo;
    // }
}