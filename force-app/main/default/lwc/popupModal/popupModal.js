import  LightningModal  from 'lightning/modal';

export default class PopupModal extends LightningModal  {
    closeModal(event){
        const evet = new CustomEvent('closemodal',{
            'detail':false
        });
        this.dispatchEvent(evet);
    }

    handleCancel(event){
        this.close(false);
    }

    handleContinue(event) {
        this.close(true);
    }

}