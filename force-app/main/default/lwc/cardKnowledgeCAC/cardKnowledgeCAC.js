import { LightningElement, wire, track } from 'lwc';
import getKnowledgeCoverage_and_ClaimsArticles from '@salesforce/apex/KnowledgeController.getKnowledgeCoverage_and_ClaimsArticles';
import { NavigationMixin } from 'lightning/navigation';

export default class CACKnowledges extends NavigationMixin(LightningElement) {
    @track articles = [];
    @track visibleArticles = [];
    @track displayedCount = 6;
    @track selectedArticle = null;

    get showMoreButton() {
        return this.articles.length > this.displayedCount;
    }

    get showLessButton() {
        return this.displayedCount > 6;
    }

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

    handleShowMore() {
        this.displayedCount += 6;
        this.updateVisibleArticles();
    }

    handleShowLess() {
        if (this.displayedCount > 6) {
            this.displayedCount -= 6;
            this.updateVisibleArticles();
        }
    }

    handleArticleClick(event) {
        event.preventDefault();
        const articleId = event.currentTarget.dataset.id;
        this.selectedArticle = this.articles.find(article => article.Id === articleId);
        this.renderArticleBody();
    }

    handleCloseArticle() {
        this.selectedArticle = null;
    }

    renderedCallback() {
        this.renderArticleBody();
    }

    renderArticleBody() {
        if (this.selectedArticle && this.selectedArticle.Article_Body__c) {
            const articleContainer = this.template.querySelector('.article-body');
            if (articleContainer) {
                articleContainer.innerHTML = this.selectedArticle.Article_Body__c;
                this.fixLinks(articleContainer);
            }
        }
    }

    showModal() {
        const modalOverlay = this.template.querySelector('.modal-overlay');
        if (modalOverlay) {
            modalOverlay.style.display = 'flex';
        }
    }

    hideModal() {
        const modalOverlay = this.template.querySelector('.modal-overlay');
        if (modalOverlay) {
            modalOverlay.style.display = 'none';
        }
    }

    fixLinks(container) {
        const links = container.querySelectorAll('a');
        links.forEach(link => {
            link.setAttribute('target', '_blank');
            link.setAttribute('rel', 'noopener noreferrer');
        });
    }
}