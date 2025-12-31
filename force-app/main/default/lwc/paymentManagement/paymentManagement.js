import { LightningElement, api, track } from 'lwc';
import LightningConfirm from "lightning/confirm";
import removeCardFromCustomerprofile from '@salesforce/apex/SavedCardController.removeCardFromCustomerprofile';
import getCardDetailsByProfileId from '@salesforce/apex/SavedCardController.getCardDetailsByProfileId';
import getCardDetialsByContact from '@salesforce/apex/SavedCardController.getCardDetialsByContact';
import updatePolicyOnCardRemove from '@salesforce/apex/PolicyRenewAlertController.updatePolicyOnCardRemove';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PaymentManagement extends LightningElement {
  @track savedCards;
  expiredCards;
  @api addNewCardScreen = false;

  performingOpration = false;

  allCardsZero = false;
  expiredCardsZero = false;

  savedCardsLoaded = false
  actionType = '';
  paymentIdEdit = '';
  selectedCardData = []


  async handleConfirmClick(event) {
    const selectedId = event.target.dataset.id;
    console.log('handleConfirmClick: selectedId in event', selectedId);
    const result = await LightningConfirm.open({
      message: "Are you sure you want to delete this?",
      variant: "default",
      label: "Delete a record"
    });
    if (result) {
      if (selectedId != '') {
        let cardNotExist = false;
          this.savedCards.find(async item => {
          console.log(selectedId);
          console.log(item.customerPaymentProfileId);
          console.log(item.isAutoRenewal);
          if (item.customerPaymentProfileId == selectedId ) {
            console.log('truee---');
              cardNotExist = true;
              const results = await LightningConfirm.open({
              message: "Deleting this card will disable auto-renewal for the policy. Are you sure you want to proceed with the deletion?",
              variant: "default",
              label: "Delete a record"
            });

            if (results) {
              this.handleRemoveCard(selectedId);
            }
            else {
              return null;
            }
          } 
        })

        if(cardNotExist == false){
          console.log('cardNotExist FALSE--',cardNotExist);
          this.handleRemoveCard(selectedId);
        }


      } else {
        const evt = new ShowToastEvent({
          message: "We are Not able to delete the card.",
          variant: 'error',
        });
        this.dispatchEvent(evt);
      }
    }
  }

  newAddedCard(event) {
    console.log('In the newAddedCard parent')
    console.log(event.detail);
    this.fetchSavedCards();
  }

  handleCloseCardScreen = (event) => {
    console.log('Closing card screen')
    console.log(event.detail)
    console.log(event.detail?.Status)
    this.addNewCardScreen = false;
  }

  hanldeCardOprations = (event) => {
    this.actionType = event.target.dataset.btntype;
    console.log(this.actionType);
    if (this.actionType != '') {

      if (this.actionType == "editCard") {
        this.paymentIdEdit = event.target.dataset.id;
        const matchedCard = this.savedCards.filter(card => (card.customerPaymentProfileId == this.paymentIdEdit))
        if (matchedCard) {
          this.selectedCardData = matchedCard[0];
        }
        console.log('Selected card for edit')
        console.log(matchedCard)
      }

      this.addNewCardScreen = true;
    } else {
      console.log('Not getting any action type')
    }

  }

  handleRemoveCard = (selectedId) => {
    this.performingOpration = true;
    removeCardFromCustomerprofile({ paymentProfileId: selectedId }).
      then(result => {
        let res = JSON.parse(result);
        console.log('Deleted' + res);
        console.log(res);
        if (res.messages.resultCode == 'Ok') {
          const evt = new ShowToastEvent({
            message: "Selected card is removed!!!",
            variant: 'success',
          });
          this.dispatchEvent(evt);
          this.fetchSavedCards();
          this.performingOpration = false;

          updatePolicyOnCardRemove({ paymentId: selectedId });
        } else {
          const evt = new ShowToastEvent({
            message: res.messages?.message[0]?.text ? res.messages?.message[0]?.text : "We are facing some issue😌",
            variant: 'error',
          });
          this.dispatchEvent(evt);
          this.performingOpration = false;
        }
      }).
      catch(error => {
        const evt = new ShowToastEvent({
          message: "We are facing some issue",
          variant: 'error',
        });
        this.dispatchEvent(evt);
        console.log(error)
      })
  }

  async fetchSavedCards() {
    this.savedCardsLoaded = false;
    await getCardDetailsByProfileId().
      then(result => {
        if (JSON.parse(result).messages?.resultCode == "Ok") {
          this.savedCards = JSON.parse(result).messages?.message?.allCards;
          this.expiredCards = JSON.parse(result).messages?.message?.expiredCards;

          if (this.savedCards.length == 0) {
            this.allCardsZero = true
          } else {
            this.allCardsZero = false
          }

          if (this.expiredCards.length == 0) {
            this.expiredCardsZero = true;
          } else {
            this.expiredCardsZero = false;
          }

          console.log(this.allCardsZero)
          console.log(this.expiredCardsZero)
        } else {
          const evt = new ShowToastEvent({
            message: "We are unable to fetch cards.",
            variant: 'error',
          });
          this.dispatchEvent(evt);
        }
        this.savedCardsLoaded = true;
      }).
      catch(error => {
        this.savedCardsLoaded = true;
        const evt = new ShowToastEvent({
          message: "We are unable to fetch cards.",
          variant: 'error',
        });
        this.dispatchEvent(evt);
        console.log(error)
      })

    await getCardDetialsByContact().then(result => {
      console.log('POLICY AND CARDIDS--');
      console.log(result);
      console.log(this.savedCards);
      const resultArray = Object.entries(result);

      resultArray.forEach(([label, value]) => {
        this.savedCards.find(item => {
          
          console.log('label---',label);
          console.log('Item---',item.customerPaymentProfileId);
          if (item.customerPaymentProfileId === label) {
            item.isAutoRenewal = true;
            item.policyNames = { 'Policy': [] };
            const data = Object.entries(value);
            data.forEach(([label, value]) => {
                item.policyNames.Policy.push({ 'label': value, 'value': label });
            });
            console.log(item);
          } 
        });
      });

    });
    console.log('AFTER UPDATE SAVED CARDS');
    console.log(this.savedCards);
  }

  connectedCallback() {
    this.fetchSavedCards();
  }

  handlePolicyselect(event) {
    console.log('handlePolicyselect--');
    console.log(event.detail.value);
    let currentUrl = window.location.origin;
    console.log(currentUrl);
    window.open(`${currentUrl}/s/policy/${event.detail.value}`)
  }

}