import { LightningElement ,api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import policyRenewAlert from '@salesforce/apex/PolicyRenewAlertController.fetchPolicy';
import saveRenewDetails from '@salesforce/apex/PolicyRenewAlertController.saveRenewDetails';
import refundCalculation from '@salesforce/apex/PoilcyEditController.refundCalculation';
import getPaymentInfo from '@salesforce/apex/PaymentFormController.getPaymentInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class PolicyRenewAlert extends NavigationMixin(LightningElement) {
    @api recordId;
    refundAmount ='';
    totalStartingDays ='';
    totalDaysLeft ='';
    totalRunningDays ='';
    isStaringDays = false;
    isRunningDays = false;
    isExpired = false;
    policyType;
    totalPremium;
    isDailyPolicy;
    @track isAutoRenewChecked = false;
    @track isShowCardNote = false;
    @track isShowCards = false;
    @track policyRenewConfirmed = false;
    @track updateCardDetails = false;
    @track showCardsOptions = [];
    @track showCardModal = false;
    @track quoteIdsList;
    @track isAnnualPolicy = false;
    selectedCard;
    cardJSON;
    @track isAutoRenewDisabled = false;

    navigateToLightningComponent() {
        sessionStorage.setItem('recordId', this.recordId)
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: this.PageName,
                recordId: this.recordId
            }
        });
    }

    showToastEvent(label, message, variant) {
        const errMsg = new ShowToastEvent({
            title: label,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(errMsg);
    }
    
    connectedCallback(){
        console.log('This Record',this.recordId);
        if(this.recordId != null){
            policyRenewAlert({'policyId':this.recordId}).then((result) => {
                console.log('Result -->',result);
                let data = JSON.parse(result);
                if(data != "ERROR"){
                    console.log('data',data);
                    this.isStaringDays = data?.isStaringDays == "True" ? true : false;
                    this.isRunningDays = data?.isRunningDays == "True" ? true : false;
                    this.isExpired = data?.isExpired == "True" ? true : false;
                    this.totalRunningDays = data.RunningDays;
                    this.totalStartingDays = data.StartingDays;
                    this.totalDaysLeft = data.DaysLeft;
                    this.policyType = data.PolicyType;
                    this.totalPremium = data.TotalPremium;
                    this.isDailyPolicy = data.isDailyPolicy;
                    this.quoteIdsList = data.QuoteID;
                    if((data.TermDays == 'Annual(One Year)' || data.TermDays == 'Annual' || data.TermDays == 'annual') && (data.Status != 'Terminated' && data.Status != 'Expired')){
                        this.isAnnualPolicy = true;
                    }

                    if(data.Autorenew == true && data.paymentProfileId != null){
                        this.isAutoRenewChecked = true;
                        this.getCardsDetails();
                        this.selectedCard = data.paymentProfileId;
                    }
                    
                }
            });

            refundCalculation({ 'policyId': this.recordId }).then((data) => {
                console.log('Data', data);
                let refundObject = data.Data;
                if (data.success) {
                    if (this.policyType != 'Watercraft' && refundObject.daysUsed <= 34) {
                        if(refundObject.policyNotStartedYet == false){
                            this.refundAmount = (this.totalPremium - refundObject.oldPremium).toFixed(2);
                        }else{
                            let totalDeductAmount = parseFloat(refundObject.total.toFixed(2)) + parseFloat(refundObject.brokerFee.toFixed(2));
                            console.log('calculating sum '+totalDeductAmount);
                            this.refundAmount = totalDeductAmount.toFixed(2);
                        }
                        
                        this.refundAmount = parseFloat(this.refundAmount);
                    } else if(this.policyType != 'Watercraft' && refundObject.daysUsed > 34){
                        this.refundAmount = this.totalPremium;
                    }
                }
                console.log('---refundAmount---', this.refundAmount);
            })
        }
        
    }

    handleAutoRenewToggle(event){
        console.log('Event->', event.target.name);
        console.log('Checked->', event.target.checked);
         
        if(event.target.checked){
            console.log('Quote Id-->',this.quoteIdsList);
            this.isAutoRenewChecked = true;
            this.getCardsDetails();
        }else{
            this.isAutoRenewChecked = false;
            this.isShowCards = false;
            this.isShowCardNote = false;
            this.policyRenewConfirmed = false;
            this.isAutoRenewDisabled = true;
            //this.showToastEvent('Auto Renew Canceled', 'The policy auto-renew has been  Canceled', 'warning');
        }
    }

    async getCardsDetails(){
        this.showCardsOptions = [];
            let data;
            let existSelectedCard = false;
            data = await getPaymentInfo({ "quoteIds": this.quoteIdsList});
            let parseData = JSON.parse(data);
            console.log('calling js getPaymentInfo ');
            if (data != null && data != undefined) {
                this.saveCreditCard = parseData.creditCards;
            }
            console.log('calling js getPaymentInfo ',this.saveCreditCard);
            if ((this.saveCreditCard.length > 0 )) {
                
                this.isShowCards = true;
                this.saveCreditCard.forEach(data => {
                    console.log('Data  --',data);
                    this.showCardsOptions.push({'label' : data.cardNumber , 'value': data.cardId});
                    if(data.cardId == this.selectedCard ){
                        existSelectedCard = true;
                    }
                });
                if(existSelectedCard == false && (this.selectedCard != null || this.selectedCard != '')){
                    this.policyRenewConfirmed = false;
                    //this.updateCardDetails = true;
                }else{
                    //this.updateCardDetails = false;
                }
                console.log('this.showCardsOptions--',this.showCardsOptions);
                //this.showToastEvent('Auto Renew ', 'The policy has been set to auto-renew.', 'success');
            }else{
                //this.isAutoRenewChecked = false;
                this.isShowCards = false;
                this.isShowCardNote = true;
                this.showToastEvent('Add card ', 'Please add card for policy auto-renew from Manage Payment', 'warning');
            }
            console.log('---saveCreditCard---', this.saveCreditCard);
    }

    handleSelectedCards(event){
        console.log('name', event.target.name);
        console.log('value', event.target.value);
        this.selectedCard = event.target.value;

    }

    handleManagePayment(){
        console.log('Add new Card Button');
        this.showCardModal = true;
    }

    async closeModal() {
        this.showCardModal = false;
        let data;
        let addNewCardsOptions = [];
        let existSelectedCard = false;
        console.log('In Close Button Modal ');
        console.log('calling js getPaymentInfo ',this.quoteIdsList);
        data = await getPaymentInfo({ "quoteIds": this.quoteIdsList});
        let parseData = JSON.parse(data);
        if (data != null && data != undefined) {
            this.saveCreditCard = parseData.creditCards;
        }
        console.log('calling js getPaymentInfo ',this.saveCreditCard);
        if ((this.saveCreditCard.length > 0 )) {
            console.log('INSIDE DATA : ');
            if(this.isAutoRenewChecked == true){
                this.isShowCards = true;
            }
                this.isShowCardNote = false;
                this.saveCreditCard.forEach(data => {
                console.log('Data  --',data);
                addNewCardsOptions.push({'label' : data.cardNumber , 'value': data.cardId});
                if(data.cardId == this.selectedCard){
                    existSelectedCard = true;
                }

            });
            if(existSelectedCard == false){
                this.selectedCard = null;
                this.policyRenewConfirmed = false;
                //this.updateCardDetails = true;
            }else{
                //this.updateCardDetails = false;
            }
            this.showCardsOptions = addNewCardsOptions;
            console.log('this.showCardsOptions--',this.showCardsOptions);
        }else{
            console.log('NOT DATA : ');
            this.selectedCard = null;
            this.isShowCards = false;
            this.isShowCardNote = true;
            this.policyRenewConfirmed = false;
            this.showToastEvent('Add card ', 'Please add card for policy auto-renew from Manage Payment', 'warning');
        }
        
    }

    closeRenewModal(){
        this.isAutoRenewDisabled = false;
        this.isAutoRenewChecked = true;
        this.isShowCards = true;
        
    }

    handleAutoRenew(){
        this.isAutoRenewDisabled = false;
        console.log('Handle Auto Renew--');
        let cardDetails;
        this.saveCreditCard.filter((data) => {
            if(data.cardId == this.selectedCard){
                this.isShowCardNote = false;
                cardDetails = data;
            }
        });
        console.log('Card Details---> ', cardDetails);
        console.log('cardJson', JSON.stringify(cardDetails));
        console.log('this.isAutoRenewChecked', this.isAutoRenewChecked);
        console.log('this.selectedCard', this.selectedCard);

        if(this.isAutoRenewChecked == true && this.selectedCard != null && (cardDetails != null || cardDetails != '' ) && (this.recordId != null || this.recordId != '')){
            console.log('AUTO RENER TRUE----');
            saveRenewDetails({'cardJson' : JSON.stringify(cardDetails) , 'policyId' : this.recordId, 'profileId': this.selectedCard, 'autoRenew': true});
            this.showToastEvent('Auto Renew ', 'The policy has been set to auto-renew.', 'success');
            this.policyRenewConfirmed = true;
        }else if(this.isAutoRenewChecked == false){
            this.selectedCard = null;
            console.log('AUTO RENER FALSE----');
            saveRenewDetails({'cardJson' : '' , 'policyId' : this.recordId, 'profileId': '', 'autoRenew': false});
            this.showToastEvent('Auto Renew Disabled', 'Policy Auto renew has been disabled', 'success');
        }else{
            console.log('AUTO RENER ELSEE----');
            this.showToastEvent('Select card ', 'Please select a card for auto-renew', 'error');
        }
        
    }
}