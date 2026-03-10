import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTimeZone from '@salesforce/apex/Mex_NewLeadProcess.getTimeZone';
import preViewPdfAction from '@salesforce/apex/Mex_PolicyEditController.preViewPdfAction';
import getEditPolicyDetail from '@salesforce/apex/Mex_PolicyEditController.getEditPolicyDetail';
import Displaypolicy from '@salesforce/label/c.TR_Display_Policy';
import RenewPolicy from '@salesforce/label/c.TR_Renew_Policy';
import Edit from '@salesforce/label/c.TR_Edit';
import Terminate from '@salesforce/label/c.TR_Terminate';
import Oursystemfoundsome from '@salesforce/label/c.TR_Our_system_found_some_problem_Kindly_try_again_later_Sorry_for_the_inconv';
import generateGreenCardfromPolicyId from '@salesforce/apex/PolicyDocumentGenerator.generateGreenCardfromPolicyId';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';

export default class Nc_policyCustomButtonComponent extends NavigationMixin(LightningElement) {
 label = {
       Displaypolicy,RenewPolicy,Edit,Terminate,Oursystemfoundsome,
    };
    @api PageName;
    @api recordId;
    policyExpiredOrTerminated;
    homeownersPolicy = false;
    renewPolicyDisabled = false;
    spinner = false;
    @track
    isDisableYellowCard = false;
    isHiddenRenewButton = false;

    get isDisabled() {
        return this.policyExpiredOrTerminated == 'Expired' || this.policyExpiredOrTerminated == 'Terminated' || this.policyExpiredOrTerminated == 'Updated' || this.policyExpiredOrTerminated == 'Fully Earned';
    }

    get isRenewBtnDisabled() {
        return this.renewPolicyDisabled;
    }

    get isHomeownersPolicy() {
        return this.homeownersPolicy;
    }

    async connectedCallback() {
        console.log('printing connected');
        if (this.recordId != null) {
            console.log(this.recordId);
            await this.fetchPolicyData();
        }
    }

    fetchPolicyData = async () => {
        try {
            this.spinner = true;
            const systemTime = await getTimeZone();
            
            const { status, ...rest } = await getEditPolicyDetail({ 'policyId': this.recordId });

            console.log('policy-> '+JSON.stringify(rest));
            if(rest && rest?.policyData && rest.policyData?.Policy_Type_picklist__c && rest.policyData.Policy_Type_picklist__c == 'Northbound'){
                this.isDisableYellowCard = true;
                this.isHiddenRenewButton = true;
            }

            if (rest.policyData.Policy_Type_picklist__c == 'Homeowners') {
                this.homeownersPolicy = true;
                this.spinner = false;
                return;
            }
            let systemCurrentYear = new Date(systemTime.dtPST).getFullYear();
            let systemCurrentMonth = (parseInt(new Date(systemTime.dtPST).getMonth()) + 1) < 10 ? '0' + (parseInt(new Date(systemTime.dtPST).getMonth()) + 1) : parseInt(new Date(systemTime.dtPST).getMonth()) + 1;
            let systemCurrentDate = new Date(systemTime.dtPST).getDate() < 10 ? '0' + new Date(systemTime.dtPST).getDate() : new Date(systemTime.dtPST).getDate();

            if (status == 'success') {
                console.log(JSON.stringify(rest));
                this.policyExpiredOrTerminated = rest.policyData.Status_picklist__c;
                this.spinner = false;
                const timeNow = new Date();
                if ((parseInt(new Date(rest.policyData?.Issued_At__c).getFullYear()) <= 2019) || (rest?.policyData?.Status_picklist__c == 'Updated' || rest?.policyData?.Status_picklist__c == 'Terminated' || new Date(rest?.policyData.Start_Date__c) > timeNow)) {
                    this.renewPolicyDisabled = true;
                }
                const hhours = Math.floor(rest.quoteData.Start_Time__c / 3600000);
                const mminutes = Math.floor((rest.quoteData.Start_Time__c % 3600000) / 60000);
                const sseconds = Math.floor(((rest.quoteData.Start_Time__c % 3600000) % 60000) / 1000);
                const Firstdate = new Date(rest.quoteData.Start_Date_for_Coverage__c);
                console.log(Firstdate);
                
                const Customdate = new Date(Firstdate.getFullYear(), Firstdate.getMonth(), Firstdate.getDate(), hhours, mminutes, sseconds);
                console.log( Customdate);
                console.log(timeNow > Customdate);

                if (rest.quoteData.Term__c == 'Daily') {    
                
                    let startDatetime = this.calculateDateTime(rest.quoteData.Start_Date_for_Coverage__c,rest.quoteData.Start_Time__c);
                    let endDatetime = this.calculateDateTime(rest.quoteData.End_Date_for_Coverage__c,rest.quoteData.End_Time__c);
                    console.log(startDatetime);
                    console.log(endDatetime);

                    if(timeNow > endDatetime){
                        this.policyExpiredOrTerminated = 'Fully Earned';
                    }
                } else {
                    // for annual & semi-annual
                }
            } else {
                // error -> something went wrong...
                this.spinner = false;
                if (status == 'error') {
                    console.log('Inside Else ::: ', status);
                    let evt = new ShowToastEvent({
                        message: this.label.Oursystemfoundsome ,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    return;
                }
            }
        } catch (error) {
            console.log(error);
            this.spinner = false;
            if (error.status === 500 && error.statusText === 'Server Error') {
                // something went wrong. Please try again...
                let errEvt = new ShowToastEvent({
                    message: this.label.Oursystemfoundsome,
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
                return;
            }
        }
    }

    calculateDateTime(customdate,customtime){
        const hhours = Math.floor(customtime / 3600000);
        const mminutes = Math.floor((customtime % 3600000) / 60000);
        const sseconds = Math.floor(((customtime % 3600000) % 60000) / 1000);
        const Firstdate = new Date(customdate);                
        const Finaldate = new Date(Firstdate.getFullYear(), Firstdate.getMonth(), Firstdate.getDate(), hhours, mminutes, sseconds);
        return Finaldate;
    }

    navigateToLightningComponent() {
        
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: this.PageName,
                recordId: this.recordId
            }
        });
    }

    handleEditClick = () => {
        this.PageName = 'policyEdit__c';
        // this.navigateToLightningComponent();
        sessionStorage.setItem('recordId', this.recordId)
        window.location.href = '/edit/';
        console.log("Edit", this.recordId);
    }

   handleRenewClick = () => {
        console.log('Renew button clicked');
        sessionStorage.setItem('recordId', this.recordId)
        window.location.href = '/renew/';
        //this.PageName = 'Re_new_Policy__c';
        //this.navigateToLightningComponent();
        //console.log(this.PageName, this.recordId);
    }

    handleTerminateClick = () => {
        console.log('Terminate button clicked');
        sessionStorage.setItem('recordId', this.recordId)
        window.location.href = '/terminate';
        // this.PageName = 'terminatepolicy__c';
        // this.navigateToLightningComponent();
        console.log('Terminate ', this.recordId);
    }
    async handleDisplayClick() {
        let actionData = await preViewPdfAction({ 'policyId': this.recordId });
        console.log('--actionData--', actionData);
        if (actionData != null) {
            window.open('/customer'+actionData, "_blank");
        }
    }

    generatePolicyPDF(event){
        console.log('generate Policy PDF ');
        console.log('generate Policy PDF '+this.recordId);

        validateandGenerateQuotePDF({'policyId':this.recordId})
        .then((result)=>{
            console.log(result);
            if(result){
                console.log('Clicked1 ');
                console.log('generate policy green card '+this.recordId);
                window.open(('/apex/'+result+'?id='+this.recordId),'_blank');
            }else{
                let errEvt = new ShowToastEvent({
                    message: 'Cannot generate PDF for the current policy.',
                    title:'Something wrong happened while generating PDF!',
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
            }
        })
        .catch((error)=>{
            console.log('Some error occured');
            console.log(error);
        });
    }

    generatePolicyGreenCard(event){

        console.log('Clicked 2 ');
        console.log('generate policy green card '+this.recordId);

        generateGreenCardfromPolicyId({'policyId':this.recordId})
        .then((result)=>{
            console.log(result);
            if(result){
                window.open(('/apex/renderAsPdf?id='+this.recordId),'_blank');
            }else{
                let errEvt = new ShowToastEvent({
                    message: 'Cannot generate Yellow Card for the current policy',
                    title:'This policy doesn\'t support Yellow Card',
                    variant: 'error',
                });
                this.dispatchEvent(errEvt);
            }
        })
        .catch((error)=>{
            console.log('Some error occured');
            console.log(error);
        });
    }
}