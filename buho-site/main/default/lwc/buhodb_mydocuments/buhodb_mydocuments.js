import { LightningElement } from 'lwc';

export default class Buhodb_mydocuments extends LightningElement {

    get activePolicyNumber() {
        return 'MEX-2345-2024';
    }

    // Mock policy documents
    get policyDocuments() {
        return [
            {
                id: 'doc1',
                title: 'Insurance Certificate',
                leftDetails: [
                    { id: 'l1', text: 'Policy: MEX-2345-2024' },
                    { id: 'l2', text: 'File: certificate_mex2345.pdf' },
                    { id: 'l3', text: 'Updated: March 15, 2024' },
                    { id: 'l4', text: 'Required for: Mexican authorities, border crossing, claims' },
                    { id: 'l5', text: 'English' }
                ],
                rightDetails: [
                    { id: 'r1', text: 'Active until September 15, 2024' },
                    { id: 'r2', text: 'Created: March 15, 2024' },
                    { id: 'r3', text: '2.3 MB' }
                ]
            },
            {
                id: 'doc2',
                title: 'Policy Terms And Conditions',
                leftDetails: [
                    { id: 'l1', text: 'Policy: MEX-2345-2024' },
                    { id: 'l2', text: 'File: terms_conditions_mex2345.pdf' },
                    { id: 'l3', text: 'English/Spanish' },
                    { id: 'l4', text: '48 pages' },
                    { id: 'l5', text: 'Includes: Coverage limits, exclusions, claims process' }
                ],
                rightDetails: [
                    { id: 'r1', text: 'Complete coverage details' },
                    { id: 'r2', text: 'Created: March 15, 2024' },
                    { id: 'r3', text: '5.7 MB' }
                ]
            },
            {
                id: 'doc3',
                title: 'Payment Confirmation #PYM-8876321',
                leftDetails: [
                    { id: 'l1', text: 'Amount: $612.50' },
                    { id: 'l2', text: 'File: payment_8876321.pdf' },
                    { id: 'l3', text: 'Method: Visa ****4231' },
                    { id: 'l4', text: 'Status' },
                    { id: 'l5', text: 'Tax ID: Available for business expense claims' }
                ],
                rightDetails: [
                    { id: 'r1', text: 'Paid: March 15, 2024' },
                    { id: 'r2', text: 'Receipt' },
                    { id: 'r3', text: '0.8 MB' },
                    { id: 'r4', text: 'Paid in full' }
                ]
            },
            {
                id: 'doc4',
                title: 'Mexico Fishing License Add On',
                leftDetails: [
                    { id: 'l1', text: 'Valid: March 15, 2024 - March 14, 2025' },
                    { id: 'l2', text: 'File: fishing_license_2024.pdf' },
                    { id: 'l3', text: 'Spanish' },
                    { id: 'l4', text: 'Required for: Sport fishing in Mexican waters' },
                    { id: 'l5', text: 'Includes: Regulations and catch limits' }
                ],
                rightDetails: [
                    { id: 'r1', text: '1.2 MB' }
                ]
            }
        ];
    }

    // Mock vehicle specific documents
    get vehicleDocuments() {
        return [
            {
                id: 'vdoc1',
                title: '2023 Tesla Model Y - Document',
                leftDetails: [
                    { id: 'l1', text: 'VIN: 5YJ3E1EB0PF123456' },
                    { id: 'l2', text: 'Vehicle Specification Sheet' },
                    { id: 'l3', text: 'EV Coverage Addendum' },
                    { id: 'l4', text: 'Charging Network Map' }
                ],
                rightDetails: [
                    { id: 'r1', text: 'Active Policy' },
                    { id: 'r2', text: '1.1 MB' },
                    { id: 'r3', text: '0.9 MB' },
                    { id: 'r4', text: '2.3 MB' }
                ]
            },
            {
                id: 'vdoc2',
                title: '2023 Tesla Model Y - Document',
                leftDetails: [
                    { id: 'l1', text: 'VIN: 5YJ3E1EB0PF123456' },
                    { id: 'l2', text: 'Vehicle Specification Sheet' },
                    { id: 'l3', text: 'EV Coverage Addendum' },
                    { id: 'l4', text: 'Charging Network Map' }
                ],
                rightDetails: [
                    { id: 'r1', text: 'Active Policy' },
                    { id: 'r2', text: '1.1 MB' },
                    { id: 'r3', text: '0.9 MB' },
                    { id: 'r4', text: '2.3 MB' }
                ]
            }
        ];
    }

    handleFilterByDates() {
        console.log('Filter by dates');
    }

    handleFilterByStatus() {
        console.log('Filter by status');
    }

    handleDownloadDoc(event) {
        const { documentId } = event.detail;
        console.log('Download document:', documentId);
    }

    handleViewDoc(event) {
        const { documentId } = event.detail;
        console.log('View document:', documentId);
    }

    handleEmailDoc(event) {
        const { documentId } = event.detail;
        console.log('Email document:', documentId);
    }
}
