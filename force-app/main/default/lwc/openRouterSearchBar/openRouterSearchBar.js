import { LightningElement, track } from 'lwc';
import getChatResponse from '@salesforce/apex/OpenRouterAPI.getChatResponse';

export default class OpenRouterChat extends LightningElement {
    @track query = '';     // Consulta del usuario
    @track messages = [];  // Historial de mensajes
    @track isLoading = false; // Indicador de carga

    // Maneja el cambio en el input
    handleInputChange(event) {
        this.query = event.target.value;
    }

    // Llama al método Apex para obtener la respuesta
    handleSearch() {
        if (this.query.trim() === '') {
            console.error('Please enter a question.');
            return;
        }

        this.isLoading = true; // Muestra la animación de carga

        const userMessage = { 
            id: Date.now(), 
            role: 'User', 
            content: this.query,
            cssClass: 'message user'  
        };
        this.messages = [...this.messages, userMessage]; 

        getChatResponse({ userMessage: this.query })
            .then(result => {
                console.log('AI Response:', result);
                const aiMessage = { 
                    id: Date.now(), 
                    role: 'AI', 
                    content: result,
                    cssClass: 'message ai' 
                };
                this.messages = [...this.messages, aiMessage]; 
                this.query = ''; 

                // 🔹 Forzar scroll al último mensaje
                this.scrollToBottom();
            })
            .catch(error => {
                console.error('Error calling AI:', error);
                const errorMessage = { 
                    id: Date.now(), 
                    role: 'AI', 
                    content: 'Error retrieving response.', 
                    cssClass: 'message ai' 
                };
                this.messages = [...this.messages, errorMessage];

                // 🔹 Forzar scroll incluso en errores
                this.scrollToBottom();
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // 🔹 Método para hacer scroll automático
    scrollToBottom() {
        setTimeout(() => {
            const chatHistory = this.template.querySelector('.chat-history');
            if (chatHistory) {
                chatHistory.scrollTop = chatHistory.scrollHeight;
            }
        }, 100);
    }
}