import { LightningElement, track } from 'lwc';
import searchKnowledgeArticles from '@salesforce/apex/KnowledgeController.searchKnowledgeArticles';

export default class KnowledgeSearch extends LightningElement {
    @track searchTerm = '';  // Guarda el texto de búsqueda
    @track articles = [];    // Lista de artículos
    @track selectedArticleId = null; // ID del artículo seleccionado

    handleSearch(event) {
        this.searchTerm = event.target.value.trim();  // 🔹 Elimina espacios extra
        this.selectedArticleId = null; // 🔹 Resetea el artículo seleccionado al buscar otra vez

        if (this.searchTerm.length > 0) {  // 🔹 Busca desde la primera letra
            searchKnowledgeArticles({ searchText: this.searchTerm.toLowerCase() }) // 🔹 Envía minúsculas
                .then(data => {
                    this.articles = data;
                })
                .catch(error => {
                    console.error('Error fetching Knowledge Articles', error);
                    this.articles = [];
                });
        } else {
            this.articles = [];
        }
    }

    handleSelect(event) {
        this.selectedArticleId = event.currentTarget.dataset.id; // Guarda el ID del artículo
        this.searchTerm = event.currentTarget.innerText; // Completa el texto en el input
        this.articles = []; // Oculta la lista después de seleccionar un artículo
    }

    handleSearchButtonClick() {
        if (this.selectedArticleId) {
            window.location.href = `/support/knowledgedetails?articleId=${this.selectedArticleId}`;
            return;
        }

        console.log('📩 Intentando abrir el chat con búsqueda:', this.searchTerm);

        if (window.embedded_svc && window.embedded_svc.liveAgentAPI) {
            try {
                window.embedded_svc.liveAgentAPI.openChat();
                console.log('✅ Chat abierto correctamente.');

                setTimeout(() => {
                    if (window.embedded_svc.liveAgentAPI.sendMessage) {
                        window.embedded_svc.liveAgentAPI.sendMessage(this.searchTerm);
                        console.log('📩 Mensaje enviado al chat:', this.searchTerm);
                    } else {
                        console.warn('⚠️ No se pudo enviar el mensaje porque sendMessage() no está disponible.');
                    }
                }, 1500);
            } catch (error) {
                console.warn('❌ Error intentando abrir el chat:', error);
            }
        } else {
            console.warn('⚠️ embedded_svc no está disponible.');
        }
    }
}