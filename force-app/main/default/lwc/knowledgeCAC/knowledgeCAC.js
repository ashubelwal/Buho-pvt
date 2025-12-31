import { LightningElement, wire, track } from 'lwc';
import getKnowledgeCoverage_and_ClaimsArticles from '@salesforce/apex/KnowledgeController.getKnowledgeCoverage_and_ClaimsArticles';
import { NavigationMixin } from 'lightning/navigation';

export default class KnowledgeWebsiteList extends NavigationMixin(LightningElement) {
    @track articles = [];  // Lista completa de artículos
    @track visibleArticles = [];  // Lista de artículos visibles
    @track displayedCount = 6;  // Cantidad inicial de artículos

    @wire(getKnowledgeCoverage_and_ClaimsArticles)
    wiredArticles({ error, data }) {
        if (data) {
            this.articles = data;
            this.updateVisibleArticles();
        } else if (error) {
            console.error('Error fetching knowledge articles:', error);
        }
    }

    updateVisibleArticles() {
        this.visibleArticles = this.articles.slice(0, this.displayedCount);
    }

    // Mostrar botón de "Show More" si hay más artículos por mostrar
    get showMoreButton() {
        return this.displayedCount < this.articles.length;
    }

    // Mostrar botón de "Show Less" si hay más artículos de los iniciales
    get showLessButton() {
        return this.displayedCount > 6;
    }

    handleShowMore() {
        this.displayedCount = Math.min(this.displayedCount + 6, this.articles.length);  // Evita exceder el límite
        this.updateVisibleArticles();
    }

    handleShowLess() {
        this.displayedCount = 6;  // Volver a la cantidad inicial
        this.updateVisibleArticles();
    }

    handleArticleClick(event) {
        event.preventDefault();
        const articleId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/knowledgeccac?articleId=${articleId}`
            }
        });
    }
}