import { LightningElement } from 'lwc';

export default class ChatLauncher extends LightningElement {
    inputValue = '';

    handleInputChange(event) {
        this.inputValue = event.target.value;  // Captura el valor del textarea
    }

    handleChatOpen() {
        if (this.inputValue.trim() === '') {
            alert('Por favor ingrese un mensaje antes de abrir el chat.');
            return;
        }

        // Verificar que el chat de Embedded Service esté disponible
        if (window.embedded_svc) {
            embedded_svc.prechatAPI.setCustomDetails([
                {
                    label: 'Mensaje Inicial',
                    value: this.inputValue,
                    transcriptFields: ['MensajeInicial__c']
                }
            ]);

            // Abrir el chat automáticamente
            embedded_svc.openChat();
        } else {
            alert('El chat no está disponible en este momento.');
        }
    }
}