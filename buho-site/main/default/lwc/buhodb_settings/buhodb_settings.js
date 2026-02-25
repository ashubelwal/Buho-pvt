import { LightningElement } from 'lwc';

export default class Buhodb_settings extends LightningElement {

    // Mock user data – will be replaced with Apex later
    get userData() {
        return {
            name: 'Sarah Conor',
            email: 'sarah.connor@example.com',
            phone: '(555) 867-5309',
            address: 'San Diego, CA 92101',
            dateOfBirth: '05/19/1985',
            paymentMethod: 'Visa ****4231 (Primary)'
        };
    }
}
