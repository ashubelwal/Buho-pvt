import { LightningElement, wire, track } from 'lwc';
import getKnowledgeWebsiteArticles from '@salesforce/apex/KnowledgeController.getKnowledgeWebsiteArticles';
import { NavigationMixin } from 'lightning/navigation';

export default class WebsiteKnowledges extends NavigationMixin(LightningElement) {
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

    @wire(getKnowledgeWebsiteArticles)
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

    fixLinks(container) {
        const links = container.querySelectorAll('a');
        links.forEach(link => {
            link.setAttribute('target', '_blank');
            link.setAttribute('rel', 'noopener noreferrer');
        });
    }
}