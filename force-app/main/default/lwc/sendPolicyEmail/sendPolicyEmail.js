import { LightningElement } from 'lwc';

// import sendEmailDocumentAction from '@salesforce/apex/Mex_QuickQuoteCommonController.sendEmailDocumentAction';
// import sendQuoteEmail from '@salesforce/apex/QuickQuotationCtrl.sendQuoteEmail';
import emailServices from '@salesforce/apex/EmailService.emailServices';

export default class SendPolicyEmail extends LightningElement {

    async connectedCallback() {


        emailServices({ 'policyId': 'a0HUj000002MvZZMA0', 'emailService': true })
                        .then((nresult) => {
                            console.log('Email sent', nresult);
                        })
                        .catch((nerr) => {
                            console.log(nerr);
                        });

        // let action = await sendQuoteEmail( 'a0HUj000002MvZZMA0', 'QACDB-25-I9Y8C', '003Uj00000ilZCKIA2', 'atul.rai+testemailfunc@cloudanalogy.com', 'Automobile-Van-Minivan', 'Qualitas')

        // let policyIdSet = ['a0HUj000002MvZZMA0'];
        // let action = await sendEmailDocumentAction({'policyIds':JSON.stringify(policyIdSet)});
        console.log('OUTPUT :action ',action);
    }
}