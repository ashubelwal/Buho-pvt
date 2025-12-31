import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getKnowledgeArticles from '@salesforce/apex/KnowledgeController.getKnowledgeArticles';
import { NavigationMixin } from 'lightning/navigation';

export default class GeneralKnowledges extends NavigationMixin(LightningElement) {
    @track articles = [];  // Lista completa de artículos
    @track visibleArticles = [];  // Solo los visibles
    @track displayedCount = 6;  // Cantidad de artículos mostrados
    articleId = null; // ID del artículo seleccionado a excluir

    // Obtener el parámetro de la URL (articleId)
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.articleId = currentPageReference.state.articleId;
            this.updateVisibleArticles(); // Actualiza la lista después de obtener el ID
        }
    }

    // Obtener los artículos desde Apex
    @wire(getKnowledgeArticles)
    wiredArticles({ error, data }) {
        if (data) {
            this.articles = data;
            this.updateVisibleArticles();
        } else if (error) {
            console.error('Error fetching knowledge articles:', error);
        }
    }

    updateVisibleArticles() {
        if (!this.articles.length) return;

        // Filtrar el artículo seleccionado y limitar la cantidad de visibles
        this.visibleArticles = this.articles
            .filter(article => article.Id !== this.articleId) // 🔥 Filtra el artículo seleccionado
            .slice(0, this.displayedCount);
    }

    get showMoreButton() {
        return this.displayedCount < this.articles.length;
    }

    handleShowMore() {
        this.displayedCount += 6;  // Aumentar la cantidad de artículos mostrados
        this.updateVisibleArticles();
    }

    handleArticleClick(event) {
        event.preventDefault();
        const selectedId = event.target.dataset.id;

        // Redirigir y pasar el ID como parámetro en la URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/knowledgedetails?articleId=${selectedId}`
            }
        });
    }
}